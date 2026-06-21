# NBAccess API リファレンス

NBAccess はセルインデックスベースでノートブックの読み書き・プライバシーフィルタリング・LLM 連携・履歴管理を提供するパッケージ。コンテキスト `NBAccess`` 。多くの関数は第1引数に NotebookObject `nb`、第2引数にセルインデックス `cellIdx`（1始まり）を取る。

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
型: Association(`<|"変数名" -> privacyLevel, ...|>`)
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

## ObjectSpec / パス正規化
### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を Association で返す。PrivacyLevel: `<0.5`=クラウドLLM可、`>=0.5`=ローカルのみ、`{0.5,1.0}`=混在(.nb)。

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

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク(橙背景 + LockIcon)を付ける。機密変数に依存する計算結果など間接的に機密なセルに使用。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク(視覚・タグ)をすべて解除する。

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
新しい履歴データベースを作成する。diffFields は差分圧縮対象のフィールド名リスト(例: `{"fullPrompt", "response", "code"}`)。既存 DB に diffFields がある場合は既存ヘッダーを返す(冪等)。

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

## カーソル移動
### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## Job 管理(非同期出力位置管理)
ClaudeQuery/ClaudeEval の非同期出力位置を管理する。
### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入。スロット1: システムメッセージ(進捗・フォールバック通知)、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再書き込みすると上書きされる。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除する。