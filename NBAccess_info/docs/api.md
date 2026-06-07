# NBAccess API リファレンス

NBAccess はセルインデックスベースでノートブックの読み書き・プライバシーフィルタリング・LLM連携・アクセス制御を提供するパッケージ。`BeginPackage["NBAccess`"]`。読込は UTF-8 で `Block[{$CharacterEncoding="UTF-8"}, Get["NBAccess.wl"]]`、または claudecode.wl 経由（エンコーディング自動処理）。

共通引数: `nb` は NotebookObject、`cellIdx` は1始まりのセルインデックス、`tag` は履歴/CellTags 文字列。PrivacySpec は `<|"AccessLevel" -> 0.5|>` 形式の Association。

## オプション
### PrivacySpec
NBAccess 関数のプライバシーフィルタリングオプション。`PrivacySpec -> <|"AccessLevel" -> 0.5|>`。AccessLevel ≤ セルのプライバシーレベルのセルのみアクセス可能。0.5: クラウドLLM安全データのみ(既定)、1.0: ローカルLLM環境など全データ。
### Decompress
NBAccess 履歴関数のオプション。True(既定): Diff差分を復元し平文で返す。False: Diffオブジェクトのまま返す(差分検査用)。System`Decompress をオプションラベルとして使用。

## グローバル変数
### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。ローカルLLM環境からは `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>`。
### $NBConfidentialSymbols
型: Association `<|"変数名" -> privacyLevel, ...|>`
秘密変数名とプライバシーレベルのテーブル。ClaudeCode が自動更新。
### $NBSendDataSchema
型: Bool, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMに送信するか制御。True: 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信。False: 一切送信しない。非秘密 Output は常にスマート要約付きで送信。
### $NBVerbose
型: Bool, 初期値: False
NBAccess 詳細ログ出力制御。True で内部詳細ログを Messages に出力。
### $NBAutoEvalProhibitedPatterns
型: List, 初期値: {}
NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト(RegularExpression/StringExpression)。マッチ時は評価スキップして警告。
### $NBSeparationIgnoreList
型: List
分離検査(ClaudeCheckSeparation)で無視するファイル名/パッケージ名のリスト。NBAccess と NotebookExtensions は既定登録済み。
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
### $NBRoutingThresholds
型: Association, 初期値: `<|"Cloud" -> 0.5, "Private" -> 0.8|>`
routing 閾値。score < Cloud → CloudLLM候補、Cloud ≤ score < Private → PrivateLLM候補、Private ≤ score → LocalOnly。
### $NBActivePolicySnapshot
型: Association|Missing
NBAcceptPolicySnapshot が Valid と判定した最新 snapshot を保持(主に subkernel 側)。参考情報であり実行判定の正本ではない。
### $ClaudePermissionMode
型: String, 初期値: "InteractiveSafe"
権限モード。"ReviewOnly"(提案のみ)/"StrictSafe"(AutoPermit のみ)/"InteractiveSafe"(標準、承認UI)/"WorkflowSafe"(Orchestrator)/"LegacyInteractive"/"DangerFullAccess"。実行中は accessSpec/snapshot に焼き込んだ値が正。
### $ClaudeAllowHardDenyOverride
型: Bool, 初期値: False
DangerFullAccess モードでのみ意味を持つ。True で HardDeny 相当を NeedsApproval へ昇格。
### $ClaudeOutputMode
型: String, 初期値: "Streaming"
出力モード。"Streaming"(逐次、既定)/"Batch"(集約)。BlockingRisk が MayBlockFrontEnd の出力は Streaming でも自動集約。
### $NBEffectClassOverrides
型: Association
head名 -> `<|EffectClass, BlockingRisk, ExecutionPlacement, RequiresFinalNode|>` の上書きテーブル。分類精度向上用(allowlist ではない)。
### $NBFinalActionAsyncActiveFunction
型: Function|Automatic, 初期値: Automatic
AsyncActive 判定の callback。Automatic で ClaudeRuntime ロード済みなら ClaudeRuntimeAsyncActiveQ、未ロードなら False。
### $NBLLMQueryFunc
型: Function
非同期 LLM 呼び出し用コールバック関数。ClaudeCode が ClaudeQueryAsync を自動登録。シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool, Integrations -> {...}]`。callback は応答文字列を受け取る関数、nb は出力先 NotebookObject。Integrations は LM Studio MCP 用(lmstudio モデル時のみ有効)。カーネルをブロックしない。

## セルユーティリティ API
### NBCellCount[nb] → Integer
ノートブックの全セル数。
### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックス。見つからない場合は 0。
### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリスト(セルブラケット選択またはカーソル位置)。
### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリスト。
### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリスト。`NBCellIndicesByStyle[nb, {style1, style2,...}]` で複数スタイル指定可。
### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルを全削除。
### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動。
### NBMoveToEnd[nb]
ノートブック末尾にカーソルを移動。
### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。
### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得。失敗時は NBCellExprToText にフォールバック。
### NBCellStyle[nb, cellIdx] → String
セルの CellStyle。
### NBCellLabel[nb, cellIdx] → String
セルの CellLabel(例: "In[3]:=")。ラベルなしは ""。
### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用。
### NBCellSetStyle[nb, cellIdx, style]
セルのスタイルを変更。Cell 式の第2引数を書換。TaggingRules 等の属性は保持。例: `NBCellSetStyle[nb, 3, "Input"]`
### NBCellWriteCode[nb, cellIdx, code]
既存セルにコードを BoxData + Input スタイルで書込。FEParser で構文カラーリング付き BoxData に変換。例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`
### NBCellWriteText[nb, cellIdx, newText]
セルのテキスト内容を newText に置換。スタイル・TaggingRules・オプションは保持。
### NBSelectCell[nb, cellIdx]
セルブラケットを選択状態にする。パレット操作後のセル選択復元用。
### NBResolveCell[nb, cellIdx] → CellObject
CellObject を返す。無効インデックスは $Failed。
### NBCellGetTaggingRule[nb, cellIdx, path] → value
TaggingRules のネスト値を返す。例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`
### NBCellSetTaggingRule[nb, cellIdx, path, value]
セルの TaggingRules にネスト値を設定。例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`
### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存。
### NBCellHasImage[cellExpr] → Bool
Cell 式が画像(RasterBox/GraphicsBox)を含むか判定。cellExpr は NBCellRead の戻り値。

## LLM 連携 API
### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可は ""。
### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換。promptFn はセルテキストを受けプロンプト文字列を返す。completionFn は結果 Association を受けるコールバック(エラー時は $Failed)。カーネルをブロックしない。セルのプライバシーレベルに応じて LLM 自動選択。
→ カーネルブロックなし(非同期)
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使う入力テキスト), Integrations -> Automatic (LM Studio MCP サーバリスト、lmstudio モデル時のみ)
completionFn が受ける Association: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API
### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル(0.0〜1.0)。0.0: 非秘密、1.0: 秘密(Confidentialマーク or 秘密変数参照)。
### NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] → Bool
セルが指定 PrivacySpec でアクセス可能か。
### NBFilterCellIndices[nb, indices, PrivacySpec -> ps] → List
セルインデックスリストを PrivacySpec でフィルタリング。

## テキスト抽出 API
### NBCellExprToText[cellExpr] → String
NotebookRead の結果(Cell式)からテキスト抽出。
### NBCellToText[nb, cellIdx] → String
セルのテキスト内容。
### NBGetCells[nb, PrivacySpec -> ps] → List
ノートブック内全セルインデックスを PrivacySpec でフィルタして返す。
### NBGetContext[nb, afterIdx, PrivacySpec -> ps] → String
afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築。PrivacySpec でフィルタ。既定 AccessLevel 0.5。

## 書き込み API
### NBWriteText[nb, text, style]
ノートブックにテキストセルを書込。style 既定 "Text"。
### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書込。
### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセル書込。
### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろに Input セルを挿入しカーソルをセル先頭に移動。autoEvaluate が True なら SelectionEvaluate も行う。
### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル(name)と Text セル(prompt)を挿入して保存・閉じる。

## ファイル型ノートブック操作 API
閉じた .nb ファイル対象の読み書き。秘匿セルの有無に関わらず必ずこの API を経由する。上位層から .nb を直接 NotebookOpen/NotebookGet してはならない。
### NBFileOpen[path] → NotebookObject
.nb を非表示(Visible->False)で開く。失敗時 $Failed。必ず NBFileClose で閉じる。例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`
### NBFileClose[nb]
NBFileOpen で開いたノートブックを閉じる。
### NBFileSave[nb, path]
開いているノートブックを指定パスに保存。path が None なら上書き保存。
### NBFileReadCells[nb, PrivacySpec -> ps] → List
全セルを PrivacySpec でフィルタし `{<|cellIdx, style, text, privacyLevel|>, ...}` を返す。privacyLevel > PrivacySpec の秘匿セルは text を "[CONFIDENTIAL]" に置換。
### NBFileReadAllCells[nb] → List
全セルをアクセスレベル別に分類して返す。秘匿セルも含む全セルを返すが PrivacyLevel フィールドで識別可。ローカルモデル処理用。
### NBFileWriteCell[nb, cellIdx, newText]
指定セルのテキストを newText で置換。スタイル・TaggingRules・秘匿マーク等は保持。
### NBFileWriteAllCells[nb, replacements]
`{cellIdx -> newText, ...}`(Association または List)に従い複数セルを一括置換。
### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevel が lo〜hi のセルのみ返す。例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]`(公開セル)、`NBFileReadCellsInRange[nb2, 0.9, 1.0]`(秘匿セル)
### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb のセルを PrivacyLevel ≤ threshold(public)と > threshold(private)に2分割。
### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
2つの `<|cellIdx->newText|>` を元セル順にマージして outputPath に保存。

## ObjectSpec API
### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を返す。PrivacyLevel: <0.5=クラウドLLM可、>=0.5=ローカルのみ、{0.5,1.0}=混在(.nb)。
### NBFileSpecCacheClear[]
NBFileSpec の base/projection キャッシュをクリア。
### NBNormalizePath[path] → Association
絶対パスを複数PC間で安定なシンボリックパス情報の Association に正規化。戻り値キー: "Kind","RootId","Parts","SymbolicPath","PhysicalPath","ResolutionStatus","MatchedBy"。ResolutionStatus: "ResolvedOnThisPC"|"AliasOnly"|"Unrooted"。MatchedBy: "LocalRoot"|"Alias"|"None"。戻り値は同一性のための情報でありアクセス権限を与えない(権限判定は PhysicalPath を現PCで解決・実在確認した上で行う、rule 104)。
### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。例: `NBValueSpec[dataset, 1.0]`
### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5 -> {"cloud"}, 1.0 -> {"local"}, {0.5,1.0} -> {"cloud","local"}

## セルマーク API
### NBGetConfidentialTag[nb, cellIdx] → True|False|Missing[]
TaggingRules から機密タグを返す。
### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val(True/False)に設定。
### NBMarkCellConfidential[nb, cellIdx, opts]
セルを機密(PrivacyLevel 1.0)に設定し赤背景マークを付ける。`NBMarkCellConfidential[nb, cellIdx, level]` で PrivacyLevel を任意の数値(0.0-1.0)に設定。level > 0.5 で赤背景マーク、≤0.5 でマーク除去。$NBApprovalHeads 登録済み(実行時に承認ゲート発火)。
→ Options: PrivacySpec -> Automatic
### NBSetSnapshotPrivacyLevel[snapshotId, level, opts]
SourceVault snapshot の PrivacyLevel を設定。人間が明示的に上書きしたい場合に使用。SourceVault ロード必須。$NBApprovalHeads 登録済み。
→ Options: PrivacySpec -> Automatic
### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク(橙背景 + LockIcon)を付ける。機密変数に依存する計算結果など間接的に機密なセルに使用。
### NBUnmarkCell[nb, cellIdx]
セルの機密マーク(視覚・タグ)をすべて解除。

## セル内容分析 API
### NBCellUsesConfidentialSymbol[nb, cellIdx] → Bool
セルが機密変数を参照しているか。
### NBCellExtractVarNames[nb, cellIdx] → List
セル内容から Set/SetDelayed の LHS 変数名を抽出。
### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容から Confidential[] 内の代入先変数名を抽出。
### NBShouldExcludeFromPrompt[nb, cellIdx] → Bool
セルがプロンプトから除外すべきか。
### NBIsClaudeFunctionCell[nb, cellIdx] → Bool
セルが Claude 関数呼び出しセルか。
### NBExtractAssignments[text] → List
テキストから Set/SetDelayed の LHS 変数名を抽出。

## 依存グラフ API
### NBCellToInputText (NBAccess`iCellToInputText)[cell] → String
FrontEnd経由でセルの InputText 形式を取得。失敗時 NBCellExprToText フォールバック。
### NBBuildVarDependencies[nb] → Association
Input セルを解析し変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返す。文字列リテラル内の識別子は除外。
### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査し統合された依存グラフを返す。LLM 呼び出し直前の精密チェック用。通常は軽量版 NBBuildVarDependencies[nb] を使う。
### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存依存グラフに CellLabel In[x] (x > afterLine) のセルのみ追加走査してマージ。インクリメンタル版。
### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。
### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新規マーク数を返す。`NBScanDependentCells[nb, confVarNames, deps]` で事前計算済みグラフを使う。Claude 関数呼び出しセルは除外。
### NBFilterHistoryEntry[entry, confVars] → entry|Nothing
履歴エントリ内の response/instruction に現時点の機密変数名/値が含まれる場合そのフィールドをブロック。confVars は現在の機密変数名リスト。
### NBDependencyEdges[nb] → List
変数依存関係をエッジリストで返す。`{DirectedEdge["dep", "var"], ...}`("dep"→"var" は var が dep に依存)。`NBDependencyEdges[nb, confVars]` で機密変数関連エッジのみ。
### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print 表示するデバッグ関数。
### NBPlotDependencyGraph[nb, opts]
依存グラフをプロット。`NBPlotDependencyGraph[]` は全ノートブック統合(既定)。ノードは変数名・Out[n]、直接秘密は赤、依存秘密は橙。NB内エッジは濃い実線、クロスNBエッジは薄い破線。
→ Graphics
Options: "Scope" -> "Global"(既定)|"Local", PrivacySpec -> `<|"AccessLevel" -> 1.0|>`
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

## 関数定義解析
### NBGetFunctionGlobalDeps[nb] → Association
全関数定義を解析し各関数が依存する大域変数のリストを返す。`<|"関数名" -> {"大域変数1",...}, ...|>`。パラメータ変数とスコーピング局所変数(Module/Block/With/Function)は除外。

## 機密変数テーブル API
### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定。assoc: `<|"varName" -> True, ...|>`
### NBGetConfidentialVars[] → Association
現在の機密変数テーブル。
### NBClearConfidentialVars[]
機密変数テーブルをクリア。
### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録(level 既定 1.0)。
### NBUnregisterConfidentialVar[name]
機密変数を1つ解除。
### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

## ノートブック TaggingRules API
### NBGetTaggingRule[nb, key] → value|Missing[]
ノートブックの TaggingRules から key の値。`NBGetTaggingRule[nb, {key1, key2,...}]` でネストパス指定可。
### NBSetTaggingRule[nb, key, value]
TaggingRules に key -> value を設定。`NBSetTaggingRule[nb, {key1, key2}, value]` でネストパス可。
### NBDeleteTaggingRule[nb, key]
TaggingRules から key を削除。
### NBListTaggingRuleKeys[nb] → List
TaggingRules の全キー。`NBListTaggingRuleKeys[nb, prefix]` で prefix で始まるキーのみ。
### NBSetNotebookDefaultModel[nb, provider, modelName]
ノートブックのデフォルトモデル(claudecode パレット設定 paletteProvider/paletteModelName)を書換。
### NBGetNotebookDefaultModel[nb] → {provider, modelName}|Missing["NotDeclared"]
ノートブックのデフォルトモデル。

## 汎用履歴データベース API
### NBHistoryData[nb, tag, opts] → Association
TaggingRules から履歴データを読取り差分復元。戻り値: `<|"header" -> <|...|>, "entries" -> {<|...|>,...}|>`
Options: Decompress -> True (False で Diff オブジェクトのまま)
### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せず履歴データを返す(内部用)。
### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書込。data は `<|"header"->..., "entries"->{...}|>`。entries は平文で渡す(自動圧縮)。
### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加。差分圧縮: 直前エントリの fullPrompt/response/code を Diff 圧縮。
Options: PrivacySpec -> ps (privacylevel をエントリに記録)
### NBHistoryEntries[nb, tag, opts] → List
差分復元した全エントリリスト。Options: Decompress -> True
### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新。updates は `<|"response"->..., "code"->...|>`。
### NBHistoryReadHeader[nb, tag] → Association
履歴ヘッダーを返す。
### NBHistoryWriteHeader[nb, tag, header]
履歴ヘッダーを書込。
### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリ。header の parent/inherit/created で親チェーンを辿る。Options: Decompress -> True
### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧。
### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除。
### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換(コンパクション/バッチ更新用)。
### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新(既存上書き、新規追加)。
### NBHistoryCreate[nb, tag, diffFields] → header
新しい履歴データベースを作成。diffFields は差分圧縮対象フィールド名リスト(例: {"fullPrompt","response","code"})。`NBHistoryCreate[nb, tag, diffFields, headerOverrides]` でヘッダー上書き可。既存 DB に diffFields がある場合は既存ヘッダーを返す(冪等)。

## セッションアタッチメント API
### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチ(ヘッダーの "attachments" リストに追加、重複除去)。
### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチ。
### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリスト。
### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリア。
### NBHistoryClearAll[nb, prefix, PrivacySpec -> ps]
prefix で始まる全履歴を削除。PrivacySpec -> `<|"AccessLevel" -> 1.0|>` 必須。セルレベルの機密タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。

## API キーアクセサ
### NBGetAPIKey[provider, opts] → String
AI プロバイダの API キーを返す。provider: "anthropic"|"openai"|"github"。AccessLevel >= 1.0 必須。呼び出し側で PrivacySpec -> `<|"AccessLevel" -> 1.0|>` を明示指定。SystemCredential へのアクセスを一元管理。
### NBListProviderModels[provider] → Association
クラウドプロバイダ(anthropic/openai)の利用可能モデル ID リストを返す。API キーは内部で読み外部に出さない。PrivacySpec 不要。戻り値: `<|"Status" -> _, "Provider" -> _, "Models" -> {_String..}|>`

## ローカル LLM サーバ API キー
### NBGetLocalLLMAPIKey[provider, url, opts] → String
ローカル LLM サーバ(LM Studio 等)の API キーを SystemCredential から返す。照合は {provider, url} ペア。AccessLevel >= 1.0 必須。解決優先度: (1)完全一致 (2)localhost↔127.0.0.1 置換版 (3){provider,"*"} ワイルドカード (4)フォールバック名 `ToUpperCase[provider]<>"_API_KEY"`。例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`
### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録(実値は書き込まない)。戻り値: `{provider, normalizedUrl} -> credentialName`
### NBStoreLocalLLMAPIKey[provider, url, credentialName, key]
上記マッピング登録に加え SystemCredential[credentialName] = key も設定。初回セットアップ用。
### NBRemoveLocalLLMAPIKey[provider, url]
{provider, url} のエントリを削除(SystemCredential 本体は変更しない)。
### NBLocalLLMAPIKeyMap[] → Dataset
登録済みローカル LLM サーバ→API キー名マッピングを Dataset で返す。Configured 列は SystemCredential 設定済みか示す。
### NBLocalLLMCredentialName[provider, url] → String
SystemCredential 名のみを返す(値は取得しない)。AccessLevel チェックなし。

## フォールバックモデル / プロバイダーアクセスレベル API
### NBSetFallbackModels[models]
フォールバックモデルリストを設定。models: `{{"provider","model"}, {"provider","model","url"}, ...}`。例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`
### NBGetFallbackModels[] → List
フォールバックモデルリスト全体。
### NBRegisterTrustedLocalServer[assoc]
信頼できるローカル LLM サーバを登録。assoc: `<|"MachineName"->_, "Subnet"->_, "Provider"->_, "URL"->_|>`。モデル名は含めない。起動ファイルから呼ぶ。
### NBResolveLocalServer[] → Association
現在のマシン環境($MachineName と自IPのサブネット)を信頼リストと照合し、信頼できるローカル LLM サーバ `<|"Provider"->_, "URL"->_, "Trusted"->_, ...|>` を返す。未知サブネットでは localhost(127.0.0.1)のみ返す。モデル名は返さない。
### NBTrustedLocalServers[] → Dataset
登録済み信頼ローカルサーバのリスト。
### NBSyncClaudeModelVars[opts]
SourceVault にキャッシュされたモデルで ClaudeCode の $ClaudeModel/$ClaudeDocModel/$ClaudePrivateModel/$ClaudeFallbackModels を更新。SourceVault 未ロードなら何もしない。SourceVault ロード時に自動実行。
Options: Verbose -> False
### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベル(0.0〜1.0)を設定。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`, `NBSetProviderMaxAccessLevel["lmstudio", 1.0]`
### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベル。未登録は 0.5。
### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルリスト。MaxAccessLevel >= accessLevel のモデルのみ。例: `NBGetAvailableFallbackModels[0.8]` → lmstudio のみ
### NBProviderCanAccess[provider, accessLevel] → Bool
プロバイダーが指定アクセスレベルのデータにアクセス可能か(MaxAccessLevel >= accessLevel)。
### NBModelCanHandleAccessLevel[modelSpec, accessLevel] → Bool
モデル指定がそのアクセスレベルのデータを扱えるか。Private ノート(1.0)でクラウドモデル(0.5)を拒否、ローカルLLM(1.0)のみ通す。modelSpec: {provider, model}|{provider, model, url}|"model"|Automatic(未指定は True)。
### NBModelProviderName[modelSpec] → String
modelSpec から provider 文字列を取り出す。
### NBNotebookRequiredAccessLevel[nb] → Real
ノートブックが要求するアクセスレベル。Private 宣言(CloudPublishable -> False)なら 1.0、それ以外 0.0。

## アクセス可能ディレクトリ API
### NBSetAccessibleDirs[nb, {dir1, dir2,...}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存。`NBSetAccessibleDirs[{...}]` で EvaluationNotebook[] 対象。
### NBGetAccessibleDirs[nb] → List
保存済みアクセス可能ディレクトリリスト。`NBGetAccessibleDirs[]` で EvaluationNotebook[]。
### NBResolvePathRef[pathRef] → String|Missing
PathRef(NBNormalizePath が返す Association、または `{"$onWork", ...}` 形式のシンボリックパスリスト)を現PCの実パスへ解決。解決でき実在すれば絶対パス文字列、できなければ Missing[...]。rule 104: alias-only/root-missing な PathRef は実パスに解決されない。
### NBSetAccessiblePathRefs[nb, refs]
AccessPathRef のリストを TaggingRules(claudeAccessiblePathRefs)に保存。`NBSetAccessiblePathRefs[refs]` で EvaluationNotebook[]。各 AccessPathRef は `<|"PathRef"->_, "Mode"->"List"|"Read"|"ReadWrite", "CloudSend"->False|True|"Ask"|>`。claudeAccessiblePathRefs が canonical、旧 claudeAccessibleDirs は read fallback。
### NBGetAccessiblePathRefs[nb] → List
保存済み AccessPathRef リスト。`NBGetAccessiblePathRefs[]` で EvaluationNotebook[]。旧 notebook では claudeAccessibleDirs を AccessPathRef に変換して返す(read fallback)。
### NBNormalizeAccessPathRef[dirOrRef] → Association
旧形式の絶対パス文字列または部分指定を完全な AccessPathRef Association に正規化。文字列は NBNormalizePath で PathRef 化し Mode->"Read", CloudSend->"Ask" を既定とする。

## Job 管理 API
ClaudeQuery/ClaudeEval の非同期出力位置管理。
### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入し jobId を返す。evalCell が CellObject でない場合はノートブック末尾に挿入。スロット1: システムメッセージ、スロット2: 完了メッセージ、アンカー: レスポンス書込位置マーカー。
### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[] を内部取得してその直後に Job スロットを挿入(claudecode が CellObject を保持する必要がない)。
### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書込み可視化。同じスロットに再書込で上書き。
### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動。レスポンス書込前に呼ぶ。
### NBEndJob[jobId]
ジョブを正常終了。未書込スロットとアンカーを削除しテーブルをクリア。
### NBAbortJob[jobId, errorMsg]
エラーメッセージを書込みジョブを終了。

## 分離API: CellEpilog / 評価
### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定。key は識別用文字列。インストール済みなら何もしない。
### NBCellEpilogInstalledQ[nb, key] → Bool
CellEpilog が key で既にインストール済みか。
### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価。
### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入。
### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブック。
### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストール。checkSymbol は FreeQ チェック用のマーカーシンボル。インストール済みなら何もしない。
### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Bool
機密追跡 CellEpilog がインストール済みか。

## セル書き込み / 出力遅延 API
### NBWriteCell[nb, cellExpr]
ノートブックに Cell 式を書込(After)。`NBWriteCell[nb, cellExpr, pos]` で pos(After/Before/All)指定可。遅延出力有効時の After 書込はバッファに溜め NBFlushDeferredOutput で一括出力。
### NBBeginDeferredOutput[]
出力遅延(集約)モードを有効化。以降 NBWriteCell(After)は即書きせずバッファに溜める。非同期並列処理やブロック回避時に使う。
### NBEndDeferredOutput[]
出力遅延モードを無効に戻す(バッファは残るので NBFlushDeferredOutput で出力)。
### NBFlushDeferredOutput[nb] → Integer
溜めた Cell を一括書込みバッファをクリア。戻り値: 出力した Cell 数。FrontEnd 操作なのでメインカーネル評価で呼ぶ。`NBFlushDeferredOutput[]`(nb 省略)は CellPrint で出力。
### NBDeferredOutputActiveQ[] → Bool
出力遅延モードが有効か。
### NBDeferredOutputCount[] → Integer
バッファに溜まっている Cell 数。
### NBDiscardDeferredOutput[]
バッファをフラッシュせず破棄。
### NBWritePrintNotice[nb, text, color]
通知用 Print セルを書込。nb が None なら CellPrint を使用(同期 In/Out 間出力)。
### NBCellPrint[cellExpr]
評価中のセル直後に出力セルを挿入(CellPrint ラッパー)。カーソル位置に依存せず常に EvaluationCell 直後に配置。
### NBWriteDynamicCell[nb, dynBoxExpr, tag]
ノートブックに Dynamic セルを書込。tag が "" でなければ CellTags を設定。
### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書込。autoEvaluate が True なら直前セルを評価。
### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価。
### NBInsertInputAfter[nb, boxes]
Input セルを After に書込み Before CellContents に移動。
### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書込。EvaluationCell が取得できない場合は末尾に書込。

## 分離API: 設定
### NBSetNotebookPrivate[nb]
ノートブック全体を Private(CloudPublishable -> False)宣言し全セルの PrivacyLevel を 1.0 にしてクラウド LLM への投入を禁止。ライブの NotebookObject に即時反映。保存済みなら NBSetCloudPublishable でファイルヘッダにも永続化。`NBSetNotebookPrivate[nb, False]` で解除。`NBSetNotebookPrivate[]` で EvaluationNotebook[]。

## Allowed Expression Surface & Runtime Integration (Phase 7)
### NBValidateHeldExpr[heldExpr, accessSpec, opts] → Association
HoldComplete[...] 式を Allowed Expression Surface に照合し AccessDecision を返す。戻り値: `<|"Decision" -> "Permit"|"Deny"|"NeedsApproval"|"RepairNeeded", ...|>`
### NBExecuteHeldExpr[heldExpr, accessSpec, opts] → Association
検証済み式を安全に実行。戻り値: `<|"Success" -> True/False, "RawResult" -> ..., "Error" -> ...|>`
### NBTryExecuteFinalActionHeld[held, accessSpec, opts] → Association
承認 wrapper(NBOpenFolderWithApproval 等)を head の context に依存せず(SymbolName で検出)安全評価し OpenDesktopItem action に正規化、NBExecuteApprovedAction 経由で実行。対象外なら `<|"Handled" -> False|>`。
### NBResolveDesktopActionPath[held, accessSpec] → Association
desktop action wrapper からパスを安全解決・検証のみ行う(SystemOpen は呼ばない)。戻り値: `<|"IsDesktopAction"->.., "Validated"->.., "Path"->..|>`
### NBRedactExecutionResult[result, accessSpec, opts] → Association
実行結果を redact して安全な形で返す。accessSpec に "ConfidentialLineNumbers" -> {n,...} があれば Out[n]/In[n]/InString[n]/% 経由の機密参照もスキー化。戻り値: `<|"RedactedResult"->..., "Summary"->String|>`
### NBConfidentialLineNumbers[nb, accessSpec] → List
機密・機密依存 Input/Code/Output セルの評価行番号リスト(In[n] と Out[n] は同一 n)。
### NBMakeContextPacket[nb, accessSpec, opts] → Association
notebook から安全な context packet を構築。戻り値: `<|"Input"->..., "Cells"->..., "AccessSpec"->..., ...|>`
### NBRouteDecision[scoreOrAccessSpec] → Association
数値スコアまたは accessSpec から routing 推奨(advisory)を返す。戻り値: `<|"Route" -> "CloudLLM"|"PrivateLLM"|"LocalOnly", "EffectiveRiskScore" -> n, "Thresholds" -> ..., "Reason" -> String|>`

## Iterative Agent Loop Support (Phase 14)
### NBInferExprRequirements[heldExpr, accessSpec] → Association
式が必要とするアクセスレベル・書込ターゲット・参照セル等を静的推定。戻り値: `<|"ReadCells"->{...}, "WriteCells"->{...}, "RequiredAccessLevel"->n, "HasSideEffects"->True/False, ...|>`
### NBReleaseResult[result, accessSpec, opts]
実行結果を指定 sink に安全に release(redaction + routing check)。
### NBMakeRetryPacket[failureAssoc, accessSpec] → Association
失敗情報から秘密を含まない安全な retry packet を構築。
### NBMakeFileAccessRequest[pathOrSpec, operation, opts] → Association
file 用 AccessRequest Association を組み立てる helper。operation: "ReadValue"|"WriteCell"|"WriteLog"|"SendExternal" 等。Sink/Networked/Route/Provider/AccessLevel は operation から既定が決まる(オプションで上書き可)。
### NBAuthorizeFile[pathOrSpec, req] → Association
NBFileSpec/file spec を NBAuthorize に渡す adapter。pathOrSpec が文字列なら NBFileSpec で base spec 取得、Association ならそのまま。
### NBPermitQ[decision] → Bool
NBAuthorize の AccessDecision を Boolean に落とす fail-closed helper。"Permit" のときだけ True。Deny/Screen/RequireApproval/$Failed/Missing/例外はすべて False。
### NBDefaultFilePolicyLabel[spec] → label
初期 placeholder file policy label。
### NBNoExtraContainerLabel[] → label
初期 placeholder container label。
### NBAuthorize[obj, req] → Association
PolicyGate + ScoreGate + EnvironmentGate を統合した AccessDecision。戻り値: `<|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval", "ReasonClass"->..., "RequiredAction"->..., "VisibleExplanation"->..., "RouteAdvice"->...|>`
### NBPolicyGate[obj, req] → Association
半順序ラベルに基づく flow 判定。PolicyLabel/ContainerLabel/SinkLabel を考慮。
### NBScoreGate[obj, req] → Association
数値スコアに基づく routing/screening 判定(advisory)。
### NBEnvironmentGate[obj, req] → Association
実行環境に基づく制約チェック。Sink/Environment/Principal を考慮。

## Function Security (Phase 20)
### NBRegisterFunctionSecurity[sym, spec]
関数 sym にセキュリティメタデータを登録。spec: `<|"DefinitionLabel"->label, "ExecPolicy"->"Open"|"Guarded"|"Denied", "ReleasePolicy"-><|...|>|>`
### NBFunctionDefinitionLabel[f] → label
関数 f の定義ラベル(コード閲覧可否を制御)。
### NBFunctionExecPolicy[f] → String
関数 f の実行ポリシー。"Open"|"Guarded"|"Denied"
### NBFunctionReleasePolicy[f] → Association
関数 f の結果リリースポリシー。
### GuardedApply[req, f, args] → result
f[args] をセキュリティポリシーに従って実行。ExecPolicy が "Guarded" の場合 flow チェック後に実行し結果に適切なラベルを付与。
### Declassify[obj, req, releaseSpec] → obj
obj のラベルを releaseSpec に従って引き下げ。req の Principal が acts-for 権限を持つ場合のみ許可。

## Label Algebra
### NBLabelQ[label] → Bool
label が有効な NBAccess ラベルか。
### NBLabelBottom[] → label
最小制約ラベル(public)。
### NBLabelTop[] → label
最大制約ラベル(全拒否)。
### NBLabelJoin[l1, l2] → label
ラベルの join(より制約的、両方の制約を満たす方向)。
### NBLabelMeet[l1, l2] → label
ラベルの meet(より緩い)。
### NBLabelLEQ[l1, l2] → Bool
l1 ⪯ l2(l1 の情報が l2 へ flow 可能)か判定。
### NBRegisterPrincipal[name, opts]
アクセス主体を登録。
### NBGrantActsFor[p, q]
principal p が q として行動できる委任を登録。
### NBActsForQ[p, q] → Bool
p が q として行動可能か。
### NBCanFlowToQ[srcLabel, dstLabel] → Bool
src から dst への flow が許可されるか。
### NBCanDeclassifyQ[srcLabel, dstLabel, req] → Bool
declassify が正当か。
### NBEffectiveLabel[obj, req] → label
オブジェクトと要求から実効ラベルを計算。
### NBEnableCategory[cat]
カテゴリを有効化。
### NBDisableCategory[cat]
カテゴリを無効化。
### NBCategoryEnabled[cat] → Bool
カテゴリが有効か。

## Notebook semantic access (閉じたファイル, Phase 9)
FrontEnd 不要。ファイル直接経路(Import["Notebook"]/Export["NB"])で closed notebook 操作。AccessSpec Association で RBAC 制御。CellGroupData ネストも再帰展開。
### NBReadHeader[path, opts] → Association
notebook の SourceVault ヘッダーを抽出。対象: TaggingRules > "SourceVault" または Header style cell、Input cell 内 BoxData(生 Association)。
Options: "AccessSpec" -> `<|"AccessLevel" -> 0.5, ...|>`
戻り値: `<|"Status"->"OK"|"Failed", "Keywords"->{...}, "Status"->_, "Deadline"->_, "NextReview"->_, "Owner"->_, "PathHint"->_, "RawHeader"-><|...|>, "Source"->"TaggingRules"|"HeaderCell"|"BoxData"|"None"|>`
### NBReadTodos[path, opts] → Association
notebook の Todo cell を全抽出。対象: Item style cell、または TaggingRules > "SourceVault" で TodoStatus 設定済。
Options: "AccessSpec" -> `<|"AccessLevel" -> 0.5, ...|>`
戻り値: `<|"Status"->"OK"|"Failed", "Todos"->{<|"Index"->n, "Text"->..., "Status"->"Open"|"Done"|"Pass", "CellPath"->{_Integer...}, "StatusSource"->..., "ExpressionUUID"->_String|_Missing|>...}|>`
### NBFindCellByPredicate[path, predicate, opts] → Association
predicate が True を返す cell を返す。predicate: Cell expr を受け True/False を返す Function。
Options: "AccessSpec" -> `<|...|>`, "MaxResults" -> All|_Integer
戻り値: `<|"Status"->"OK"|"Failed", "Matches"->{<|"CellIndex"->n, "CellPath"->{...}, "Cell"->HoldComplete[Cell[...]], "Style"->_, "ExpressionUUID"->_|>...}|>`
### NBSetCellOptionsByPredicate[path, predicate, optionRules, opts] → Association
predicate が True の cell の options を optionRules で上書き。optionRules 例: `{FontVariations->{"StrikeThrough"->True}, FontColor->RGBColor[0,0.5,0]}`
Options: "AccessSpec" -> `<|"AccessLevel"->0.7|>` (書込に >= 0.7 必要、既定 0.7), "DryRun" -> True (既定), "MaxResults" -> All
戻り値: `<|"Status"->"OK"|"Failed"|"DryRunOK", "Modified"->{<|"CellPath"->..., "Before"->..., "After"->...|>...}, "DryRun"->_Boolean, "AccessLevel"->_Real|>`
### NBSetCellTaggingRuleByPredicate[path, predicate, taggingKeyPath, value, opts] → Association
predicate が True の cell の TaggingRules 内 key パスを value で設定。例: taggingKeyPath = `{"SourceVault", "TodoStatus"}`, value = "Done"。Options/戻り値は NBSetCellOptionsByPredicate と同形。
### NBWriteHeader[path, key, value, opts] → Association
notebook の SourceVault ヘッダー1フィールドを更新(TaggingRules > SourceVault 配下に key -> value マージ)。key: "Status"/"Keywords"/"Deadline"/"NextReview"/"Owner"/"PathHint" 等。
Options: "AccessSpec" -> `<|"AccessLevel"->0.7|>` (既定 0.7), "DryRun" -> True (既定)
戻り値: `<|"Status"->"OK"|"Failed"|"DryRunOK", "Before"->_, "After"->_, "DryRun"->_Boolean, "Path"->_String|>`
### NBWriteTodoStatus[path, todoKey, newStatus, opts] → Association
todoKey で特定される Todo cell の Status を変更。todoKey: `<|"Index"->n, "Text"->"..."|>`(両方一致する cell のみ編集)。newStatus: "Open"/"Done"/"Pass"。変更内容: FontVariations StrikeThrough on/off + FontColor(緑/灰)+ TaggingRules SourceVault TodoStatus。
Options: "AccessSpec" -> `<|"AccessLevel"->0.7|>` (既定 0.7), "DryRun" -> True (既定)
戻り値: `<|"Status"->..., "MatchedTodo"-><|"Index"->..., "Text"->...|>, "OldStatus"->_, "NewStatus"->_, "CellPath"->{...}|>`

## CloudPublishable (Phase 9 拡張)
### NBGetCloudPublishable[path] → True|False|Missing
ノートブック自身のクラウド公開宣言を読取(TaggingRules > SourceVault > "CloudPublishable")。戻り値: True(クラウド可)/False(クラウド禁止)/Missing["NotDeclared"](宣言なし、既定はパスベース判定にフォールバック)/Missing["NoHeader"|"NoRawHeader"](内部エラー)。
### NBSetCloudPublishable[path, True|False, opts] → Association
クラウド公開宣言を設定。設定後セル機密チェックと組み合わさり NBFileSpec の PrivacyLevel が 0.4/0.5/1.0/{0.5,1.0} に自動決定。
Options: "AccessSpec" -> `<|"AccessLevel"->0.7|>` (既定 0.7), "DryRun" -> False (既定、トグル操作)
戻り値: NBWriteHeader と同形
### NBClearCloudPublishable[path, opts] → Association
クラウド公開宣言を「未指定」に戻す(CloudPublishable キー削除、空になれば SourceVault キー/TaggingRules もクリーンアップ)。
Options: "AccessSpec" -> `<|"AccessLevel"->0.7|>` (既定 0.7), "DryRun" -> False (既定)
戻り値: `<|"Status"->"OK"|"DryRunOK"|"Failed", "Before"->True|False|Missing["NotPresent"], "After"->Missing["Removed"|"NotPresent"], "NoOp"->True, "Path"->_String|>`

## Notebook cache repair (Phase 9)
### NBRepairNotebookCache[path] → Association
.nb の outline cache を正規化。「Wolfram システム外で編集されたようです」ダイアログが繰り返す .nb をクリーンアップ。frontend 経由 NotebookSave でヘッダのバイト位置キャッシュ再生成。内容は変わらない。戻り値: `<|"Status"->"OK"|"Failed", "Path"->_String, "WasAlreadyOpen"->True|False|>`
### NBRepairNotebookCacheFolder[dir, opts] → Association
dir 配下の .nb を全修復。
Options: "Recursive" -> True (既定)
戻り値: `<|"Status", "Directory", "TotalFiles", "Succeeded", "Failed", "Details"|>`
### NBCleanupTmpFiles[dir, opts] → Association
dir 配下の .nb.tmp-* 残骸を削除。
Options: "Recursive" -> True (既定)
戻り値: `<|"Status", "Directory", "Deleted", "Files"|>`
### NBRepairNotebookCacheStrict[path] → Association
NBRepairNotebookCache が効果なかった場合の強力版 fallback。NotebookImport で読み CreateDocument で新ノート作成、NotebookSave で元パスに上書き。帯同オプション(TaggingRules等)も取込。実行前に既に開かれているノートは閉じられる。戻り値: `<|"Status"->"OK"|"Failed", "Path", "Method"->"RecreateAndSave"|>`

## Codex audit
### NBAuditCodexAccessibleDirs[dirs, opts] → Association|Failure
ChatGPT Codex に晒すディレクトリを、Codex プロバイダ最大アクセスレベルを超えうるファイル(.env, *secret*, *credential*, *token*, 秘密鍵, API-key 様内容)について監査。Codex 権限プロファイル生成前の必須ゲート。既定は fail-stop(危険ファイル発見で Failure を返す)。
Options: "MaxDepth" -> Infinity (有限値で未走査部分があると fail-closed), "OnDanger" -> "Fail" (既定)|"DenyAndContinue", "ScanContents" -> True, "MaxFileScanBytes" -> _
戻り値(pass/continue 時): `<|"Status", "Gate", "Findings", "AuditedDirs", "FileCount", "Truncated", "SuggestedDenyRules"|>`

## Policy Snapshot / Runtime async (Phase A1)
### NBPolicySnapshot[] → Association
現在の NBAccess 動的 policy(導出済み AllowedHeads, ApprovalHeads, DenyHeads, ConfidentialSymbols)を凍結。キー: "SnapshotID","CreatedAt","NBAccessPolicyVersion","AllowedHeads","ApprovalHeads","DenyHeads","ConfidentialSymbols","Digest","Source"。
### NBAcceptPolicySnapshot[snapshot] → Association
snapshot の必須キーと Digest を検証。戻り値: `<|"Valid"->True|False, "Digest"->_, "Reason"->_|>`。Valid のとき subkernel 内 $NBActivePolicySnapshot に保存可だが実行判定の正本は accessSpec["PolicySnapshot"]。
### NBApplyPolicySnapshot[snapshot] → Association
snapshot の digest を検証し正規化した snapshot を返す(global 復元はせず accessSpec 注入の補助に限定)。戻り値: `<|"Valid"->_, "Snapshot"->_, "Reason"->_|>`
### NBValidateNotebookPreActions[actions, accessSpec] → List
PreExecutionNotebookActions のリストを検証し許可された action だけ返す。必須 action は "MoveSelectionAfterNotebook"。許可条件: action 名が accessSpec["AllowedNotebookActions"] に含まれ、MayUseFrontEnd/MayWriteNotebook が True、ExecutionKernel が "MainOnly"、Notebook が target と一致。
### NBSubkernelExecutableQ[held, accessSpec] → Bool
held が subkernel で安全に実行できるか(iShouldExecuteAsync の判定本体)。False 条件: ExecutionRole ≠ "ProposalEval"/ExecutionKernel ≠ "SubkernelAllowed"/MayUseFrontEnd・MayWriteNotebook・MayUseExternalProcess・MayUseNetwork いずれか True/ResultMayCrossKernel ≠ True/PolicySnapshot 無効/confidential 参照/DenyHeads・ApprovalHeads 該当/副作用 head(NotebookWrite, SelectionMove, Import, Export, RunProcess, StartProcess, Evaluate 等)を含む。
### NBExecuteHeldExprSubkernelRaw[held, accessSpec, opts] → result|$TimedOut|$Failed
subkernel 専用実行 wrapper。生の評価結果を返す(Association は返さない)。snapshot 検証・NBSubkernelExecutableQ・再検証をすべて通過し Decision が Permit のときのみ ReleaseHold。Screen/NeedsApproval/Deny/RepairNeeded は $Failed。TimeConstraint が Infinity なら TimeConstrained 不使用。
### NBMakeRuntimeAccessSpec[contextPacket, role] → Association
Runtime/Orchestrator から NBAccess へ渡す accessSpec を作る。role: "ProposalEval"(既定、SubkernelAllowed)/"Committer"(MainOnly, FE/書込可, MoveSelectionAfterNotebook 許可)/"VisionFallback"/"ManualDispatch"。PolicySnapshot は NBPolicySnapshot[] で凍結。contextPacket から ConfidentialSymbols/Secrets/Caller/WorkflowID/StepID/PermissionMode を取込。
### NBResolveOutputMode[mode, blockingRisk] → "Immediate"|"Deferred"
即出力か集約かを返す。blockingRisk が "MayBlockFrontEnd" なら mode に関わらず "Deferred"、mode が "Batch" なら "Deferred"、それ以外 "Immediate"。

## Action registry (Phase 5B.8)
### NBRegisterAction[name, spec]
承認対象操作(desktop/notebook/filesystem)を action registry に登録。spec キー: EffectClass, DefaultApprovalEligibility, AllowedTargetTypes, RequiresFinalNode, Validator, Executor。
### NBValidateAction[action, accessSpec] → Association
action association を registry の Validator + PermissionMode 変換で検証し Decision を返す。返り値は NBValidateHeldExpr と同形(Decision/ApprovalEligibility/EffectClass/AllowApprovalUI/MayExecute 等)。
### NBExecuteApprovedAction[action, accessSpec, opts] → result
承認済み action を実行。実行直前に再 validate(TOCTOU 対策)、承認後に path/target 変化なら PostApprovalValidationFailed で拒否。
### NBOpenFolderWithApproval[path]
OpenDesktopItem action(TargetType Folder)の薄い互換 wrapper。

## Final action queue (Phase 案3-lite)
### NBEnqueueFinalAction[action, accessSpec, opts] → ActionID
承認済み final action(FrontEnd ブロックリスクのある desktop/notebook 操作)を PendingFinalActionQueue に積む。共有 polling tick が安全条件を満たしたとき 1 件ずつ実行。
### NBFinalActionTick[]
共有 polling tick から呼ばれ、安全条件を確認して最大 1 件実行。安全条件: AsyncActive でない/final action 実行中でない/承認済み/再 validate 成功/期限内。
### NBFinalActionStatus[actionID] → status
queue item の状態。actionID 省略時は全 item。状態: Pending/Running/Completed/Failed/Expired/Cancelled/NeedsRetryAfterAsync。
### NBCancelFinalAction[actionID]
queue item を Cancelled にする。
### NBFinalActionQueueSnapshot[] → Association
queue 全体の snapshot(debug/Doctor 用)。
### NBFinalActionRunningQ[] → Bool
Running 状態の final action があるか。

## External job cooperative I/O guards (Phase 4.B)
### NBCheckFileRead[path, accessSpec] → Association
path の読み取りが accessSpec の MayAccessFileSystem/AllowedDirectories scope 内か検査。`<|"Allowed"->_, "Reason"->_|>`
### NBCheckFileWrite[path, accessSpec] → Association
path への書き込みが scope 内か検査。
### NBCheckNetworkAccess[target, accessSpec] → Association
target(URL 文字列または `<|Scheme,Host,Port|>`)が AllowedNetworkTargets scope 内か検査。
### NBCheckExternalProcess[cmd, accessSpec] → Association
外部コマンドが AllowedExternalCommands 内か検査。
### NBCheckedImport[path, fmt, accessSpec] → result|AccessSpecViolation
NBCheckFileRead 通過後に Import。違反時は AccessSpecViolation。
### NBCheckedExport[path, expr, fmt, accessSpec]
NBCheckFileWrite 通過後に Export。
### NBCheckedURLRead[url, accessSpec]
NBCheckNetworkAccess 通過後に URLRead。
### NBCheckedFileWrite[path, content, accessSpec]
NBCheckFileWrite 通過後に書き込む。
### NBCheckedFileRead[path, accessSpec]
NBCheckFileRead 通過後に読み取る。
### NBConfidentialHandlingAllowedQ[mode, permissionMode] → Bool
ConfidentialHandling mode(EncryptedBundle/ReferenceOnly/Redacted/PlaintextDebug)が当該 permissionMode で許容されるか(PlaintextDebug gate)。
### NBResolveCredentialRef[ref, accessSpec] → Association
credential-ref を解決し、secret 本体ではなく取得用 descriptor(`<|"Provider"->_, ...|>`)を返す。handler はこの descriptor で NBGetAPIKey を呼ぶ。