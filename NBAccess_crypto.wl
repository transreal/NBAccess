(* ::Package:: *)

(* ============================================================
   NBAccess_crypto.wl -- NBAccess crypto 鍵隔離層 (Phase SV-E3 step 3)

   This file is encoded in UTF-8.
   Load via: Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess_crypto.wl"]]

   仕様: SourceVault encryption spec v18 / review v18

   原則 (鍵隔離境界):
     - 鍵材料は NBAccess の外へ返さない。NB*WithKeyRef は keyRef を受け取り、
       内部で鍵を解決して暗号操作を行い、結果 (暗号文 / MAC / 真偽) だけを返す。
     - 鍵解決 iNB* は NBAccess`Private` に閉じ、公開しない。
     - KeyRef index は鍵材料を含まず、purpose / algorithm / fingerprint /
       created / status / backend だけを持つ。

   鍵ストア backend:
     $NBCredentialBackend = "Memory"  (既定。in-kernel。テスト/開発用。同期されない)
                          | "SystemCredential"  (本番想定。書き込み API は TODO)
     本フェーズでは Memory backend を完全実装・検証する。
     SystemCredential 永続 backend は credential 書き込み API 確認後に有効化する。

   実装する公開 API:
     NBStoreCredentialKey / NBKeyStatus / NBListCredentialKeyRefs / NBDeleteCredentialKey
     NBGenerateSymmetricKeyRef / NBGenerateMacKeyRef / NBGenerateAsymmetricKeyRefPair
     NBEncryptWithKeyRef / NBDecryptWithKeyRef
     NBMacWithKeyRef / NBVerifyMacWithKeyRef
     NBGetPublicKeyForKeyRef          (公開鍵は秘密でないので返してよい)
     NBCryptoSelfTest
   ============================================================ *)

BeginPackage["NBAccess`"];

NBStoreCredentialKey::usage = "NBStoreCredentialKey[keyRef, keyObject, metadata] は鍵を直列化して backend に保存し、鍵材料を含まない index entry を作る。";
NBKeyStatus::usage = "NBKeyStatus[keyRef] は鍵の metadata (鍵材料を含まない) を返す。存在しなければ Missing。";
NBListCredentialKeyRefs::usage = "NBListCredentialKeyRefs[pattern_:\"*\"] は登録済み keyRef の一覧を返す (鍵材料は含まない)。";
NBDeleteCredentialKey::usage = "NBDeleteCredentialKey[keyRef] は鍵を削除する。";
NBGenerateSymmetricKeyRef::usage = "NBGenerateSymmetricKeyRef[keyRef, metadata_:<||>] は AES256 対称鍵を生成して keyRef に保存する。";
NBGenerateMacKeyRef::usage = "NBGenerateMacKeyRef[keyRef, metadata_:<||>] は 256bit ランダム MAC 鍵を生成して keyRef に保存する。";
NBGenerateAsymmetricKeyRefPair::usage = "NBGenerateAsymmetricKeyRefPair[keyRef, metadata_:<||>] は RSA 鍵対を生成し、秘密鍵を keyRef に保存する。公開鍵は index に保持する。";
NBEncryptWithKeyRef::usage = "NBEncryptWithKeyRef[keyRef, plaintextBytes, purpose_:None, accessSpec_:Automatic] は対称鍵で暗号化し、Base64 化した直列 EncryptedObject を返す。鍵は返さない。";
NBDecryptWithKeyRef::usage = "NBDecryptWithKeyRef[keyRef, ciphertextB64, purpose_:None, accessSpec_:Automatic] は復号して ByteArray を返す。失敗時は $Failed。";
NBMacWithKeyRef::usage = "NBMacWithKeyRef[keyRef, bytes, purpose_:None, accessSpec_:Automatic] は HMAC-SHA256 を hex で返す。";
NBVerifyMacWithKeyRef::usage = "NBVerifyMacWithKeyRef[keyRef, bytes, macHex, purpose_:None, accessSpec_:Automatic] は MAC を constant-time 比較で検証する。";
NBGetPublicKeyForKeyRef::usage = "NBGetPublicKeyForKeyRef[keyRef] は非対称鍵対の公開鍵 (秘密でない) を返す。";
NBCryptoSelfTest::usage = "NBCryptoSelfTest[] は鍵隔離・暗号/MAC roundtrip・誤鍵検出を検査する。";
NBExportWrappedKeys::usage = "NBExportWrappedKeys[keyRefs, wrapKey] は各鍵オブジェクトを wrapKey (SymmetricKey) で暗号化した EncryptedObject と非秘密 index meta だけを返す。平文鍵材料は決して返さない (可搬な鍵バンドル用の内部プリミティブ)。";
NBImportWrappedKeys::usage = "NBImportWrappedKeys[wrappedAssoc, wrapKey] は wrapKey で復号した鍵オブジェクトを現 backend の credential store に書き戻す。BinaryDeserialize のみ (ToExpression 不使用)。復元した keyRef のリストを返す。";

$NBCredentialBackend::usage = "$NBCredentialBackend は鍵ストア backend (\"Memory\" | \"SystemCredential\")。既定 \"Memory\"。";

Begin["`Private`"];

If[! ValueQ[$NBCredentialBackend], $NBCredentialBackend = "Memory"];

(* in-kernel backend state (Memory). 鍵材料 (Base64) と index を分離して保持。 *)
If[! AssociationQ[$iNBKeyMaterial], $iNBKeyMaterial = <||>];
If[! AssociationQ[$iNBKeyIndex], $iNBKeyIndex = <||>];

(* ---- HMAC-SHA256 (RFC 2104) -- WL に組み込み HMAC が無いため自前構成 ---- *)
$iNBHashBlock = 64;
iNBSha256Bytes[ba_ByteArray] := Module[{r},
  r = Quiet@Check[Hash[ba, "SHA256", "ByteArray"], $Failed];
  If[Head[r] === ByteArray, r, ByteArray[IntegerDigits[Hash[ba, "SHA256"], 256, 32]]]];
iNBJoin[a_ByteArray, b_ByteArray] := ByteArray[Join[Normal[a], Normal[b]]];
iNBHMAC[keyBA_ByteArray, msgBA_ByteArray] := Module[{k0, kp, ip, op, inner},
  k0 = If[Length[keyBA] > $iNBHashBlock, iNBSha256Bytes[keyBA], keyBA];
  kp = PadRight[Normal[k0], $iNBHashBlock, 0];
  ip = ByteArray[BitXor[#, 54] & /@ kp];
  op = ByteArray[BitXor[#, 92] & /@ kp];
  inner = iNBSha256Bytes[iNBJoin[ip, msgBA]];
  iNBSha256Bytes[iNBJoin[op, inner]]];
iNBHMACHex[keyBA_ByteArray, msgBA_ByteArray] :=
  StringJoin[IntegerString[#, 16, 2] & /@ Normal[iNBHMAC[keyBA, msgBA]]];
iNBConstEq[a_String, b_String] :=
  StringLength[a] === StringLength[b] &&
   BitOr @@ MapThread[BitXor, {ToCharacterCode[a], ToCharacterCode[b]}] === 0;

iNBFingerprint[keyObject_] :=
  StringTake[
   StringJoin[IntegerString[#, 16, 2] & /@ Normal[iNBSha256Bytes[BinarySerialize[keyObject]]]],
   16];

(* ---- backend 読み書き (鍵材料) ----
   Memory         : in-kernel $iNBKeyMaterial (テスト/開発。同期されない)
   SystemCredential: OS credential store に永続化。
                     - 鍵材料は per-key credential (名前は colon を sanitize)
                     - index (metadata のみ、鍵材料なし) も 1 つの credential blob に永続化し、
                       再起動後も NBKeyStatus / bootstrap idempotency が効くようにする。
   SystemCredential[name] = v / SystemCredential[name] / SystemCredential[name] =. が API
   (WL 14.3 で確認)。 *)

iNBCredName[keyRef_String] :=
  "SourceVault__k__" <> StringReplace[keyRef, RegularExpression["[^A-Za-z0-9]"] -> "_"];
$iNBIndexCredName = "SourceVault__keyindex__v1";

iNBSysGet[name_String] :=
  Module[{v}, v = Quiet@Check[SystemCredential[name], $Failed];
    If[MissingQ[v] || v === $Failed, $Failed, v]];

(* index (metadata のみ) を credential blob に永続化 / 復元。鍵材料は含まない。 *)
iNBPersistIndex[] := If[$NBCredentialBackend === "SystemCredential",
  Quiet@Check[
    SystemCredential[$iNBIndexCredName] = BaseEncode[BinarySerialize[$iNBKeyIndex]];, Null]];

If[! ValueQ[$iNBIndexLoaded], $iNBIndexLoaded = False];
iNBEnsureIndexLoaded[] := If[$NBCredentialBackend === "SystemCredential" && ! $iNBIndexLoaded,
  Module[{blob, idx},
    blob = iNBSysGet[$iNBIndexCredName];
    If[StringQ[blob],
      idx = Quiet@Check[BinaryDeserialize[BaseDecode[blob]], $Failed];
      If[AssociationQ[idx], $iNBKeyIndex = idx]];
    $iNBIndexLoaded = True]];

iNBBackendPut[keyRef_String, b64_String] :=
  Switch[$NBCredentialBackend,
    "Memory", AssociateTo[$iNBKeyMaterial, keyRef -> b64]; True,
    "SystemCredential", Quiet@Check[SystemCredential[iNBCredName[keyRef]] = b64; True, $Failed],
    _, $Failed];

iNBBackendGet[keyRef_String] :=
  Switch[$NBCredentialBackend,
    "Memory", Lookup[$iNBKeyMaterial, keyRef, $Failed],
    "SystemCredential", iNBSysGet[iNBCredName[keyRef]],
    _, $Failed];

iNBBackendDelete[keyRef_String] :=
  Switch[$NBCredentialBackend,
    "Memory", $iNBKeyMaterial = KeyDrop[$iNBKeyMaterial, keyRef]; True,
    "SystemCredential", Quiet@Check[SystemCredential[iNBCredName[keyRef]] =.; True, $Failed],
    _, $Failed];

(* ---- 鍵解決 (内部のみ。鍵材料を返すので絶対に公開しない) ---- *)
iNBResolveKeyObject[keyRef_String] := Module[{b64, bytes},
  iNBEnsureIndexLoaded[];
  b64 = iNBBackendGet[keyRef];
  If[! StringQ[b64], Return[$Failed]];
  bytes = Quiet@Check[BaseDecode[b64], $Failed];
  If[Head[bytes] =!= ByteArray, Return[$Failed]];
  (* BinaryDeserialize のみ。ToExpression は使わない。 *)
  Quiet@Check[BinaryDeserialize[bytes], $Failed]];

(* ---- 公開 API: 鍵保存 / 生成 ---- *)
NBStoreCredentialKey[keyRef_String, keyObject_, metadata_Association : <||>] :=
  Module[{b64, kind},
    iNBEnsureIndexLoaded[];
    b64 = BaseEncode[BinarySerialize[keyObject]];
    iNBBackendPut[keyRef, b64];
    kind = Switch[Head[keyObject],
      SymmetricKey, "SymmetricKey", PrivateKey, "PrivateKey",
      PublicKey, "PublicKey", ByteArray, "MacKey", _, "Unknown"];
    AssociateTo[$iNBKeyIndex, keyRef -> Join[<|
       "KeyRef" -> keyRef, "Kind" -> kind, "Backend" -> $NBCredentialBackend,
       "Fingerprint" -> iNBFingerprint[keyObject],
       "Status" -> "Active", "CreatedAt" -> DateString["ISODateTime"],
       (* 公開鍵は秘密でないので非対称鍵生成時に metadata 経由で渡す。
          PrivateKey オブジェクトから ["PublicKey"] は取得できないため、ここでは置かない。 *)
       "PublicKey" -> Missing["NotApplicable"]
       |>, metadata]];
    iNBPersistIndex[];
    <|"Status" -> "Stored", "KeyRef" -> keyRef, "KeyMaterialReturned" -> False|>];

NBGenerateSymmetricKeyRef[keyRef_String, metadata_Association : <||>] :=
  NBStoreCredentialKey[keyRef, GenerateSymmetricKey[],
    Join[<|"Purpose" -> "SymmetricAtRest", "Algorithm" -> "AES256"|>, metadata]];

NBGenerateMacKeyRef[keyRef_String, metadata_Association : <||>] :=
  NBStoreCredentialKey[keyRef, ByteArray[RandomInteger[{0, 255}, 32]],
    Join[<|"Purpose" -> "HMAC", "Algorithm" -> "HMAC-SHA256"|>, metadata]];

NBGenerateAsymmetricKeyRefPair[keyRef_String, metadata_Association : <||>] :=
  Module[{kp},
    kp = GenerateAsymmetricKeyPair[];
    NBStoreCredentialKey[keyRef, kp["PrivateKey"],
      Join[<|"Purpose" -> "Asymmetric", "Algorithm" -> "RSA",
         "PublicKey" -> BaseEncode[BinarySerialize[kp["PublicKey"]]]|>, metadata]]];

(* ---- 公開 API: 状態 / 一覧 / 削除 (鍵材料を含まない) ---- *)
NBKeyStatus[keyRef_String] := (iNBEnsureIndexLoaded[];
  Lookup[$iNBKeyIndex, keyRef, Missing["NotFound"]]);

NBListCredentialKeyRefs[pattern_String : "*"] := (iNBEnsureIndexLoaded[];
  Select[Keys[$iNBKeyIndex], StringMatchQ[#, pattern] &]);

NBDeleteCredentialKey[keyRef_String, opts : OptionsPattern[]] := (
  iNBEnsureIndexLoaded[];
  iNBBackendDelete[keyRef];
  $iNBKeyIndex = KeyDrop[$iNBKeyIndex, keyRef];
  iNBPersistIndex[];
  <|"Status" -> "Deleted", "KeyRef" -> keyRef|>);

(* ---- 公開 API: 暗号操作 (鍵は内部で解決し、返さない) ---- *)
NBEncryptWithKeyRef[keyRef_String, plaintextBytes_ByteArray, purpose_ : None, accessSpec_ : Automatic] :=
  Module[{k, enc},
    k = iNBResolveKeyObject[keyRef];
    If[Head[k] =!= SymmetricKey, Return[$Failed]];
    enc = Quiet@Check[Encrypt[k, plaintextBytes], $Failed];
    If[Head[enc] =!= EncryptedObject, Return[$Failed]];
    <|"Status" -> "Ok", "KeyRef" -> keyRef,
      "CiphertextB64" -> BaseEncode[BinarySerialize[enc]],
      "IV" -> Quiet@Check[BaseEncode[enc[[1]]["InitializationVector"]], Missing["NoIV"]]|>];

NBDecryptWithKeyRef[keyRef_String, ciphertextB64_String, purpose_ : None, accessSpec_ : Automatic] :=
  Module[{k, enc, pt},
    k = iNBResolveKeyObject[keyRef];
    If[Head[k] =!= SymmetricKey, Return[$Failed]];
    enc = Quiet@Check[BinaryDeserialize[BaseDecode[ciphertextB64]], $Failed];
    If[Head[enc] =!= EncryptedObject, Return[$Failed]];
    pt = Quiet@Check[Decrypt[k, enc], $Failed];
    If[Head[pt] === ByteArray, pt, $Failed]];

NBMacWithKeyRef[keyRef_String, bytes_ByteArray, purpose_ : None, accessSpec_ : Automatic] :=
  Module[{k},
    k = iNBResolveKeyObject[keyRef];
    If[Head[k] =!= ByteArray, Return[$Failed]];
    iNBHMACHex[k, bytes]];

NBVerifyMacWithKeyRef[keyRef_String, bytes_ByteArray, macHex_String, purpose_ : None, accessSpec_ : Automatic] :=
  Module[{got},
    got = NBMacWithKeyRef[keyRef, bytes, purpose, accessSpec];
    StringQ[got] && iNBConstEq[got, macHex]];

NBGetPublicKeyForKeyRef[keyRef_String] := Module[{idx, b64},
  idx = NBKeyStatus[keyRef];
  If[! AssociationQ[idx], Return[$Failed]];
  b64 = Lookup[idx, "PublicKey", Missing[]];
  If[! StringQ[b64], Return[$Failed]];
  Quiet@Check[BinaryDeserialize[BaseDecode[b64]], $Failed]];

(* ---- self test ---- *)
NBCryptoSelfTest[] := Module[
  {save, encRef, macRef, pt, encR, dec, mac, badBytes, asymRef, pub, exportedSymbols},
  (* 隔離した一時 backend で実行 (ユーザーの実鍵を汚さない) *)
  save = {$iNBKeyMaterial, $iNBKeyIndex, $NBCredentialBackend};
  $iNBKeyMaterial = <||>; $iNBKeyIndex = <||>; $NBCredentialBackend = "Memory";

  encRef = "NBTest:enc:v1"; macRef = "NBTest:mac:v1"; asymRef = "NBTest:sign:v1";
  NBGenerateSymmetricKeyRef[encRef];
  NBGenerateMacKeyRef[macRef];
  NBGenerateAsymmetricKeyRefPair[asymRef];

  pt = StringToByteArray["秘密の本文 payload", "UTF-8"];
  encR = NBEncryptWithKeyRef[encRef, pt];
  dec = NBDecryptWithKeyRef[encRef, encR["CiphertextB64"]];
  mac = NBMacWithKeyRef[macRef, pt];
  badBytes = StringToByteArray["改ざんされた payload", "UTF-8"];
  pub = NBGetPublicKeyForKeyRef[asymRef];

  (* 鍵材料が API 戻り値・index に出ていないこと *)
  exportedSymbols = <|
    "EncryptResultHasNoKey" -> FreeQ[encR, _SymmetricKey],
    "KeyStatusHasNoMaterial" ->
      (FreeQ[NBKeyStatus[encRef], _SymmetricKey] &&
       FreeQ[NBKeyStatus[asymRef], _PrivateKey] &&
       ! KeyExistsQ[NBKeyStatus[encRef], "PrivateExponent"]),
    "PublicKeyResolvable" -> (Head[pub] === PublicKey)
  |>;

  With[{result = <|
     "EncryptRoundtrip" -> (Head[dec] === ByteArray && dec === pt),
     "MacRoundtrip" -> NBVerifyMacWithKeyRef[macRef, pt, mac],
     "MacRejectsTamper" -> (! NBVerifyMacWithKeyRef[macRef, badBytes, mac]),
     "WrongMacKeyFails" -> (NBMacWithKeyRef[encRef, pt] === $Failed),
     "DecryptWrongTypeFails" -> (NBDecryptWithKeyRef[macRef, encR["CiphertextB64"]] === $Failed),
     "KeyIsolation" -> AllTrue[Values[exportedSymbols], TrueQ],
     "ListWorks" -> (Length[NBListCredentialKeyRefs["NBTest:*"]] === 3),
     "DeleteWorks" -> (NBDeleteCredentialKey[encRef];
        NBKeyStatus[encRef] === Missing["NotFound"])|>},
   (* restore *)
   {$iNBKeyMaterial, $iNBKeyIndex, $NBCredentialBackend} = save;
   Append[result, "AllPassed" -> AllTrue[Values[result], TrueQ]]]
  ];

(* ---- 可搬鍵バンドル用プリミティブ (出力は ciphertext のみ。平文鍵材料は返さない) ----
   wrapKey は呼び出し側 (SourceVault_keybundle) が passphrase から scrypt 派生した
   SymmetricKey。ここでは鍵オブジェクトを BinarySerialize -> Encrypt[wrapKey, .] するだけ。 *)
NBExportWrappedKeys[keyRefs_List, wrapKey_] :=
  Module[{out = <||>},
    iNBEnsureIndexLoaded[];
    Do[
      Module[{obj = iNBResolveKeyObject[kr], idx, ct, meta},
        If[obj === $Failed, Continue[]];
        ct = Quiet@Check[Encrypt[wrapKey, BinarySerialize[obj]], $Failed];
        If[Head[ct] =!= EncryptedObject, Continue[]];
        idx = Lookup[$iNBKeyIndex, kr, <||>];
        (* 非秘密 meta のみ (鍵材料・Backend は除外)。復元に要る公開鍵/種別/用途を保持。 *)
        meta = KeyTake[idx, {"Kind", "Purpose", "RotationStable", "Owner",
            "Algorithm", "PublicKey", "Fingerprint"}];
        AssociateTo[out, kr -> <|"IndexMeta" -> meta, "Ciphertext" -> ct|>]],
      {kr, keyRefs}];
    out];

NBImportWrappedKeys[wrapped_Association, wrapKey_] :=
  Module[{restored = {}},
    iNBEnsureIndexLoaded[];
    KeyValueMap[
      Function[{kr, rec},
        Module[{pt, obj, meta},
          pt = Quiet@Check[Decrypt[wrapKey, Lookup[rec, "Ciphertext", $Failed]], $Failed];
          If[Head[pt] === ByteArray,
            obj = Quiet@Check[BinaryDeserialize[pt], $Failed];
            If[obj =!= $Failed && Head[obj] =!= Symbol,
              meta = KeyTake[Lookup[rec, "IndexMeta", <||>],
                 {"Purpose", "RotationStable", "Owner", "Algorithm", "PublicKey"}];
              NBStoreCredentialKey[kr, obj, meta];
              AppendTo[restored, kr]]]]],
      wrapped];
    restored];

End[];
EndPackage[];
