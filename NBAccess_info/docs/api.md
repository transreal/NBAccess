# NBAccess API リファレンス

パッケージ: `NBAccess`
GitHub: https://github.com/transreal/NBAccess
ロード: `Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]`（または claudecode.wl 経由）

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。ローカルLLM環境では `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` に設定する。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名 → プライバシーレベルのテーブル `<|"varName" -> level, ...|>`。ClaudeCode パッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: `True`
`True`: 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信する。`False`: 秘密依存 Output のスキーマ情報を一切送信しない。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査 (ClaudeCheckSeparation) で無視するファイル名またはパッケージ名のリスト。
例: `AppendTo[$NBSeparationIgnoreList, "MyPackage"]`

## オプション

### PrivacySpec
NBAccess 関数のプライバシーフィルタリングオプション。
`PrivacySpec -> <|"AccessLevel" -> 0.5|>`
`AccessLevel <= セルのプライバシーレベル` のセルのみアクセス可能。0.5: クラウドLLM安全なデータのみ（デフォルト）、1.0: すべてのデータ。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリストを返す。セルブラケット選択またはカーソル位置のセルを返す。

### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリストを返す。`style` は文字列または文字列リスト。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルをすべて削除する。

### NBMoveAfterCell[nb, cellIdx]
指定セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel（例: `"In[3]:="`）を返す。ラベルなしの場合は `""` を返す。

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
TaggingRules のネスト値を返す。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像（RasterBox/GraphicsBox）を含むか判定する。cellExpr は NBCellRead の戻り値を想定。

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル（0.0〜1.0）を返す。
0.0: 非秘密、0.75: 秘密依存、1.0: 秘密（Confidential マークまたは秘密変数参照）。

### NBIsAccessible[nb, cellIdx, opts] → Boolean
セルが指定の PrivacySpec でアクセス可能かを返す。
Options: `PrivacySpec -> Automatic`

### NBFilterCellIndices[nb, indices, opts] → List
セルインデックスリストを PrivacySpec でフィルタリングして返す。
Options: `PrivacySpec -> Automatic`

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookRead の結果（Cell 式）からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, opts] → List
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。
Options: `PrivacySpec -> Automatic`

### NBGetContext[nb, afterIdx, opts] → String
ノートブック内の afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築する。PrivacySpec でフィルタリングされる。
Options: `PrivacySpec -> Automatic`（デフォルト AccessLevel 0.5）

## 書き込み API

### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。style のデフォルトは `"Text"`。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。安全な数式は MakeBoxes でタイプセット、それ以外は FEParser でフォールバック。

### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動する。`autoEvaluate` が True の場合はさらに SelectionEvaluate を行う。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル（name）と Text セル（prompt）を挿入して保存・閉じる。

### NBWriteCell[nb, cellExpr]
ノートブックに Cell 式を書き込む（After）。`NBWriteCell[nb, cellExpr, pos]` で pos（After/Before/All）を指定可能。

### NBWritePrintNotice[nb, text, color]
ノートブックに通知用 Print セルを書き込む。nb が None の場合は CellPrint を使用（同期 In/Out 間出力）。

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
ノートブックに Dynamic セルを書き込む。tag が `""` でない場合は CellTags を設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。autoEvaluate が True なら直前セルを評価する。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書き込む。EvaluationCell が取得できない場合はノートブック末尾に書き込む。

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val（True/False）に設定する。

### NBMarkCellConfidential[nb, cellIdx]
セルに機密マーク（赤背景 + WarningSign）を付ける。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク（橙背景 + LockIcon）を付ける。機密変数に依存する計算結果など、間接的に機密なセルに使用する。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク（視覚・タグ）をすべて解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが機密変数を参照しているかを返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容から `Confidential[var = ...]` パターンの代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきかを返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルが Claude 関数呼び出しセル（ClaudeQuery 等）かを返す。

### NBExtractAssignments[text] → List
テキストから Set/SetDelayed の LHS 変数名を抽出する。

## 依存グラフ API

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析して変数依存関係グラフ `<|"var" -> {"dep1", ...}, ...|>` を返す。文字列リテラル内の識別子は除外される。通常のセル実行時はこちらを使用する。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査して統合された変数依存関係グラフを返す。LLM 呼び出し直前の精密チェック用。通常は NBBuildVarDependencies[nb] を使用すること。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {Association, Integer}
既存の依存グラフに `In[x]`（x > afterLine）のセルのみを追加走査してマージするインクリメンタル版。返り値: `{updatedDeps, newLastLine}`。

### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。Claude 関数呼び出しセルは除外される。
`NBScanDependentCells[nb, confVarNames, deps]` は事前計算済みの依存グラフ deps を使う（二重計算回避）。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリ内の response/code に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。
`NBFilterHistoryEntry[entry, confVars, confVarTimes]` は機密変数登録時刻も考慮する。

### NBDependencyEdges[nb] → List
ノートブックの変数依存関係をエッジリスト `{DirectedEdge["dep", "var"], ...}` で返す。`"dep" → "var"` は「var が dep に依存する」を意味する。
`NBDependencyEdges[nb, confVars]` は機密変数 confVars に関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。

### NBPlotDependencyGraph[opts]
全ノートブック統合の依存グラフをプロット（デフォルト Scope="Global"）。
`NBPlotDependencyGraph[nb, opts]` は指定ノートブックの依存グラフをプロット。
→ Graphics
Options: `PrivacySpec -> <|"AccessLevel" -> 1.0|>`, `"Scope" -> "Global"` ("Global"|"Local"), `GraphLayout -> "LayeredDigraphEmbedding"`
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。
戻り値: `<|"関数名" -> {"大域変数1", ...}, ...|>`。パターン変数とスコーピング局所変数（Module/Block/With/Function）は除外される。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックの TaggingRules から key の値を返す。
`NBGetTaggingRule[nb, {key1, key2, ...}]` でネストしたパスを指定可能。キーが存在しない場合は Missing[] を返す。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に key → value を設定する。`NBSetTaggingRule[nb, {key1, key2}, value]` でネストしたパスを指定可能。

### NBDeleteTaggingRule[nb, key]
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] → List
ノートブックの TaggingRules の全キーを返す。
`NBListTaggingRuleKeys[nb, prefix]` は prefix で始まるキーのみ返す。

## 汎用履歴データベース API

TaggingRules を用いた順次格納型履歴システム。各タグに `<|"header" -> ..., "entries" -> {...}|>` を格納。diffFields に指定したフィールドは Diff による差分圧縮（最新エントリは平文、それ以前は Diff オブジェクト）。

### NBHistoryCreate[nb, tag, diffFields]
新しい履歴データベースを作成する（冪等）。diffFields は差分圧縮対象のフィールド名リスト（例: `{"fullPrompt", "response", "code"}`）。
`NBHistoryCreate[nb, tag, diffFields, headerOverrides]` でヘッダーを上書き可能。既存 DB に diffFields がある場合は既存ヘッダーを返す。

### NBHistoryData[nb, tag] → Association
TaggingRules から履歴データを読み取り、差分圧縮されたエントリを復元して返す。
戻り値: `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: `Decompress -> False` で Diff オブジェクトのまま返す。

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す（内部用）。

### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書き込む。data は `<|"header" -> ..., "entries" -> {...}|>` の形式。entries は差分圧縮されていない平文で渡すこと（自動的に圧縮される）。

### NBHistoryAppend[nb, tag, entry]
エントリを履歴に追加する。直前エントリの fullPrompt/response/code 等を Diff で圧縮する。
Options: `PrivacySpec -> Automatic`（privacylevel をエントリに記録）

### NBHistoryEntries[nb, tag] → List
差分圧縮を復元した全エントリリストを返す。
Options: `Decompress -> False` で Diff オブジェクトのまま返す。

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updates は `<|"response" -> ..., "code" -> ..., ...|>` の形式。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加される。

### NBHistoryEntriesWithInherit[nb, tag] → List
親履歴を含む全エントリを返す。header の parent/inherit/created に従って親チェーンを辿る。
Options: `Decompress -> False` で Diff オブジェクトのまま返す。

### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクションやバッチ更新に使用する。

## セッションアタッチメント API

### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加（重複除去）。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

## API キーアクセサー

### NBGetAPIKey[provider, opts] → String | $Failed
AI プロバイダの API キーを返す。provider: `"anthropic"` | `"openai"` | `"github"`。
→ String（成功時）、$Failed（未設定またはアクセスレベル不足）
Options: `PrivacySpec -> <|"AccessLevel" -> 1.0|>`
SystemCredential へのアクセスを一元管理する。AccessLevel < 1.0 では常に $Failed を返す。

## フォールバックモデル / プロバイダーアクセスレベル API

### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{"provider", "model"}, {"provider", "model", "url"}, ...}`
例: `NBSetFallbackModels[{{"anthropic", "claude-opus-4-6"}, {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`、`NBSetProviderMaxAccessLevel["lmstudio", 1.0]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは 0.5 を返す。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダーの MaxAccessLevel >= accessLevel のモデルのみ含まれる。
例: `NBGetAvailableFallbackModels[0.8]` → lmstudio のみ、`NBGetAvailableFallbackModels[0.5]` → 全プロバイダー

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダーが指定アクセスレベルのデータにアクセス可能かを返す。MaxAccessLevel >= accessLevel なら True。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。
`NBSetAccessibleDirs[{dir1, ...}]` は EvaluationNotebook[] に保存する。

### NBGetAccessibleDirs[nb] → List
保存されたアクセス可能ディレクトリリストを返す。
`NBGetAccessibleDirs[]` は EvaluationNotebook[] から取得する。

## Job 管理 API

非同期出力位置管理。ClaudeQuery/ClaudeEval の非同期出力セルを評価セルの直後に予約する。

### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入し、ジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入する。
スロット1: システムメッセージ（プログレス・フォールバック通知）、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除してテーブルをクリアする。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[] を内部取得してその直後にジョブスロットを挿入する。claudecode が CellObject を保持する必要がない分離 API。

## 分離 API（claudecode 向け）

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する（level デフォルト 1.0）。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定する。key は識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilog が key で既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストールする。checkSymbol は FreeQ チェック用のマーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡 CellEpilog がインストール済みか返す。checkSymbol は FreeQ チェック用のマーカーシンボル。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## ノートブック管理

### NBUserNotebooks[] → List
WindowFrame が "Normal" のユーザーノートブックのみを返す。パレット・ヘルプブラウザ・ダイアログ等のシステム NB は除外される。

### NBInvalidateCellsCache[]
全ノートブックのセルキャッシュを無効化する。
`NBInvalidateCellsCache[nb]` は指定ノートブックのキャッシュのみ無効化する。

## 内部 API（公開シンボル）

### iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。