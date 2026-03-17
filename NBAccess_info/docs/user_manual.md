# NBAccess ユーザーマニュアル

NBAccess は Mathematica ノートブックのセル操作・プライバシーフィルタリング・履歴管理を提供するユーティリティパッケージです。

リポジトリ: https://github.com/transreal/NBAccess

## 目次

1. [グローバル設定](#グローバル設定)
2. [セル情報の取得](#セル情報の取得)
3. [セル内容の読み取り](#セル内容の読み取り)
4. [プライバシー制御](#プライバシー制御)
5. [機密マーク管理](#機密マーク管理)
6. [セル内容分析](#セル内容分析)
7. [依存グラフ](#依存グラフ)
8. [書き込み](#書き込み)
9. [ノートブック TaggingRules](#ノートブック-taggingrules)
10. [履歴データベース](#履歴データベース)
11. [Job 管理](#job-管理)
12. [API キー](#api-キー)
13. [その他のユーティリティ](#その他のユーティリティ)

---

## グローバル設定

### $NBPrivacySpec

デフォルトの PrivacySpec です。初期値は `<|"AccessLevel" -> 0.5|>` (クラウド LLM 安全) です。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>
```

### $NBConfidentialSymbols

機密変数名とプライバシーレベルのテーブルです。[claudecode](https://github.com/transreal/claudecode) パッケージが自動的に更新します。

### $NBSeparationIgnoreList

分離検査で無視するパッケージ名のリストです。NBAccess と [NotebookExtensions](https://github.com/transreal/NotebookExtensions) はデフォルトで登録されています。

```mathematica
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

---

## セル情報の取得

### NBCellCount

ノートブックの全セル数を返します。

```mathematica
NBCellCount[nb]
(* 例: 42 *)
```

### NBCurrentCellIndex

EvaluationCell のセルインデックスを返します。見つからない場合は 0 です。

```mathematica
NBCurrentCellIndex[nb]
```

### NBSelectedCellIndices

選択中セルのインデックスリストを返します。

```mathematica
NBSelectedCellIndices[nb]
(* 例: {3, 4, 5} *)
```

### NBCellIndicesByTag

指定 CellTags を持つセルのインデックスリストを返します。

```mathematica
NBCellIndicesByTag[nb, "myTag"]
```

### NBCellIndicesByStyle

指定スタイルのセルインデックスリストを返します。複数スタイルも指定可能です。

```mathematica
NBCellIndicesByStyle[nb, "Input"]
NBCellIndicesByStyle[nb, {"Input", "Code"}]
```

### NBCellStyle / NBCellLabel

セルのスタイルまたはラベルを返します。

```mathematica
NBCellStyle[nb, 3]       (* 例: "Input" *)
NBCellLabel[nb, 3]       (* 例: "In[3]:=" *)
```

---

## セル内容の読み取り

### NBCellRead

NotebookRead で Cell 式を返します。

```mathematica
NBCellRead[nb, 5]
```

### NBCellReadInputText

FrontEnd 経由で InputText 形式のテキストを取得します。失敗時は NBCellExprToText にフォールバックします。

```mathematica
NBCellReadInputText[nb, 5]
(* 例: "Plot[Sin[x], {x, 0, 2Pi}]" *)
```

### NBCellExprToText

NotebookRead の結果 (Cell 式) からテキストを抽出します。

```mathematica
cell = NBCellRead[nb, 5];
NBCellExprToText[cell]
```

### NBCellToText

セルのテキスト内容を直接返します。

```mathematica
NBCellToText[nb, 3]
```

### NBCellHasImage

Cell 式が画像を含むか判定します。

```mathematica
NBCellHasImage[NBCellRead[nb, 7]]
(* 例: True *)
```

### NBCellRasterize

セルをラスタライズしてファイルに保存します。

```mathematica
NBCellRasterize[nb, 5, "output.png"]
```

---

## プライバシー制御

### NBCellPrivacyLevel

セルのプライバシーレベル (0.0〜1.0) を返します。

```mathematica
NBCellPrivacyLevel[nb, 3]
(* 0.0: 非秘密, 1.0: 秘密 *)
```

### NBIsAccessible

セルが指定の PrivacySpec でアクセス可能か判定します。

```mathematica
NBIsAccessible[nb, 3, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

### NBFilterCellIndices

セルインデックスリストを PrivacySpec でフィルタリングします。

```mathematica
NBFilterCellIndices[nb, {1, 2, 3, 4}, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
(* 例: {1, 3} — アクセス可能なセルのみ *)
```

### NBGetCells

全セルインデックスを PrivacySpec フィルタリング付きで返します。

```mathematica
NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

### NBGetContext

指定インデックス以降のセルから LLM プロンプト用コンテキスト文字列を構築します。

```mathematica
NBGetContext[nb, 5, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

---

## 機密マーク管理

### NBGetConfidentialTag / NBSetConfidentialTag

セルの機密タグを取得・設定します。

```mathematica
NBGetConfidentialTag[nb, 3]          (* True / False / Missing[] *)
NBSetConfidentialTag[nb, 3, True]
```

### NBMarkCellConfidential

セルに機密マーク（赤背景 + WarningSign）を付けます。

```mathematica
NBMarkCellConfidential[nb, 3]
```

### NBMarkCellDependent

セルに依存機密マーク（橙背景 + LockIcon）を付けます。機密変数に間接依存するセルに使用します。

```mathematica
NBMarkCellDependent[nb, 7]
```

### NBUnmarkCell

セルの機密マーク（視覚・タグ）をすべて解除します。

```mathematica
NBUnmarkCell[nb, 3]
```

---

## セル内容分析

### NBCellUsesConfidentialSymbol

セルが機密変数を参照しているか返します。

```mathematica
NBCellUsesConfidentialSymbol[nb, 5]
```

### NBCellExtractVarNames / NBCellExtractAssignedNames

セルから変数名を抽出します。

```mathematica
NBCellExtractVarNames[nb, 3]         (* Set/SetDelayed の LHS 変数名 *)
NBCellExtractAssignedNames[nb, 3]    (* Confidential[] 内の代入先変数名 *)
```

### NBExtractAssignments

テキストから代入先変数名を抽出します。

```mathematica
NBExtractAssignments["x = 1; y := 2"]
(* {"x", "y"} *)
```

### NBShouldExcludeFromPrompt / NBIsClaudeFunctionCell

セルの除外判定・Claude 関数呼び出し判定を行います。

```mathematica
NBShouldExcludeFromPrompt[nb, 3]
NBIsClaudeFunctionCell[nb, 3]
```

---

## 依存グラフ

### NBBuildVarDependencies

ノートブックの Input セルから変数依存関係グラフを構築します。

```mathematica
NBBuildVarDependencies[nb]
(* <|"y" -> {"x"}, "z" -> {"x", "y"}|> *)
```

### NBTransitiveDependents

機密変数に直接・間接依存する全変数名を返します。

```mathematica
NBTransitiveDependents[deps, {"secretKey"}]
```

### NBScanDependentCells

依存グラフを使って機密変数に依存するセルに自動マークを適用します。

```mathematica
NBScanDependentCells[nb]
(* 例: 3  — 新たにマークしたセル数 *)
```

### NBDependencyEdges

変数依存関係をエッジリストで返します。機密変数でフィルタも可能です。

```mathematica
NBDependencyEdges[nb]
NBDependencyEdges[nb, {"secretKey"}]
(* {DirectedEdge["x", "y"], ...} *)
```

### NBPlotDependencyGraph

変数依存関係グラフを可視化します。直接秘密は赤、依存秘密は橙で着色されます。

```mathematica
NBPlotDependencyGraph[nb]
```

### NBGetFunctionGlobalDeps

各関数が依存する大域変数を解析します。

```mathematica
NBGetFunctionGlobalDeps[nb]
(* <|"myFunc" -> {"globalVar1", "globalVar2"}|> *)
```

### NBDebugDependencies

依存グラフのデバッグ情報を Print で出力します。

```mathematica
NBDebugDependencies[nb, {"secretKey"}]
```

---

## 書き込み

### NBWriteText / NBWriteCode

テキストセルまたは Input セルを書き込みます。

```mathematica
NBWriteText[nb, "これは説明です", "Text"]
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

### NBWriteSmartCode

CellPrint パターンを自動検出してスマートに書き込みます。

```mathematica
NBWriteSmartCode[nb, "Table[i^2, {i, 10}]"]
```

### NBWriteCell

Cell 式を直接書き込みます。位置指定も可能です。

```mathematica
NBWriteCell[nb, Cell["Hello", "Text"]]
NBWriteCell[nb, Cell["Hello", "Text"], Before]
```

### NBWritePrintNotice

通知用 Print セルを書き込みます。

```mathematica
NBWritePrintNotice[nb, "処理が完了しました", Green]
```

### NBInsertTextCells

.nb ファイルに Subsection + Text セルを挿入して保存します。

```mathematica
NBInsertTextCells["report.nb", "結果", "分析結果を以下に示します"]
```

### NBInsertAndEvaluateInput / NBInsertInputAfter

Input セルを挿入して評価、またはカーソル後に挿入します。

```mathematica
NBInsertAndEvaluateInput[nb, MakeBoxes[1 + 1]]
```

---

## ノートブック TaggingRules

### NBGetTaggingRule / NBSetTaggingRule

ノートブックの TaggingRules を読み書きします。ネストパスも指定可能です。

```mathematica
NBSetTaggingRule[nb, {"project", "name"}, "MyProject"]
NBGetTaggingRule[nb, {"project", "name"}]
(* "MyProject" *)
```

### NBDeleteTaggingRule / NBListTaggingRuleKeys

キーの削除・一覧取得を行います。

```mathematica
NBListTaggingRuleKeys[nb]
NBListTaggingRuleKeys[nb, "project"]
NBDeleteTaggingRule[nb, "oldKey"]
```

### NBCellGetTaggingRule / NBCellSetOptions

セル単位の TaggingRules 取得・オプション設定を行います。

```mathematica
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
NBCellSetOptions[nb, 3, CellStyle -> "Code"]
```

---

## 履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存する汎用 API です。

### NBHistoryCreate

新しい履歴データベースを作成します（冪等）。

```mathematica
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}]
```

### NBHistoryAppend / NBHistoryUpdateLast

エントリの追加・最後のエントリの更新を行います。

```mathematica
NBHistoryAppend[nb, "chat", <|"role" -> "user", "response" -> "Hello"|>]
NBHistoryUpdateLast[nb, "chat", <|"response" -> "Updated response"|>]
```

### NBHistoryEntries / NBHistoryData

全エントリの取得を行います。`Decompress -> False` で Diff オブジェクトのまま取得できます。

```mathematica
NBHistoryEntries[nb, "chat"]
NBHistoryData[nb, "chat", Decompress -> False]
```

### NBHistoryEntriesWithInherit

親チェーンを辿って全エントリを返します。

```mathematica
NBHistoryEntriesWithInherit[nb, "chat"]
```

### NBHistoryReadHeader / NBHistoryWriteHeader / NBHistoryUpdateHeader

ヘッダーの読み書き・部分更新を行います。

```mathematica
NBHistoryReadHeader[nb, "chat"]
NBHistoryUpdateHeader[nb, "chat", <|"model" -> "claude-opus-4-6"|>]
```

### NBHistoryListTags / NBHistoryDelete / NBHistoryReplaceEntries

タグ一覧・削除・エントリ全置換です。

```mathematica
NBHistoryListTags[nb, "chat"]
NBHistoryDelete[nb, "chat-old"]
```

### セッションアタッチメント

```mathematica
NBHistoryAddAttachment[nb, "chat", "/path/to/file.pdf"]
NBHistoryGetAttachments[nb, "chat"]
NBHistoryRemoveAttachment[nb, "chat", "/path/to/file.pdf"]
NBHistoryClearAttachments[nb, "chat"]
```

---

## Job 管理

ClaudeQuery / ClaudeEval の非同期出力位置を管理します。

### NBBeginJob / NBEndJob / NBAbortJob

ジョブのライフサイクルを管理します。

```mathematica
jobId = NBBeginJob[nb, EvaluationCell[]]
(* ... 処理 ... *)
NBEndJob[jobId]

(* エラー時 *)
NBAbortJob[jobId, "タイムアウトしました"]
```

### NBWriteSlot

ジョブのスロット（システムメッセージ / 完了メッセージ）に書き込みます。

```mathematica
NBWriteSlot[jobId, 1, Cell["処理中...", "Text"]]
```

### NBJobMoveToAnchor

アンカーセル直後にカーソルを移動します。レスポンス書き込み前に呼びます。

```mathematica
NBJobMoveToAnchor[jobId]
```

---

## API キー

### NBGetAPIKey

AI プロバイダの API キーを SystemCredential から取得します。

```mathematica
NBGetAPIKey["anthropic"]
NBGetAPIKey["openai"]
NBGetAPIKey["github"]
```

---

## その他のユーティリティ

### 機密変数の管理

```mathematica
NBRegisterConfidentialVar["apiKey", 1.0]
NBUnregisterConfidentialVar["apiKey"]
NBGetConfidentialVars[]
NBSetConfidentialVars[<|"secret1" -> True, "secret2" -> True|>]
NBClearConfidentialVars[]
```

### アクセス可能ディレクトリ

```mathematica
NBSetAccessibleDirs[nb, {"/home/user/project", "/data"}]
NBGetAccessibleDirs[nb]
```

### カーソル・セル操作

```mathematica
NBMoveToEnd[nb]                    (* 末尾に移動 *)
NBMoveAfterCell[nb, 5]            (* セル5の後ろに移動 *)
NBDeleteCellsByTag[nb, "temp"]    (* タグで一括削除 *)
NBEvaluatePreviousCell[nb]        (* 直前セルを評価 *)
```

### CellEpilog 管理

```mathematica
NBInstallCellEpilog[nb, "myHook", expr]
NBCellEpilogInstalledQ[nb, "myHook"]
NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
```

### NBFilterHistoryEntry

履歴エントリから機密変数の名前・値を含むフィールドをブロックします。

```mathematica
NBFilterHistoryEntry[entry, {"secretKey", "password"}]
```

---

## 関連パッケージ

- [claudecode](https://github.com/transreal/claudecode) — Claude AI との対話を管理するメインパッケージ
- [NotebookExtensions](https://github.com/transreal/NotebookExtensions) — ノートブック拡張ユーティリティ
- [PresentationListener](https://github.com/transreal/PresentationListener) — プレゼンテーション連携