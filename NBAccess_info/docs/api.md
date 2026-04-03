# NBAccess API リファレンス

NBAccess パッケージはセルインデックスベースでノートブックの読み書きとプライバシーフィルタリングを提供する。

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。ローカル LLM 環境では `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` に変更する。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名とプライバシーレベルのテーブル `<|"変数名" -> level, ...|>`。ClaudeCode パッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: True
True: 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報をクラウド LLM に送信する。False: 一切送信しない。

### $NBVerbose
型: Boolean, 初期値: False
True: NBAccess 内部の詳細ログを Messages に出力する。

### $NBAutoEvalProhibitedPatterns
型: List, 初期値: `{}`
NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト (RegularExpression または StringExpression)。ClaudeCode がロード時に登録する。

### $NBLLMQueryFunc
型: Function|Symbol|None, 初期値: None
非同期 LLM 呼び出し用コールバック関数。ClaudeCode パッケージが自動的に ClaudeQueryAsync を登録する。シグネチャ: `f[prompt, callback, nb, Model -> spec, Fallback -> bool]`。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
ClaudeCheckSeparation で無視するファイル名またはパッケージ名のリスト。追加: `AppendTo[$NBSeparationIgnoreList, "MyPackage"]`。

## オプション

### PrivacySpec
NBAccess 履歴・セル取得関数のプライバシーフィルタリングオプション。
値: `<|"AccessLevel" -> level|>` (level: 0.0〜1.0)。
0.5 = クラウド LLM 安全なデータのみ (デフォルト)、1.0 = ローカル LLM 環境などすべてのデータ。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → {Integer, ...}
選択中セルのインデックスリストを返す。セルブラケット選択またはカーソル位置のセルを返す。

### NBCellIndicesByTag[nb, tag] → {Integer, ...}
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → {Integer, ...}
指定 CellStyle のセルのインデックスリストを返す。`style` は文字列またはリスト `{style1, style2, ...}`。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルをすべて削除する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel (例: "In[3]:=") を返す。ラベルなしの場合は ""。

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

### NBCellSetStyle[nb, cellIdx, style]
セルのスタイルを変更する。TaggingRules 等の属性は保持される。
例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code]
既存セルにコードを BoxData + Input スタイルで書き込む。FEParser で構文カラーリング付き BoxData に変換する。
例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBCellWriteText[nb, cellIdx, newText]
セルのテキスト内容を newText に置き換える。セルスタイル・TaggingRules・オプション等の属性は保持される。
例: `NBCellWriteText[nb, 3, "新しいテキスト"]`

### NBSelectCell[nb, cellIdx]
セルブラケットを選択状態にする。パレット操作後のセル選択復元に使用する。

### NBResolveCell[nb, cellIdx] → CellObject | $Failed
CellObject を返す。指定インデックスが無効な場合は $Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → value | Missing[]
TaggingRules のネスト値を返す。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value]
セルの TaggingRules にネスト値を設定する。NBCellGetTaggingRule の対となるセッター。
例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`

### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → True | False
Cell 式が画像 (RasterBox/GraphicsBox) を含むか判定する。cellExpr は NBCellRead の戻り値を想定。

## LLM 連携 API

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得する。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可の場合は ""。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換する。カーネルをブロックしない。セルのプライバシーレベルに応じて適切な LLM を自動選択する。
→ Null (非同期)
Options: Fallback -> False (フォールバックモデル使用), InputText -> Automatic (セルテキストの代わりに使用する入力テキスト)
completionFn が受け取る Association: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`
エラー時は completionFn に $Failed を渡す。
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル (0.0〜1.0) を返す。0.0: 非秘密、1.0: 秘密 (Confidential マークまたは秘密変数参照)。

### NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] → True | False
セルが指定の PrivacySpec でアクセス可能かどうかを返す。

### NBFilterCellIndices[nb, indices, PrivacySpec -> ps] → {Integer, ...}
セルインデックスリストを PrivacySpec でフィルタリングして返す。

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookRead の結果 (Cell 式) からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, PrivacySpec -> ps] → {Integer, ...}
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。

### NBGetContext[nb, afterIdx, PrivacySpec -> ps] → String
ノートブック内の afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築する。PrivacySpec でフィルタリングされる。デフォルト: AccessLevel 0.5。

## 書き込み API

### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。style のデフォルトは "Text"。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動する。autoEvaluate が True の場合はさらに SelectionEvaluate を行う。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル (name) と Text セル (prompt) を挿入して保存・閉じる。

### NBWriteCell[nb, cellExpr]
ノートブックに Cell 式を書き込む (After)。
### NBWriteCell[nb, cellExpr, pos]
pos (After/Before/All) を指定可能。

### NBWritePrintNotice[nb, text, color]
ノートブックに通知用 Print セルを書き込む。nb が None の場合は CellPrint を使用 (同期 In/Out 間出力)。

### NBCellPrint[cellExpr]
評価中のセルの直後に出力セルを挿入する (CellPrint ラッパー)。カーソル位置に依存せず、常に EvaluationCell の直後に配置される。

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
ノートブックに Dynamic セルを書き込む。tag が "" でない場合は CellTags を設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。autoEvaluate が True なら直前セルを評価する。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書き込む。EvaluationCell が取得できない場合はノートブック末尾に書き込む。

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## ファイル型ノートブック操作 API

閉じた .nb ファイルを対象とした読み書き操作。必ず NBFileOpen/NBFileClose を経由すること。上位層から .nb ファイルを直接 NotebookOpen/NotebookGet で開いてはならない。

### NBFileOpen[path] → NotebookObject | $Failed
.nb ファイルを非表示 (Visible->False) で開き NotebookObject を返す。失敗時は $Failed。必ず NBFileClose で閉じること。
例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`

### NBFileClose[nb]
NBFileOpen で開いたノートブックを閉じる。
例: `NBFileClose[nb2]`

### NBFileSave[nb, path]
開いているノートブックを指定パスに保存する。path が None の場合は上書き保存。
例: `NBFileSave[nb2, "C:\\path\\to\\translated.nb"]`

### NBFileReadCells[nb, PrivacySpec -> ps] → {{cellIdx, style, text, privacyLevel}, ...}
開いているノートブックの全セルを PrivacySpec に従ってフィルタリングし Association のリストで返す。privacyLevel > PrivacySpec の秘匿セルはテキストを "[CONFIDENTIAL]" に置換する。
例: `cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]`

### NBFileReadAllCells[nb] → {{cellIdx, style, text, privacyLevel}, ...}
開いているノートブックの全セルをアクセスレベル別に分類して返す。秘匿セルも含む全セルを返すが PrivacyLevel フィールドで識別できる。ローカルモデルで処理する際に使用する。
例: `cells = NBFileReadAllCells[nb2]`

### NBFileWriteCell[nb, cellIdx, newText]
開いているノートブックの指定セルのテキストを newText で置き換える。セルスタイル・TaggingRules・秘匿マーク等の属性は保持される。
例: `NBFileWriteCell[nb2, 3, "This is a pen."]`

### NBFileWriteAllCells[nb, replacements]
`{cellIdx -> newText, ...}` の Association または List に従って複数セルを一括置換する。
例: `NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]`

## ObjectSpec API

### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を Association で返す。PrivacyLevel: 0.5=クラウド LLM 可、1.0=ローカルのみ、{0.5,1.0}=混在(.nb)。
例: `NBFileSpec["C:\\path\\file.nb"]`

### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。
例: `NBValueSpec[dataset, 1.0]`

### NBPrivacyLevelToRoutes[privacyLevel] → {String, ...}
必要なモデルルートリストを返す。0.5 → {"cloud"}、1.0 → {"local"}、{0.5,1.0} → {"cloud","local"}。
例: `NBPrivacyLevelToRoutes[{0.5, 1.0}]`

### NBFileReadCellsInRange[nb, lo, hi] → {{cellIdx, style, text, privacyLevel}, ...}
PrivacyLevel が lo〜hi のセルのみ返す。
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (公開セルのみ)、`NBFileReadCellsInRange[nb2, 0.9, 1.0]` (秘匿セルのみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb ファイルのセルを PrivacyLevel <= threshold (public) と > threshold (private) に2分割する。
例: `{pub, priv} = NBAccess`NBSplitNotebookCells["file.nb", 0.5]`

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
2つの `<|cellIdx->newText|>` を元セル順にマージして outputPath に保存する。
例: `NBAccess`NBMergeNotebookCells[src, dst, pubResults, privResults]`

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx]
セルに機密マーク (赤背景 + WarningSign) を付ける。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク (橙背景 + LockIcon) を付ける。機密変数に依存する計算結果などの間接的に機密なセルに使用する。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク (視覚・タグ) をすべて解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → True | False
セルが機密変数を参照しているか返す。

### NBCellExtractVarNames[nb, cellIdx] → {String, ...}
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → {String, ...}
セル内容から Confidential[] 内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → True | False
セルがプロンプトから除外すべきか返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → True | False
セルが Claude 関数呼び出しセルか返す。

### iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。(NBAccess` 名前空間の低レベル関数)

## 依存グラフ API

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析して変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返す。文字列リテラル内の識別子は除外される。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査して統合された変数依存関係グラフを返す。LLM 呼び出し直前の精密チェックで使用する。通常のセル実行時は軽量版 NBBuildVarDependencies[nb] を使用すること。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存の依存グラフに CellLabel In[x] (x > afterLine) のセルのみを追加走査してマージする。完全なグラフを毎回構築するコストを回避するインクリメンタル版。

### NBTransitiveDependents[deps, confVars] → {String, ...}
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。
### NBScanDependentCells[nb, confVarNames, deps]
事前計算済みの依存グラフ deps を使う (二重計算回避)。Claude 関数呼び出しセル (ClaudeQuery 等) は除外される。

### NBFilterHistoryEntry[entry, confVars] → entry
履歴エントリ内の response/instruction に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。confVars は現在の機密変数名リスト。

### NBDependencyEdges[nb] → {DirectedEdge["dep", "var"], ...}
ノートブックの変数依存関係をエッジリストで返す。"dep" → "var" は "var が dep に依存する" を意味する。
### NBDependencyEdges[nb, confVars]
機密変数 confVars に関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。各 Input セルについて InputText 取得結果、代入解析結果、依存判定結果を出力する。

### NBPlotDependencyGraph[]
全ノートブック統合の依存グラフをプロットする (デフォルト)。
### NBPlotDependencyGraph[nb]
指定ノートブックの依存グラフをプロットする。ノードは変数名・Out[n]で、直接秘密は赤、依存秘密は橙で着色。NB 内エッジは濃い実線、クロス NB エッジは薄い破線で描画。
Options: "Scope" -> "Global" (デフォルト) | "Local", PrivacySpec -> `<|"AccessLevel" -> 1.0|>` (表示範囲制御)
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。戻り値: `<|"関数名" -> {"大域変数1", ...}, ...|>`。パターン変数とスコーピング局所変数 (Module/Block/With/Function) は除外される。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックの TaggingRules から key の値を返す。ネストしたパス `{key1, key2, ...}` を指定可能。キーが存在しない場合は Missing[]。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に key -> value を設定する。ネストしたパス `{key1, key2}` を指定可能。

### NBDeleteTaggingRule[nb, key]
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] → {String, ...}
ノートブックの TaggingRules の全キーを返す。
### NBListTaggingRuleKeys[nb, prefix] → {String, ...}
prefix で始まるキーのみ返す。

## 汎用履歴データベース API

### NBHistoryCreate[nb, tag, diffFields] → Association | existing
新しい履歴データベースを作成する。diffFields は差分圧縮対象のフィールド名リスト (例: `{"fullPrompt", "response", "code"}`)。既存 DB に diffFields がある場合は既存ヘッダーを返す (冪等)。
### NBHistoryCreate[nb, tag, diffFields, headerOverrides]
ヘッダーを上書き可能。

### NBHistoryData[nb, tag] → Association
TaggingRules から履歴データを読み取り、差分圧縮されたエントリを復元して返す。戻り値: `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`。
Options: Decompress -> False で Diff オブジェクトのまま返す。

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す (内部用)。

### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書き込む。data は `<|"header" -> ..., "entries" -> {...}|>` の形式。entries は差分圧縮されていない平文で渡すこと。自動的に圧縮される。

### NBHistoryAppend[nb, tag, entry]
エントリを履歴に追加する。直前のエントリの fullPrompt/response/code を Diff で圧縮する。
Options: PrivacySpec -> ps (privacylevel をエントリに記録)

### NBHistoryEntries[nb, tag] → {Association, ...}
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> False で Diff オブジェクトのまま返す。

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updates は `<|"response" -> ..., "code" -> ..., ...|>` の形式。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加される。

### NBHistoryEntriesWithInherit[nb, tag] → {Association, ...}
親履歴を含む全エントリを返す。header の parent/inherit/created に従って親チェーンを遡る。
Options: Decompress -> False で Diff オブジェクトのまま返す。

### NBHistoryListTags[nb, prefix] → {String, ...}
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクション やバッチ更新に使用する。

## セッションアタッチメント API

### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加 (重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → {String, ...}
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, PrivacySpec -> ps]
prefix で始まる全履歴を削除する。PrivacySpec -> `<|"AccessLevel" -> 1.0|>` が必須。セルレベルの機密・機密依存タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。

## API キーアクセサー

### NBGetAPIKey[provider] → String
AI プロバイダーの API キーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0 が必要。呼び出し側で `PrivacySpec -> <|"AccessLevel" -> 1.0|>` を明示指定すること。SystemCredential へのアクセスを一元管理する。

## フォールバックモデル / プロバイダーアクセスレベル API

### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{provider, model}, {provider, model, url}, ...}`
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → {{String, ...}, ...}
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`、`NBSetProviderMaxAccessLevel["lmstudio", 1.0]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは 0.5 を返す。

### NBGetAvailableFallbackModels[accessLevel] → {{String, ...}, ...}
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダーの MaxAccessLevel >= accessLevel のモデルのみ含まれる。
例: `NBGetAvailableFallbackModels[0.8]` → lmstudio のみ、`NBGetAvailableFallbackModels[0.5]` → 全プロバイダー

### NBProviderCanAccess[provider, accessLevel] → True | False
プロバイダーが指定アクセスレベルのデータにアクセス可能か返す。MaxAccessLevel >= accessLevel なら True。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。
### NBSetAccessibleDirs[{dir1, dir2, ...}]
EvaluationNotebook[] に保存する。

### NBGetAccessibleDirs[nb] → {String, ...}
保存されたアクセス可能ディレクトリリストを返す。
### NBGetAccessibleDirs[] → {String, ...}
EvaluationNotebook[] から取得する。

## Job 管理 API

ClaudeQuery/ClaudeEval の非同期出力位置管理。

### NBBeginJob[nb, evalCell] → String
評価セルの直後に3つの不可視スロットセルを挿入しジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入する。スロット1: システムメッセージ (プログレス・フォールバック通知)、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除してテーブルをクリアする。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

### NBBeginJobAtEvalCell[nb] → String
EvaluationCell[] を内部取得してその直後に Job スロットを挿入する。claudecode が CellObject を保持する必要がない。

## 分離 API

claudecode が CellObject/Private に直接触れないための公開 API。

### NBExtractAssignments[text] → {String, ...}
テキストから Set/SetDelayed の LHS 変数名を抽出する。

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する。level デフォルト 1.0。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定する。key は識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → True | False
CellEpilog が key で既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストールする。checkSymbol は FreeQ チェック用マーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → True | False
機密追跡 CellEpilog がインストール済みか返す。checkSymbol は FreeQ チェック用マーカーシンボル。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。$NBAutoEvalProhibitedPatterns のいずれかにマッチする場合は評価をスキップして警告を表示する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。