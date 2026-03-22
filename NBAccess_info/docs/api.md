# NBAccess API リファレンス

NBAccess は Mathematica ノートブックのセル操作・プライバシーフィルタリング・履歴管理を提供するユーティリティパッケージである。

## グローバル設定

### $NBPrivacySpec
型: Association, 初期値: `<|"AccessLevel" -> 0.5|>`
デフォルトの PrivacySpec。0.5 はクラウド LLM 安全、1.0 は全データアクセス。

### $NBConfidentialSymbols
型: Association, 初期値: `<||>`
機密変数名とプライバシーレベルのテーブル。`<|"変数名" -> level, ...|>` 形式。[claudecode](https://github.com/transreal/claudecode) パッケージが自動更新する。

### $NBSendDataSchema
型: Boolean, 初期値: `True`
秘密依存データのスキーマ情報をクラウド LLM に送信するかを制御する。
True: 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信する（値は含まない）。
False: 秘密依存 Output のスキーマ情報を一切送信しない。
非秘密 Output は常にスマート要約付きで送信される。

### $NBSeparationIgnoreList
型: List, 初期値: `{"NBAccess", "NotebookExtensions"}`
分離検査（ClaudeCheckSeparation）で無視するパッケージ名のリスト。

### PrivacySpec (オプション)
多くの関数で使用されるオプション。`PrivacySpec -> <|"AccessLevel" -> 0.5|>` の形式。
Automatic 指定時は $NBPrivacySpec を使用する。

## セル情報の取得

### NBCellCount[nb] → Integer
ノートブックの全セル数を返す。

### NBCurrentCellIndex[nb] → Integer
EvaluationCell のセルインデックスを返す。見つからない場合は 0。

### NBSelectedCellIndices[nb] → {Integer...}
選択中セルのインデックスリストを返す。セルブラケット選択を優先し、選択がない場合はカーソル位置のセルにフォールバックする。

### NBCellIndicesByTag[nb, tag] → {Integer...}
指定 CellTags を持つセルのインデックスリストを返す。tag は String。

### NBCellIndicesByStyle[nb, style] → {Integer...}
指定スタイルのセルインデックスリストを返す。style は String または {String...}。
内部で NBCellStyle（正規化済み）を使用するため、CellStyle がリスト形式でも正しくマッチする。

### NBCellStyle[nb, cellIdx] → String
セルの CellStyle を返す。CellStyle がリスト `{"Input"}` の場合も先頭要素の文字列を返す。

### NBCellLabel[nb, cellIdx] → String
セルの CellLabel（例: `"In[3]:="`）を返す。ラベルなしの場合は ""。

## セル内容の読み取り

### NBCellRead[nb, cellIdx] → Cell
NotebookRead で Cell 式を返す。

### NBCellReadInputText[nb, cellIdx] → String
FrontEnd`ExportPacket 経由で InputText 形式のテキストを取得する。2D 表示（Sum, Integral 等）も正しく変換される。失敗時は NBCellExprToText にフォールバック。

### NBCellExprToText[cellExpr] → String
NotebookRead の結果（Cell 式）からテキストを抽出する。Cell[BoxData[...]], Cell[String, ...], Cell[TextData[...]] を処理する。

### NBCellToText[nb, cellIdx] → String
セルのテキスト内容を直接返す。内部で NBCellExprToText を使用。

### NBCellHasImage[cellExpr] → Boolean
Cell 式が画像（RasterBox/GraphicsBox）を含むか判定する。$Failed, {} に対しては False を返す。

### NBCellRasterize[nb, cellIdx, file, opts] → String | $Failed
セルを Rasterize して file に PNG 保存する。成功時はファイルパスを返す。
内部で ImageResolution -> 144 を付加する。opts は Rasterize に渡される。

## プライバシー制御

### NBCellPrivacyLevel[nb, cellIdx] → Real
セルのプライバシーレベル（0.0〜1.0）を返す。
0.0: 非秘密（confidential タグが False または未設定で秘密変数非参照）
0.75: 依存機密（dependent タグが True）
1.0: 秘密（confidential タグが True、または秘密変数を参照）

### NBIsAccessible[nb, cellIdx, opts] → Boolean
セルが指定の PrivacySpec でアクセス可能か判定する。NBCellPrivacyLevel <= AccessLevel なら True。
Options: PrivacySpec -> Automatic

### NBFilterCellIndices[nb, indices, opts] → {Integer...}
セルインデックスリストを PrivacySpec でフィルタリングする。
Options: PrivacySpec -> Automatic

### NBGetCells[nb, opts] → {Integer...}
全セルインデックスを PrivacySpec フィルタリング付きで返す。
Options: PrivacySpec -> Automatic

### NBGetContext[nb, afterIdx, opts] → String
ノートブックのセルから LLM プロンプト用コンテキスト文字列を構築する。
Options: PrivacySpec -> Automatic
処理の詳細:
1. Input セル: 全 Input/Code セルを対象とし、プライバシーフィルタリングは2段階で行われる。
   - セルレベル（完全除外）: NBCellPrivacyLevel が AccessLevel を超えるセルはテキストを出さず、対応 Output も抑制。
   - 変数名レベル（行単位リダクション）: $NBConfidentialSymbols に登録された変数名を含む行を個別にリダクション。代入文の LHS は保持し RHS を `(* [機密変数に依存: 値は非表示] *)` に置換。非代入文は `(* [機密変数を含む行: 非表示] *)` に置換。
2. Output セル: afterIdx フィルタなしで全 Output を対象とし、3段階の処理を適用する。
   - 非秘密かつ非抑制 → スマート要約（200文字以下はそのまま、超過時はデータ型・サイズ・先頭100文字プレビュー付き要約）。
   - 秘密依存だが $NBSendDataSchema が True → スキーマ情報のみ送信（データ型・サイズ・キー名等、値は含まない）。
   - それ以外 → 完全スキップ。
3. Message セル: afterIdx 以降のみ対象、PrivacySpec でフィルタリング。Message と MSG スタイルの両方を対象。
戻り値は `=== 実行されたコード ===\n...` `=== エラーメッセージ ===\n...` `=== Output 一覧 ===\n...` を連結した文字列。
スマート要約は内部関数 iDetectDataInfo により以下のデータ型を検出する: Association, Dataset, NestedList/Matrix, List, SparseArray, NumericArray, Graphics/Image。

## 機密マーク管理

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
セルの機密タグを返す。TaggingRules の `{"claudecode", "confidential"}` を参照する。

### NBSetConfidentialTag[nb, cellIdx, val]
セルの機密タグを val (True/False) に設定する。

### NBMarkCellConfidential[nb, cellIdx]
セルに機密マーク（赤背景 + WarningSign）を付ける。confidential タグを True に設定する。

### NBMarkCellDependent[nb, cellIdx]
セルに依存機密マーク（橙背景 + WarningSign）を付ける。confidential タグを True、dependent タグを True に設定する。

### NBUnmarkCell[nb, cellIdx]
セルの機密マーク（視覚・タグ）をすべて解除する。confidential タグを False に設定し、dependent タグを除去し、Background/CellFrame/CellFrameColor/CellDingbat を Inherited に戻す。

## セル内容分析

### NBCellUsesConfidentialSymbol[nb, cellIdx] → Boolean
セルが $NBConfidentialSymbols に登録された機密変数を参照しているか返す。単語境界を考慮した正規表現でマッチする。

### NBCellExtractVarNames[nb, cellIdx] → {String...}
セル内容から Set/SetDelayed の LHS 変数名を抽出する。制御構造名（If, Module 等）は除外される。

### NBCellExtractAssignedNames[nb, cellIdx] → {String...}
セル内容から `var = Confidential[...]` または `Confidential[var = ...]` パターンの代入先変数名を抽出する。

### NBExtractAssignments[text] → {{lhs, {rhs...}}...}
テキストから代入先変数名と RHS 依存変数を抽出する。内部関数 iExtractAssignments の公開版。
文字列リテラル内の識別子は除外される。`Confidential[...]` ラッパーは除去して内部の代入を検出する。
`%n` および `Out[n]` の参照は `"Out$n"` として抽出される。

### NBShouldExcludeFromPrompt[nb, cellIdx] → Boolean
セルがプロンプトから除外すべきか返す。confidential タグが True、または機密変数を参照している場合に True。

### NBIsClaudeFunctionCell[nb, cellIdx] → Boolean
セルが Claude 関数呼び出しセルか判定する。検出対象: ClaudeQuery, ClaudeEval, ContinueEval, ClaudeMath, ClaudeSpec, ClaudeExtractCode, ClaudeExtractAllCode。

## 依存グラフ

### NBBuildVarDependencies[nb] → Association
ノートブックの Input セルから変数依存関係グラフを構築する。
→ `<|"var" -> {"dep1", ...}, ...|>`
InputText 形式で取得するため 2D 表示も正しく解析される。変数代入と関数定義の両方を解析する。
`Out$n` 仮想変数（In[n] の出力に対応）も依存グラフに含める。
文字列リテラル内の識別子は除外される。

### NBBuildGlobalVarDependencies[] → Association
Notebooks[] 全体の Input セルを走査して統合された変数依存関係グラフを返す。
→ `<|"var" -> {"dep1", ...}, ...|>`
LLM 呼び出し直前の精密チェックで使用する。通常のセル実行時は軽量版 NBBuildVarDependencies[nb] を使用すること。

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {Association, Integer}
既存の依存グラフに CellLabel In[x] (x > afterLine) のセルのみを追加走査してマージする。
返り値は {updatedDeps, newLastLine}。
完全なグラフを毎回構築するコストを回避するインクリメンタル版。

### NBTransitiveDependents[deps, confVars] → {String...}
deps グラフ上で confVars に直接・間接依存する全変数名を返す（confVars 自身も含む）。

### NBScanDependentCells[nb, confVarNames] → Integer
依存グラフを内部で計算し、機密変数に依存するセルに NBMarkCellDependent を適用する。新たにマークしたセル数を返す。
処理フロー:
1. 全セルの dependent マークをリセット（Phase 1）
2. 全セルを順次走査し、Input セルの依存判定 → 対応 Output セルをマーク（Phase 2）
   - 直接秘密 Input の Output → 赤マーク（NBMarkCellConfidential）
   - 依存秘密 Input の Output → 橙マーク（NBMarkCellDependent）
   - Claude 関数呼び出しセルは除外
   - 関数定義セルは除外
   - 明示的非秘密マーク（False）のセルは除外

### NBScanDependentCells[nb, confVarNames, deps] → Integer
事前計算済みの依存グラフ deps を使うオーバーロード。NBBuildVarDependencies の二重計算を回避する。
```mathematica
deps = NBBuildVarDependencies[nb];
NBScanDependentCells[nb, confVarNames, deps]
```

### NBDependencyEdges[nb] → {DirectedEdge...}
変数依存関係をエッジリストで返す。`DirectedEdge["dep", "var"]` は "var が dep に依存する" を意味する。

### NBDependencyEdges[nb, confVars] → {DirectedEdge...}
機密変数 confVars に関連するエッジのみ返す。推移的依存変数が関与するエッジのみフィルタする。

### NBPlotDependencyGraph[nb, opts] → Graphics
変数依存関係グラフを可視化する。直接秘密は赤、依存秘密は橙で着色。
`Out$n` は `Out[n]` として表示される。エッジツールチップに依存定義元の `In[xx]` 番号を表示。
全ノートブック（Notebooks[]）から直接秘密変数を収集する。
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>`

### NBGetFunctionGlobalDeps[nb] → Association
各関数定義が依存する大域変数を解析する。
→ `<|"funcName" -> {"globalVar1", ...}, ...|>`
パターン変数とスコーピング局所変数（Module/Block/With/Function）は除外される。

### NBDebugDependencies[nb, confVars]
依存グラフのデバッグ情報を Print で出力する。エッジリスト、変数テーブル、機密/推移的依存変数、関数定義解析、全 Input セル詳細、セル構成を表示する。

## フォールバックモデル / プロバイダーアクセスレベル

### NBSetFallbackModels[models]
フォールバックモデルリストを設定する。models: `{{"provider","model"}, {"provider","model","url"}, ...}`

### NBGetFallbackModels[] → List
フォールバックモデルリスト全体を返す。

### NBSetProviderMaxAccessLevel[provider, level]
プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0（Clip で制限される）。

### NBGetProviderMaxAccessLevel[provider] → Real
プロバイダーの最大アクセスレベルを返す。未登録プロバイダーは 0.5。

### NBProviderCanAccess[provider, accessLevel] → Boolean
プロバイダーが指定アクセスレベルのデータにアクセス可能か返す。MaxAccessLevel >= accessLevel なら True。

### NBGetAvailableFallbackModels[accessLevel] → List
指定アクセスレベルで利用可能なフォールバックモデルのみ返す。

### 内部状態変数
- `$iFallbackModels` — 初期値: `{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}`
- `$iProviderMaxAccessLevel` — 初期値: `<|"claudecode" -> 0.5, "anthropic" -> 0.5, "openai" -> 0.5, "lmstudio" -> 1.0|>`

## 書き込み

### NBWriteText[nb, text, style]
テキストセルを書き込む。style のデフォルトは "Text"。After に書き込む。

### NBWriteCode[nb, code]
構文カラーリング付き Input セルを書き込む。FrontEnd`UndocumentedTestFEParserPacket でパースし、失敗時は MakeBoxes にフォールバック、さらに失敗時はプレーンテキスト Input セルを書き込む。

### NBWriteSmartCode[nb, code]
CellPrint パターンを自動検出してスマートに書き込む。
検出パターン: `CellPrint[cellExpr]`, `CompoundExpression[CellPrint[cellExpr], rest]`。
検出できない場合は NBWriteCode にフォールバック。

### NBWriteCell[nb, cellExpr, where]
Cell 式を直接書き込む。where のデフォルトは After。Before/All も指定可能。

### NBWritePrintNotice[nb, text, color]
通知用 Print セルを書き込む（FontWeight -> Bold, FontSize -> 11）。nb が None の場合は CellPrint を使用する。

### NBWriteDynamicCell[nb, dynBoxExpr, tag, opts]
Dynamic セルを書き込む（"Print" スタイル）。tag が "" でない場合は CellTags を設定する。opts は Cell に渡される。

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
ExternalLanguage セルを書き込む。CellEvaluationLanguage -> lang を設定する。autoEvaluate のデフォルトは False。True の場合は書き込み後に直前セルを評価する。

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
カーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭（Before CellContents）に移動する。autoEvaluate のデフォルトは False。True の場合は SelectionEvaluate を実行する。

### NBInsertTextCells[nbFile, name, prompt]
.nb ファイルを非表示で開き、末尾に Subsection セル（"Package: " <> name）と Text セル（prompt）を挿入して保存・閉じる。

### NBInsertAndEvaluateInput[nb, boxes]
Input セルを After に書き込み即座に SelectionEvaluate で評価する。

### NBInsertInputAfter[nb, boxes]
Input セルを After に書き込み Before CellContents に移動する。

### NBInsertInputTemplate[nb, boxes]
Input セルテンプレートを All で書き込み、All CellContents を選択する。

### NBWriteAnchorAfterEvalCell[nb, tag]
EvaluationCell 直後に不可視アンカーセル（CellOpen -> False）を書き込む。EvaluationCell が取得できない場合はノートブック末尾に書き込む。

## ノートブック TaggingRules

### NBGetTaggingRule[nb, key] → value | Missing[]
ノートブックの TaggingRules から key の値を返す。key は String または {String...}（ネストパス）。Inherited や未解決の CurrentValue は Missing[] として返す。

### NBSetTaggingRule[nb, key, value]
ノートブックの TaggingRules に値を設定する。key は String または {String...}。

### NBDeleteTaggingRule[nb, key]
TaggingRules からキーを削除する。Association 形式と List 形式の両方に対応。

### NBListTaggingRuleKeys[nb] → {String...}
TaggingRules の全キーを返す。

### NBListTaggingRuleKeys[nb, prefix] → {String...}
prefix で始まるキーのみ返す。

### NBCellGetTaggingRule[nb, cellIdx, path] → value
セル単位の TaggingRules 値を返す。path は String または {String...}。
```mathematica
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
```

### NBCellSetOptions[nb, cellIdx, opts]
セルに SetOptions を適用する。

## 履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存する汎用 API である。
Decompress オプションは System`Decompress シンボルをラベルとして使用する（新規シンボルは定義しない）。

### NBHistoryCreate[nb, tag, diffFields] → Association
新しい履歴データベースを作成する（冪等）。diffFields は差分圧縮対象のフィールド名リスト。
既存 DB に diffFields が設定済みなら既存ヘッダーをそのまま返す。
ヘッダーの初期値: `<|"type" -> "history_header", "name" -> "$default", "parent" -> None, "inherit" -> True, "created" -> AbsoluteTime[], "diffFields" -> diffFields|>`

### NBHistoryCreate[nb, tag, diffFields, headerOverrides] → Association
ヘッダーを上書き指定して作成する。headerOverrides のキーがデフォルトヘッダーを上書きする。

### NBHistoryAppend[nb, tag, entry, opts]
エントリを履歴に追加する。差分圧縮を自動適用（二つ前のエントリが未圧縮なら直前エントリとの Diff で圧縮）。
Options: PrivacySpec -> Automatic（privacylevel をエントリに記録）

### NBHistoryUpdateLast[nb, tag, updates]
最後のエントリを updates で部分更新する。Merge[{lastEntry, updates}, Last] で更新。

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
全データを書き込む。entries は平文で渡すこと（iCompressAllEntries で自動圧縮される）。

### NBHistoryEntriesWithInherit[nb, tag, opts] → {Association...}
親チェーンを辿って全エントリを返す。header の parent/inherit/created に従う。
inherit が False または parent が None の場合は自身のエントリのみ返す。
親履歴のエントリは created 時刻以前のもののみ含む。
Options: Decompress -> True

### NBHistoryReadHeader[nb, tag] → Association
履歴のヘッダーを返す。未設定時はデフォルトヘッダーを返す。

### NBHistoryWriteHeader[nb, tag, header]
履歴のヘッダーを書き込む。

### NBHistoryUpdateHeader[nb, tag, updates]
ヘッダーにキーを追加・更新する。既存キーは上書き、新規キーは追加。Merge[{hdr, updates}, Last] で更新。

### NBHistoryListTags[nb, prefix] → {String...}
prefix で始まる履歴タグ一覧を返す。内部で NBListTaggingRuleKeys を使用。

### NBHistoryDelete[nb, tag]
指定タグの履歴を TaggingRules から削除し、キャッシュも無効化する。

### NBHistoryReplaceEntries[nb, tag, entries]
エントリリスト全体を置換する。圧縮は行わない（そのまま格納）。コンパクションやバッチ更新に使用する。

### セッションアタッチメント

### NBHistoryAddAttachment[nb, tag, path] → {String...}
セッションにファイルをアタッチする。ExpandFileName で正規化し、重複除去する。

### NBHistoryRemoveAttachment[nb, tag, path] → {String...}
セッションからファイルをデタッチする。

### NBHistoryGetAttachments[nb, tag] → {String...}
セッションのアタッチメントリストを返す。

### NBHistoryClearAttachments[nb, tag]
セッションの全アタッチメントをクリアする。

### NBFilterHistoryEntry[entry, confVars] → Association
履歴エントリから機密変数の名前・値を含むフィールドをブロックする。response と code フィールドを検査する。

### NBFilterHistoryEntry[entry, confVars, confVarTimes] → Association
confVarTimes（変数名→登録時刻の Association）を指定し、時刻ベースでフィルタを最適化する。エントリの time が全機密変数の最小登録時刻より後の場合はフィルタをスキップする。

## Job 管理

### NBBeginJob[nb, evalCell] → String
評価セルの直後に3つの不可視スロットセルを挿入しジョブIDを返す。evalCell が CellObject でない場合はノートブック末尾に挿入する。
スロット1: システムメッセージ（プログレス・フォールバック通知）
スロット2: 完了メッセージ
アンカー: レスポンス書き込み位置マーカー

### NBBeginJobAtEvalCell[nb] → String
EvaluationCell を内部取得して Job を開始する。[claudecode](https://github.com/transreal/claudecode) が CellObject を保持する必要がない。

### NBWriteSlot[jobId, slotIdx, cellExpr]
ジョブのスロットに Cell 式を書き込み可視にする。同じスロットに再度書き込むと上書きされる。CellTags は自動付与される。

### NBJobMoveToAnchor[jobId]
アンカーセル直後にカーソルを移動する。レスポンスコンテンツの書き込み前に呼ぶ。

### NBEndJob[jobId]
ジョブを正常終了する。未書き込みスロットとアンカーを削除し、$NBJobTable からエントリを除去する。

### NBAbortJob[jobId, errorMsg]
最初の未書き込みスロットにエラーメッセージ（赤太字）を書き込み、NBEndJob でクリーンアップする。

## API キー

### NBGetAPIKey[provider, opts] → String | $Failed
AI プロバイダの API キーを SystemCredential から取得する。
provider: "anthropic" → ANTHROPIC_API_KEY, "openai" → OPENAI_API_KEY, "github"/"gh"/"github_pat" → GITHUB_TOKEN
AccessLevel < 1.0 の場合は $Failed を返す（API キーは常に秘密データ扱い）。
Options: PrivacySpec -> `<|"AccessLevel" -> 1.0|>`

## その他のユーティリティ

### 機密変数の管理

### NBRegisterConfidentialVar[name, level]
機密変数を1つ登録する。level のデフォルトは 1.0。$NBConfidentialSymbols に追加。

### NBUnregisterConfidentialVar[name]
機密変数を1つ解除する。$NBConfidentialSymbols から除去。

### NBGetConfidentialVars[] → Association
現在の $NBConfidentialSymbols を返す。未初期化時は `<||>` を返す。

### NBSetConfidentialVars[assoc]
機密変数テーブルを一括設定する。

### NBClearConfidentialVars[]
機密変数テーブルをクリアする（`<||>` にリセット）。

### NBGetPrivacySpec[] → Association
現在の $NBPrivacySpec を返す。未初期化時は `<|"AccessLevel" -> 0.5|>` を返す。

### アクセス可能ディレクトリ

### NBSetAccessibleDirs[nb, dirs]
Claude Code が参照可能なディレクトリリストを TaggingRules の "claudeAccessibleDirs" に保存する。

### NBSetAccessibleDirs[dirs]
nb を省略した場合は EvaluationNotebook[] に保存する。

### NBGetAccessibleDirs[nb] → {String...}
保存されたアクセス可能ディレクトリリストを返す。

### NBGetAccessibleDirs[] → {String...}
nb を省略した場合は EvaluationNotebook[] から取得する。

### カーソル・セル操作

### NBMoveToEnd[nb]
ノートブックの末尾にカーソルを移動する。

### NBMoveAfterCell[nb, cellIdx]
セルの後ろにカーソルを移動する。

### NBDeleteCellsByTag[nb, tag]
指定 CellTags を持つセルを全て削除する。

### NBEvaluatePreviousCell[nb]
直前のセルを選択して評価し、After Cell にカーソルを移動する。

### NBParentNotebookOfCurrentCell[] → NotebookObject
EvaluationCell の親ノートブックを返す。取得失敗時は InputNotebook[] にフォールバック。

### CellEpilog 管理

### NBInstallCellEpilog[nb, key, expr]
ノートブックの CellEpilog に式を設定する。key は識別用文字列。既にインストール済み（FreeQ で key を検出）なら何もしない。

### NBCellEpilogInstalledQ[nb, key] → Boolean
CellEpilog が key で既にインストールされているか返す。

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
機密変数追跡用 CellEpilog をインストールする。checkSymbol は FreeQ チェック用マーカーシンボル。既にインストール済みなら何もしない。

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → Boolean
機密追跡 CellEpilog がインストール済みか返す。checkSymbol は FreeQ チェック用のマーカーシンボル。

### 内部公開関数

### iCellToInputText[cell] → String
FrontEnd`ExportPacket 経由でセルの InputText 形式を取得する。失敗時は NBCellExprToText にフォールバック。`NBAccess`iCellToInputText` として公開。