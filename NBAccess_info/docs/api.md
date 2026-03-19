# NBAccess ユーザーマニュアル

NBAccess は Mathematica ノートブックのセル操作・プライバシーフィルタリング・履歴管理を提供するユーティリティパッケージである。

リポジトリ: https://github.com/transreal/NBAccess

## 目次

1. [グローバル設定](#グローバル設定)
2. [セル情報の取得](#セル情報の取得)
3. [セル内容の読み取り](#セル内容の読み取り)
4. [プライバシー制御](#プライバシー制御)
5. [機密マーク管理](#機密マーク管理)
6. [セル内容分析](#セル内容分析)
7. [依存グラフ](#依存グラフ)
8. [フォールバックモデル / プロバイダーアクセスレベル](#フォールバックモデル--プロバイダーアクセスレベル)
9. [書き込み](#書き込み)
10. [ノートブック TaggingRules](#ノートブック-taggingrules)
11. [履歴データベース](#履歴データベース)
12. [Job 管理](#job-管理)
13. [API キー](#api-キー)
14. [その他のユーティリティ](#その他のユーティリティ)

## グローバル設定

### $NBPrivacySpec

デフォルトの PrivacySpec。初期値は `<|"AccessLevel" -> 0.5|>`（クラウド LLM 安全）。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>
```

### $NBConfidentialSymbols

機密変数名とプライバシーレベルのテーブル。[claudecode](https://github.com/transreal/claudecode) パッケージが自動的に更新する。

### $NBSeparationIgnoreList

分離検査で無視するパッケージ名のリスト。NBAccess と [NotebookExtensions](https://github.com/transreal/NotebookExtensions) はデフォルトで登録済み。

```mathematica
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

## セル情報の取得

### NBCellCount

ノートブックの全セル数を返す。

```mathematica
NBCellCount[nb]
(* 例: 42 *)
```

### NBCurrentCellIndex

EvaluationCell のセルインデックスを返す。見つからない場合は 0。

```mathematica
NBCurrentCellIndex[nb]
```

### NBSelectedCellIndices

選択中セルのインデックスリストを返す。

```mathematica
NBSelectedCellIndices[nb]
(* 例: {3, 4, 5} *)
```

### NBCellIndicesByTag

指定 CellTags を持つセルのインデックスリストを返す。

```mathematica
NBCellIndicesByTag[nb, "myTag"]
```

### NBCellIndicesByStyle

指定スタイルのセルインデックスリストを返す。複数スタイルも指定可能。

```mathematica
NBCellIndicesByStyle[nb, "Input"]
NBCellIndicesByStyle[nb, {"Input", "Code"}]
```

### NBCellStyle / NBCellLabel

セルのスタイルまたはラベルを返す。

```mathematica
NBCellStyle[nb, 3]       (* 例: "Input" *)
NBCellLabel[nb, 3]       (* 例: "In[3]:=" *)
```

## セル内容の読み取り

### NBCellRead

NotebookRead で Cell 式を返す。

```mathematica
NBCellRead[nb, 5]
```

### NBCellReadInputText

FrontEnd 経由で InputText 形式のテキストを取得する。失敗時は NBCellExprToText にフォールバック。

```mathematica
NBCellReadInputText[nb, 5]
(* 例: "Plot[Sin[x], {x, 0, 2Pi}]" *)
```

### NBCellExprToText

NotebookRead の結果（Cell 式）からテキストを抽出する。

```mathematica
cell = NBCellRead[nb, 5];
NBCellExprToText[cell]
```

### NBCellToText

セルのテキスト内容を直接返す。

```mathematica
NBCellToText[nb, 3]
```

### NBCellHasImage

Cell 式が画像を含むか判定する。

```mathematica
NBCellHasImage[NBCellRead[nb, 7]]
(* 例: True *)
```

### NBCellRasterize

セルをラスタライズしてファイルに保存する。

```mathematica
NBCellRasterize[nb, 5, "output.png"]
```

## プライバシー制御

### NBCellPrivacyLevel

セルのプライバシーレベル（0.0〜1.0）を返す。

```mathematica
NBCellPrivacyLevel[nb, 3]
(* 0.0: 非秘密, 0.75: 依存機密, 1.0: 秘密 *)
```

### NBIsAccessible

セルが指定の PrivacySpec でアクセス可能か判定する。

```mathematica
NBIsAccessible[nb, 3, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

### NBFilterCellIndices

セルインデックスリストを PrivacySpec でフィルタリングする。

```mathematica
NBFilterCellIndices[nb, {1, 2, 3, 4}, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
(* 例: {1, 3} — アクセス可能なセルのみ *)
```

### NBGetCells

全セルインデックスを PrivacySpec フィルタリング付きで返す。

```mathematica
NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

### NBGetContext

指定インデックス以降のセルから LLM プロンプト用コンテキスト文字列を構築する。プライバシーフィルタリングは**2段階**で行われる:

1. **セルレベル（完全除外）**: `NBCellPrivacyLevel` が AccessLevel を超えるセルはテキストを一切出力せず、`"In[n]:= (* [機密セル: 非表示] *)"` のみ表示する。対応する Output セルも自動的に抑制される。これにより、`Confidential[]` でマークされたセルや機密変数を直接参照するセルの内容が LLM に送信されることを防ぐ。

2. **変数名レベル（行単位リダクション）**: セルレベルのフィルタを通過したセルに対して、`$NBConfidentialSymbols` に登録された機密変数名を含む行を個別にリダクションする（`iRedactConfidentialLines`）。代入文の場合は `変数名 = (* [機密変数に依存: 値は非表示] *)` に、それ以外は `(* [機密変数を含む行: 非表示] *)` に置換される。依存タグ付きセルの Output も自動抑制される。

```mathematica
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

この2段階方式により、直接機密なセルは内容ごと除外され、間接的に機密変数を参照する行のみが行単位で処理される。

## 機密マーク管理

### NBGetConfidentialTag / NBSetConfidentialTag

セルの機密タグを取得・設定する。

```mathematica
NBGetConfidentialTag[nb, 3]          (* True / False / Missing[] *)
NBSetConfidentialTag[nb, 3, True]
```

### NBMarkCellConfidential

セルに機密マーク（赤背景 + WarningSign）を付ける。

```mathematica
NBMarkCellConfidential[nb, 3]
```

### NBMarkCellDependent

セルに依存機密マーク（橙背景 + LockIcon）を付ける。機密変数に間接依存するセルに使用する。

```mathematica
NBMarkCellDependent[nb, 7]
```

### NBUnmarkCell

セルの機密マーク（視覚・タグ）をすべて解除する。

```mathematica
NBUnmarkCell[nb, 3]
```

## セル内容分析

### NBCellUsesConfidentialSymbol

セルが機密変数を参照しているか返す。

```mathematica
NBCellUsesConfidentialSymbol[nb, 5]
```

### NBCellExtractVarNames / NBCellExtractAssignedNames

セルから変数名を抽出する。

```mathematica
NBCellExtractVarNames[nb, 3]         (* Set/SetDelayed の LHS 変数名 *)
NBCellExtractAssignedNames[nb, 3]    (* Confidential[] 内の代入先変数名 *)
```

### NBExtractAssignments

テキストから代入先変数名と依存変数を抽出する。

```mathematica
NBExtractAssignments["x = 1; y := 2"]
```

### NBShouldExcludeFromPrompt / NBIsClaudeFunctionCell

セルの除外判定・Claude 関数呼び出し判定を行う。

```mathematica
NBShouldExcludeFromPrompt[nb, 3]
NBIsClaudeFunctionCell[nb, 3]
```

## 依存グラフ

### NBBuildVarDependencies

ノートブックの Input セルから変数依存関係グラフを構築する。

```mathematica
NBBuildVarDependencies[nb]
(* <|"y" -> {"x"}, "z" -> {"x", "y"}|> *)
```

### NBTransitiveDependents

機密変数に直接・間接依存する全変数名を返す。

```mathematica
NBTransitiveDependents[deps, {"secretKey"}]
```

### NBScanDependentCells

依存グラフを使って機密変数に依存するセルに自動マークを適用する。

```mathematica
NBScanDependentCells[nb]
(* 例: 3  — 新たにマークしたセル数 *)
```

### NBDependencyEdges

変数依存関係をエッジリストで返す。機密変数でフィルタも可能。

```mathematica
NBDependencyEdges[nb]
NBDependencyEdges[nb, {"secretKey"}]
(* {DirectedEdge["x", "y"], ...} *)
```

### NBPlotDependencyGraph

変数依存関係グラフを可視化する。直接秘密は赤、依存秘密は橙で着色される。

```mathematica
NBPlotDependencyGraph[nb]
```

### NBGetFunctionGlobalDeps

各関数が依存する大域変数を解析する。

```mathematica
NBGetFunctionGlobalDeps[nb]
(* <|"myFunc" -> {"globalVar1", "globalVar2"}|> *)
```

### NBDebugDependencies

依存グラフのデバッグ情報を Print で出力する。

```mathematica
NBDebugDependencies[nb, {"secretKey"}]
```

## フォールバックモデル / プロバイダーアクセスレベル

機密データ（AccessLevel > 0.5）はローカル LLM のみに送信し、非機密データはクラウド LLM にも送信可能にするためのアクセス制御機能である。[claudecode](https://github.com/transreal/claudecode) のフォールバック機構がこの API を利用する。

### 設計思想

プロバイダーごとに「最大アクセスレベル」を設定することで、データの機密度に応じて利用可能なモデルを自動的にフィルタリングする。デフォルトでは:
- `lmstudio`（ローカル LLM）: MaxAccessLevel = 1.0（全データアクセス可）
- `anthropic`, `openai`, `claudecode`（クラウド）: MaxAccessLevel = 0.5（非機密のみ）

### プロバイダーアクセスレベルの設定

各プロバイダーに最大アクセスレベルを設定する。未登録プロバイダーは 0.5 として扱われる。

```mathematica
(* プロバイダーの最大アクセスレベルを設定 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0]   (* ローカル: 全データ可 *)
NBSetProviderMaxAccessLevel["anthropic", 0.5]  (* クラウド: 非機密のみ *)

(* アクセスレベルの取得 *)
NBGetProviderMaxAccessLevel["anthropic"]        (* → 0.5 *)

(* アクセス可否の判定 *)
NBProviderCanAccess["lmstudio", 0.8]            (* → True *)
NBProviderCanAccess["anthropic", 0.8]           (* → False *)
```

### フォールバックモデルリストの管理

メイン LLM（Claude Code）が利用不可の場合に試行するモデルのリストを管理する。各要素は `{"provider", "model"}` または `{"provider", "model", "url"}` の形式。

```mathematica
(* モデルリストの設定 *)
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}
}]

(* モデルリストの取得 *)
NBGetFallbackModels[]
```

### アクセスレベルに応じたモデルフィルタリング

`NBGetAvailableFallbackModels` は、指定アクセスレベルで利用可能なモデルのみを返す。プロバイダーの MaxAccessLevel >= 指定アクセスレベル のモデルのみ含まれる。

```mathematica
(* 機密データ (AccessLevel 0.8) で使えるモデル → ローカル LLM のみ *)
NBGetAvailableFallbackModels[0.8]
(* → {{"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}} *)

(* 非機密データ (AccessLevel 0.5) で使えるモデル → 全プロバイダー *)
NBGetAvailableFallbackModels[0.5]
(* → {{"anthropic", "claude-opus-4-6"}, {"lmstudio", "gpt-oss-20b", ...}} *)
```

### 内部状態変数

- `$iFallbackModels` — フォールバックモデルリスト。初期値: `{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}`
- `$iProviderMaxAccessLevel` — プロバイダー別最大アクセスレベル。初期値: `<|"claudecode" -> 0.5, "anthropic" -> 0.5, "openai" -> 0.5, "lmstudio" -> 1.0|>`

これらは `NBSet*` / `NBGet*` 関数で操作する。直接変更は非推奨。

## 書き込み

### NBWriteText / NBWriteCode

テキストセルまたは Input セルを書き込む。

```mathematica
NBWriteText[nb, "これは説明です", "Text"]
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

### NBWriteSmartCode

CellPrint パターンを自動検出してスマートに書き込む。

```mathematica
NBWriteSmartCode[nb, "Table[i^2, {i, 10}]"]
```

### NBWriteCell

Cell 式を直接書き込む。位置指定も可能。

```mathematica
NBWriteCell[nb, Cell["Hello", "Text"]]
NBWriteCell[nb, Cell["先頭に", "Text"], Before]
```

### NBWritePrintNotice

通知用 Print セルを書き込む。`nb` が `None` の場合は `CellPrint` を使用する。

```mathematica
NBWritePrintNotice[nb, "処理が完了しました", Green]
```

### NBInsertTextCells

.nb ファイルに Subsection + Text セルを挿入して保存する。

```mathematica
NBInsertTextCells["report.nb", "結果", "分析結果を以下に示します"]
```

### NBInsertAndEvaluateInput / NBInsertInputAfter

Input セルを挿入して評価、またはカーソル後に挿入する。

```mathematica
NBInsertAndEvaluateInput[nb, MakeBoxes[1 + 1]]
```

## ノートブック TaggingRules

### NBGetTaggingRule / NBSetTaggingRule

ノートブックの TaggingRules を読み書きする。ネストパスも指定可能。

```mathematica
NBSetTaggingRule[nb, {"project", "name"}, "MyProject"]
NBGetTaggingRule[nb, {"project", "name"}]
(* "MyProject" *)
```

### NBDeleteTaggingRule / NBListTaggingRuleKeys

キーの削除・一覧取得を行う。

```mathematica
NBListTaggingRuleKeys[nb]
NBListTaggingRuleKeys[nb, "project"]
NBDeleteTaggingRule[nb, "oldKey"]
```

### NBCellGetTaggingRule / NBCellSetOptions

セル単位の TaggingRules 取得・オプション設定を行う。

```mathematica
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
NBCellSetOptions[nb, 3, CellStyle -> "Code"]
```

## 履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存する汎用 API である。

### NBHistoryCreate

新しい履歴データベースを作成する（冪等）。

```mathematica
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}]
```

### NBHistoryAppend / NBHistoryUpdateLast

エントリの追加・最後のエントリの更新を行う。

```mathematica
NBHistoryAppend[nb, "chat", <|"role" -> "user", "response" -> "Hello"|>]
NBHistoryUpdateLast[nb, "chat", <|"response" -> "Updated response"|>]
```

### NBHistoryEntries / NBHistoryData

全エントリの取得を行う。`Decompress -> False` で Diff オブジェクトのまま取得できる。

```mathematica
NBHistoryEntries[nb, "chat"]
NBHistoryData[nb, "chat", Decompress -> False]
```

### NBHistoryEntriesWithInherit

親チェーンを辿って全エントリを返す。

```mathematica
NBHistoryEntriesWithInherit[nb, "chat"]
```

### NBHistoryReadHeader / NBHistoryWriteHeader / NBHistoryUpdateHeader

ヘッダーの読み書き・部分更新を行う。

```mathematica
NBHistoryReadHeader[nb, "chat"]
NBHistoryUpdateHeader[nb, "chat", <|"model" -> "claude-opus-4-6"|>]
```

### NBHistoryListTags / NBHistoryDelete / NBHistoryReplaceEntries

タグ一覧・削除・エントリ全置換。

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

## Job 管理

ClaudeQuery / ClaudeEval の非同期出力位置を管理する。

### NBBeginJob / NBEndJob / NBAbortJob

ジョブのライフサイクルを管理する。

```mathematica
jobId = NBBeginJob[nb, EvaluationCell[]]
(* ... 処理 ... *)
NBEndJob[jobId]

(* エラー時 *)
NBAbortJob[jobId, "タイムアウトしました"]
```

### NBWriteSlot

ジョブのスロット（システムメッセージ / 完了メッセージ）に書き込む。

```mathematica
NBWriteSlot[jobId, 1, Cell["処理中...", "Text"]]
```

### NBJobMoveToAnchor

アンカーセル直後にカーソルを移動する。レスポンス書き込み前に呼ぶ。

```mathematica
NBJobMoveToAnchor[jobId]
```

## API キー

### NBGetAPIKey

AI プロバイダの API キーを SystemCredential から取得する。

```mathematica
NBGetAPIKey["anthropic"]
NBGetAPIKey["openai"]
NBGetAPIKey["github"]
```

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

履歴エントリから機密変数の名前・値を含むフィールドをブロックする。

```mathematica
NBFilterHistoryEntry[entry, {"secretKey", "password"}]
```

## 関連パッケージ

- [claudecode](https://github.com/transreal/claudecode) — Claude AI との対話を管理するメインパッケージ
- [NotebookExtensions](https://github.com/transreal/NotebookExtensions) — ノートブック拡張ユーティリティ
- [PresentationListener](https://github.com/transreal/PresentationListener) — プレゼンテーション連携

**=== FILE: examples/example.md ===**

# NBAccess 使用例集

このドキュメントでは、NBAccess パッケージの主な使い方を実践的な例で紹介する。
パッケージの詳細は [NBAccess リポジトリ](https://github.com/transreal/NBAccess) を参照。

## 前提

```mathematica
Needs["NBAccess`"]
nb = EvaluationNotebook[];
```

## 例1: セルの読み取りとテキスト抽出

ノートブック内のセルをインデックス指定で読み取り、テキストとして取得する。

```mathematica
count = NBCellCount[nb];
text = NBCellToText[nb, 1];
style = NBCellStyle[nb, 1];
label = NBCellLabel[nb, 1];
```

```
(* 例: count = 12, text = "Needs[\"NBAccess`\"]", style = "Input", label = "In[1]:=" *)
```

## 例2: プライバシーフィルタリング付きセル一覧

AccessLevel を指定して、安全なセルのみを取得する。

```mathematica
(* クラウド LLM 安全なセルのみ (デフォルト) *)
safeCells = NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* ローカル環境: 全セル取得 *)
allCells = NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 1.0|>];
```

```
(* 例: safeCells = {1, 2, 4, 5}, allCells = {1, 2, 3, 4, 5, 6} *)
```

## 例3: 機密セルのマークと解除

セルに機密マーク（赤背景）や依存機密マーク（橙背景）を付ける。

```mathematica
NBMarkCellConfidential[nb, 3];
NBMarkCellDependent[nb, 5];

(* 確認 *)
NBGetConfidentialTag[nb, 3]
(* マーク解除 *)
NBUnmarkCell[nb, 3];
```

```
(* NBGetConfidentialTag の戻り値: True *)
```

## 例4: LLM プロンプト用コンテキスト構築

指定セル以降の内容をプライバシーフィルタ付きで文字列化する。フィルタリングは2段階で行われる:

1. **セルレベル（完全除外）**: 機密マーク済みセル（`Confidential[]` で定義されたセルや機密変数を直接参照するセル）は `NBCellPrivacyLevel` が AccessLevel を超えるため、テキストを一切出力せず `"In[n]:= (* [機密セル: 非表示] *)"` のみ表示される。対応する Output セルも自動的に抑制される。

2. **変数名レベル（行単位リダクション）**: セルレベルを通過したセルでも、`$NBConfidentialSymbols` に登録された機密変数名を含む行は個別にリダクションされる。

```mathematica
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];
```

```
(* 例: "In[1]:= Needs[\"NBAccess`\"]\nIn[2]:= x = 42\nIn[3]:= (* [機密セル: 非表示] *)\nIn[4]:= y = (* [機密変数に依存: 値は非表示] *)\n..." *)
```

## 例5: セルの書き込み

テキストセルやコードセルをノートブックに追加する。

```mathematica
NBWriteText[nb, "計算結果の説明です。", "Text"];
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2 Pi}]"];
```

```
(* ノートブックにセルが追加される *)
```

## 例6: 変数依存グラフの解析と可視化

機密変数に依存するセルを自動検出し、依存関係を可視化する。

```mathematica
deps = NBBuildVarDependencies[nb];
transitive = NBTransitiveDependents[deps, {"apiKey", "password"}];

(* 依存セルに自動マーク *)
markedCount = NBScanDependentCells[nb];

(* グラフの可視化 *)
NBPlotDependencyGraph[nb]
```

```
(* 例: deps = <|"result" -> {"apiKey"}, ...|>, markedCount = 3 *)
```

## 例7: 汎用履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存・取得する。

```mathematica
NBHistoryCreate[nb, "chat-session-1", {"fullPrompt", "response"}];
NBHistoryAppend[nb, "chat-session-1", <|
  "fullPrompt" -> "Hello",
  "response" -> "Hi there!"
|>];
entries = NBHistoryEntries[nb, "chat-session-1"];
tags = NBHistoryListTags[nb, "chat-"];
```

```
(* 例: entries = {<|"fullPrompt" -> "Hello", "response" -> "Hi there!"|>} *)
```

## 例8: API キー取得とアクセス可能ディレクトリ

API キーの安全な取得と、Claude Code が参照可能なディレクトリの管理を行う。

```mathematica
key = NBGetAPIKey["anthropic"];

NBSetAccessibleDirs[nb, {
  "C:/Projects/myapp",
  "C:/Data/public"
}];
dirs = NBGetAccessibleDirs[nb];
```

```
(* 例: key = "sk-ant-...", dirs = {"C:/Projects/myapp", "C:/Data/public"} *)
```

## 例9: フォールバックモデルとプロバイダーアクセスレベル

機密データはローカル LLM のみに送信し、非機密データはクラウド LLM にも送信可能にするアクセス制御を設定する。[claudecode](https://github.com/transreal/claudecode) のフォールバック機構がこの API を利用する。

```mathematica
(* プロバイダーの最大アクセスレベルを設定 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];   (* ローカル: 全データ可 *)
NBSetProviderMaxAccessLevel["anthropic", 0.5];  (* クラウド: 非機密のみ *)

(* フォールバックモデルリストを設定 *)
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}
}];

(* 現在のモデルリストを確認 *)
NBGetFallbackModels[]
(* → {{"anthropic", "claude-opus-4-6"}, {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}} *)

(* 機密データ (AccessLevel 0.8) で使えるモデルを取得 *)
NBGetAvailableFallbackModels[0.8]
(* → {{"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}} — ローカルのみ *)

(* 非機密データ (AccessLevel 0.5) で使えるモデルを取得 *)
NBGetAvailableFallbackModels[0.5]
(* → 全プロバイダーのモデル *)

(* プロバイダーのアクセス可否を確認 *)
NBProviderCanAccess["lmstudio", 0.8]    (* → True *)
NBProviderCanAccess["anthropic", 0.8]   (* → False *)
```

## 補足: グローバル設定

プライバシーレベルのデフォルトはセッション全体で変更できる。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

関連パッケージ: [claudecode](https://github.com/transreal/claudecode) は NBAccess を内部的に利用し、プライバシーフィルタリングとフォールバック処理を自動化する。

**=== 更新サマリー ===**

| ファイル | 変更内容 |
|----------|----------|
| `user_manual.md` | 目次に「フォールバックモデル / プロバイダーアクセスレベル」セクション追加（項目8）、同セクション新設（設計思想・プロバイダーアクセスレベル設定・モデルリスト管理・アクセスレベルフィルタリング・内部状態変数）、NBGetContext の説明に2段階プライバシーフィルタリング（セルレベル完全除外→変数名レベル行単位リダクション）の詳細動作を追記 |
| `examples/example.md` | 例4（NBGetContext）に機密セルのセルレベル除外と変数名レベルリダクションの説明を追記、出力例にリダクション後の表示を追加。例9「フォールバックモデルとプロバイダーアクセスレベル」を新設（6関数すべての使用例を含む） |
| `api.md` | 変更不要（前回更新で反映済み） |
| `README.md` | 変更不要 |
| `setup.md` | 変更不要 |