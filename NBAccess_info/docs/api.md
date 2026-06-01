# NBAccess API リファレンス

セルインデックスベースでノートブックの読み書き、プライバシーフィルタリング、LLM 連携、履歴データベース、API キー管理を提供するパッケージ。
プライバシーモデル: 各セル/データに PrivacyLevel (0.0=非秘密 〜 1.0=秘密) を持ち、PrivacySpec の AccessLevel 以下のもののみアクセス可能。0.5=クラウド LLM 安全、1.0=ローカル LLM のみ。

## オプション名
### PrivacySpec
NBAccess 関数のプライバシーフィルタリングオプション。
例: PrivacySpec -> <|"AccessLevel" -> 0.5|>。AccessLevel <= セルの PrivacyLevel のセルのみアクセス可能。0.5=クラウド安全データのみ(既定)、1.0=全データ。

## グローバル変数
### $NBPrivacySpec
型: Association, 初期値: <|"AccessLevel" -> 0.5|>
NBAccess 関数のデフォルト PrivacySpec。ローカル LLM 環境では $NBPrivacySpec = <|"AccessLevel" -> 1.0|> に設定。

### $NBConfidentialSymbols
型: Association (<|"変数名" -> privacyLevel, ...|>)
秘密変数名とプライバシーレベルのテーブル。ClaudeCode パッケージが自動更新。

### $NBSendDataSchema
型: Boolean, 初期値: True
秘密依存データのスキーマ情報をクラウド LLM に送信するか制御。True で秘密依存 Output でも型・サイズ・キー等のスキーマ情報を送信。False で一切送信しない。非秘密 Output は常にスマート要約付きで送信される。

### $NBVerbose
型: Boolean, 初期値: False
NBAccess の詳細ログ出力フラグ。True で内部詳細ログを Messages に出力。

### $NBAutoEvalProhibitedPatterns
型: List (RegularExpression または StringExpression), 初期値: {}
NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト。セル内容がマッチすると評価をスキップし警告表示。ClaudeCode がロード時に登録。

## セルユーティリティ API
### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリストを返す。セルブラケット選択またはカーソル位置のセル。

### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリストを返す。style にリスト {style1, style2, ...} で複数指定可能。

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
セルのスタイルを変更する。Cell 式の第2引数を書き換える。TaggingRules 等の属性は保持。
例: NBCellSetStyle[nb, 3, "Input"]

### NBCellWriteCode[nb, cellIdx, code]
既存セルにコードを BoxData + Input スタイルで書き込む。FEParser で構文カラーリング付き BoxData に変換し Cell 式全体を置換。
例: NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]

### NBCellWriteText[nb, cellIdx, newText]
セルのテキスト内容を newText に置き換える。スタイル・TaggingRules・オプション等の属性は保持。
例: NBCellWriteText[nb, 3, "新しいテキスト"]

### NBSelectCell[nb, cellIdx]
セルブラケットを選択状態にする。ペースト操作後のセル選択復元に使用。

### NBResolveCell[nb, cellIdx] → CellObject
CellObject を返す。無効インデックスなら $Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
TaggingRules のネスト値を返す。
例: NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]

### NBCellSetTaggingRule[nb, cellIdx, path, value]
セルの TaggingRules にネスト値を設定する。NBCellGetTaggingRule の対セッター。
例: NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]

### NBCellRasterize[nb, cellIdx, file, opts]
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像 (RasterBox/GraphicsBox) を含むか判定。cellExpr は NBCellRead の戻り値。

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

## LLM 連携 API
### $NBLLMQueryFunc
型: Function (コールバック)
非同期 LLM 呼び出し用コールバック関数。ClaudeCode が ClaudeQueryAsync を登録。
シグネチャ: $NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool, Integrations -> {...}]。callback は応答文字列を受け取る関数、nb は出力先 NotebookObject。Integrations は LM Studio MCP 用 (lmstudio モデル時のみ有効、Automatic なら無視)。カーネルをブロックしない。

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。取得不可なら ""。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換する。promptFn はセルテキストを受けプロンプト文字列を返す関数。completionFn は結果 Association を受けるコールバック (エラー時は $Failed)。セルのプライバシーレベルに応じ適切な LLM を自動選択。カーネルをブロックしない。
→ Null (非同期)
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使う入力テキスト), Integrations -> Automatic (LM Studio MCP サーバリスト、lmstudio モデル時のみ)
completionFn が受ける Association: <|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>
例: NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]

## プライバシー API
### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル (0.0〜1.0) を返す。0.0=非秘密、1.0=秘密 (Confidential マーク or 秘密変数参照)。

### NBIsAccessible[nb, cellIdx, opts] → Boolean
セルが指定 PrivacySpec でアクセス可能か返す。
Options: PrivacySpec -> $NBPrivacySpec

### NBFilterCellIndices[nb, indices, opts] → List
セルインデックスリストを PrivacySpec でフィルタリングして返す。
Options: PrivacySpec -> $NBPrivacySpec

## テキスト抽出 API
### NBCellExprToText[cellExpr] → String
NotebookRead の結果 (Cell 式) からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, opts] → List
ノートブック内の全セルインデックスを PrivacySpec でフィルタリングして返す。
Options: PrivacySpec -> $NBPrivacySpec

### NBGetContext[nb, afterIdx, opts] → String
afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築。PrivacySpec でフィルタリングされる。
Options: PrivacySpec -> $NBPrivacySpec (既定 AccessLevel 0.5)

## 書き込み API
### NBWriteText[nb, text, style]
ノートブックにテキストセルを書き込む。style 既定は "Text"。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
現在のカーソル位置の後ろに Input セルを挿入しカーソルをセル先頭に移動。autoEvaluate が True なら SelectionEvaluate を行う。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル (name) と Text セル (prompt) を挿入して保存・閉じる。

## ファイル型ノートブック操作 API
閉じた .nb ファイルへの読み書き。上位層から直接 NotebookOpen/NotebookGet せず必ず NBFileOpen を経由すること。
### NBFileOpen[path] → NotebookObject
.nb ファイルを非表示 (Visible->False) で開き NotebookObject を返す。失敗時は $Failed。必ず NBFileClose で閉じること。
例: nb2 = NBFileOpen["C:\\path\\to\\file.nb"]

### NBFileClose[nb]
NBFileOpen で開いたノートブックを閉じる。

### NBFileSave[nb, path]
開いているノートブックを指定パスに保存する。path が None なら上書き保存。
例: NBFileSave[nb2, "C:\\path\\to\\translated.nb"]

### NBFileReadCells[nb, opts] → List
開いているノートブックの全セルを PrivacySpec でフィルタリングし {<|cellIdx, style, text, privacyLevel|>, ...} を返す。privacyLevel > PrivacySpec の秘匿セルはテキストを "[CONFIDENTIAL]" に置換。
Options: PrivacySpec -> $NBPrivacySpec
例: cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]

### NBFileReadAllCells[nb] → List
開いているノートブックの全セルをアクセスレベル別に分類して返す。秘匿セルも含む全セルを返すが PrivacyLevel フィールドで識別可能。ローカルモデル処理時に使用。

### NBFileWriteCell[nb, cellIdx, newText]
開いているノートブックの指定セルのテキストを newText で置き換える。スタイル・TaggingRules・秘匿マーク等は保持。
例: NBFileWriteCell[nb2, 3, "This is a pen."]

### NBFileWriteAllCells[nb, replacements]
{cellIdx -> newText, ...} の Association または List に従い複数セルを一括置換する。
例: NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]

## ObjectSpec / パス正規化 API
### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を Association で返す。PrivacyLevel: <0.5=クラウド LLM 可、>=0.5=ローカルのみ、{0.5,1.0}=混在(.nb)。
例: NBFileSpec["C:\\path\\file.nb"]

### NBFileSpecCacheClear[]
NBFileSpec の base/projection キャッシュをクリアする。

### NBNormalizePath[path] → Association
絶対パスを複数 PC 間で安定なシンボリックパス情報の Association に正規化する。
→ <|"Kind", "RootId", "Parts", "SymbolicPath", "PhysicalPath", "ResolutionStatus", "MatchedBy"|>
ResolutionStatus: "ResolvedOnThisPC" | "AliasOnly" | "Unrooted"。MatchedBy: "LocalRoot" | "Alias" | "None"。戻り値は同一性 (identity) 情報でありアクセス権限を与えない。権限判定は PhysicalPath を現 PC で解決・実在確認した上で行う (rule 104)。

### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。
例: NBValueSpec[dataset, 1.0]

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5 -> {"cloud"}, 1.0 -> {"local"}, {0.5,1.0} -> {"cloud","local"}。
例: NBPrivacyLevelToRoutes[{0.5, 1.0}]

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevel が lo〜hi のセルのみ返す。
例: NBFileReadCellsInRange[nb2, 0.5, 0.5] (公開セルのみ)、NBFileReadCellsInRange[nb2, 0.9, 1.0] (秘匿セルのみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb のセルを PrivacyLevel <= threshold (public) と > threshold (private) に2分割する。
例: {pub, priv} = NBSplitNotebookCells["file.nb", 0.5]

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
2つの <|cellIdx->newText|> を元セル順にマージして outputPath に保存する。
例: NBMergeNotebookCells[src, dst, pubResults, privResults]

## セルマーク API
### NBGetConfidentialTag[nb, cellIdx] → True|False|Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx, opts]
セルを機密 (PrivacyLevel 1.0) に設定し赤背景マークを付ける。
NBMarkCellConfidential[nb, cellIdx, level] で任意の数値 (0.0-1.0) に設定。level > 0.5 で赤背景マーク、<= 0.5 でマーク除去。
Options: PrivacySpec -> Automatic
$NBApprovalHeads に登録され実行時に承認ゲートを発火させる。

### NBSetSnapshotPrivacyLevel[snapshotId, level, opts]
SourceVault snapshot の PrivacyLevel を設定する。人間が明示的に上書きしたい場合に使う。
Options: PrivacySpec -> Automatic。SourceVault ロード必須。$NBApprovalHeads に登録され承認ゲート発火。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク (橙背景 + LockIcon) を付ける。機密変数に依存する計算結果など間接的に機密なセルに使用。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク (視覚・タグ) を全て解除する。

## セル内容分析 API
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

## 依存グラフ API
### NBAccess`iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得。失敗時は NBCellExprToText にフォールバック。

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析して変数依存関係グラフ <|"var" -> {"dep1",...}|> を返す。文字列リテラル内の識別子は除外。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査して統合された変数依存関係グラフを返す。LLM 呼び出し直前の精密チェック用。通常のセル実行時は軽量版 NBBuildVarDependencies[nb] を使う。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存依存グラフに CellLabel In[x] (x > afterLine) のセルのみ追加走査してマージする。インクリメンタル版。

### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。Claude 関数呼び出しセルは除外。
NBScanDependentCells[nb, confVarNames, deps] で事前計算済み依存グラフ deps を使う。

### NBFilterHistoryEntry[entry, confVars] → entry
履歴エントリ内の response/instruction に現時点の機密変数名または値が含まれる場合そのフィールドをブロックする。confVars は現在の機密変数名リスト。

### NBDependencyEdges[nb] → {DirectedEdge[...], ...}
ノートブックの変数依存関係をエッジリストで返す。"dep" → "var" は "var が dep に依存する" を意味する。
NBDependencyEdges[nb, confVars] で機密変数 confVars に関連するエッジのみ返す。

### NBDebugDependencies[nb, confVars]
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。

### NBPlotDependencyGraph[opts]
全ノートブック統合の依存グラフをプロットする (デフォルト)。
NBPlotDependencyGraph[nb, opts] で指定ノートブック。ノードは変数名・Out[n]、直接秘密は赤、依存秘密は橙。NB 内エッジは濃い実線、クロス NB エッジは薄い破線。
Options: "Scope" -> "Global" (既定) | "Local", PrivacySpec -> <|"AccessLevel" -> 1.0|>
例: NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数が依存する大域変数リストを返す。<|"関数名" -> {"大域変数1", ...}, ...|>。パターン変数とスコーピング局所変数 (Module/Block/With/Function) は除外。

## ノートブック TaggingRules API
### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックの TaggingRules から key の値を返す。key にリスト {key1, key2, ...} でネストパス指定可能。存在しなければ Missing[]。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に key -> value を設定する。key にリストでネストパス指定可能。

### NBDeleteTaggingRule[nb, key]
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] → List
ノートブックの TaggingRules の全キーを返す。NBListTaggingRuleKeys[nb, prefix] で prefix で始まるキーのみ。

### NBSetNotebookDefaultModel[nb, provider, modelName]
ノートブックのデフォルトモデル (claudecode パレット設定 paletteProvider/paletteModelName) を書き換える。

### NBGetNotebookDefaultModel[nb] → {provider, modelName} | Missing["NotDeclared"]
ノートブックのデフォルトモデルを返す。未設定なら Missing["NotDeclared"]。

## 履歴データベース API
履歴は差分圧縮 (Diff) して TaggingRules に保存される。Decompress -> True (既定) で復元、False で Diff オブジェクトのまま返す。
### NBHistoryData[nb, tag, opts] → Association
TaggingRules から履歴データを読み取り差分を復元して返す。
→ <|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>
Options: Decompress -> True (False で Diff のまま)

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す (内部用)。

### NBHistorySetData[nb, tag, data]
TaggingRules に履歴データを書き込む。data は <|"header" -> ..., "entries" -> {...}|>。entries は平文で渡すと自動圧縮される。

### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加する。直前エントリの fullPrompt/response/code を Diff 圧縮。
Options: PrivacySpec -> ps (privacylevel をエントリに記録)

### NBHistoryEntries[nb, tag, opts] → List
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを更新する。updates は <|"response" -> ..., "code" -> ..., ...|>。

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリを返す。header の parent/inherit/created に従い親チェーンを辿る。
Options: Decompress -> True

### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。コンパクションやバッチ更新に使用。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加。

### NBHistoryCreate[nb, tag, diffFields] → header
新しい履歴データベースを作成する。diffFields は差分圧縮対象のフィールド名リスト (例: {"fullPrompt", "response", "code"})。NBHistoryCreate[nb, tag, diffFields, headerOverrides] でヘッダー上書き可能。既存 DB に diffFields がある場合は既存ヘッダーを返す (冪等)。

## セッションアタッチメント API
### NBHistoryAddAttachment[nb, tag, path]
セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加 (重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path]
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, opts]
prefix で始まる全履歴を削除する。セルレベルの機密・機密依存タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。
Options: PrivacySpec -> <|"AccessLevel" -> 1.0|> (必須)

## API キーアクセサ
### NBGetAPIKey[provider, opts] → String
AI プロバイダの API キーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0 必須。SystemCredential へのアクセスを一元管理。
Options: PrivacySpec -> <|"AccessLevel" -> 1.0|> (明示指定必須)

### NBListProviderModels[provider] → Association
クラウドプロバイダ (anthropic / openai) の利用可能モデル ID リストを返す。API キーは内部で SystemCredential から読み外部に出さない。返すのはモデル名リスト (秘匿性なし) なので PrivacySpec 指定不要。
→ <|"Status" -> _, "Provider" -> _, "Models" -> {_String..}|>

## ローカル LLM サーバの API キーアクセサ
### NBGetLocalLLMAPIKey[provider, url, opts] → String
ローカル LLM サーバ (LM Studio 等) の API キーを SystemCredential から返す。照合は {provider, url} ペア。AccessLevel >= 1.0 必須。
Options: PrivacySpec -> <|"AccessLevel"->1.0|> (明示指定必須)
解決優先度: (1) 完全一致 (2) localhost⟷127.0.0.1 置換版 (3) {provider, "*"} ワイルドカード (4) フォールバック名 ToUpperCase[provider]<>"_API_KEY"。
例: NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録する。SystemCredential の実値自体は書き込まない (名前の紐付けのみ)。
→ {provider, normalizedUrl} -> credentialName
例: NBSetLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234", "LMSTUDIO_STUDY_KEY"]

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key]
上記マッピング登録に加えて SystemCredential[credentialName] = key も同時に設定する。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url]
{provider, url} のエントリを削除する。SystemCredential 本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
現在登録されているローカル LLM サーバ→API キー名マッピングを Dataset で返す。Configured 列は SystemCredential が実際に設定済みかを示す。

### NBLocalLLMCredentialName[provider, url] → String
SystemCredential 名のみを返す (値は取得しない)。AccessLevel チェックなし。登録確認用。

## フォールバックモデル / プロバイダアクセスレベル API
### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: {{"provider","model"}, {"provider","model","url"}, ...}。
例: NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。プロバイダの MaxAccessLevel >= accessLevel のモデルのみ含まれる。
例: NBGetAvailableFallbackModels[0.8] → lmstudio のみ、NBGetAvailableFallbackModels[0.5] → 全プロバイダ

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダの最大アクセスレベル (0.0〜1.0) を設定する。このレベルを超えるリクエストにはフォールバックしない。
例: NBSetProviderMaxAccessLevel["anthropic", 0.5]、NBSetProviderMaxAccessLevel["lmstudio", 1.0]

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダの最大アクセスレベルを返す。未登録プロバイダは 0.5。

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダが指定アクセスレベルのデータにアクセス可能か返す。MaxAccessLevel >= accessLevel なら True。

### NBModelCanHandleAccessLevel[modelSpec, accessLevel] → Boolean
モデル指定がそのアクセスレベルのデータを扱えるか返す。Private ノート (レベル 1.0) でクラウドモデル (claudecode/anthropic/openai = 0.5) を拒否し、ローカル LLM (lmstudio = 1.0) のみ通すために使う。
modelSpec: {provider, model} | {provider, model, url} | "model" | Automatic (未指定は True)。

### NBModelProviderName[modelSpec] → String
modelSpec から provider 文字列を取り出す。

### NBNotebookRequiredAccessLevel[nb] → Real
ノートブックが要求するアクセスレベルを返す。Private 宣言 (CloudPublishable -> False) なら 1.0 (クラウド禁止)、それ以外は 0.0。

## 信頼ローカルサーバ / モデル変数同期 API
### NBRegisterTrustedLocalServer[assoc]
信頼できるローカル LLM サーバを登録する。assoc: <|"MachineName" -> _, "Subnet" -> _, "Provider" -> _, "URL" -> _|>。IP/サブネットはセキュリティ境界なので NBAccess が管理。モデル名は含めない (SourceVault が intent 解決で扱う)。
例: NBRegisterTrustedLocalServer[<|"MachineName"->"phoenix", "Subnet"->"192.168.2", "Provider"->"lmstudio", "URL"->"http://192.168.2.110:1234"|>]

### NBResolveLocalServer[] → Association
現在のマシン環境 ($MachineName と自 IP のサブネット) を信頼リストと照合し、信頼できるローカル LLM サーバ <|"Provider" -> _, "URL" -> _, "Trusted" -> _, ...|> を返す。未知のサブネットでは安全側に倒し localhost (127.0.0.1) のみ返す。モデル名は返さない。

### NBTrustedLocalServers[] → Dataset
現在登録されている信頼ローカルサーバのリストを返す。

### NBSyncClaudeModelVars[opts]
SourceVault にキャッシュされているモデルで ClaudeCode の $ClaudeModel / $ClaudeDocModel / $ClaudePrivateModel / $ClaudeFallbackModels を更新する。ローカルサーバの URL は NBResolveLocalServer で安全に解決して実変数へ代入。SourceVault 未ロードなら何もしない。SourceVault ロード時に自動実行される。
Options: Verbose -> False

## アクセス可能ディレクトリ API
### NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。NBSetAccessibleDirs[{...}] は EvaluationNotebook[] に保存。

### NBGetAccessibleDirs[nb] → List
保存されたアクセス可能ディレクトリリストを返す。NBGetAccessibleDirs[] は EvaluationNotebook[] から取得。

### NBResolvePathRef[pathRef] → String | Missing[...]
PathRef (NBNormalizePath が返す Association、または {"$onWork", ...} 形式のシンボリックパスリスト) を現 PC の実パスへ解決する。解決でき実在すれば絶対パス文字列、解決できない (ルート未定義・別 PC エイリアスのみ) なら Missing[...]。SourceVault ロード時は iSVResolvePath を利用。rule 104: alias-only / root-missing な PathRef は実パスに解決されない。

### NBSetAccessiblePathRefs[nb, refs]
AccessPathRef のリストを notebook の TaggingRules (claudeAccessiblePathRefs) に保存する。NBSetAccessiblePathRefs[refs] は EvaluationNotebook[] に保存。各 AccessPathRef は <|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|>。claudeAccessiblePathRefs が canonical、旧 claudeAccessibleDirs は read fallback のみ。

### NBGetAccessiblePathRefs[nb] → List
notebook に保存された AccessPathRef のリストを返す。NBGetAccessiblePathRefs[] は EvaluationNotebook[]。claudeAccessiblePathRefs が無い旧 notebook では claudeAccessibleDirs を AccessPathRef に変換して返す (read fallback)。

### NBNormalizeAccessPathRef[dirOrRef] → Association
旧形式の絶対パス文字列または部分的な指定を完全な AccessPathRef Association に正規化する。文字列なら NBNormalizePath で PathRef 化し Mode -> "Read"、CloudSend -> "Ask" を既定とする。既に AccessPathRef なら不足キーを既定で補う。

## Job 管理 API
ClaudeQuery/ClaudeEval の非同期出力位置を管理する。評価セル直後に不可視スロットセルを挿入し、応答書き込み位置をアンカーで管理する。
### NBBeginJob[nb, evalCell] → jobId
評価セルの直後に3つの不可視スロットセルを挿入しジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入。スロット1: システムメッセージ (プログレス・フォールバック通知)、スロット2: 完了メッセージ、アンカー: レスポンス書き込み位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再度書き込むと上書き。

### NBJobMoveToAnchor[jobId]
アンカーセルの直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除する。