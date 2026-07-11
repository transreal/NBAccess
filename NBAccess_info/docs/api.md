## オプションシンボル
### PrivacySpec
NBAccess 関数のプライバシーフィルタリングオプション。値は `<|"AccessLevel" -> level|>`。AccessLevel ≤ セルのプライバシーレベルのセルのみアクセス可能。0.5=クラウドLLM安全データのみ(既定)、1.0=ローカルLLM環境など全データ。

### Decompress
NBAccess 履歴関数のオプション。True(既定)=Diff差分を復元して平文で返す、False=Diffオブジェクトのまま返す(差分検査用)。System`Decompress をオプションラベルとして使用。

## グローバル変数
### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。ローカルLLM環境からは `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` を設定。

### $NBConfidentialSymbols
型: Association(`<|"変数名" -> privacyLevel, ...|>`), 初期値: `<||>`
秘密変数名とプライバシーレベルのテーブル。ClaudeCode パッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMに送信するかを制御。True=秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信、False=秘密依存 Output のスキーマ情報を一切送信しない。非秘密 Output は常にスマート要約付きで送信される。

### $NBVerbose
型: Boolean, 初期値: False
NBAccess の詳細ログ出力を制御。True=内部の詳細ログを Messages に出力、False=重大エラー以外を抑制。

### $NBAutoEvalProhibitedPatterns
型: List(RegularExpression または StringExpression), 初期値: `{}`
NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト。セル内容がいずれかにマッチすると評価をスキップし警告を表示。ClaudeCode がロード時に登録する。

### $NBSeparationIgnoreList
型: List(String), 初期値: `{"NBAccess", "NotebookExtensions"}`
ClaudeCheckSeparation の分離検査で無視するファイル名・パッケージ名のリスト。
例: `AppendTo[$NBSeparationIgnoreList, "MyPackage"]`

### $NBLLMQueryFunc
型: 関数(コールバック)
非同期 LLM 呼び出し用コールバック関数。ClaudeCode が `ClaudeQueryAsync` を自動登録する。
シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool, Integrations -> {...}]`
callback は応答文字列を受け取る関数、nb は出力先 NotebookObject、Integrations は LM Studio MCP 用(lmstudio モデル時のみ有効、Automatic なら無視)。カーネルをブロックしない。

## セルユーティリティ
### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。見つからなければ 0。

### NBSelectedCellIndices[nb] → List
選択中セル(セルブラケット選択またはカーソル位置)のインデックスリストを返す。

### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリストを返す。style に `{style1, style2, ...}` で複数スタイル指定可。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルを全削除する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得。失敗時は NBCellExprToText にフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel(例: "In[3]:=")を返す。ラベルなしなら ""。

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

### NBCellSetStyle[nb, cellIdx, style]
セルのスタイルを変更する。Cell 式の第2引数を書き換える。TaggingRules 等の属性は保持。
例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code]
既存セルにコードを BoxData + Input スタイルで書き込む。FEParser で構文カラーリング付き BoxData に変換し、Cell 式全体を置換する。
例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBCellWriteText[nb, cellIdx, newText]
セルのテキスト内容を newText に置換する。スタイル・TaggingRules・オプション等の属性は保持。
例: `NBCellWriteText[nb, 3, "新しいテキスト"]`

### NBSelectCell[nb, cellIdx]
セルブラケットを選択状態にする。ペースト操作後のセル選択復元に使用。

### NBResolveCell[nb, cellIdx] → CellObject
CellObject を返す。インデックスが無効なら $Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → 値
TaggingRules のネスト値を返す。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value]
セルの TaggingRules にネスト値を設定する。NBCellGetTaggingRule の対のセッター。
例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`

### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像(RasterBox/GraphicsBox)を含むか判定。cellExpr は NBCellRead の戻り値を想定。

### NBInvalidateCellsCache[] / NBInvalidateCellsCache[nb]
内部セルキャッシュ($iCellsCache/$iCellStyleCache)をクリアする。nb 省略時は全ノートブック分をクリア。

### NBUserNotebooks[] → List
WindowFrame が通常のユーザーノートブックのみを返す(パレット・ダイアログ等を除外)。

### NBRefreshCellsCache[] → List
ユーザーノートブックのセルキャッシュをスマートに再検証し、変更があった NotebookObject のリストを返す。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。

## LLM 連携
### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可なら ""。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換する。promptFn はセルテキストを受け取りプロンプト文字列を返す関数。completionFn は結果 Association を受け取るコールバック(エラー時は $Failed)。カーネルをブロックしない。セルのプライバシーレベルに応じ適切な LLM を自動選択。
→ Null(非同期)
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使う入力テキスト), Integrations -> Automatic (LM Studio MCP サーバーリスト、lmstudio モデル時のみ)
completionFn が受け取る Association: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー
### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル(0.0〜1.0)を返す。0.0=非秘密、1.0=秘密(Confidentialマーク or 秘密変数参照)。

### NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] → Boolean
セルが指定 PrivacySpec でアクセス可能かを返す。

### NBFilterCellIndices[nb, indices, PrivacySpec -> ps] → List
セルインデックスリストを PrivacySpec でフィルタリングして返す。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

### NBConfidentialHandlingAllowedQ[mode, permissionMode] → Boolean
ConfidentialHandling mode(EncryptedBundle/ReferenceOnly/Redacted/PlaintextDebug)が permissionMode で許容されるか返す(PlaintextDebug gate)。

## テキスト抽出
### NBCellExprToText[cellExpr] → String
NotebookRead の結果(Cell式)からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, PrivacySpec -> ps] → List
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。

### NBGetContext[nb, afterIdx, PrivacySpec -> ps] → String
afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築する。PrivacySpec でフィルタリング。既定 AccessLevel 0.5。

## 書き込み
### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。style の既定は "Text"。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろに Input セルを挿入しカーソルをセル先頭に移動する。autoEvaluate が True なら SelectionEvaluate も行う。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル(name)と Text セル(prompt)を挿入して保存・閉じる。

### NBWriteCell[nb, cellExpr] / NBWriteCell[nb, cellExpr, pos]
ノートブックに Cell 式を書き込む。pos は After(既定)/Before/All。遅延出力が有効な間は After 書き込みをバッファに溜める。

### NBWritePrintNotice[nb, text, color]
ノートブックに通知用 Print セルを書き込む。nb が None なら CellPrint を使用。

### NBCellPrint[cellExpr]
評価中セルの直後に出力セルを挿入する(CellPrint ラッパー)。常に EvaluationCell の直後に配置される。ClaudeBackupDataset 等のタグ付き出力セルに使用する。

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
ノートブックに Dynamic セルを書き込む。tag が "" でなければ CellTags を設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。autoEvaluate が True なら直前セルを評価する。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書き込む。EvaluationCell が取得できない場合はノートブック末尾に書き込む。

## 遅延出力
非同期並列処理やブロック回避時に NBWriteCell の After 書き込みをバッファリングし一括 flush する仕組み。
### NBBeginDeferredOutput[]
出力遅延モードを有効にする。以降 NBWriteCell[nb, cell](After)はバッファに溜まる。NBEndDeferredOutput と対。

### NBEndDeferredOutput[]
出力遅延モードを無効に戻す。バッファは保持されるので NBFlushDeferredOutput で出力する。

### NBFlushDeferredOutput[nb] → Integer
溜めた Cell を notebook に一括書き込みバッファをクリアする。戻り値は出力 Cell 数。メインカーネル評価で呼ぶこと。NBFlushDeferredOutput[](nb 省略)は CellPrint で出力する。

### NBDeferredOutputActiveQ[] → Boolean
出力遅延モードが有効か返す。

### NBDeferredOutputCount[] → Integer
バッファに溜まっている Cell 数を返す。

### NBDiscardDeferredOutput[]
バッファをフラッシュせず破棄する。

## ファイル型ノートブック操作
閉じた .nb ファイルを対象とした読み書き。上位層から .nb を直接 NotebookOpen/NotebookGet せず必ずこの API を経由すること。
### NBFileOpen[path] → NotebookObject
.nb ファイルを非表示(Visible->False)で開き NotebookObject を返す。失敗時は $Failed。必ず NBFileClose で閉じる。
例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`

### NBFileClose[nb]
NBFileOpen で開いたノートブックを閉じる。

### NBFileSave[nb, path]
開いているノートブックを指定パスに保存する。path が None なら上書き保存。

### NBFileReadCells[nb, PrivacySpec -> ps] → List
全セルを PrivacySpec でフィルタリングし `{<|cellIdx, style, text, privacyLevel|>, ...}` を返す。privacyLevel > PrivacySpec の秘匿セルはテキストを "[CONFIDENTIAL]" に置換。
例: `cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]`

### NBFileReadAllCells[nb] → List
全セルをアクセスレベル別に分類して返す。秘匿セルも含む全セルを返し PrivacyLevel フィールドで識別可能。ローカルモデル処理時に使用。

### NBFileWriteCell[nb, cellIdx, newText]
指定セルのテキストを newText で置換する。スタイル・TaggingRules・秘匿マーク等の属性は保持。
例: `NBFileWriteCell[nb2, 3, "This is a pen."]`

### NBFileWriteAllCells[nb, replacements]
`{cellIdx -> newText, ...}` の Association または List に従って複数セルを一括置換する。
例: `NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]`

## SourceVault ヘッダー・Todo
閉じた .nb ファイルのヘッダーと Todo を読み書きするファイルベース API。
### NBReadHeader[path, opts] → Association
notebook の SourceVault ヘッダーを抽出する。TaggingRules・HeaderCell・BoxData の順に探索。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.5 相当のフィルタリング)
戻り値: `<|"Status" -> "OK"|"Failed", "Keywords", "Deadline", "NextReview", "Owner", "PathHint", "RawHeader", "Source" -> "TaggingRules"|"HeaderCell"|"BoxData"|"None"|>`

### NBReadTodos[path, opts] → Association
notebook の Todo cell を全抽出する。CellGroupData ネストも再帰展開。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.5 相当のフィルタリング)
戻り値: `<|"Status" -> _, "Todos" -> {<|"Index", "Text", "Status" -> "Open"|"Done"|"Pass", "CellPath", "StatusSource", "ExpressionUUID"|>, ...}|>`

### NBFindCellByPredicate[path, predicate, opts] → Association
predicate が True を返すセルを全検索する。predicate は Cell 式を受け取り True/False を返す関数。CellGroupData ネストも再帰展開。
Options: "AccessSpec" -> Automatic, "MaxResults" -> All|_Integer
戻り値: `<|"Status" -> _, "Matches" -> {<|"CellIndex", "CellPath", "Cell" -> HoldComplete[Cell[...]], "Style", "ExpressionUUID"|>, ...}|>`

### NBSetCellOptionsByPredicate[path, predicate, optionRules, opts] → Association
predicate が True を返すセルの options を optionRules で上書きする。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.7 相当), "DryRun" -> True, "MaxResults" -> All
戻り値: `<|"Status" -> "OK"|"Failed"|"DryRunOK", "Modified" -> {...}, "DryRun" -> _, "AccessLevel" -> _|>`

### NBSetCellTaggingRuleByPredicate[path, predicate, taggingKeyPath, value, opts] → Association
predicate が True を返すセルの TaggingRules 内部の key パスを value で設定する。
例: `NBSetCellTaggingRuleByPredicate[path, pred, {"SourceVault", "TodoStatus"}, "Done"]`
Options: NBSetCellOptionsByPredicate と同様。

### NBWriteHeader[path, key, value, opts] → Association
notebook の SourceVault ヘッダー 1 フィールドを更新する。key: "Status"/"Keywords"/"Deadline"/"NextReview"/"Owner"/"PathHint" など。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.7 相当), "DryRun" -> True
戻り値: `<|"Status" -> "OK"|"Failed"|"DryRunOK", "Before", "After", "DryRun", "Path"|>`

### NBWriteTodoStatus[path, todoKey, newStatus, opts] → Association
todoKey で特定される Todo cell の Status を newStatus に変更する。todoKey: `<|"Index" -> n, "Text" -> ".."|>`。newStatus: "Open"/"Done"/"Pass"。FontVariations/FontColor/TaggingRules を更新する。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.7 相当), "DryRun" -> True

## ObjectSpec / パス正規化
### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を Association で返す。PrivacyLevel: `<0.5`=クラウドLLM可、`>=0.5`=ローカルのみ、`{0.5,1.0}`=混在(.nb)。
Options: PrivacySpec -> Automatic, "IncludeProjections" -> False

### NBFileSpecCacheClear[]
NBFileSpec の base/projection キャッシュをクリアする(Phase 4.3)。

### NBNormalizePath[path] → Association
絶対パスを複数PC間で安定なシンボリックパス情報の Association に正規化する。
→ `<|"Kind", "RootId", "Parts", "SymbolicPath", "PhysicalPath", "ResolutionStatus", "MatchedBy"|>`
ResolutionStatus: "ResolvedOnThisPC" | "AliasOnly" | "Unrooted"。MatchedBy: "LocalRoot" | "Alias" | "None"。SourceVault ロード済みなら iSVSymbolicPath のクロスPC正規化を利用。戻り値は同一性のための情報でアクセス権限を与えるものではない(rule 104)。

### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。
例: `NBValueSpec[dataset, 1.0]`

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5 -> {"cloud"}, 1.0 -> {"local"}, {0.5,1.0} -> {"cloud","local"}。

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevel が lo〜hi のセルのみ返す。
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]`(公開セルのみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb ファイルのセルを PrivacyLevel <= threshold(public)と > threshold(private)に2分割する。
例: `{pub, priv} = NBSplitNotebookCells["file.nb", 0.5]`

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
2つの `<|cellIdx->newText|>` を元セル順にマージして outputPath に保存する。
例: `NBMergeNotebookCells[src, dst, pubResults, privResults]`

## セルマーク
### $NBConfidentialCellOpts
型: List
NBMarkCellConfidential が適用する機密セルの装飾オプション列。赤背景(RGBColor[1,.90,.90])+赤枠+警告 dingbat。

### $NBDependentCellOpts
型: List
NBMarkCellDependent が適用する依存機密セルの装飾オプション列。橙背景(RGBColor[1,.95,.85])+橙枠。

### NBGetConfidentialTag[nb, cellIdx] → True|False|Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val(True/False)に設定する。

### NBMarkCellConfidential[nb, cellIdx, opts]
セルを機密(PrivacyLevel 1.0)に設定し赤背景マークを付ける。`NBMarkCellConfidential[nb, cellIdx, level]` で PrivacyLevel を任意数値(0.0-1.0)に設定。level > 0.5 で赤背景マーク、<= 0.5 でマーク除去。$NBApprovalHeads に登録され実行時に承認ゲートを発火。
Options: PrivacySpec -> Automatic

### NBSetSnapshotPrivacyLevel[snapshotId, level, opts]
SourceVault snapshot の PrivacyLevel を設定する。人間が明示的に上書きしたい場合に使用。SourceVault がロード済み必須。$NBApprovalHeads に登録され承認ゲートを発火。
Options: PrivacySpec -> Automatic

### NBInsertArtifactCell[nb, uri, opts] / NBInsertArtifactCell[uri, opts]
SourceVault artifact URI(`sv://artifact/<id>` または `sv://hash/sha256/<hex>`)の内容を解決しメディア種別に応じたセルとして挿入する。Image→画像セル、Video/Binary→ファイルリンク、Text→本文。artifact の PrivacyLevel が TaggingRules に焼き込まれ、level > 0.5 なら機密マーク(赤背景+警告 dingbat)付き。`NBInsertArtifactCell[uri]` は EvaluationNotebook[] へ。内容解決は SourceVault`SourceVaultResolveArtifactContent に委譲。SourceVault 未ロードなら Error。
→ `<|"Status", "URI", "MediaKind", "PrivacyLevel", "Marked"|>`
Options: "VideoCell" -> False (True で Video[file]セル、既定はファイルリンク), "MaxImageSize" -> 480 (表示幅 px、None で原寸), "Materialize" -> Automatic

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク(橙背景 + LockIcon)を付ける。機密変数に依存する計算結果など間接的に機密なセルに使用。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク(視覚・タグ)をすべて解除する。

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定する。key は識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilog が key で既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストールする。checkSymbol は FreeQ チェック用のマーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡 CellEpilog がインストール済みか返す。

### NBConfidentialLineNumbers[nb, accessSpec] → List
ノートブック内の機密・機密依存 Input/Code/Output セルの評価行番号(n; In[n] と Out[n] は同一 n)のリストを返す。LLM が Out[n]/In[n]/InString[n]/% で機密セルを参照したときの漏洩検出に使う。

### NBCollectDeclassifiedVarNames[nb] → List
TaggingRules に `{"claudecode", "declassified"}` タグを持つセルで代入された変数名を収集する。

## セル内容分析
### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが機密変数を参照しているかを返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容から Confidential[] 内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきかを返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルが Claude 関数呼び出しセルかを返す。

### NBExtractAssignments[text] → List
テキストから Set/SetDelayed の LHS 変数名を抽出する。

### NBTextUsesConfidentialHead[text] → Boolean
text が登録済みの機密生成ヘッドを参照していれば True を返す。識別子境界(Unicode)で判定し、Map などへ関数値として渡される形(ブラケットなし)も検出する。

## 依存グラフ
### NBAccess`iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析し変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返す。文字列リテラル内の識別子は除外。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査して統合された変数依存関係グラフを返す。LLM 呼び出し直前の精密チェックで使用。通常実行時は軽量版 NBBuildVarDependencies[nb] を使用。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存の依存グラフに CellLabel In[x](x > afterLine)のセルのみ追加走査してマージする。完全なグラフを毎回構築するコストを回避するインクリメンタル版。

### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。`NBScanDependentCells[nb, confVarNames, deps]` は事前計算済みの依存グラフ deps を使う(二重計算回避)。Claude 関数呼び出しセル(ClaudeQuery 等)は除外。

### NBFilterHistoryEntry[entry, confVars] → entry
履歴エントリ内の response/instruction に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。confVars は現在の機密変数名リスト。

### NBDependencyEdges[nb] → List
ノートブックの変数依存関係をエッジリストで返す。
→ `{DirectedEdge["dep", "var"], ...}`("dep" → "var" は "var が dep に依存する")
`NBDependencyEdges[nb, confVars]` は機密変数 confVars に関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。

### NBPlotDependencyGraph[opts] / NBPlotDependencyGraph[nb, opts]
全ノートブック統合(既定)または指定ノートブックの依存グラフをプロットする。ノードは変数名・Out[n]、直接秘密は赤、依存秘密は橙で着色。NB内エッジは濃い実線、クロスNBエッジは薄い破線。
Options: "Scope" -> "Global"(既定)|"Local", PrivacySpec -> `<|"AccessLevel" -> 1.0|>`
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

## 関数定義解析
### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存する大域変数のリストを返す。
→ `<|"関数名" -> {"大域変数1", ...}, ...|>`
パターン変数とスコーピング局所変数(Module/Block/With/Function)は除外。

## ノートブック TaggingRules
### NBGetTaggingRule[nb, key] → 値|Missing[]
ノートブックの TaggingRules から key の値を返す。`NBGetTaggingRule[nb, {key1, key2, ...}]` でネストパス指定可。キーがなければ Missing[]。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に key -> value を設定する。`NBSetTaggingRule[nb, {key1, key2}, value]` でネストパス指定可。

### NBDeleteTaggingRule[nb, key]
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] → List
TaggingRules の全キーを返す。`NBListTaggingRuleKeys[nb, prefix]` で prefix で始まるキーのみ返す。

### NBSetNotebookDefaultModel[nb, provider, modelName]
ノートブックのデフォルトモデル(claudecode パレット設定 paletteProvider/paletteModelName)を書き換える。NBAccess 以外がノートブック内部データを書き換えない原則に従い書き込みは NBAccess が行う。

### NBGetNotebookDefaultModel[nb] → {provider, modelName}|Missing["NotDeclared"]
ノートブックのデフォルトモデルを返す。未設定なら Missing["NotDeclared"]。

## 汎用履歴データベース
履歴は TaggingRules に差分圧縮で保存される。エントリは fullPrompt/response/code 等のフィールドを直前エントリとの Diff で圧縮。
### NBHistoryData[nb, tag, opts] → Association
TaggingRules から履歴データを読み取り、差分圧縮されたエントリを復元して返す。
→ `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す(内部用)。

### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書き込む。data は `<|"header" -> ..., "entries" -> {...}|>`。entries は差分圧縮されていない平文で渡すこと(自動圧縮される)。

### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加する。差分圧縮: 直前エントリの fullPrompt/response/code を Diff で圧縮。
Options: PrivacySpec -> ps (privacylevel をエントリに記録)

### NBHistoryEntries[nb, tag, opts] → List
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updates は `<|"response" -> ..., "code" -> ..., ...|>`。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリを返す。header の parent/inherit/created に従って親チェーンを辿る。
Options: Decompress -> True (False で Diff オブジェクトのまま返す)

### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクションやバッチ更新に使用。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加。

### NBHistoryCreate[nb, tag, diffFields] / NBHistoryCreate[nb, tag, diffFields, headerOverrides] → header
新しい履歴データベースを作成する。diffFields は差分圧縮対象のフィールド名リスト(例: `{"fullPrompt", "response", "code"}`)。既存 DB に diffFields がある場合は既存ヘッダーを返す(冪等)。ヘッダーには "type"->"history_header", "parent"->None, "inherit"->True, "created"->AbsoluteTime[] が既定で自動付与され、既存ヘッダー/headerOverrides とマージされる。

### NBHistoryCacheClear[]
履歴読み取りキャッシュ($iNBHistoryCache)をクリアする。

## セッションアタッチメント
### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加(重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, PrivacySpec -> ps]
prefix で始まる全履歴を削除する。PrivacySpec -> `<|"AccessLevel" -> 1.0|>` が必須。セルレベルの機密・機密依存タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。

## API キーアクセサ
### NBGetAPIKey[provider] → String
AI プロバイダの API キーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0 が必須で、呼び出し側で PrivacySpec -> `<|"AccessLevel" -> 1.0|>` を明示指定すること。SystemCredential へのアクセスを一元管理。

### NBListProviderModels[provider] → Association
クラウドプロバイダ(anthropic/openai)の利用可能モデル ID リストを返す。API キーは内部で SystemCredential から読み外部に出さない。PrivacySpec/AccessLevel 指定は不要。
→ `<|"Status" -> _, "Provider" -> _, "Models" -> {_String..}|>`

## ローカル LLM API キーアクセサ
### NBGetLocalLLMAPIKey[provider, url] → String
ローカル LLM サーバー(LM Studio 等)の API キーを SystemCredential から返す。照合は {provider, url} ペア。AccessLevel >= 1.0 が必須(PrivacySpec -> `<|"AccessLevel"->1.0|>` 明示)。解決優先度: (1)完全一致 (2)localhost⇔127.0.0.1 置換版 (3){provider, "*"} ワイルドカード (4)フォールバック名 `ToUpperCase[provider]<>"_API_KEY"`。
例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録する。SystemCredential の実値自体は書き込まない(名前の紐付けのみ)。
→ `{provider, normalizedUrl} -> credentialName`

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key]
上記マッピング登録に加えて `SystemCredential[credentialName] = key` も同時設定する。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url]
{provider, url} のエントリを削除する。SystemCredential 本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
登録済みローカル LLM サーバー → API キー名マッピングを Dataset で返す。Configured 列は SystemCredential が実際に設定済みかを示す。

### NBLocalLLMCredentialName[provider, url] → String
SystemCredential 名のみを返す(値は取得しない)。AccessLevel チェックなし。登録確認用。

## フォールバックモデル / プロバイダアクセスレベル
### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{"provider","model"}, {"provider","model","url"}, ...}`。
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベル(0.0〜1.0)を設定する。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは 0.5。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダーの MaxAccessLevel >= accessLevel のモデルのみ。
例: `NBGetAvailableFallbackModels[0.8]` → lmstudio のみ

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダーが指定アクセスレベルのデータにアクセス可能かを返す。MaxAccessLevel >= accessLevel なら True。

### NBModelCanHandleAccessLevel[modelSpec, accessLevel] → Boolean
モデル指定がそのアクセスレベルのデータを扱えるかを返す。Private ノート(レベル 1.0)でクラウドモデル(=0.5)を拒否しローカル LLM(lmstudio=1.0)のみ通すために使う。modelSpec: `{provider, model}` | `{provider, model, url}` | "model" | Automatic(未指定は True)。

### NBModelProviderName[modelSpec] → String
modelSpec から provider 文字列を取り出す。

### NBNotebookRequiredAccessLevel[nb] → Real
ノートブックが要求するアクセスレベルを返す。Private 宣言(CloudPublishable -> False)なら 1.0(クラウド禁止)、それ以外は 0.0。

## 信頼ローカルサーバー
### NBRegisterTrustedLocalServer[assoc]
信頼できるローカル LLM サーバを登録する。assoc: `<|"MachineName" -> _, "Subnet" -> _, "Provider" -> _, "URL" -> _|>`。IP/サブネットはセキュリティ境界なので NBAccess が管理。モデル名は含めない(SourceVault が intent 解決で扱う)。
例: `NBRegisterTrustedLocalServer[<|"MachineName"->"phoenix", "Subnet"->"192.168.2", "Provider"->"lmstudio", "URL"->"http://192.168.2.110:1234"|>]`

### NBResolveLocalServer[] → Association
現在のマシン環境($MachineName と自 IP のサブネット)を信頼リストと照合し、信頼できるローカル LLM サーバ `<|"Provider" -> _, "URL" -> _, "Trusted" -> _, ...|>` を返す。未知のサブネットでは安全側に倒し localhost(127.0.0.1)のローカルサーバのみ返す。モデル名は返さない。

### NBTrustedLocalServers[] → Dataset
現在登録されている信頼ローカルサーバのリストを返す。

### NBSyncClaudeModelVars[opts]
SourceVault にキャッシュされているモデルで ClaudeCode の `$ClaudeModel` / `$ClaudeDocModel` / `$ClaudePrivateModel` / `$ClaudeFallbackModels` を更新する。intent 割当てマップ(SourceVaultModelIntentMap)を読み SourceVaultResolve でモデル ID に解決、ローカルサーバの URL は NBResolveLocalServer で安全に解決して実変数へ代入。SourceVault 未ロードなら何もしない。SourceVault ロード時に自動実行。
Options: Verbose -> False

## アクセス可能ディレクトリ
### NBSetAccessibleDirs[nb, {dir1, ...}] / NBSetAccessibleDirs[{dir1, ...}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。nb 省略時は EvaluationNotebook[]。

### NBGetAccessibleDirs[nb] / NBGetAccessibleDirs[] → List
保存されたアクセス可能ディレクトリリストを返す。nb 省略時は EvaluationNotebook[]。

### NBResolvePathRef[pathRef] → String|Missing[...]
PathRef(NBNormalizePath が返す Association、または `{"$onWork", ...}` 形式のシンボリックパスリスト)を現 PC の実パスへ解決する。解決でき実在すれば絶対パス文字列、解決できない(ルート未定義・別 PC エイリアスのみ)なら Missing[...]。SourceVault ロード済みなら iSVResolvePath を利用。rule 104: alias-only / root-missing な PathRef は実パスに解決されない。

### NBSetAccessiblePathRefs[nb, refs] / NBSetAccessiblePathRefs[refs]
AccessPathRef のリストを notebook の TaggingRules(claudeAccessiblePathRefs)に保存する。nb 省略時は EvaluationNotebook[]。各 AccessPathRef は `<|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|>`。claudeAccessiblePathRefs を正本とし、旧 claudeAccessibleDirs は read fallback。

### NBGetAccessiblePathRefs[nb] / NBGetAccessiblePathRefs[] → List
notebook に保存された AccessPathRef リストを返す。claudeAccessiblePathRefs が無い旧 notebook では claudeAccessibleDirs を AccessPathRef に変換して返す(read fallback)。実パスへの解決は NBResolvePathRef / NBGetAccessibleDirs で行う。

### NBNormalizeAccessPathRef[dirOrRef] → Association
旧形式の絶対パス文字列または部分的指定を完全な AccessPathRef Association に正規化する。文字列なら NBNormalizePath で PathRef 化し Mode -> "Read"、CloudSend -> "Ask" を既定とする。既に AccessPathRef なら不足キーを既定で補う。

### NBAuditCodexAccessibleDirs[dirs] → Association
Codex に公開する前に dirs 配下に Codex の最大アクセスレベルを超えるファイル(.env/*secret*/*credential*/*token*/秘密鍵/API キー類似内容など)がないか検査する必須ゲート。デフォルト動作は fail-stop(危険ファイル発見時は Failure を返し Codex を起動しない)。有限 MaxDepth を指定すると走査未完のためそれ自体がセキュリティ失敗扱いになる。
Options: "MaxDepth" -> Infinity, "OnDanger" -> "Fail"|"DenyAndContinue", "ScanContents" -> True, "MaxFileScanBytes" -> 262144
戻り値: `<|"Status", "Gate", "Findings", "AuditedDirs", "FileCount", "Truncated", "SuggestedDenyRules"|>`

## カーソル移動
### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## Job 管理(非同期出力位置管理)
ClaudeQuery/ClaudeEval の非同期出力位置を管理する。
### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入。スロット1: システムメッセージ(進捗・フォールバック通知)、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再書き込みすると上書きされる。

### NBJobMoveToAnchor[jobId] → True|False
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。位置確定できたら True。アンカー消失時はノートブック末尾へ退避し True。jobId 不明なら False(呼び出し側で末尾退避)。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除する。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[] を内部取得してその直後に Job スロットを挿入する。claudecode が CellObject を保持する必要がない。

### NBJobResetSlotWritten[jobId, slotIdx]
ジョブスロットの書き込み済みフラグをリセットする。同一スロットへの再書き込みを許可する際に使用。

## 機密変数・ヘッド管理
### NBGetConfidentialVars[] → Association
現在の機密変数テーブル `<|"varName" -> level|>` を返す。

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。assoc: `<|"varName" -> True, ...|>`

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する。level 既定 1.0。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

### NBGetConfidentialHeads[] → Association
登録済みの機密生成ヘッド表 `<|name -> level|>` を返す。

### NBRegisterConfidentialHead[name, level]
「返り値が機密たり得る関数ヘッド」を登録する。level 既定 1.0。SourceVault 等のデータ層がロード時に登録し、claudecode が LLM 生成コードの自動機密マークと CellEpilog の依存秘密判定に使う。

### NBUnregisterConfidentialHead[name]
機密生成ヘッドの登録を1つ解除する。

## クラウド公開設定
### NBGetCloudPublishable[path] → True|False|Missing[...]
ノートブックのクラウド公開宣言を読み取る。True=クラウドLLM可、False=クラウド禁止、Missing["NotDeclared"]=宣言無し(パスベース判定へフォールバック)。

### NBSetCloudPublishable[path, True|False, opts] → Association
ノートブックのクラウド公開宣言を設定する(TaggingRules > SourceVault > CloudPublishable)。設定後は NBFileSpec の PrivacyLevel が自動決定される。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.7 相当), "DryRun" -> False

### NBClearCloudPublishable[path, opts] → Association
ノートブックのクラウド公開宣言を「未指定」状態に戻す。SourceVault キーが空になれば削除。
Options: "AccessSpec" -> Automatic (既定で AccessLevel 0.7 相当), "DryRun" -> False

### NBSetNotebookPrivate[nb] / NBSetNotebookPrivate[nb, False] / NBSetNotebookPrivate[]
ノートブック全体を Private(CloudPublishable -> False)宣言し全セルの PrivacyLevel を 1.0 にする。NBSetNotebookPrivate[nb, False] で解除。nb 省略時は EvaluationNotebook[]。

## ノートブック修復・クリーンアップ
### NBRepairNotebookCache[path] → Association
.nb ファイルの outline cache を正規化する。「Wolfram システム外で編集されたようです」ダイアログが繰り返す .nb に使う。ファイル内容は変わらない。
戻り値: `<|"Status" -> "OK"|"Failed", "Path", "WasAlreadyOpen"|>`

### NBRepairNotebookCacheFolder[dir, opts] → Association
dir 配下の .nb を全部修復する。
Options: "Recursive" -> True

### NBRepairNotebookCacheStrict[path] → Association
NBRepairNotebookCache が効かなかった場合の強力版。NotebookImport → CreateDocument → NotebookSave で再作成する。
戻り値: `<|"Status" -> "OK"|"Failed", "Path", "Method" -> "RecreateAndSave"|>`

### NBCleanupTmpFiles[dir, opts] → Association
dir 配下の .nb.tmp-* 残骸を削除する。
Options: "Recursive" -> True

## セキュリティポリシー
NBAccess のアクセス制御・承認システム。NBAuthorize が PolicyGate + ScoreGate + EnvironmentGate を統合して AccessDecision を返す。
### $NBAllowedHeads
型: List
LLM が自由に実行可能な head のリスト。$NBAllowedHeadsByCategory から有効カテゴリの head を集約して動的に計算される。

### $NBApprovalHeads
型: List
人間承認を要する head のリスト。NBMarkCellConfidential・NBSetSnapshotPrivacyLevel 等がここに登録され、実行時に承認ゲートを発火する。

### $NBDenyHeads
型: List
常に拒否する head のリスト。

### $NBEffectClassOverrides
型: Association(`<|head -> <|"EffectClass", "BlockingRisk", "ExecutionPlacement", "RequiresFinalNode"|>, ...|>`)
head 名ごとの分類上書きテーブル(spec 5B.5A)。allowlist ではなく分類精度向上用。未登録 head はフォールバック分類(System` 純粋関数 -> PureComputation 等)に進む。

### $NBTrustedPackageHeads
型: Association(`<|"コンテキスト`" -> {"名前パターン", ...}|>`), 初期値: `<|"SourceVault`" -> {"SourceVault*"}|>`
「package 文脈だが承認不要とみなす head」の登録テーブル。SourceVault* 公開関数は全経路で PrivacyLevel を考慮した安全設計(release gate / fail-closed / 承認は関数内部の gate が担う)であるため unknown-head 承認を免除する。$NBDenyHeads / $NBApprovalHeads の明示登録はこの信頼より優先される(deny/approval チェックが先に走る)。過剰実行は $NBTrustedHeadIterationLimit の静的 guard と SourceVault 側の実行時 guard で保護する。

### $NBTrustedHeadIterationLimit
型: Integer, 初期値: 100
trusted package head を含む反復構造(Do/Table/For/Nest/Map over Range 等)の literal 反復数がこの値以上のとき NeedsApproval に格上げする閾値。

### NBAuthorize[obj, req] → Association
PolicyGate + ScoreGate + EnvironmentGate を統合した AccessDecision を返す。
戻り値: `<|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval", "ReasonClass", "RequiredAction", "VisibleExplanation", "RouteAdvice"|>`

### NBAuthorizeFile[pathOrSpec, req] → Association
NBFileSpec / file spec を NBAuthorize に渡す adapter。pathOrSpec が文字列なら NBFileSpec で base spec を取得。

### NBPermitQ[decision] → Boolean
NBAuthorize の AccessDecision を Boolean に落とす fail-closed helper。Decision が "Permit" のときだけ True。判定不能なら False。

### NBPolicyGate[obj, req] → Association
半順序ラベルに基づく flow 判定。PolicyLabel/ContainerLabel/SinkLabel を考慮する。

### NBScoreGate[obj, req] → Association
数値スコアに基づく routing/screening 判定(advisory 体系)。

### NBEnvironmentGate[obj, req] → Association
実行環境に基づく制約チェック。Sink/Environment/Principal を考慮する。

### NBValidateHeldExpr[heldExpr, accessSpec, opts] → Association
HoldComplete[...] 式を Allowed Expression Surface に照合し AccessDecision を返す。
Options: "AllowedHeads" -> Automatic, "ApprovalHeads" -> Automatic, "DenyHeads" -> Automatic, "LabelCheck" -> Automatic, "PolicySnapshot" -> None
戻り値: `<|"Decision" -> "Permit"|"Deny"|"NeedsApproval"|"RepairNeeded", ...|>`

### NBExecuteHeldExpr[heldExpr, accessSpec, opts] → Association
検証済み式を安全に実行し結果を返す。
Options: "TimeConstraint" -> 30, "ScreenMode" -> "Block", "PolicySnapshot" -> Automatic, "PreExecutionNotebookActions" -> {}, "Audit" -> True, "ApprovalMode" -> "None"
戻り値: `<|"Success" -> True|False, "RawResult", "Error"|>`

### NBExecuteHeldExprSubkernelRaw[held, accessSpec, opts]
subkernel 専用の実行 wrapper。snapshot 検証・NBSubkernelExecutableQ・再検証をすべて通過し Permit のときのみ ReleaseHold する。Screen/NeedsApproval/Deny/RepairNeeded はすべて $Failed。
Options: "TimeConstraint" -> 30

### NBSubkernelExecutableQ[held, accessSpec] → Boolean
held が subkernel で安全に実行できるかを返す(iShouldExecuteAsync の正式判定)。FrontEnd 操作・外部プロセス・ネットワーク・機密参照・DenyHeads/ApprovalHeads 該当などは False。

### NBValidateNotebookPreActions[actions, accessSpec] → List
PreExecutionNotebookActions のリストを検証し、許可された action だけを返す。

### NBInferExprRequirements[heldExpr, accessSpec, opts] → Association
式が必要とするアクセスレベル・書き込みターゲット・参照セル等を静的に推定する。
→ `<|"ReadCells", "WriteCells", "RequiredAccessLevel", "HasSideEffects" -> True|False, ...|>`
Options: "Depth" -> Infinity

### NBRedactExecutionResult[result, accessSpec, opts] → Association
実行結果を redact し安全な形で返す。accessSpec に "ConfidentialLineNumbers" があれば機密依存も検出しスキーマ化する。
戻り値: `<|"RedactedResult", "Summary" -> String|>`
Options: "MaxSummaryLength" -> 500

### NBMakeContextPacket[nb, accessSpec, opts] → Association
notebook から安全な context packet を構築する。
Options: "CellRange" -> All, "IncludeSelection" -> True, "MaxCells" -> 50 (走査セル数の上限)

### NBReleaseResult[result, accessSpec, opts] → Association
実行結果を指定 sink に安全に release する。redaction + routing check を行う。
Options: "Sink" -> "CloudLLM", "MaxSummaryLength" -> 500

### NBMakeRetryPacket[failureAssoc, accessSpec] → Association
失敗情報から秘密を含まない安全な retry packet を構築する。

### NBMakeFileAccessRequest[pathOrSpec, operation, opts] → Association
file 用の AccessRequest Association を組み立てる helper。operation: "ReadValue"|"WriteCell"|"WriteLog"|"SendExternal" など。
Options: "Subject" -> "ClaudeAgent", "Module" -> "claudecode", "Sink" -> Automatic, "Networked" -> Automatic, "Route" -> Automatic, "Provider" -> Automatic, "ModelIntent" -> Automatic, "AccessLevel" -> Automatic

### NBMakeRuntimeAccessSpec[contextPacket, role] → Association
Runtime/Orchestrator から NBAccess へ渡す accessSpec を作る。role: "ProposalEval"(既定, SubkernelAllowed)/"Committer"(MainOnly, FE/書込可)/"VisionFallback"/"ManualDispatch"。PolicySnapshot を凍結して埋める。

### $ClaudePermissionMode
型: String, 初期値: "InteractiveSafe"
ClaudeEval/NBAccess 共通の権限モード(spec 5B)。値: "ReviewOnly"(提案のみ)|"StrictSafe"(AutoPermit のみ実行)|"InteractiveSafe"(標準、AskUserAllowed は承認 UI)|"WorkflowSafe"(Orchestrator、final node 分離)|"LegacyInteractive"|"DangerFullAccess"。実行中の判定では accessSpec/snapshot に焼き込んだ値を正とし global を読み直さない(I12)。

### $ClaudeAllowHardDenyOverride
型: Boolean, 初期値: False
DangerFullAccess モードでのみ意味を持つ。True のとき HardDeny 相当(Run/ExternalEvaluate/破壊的 IO 等)を承認可能(NeedsApproval)へ格上げする。既定 False では HardDeny は承認しても実行しない。

### $ClaudeOutputMode
型: String, 初期値: "Streaming"
ClaudeEval/NBAccess 共通の出力モード。"Streaming"(逐次。結果が出るたびに notebook へ出力、計算状況が見える)|"Batch"(集約。notebook へ即時出力せずバッファに溜め最後にまとめて出力、非同期並列の多数処理向け)。最優先事項は FrontEnd/カーネルのブロック回避であり、BlockingRisk が MayBlockFrontEnd の出力は Streaming でも自動的に集約側へ回る。単発 ClaudeEval(出力1個)では Streaming/Batch で結果は同じ(実質無影響)。

### NBRouteDecision[scoreOrAccessSpec] → Association
数値スコアまたは accessSpec から routing 推奨を返す(advisory)。
戻り値: `<|"Route" -> "CloudLLM"|"PrivateLLM"|"LocalOnly", "EffectiveRiskScore", "Thresholds", "Reason" -> String|>`

### $NBRoutingThresholds
型: Association, 初期値: `<|"Cloud" -> 0.5, "Private" -> 0.8|>`
NBRouteDecision の routing 閾値。EffectiveRiskScore < Cloud → CloudLLM 候補、Cloud <= score < Private → PrivateLLM 候補、Private <= score → LocalOnly。

### NBResolveOutputMode[mode, blockingRisk] → String
即出力("Immediate")か集約("Deferred")かを返す。blockingRisk が "MayBlockFrontEnd" なら常に "Deferred"。mode が "Batch" なら "Deferred"。

### NBResolveDesktopActionPath[held, accessSpec] → Association
desktop action wrapper からパスを安全解決・検証のみ行う(SystemOpen は呼ばない)。
戻り値: `<|"IsDesktopAction", "Validated", "Path"|>`

### NBResolveCredentialRef[ref, accessSpec] → Association
credential-ref を解決し secret 本体ではなく取得用 descriptor を返す。handler はこの descriptor で NBGetAPIKey を呼ぶ(rules/20: 鍵を返す補助関数は作らない)。

### NBCheckFileRead[path, accessSpec] → Association
path の読み取りが accessSpec の MayAccessFileSystem/AllowedDirectories scope 内か検査する。
戻り値: `<|"Allowed" -> _, "Reason" -> _|>`

### NBCheckFileWrite[path, accessSpec] → Association
path への書き込みが scope 内か検査する。

### NBCheckNetworkAccess[target, accessSpec] → Association
target(URL または `<|Scheme, Host, Port|>`)が AllowedNetworkTargets scope 内か検査する。

### NBCheckExternalProcess[cmd, accessSpec] → Association
外部コマンドが AllowedExternalCommands 内か検査する。

### NBCheckedImport[path, fmt, accessSpec]
NBCheckFileRead 通過後に Import する。違反時は AccessSpecViolation を返す。

### NBCheckedExport[path, expr, fmt, accessSpec]
NBCheckFileWrite 通過後に Export する。

### NBCheckedURLRead[url, accessSpec]
NBCheckNetworkAccess 通過後に URLRead する。

### NBCheckedFileRead[path, accessSpec]
NBCheckFileRead 通過後にファイルを読み取る。

### NBCheckedFileWrite[path, content, accessSpec]
NBCheckFileWrite 通過後にファイルへ書き込む。

### NBRegisterFunctionSecurity[sym, spec]
関数 sym にセキュリティメタデータを登録する。spec: `<|"DefinitionLabel", "ExecPolicy" -> "Open"|"Guarded"|"Denied", "ReleasePolicy"|>`

### NBFunctionDefinitionLabel[f] → label
関数 f の定義ラベルを返す。コード自体の閲覧可否を制御する。

### NBFunctionExecPolicy[f] → String
関数 f の実行ポリシーを返す。"Open"|"Guarded"|"Denied"。

### NBFunctionReleasePolicy[f] → Association
関数 f の結果リリースポリシーを返す。

### GuardedApply[req, f, args] → 任意
f[args] をセキュリティポリシーに従って実行する。ExecPolicy が "Guarded" の場合、flow チェック後に実行し結果に適切なラベルを付与する。

### NBTryExecuteFinalActionHeld[held, accessSpec, opts] → Association
承認 wrapper を head の context に依存せず検出し引数パスを安全評価して OpenDesktopItem action に正規化し NBExecuteApprovedAction 経由で実行する。対象外なら `<|"Handled" -> False|>`。
Options: "ApprovalMode" -> "UserApproved"

### NBPolicySnapshot[] → Association
現在の NBAccess 動的 policy を凍結した Association を返す。snapshot mode の検証はこの snapshot を判定入力とし global を参照しない。キー: "SnapshotID"/"CreatedAt"/"AllowedHeads"/"ApprovalHeads"/"DenyHeads"/"ConfidentialSymbols"/"Digest"/"Source"。

### NBAcceptPolicySnapshot[snapshot] → Association
snapshot の必須キーと Digest を検証する。`<|"Valid" -> True|False, "Digest", "Reason"|>`。Valid のとき subkernel 内 $NBActivePolicySnapshot に保存してよいが、実行判定の正本は accessSpec["PolicySnapshot"]。

### $NBActivePolicySnapshot
型: Association|Missing[]
NBAcceptPolicySnapshot が Valid と判定した最新 snapshot を保持する(主に subkernel 側)。参考情報であり実行判定の正本ではない(正本は各実行の accessSpec["PolicySnapshot"])。

### NBApplyPolicySnapshot[snapshot] → Association
snapshot の digest を検証し正規化した snapshot を返す(global 復元はせず accessSpec 注入の補助に限定)。`<|"Valid", "Snapshot", "Reason"|>`。

### NBDefaultFilePolicyLabel[spec] → label
Phase 4 暫定の file policy label を返す(DLM/LabelJoin 完全実装までの最小実装)。

### NBNoExtraContainerLabel[] → label
Phase 4 暫定の container label を返す。

## 情報フロー制御
半順序ラベル(DLM)に基づく情報フロー制御 API。
### NBLabelQ[label] → Boolean
label が有効な NBAccess ラベルか判定する。

### NBLabelBottom[] → label
最小制約ラベル(public)を返す。

### NBLabelTop[] → label
最大制約ラベル(全拒否)を返す。

### NBLabelJoin[l1, l2] → label
ラベルの join(より制約的な方向)を返す。両方の制約を満たす方向。

### NBLabelMeet[l1, l2] → label
ラベルの meet(より緩い方向)を返す。

### NBLabelLEQ[l1, l2] → Boolean
l1 ⪯ l2(l1 の情報が l2 へ flow 可能)を判定する。

### NBCanFlowToQ[srcLabel, dstLabel] → Boolean
src から dst への flow が許可されるか判定する。

### NBCanDeclassifyQ[srcLabel, dstLabel, req] → Boolean
declassify が正当か判定する。

### Declassify[obj, req, releaseSpec] → 任意
obj のラベルを releaseSpec に従って引き下げる。req の Principal が acts-for 権限を持つ場合のみ許可。

### NBEffectiveLabel[obj, req] → label
オブジェクトと要求から実効ラベルを計算する。

### NBRegisterPrincipal[name, opts]
アクセス主体を登録する。

### NBGrantActsFor[p, q]
principal p が q として行動できる委任を登録する。

### NBActsForQ[p, q] → Boolean
p が q として行動可能か判定する。

## 承認ゲート・アクション実行
### NBRegisterAction[name, spec]
承認対象操作(desktop/notebook/filesystem)を action registry に登録する。spec キー: EffectClass, DefaultApprovalEligibility, AllowedTargetTypes, RequiresFinalNode, Validator, Executor。

### NBValidateAction[action, accessSpec] → Association
action association を registry の Validator + PermissionMode 変換で検証し Decision を返す。NBValidateHeldExpr と同形の戻り値。

### NBExecuteApprovedAction[action, accessSpec, opts] → Association
承認済み action を実行する。実行直前に再 validate し(TOCTOU 対策)、承認後に path/target が変化していれば PostApprovalValidationFailed で拒否。
Options: "ApprovalMode" -> "UserApproved"

### NBOpenFolderWithApproval[path]
OpenDesktopItem action(TargetType Folder)の薄い互換 wrapper。正本は action registry + permission mode。

### NBEnqueueFinalAction[action, accessSpec, opts] → actionID
承認済み final action を PendingFinalActionQueue に積む。直接同期実行せず、共有 polling tick が安全条件を満たしたとき1件ずつ実行する。
Options: "TTL" -> Automatic, "ApprovalStatus" -> "UserApproved", "MaxRetries" -> 100

### NBFinalActionTick[]
共有 polling tick から呼ばれ PendingFinalActionQueue の安全条件を確認して最大1件だけ実行する。新規 ScheduledTask は作らない。

### NBFinalActionStatus[actionID] → Association
queue item の状態を返す。actionID 省略時は全 item。状態: Pending/Running/Completed/Failed/Expired/Cancelled/NeedsRetryAfterAsync。

### NBCancelFinalAction[actionID]
queue item を Cancelled にする。

### NBFinalActionQueueSnapshot[] → Association
queue 全体の snapshot を返す(debug/Doctor 用)。

### NBFinalActionRunningQ[] → Boolean
Running 状態の final action があるか返す。

### $NBFinalActionAsyncActiveFunction
型: 関数|Automatic, 初期値: Automatic
AsyncActive 判定用コールバック。Automatic のとき ClaudeRuntime がロード済みなら ClaudeRuntimeAsyncActiveQ を使用、未ロードなら False。NBAccess 単体テストでは関数を差し替えて queue 基盤を独立検証できる。

## カテゴリ管理
### $NBAllowedHeadsByCategory
型: Association(`<|カテゴリ名 -> {head, ...}, ...|>`)
カテゴリ別の許可 head リスト。初期カテゴリ: "NBAccess_ReadOnly", "Control", "Arithmetic", "DataOps", "StringOps", "TypeChecks", "KernelRead", "Formatting", "NotebookData"。

### $NBDisabledCategories
型: Association, 初期値: `<||>`
無効化されたカテゴリの追跡テーブル。NBDisableCategory/NBEnableCategory が更新する。

### NBEnableCategory[cat]
カテゴリを有効化する。

### NBDisableCategory[cat]
カテゴリを無効化する。

### NBCategoryEnabled[cat] → Boolean
カテゴリが有効か返す。