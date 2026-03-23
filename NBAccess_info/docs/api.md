# NBAccess API リファレンス

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess関数のデフォルトPrivacySpec。ローカルLLM環境では `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` に設定する。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名とプライバシーレベルのテーブル。`<|"変数名" -> privacyLevel, ...|>` の形式。ClaudeCodeパッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMに送信するかを制御する。Falseにすると秘密依存Outputのスキーマ情報を一切送信しない。非秘密Outputは常にスマート要約付きで送信される。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査(ClaudeCheckSeparation)で無視するファイル名またはパッケージ名のリスト。`AppendTo[$NBSeparationIgnoreList, "MyPackage"]` で追加する。

## オプション

### PrivacySpec
NBAccess関数のプライバシーフィルタリングオプション。`PrivacySpec -> <|"AccessLevel" -> 0.5|>` の形式。AccessLevel ≤ セルのプライバシーレベルのセルのみアクセス可能。0.5はクラウドLLM安全なデータのみ、1.0は全データ。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[]のセルインデックスを返す。見つからない場合は0を返す。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリストを返す。セルブラケット選択またはカーソル位置のセルを返す。

### NBCellIndicesByTag[nb, tag] → List
指定CellTagsを持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定CellStyleのセルのインデックスリストを返す。`NBCellIndicesByStyle[nb, {style1, style2, ...}]` で複数スタイルを指定可能。

### NBDeleteCellsByTag[nb, tag]
指定CellTagsを持つセルを全て削除する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookReadでCell式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd経由でInputText形式を取得する。失敗時はNBCellExprToTextにフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルのCellStyleを返す。

### NBCellLabel[nb, cellIdx] → String
セルのCellLabel（例: "In[3]:="）を返す。ラベルなしの場合は "" を返す。

### NBCellSetOptions[nb, cellIdx, opts]
セルにSetOptionsを適用する。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
TaggingRulesのネスト値を返す。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellRasterize[nb, cellIdx, file, opts]
セルをRasterizeしてfileに保存する。

### NBCellHasImage[cellExpr] → Boolean
Cell式が画像(RasterBox/GraphicsBox)を含むか判定する。cellExprはNBCellReadの戻り値を想定。

### NBUserNotebooks[] → List
WindowFrame が "Normal" のユーザーノートブックのみを返す。パレット・ヘルプブラウザ等のシステムNBは除外される。

### NBInvalidateCellsCache[]
全ノートブックのセルキャッシュを無効化する。

### NBInvalidateCellsCache[nb]
指定ノートブックのセルキャッシュを無効化する。

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル(0.0〜1.0)を返す。0.0=非秘密、0.75=依存秘密、1.0=直接秘密(Confidentialマークまたは秘密変数参照)。

### NBIsAccessible[nb, cellIdx, opts]
セルが指定のPrivacySpecでアクセス可能かどうかを返す(True/False)。
→ Boolean
Options: PrivacySpec -> Automatic (デフォルトは$NBPrivacySpec)

### NBFilterCellIndices[nb, indices, opts]
セルインデックスリストをPrivacySpecでフィルタリングして返す。
→ List
Options: PrivacySpec -> Automatic

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookReadの結果(Cell式)からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, opts]
ノートブック内の全セルインデックスをPrivacySpecでフィルタリングして返す。
→ List
Options: PrivacySpec -> Automatic

### NBGetContext[nb, afterIdx, opts]
ノートブック内のafterIdx番目以降のセルからLLMプロンプト用コンテキスト文字列を構築する。PrivacySpecでフィルタリングされる。
→ String
Options: PrivacySpec -> Automatic (デフォルトAccessLevel 0.5)

## 書き込み API

### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。styleのデフォルトは "Text"。

### NBWriteCode[nb, code]
構文カラーリング付きInputセルを書き込む。安全な数式はMakeBoxes[StandardForm]でタイプセット、それ以外はFEParserにフォールバック。

### NBWriteSmartCode[nb, code]
CellPrint[]パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろにInputセルを挿入し、カーソルをセル先頭に移動する。autoEvaluateがTrueの場合はさらにSelectionEvaluateを行う。

### NBInsertTextCells[nbFile, name, prompt]
.nbファイルを非表示で開き、末尾にSubsectionセル(name)とTextセル(prompt)を挿入して保存・閉じる。

### NBWriteCell[nb, cellExpr]
ノートブックにCell式を書き込む(After)。`NBWriteCell[nb, cellExpr, pos]`でpos(After/Before/All)を指定可能。

### NBWritePrintNotice[nb, text, color]
ノートブックに通知用Printセルを書き込む。nbがNoneの場合はCellPrintを使用(同期In/Out間出力)。

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
ノートブックにDynamicセルを書き込む。tagが "" でない場合はCellTagsを設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguageセルを書き込む。autoEvaluateがTrueなら直前セルを評価する。

### NBInsertAndEvaluateInput[nb, boxes]
Inputセルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
InputセルをAfterに書き込みBefore CellContentsに移動する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell直後に不可視アンカーセルを書き込む。EvaluationCellが取得できない場合はノートブック末尾に書き込む。

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRulesから機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグをval(True/False)に設定する。

### NBMarkCellConfidential[nb, cellIdx]
セルに機密マーク（赤背景 + WarningSign）を付ける。直接秘密セルに使用する。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク（橙背景 + LockIcon）を付ける。機密変数に依存する計算結果など間接的に機密なセルに使用する。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク（視覚・タグ）をすべて解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが機密変数を参照しているかを返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容からSet/SetDelayedのLHS変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容からConfidential[]内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきかを返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルがClaude関数呼び出しセルかを返す。

## 依存グラフ API

### NBBuildVarDependencies[nb] → Association
ノートブックのInputセルを解析して変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返す。文字列リテラル内の識別子は除外される。通常のセル実行時に使用する。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[]全体のInputセルを走査して統合された変数依存関係グラフを返す。LLM呼び出し直前の精密チェックで使用する。通常はNBBuildVarDependencies[nb]を使うこと。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {Association, Integer}
既存の依存グラフにCellLabel In[x] (x > afterLine)のセルのみを追加走査してマージする。返り値は `{updatedDeps, newLastLine}`。完全グラフを毎回構築するコストを回避するインクリメンタル版。

### NBTransitiveDependents[deps, confVars] → List
depsグラフ上でconfVarsに直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルにNBMarkCellDependentを適用し、新たにマークしたセル数を返す。Claude関数呼び出しセルは除外される。
`NBScanDependentCells[nb, confVarNames, deps]` で事前計算済みの依存グラフdepsを使う（二重計算回避）。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリ内のresponse/instructionに現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。confVarsは現在の機密変数名リスト。
`NBFilterHistoryEntry[entry, confVars, confVarTimes]` でconfVarTimesを指定すると登録時刻ベースのフィルタリングも行う。

### NBDependencyEdges[nb] → List
ノートブックの変数依存関係をエッジリスト `{DirectedEdge["dep", "var"], ...}` で返す。"dep" → "var" は "varがdepに依存する"を意味する。
`NBDependencyEdges[nb, confVars]` は機密変数confVarsに関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストをPrintで表示するデバッグ関数。各Inputセルについて InputText取得結果、代入解析結果、依存判定結果を出力する。

### NBPlotDependencyGraph[opts]
全ノートブック統合の依存グラフをプロットする（デフォルト）。
`NBPlotDependencyGraph[nb, opts]` で指定ノートブックの依存グラフをプロットする。
ノードは変数名・Out[n]で、直接秘密は赤、依存秘密は橙で着色。NB内エッジは濃い実線、クロスNBエッジは薄い破線で描画。
→ Graph
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>` (表示範囲制御), "Scope" -> "Global" ("Global"|"Local"), GraphLayout -> "LayeredDigraphEmbedding"
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。`<|"関数名" -> {"大域変数1", ...}, ...|>` の形式。パターン変数とスコーピング局所変数(Module/Block/With/Function)は除外される。

## TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックのTaggingRulesからkeyの値を返す。`NBGetTaggingRule[nb, {key1, key2, ...}]` でネストしたパスを指定可能。キーが存在しない場合はMissing[]を返す。

### NBSetTaggingRule[nb, key, value]
ノートブックのTaggingRulesに `key -> value` を設定する。`NBSetTaggingRule[nb, {key1, key2}, value]` でネストしたパスを指定可能。

### NBDeleteTaggingRule[nb, key]
ノートブックのTaggingRulesからkeyを削除する。

### NBListTaggingRuleKeys[nb] → List
ノートブックのTaggingRulesの全キーを返す。`NBListTaggingRuleKeys[nb, prefix]` でprefixで始まるキーのみ返す。

## 履歴データベース API

### NBHistoryCreate[nb, tag, diffFields]
新しい履歴データベースを作成する。diffFieldsは差分圧縮対象のフィールド名リスト（例: `{"fullPrompt", "response", "code"}`）。既存DBにdiffFieldsがある場合は既存ヘッダーを返す（冪等）。
`NBHistoryCreate[nb, tag, diffFields, headerOverrides]` でヘッダーを上書き可能。

### NBHistoryData[nb, tag] → Association
TaggingRulesから履歴データを読み取り、差分圧縮されたエントリを復元して返す。`<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>` の形式。
Options: Decompress -> True (False でDiffオブジェクトのまま返す)

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す（内部用）。

### NBHistorySetData[nb, tag, data]
TaggingRulesに履歴データを書き込む。dataは `<|"header" -> ..., "entries" -> {...}|>` の形式。entriesは差分圧縮されていない平文で渡すこと。自動的に圧縮される。

### NBHistoryAppend[nb, tag, entry]
エントリを履歴に追加する。差分圧縮: 直前エントリのfullPrompt/response/codeをDiffで圧縮する。
Options: PrivacySpec -> Automatic (privacylevelをエントリに記録)

### NBHistoryEntries[nb, tag] → List
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True (False でDiffオブジェクトのまま返す)

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updatesは `<|"response" -> ..., "code" -> ..., ...|>` の形式。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダーAssociationを返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag] → List
親履歴を含む全エントリを返す。headerのparent/inherit/createdに従って親チェーンを辿る。
Options: Decompress -> True (False でDiffオブジェクトのまま返す)

### NBHistoryListTags[nb, prefix] → List
prefixで始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴をTaggingRulesから削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクションやバッチ更新に使用する。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加される。

### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加（重複除去）。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

## Job管理 API

### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブIDを返す。evalCellがCellObjectでない場合はノートブック末尾に挿入する。スロット1: システムメッセージ（プログレス・フォールバック通知）、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[]を内部取得してその直後にJobスロットを挿入する。claudecodeがCellObjectを保持する必要がない分離API。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットにCell式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除してテーブルをクリアする。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

## 分離 API

### NBExtractAssignments[text] → List
テキストからSet/SetDelayedのLHS変数名を抽出する。

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する（levelデフォルト 1.0）。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

### NBGetPrivacySpec[] → Association
現在の$NBPrivacySpecを返す。

### NBInstallCellEpilog[nb, key, expr]
ノートブックのCellEpilogに式を設定する。keyは識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilogがkeyで既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用CellEpilogをインストールする。checkSymbolはFreeQチェック用のマーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡CellEpilogがインストール済みか返す。checkSymbolはFreeQチェック用のマーカーシンボル。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。

### NBInsertInputTemplate[nb, boxes]
InputセルテンプレートをBefore CellContentsに挿入する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCellの親ノートブックを返す。

## API キーアクセサー

### NBGetAPIKey[provider, opts]
AIプロバイダのAPIキーを返す。providerは "anthropic" | "openai" | "github"。SystemCredentialへのアクセスを一元管理する。
→ String | $Failed
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>` (AccessLevel < 1.0 の場合は$Failedを返す)

## フォールバックモデル / プロバイダーアクセスレベル API

### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{provider, model}, {provider, model, url}, ...}`
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベルを設定する。levelは0.0〜1.0。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`、`NBSetProviderMaxAccessLevel["lmstudio", 1.0]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは0.5を返す。初期値: anthropic=0.5, openai=0.5, lmstudio=1.0, claudecode=0.5。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダーのMaxAccessLevel >= accessLevelのモデルのみ含まれる。
例: `NBGetAvailableFallbackModels[0.8]` → lmstudioのみ、`NBGetAvailableFallbackModels[0.5]` → 全プロバイダー

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダーが指定アクセスレベルのデータにアクセス可能かを返す。MaxAccessLevel >= accessLevel ならTrue。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
Claude Codeが参照可能なディレクトリリストをTaggingRulesに保存する。
`NBSetAccessibleDirs[{dir1, dir2, ...}]` はEvaluationNotebook[]に保存する。

### NBGetAccessibleDirs[nb] → List
保存されたアクセス可能ディレクトリリストを返す。
`NBGetAccessibleDirs[]` はEvaluationNotebook[]から取得する。