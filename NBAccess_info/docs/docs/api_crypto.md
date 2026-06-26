# NBAccess_crypto API リファレンス

NBAccess の crypto 鍵隔離層 (Phase SV-E3)。SourceVault encryption spec v18 準拠。鍵材料を NBAccess の外へ返さない「鍵隔離境界」を提供する。すべての公開シンボルは `NBAccess` コンテキストに属する。関連: [NBAccess](https://github.com/transreal/NBAccess) 本体、[SourceVault_crypto](https://github.com/transreal/SourceVault_crypto)。

## 概要
鍵隔離の原則:
- 鍵材料は NBAccess の外へ返さない。`NB*WithKeyRef` 系は keyRef を受け取り、内部で鍵を解決して暗号操作を行い、結果 (暗号文 / MAC / 真偽) だけを返す。
- 鍵解決を担う内部関数 `iNB*` は `NBAccess`Private` に閉じ、公開しない。
- KeyRef index は鍵材料を含まず、purpose / algorithm / fingerprint / created / status / backend だけを持つ。

鍵ストア backend は `$NBCredentialBackend` で選択する。`"Memory"` (既定、in-kernel、テスト/開発用、同期されない) と `"SystemCredential"` (本番想定、書き込み API は TODO)。本フェーズでは Memory backend を完全実装・検証する。

共通引数の慣習:
- `keyRef`: 鍵を識別する参照 (文字列)。鍵材料そのものではない。
- `metadata`: 非秘密の付随情報 Association。既定 `<||>`。
- `purpose` / `accessSpec`: 暗号操作時の用途・アクセス指定。既定はそれぞれ `None` / `Automatic`。
- 鍵が存在しない・復号に失敗した場合は `Missing` または `$Failed` を返し、鍵材料は決して露出しない。

## 鍵ストア管理
### NBStoreCredentialKey[keyRef, keyObject, metadata]
鍵を直列化して backend に保存し、鍵材料を含まない index entry を作る。
→ keyRef

### NBKeyStatus[keyRef] → Association | Missing
鍵の metadata (鍵材料を含まない) を返す。存在しなければ Missing。

### NBListCredentialKeyRefs[pattern_:"*"] → List
登録済み keyRef の一覧を返す (鍵材料は含まない)。pattern で絞り込み可能、既定 `"*"`。

### NBDeleteCredentialKey[keyRef] → keyRef
鍵を削除する。

## 鍵生成
### NBGenerateSymmetricKeyRef[keyRef, metadata_:<||>] → keyRef
AES256 対称鍵を生成して keyRef に保存する。metadata 既定 `<||>`。

### NBGenerateMacKeyRef[keyRef, metadata_:<||>] → keyRef
256bit ランダム MAC 鍵を生成して keyRef に保存する。metadata 既定 `<||>`。

### NBGenerateAsymmetricKeyRefPair[keyRef, metadata_:<||>] → keyRef
RSA 鍵対を生成し、秘密鍵を keyRef に保存する。公開鍵は index に保持する。metadata 既定 `<||>`。

## 暗号化 / 復号
### NBEncryptWithKeyRef[keyRef, plaintextBytes, purpose_:None, accessSpec_:Automatic]
対称鍵で暗号化し、Base64 化した直列 EncryptedObject を返す。鍵は返さない。
→ String (Base64)
purpose 既定 None、accessSpec 既定 Automatic。

### NBDecryptWithKeyRef[keyRef, ciphertextB64, purpose_:None, accessSpec_:Automatic]
復号して ByteArray を返す。失敗時は $Failed。
→ ByteArray | $Failed
purpose 既定 None、accessSpec 既定 Automatic。
例: NBDecryptWithKeyRef["k1", NBEncryptWithKeyRef["k1", ByteArray[{1,2,3}]]]

## MAC
### NBMacWithKeyRef[keyRef, bytes, purpose_:None, accessSpec_:Automatic] → String (hex)
HMAC-SHA256 を hex で返す。purpose 既定 None、accessSpec 既定 Automatic。

### NBVerifyMacWithKeyRef[keyRef, bytes, macHex, purpose_:None, accessSpec_:Automatic] → Bool
MAC を constant-time 比較で検証する。purpose 既定 None、accessSpec 既定 Automatic。

## 公開鍵
### NBGetPublicKeyForKeyRef[keyRef] → PublicKey
非対称鍵対の公開鍵 (秘密でない) を返す。

## 鍵バンドル (内部プリミティブ)
### NBExportWrappedKeys[keyRefs, wrapKey] → Association
各鍵オブジェクトを wrapKey (SymmetricKey) で暗号化した EncryptedObject と非秘密 index meta だけを返す。平文鍵材料は決して返さない。可搬な鍵バンドル用。

### NBImportWrappedKeys[wrappedAssoc, wrapKey] → List
wrapKey で復号した鍵オブジェクトを現 backend の credential store に書き戻す。BinaryDeserialize のみ使用 (ToExpression 不使用)。復元した keyRef のリストを返す。

## 自己テスト
### NBCryptoSelfTest[] → Bool | Association
鍵隔離・暗号/MAC roundtrip・誤鍵検出を検査する。

## 変数
### $NBCredentialBackend
型: String, 初期値: "Memory"
鍵ストア backend (`"Memory"` | `"SystemCredential"`)。`"Memory"` は in-kernel でテスト/開発用 (同期されない)。`"SystemCredential"` は本番想定だが書き込み API は TODO。