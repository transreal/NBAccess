# NBAccess API リファレンス

Notebook Access ユーティリティパッケージ。セル単位でノートブックの読み書きとプライバシーフィルタリングを提供する。

## グローバル変数

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
NBAccess 関数のデフォルト PrivacySpec。0.5=クラウドLLM安全、1.0=ローカルLLM全データ。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
秘密変数名とプライバシーレベルのテーブル `<|"name" -> level, ...|>`。ClaudeCode が自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: True
秘密依存データのスキーマ情報をクラウドLLMに送信するか制御。

### $NBVerbose
型: Boolean, 初期値: False
NBAccess パッケージの詳細ログ出力を制御。

### $NBAutoEvalProhibitedPatterns
型: List, 初期値: `{}`
NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト。RegularExpression または StringExpression。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
ClaudeCheckSeparation で無視するファイル名/パッケージ名のリスト。

### $NBLLMQueryFunc
型: Function, 初期値: None
非同期 LLM 呼び出しコールバック関数。シグネチャ: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]`。

### $NBAllowedHeads
型: List
LLM が自由に実行可能な head のリスト。

### $NBApprovalHeads
型: List
人間承認を要する head のリスト。

### $NBDenyHeads
型: List
常に拒否する head のリスト。

### $NBRoutingThresholds
型: Association, 初期値: `<|"Cloud" -> 0.5, "Private" -> 0.8|>`
ルーティング閾値。score < Cloud → CloudLLM、Cloud ≤ score < Private → PrivateLLM、score ≥ Private → LocalOnly。

## オプション

### PrivacySpec
NBAccess 関数のプライバシーフィルタリングオプション。`PrivacySpec -> <|"AccessLevel" -> 0.5|>` の形式。AccessLevel ≤ セルプライバシーレベル のセルのみアクセス可能。

## セルユーティリティ API

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell[] のセルインデックスを返す。未発見時は 0。

### NBSelectedCellIndices[nb] → List
選択中セルのインデックスリストを返す。

### NBCellIndicesByTag[nb, tag] → List
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → List
指定 CellStyle のセルのインデックスリストを返す。style はリストも可。

### NBDeleteCellsByTag[nb, tag] → Null
指定 CellTags を持つセルを全て削除する。

### NBMoveAfterCell[nb, cellIdx] → Null
セルの後ろにカーソルを移動する。

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式を取得。失敗時は NBCellExprToText にフォールバック。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel (例: "In[3]:=") を返す。ラベルなしは ""。

### NBCellSetOptions[nb, cellIdx, opts] → Null
セルに SetOptions を適用する。

### NBCellSetStyle[nb, cellIdx, style] → Null
セルのスタイルを変更する。TaggingRules 等の属性は保持される。
例: `NBCellSetStyle[nb, 3, "Input"]`

### NBCellWriteCode[nb, cellIdx, code] → Null
既存セルに BoxData + Input スタイルでコードを書き込む。FEParser で構文カラーリング付き BoxData に変換。
例: `NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]`

### NBCellWriteText[nb, cellIdx, newText] → Null
セルのテキスト内容を newText に置き換える。スタイル・TaggingRules・オプションは保持。

### NBSelectCell[nb, cellIdx] → Null
セルブラケットを選択状態にする。

### NBResolveCell[nb, cellIdx] → CellObject | $Failed
CellObject を返す。無効インデックスは $Failed。

### NBCellGetTaggingRule[nb, cellIdx, path] → Any
TaggingRules のネスト値を返す。
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value] → Null
セルの TaggingRules にネスト値を設定する。
例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]`

### NBCellRasterize[nb, cellIdx, file, opts] → Null
セルを Rasterize して file に保存する。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像 (RasterBox/GraphicsBox) を含むか判定する。

## LLM 連携 API

### NBCellGetText[nb, cellIdx] → String
セルからテキストを堅牢に取得。FrontEnd InputText → NBCellToText → NBCellExprToText の順でフォールバック。失敗時は ""。

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
非同期でセルを LLM 変換する。promptFn はセルテキストを受けプロンプト文字列を返す。completionFn は結果 Association `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>` を受ける。エラー時は $Failed を受ける。
→ Null (非同期)
Options: Fallback -> False, InputText -> Automatic (セルテキストの代わりに使用する入力テキスト)
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## プライバシー API

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル (0.0〜1.0) を返す。

### NBIsAccessible[nb, cellIdx, opts] → Boolean
セルが指定 PrivacySpec でアクセス可能か判定。
Options: PrivacySpec -> $NBPrivacySpec

### NBFilterCellIndices[nb, indices, opts] → List
セルインデックスリストを PrivacySpec でフィルタリング。
Options: PrivacySpec -> $NBPrivacySpec

## テキスト抽出 API

### NBCellExprToText[cellExpr] → String
NotebookRead の結果 (Cell式) からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を返す。

### NBGetCells[nb, opts] → List
ノートブック内の全セルインデックスを PrivacySpec でフィルタリング。
Options: PrivacySpec -> $NBPrivacySpec

### NBGetContext[nb, afterIdx, opts] → String
afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築。
Options: PrivacySpec -> $NBPrivacySpec (デフォルト AccessLevel 0.5)

## 書き込み API

### NBWriteText[nb, text, style] → Null
ノートブックにテキストセルを書き込む。style デフォルトは "Text"。

### NBWriteCode[nb, code] → Null
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code] → Null
CellPrint[] パターンを自動検出してスマートにセルを書き込む。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate] → Null
現在のカーソル位置の後ろに Input セルを挿入。autoEvaluate=True で SelectionEvaluate も実行。

### NBInsertTextCells[nbFile, name, prompt] → Null
.nb ファイルを非表示で開き末尾に Subsection (name) と Text (prompt) を挿入して保存・閉じる。

## ファイル型ノートブック操作 API

### NBFileOpen[path] → NotebookObject | $Failed
.nb ファイルを非表示 (Visible->False) で開き NotebookObject を返す。必ず NBFileClose で閉じること。

### NBFileClose[nb] → Null
NBFileOpen で開いたノートブックを閉じる。

### NBFileSave[nb, path] → Null
ノートブックを path に保存。path=None で上書き保存。

### NBFileReadCells[nb, opts] → List
全セルを PrivacySpec フィルタしリスト `{<|cellIdx, style, text, privacyLevel|>, ...}` を返す。privacyLevel > AccessLevel のセルは text が "[CONFIDENTIAL]" になる。
Options: PrivacySpec -> $NBPrivacySpec

### NBFileReadAllCells[nb] → List
全セルをアクセスレベル別に分類して返す。秘匿セルも含むがPrivacyLevel フィールドで識別可能。ローカルモデル用。

### NBFileWriteCell[nb, cellIdx, newText] → Null
指定セルのテキストを newText で置き換える。属性は保持。

### NBFileWriteAllCells[nb, replacements] → Null
`<|cellIdx -> newText, ...|>` または List に従って複数セルを一括置換。

## ObjectSpec API

### NBFileSpec[path] → Association
ファイルのメタ情報と PrivacyLevel を Association で返す。PrivacyLevel: 0.5=クラウド可, 1.0=ローカルのみ, {0.5,1.0}=混在 (.nb)。

### NBValueSpec[expr, privacyLevel] → Association
値の型情報と PrivacyLevel を返す。

### NBPrivacyLevelToRoutes[privacyLevel] → List
必要なモデルルートリストを返す。0.5→{"cloud"}, 1.0→{"local"}, {0.5,1.0}→{"cloud","local"}。

### NBFileReadCellsInRange[nb, lo, hi] → List
PrivacyLevel が lo〜hi のセルのみ返す。
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (公開のみ), `NBFileReadCellsInRange[nb2, 0.9, 1.0]` (秘匿のみ)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
.nb のセルを PrivacyLevel ≤ threshold (public) と > threshold (private) に分割する。

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2] → Null
2 つの `<|cellIdx -> newText|>` を元のセル順にマージして outputPath に保存する。

## セルマーク API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
TaggingRules から機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val] → Null
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx] → Null
セルに機密マーク (赤背景 + WarningSign) を付ける。

### NBMarkCellDependent[nb, cellIdx] → Null
セルに依存機密マーク (橙背景 + LockIcon) を付ける。

### NBUnmarkCell[nb, cellIdx] → Null
セルの機密マーク (視覚・タグ) を全解除する。

## セル内容分析 API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが機密変数を参照しているか返す。

### NBCellExtractVarNames[nb, cellIdx] → List
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → List
セル内容から Confidential[] 内の代入先変数名を抽出する。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきか返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルが Claude 関数呼び出しセルか返す。

## 依存グラフ API

### iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得 (内部用)。

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルを解析し変数依存グラフ `<|"var" -> {"dep1",...}|>` を返す。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査し統合された変数依存グラフを返す。LLM 呼び出し直前の精密チェック用。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
既存依存グラフに CellLabel In[x] (x > afterLine) のセルのみ追加走査しマージする。

### NBTransitiveDependents[deps, confVars] → List
deps グラフ上で confVars に直接・間接依存する全変数名リストを返す。

### NBScanDependentCells[nb, confVarNames] → Integer
NBScanDependentCells[nb, confVarNames, deps] → Integer
依存グラフを使い機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。Claude 関数呼び出しセルは除外。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリ内の response/instruction に機密変数名/値が含まれる場合そのフィールドをブロックする。

### NBDependencyEdges[nb] → List
NBDependencyEdges[nb, confVars] → List
変数依存関係をエッジリスト `{DirectedEdge["dep", "var"], ...}` で返す。confVars 指定時は関連エッジのみ。

### NBDebugDependencies[nb, confVars] → Null
依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。

### NBPlotDependencyGraph[opts] → Graph
NBPlotDependencyGraph[nb, opts] → Graph
依存グラフをプロットする。直接秘密=赤、依存秘密=橙、NB内エッジ=濃実線、クロスNBエッジ=薄破線。
Options: "Scope" -> "Global" ("Global" | "Local"), PrivacySpec -> $NBPrivacySpec
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

## 関数定義解析

### NBGetFunctionGlobalDeps[nb] → Association
ノートブック内の全関数定義を解析し、各関数の大域変数依存リストを `<|"funcName" -> {"globalVar1", ...}, ...|>` で返す。パターン変数・Module/Block/With/Function 局所変数は除外。

## ノートブック TaggingRules API

### NBGetTaggingRule[nb, key] → Any
NBGetTaggingRule[nb, {key1, key2, ...}] → Any
ノートブックの TaggingRules から key の値を返す。存在しない場合 Missing[]。

### NBSetTaggingRule[nb, key, value] → Null
NBSetTaggingRule[nb, {key1, key2}, value] → Null
ノートブックの TaggingRules に key -> value を設定する。

### NBDeleteTaggingRule[nb, key] → Null
ノートブックの TaggingRules から key を削除する。

### NBListTaggingRuleKeys[nb] → List
NBListTaggingRuleKeys[nb, prefix] → List
TaggingRules の全キーまたは prefix で始まるキーを返す。

## 履歴データベース API

### NBHistoryData[nb, tag, opts] → Association
TaggingRules から履歴データを読み Diff 圧縮を復元したエントリを返す。
→ `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`
Options: Decompress -> True (False で Diff オブジェクトのまま)

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す (内部用)。

### NBHistorySetData[nb, tag, data] → Null
TaggingRules に履歴データを書き込む。entries は平文で渡し自動圧縮される。

### NBHistoryAppend[nb, tag, entry, opts] → Null
エントリを履歴に追加。直前の fullPrompt/response/code を Diff で圧縮する。
Options: PrivacySpec -> $NBPrivacySpec (privacylevel をエントリに記録)

### NBHistoryEntries[nb, tag, opts] → List
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True

### NBHistoryUpdateLast[nb, tag, updates] → Null
最後のエントリを更新する。updates: `<|"response" -> ..., "code" -> ..., ...|>`

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダー Association を返す。

### NBHistoryWriteHeader[nb, tag, header] → Null
履歴のヘッダーを書き込む。

### NBHistoryEntriesWithInherit[nb, tag, opts] → List
親履歴を含む全エントリを返す。header の parent/inherit/created に従い親チェーンを辿る。
Options: Decompress -> True

### NBHistoryListTags[nb, prefix] → List
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag] → Null
指定タグの履歴を TaggingRules から削除する。

### NBHistoryReplaceEntries[nb, tag, entries] → Null
エントリリスト全体を置換する。コンパクションやバッチ更新用。

### NBHistoryUpdateHeader[nb, tag, updates] → Null
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加。

### NBHistoryCreate[nb, tag, diffFields] → Association
NBHistoryCreate[nb, tag, diffFields, headerOverrides] → Association
新しい履歴データベースを作成する。diffFields は差分圧縮対象フィールド名リスト (例: `{"fullPrompt", "response", "code"}`)。既存 DB に diffFields がある場合は冪等。

## セッションアタッチメント API

### NBHistoryAddAttachment[nb, tag, path] → Null
セッションヘッダーの "attachments" にパスを追加 (重複除去)。

### NBHistoryRemoveAttachment[nb, tag, path] → Null
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → List
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag] → Null
セッションの全アタッチメントをクリアする。

### NBHistoryClearAll[nb, prefix, opts] → Null
prefix で始まる全履歴を削除する。セルレベルの機密・依存タグは削除しない。
Options: PrivacySpec -> <|"AccessLevel" -> 1.0|> (必須)

## API キーアクセサ

### NBGetAPIKey[provider] → String
AI プロバイダの API キーを返す。provider: "anthropic" | "openai" | "github"。AccessLevel >= 1.0 必須 (PrivacySpec を明示指定)。

### NBGetLocalLLMAPIKey[provider, url] → String
ローカル LLM サーバの API キーを SystemCredential から返す。解決優先度: (1) 完全一致 (2) localhost↔127.0.0.1 置換版 (3) {provider, "*"} ワイルドカード (4) `ToUpperCase[provider]<>"_API_KEY"` フォールバック。AccessLevel >= 1.0 必須。
例: `NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234"]`

### NBSetLocalLLMAPIKey[provider, url, credentialName] → Rule
{provider, url} → credentialName のマッピングを登録。SystemCredential の実値は書き込まない。
→ `{provider, normalizedUrl} -> credentialName`

### NBStoreLocalLLMAPIKey[provider, url, credentialName, key] → Null
上記マッピング登録に加え `SystemCredential[credentialName] = key` も設定。初回セットアップ用。

### NBRemoveLocalLLMAPIKey[provider, url] → Null
{provider, url} のエントリを削除。SystemCredential 本体は変更しない。

### NBLocalLLMAPIKeyMap[] → Dataset
現在登録されているローカル LLM サーバ→API キー名マッピングを Dataset で返す。Configured 列は SystemCredential が設定済みか示す。

### NBLocalLLMCredentialName[provider, url] → String
SystemCredential 名のみを返す (値は取得しない)。AccessLevel チェックなし。

## フォールバックモデル/プロバイダアクセスレベル API

### NBSetFallbackModels[models] → Null
フォールバックモデルリストを設定。models: `{{"provider","model"}, {"provider","model","url"}, ...}`
例: `NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level] → Null
プロバイダの最大アクセスレベル (0.0〜1.0) を設定。これを超えるリクエストにはフォールバックしない。

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダの最大アクセスレベルを返す。未登録は 0.5。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルリストを返す。

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダが指定アクセスレベルのデータにアクセス可能か返す。MaxAccessLevel >= accessLevel なら True。

## アクセス可能ディレクトリ API

### NBSetAccessibleDirs[nb, dirs] → Null
NBSetAccessibleDirs[dirs] → Null
Claude Code が参照可能なディレクトリリストを TaggingRules に保存。引数1個版は EvaluationNotebook[] に保存。

### NBGetAccessibleDirs[nb] → List
NBGetAccessibleDirs[] → List
保存されたアクセス可能ディレクトリリストを返す。

### NBMoveToEnd[nb] → Null
ノートブックの末尾にカーソルを移動する。

## Job 管理 API

### NBBeginJob[nb, evalCell] → String
評価セル直後に3つの不可視スロットセルを挿入しジョブ ID を返す。evalCell が CellObject でない場合はノートブック末尾に挿入。スロット1: システムメッセージ、スロット2: 完了メッセージ、アンカー: レスポンス位置マーカー。

### NBWriteSlot[jobId, slotIdx, cellExpr] → Null
ジョブのスロットに Cell 式を書き込み可視化する。同スロット再書込で上書き。

### NBJobMoveToAnchor[jobId] → Null
アンカーセルの直後にカーソルを移動する。

### NBEndJob[jobId] → Null
ジョブを正常終了。未書込スロットとアンカーを削除しテーブルクリア。

### NBAbortJob[jobId, errorMsg] → Null
エラーメッセージを書き込みジョブを終了する。

### NBBeginJobAtEvalCell[nb] → String
EvaluationCell[] を内部取得しその直後に Job スロットを挿入する。

## 分離 API: claudecode からの間接アクセス

### NBExtractAssignments[text] → List
テキストから Set/SetDelayed の LHS 変数名を抽出する。

### NBSetConfidentialVars[assoc] → Null
機密変数テーブルを一括設定。assoc: `<|"varName" -> True, ...|>`

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBClearConfidentialVars[] → Null
機密変数テーブルをクリアする。

### NBRegisterConfidentialVar[name, level] → Null
機密変数を1つ登録 (level デフォルト 1.0)。

### NBUnregisterConfidentialVar[name] → Null
機密変数を1つ解除する。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

### NBInstallCellEpilog[nb, key, expr] → Null
ノートブックの CellEpilog に式を設定。key は識別用文字列。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilog が key で既にインストール済みか返す。

### NBEvaluatePreviousCell[nb] → Null
直前のセルを選択して評価。$NBAutoEvalProhibitedPatterns に該当する内容はスキップ。

### NBInsertInputTemplate[nb, boxes] → Null
Input セルテンプレートを挿入する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。

## セル書き込み (分離 API 拡張)

### NBWriteCell[nb, cellExpr] → Null
NBWriteCell[nb, cellExpr, pos] → Null
ノートブックに Cell 式を書き込む。pos: After (デフォルト) | Before | All。

### NBWritePrintNotice[nb, text, color] → Null
通知用 Print セルを書き込む。nb=None で CellPrint を使用。

### NBCellPrint[cellExpr] → Null
評価中のセルの直後に出力セルを挿入する (CellPrint ラッパー)。カーソル位置に依存せず常に EvaluationCell 直後に配置。

### NBWriteDynamicCell[nb, dynBoxExpr, tag] → Null
ノートブックに Dynamic セルを書き込む。tag が "" でない場合は CellTags を設定。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate] → Null
ExternalLanguage セルを書き込む。autoEvaluate=True なら直前セルを評価。

### NBInsertAndEvaluateInput[nb, boxes] → Null
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes] → Null
Input セルを After に書き込み Before CellContents にカーソル移動する。

### NBWriteAnchorAfterEvalCell[nb, tag] → Null
EvaluationCell 直後に不可視アンカーセルを書き込む。取得不可なら末尾に書き込む。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol] → Null
機密変数追跡用 CellEpilog をインストール。checkSymbol は FreeQ チェック用マーカーシンボル。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡 CellEpilog がインストール済みか返す。

## Phase 7: Allowed Expression Surface API

### NBValidateHeldExpr[heldExpr, accessSpec, opts] → Association
HoldComplete[...] 式を Allowed Expression Surface に照合し AccessDecision を返す。
→ `<|"Decision" -> "Permit"|"Deny"|"NeedsApproval"|"RepairNeeded", ...|>`

### NBExecuteHeldExpr[heldExpr, accessSpec, opts] → Association
検証済み式を安全に実行し結果を返す。
→ `<|"Success" -> True|False, "RawResult" -> ..., "Error" -> ...|>`

### NBRedactExecutionResult[result, accessSpec, opts] → Association
実行結果を redact し安全な形で返す。
→ `<|"RedactedResult" -> ..., "Summary" -> String|>`

### NBMakeContextPacket[nb, accessSpec, opts] → Association
ノートブックから安全な context packet を構築する。
→ `<|"Input" -> ..., "Cells" -> ..., "AccessSpec" -> ..., ...|>`

### NBRouteDecision[scoreOrAccessSpec] → Association
数値スコアまたは accessSpec から routing 推奨を返す (advisory)。
→ `<|"Route" -> "CloudLLM"|"PrivateLLM"|"LocalOnly", "EffectiveRiskScore" -> n, "Thresholds" -> ..., "Reason" -> String|>`

## Phase 14: Iterative Agent Loop API

### NBInferExprRequirements[heldExpr, accessSpec] → Association
式が必要とするアクセスレベル・書き込みターゲット・参照セル等を静的に推定。
→ `<|"ReadCells" -> {...}, "WriteCells" -> {...}, "RequiredAccessLevel" -> n, "HasSideEffects" -> True|False, ...|>`

### NBReleaseResult[result, accessSpec, opts] → Any
実行結果を指定 sink に安全に release する。redaction + routing check を実行。

### NBMakeRetryPacket[failureAssoc, accessSpec] → Association
失敗情報から秘密を含まない安全な retry packet を構築する。

### NBAuthorize[obj, req] → Association
PolicyGate + ScoreGate + EnvironmentGate を統合した AccessDecision を返す。
→ `<|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval", "ReasonClass" -> ..., "RequiredAction" -> ..., "VisibleExplanation" -> ..., "RouteAdvice" -> ...|>`

### NBPolicyGate[obj, req] → Association
半順序ラベルに基づく flow 判定を返す。PolicyLabel / ContainerLabel / SinkLabel を考慮。

### NBScoreGate[obj, req] → Association
数値スコアに基づく routing/screening 判定を返す (advisory)。

### NBEnvironmentGate[obj, req] → Association
実行環境に基づく制約チェックを返す。Sink / Environment / Principal を考慮。