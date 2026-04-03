# NBAccess セットアップガイド

NBAccess は Wolfram Language 用のノートブックアクセスユーティリティパッケージです。セルインデックスベースでノートブックの読み書きを行い、プライバシーフィルタリング機能を提供します。

## 動作環境

- **Wolfram Mathematica** 12.0 以降
- **Wolfram Language** カーネル
- **文字エンコーディング**: UTF-8 対応

## インストール方法

### 方法1: 直接読み込み（推奨）

パッケージファイルを適切なディレクトリに配置し、以下のコードで読み込みます：

```mathematica
Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
```

### 方法2: claudecode パッケージ経由（最も簡単）

claudecode パッケージを使用している場合、エンコーディングが自動的に処理されます：

```mathematica
Get["claudecode.wl"]
(* NBAccess は自動的に利用可能になります *)
```

### 方法3: パッケージディレクトリへの配置

1. Wolfram Language の `$UserBaseDirectory` または `$BaseDirectory` を確認します
2. `Applications` フォルダ内に `NBAccess.wl` を配置します
3. 通常の `Get` または `Needs` で読み込みます

## 基本設定

### プライバシー設定

NBAccess の主要な設定項目として、プライバシーアクセスレベルがあります：

```mathematica
(* デフォルト設定（クラウドLLM安全レベル） *)
$NBPrivacySpec = <|"AccessLevel" -> 0.5|>

(* ローカルLLM環境での設定 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>
```

### 機密変数設定

機密データのスキーマ情報送信制御：

```mathematica
(* スキーマ情報を送信する（デフォルト） *)
$NBSendDataSchema = True

(* スキーマ情報も送信しない *)
$NBSendDataSchema = False
```

### 分離原則の除外設定

NBAccess 分離原則チェックから除外するパッケージの設定：

```mathematica
(* デフォルトで NBAccess と NotebookExtensions は除外済み *)
$NBSeparationIgnoreList = {"NBAccess", "NotebookExtensions"}

(* 独自パッケージを追加する場合 *)
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

## 動作確認

### 基本機能テスト

インストールが正常に完了したかを確認します：

```mathematica
(* パッケージの読み込み確認 *)
NBAccess`NBCellCount[EvaluationNotebook[]]

(* 現在のノートブックのセル数が返されれば成功 *)
```

### セル操作テスト

```mathematica
nb = EvaluationNotebook[]

(* 現在のセルインデックス取得 *)
currentIdx = NBAccess`NBCurrentCellIndex[nb]

(* セル内容の読み取り *)
cellText = NBAccess`NBCellToText[nb, currentIdx]
```

### 低レベルセル操作テスト

以下の関数を使うと、セルの CellObject 解決・セル選択・スタイル変更・コード書き込みを行えます：

```mathematica
nb = EvaluationNotebook[]

(* CellObject を取得する（外部パッケージが低レベル参照を必要とする場合に使用） *)
(* 指定インデックスが無効な場合は $Failed を返す *)
cellObj = NBAccess`NBResolveCell[nb, 3]

(* セルブラケットを選択状態にする（パレット操作後のセル選択復元に使用） *)
NBAccess`NBSelectCell[nb, 3]

(* セルのスタイルを変更する *)
(* Cell 式の第2引数を書き換える。TaggingRules 等の属性は保持される *)
NBAccess`NBCellSetStyle[nb, 3, "Input"]

(* 既存セルにコードを BoxData + Input スタイルで書き込む *)
(* FEParser で構文カラーリング付き BoxData に変換し、Cell 式全体を置換する *)
NBAccess`NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"]
```

### プライバシーフィルタリングテスト

```mathematica
(* アクセス可能なセル一覧取得 *)
accessibleCells = NBAccess`NBGetCells[nb, PrivacySpec -> $NBPrivacySpec]

(* 特定セルのアクセス可能性確認 *)
isAccessible = NBAccess`NBIsAccessible[nb, 1, PrivacySpec -> $NBPrivacySpec]
```

### 依存グラフ機能テスト

```mathematica
(* 基本的な依存関係の確認 *)
dependencies = NBAccess`NBBuildVarDependencies[nb]

(* 依存グラフの可視化（機密変数がある場合） *)
NBAccess`NBPlotDependencyGraph[nb, "Scope" -> "Local"]
```

## API キー設定（オプション）

AI プロバイダーとの連携を行う場合：

```mathematica
(* API キーの設定確認 *)
anthropicKey = NBAccess`NBGetAPIKey["anthropic"]
openaiKey = NBAccess`NBGetAPIKey["openai"]
githubKey = NBAccess`NBGetAPIKey["github"]
```

API キーは Wolfram Language の `SystemCredential` 機能を通じて安全に管理されます。

## トラブルシューティング

### エンコーディング問題

文字化けが発生する場合：

```mathematica
(* 明示的にUTF-8エンコーディングで読み込み *)
Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
```

### プライバシーレベル問題

アクセスが拒否される場合：

```mathematica
(* より高いアクセスレベルに設定 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>

(* または関数呼び出し時に個別指定 *)
NBAccess`NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 1.0|>]
```

### 依存関係問題

分離原則違反が報告される場合：

```mathematica
(* 分離原則チェック実行 *)
NBAccess`ClaudeCheckSeparation["YourPackageName"]

(* 自動修正 *)
NBAccess`ClaudeFixSeparation["YourPackageName"]
```

### パフォーマンス問題

大きなノートブックで動作が遅い場合、NBAccess は自動的にキャッシュ機能を使用してFrontEndアクセスを最適化します。通常は設定不要ですが、問題が発生した場合はノートブックを再起動してください。

## 次のステップ

- **基本的な使用方法**: `usage.md` を参照してください
- **API リファレンス**: `api-reference.md` で詳細な関数仕様を確認してください  
- **プライバシー管理**: `privacy.md` でセキュリティ機能の詳細を学習してください
- **高度な機能**: `advanced-features.md` で履歴管理や依存グラフ機能を確認してください

## サポート

問題が発生した場合は、GitHub リポジトリにてイシューを報告してください：  
https://github.com/transreal/NBAccess