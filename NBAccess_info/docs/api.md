# NBAccess API Reference

LLM向けAPIリファレンス。このファイルのみを読んでNBAccessの正しいコードを書くことができる。

## パッケージ情報

パッケージ名: `NBAccess`、コンテキスト: `NBAccess``  
読み込み: `Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]`  
GitHub: https://github.com/transreal/NBAccess

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`  
NBAccess関数のデフォルトPrivacySpec。ローカルLLM環境では`$NBPrivacySpec = <|"AccessLevel" -> 1.0|>`と設定する。

### $NBConfidentialSymbols
型: Association  
秘密変数名とプライバシーレベルのテーブル `<|"変数名" -> privacyLevel, ...|>`。ClaudeCodeパッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: True  
Trueのとき秘密依存Outputでもデータ型・サイズ・キー等のスキーマ情報をクラウドLLMに送信する。Falseのとき秘密依存Outputのスキーマ情報を一切送信しない。非秘密Outputは常にスマート要約付きで送信される。

### $NBVerbose
型: Boolean, 初期値: False  
Trueのとき NBAccess 内部の詳細ログをMessagesに出力する。

### $NBAutoEvalProhibitedPatterns
型: List, 初期値: `{}`  
NBEvaluatePreviousCellで自動実行をブロックするパターン(RegularExpressionまたはStringExpression)のリスト。ClaudeCodeパッケージがロード時に登録する。

### $NBLLMQueryFunc
型: Function  
非同期LLM呼び出し用コールバック関数。ClaudeCodeパッケージが自動的にClaudeQueryAsyncを登録する。シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]`。カーネルをブロックしない。

### $NBSeparationIgnoreList
型: List  
分離検査(ClaudeCheckSeparation)で無視するファイル名またはパッケージ名のリスト。NBAccessとNotebookExtensionsはデフォルト登録済み。  
例: `AppendTo[$NBSeparationIgnoreList, "MyPackage"]`

### $NBAllowedHeads
型: List  
LLMが自由に実行可能なheadのリスト。

### $NBApprovalHeads
型: List  
人間承認を要するheadのリスト。

### $NBDenyHeads
型: List  
常に拒否するheadのリスト。

### $NBRoutingThresholds
型: Association  
routing閾値の Association。`<|"Cloud" -> 0.5, "Private" -> 0.8|>`。EffectiveRiskScore < Cloud → CloudLLM候補、Cloud <= score < Private → PrivateLLM候補、Private <= score → LocalOnly。

### $NBAllowedHeadsByCategory
型: Association  
カテゴリ別の許可headリスト。

### $NBDisabledCategories
型: Association  
無効化されたカテゴリの追跡。

## オプション

### PrivacySpec
NBAccess履歴関数のプライバシーフィルタリングオプション。  
値: `<|"AccessLevel" -> level|>` の形式。level ≤ セルのプライバシーレベルのセルのみアクセス可能。  
0.5: クラウドLLM安全なデータのみ(デフォルト)、1.0: ローカルLLM環境など全データ。

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
指定CellStyleのセルのインデックスリストを返す。`NBCellIndicesByStyle[nb, {style1, style2, ...}]`で複数スタイル指定可能。

### NBDeleteCellsByTag[nb, tag] → Null
指定CellTagsを持つセルを全て削除する。

### NBMoveAfterCell[nb, cellIdx] → Null
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookReadでCell式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd経由でInputText形式を取得する。失敗時はNBCellExprToTextにフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルのCellStyleを返す。

### NBCellLabel[nb, cellIdx] → String
セルのCellLabel(例: "In[3]:=")を返す。ラベルなしの場合は""を返す。

### NBCellSetOptions[nb, cellIdx, opts] → Null
セルにSetOptionsを適用する。

### NBCellSetStyle[nb, cellIdx, style] → Null
セルのスタイルを変更する。Cell式の第2引数を書き換える。TaggingRules等の属性は保持される。  
例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code] → Null
既存セルにコードをBoxData + Inputスタイルで書き込む。FEParserで構文カラーリング付きBoxDataに変換し、Cell式全体を内容(BoxData)とスタイル(Input)で置換する。  
例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBSelectCell[nb, cellIdx] → Null
セルブラケットを選択状態にする。パレット操作後のセル選択復元に使用する。

### NBResolveCell[nb, cellIdx] → CellObject | $Failed
CellObjectを返す。指定インデックスが無効な場合は$Failedを返す。

### NBCellGetTaggingRule[nb, cellIdx, path] → value | Missing[]
TaggingRulesのネスト値を返す。  
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellRasterize[nb, cellIdx, file, opts] → Null
セルをRasterizeしてfileに保存する。

### NBCellHasImage[cellExpr] → True | False
Cell式が画像(RasterBox/GraphicsBox)を含むか判定する。cellExprはNBCellReadの戻り値を想定。

### NBCellWriteText[nb, cellIdx, newText] → Null
セルのテキスト内容をnewTextに置き換える。セルスタイル・TaggingRules・オプション等の属性はそのまま保持される。  
例: `NBCellWriteText[nb, 3, "新しいテキスト"]`

### NBCellSetTaggingRule[nb, cellIdx, path, value] → Null
セルのTaggingRulesにネスト値を設定する。NBCellGetTaggingRuleの対となるセッター関数。  
例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`

## LLM連携 API

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得する。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。テキスト取得不可の場合は""を返す。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルをLLM変換する。promptFnはセルテキストを受け取りプロンプト文字列を返す関数。completionFnは結果Associationを受け取るコールバック。エラー時は$Failedを受け取る。カーネルをブロックしない。セルのプライバシーレベルに応じて適切なLLMを自動選択する。  
→ Null  
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使用する入力テキスト)  
completionFnが受け取るAssociation: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`  
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル(0.0〜1.0)を返す。0.0: 非秘密、1.0: 秘密(Confidentialマーク or 秘密変数参照)。

### NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] → True | False
セルが指定のPrivacySpecでアクセス可能かどうかを返す。

### NBFilterCellIndices[nb, indices, PrivacySpec -> ps] → List
セルインデックスリストをPrivacySpecでフィルタリングして返す。

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookReadの結果(Cell式)からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, PrivacySpec -> ps] → List
ノートブック内の全セルインデックスをPrivacySpecでフィルタリングして返す。

### NBGetContext[nb, afterIdx, PrivacySpec -> ps] → String
ノートブック内のafterIdx番目以降のセルからLLMプロンプト用コンテキスト文字列を構築する。PrivacySpecでフィルタリングされる。デフォルト: AccessLevel 0.5。

## 書き込み API

### NBWriteText[nb, text, style] → Null
ノートブックにテキストセルを書き込む。styleのデフォルトは"Text"。

### NBWriteCode[nb, code] → Null
構文カラーリング付きInputセルを書き込む。

### NBWriteSmartCode[nb, code] → Null
CellPrint[]パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate] → Null
現在のカーソル位置の後ろにInputセルを挿入し、カーソルをセル先頭に移動する。autoEvaluateがTrueの場合はさらにSelectionEvaluateを行う。

### NBInsertTextCells[nbFile, name, prompt] → Null
.nbファイルを非表示で開き、末尾にSubsectionセル(name)とTextセル(prompt)を挿入して保存・閉じる。

## ファイル型ノートブック操作 API

閉じた.nbファイルを対象とした読み書き操作。秘密セルの有無に関わらず、必ずこのAPIを経由する。claudecode.wl等の上位層から.nbファイルをNotebookOpen/NotebookGetで直接開いてはならない。必ずNBFileOpenを使うこと。

### NBFileOpen[path] → NotebookObject | $Failed
.nbファイルを非表示(Visible->False)で開きNotebookObjectを返す。失敗時は$Failedを返す。必ずNBFileCloseで閉じること。  
例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`

### NBFileClose[nb] → Null
NBFileOpenで開いたノートブックを閉じる。  
例: `NBFileClose[nb2]`

### NBFileSave[nb, path] → Null
開いているノートブックを指定パスに保存する。pathがNoneの場合は上書き保存。  
例: `NBFileSave[nb2, "C:\\path\\to\\translated.nb"]`

### NBFileReadCells[nb, PrivacySpec -> ps] → List
開いているノートブックの全セルをPrivacySpecに従ってフィルタリングし、`{<|"cellIdx"->n, "style"->s, "text"->t, "privacyLevel"->pl|>, ...}`を返す。privacyLevel > PrivacySpecの秘密セルはテキストを"[CONFIDENTIAL]"に置換する。  
例: `cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]`

### NBFileReadAllCells[nb] → List
開いているノートブックの全セルをアクセスレベル別に分類して返す。秘密セルも含む全セルを返すがPrivacyLevelフィールドで識別できる。ローカルモデルで処理する際に使用。  
例: `cells = NBFileReadAllCells[nb2]`

### NBFileWriteCell[nb, cellIdx, newText] → Null
開いているノートブックの指定セルのテキストをnewTextで置き換える。セルスタイル・TaggingRules・秘密マーク等の属性はそのまま保持される。  
例: `NBFileWriteCell[nb2, 3, "This is a pen."]`

### NBFileWriteAllCells[nb, replacements] → Null
`{cellIdx -> newText, ...}`のAssociationまたはListに従って複数セルを一括置換する。  
例: `NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]`

## ObjectSpec API

### NBFileSpec[path] → Association
ファイルのメタ情報とPrivacyLevelをAssociationで返す。PrivacyLevel: 0.5=クラウドLLM可、1.0=ローカルのみ、{0.5,1.0}=混在(.nb)。  
例: `NBFileSpec["C:\\path\\file.nb"]`

### NBValueSpec[expr, privacyLevel] → Association
値の型情報とPrivacyLevelを返す。  
例: `NBValueSpec[dataset, 1.0]`

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5 -> {"cloud"}、1.0 -> {"local"}、{0.5,1.0} -> {"cloud","local"}。  
例: `NBPrivacyLevelToRoutes[{0.5, 1.0}]`

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevelがlo〜hiのセルのみ返す。  
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (公開セルのみ)、`NBFileReadCellsInRange[nb2, 0.9, 1.0]` (秘密セルのみ)

### NBSplitNotebookCells[path, threshold] → {List, List}
.nbファイルのセルをPrivacyLevel <= threshold (public) と > threshold (private) に2分割する。  
例: `{pub, priv} = NBAccess``NBSplitNotebookCells["file.nb", 0.5]`

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2] → Null
2つの`<|cellIdx->newText|>`を元セル順にマージしてoutputPathに保存する。  
例: `NBAccess``NBMergeNotebookCells[src, dst, pubResults, privResults]`

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRulesから機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val] → Null
セルの機密タグをval(True/False)に設定する。

### NBMarkCellConfidential[nb, cellIdx] → Null
セルに機密マーク(赤背景 + WarningSign)を付ける。

### NBMarkCellDependent[nb, cellIdx] → Null
セルに依存機密マーク(橙背景 + LockIcon)を付ける。機密変数に依存する計算結果など、間接的に機密なセルに使用する。

### NBUnmarkCell[nb, cellIdx] → Null
セルの機密マーク(視覚・タグ)を全て解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → True | False
セルが機密変数を参照しているかを返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容からSet/SetDelayedのLHS変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容からConfidential[]内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → True | False
セルがプロンプトから除外すべきかを返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → True | False
セルがClaude関数呼び出しセルかを返す。

## 依存グラフ API

### NBBuildVarDependencies[nb] → Association
ノートブックのInputセルを解析して変数依存関係グラフ`<|"var" -> {"dep1",...}|>`を返す。文字列リテラル内の識別子は除外される。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[]全体のInputセルを走査して統合された変数依存関係グラフを返す。LLM呼び出し直前の精密チェックで使用する。通常のセル実行時は軽量版NBBuildVarDependencies[nb]を使用すること。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {Association, Integer}
既存の依存グラフにCellLabel In[x] (x > afterLine)のセルのみを追加走査してマージする。完全なグラフを毎回構築するコストを回避するインクリメンタル版。戻り値は`{updatedDeps, newLastLine}`。

### NBTransitiveDependents[deps, confVars] → List
depsグラフ上でconfVarsに直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルにNBMarkCellDependentを適用し、新たにマークしたセル数を返す。

### NBScanDependentCells[nb, confVarNames, deps] → Integer
事前計算済みの依存グラフdepsを使う(二重計算回避)。Claude関数呼び出しセル(ClaudeQuery等)は除外される。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリ内のresponse/instructionに現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。confVarsは現在の機密変数名リスト。

### NBDependencyEdges[nb] → List
ノートブックの変数依存関係をエッジリストで返す。戻り値: `{DirectedEdge["dep", "var"], ...}`。"dep" → "var" は "varがdepに依存する" を意味する。

### NBDependencyEdges[nb, confVars] → List
機密変数confVarsに関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars] → Null
依存グラフ・推移依存・セルテキストをPrintで表示するデバッグ関数。各InputセルについてInputText取得結果、代入解析結果、依存判定結果を出力する。

### NBPlotDependencyGraph[] → Graphics
全ノートブック統合の依存グラフをプロットする(デフォルト)。

### NBPlotDependencyGraph[nb] → Graphics
指定ノートブックの依存グラフをプロットする。ノードは変数名・Out[n]で、直接秘密は赤、依存秘密は橙で着色。NB内エッジは濃い実線、クロスNBエッジは薄い破線で描画。  
Options: "Scope" -> "Global" (デフォルト) | "Local", PrivacySpec -> `<|"AccessLevel" -> 1.0|>` (表示範囲制御)  
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

## 関数定義解析

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。戻り値: `<|"関数名" -> {"大域変数1", ...}, ...|>`。パターン変数とスコーピング局所変数(Module/Block/With/Function)は除外される。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックのTaggingRulesからkeyの値を返す。`NBGetTaggingRule[nb, {key1, key2, ...}]`でネストしたパスを指定可能。キーが存在しない場合はMissing[]を返す。

### NBSetTaggingRule[nb, key, value] → Null
ノートブックのTaggingRulesにkey -> valueを設定する。`NBSetTaggingRule[nb, {key1, key2}, value]`でネストしたパスを指定可能。

### NBDeleteTaggingRule[nb, key] → Null
ノートブックのTaggingRulesからkeyを削除する。

### NBListTaggingRuleKeys[nb] → List
ノートブックのTaggingRulesの全キーを返す。

### NBListTaggingRuleKeys[nb, prefix] → List
prefixで始まるキーのみ返す。

## 汎用履歴データベース API

履歴データは差分圧縮されTaggingRulesに保存される。エントリの形式: `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`。

### NBHistoryData[nb, tag] → Association
TaggingRulesから履歴データを読み取り、差分圧縮されたエントリを復元して返す。戻り値: `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`。  
Options: Decompress -> True (デフォルト)、False でDiffオブジェクトのまま返す。

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す(内部用)。

### NBHistorySetData[nb, tag, data] → Null
TaggingRulesに履歴データを書き込む。dataは`<|"header" -> ..., "entries" -> {...}|>`の形式。entriesは差分圧縮されていない平文で渡すこと。自動的に圧縮される。

### NBHistoryAppend[nb, tag, entry] → Null
エントリを履歴に追加する。差分圧縮: 直前のエントリのfullPrompt/response/codeをDiffで圧縮。  
Options: PrivacySpec -> ps (privacylevelをエントリに記録)

### NBHistoryEntries[nb, tag] → List
差分圧縮を復元した全エントリリストを返す。  
Options: Decompress -> True (デフォルト)、False でDiffオブジェクトのまま返す。

### NBHistoryUpdateLast[nb, tag, updates] → Null
最後のエントリを更新する。updatesは`<|"response" -> ..., "code" -> ..., ...|>`の形式。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダーAssociationを返す。

### NBHistoryWriteHeader[nb, tag, header] → Null
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag] → List
親履歴を含む全エントリを返す。headerのparent/inherit/createdに従って親チェーンを遡る。  
Options: Decompress -> True (デフォルト)、False でDiffオブジェクトのまま返す。

### NBHistoryListTags[nb, prefix] → List
prefixで始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag] → Null
指定タグの履歴をTaggingRulesから削除する。

### NBHistoryReplaceEntries[nb, tag, entries] → Null
エントリリスト全体を置換する。コンパクションやバッチ更新に使用する。

### NBHistoryUpdateHeader[nb, tag, updates] → Null
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加される。

### NBHistoryCreate[nb, tag, diffFields] → Association
新しい履歴データベースを作成する。diffFieldsは差分圧縮対象のフィールド名リスト(例: `{"fullPrompt", "response", "code"}`)。既存DBにdiffFieldsがある場合は既存ヘッダーを返す(冪等)。

### NBHistoryCreate[nb, tag, diffFields, headerOverrides] → Association
ヘッダーを上書き指定して作成する。

## セッションアタッチメント API

### NBHistoryAddAttachment[nb, tag, path] → Null
セッションにファイルをアタッチする。ヘッダーの"attachments"リストにパスを追加(重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path] → Null
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag] → Null
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, PrivacySpec -> ps] → Null
prefixで始まる全履歴を削除する。`PrivacySpec -> <|"AccessLevel" -> 1.0|>`が必須。セルレベルの機密・機密依存タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。

## API キーアクセサー

### NBGetAPIKey[provider] → String
AIプロバイダーのAPIキーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0が必須。呼び出し側でPrivacySpec -> `<|"AccessLevel" -> 1.0|>`を明示指定すること。SystemCredentialへのアクセスを一元管理する。

### NBGetLocalLLMAPIKey[provider, url] → String
ローカルLLMサーバー(LM Studio等)のAPIキーをSystemCredentialから返す。照合は{provider, url}ペア。AccessLevel >= 1.0が必須。  
解決優先度: (1)完全一致 (2)localhost⇔127.0.0.1置換版 (3){provider, "*"}ワイルドカード (4)フォールバック名ToUpperCase[provider]<>"_API_KEY"。  
例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録する。SystemCredentialの実値自体は書き込まない(名前の紐付けのみ)。戻り値: `{provider, normalizedUrl} -> credentialName` のRule。  
例: `NBSetLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234", "LMSTUDIO_STUDY_KEY"]`

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key] → Null
上記マッピング登録に加えてSystemCredential[credentialName] = keyも同時に設定する。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url] → Null
{provider, url}のエントリを削除する。SystemCredential本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
現在登録されているローカルLLMサーバー→APIキー名マッピングをDatasetで返す。Configured列はSystemCredentialが実際に設定済みかどうかを示す。

### NBLocalLLMCredentialName[provider, url] → String | Missing[]
SystemCredential名のみを返す(値は取得しない)。AccessLevelチェックなし。登録確認用。

## フォールバックモデル / プロバイダーアクセスレベル API

### NBSetFallbackModels[models] → Null
フォールバックモデルリストを設定する。models: `{{"provider","model"}, {"provider","model","url"}, ...}`。  
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level] → Null
プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。  
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`、`NBSetProviderMaxAccessLevel["lmstudio", 1.0]`

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは0.5を返す。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダーのMaxAccessLevel >= accessLevelのモデルのみ含まれる。  
例: `NBGetAvailableFallbackModels[0.8]` → lmstudioのみ、`NBGetAvailableFallbackModels[0.5]` → 全プロバイダー

### NBProviderCanAccess[provider, accessLevel] → True | False
プロバイダーが指定アクセスレベルのデータにアクセス可能かを返す。MaxAccessLevel >= accessLevelならTrue。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}] → Null
Claude Codeが参照可能なディレクトリリストをTaggingRulesに保存する。

### NBSetAccessibleDirs[{dir1, dir2, ...}] → Null
EvaluationNotebook[]に保存する。

### NBGetAccessibleDirs[nb] → List
保存されたアクセス可能ディレクトリリストを返す。

### NBGetAccessibleDirs[] → List
EvaluationNotebook[]から取得する。

### NBMoveToEnd[nb] → Null
ノートブックの末尾にカーソルを移動する。

## Job 管理 API

ClaudeQuery/ClaudeEvalの非同期出力位置管理。

### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブIDを返す。evalCellがCellObjectでない場合はノートブック末尾に挿入する。スロット1: システムメッセージ(プログレス・フォールバック通知)、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr] → Null
ジョブのスロットにCell式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。

### NBJobMoveToAnchor[jobId] → Null
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId] → Null
ジョブを正常終了する。未書き込みスロットとアンカーを削除しテーブルをクリアする。

### NBAbortJob[jobId, errorMsg] → Null
エラーメッセージを書き込みジョブを終了する。

### NBBeginJobAtEvalCell[nb] → jobId
EvaluationCell[]を内部取得してその直後にJobスロットを挿入する。claudecodeがCellObjectを保持する必要がない。

## 分離API / 状態管理

### NBExtractAssignments[text] → List
テキストからSet/SetDelayedのLHS変数名を抽出する。

### NBSetConfidentialVars[assoc] → Null
機密変数テーブルを一括設定する。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[] → Null
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level] → Null
機密変数を1つ登録する(levelデフォルト1.0)。

### NBUnregisterConfidentialVar[name] → Null
機密変数を1つ解除する。

### NBGetPrivacySpec[] → Association
現在の$NBPrivacySpecを返す。

### NBInstallCellEpilog[nb, key, expr] → Null
ノートブックのCellEpilogに式を設定する。keyは識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → True | False
CellEpilogがkeyで既にインストールされているか返す。

### NBEvaluatePreviousCell[nb] → Null
直前のセルを選択して評価する。$NBAutoEvalProhibitedPatternsにマッチするセルはスキップして警告を表示する。

### NBInsertInputTemplate[nb, boxes] → Null
InputセルテンプレートをNotebookに挿入する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCellの親ノートブックを返す。

## セル書き込み API (追加)

### NBWriteCell[nb, cellExpr] → Null
ノートブックにCell式を書き込む(After)。

### NBWriteCell[nb, cellExpr, pos] → Null
pos(After/Before/All)を指定可能。

### NBWritePrintNotice[nb, text, color] → Null
ノートブックに通知用PrintセルをNotebookWriteで書き込む。nbがNoneの場合はCellPrintを使用(同期In/Out間出力)。

### NBCellPrint[cellExpr] → Null
評価中のセルの直後に出力セルを挿入する(CellPrintラッパー)。カーソル位置に依存せず、常にEvaluationCellの直後に配置される。ClaudeBackupDataset等のタグ付き出力セルに使用する。

### NBWriteDynamicCell[nb, dynBoxExpr, tag] → Null
ノートブックにDynamicセルを書き込む。tagが""でない場合はCellTagsを設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate] → Null
ExternalLanguageセルを書き込む。autoEvaluateがTrueなら直前セルを評価する。

### NBInsertAndEvaluateInput[nb, boxes] → Null
Inputセルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes] → Null
InputセルをAfterに書き込みBeforeCellContentsに移動する。

### NBWriteAnchorAfterEvalCell[nb, tag] → Null
EvaluationCell直後に不可視アンカーセルを書き込む。EvaluationCellが取得できない場合はノートブック末尾に書き込む。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol] → Null
機密変数追跡用CellEpilogをインストールする。checkSymbolはFreeQチェック用のマーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → True | False
機密追跡CellEpilogがインストール済みか返す。checkSymbolはFreeQチェック用のマーカーシンボル。

## Allowed Expression Surface & Runtime Integration API

### NBValidateHeldExpr[heldExpr, accessSpec, opts] → Association
HoldComplete[...]式をAllowed Expression Surfaceに照合しAccessDecisionを返す。  
戻り値: `<|"Decision" -> "Permit"|"Deny"|"NeedsApproval"|"RepairNeeded", ...|>`

### NBExecuteHeldExpr[heldExpr, accessSpec, opts] → Association
検証済み式を安全に実行し結果を返す。  
戻り値: `<|"Success" -> True/False, "RawResult" -> ..., "Error" -> ...|>`

### NBRedactExecutionResult[result, accessSpec, opts] → Association
実行結果をredactし安全な形で返す。  
戻り値: `<|"RedactedResult" -> ..., "Summary" -> String|>`

### NBMakeContextPacket[nb, accessSpec, opts] → Association
ノートブックから安全なcontext packetを構築する。  
戻り値: `<|"Input" -> ..., "Cells" -> ..., "AccessSpec" -> ..., ...|>`

### NBRouteDecision[scoreOrAccessSpec] → Association
数値スコアまたはaccessSpecからrouting推奨を返す(advisory、非ゲートキーピング)。  
戻り値: `<|"Route" -> "CloudLLM"|"PrivateLLM"|"LocalOnly", "EffectiveRiskScore" -> n, "Thresholds" -> ..., "Reason" -> String|>`

## Iterative Agent Loop Support APIs

### NBInferExprRequirements[heldExpr, accessSpec] → Association
式が必要とするアクセスレベル・書き込みターゲット・参照セル等を静的に推定する。  
戻り値: `<|"ReadCells" -> {...}, "WriteCells" -> {...}, "RequiredAccessLevel" -> n, "HasSideEffects" -> True/False, ...|>`

### NBReleaseResult[result, accessSpec, opts] → Association
実行結果を指定されたsinkに安全にreleaseする。redaction + routingチェックを行い、release可能な形を返す。

### NBMakeRetryPacket[failureAssoc, accessSpec] → Association
失敗情報から秘密を含まない安全なretry packetを構築する。

### NBAuthorize[obj, req] → Association
PolicyGate + ScoreGate + EnvironmentGateを統合したAccessDecisionを返す。  
戻り値: `<|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval", "ReasonClass" -> ..., "RequiredAction" -> ..., "VisibleExplanation" -> ..., "RouteAdvice" -> ...|>`

### NBPolicyGate[obj, req] → Association
半順序ラベルに基づくflow判定を返す。PolicyLabel / ContainerLabel / SinkLabelを考慮する。

### NBScoreGate[obj, req] → Association
数値スコアに基づくrouting/screening判定を返す。advisory体系: 判定はroutingに影響するがpermit/denyの主体ではない。

### NBEnvironmentGate[obj, req] → Association
実行環境に基づく制約チェックを返す。Sink / Environment / Principalを考慮する。

## Function Security API

### NBRegisterFunctionSecurity[sym, spec] → Null
関数symにセキュリティメタデータを登録する。  
spec: `<|"DefinitionLabel" -> label, "ExecPolicy" -> "Open"|"Guarded"|"Denied", "ReleasePolicy" -> <|...|>|>`

### NBFunctionDefinitionLabel[f] → label
関数fの定義ラベルを返す。定義ラベルはコード自体の閲覧可否を制御する。

### NBFunctionExecPolicy[f] → String
関数fの実行ポリシーを返す。"Open"|"Guarded"|"Denied"。

### NBFunctionReleasePolicy[f] → Association
関数fの結果リリースポリシーを返す。結果のラベル引き下げ条件を定義する。

### GuardedApply[req, f, args] → value
f[args]をセキュリティポリシーに従って実行する。ExecPolicyが"Guarded"の場合、flowチェック後に実行し、結果に適切なラベルを付与する。

### Declassify[obj, req, releaseSpec] → value
objのラベルをreleaseSpecに従って引き下げる。reqのPrincipalがacts-for権限を持つ場合のみ許可。

## Label Algebra API

### NBLabelQ[label] → True | False
labelが有効なNBAccessラベルかを判定する。

### NBLabelBottom[] → label
最小制約ラベル(public)を返す。

### NBLabelTop[] → label
最大制約ラベル(全拒否)を返す。

### NBLabelJoin[l1, l2] → label
ラベルのjoin(より制約的な方向)を返す。両方の制約を満たす。

### NBLabelMeet[l1, l2] → label
ラベルのmeet(より緩い方向)を返す。

### NBLabelLEQ[l1, l2] → True | False
l1 ⪯ l2 (l1の情報がl2へflow可能)かを判定する。

### NBRegisterPrincipal[name, opts] → Null
アクセス主体を登録する。

### NBGrantActsFor[p, q] → Null
principal pがqとして行動できる委任を登録する。

### NBActsForQ[p, q] → True | False
pがqとして行動可能かを判定する。

### NBCanFlowToQ[srcLabel, dstLabel] → True | False
srcからdstへのflowが許可されるかを判定する。

### NBCanDeclassifyQ[srcLabel, dstLabel, req] → True | False
declassifyが正当かを判定する。

### NBEffectiveLabel[obj, req] → label
オブジェクトと要求から実効ラベルを計算する。

## カテゴリ管理

### NBEnableCategory[cat] → Null
カテゴリを有効化する。

### NBDisableCategory[cat] → Null
カテゴリを無効化する。

### NBCategoryEnabled[cat] → True | False
カテゴリが有効かを返す。