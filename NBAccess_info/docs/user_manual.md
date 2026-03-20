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
13. [フォールバックモデル / プロバイダーアクセスレベル](#フォールバックモデル--プロバイダーアクセスレベル)
14. [その他のユーティリティ](#その他のユーティリティ)

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

### $NBSendDataSchema

秘密依存データのスキーマ情報（データ型・サイズ・キー名等）をクラウド LLM に送信するかどうかを制御するフラグです。初期値は `True` です。

- **True（デフォルト）**: 秘密依存 Output であっても、データ型・サイズ・キー名等のスキーマ情報のみを LLM に送信します。値そのものは含まれません。
- **False**: 秘密依存 Output のスキーマ情報を一切送信しません。

非秘密 Output は常にスマート要約付きで送信されます。

```mathematica
(* スキーマ情報の送信を無効化する場合 *)
$NBSendDataSchema = False
```

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

FrontEnd の `ExportPacket` 経由で InputText 形式のテキストを取得します。この方式は 2D 表示（Sum、Integral 等の数式表記）も正しくテキスト変換できるため、`NBCellToText` より信頼性が高い場合があります。失敗時は `NBCellExprToText` にフォールバックします。

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

セルのテキスト内容を直接返します。Cases ベースの文字列トークン収集を行いますが、特殊な BoxData 形式では空文字列を返す場合があります。より堅牢なテキスト取得が必要な場合は `NBCellReadInputText` を使用してください。

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
(* 0.0: 非秘密, 0.75: 依存秘密, 1.0: 秘密 *)
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

#### プライバシーフィルタリングとスマート出力要約

NBGetContext は、機密情報の漏洩を防ぎつつ LLM に有用なコンテキストを提供するために、**入力セルのプライバシーフィルタリング**と**出力セルのスマート要約**を実行します。

**第1段階: セルレベルの完全除外（Input セル）**

各 Input セルのプライバシーレベル (`NBCellPrivacyLevel`) を PrivacySpec の AccessLevel と比較し、アクセス不可のセル（機密マーク済み・直接機密変数を代入するセル等）はセル内容を一切出力せず、`(* [機密セル: 非表示] *)` というプレースホルダに置換します。対応する Output セルも同時に抑制されます。

```
In[3]:= (* [機密セル: 非表示] *)
```

**第2段階: 変数名レベルのリダクション（Input セル）**

第1段階を通過したセル（プライバシーレベルがアクセスレベル以下のセル）に対して、`$NBConfidentialSymbols` に登録されている機密変数名が行内に含まれていないかを走査します。機密変数名が検出された行は以下のようにリダクションされます。

- 代入式（`変数名 = ...`）の場合: 左辺の変数名のみ残し、右辺を `(* [機密変数に依存: 値は非表示] *)` に置換します。
- それ以外の行: `(* [機密変数を含む行: 非表示] *)` に置換します。

リダクションが発生したセルに対応する Output セルも抑制されます。

**第3段階: Output のスマート要約**

全 Output セルに対して、プライバシーレベルと抑制状態に基づいて3種類の処理を適用します。

1. **非秘密かつ非抑制の Output**: スマート要約付きでコンテキストに含めます。
   - 短い出力（200文字以下）はそのまま含めます。
   - 長い出力はデータ構造情報（型・サイズ・キー名等）と先頭100文字のプレビューを要約として生成します。

2. **秘密依存の Output**（`$NBSendDataSchema = True` の場合）: 値を一切含まず、スキーマ情報（データ型・サイズ・キー名等）のみを送信します。

3. **それ以外の Output**（抑制済み、または `$NBSendDataSchema = False` の秘密依存 Output）: 完全にスキップされます。

スマート要約で検出されるデータ構造の種類:

| データ構造 | 要約例 |
|---|---|
| Association | `Association, 5 keys: {name, age, ...}` |
| Dataset | `Dataset, columns: {col1, col2, ...}` |
| ネストリスト/行列 | `NestedList/Matrix, ~10 rows` |
| リスト | `List, ~42 elements` |
| SparseArray | `SparseArray` |
| NumericArray | `NumericArray` |
| Graphics/Image | `Graphics/Image` |
| その他 | `1234 chars` |

```mathematica
(* 非秘密 Output のスマート要約例 *)
Out[5]= (* Association, 3 keys: {name, age, city} *) <|"name" -> "Alice", "age" -> 30, ... …

(* 秘密依存 Output のスキーマ情報例 *)
Out[8]= (* [機密依存データ: Dataset, columns: {revenue, profit, cost}] *)
```

**Message の処理**

Message セル（エラーメッセージ）は afterIdx 以降のもののみがコンテキストに含まれます。PrivacySpec によるフィルタリングも適用されます。

この方式により、直接機密なセルは完全に隠蔽され、間接的に機密変数を参照するセルはコードの構造を保ちつつ値のみが隠蔽されます。さらに、Output セルにはスマート要約が適用されるため、LLM に必要な構造情報を効率的に提供できます。

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

ノートブックの Input セルから変数依存関係グラフを構築します。通常のセル実行時にはこちらを使用します。

```mathematica
NBBuildVarDependencies[nb]
(* <|"y" -> {"x"}, "z" -> {"x", "y"}|> *)
```

### NBBuildGlobalVarDependencies

`Notebooks[]` 全体の Input/Code セルを走査し、統合された変数依存関係グラフを構築して返します。ClaudeQuery/ClaudeEval/ContinueEval の直前の精密チェックで使用します。

通常のセル実行時は軽量版の `NBBuildVarDependencies[nb]` を使用してください。

```mathematica
NBBuildGlobalVarDependencies[]
(* <|"y" -> {"x"}, "z" -> {"x", "y"}, "w" -> {"z"}|> *)
```

`NBBuildVarDependencies[nb]` が単一ノートブック内の依存関係のみを解析するのに対し、`NBBuildGlobalVarDependencies[]` は開いているすべてのノートブックを横断して解析します。これにより、あるノートブックで定義された変数を別のノートブックで参照しているケースも検出できます。

### NBTransitiveDependents

機密変数に直接・間接依存する全変数名を返します。

```mathematica
NBTransitiveDependents[deps, {"secretKey"}]
```

### NBScanDependentCells

依存グラフを使って機密変数に依存するセルに自動マークを適用します。事前計算済みの依存グラフを渡すオーバーロードも利用可能です。

```mathematica
(* 依存グラフを内部で計算する版 *)
NBScanDependentCells[nb, {"secretVar1", "secretVar2"}]
(* 例: 3  — 新たにマークしたセル数 *)

(* 事前計算済みの依存グラフを渡す版（二重計算を回避） *)
deps = NBBuildVarDependencies[nb];
NBScanDependentCells[nb, {"secretVar1", "secretVar2"}, deps]
```

事前計算済みの依存グラフ `deps` を第3引数に渡すことで、同じ依存グラフを複数回計算するオーバーヘッドを回避できます。`deps` を省略した場合は内部で `NBBuildVarDependencies[nb]` が呼ばれます。

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

### 履歴キャッシュ

履歴データベースの読み取りにはインメモリキャッシュが使用されます。ClaudeQuery 1回の処理で同一の履歴が7回以上読まれることがあるため、キャッシュにより FrontEnd 通信のオーバーヘッドを大幅に削減します。

書き込み系関数（`NBHistoryAppend`、`NBHistoryUpdateLast`、`NBHistoryWriteHeader`、`NBHistoryUpdateHeader`、`NBHistorySetData`、`NBHistoryReplaceEntries` 等）はキャッシュを自動的に同期します。`NBHistoryDelete` はキャッシュを無効化します。

パッケージの再ロードやセッション切替時など、キャッシュを手動でクリアする必要がある場合は `NBHistoryCacheClear[]` を使用します。

```mathematica
(* 全履歴キャッシュをクリア *)
NBHistoryCacheClear[]
```

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

### NBHistoryRawData

差分圧縮を解除せずに履歴データを返します（内部用）。キャッシュが有効な場合はキャッシュから返します。

```mathematica
NBHistoryRawData[nb, "chat"]
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

タグ一覧・削除・エントリ全置換です。`NBHistoryDelete` は対応するキャッシュも無効化します。

```mathematica
NBHistoryListTags[nb, "chat"]
NBHistoryDelete[nb, "chat-old"]
```

### NBHistoryCacheClear

全履歴キャッシュをクリアします。パッケージ再ロード時やセッション切替時に使用します。

```mathematica
NBHistoryCacheClear[]
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

## フォールバックモデル / プロバイダーアクセスレベル

LLM のフォールバック先モデルと、各プロバイダーがアクセスできるデータのレベルを管理する API です。プライバシーレベルの高い（機密性の高い）データを扱う場合に、そのデータにアクセス可能なプロバイダーのモデルのみをフォールバック先として選択するために使用します。

### 概念

- **フォールバックモデルリスト**: メインの LLM が利用不可の場合に試行する代替モデルの順序付きリストです。各エントリは `{プロバイダー名, モデル名}` または `{プロバイダー名, モデル名, エンドポイントURL}` の形式です。
- **プロバイダー最大アクセスレベル**: 各プロバイダーに対して設定される、そのプロバイダーに送信可能なデータの最大プライバシーレベル (0.0〜1.0) です。例えば、クラウド LLM プロバイダーは 0.5（公開データのみ）、ローカル LLM は 1.0（全データ）に設定します。

### デフォルト値

フォールバックモデルリストの初期値:

```mathematica
{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}
```

プロバイダー最大アクセスレベルの初期値:

```mathematica
<|"claudecode" -> 0.5, "anthropic" -> 0.5, "openai" -> 0.5, "lmstudio" -> 1.0|>
```

未登録のプロバイダーは 0.5 として扱われます。

### NBSetFallbackModels

フォールバックモデルリストを設定します。

```mathematica
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"openai", "gpt-5"},
  {"lmstudio", "local-model", "http://127.0.0.1:1234"}
}]
```

各エントリの形式は以下のいずれかです。

- `{プロバイダー名, モデル名}` — 標準エンドポイントを使用します。
- `{プロバイダー名, モデル名, エンドポイントURL}` — カスタムエンドポイントを指定します（ローカル LLM 等）。

### NBGetFallbackModels

現在のフォールバックモデルリスト全体を返します。

```mathematica
NBGetFallbackModels[]
(* {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}} *)
```

### NBSetProviderMaxAccessLevel

プロバイダーの最大アクセスレベルを設定します。値は 0.0〜1.0 にクリップされます。

```mathematica
(* クラウドプロバイダー: 公開データのみ *)
NBSetProviderMaxAccessLevel["anthropic", 0.5]
NBSetProviderMaxAccessLevel["openai", 0.5]

(* ローカル LLM: 全データにアクセス可能 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0]
```

### NBGetProviderMaxAccessLevel

プロバイダーの現在の最大アクセスレベルを返します。未登録プロバイダーは 0.5 を返します。

```mathematica
NBGetProviderMaxAccessLevel["anthropic"]
(* 0.5 *)

NBGetProviderMaxAccessLevel["lmstudio"]
(* 1.0 *)

NBGetProviderMaxAccessLevel["unknown_provider"]
(* 0.5 *)
```

### NBGetAvailableFallbackModels

指定アクセスレベルで利用可能なフォールバックモデルのみを返します。プロバイダーの MaxAccessLevel が指定アクセスレベル以上であるモデルのみが含まれます。

```mathematica
(* AccessLevel 0.5: 全プロバイダーが利用可能 *)
NBGetAvailableFallbackModels[0.5]
(* {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"},
     {"lmstudio", "local-model", "http://127.0.0.1:1234"}} *)

(* AccessLevel 0.8: ローカル LLM のみ利用可能 *)
NBGetAvailableFallbackModels[0.8]
(* {{"lmstudio", "local-model", "http://127.0.0.1:1234"}} *)

(* AccessLevel 1.0: MaxAccessLevel=1.0 のプロバイダーのみ *)
NBGetAvailableFallbackModels[1.0]
(* {{"lmstudio", "local-model", "http://127.0.0.1:1234"}} *)
```

### NBProviderCanAccess

プロバイダーが指定アクセスレベルのデータにアクセス可能かを返します (True/False)。MaxAccessLevel >= accessLevel なら True です。

```mathematica
NBProviderCanAccess["anthropic", 0.5]
(* True *)

NBProviderCanAccess["anthropic", 0.8]
(* False — クラウドプロバイダーは高機密データにアクセス不可 *)

NBProviderCanAccess["lmstudio", 1.0]
(* True — ローカル LLM は全データにアクセス可能 *)
```

### 典型的な使用シナリオ

機密データを含むクエリでフォールバックが発生した場合、クラウドプロバイダー（anthropic, openai 等）には機密データを送信せず、ローカル LLM のみにフォールバックするというポリシーを実現できます。

```mathematica
(* セットアップ: ローカル LLM を高アクセスレベルで登録 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0]
NBSetFallbackModels[{
  {"anthropic", "claude-opus-4-6"},
  {"lmstudio", "qwen-32b", "http://127.0.0.1:1234"}
}]

(* 機密データを含むリクエストの場合 *)
NBGetAvailableFallbackModels[0.8]
(* → lmstudio のモデルのみ返される *)
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