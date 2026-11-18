# NBAccess_crypto API リファレンス

NBAccess の crypto 鍵隔離層。鍵材料を NBAccess 境界外に出さず、keyRef 経由で暗号操作を行う。`BeginPackage["NBAccess`"]` に属する。鍵解決は `NBAccess`Private` に閉じ非公開。KeyRef index は鍵材料を含まず purpose / algorithm / fingerprint / created / status / backend のみ保持。

## 鍵ストア管理

### NBStoreCredentialKey[keyRef, keyObject, metadata_:<||>, opts]
鍵を直列化して backend に保存し、鍵材料を含まない index entry を作る。metadata は index entry に Join される。
→ <|"Status" -> "Stored", "KeyRef" -> keyRef, "KeyMaterialReturned" -> False|> | <|"Status" -> "Exists", ...|>(CreateOnly で既存時、上書きしない)
Options: "CreateOnly" -> False (True で鍵材料が既にあれば上書きせず Status "Exists" を返す。鍵喪失防止用)
index entry の Kind は Head から SymmetricKey | PrivateKey | PublicKey | MacKey(ByteArray) | Unknown。

### NBKeyStatus[keyRef] → Association | Missing
鍵の metadata(鍵材料を含まない)を返す。存在しなければ Missing["NotFound"]。

### NBListCredentialKeyRefs[pattern_:"*"] → List
登録済み keyRef の一覧を返す(鍵材料は含まない)。pattern は文字列パターン(StringMatchQ)。

### NBDeleteCredentialKey[keyRef] → Association
鍵を削除する。戻り値は <|"Status" -> "Deleted", "KeyRef" -> keyRef|>。削除した keyRef は同一カーネルの merge 永続で復活しないよう内部 ledger
(`$iNBDeletedKeyRefs`)に記録される。

### NBKeyMaterialExistsQ[keyRef] → Boolean
鍵材料が backend に存在するかを **index 非依存**で返す。共有 index は複数カーネル間で
last-writer-wins の clobber が起きうるため、「鍵が本当に存在するか」(crypto-shredding 済み判定・
消去検査など)は NBKeyStatus でなく本関数を使う。

### NBKeyMaterialFingerprint[keyRef] → String | Missing["NoMaterial"]
鍵ストアの鍵材料から指紋(SHA-256 の先頭 16 桁)を計算して返す。index に依存しない。鍵が無ければ Missing["NoMaterial"]。鍵材料は返さない。

注: SystemCredential backend の鍵 index(メタデータのみ)は、永続先がファイル `$HomeDirectory/.nbaccess/key-index.wxf.b64` に移行済み(2026-07-23)。真因は Windows Credential Manager の値上限(約 2560 bytes ≒ 1280 文字)で、鍵が増えると index blob の書込みが silent に失敗し再起動で index が消失したため。旧 credential blob(`SourceVault__keyindex__v1`)は legacy として読み継ぎ、初回 persist でファイルへ移行する。永続時は既存と **merge** される(他カーネルが発行した keyRef を消さない。自カーネルで削除した keyRef は除外)。鍵材料 credential(`SourceVault__k__*`)は keyRef 毎に独立で clobber しない。

### NBRebuildKeyIndexFromCredentials[keyRefs] → Association
index に無いが鍵材料 credential が存在する keyRef の index entry を材料から再構築する
(index 消失からの復旧用)。鍵材料は返さない。keyRefs はリスト。
戻り値は keyRef ごとに "Rebuilt"(再構築した) | "AlreadyIndexed"(既に index にある) |
"NoMaterial"(鍵材料が存在しない)を対応付けた Association。再構築 entry の Purpose は "RebuiltFromCredential"(元の Purpose/CreatedAt は復元不能)。

## 鍵生成

### NBGenerateSymmetricKeyRef[keyRef, metadata_:<||>, opts]
AES256 対称鍵を生成して keyRef に保存する。Purpose "SymmetricAtRest", Algorithm "AES256" が既定 metadata。
→ NBStoreCredentialKey の戻り値(Association)
Options: "CreateOnly" -> False (True で既存鍵を上書きしない)

### NBGenerateMacKeyRef[keyRef, metadata_:<||>, opts]
GenerateSymmetricKey 由来の 256bit 暗号用乱数 MAC 鍵を生成して keyRef に保存する。Purpose "HMAC", Algorithm "HMAC-SHA256" が既定 metadata。
→ NBStoreCredentialKey の戻り値(Association)
Options: "CreateOnly" -> False (True で既存鍵を上書きしない)

### NBGenerateAsymmetricKeyRefPair[keyRef, metadata_:<||>]
RSA 鍵対を生成し、秘密鍵を keyRef に保存する。公開鍵は index の "PublicKey"(Base64 の BinarySerialize)に保持する。
→ NBStoreCredentialKey の戻り値(Association)

## 暗号 / 復号

### NBEncryptWithKeyRef[keyRef, plaintextBytes, purpose_:None, accessSpec_:Automatic] → Association | $Failed
対称鍵で暗号化する。鍵は返さない。plaintextBytes は ByteArray。keyRef が SymmetricKey でなければ $Failed。
成功時: <|"Status" -> "Ok", "KeyRef" -> keyRef, "CiphertextB64" -> String(Base64 化した直列 EncryptedObject), "IV" -> String | Missing["NoIV"]|>

### NBDecryptWithKeyRef[keyRef, ciphertextB64, purpose_:None, accessSpec_:Automatic] → ByteArray | $Failed
復号して ByteArray を返す。失敗時は $Failed。ciphertextB64 は NBEncryptWithKeyRef 戻り値の "CiphertextB64"。

## MAC

### NBMacWithKeyRef[keyRef, bytes, purpose_:None, accessSpec_:Automatic] → String | $Failed
HMAC-SHA256 を hex で返す。keyRef が MAC 鍵(ByteArray)でなければ $Failed。

### NBVerifyMacWithKeyRef[keyRef, bytes, macHex, purpose_:None, accessSpec_:Automatic] → Boolean
MAC を constant-time 比較で検証する。

## 公開鍵 / 自己検査

### NBGetPublicKeyForKeyRef[keyRef] → PublicKey | $Failed
非対称鍵対の公開鍵(秘密でない)を返す。index に公開鍵が無ければ $Failed。

### NBCryptoSelfTest[] → Association
隔離した一時 Memory backend で鍵隔離・暗号/MAC roundtrip・誤鍵検出・一覧・削除を検査する。各検査項目の Boolean と "AllPassed" を持つ Association を返す。

## 鍵バンドル(内部プリミティブ)

### NBExportWrappedKeys[keyRefs, wrapKey] → Association
各鍵オブジェクトを wrapKey (SymmetricKey) で暗号化した EncryptedObject と非秘密 index meta だけを返す。平文鍵材料は決して返さない。可搬な鍵バンドル用。keyRefs は keyRef のリスト。鍵が解決できない keyRef はスキップされる。
戻り値: <|keyRef -> <|"IndexMeta" -> Association, "Ciphertext" -> EncryptedObject|>|>。IndexMeta は Kind / Purpose / RotationStable / Owner / Algorithm / PublicKey / Fingerprint / KeyGroup / Tier / ClassId のうち存在するもの(Backend は除外)。

### NBImportWrappedKeys[wrappedAssoc, wrapKey] → List
wrapKey で復号した鍵オブジェクトを現 backend の credential store に書き戻す。BinaryDeserialize のみ(ToExpression 不使用)。復元した keyRef のリストを返す。wrappedAssoc は NBExportWrappedKeys の出力。復元時 metadata は Purpose / RotationStable / Owner / Algorithm / PublicKey / KeyGroup / Tier / ClassId のみ引き継ぐ。

## 紙の回復の受取人(公開鍵による包み)

### NBWrapKeyRefsForPublicKey[keyRefs, publicKey] → Association | $Failed
各鍵オブジェクトを公開鍵 (RSA, OAEP) で包んだ暗号文と、鍵の指紋・種類だけを返す(紙の回復の受取人用)。平文の鍵材料は返さない。解決できない keyRef はスキップ。引数型が不正なら $Failed。
戻り値: <|keyRef -> <|"Ciphertext" -> EncryptedObject, "Fingerprint" -> String, "Kind" -> "SymmetricKey" | "MacKey" | "PrivateKey" | "Unknown"|>|>

### NBUnwrapKeyRefsWithPrivateKey[wrapped, privateKey, mode_:"Verify"] → Association | $Failed
NBWrapKeyRefsForPublicKey の結果を秘密鍵でほどく。鍵材料は返さず、keyRef ごとの状態だけを返す。引数型が不正なら $Failed。
mode = "Verify"(既定): 指紋の照合だけ。"Import": この機の鍵ストアに書く(CreateOnly で既存鍵は上書きしない)。Import 時の metadata は Purpose "RecoveredFromPaper", Owner "SourceVault"。
戻り値: <|keyRef -> <|"Status" -> status, "Fingerprint" -> String, "MatchesStore" -> Boolean | Missing["NotInStore"]|>|>。復号失敗時は <|"Status" -> "DecryptFailed"|> のみ。
Status: "Verified"(Verify で成功) | "Imported" | "ImportFailed" | "AlreadyPresent"(既存鍵と指紋一致) | "Conflict"(既存鍵と指紋不一致、上書きしない) | "FingerprintMismatch"(記録指紋と復号後の指紋が不一致) | "DecryptFailed"

## 変数

### $NBCredentialBackend
型: String, 初期値: "Memory"
鍵ストア backend。"Memory"(in-kernel、テスト/開発用、同期されない) | "SystemCredential"(OS credential store に鍵材料を永続化。index はファイル永続)。SystemCredential の読み書きは `SystemCredential[name]` / `SystemCredential[name] = v` / `SystemCredential[name] =.` を使う。