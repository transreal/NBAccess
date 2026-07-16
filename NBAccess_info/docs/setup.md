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

## 関連パッケージ

### ClaudeRuntime との連携

NBAccess は [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) パッケージと連携することで、ノートブック内での安全な式実行・検証・ルーティング機能が強化されます。

ClaudeRuntime を導入すると、以下の高度な API が利用可能になります：

- **`NBValidateHeldExpr`** — LLM が生成した式を Allowed Expression Surface に照合し、実行前に安全性を検証します
- **`NBExecuteHeldExpr`** — 検証済み式をポリシーに従って安全に実行します
- **`NBAuthorize`** — PolicyGate・ScoreGate・EnvironmentGate を統合したアクセス制御判定を行います
- **`NBRouteDecision`** — コンテキストのリスクスコアに基づき、CloudLLM / PrivateLLM / LocalOnly へのルーティング推奨を返します
- **`GuardedApply`** / **`Declassify`** — 関数単位のセキュリティポリシー適用と情報ラベルの引き下げ

ClaudeRuntime は NBAccess とは独立したパッケージです。NBAccess 単体でも従来どおりすべての機能が利用できます（後方互換性の節を参照）。

ClaudeRuntime の読み込み例：

```mathematica
Block[{$CharacterEncoding = "UTF-8"}, Get["ClaudeRuntime.wl"]]
(* または claudecode.wl 経由で自動ロードされます *)
```

#### 式検証・実行エンジンの判定モデル

`NBValidateHeldExpr` の検証ロジックは、従来の AllowedHeads / ApprovalHeads / DenyHeads の照合に加えて、式に含まれる head の副作用クラス（EffectClass）から承認適格性（ApprovalEligibility）を集約し、ベース判定と合成して最終判定を行うように拡張されました。最終判定は、ベース判定（`iNBValidateHeldExprBase`）で得た Decision（BaseDecision）と、式中の head から集約した EffectClass の eligibility を「厳しい方」を採用して合成します。合成後は Decision（変換後）と BaseDecision を併存させ、追加の metadata とともに返します。

- 純粋な数学関数（`Total`、`IntegerPart`、`Round`、`Floor`、`Ceiling` など副作用のないもの）は `PureComputation` として扱われ、ブロックされにくくなります。`System`` 系の副作用のない関数も同様に純粋計算として扱われます。
- `Module`／`Block`／`With` などのスコープ局所変数や、`Set`／`SetDelayed` で定義したローカル関数名は承認対象から除外され、過剰な承認要求を抑制します（これらはユーザー定義の安全なローカルとみなされます）。たとえば `Module[{traj}, traj[x_] := ...]` の `traj` が NeedsApproval になるような過剰判定は抑制されます。
- head の eligibility が同点の場合は、specificity rank（より具体的な分類）を優先して最終アクションを決定します。
- ユーザーが承認 UI で明示承認した場合（**UserApproved**）や、directLLM rescue などの自動 commit 互換経路（**CommitterAutoApprove**）では、検証済みパスに対して実行が許可されます。
- 式中の head が `System` 系の純粋関数か否かを文字列パースに頼らずに判定できるよう改善され、`NotebookWrite[nb, Cell[...]]` のように未知 head（`Cell` 等）を含む式が誤って NeedsApproval 扱いされる過剰判定が抑制されています。
- side-effect stem（副作用語幹）のヒューリスティックは部分文字列マッチのため本質的に漏れがあり得ますが、副作用語幹に部分一致しても実際は純粋（式・リスト・文字列・画像など）の head については過剰判定を回避するよう調整されています。
- trusted package head（`SourceVault*` 等、名前に "Notebook"/"Generate" を含む信頼パッケージ由来の head）に対しては、過剰反復ガードが働き、承認要求が繰り返し発火しないようになっています。
- `"Evaluate"` は Deny 対象から除去されました。これにより `ParametricPlot[Evaluate[...]]` のように `Evaluate` を含む一般的なプロット・計算式が、不必要に拒否・承認待ちになることがなくなっています。

これに伴い、旧来の `NBExecuteHeldExpr` の `"TimeConstraint"` オプションおよび `NBValidateHeldExpr` の `"AllowedHeads"`／`"ApprovalHeads"`／`"DenyHeads"`／`"LabelCheck"` をオプション引数で逐一指定する方式は廃止され、グローバル変数（`$NBAllowedHeads` 等）と上記の EffectClass ベース判定に統合されています。式中の head から「全 head が承認可能 head か」を文字列パースせずに判定できるようになっています。

#### 出力モードと遅延バッファ

ClaudeRuntime 経由の式実行では、出力の扱い方を 2 つのモードから選べます（2026-06-03 追加）：

- **Streaming（逐次・既定）**: 評価の進行に合わせて出力を逐次表示します。
- **Batch（集約）**: 出力を遅延バッファに溜め込み、`NBFlushDeferredOutput` を呼び出した時点で一括表示します。

```mathematica
(* バッファに溜まった出力をまとめて出力する *)
NBAccess`NBFlushDeferredOutput[]
```

Batch モードは、scheduled タスクなどから多数の出力を生成する処理で、表示順序を整えたい場合に有用です。バッファへの追加は変数操作のため評価コンテキストを問わず安全に行えますが、最終的な一括出力（フラッシュ）はメインカーネル評価で行う必要があります。位置依存の挿入はバッファ順序と整合しないため行いません。

### ClaudeTestKit との連携

[ClaudeTestKit](https://github.com/transreal/ClaudeTestKit) は NBAccess および ClaudeRuntime のテストを自動化するためのユーティリティパッケージです。パッケージ開発者や NBAccess を組み込むプロジェクト向けに、以下の用途で使用します：

- NBAccess の各 API に対するユニットテスト・統合テストの実行
- プライバシーフィルタリング・アクセス制御ロジックの回帰テスト
- ClaudeRuntime のルーティング判定・ポリシーゲートの動作検証

ClaudeTestKit は開発・検証用パッケージであり、エンドユーザーが通常利用する際には必須ではありません。

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

### 詳細ログ設定

NBAccess 内部の詳細ログ出力を制御できます：

```mathematica
(* 詳細ログを Messages に出力する *)
$NBVerbose = True

(* 重大エラー以外のログを抑制する（デフォルト） *)
$NBVerbose = False
```

### アクセス可能ディレクトリ・パス参照設定

Claude Code が参照可能なディレクトリは、ノートブック単位で TaggingRules に永続化されます。従来は絶対パス文字列のリスト（`claudeAccessibleDirs`）で管理していましたが、複数 PC 間で安定したシンボリックパスを扱える **AccessPathRef** 形式（`claudeAccessiblePathRefs`）が正本（canonical）になりました。

```mathematica
(* 従来形式（後方互換 API）: 絶対パス文字列のリストを保存・取得 *)
NBAccess`NBSetAccessibleDirs[nb, {"C:\\path\\to\\dir1", "C:\\path\\to\\dir2"}]
NBAccess`NBGetAccessibleDirs[nb]

(* 正本 API: AccessPathRef のリストを保存・取得 *)
(* 各 AccessPathRef は <|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|> *)
refs = {NBAccess`NBNormalizeAccessPathRef["C:\\path\\to\\dir1"]}
NBAccess`NBSetAccessiblePathRefs[nb, refs]
NBAccess`NBGetAccessiblePathRefs[nb]

(* PathRef を現在の PC 上の実パスへ解決する *)
NBAccess`NBResolvePathRef[First[refs]["PathRef"]]
```

`NBGetAccessiblePathRefs` は、`claudeAccessiblePathRefs` が未設定の旧ノートブックに対しては `claudeAccessibleDirs`（旧形式の絶対パスリスト）を AccessPathRef に変換して返す read fallback を行います。`NBResolvePathRef` は PathRef が別 PC のエイリアスにしか一致しない場合やルート未定義の場合は `Missing[...]` を返します。これは同一性の情報であり、アクセス権限を直接与えるものではない点に注意してください。

### プロバイダー別アクセスレベル設定

ClaudeRuntime のフォールバックモデル・ルーティング機構と連携し、AI プロバイダーごとにアクセスを許可するデータの機密レベル上限を設定できます：

```mathematica
(* anthropic はクラウドLLM安全レベル (0.5) までのデータのみアクセス許可 *)
NBAccess`NBSetProviderMaxAccessLevel["anthropic", 0.5]

(* lmstudio (ローカルLLM) はすべてのレベルのデータにアクセス許可 *)
NBAccess`NBSetProviderMaxAccessLevel["lmstudio", 1.0]

(* 現在の設定値を取得する（未登録プロバイダーは 0.5 を返す） *)
NBAccess`NBGetProviderMaxAccessLevel["anthropic"]

(* 指定アクセスレベルで利用可能なフォールバックモデルのみ抽出する *)
NBAccess`NBGetAvailableFallbackModels[0.8]
```

これにより、`Private` 宣言（`CloudPublishable -> False`）されたノートブックのデータが誤ってクラウドLLM（anthropic / openai などの MaxAccessLevel = 0.5 プロバイダー）に送信されることを防ぎ、ローカル LLM（lmstudio 等の MaxAccessLevel = 1.0 プロバイダー）のみを経由するよう強制できます。ノートブックが要求するアクセスレベルは `NBAccess`NBNotebookRequiredAccessLevel[nb]` で確認でき、Private 宣言時は 1.0、それ以外は 0.0 を返します。

### 分離原則の除外設定

NBAccess 分離原則チェックから除外するパッケージの設定：

```mathematica
(* デフォルトで NBAccess と NotebookExtensions は除外済み *)
$NBSeparationIgnoreList = {"NBAccess", "NotebookExtensions"}

(* 独自パッケージを追加する場合 *)
AppendTo[$NBSeparationIgnoreList, "MyPackage"]
```

### 機密生成ヘッド API

`$NBConfidentialHeads` は「返り値が機密たり得る関数ヘッド」の登録レジストリ（`<|name -> level|>` 形式）です。SourceVault 等のデータ層パッケージがロード時に自動登録し、claudecode が LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定に使用します。通常はユーザーが手動で操作する必要はありませんが、以下の API で参照・管理できます。

```mathematica
(* 登録済みの機密生成ヘッド表を取得する *)
NBAccess`NBGetConfidentialHeads[]
(* 出力例: <|"SourceVaultSearch" -> 1.0, ...|> *)

(* 返り値が機密たり得る関数ヘッドを登録する（level 既定 1.0） *)
NBAccess`NBRegisterConfidentialHead["MySecretFunc"]
NBAccess`NBRegisterConfidentialHead["MySecretFunc", 0.8]

(* テキストが登録済みの機密生成ヘッドを参照しているか確認する *)
(* 識別子境界 (Unicode) で誤マッチを防ぎ、Map 等への関数値渡し形式も検出する *)
NBAccess`NBTextUsesConfidentialHead["result = MySecretFunc[x]"]
(* True または False を返す *)

(* 機密生成ヘッドの登録を解除する *)
NBAccess`NBUnregisterConfidentialHead["MySecretFunc"]
```

これらの関数は `$NBConfidentialSymbols`（秘密変数レジストリ）のヘッド版にあたる仕組みを提供します。カスタムデータ層パッケージを開発している場合、ロード時に `NBRegisterConfidentialHead` を呼び出すことで、そのパッケージの出力を返す関数を機密生成ヘッドとして宣言できます。

### カレンダー連携設定（iCal/ICS、新規追加）

NBAccess にオーナーの iCal/ICS カレンダーをアクセスレベル制御付きで読み取る機能が追加されました。カレンダー本体はプライベートなオーナーの予定表であるため、SystemCredential 経由で所在地を登録してから使用します。

```mathematica
(* カレンダーの所在地（.ics ファイルパスまたは URL）を登録する *)
SystemCredential["ics-calendar"] = "C:\\path\\to\\calendar.ics"
(* または SystemCredential["ics-calendar"] = "https://example.com/calendar.ics" *)

(* イベント同一性 (EventId) 導出用の HMAC 鍵を、署名鍵とは別の credential 名で登録する場合 *)
SystemCredential["MyCalendarHmacKey"] = "任意の秘密文字列"
NBAccess`$NBCalendarIdentityKeyRef = "MyCalendarHmacKey"

(* 出席必須イベントを判定するパターン（Summary/Categories/Description に大小文字を区別せずマッチ） *)
$NBCalendarMandatoryPatterns = {"MTG", "\:9762\:8ac7"}

(* 解析結果のメモリキャッシュ保持秒数（デフォルト 300） *)
$NBCalendarCacheSeconds = 300
```

- **`$NBCalendarCredentialName`**（既定 `"ics-calendar"`）: カレンダーの所在地（ファイルパスまたは URL）を保持する SystemCredential キー名です。
- **`$NBCalendarIdentityKeyRef`**（既定 `Missing["None"]`）: 各イベントの安定した匿名 ID（`"EventId"`）を導出する HMAC 鍵を保持する SystemCredential キー名です。署名・MAC 鍵とは別に管理します。未設定の場合、`EventId` は `"unkeyed:<digest>"` 形式に劣化し、`"Wrap"->True` 時の `"IdentityKeyed"` は `False` になります。鍵をローテーションすると埋め込みの KeyId が変わるため、保存済みの EventId マッピングの移行が必要です。
- **`$NBCalendarMandatoryPatterns`**（既定 `{}`）: イベントを「出席必須」とマークする文字列パターンのリストです。導出される `Mandatory` フラグはすべてのアクセスレベルで返されます。
- **`$NBCalendarCacheSeconds`**（既定 `300`）: カレンダーソースの解析結果をメモリキャッシュする秒数です。

主要 API（アクセスレベル制御あり）:

```mathematica
(* [from, to) と重なるイベントを Start 順の Association リストで取得する *)
NBAccess`NBCalendarEvents[DateObject[{2026, 7, 16}], DateObject[{2026, 7, 23}]]

(* マージ済みのビジーブロックのみ取得する（内容フリー、AccessLevel 0.5 から利用可） *)
NBAccess`NBCalendarFreeBusy[DateObject[{2026, 7, 16}], DateObject[{2026, 7, 23}]]

(* 現在時刻が会議中かどうかを確認する（ソース不可時は False にフェイルオープン） *)
NBAccess`NBCalendarBusyQ[AbsoluteTime[]]
```

`NBCalendarEvents` は RRULE（`FREQ` DAILY/WEEKLY/MONTHLY/YEARLY、`INTERVAL`、`UNTIL`、`COUNT`、`BYDAY`（`2MO` 等の序数含む）、`BYMONTHDAY`（負値含む）、`EXDATE`、`RECURRENCE-ID` による上書き・キャンセルを含む）を個々の occurrence に展開します。返却フィールドは `PrivacySpec`（既定 `$NBPrivacySpec`）のアクセスレベルに応じて段階的に増えます：0.5 以上で free/busy と identity metadata（`Start`/`End`/`AllDay`/`Busy`/`Mandatory`/`Recurring`/`UIDDigest` に加え、生の UID を含まない `EventId`/`OriginalStart`/`SemanticDigest`/`ObservedRevision`）、0.7 以上で `Summary`/`Categories`/`Status` を追加、1.0 以上で `Description`/`Location`/`UID` を含む全フィールドが返ります。0.5 未満は `Failure["NBCalendarAccessDenied"]` を返します。オプションには `"Source"` -> Automatic（`SystemCredential[$NBCalendarCredentialName]`、または明示的な `.ics` パス/URL）、`"MaxEvents"` -> 500、`"Refresh"` -> False（解析キャッシュを無視）、`"Wrap"` -> False（True で `"Events"`/`"ObservedAtUTC"`/`"Count"`/`"Truncated"`/`"Completeness"`/`"IdentityKeyed"` を含む Association を返す）などがあります。`NBCalendarFreeBusy` と `NBCalendarBusyQ` も同じ `"Source"` 系オプションを共有します。

低レベルのピュアパーサーとして `NBICSParseEvents`（生 ICS テキストを Association リストへ解析、資格情報・ネットワーク・アクセス制御なし）と `NBICSEventOccurrences`（解析済みイベント 1 件を occurrence に展開）も公開されていますが、通常は `NBCalendarEvents` 経由で利用すれば十分です。

### $onWork タスク管理連携（新規追加）

`Global`$onWork` フォルダ配下の .nb ファイルからタスクメタデータ（Title/Status/Deadline/NextReview/Keywords/Effort/Movable/DependsOn/TaskId 等）のみを、ノートブック本文・出力を一切読まずにアクセスレベル別に取得する API が追加されました。特別な資格情報設定は不要で、既定では `Global`$onWork` を対象にします。

```mathematica
(* $onWork 配下のタスクをアクセスレベルに応じたフィールドで取得する *)
NBAccess`NBOnWorkTasks[]

(* 対象ディレクトリや未完了のみに絞り込む場合 *)
NBAccess`NBOnWorkTasks["Directory" -> "C:\\path\\to\\onWork", "IncludeDone" -> False]
```

フィールドはアクセスレベル別に段階的に増えます：0.5 で `Due`/`DueKind`/`State`/`FileDigest`/`ModificationDate`、0.7 でさらに `Title`/`Keywords`/`TaskId`/`Effort`/`Movable`/`DependsOn`、1.0 で `Path` が加わります。`Due` は `Deadline`（無ければ `NextReview`。`NextReview` が `Quantity` の場合は `ModificationDate` + offset として解決）から、`State` は `Status` から `Done`/`Pass`/`Keep`/`Open` として導出されます。オプションには `"Directory"` -> Automatic（`Global`$onWork`）、`"ModifiedWithinDays"` -> Automatic（全件）、`"IncludeDone"` -> False（`Status` が Done/Pass のものを除外）、`PrivacySpec` -> Automatic、`"MaxFiles"` -> 2000 などがあります。読み取り不能・メタデータのパース失敗時は `"State"->"Unknown"`, `"ParseFailed"->True` のレコードとなり、スキャン全体は中断しません。低レベルの `NBOnWorkTaskSafeExtract`（HELD 式から一切評価せずに安全抽出）も公開されていますが、通常は `NBOnWorkTasks` 経由で利用すれば十分です。

## 後方互換性について

NBAccess は ClaudeRuntime および ClaudeTestKit の導入後も、既存のコードとの後方互換性を維持しています。

### 互換性の保証範囲

- **ClaudeRuntime 未導入環境**: ClaudeRuntime に依存する新 API（`NBValidateHeldExpr`、`NBExecuteHeldExpr`、`NBAuthorize` 等）は ClaudeRuntime が読み込まれていない場合は定義されませんが、それ以外の全 API は従来どおり動作します。
- **既存の PrivacySpec・プライバシーフィルタリング API**: 変更なく利用可能です。
- **HistoryDB・TaggingRules API**: 変更なく利用可能です。
- **セル操作 API（`NBCellRead`、`NBCellWriteText`、`NBGetCells` 等）**: 変更なく利用可能です。
- **`$NBPrivacySpec`・`$NBConfidentialSymbols`・`$NBSendDataSchema`** 等のグローバル変数: 初期値・動作に変更はありません。
- **`$NBConfidentialHeads`**（新規追加）: 「返り値が機密たり得る関数ヘッド」の登録レジストリ（`<|name -> level|>` 形式）です。`$NBConfidentialSymbols`（秘密変数レジストリ）のヘッド版にあたります。SourceVault 等のデータ層パッケージがロード時に `NBRegisterConfidentialHead` で自動登録し、claudecode が LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定に使用します。ユーザーが手動で設定する必要はありません。関連 API として `NBGetConfidentialHeads`（テーブル取得）、`NBRegisterConfidentialHead`（登録）、`NBUnregisterConfidentialHead`（登録解除）、`NBTextUsesConfidentialHead`（テキスト内参照判定）が追加されています。
- **アクセス可能ディレクトリの正本形式変更**（Stage 9 拡張）: 旧 `NBSetAccessibleDirs`／`NBGetAccessibleDirs`（絶対パス文字列リスト）はそのまま後方互換 API として動作しますが、内部的な正本は AccessPathRef 形式（`NBSetAccessiblePathRefs`／`NBGetAccessiblePathRefs`）に移行しました。既存コードは変更なく動作します。
- **`NBJobMoveToAnchor` の戻り値変更**（2026-06-24 修正）: アンカーセルの直後にカーソルを移動する関数が True/False を返すようになりました。位置を確定できた場合（アンカーが消失している場合のノートブック末尾退避を含む）は True、jobId が `$NBJobTable` に存在しない場合のみ False を返します。従来は戻り値を使用していないコードには影響ありません。
- **カレンダー access API（`NBCalendarEvents`／`NBCalendarFreeBusy`／`NBCalendarBusyQ`／`NBICSParseEvents`／`NBICSEventOccurrences`）と `$onWork` タスク管理 API（`NBOnWorkTasks`／`NBOnWorkTaskSafeExtract`）**（新規追加）: いずれも新規 API であり、既存 API・グローバル変数には影響しません。カレンダー API はアクセスレベル 0.5 未満では `Failure["NBCalendarAccessDenied"]`（`NBCalendarBusyQ` のみ `False`）を返すため、既定の `$NBPrivacySpec`（AccessLevel 0.5）のままでも free/busy 用途には利用できます。

### ClaudeRuntime 導入時の注意点

ClaudeRuntime を導入すると、`$NBAllowedHeads`・`$NBApprovalHeads`・`$NBDenyHeads` などのグローバル変数が追加されます。既存コードがこれらのシンボル名を独自に使用している場合は、名前の衝突を確認してください。

ラベル代数 API（`NBLabelQ`、`NBLabelJoin`、`NBLabelMeet` 等）および関数セキュリティ API（`NBRegisterFunctionSecurity`、`GuardedApply`、`Declassify` 等）は ClaudeRuntime と同時に導入されたものですが、既存の API とは完全に独立しており、既存の動作に影響しません。

### バージョン間の移行

ClaudeRuntime 導入前に作成したノートブックをそのまま使い続けることができます。ClaudeRuntime の新機能を使用したい場合は、個別の関数呼び出し時に `NBAuthorize` や `NBValidateHeldExpr` を任意で追加するだけで構いません。強制的な移行作業は不要です。

なお、`NBValidateHeldExpr`／`NBExecuteHeldExpr` の検証・実行ロジックは EffectClass ベースの判定モデルに刷新されましたが、これらの API のシグネチャ（`HoldComplete[...]` と PrivacySpec を渡す呼び出し方）は変わっていません。旧来オプション（`"TimeConstraint"`、`"AllowedHeads"`、`"ApprovalHeads"`、`"DenyHeads"`、`"LabelCheck"` 等）を明示指定していたコードがある場合のみ、グローバル変数による設定へ置き換えてください。これらのオプションはすでに削除されており、明示指定しても効果はありません。

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

### アクセス可能ディレクトリテスト

```mathematica
(* 現在のノートブックにアクセス可能ディレクトリを設定・取得する *)
NBAccess`NBSetAccessiblePathRefs[nb, {NBAccess`NBNormalizeAccessPathRef["C:\\path\\to\\dir"]}]
NBAccess`NBGetAccessiblePathRefs[nb]
```

### 依存グラフ機能テスト

```mathematica
(* 基本的な依存関係の確認 *)
dependencies = NBAccess`NBBuildVarDependencies[nb]

(* 依存グラフの可視化（機密変数がある場合） *)
NBAccess`NBPlotDependencyGraph[nb, "Scope" -> "Local"]
```

### 機密生成ヘッド API テスト

```mathematica
(* 登録済みの機密生成ヘッド一覧を確認する *)
NBAccess`NBGetConfidentialHeads[]

(* テキストが機密生成ヘッドを参照しているか確認する *)
NBAccess`NBTextUsesConfidentialHead["result = SourceVaultSearch[query]"]
(* True が返れば、そのテキストを含むセルは機密扱い候補となる *)
```

### カレンダーアクセステスト

```mathematica
(* SystemCredential["ics-calendar"] にカレンダーの所在地を登録済みであること *)

(* free/busy のみ取得（AccessLevel 0.5 で利用可能） *)
NBAccess`NBCalendarFreeBusy[DateObject[{2026, 7, 16}], DateObject[{2026, 7, 23}]]

(* 現在時刻が会議中かどうかを確認する *)
NBAccess`NBCalendarBusyQ[AbsoluteTime[]]

(* テスト用に .ics 生テキストを直接渡す（Source をバイパス） *)
NBAccess`NBCalendarEvents[
  DateObject[{2026, 7, 16}], DateObject[{2026, 7, 23}],
  "ICSText" -> icsRawText, "Wrap" -> True
]
```

### $onWork タスク一覧テスト

```mathematica
(* Global`$onWork 配下のタスクをアクセスレベルに応じたフィールドで取得する *)
NBAccess`NBOnWorkTasks[]

(* 未完了タスクのみ、最近更新されたものに絞り込む *)
NBAccess`NBOnWorkTasks["IncludeDone" -> False, "ModifiedWithinDays" -> 7]
```

### ClaudeRuntime 連携テスト（ClaudeRuntime 導入時のみ）

```mathematica
(* ルーティング判定の確認 *)
NBAccess`NBRouteDecision[0.5]
(* 出力例: <|"Route" -> "CloudLLM", "EffectiveRiskScore" -> 0.5, ...|> *)

(* 式の事前検証 *)
NBAccess`NBValidateHeldExpr[HoldComplete[1 + 1], <|"AccessLevel" -> 0.5|>]

(* Batch 出力モードで溜めた出力の一括フラッシュ *)
NBAccess`NBFlushDeferredOutput[]
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

### 式の実行が不必要に承認待ちになる場合

`NBValidateHeldExpr`／`NBExecuteHeldExpr` が、本来は安全なローカル定義や純粋な数学関数を承認対象としてしまう場合は、検証エンジンの EffectClass ベース判定が想定どおり機能しているかを確認してください。`Module`／`Block`／`With` のスコープ局所変数や `Set`／`SetDelayed` で定義したローカル関数名は承認対象から除外されます。`Total` や `IntegerPart`、`Round`、`Floor`、`Ceiling` などの純粋な数学関数も `PureComputation` として扱われ、ブロックされにくくなっています。`Evaluate` は Deny 対象から除去済みのため、`ParametricPlot[Evaluate[...]]` のような式が不必要に拒否・承認待ちになることもありません。信頼パッケージ由来の head（`SourceVault*` 等）についても過剰反復ガードにより承認要求が繰り返し発火しないようになっています。意図せず承認が要求される場合は、式が副作用のある head（ノートブック書き込みやファイル操作など）を含んでいないかを確認してください。

### 承認 UI が「フォーマットしています」のまま長時間ブロックする場合

承認ボタン本体はメインカーネル評価コンテキストで動作します。検証済みパスに対する実行はトップレベル評価でのみ効くため、承認 UI が「フォーマットしています」の表示のまま長時間応答しないように見えることがあります（2026-06-06 の修正で改善済み）。最新のパッケージに更新してもこの状態が続く場合は、評価が AsyncActive（非同期処理の進行中）のまま Pending になっていないかを確認してください。

### ClaudeRuntime の API が見つからない場合

`NBValidateHeldExpr` 等の ClaudeRuntime 連携 API が未定義の場合は、ClaudeRuntime が読み込まれていることを確認してください：

```mathematica
(* ClaudeRuntime が読み込まれているか確認 *)
Names["NBAccess`NBAuthorize"]
(* {} が返る場合は ClaudeRuntime が未ロード *)

Block[{$CharacterEncoding = "UTF-8"}, Get["ClaudeRuntime.wl"]]
```

### Batch モードで出力が表示されない場合

出力モードを Batch（集約）にしている場合、評価が終わっても出力が表示されないことがあります。これは出力が遅延バッファに溜まっているためです。`NBFlushDeferredOutput` を呼び出してバッファ内容を一括出力してください：

```mathematica
NBAccess`NBFlushDeferredOutput[]
```

フラッシュはメインカーネル評価で行う必要があります。scheduled タスクなどから直接呼ぶと正しく表示されない場合があるため、メイン評価のタイミングで呼び出してください。

### アクセス可能ディレクトリ・プロバイダーアクセスレベルの確認

意図しないディレクトリ・プロバイダーにデータが渡っているように見える場合は、まず現在の設定を確認してください：

```mathematica
(* 現在のノートブックのアクセス可能ディレクトリ（正本）を確認 *)
NBAccess`NBGetAccessiblePathRefs[nb]

(* 各プロバイダーの許可アクセスレベル上限を確認 *)
NBAccess`NBGetProviderMaxAccessLevel["anthropic"]
NBAccess`NBGetProviderMaxAccessLevel["lmstudio"]
```

`PathRef` が別 PC のエイリアスにしか一致しない、またはルート未定義の場合、`NBResolvePathRef` は `Missing[...]` を返し実パスへの解決を行いません（rule 104）。プロバイダー側は `MaxAccessLevel` を超えるアクセスレベルのリクエストにはフォールバックしないため、Private 宣言されたノートブックのデータがクラウドLLMに送られることはありません。

### カレンダーアクセスが失敗・拒否される場合

`NBCalendarEvents` が `Failure["NBCalendarAccessDenied"]` を返す場合は、`PrivacySpec`（既定 `$NBPrivacySpec`）の `AccessLevel` が 0.5 未満になっていないか確認してください。free/busy のみで良い場合は `NBCalendarFreeBusy` や `NBCalendarBusyQ` を使うと AccessLevel 0.5 のまま利用できます。

イベントが 1 件も返らない、あるいはカレンダー全体が読めていないように見える場合は、`SystemCredential["ics-calendar"]`（または `$NBCalendarCredentialName` で指定したキー）にカレンダーの所在地（`.ics` ファイルパスまたは URL）が正しく設定されているかを確認してください。`NBCalendarBusyQ` はソースが読めない場合でも `Failure` ではなく `False` を返す（通知ゲーティングが「busy でない」側にフェイルオープンする）ため、常に `False` が返る場合はソース未設定・読み取り不可を疑ってください。

解析結果は既定で `$NBCalendarCacheSeconds`（既定 300 秒）の間キャッシュされます。カレンダーを更新した直後に古い内容が返る場合は、`"Refresh" -> True` オプションを指定してキャッシュを無視してください。

`EventId` が呼び出しのたびに変わって見える場合は、`$NBCalendarIdentityKeyRef` に登録した SystemCredential キーが変更・ローテーションされていないかを確認してください。鍵をローテーションすると `EventId` に埋め込まれる KeyId が変わるため、保存済みの EventId マッピングは移行が必要です（未設定のままだと `EventId` は `"unkeyed:<digest>"` 形式になります）。

### 依存関係問題

分離原則違反が報告される場合：

```mathematica
(* 分離原則チェック実行 (claudecode が提供する関数) *)
ClaudeCheckSeparation["YourPackageName"]

(* 自動修正 *)
ClaudeFixSeparation["YourPackageName"]
```

### パフォーマンス問題

大きなノートブックで動作が遅い場合、NBAccess は自動的にキャッシュ機能を使用してFrontEndアクセスを最適化します。通常は設定不要ですが、問題が発生した場合はノートブックを再起動してください。

`NBFileSpec` によるファイルメタ情報・PrivacyLevel 判定にはキャッシュが使用されています（Phase 4.3）。ファイルの内容やアクセス権が変わったにもかかわらず古い判定結果が返り続ける場合は、以下でキャッシュをクリアしてください：

```mathematica
NBAccess`NBFileSpecCacheClear[]
```

## 次のステップ

- **基本的な使用方法**: `user_manual.md` を参照してください
- **API リファレンス**: `api.md` で詳細な関数仕様を確認してください
- **暗号化・鍵管理**: `api_crypto.md` で暗号化 API の詳細を確認してください
- **概要・設計思想**: `README.md` を参照してください

## サポート

問題が発生した場合は、GitHub リポジトリにてイシューを報告してください：  
https://github.com/transreal/NBAccess