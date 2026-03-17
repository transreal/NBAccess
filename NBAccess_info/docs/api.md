# NBAccess API リファレンス

NBAccess はノートブックのセル単位の読み書き・プライバシーフィルタリング・履歴管理・依存グラフ解析を提供するユーティリティパッケージである。
リポジトリ: https://github.com/transreal/NBAccess

## グローバル変数・定数

### `$NBPrivacySpec`
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。クラウド LLM 安全なデータのみ許可する。ローカル LLM 環境では `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` に変更する。

### `$NBConfidentialSymbols`
型: Association, 初期値: `<||>`
機密変数名とプライバシーレベルのテーブル。`<|"変数名" -> privacyLevel, ...|>` の形式。[claudecode](https://github.com/transreal/claudecode) パッケージが自動的に更新する。

### `$NBSeparationIgnoreList`
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}` 等
分離検査 (ClaudeCheckSeparation) で無視するファイル名またはパッケージ名のリスト。`AppendTo[$NBSeparationIgnoreList, "MyPackage"]` で追加可能。

## オプション

### `PrivacySpec`
NBAccess の多くの関数で使用されるプライバシーフィルタリングオプション。
`PrivacySpec -> <|"AccessLevel" -> 0.5|>`
| AccessLevel 値 | 意味 |
|---|---|
| `0.5` | クラウド LLM 安全なデータのみ（デフォルト） |
| `1.0` | ローカル LLM 環境など全データ |
セルのプライバシーレベルが `AccessLevel` 以下のセルのみアクセス可能となる。

### `Decompress`
履歴関数で使用。`System`Decompress` をオプションラベルとして流用。
| 値 | 意味 |
|---|---|
| `True`（デフォルト） | Diff 差分を復元して平文で返す |
| `False` | Diff オブジェクトのまま返す（差分検査用） |

## セルユーティリティ関数

### `NBCellCount[nb]` → Integer
ノートブックの全セル数を返す。

### `NBCurrentCellIndex[nb]` → Integer
`EvaluationCell[]` のセルインデックスを返す。見つからない場合は `0`。

### `NBSelectedCellIndices[nb]` → {Integer...}
選択中セルのインデックスリストを返す。セルブラケット選択またはカーソル位置のセルを対象とする。

### `NBCellIndicesByTag[nb, tag]` → {Integer...}
指定の `CellTags` を持つセルのインデックスリストを返す。

### `NBCellIndicesByStyle[nb, style]` → {Integer...}
指定の CellStyle を持つセルのインデックスリストを返す。`style` は String または {String...}。
```mathematica
NBCellIndicesByStyle[nb, "Input"]
NBCellIndicesByStyle[nb, {"Title", "Section", "Subsection"}]
```

### `NBDeleteCellsByTag[nb, tag]` → Null
指定の `CellTags` を持つセルを全て削除する。

### `NBMoveAfterCell[nb, cellIdx]` → Null
指定セルの後ろにカーソルを移動する。

### `NBMoveToEnd[nb]` → Null
ノートブックの末尾にカーソルを移動する。

### `NBCellRead[nb, cellIdx]` → Cell[...]
`NotebookRead` で Cell 式を返す。

### `NBCellReadInputText[nb, cellIdx]` → String
FrontEnd 経由で InputText 形式のテキストを取得する。失敗時は `NBCellExprToText` にフォールバックする。

### `NBCellStyle[nb, cellIdx]` → String
セルの CellStyle を返す（例: `"Input"`, `"Output"`, `"Text"`）。

### `NBCellLabel[nb, cellIdx]` → String
セルの CellLabel を返す（例: `"In[3]:="`）。ラベルなしの場合は `""` を返す。

### `NBCellSetOptions[nb, cellIdx, opts]` → Null
セルに `SetOptions` を適用する。

### `NBCellGetTaggingRule[nb, cellIdx, path]` → 値 | Missing[]
セルの TaggingRules からネストした値を取得する。`path` は String | {String...}。
```mathematica
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
```

### `NBCellRasterize[nb, cellIdx, file, opts]` → ファイルパス
セルを Rasterize して `file` に保存する。`opts` は Rasterize オプション。

### `NBCellHasImage[cellExpr]` → True | False
Cell 式が画像（RasterBox/GraphicsBox）を含むかを判定する。`cellExpr` は `NBCellRead` の戻り値を想定。

## プライバシー API

### `NBCellPrivacyLevel[nb, cellIdx]` → Real
セルのプライバシーレベル（0.0〜1.0）を返す。`0.0` は非機密、`0.75` は依存機密、`1.0` は機密（Confidential マークまたは機密変数参照）。

### `NBIsAccessible[nb, cellIdx, opts]` → True | False
セルが指定の PrivacySpec でアクセス可能かどうかを返す。
Options: PrivacySpec -> Automatic ($NBPrivacySpec)

### `NBFilterCellIndices[nb, indices, opts]` → {Integer...}
セルインデックスリストを PrivacySpec でフィルタリングして返す。
Options: PrivacySpec -> Automatic ($NBPrivacySpec)

## テキスト抽出 API

### `NBCellExprToText[cellExpr]` → String
`NotebookRead` の結果（Cell 式）からテキストを抽出する。

### `NBCellToText[nb, cellIdx]` → String
セルのテキスト内容を返す。

### `NBGetCells[nb, opts]` → {Integer...}
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。
Options: PrivacySpec -> Automatic ($NBPrivacySpec)

### `NBGetContext[nb, afterIdx, opts]`
ノートブック内の `afterIdx` 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築する。PrivacySpec でフィルタリングされる。
→ String（LLM に渡すためのフォーマット済みテキスト）
Options: PrivacySpec -> Automatic ($NBPrivacySpec)
```mathematica
ctx = NBGetContext[nb, 0]  (* 全セルからコンテキスト構築 *)
```

## 書き込み API

### `NBWriteText[nb, text, style]` → Null
ノートブックにテキストセルを書き込む。`style` のデフォルトは `"Text"`。

### `NBWriteCode[nb, code]` → Null
構文カラーリング付き Input セルを書き込む。

### `NBWriteSmartCode[nb, code]` → Null
`CellPrint[]` パターンを自動検出してスマートにセルを書き込む。通常のコードと `CellPrint` を含むコードを適切に処理する。

### `NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]` → Null
現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動する。`autoEvaluate` が `True` の場合は `SelectionEvaluate` を実行する。

### `NBInsertTextCells[nbFile, name, prompt]` → Null
`.nb` ファイルを非表示で開き、末尾に Subsection セル（`name`）と Text セル（`prompt`）を挿入して保存・閉じる。

### `NBWriteCell[nb, cellExpr]` → Null
ノートブックに Cell 式を書き込む。`pos` は `After`（デフォルト）| `Before` | `All`。
```mathematica
NBWriteCell[nb, Cell["テスト", "Text"]]
NBWriteCell[nb, Cell["先頭に", "Text"], Before]
```

### `NBWritePrintNotice[nb, text, color]` → Null
ノートブックに通知用 Print セルを書き込む。`nb` が `None` の場合は `CellPrint` を使用する（同期 In/Out 間出力）。

### `NBWriteDynamicCell[nb, dynBoxExpr, tag]` → Null
ノートブックに Dynamic セルを書き込む。`tag` が `""` でない場合は CellTags を設定する。

### `NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]` → Null
ExternalLanguage セルを書き込む。`autoEvaluate` が `True` なら直前セルを評価する。

### `NBInsertAndEvaluateInput[nb, boxes]` → Null
Input セルを挿入して即座に評価する。

### `NBInsertInputAfter[nb, boxes]` → Null
Input セルを After に書き込み Before CellContents にカーソルを移動する。

### `NBWriteAnchorAfterEvalCell[nb, tag]` → Null
`EvaluationCell` 直後に不可視アンカーセルを書き込む。`EvaluationCell` が取得できない場合はノートブック末尾に書き込む。

### `NBInsertInputTemplate[nb, boxes]` → Null
Input セルテンプレートを挿入する。

## セルマーク API

### `NBGetConfidentialTag[nb, cellIdx]` → True | False | Missing[]
TaggingRules から機密タグを返す。

### `NBSetConfidentialTag[nb, cellIdx, val]` → Null
セルの機密タグを設定する。`val` は `True | False`。

### `NBMarkCellConfidential[nb, cellIdx]` → Null
セルに機密マーク（赤背景 + WarningSign）を付ける。直接機密なセルに使用する。

### `NBMarkCellDependent[nb, cellIdx]` → Null
セルに依存機密マーク（橙背景 + LockIcon）を付ける。機密変数に依存する計算結果など、間接的に機密なセルに使用する。

### `NBUnmarkCell[nb, cellIdx]` → Null
セルの機密マーク（視覚・タグ）をすべて解除する。

## セル内容分析 API

### `NBCellUsesConfidentialSymbol[nb, cellIdx]` → True | False
セルが機密変数を参照しているかを返す。`$NBConfidentialSymbols` に登録された変数名を検査する。

### `NBCellExtractVarNames[nb, cellIdx]` → {String...}
セル内容から `Set`/`SetDelayed` の左辺（LHS）の変数名を抽出する。

### `NBCellExtractAssignedNames[nb, cellIdx]` → {String...}
セル内容から `Confidential[]` 内の代入先変数名を抽出する。

### `NBShouldExcludeFromPrompt[nb, cellIdx]` → True | False
セルが LLM プロンプトから除外すべきかを返す。

### `NBIsClaudeFunctionCell[nb, cellIdx]` → True | False
セルが Claude 関数呼び出しセル（`ClaudeQuery` 等）かを返す。

### `NBExtractAssignments[text]` → {{lhs, {rhsVars...}}...}
テキストから `Set`/`SetDelayed` の LHS 変数名と RHS 依存変数を抽出する。
```mathematica
NBExtractAssignments["x = 1; f[y_] := y^2"]
```

## 依存グラフ API

### `NBBuildVarDependencies[nb]` → Association
ノートブックの Input セルを解析して変数依存関係グラフを返す。文字列リテラル内の識別子は除外される。
→ `<|"var" -> {"dep1", ...}, ...|>`

### `NBTransitiveDependents[deps, confVars]` → {String...}
依存グラフ上で `confVars` に直接・間接依存する全変数名リストを返す。
```mathematica
deps = NBBuildVarDependencies[nb];
allDependent = NBTransitiveDependents[deps, {"apiKey", "secret"}]
```

### `NBScanDependentCells[nb]` → Integer
依存グラフを使って機密変数に依存するセルに `NBMarkCellDependent` を適用し、新たにマークしたセル数を返す。Claude 関数呼び出しセル（`ClaudeQuery` 等）は除外される。

### `NBDependencyEdges[nb]` → {DirectedEdge[String, String]...}
ノートブックの変数依存関係をエッジリストで返す。`DirectedEdge["dep", "var"]` は「var が dep に依存する」を意味する。`confVars` 指定時は機密変数に関連するエッジのみ返す。
```mathematica
edges = NBDependencyEdges[nb]
edges = NBDependencyEdges[nb, {"apiKey"}]
```

### `NBDebugDependencies[nb, confVars]` → Null
依存グラフ・推移依存・セルテキストを `Print` で表示するデバッグ関数。各 Input セルについて InputText 取得結果、代入解析結果、依存判定結果を出力する。

### `NBPlotDependencyGraph[nb, opts]`
ノートブックの変数依存関係グラフをプロットする。ノードは変数名・`Out[n]` で、直接秘密は赤、依存秘密は橙で着色される。エッジラベルは依存を定義するセルの `In[xx]` 番号。
→ Graph オブジェクト
Options: PrivacySpec -> <|"AccessLevel" -> 1.0|> (表示範囲を制御)

## 関数定義解析

### `NBGetFunctionGlobalDeps[nb]` → Association
ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。パターン変数とスコーピング局所変数（`Module`/`Block`/`With`/`Function`）は除外される。
→ `<|"関数名" -> {"大域変数1", ...}, ...|>`

## ノートブック TaggingRules API

### `NBGetTaggingRule[nb, key]` → 値 | Missing[]
ノートブックの TaggingRules から値を取得する。`key` は String | {String...} でネストしたパスの指定も可能。

### `NBSetTaggingRule[nb, key, value]` → Null
ノートブックの TaggingRules に値を設定する。`key` は String | {String...} でネストしたパスの指定も可能。

### `NBDeleteTaggingRule[nb, key]` → Null
ノートブックの TaggingRules からキーを削除する。

### `NBListTaggingRuleKeys[nb]` → {String...}
ノートブックの TaggingRules の全キーを返す。`prefix` 指定時はそれで始まるキーのみ返す。
```mathematica
NBListTaggingRuleKeys[nb, "claude"]
```

## 汎用履歴データベース API

NBAccess は TaggingRules をバックエンドとした差分圧縮付き履歴データベースを提供する。各履歴は `tag` 文字列で識別され、`<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>` の構造を持つ。

### `NBHistoryCreate[nb, tag, diffFields]`
新しい履歴データベースを作成する。既存 DB に同じ `diffFields` がある場合は既存ヘッダーを返す（冪等）。`headerOverrides` で追加ヘッダーを指定可能。
→ ヘッダー Association
```mathematica
NBHistoryCreate[nb, "chat-session1", {"fullPrompt", "response", "code"}]
```

### `NBHistoryData[nb, tag, opts]`
TaggingRules から履歴データを読み取り、差分圧縮されたエントリを復元して返す。
→ `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### `NBHistoryRawData[nb, tag]` → Association
差分圧縮を解除せずに履歴データを返す（内部用）。

### `NBHistorySetData[nb, tag, data]` → Null
TaggingRules に履歴データを書き込む。`entries` は差分圧縮されていない平文で渡すこと（自動的に圧縮される）。

### `NBHistoryAppend[nb, tag, entry, opts]` → Null
エントリを履歴に追加する。直前エントリの対象フィールドを Diff で差分圧縮する。
Options: PrivacySpec -> Automatic (エントリに privacylevel を記録)

### `NBHistoryEntries[nb, tag, opts]` → {Association...}
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### `NBHistoryEntriesWithInherit[nb, tag, opts]` → {Association...}
親履歴を含む全エントリを返す。ヘッダーの `parent`/`inherit`/`created` に従って親チェーンを辿る。
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### `NBHistoryUpdateLast[nb, tag, updates]` → Null
最後のエントリを更新する。

### `NBHistoryReplaceEntries[nb, tag, entries]` → Null
エントリリスト全体を置換する。コンパクションやバッチ更新に使用する。

### `NBHistoryReadHeader[nb, tag]` → Association
履歴のヘッダー Association を返す。

### `NBHistoryWriteHeader[nb, tag, header]` → Null
履歴のヘッダーを書き込む。

### `NBHistoryUpdateHeader[nb, tag, updates]` → Null
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加される。

### `NBHistoryListTags[nb, prefix]` → {String...}
`prefix` で始まる履歴タグ一覧を返す。

### `NBHistoryDelete[nb, tag]` → Null
指定タグの履歴を TaggingRules から削除する。

### `NBFilterHistoryEntry[entry, confVars]` → Association
履歴エントリ内の `response`/`instruction` に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。

## セッションアタッチメント API

### `NBHistoryAddAttachment[nb, tag, path]` → Null
セッションにファイルをアタッチする。ヘッダーの `"attachments"` リストにパスを追加する（重複除去）。

### `NBHistoryRemoveAttachment[nb, tag, path]` → Null
セッションからファイルをデタッチする。

### `NBHistoryGetAttachments[nb, tag]` → {String...}
セッションのアタッチメントリストを返す。

### `NBHistoryClearAttachments[nb, tag]` → Null
セッションの全アタッチメントをクリアする。

## API キーアクセサー

### `NBGetAPIKey[provider, opts]`
AI プロバイダの API キーを返す。`SystemCredential` へのアクセスを一元管理する。`provider` は `"anthropic"` | `"openai"` | `"github"`。
→ String（API キー）
Options: PrivacySpec -> <|"AccessLevel" -> 1.0|> (API キーはデフォルトで最高レベル)

## アクセス可能ディレクトリ API

### `NBSetAccessibleDirs[nb, {dir1, dir2, ...}]` → Null
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。`nb` 省略時は `EvaluationNotebook[]` を使用。

### `NBGetAccessibleDirs[nb]` → {String...}
保存されたアクセス可能ディレクトリリストを返す。引数省略時は `EvaluationNotebook[]` から取得する。

## Job 管理 API

ClaudeQuery/ClaudeEval の非同期出力位置を管理するための API。評価セル直後にスロットセルを挿入し、応答コンテンツを順序付けて書き込む。

### `NBBeginJob[nb, evalCell]` → ジョブ ID
評価セルの直後に3つの不可視スロットセルを挿入しジョブ ID を返す。`evalCell` が `CellObject` でない場合はノートブック末尾に挿入する。
スロット1: システムメッセージ（プログレス・フォールバック通知）、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### `NBBeginJobAtEvalCell[nb]` → ジョブ ID
`EvaluationCell[]` を内部取得してその直後に Job スロットを挿入する。[claudecode](https://github.com/transreal/claudecode) が CellObject を保持する必要がない。

### `NBWriteSlot[jobId, slotIdx, cellExpr]` → Null
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。

### `NBJobMoveToAnchor[jobId]` → Null
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### `NBEndJob[jobId]` → Null
ジョブを正常終了する。未書き込みスロットとアンカーを削除しテーブルをクリアする。

### `NBAbortJob[jobId, errorMsg]` → Null
エラーメッセージを書き込みジョブを終了する。

## 機密変数管理 API

### `NBSetConfidentialVars[assoc]` → Null
機密変数テーブルを一括設定する。`assoc` は `<|"varName" -> True, ...|>`。

### `NBGetConfidentialVars[]` → Association
現在の機密変数テーブルを返す。

### `NBClearConfidentialVars[]` → Null
機密変数テーブルをクリアする。

### `NBRegisterConfidentialVar[name, level]` → Null
機密変数を1つ登録する。`level` のデフォルトは `1.0`。

### `NBUnregisterConfidentialVar[name]` → Null
機密変数を1つ解除する。

### `NBGetPrivacySpec[]` → Association
現在の `$NBPrivacySpec` を返す。

## CellEpilog 管理 API

### `NBInstallCellEpilog[nb, key, expr]` → Null
ノートブックの CellEpilog に式を設定する。`key` は識別用文字列。既にインストール済みなら何もしない。

### `NBCellEpilogInstalledQ[nb, key]` → True | False
CellEpilog が `key` で既にインストールされているか返す。

### `NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]` → Null
機密変数追跡用 CellEpilog をインストールする。`checkSymbol` は `FreeQ` チェック用のマーカーシンボル。既にインストール済みなら何もしない。

### `NBConfidentialEpilogInstalledQ[nb, checkSymbol]` → True | False
機密追跡 CellEpilog がインストール済みか返す。

## その他のユーティリティ

### `NBEvaluatePreviousCell[nb]` → Null
直前のセルを選択して評価する。

### `NBParentNotebookOfCurrentCell[]` → NotebookObject
`EvaluationCell` の親ノートブックを返す。

### `NBAccess`iCellToInputText[cell]` → String
FrontEnd 経由でセルの InputText 形式を取得する。失敗時は `NBCellExprToText` にフォールバック。内部公開関数。

## 関連パッケージ

- [claudecode](https://github.com/transreal/claudecode) — Claude AI との対話インターフェース。NBAccess を利用してノートブックの読み書きとプライバシー管理を行う。
- [NotebookExtensions](https://github.com/transreal/NotebookExtensions) — ノートブック拡張機能。
- [PresentationListener](https://github.com/transreal/PresentationListener) — プレゼンテーション連携。