# NBAccess

Mathematica ノートブックのセル単位の読み書き・プライバシーフィルタリング・履歴管理・依存グラフ解析を提供するユーティリティパッケージです。

**リポジトリ:** https://github.com/transreal/NBAccess

## 設計思想と実装の概要

NBAccess は、Mathematica ノートブックを「セルの配列」として扱い、すべての操作を **セルインデックス（1-based の整数）** で統一的にアクセスする設計を採用しています。これにより、CellObject の直接操作に伴う煩雑さを隠蔽し、LLM エージェントや自動化スクリプトからノートブックを安全かつ簡潔に操作できます。

### プライバシーファーストの設計

本パッケージの最大の特徴は、すべてのセル読み取り操作に **プライバシーフィルタリング** が組み込まれている点です。各セルには 0.0（非機密）〜 1.0（機密）のプライバシーレベルが付与され、`PrivacySpec` オプションの `AccessLevel` と比較することでアクセス制御を行います。デフォルトの `AccessLevel` は 0.5 で、これはクラウド LLM に送信しても安全なデータのみを許可する設定です。ローカル LLM 環境では 1.0 に変更することで全データにアクセスできます。

この仕組みにより、API キーやパスワードなどの機密情報が意図せず LLM のプロンプトに含まれることを防ぎます。機密セルには赤背景（直接機密）や橙背景（依存機密）の視覚的マークが付与され、ユーザーが一目で安全性を確認できます。

`NBGetContext` はセルレベルのプライバシーチェックを行い、機密マーク済みセルはその内容を完全に非表示にし、対応する Output セルも自動的に除外します。変数名ベースのリダクションに加え、セル全体の機密レベルを先にチェックすることで、より確実なプライバシー保護を実現しています。

### スマート出力要約とスキーマ情報送信

`NBGetContext` は Output セルに対して **3段階の処理** を適用します。非秘密 Output には **スマート要約** を適用し、短い出力はそのまま含め、長い出力にはデータ型・サイズ・先頭プレビューを付与して要約します。Association、Dataset、NestedList/Matrix、List、SparseArray、NumericArray、Graphics/Image などのデータ型が自動検出されます。

秘密依存 Output に対しては、`$NBSendDataSchema` フラグに基づき、値を含まないスキーマ情報（データ型・サイズ・キー名等）のみを送信するか、完全にスキップするかを選択できます。これにより、LLM が秘密データの値を知らなくても適切なコードを生成できるようになります。

セルテキストの取得には `FrontEnd`ExportPacket` 経由の `NBCellReadInputText` を優先し、2D 表示（Sum、Integral 等の数式表記）も正しくテキスト変換できます。失敗時には `NBCellGetText`（FrontEnd InputText → `NBCellToText` → `NBCellExprToText` の順でフォールバック）による堅牢な取得機構を備えています。CellObject を直接受け取る `iCellToInputText` 内部関数も提供されており、より柔軟なテキスト抽出が可能です。

### セルの非同期 LLM 変換

`NBCellTransformWithLLM` は、セルのプライバシーレベルに応じて適切な LLM を自動選択し、非同期でセルを変換します。カーネルをブロックせず、完了コールバックで結果を受け取ります。これにより、機密データは自動的にローカル LLM のみに送信され、クラウド LLM への漏洩が防止されます。

### フォールバックモデルとプロバイダーアクセスレベル

NBAccess は、LLM プロバイダーごとに最大アクセスレベルを設定する仕組みを提供します。これにより、機密データ（AccessLevel > 0.5）はローカル LLM（例: LM Studio）のみに送信し、非機密データはクラウド LLM（Anthropic、OpenAI 等）にも送信可能にする、といった柔軟なアクセス制御が実現できます。フォールバックモデルリストと組み合わせることで、メイン LLM が利用不可の場合にアクセスレベルに応じた適切な代替モデルを自動選択できます。

### 変数依存グラフによる自動検出

NBAccess は Input セルの代入文を静的に解析し、変数間の依存関係グラフを構築します。機密変数に直接・間接的に依存するすべてのセルを推移的に検出し、自動的に「依存機密」としてマークします。これにより、`apiKey = "sk-..."` のような直接的な機密だけでなく、`result = callAPI[apiKey]` のような間接的な機密も漏れなく保護されます。

`NBScanDependentCells` は事前計算済みの依存グラフを受け取るオーバーロードを提供しており、同一ノートブックに対して複数回スキャンする場合の二重計算を回避できます。また、`NBUpdateGlobalVarDependencies` により、既存の依存グラフに新しいセルのみを追加走査してマージするインクリメンタル更新も可能です。

`NBBuildGlobalVarDependencies` は開いている全ノートブック（`Notebooks[]`）の Input セルを横断的に走査し、統合された変数依存関係グラフを構築します。これは ClaudeQuery/ClaudeEval/ContinueEval の直前に行う精密チェックで使用されます。通常のセル実行時には軽量版の `NBBuildVarDependencies[nb]` を使用してください。`NBExtractAssignments` 公開関数により、テキストから代入文の解析も直接実行できます。

### 差分圧縮による履歴管理

汎用履歴データベース API は、ノートブックの TaggingRules にチャットセッションなどの履歴を保存します。連続するエントリ間の差分を自動圧縮することで、ノートブックファイルの肥大化を抑えつつ、完全な履歴を保持します。親セッションの継承機能により、セッションのフォークや分岐にも対応しています。

履歴データの読み取りにはインメモリキャッシュが組み込まれており、同一セッション内で同じ履歴を繰り返し参照する際の FrontEnd 通信を大幅に削減します。書き込み操作はキャッシュと自動的に同期されるため、整合性は常に保たれます。`NBHistoryCacheClear[]` でキャッシュの手動クリアも可能です。履歴が不要になった場合は `NBHistoryDelete[nb, tag]` でデータベースごと削除できます。

### claudecode との連携

NBAccess は [claudecode](https://github.com/transreal/claudecode) パッケージの基盤として設計されています。claudecode は NBAccess を内部的に利用し、Claude AI とのインタラクティブなノートブック操作を実現します。エンコーディング処理や `$Path` の設定は claudecode 経由で自動化されるため、通常は claudecode を通じて利用することを推奨します。

### [実験的] ノートブックファイルのプライバシー分割処理

NBAccess は claudecode パッケージの `ClaudeProcessFile` 機能に対して、ノートブックファイル（.nb）のセル単位のプライバシーレベル判定とマージ処理を提供します。各セルのプライバシーレベルは 3 段階（0.0: 公開、0.75: 秘匿依存、1.0: 秘匿）で判定され、claudecode 側でクラウド LLM とプライベート LLM への自動振り分けに使用されます。処理結果は `NBMergeNotebookCells` により元のセル構造を保ったままマージされます。

### Job 管理による非同期出力

`NBBeginJob` / `NBEndJob` API は、ClaudeQuery などの非同期処理の出力位置を管理します。評価セルの直後にスロットセルを挿入し、プログレス通知・完了メッセージ・レスポンス本体をそれぞれ独立して書き込めます。これにより、長時間実行される AI クエリの途中経過をリアルタイムに表示できます。

## 詳細説明

### 動作環境

| 項目 | 要件 |
|------|------|
| Mathematica | 13.0 以上（推奨: 14.x） |
| OS | Windows 11 |
| 関連パッケージ | [claudecode](https://github.com/transreal/claudecode)（推奨・自動パス設定あり） |

### インストール

#### リポジトリの取得

```powershell
cd %USERPROFILE%\Documents
git clone https://github.com/transreal/NBAccess.git
```

#### `$packageDirectory` への配置

`NBAccess.wl` を `$packageDirectory` 直下にコピーしてください。

```powershell
copy NBAccess\NBAccess.wl C:\path\to\packageDirectory\
```

#### `$Path` の設定

Mathematica の `init.m` または作業ノートブック冒頭で以下を実行します。

```mathematica
AppendTo[$Path, $packageDirectory]
```

> **注意:** `AppendTo[$Path, "C:\\path\\to\\NBAccess"]` のようにパッケージ固有のサブディレクトリを指定してはいけません。すべての `.wl` パッケージは `$packageDirectory` 直下に配置し、`$Path` には `$packageDirectory` 自体を追加してください。[claudecode](https://github.com/transreal/claudecode) を使用している場合は `$Path` が自動設定されます。

#### パッケージの読み込み

**方法 A: 直接読み込み（UTF-8 指定必須）**

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["NBAccess`", "NBAccess.wl"]];
```

ファイル名のみの形式 `"NBAccess.wl"` は、`$packageDirectory` が `$Path` に含まれているため正しく動作します。

**方法 B: claudecode 経由（推奨）**

[claudecode](https://github.com/transreal/claudecode) を使用している場合は、エンコーディングと `$Path` の設定が自動的に行われます。

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["ClaudeCode`", "claudecode.wl"]];
(* NBAccess は自動的にロードされます *)
```

### クイックスタート

```mathematica
(* 1. パッケージの読み込み *)
Block[{$CharacterEncoding = "UTF-8"},
  Needs["NBAccess`", "NBAccess.wl"]];

(* 2. ノートブックの取得 *)
nb = EvaluationNotebook[];

(* 3. セル数を確認 *)
NBCellCount[nb]

(* 4. アクセス可能なセルのインデックスを取得（プライバシーフィルタ付き） *)
cells = NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* 5. 各セルのスタイルとテキストを表示 *)
Table[
  {i, NBCellStyle[nb, i], StringTake[NBCellToText[nb, i], UpTo[50]]},
  {i, cells}
] // Dataset

(* 6. LLM プロンプト用コンテキストを構築 *)
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* 7. テキストセルやコードセルを追加 *)
NBWriteText[nb, "計算結果の説明です。", "Text"];
NBWriteCode[nb, "Plot[Sin[x], {x, 0, 2 Pi}]"];

(* 8. プロバイダーアクセスレベルの設定 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];  (* ローカル LLM: 全データアクセス可 *)
NBSetProviderMaxAccessLevel["anthropic", 0.5]; (* クラウド: 非機密のみ *)

(* 9. アクセスレベルに応じた利用可能モデルの取得 *)
NBGetAvailableFallbackModels[0.8]  (* → lmstudio のモデルのみ *)
```

#### 主要設定変数

| 変数 | 説明 | 初期値 |
|------|------|--------|
| `$NBPrivacySpec` | デフォルトのプライバシーフィルタ | `<\|"AccessLevel" -> 0.5\|>` |
| `$NBConfidentialSymbols` | 機密変数テーブル | `<\|\|>` |
| `$NBSendDataSchema` | 秘密依存 Output のスキーマ情報送信フラグ | `True` |
| `$NBVerbose` | 内部詳細ログ出力フラグ | `False` |
| `$NBAutoEvalProhibitedPatterns` | 自動実行ブロックパターンリスト | `{}` |
| `$NBLLMQueryFunc` | 非同期 LLM 呼び出し用コールバック関数 | `None` |
| `$NBSeparationIgnoreList` | 分離検査で無視するパッケージ名 | `{"NBAccess", "NotebookExtensions"}` |
| `$NBConfidentialCellOpts` | 機密マーク（直接）のセル表示オプション | 赤背景 + WarningSign |
| `$NBDependentCellOpts` | 依存機密マークのセル表示オプション | 橙背景 + LockIcon |

内部状態変数（`Private` スコープ）:

| 変数 | 説明 | 初期値 |
|------|------|--------|
| `$iFallbackModels` | フォールバックモデルリスト | `{{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}` |
| `$iProviderMaxAccessLevel` | プロバイダー別最大アクセスレベル | `<\|"claudecode"->0.5, "anthropic"->0.5, "openai"->0.5, "lmstudio"->1.0\|>` |
| `$iNBHistoryCache` | 履歴データの読み取りキャッシュ | `<\|\|>` |

プライバシーレベルを変更するには以下のようにします。

```mathematica
(* ローカル LLM 環境：すべてのデータにアクセス *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

### 主な機能

#### セルユーティリティ

- **`NBCellCount[nb]`** — ノートブックの全セル数を返します
- **`NBCurrentCellIndex[nb]`** — 現在の評価セルのインデックスを返します
- **`NBSelectedCellIndices[nb]`** — 選択中セルのインデックスリストを返します
- **`NBCellIndicesByTag[nb, tag]`** — 指定タグを持つセルを検索します
- **`NBCellIndicesByStyle[nb, style]`** — 指定スタイルのセルを検索します
- **`NBDeleteCellsByTag[nb, tag]`** — 指定タグを持つセルをすべて削除します
- **`NBMoveAfterCell[nb, cellIdx]`** — セルの後ろにカーソルを移動します
- **`NBCellRead[nb, cellIdx]`** — NotebookRead で Cell 式を返します
- **`NBCellExprToText[cellExpr]`** — NotebookRead の結果（Cell 式）からテキストを抽出します
- **`NBCellToText[nb, idx]`** — セルのテキスト内容を取得します（Cases ベース）
- **`NBCellGetText[nb, cellIdx]`** — FrontEnd InputText → `NBCellToText` → `NBCellExprToText` の順でフォールバックしながら堅牢にテキストを取得します
- **`NBCellReadInputText[nb, idx]`** — FrontEnd ExportPacket 経由で堅牢なテキスト取得を行います（2D 表示対応）
- **`iCellToInputText[cellObj]`** — CellObject から直接 InputText 形式のテキストを取得する内部関数
- **`NBCellStyle[nb, idx]`** / **`NBCellLabel[nb, idx]`** — セルのスタイル・ラベルを取得します
- **`NBCellSetStyle[nb, cellIdx, style]`** — セルのスタイルを変更します（TaggingRules 等の属性を保持）
- **`NBCellSetOptions[nb, cellIdx, opts]`** — セルに SetOptions を適用します
- **`NBCellWriteCode[nb, cellIdx, code]`** — 既存セルにコードを構文カラーリング付き BoxData で書き込みます
- **`NBCellWriteText[nb, cellIdx, newText]`** — 既存セルのテキスト内容を置き換えます（スタイル・TaggingRules は保持）
- **`NBCellHasImage[cellExpr]`** — Cell 式が画像（RasterBox/GraphicsBox）を含むか判定します
- **`NBCellRasterize[nb, cellIdx, file, opts]`** — セルをラスタライズしてファイルに保存します
- **`NBCellGetTaggingRule[nb, cellIdx, path]`** — セルの TaggingRules からネスト値を取得します
- **`NBCellSetTaggingRule[nb, cellIdx, path, value]`** — セルの TaggingRules にネスト値を設定します
- **`NBSelectCell[nb, cellIdx]`** — セルブラケットを選択状態にします
- **`NBResolveCell[nb, cellIdx]`** — CellObject を返します（無効インデックスの場合は `$Failed`）
- **`NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]`** — セルのプライバシーレベルに応じた LLM を自動選択し、非同期でセルを変換します

#### プライバシー制御

- **`NBCellPrivacyLevel[nb, idx]`** — セルのプライバシーレベル（0.0〜1.0）を返します
- **`NBIsAccessible[nb, idx, PrivacySpec -> ps]`** — セルがアクセス可能か判定します
- **`NBFilterCellIndices[nb, indices, PrivacySpec -> ps]`** — インデックスリストをフィルタリングします
- **`NBGetCells[nb, PrivacySpec -> ps]`** — 全セルをフィルタリングして返します
- **`NBGetContext[nb, afterIdx, PrivacySpec -> ps]`** — LLM プロンプト用コンテキスト文字列を構築します（2段階の Input フィルタリング + 3段階の Output 処理：スマート要約・スキーマ情報送信・完全スキップ）

#### 機密マーク管理

- **`NBMarkCellConfidential[nb, idx]`** — セルに機密マーク（赤背景）を付与します
- **`NBMarkCellDependent[nb, idx]`** — セルに依存機密マーク（橙背景）を付与します
- **`NBUnmarkCell[nb, idx]`** — 機密マークを解除します
- **`NBGetConfidentialTag[nb, idx]`** — セルの機密タグを取得します

#### 依存グラフ解析

- **`NBBuildVarDependencies[nb]`** — 単一ノートブックの変数依存関係グラフを構築します
- **`NBBuildGlobalVarDependencies[]`** — 全ノートブックを横断して統合依存関係グラフを構築します（LLM 呼び出し直前の精密チェック用）
- **`NBUpdateGlobalVarDependencies[existingDeps, afterLine]`** — 既存依存グラフのインクリメンタル更新を行います
- **`NBTransitiveDependents[deps, confVars]`** — 推移的依存変数を検出します
- **`NBScanDependentCells[nb, confVarNames]`** — 機密変数に依存するセルを自動マークします。事前計算済みの依存グラフを第3引数 `deps` で渡すオーバーロードにより、二重計算を回避できます
- **`NBExtractAssignments[text]`** — テキストから代入先変数名と RHS 依存変数を抽出します（公開関数）
- **`NBDependencyEdges[nb]`** — 依存関係をエッジリストで返します
- **`NBPlotDependencyGraph[nb]`** — 依存関係グラフを可視化します
- **`NBGetFunctionGlobalDeps[nb]`** — 関数定義が依存する大域変数を解析します

#### フォールバックモデル / プロバイダーアクセスレベル

- **`NBSetFallbackModels[models]`** — フォールバックモデルリストを設定します
- **`NBGetFallbackModels[]`** — フォールバックモデルリスト全体を返します
- **`NBSetProviderMaxAccessLevel[provider, level]`** — プロバイダーの最大アクセスレベルを設定します
- **`NBGetProviderMaxAccessLevel[provider]`** — プロバイダーの最大アクセスレベルを返します
- **`NBGetAvailableFallbackModels[accessLevel]`** — 指定アクセスレベルで利用可能なフォールバックモデルを返します
- **`NBProviderCanAccess[provider, accessLevel]`** — プロバイダーが指定アクセスレベルのデータにアクセス可能か判定します

#### 書き込み

- **`NBWriteText[nb, text, style]`** — テキストセルを書き込みます
- **`NBWriteCode[nb, code]`** — 構文カラーリング付き Input セルを書き込みます
- **`NBWriteSmartCode[nb, code]`** — CellPrint パターンを自動検出してスマートに書き込みます
- **`NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]`** — Input セル挿入と条件付き評価を行います
- **`NBInsertTextCells[nbFile, name, prompt]`** — .nb ファイルを非表示で開き、末尾に Subsection セルと Text セルを挿入して保存します
- **`NBWriteCell[nb, cellExpr]`** — Cell 式をノートブックに書き込みます（位置指定可能）
- **`NBWritePrintNotice[nb, text, color]`** — ノートブックに通知用 Print セルを書き込みます
- **`NBWriteDynamicCell[nb, dynBoxExpr, tag]`** — Dynamic セルを書き込みます
- **`NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]`** — ExternalLanguage セルを書き込みます
- **`NBInsertAndEvaluateInput[nb, boxes]`** — Input セルを挿入して即座に評価します
- **`NBInsertInputAfter[nb, boxes]`** — Input セルを After に書き込み Before CellContents に移動します
- **`NBWriteAnchorAfterEvalCell[nb, tag]`** — EvaluationCell 直後に不可視アンカーセルを書き込みます

#### 履歴データベース

- **`NBHistoryCreate[nb, tag, diffFields]`** — 新しい履歴データベースを作成します（冪等）
- **`NBHistoryAppend[nb, tag, entry]`** — エントリを差分圧縮して追加します
- **`NBHistoryEntries[nb, tag]`** — 全エントリを復元して返します
- **`NBHistoryUpdateLast[nb, tag, updates]`** — 最後のエントリを更新します
- **`NBHistoryEntriesWithInherit[nb, tag]`** — 親チェーンを含む全履歴を返します
- **`NBHistoryListTags[nb, prefix]`** — タグ一覧を返します
- **`NBHistoryAddAttachment[nb, tag, path]`** — セッションにファイルをアタッチします
- **`NBHistoryRawData[nb, tag]`** — 圧縮状態のまま履歴データを返します（キャッシュ付き）
- **`NBHistoryDelete[nb, tag]`** — 指定タグの履歴データベースを TaggingRules から完全に削除します
- **`NBHistoryCacheClear[]`** — 履歴読み取りキャッシュを全クリアします（パッケージ再ロードやセッション切替時に使用）

#### Job 管理

- **`NBBeginJob[nb, evalCell]`** — 非同期出力用スロットを挿入しジョブ ID を返します
- **`NBWriteSlot[jobId, slotIdx, cellExpr]`** — スロットにセルを書き込みます
- **`NBEndJob[jobId]`** — ジョブを正常終了します
- **`NBAbortJob[jobId, errorMsg]`** — エラーメッセージを書き込みジョブを終了します

#### API キー・ディレクトリ管理

- **`NBGetAPIKey[provider]`** — `SystemCredential` 経由で API キーを取得します（`"anthropic"` / `"openai"` / `"github"`）
- **`NBSetAccessibleDirs[nb, dirs]`** — Claude Code が参照可能なディレクトリリストを設定します
- **`NBGetAccessibleDirs[nb]`** — 設定済みディレクトリリストを取得します

#### [実験的] ノートブックファイルのセル操作

- **`NBFileOpen[path]`** — .nb ファイルを invisible モードで開きノートブックオブジェクトを返します
- **`NBFileCells[nb]`** — セル情報（テキスト・スタイル・プライバシーレベル）を取得します
- **`NBMergeNotebookCells[src, results, outputPath]`** — 処理済みセルを元の構造にマージして保存します

#### ノートブック TaggingRules

- **`NBGetTaggingRule[nb, key]`** — TaggingRules から値を取得します（ネストパス対応）
- **`NBSetTaggingRule[nb, key, value]`** — TaggingRules に値を設定します
- **`NBDeleteTaggingRule[nb, key]`** — TaggingRules からキーを削除します
- **`NBListTaggingRuleKeys[nb, prefix]`** — TaggingRules のキー一覧を返します

### ドキュメント一覧

| ファイル | 内容 |
|----------|------|
| `docs/api.md` | API リファレンス（全関数・オプション・グローバル変数の詳細仕様） |
| `docs/setup.md` | セットアップガイド（インストール・設定・トラブルシューティング） |
| `docs/user_manual.md` | ユーザーマニュアル（機能カテゴリ別の使い方） |
| `docs/example.md` | 使用例集（実践的なコード例） |

## 使用例・デモ

### セルのプライバシーフィルタリング

```mathematica
(* クラウド LLM 安全なセルのみを取得 *)
safeCells = NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* 機密セルのマーク *)
NBMarkCellConfidential[nb, 3];
NBMarkCellDependent[nb, 5];

(* LLM プロンプト用コンテキスト構築（2段階フィルタリング + 3段階Output処理） *)
context = NBGetContext[nb, 0, PrivacySpec -> <|"AccessLevel" -> 0.5|>];
```

### 既存セルの編集

```mathematica
(* セルのスタイルを変更する（TaggingRules 等の属性は保持） *)
NBCellSetStyle[nb, 3, "Input"];

(* 既存セルにコードを書き込む（FEParser で構文カラーリング付き BoxData に変換） *)
NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"];

(* セルのテキスト内容を置き換える（スタイルは保持） *)
NBCellWriteText[nb, 5, "新しいテキスト内容"];

(* 非同期でセルを LLM 変換する（プライバシーレベルに応じた LLM を自動選択） *)
NBCellTransformWithLLM[nb, 3, promptFn, completionFn, Fallback -> True];
```

### 変数依存グラフ解析とインクリメンタル更新

```mathematica
(* 依存関係グラフの構築と可視化 *)
deps = NBBuildVarDependencies[nb];
NBPlotDependencyGraph[nb];

(* 機密変数に依存するセルを自動検出・マーク *)
NBScanDependentCells[nb, {"apiKey", "password"}, deps];

(* 全ノートブック統合依存グラフ（精密チェック用） *)
globalDeps = NBBuildGlobalVarDependencies[];

(* インクリメンタル更新で効率化 *)
{updatedDeps, newLastLine} = NBUpdateGlobalVarDependencies[globalDeps, 10];
```

### 履歴データベースとJob管理

```mathematica
(* 差分圧縮付き履歴保存 *)
NBHistoryCreate[nb, "chat-session-1", {"prompt", "response"}];
NBHistoryAppend[nb, "chat-session-1", <|"prompt" -> "Hello", "response" -> "Hi!"|>];

(* 履歴の削除 *)
NBHistoryDelete[nb, "chat-session-1"];

(* 非同期処理用Job管理 *)
jobId = NBBeginJob[nb, EvaluationCell[]];
NBWriteSlot[jobId, 1, Cell["Progress: 50%", "Text"]];
NBEndJob[jobId];
```

### フォールバックモデル制御

```mathematica
(* プロバイダー別アクセスレベル設定 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];   (* ローカル: 全データ可 *)
NBSetProviderMaxAccessLevel["anthropic", 0.5]; (* クラウド: 非機密のみ *)

(* 機密データで利用可能なモデルを取得 *)
NBGetAvailableFallbackModels[0.8] (* → ローカルモデルのみ *)
```

## 免責事項

本ソフトウェアは "as is"（現状有姿）で提供されており、明示・黙示を問わずいかなる保証もありません。
本ソフトウェアの使用または使用不能から生じるいかなる損害についても責任を負いません。
今後の動作保証のための更新が行われるとは限りません。
本ソフトウェアとドキュメントはほぼすべてが生成AIによって生成されたものです。
Windows 11上での実行を想定しており、MacOS, LinuxのMathematicaでの動作検証は一切していません(生成AIの処理で対応可能と想定されます)。

## ライセンス

```
MIT License

Copyright (c) 2026 Katsunobu Imai

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.