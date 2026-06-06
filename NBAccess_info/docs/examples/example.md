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

(* FrontEnd ExportPacket 経由でより堅牢なテキスト取得 *)
inputText = NBCellReadInputText[nb, 1];
```

```
(* 例: count = 12, text = "Needs[\"NBAccess`\"]", style = "Input", label = "In[1]:=" *)
(* inputText は 2D 表示（Sum, Integral 等）も正しくテキスト変換します *)
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
`NBGetContext` は **2段階のプライバシーフィルタリング** と **3段階の Output 処理** を適用します。

### Input セルのプライバシーフィルタリング

1. **セルレベルフィルタリング**: 機密マーク（`NBMarkCellConfidential`）が付いたセルや、プライバシーレベルが AccessLevel を超えるセルは **コード全体が除外** されます。対応する Output セルも同時に抑制されます。除外されたセルはラベルのみ残り `(* [機密セル: 非表示] *)` と表示されます。
2. **変数名レベルリダクション**: セル自体は機密マークされていなくても、`$NBConfidentialSymbols` に登録された機密変数を参照する行は個別にリダクションされます。代入文の場合は `変数名 = (* [機密変数に依存: 値は非表示] *)` に、それ以外は `(* [機密変数を含む行: 非表示] *)` に置換されます。

### Output セルのスマート要約

全 Output セルに対して、プライバシーレベルと抑制状態に基づいて3段階の処理を適用します。

1. **非秘密かつ非抑制の Output**: スマート要約付きでコンテキストに含めます。短い出力（200文字以下）はそのまま、長い出力はデータ構造情報（型・サイズ・キー名等）と先頭プレビューで要約されます。
2. **秘密依存だが `$NBSendDataSchema = True` の Output**: 値を含まず、スキーマ情報（データ型・サイズ・キー名）のみを送信します。
3. **その他の Output**: 完全にスキップされます。

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
    ...
    === Output 一覧 ===
    Out[1]= 42
    Out[4]= (* [機密依存データ: Association, 3 keys: {name, age, city}] *)
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

## 例6: 既存セルの編集

インデックスを指定して既存セルのスタイル・コード内容を変更したり、CellObject を取得したりします。

```mathematica
(* セルのスタイルを変更する (TaggingRules 等の属性は保持される) *)
NBCellSetStyle[nb, 3, "Input"];

(* 既存セルにコードを書き込む (FEParser で構文カラーリング付き BoxData に変換) *)
NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2Pi}]"];

(* CellObject を取得する (低レベルのセル参照が必要な場合) *)
cell = NBResolveCell[nb, 3];

(* セルブラケットを選択状態にする (パレット操作後のセル選択復元などに使用) *)
NBSelectCell[nb, 3];
```

```
(* 例:
   NBCellSetStyle[nb, 3, "Input"] → 3番セルのスタイルが "Input" に変更される
   NBCellWriteCode[nb, 3, "Plot[...]"] → 構文カラーリング付き BoxData でセルを置換
   NBResolveCell[nb, 99] → 無効なインデックスの場合は $Failed を返す *)
```

**注意**: `NBCellSetStyle` は `SetOptions[cell, CellStyle -> ...]` とは異なり、Cell 式の第2引数を直接書き換えるためスタイルが確実に変更されます。

## 例7: 変数依存グラフの解析と可視化

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

グラフの可視化では以下の特徴があります：

- **ノードスタイル**: 関数は白地 + 色付き縁取り、変数は塗りつぶし + 縁取りなし
- **色分け**: 秘密（直接）は赤、依存秘密（推移的）は橙、公開は青
- **ラベル**: 秘密・依存秘密のみ変数名を表示、公開はラベルなし
- **エッジツールチップ**: 依存を定義するセルの番号 (In[xx]) を表示
- **凡例**: "秘密 (直接)"、"依存秘密 (推移的)"、"公開" の3段階で表示

```
(* 例: deps = <|"result" -> {"apiKey"}, ...|>, markedCount = 3 *)
```

**注意**: 通知セル（CellTags -> {"claudecode-notice"}）はマーキング対象外となります。これにより、ClaudeCode が生成するシステム通知セルは依存解析から除外されます。

## 例8: 全ノートブック統合依存グラフ

`NBBuildGlobalVarDependencies[]` は開いている全ノートブックの Input/Code セルを走査して、統合された変数依存関係グラフを構築します。ClaudeQuery/ClaudeEval/ContinueEval の直前の精密チェックで使用します。

```mathematica
(* 全ノートブック統合依存グラフを取得 *)
globalDeps = NBBuildGlobalVarDependencies[]
(* <|"y" -> {"x"}, "z" -> {"x", "y"}, "w" -> {"z"}|> *)

(* インクリメンタル更新: 既存グラフに新しいセルのみ追加 *)
{updatedDeps, newLastLine} = NBUpdateGlobalVarDependencies[globalDeps, 10];

(* 推移的依存変数を検出 *)
allDepVars = NBTransitiveDependents[globalDeps, {"apiKey"}];

(* 精密チェック付きスキャン *)
NBScanDependentCells[nb, Keys[NBGetConfidentialVars[]], globalDeps]
```

```
(* 例: globalDeps はすべてのノートブックを横断した依存グラフ *)
(* 単一ノートブック版の NBBuildVarDependencies[nb] より処理コストが高いため、
   通常のセル実行時は NBBuildVarDependencies[nb] を使用してください *)
```

**インクリメンタル更新機能**: `NBUpdateGlobalVarDependencies` は完全なグラフ再構築を回避し、CellLabel In[x] の x が afterLine より大きいセルのみを追加走査してマージします。大規模なノートブックセッションでのパフォーマンス向上に寄与します。

## 例9: 汎用履歴データベース

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

## 例10: API キー取得とアクセス可能ディレクトリ

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

## 例11: フォールバックモデルとプロバイダーアクセスレベル

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

## 例12: 秘密依存データのスキーマ情報送信制御

`$NBSendDataSchema` は、秘密依存 Output のスキーマ情報（データ型・サイズ・キー名等）をクラウド LLM に送信するかどうかを制御します。非秘密 Output は本設定に関係なく常にスマート要約付きで送信されます。

```mathematica
(* デフォルト: スキーマ情報を送信する *)
$NBSendDataSchema = True;

(* このとき NBGetContext の秘密依存 Output 部分は以下のように出力されます: *)
(* Out[5]= (* [機密依存データ: Association, 3 keys: {name, token, secret}] *) *)
(* Out[7]= (* [機密依存データ: Dataset, columns: {revenue, profit, cost}] *) *)
(* Out[9]= (* [機密依存データ: List, ~42 elements] *) *)
```

```mathematica
(* スキーマ情報も一切送信しない場合 *)
$NBSendDataSchema = False;

(* このとき秘密依存 Output は完全にスキップされます *)
```

### スマート要約で検出されるデータ構造

非秘密 Output に対するスマート要約、および秘密依存 Output に対するスキーマ情報では、以下のデータ構造が検出されます。

```mathematica
(* Association: キー数とキー名を表示 *)
(* → "Association, 5 keys: {name, age, city, phone, email}" *)

(* Dataset: カラム名を表示 *)
(* → "Dataset, columns: {col1, col2, col3}" *)

(* ネストリスト/行列: 行数を表示 *)
(* → "NestedList/Matrix, ~10 rows" *)

(* リスト: 要素数を表示 *)
(* → "List, ~42 elements" *)

(* SparseArray / NumericArray: 型名を表示 *)
(* → "SparseArray" / "NumericArray" *)

(* Graphics / Image: 型名を表示 *)
(* → "Graphics/Image" *)

(* その他: 文字数を表示 *)
(* → "1234 chars" *)
```

## 例13: コード実行と承認エンジン（held 式ベース判定）

NBAccess は LLM が生成したコードを実行する前に、保持された式（`HoldComplete[...]`）を評価せずに走査し、副作用の有無に応じて実行可否を判定します。判定は **base 判定**（従来の head 許可/拒否リスト）に加えて、式中の head の **副作用クラス（EffectClass）** から導出した **承認適格性（ApprovalEligibility）** を合成し、より厳しい側を採用します。

```mathematica
(* held 式を評価せずに検証し、実行可否の Decision を得る *)
held = HoldComplete[Total[Range[1, 100]]];
decision = NBValidateHeldExpr[held];
(* → 純数学関数のみなので実行可能 (PureComputation) *)
```

判定ロジックの要点は以下のとおりです。

- **副作用クラスの集約**: 式中の各 head を `PureComputation`（純粋計算）/ 副作用ありのカテゴリへ分類し、最も強い影響を持つものから承認適格性を決定します。
- **base 判定との合成**: head 許可/拒否リストによる base Decision と、EffectClass 由来の eligibility を合成し、より制限的な結果を最終判定とします。
- **ローカル変数の除外**: `Module` / `Block` / `With` 等でスコープ局所化された変数や、`Set` / `SetDelayed` でその式内に定義された関数名は、未知 head（`NeedsApproval`）の対象から除外されます。これにより、ユーザー定義の安全なローカル関数が過剰に承認要求されることを防ぎます（例: `Module[{traj}, traj[x_] := ...]` の `traj`）。
- **明示的 eval の許容**: `Evaluate` は拒否リストから除外され、`ParametricPlot[Evaluate[..]]` のような正当な用途を妨げません。

```
(* Decision の例:
   <|"Decision" -> "Allowed", "ReasonClass" -> "PureComputation", ...|>
   <|"Decision" -> "NeedsApproval",
     "VisibleExplanation" -> "Unknown heads: ...", ...|> *)
```

承認 UI でユーザーが明示承認した場合は `UserApproved`、`directLLM rescue` 等の自動 commit 経路では `CommitterAutoApprove` として、検証済みパスに対する実行が許可されます。

**注意**: `NotebookWrite[nb, Cell[...]]` のように、エージェント由来式が notebook を直接書き換える head（`Cell` 等）を含む場合は、シンボル名（keys）で照合して適切に判定されます。これらを含む式は subkernel 実行ができません（`RawResult` がカーネル間を跨ぐため）。

## 例14: 出力モードと遅延出力バッファ

長時間実行や大量出力を伴うコードでは、出力を逐次表示するか一括表示するかを **出力モード** で切り替えられます。

- **Streaming（既定）**: 出力を逐次表示します。
- **Batch**: 出力を遅延バッファに溜め、`NBFlushDeferredOutput` で一括出力します。スケジュール評価などブロックを避けたい状況に向きます。

```mathematica
(* バッファに溜めた出力を一括でフラッシュする *)
NBFlushDeferredOutput[nb];
```

```
(* バッファ内の遅延出力がまとめてノートブックに書き出されます *)
```

**メモ**: バッファへの追加は変数操作のため評価コンテキストを問いませんが、実際の `NotebookWrite` を伴うフラッシュはメインカーネル評価で行う必要があります。出力は「消えるより出る方が安全」という方針で、フラッシュ忘れがあっても評価セル直後に出力されるよう設計されています。

## 例15: 暗号鍵ストアのバックエンド設定と鍵生成

`NBAccess_crypto.wl`（本体とは別ファイルだが同じ `NBAccess`` コンテキスト）の鍵隔離層を使います。鍵材料は公開 API から一切返らず、KeyRef 文字列を介して暗号操作を行います。

**重要**: `$NBCredentialBackend` は **鍵を生成・使用する前に**設定してください。永続的に保存・後日復号するデータには必ず `"SystemCredential"` を選びます（`"Memory"` 鍵はカーネルごとにランダムで、終了時に失われます）。

```mathematica
(* バックエンドを選択（鍵生成より前） *)
$NBCredentialBackend = "SystemCredential";  (* 本番想定。OS 資格情報ストアに永続化 *)
(* $NBCredentialBackend = "Memory"; *)       (* 既定。揮発性。開発/テスト用 *)

(* 対称鍵・MAC 鍵・RSA 鍵対を生成（KeyRef だけが返り、鍵材料は返らない） *)
NBGenerateSymmetricKeyRef["MyApp:master:atrest:v1"];
NBGenerateMacKeyRef["MyApp:master:mac:v1"];
NBGenerateAsymmetricKeyRefPair["MyApp:master:sign:v1"];

(* 鍵の metadata（鍵材料を含まない）を確認 *)
NBKeyStatus["MyApp:master:atrest:v1"]

(* 登録済み keyRef の一覧 *)
NBListCredentialKeyRefs["MyApp:*"]
```

```
(* 例: NBGenerateSymmetricKeyRef の戻り値:
   <|"Status" -> "Stored", "KeyRef" -> "MyApp:master:atrest:v1",
     "KeyMaterialReturned" -> False|> *)
(* NBKeyStatus は <|"KeyRef" -> ..., "Kind" -> "SymmetricKey",
     "Backend" -> "SystemCredential", "Fingerprint" -> "...",
     "Status" -> "Active", "Purpose" -> "SymmetricAtRest",
     "Algorithm" -> "AES256", ...|> を返す（鍵材料は含まれない） *)
(* NBListCredentialKeyRefs:
   {"MyApp:master:atrest:v1", "MyApp:master:mac:v1", "MyApp:master:sign:v1"} *)
```

## 例16: 暗号化・復号の roundtrip

KeyRef を介して `ByteArray` の平文を暗号化し、復号します。暗号文は Base64 化された直列 `EncryptedObject` で、鍵材料は戻り値に一切含まれません。

```mathematica
pt  = StringToByteArray["保護したい本文 payload", "UTF-8"];

(* 暗号化（CiphertextB64 と IV を持つ Association が返る） *)
enc = NBEncryptWithKeyRef["MyApp:master:atrest:v1", pt];
ct  = enc["CiphertextB64"];

(* 復号（ByteArray が返る。失敗時は $Failed） *)
dec = NBDecryptWithKeyRef["MyApp:master:atrest:v1", ct];
ByteArrayToString[dec, "UTF-8"]
```

```
(* 例: enc = <|"Status" -> "Ok", "KeyRef" -> "MyApp:master:atrest:v1",
              "CiphertextB64" -> "QmluYXJ5...", "IV" -> "..."|> *)
(* ByteArrayToString[dec, "UTF-8"] → "保護したい本文 payload" *)
```

## 例17: encrypt-then-MAC による完全性確保

WL 14.3 には AEAD/GCM がなく、`Encrypt` は完全性フィールドを持たない AES256/CBC です。そのため at-rest の完全性は **暗号文を別の MAC 鍵で MAC する**（encrypt-then-MAC）方式で確保します。受信側は復号する前に MAC を constant-time 検証します。

```mathematica
(* 暗号文に MAC を付与 *)
ctBytes = StringToByteArray[ct, "UTF-8"];
mac = NBMacWithKeyRef["MyApp:master:mac:v1", ctBytes];

(* 受信側: MAC を検証してから復号する *)
If[NBVerifyMacWithKeyRef["MyApp:master:mac:v1", ctBytes, mac],
  ByteArrayToString[NBDecryptWithKeyRef["MyApp:master:atrest:v1", ct], "UTF-8"],
  $Failed  (* MAC 不一致 → 改ざんの可能性。復号しない *)
]

(* 改ざん検出の確認: 異なるバイト列では検証が False になる *)
tampered = StringToByteArray["改ざんされた payload", "UTF-8"];
NBVerifyMacWithKeyRef["MyApp:master:mac:v1", tampered, mac]
(* 戻り値: False *)
```

```
(* mac は HMAC-SHA256 の hex 文字列（例: "9f3c...a21b"） *)
(* NBVerifyMacWithKeyRef は constant-time 比較で True / False を返す *)
```

## 例18: セルフテストと鍵の削除

`NBCryptoSelfTest[]` は、ユーザーの実鍵を汚さない隔離した一時 Memory バックエンドで、鍵隔離・暗号/MAC roundtrip・誤鍵検出を一括検査します。

```mathematica
(* 鍵隔離・roundtrip・誤鍵検出のセルフテスト *)
NBCryptoSelfTest[]

(* 不要になった鍵の削除 *)
NBDeleteCredentialKey["MyApp:master:sign:v1"];
NBKeyStatus["MyApp:master:sign:v1"]
(* 戻り値: Missing["NotFound"] *)
```

```
(* NBCryptoSelfTest の戻り値:
   <|"EncryptRoundtrip" -> True, "MacRoundtrip" -> True,
     "MacRejectsTamper" -> True, "WrongMacKeyFails" -> True,
     "DecryptWrongTypeFails" -> True, "KeyIsolation" -> True,
     "ListWorks" -> True, "DeleteWorks" -> True, "AllPassed" -> True|> *)
```

**メモ**: `NBAccess_crypto.wl` は下位レイヤーであり、`SourceVault_crypto` がこの上に構築されます。鍵材料はどの公開 API でも露出しないため、鍵そのものを読み出そうとしないでください。可搬鍵バンドル用の `NBExportWrappedKeys` / `NBImportWrappedKeys` も、出力は `wrapKey` で暗号化された暗号文のみです。

---

## 補足: グローバル設定

プライバシーレベルのデフォルトはセッション全体で変更できます。

```mathematica
(* ローカル LLM 環境で全データにアクセスする場合 *)
$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;
```

関連パッケージ: [claudecode](https://github.com/transreal/claudecode) は NBAccess を内部的に利用し、エンコーディング処理を自動化します。