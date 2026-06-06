# NBAccess API リファレンス

NBAccess は Wolfram Language ノートブックのセルレベル読み書き・プライバシーフィルタリング・LLM連携・履歴管理・アクセス制御を提供するパッケージ。全シンボルは `NBAccess`` コンテキスト。
GitHub: https://github.com/transreal/NBAccess

プライバシーモデル: 各セル/データは PrivacyLevel (0.0=非秘密 〜 1.0=秘密) を持つ。アクセスは PrivacySpec `<|"AccessLevel" -> n|>` で制御。`AccessLevel >= privacyLevel` のデータのみアクセス可。0.5=クラウドLLM安全、1.0=ローカルLLM/全データ。

## グローバル変数・オプション

### PrivacySpec
型: オプション名
NBAccess 関数のプライバシーフィルタリングオプション。例: `PrivacySpec -> <|"AccessLevel" -> 0.5|>`。AccessLevel <= セルのプライバシーレベルのセルのみアクセス可。

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
デフォルト PrivacySpec。ローカルLLM環境からは `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` に設定。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名→プライバシーレベルのテーブル `<|"変数名" -> level, ...|>`。ClaudeCode が自動更新。

### $NBSendDataSchema
型: Bool, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMへ送信するか。True=秘密依存Outputでも型・サイズ・キー等を送信。False=一切送信しない。非秘密Outputは常にスマート要約付きで送信。

### $NBVerbose
型: Bool, 初期値: False
詳細ログ出力フラグ。True=内部詳細ログをMessagesに出力。

### $NBAutoEvalProhibitedPatterns
型: List (RegularExpression/StringExpression), 初期値: `{}`
NBEvaluatePreviousCell で自動実行をブロックするパターンリスト。マッチ時は評価スキップ+警告。

### $NBLLMQueryFunc
型: Function|Symbol, 初期値: None
非同期 LLM 呼び出しコールバック。ClaudeCode が ClaudeQueryAsync を登録。シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool, Integrations -> {...}]`。callback は応答文字列を受け取る。カーネルをブロックしない。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査 (ClaudeCheckSeparation) で無視するファイル名/パッケージ名のリスト。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリストを返す。

### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリストを返す。`NBCellIndicesByStyle[nb, {style1, style2, ...}]` で複数スタイル指定可。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルを全て削除する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得。失敗時は NBCellExprToText にフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel (例: "In[3]:=") を返す。ラベルなしは ""。

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

### NBCellSetStyle[nb, cellIdx, style]
セルのスタイルを変更する。TaggingRules 等の属性は保持。例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code]
既存セルにコードを BoxData + Input スタイルで書き込む。FEParser で構文カラーリング付き BoxData に変換。例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBSelectCell[nb, cellIdx]
セルブラケットを選択状態にする。

### NBResolveCell[nb, cellIdx] → CellObject
CellObject を返す。無効インデックスは $Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
TaggingRules のネスト値を返す。例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value]
セルの TaggingRules にネスト値を設定する。例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`

### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → Bool
Cell 式が画像 (RasterBox/GraphicsBox) を含むか判定。cellExpr は NBCellRead の戻り値。

### NBCellWriteText[nb, cellIdx, newText]
セルのテキスト内容を newText に置換。スタイル・TaggingRules・オプションは保持。例: `NBCellWriteText[nb, 3, "新しいテキスト"]`

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可は ""。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBCellExprToText[cellExpr] → String
NotebookRead の結果 (Cell式) からテキストを抽出する。

### NBAccess`iCellToInputText[cell] → String
FrontEnd経由でセルの InputText形式を取得。失敗時は NBCellExprToText にフォールバック。

## LLM 連携 API

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換する。promptFn はセルテキストを受けプロンプト文字列を返す。completionFn は結果 Association を受け取る (エラー時は $Failed)。カーネルをブロックしない。セルのプライバシーレベルに応じて適切な LLM を自動選択。
→ Null (非同期)
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使う入力テキスト), Integrations -> Automatic (LM Studio MCP サーバーリスト, lmstudio モデル時のみ)
completionFn が受ける Association: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル (0.0〜1.0) を返す。0.0=非秘密, 1.0=秘密 (Confidentialマーク or 秘密変数参照)。

### NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] → Bool
セルが指定 PrivacySpec でアクセス可能か返す。

### NBFilterCellIndices[nb, indices, PrivacySpec -> ps] → List
セルインデックスリストを PrivacySpec でフィルタリングして返す。

### NBGetCells[nb, PrivacySpec -> ps] → List
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。

### NBGetContext[nb, afterIdx, PrivacySpec -> ps] → String
afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築。デフォルト AccessLevel 0.5。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

## 書き込み API

### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。style デフォルトは "Text"。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
カーソル位置の後ろに Input セルを挿入しカーソルをセル先頭に移動。autoEvaluate が True なら SelectionEvaluate も行う。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル (name) と Text セル (prompt) を挿入して保存・閉じる。

### NBWriteCell[nb, cellExpr] / NBWriteCell[nb, cellExpr, pos]
ノートブックに Cell 式を書き込む (デフォルト After)。pos は After/Before/All。遅延出力有効時 (After) はバッファに溜め NBFlushDeferredOutput で一括出力。

### NBWritePrintNotice[nb, text, color]
通知用 Print セルを書き込む。nb が None なら CellPrint を使用 (同期 In/Out 間出力)。

### NBCellPrint[cellExpr]
評価中セルの直後に出力セルを挿入する (CellPrint ラッパー)。常に EvaluationCell の直後に配置。

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
Dynamic セルを書き込む。tag が "" でなければ CellTags を設定。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。autoEvaluate が True なら直前セルを評価。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書き込む。取得不可なら末尾に書き込む。

### NBMoveToEnd[nb]
ノートブック末尾にカーソルを移動する。

### NBMoveToEnd / NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。

## 遅延出力 API

### NBBeginDeferredOutput[]
出力遅延 (集約) モードを有効にする。以降 NBWriteCell (After) は notebook に即書せずバッファに溜める。非同期並列処理・ブロック回避時に使用。NBEndDeferredOutput と対。

### NBEndDeferredOutput[]
出力遅延モードを無効に戻す (バッファは残るので NBFlushDeferredOutput で出力)。

### NBFlushDeferredOutput[nb] → Integer
溜めた Cell を notebook に一括書き込みバッファをクリア。出力した Cell 数を返す。メインカーネル評価で呼ぶこと。`NBFlushDeferredOutput[]` (nb省略) は CellPrint で出力。

### NBDeferredOutputActiveQ[] → Bool
出力遅延モードが有効か返す。

### NBDeferredOutputCount[] → Integer
バッファに溜まっている Cell 数を返す。

### NBDiscardDeferredOutput[]
バッファをフラッシュせず破棄する。

## ファイル型ノートブック操作 API

閉じた .nb ファイルへの読み書き。必ずこの API を経由する (直接 NotebookOpen/NotebookGet 禁止)。

### NBFileOpen[path] → NotebookObject
.nb ファイルを非表示 (Visible->False) で開く。失敗時 $Failed。必ず NBFileClose で閉じる。例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`

### NBFileClose[nb]
NBFileOpen で開いたノートブックを閉じる。

### NBFileSave[nb, path]
ノートブックを指定パスに保存。path が None なら上書き保存。

### NBFileReadCells[nb, PrivacySpec -> ps] → List
全セルを PrivacySpec でフィルタリングし `{<|cellIdx, style, text, privacyLevel|>, ...}` を返す。privacyLevel > PrivacySpec の秘匿セルは text を "[CONFIDENTIAL]" に置換。例: `cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]`

### NBFileReadAllCells[nb] → List
全セルをアクセスレベル別に分類して返す。秘匿セルも含み PrivacyLevel フィールドで識別可。ローカルモデル処理用。

### NBFileWriteCell[nb, cellIdx, newText]
指定セルのテキストを newText で置換。スタイル・TaggingRules・秘匿マーク等は保持。例: `NBFileWriteCell[nb2, 3, "This is a pen."]`

### NBFileWriteAllCells[nb, replacements]
`{cellIdx -> newText, ...}` の Association/List に従って複数セルを一括置換。例: `NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]`

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevel が lo〜hi のセルのみ返す。例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (公開セルのみ), `NBFileReadCellsInRange[nb2, 0.9, 1.0]` (秘匿セルのみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb ファイルのセルを PrivacyLevel <= threshold (public) と > threshold (private) に2分割。例: `{pub, priv} = NBSplitNotebookCells["file.nb", 0.5]`

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
2つの `<|cellIdx->newText|>` を元セル順にマージして outputPath に保存。例: `NBMergeNotebookCells[src, dst, pubResults, privResults]`

## ObjectSpec / パス正規化 API

### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を返す。PrivacyLevel: <0.5=クラウドLLM可, >=0.5=ローカルのみ, {0.5,1.0}=混在(.nb)。

### NBFileSpecCacheClear[]
NBFileSpec の base/projection キャッシュをクリアする。

### NBNormalizePath[path] → Association
絶対パスを複数PC間で安定なシンボリックパス情報の Association に正規化。
→ `<|"Kind", "RootId", "Parts", "SymbolicPath", "PhysicalPath", "ResolutionStatus", "MatchedBy"|>`
ResolutionStatus: "ResolvedOnThisPC" | "AliasOnly" | "Unrooted"。MatchedBy: "LocalRoot" | "Alias" | "None"。戻り値は同一性 (identity) 用でアクセス権を与えない。権限判定は PhysicalPath を現PCで解決・実在確認した上で行うこと。

### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。例: `NBValueSpec[dataset, 1.0]`

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5 -> {"cloud"}, 1.0 -> {"local"}, {0.5,1.0} -> {"cloud","local"}。例: `NBPrivacyLevelToRoutes[{0.5, 1.0}]`

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True|False|Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx, opts] / NBMarkCellConfidential[nb, cellIdx, level, opts]
セルを機密 (PrivacyLevel 1.0) に設定し赤背景マーク。level 指定で任意の数値 (0.0-1.0) に設定。level > 0.5 で赤背景マーク、level <= 0.5 でマーク解除。$NBApprovalHeads 登録済み (実行時に承認ゲート発火)。
Options: PrivacySpec -> Automatic

### NBSetSnapshotPrivacyLevel[snapshotId, level, opts]
SourceVault snapshot の PrivacyLevel を設定する。人間が明示的に上書きする場合に使う。SourceVault ロード必須。$NBApprovalHeads 登録済み。
Options: PrivacySpec -> Automatic

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク (橙背景 + LockIcon) を付ける。機密変数依存の計算結果等に使用。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク (視覚・タグ) を全て解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Bool
セルが機密変数を参照しているか返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容から Confidential[] 内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Bool
セルがプロンプトから除外すべきか返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Bool
セルが Claude 関数呼び出しセルか返す。

### NBExtractAssignments[text] → List
テキストから Set/SetDelayed の LHS 変数名を抽出する。

## 機密変数テーブル API

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する (level デフォルト 1.0)。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

## 依存グラフ API

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析し変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返す。文字列リテラル内識別子は除外。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査し統合された変数依存グラフを返す。LLM 呼び出し直前の精密チェック用。通常は軽量版 NBBuildVarDependencies[nb] を使う。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存依存グラフに CellLabel In[x] (x > afterLine) のセルのみ追加走査してマージ。インクリメンタル版。

### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] / NBScanDependentCells[nb, confVarNames, deps] → Integer
依存グラフを使い機密変数に依存するセルに NBMarkCellDependent を適用、新たにマークしたセル数を返す。deps 引数で事前計算済みグラフ使用 (二重計算回避)。Claude 関数呼び出しセルは除外。

### NBFilterHistoryEntry[entry, confVars]
履歴エントリ内の response/instruction に現時点の機密変数名/値が含まれる場合そのフィールドをブロックする。

### NBDependencyEdges[nb] → {DirectedEdge[...], ...}
変数依存関係をエッジリストで返す。"dep" → "var" は "var が dep に依存する" を意味。`NBDependencyEdges[nb, confVars]` は機密変数関連エッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。

### NBPlotDependencyGraph[opts] / NBPlotDependencyGraph[nb, opts]
依存グラフをプロット。引数なしは全ノートブック統合 (Global)。直接秘密=赤、依存秘密=橙。NB内エッジ=濃実線、クロスNB=薄破線。
→ Graph
Options: "Scope" -> "Global" (デフォルト) | "Local", PrivacySpec -> <|"AccessLevel" -> 1.0|>
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

### NBGetFunctionGlobalDeps[nb] → Association
全関数定義を解析し各関数が依存する大域変数のリストを返す。`<|"関数名" -> {"大域変数1", ...}, ...|>`。パラメータ変数とスコーピング局所変数 (Module/Block/With/Function) は除外。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → value
ノートブックの TaggingRules から key の値を返す。`NBGetTaggingRule[nb, {key1, key2, ...}]` でネストパス指定可。存在しない場合 Missing[]。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に key -> value を設定。`NBSetTaggingRule[nb, {key1, key2}, value]` でネストパス指定可。

### NBDeleteTaggingRule[nb, key]
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] / NBListTaggingRuleKeys[nb, prefix] → List
TaggingRules の全キーを返す。prefix 指定でそのプレフィックスで始まるキーのみ。

### NBSetNotebookDefaultModel[nb, provider, modelName]
ノートブックのデフォルトモデル (paletteProvider/paletteModelName) を書き換える。

### NBGetNotebookDefaultModel[nb] → {provider, modelName}
ノートブックのデフォルトモデルを返す。未設定なら Missing["NotDeclared"]。

## 履歴データベース API

履歴は TaggingRules に差分圧縮で格納。`Decompress -> True` (デフォルト) で差分復元、False で Diff オブジェクトのまま返す。

### NBHistoryData[nb, tag, opts] → Association
履歴データを読み取り差分復元して返す。
→ `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: Decompress -> True

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す (内部用)。

### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書き込む。data は `<|"header" -> ..., "entries" -> {...}|>`。entries は平文で渡すと自動圧縮される。

### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加。直前エントリの fullPrompt/response/code を Diff 圧縮。
Options: PrivacySpec -> ps (privacylevel をエントリに記録)

### NBHistoryEntries[nb, tag, opts] → List
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updates は `<|"response" -> ..., "code" -> ...|>`。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリを返す。header の parent/inherit/created に従って親チェーンを辿る。
Options: Decompress -> True

### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクションやバッチ更新用。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規は追加。

### NBHistoryCreate[nb, tag, diffFields] / NBHistoryCreate[nb, tag, diffFields, headerOverrides] → Association
新しい履歴データベースを作成。diffFields は差分圧縮対象フィールド名リスト (例: `{"fullPrompt", "response", "code"}`)。既存DBに diffFields がある場合は既存ヘッダーを返す (冪等)。

### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチ (重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, PrivacySpec -> ps]
prefix で始まる全履歴を削除。`PrivacySpec -> <|"AccessLevel" -> 1.0|>` 必須。セルレベルの機密タグは削除しない。ノートブックを他者に渡す際の履歴除去用。

## API キーアクセサ

### NBGetAPIKey[provider] → String
AI プロバイダの API キーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0 必須。呼び出し側で `PrivacySpec -> <|"AccessLevel" -> 1.0|>` を明示指定。

### NBListProviderModels[provider] → Association
クラウドプロバイダ (anthropic / openai) の利用可能モデル ID リストを返す。API キーは内部で読み外部に出さない。PrivacySpec 指定不要。
→ `<|"Status" -> _, "Provider" -> _, "Models" -> {_String..}|>`

### NBResolveCredentialRef[ref, accessSpec] → Association
credential-ref を解決し secret 本体ではなく取得用 descriptor `<|"Provider" -> _, ...|>` を返す。handler はこの descriptor で NBGetAPIKey を呼ぶ。

## ローカル LLM サーバー API

### NBGetLocalLLMAPIKey[provider, url] → String
ローカル LLM サーバー (LM Studio 等) の API キーを SystemCredential から返す。照合は {provider, url} ペア。AccessLevel >= 1.0 必須。解決優先度: (1) 完全一致 (2) localhost↔127.0.0.1 置換版 (3) {provider, "*"} ワイルドカード (4) フォールバック名 `ToUpperCase[provider]<>"_API_KEY"`。例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録。SystemCredential の実値は書き込まない。→ `{provider, normalizedUrl} -> credentialName`

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key]
上記マッピング登録に加えて `SystemCredential[credentialName] = key` も同時設定。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url]
{provider, url} のエントリを削除。SystemCredential 本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
登録済みローカル LLM サーバー→API キー名マッピングを Dataset で返す。Configured 列は SystemCredential 設定済みか示す。

### NBLocalLLMCredentialName[provider, url] → String
SystemCredential 名のみを返す (値は取得しない)。AccessLevel チェックなし。

## フォールバックモデル / プロバイダアクセスレベル API

### NBSetFallbackModels[models]
フォールバックモデルリストを設定。models: `{{"provider","model"}, {"provider","model","url"}, ...}`。例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルリストを返す。MaxAccessLevel >= accessLevel のモデルのみ。例: `NBGetAvailableFallbackModels[0.8]` → lmstudio のみ。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベル (0.0〜1.0) を設定。このレベルを超えるリクエストにはフォールバックしない。例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録は 0.5。

### NBProviderCanAccess[provider, accessLevel] → Bool
プロバイダーが指定アクセスレベルのデータにアクセス可能か返す (MaxAccessLevel >= accessLevel)。

### NBModelCanHandleAccessLevel[modelSpec, accessLevel] → Bool
モデル指定がそのアクセスレベルのデータを扱えるか返す。Private ノート (1.0) でクラウドモデル (0.5) を拒否しローカル LLM (1.0) のみ通す。modelSpec: {provider, model} | {provider, model, url} | "model" | Automatic (未指定は True)。

### NBModelProviderName[modelSpec] → String
modelSpec から provider 文字列を取り出す。

### NBNotebookRequiredAccessLevel[nb] → Real
ノートブックが要求するアクセスレベルを返す。Private 宣言 (CloudPublishable -> False) なら 1.0、それ以外は 0.0。

## 信頼ローカルサーバー / モデル同期 API

### NBRegisterTrustedLocalServer[assoc]
信頼できるローカル LLM サーバを登録。assoc: `<|"MachineName" -> _, "Subnet" -> _, "Provider" -> _, "URL" -> _|>`。モデル名は含めない。例: `NBRegisterTrustedLocalServer[<|"MachineName"->"phoenix", "Subnet"->"192.168.2", "Provider"->"lmstudio", "URL"->"http://192.168.2.110:1234"|>]`

### NBResolveLocalServer[] → Association
現在のマシン環境 ($MachineName と自IPのサブネット) を信頼リストと照合し信頼ローカル LLM サーバ `<|"Provider" -> _, "URL" -> _, "Trusted" -> _, ...|>` を返す。未知のサブネットでは安全側に倒し localhost のみ返す。

### NBTrustedLocalServers[] → Dataset
登録済み信頼ローカルサーバのリスト (Dataset) を返す。

### NBSyncClaudeModelVars[opts]
SourceVault のモデルで ClaudeCode の $ClaudeModel / $ClaudeDocModel / $ClaudePrivateModel / $ClaudeFallbackModels を更新。ローカルサーバ URL は NBResolveLocalServer で安全解決。SourceVault 未ロードなら何もしない。SourceVault ロード時に自動実行。
Options: Verbose -> False

## アクセス可能ディレクトリ / PathRef API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}] / NBSetAccessibleDirs[{dirs}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存。nb 省略時は EvaluationNotebook[]。

### NBGetAccessibleDirs[nb] / NBGetAccessibleDirs[] → List
保存されたアクセス可能ディレクトリリストを返す。nb 省略時は EvaluationNotebook[]。

### NBResolvePathRef[pathRef] → String | Missing
PathRef (NBNormalizePath の Association、または `{"$onWork", ...}` 形式のシンボリックパスリスト) を現PCの実パスへ解決。解決でき実在すれば絶対パス文字列、解決不可なら Missing[...]。alias-only / root-missing は解決されない。

### NBSetAccessiblePathRefs[nb, refs] / NBSetAccessiblePathRefs[refs]
AccessPathRef のリストを notebook の TaggingRules (claudeAccessiblePathRefs) に保存。nb 省略時は EvaluationNotebook[]。各 AccessPathRef: `<|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|>`。

### NBGetAccessiblePathRefs[nb] / NBGetAccessiblePathRefs[] → List
notebook に保存された AccessPathRef のリストを返す。旧 notebook では claudeAccessibleDirs を変換して返す (read fallback)。

### NBNormalizeAccessPathRef[dirOrRef] → Association
旧形式の絶対パス文字列または部分的指定を完全な AccessPathRef Association に正規化。文字列なら NBNormalizePath で PathRef 化し Mode -> "Read"、CloudSend -> "Ask" を既定とする。

## Job 管理 API (非同期出力位置管理)

### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブID を返す。evalCell が CellObject でない場合は末尾に挿入。スロット1: システムメッセージ、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[] を内部取得してその直後に Job スロットを挿入する。CellObject 保持不要。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットへの再書き込みは上書き。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除する。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

## CellEpilog API

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定。key は識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Bool
CellEpilog が key でインストール済みか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストール。checkSymbol は FreeQ チェック用マーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Bool
機密追跡 CellEpilog がインストール済みか返す。

## Allowed Expression Surface / 実行 API

### $NBAllowedHeads
型: List
LLM が自由に実行可能な head のリスト。

### $NBApprovalHeads
型: List
人間承認を要する head のリスト。

### $NBDenyHeads
型: List
常に拒否する head のリスト。

### $NBAllowedHeadsByCategory
型: Association
カテゴリ別の許可 head リスト。

### $NBDisabledCategories
型: Association
無効化されたカテゴリの追跡。

### NBValidateHeldExpr[heldExpr, accessSpec, opts] → Association
HoldComplete[...] 式を Allowed Expression Surface に照合し AccessDecision を返す。
→ `<|"Decision" -> "Permit"|"Deny"|"NeedsApproval"|"RepairNeeded", ...|>`

### NBExecuteHeldExpr[heldExpr, accessSpec, opts] → Association
検証済み式を安全に実行し結果を返す。→ `<|"Success" -> True/False, "RawResult" -> ..., "Error" -> ...|>`

### NBTryExecuteFinalActionHeld[held, accessSpec, opts] → Association
承認 wrapper (NBOpenFolderWithApproval 等) を head の context に依存せず安全評価し OpenDesktopItem action に正規化、NBExecuteApprovedAction 経由で実行。対象外なら `<|"Handled" -> False|>`。

### NBResolveDesktopActionPath[held, accessSpec] → Association
desktop action wrapper からパスを安全解決・検証だけ行う (SystemOpen は呼ばない)。→ `<|"IsDesktopAction" -> .., "Validated" -> .., "Path" -> ..|>`

### NBRedactExecutionResult[result, accessSpec, opts] → Association
実行結果を redact し安全な形で返す。accessSpec に "ConfidentialLineNumbers" -> {n, ...} があれば Out[n]/In[n]/% 等で機密セル参照時も機密依存としてスキマ化。→ `<|"RedactedResult" -> ..., "Summary" -> String|>`

### NBConfidentialLineNumbers[nb, accessSpec] → List
ノートブック内の機密・機密依存 Input/Code/Output セルの評価行番号リストを返す。漏洩検出 (NBRedactExecutionResult) 用。

### NBMakeContextPacket[nb, accessSpec, opts] → Association
notebook から安全な context packet を構築。→ `<|"Input" -> ..., "Cells" -> ..., "AccessSpec" -> ..., ...|>`

### NBInferExprRequirements[heldExpr, accessSpec] → Association
式が必要とするアクセスレベル・書き込みターゲット・参照セル等を静的推定。→ `<|"ReadCells" -> {...}, "WriteCells" -> {...}, "RequiredAccessLevel" -> n, "HasSideEffects" -> True/False, ...|>`

### NBReleaseResult[result, accessSpec, opts]
実行結果を指定 sink に安全に release する。redaction + routing check を行う。

### NBMakeRetryPacket[failureAssoc, accessSpec] → Association
失敗情報から秘密を含まない安全な retry packet を構築する。

### NBExecuteHeldExprSubkernelRaw[held, accessSpec, opts]
subkernel 専用の実行 wrapper。戻り値は生の評価結果 / $TimedOut / $Failed。snapshot 検証・NBSubkernelExecutableQ・再検証を通過し Decision が Permit のときのみ ReleaseHold。Screen/NeedsApproval/Deny/RepairNeeded はすべて $Failed。

### NBSubkernelExecutableQ[held, accessSpec] → Bool
held が subkernel で安全に実行できるか返す。False条件: ExecutionRole≠"ProposalEval" / ExecutionKernel≠"SubkernelAllowed" / MayUseFrontEnd・MayWriteNotebook・MayUseExternalProcess・MayUseNetwork のいずれか True / ResultMayCrossKernel≠True / PolicySnapshot 無効 / confidential 参照 / DenyHeads・ApprovalHeads 該当 / 副作用 head 含む。

## Routing API

### $NBRoutingThresholds
型: Association, 初期値: `<|"Cloud" -> 0.5, "Private" -> 0.8|>`
routing 閾値。score < Cloud → CloudLLM、Cloud <= score < Private → PrivateLLM、Private <= score → LocalOnly。

### NBRouteDecision[scoreOrAccessSpec] → Association
数値スコアまたは accessSpec から routing 推奨を返す (advisory)。→ `<|"Route" -> "CloudLLM"|"PrivateLLM"|"LocalOnly", "EffectiveRiskScore" -> n, "Thresholds" -> ..., "Reason" -> String|>`

## ファイルアクセス認可 API

### NBMakeFileAccessRequest[pathOrSpec, operation, opts] → Association
file 用 AccessRequest Association を組み立てる helper。operation: "ReadValue" | "WriteCell" | "WriteLog" | "SendExternal" 等。cloud send は Sink -> "CloudLLM"、local read/write は Sink -> "LocalOnly" / "Notebook"。

### NBAuthorizeFile[pathOrSpec, req] → Association
NBFileSpec / file spec を NBAuthorize に渡す adapter。pathOrSpec が文字列なら NBFileSpec で base spec 取得、Association ならそのまま。

### NBAuthorize[obj, req] → Association
PolicyGate + ScoreGate + EnvironmentGate を統合した AccessDecision を返す。→ `<|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval", "ReasonClass" -> ..., "RequiredAction" -> ..., "VisibleExplanation" -> ..., "RouteAdvice" -> ...|>`

### NBPermitQ[decision] → Bool
NBAuthorize の AccessDecision を Boolean projection に落とす fail-closed helper。Decision="Permit" のときだけ True。それ以外・$Failed・Missing・例外はすべて False。

### NBPolicyGate[obj, req] → Association
半順序ラベルに基づく flow 判定を返す。PolicyLabel / ContainerLabel / SinkLabel を考慮。

### NBScoreGate[obj, req] → Association
数値スコアに基づく routing/screening 判定を返す (advisory)。

### NBEnvironmentGate[obj, req] → Association
実行環境に基づく制約チェックを返す。Sink / Environment / Principal を考慮。

### NBDefaultFilePolicyLabel[spec] → label
placeholder file policy label を返す。

### NBNoExtraContainerLabel[] → label
placeholder container label を返す。

## Function Security API

### NBRegisterFunctionSecurity[sym, spec]
関数 sym にセキュリティメタデータを登録。spec: `<|"DefinitionLabel" -> label, "ExecPolicy" -> "Open"|"Guarded"|"Denied", "ReleasePolicy" -> <|...|>|>`

### NBFunctionDefinitionLabel[f] → label
関数 f の定義ラベルを返す。

### NBFunctionExecPolicy[f] → String
関数 f の実行ポリシー "Open"|"Guarded"|"Denied" を返す。

### NBFunctionReleasePolicy[f] → spec
関数 f の結果リリースポリシーを返す。

### GuardedApply[req, f, args]
f[args] をセキュリティポリシーに従って実行。ExecPolicy が "Guarded" の場合 flow チェック後に実行し結果に適切なラベルを付与。

### Declassify[obj, req, releaseSpec]
obj のラベルを releaseSpec に従って引き下げる。req の Principal が acts-for 権限を持つ場合のみ許可。

## Label Algebra API

### NBLabelQ[label] → Bool
label が有効な NBAccess ラベルか判定する。

### NBLabelBottom[] → label
最小制約ラベル (public) を返す。

### NBLabelTop[] → label
最大制約ラベル (全拒否) を返す。

### NBLabelJoin[l1, l2] → label
ラベルの join (より制約的) を返す。両方の制約を満たす方向。

### NBLabelMeet[l1, l2] → label
ラベルの meet (より緩い) を返す。

### NBLabelLEQ[l1, l2] → Bool
l1 ⪯ l2 (l1 の情報が l2 へ flow 可能) を判定する。

### NBRegisterPrincipal[name, opts]
アクセス主体を登録する。

### NBGrantActsFor[p, q]
principal p が q として行動できる委任を登録する。

### NBActsForQ[p, q] → Bool
p が q として行動可能か判定する。

### NBCanFlowToQ[srcLabel, dstLabel] → Bool
src から dst への flow が許可されるか判定する。

### NBCanDeclassifyQ[srcLabel, dstLabel, req] → Bool
declassify が正当か判定する。

### NBEffectiveLabel[obj, req] → label
オブジェクトと要求から実効ラベルを計算する。

## カテゴリ管理 API

### NBEnableCategory[cat]
カテゴリを有効化する。

### NBDisableCategory[cat]
カテゴリを無効化する。

### NBCategoryEnabled[cat] → Bool
カテゴリが有効か返す。

## Notebook semantic access API (closed notebook 直接操作)

ファイル直接経路 (Import["Notebook"] / Export["NB"]) で closed notebook を FrontEnd 不要で操作。AccessSpec Association で RBAC 制御。読み取り系デフォルト AccessLevel=0.5、書き込み系 >=0.7。

### NBReadHeader[path, opts] → Association
notebook の SourceVault ヘッダーを抽出。対象: TaggingRules="SourceVault" または Header style cell、Input cell 内 BoxData も MakeExpression 経由で取得可。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.5, ...|>
→ `<|"Status" -> "OK"|"Failed", "Keywords" -> {...}, "Status" -> _, "Deadline" -> _, "NextReview" -> _, "Owner" -> _, "PathHint" -> _, "RawHeader" -> <|...|>, "Source" -> "TaggingRules"|"HeaderCell"|"BoxData"|"None"|>`

### NBReadTodos[path, opts] → Association
notebook の Todo cell を全抽出。対象: Item style cell、または TaggingRules="SourceVault" で TodoStatus 設定済。CellGroupData ネストも再帰展開。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.5, ...|>
→ `<|"Status" -> _, "Todos" -> {<|"Index" -> n, "Text" -> ..., "Status" -> "Open"|"Done"|"Pass", "CellPath" -> {...}, "StatusSource" -> ..., "ExpressionUUID" -> _|>...}|>`

### NBFindCellByPredicate[path, predicate, opts] → Association
predicate が True を返す cell を返す。predicate は Cell expr を受け True/False を返す Function。CellGroupData ネストも再帰展開。
Options: "AccessSpec" -> <|...|>, "MaxResults" -> All|_Integer
→ `<|"Status" -> _, "Matches" -> {<|"CellIndex" -> n, "CellPath" -> {...}, "Cell" -> HoldComplete[Cell[...]], "Style" -> _, "ExpressionUUID" -> _|>...}|>`

### NBSetCellOptionsByPredicate[path, predicate, optionRules, opts] → Association
predicate が True を返す cell の options を optionRules で上書き。optionRules 例: `{FontVariations -> {"StrikeThrough" -> True}, FontColor -> RGBColor[0,0.5,0]}`。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.7, ...|> (書き込みには >= 0.7), "DryRun" -> True (default True, プレビューのみ), "MaxResults" -> All
→ `<|"Status" -> "OK"|"Failed"|"DryRunOK", "Modified" -> {<|"CellPath", "Before", "After"|>...}, "DryRun" -> _, "AccessLevel" -> _|>`

### NBSetCellTaggingRuleByPredicate[path, predicate, taggingKeyPath, value, opts] → Association
predicate が True の cell の TaggingRules 内 key パスを value で設定。例: taggingKeyPath = {"SourceVault", "TodoStatus"}, value = "Done"。Options/戻り値は NBSetCellOptionsByPredicate と同形。

### NBWriteHeader[path, key, value, opts] → Association
notebook の SourceVault ヘッダー1フィールドを更新。key: "Status"/"Keywords"/"Deadline"/"NextReview"/"Owner"/"PathHint" 等。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.7|> (default 0.7), "DryRun" -> True (default True)
→ `<|"Status" -> _, "Before" -> _, "After" -> _, "DryRun" -> _, "Path" -> _|>`

### NBWriteTodoStatus[path, todoKey, newStatus, opts] → Association
todoKey で特定される Todo cell の Status を変更。todoKey: `<|"Index" -> n, "Text" -> "..."|>` (両方一致する cell のみ)。newStatus: "Open"/"Done"/"Pass"。変更: StrikeThrough + FontColor + TaggingRules TodoStatus。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.7|> (default 0.7), "DryRun" -> True (default True)
→ `<|"Status" -> _, "MatchedTodo" -> <|...|>, "OldStatus" -> _, "NewStatus" -> _, "CellPath" -> {...}|>`

## クラウド公開宣言 API

### NBGetCloudPublishable[path] → True|False|Missing
ノートブック自身のクラウド公開宣言を読み取る (TaggingRules > SourceVault > "CloudPublishable")。True=クラウドLLM可、False=明示禁止、Missing["NotDeclared"]=宣言なし (パスベース判定にフォールバック)。

### NBSetCloudPublishable[path, True|False, opts] → Association
ノートブック自身のクラウド公開宣言を設定。設定後 PrivacyLevel が 0.4/0.5/1.0/{0.5,1.0} に自動決定。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.7|> (default 0.7), "DryRun" -> False
→ NBWriteHeader と同形

### NBClearCloudPublishable[path, opts] → Association
クラウド公開宣言を「未指定」状態に戻す (CloudPublishable キー削除、空なら親キーもクリーンアップ)。
Options: "AccessSpec" -> <|"AccessLevel" -> 0.7|> (default 0.7), "DryRun" -> False
→ `<|"Status" -> _, "Before" -> _, "After" -> _, "NoOp" -> True, "Path" -> _|>`

### NBSetNotebookPrivate[nb] / NBSetNotebookPrivate[nb, False] / NBSetNotebookPrivate[]
ノートブック全体を Private (CloudPublishable -> False) 宣言し、全セルの PrivacyLevel を 1.0 にしてクラウド LLM 投入禁止。ライブ NotebookObject に即時反映、保存済みなら NBSetCloudPublishable でファイルにも永続化。第2引数 False で解除。nb 省略時は EvaluationNotebook[]。

## .nb キャッシュ修復 / クリーンアップ API

### NBRepairNotebookCache[path] → Association
.nb ファイルの outline cache を正規化 (「Wolfram システム外で編集された」ダイアログ抑制)。frontend 経由で NotebookSave しヘッダのバイト位置キャッシュを再生成。内容は変わらない。→ `<|"Status" -> _, "Path" -> _, "WasAlreadyOpen" -> _|>`

### NBRepairNotebookCacheFolder[dir, opts] → Association
dir 配下の .nb を全部修復。
Options: "Recursive" -> True
→ `<|"Status", "Directory", "TotalFiles", "Succeeded", "Failed", "Details"|>`

### NBCleanupTmpFiles[dir, opts] → Association
dir 配下の .nb.tmp-* 残骸を削除。
Options: "Recursive" -> True
→ `<|"Status", "Directory", "Deleted", "Files"|>`

### NBRepairNotebookCacheStrict[path] → Association
NBRepairNotebookCache が効果ない場合の強力版 fallback。NotebookImport で読み CreateDocument で再作成し元パスに上書き保存。→ `<|"Status" -> _, "Path", "Method" -> "RecreateAndSave"|>`

### NBAuditCodexAccessibleDirs[dirs, opts] → Association|Failure
ChatGPT Codex に露出するディレクトリを危険ファイル (.env, *secret*, *credential*, *token*, 秘密鍵, APIキー様内容) について監査。Codex 権限プロファイル生成前の必須ゲート。デフォルト fail-stop。
Options: "MaxDepth" -> Infinity, "OnDanger" -> "Fail" | "DenyAndContinue", "ScanContents" -> True, "MaxFileScanBytes"
→ `<|"Status", "Gate", "Findings", "AuditedDirs", "FileCount", "Truncated", "SuggestedDenyRules"|>`

## Policy Snapshot API

### NBPolicySnapshot[] → Association
現在の NBAccess 動的 policy (導出済み AllowedHeads, ApprovalHeads, DenyHeads, ConfidentialSymbols) を凍結した Association を返す。キー: "SnapshotID", "CreatedAt", "NBAccessPolicyVersion", "AllowedHeads", "ApprovalHeads", "DenyHeads", "ConfidentialSymbols", "Digest", "Source"。

### NBAcceptPolicySnapshot[snapshot] → Association
snapshot の必須キーと Digest を検証。→ `<|"Valid" -> True|False, "Digest" -> _, "Reason" -> _|>`

### $NBActivePolicySnapshot
型: Association
NBAcceptPolicySnapshot が Valid と判定した最新 snapshot を保持 (主に subkernel 側)。参考情報であり実行判定の正本ではない。

### NBApplyPolicySnapshot[snapshot] → Association
snapshot の digest を検証し正規化した snapshot を返す。→ `<|"Valid" -> _, "Snapshot" -> _, "Reason" -> _|>`

### NBValidateNotebookPreActions[actions, accessSpec] → List
PreExecutionNotebookActions のリストを検証し許可された action だけ返す。P0 必須 action は "MoveSelectionAfterNotebook"。許可条件: action 名が accessSpec["AllowedNotebookActions"] に含まれ、MayUseFrontEnd/MayWriteNotebook が True、ExecutionKernel="MainOnly"、Notebook が target と一致。

### NBMakeRuntimeAccessSpec[contextPacket, role] → Association
Runtime/Orchestrator から NBAccess へ渡す accessSpec を作る。role: "ProposalEval" (既定, SubkernelAllowed) / "Committer" (MainOnly, FE/書込可) / "VisionFallback" / "ManualDispatch"。PolicySnapshot は生成時点の policy を凍結して埋める。

## Permission / Output モード

### $ClaudePermissionMode
型: String, 初期値: "InteractiveSafe"
権限モード。値: "ReviewOnly"(提案のみ) / "StrictSafe"(AutoPermit のみ) / "InteractiveSafe"(標準、承認 UI) / "WorkflowSafe"(Orchestrator) / "LegacyInteractive" / "DangerFullAccess"。実行中は accessSpec/snapshot 焼き込み値を正とする。

### $ClaudeAllowHardDenyOverride
型: Bool, 初期値: False
DangerFullAccess モードでのみ意味を持つ。True で HardDeny 相当 (Run/ExternalEvaluate/破壊的 IO) を NeedsApproval へ昇格。

### $ClaudeOutputMode
型: String, 初期値: "Streaming"
出力モード。"Streaming"(逐次、結果が出るたびに出力) / "Batch"(集約、バッファに溜め最後に出力)。BlockingRisk が MayBlockFrontEnd の出力は Streaming でも自動集約。

### NBResolveOutputMode[mode, blockingRisk] → String
即出力 ("Immediate") か集約 ("Deferred") かを返す。blockingRisk="MayBlockFrontEnd" なら "Deferred"、mode="Batch" なら "Deferred"、それ以外 "Immediate"。

### $NBEffectClassOverrides
型: Association
head 名 -> `<|EffectClass, BlockingRisk, ExecutionPlacement, RequiresFinalNode|>` の任意上書きテーブル。分類精度向上用 (allowlist ではない)。

## Action Registry API

### NBRegisterAction[name, spec]
承認対象操作 (desktop/notebook/filesystem) を action registry に登録。spec キー: EffectClass, DefaultApprovalEligibility, AllowedTargetTypes, RequiresFinalNode, Validator, Executor。

### NBValidateAction[action, accessSpec] → Association
action association を registry の Validator + PermissionMode 変換で検証し Decision を返す。NBValidateHeldExpr と同形 (Decision/ApprovalEligibility/EffectClass/AllowApprovalUI/MayExecute 等)。

### NBExecuteApprovedAction[action, accessSpec, opts]
承認済み action を実行。実行直前に再 validate (TOCTOU 対策)、承認後に path/target 変化なら PostApprovalValidationFailed で拒否。

### NBOpenFolderWithApproval[path]
OpenDesktopItem action (TargetType Folder) の薄い互換 wrapper。

## Final Action Queue API

### NBEnqueueFinalAction[action, accessSpec, opts] → ActionID
承認済み final action (FrontEnd ブロックリスクのある desktop/notebook 操作) を PendingFinalActionQueue に積む。直接同期実行せず共有 polling tick が安全条件を満たしたとき1件ずつ実行。

### NBFinalActionTick[]
共有 polling tick から呼ばれ PendingFinalActionQueue の安全条件を確認し最大1件実行。安全条件: AsyncActive でない / final action 実行中でない / 承認済み / 再 validate 成功 / 期限内。

### NBFinalActionStatus[actionID] / NBFinalActionStatus[] → 状態
queue item の状態を返す。省略時は全 item。状態: Pending/Running/Completed/Failed/Expired/Cancelled/NeedsRetryAfterAsync。

### NBCancelFinalAction[actionID]
queue item を Cancelled にする。

### NBFinalActionQueueSnapshot[] → Association
queue 全体の snapshot を返す (debug/Doctor 用)。

### NBFinalActionRunningQ[] → Bool
Running 状態の final action があるか返す。

### $NBFinalActionAsyncActiveFunction
型: Function|Automatic, 初期値: Automatic
AsyncActive 判定の callback。Automatic のとき ClaudeRuntime ロード済みなら ClaudeRuntimeAsyncActiveQ、未ロードなら False。

## External I/O Guards

### NBCheckFileRead[path, accessSpec] → Association
path の読み取りが accessSpec の MayAccessFileSystem / AllowedDirectories scope 内か検査。→ `<|"Allowed" -> _, "Reason" -> _|>`

### NBCheckFileWrite[path, accessSpec] → Association
path への書き込みが scope 内か検査する。

### NBCheckNetworkAccess[target, accessSpec] → Association
target (URL 文字列または `<|Scheme,Host,Port|>`) が AllowedNetworkTargets scope 内か検査する。

### NBCheckExternalProcess[cmd, accessSpec] → Association
外部コマンドが AllowedExternalCommands 内か検査する。

### NBCheckedImport[path, fmt, accessSpec]
NBCheckFileRead 通過後に Import する。違反時は AccessSpecViolation を返す。

### NBCheckedExport[path, expr, fmt, accessSpec]
NBCheckFileWrite 通過後に Export する。

### NBCheckedURLRead[url, accessSpec]
NBCheckNetworkAccess 通過後に URLRead する。

### NBCheckedFileWrite[path, content, accessSpec]
NBCheckFileWrite 通過後に書き込む。

### NBCheckedFileRead[path, accessSpec]
NBCheckFileRead 通過後に読み取る。

### NBConfidentialHandlingAllowedQ[mode, permissionMode] → Bool
ConfidentialHandling mode (EncryptedBundle/ReferenceOnly/Redacted/PlaintextDebug) が当該 permissionMode で許容されるか (PlaintextDebug gate) を返す。