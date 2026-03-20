# NBAccess API リファレンス

NBAccess は Mathematica ノートブックのセル操作・プライバシーフィルタリング・履歴管理を提供するユーティリティパッケージである。

## グローバル設定

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
デフォルトの PrivacySpec。0.5 はクラウド LLM 安全、1.0 は全データアクセス。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
機密変数名とプライバシーレベルのテーブル。`<|"変数名" -> level, ...|>` 形式。claudecode パッケージが自動更新する。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査で無視するパッケージ名のリスト。

### PrivacySpec (オプション)
多くの関数で使用されるオプション。`PrivacySpec -> <|"AccessLevel" -> 0.5|>` の形式。

## セル情報の取得

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → {Integer...}
選択中セルのインデックスリストを返す。

### NBCellIndicesByTag[nb, tag] → {Integer...}
指定 CellTags を持つセルのインデックスリストを返す。

### NBCellIndicesByStyle[nb, style] → {Integer...}
指定スタイルのセルインデックスリストを返す。style は String または {String...}。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel を返す。ラベルなしの場合は ""。

## セル内容の読み取り

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd 経由で InputText 形式のテキストを取得する。失敗時は NBCellExprToText にフォールバック。

### NBCellExprToText[cellExpr] → String
NotebookRead の結果（Cell 式）からテキストを抽出する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を直接返す。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像（RasterBox/GraphicsBox）を含むか判定する。

### NBCellRasterize[nb, cellIdx, file, opts] → String | $Failed
セルをラスタライズして file に保存する。成功時はファイルパスを返す。

## プライバシー制御

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル（0.0〜1.0）を返す。0.0: 非秘密, 0.75: 依存機密, 1.0: 秘密。

### NBIsAccessible[nb, cellIdx, opts] → Boolean
セルが指定の PrivacySpec でアクセス可能か判定する。
Options: PrivacySpec -> Automatic

### NBFilterCellIndices[nb, indices, opts] → {Integer...}
セルインデックスリストを PrivacySpec でフィルタリングする。
Options: PrivacySpec -> Automatic

### NBGetCells[nb, opts] → {Integer...}
全セルインデックスを PrivacySpec フィルタリング付きで返す。
Options: PrivacySpec -> Automatic

### NBGetContext[nb, afterIdx, opts] → String
afterIdx 以降のセルから LLM プロンプト用コンテキスト文字列を構築する。プライバシーフィルタリングは2段階で行われる:
1. セルレベル（完全除外）: NBCellPrivacyLevel が AccessLevel を超えるセルはテキストを出さず、対応 Output も抑制。
2. 変数名レベル（行単位リダクション）: $NBConfidentialSymbols に登録された変数名を含む行を個別にリダクション。
Options: PrivacySpec -> Automatic

## 機密マーク管理

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
セルの機密タグを返す。

### NBSetConfidentialTag[nb, cellIdx, val] → _
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx]
セルに機密マーク（赤背景 + WarningSign）を付ける。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク（橙背景 + LockIcon）を付ける。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク（視覚・タグ）をすべて解除する。

## セル内容分析

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが機密変数を参照しているか返す。

### NBCellExtractVarNames[nb, cellIdx] → {String...}
セル内容から Set/SetDelayed の LHS 変数名を抽出する。

### NBCellExtractAssignedNames[nb, cellIdx] → {String...}
セル内容から Confidential[] 内の代入先変数名を抽出する。

### NBExtractAssignments[text] → {{lhs, {rhs...}}...}
テキストから代入先変数名と依存変数を抽出する。iExtractAssignments の公開版。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきか返す。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルが Claude 関数呼び出しセル（ClaudeQuery, ClaudeEval 等）か判定する。

## 依存グラフ

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルから変数依存関係グラフを構築する。
→ `<|"var" -> {"dep1", ...}, ...|>`

### NBTransitiveDependents[deps, confVars] → {String...}
deps グラフ上で confVars に直接・間接依存する全変数名を返す。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを内部で計算し、機密変数に依存するセルに NBMarkCellDependent を適用する。新たにマークしたセル数を返す。Claude 関数呼び出しセルは除外される。

### NBScanDependentCells[nb, confVarNames, deps] → Integer
事前計算済みの依存グラフ deps を使うオーバーロード。NBBuildVarDependencies の二重計算を回避する。
```mathematica
deps = NBBuildVarDependencies[nb];
NBScanDependentCells[nb, confVarNames, deps]
```

### NBDependencyEdges[nb] → {DirectedEdge...}
変数依存関係をエッジリストで返す。`DirectedEdge["dep", "var"]` は "var が dep に依存する" を意味する。

### NBDependencyEdges[nb, confVars] → {DirectedEdge...}
機密変数 confVars に関連するエッジのみ返す。

### NBPlotDependencyGraph[nb, opts] → Graphics
変数依存関係グラフを可視化する。直接秘密は赤、依存秘密は橙で着色。
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>`

### NBGetFunctionGlobalDeps[nb] → Association
各関数が依存する大域変数を解析する。
→ `<|"funcName" -> {"globalVar1", ...}, ...|>`

### NBDebugDependencies[nb, confVars]
依存グラフのデバッグ情報を Print で出力する。

## フォールバックモデル / プロバイダーアクセスレベル

### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{"provider","model"}, {"provider","model","url"}, ...}`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0。

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは 0.5。

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダーが指定アクセスレベルのデータにアクセス可能か返す。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのみ返す。

### 内部状態変数
- `$iFallbackModels` — 初期値: `{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}`
- `$iProviderMaxAccessLevel` — 初期値: `<|"claudecode" -> 0.5, "anthropic" -> 0.5, "openai" -> 0.5, "lmstudio" -> 1.0|>`

## 書き込み

### NBWriteText[nb, text, style]
テキストセルを書き込む。style のデフォルトは "Text"。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint パターンを自動検出してスマートに書き込む。

### NBWriteCell[nb, cellExpr, where]
Cell 式を直接書き込む。where のデフォルトは After。Before/All も指定可能。

### NBWritePrintNotice[nb, text, color]
通知用 Print セルを書き込む。nb が None の場合は CellPrint を使用。

### NBWriteDynamicCell[nb, dynBoxExpr, tag, opts]
Dynamic セルを書き込む。tag が "" でない場合は CellTags を設定する。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。autoEvaluate のデフォルトは False。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
カーソル位置の後ろに Input セルを挿入する。autoEvaluate のデフォルトは False。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルに Subsection + Text セルを挿入して保存する。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを挿入して即座に評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを挿入する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセルを書き込む。

## ノートブック TaggingRules

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックの TaggingRules から key の値を返す。key は String または {String...}（ネストパス）。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に値を設定する。key は String または {String...}。

### NBDeleteTaggingRule[nb, key]
TaggingRules からキーを削除する。

### NBListTaggingRuleKeys[nb] → {String...}
TaggingRules の全キーを返す。

### NBListTaggingRuleKeys[nb, prefix] → {String...}
prefix で始まるキーのみ返す。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
セル単位の TaggingRules 値を返す。

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

## 履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存する汎用 API である。

### NBHistoryCreate[nb, tag, diffFields] → Association
新しい履歴データベースを作成する（冪等）。diffFields は差分圧縮対象のフィールド名リスト。

### NBHistoryCreate[nb, tag, diffFields, headerOverrides] → Association
ヘッダーを上書き指定して作成する。

### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加する。差分圧縮を自動適用。
Options: PrivacySpec -> Automatic（privacylevel をエントリに記録）

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを updates で部分更新する。

### NBHistoryEntries[nb, tag, opts] → {Association...}
差分圧縮を復元した全エントリリストを返す。
Options: Decompress -> True（False で Diff オブジェクトのまま返す）

### NBHistoryData[nb, tag, opts] → Association
復元済み全データ `<|"header" -> ..., "entries" -> ...|>` を返す。
Options: Decompress -> True

### NBHistoryRawData[nb, tag] → Association
差分圧縮を解除せずに履歴データを返す（内部用）。キャッシュ付きで、同一セッション内の繰り返し読み取りで FE 通信を削減する。書き込み系関数はキャッシュを自動同期する。

### NBHistoryCacheClear[]
履歴キャッシュを全クリアする。パッケージ再ロードやセッション切替時に使用する。

### NBHistorySetData[nb, tag, data]
全データを書き込む。entries は平文で渡すこと（自動圧縮される）。

### NBHistoryEntriesWithInherit[nb, tag, opts] → {Association...}
親チェーンを辿って全エントリを返す。header の parent/inherit/created に従う。
Options: Decompress -> True

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダーを返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加。

### NBHistoryListTags[nb, prefix] → {String...}
prefix で始まる履歴タグ一覧を返す。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除し、キャッシュも無効化する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。

### セッションアタッチメント

### NBHistoryAddAttachment[nb, tag, path] → {String...}
セッションにファイルをアタッチする。重複除去。

### NBHistoryRemoveAttachment[nb, tag, path] → {String...}
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → {String...}
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリから機密変数の名前・値を含むフィールドをブロックする。

### NBFilterHistoryEntry[entry, confVars, confVarTimes] → Association
confVarTimes（変数名→登録時刻の Association）を指定し、時刻ベースでフィルタを最適化する。

## Job 管理

### NBBeginJob[nb, evalCell] → String
評価セルの直後に3つの不可視スロットセルを挿入しジョブIDを返す。

### NBBeginJobAtEvalCell[nb] → String
EvaluationCell を内部取得して Job を開始する。claudecode が CellObject を保持する必要がない。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。

### NBJobMoveToAnchor[jobId]
アンカーセル直後にカーソルを移動する。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除。

### NBAbortJob[jobId, errorMsg]
エラーメッセージを書き込みジョブを終了する。

## API キー

### NBGetAPIKey[provider, opts] → String | $Failed
AI プロバイダの API キーを SystemCredential から取得する。provider: "anthropic" | "openai" | "github"
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>`

## その他のユーティリティ

### 機密変数の管理

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する。level のデフォルトは 1.0。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。

### NBGetConfidentialVars[] → Association
現在の機密変数テーブルを返す。

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。

### アクセス可能ディレクトリ

### NBSetAccessibleDirs[nb, dirs]
Claude Code が参照可能なディレクトリリストを TaggingRules に保存する。nb 省略時は EvaluationNotebook[]。

### NBGetAccessibleDirs[nb] → {String...}
保存されたアクセス可能ディレクトリリストを返す。nb 省略時は EvaluationNotebook[]。

### カーソル・セル操作

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルを全て削除する。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。

### CellEpilog 管理

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定する。既にインストール済みなら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilog が key で既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストールする。checkSymbol は FreeQ チェック用マーカー。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡 CellEpilog がインストール済みか返す。

### 内部公開関数

### iCellToInputText[cell] → String
FrontEnd 経由でセルの InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。