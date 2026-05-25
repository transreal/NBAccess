# NBAccess API リファレンス

ノートブックアクセスユーティリティパッケージ。セルインデックスベースでノートブックの読み書きとプライバシーフィルタリングを提供する。

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess関数のデフォルトPrivacySpec。0.5=クラウドLLM安全データのみ、1.0=ローカルLLM環境などすべてのデータ。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名とプライバシーレベルのテーブル。`<|"変数名" -> privacyLevel, ...|>` 形式。ClaudeCodeが自動更新。

### $NBSendDataSchema
型: Boolean, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMに送信するかを制御。

### $NBVerbose
型: Boolean, 初期値: False
NBAccess内部の詳細ログ出力を制御。

### $NBAutoEvalProhibitedPatterns
型: List, 初期値: `{}`
NBEvaluatePreviousCellで自動実行をブロックするRegularExpression/StringExpressionのリスト。

### $NBLLMQueryFunc
型: Function, 初期値: None
非同期LLM呼び出し用コールバック。シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]`。ClaudeCodeがClaudeQueryAsyncを登録する。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査(ClaudeCheckSeparation)で無視するファイル名/パッケージ名のリスト。

## オプション名

### PrivacySpec
NBAccess関数のプライバシーフィルタリングオプション。
例: `PrivacySpec -> <|"AccessLevel" -> 0.5|>`
AccessLevel ≦ セルのプライバシーレベル のセルのみアクセス可能。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[]のセルインデックス。見つからないと0。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリスト。

### NBCellIndicesByTag[nb, tag] → List
指定CellTagsを持つセルのインデックスリスト。

### NBCellIndicesByStyle[nb, style] → List
指定CellStyleのセルのインデックスリスト。styleはStringまたは`{style1, style2, ...}`。

### NBDeleteCellsByTag[nb, tag] → Null
指定CellTagsを持つセルをすべて削除。

### NBMoveAfterCell[nb, cellIdx] → Null
セルの後ろにカーソルを移動。

### NBCellRead[nb, cellIdx] → Cell
NotebookReadでCell式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd経由でInputText形式取得。失敗時はNBCellExprToTextにフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルのCellStyle。

### NBCellLabel[nb, cellIdx] → String
セルのCellLabel(例: "In[3]:=")。ラベルなしは""。

### NBCellSetOptions[nb, cellIdx, opts] → Null
セルにSetOptionsを適用。

### NBCellSetStyle[nb, cellIdx, style] → Null
セルのスタイルを変更。TaggingRules等の属性は保持される。
例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code] → Null
既存セルに構文カラーリング付きでコードを書き込む(BoxData + Input)。
例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBCellWriteText[nb, cellIdx, newText] → Null
セルのテキスト内容をnewTextに置き換える。スタイル・TaggingRules・オプション等は保持。

### NBSelectCell[nb, cellIdx] → Null
セルブラケットを選択状態にする。

### NBResolveCell[nb, cellIdx] → CellObject | $Failed
CellObjectを返す。無効な場合は$Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → value | Missing[]
TaggingRulesのネスト値を取得。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value] → Null
セルのTaggingRulesにネスト値を設定。

### NBCellRasterize[nb, cellIdx, file, opts] → Null
セルをRasterizeしてファイルに保存。

### NBCellHasImage[cellExpr] → Bool
Cell式が画像(RasterBox/GraphicsBox)を含むか判定。

## LLM 連携 API

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可なら""。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルをLLM変換。
→ Null
Options: Fallback -> False, InputText -> Automatic
promptFnはセルテキスト→プロンプト文字列。completionFnは`<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`を受け取る(エラー時は$Failed)。
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル(0.0〜1.0)。0.0=非秘密、1.0=秘密。

### NBIsAccessible[nb, cellIdx, opts] → Bool
セルが指定PrivacySpecでアクセス可能か。
Options: PrivacySpec -> $NBPrivacySpec

### NBFilterCellIndices[nb, indices, opts] → List
インデックスリストをPrivacySpecでフィルタ。
Options: PrivacySpec -> $NBPrivacySpec

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookReadの結果(Cell式)からテキスト抽出。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容。

### NBGetCells[nb, opts] → List
ノートブック内の全セルインデックスをPrivacySpecでフィルタ。
Options: PrivacySpec -> $NBPrivacySpec

### NBGetContext[nb, afterIdx, opts] → String
afterIdx番目以降からLLMプロンプト用コンテキスト文字列を構築。
Options: PrivacySpec -> $NBPrivacySpec

## 書き込み API

### NBWriteText[nb, text, style] → Null
テキストセルを書き込む。styleデフォルトは"Text"。

### NBWriteCode[nb, code] → Null
構文カラーリング付きInputセルを書き込む。

### NBWriteSmartCode[nb, code] → Null
CellPrint[]パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate] → Null
現在のカーソル位置の後ろにInputセルを挿入。autoEvaluateがTrueならSelectionEvaluate。

### NBInsertTextCells[nbFile, name, prompt] → Null
.nbファイルを非表示で開き末尾にSubsection(name)とText(prompt)を挿入し保存・閉じる。

## ファイル型ノートブック操作 API

閉じた.nbファイルを対象。**必ずこのAPIを経由すること**。NotebookOpen/NotebookGetを直接使ってはならない。

### NBFileOpen[path] → NotebookObject | $Failed
.nbファイルを非表示(Visible->False)で開く。必ずNBFileCloseで閉じる。

### NBFileClose[nb] → Null
NBFileOpenで開いたノートブックを閉じる。

### NBFileSave[nb, path] → Null
ノートブックを指定パスに保存。pathがNoneなら上書き。

### NBFileReadCells[nb, opts] → List
全セルをPrivacySpecでフィルタリングし`{<|cellIdx, style, text, privacyLevel|>, ...}`を返す。privacyLevel > PrivacySpec の秘密セルはテキストを`"[CONFIDENTIAL]"`に置換。
Options: PrivacySpec -> $NBPrivacySpec

### NBFileReadAllCells[nb] → List
全セルをアクセスレベル別に分類して返す。秘密セルも含む(PrivacyLevelフィールドで識別)。ローカルモデル用。

### NBFileWriteCell[nb, cellIdx, newText] → Null
指定セルのテキストをnewTextに置換。属性保持。

### NBFileWriteAllCells[nb, replacements] → Null
`<|cellIdx -> newText, ...|>`に従って一括置換。

## ObjectSpec API

### NBFileSpec[path] → Association
ファイルのメタ情報とPrivacyLevelをAssociationで返す。PrivacyLevel: <0.5=クラウド可、>=0.5=ローカルのみ、{0.5,1.0}=混在。

### NBFileSpecCacheClear[] → Null
NBFileSpecのbase/projectionキャッシュをクリア。

### NBNormalizePath[path] → Association
絶対パスをシンボリックパス情報のAssociationに正規化。
キー: `"Kind", "RootId", "Parts", "SymbolicPath", "PhysicalPath", "ResolutionStatus", "MatchedBy"`
ResolutionStatus: `"ResolvedOnThisPC" | "AliasOnly" | "Unrooted"`
MatchedBy: `"LocalRoot" | "Alias" | "None"`
権限判定にはPhysicalPathを別途現PCで実在確認すること。

### NBValueSpec[expr, privacyLevel] → Association
値の型情報とPrivacyLevelを返す。

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5→`{"cloud"}`、1.0→`{"local"}`、`{0.5,1.0}`→`{"cloud","local"}`。

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevelがlo〜hiのセルのみ返す。
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (公開のみ)、`NBFileReadCellsInRange[nb2, 0.9, 1.0]` (秘密のみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nbファイルのセルをPrivacyLevel <= threshold (public) と > threshold (private) に2分割。

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2] → Null
2つの`<|cellIdx->newText|>`を元セル順にマージしてoutputPathに保存。

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRulesから機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val] → Null
セルの機密タグをval(True/False)に設定。

### NBMarkCellConfidential[nb, cellIdx, opts] → Null
セルを機密(PrivacyLevel 1.0)に設定し赤背景マーク。
`NBMarkCellConfidential[nb, cellIdx, level, opts]` で任意のPrivacyLevel(0.0-1.0)を設定。level > 0.5 で赤背景、≦0.5 ならマーク解除。
Options: PrivacySpec -> Automatic
$NBApprovalHeadsに登録済み(承認ゲート発火)。

### NBSetSnapshotPrivacyLevel[snapshotId, level, opts] → Null
SourceVault snapshotのPrivacyLevelを設定。
Options: PrivacySpec -> Automatic
SourceVaultがロード済み必要。$NBApprovalHeadsに登録済み。

### NBMarkCellDependent[nb, cellIdx] → Null
セルに依存機密マーク(橙背景 + LockIcon)を付ける。

### NBUnmarkCell[nb, cellIdx] → Null
セルの機密マーク(視覚・タグ)をすべて解除。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Bool
セルが機密変数を参照しているか。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容からSet/SetDelayedのLHS変数名を抽出。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容からConfidential[]内の代入先変数名を抽出。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Bool
セルがプロンプトから除外すべきか。

### NBIsClaudeFunctionCell[nb, cellIdx] → Bool
セルがClaude関数呼び出しセルか。

## 依存グラフ API

### NBAccess`iCellToInputText[cell] → String
FrontEnd経由でセルのInputText形式取得。失敗時はNBCellExprToTextにフォールバック。

### NBBuildVarDependencies[nb] → Association
ノートブックのInputセル解析。`<|"var" -> {"dep1",...}|>`を返す。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[]全体の統合依存グラフ。LLM呼び出し直前の精密チェック用。通常はNBBuildVarDependenciesを使う。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
CellLabel In[x] (x > afterLine)のセルのみ追加走査・マージするインクリメンタル版。

### NBTransitiveDependents[deps, confVars] → List
depsグラフ上でconfVarsに直接/間接依存する全変数名。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルにNBMarkCellDependentを適用。新規マーク数を返す。
`NBScanDependentCells[nb, confVarNames, deps]` で事前計算済みdepsを使う。Claude関数呼び出しセルは除外。

### NBFilterHistoryEntry[entry, confVars] → entry
履歴エントリ内のresponse/instructionに現時点の機密変数名/値が含まれる場合にフィールドをブロック。

### NBDependencyEdges[nb] → List
変数依存関係をエッジリスト`{DirectedEdge["dep", "var"], ...}`で返す。
`NBDependencyEdges[nb, confVars]` で機密変数関連のエッジのみ。

### NBDebugDependencies[nb, confVars] → Null
依存グラフ・推移依存・セルテキストをPrint表示するデバッグ関数。

### NBPlotDependencyGraph[opts] → Graphics
全ノートブック統合依存グラフをプロット。
`NBPlotDependencyGraph[nb, opts]` で指定ノートブックのみ。
Options: "Scope" -> "Global" | "Local", PrivacySpec -> $NBPrivacySpec
直接機密=赤、依存機密=橙、NB内エッジ=濃い実線、クロスNB=薄い破線。

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内全関数定義を解析し`<|"関数名" -> {"大域変数1", ...}, ...|>`を返す。パラメータ変数とスコーピング局所変数(Module/Block/With/Function)は除外。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
TaggingRulesからkeyの値を返す。`NBGetTaggingRule[nb, {key1, key2, ...}]` でネストパス指定可。

### NBSetTaggingRule[nb, key, value] → Null
TaggingRulesにkey -> valueを設定。ネストパス指定可。

### NBDeleteTaggingRule[nb, key] → Null
TaggingRulesからkeyを削除。

### NBListTaggingRuleKeys[nb] → List
TaggingRulesの全キー。`NBListTaggingRuleKeys[nb, prefix]` でprefix始まりのみ。

## 履歴データベース API

### NBHistoryData[nb, tag, opts] → Association
TaggingRulesから履歴を読み取り差分復元したエントリ。
→ `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: Decompress -> True (False: Diffオブジェクトのまま返す)

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す(内部用)。

### NBHistorySetData[nb, tag, data] → Null
TaggingRulesに履歴データを書き込む。dataは`<|"header" -> ..., "entries" -> {...}|>`。entriesは平文で渡す(自動圧縮)。

### NBHistoryAppend[nb, tag, entry, opts] → Null
エントリを履歴に追加。直前エントリのfullPrompt/response/codeをDiffで圧縮。
Options: PrivacySpec -> $NBPrivacySpec

### NBHistoryEntries[nb, tag, opts] → List
差分復元した全エントリ。
Options: Decompress -> True

### NBHistoryUpdateLast[nb, tag, updates] → Null
最後のエントリを更新。updates: `<|"response" -> ..., "code" -> ..., ...|>`

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー。

### NBHistoryWriteHeader[nb, tag, header] → Null
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリ。
Options: Decompress -> True

### NBHistoryListTags[nb, prefix] → List
prefix始まりの履歴タグ一覧。

### NBHistoryDelete[nb, tag] → Null
指定タグの履歴を削除。

### NBHistoryReplaceEntries[nb, tag, entries] → Null
エントリリスト全体を置換。コンパクションやバッチ更新用。

### NBHistoryUpdateHeader[nb, tag, updates] → Null
ヘッダーにキー追加/更新。

### NBHistoryCreate[nb, tag, diffFields] → Association
新しい履歴データベースを作成。diffFields例: `{"fullPrompt", "response", "code"}`
`NBHistoryCreate[nb, tag, diffFields, headerOverrides]` でヘッダー上書き。既存DBに同じdiffFieldsがあれば既存ヘッダー返却(冪等)。

## セッションアタッチメント API

### NBHistoryAddAttachment[nb, tag, path] → Null
ヘッダーの"attachments"リストにパス追加(重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path] → Null
アタッチメントから削除。

### NBHistoryGetAttachments[nb, tag] → List
アタッチメントリスト。

### NBHistoryClearAttachments[nb, tag] → Null
全アタッチメントクリア。

### NBHistoryClearAll[nb, prefix, opts] → Null
prefixで始まる全履歴を削除。
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>` (必須)
セルレベルの機密タグは削除しない。

## API キーアクセサー

### NBGetAPIKey[provider] → String
AIプロバイダのAPIキー。provider: `"anthropic" | "openai" | "github"`
AccessLevel >= 1.0 必須。呼び出し側で `PrivacySpec -> <|"AccessLevel" -> 1.0|>` を明示指定。

## ローカル LLM API キー

### NBGetLocalLLMAPIKey[provider, url] → String
ローカルLLMサーバのAPIキー取得。照合は{provider, url}ペア。
例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`
AccessLevel >= 1.0 必須。解決優先度: (1)完全一致 (2)localhost↔127.0.0.1置換 (3){provider, "*"}ワイルドカード (4)`ToUpperCase[provider]<>"_API_KEY"`。

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピング登録。SystemCredential実値は書き込まない。
例: `NBSetLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234", "LMSTUDIO_STUDY_KEY"]`

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key] → Null
マッピング登録 + SystemCredential[credentialName] = key を同時設定。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url] → Null
{provider, url}エントリ削除。SystemCredential本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
登録済みローカルLLMサーバ→APIキー名マッピング。Configured列は実際にSystemCredential設定済みかを示す。

### NBLocalLLMCredentialName[provider, url] → String
SystemCredential名のみ返す(値は取得しない)。AccessLevelチェックなし。

## フォールバックモデル / プロバイダーアクセスレベル API

### NBSetFallbackModels[models] → Null
フォールバックモデルリストを設定。models: `{{"provider","model"}, {"provider","model","url"}, ...}`
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体。

### NBSetProviderMaxAccessLevel[provider, level] → Null
プロバイダーの最大アクセスレベル(0.0〜1.0)を設定。

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベル。未登録は0.5。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリスト。プロバイダーのMaxAccessLevel >= accessLevelのみ。

### NBProviderCanAccess[provider, accessLevel] → Bool
プロバイダーが指定アクセスレベルのデータにアクセス可能か。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, dirs] → Null
Claude Codeが参照可能なディレクトリリストをTaggingRulesに保存。
`NBSetAccessibleDirs[dirs]` で EvaluationNotebook[]に保存。

### NBGetAccessibleDirs[nb] → List
保存されたアクセス可能ディレクトリリスト。`NBGetAccessibleDirs[]` で EvaluationNotebook[]から。

### NBResolvePathRef[pathRef] → String | Missing[...]
PathRef(NBNormalizePathが返すAssociation、または`{"$onWork", ...}`形式)を現PCの実パスへ解決。解決不可ならMissing[...]。

### NBSetAccessiblePathRefs[nb, refs] → Null
AccessPathRefのリストをTaggingRules(claudeAccessiblePathRefs)に保存。各AccessPathRefは `<|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|>`。
`NBSetAccessiblePathRefs[refs]` で EvaluationNotebook[]に保存。

### NBGetAccessiblePathRefs[nb] → List
保存されたAccessPathRefリスト。旧claudeAccessibleDirsからのreadフォールバックあり。

### NBNormalizeAccessPathRef[dirOrRef] → Association
旧形式の絶対パス文字列または部分指定を完全なAccessPathRef Associationに正規化。文字列ならMode -> "Read"、CloudSend -> "Ask"既定。

### NBMoveToEnd[nb] → Null
ノートブックの末尾にカーソル移動。

## Job 管理 API

ClaudeQuery/ClaudeEvalの非同期出力位置管理。

### NBBeginJob[nb, evalCell] → jobId
評価セル直後に3つの不可視スロットセル(システム/完了/アンカー)を挿入。

### NBWriteSlot[jobId, slotIdx, cellExpr] → Null
ジョブのスロットにCell式を書き込み可視化。同スロット再書込で上書き。

### NBJobMoveToAnchor[jobId] → Null
アンカーセル直後にカーソル移動。

### NBEndJob[jobId] → Null
ジョブを正常終了。未書込スロットとアンカーを削除しテーブルをクリア。

### NBAbortJob[jobId, errorMsg] → Null
エラーメッセージを書き込みジョブを終了。

## 分離 API

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[]を内部取得しJobスロットを挿入。claudecodeがCellObject保持不要。

### NBExtractAssignments[text] → List
テキストからSet/SetDelayedのLHS変数名を抽出。

### NBSetConfidentialVars[assoc] → Null
機密変数テーブルを一括設定。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブル。

### NBClearConfidentialVars[] → Null
機密変数テーブルをクリア。

### NBRegisterConfidentialVar[name, level] → Null
機密変数を1つ登録(levelデフォルト1.0)。

### NBUnregisterConfidentialVar[name] → Null
機密変数を1つ解除。

### NBGetPrivacySpec[] → Association
現在の$NBPrivacySpec。

### NBInstallCellEpilog[nb, key, expr] → Null
ノートブックのCellEpilogに式を設定。keyは識別文字列。インストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Bool
CellEpilogがkeyでインストール済みか。

### NBEvaluatePreviousCell[nb] → Null
直前のセルを選択して評価。$NBAutoEvalProhibitedPatternsにマッチする場合はスキップして警告。

### NBInsertInputTemplate[nb, boxes] → Null
Inputセルテンプレートを挿入。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCellの親ノートブック。

## セル書き込み追加 API

### NBWriteCell[nb, cellExpr] → Null
ノートブックにCell式を書き込む(After既定)。
`NBWriteCell[nb, cellExpr, pos]` でpos(After/Before/All)指定。

### NBWritePrintNotice[nb, text, color] → Null
通知用Printセルを書き込む。nbがNoneならCellPrintを使用(同期In/Out間出力)。

### NBCellPrint[cellExpr] → Null
評価中のセル直後に出力セルを挿入(CellPrintラッパー)。カーソル位置非依存。

### NBWriteDynamicCell[nb, dynBoxExpr, tag] → Null
Dynamicセルを書き込む。tagが""でなければCellTagsを設定。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate] → Null
ExternalLanguageセル書き込み。autoEvaluateがTrueなら直前セルを評価。

### NBInsertAndEvaluateInput[nb, boxes] → Null
Inputセルを挿入して即座に評価。

### NBInsertInputAfter[nb, boxes] → Null
InputセルをAfterに書き込みBefore CellContentsに移動。

### NBWriteAnchorAfterEvalCell[nb, tag] → Null
EvaluationCell直後に不可視アンカーセルを書き込む。取得不可ならノートブック末尾。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol] → Null
機密変数追跡用CellEpilogをインストール。checkSymbolはFreeQチェック用マーカーシンボル。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Bool
機密追跡CellEpilogがインストール済みか。