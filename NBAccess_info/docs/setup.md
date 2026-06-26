## 動作環境

- **Wolfram Mathematica** 12.0 以降
- **Wolfram Language** カーネル
- **文字エンコーディング**: UTF-8 対応

## インストール方法

### 方法1: 直接読み込み（推奨）

パッケージファイルを適切なディレクトリに配置し、以下のコードで読み込みます：

```mathematica
Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
```

### 方法2: claudecode パッケージ経由（最も簡単）

claudecode パッケージを使用している場合、エンコーディングが自動的に処理されます：

```mathematica
Get["claudecode.wl"]
(* NBAccess は自動的に利用可能になります *)
```

### 方法3: パッケージディレクトリへの配置

1. Wolfram Language の `$UserBaseDirectory` または `$BaseDirectory` を確認します
2. `Applications` フォルダ内に `NBAccess.wl` を配置します
3. 通常の `Get` または `Needs` で読み込みます

## 関連パッケージ

### ClaudeRuntime との連携

NBAccess は [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) パッケージと連携することで、ノートブック内での安全な式実行・検証・ルーティング機能が強化されます。

ClaudeRuntime を導入すると、以下の高度な API が利用可能になります：

- **`NBValidateHeldExpr`** — LLM が生成した式を Allowed Expression Surface に照合し、実行前に安全性を検証します
- **`NBExecuteHeldExpr`** — 検証済み式をポリシーに従って安全に実行します
- **`NBAuthorize`** — PolicyGate・ScoreGate・EnvironmentGate を統合したアクセス制御判定を行います
- **`NBRouteDecision`** — コンテキストのリスクスコアに基づき、CloudLLM / PrivateLLM / LocalOnly へのルーティング推奨を返します
- **`GuardedApply`** / **`Declassify`** — 関数単位のセキュリティポリシー適用と情報ラベルの引き下げ

ClaudeRuntime は NBAccess とは独立したパッケージです。NBAccess 単体でも従来どおりすべての機能が利用できます（後方互換性の節を参照）。

ClaudeRuntime の読み込み例：

```mathematica
Block[{$CharacterEncoding = "UTF-8"}, Get["ClaudeRuntime.wl"]]
(* または claudecode.wl 経由で自動ロードされます *)
```

#### 式検証・実行エンジンの判定モデル

`NBValidateHeldExpr` の検証ロジックは、従来の AllowedHeads / ApprovalHeads / DenyHeads の照合に加えて、式に含まれる head の副作用クラス（EffectClass）から承認適格性（ApprovalEligibility）を集約し、ベース判定と合成して最終判定を行うように拡張されました。最終判定は、ベース判定（`iNBValidateHeldExprBase`）で得た Decision と、式中の head から集約した EffectClass の eligibility を「厳しい方」を採用して合成します。

- 純粋な数学関数（`Total`、`IntegerPart`、`Round`、`Floor`、`Ceiling` など副作用のないもの）は `PureComputation` として扱われ、ブロックされにくくなります。`System`` 系の副作用のない関数も同様に純粋計算として扱われます。
- `Module`／`Block`／`With` などのスコープ局所変数や、`Set`／`SetDelayed` で定義したローカル関数名は承認対象から除外され、過剰な承認要求を抑制します（これらはユーザー定義の安全なローカルとみなされます）。
- head の eligibility が同点の場合は、specificity rank（より具体的な分類）を優先して最終アクションを決定します。
- ユーザーが承認 UI で明示承認した場合（**UserApproved**）や、directLLM rescue などの自動 commit 互換経路（**CommitterAutoApprove**）では、検証済みパスに対して実行が許可されます。
- 式中の head が `System` 系の純粋関数か否かを文字列パースに頼らずに判定できるよう改善され、`NotebookWrite[nb, Cell[...]]` のように未知 head（`Cell` 等）を含む式が誤って NeedsApproval 扱いされる過剰判定が抑制されています。

これに伴い、旧来の `NBExecuteHeldExpr` の `"TimeConstraint"` オプションおよび `NBValidateHeldExpr` の `"AllowedHeads"`／`"ApprovalHeads"`／`"DenyHeads"`／`"LabelCheck"` をオプション引数で逐一指定する方式は廃止され、グローバル変数（`$NBAllowedHeads` 等）と上記の EffectClass ベース判定に統合されています。式中の head から「全 head が承認可能 head か」を文字列パースせずに判定できるようになっています。

#### 出力モードと遅延バッファ

ClaudeRuntime 経由の式実行では、出力の扱い方を 2 つのモードから選べます（2026-06-03 追加）：

- **Streaming（逐次・既定）**: 評価の進行に合わせて出力を逐次表示します。
- **Batch（集約）**: 出力を遅延バッファに溜め込み、`NBFlushDeferredOutput` を呼び出した時点で一括表示します。

```mathematica
(* バッファに溜まった出力をまとめて出力する *)
NBAccess`NBFlushDeferredOutput[]
```

Batch モードは、scheduled タスクなどから多数の出力を生成する処理で、表示順序を整えたい場合に有用です。バッファへの追加は変数操作のため評価コンテキストを問わず安全に行えますが、最終的な一括出力（フラッシュ）はメインカーネル評価で行う必要があります。位置依存の挿入はバッファ順序と整合しないため行いません。

### ClaudeTestKit との連携

[ClaudeTestKit](https://github.com/transreal/ClaudeTestKit) は NBAccess および ClaudeRuntime のテストを自動化するためのユーティリティパッケージです。パッケージ開発者や NBAccess を組み込むプロジェクト向けに、以下の用途で使用します：

- NBAccess の各 API に対するユニットテスト・統合テストの実行
- プライバシーフィルタリング・アクセス制御ロジックの回帰テスト
- ClaudeRuntime のルーティング判定・ポリシーゲートの動作検証

ClaudeTestKit は開発・検証用パッケージであり、エンドユーザーが通常利用する際には必須ではありません。

## 基本設定

### プライバシー設定

NBAccess の主要な設定項目として、プライバシーアクセスレベルがあります：

```mathematica
(* デフォルト設定（クラウドLLM安全レベル） *)
$NBPrivacySpec = <|"AccessLevel" -> 0.5|>

(* ローカルLLM環境での設定 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>
```

### 機密変数設定

機密データのスキーマ情報送信制御：

```mathematica
(* スキーマ情報を送信する（デフォルト） *)
$NBSendDataSchema = True

(* スキーマ情報も送信しない *)
$NBSendDataSchema = False
```

### 詳細ログ設定

NBAccess 内部の詳細ログ出力を制御できます：

```mathematica
(* 詳細ログを Messages に出力する *)
$NBVerbose = True

(* 重大エラー以外のログを抑制する（デフォルト） *)
$NBVerbose = False
```

### 分離原則の除外設定

NBAccess 分離原則チェックから除外するパッケージの設定：

```mathematica
(* デフォルトで NBAccess と NotebookExtensions は除外済み *)
$NBSeparationIgnoreList = {"NBAccess", "NotebookExtensions"}

(* 独自パッケージを追加する場合 *)
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

### 機密生成ヘッド API

`$NBConfidentialHeads` は「返り値が機密たり得る関数ヘッド」の登録レジストリ（`<|name -> level|>` 形式）です。SourceVault 等のデータ層パッケージがロード時に自動登録し、claudecode が LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定に使用します。通常はユーザーが手動で操作する必要はありませんが、以下の API で参照・管理できます。

```mathematica
(* 登録済みの機密生成ヘッド表を取得する *)
NBAccess`NBGetConfidentialHeads[]
(* 出力例: <|"SourceVaultSearch" -> 1.0, ...|> *)

(* 返り値が機密たり得る関数ヘッドを登録する（level 既定 1.0） *)
NBAccess`NBRegisterConfidentialHead["MySecretFunc"]
NBAccess`NBRegisterConfidentialHead["MySecretFunc", 0.8]

(* テキストが登録済みの機密生成ヘッドを参照しているか確認する *)
(* 識別子境界 (Unicode) で誤マッチを防ぎ、Map 等への関数値渡し形式も検出する *)
NBAccess`NBTextUsesConfidentialHead["result = MySecretFunc[x]"]
(* True または False を返す *)

(* 機密生成ヘッドの登録を解除する *)
NBAccess`NBUnregisterConfidentialHead["MySecretFunc"]
```

これらの関数は `$NBConfidentialSymbols`（秘密変数レジストリ）のヘッド版にあたる仕組みを提供します。カスタムデータ層パッケージを開発している場合、ロード時に `NBRegisterConfidentialHead` を呼び出すことで、そのパッケージの出力を返す関数を機密生成ヘッドとして宣言できます。

## 後方互換性について

NBAccess は ClaudeRuntime および ClaudeTestKit の導入後も、既存のコードとの後方互換性を維持しています。

### 互換性の保証範囲

- **ClaudeRuntime 未導入環境**: ClaudeRuntime に依存する新 API（`NBValidateHeldExpr`、`NBExecuteHeldExpr`、`NBAuthorize` 等）は ClaudeRuntime が読み込まれていない場合は定義されませんが、それ以外の全 API は従来どおり動作します。
- **既存の PrivacySpec・プライバシーフィルタリング API**: 変更なく利用可能です。
- **HistoryDB・TaggingRules API**: 変更なく利用可能です。
- **セル操作 API（`NBCellRead`、`NBCellWriteText`、`NBGetCells` 等）**: 変更なく利用可能です。
- **`$NBPrivacySpec`・`$NBConfidentialSymbols`・`$NBSendDataSchema`** 等のグローバル変数: 初期値・動作に変更はありません。
- **`$NBConfidentialHeads`**（新規追加）: 「返り値が機密たり得る関数ヘッド」の登録レジストリ（`<|name -> level|>` 形式）です。`$NBConfidentialSymbols`（秘密変数レジストリ）のヘッド版にあたります。SourceVault 等のデータ層パッケージがロード時に `NBRegisterConfidentialHead` で自動登録し、claudecode が LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定に使用します。ユーザーが手動で設定する必要はありません。関連 API として `NBGetConfidentialHeads`（テーブル取得）、`NBRegisterConfidentialHead`（登録）、`NBUnregisterConfidentialHead`（登録解除）、`NBTextUsesConfidentialHead`（テキスト内参照判定）が追加されています。
- **`NBJobMoveToAnchor` の戻り値変更**（2026-06-24 修正）: アンカーセルの直後にカーソルを移動する関数が True/False を返すようになりました。位置を確定できた場合（アンカーが消失している場合のノートブック末尾退避を含む）は True、jobId が `$NBJobTable` に存在しない場合のみ False を返します。従来は戻り値を使用していないコードには影響ありません。

### ClaudeRuntime 導入時の注意点

ClaudeRuntime を導入すると、`$NBAllowedHeads`・`$NBApprovalHeads`・`$NBDenyHeads` などのグローバル変数が追加されます。既存コードがこれらのシンボル名を独自に使用している場合は、名前の衝突を確認してください。

ラベル代数 API（`NBLabelQ`、`NBLabelJoin`、`NBLabelMeet` 等）および関数セキュリティ API（`NBRegisterFunctionSecurity`、`GuardedApply`、`Declassify` 等）は ClaudeRuntime と同時に導入されたものですが、既存の API とは完全に独立しており、既存の動作に影響しません。

### バージョン間の移行

ClaudeRuntime 導入前に作成したノートブックをそのまま使い続けることができます。ClaudeRuntime の新機能を使用したい場合は、個別の関数呼び出し時に `NBAuthorize` や `NBValidateHeldExpr` を任意で追加するだけで構いません。強制的な移行作業は不要です。

なお、`NBValidateHeldExpr`／`NBExecuteHeldExpr` の検証・実行ロジックは EffectClass ベースの判定モデルに刷新されましたが、これらの API のシグネチャ（`HoldComplete[...]` と PrivacySpec を渡す呼び出し方）は変わっていません。旧来オプション（`"TimeConstraint"`、`"AllowedHeads"`、`"ApprovalHeads"`、`"DenyHeads"`、`"LabelCheck"` 等）を明示指定していたコードがある場合のみ、グローバル変数による設定へ置き換えてください。これらのオプションはすでに削除されており、明示指定しても効果はありません。

## 動作確認

### 基本機能テスト

インストールが正常に完了したかを確認します：

```mathematica
(* パッケージの読み込み確認 *)
NBAccess`NBCellCount[EvaluationNotebook[]]

(* 現在のノートブックのセル数が返されれば成功 *)
```

### セル操作テスト

```mathematica
nb = EvaluationNotebook[]

(* 現在のセルインデックス取得 *)
currentIdx = NBAccess`NBCurrentCellIndex[nb]

(* セル内容の読み取り *)
cellText = NBAccess`NBCellToText[nb, currentIdx]
```

### 低レベルセル操作テスト

以下の関数を使うと、セルの CellObject 解決・セル選択・スタイル変更・コード書き込みを行えます：

```mathematica
nb = EvaluationNotebook[]

(* CellObject を取得する（外部パッケージが低レベル参照を必要とする場合に使用） *)
(* 指定インデックスが無効な場合は $Failed を返す *)
cellObj = NBAccess`NBResolveCell[nb, 3]

(* セルブラケットを選択状態にする（パレット操作後のセル選択復元に使用） *)
NBAccess`NBSelectCell[nb, 3]

(* セルのスタイルを変更する *)
(* Cell 式の第2引数を書き換える。TaggingRules 等の属性は保持される *)
NBAccess`NBCellSetStyle[nb, 3, "Input"]

(* 既存セルにコードを BoxData + Input スタイルで書き込む *)
(* FEParser で構文カラーリング付き BoxData に変換し、Cell 式全体を置換する *)
NBAccess`NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

### プライバシーフィルタリングテスト

```mathematica
(* アクセス可能なセル一覧取得 *)
accessibleCells = NBAccess`NBGetCells[nb, PrivacySpec -> $NBPrivacySpec]

(* 特定セルのアクセス可能性確認 *)
isAccessible = NBAccess`NBIsAccessible[nb, 1, PrivacySpec -> $NBPrivacySpec]
```

### 依存グラフ機能テスト

```mathematica
(* 基本的な依存関係の確認 *)
dependencies = NBAccess`NBBuildVarDependencies[nb]

(* 依存グラフの可視化（機密変数がある場合） *)
NBAccess`NBPlotDependencyGraph[nb, "Scope" -> "Local"]
```

### 機密生成ヘッド API テスト

```mathematica
(* 登録済みの機密生成ヘッド一覧を確認する *)
NBAccess`NBGetConfidentialHeads[]

(* テキストが機密生成ヘッドを参照しているか確認する *)
NBAccess`NBTextUsesConfidentialHead["result = SourceVaultSearch[query]"]
(* True が返れば、そのテキストを含むセルは機密扱い候補となる *)
```

### ClaudeRuntime 連携テスト（ClaudeRuntime 導入時のみ）

```mathematica
(* ルーティング判定の確認 *)
NBAccess`NBRouteDecision[0.5]
(* 出力例: <|"Route" -> "CloudLLM", "EffectiveRiskScore" -> 0.5, ...|> *)

(* 式の事前検証 *)
NBAccess`NBValidateHeldExpr[HoldComplete[1 + 1], <|"AccessLevel" -> 0.5|>]

(* Batch 出力モードで溜めた出力の一括フラッシュ *)
NBAccess`NBFlushDeferredOutput[]
```

## API キー設定（オプション）

AI プロバイダーとの連携を行う場合：

```mathematica
(* API キーの設定確認 *)
anthropicKey = NBAccess`NBGetAPIKey["anthropic"]
openaiKey = NBAccess`NBGetAPIKey["openai"]
githubKey = NBAccess`NBGetAPIKey["github"]
```

API キーは Wolfram Language の `SystemCredential` 機能を通じて安全に管理されます。

## トラブルシューティング

### エンコーディング問題

文字化けが発生する場合：

```mathematica
(* 明示的にUTF-8エンコーディングで読み込み *)
Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
```

### プライバシーレベル問題

アクセスが拒否される場合：

```mathematica
(* より高いアクセスレベルに設定 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>

(* または関数呼び出し時に個別指定 *)
NBAccess`NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

### 式の実行が不必要に承認待ちになる場合

`NBValidateHeldExpr`／`NBExecuteHeldExpr` が、本来は安全なローカル定義や純粋な数学関数を承認対象としてしまう場合は、検証エンジンの EffectClass ベース判定が想定どおり機能しているかを確認してください。`Module`／`Block`／`With` のスコープ局所変数や `Set`／`SetDelayed` で定義したローカル関数名は承認対象から除外されます。`Total` や `IntegerPart`、`Round`、`Floor`、`Ceiling` などの純粋な数学関数も `PureComputation` として扱われ、ブロックされにくくなっています。意図せず承認が要求される場合は、式が副作用のある head（ノートブック書き込みやファイル操作など）を含んでいないかを確認してください。

### 承認 UI が「フォーマットしています」のまま長時間ブロックする場合

承認ボタン本体はメインカーネル評価コンテキストで動作します。検証済みパスに対する実行はトップレベル評価でのみ効くため、承認 UI が「フォーマットしています」の表示のまま長時間応答しないように見えることがあります（2026-06-06 の修正で改善済み）。最新のパッケージに更新してもこの状態が続く場合は、評価が AsyncActive（非同期処理の進行中）のまま Pending になっていないかを確認してください。

### ClaudeRuntime の API が見つからない場合

`NBValidateHeldExpr` 等の ClaudeRuntime 連携 API が未定義の場合は、ClaudeRuntime が読み込まれていることを確認してください：

```mathematica
(* ClaudeRuntime が読み込まれているか確認 *)
Names["NBAccess`NBAuthorize"]
(* {} が返る場合は ClaudeRuntime が未ロード *)

Block[{$CharacterEncoding = "UTF-8"}, Get["ClaudeRuntime.wl"]]
```

### Batch モードで出力が表示されない場合

出力モードを Batch（集約）にしている場合、評価が終わっても出力が表示されないことがあります。これは出力が遅延バッファに溜まっているためです。`NBFlushDeferredOutput` を呼び出してバッファ内容を一括出力してください：

```mathematica
NBAccess`NBFlushDeferredOutput[]
```

フラッシュはメインカーネル評価で行う必要があります。scheduled タスクなどから直接呼ぶと正しく表示されない場合があるため、メイン評価のタイミングで呼び出してください。

### 依存関係問題

分離原則違反が報告される場合：

```mathematica
(* 分離原則チェック実行 (claudecode が提供する関数) *)
ClaudeCheckSeparation["YourPackageName"]

(* 自動修正 *)
ClaudeFixSeparation["YourPackageName"]
```

### パフォーマンス問題

大きなノートブックで動作が遅い場合、NBAccess は自動的にキャッシュ機能を使用してFrontEndアクセスを最適化します。通常は設定不要ですが、問題が発生した場合はノートブックを再起動してください。

## 次のステップ

- **基本的な使用方法**: `user_manual.md` を参照してください
- **API リファレンス**: `api.md` で詳細な関数仕様を確認してください
- **暗号化・鍵管理**: `api_crypto.md` で暗号化 API の詳細を確認してください
- **概要・設計思想**: `README.md` を参照してください

## サポート

問題が発生した場合は、GitHub リポジトリにてイシューを報告してください：  
https://github.com/transreal/NBAccess