# NBAccess セットアップガイド

**パッケージ:** [NBAccess](https://github.com/transreal/NBAccess) — ノートブックアクセスユーティリティ（セル読み書き・プライバシーフィルタリング・履歴管理）

> macOS/Linux ではパス区切りやシェルコマンドを適宜読み替えてください。

---

## 1. 動作要件

| 項目 | 要件 |
|------|------|
| Mathematica | 13.0 以上（推奨: 14.x） |
| OS | Windows 11 |
| 関連パッケージ | [claudecode](https://github.com/transreal/claudecode)（推奨・自動パス設定あり） |

---

## 2. インストール

### 2.1 リポジトリの取得

```powershell
cd %USERPROFILE%\Documents
git clone https://github.com/transreal/NBAccess.git
```

### 2.2 `$packageDirectory` への配置

`NBAccess.wl` を `$packageDirectory` 直下にコピーまたはシンボリックリンクしてください。

```powershell
copy NBAccess\NBAccess.wl C:\path\to\packageDirectory\
```

### 2.3 `$Path` の設定

Mathematica の `init.m` または作業ノートブック冒頭で以下を実行します。

```mathematica
AppendTo[$Path, $packageDirectory]
```

> **注意:** パッケージ固有のサブディレクトリではなく、`$packageDirectory` 自体を追加してください。

---

## 3. パッケージの読み込み

### 方法 A: 直接読み込み（UTF-8 指定必須）

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["NBAccess`", "NBAccess.wl"]];
```

### 方法 B: claudecode 経由（推奨）

[claudecode](https://github.com/transreal/claudecode) を使用している場合は、エンコーディングと `$Path` の設定が自動的に行われます。

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["ClaudeCode`", "claudecode.wl"]];
(* NBAccess は自動的にロードされます *)
```

---

## 4. API キーの設定

`NBGetAPIKey` は `SystemCredential` を通じて API キーにアクセスします。事前に登録してください。

```mathematica
SystemCredential["ANTHROPIC_API_KEY"] = "sk-ant-...";
SystemCredential["OPENAI_API_KEY"]    = "sk-...";
SystemCredential["GITHUB_TOKEN"]      = "ghp_...";
```

使用時:

```mathematica
NBGetAPIKey["anthropic"]
```

> API キーは `AccessLevel -> 1.0`（ローカル専用）として扱われます。クラウド LLM には送信されません。

---

## 5. 主要設定変数

| 変数 | 説明 | 初期値 |
|------|------|--------|
| `$NBPrivacySpec` | デフォルトのプライバシーフィルタ | `<\|"AccessLevel" -> 0.5\|>` |
| `$NBConfidentialSymbols` | 機密変数テーブル | `<\|\|>` |
| `$NBSendDataSchema` | 秘密依存 Output のスキーマ情報送信フラグ | `True` |
| `$NBSeparationIgnoreList` | 分離検査で無視するパッケージ名 | `{"NBAccess", "NotebookExtensions"}` |

### プライバシーレベルの変更

```mathematica
(* クラウド LLM 安全なデータのみ（デフォルト） *)
$NBPrivacySpec = <|"AccessLevel" -> 0.5|>;

(* ローカル LLM 環境：すべてのデータにアクセス *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

### スキーマ情報送信の制御

`$NBSendDataSchema` は、秘密依存 Output のスキーマ情報（データ型・サイズ・キー名など）をクラウド LLM に送信するかどうかを制御します。

```mathematica
(* デフォルト: スキーマ情報を送信する *)
$NBSendDataSchema = True;

(* スキーマ情報も一切送信しない *)
$NBSendDataSchema = False;
```

`True` の場合、秘密依存 Output であっても「Association, 5 keys: {name, age, ...}」のようなデータ構造の概要が LLM に送信されます。これにより、LLM が秘密データの値を知らなくても適切なコードを生成できるようになります。非秘密 Output は本設定に関係なく、常にスマート要約付きで送信されます。

---

## 6. 動作確認

以下のコードをノートブックで順に実行し、エラーが出ないことを確認してください。

```mathematica
(* 1. パッケージが読み込まれているか *)
Names["NBAccess`*"] // Length
(* → 70 以上のシンボルが返れば OK *)

(* 2. 基本的なセル操作 *)
nb = EvaluationNotebook[];
NBCellCount[nb]
(* → 正の整数が返れば OK *)

(* 3. プライバシー設定の確認 *)
NBGetPrivacySpec[]
(* → <|"AccessLevel" -> 0.5|> *)

(* 4. セルテキスト取得 *)
NBCellToText[nb, 1]
(* → 最初のセルの内容が返れば OK *)
```

---

## 7. 最小動作例

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["NBAccess`", "NBAccess.wl"]];

nb = EvaluationNotebook[];

(* アクセス可能なセル一覧を取得 *)
cells = NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* 各セルのスタイルとテキストを表示 *)
Table[
  {i, NBCellStyle[nb, i], StringTake[NBCellToText[nb, i], UpTo[50]]},
  {i, cells}
] // Dataset
```

---

## 8. NBGetContext のスマート出力要約

`NBGetContext` は LLM プロンプト用のコンテキスト文字列を構築する関数です。Output セルの処理において、以下のスマート要約機構を使用しています。

### 非秘密 Output

短い出力（200 文字以下）はそのまま含められます。長い出力に対しては、データ構造情報と先頭プレビューで要約されます。

検出されるデータ型の例:
- **Association**: キー数とキー名を表示（例: `Association, 5 keys: {name, age, score}`）
- **Dataset**: カラム名を表示
- **NestedList/Matrix**: 行数を表示
- **List**: 要素数を表示
- **Graphics/Image**: `Graphics/Image` と表示
- **SparseArray/NumericArray**: 型名を表示
- **その他**: 文字数を表示

### 秘密依存 Output

`$NBSendDataSchema` が `True` の場合、秘密依存 Output はスキーマ情報（データ型・サイズ・キー名）のみが送信されます。値は一切含まれません。

```
(* [機密依存データ: Association, 3 keys: {password, token, secret}] *)
```

`$NBSendDataSchema` が `False` の場合、秘密依存 Output は完全にスキップされます。

---

## 9. 履歴キャッシュについて

NBAccess は履歴データ（`NBHistoryRawData`）の読み取りにインメモリキャッシュを使用しています。ClaudeQuery 1回の処理中に同じ履歴を7回以上読み取ることがあるため、キャッシュによって FrontEnd 通信を大幅に削減しています。

書き込み系関数（`NBHistoryAppend`、`NBHistorySetData`、`NBHistoryWriteHeader` 等）はキャッシュを自動的に同期するため、通常の使用ではキャッシュを意識する必要はありません。

パッケージの再ロードやセッション切替時にキャッシュをクリアしたい場合は以下を実行してください。

```mathematica
NBHistoryCacheClear[]
```

---

## 10. NBScanDependentCells の最適化

`NBScanDependentCells` は事前計算済みの依存グラフを第3引数として受け取るオーバーロードをサポートしています。同じノートブックに対して `NBBuildVarDependencies` を複数回呼び出す場合、依存グラフを事前に計算して渡すことで二重計算を回避できます。

```mathematica
(* 従来の使い方（内部で依存グラフを計算） *)
NBScanDependentCells[nb, confVarNames]

(* 最適化: 事前計算済みの依存グラフを渡す *)
deps = NBBuildVarDependencies[nb];
NBScanDependentCells[nb, confVarNames, deps]
```

---

## 11. NBBuildGlobalVarDependencies による全ノートブック統合依存解析

`NBBuildGlobalVarDependencies[]` は `Notebooks[]` 全体の Input セルを走査して、統合された変数依存関係グラフを返します。`NBBuildVarDependencies[nb]` が単一ノートブック内の依存関係のみを解析するのに対し、この関数は全ノートブックをまたいだ依存関係を構築します。

```mathematica
(* 全ノートブック統合依存グラフを取得 *)
globalDeps = NBBuildGlobalVarDependencies[]
(* → <|"var1" -> {"dep1", "dep2"}, ...|> *)
```

> **注意:** この関数は全ノートブックを走査するため、処理コストが高くなります。LLM 呼び出し直前の精密チェック（ClaudeQuery / ClaudeEval / ContinueEval の直前）にのみ使用してください。通常のセル実行時は `NBBuildVarDependencies[nb]` を使用してください。

---

## 12. トラブルシューティング

| 症状 | 対処 |
|------|------|
| 文字化け・`$CharacterEncoding` エラー | `Block[{$CharacterEncoding = "UTF-8"}, ...]` で読み込んでいるか確認してください |
| `Needs` で見つからない | `$Path` に `$packageDirectory` が含まれているか `MemberQ[$Path, $packageDirectory]` で確認してください |
| `NBGetAPIKey` が `$Failed` | `SystemCredential["ANTHROPIC_API_KEY"]` 等が設定済みか確認してください |
| プライバシーフィルタで空リスト | `$NBPrivacySpec` の `AccessLevel` を `1.0` に上げて再試行してください |
| 履歴データが古い・不整合がある | `NBHistoryCacheClear[]` を実行してキャッシュをクリアしてください |
| 秘密依存 Output のスキーマが送信されない | `$NBSendDataSchema` が `True` に設定されているか確認してください |
| Output の内容が `(出力取得失敗)` と表示される | セル出力が空、または FrontEnd からのテキスト取得に失敗しています。セルを再評価してください |