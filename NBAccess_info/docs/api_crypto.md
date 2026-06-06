# NBAccess_crypto API リファレンス

NBAccess の crypto 鍵隔離層。鍵材料を NBAccess 境界外に出さず、keyRef 経由で暗号操作を行う。`BeginPackage["NBAccess`"]` に属する。鍵解決は `NBAccess`Private` に閉じ非公開。KeyRef index は鍵材料を含まず purpose / algorithm / fingerprint / created / status / backend のみ保持。

## 鍵ストア管理

### NBStoreCredentialKey[keyRef, keyObject, metadata]
鍵を直列化して backend に保存し、鍵材料を含まない index entry を作る。
→ keyRef(保存成功) / $Failed

### NBKeyStatus[keyRef] → Association | Missing
鍵の metadata(鍵材料を含まない)を返す。存在しなければ Missing。

### NBListCredentialKeyRefs[pattern_:"*"] → List
登録済み keyRef の一覧を返す(鍵材料は含まない)。pattern は文字列パターン。

### NBDeleteCredentialKey[keyRef] → Boolean
鍵を削除する。

## 鍵生成

### NBGenerateSymmetricKeyRef[keyRef, metadata_:<||>] → keyRef
AES256 対称鍵を生成して keyRef に保存する。

### NBGenerateMacKeyRef[keyRef, metadata_:<||>] → keyRef
256bit ランダム MAC 鍵を生成して keyRef に保存する。

### NBGenerateAsymmetricKeyRefPair[keyRef, metadata_:<||>] → keyRef
RSA 鍵対を生成し、秘密鍵を keyRef に保存する。公開鍵は index に保持する。

## 暗号 / 復号

### NBEncryptWithKeyRef[keyRef, plaintextBytes, purpose_:None, accessSpec_:Automatic] → String
対称鍵で暗号化し、Base64 化した直列 EncryptedObject を返す。鍵は返さない。plaintextBytes は ByteArray。

### NBDecryptWithKeyRef[keyRef, ciphertextB64, purpose_:None, accessSpec_:Automatic] → ByteArray | $Failed
復号して ByteArray を返す。失敗時は $Failed。ciphertextB64 は NBEncryptWithKeyRef の出力。

## MAC

### NBMacWithKeyRef[keyRef, bytes, purpose_:None, accessSpec_:Automatic] → String
HMAC-SHA256 を hex で返す。

### NBVerifyMacWithKeyRef[keyRef, bytes, macHex, purpose_:None, accessSpec_:Automatic] → Boolean
MAC を constant-time 比較で検証する。

## 公開鍵 / 自己検査

### NBGetPublicKeyForKeyRef[keyRef] → PublicKey
非対称鍵対の公開鍵(秘密でない)を返す。

### NBCryptoSelfTest[] → Boolean | Association
鍵隔離・暗号/MAC roundtrip・誤鍵検出を検査する。

## 鍵バンドル(内部プリミティブ)

### NBExportWrappedKeys[keyRefs, wrapKey] → Association
各鍵オブジェクトを wrapKey (SymmetricKey) で暗号化した EncryptedObject と非秘密 index meta だけを返す。平文鍵材料は決して返さない。可搬な鍵バンドル用。keyRefs は keyRef のリスト。

### NBImportWrappedKeys[wrappedAssoc, wrapKey] → List
wrapKey で復号した鍵オブジェクトを現 backend の credential store に書き戻す。BinaryDeserialize のみ(ToExpression 不使用)。復元した keyRef のリストを返す。wrappedAssoc は NBExportWrappedKeys の出力。

## 変数

### $NBCredentialBackend
型: String, 初期値: "Memory"
鍵ストア backend。"Memory"(in-kernel、テスト/開発用、同期されない) | "SystemCredential"(本番想定、書き込み API は TODO)。Memory backend のみ本フェーズで完全実装・検証済み。