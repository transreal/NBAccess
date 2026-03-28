# NBAccess パッケージ API リファレンス

**パッケージ**: NBAccess  
**リポジトリ**: https://github.com/transreal/NBAccess  
**対象ファイル**: NBAccess.wl  

---

## 概要

NBAccess は、Wolfram Language ノートブックのセルインデックスベースな読み書きとプライバシーフィルタリングを提供するユーティリティパッケージです。セルの読み書き・マーク・依存グラフ解析・履歴管理・LLM連携など、ノートブック操作に必要な幅広い機能を提供しています。

---

## オプション・グローバル変数

### `PrivacySpec`

```
PrivacySpec -> <|"AccessLevel" -> 値|>
```

NBAccess 関数のプライバシーフィルタリングオプションです。`AccessLevel` 以下のプライバシーレベルを持つセルのみアクセス可能になります。

| AccessLevel | 意味 |
|---|---|
| `0.5` | クラウド LLM 安全なデータのみ（デフォルト） |
| `1.0` | ローカル LLM 環境などすべてのデータ |

---

### `$NBPrivacySpec`

```
$NBPrivacySpec
```

NBAccess 関数のデフォルト `PrivacySpec` です。初期値は `<|"AccessLevel" -> 0.5|>`（クラウド LLM 安全なデータのみ）です。ローカル LLM 環境から利用する場合は `$NBPrivacySpec = <|"AccessLevel" -> 1.0|>` と設定してください。

---

### `$NBConfidentialSymbols`

```
$NBConfidentialSymbols
```

秘密変数名とプライバシーレベルのテーブルです。`<|"変数名" -> privacyLevel, ...|>` の形式です。ClaudeCode パッケージが自動的に更新します。

---

### `$NBSendDataSchema`

```
$NBSendDataSchema
```

秘密依存データのスキーマ情報をクラウド LLM に送信するかを制御するフラグです。

- `True`（デフォルト）: 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信します。
- `False`: 秘密依存 Output のスキーマ情報を一切送信しません。

非秘密 Output は常にスマート要約付きで送信されます。

---

### `$NBVerbose`

```
$NBVerbose
```

NBAccess パッケージの詳細ログ出力を制御するフラグです。`True` にすると NBAccess 内部の詳細ログを Messages に出力します。デフォルトは `False`（重大エラー以外のログを抑制）です。

---

### `$NBAutoEvalProhibitedPatterns`

```
$NBAutoEvalProhibitedPatterns
```

`NBEvaluatePreviousCell` で自動実行をブロックするパターンのリストです。`RegularExpression` または `StringExpression` のリストです。セル内容がいずれかのパターンにマッチする場合、評価をスキップして警告を表示します。ClaudeCode パッケージがロード時にパターンを登録します。デフォルトは空リストです。

---

### `$NBSeparationIgnoreList`

```
$NBSeparationIgnoreList
```

分離検査（`ClaudeCheckSeparation`）で無視するファイル名またはパッケージ名のリストです。NBAccess と NotebookExtensions はデフォルトで登録済みです。

**例:**
```mathematica
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

---

## セルユーティリティ API

### `NBCellCount`

```
NBCellCount[nb]
```

ノートブックの全セル数を返します。

---

### `NBCurrentCellIndex`

```
NBCurrentCellIndex[nb]
```

`EvaluationCell[]` のセルインデックスを返します。見つからない場合は `0` を返します。

---

### `NBSelectedCellIndices`

```
NBSelectedCellIndices[nb]
```

選択中セルのインデックスリストを返します。セルブラケット選択またはカーソル位置のセルを返します。

---

### `NBCellIndicesByTag`

```
NBCellIndicesByTag[nb, tag]
```

指定 `CellTags` を持つセルのインデックスリストを返します。

---

### `NBCellIndicesByStyle`

```
NBCellIndicesByStyle[nb, style]
NBCellIndicesByStyle[nb, {style1, style2, ...}]
```

指定 `CellStyle` のセルのインデックスリストを返します。複数スタイルを指定可能です。

---

### `NBDeleteCellsByTag`

```
NBDeleteCellsByTag[nb, tag]
```

指定 `CellTags` を持つセルをすべて削除します。

---

### `NBMoveAfterCell`

```
NBMoveAfterCell[nb, cellIdx]
```

セルの後ろにカーソルを移動します。

---

### `NBCellRead`

```
NBCellRead[nb, cellIdx]
```

`NotebookRead` で `Cell` 式を返します。

---

### `NBCellReadInputText`

```
NBCellReadInputText[nb, cellIdx]
```

FrontEnd 経由で `InputText` 形式を取得します。失敗時は `NBCellExprToText` にフォールバックします。

---

### `NBCellStyle`

```
NBCellStyle[nb, cellIdx]
```

セルの `CellStyle` を返します。

---

### `NBCellLabel`

```
NBCellLabel[nb, cellIdx]
```

セルの `CellLabel`（例: `"In[3]:="`）を返します。ラベルなしの場合は `""` を返します。

---

### `NBCellSetOptions`

```
NBCellSetOptions[nb, cellIdx, opts]
```

セルに `SetOptions` を適用します。

---

### `NBCellGetTaggingRule`

```
NBCellGetTaggingRule[nb, cellIdx, path]
```

`TaggingRules` のネスト値を返します。

**例:**
```mathematica
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
```

---

### `NBCellRasterize`

```
NBCellRasterize[nb, cellIdx, file, opts]
```

セルを `Rasterize` して `file` に保存します。

---

### `NBCellHasImage`

```
NBCellHasImage[cellExpr]
```

`Cell` 式が画像（`RasterBox`/`GraphicsBox`）を含むか判定します。`cellExpr` は `NBCellRead` の戻り値を想定します。

---

### `NBCellWriteText`

```
NBCellWriteText[nb, cellIdx, newText]
```

セルのテキスト内容を `newText` に置き換えます。セルスタイル・TaggingRules・オプション等の属性はそのまま保持されます。

**例:**
```mathematica
NBCellWriteText[nb, 3, "新しいテキスト"]
```

---

### `NBCellSetTaggingRule`

```
NBCellSetTaggingRule[nb, cellIdx, path, value]
```

セルの `TaggingRules` にネスト値を設定します。`NBCellGetTaggingRule` の対となるセッター関数です。

**例:**
```mathematica
NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]
```

---

## LLM 連携 API

### `$NBLLMQueryFunc`

```
$NBLLMQueryFunc
```

非同期 LLM 呼び出し用コールバック関数です。ClaudeCode パッケージが自動的に `ClaudeQueryAsync` を登録します。

**シグネチャ:**
```
$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]
```

`callback` は応答文字列を受け取る関数です。`nb` は出力先 `NotebookObject` です。カーネルをブロックしません。

---

### `NBCellGetText`

```
NBCellGetText[nb, cellIdx]
```

セルからテキストを堅牢に取得します。FrontEnd InputText → `NBCellToText` → `NBCellExprToText` の順でフォールバックします。テキスト取得不可の場合は `""` を返します。

---

### `NBCellTransformWithLLM`

```
NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn]
NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
```

非同期でセルを LLM 変換します。`promptFn` はセルテキストを受け取りプロンプト文字列を返す関数です。`completionFn` は結果 Association を受け取るコールバックです。エラー時は `$Failed` を受け取ります。カーネルをブロックしません。セルのプライバシーレベルに応じて適切な LLM を自動選択します。

**オプション:**

| オプション | デフォルト | 説明 |
|---|---|---|
| `Fallback` | `False` | フォールバックモデルを使用するか |
| `InputText` | `Automatic` | セルテキストの代わりに使用する入力テキスト |

**completionFn が受け取る Association:**
```mathematica
<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>
```

**例:**
```mathematica
NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]
```

---

## プライバシー API

### `NBCellPrivacyLevel`

```
NBCellPrivacyLevel[nb, cellIdx]
```

セルのプライバシーレベル（`0.0`〜`1.0`）を返します。`0.0`: 非秘密、`1.0`: 秘密（Confidential マークまたは秘密変数参照）です。

---

### `NBIsAccessible`

```
NBIsAccessible[nb, cellIdx, PrivacySpec -> ps]
```

セルが指定の `PrivacySpec` でアクセス可能かどうかを返します（`True`/`False`）。

---

### `NBFilterCellIndices`

```
NBFilterCellIndices[nb, indices, PrivacySpec -> ps]
```

セルインデックスリストを `PrivacySpec` でフィルタリングして返します。

---

## テキスト抽出 API

### `NBCellExprToText`

```
NBCellExprToText[cellExpr]
```

`NotebookRead` の結果（`Cell` 式）からテキストを抽出します。

---

### `NBCellToText`

```
NBCellToText[nb, cellIdx]
```

セルのテキスト内容を返します。

---

### `NBGetCells`

```
NBGetCells[nb, PrivacySpec -> ps]
```

ノートブック内の全セルインデックスを `PrivacySpec` でフィルタリングして返します。

---

### `NBGetContext`

```
NBGetContext[nb, afterIdx, PrivacySpec -> ps]
```

ノートブック内の `afterIdx` 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築します。`PrivacySpec` でフィルタリングされます。デフォルト: AccessLevel 0.5。

---

## 書き込み API

### `NBWriteText`

```
NBWriteText[nb, text, style]
```

ノートブックにテキストセルを書き込みます。`style` のデフォルトは `"Text"` です。

---

### `NBWriteCode`

```
NBWriteCode[nb, code]
```

構文カラーリング付き Input セルを書き込みます。

---

### `NBWriteSmartCode`

```
NBWriteSmartCode[nb, code]
```

`CellPrint[]` パターンを自動検出してスマートにセルを書き込みます。

---

### `NBWriteInputCellAndMaybeEvaluate`

```
NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
```

現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動します。`autoEvaluate` が `True` の場合はさらに `SelectionEvaluate` を行います。

---

### `NBInsertTextCells`

```
NBInsertTextCells[nbFile, name, prompt]
```

`.nb` ファイルを非表示で開き、末尾に Subsection セル（`name`）と Text セル（`prompt`）を挿入して保存・閉じます。

---

### `NBWriteCell`

```
NBWriteCell[nb, cellExpr]
NBWriteCell[nb, cellExpr, pos]
```

ノートブックに `Cell` 式を書き込みます（After）。`pos`（`After`/`Before`/`All`）を指定可能です。

---

### `NBWritePrintNotice`

```
NBWritePrintNotice[nb, text, color]
```

ノートブックに通知用 Print セルを書き込みます。`nb` が `None` の場合は `CellPrint` を使用します（同期 In/Out 間出力）。

---

### `NBWriteDynamicCell`

```
NBWriteDynamicCell[nb, dynBoxExpr, tag]
```

ノートブックに Dynamic セルを書き込みます。`tag` が `""` でない場合は `CellTags` を設定します。

---

### `NBWriteExternalLanguageCell`

```
NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
```

`ExternalLanguage` セルを書き込みます。`autoEvaluate` が `True` なら直前セルを評価します。

---

### `NBInsertAndEvaluateInput`

```
NBInsertAndEvaluateInput[nb, boxes]
```

Input セルを挿入して即座に評価します。

---

### `NBInsertInputAfter`

```
NBInsertInputAfter[nb, boxes]
```

Input セルを After に書き込み Before CellContents に移動します。

---

### `NBWriteAnchorAfterEvalCell`

```
NBWriteAnchorAfterEvalCell[nb, tag]
```

EvaluationCell 直後に不可視アンカーセルを書き込みます。EvaluationCell が取得できない場合はノートブック末尾に書き込みます。

---

## ファイル型ノートブック操作 API

閉じた `.nb` ファイルを対象とした読み書き操作です。秘密セルの有無に関わらず、必ずこの API を経由してください。上位層から `.nb` ファイルを直接 `NotebookOpen`/`NotebookGet` などで開いてはなりません。必ず `NBFileOpen` を使用してください。

### `NBFileOpen`

```
NBFileOpen[path]
```

`.nb` ファイルを非表示（`Visible->False`）で開き `NotebookObject` を返します。失敗時は `$Failed` を返します。必ず `NBFileClose` で閉じてください。

**例:**
```mathematica
nb2 = NBFileOpen["C:\\path\\to\\file.nb"]
```

---

### `NBFileClose`

```
NBFileClose[nb]
```

`NBFileOpen` で開いたノートブックを閉じます。

**例:**
```mathematica
NBFileClose[nb2]
```

---

### `NBFileSave`

```
NBFileSave[nb, path]
```

開いているノートブックを指定パスに保存します。`path` が `None` の場合は上書き保存します。

**例:**
```mathematica
NBFileSave[nb2, "C:\\path\\to\\translated.nb"]
```

---

### `NBFileReadCells`

```
NBFileReadCells[nb, PrivacySpec -> ps]
```

開いているノートブックの全セルを `PrivacySpec` に従ってフィルタリングし、`{<|cellIdx, style, text, privacyLevel|>, ...}` を返します。`privacyLevel > PrivacySpec` の秘密セルはテキストを `"[CONFIDENTIAL]"` に置換します。

**例:**
```mathematica
cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel"->0.5|>]
```

---

### `NBFileReadAllCells`

```
NBFileReadAllCells[nb]
```

開いているノートブックの全セルをアクセスレベル別に分類して返します。秘密セルも含む全セルを返しますが `PrivacyLevel` フィールドで識別できます。ローカルモデルで処理する際に使用します。

**例:**
```mathematica
cells = NBFileReadAllCells[nb2]
```

---

### `NBFileWriteCell`

```
NBFileWriteCell[nb, cellIdx, newText]
```

開いているノートブックの指定セルのテキストを `newText` で置き換えます。セルスタイル・TaggingRules・秘密マーク等の属性はそのまま保持されます。

**例:**
```mathematica
NBFileWriteCell[nb2, 3, "This is a pen."]
```

---

### `NBFileWriteAllCells`

```
NBFileWriteAllCells[nb, replacements]
```

`{cellIdx -> newText, ...}` の Association または List に従って複数セルを一括置換します。

**例:**
```mathematica
NBFileWriteAllCells[nb2, <|2->"text", 3->"[CONFIDENTIAL]"|>]
```

---

### `NBFileReadCellsInRange`

```
NBFileReadCellsInRange[nb, lo, hi]
```

`PrivacyLevel` が `lo`〜`hi` のセルのみ返します。

**例:**
```mathematica
NBFileReadCellsInRange[nb2, 0.5, 0.5]  (* 公開セルのみ *)
NBFileReadCellsInRange[nb2, 0.9, 1.0]  (* 秘密セルのみ *)
```

---

### `NBSplitNotebookCells`

```
NBSplitNotebookCells[path, threshold]
```

`.nb` ファイルのセルを `PrivacyLevel <= threshold`（公開）と `> threshold`（非公開）に2分割します。戻り値: `{publicCells, privateCells}`。

**例:**
```mathematica
{pub, priv} = NBAccess`NBSplitNotebookCells["file.nb", 0.5]
```

---

### `NBMergeNotebookCells`

```
NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
```

2つの `<|cellIdx->newText|>` を元セル順にマージして `outputPath` に保存します。

**例:**
```mathematica
NBAccess`NBMergeNotebookCells[src, dst, pubResults, privResults]
```

---

## ObjectSpec API

### `NBFileSpec`

```
NBFileSpec[path]
```

ファイルのメタ情報と `PrivacyLevel` を Association で返します。`PrivacyLevel`: `0.5`=クラウド LLM 可、`1.0`=ローカルのみ、`{0.5,1.0}`=混在（.nb）。

**例:**
```mathematica
NBFileSpec["C:\\path\\file.nb"]
```

---

### `NBValueSpec`

```
NBValueSpec[expr, privacyLevel]
```

値の型情報と `PrivacyLevel` を返します。

**例:**
```mathematica
NBValueSpec[dataset, 1.0]
```

---

### `NBPrivacyLevelToRoutes`

```
NBPrivacyLevelToRoutes[privacyLevel]
```

必要なモデルルートリストを返します。`0.5 -> {"cloud"}`、`1.0 -> {"local"}`、`{0.5,1.0} -> {"cloud","local"}`。

**例:**
```mathematica
NBPrivacyLevelToRoutes[{0.5, 1.0}]
```

---

## セルマーク API

### `NBGetConfidentialTag`

```
NBGetConfidentialTag[nb, cellIdx]
```

`TaggingRules` から機密タグを返します: `True`/`False`/`Missing[]`。

---

### `NBSetConfidentialTag`

```
NBSetConfidentialTag[nb, cellIdx, val]
```

セルの機密タグを `val`（`True`/`False`）に設定します。

---

### `NBMarkCellConfidential`

```
NBMarkCellConfidential[nb, cellIdx]
```

セルに機密マーク（赤背景 + WarningSign）を付けます。

---

### `NBMarkCellDependent`

```
NBMarkCellDependent[nb, cellIdx]
```

セルに依存機密マーク（橙背景 + LockIcon）を付けます。機密変数に依存する計算結果など、間接的に機密なセルに使用します。

---

### `NBUnmarkCell`

```
NBUnmarkCell[nb, cellIdx]
```

セルの機密マーク（視覚・タグ）をすべて解除します。

---

## セル内容分析 API

### `NBCellUsesConfidentialSymbol`

```
NBCellUsesConfidentialSymbol[nb, cellIdx]
```

セルが機密変数を参照しているかを返します。

---

### `NBCellExtractVarNames`

```
NBCellExtractVarNames[nb, cellIdx]
```

セル内容から `Set`/`SetDelayed` の LHS 変数名を抽出します。

---

### `NBCellExtractAssignedNames`

```
NBCellExtractAssignedNames[nb, cellIdx]
```

セル内容から `Confidential[]` 内の代入先変数名を抽出します。

---

### `NBShouldExcludeFromPrompt`

```
NBShouldExcludeFromPrompt[nb, cellIdx]
```

セルがプロンプトから除外すべきかを返します。

---

### `NBIsClaudeFunctionCell`

```
NBIsClaudeFunctionCell[nb, cellIdx]
```

セルが Claude 関数呼び出しセルかを返します。

---

## 依存グラフ API

### `NBBuildVarDependencies`

```
NBBuildVarDependencies[nb]
```

ノートブックの Input セルを解析して変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返します。文字列リテラル内の識別子は除外されます。

---

### `NBBuildGlobalVarDependencies`

```
NBBuildGlobalVarDependencies[]
```

`Notebooks[]` 全体の Input セルを走査して統合された変数依存関係グラフ `<|"var" -> {"dep1",...}|>` を返します。LLM 呼び出し直前の精密チェックで使用します。通常のセル実行時は軽量版 `NBBuildVarDependencies[nb]` を使用してください。

---

### `NBUpdateGlobalVarDependencies`

```
NBUpdateGlobalVarDependencies[existingDeps, afterLine]
```

既存の依存グラフに `CellLabel In[x]`（`x > afterLine`）のセルのみを追加走査してマージします。戻り値は `{updatedDeps, newLastLine}` です。完全なグラフを毎回構築するコストを回避するインクリメンタル版です。

---

### `NBTransitiveDependents`

```
NBTransitiveDependents[deps, confVars]
```

`deps` グラフ上で `confVars` に直接・間接依存する全変数名リストを返します。

---

### `NBScanDependentCells`

```
NBScanDependentCells[nb, confVarNames]
NBScanDependentCells[nb, confVarNames, deps]
```

依存グラフを使って機密変数に依存するセルに `NBMarkCellDependent` を適用し、新たにマークしたセル数を返します。事前計算済みの依存グラフ `deps` を渡すと二重計算を回避できます。Claude 関数呼び出しセル（`ClaudeQuery` 等）は除外されます。

---

### `NBFilterHistoryEntry`

```
NBFilterHistoryEntry[entry, confVars]
```

履歴エントリ内の `response`/`instruction` に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックします。`confVars` は現在の機密変数名リストです。

---

### `NBDependencyEdges`

```
NBDependencyEdges[nb]
NBDependencyEdges[nb, confVars]
```

ノートブックの変数依存関係をエッジリストで返します。戻り値: `{DirectedEdge["dep", "var"], ...}`。`"dep" → "var"` は「var が dep に依存する」を意味します。`confVars` を指定すると機密変数 `confVars` に関連するエッジのみ返します。

---

### `NBDebugDependencies`

```
NBDebugDependencies[nb, confVars]
```

依存グラフ・推移依存・セルテキストを `Print` で表示するデバッグ関数です。各 Input セルについて InputText 取得結果、代入解析結果、依存判定結果を出力します。

---

### `NBPlotDependencyGraph`

```
NBPlotDependencyGraph[]
NBPlotDependencyGraph[nb]
```

全ノートブック統合の依存グラフをプロットします（デフォルト）。`nb` を指定すると指定ノートブックの依存グラフをプロットします。ノードは変数名・`Out[n]` で、直接秘密は赤、依存秘密は橙で着色します。NB内エッジは濃い実線、クロスNBエッジは薄い破線で描画します。

**オプション:**

| オプション | デフォルト | 説明 |
|---|---|---|
| `"Scope"` | `"Global"` | `"Global"` または `"Local"` |
| `PrivacySpec` | — | 表示範囲を制御 |

**例:**
```mathematica
NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]
```

---

### `NBGetFunctionGlobalDeps`

```
NBGetFunctionGlobalDeps[nb]
```

ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返します。戻り値: `<|"関数名" -> {"大域変数1", ...}, ...|>`。パターン変数とスコーピング局所変数（`Module`/`Block`/`With`/`Function`）は除外されます。

---

## ノートブック TaggingRules API

### `NBGetTaggingRule`

```
NBGetTaggingRule[nb, key]
NBGetTaggingRule[nb, {key1, key2, ...}]
```

ノートブックの `TaggingRules` から `key` の値を返します。ネストしたパスを指定可能です。キーが存在しない場合は `Missing[]` を返します。

---

### `NBSetTaggingRule`

```
NBSetTaggingRule[nb, key, value]
NBSetTaggingRule[nb, {key1, key2}, value]
```

ノートブックの `TaggingRules` に `key -> value` を設定します。ネストしたパスを指定可能です。

---

### `NBDeleteTaggingRule`

```
NBDeleteTaggingRule[nb, key]
```

ノートブックの `TaggingRules` から `key` を削除します。

---

### `NBListTaggingRuleKeys`

```
NBListTaggingRuleKeys[nb]
NBListTaggingRuleKeys[nb, prefix]
```

ノートブックの `TaggingRules` の全キーを返します。`prefix` を指定すると prefix で始まるキーのみ返します。

---

## 汎用履歴データベース API

### `NBHistoryData`

```
NBHistoryData[nb, tag]
```

`TaggingRules` から履歴データを読み取り、差分圧縮されたエントリを復元して返します。`Decompress -> False` オプションで Diff オブジェクトのまま返します。戻り値: `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`。

---

### `NBHistoryRawData`

```
NBHistoryRawData[nb, tag]
```

差分圧縮を解除せずに履歴データを返します（内部用）。

---

### `NBHistorySetData`

```
NBHistorySetData[nb, tag, data]
```

`TaggingRules` に履歴データを書き込みます。`data` は `<|"header" -> ..., "entries" -> {...}|>` の形式です。`entries` は差分圧縮されていない平文で渡すこと。自動的に圧縮されます。

---

### `NBHistoryAppend`

```
NBHistoryAppend[nb, tag, entry]
```

エントリを履歴に追加します。差分圧縮: 直前のエントリの `fullPrompt`/`response`/`code` を Diff で圧縮します。`PrivacySpec -> ps` オプションで `privacylevel` をエントリに記録します。

---

### `NBHistoryEntries`

```
NBHistoryEntries[nb, tag]
```

差分圧縮を復元した全エントリリストを返します。`Decompress -> False` オプションで Diff オブジェクトのまま返します。

---

### `NBHistoryUpdateLast`

```
NBHistoryUpdateLast[nb, tag, updates]
```

最後のエントリを更新します。`updates` は `<|"response" -> ..., "code" -> ..., ...|>` の形式です。

---

### `NBHistoryReadHeader`

```
NBHistoryReadHeader[nb, tag]
```

履歴のヘッダー Association を返します。

---

### `NBHistoryWriteHeader`

```
NBHistoryWriteHeader[nb, tag, header]
```

履歴のヘッダーを書き込みます。

---

### `NBHistoryEntriesWithInherit`

```
NBHistoryEntriesWithInherit[nb, tag]
```

親履歴を含む全エントリを返します。`header` の `parent`/`inherit`/`created` に従って親チェーンを辿ります。`Decompress -> False` オプションで Diff オブジェクトのまま返します。

---

### `NBHistoryListTags`

```
NBHistoryListTags[nb, prefix]
```

`prefix` で始まる履歴タグ一覧を返します。

---

### `NBHistoryDelete`

```
NBHistoryDelete[nb, tag]
```

指定タグの履歴を `TaggingRules` から削除します。

---

### `NBHistoryReplaceEntries`

```
NBHistoryReplaceEntries[nb, tag, entries]
```

エントリリスト全体を置換します。コンパクションやバッチ更新に使用します。

---

### `NBHistoryUpdateHeader`

```
NBHistoryUpdateHeader[nb, tag, updates]
```

ヘッダーにキーを追加・更新します。既存キーは上書き、新規キーは追加されます。

---

### `NBHistoryCreate`

```
NBHistoryCreate[nb, tag, diffFields]
NBHistoryCreate[nb, tag, diffFields, headerOverrides]
```

新しい履歴データベースを作成します。`diffFields` は差分圧縮対象のフィールド名リスト（例: `{"fullPrompt", "response", "code"}`）です。`headerOverrides` でヘッダーを上書き可能です。既存 DB に `diffFields` がある場合は既存ヘッダーを返します（冪等）。

---

### `NBHistoryAddAttachment`

```
NBHistoryAddAttachment[nb, tag, path]
```

セッションにファイルをアタッチします。ヘッダーの `"attachments"` リストにパスを追加します（重複除去）。

---

### `NBHistoryRemoveAttachment`

```
NBHistoryRemoveAttachment[nb, tag, path]
```

セッションからファイルをデタッチします。

---

### `NBHistoryGetAttachments`

```
NBHistoryGetAttachments[nb, tag]
```

セッションのアタッチメントリストを返します。

---

### `NBHistoryClearAttachments`

```
NBHistoryClearAttachments[nb, tag]
```

セッションの全アタッチメントをクリアします。

---

### `NBHistoryClearAll`

```
NBHistoryClearAll[nb, prefix, PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

`prefix` で始まる全履歴を削除します。

**重要**: `PrivacySpec -> <|"AccessLevel" -> 1.0|>` が必須です。呼び出し側で明示指定してください。`AccessLevel` が `1.0` 未満の場合はエラーになります。

セルレベルの機密・機密依存タグは削除しません。ノートブックを他者に渡す際の履歴情報除去用です。

**例:**
```mathematica
NBHistoryClearAll[nb, "claudecode-", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

---

## 履歴プライバシーフィルター

### `NBFilterHistoryEntry`

```
NBFilterHistoryEntry[entry, confVars]
```

履歴エントリ内の `response`/`instruction` に現時点の機密変数名または値が含まれる場合にそのフィールドをブロックします。`confVars` は現在の機密変数名リストです。

---

## API キーアクセサー

### `NBGetAPIKey`

```
NBGetAPIKey[provider]
```

AI プロバイダーの API キーを返します。

**provider の値:**

| 値 | 説明 |
|---|---|
| `"anthropic"` | Anthropic API キー |
| `"openai"` | OpenAI API キー |
| `"github"` | GitHub API キー |

**重要**: `AccessLevel >= 1.0` が必須です。呼び出し側で `PrivacySpec -> <|"AccessLevel" -> 1.0|>` を明示指定してください。`SystemCredential` へのアクセスを一元管理します。

**例:**
```mathematica
NBGetAPIKey["anthropic", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

---

## フォールバックモデル / プロバイダーアクセスレベル API

### `NBSetFallbackModels`

```
NBSetFallbackModels[models]
```

フォールバックモデルリストを設定します。`models`: `{{"provider","model"}, {"provider","model","url"}, ...}`。

**例:**
```mathematica
NBSetFallbackModels[{{"anthropic","claude-opus-4-6"},{"lmstudio","gpt-oss-20b","http://127.0.0.1:1234"}}]
```

---

### `NBGetFallbackModels`

```
NBGetFallbackModels[]
```

フォールバックモデルリスト全体を返します。

---

### `NBSetProviderMaxAccessLevel`

```
NBSetProviderMaxAccessLevel[provider, level]
```

プロバイダーの最大アクセスレベルを設定します。`level`: `0.0`〜`1.0`。このレベルを超えるアクセスレベルのリクエストにはフォールバックしません。

**例:**
```mathematica
NBSetProviderMaxAccessLevel["anthropic", 0.5]
NBSetProviderMaxAccessLevel["lmstudio", 1.0]
```

---

### `NBGetProviderMaxAccessLevel`

```
NBGetProviderMaxAccessLevel[provider]
```

プロバイダーの最大アクセスレベルを返します。未登録プロバイダーは `0.5` を返します。

---

### `NBGetAvailableFallbackModels`

```
NBGetAvailableFallbackModels[accessLevel]
```

指定アクセスレベルで利用可能なフォールバックモデルのリストを返します。プロバイダーの `MaxAccessLevel >= accessLevel` のモデルのみ含まれます。

**例:**
```mathematica
NBGetAvailableFallbackModels[0.8]  (* → lmstudio のみ *)
NBGetAvailableFallbackModels[0.5]  (* → 全プロバイダー *)
```

---

### `NBProviderCanAccess`

```
NBProviderCanAccess[provider, accessLevel]
```

プロバイダーが指定アクセスレベルのデータにアクセス可能かを返します（`True`/`False`）。`MaxAccessLevel >= accessLevel` なら `True` です。

---

## アクセス可能ディレクトリ API

### `NBSetAccessibleDirs`

```
NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
NBSetAccessibleDirs[{dir1, dir2, ...}]
```

Claude Code が参照可能なディレクトリリストを `TaggingRules` に保存します。引数なしバージョンは `EvaluationNotebook[]` に保存します。

---

### `NBGetAccessibleDirs`

```
NBGetAccessibleDirs[nb]
NBGetAccessibleDirs[]
```

保存されたアクセス可能ディレクトリリストを返します。引数なしバージョンは `EvaluationNotebook[]` から取得します。

---

### `NBMoveToEnd`

```
NBMoveToEnd[nb]
```

ノートブックの末尾にカーソルを移動します。

---

## Job 管理 API

`ClaudeQuery`/`ClaudeEval` の非同期出力位置管理用 API です。

### `NBBeginJob`

```
NBBeginJob[nb, evalCell]
```

評価セルの直後に3つの不可視スロットセルを挿入し Job ID を返します。`evalCell` が `CellObject` でない場合はノートブック末尾に挿入します。

- スロット1: システムメッセージ（プログレス・フォールバック通知）
- スロット2: 完了メッセージ
- アンカー: レスポンス書き込み位置マーカー

---

### `NBWriteSlot`

```
NBWriteSlot[jobId, slotIdx, cellExpr]
```

ジョブのスロットに `Cell` 式を書き込み可視にします。同じスロットに再度書き込むと上書きされます。

---

### `NBJobMoveToAnchor`

```
NBJobMoveToAnchor[jobId]
```

アンカーセルの直後にカーソルを移動します。レスポンスコンテンツの書き込み前に呼びます。

---

### `NBEndJob`

```
NBEndJob[jobId]
```

ジョブを正常終了します。未書き込みスロットとアンカーを削除してテーブルをクリアします。

---

### `NBAbortJob`

```
NBAbortJob[jobId, errorMsg]
```

エラーメッセージを書き込みジョブを終了します。

---

## 分離 API

`claudecode` が `CellObject`/`Private` に直接触れないための公開 API です。

### `NBBeginJobAtEvalCell`

```
NBBeginJobAtEvalCell[nb]
```

`EvaluationCell[]` を内部取得してその直後に Job スロットを挿入します。`claudecode` が `CellObject` を保持する必要がありません。

---

### `NBExtractAssignments`

```
NBExtractAssignments[text]
```

テキストから `Set`/`SetDelayed` の LHS 変数名を抽出します。

---

### `NBSetConfidentialVars`

```
NBSetConfidentialVars[assoc]
```

機密変数テーブルを一括設定します。`assoc`: `<|"varName" -> True, ...|>`。

---

### `NBGetConfidentialVars`

```
NBGetConfidentialVars[]
```

現在の機密変数テーブルを返します。

---

### `NBClearConfidentialVars`

```
NBClearConfidentialVars[]
```

機密変数テーブルをクリアします。

---

### `NBRegisterConfidentialVar`

```
NBRegisterConfidentialVar[name, level]
```

機密変数を1つ登録します（`level` デフォルト `1.0`）。

---

### `NBUnregisterConfidentialVar`

```
NBUnregisterConfidentialVar[name]
```

機密変数を1つ解除します。

---

### `NBGetPrivacySpec`

```
NBGetPrivacySpec[]
```

現在の `$NBPrivacySpec` を返します。

---

### `NBInstallCellEpilog`

```
NBInstallCellEpilog[nb, key, expr]
```

ノートブックの `CellEpilog` に式を設定します。`key` は識別用文字列です。既にインストール済みなら何もしません。

---

### `NBCellEpilogInstalledQ`

```
NBCellEpilogInstalledQ[nb, key]
```

`CellEpilog` が `key` で既にインストールされているか返します。

---

### `NBEvaluatePreviousCell`

```
NBEvaluatePreviousCell[nb]
```

直前のセルを選択して評価します。

---

### `NBInsertInputTemplate`

```
NBInsertInputTemplate[nb, boxes]
```

Input セルテンプレートを挿入します。

---

### `NBParentNotebookOfCurrentCell`

```
NBParentNotebookOfCurrentCell[]
```

`EvaluationCell` の親ノートブックを返します。

---

### `NBInstallConfidentialEpilog`

```
NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
```

機密変数追跡用 `CellEpilog` をインストールします。`checkSymbol` は `FreeQ` チェック用のマーカーシンボルです。既にインストール済みなら何もしません。

---

### `NBConfidentialEpilogInstalledQ`

```
NBConfidentialEpilogInstalledQ[nb, checkSymbol]
```

機密追跡 `CellEpilog` がインストール済みか返します。`checkSymbol` は `FreeQ` チェック用のマーカーシンボルです。

---

## 関連パッケージ

- [claudecode](https://github.com/transreal/claudecode) — Claude API 連携・`ClaudeQueryAsync` 登録・機密変数追跡 CellEpilog のインストール元