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
13. [カレンダーアクセス (iCal/ICS)](#カレンダーアクセス-ical-ics)
14. [$onWork タスクメタデータ](#onwork-タスクメタデータ)
15. [NBImport（LLM 生成コード向け仲介 Import）](#nbimportllm-生成コード向け仲介-import)
16. [API キー](#api-キー)
    - [クラウド LLM API キー](#クラウド-llm-api-キー)
    - [ローカル LLM API キー (LM Studio 等)](#ローカル-llm-api-キー-lm-studio-等)
17. [暗号鍵ストア (NBAccess_crypto)](#暗号鍵ストア-nbaccess_crypto)
18. [フォールバックモデル / プロバイダーアクセスレベル](#フォールバックモデル--プロバイダーアクセスレベル)
19. [ノートブックモデル選択と信頼ローカルサーバー管理](#ノートブックモデル選択と信頼ローカルサーバー管理)
20. [SourceVault との統合とパス参照 API](#sourcevault-との統合とパス参照-api)
21. [その他のユーティリティ](#その他のユーティリティ)
22. [クラウド公開宣言とノートブックキャッシュ修復](#クラウド公開宣言とノートブックキャッシュ修復)
23. [[実験的] ノートブックファイルのセル操作](#実験的-ノートブックファイルのセル操作)
24. [ClaudeRuntime との統合](#clauderuntime-との統合)
25. [ClaudeTestKit との連携](#claudetestkit-との連携)
26. [後方互換性](#後方互換性)

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

### NBDeleteCellsByTag

指定 CellTags を持つセルをすべて削除します。

```mathematica
NBDeleteCellsByTag[nb, "myTag"]
```

通知セル（"claudecode-notice" タグ）の一括削除や、ジョブスロットセルのクリーンアップに使用します。

### NBMoveAfterCell

指定セルの後ろにカーソルを移動します。

```mathematica
NBMoveAfterCell[nb, cellIdx]
```

コード挿入後のカーソル位置制御や、アンカーセル直後への移動に使用します。

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

なお、`NBCellRead[nb, 3]` のような「セル参照式」が LLM 生成コード内で検出された場合は、参照セル番号のリスト（例: `{3}`）が自動抽出され、実行検証 API（後述）の `ReadCells` フィールドに反映されます。

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

### NBCellGetText

複数の取得経路を組み合わせ、堅牢にセルテキストを取得するヘルパーです。FrontEnd の InputText 取得 → `NBCellToText` → `NBCellExprToText` の順でフォールバックし、最終的にテキストが取得できなければ空文字列を返します。

```mathematica
NBCellGetText[nb, 3]
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

第3引数として PrivacyLevel 数値（0.0〜1.0）を任意に指定でき、セルの PrivacyLevel を直接書き換えることもできます。`level > 0.5` の場合は赤背景マークが付与され、`level <= 0.5` の場合はマークが解除されます。

```mathematica
(* デフォルト: PrivacyLevel 1.0 として機密マークを付与 *)
NBMarkCellConfidential[nb, 3]

(* 任意の PrivacyLevel を指定する場合 *)
NBMarkCellConfidential[nb, 3, 0.8]
```

`NBMarkCellConfidential` は `$NBApprovalHeads` に登録されており、ClaudeRuntime 経由で LLM が実行する場合は人間の承認ゲートが起動します。直接 Mathematica から呼び出す場合は通常どおり評価されます。

### NBSetSnapshotPrivacyLevel

SourceVault snapshot の PrivacyLevel を直接書き換えます。snapshot の PrivacyLevel は通常、各セルの判定結果から自動導出されますが、人間が明示的に上書きしたい場合に使用します。

```mathematica
NBSetSnapshotPrivacyLevel["snapshot-abc123", 1.0]
```

`SourceVault` パッケージがロードされている必要があります。`NBSetSnapshotPrivacyLevel` も `$NBApprovalHeads` に登録されており、LLM 経由で呼び出した場合は人間の承認が要求されます。

### NBInsertArtifactCell

SourceVault artifact URI の内容を解決し、メディア種別に応じたセルとしてノートブックへ挿入します。

```mathematica
(* EvaluationNotebook[] へ挿入 *)
NBInsertArtifactCell["sv://artifact/abc123"]

(* 対象ノートブックを明示する場合 *)
NBInsertArtifactCell[nb, "sv://artifact/abc123"]

(* ハッシュ URI 形式 *)
NBInsertArtifactCell["sv://hash/sha256/deadbeef..."]

(* オプション指定 *)
NBInsertArtifactCell[nb, uri,
  "VideoCell" -> True,      (* True で Video[file] セル、既定はファイルリンク *)
  "MaxImageSize" -> 800,    (* 表示上の最大幅 px。None で原寸 *)
  "Materialize" -> Automatic
]
```

サポートする URI 形式:
- `sv://artifact/<id>` — artifact ID による参照
- `sv://hash/sha256/<hex>` — コンテンツハッシュによる参照

メディア種別ごとの挿入形式:

| MediaKind | 挿入形式 |
|---|---|
| Image | 画像セル |
| Video | Video[file] セルまたはファイルリンク（VideoCell オプション依存） |
| Binary | ファイルリンクセル |
| Text | 本文テキストセル |

セルには artifact の PrivacyLevel が必ず TaggingRules (`claudecode/privacyLevel`, `claudecode/confidential`) として焼き込まれます。`level > 0.5` の場合は `$NBConfidentialCellOpts` の機密マーク（赤背景 + 警告 dingbat）付きで出力されます。

内容解決は `SourceVault``SourceVaultResolveArtifactContent`（sanctioned reader）に委譲します。SourceVault が未ロードの場合はエラーを返します。生データを裸で返す API ではなく、実体化は常に privacy marking と一体であり、SourceVault のガードを剥がしません。

返り値:

```mathematica
<|
  "Status"       -> "Ok" | "Error",
  "URI"          -> "sv://artifact/...",
  "MediaKind"    -> "Image" | "Video" | "Binary" | "Text",
  "PrivacyLevel" -> 0.0 | 1.0,
  "Marked"       -> True | False
|>
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

### NBCellWriteText

既存セルのテキスト内容を新しいテキストで置き換えます。セルスタイル・TaggingRules・オプション等の属性はそのまま保持されます。

```mathematica
NBCellWriteText[nb, 3, "新しいテキスト"]
```

### NBCellSetTaggingRule

セルの TaggingRules に値をネストパス指定で書き込みます。`NBCellGetTaggingRule` の対となるセッター関数です。

```mathematica
NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]
```

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

出力遅延モードが有効（`NBBeginDeferredOutput` 実行後）の場合、After 書き込みはノートブックに即時反映されず内部バッファに溜められ、`NBFlushDeferredOutput` で一括出力されます。詳細は後述の「出力遅延バッファ」を参照してください。

### 出力遅延バッファ

非同期並列処理やブロック回避が必要な場面で、`NBWriteCell` の After 書き込みをいったんバッファに溜め、安全なタイミングで一括出力するための API 群です。これは出力集約対策（対策2）として導入されました。

#### NBBeginDeferredOutput / NBEndDeferredOutput

`NBBeginDeferredOutput[]` は出力遅延（集約）モードを有効にします。以降の `NBWriteCell[nb, cell]`（After）はノートブックに即書きせずバッファに溜められます。`NBEndDeferredOutput[]` は遅延モードを無効に戻します（バッファ内容は残るため、`NBFlushDeferredOutput` で出力する必要があります）。

```mathematica
NBBeginDeferredOutput[]
(* ... 複数の NBWriteCell ... *)
NBEndDeferredOutput[]
NBFlushDeferredOutput[nb]
```

#### NBFlushDeferredOutput

`NBFlushDeferredOutput[nb]` は溜めた Cell をノートブックに一括書き込みし、バッファをクリアします。返り値は出力した Cell 数です。

FrontEnd 操作であるため、メインカーネル評価で呼ぶ必要があります（罠 #30）。`nb` を省略した `NBFlushDeferredOutput[]` は `CellPrint` で出力します。

```mathematica
n = NBFlushDeferredOutput[nb]
(* 例: 5 *)
```

#### NBDeferredOutputActiveQ / NBDeferredOutputCount / NBDiscardDeferredOutput

```mathematica
NBDeferredOutputActiveQ[]    (* 出力遅延モードが有効か *)
NBDeferredOutputCount[]      (* バッファに溜まっている Cell 数 *)
NBDiscardDeferredOutput[]    (* バッファをフラッシュせずに破棄する *)
```

### NBWritePrintNotice

通知用 Print セルを書き込みます。CellTags に "claudecode-notice" を付与して、`NBScanDependentCells` のマーキング対象外にします。`nb` が `None` の場合は `CellPrint` を使用します（同期 In/Out 間出力）。

```mathematica
NBWritePrintNotice[nb, "処理が完了しました", Green]
NBWritePrintNotice[None, "同期出力", Blue]
```

### NBCellPrint

CellPrint のラッパー関数です。評価セルの直後に出力セルを挿入します。カーソル位置に依存せず、常に EvaluationCell の直後に配置されます。ClaudeBackupDataset 等のタグ付き出力セルに使用します。

```mathematica
NBCellPrint[Cell[BoxData[...], "Output", TaggingRules -> <|...|>]]
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

### NBCellTransformWithLLM

セル内容を非同期で LLM に渡して変換し、結果をコールバックで受け取るユーティリティです。プロンプト生成関数 `promptFn` がセルテキストを受け取り送信プロンプトを返し、`completionFn` が結果 Association を受け取ります。セルのプライバシーレベルに応じて適切な LLM が自動選択され、`$NBLLMQueryFunc` が登録されていれば非同期実行されます。

```mathematica
NBCellTransformWithLLM[nb, 3,
  Function[txt, "次の式を簡略化: " <> txt],
  Function[res, Print[res["Response"]]],
  Fallback -> True]
```

オプション:

- `Fallback -> False`: フォールバックモデルの使用可否です。
- `InputText -> Automatic`: セルテキストの代わりに使用する入力テキストを明示指定します。
- `Integrations -> Automatic`: LM Studio MCP のサーバーリストです（`lmstudio` モデル使用時のみ有効、`Automatic` の場合は無視されます）。

`completionFn` が受け取る Association は `<|"Response" -> 応答, "OriginalText" -> 元のセルテキスト, "PrivacyLevel" -> 0.0|1.0|>` の形式です。エラー時は `$Failed` が渡されます。

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
| `"claudeAccessiblePathRefs"` | Claude Code が参照可能な PathRef リスト（SourceVault 形式・正本） |
| `"claudecode-accessible-dirs"` | 旧形式の絶対パスリスト（read fallback のみ） |
| ネストパス `{"project", "name"}` 等 | 任意のプロジェクトメタデータ |

```mathematica
(* アクセス可能ディレクトリの保存（SourceVault 形式） *)
NBSetAccessiblePathRefs[nb,
  {<|"PathRef" -> NBNormalizePath["/home/user/project"],
     "Mode" -> "Read", "CloudSend" -> "Ask"|>}]

(* 後方互換のための絶対パス指定 *)
NBSetAccessibleDirs[nb, {"/home/user/project", "/data"}]
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
(* {"project", "chat", "claudeAccessiblePathRefs", ...} *)

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
NBHistoryCreate[nb, "chat", {"fullPrompt", "response", "code"}, <|"model" -> "claude-sonnet-4-6"|>]
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
NBHistoryUpdateHeader[nb, "chat", <|"model" -> "claude-sonnet-4-6"|>]
```

### NBHistoryListTags / NBHistoryDelete / NBHistoryReplaceEntries

タグ一覧・削除・エントリ全置換です。`NBHistoryDelete` は対応するキャッシュも無効化します。`NBHistoryReplaceEntries` はコンパクションやバッチ更新に使用します。

```mathematica
NBHistoryListTags[nb, "chat"]
NBHistoryDelete[nb, "chat-old"]
NBHistoryReplaceEntries[nb, "chat", newEntries]
```

### NBHistoryClearAll

指定プレフィックスで始まる全履歴をまとめて削除します。`PrivacySpec -> <|"AccessLevel" -> 1.0|>` を必須引数として要求し、誤操作を防止します。セルレベルの機密タグ・依存タグは削除しません。ノートブックを他者に渡す際の履歴情報除去に使用します。

```mathematica
NBHistoryClearAll[nb, "chat", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

### NBHistoryCacheClear

全履歴キャッシュをクリアします。パッケージ再ロード時やセッション切替時に使用します。

```mathematica
NBHistoryCacheClear[]
```

### NBFilterHistoryEntry

履歴エントリ内の `response` / `instruction` フィールドに、現時点の機密変数名または値が含まれる場合に、そのフィールドをブロックします。

```mathematica
NBFilterHistoryEntry[entry, confVars]
```

- `entry`: 履歴エントリ Association（`<|"role" -> _, "response" -> _, ...|>` 形式）
- `confVars`: 現在の機密変数名リスト

機密変数名が `response` や `instruction` フィールドに含まれる場合、当該フィールドの値を非表示プレースホルダに置換して返します。LLM に送信する会話履歴から機密情報の漏洩を防ぐために `NBHistoryEntriesWithInherit` と組み合わせて使用します。

```mathematica
(* 機密変数リストを渡してエントリをフィルタ *)
filtered = NBFilterHistoryEntry[
  <|"role" -> "user", "response" -> "secretKey の値は ..."|>,
  {"secretKey"}
]
(* → response フィールドがブロックされたエントリを返す *)
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

ジョブのスロット（システムメッセージ用 / 完了メッセージ用 / アンカー用の3スロットのいずれか）に Cell 式を書き込んで可視化します。同じスロットに再度書き込むと上書きされます。

```mathematica
NBWriteSlot[jobId, slotIdx, cellExpr]
```

---

## カレンダーアクセス (iCal/ICS)

オーナーの iCal/ICS カレンダー（.ics ファイルまたは http(s) URL）を読み取り、アクセスレベルに応じたフィールドのみを返す API 群です。すべてアクセスレベルでゲートされており、Summary/Description/Location/UID のような内容そのものは高いアクセスレベルでのみ返されます。RRULE（繰り返しルール）の展開に対応しており、[NotebookExtensions](https://github.com/transreal/NotebookExtensions) の `calendardata` にあった繰り返し処理のバグ（単一オフセット展開のみ、INTERVAL 無視、月計算の近似、DAILY/COUNT/BYDAY/EXDATE 未対応）を修正しています。

### NBCalendarEvents

`from` から `to` までの区間 `[from, to)` に重なるカレンダーイベントの発生を、Start でソートした Association のリストとして返します。

```mathematica
NBCalendarEvents[DateObject[{2026, 7, 16}], DateObject[{2026, 7, 23}]]
```

繰り返しイベント（RRULE）は個々の発生（occurrence）に展開されます。対応する要素は FREQ（DAILY/WEEKLY/MONTHLY/YEARLY）、INTERVAL、UNTIL、COUNT、BYDAY（`2MO` のような序数付きも含む）、BYMONTHDAY（負の値も含む）、EXDATE、RECURRENCE-ID による上書き（キャンセルされたインスタンスを含む）です。

**アクセスレベルによるフィールドの段階公開**

返されるフィールドは呼び出し側のアクセスレベル（PrivacySpec オプション、デフォルトは `$NBPrivacySpec`）に依存します。

| AccessLevel | 返却フィールド |
|---|---|
| < 0.5 | `Failure["NBCalendarAccessDenied"]` |
| >= 0.5 | フリー/ビジー情報 + アイデンティティメタデータのみ: Start/End/AllDay/Busy/Mandatory/Recurring/UIDDigest + R0b アイデンティティフィールド（EventId/OriginalStart/SemanticDigest/ObservedRevision） |
| >= 0.7 | 上記に加え Summary/Categories/Status |
| >= 1.0 | 全フィールド（Description/Location/UID を含む） |

**R0b アイデンティティ/リビジョンフィールド**（すべてのアクセスレベルで返される、値自体は不透明なトークン）:

- `"EventId"`: UID の HMAC キー付き安定 ID（`$NBCalendarIdentityKeyRef` を使用。未設定の場合は非キー付きフォールバック）。同一の繰り返しシリーズ内では発生ごとに変わりません。
- `"OriginalStart"`: 発生の元のシリーズ内スロット（上書きの場合は RECURRENCE-ID、それ以外は生成されたスロット）。発生ごとに安定したトークンで、開始時刻が変更（MOVED）された場合でも `Start` のみが変わり、こちらは変わりません。
- `"SemanticDigest"`: 挙動に関わるフィールド（OriginalStart、実効 Start/End、Status、Busy、AllDay）のダイジェスト。上書き検出（supersede detection）に使用します。
- `"ObservedRevision"`: SEQUENCE/DTSTAMP のダイジェスト（観測専用）。DTSTAMP のみの変更は `SemanticDigest` を変化させません。

オプション:

- `PrivacySpec -> Automatic`（`$NBPrivacySpec`）
- `"Source" -> Automatic`: `SystemCredential[$NBCalendarCredentialName]`、または明示的な .ics パス / http(s) URL。
- `"ICSText" -> ...`: 生の ICS テキストを直接渡す（テスト用の注入経路。`"Source"` をバイパスします）。
- `"MandatoryPatterns" -> Automatic`（`$NBCalendarMandatoryPatterns`）: Summary/Categories/Description に大文字小文字を区別せずマッチさせ、`Mandatory` フラグを設定する文字列パターンのリスト。このフラグは全アクセスレベルで維持されます。
- `"MaxEvents" -> 500`
- `"Refresh" -> False`: パースキャッシュをバイパスします。
- `"Wrap" -> False`: `True` の場合、裸のリストの代わりに `<|"Events" -> {...}, "ObservedAtUTC", "Count", "Truncated", "Completeness" (MaxEvents で切り詰められた場合は 1 未満), "IdentityKeyed"|>` を返します。

```mathematica
(* Wrap 付きで取得し、切り詰めの有無を確認する *)
result = NBCalendarEvents[
  DateObject[{2026, 7, 1}], DateObject[{2026, 8, 1}],
  "Wrap" -> True, "MaxEvents" -> 200]
result["Truncated"]
result["Completeness"]
```

### NBCalendarFreeBusy

`[from, to)` の区間でマージされたビジーブロック（重なるビジー発生は結合される）を `{<|"Start", "End", "Mandatory", "Count"|>, ...}` の形式で返します。`TRANSP:TRANSPARENT` が設定されたイベントは除外されます。内容を含まない（メタデータのみの）API のため、AccessLevel 0.5 から利用できます。ソース関連オプションは `NBCalendarEvents` と共通です。

```mathematica
NBCalendarFreeBusy[DateObject[{2026, 7, 16}], DateObject[{2026, 7, 17}]]
(* {<|"Start" -> ..., "End" -> ..., "Mandatory" -> True, "Count" -> 2|>, ...} *)
```

### NBCalendarBusyQ

指定した時刻 `t` がビジーなカレンダーブロック（会議中等）に含まれるかを返します。

```mathematica
NBCalendarBusyQ[Now]
(* True / False *)

NBCalendarBusyQ[Now, "Detailed" -> True]
(* <|"Busy" -> True, "Mandatory" -> True, "Block" -> <|"Start" -> ..., "End" -> ...|>|> *)
```

`"Detailed" -> True` の場合、`<|"Busy", "Mandatory", "Block"|>` の Association を返します。ソースが利用不可な場合は `Failure` ではなく `False` を返す（fail open）設計になっており、通知の抑制判定などが「非ビジー」側に倒れるようになっています。ソース関連オプションは `NBCalendarEvents` と共通です。

### NBICSParseEvents / NBICSEventOccurrences

低レベルの純粋パーサー API です。資格情報・ネットワーク・アクセスレベルによるゲーティングを一切行いません。

```mathematica
events = NBICSParseEvents[icsText]
(* UID/Summary/Description/Location/Status/Categories/Busy/Start/End/AllDay/RRule/ExDates/RecurrenceId を持つ Association のリスト *)

NBICSEventOccurrences[events[[1]], DateObject[{2026, 7, 1}], DateObject[{2026, 8, 1}]]
(* occurrence Start/End と "Recurring" -> True|False を持つ Association のリスト *)
```

`NBICSParseEvents` は行の折り返し（folded lines）、TEXT エスケープ、TZID/UTC/floating および `VALUE=DATE`（終日）の日付形式、DURATION を処理します。不正な VEVENT ブロックはスキップされます。`NBICSEventOccurrences` はパース済みの1イベントを `NBCalendarEvents` と同じ RRULE/EXDATE セマンティクスで展開します。

### カレンダー関連グローバル設定

| シンボル | 説明 |
|---|---|
| `$NBCalendarMandatoryPatterns` | 出席必須イベントとみなす文字列パターンのデフォルトリスト（Summary/Categories/Description に大文字小文字を区別せずマッチ）。デフォルトは空リスト `{}`。オーナーが実行時に設定し、導出される `Mandatory` フラグは全アクセスレベルで公開されます。 |
| `$NBCalendarCacheSeconds` | `NBCalendarEvents` が読むカレンダーソースのインメモリ・パースキャッシュの TTL（秒）。デフォルト 300。 |
| `$NBCalendarCredentialName` | ICS カレンダーの場所（ファイルパスまたは URL）を保持する SystemCredential キー。デフォルト `"ics-calendar"`。 |
| `$NBCalendarIdentityKeyRef` | 各イベントの不透明で安定した `"EventId"` を導出するための HMAC アイデンティティキーを保持する SystemCredential キー（署名/MAC 用の鍵とは別）。デフォルトは `Missing["None"]`（未設定時は `"unkeyed:<digest>"` 形式に劣化し、`"Wrap"->True` の `"IdentityKeyed"` は `False` になります）。このキーをローテーションすると EventId 内部の KeyId が変わるため、保存済みの EventId マッピングの移行が必要になります。 |

```mathematica
(* 出席必須パターンとカレンダー資格情報を設定する例 *)
$NBCalendarMandatoryPatterns = {"1on1", "面談"};
SystemCredential[$NBCalendarCredentialName] = "https://example.com/my-calendar.ics";
```

---

## $onWork タスクメタデータ

`$onWork` ディレクトリ配下のタスク管理用ノートブック（.nb ファイル）からメタデータのみを、アクセスレベルに応じて安全に読み取る API 群です。ノートブックの本文やセル出力は評価・読み取り一切行われません（メタデータオンリー）。

### NBOnWorkTaskSafeExtract

**HELD 式**（`HoldComplete[...]` または `Hold[...]` でメタデータ Association をラップしたもの、あるいはそれを先頭要素とするリスト）から $onWork ノートブックのタスクメタデータを、何も評価せずに抽出します。

```mathematica
NBOnWorkTaskSafeExtract[held]
```

ホワイトリストされた文字列キー（`Title`/`Status`/`Deadline`/`NextReview`/`EventDate`/`Keywords`/`Effort`/`Movable`/`DependsOn`/`TaskId`）のうち、リテラル値（String、Integer、Real、True/False、`DateObject[{整数...}, (粒度)]`、`Quantity[数値, 単位]`、文字列のリスト）を持つもののみが保持され、それ以外の全キー・値は破棄されます。副作用のある式・Notebook のボックス・巨大な式・UpValue を持つシンボルは決して評価されません。実装内に `ReleaseHold` は一切含まれません。安全な Association を返します。

### NBOnWorkTasks

`$onWork` の .nb ファイルを列挙し、`NBOnWorkTaskSafeExtract` で読み取ったメタデータをアクセスレベルに応じて射影したタスクレコードのリストを返します。

```mathematica
NBOnWorkTasks[]
NBOnWorkTasks[PrivacySpec -> <|"AccessLevel" -> 0.7|>]
```

各レコードは `"Due"`（`Deadline`、なければ `NextReview`。`NextReview` が `Quantity` の場合は `NotebookExtensions` と同様に ModificationDate + オフセットとして解決）と `"State"`（`Status` から Done/Pass/Keep、それ以外は Open）を導出します。

**アクセスレベルによるフィールドの段階公開**

| AccessLevel | 追加で公開されるフィールド |
|---|---|
| 0.5 | Due/DueKind/State/FileDigest/ModificationDate |
| 0.7 | 上記に加え Title/Keywords/TaskId/Effort/Movable/DependsOn |
| 1.0 | 上記に加え Path |

オプション:

- `"Directory" -> Automatic`（`Global`$onWork`）
- `"ModifiedWithinDays" -> Automatic`（デフォルトは全件対象）
- `"IncludeDone" -> False`: Status が Done/Pass のレコードを除外します。
- `PrivacySpec -> Automatic`
- `"MaxFiles" -> 2000`
- `"Files" -> Automatic`: テスト用の注入経路。`{<|"Path" -> _, "Held" -> HoldComplete[...], ("ModificationDate" -> _)|>, ...}` の形式でファイルシステムをバイパスします。

```mathematica
(* 未完了タスクのみ、直近7日以内に変更されたものだけを取得 *)
NBOnWorkTasks["ModifiedWithinDays" -> 7, "IncludeDone" -> False]
```

読み取り不能なファイル、またはメタデータの安全なパースに失敗したファイルは、スキャン全体を中断させずに `"State" -> "Unknown"`, `"ParseFailed" -> True` のレコードとして扱われます。

---

## NBImport（LLM 生成コード向け仲介 Import）

生の `Import` は `$NBDenyHeads` に登録された恒久禁止 head であり、ClaudeRuntime 経由で LLM 生成コードとして実行しようとすると ForbiddenHead 検出によりターン全体が即座に失敗します。とはいえ `Import` は WL でファイルを読み込む最も自然な関数であるため、単に禁止するだけでなく「代わりにこれを呼べ」と言える安全な受け皿として `NBImport` が追加されました。

```mathematica
NBImport[path]
NBImport[path, fmt]
```

### accessSpec を引数に取らない設計

`NBImport` は `accessSpec` を引数として受け取りません。もし引数で受け取る設計にすると、LLM 生成コードが自分に都合の良い緩い `accessSpec`（例: `<|"MayAccessFileSystem" -> "ReadOnly"|>` のような無制限指定）を書いてチェックを自己承認してしまいます。代わりに `NBImport` は、`NBExecuteHeldExpr` が検証済みの式を実行する際に `Block` で束縛する「本物の」ambient accessSpec（内部変数 `$iNBAmbientAccessSpec`）だけを参照します。

- **`NBExecuteHeldExpr` の管理下でのみ使用可能**: ambient accessSpec が束縛されていない文脈（NBAccess の管理された評価の外）で呼び出すと、`NBImport::noctx`（「NBImport は NBAccess 管理下の評価（NBExecuteHeldExpr）の中でのみ使えます」）を発行して `$Failed` を返します。
- **読み取り範囲**: ambient accessSpec の `AllowedDirectories`、それが空ならノートブックに宣言済みのアクセス可能ディレクトリ（`NBGetAccessibleDirs[]`）にスコープされます。どちらも空の場合は fail-closed で全拒否されます。
- **拒否時**: `NBImport::denied` メッセージ（`「〈path〉の読み取りは許可されていません（〈理由〉）。NBSetAccessibleDirs[{...}] でアクセス可能ディレクトリを宣言してください。」`）を発行し `$Failed` を返します。

```mathematica
(* NBExecuteHeldExpr が実行する LLM 生成コード内で使う想定 *)
data = NBImport["C:\\data\\report.csv", "CSV"];

(* アクセス可能ディレクトリが未宣言、または対象パスがスコープ外の場合 *)
NBImport["C:\\secret\\keys.txt"]
(* NBImport::denied: ... の読み取りは許可されていません (...)。NBSetAccessibleDirs[{...}] で ... *)
(* $Failed *)
```

### 評価スコープのプライバシー透かし（EvaluationPrivacy watermark）

変数単位の秘密依存追跡は、WL の組み込み評価に値レベルの taint 追跡フックが無いため原理的に不可能です。その代わりに `NBImport` は、読み込んだファイルの PrivacyLevel（`NBFileSpec` から取得）で、その評価スコープ全体の「透かしレベル」`$iNBEvaluationPrivacy` を `Max` 更新します。

この仕組みにより、静的解析（機密変数名や `Out[n]`/`In[n]`/`InString[n]`/`%` 参照の検出）だけでは捕捉できない経路——たとえば読み込んだファイル内容を静的解析が追跡できないローカル変数へ代入する場合など——で機密データが評価結果に混入しても、当該評価の出力全体を `NBRedactExecutionResult` が schema-only（値を含まずスキーマ情報のみ）にフォールバックできます。読み取り自体は許可しつつ、「読めるが漏れない」を成立させる保守的だが安全な設計です。`$iNBEvaluationPrivacy` は `NBExecuteHeldExpr` が式を実行するたびに `0.0` にリセットされます。

### 既存の NBCheckedImport との違い

低レベルの `NBCheckedImport[path, fmt, accessSpec]`（`NBCheckFileRead` 通過後に生の `Import` を呼ぶだけの薄いラッパー）は今も存在しますが、`accessSpec` を引数で受け取るため LLM 生成コードに直接使わせてはいけません。`NBAccess` の内部評価経路（例: `mathematica_eval` の評価ヘルパー）から呼ぶ内部プリミティブとしてのみ想定されています。LLM 向けには必ず `NBImport` を使用してください。

### Allowed Expression Surface / EffectClass 上の扱い

`NBImport` は許可 head カテゴリ `$NBAllowedHeadsByCategory["NBAccess_ReadOnly"]`（→ `$NBAllowedHeads` に自動反映）に登録されています。ただし実効的なアクセス制御は head 名の許可可否ではなく、上記の ambient accessSpec + ディレクトリスコープの検査で行われます。EffectClass 分類では `"EffectClass" -> "ReadOnlyFileSystem"`、`"ExecutionPlacement" -> "FileSystemReadOnly"` として登録されており、通常のファイル読み取りと同様 auto-permit 対象ですが、プライバシー漏洩の防止は上記の評価スコープ透かしが担います。

なお、組み込みの `FileByteCount`（ファイルサイズ等のメタデータのみを返し、本文は一切読まない関数）も同じ EffectClass override テーブルに `"ReadOnlyFileSystem"` として登録されています。以前は `"File"` という語幹からファイルシステムに触れる副作用系ビルトインと誤判定され、ファイル一覧の集計程度の用途でも承認要求が発生していましたが、この分類修正により不要な承認要求は発生しなくなりました。

---

## API キー

### クラウド LLM API キー

（本セクションは今後追記予定です。）

### ローカル LLM API キー (LM Studio 等)

（本セクションは今後追記予定です。）