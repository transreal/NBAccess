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
9. [TaggingRules の概要と NBAccess での利用](#taggingrules-の概要と-nbaccess-での利用)
10. [ノートブック TaggingRules API](#ノートブック-taggingrules-api)
11. [履歴データベース](#履歴データベース)
12. [Job 管理](#job-管理)
13. [API キー](#api-キー)
14. [フォールバックモデル / プロバイダーアクセスレベル](#フォールバックモデル--プロバイダーアクセスレベル)
15. [その他のユーティリティ](#その他のユーティリティ)
16. [[実験的] ノートブックファイルのセル操作](#実験的-ノートブックファイルのセル操作)

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

### $NBVerbose

NBAccess パッケージの詳細ログ出力を制御するフラグです。

- **False（デフォルト）**: 重大エラー以外の NBAccess ログを抑制します。
- **True**: NBAccess 内部の詳細ログを Messages に出力します。

```mathematica
(* 詳細ログを有効化する場合 *)
$NBVerbose = True
```

### $NBAutoEvalProhibitedPatterns

`NBEvaluatePreviousCell` で自動実行をブロックするパターンのリストです。RegularExpression または StringExpression のリストを指定します。セル内容がいずれかのパターンにマッチする場合、評価をスキップして警告を表示します。[claudecode](https://github.com/transreal/claudecode) パッケージがロード時にパターンを登録します。デフォルトは空リストです。

```mathematica
(* 特定パターンを含むセルの自動評価を禁止する場合 *)
AppendTo[$NBAutoEvalProhibitedPatterns, RegularExpression["危険なパターン"]]
```

### $NBSeparationIgnoreList

分離検査で無視するパッケージ名のリストです。NBAccess と [NotebookExtensions](https://github.com/transreal/NotebookExtensions) はデフォルトで登録されています。

```mathematica
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

### $NBConfidentialCellOpts / $NBDependentCellOpts

機密マーク・依存機密マークのセル表示オプションです。`NBMarkCellConfidential` および `NBMarkCellDependent` が内部で使用します。

- `$NBConfidentialCellOpts`: 赤背景 + WarningSign（直接機密セル用）
- `$NBDependentCellOpts`: 橙背景 + LockIcon（依存機密セル用）

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

選択中セルのインデックスリストを返します。セルブラケット選択がない場合は、カーソル位置のセルにフォールバックします。

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

セルのスタイルまたはラベルを返します。CellStyle がリスト形式の場合も文字列に正規化されます。

```mathematica
NBCellStyle[nb, 3]       (* 例: "Input" *)
NBCellLabel[nb, 3]       (* 例: "In[3]:=" *)
```

### NBCellSetStyle

セルのスタイルを変更します。Cell 式の第2引数を書き換え、TaggingRules 等の他の属性は保持されます。`SetOptions[cell, CellStyle -> ...]` ではセルスタイルは変わらないため、Cell 式全体を読み書きする実装になっています。

```mathematica
NBCellSetStyle[nb, 3, "Input"]
NBCellSetStyle[nb, 5, "Text"]
```

### NBResolveCell

セルインデックスに対応する CellObject を返します。外部パッケージが低レベルのセル参照を必要とする場合に使用します。指定インデックスが無効な場合は `$Failed` を返します。

```mathematica
NBResolveCell[nb, 3]
(* 例: CellObject[...] *)
```

### NBSelectCell

セルブラケットを選択状態にします。パレット操作後のセル選択復元に使用します。

```mathematica
NBSelectCell[nb, 3]
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

### iCellToInputText

CellObject から FrontEnd`ExportPacket 経由で InputText 形式のテキストを取得する内部ユーティリティです。失敗時は `NBCellExprToText` にフォールバックします。`NBCellReadInputText` がセルインデックスを受け取るのに対し、こちらは CellObject を直接受け取ります。

```mathematica
NBAccess`iCellToInputText[cellObject]
```

### NBCellHasImage

Cell 式が画像（RasterBox / GraphicsBox）を含むか判定します。

```mathematica
NBCellHasImage[NBCellRead[nb, 7]]
(* 例: True *)
```

`$Failed` や空リスト `{}` に対しては `False` を返します。

### NBCellRasterize

セルをラスタライズしてファイルに保存します。デフォルト解像度は 144 DPI です。

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

判定ロジックは以下の優先順で適用されます。

1. 機密タグが `False`（明示的に非秘密）→ 0.0
2. `dependent` タグが `True` → 0.75
3. 機密タグが `True` → 1.0
4. 機密変数を参照している → 1.0
5. いずれにも該当しない → 0.0

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

Message セル（エラーメッセージ）は afterIdx 以降のもののみがコンテキストに含まれます。PrivacySpec によるフィルタリングも適用されます。対象スタイルは `"Message"` および `"MSG"` です。

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

セルに機密マーク（赤背景 + WarningSign）を付けます。TaggingRules に `"confidential" -> True` を設定し、`$NBConfidentialCellOpts` のスタイルを適用します。

```mathematica
NBMarkCellConfidential[nb, 3]
```

### NBMarkCellDependent

セルに依存機密マーク（橙背景 + LockIcon）を付けます。機密変数に間接依存するセルに使用します。TaggingRules に `"confidential" -> True` と `"dependent" -> True` の両方を設定し、`$NBDependentCellOpts` のスタイルを適用します。

```mathematica
NBMarkCellDependent[nb, 7]
```

### NBUnmarkCell

セルの機密マーク（視覚・タグ）をすべて解除します。`"confidential"` タグを `False` に設定し、`"dependent"` タグを削除し、セルのスタイル（背景色・枠・アイコン）を `Inherited` にリセットします。

```mathematica
NBUnmarkCell[nb, 3]
```

---

## セル内容分析

### NBCellUsesConfidentialSymbol

セルが機密変数を参照しているか返します。`$NBConfidentialSymbols` に登録された変数名がセル内容に含まれているかを単語境界ベースの正規表現で判定します。

```mathematica
NBCellUsesConfidentialSymbol[nb, 5]
```

### NBCellExtractVarNames

セル内容から Set/SetDelayed の LHS 変数名を抽出します。InputText 形式でテキストを取得し、`変数名 =` または `変数名 :=` のパターンを検出します。予約語（`If`, `Module` 等）は除外されます。

```mathematica
NBCellExtractVarNames[nb, 3]
(* 例: {"x", "y"} *)
```

### NBCellExtractAssignedNames

セル内容から `Confidential[]` 内の代入先変数名を抽出します。`変数名 = Confidential[...]` および `Confidential[変数名 = ...]` の両パターンを検出します。

```mathematica
NBCellExtractAssignedNames[nb, 3]
```

### NBExtractAssignments

テキストから代入先変数名と右辺の依存変数を抽出します。文字列リテラル内の識別子は除外されます。`Confidential[...]` ラッパーは自動的に除去して内部の代入を検出します。

```mathematica
NBExtractAssignments["x = 1; y := f[x]"]
(* {{" x", {}}, {"y", {"f", "x"}}} *)
```

### NBShouldExcludeFromPrompt

セルがプロンプトから除外すべきかを返します。機密タグが `True` の場合、または機密変数を参照している場合に `True` を返します。機密タグが明示的に `False` の場合は常に `False` を返します。

```mathematica
NBShouldExcludeFromPrompt[nb, 3]
```

### NBIsClaudeFunctionCell

セルが Claude 関数呼び出しセル（`ClaudeQuery`, `ClaudeEval`, `ContinueEval`, `ClaudeMath`, `ClaudeSpec`, `ClaudeExtractCode`, `ClaudeExtractAllCode`）かを判定します。

```mathematica
NBIsClaudeFunctionCell[nb, 3]
```

---

## 依存グラフ

### NBBuildVarDependencies

ノートブックの Input セルから変数依存関係グラフを構築します。通常のセル実行時にはこちらを使用します。

InputText 形式でセルテキストを取得し、代入文（`var = expr`）と関数定義（`f[x_] := body`）の両方を解析します。文字列リテラル内の識別子は除外されます。セル番号から `Out$n` 仮想変数も自動生成されます。

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

### NBUpdateGlobalVarDependencies

既存の依存グラフに新しいセルのみを追加してマージします。完全なグラフを毎回構築するコストを回避するインクリメンタル版です。

CellLabel In[x] の x が afterLine より大きいセルだけを走査し、既存の依存グラフにマージします。

```mathematica
{updatedDeps, newLastLine} = NBUpdateGlobalVarDependencies[existingDeps, afterLine]
```

返り値は `{更新された依存グラフ, 新しい最終行番号}` の形式です。この関数により、大規模なノートブックでも効率的に依存関係を追跡できます。

### NBTransitiveDependents

機密変数に直接・間接依存する全変数名を返します。依存グラフ上で固定点に達するまで反復的に依存を追跡します。

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

処理は以下の2フェーズで実行されます。

1. **Phase 1: 事前クリーニング** — 全セルの `dependent` マークをリセットします。
2. **Phase 2: セル走査** — 全セルを順番に走査し、Input/Code セルの代入を解析して依存判定を行います。依存秘密と判定された Input セルの直後の Output/Print セルにもマークを適用します。直接秘密セルの Output には赤マーク、依存秘密セルの Output には橙マークが適用されます。

Claude 関数呼び出しセル（ClaudeQuery 等）は走査対象から除外されます。事前計算済みの依存グラフ `deps` を第3引数に渡すことで、同じ依存グラフを複数回計算するオーバーヘッドを回避できます。`deps` を省略した場合は内部で `NBBuildVarDependencies[nb]` が呼ばれます。

通知セル（CellTags に "claudecode-notice" が含まれるセル）は自動的にマーキング対象から除外されます。

### NBDependencyEdges

変数依存関係をエッジリストで返します。機密変数でフィルタも可能です。

```mathematica
NBDependencyEdges[nb]
NBDependencyEdges[nb, {"secretKey"}]
(* {DirectedEdge["x", "y"], ...} *)
```

機密変数リストを指定した場合は、推移的依存変数が関与するエッジのみが返されます。

### NBPlotDependencyGraph

変数依存関係グラフを可視化します。直接秘密は赤、依存秘密は橙で着色されます。

```mathematica
NBPlotDependencyGraph[nb]
NBPlotDependencyGraph[nb, PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

デフォルトの AccessLevel は 1.0（全ノード表示）です。AccessLevel を下げると、そのレベルを超えるプライバシーレベルのノードが非表示になります。エッジラベルには依存を定義するセルの `In[xx]` 番号がツールチップとして付与されます。`Out$n` 形式の仮想変数は `Out[n]` として表示されます。

グラフの表示には以下の特徴があります：

- **ノード着色**: 関数は白地に色付き縁取り、変数は塗りつぶしで表示されます。秘密は赤、依存秘密は橙、公開は青で色分けされます。
- **エッジスタイル**: ノートブック内エッジは濃い実線、クロスノートブック間エッジは薄い破線で描画されます。
- **ラベル**: 秘密・依存秘密のノードのみ変数名ラベルが表示され、公開ノードはラベルなしで表示されます。

オプション:

- `"Scope" -> "Global"`（デフォルト）: 全ノートブック統合の依存グラフを表示します。
- `"Scope" -> "Local"`: 指定ノートブックのみの依存グラフを表示します。

```mathematica
NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]
```

### NBGetFunctionGlobalDeps

各関数が依存する大域変数を解析します。パターン変数とスコーピング局所変数（Module/Block/With/Function）は自動的に除外されます。

```mathematica
NBGetFunctionGlobalDeps[nb]
(* <|"myFunc" -> {"globalVar1", "globalVar2"}|> *)
```

### NBDebugDependencies

依存グラフのデバッグ情報を Print で出力します。以下の情報が表示されます。

- 依存グラフ（全エッジ / 機密関連エッジ）
- 変数テーブル
- 直接機密変数 / 推移的依存変数
- 関数定義の解析結果
- 全 Input セルの詳細（InputText、代入解析、依存判定）
- セル構成一覧

```mathematica
NBDebugDependencies[nb, {"secretKey"}]
```

---

## 書き込み

### NBWriteText / NBWriteCode

テキストセルまたは Input セルを書き込みます。`NBWriteCode` は FrontEnd のパーサーを使用して構文カラーリング付きの BoxData を生成します。パーサーが失敗した場合は `ToExpression` + `MakeBoxes` にフォールバックし、さらにそれも失敗した場合は平文テキストの Input セルを書き込みます。

```mathematica
NBWriteText[nb, "これは説明です", "Text"]
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

### NBCellWriteCode

既存セルにコードを BoxData + Input スタイルで書き込みます。FrontEnd のパーサー（FEParser）で構文カラーリング付き BoxData に変換し、Cell 式全体を内容（BoxData）とスタイル（Input）で置換します。TaggingRules 等の属性は保持されます。

```mathematica
NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

`NBWriteCode` がノートブックの現在位置に新しいセルを書き込むのに対し、`NBCellWriteCode` は指定インデックスの**既存セル**を上書きします。

### NBWriteSmartCode

CellPrint パターンを自動検出してスマートに書き込みます。以下のパターンを認識します。

- `CellPrint[cellExpr]`: cellExpr を直接書き込みます。
- `CompoundExpression[CellPrint[cellExpr], rest...]`: cellExpr を書き込んだ後、残りの式を Input セルとして書き込みます。
- その他: `NBWriteCode` にフォールバックします。

```mathematica
NBWriteSmartCode[nb, "Table[i^2, {i, 10}]"]
```

### NBWriteCell

Cell 式を直接書き込みます。位置指定（After/Before/All）も可能です。デフォルトは After です。

```mathematica
NBWriteCell[nb, Cell["Hello", "Text"]]
NBWriteCell[nb, Cell["Hello", "Text"], Before]
```

### NBWritePrintNotice

通知用 Print セルを書き込みます。CellTags に "claudecode-notice" を付与して、`NBScanDependentCells` のマーキング対象外にします。`nb` が `None` の場合は `CellPrint` を使用します（同期 In/Out 間出力）。

```mathematica
NBWritePrintNotice[nb, "処理が完了しました", Green]
NBWritePrintNotice[None, "同期出力", Blue]
```

### NBWriteDynamicCell

Dynamic セルを書き込みます。タグを指定した場合は CellTags が設定されます。追加オプションも渡せます。

```mathematica
NBWriteDynamicCell[nb, DynamicBox[...], "progressTag"]
NBWriteDynamicCell[nb, DynamicBox[...], ""]  (* タグなし *)
```

### NBWriteExternalLanguageCell

ExternalLanguage セル（R、Python 等）を書き込みます。`autoEvaluate` が `True` の場合、書き込み後にセルを自動評価します。

```mathematica
NBWriteExternalLanguageCell[nb, "print('Hello')", "Python"]
NBWriteExternalLanguageCell[nb, "cat('Hello')", "R", True]  (* 自動評価 *)
```

### NBWriteInputCellAndMaybeEvaluate

現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動します。`autoEvaluate` が `True` の場合はさらに `SelectionEvaluate` を行います。挿入後に `SetSelectedNotebook` で対象ノートブックをフォーカスします。

```mathematica
NBWriteInputCellAndMaybeEvaluate[nb, MakeBoxes[1 + 1]]
NBWriteInputCellAndMaybeEvaluate[nb, MakeBoxes[Plot[Sin[x], {x, 0, 2Pi}]], True]
```

### NBWriteAnchorAfterEvalCell

EvaluationCell 直後に不可視アンカーセル（CellOpen -> False）を書き込みます。EvaluationCell が取得できない場合はノートブック末尾に書き込みます。

```mathematica
NBWriteAnchorAfterEvalCell[nb, "myAnchorTag"]
```

### NBInsertTextCells

.nb ファイルを非表示で開き、末尾に Subsection セルと Text セルを挿入して保存・閉じます。Subsection のタイトルには `"Package: "` が先頭に付きます。

```mathematica
NBInsertTextCells["report.nb", "結果", "分析結果を以下に示します"]
```

### NBInsertAndEvaluateInput / NBInsertInputAfter

Input セルを挿入して評価、またはカーソル後に挿入します。

```mathematica
NBInsertAndEvaluateInput[nb, MakeBoxes[1 + 1]]
NBInsertInputAfter[nb, MakeBoxes[Table[i^2, {i, 5}]]]
```

`NBInsertInputAfter` はセルを After に書き込んだ後、カーソルを Before CellContents に移動します。

### NBInsertInputTemplate

Input セルテンプレートを挿入します。セルを All で書き込み、カーソルをセル内容全体に移動します。

```mathematica
NBInsertInputTemplate[nb, MakeBoxes[ClaudeQuery[""]]]
```

---

## TaggingRules の概要と NBAccess での利用

### TaggingRules とは

**TaggingRules** は Wolfram Mathematica ノートブックおよびセルが持つ組み込みオプションで、任意のキー・値ペアをメタデータとして付与するための汎用ストレージ機構です。ノートブックや個々のセルに対して、Mathematica の評価エンジンとは独立した文書レベルの情報を保持させることができます。

Mathematica では `TaggingRules` オプションは歴史的に `{key -> value, ...}` 形式のルールリストとして実装されてきましたが、現在の Mathematica バージョンでは `<|key -> value, ...|>` 形式の Association としても使用できます。NBAccess はこの両形式に対応した読み書きを行います。

```mathematica
(* ノートブックに TaggingRules を直接設定する例（低レベル） *)
SetOptions[EvaluationNotebook[], TaggingRules -> <|"myKey" -> "myValue"|>]

(* NBAccess の API を通じた推奨アクセス方法 *)
NBSetTaggingRule[EvaluationNotebook[], "myKey", "myValue"]
NBGetTaggingRule[EvaluationNotebook[], "myKey"]
(* "myValue" *)
```

### NBAccess が TaggingRules を使用する目的

NBAccess は TaggingRules をノートブックおよびセルの**永続的メタデータストア**として活用しています。セッションをまたいでも（ノートブックファイルに保存されるため）データが保持される点が、グローバル変数との大きな違いです。

NBAccess が TaggingRules に保存するデータは、大きく以下の3カテゴリに分類されます。

#### 1. セルレベルの機密マーク

個々のセルの TaggingRules に機密状態を記録します。これによりノートブックを再度開いたときも機密マークが維持されます。

| キー | 値 | 意味 |
|---|---|---|
| `"confidential"` | `True` | セルが機密または機密依存であることを示す |
| `"confidential"` | `False` | 明示的に非機密であることを示す（検査をスキップ） |
| `"dependent"` | `True` | 機密変数に間接依存するセルであることを示す |

```mathematica
(* 機密マークの付与（内部では TaggingRules に書き込む） *)
NBMarkCellConfidential[nb, 3]
(* → セル3の TaggingRules: <|"confidential" -> True|> *)

NBMarkCellDependent[nb, 7]
(* → セル7の TaggingRules: <|"confidential" -> True, "dependent" -> True|> *)

NBUnmarkCell[nb, 3]
(* → セル3の TaggingRules: <|"confidential" -> False|> *)
```

#### 2. ノートブックレベルの設定・プロジェクト情報

ノートブック全体に関わる設定をノートブックの TaggingRules に保存します。

| キー（例） | 用途 |
|---|---|
| `"claudecode-accessible-dirs"` | Claude Code が参照可能なディレクトリリスト |
| ネストパス `{"project", "name"}` 等 | 任意のプロジェクトメタデータ |

```mathematica
(* アクセス可能ディレクトリの保存 *)
NBSetAccessibleDirs[nb, {"/home/user/project", "/data"}]
(* → NBSetTaggingRule[nb, "claudecode-accessible-dirs", {"/home/user/project", "/data"}] *)
```

#### 3. 履歴データベース

NBAccess の最も重要な TaggingRules 活用例が**履歴データベース**です。ClaudeQuery / ClaudeEval の会話履歴・プロンプト・レスポンス・コードを、差分圧縮形式でノートブックの TaggingRules に永続保存します。

各履歴はタグ（`"chat"` 等）をキーとして格納され、ヘッダーとエントリリストから構成されます。

```mathematica
(* 履歴データベースの作成 → TaggingRules["chat"] に書き込む *)
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}]

(* エントリの追加 → TaggingRules["chat"]["entries"] に追記 *)
NBHistoryAppend[nb, "chat", <|"role" -> "user", "response" -> "Hello"|>]
```

TaggingRules に保存された履歴データの構造は以下のとおりです。

```mathematica
TaggingRules -> <|
  "chat" -> <|
    "header" -> <|
      "type"       -> "history_header",
      "name"       -> "chat",
      "diffFields" -> {"fullPrompt", "response", "code"},
      "created"    -> 3900000000  (* AbsoluteTime[] のタイムスタンプ *)
    |>,
    "entries" -> {
      <|"role" -> "user", "response" -> "Hello", ...|>,
      <|"role" -> "assistant", "response" -> Diff[...], ...|>
      (* 古いエントリは差分圧縮されて保存される *)
    }
  |>
|>
```

### TaggingRules のネストパス指定

NBAccess の TaggingRules API はネストしたキーパスをリスト形式で指定できます。これにより階層的なメタデータ管理が可能です。

```mathematica
(* ネストパスで書き込み *)
NBSetTaggingRule[nb, {"project", "name"}, "MyProject"]
NBSetTaggingRule[nb, {"project", "version"}, "1.0"]

(* ネストパスで読み取り *)
NBGetTaggingRule[nb, {"project", "name"}]
(* "MyProject" *)

(* トップレベルキー一覧 *)
NBListTaggingRuleKeys[nb]
(* {"project", "chat", "claudecode-accessible-dirs", ...} *)

(* サブキー一覧 *)
NBListTaggingRuleKeys[nb, "project"]
(* {"name", "version"} *)
```

### TaggingRules と Association / List 形式の互換性

Mathematica の FrontEnd は TaggingRules を内部的に `{key -> value, ...}` の List 形式で管理する場合があります。NBAccess はこの List 形式と Association 形式の両方を透過的に処理します。

- **読み取り時**: List 形式・Association 形式どちらでも正しく値を取得します。
- **書き込み時**: 既存の形式を維持しながらキーを追加・更新します。

この互換処理は `NBGetTaggingRule` / `NBSetTaggingRule` 等の内部で自動的に行われるため、利用者は形式の違いを意識する必要はありません。

### TaggingRules キャッシュ

履歴データベースの読み取りにはインメモリキャッシュ機構が組み込まれています。同一セッション内で同じ TaggingRules キーに頻繁にアクセスする場合（ClaudeQuery 1回の処理で7回以上読まれるケース等）、FrontEnd との通信オーバーヘッドを大幅に削減します。

書き込み操作はキャッシュを自動的に同期し、`NBHistoryDelete` はキャッシュを無効化します。手動でキャッシュをクリアするには `NBHistoryCacheClear[]` を使用します。

---

## ノートブック TaggingRules API

### NBGetTaggingRule / NBSetTaggingRule

ノートブックの TaggingRules を読み書きします。ネストパスも指定可能です。キーが存在しない場合は `Missing[]` を返します。

```mathematica
NBSetTaggingRule[nb, {"project", "name"}, "MyProject"]
NBGetTaggingRule[nb, {"project", "name"}]
(* "MyProject" *)
```

### NBDeleteTaggingRule / NBListTaggingRuleKeys

キーの削除・一覧取得を行います。TaggingRules が Association 形式でも List 形式でも対応します。

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

### 差分圧縮の仕組み

履歴エントリの指定フィールド（`diffFields` で指定）は、隣接エントリとの差分（`Diff` オブジェクト）として圧縮保存されます。最新エントリは常に平文で保持され、それ以前のエントリは差分で表現されます。読み取り時に `DiffApply` で自動復元されます。

### 履歴キャッシュ

履歴データベースの読み取りにはインメモリキャッシュが使用されます。ClaudeQuery 1回の処理で同一の履歴が7回以上読まれることがあるため、キャッシュにより FrontEnd 通信のオーバーヘッドを大幅に削減します。

書き込み系関数（`NBHistoryAppend`、`NBHistoryUpdateLast`、`NBHistoryWriteHeader`、`NBHistoryUpdateHeader`、`NBHistorySetData`、`NBHistoryReplaceEntries` 等）はキャッシュを自動的に同期します。`NBHistoryDelete` はキャッシュを無効化します。

パッケージの再ロードやセッション切替時など、キャッシュを手動でクリアする必要がある場合は `NBHistoryCacheClear[]` を使用します。

```mathematica
(* 全履歴キャッシュをクリア *)
NBHistoryCacheClear[]
```

### NBHistoryCreate

新しい履歴データベースを作成します（冪等）。`diffFields` には差分圧縮対象のフィールド名リストを指定します。既に `diffFields` が設定済みの DB に対して呼び出した場合は既存ヘッダーを返します。第4引数でヘッダーの初期値を上書きできます。

```mathematica
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}]
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}, <|"model" -> "claude-opus-4-6"|>]
```

作成されるヘッダーには以下のフィールドが含まれます: `type`, `name`, `parent`, `inherit`, `created`, `diffFields`。

### NBHistoryAppend / NBHistoryUpdateLast

エントリの追加・最後のエントリの更新を行います。`NBHistoryAppend` は PrivacySpec オプションでエントリに `privacylevel` を自動付与します。また、二つ前のエントリが未圧縮の場合は自動的に差分圧縮します。

```mathematica
NBHistoryAppend[nb, "chat", <|"role" -> "user", "response" -> "Hello"|>]
NBHistoryAppend[nb, "chat", <|"role" -> "user"|>, PrivacySpec -> <|"AccessLevel" -> 0.8|>]
NBHistoryUpdateLast[nb, "chat", <|"response" -> "Updated response"|>]
```

### NBHistoryEntries / NBHistoryData

全エントリの取得を行います。`Decompress -> False` で Diff オブジェクトのまま取得できます。

```mathematica
NBHistoryEntries[nb, "chat"]
NBHistoryData[nb, "chat", Decompress -> False]
```

`NBHistoryData` は `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>` 形式で返します。

### NBHistorySetData

履歴データ全体を書き込みます。`entries` は差分圧縮されていない平文で渡してください。自動的に圧縮されて保存されます。

```mathematica
NBHistorySetData[nb, "chat", <|"header" -> hdr, "entries" -> plainEntries|>]
```

### NBHistoryRawData

差分圧縮を解除せずに履歴データを返します（内部用）。キャッシュが有効な場合はキャッシュから返します。

```mathematica
NBHistoryRawData[nb, "chat"]
```

### NBHistoryEntriesWithInherit

親チェーンを辿って全エントリを返します。ヘッダーの `parent`、`inherit`、`created` フィールドに従って親履歴を再帰的に取得します。`created` タイムスタンプより後の親エントリは除外されます。

```mathematica
NBHistoryEntriesWithInherit[nb, "chat"]
```

### NBHistoryReadHeader / NBHistoryWriteHeader / NBHistoryUpdateHeader

ヘッダーの読み書き・部分更新を行います。`NBHistoryUpdateHeader` は既存キーを上書きし、新規キーを追加します。

```mathematica
NBHistoryReadHeader[nb, "chat"]
NBHistoryWriteHeader[nb, "chat", <|"type" -> "history_header", ...|>]
NBHistoryUpdateHeader[nb, "chat", <|"model" -> "claude-opus-4-6"|>]
```

### NBHistoryListTags / NBHistoryDelete / NBHistoryReplaceEntries

タグ一覧・削除・エントリ全置換です。`NBHistoryDelete` は対応するキャッシュも無効化します。`NBHistoryReplaceEntries` はコンパクションやバッチ更新に使用します。

```mathematica
NBHistoryListTags[nb, "chat"]
NBHistoryDelete[nb, "chat-old"]
NBHistoryReplaceEntries[nb, "chat", newEntries]
```

### NBHistoryCacheClear

全履歴キャッシュをクリアします。パッケージ再ロード時やセッション切替時に使用します。

```mathematica
NBHistoryCacheClear[]
```

### セッションアタッチメント

ヘッダーの `"attachments"` フィールドにファイルパスを管理します。パスは `ExpandFileName` で正規化され、重複は自動除去されます。

```mathematica
NBHistoryAddAttachment[nb, "chat", "/path/to/file.pdf"]
NBHistoryGetAttachments[nb, "chat"]
NBHistoryRemoveAttachment[nb, "chat", "/path/to/file.pdf"]
NBHistoryClearAttachments[nb, "chat"]
```

---

## Job 管理

ClaudeQuery / ClaudeEval の非同期出力位置を管理します。評価セルの直後に3つの不可視スロットセル（システムメッセージ用、完了メッセージ用、アンカー用）を挿入し、ジョブ ID で管理します。

### NBBeginJob / NBEndJob / NBAbortJob

ジョブのライフサイクルを管理します。

```mathematica
jobId = NBBeginJob[nb, EvaluationCell[]]
(* ... 処理 ... *)
NBEndJob[jobId]

(* エラー時 *)
NBAbortJob[jobId, "タイムアウトしました"]
```

`NBBeginJob` は `evalCell` が CellObject でない場合はノートブック末尾にスロットを挿入します。`NBEndJob` は未書き込みスロットとアンカーを削除します。`NBAbortJob` は最初の未書き込みスロットにエラーメッセージを書き込んでからクリーンアップします。

### NBBeginJobAtEvalCell

EvaluationCell を内部取得して Job を開始します。[claudecode](https://github.com/transreal/claudecode) が CellObject を直接保持する必要がないようにするための分離 API です。

```mathematica
jobId = NBBeginJobAtEvalCell[nb]
```

### NBWriteSlot

ジョブのスロット（システムメッセージ / 完了メッセージ）に書き込みます。同じスロットに再度書き込むと上書きされます。書き込み時にスロットのタグが維持されます。

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

AI プロバイダの API キーを SystemCredential から取得します。AccessLevel が 1.0 未満の場合は `$Failed` を返します（API キーは最高機密データのため）。

```mathematica
NBGetAPIKey["anthropic"]
NBGetAPIKey["openai"]
NBGetAPIKey["github"]
```

サポートされるプロバイダー名と対応する SystemCredential キー:

| プロバイダー名 | SystemCredential キー |
|---|---|
| `"anthropic"` | `ANTHROPIC_API_KEY` |
| `"openai"` | `OPENAI_API_KEY` |
| `"github"` / `"gh"` / `"github_pat"` | `GITHUB_TOKEN` |

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

プロバイダーの最大アクセスレベルを設定します。値は 0.0〜1.0 にクリップされます。プロバイダー名は内部で小文字に正規化されます。

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

機密変数テーブル（`$NBConfidentialSymbols`）を操作する API です。

```mathematica
NBRegisterConfidentialVar["apiKey", 1.0]   (* 変数を1つ登録 (level デフォルト 1.0) *)
NBUnregisterConfidentialVar["apiKey"]      (* 変数を1つ解除 *)
NBGetConfidentialVars[]                    (* 現在のテーブルを返す *)
NBSetConfidentialVars[<|"secret1" -> True, "secret2" -> True|>]  (* 一括設定 *)
NBClearConfidentialVars[]                  (* テーブルをクリア *)
```

### NBGetPrivacySpec

現在の `$NBPrivacySpec` を返します。`$NBPrivacySpec` が Association でない場合はデフォルト値 `<|"AccessLevel" -> 0.5|>` を返します。

```mathematica
NBGetPrivacySpec[]
(* <|"AccessLevel" -> 0.5|> *)
```

### アクセス可能ディレクトリ

Claude Code が参照可能なディレクトリリストを TaggingRules に保存・取得します。`nb` を省略すると `EvaluationNotebook[]` が使用されます。

```mathematica
NBSetAccessibleDirs[nb, {"/home/user/project", "/data"}]
NBGetAccessibleDirs[nb]
NBSetAccessibleDirs[{"/home/user/project"}]  (* EvaluationNotebook[] に保存 *)
NBGetAccessibleDirs[]                        (* EvaluationNotebook[] から取得 *)
```

### カーソル・セル操作

```mathematica
NBMoveToEnd[nb]                    (* 末尾に移動 *)
NBMoveAfterCell[nb, 5]            (* セル5の後ろに移動 *)
NBDeleteCellsByTag[nb, "temp"]    (* タグで一括削除 *)
NBEvaluatePreviousCell[nb]        (* 直前セルを評価（禁止パターンチェック付き） *)
```

#### NBEvaluatePreviousCell の禁止パターンチェック

`NBEvaluatePreviousCell` は単純な評価実行ではなく、`$NBAutoEvalProhibitedPatterns` に登録されたパターンを照合してから評価を行います。これは全 AutoEvaluate パスの最終防衛線であり、バイパスできません。

処理フローは以下のとおりです。

1. 直前セルの内容を `NotebookRead` で取得し、テキストに変換します。
2. `$NBAutoEvalProhibitedPatterns` が空でない場合、セルテキストが各パターンに `StringContainsQ` でマッチするか検査します。
3. **パターンにマッチした場合**: 評価をスキップし、赤文字で以下の警告を表示します。

```
⛔ セキュリティ保護: 上のセルはアクセス範囲を変更する操作を含むため自動実行をブロックしました。内容を確認してから Shift+Enter で手動実行してください。
```

4. **パターンにマッチしない場合**: 通常どおり `SelectionEvaluate` を実行します。

`$NBAutoEvalProhibitedPatterns` は [claudecode](https://github.com/transreal/claudecode) パッケージがロード時に登録します。デフォルトは空リストのため、claudecode をロードしない環境では常に通常評価が実行されます。

### NBParentNotebookOfCurrentCell

EvaluationCell の親ノートブックを返します。EvaluationCell が取得できない場合は `InputNotebook[]` にフォールバックします。

```mathematica
NBParentNotebookOfCurrentCell[]
```

### CellEpilog 管理

```mathematica
NBInstallCellEpilog[nb, "myHook", expr]           (* CellEpilog に式を設定 *)
NBCellEpilogInstalledQ[nb, "myHook"]               (* インストール済みか判定 *)
NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]  (* 機密追跡用 CellEpilog *)
NBConfidentialEpilogInstalledQ[nb, checkSymbol]    (* 機密追跡 CellEpilog が済みか *)
```

`NBInstallCellEpilog` と `NBInstallConfidentialEpilog` は既にインストール済みの場合は何もしません（冪等）。`NBInstallConfidentialEpilog` は `checkSymbol` を `FreeQ` のマーカーとして使用し、二重インストールを防止します。

### NBFilterHistoryEntry

履歴エントリから機密変数の名前・値を含むフィールドをブロックします。`response` または `code` フィールドに機密変数名が含まれている場合、そのフィールドの内容をブロックメッセージに置換します。

第3引数として機密変数のタイムスタンプ Association を渡すこともできます。エントリの `time` が最も早い機密変数の登録時刻より後の場合は、フィルタリングをスキップします（後から登録された機密変数は過去の履歴には適用しない）。

```mathematica
NBFilterHistoryEntry[entry, {"secretKey", "password"}]
NBFilterHistoryEntry[entry, {"secretKey"}, <|"secretKey" -> 3900000000|>]
```

---

## [実験的] ノートブックファイルのセル操作

claudecode パッケージの `ClaudeProcessFile` と連携し、.nb ファイルのセルをプライバシーレベルに基づいて分割・処理・マージする機能を提供します。

### NBFileOpen

.nb ファイルを invisible（非表示）モードで開き、ノートブックオブジェクトを返します。

```mathematica
nb = NBFileOpen["C:\\...\\sample.nb"]
```

### NBFileCells

ノートブック内の各セルの情報（テキスト・スタイル・プライバシーレベル）を取得します。

```mathematica
cells = NBFileCells[nb]
(* {<|"CellIdx" -> 1, "Style" -> "Text", "Text" -> "...", "PrivacyLevel" -> 0.0|>, ...} *)
```

プライバシーレベルは 3 段階で判定されます。

| レベル | 意味 | claudecode での LLM ルーティング先 |
|--------|------|-----------------------------------|
| 0.0 | 公開 | クラウド LLM (Claude Code CLI) |
| 0.75 | 秘匿依存 (dependent) | プライベート LLM |
| 1.0 | 秘匿 (Confidential) | プライベート LLM ($ClaudePrivateModel) |

### NBMergeNotebookCells

処理済みセル（LLM からの変換結果）を元のノートブック構造にマージし、指定パスに保存します。

```mathematica
NBMergeNotebookCells[srcNB, processedResults, "C:\\...\\output.nb"]
```

保存前後に同一パスの既存 invisible ノートブックをクリーンアップし、ファイルロック（エラー-43）を回避します。

### 変更履歴

以下のバグ修正・機能追加が行われました。

- **`NBCellSetStyle` の追加**: Cell 式の第2引数（スタイル）を書き換える新関数です。`SetOptions[cell, CellStyle -> ...]` ではセルスタイルが変わらないため、Cell 式全体を読み書きする実装になっています。TaggingRules 等の属性は保持されます。
- **`NBCellWriteCode` の追加**: 既存セルにコードを BoxData + Input スタイルで書き込む新関数です。FEParser で構文カラーリング付き BoxData に変換し、Cell 式全体を置換します。
- **`NBResolveCell` の追加**: セルインデックスに対応する CellObject を返す新関数です。外部パッケージが低レベルのセル参照を必要とする場合に使用します。指定インデックスが無効な場合は `$Failed` を返します。
- **`NBSelectCell` の追加**: セルブラケットを選択状態にする新関数です。パレット操作後のセル選択復元に使用します。
- **`SelectionMove` の `AutoScroll -> False`**: セル選択・移動処理全般に `AutoScroll -> False` を追加し、操作中の意図しないスクロールを抑制しました。
- **`iNBFileCellIsConfidential`**: TaggingRules が List 形式の場合にも対応（Extract → Lookup）
- **`iNBFileCellPrivacyLevel`**: 2 値（0/1）から 3 値（0/0.75/1.0）に拡張し dependent 対応
- **`iNBFileCellText`**: 裸文字列の捕捉に対応（Cases のレベル指定を `{0, Infinity}` に修正）
- **`NBMergeNotebookCells`**: 保存前後の invisible NB クリーンアップ処理を追加（エラー-43 対策）
- **Lookup ガード強化**: `iNBFileCellGetClaudeCodeCC`, `iNBFileCellIsConfidential`, `iNBFileCellPrivacyLevel` の全 Lookup に ListQ/AssociationQ チェックと Quiet ガードを追加

---

## 関連パッケージ

- [claudecode](https://github.com/transreal/claudecode) — Claude AI との対話を管理するメインパッケージ
- [NotebookExtensions](https://github.com/transreal/NotebookExtensions) — ノートブック拡張ユーティリティ
- [PresentationListener](https://github.com/transreal/PresentationListener) — プレゼンテーション連携