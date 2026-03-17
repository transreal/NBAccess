# NBAccess 使用例集

このドキュメントでは、NBAccess パッケージの主な使い方を実践的な例で紹介します。
パッケージの詳細は [NBAccess リポジトリ](https://github.com/transreal/NBAccess) を参照してください。

## 前提

```mathematica
Needs["NBAccess`"]
nb = EvaluationNotebook[];
```

---

## 例1: セルの読み取りとテキスト抽出

ノートブック内のセルをインデックス指定で読み取り、テキストとして取得します。

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

AccessLevel を指定して、安全なセルのみを取得します。

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

セルに機密マーク（赤背景）や依存機密マーク（橙背景）を付けます。

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

指定セル以降の内容をプライバシーフィルタ付きで文字列化します。

```mathematica
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];
```

```
(* 例: "In[1]:= Needs[\"NBAccess`\"]\nIn[2]:= x = 42\n..." *)
```

## 例5: セルの書き込み

テキストセルやコードセルをノートブックに追加します。

```mathematica
NBWriteText[nb, "計算結果の説明です。", "Text"];
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2 Pi}]"];
```

```
(* ノートブックにセルが追加されます *)
```

## 例6: 変数依存グラフの解析と可視化

機密変数に依存するセルを自動検出し、依存関係を可視化します。

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

ノートブックの TaggingRules に差分圧縮された履歴を保存・取得します。

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

API キーの安全な取得と、Claude Code が参照可能なディレクトリの管理を行います。

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

---

## 補足: グローバル設定

プライバシーレベルのデフォルトはセッション全体で変更できます。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

関連パッケージ: [claudecode](https://github.com/transreal/claudecode) は NBAccess を内部的に利用し、エンコーディング処理を自動化します。