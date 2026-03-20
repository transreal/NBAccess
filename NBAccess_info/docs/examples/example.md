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

セルに機密マーク（赤背景 + WarningSign）や依存機密マーク（橙背景 + LockIcon）を付けます。

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
`NBGetContext` は **2段階のプライバシーフィルタリング** を適用します:

1. **セルレベルフィルタリング**: 機密マーク（`NBMarkCellConfidential`）が付いたセルや、プライバシーレベルが AccessLevel を超えるセルは **コード全体が除外** されます。対応する Output セルも同時に抑制されます。除外されたセルはラベルのみ残り `(* [機密セル: 非表示] *)` と表示されます。
2. **変数名レベルリダクション**: セル自体は機密マークされていなくても、`$NBConfidentialSymbols` に登録された機密変数を参照する行は個別にリダクションされます。代入文の場合は `変数名 = (* [機密変数に依存: 値は非表示] *)` に、それ以外は `(* [機密変数を含む行: 非表示] *)` に置換されます。

```mathematica
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];
```

```
(* 例: 機密セル (In[3]) は除外され、機密変数参照行はリダクションされた文字列:
   "=== 実行されたコード ===
    In[1]:= Needs[\"NBAccess`\"]
    In[2]:= x = 42
    In[3]:= (* [機密セル: 非表示] *)
    In[4]:= result = (* [機密変数に依存: 値は非表示] *)
    ..." *)
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

(* 依存セルに自動マーク — deps を事前計算して渡すことで二重計算を回避 *)
markedCount = NBScanDependentCells[nb, {"apiKey", "password"}, deps];

(* deps を省略した従来互換の呼び出しも可能 *)
markedCount = NBScanDependentCells[nb, {"apiKey", "password"}];

(* グラフの可視化 *)
NBPlotDependencyGraph[nb]
```

```
(* 例: deps = <|"result" -> {"apiKey"}, ...|>, markedCount = 3 *)
```

## 例7: 汎用履歴データベース

ノートブックの TaggingRules に差分圧縮された履歴を保存・取得します。
履歴データの読み取りにはキャッシュが利用され、同一セッション内で同じ履歴を複数回読み取る場合の FrontEnd 通信が削減されます。

```mathematica
NBHistoryCreate[nb, "chat-session-1", {"fullPrompt", "response"}];
NBHistoryAppend[nb, "chat-session-1", <|
  "fullPrompt" -> "Hello",
  "response" -> "Hi there!"
|>];
entries = NBHistoryEntries[nb, "chat-session-1"];
tags = NBHistoryListTags[nb, "chat-"];

(* キャッシュのクリア（パッケージ再ロード・セッション切替時などに使用） *)
NBHistoryCacheClear[];
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

## 例9: フォールバックモデルとプロバイダーアクセスレベル

メインの LLM が利用できない場合のフォールバックモデルを設定し、プロバイダーごとにアクセス可能なデータレベルを制御します。

```mathematica
(* フォールバックモデルリストの設定 *)
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"openai", "gpt-5"},
  {"lmstudio", "local-model-7b", "http://127.0.0.1:1234"}
}];

(* 現在のフォールバックモデルリストを確認 *)
NBGetFallbackModels[]
```

```
(* 戻り値: {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"},
            {"lmstudio", "local-model-7b", "http://127.0.0.1:1234"}} *)
```

```mathematica
(* プロバイダーごとの最大アクセスレベルを設定 *)
(* クラウドプロバイダーには機密データを送らない (0.5) *)
NBSetProviderMaxAccessLevel["anthropic", 0.5];
NBSetProviderMaxAccessLevel["openai", 0.5];
(* ローカル LLM には全データを許可 (1.0) *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];

(* 特定プロバイダーのアクセスレベルを確認 *)
NBGetProviderMaxAccessLevel["lmstudio"]
(* 戻り値: 1.0 *)

(* プロバイダーが機密データにアクセスできるか判定 *)
NBProviderCanAccess["anthropic", 0.8]
(* 戻り値: False — anthropic の MaxAccessLevel は 0.5 *)

NBProviderCanAccess["lmstudio", 0.8]
(* 戻り値: True — lmstudio の MaxAccessLevel は 1.0 *)
```

```mathematica
(* 機密データを含むリクエストで利用可能なモデルのみ取得 *)
NBGetAvailableFallbackModels[0.8]
(* 戻り値: {{"lmstudio", "local-model-7b", "http://127.0.0.1:1234"}} *)
(* → lmstudio のみ。anthropic/openai は MaxAccessLevel=0.5 なので除外 *)

(* 非機密データなら全モデルが利用可能 *)
NBGetAvailableFallbackModels[0.5]
(* 戻り値: {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"},
            {"lmstudio", "local-model-7b", "http://127.0.0.1:1234"}} *)
```

---

## 補足: グローバル設定

プライバシーレベルのデフォルトはセッション全体で変更できます。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

関連パッケージ: [claudecode](https://github.com/transreal/claudecode) は NBAccess を内部的に利用し、エンコーディング処理を自動化します。

---

## Updated: user_manual.md

以下は `user_manual.md` の更新内容です。既存の構造を維持しつつ、以下のセクションを追加・更新してください。

### 追加セクション: フォールバックモデル / プロバイダーアクセスレベル API

以下のセクションを user_manual.md の API キー取得セクションの後、または適切な位置に追加してください:

---

## フォールバックモデル / プロバイダーアクセスレベル API

メインの LLM（Claude Code）が利用制限に達した場合に、代替モデルへ自動的にフォールバックする仕組みを提供します。プロバイダーごとにアクセス可能なデータの機密レベルを設定することで、機密データがクラウド LLM に送信されることを防ぎます。

### 概念

- **フォールバックモデルリスト**: メイン LLM が利用不可のときに順次試行されるモデルのリストです。各エントリは `{プロバイダー名, モデル名}` または `{プロバイダー名, モデル名, エンドポイントURL}` の形式です。
- **プロバイダー最大アクセスレベル**: 各プロバイダーが扱えるデータの機密レベルの上限です。`0.5` はクラウド LLM 安全なデータのみ、`1.0` はローカル環境で全データにアクセス可能であることを意味します。
- **アクセスレベルに基づくフィルタリング**: リクエストに含まれるデータの機密レベルに応じて、そのレベルを扱えるプロバイダーのモデルのみがフォールバック候補になります。

### デフォルト設定

パッケージ読み込み時のデフォルト値は以下の通りです:

```mathematica
(* フォールバックモデル *)
{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}

(* プロバイダー最大アクセスレベル *)
<|"claudecode" -> 0.5, "anthropic" -> 0.5, "openai" -> 0.5, "lmstudio" -> 1.0|>
```

未登録のプロバイダーは `0.5`（クラウド安全レベル）として扱われます。

### 関数リファレンス

#### NBSetFallbackModels[models]

フォールバックモデルリストを設定します。

- **引数**: `models` — `{{provider, model}, {provider, model, url}, ...}` 形式のリスト
- **戻り値**: 設定されたリスト

```mathematica
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"lmstudio", "local-7b", "http://127.0.0.1:1234"}
}]
```

#### NBGetFallbackModels[]

現在のフォールバックモデルリスト全体を返します。

```mathematica
NBGetFallbackModels[]
(* {{"anthropic", "claude-opus-4-6"}, {"lmstudio", "local-7b", "http://127.0.0.1:1234"}} *)
```

#### NBSetProviderMaxAccessLevel[provider, level]

プロバイダーの最大アクセスレベルを設定します。

- **引数**:
  - `provider` — プロバイダー名（文字列、大文字小文字不問）
  - `level` — 0.0〜1.0 の数値（自動的に範囲内にクリップされます）
- **戻り値**: 設定された値

```mathematica
NBSetProviderMaxAccessLevel["anthropic", 0.5]  (* クラウド安全データのみ *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0]   (* 全データアクセス可能 *)
```

#### NBGetProviderMaxAccessLevel[provider]

プロバイダーの最大アクセスレベルを返します。未登録プロバイダーの場合は `0.5` を返します。

```mathematica
NBGetProviderMaxAccessLevel["lmstudio"]   (* 1.0 *)
NBGetProviderMaxAccessLevel["unknown"]    (* 0.5 *)
```

#### NBGetAvailableFallbackModels[accessLevel]

指定されたアクセスレベルで利用可能なフォールバックモデルのみを返します。プロバイダーの `MaxAccessLevel >= accessLevel` を満たすモデルのみが含まれます。

```mathematica
(* 機密データ (accessLevel=0.8) を含むリクエスト *)
NBGetAvailableFallbackModels[0.8]
(* → lmstudio のモデルのみ返される *)

(* 非機密データ (accessLevel=0.5) のリクエスト *)
NBGetAvailableFallbackModels[0.5]
(* → 全プロバイダーのモデルが返される *)
```

#### NBProviderCanAccess[provider, accessLevel]

プロバイダーが指定されたアクセスレベルのデータにアクセス可能かを判定します。

- **戻り値**: `True` / `False`

```mathematica
NBProviderCanAccess["anthropic", 0.5]   (* True *)
NBProviderCanAccess["anthropic", 0.8]   (* False *)
NBProviderCanAccess["lmstudio", 1.0]    (* True *)
```

### 典型的な使用パターン

ローカル LLM とクラウド LLM を併用する環境では、以下のように設定します:

```mathematica
(* ローカル LLM を最優先フォールバックに設定 *)
NBSetFallbackModels[{
  {"lmstudio", "qwen-32b", "http://127.0.0.1:1234"},
  {"anthropic", "claude-opus-4-6"},
  {"openai", "gpt-5"}
}];

(* ローカル LLM には全データへのアクセスを許可 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];

(* クラウドプロバイダーは非機密データのみ *)
NBSetProviderMaxAccessLevel["anthropic", 0.5];
NBSetProviderMaxAccessLevel["openai", 0.5];
```

この設定により、機密データを含むリクエストではローカル LLM のみがフォールバック先となり、非機密データのリクエストでは全プロバイダーが利用可能になります。

---

### 追加セクション: 履歴キャッシュ

以下のセクションを汎用履歴データベース API セクション内に追加してください:

---

## 履歴キャッシュ

`NBHistoryRawData` をはじめとする履歴読み取り関数は、内部キャッシュを使用して FrontEnd 通信を削減します。ClaudeQuery 1回の処理中に同じ履歴が7回以上読み取られることがあるため、このキャッシュにより大幅なパフォーマンス向上が期待できます。

### キャッシュの動作

- **自動同期**: `NBHistoryAppend`、`NBHistoryUpdateLast`、`NBHistoryWriteHeader`、`NBHistorySetData`、`NBHistoryReplaceEntries`、`NBHistoryUpdateHeader`、`NBHistoryCreate` などの書き込み系関数は、書き込みと同時にキャッシュを自動更新します。
- **自動無効化**: `NBHistoryDelete` はキャッシュエントリを自動的に無効化します。
- **手動クリア**: パッケージの再ロードやセッション切替時など、キャッシュ全体をクリアする必要がある場合は `NBHistoryCacheClear[]` を使用します。

### 関数リファレンス

#### NBHistoryCacheClear[]

履歴キャッシュ全体をクリアします。パッケージの再ロード時やセッション切替時に使用します。

```mathematica
NBHistoryCacheClear[]
```

通常の使用では、書き込み系関数がキャッシュを自動同期するため、明示的にクリアする必要はありません。

---

### 更新セクション: NBScanDependentCells のオーバーロード

user_manual.md の `NBScanDependentCells` の説明を以下のように更新してください:

---

## NBScanDependentCells — 依存セルの自動検出とマーク

`NBScanDependentCells` は依存グラフを使って機密変数に依存するセルを検出し、`NBMarkCellDependent` で自動マークします。Claude 関数呼び出しセル（`ClaudeQuery` 等）は除外されます。

### シグネチャ

```mathematica
(* 従来互換: 依存グラフを内部で計算 *)
NBScanDependentCells[nb, confVarNames]

(* 事前計算済みの依存グラフを渡すオーバーロード（二重計算回避） *)
NBScanDependentCells[nb, confVarNames, deps]
```

### 引数

- `nb` — 対象ノートブック（NotebookObject）
- `confVarNames` — 機密変数名のリスト（例: `{"apiKey", "password"}`）
- `deps` — （オプション）`NBBuildVarDependencies[nb]` の戻り値。事前に依存グラフを計算済みの場合に渡すことで、内部での二重計算を回避できます。

### 戻り値

新たにマークしたセル数（Integer）。

### 使用例

```mathematica
(* 従来の呼び出し方: 依存グラフは内部で自動計算 *)
markedCount = NBScanDependentCells[nb, {"apiKey", "password"}];

(* 事前計算済みの依存グラフを渡す呼び出し方 *)
deps = NBBuildVarDependencies[nb];
(* deps を他の処理でも使用する場合、渡すことで二重計算を回避 *)
transitive = NBTransitiveDependents[deps, {"apiKey", "password"}];
markedCount = NBScanDependentCells[nb, {"apiKey", "password"}, deps];
```

`deps` 引数を渡すオーバーロードは、`NBBuildVarDependencies` の結果を他の処理（`NBTransitiveDependents` 等）と共有する場合に推奨されます。同一ノートブックに対して依存グラフを2回計算するコストを省くことができます。

---

### 更新セクション: NBGetContext の2段階プライバシーフィルタリング

user_manual.md の `NBGetContext` の説明を以下のように更新してください:

---

## NBGetContext — LLM プロンプト用コンテキスト構築

`NBGetContext[nb, afterIdx, PrivacySpec -> ps]` は、ノートブック内の `afterIdx` 番目以降のセルから LLM プロンプト用のコンテキスト文字列を構築します。

### 2段階プライバシーフィルタリング

`NBGetContext` はプライバシー保護のために **2段階のフィルタリング** を適用します:

#### 第1段階: セルレベルの完全除外

`NBCellPrivacyLevel` がリクエストの `AccessLevel` を超えるセルは、**セル全体が除外** されます。これには以下が該当します:

- `NBMarkCellConfidential` で直接機密マークされたセル（プライバシーレベル 1.0）
- `NBMarkCellDependent` で依存機密マークされたセル（プライバシーレベル 0.75）
- `$NBConfidentialSymbols` に登録された機密変数を参照するセル（プライバシーレベル 1.0）

除外されたセルは、ラベルがある場合 `In[N]:= (* [機密セル: 非表示] *)` として残り、対応する Output セルも自動的に抑制されます。

#### 第2段階: 変数名レベルのリダクション

セル自体は除外されなかったが、`$NBConfidentialSymbols` に登録された機密変数名を **行単位で** 参照している場合、該当行のみがリダクションされます:

- **代入文**（`変数名 = 式`）の場合: `変数名 = (* [機密変数に依存: 値は非表示] *)` に置換
- **その他の行**: `(* [機密変数を含む行: 非表示] *)` に置換

リダクションが発生した Input セルに対応する Output セルも自動的に抑制されます。

### 使用例

```mathematica
(* クラウド LLM 安全なコンテキストを構築 *)
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* ローカル LLM 用: 全データを含むコンテキスト *)
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 1.0|>];

(* 特定セル以降のみ *)
context = NBGetContext[nb, 5];
```

### フィルタリングの動作例

ノートブックに以下のセルがあるとします:

```
In[1]:= x = 42                          (* 通常セル *)
In[2]:= apiKey = Confidential["sk-..."] (* 機密マーク済み *)
In[3]:= result = fetchData[apiKey]       (* 依存マーク済み *)
In[4]:= summary = Length[result]         (* 機密変数 result を参照 *)
In[5]:= Plot[Sin[t], {t, 0, 2 Pi}]     (* 通常セル *)
```

`AccessLevel -> 0.5` での `NBGetContext` の出力:

```
In[1]:= x = 42
In[2]:= (* [機密セル: 非表示] *)
In[3]:= (* [機密セル: 非表示] *)
In[4]:= summary = (* [機密変数に依存: 値は非表示] *)
In[5]:= Plot[Sin[t], {t, 0, 2 Pi}]
```

- In[2] は直接機密マーク → セル全体除外（第1段階）
- In[3] は依存機密マーク → セル全体除外（第1段階）
- In[4] はマークなしだが `result`（機密変数）を参照 → 行レベルリダクション（第2段階）
- In[5] は機密情報なし → そのまま表示