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

API キー管理では、クラウド LLM（Anthropic、OpenAI）だけでなく、**LM Studio などのローカル LLM の API キーも `SystemCredential` 経由で統一的に管理**できます。`NBGetAPIKey["lmstudio"]` により、LM Studio の API キー（ローカルサーバーへの認証トークン等）を安全に取得できます。これにより、ローカル・クラウドを問わず、すべてのプロバイダーの API キー管理を同一のインターフェースで行えます。

**クラウド公開宣言（CloudPublishable）**: ノートブックに `CloudPublishable -> False` を宣言することで、そのノートブックが機密データを含みクラウド LLM への送信を拒否することを明示できます。`NBNotebookRequiredAccessLevel[nb]` はこの宣言を読み取り、Private 宣言済みのノートブックでは 1.0（ローカル LLM のみ）、それ以外では 0.0 を返します。この値は `NBGetAvailableFallbackModels` と組み合わせてプロバイダールーティング判定に利用できます。

**ノートブックキャッシュ修復**: 外部ツール（エディタ・バージョン管理のマージ等）で Wolfram System の外側から直接編集された `.nb` ファイルは、ヘッダ内のバイト位置キャッシュ（NotebookDataLength / OutlinePosition / CellTagsIndexPosition 等）が実体とずれ、開くたびにクリーンアップダイアログが繰り返し出るなどの症状を起こします。`NBRepairNotebookCache[path]` は該当ファイルを FrontEnd 経由で一度開いて `NotebookSave` することでこのバイト位置キャッシュを再生成します（Notebook 式の内容自体は変更しません）。フォルダ配下を一括修復する `NBRepairNotebookCacheFolder[dir, opts]`、通常修復では効果がない場合の強力版フォールバック `NBRepairNotebookCacheStrict[path]`（`NotebookImport` で読み込み、`CreateDocument` で新規ノートブックを作成し直して元パスに上書き保存）、および修復作業で残る `.nb.tmp-*` の残骸を削除する `NBCleanupTmpFiles[dir, opts]` も提供されます。

### 変数依存グラフによる自動検出

NBAccess は Input セルの代入文を静的に解析し、変数間の依存関係グラフを構築します。機密変数に直接・間接的に依存するすべてのセルを推移的に検出し、自動的に「依存機密」としてマークします。これにより、`apiKey = "sk-..."` のような直接的な機密だけでなく、`result = callAPI[apiKey]` のような間接的な機密も漏れなく保護されます。

変数名だけでなく **関数ヘッド単位の機密判定** にも対応しています。「返り値が機密たり得る関数ヘッド」を `$NBConfidentialHeads` レジストリ（`NBRegisterConfidentialHead` で登録）に保持し、SourceVault 等のデータ層パッケージがロード時に自動登録します。claudecode は LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定にこれを利用します。

`NBScanDependentCells` は事前計算済みの依存グラフを受け取るオーバーロードを提供しており、同一ノートブックに対して複数回スキャンする場合の二重計算を回避できます。また、`NBUpdateGlobalVarDependencies` により、既存の依存グラフに新しいセルのみを追加走査してマージするインクリメンタル更新も可能です。

`NBBuildGlobalVarDependencies` は開いている全ノートブック（`Notebooks[]`）の Input セルを横断的に走査し、統合された変数依存関係グラフを構築します。これは ClaudeQuery/ClaudeEval/ContinueEval の直前に行う精密チェックで使用されます。通常のセル実行時には軽量版の `NBBuildVarDependencies[nb]` を使用してください。`NBExtractAssignments` 公開関数により、テキストから代入文の解析も直接実行できます。現在登録済みの機密変数テーブルは `NBGetConfidentialVars[]` で取得できます。

### 差分圧縮による履歴管理

汎用履歴データベース API は、ノートブックの TaggingRules にチャットセッションなどの履歴を保存します。連続するエントリ間の差分を自動圧縮することで、ノートブックファイルの肥大化を抑えつつ、完全な履歴を保持します。親セッションの継承機能により、セッションのフォークや分岐にも対応しています。

履歴データの読み取りにはインメモリキャッシュが組み込まれており、同一セッション内で同じ履歴を繰り返し参照する際の FrontEnd 通信を大幅に削減します。書き込み操作はキャッシュと自動的に同期されるため、整合性は常に保たれます。`NBHistoryCacheClear[]` でキャッシュの手動クリアも可能です。履歴が不要になった場合は `NBHistoryDelete[nb, tag]` でデータベースごと削除できます。

### SourceVault との統合とパス・値オブジェクトの正規化

NBAccess は [SourceVault](https://github.com/transreal/SourceVault) パッケージと統合され、**ファイル・ディレクトリパスおよびカーネル内の値オブジェクトを、プライバシーレベル付きの正規化された ObjectSpec として表現**できるようになりました。SourceVault は機密リソースの参照を抽象化するためのレジストリ層であり、NBAccess はその上で以下のような統合 API を提供します。

- **`NBFileSpec[path]`** — ファイルのメタ情報とプライバシーレベルを Association として返します。`PrivacyLevel` フィールドは `< 0.5`（クラウド可）/ `>= 0.5`（ローカルのみ）/ `{0.5, 1.0}`（混在）の値域で、ファイル単位のルーティング判定に直接利用できます。
- **`NBNormalizePath[path]`** — 絶対パスを `RootId`・`Parts`・`SymbolicPath`・`PhysicalPath`・`ResolutionStatus`・`MatchedBy` などのキーを持つシンボリックパス情報に正規化します。これにより、別 PC や別ユーザー環境で記録されたパスでも、ローカルルート / エイリアスとのマッチング状態を明示的に保持したまま受け渡しできます。
- **`NBValueSpec[expr, privacyLevel]`** — カーネル内の値オブジェクトの型情報とプライバシーレベルを Association として返します。値そのものを LLM に渡さずに、構造情報のみを安全に伝達できます。
- **`NBPrivacyLevelToRoutes[privacyLevel]`** — プライバシーレベルを `{"cloud"}` / `{"local"}` / `{"cloud", "local"}` のモデルルートリストに変換します。NBFileSpec / NBValueSpec が返す `PrivacyLevel` をそのまま渡すことで、利用可能なモデルクラスを自動判定できます。

これらの ObjectSpec API は、ファイル単位・値単位のプライバシーポリシーを **セルレベルのフィルタリングと整合的に組み合わせる** ための基盤を提供します。`NBFileSpec` には base/projection レベルのキャッシュが組み込まれており、頻繁なパス参照でも FrontEnd 通信や FileSystem アクセスを大幅に削減します。キャッシュの手動クリアには `NBFileSpecCacheClear[]` を使用してください。

### アクセス可能ディレクトリの正規化パス参照 (AccessPathRef)

NBAccess は、Claude Code が参照可能なディレクトリを **AccessPathRef 形式**（`PathRef` / `Mode` / `CloudSend` キーを持つ Association）で管理する仕組みを提供します。従来の絶対パス文字列リスト（`claudeAccessibleDirs`）に代わり、AccessPathRef がノートブック単位のディレクトリ設定の正本（canonical）形式となりました。`NBNormalizeAccessPathRef` でパスを AccessPathRef 形式に変換し、`NBSetAccessiblePathRefs` / `NBGetAccessiblePathRefs` で保存・取得します。`NBResolvePathRef` は AccessPathRef を現在の PC 上の実パスへ解決し、別 PC や未定義ルートの場合は `Missing[...]` を返します。旧形式の `NBSetAccessibleDirs` / `NBGetAccessibleDirs` は後方互換 API として引き続き利用可能であり、`NBGetAccessiblePathRefs` は旧形式ノートブックに対して自動的に変換して返す read fallback を備えています。

### ノートブックモデル選択と信頼ローカルサーバー管理

NBAccess は、ノートブック単位でどの LLM モデルを優先的に使用するかを設定し、信頼できるローカル LLM サーバーを管理する仕組みを提供します。これにより、ノートブックごとに異なるモデルやサーバーエンドポイントを割り当て、実行環境に応じた柔軟なルーティングが可能になります。詳細は [ユーザーマニュアル](docs/user_manual.md) のノートブックモデル選択セクションを参照してください。

### カレンダーアクセスと $onWork タスクメタデータ（アクセスレベル制御・新機能）

NBAccess は、プライバシーファーストの設計をノートブック外部の情報源にも拡張し、ユーザーの iCal/ICS カレンダーおよび `$onWork` ディレクトリ配下のタスク管理ノートブック群を、アクセスレベルに応じて安全に読み取る API を提供します。

- **`NBCalendarEvents[from, to, opts]`** — iCal/ICS カレンダー（`SystemCredential` 経由のファイルパス / URL、または明示指定）を読み取り、指定期間に重なる予定を開始時刻順の Association リストとして返します。RRULE（FREQ DAILY/WEEKLY/MONTHLY/YEARLY、INTERVAL、UNTIL、COUNT、序数付き BYDAY、負数を含む BYMONTHDAY、EXDATE、RECURRENCE-ID による個別上書き・キャンセルを含む）を正しく展開します。返却フィールドはアクセスレベルに応じて段階的に開示されます：**0.5 以上** で空き/埋まり・出席必須フラグ・匿名化された安定 ID などのメタ情報のみ、**0.7 以上** で件名・カテゴリ・ステータスが追加、**1.0** で説明・場所・UID を含む全フィールドが開示されます。0.5 未満は `Failure["NBCalendarAccessDenied"]` を返します。
- **`NBCalendarFreeBusy[from, to, opts]`** / **`NBCalendarBusyQ[t, opts]`** — 予定の内容を一切含まない空き時間ブロック（またはある時刻が会議中か）のみを返します。AccessLevel 0.5 から利用可能で、`NBCalendarBusyQ` はカレンダーソースが取得できない場合 `Failure` ではなく `False`（非多忙扱い）にフェイルオープンし、通知ゲーティングの安全側動作を保証します。
- **`NBICSParseEvents[icsText]`** / **`NBICSEventOccurrences[event, from, to]`** — 資格情報・ネットワークアクセス・アクセス制御を伴わない純粋な ICS パーサおよび RRULE 展開関数です。
- **`NBOnWorkTasks[opts]`** — `$onWork` ディレクトリ配下のタスク管理ノートブック（.nb）を列挙し、アクセスレベルに応じて射影されたタスクレコードを返します。各ノートブックのメタデータは `NBOnWorkTaskSafeExtract` が **式を一切評価せずに** 抽出します（許可された文字列キー Title/Status/Deadline/NextReview/EventDate/Keywords/Effort/Movable/DependsOn/TaskId とリテラル値のみを保持し、それ以外はすべて破棄）。0.5 未満は `Failure["NBOnWorkAccessDenied"]` を返し、ノートブック本文・出力はいかなるアクセスレベルでも読み取られません。

これらの API は、Anthropic 等クラウド LLM にスケジュール情報を渡す際の意図しない情報漏洩を防ぎつつ、AI エージェントが空き時間確認やタスク進捗の把握を安全に行えるようにするために設計されています。

### 暗号鍵ストア (NBAccess_crypto)

NBAccess は、`NBAccess_crypto.wl`（本体とは別ファイルだが同じ `NBAccess`` コンテキスト）として **鍵隔離層** を提供します。SourceVault などの上位層に暗号化・MAC・署名機能を提供しつつ、**鍵材料（鍵そのもの）は NBAccess の外へ一切返さない** ことが設計の核心です。上位層は不透明な KeyRef 文字列を介して鍵を参照し、暗号操作の結果（暗号文・MAC・真偽値・公開鍵）だけを受け取ります。鍵材料はどの公開 API の戻り値・ログ・index レコードにも現れず、復元は `BinaryDeserialize` のみ（`ToExpression` 不使用）で行われます。KeyRef index には鍵材料を含まず、purpose / algorithm / fingerprint / created / status / backend のメタ情報のみが保持されます。

主な特徴は以下のとおりです。

- **2 種類のバックエンド** — `$NBCredentialBackend` で `"Memory"`（既定。カーネル内・揮発性・開発/テスト用、同期も永続化もされない）と `"SystemCredential"`（OS の資格情報ストア = Windows Credential Manager/DPAPI による永続化。本番想定）を切り替えます。鍵を生成・使用する **前に** 設定してください。永続データには必ず `"SystemCredential"` を選びます（`"Memory"` 鍵はカーネルごとにランダムで、終了時に失われ、暗号化したデータは後で復号できません）。
- **鍵生成と管理** — `NBGenerateSymmetricKeyRef`（AES256）/ `NBGenerateMacKeyRef`（HMAC 鍵）/ `NBGenerateAsymmetricKeyRefPair`（RSA）でランダム鍵を生成し、`NBKeyStatus` / `NBListCredentialKeyRefs` / `NBDeleteCredentialKey` で管理します。`NBKeyStatus` は鍵材料を含まない metadata のみを返します。
- **KeyRef による暗号操作** — `NBEncryptWithKeyRef` / `NBDecryptWithKeyRef` / `NBMacWithKeyRef`（HMAC-SHA256）/ `NBVerifyMacWithKeyRef`（constant-time 比較）/ `NBGetPublicKeyForKeyRef`。WL 14.3 には AEAD/GCM がないため、at-rest の完全性は **encrypt-then-MAC** で確保します。
- **可搬鍵バンドル** — `NBExportWrappedKeys` / `NBImportWrappedKeys` は、SourceVault のパスフレーズ鍵バンドル向けに、鍵を `wrapKey` で暗号化した状態でのみ取り出し / 書き戻します（出力は暗号文のみ）。
- **セルフテスト** — `NBCryptoSelfTest[]` が鍵隔離・暗号/MAC roundtrip・誤鍵検出を検査します。

```mathematica
(* バックエンドを鍵生成より前に設定し、対称鍵・MAC 鍵を生成して暗号化する *)
$NBCredentialBackend = "SystemCredential";
NBGenerateSymmetricKeyRef["MyApp:master:atrest:v1"];
NBGenerateMacKeyRef["MyApp:master:mac:v1"];

pt  = StringToByteArray["保護したい本文", "UTF-8"];
enc = NBEncryptWithKeyRef["MyApp:master:atrest:v1", pt];   (* 鍵材料は返らない *)
dec = NBDecryptWithKeyRef["MyApp:master:atrest:v1", enc["CiphertextB64"]];
```

これは下位レイヤーであり、`SourceVault_crypto` がこの上に構築されます。API キーが `NBGetAPIKey` を経由するのと同様、この暗号レイヤーは資格情報バックエンドを自前で実装する正規の場所です。

### ClaudeRuntime との連携

NBAccess は、ノートブック内での安全な式実行・検証・ルーティング機能を提供する以下の高度な API を本体に内蔵しています。これらは主に [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) パッケージから利用されることを想定して設計されていますが、API 自体は NBAccess 本体に含まれており、ClaudeRuntime を導入していない環境でも `Needs["NBAccess`"]` だけで呼び出せます。

- **`NBValidateHeldExpr`** — LLM が生成した式を Allowed Expression Surface に照合し、実行前に安全性を検証します
- **`NBExecuteHeldExpr`** — 検証済み式をポリシーに従って安全に実行します
- **`NBAuthorize`** — PolicyGate・ScoreGate・EnvironmentGate を統合したアクセス制御判定を行います
- **`NBRouteDecision`** — コンテキストのリスクスコアに基づき、CloudLLM / PrivateLLM / LocalOnly へのルーティング推奨を返します
- **`GuardedApply`** / **`Declassify`** — 関数単位のセキュリティポリシー適用と情報ラベルの引き下げ

ClaudeRuntime は NBAccess を依存パッケージとしてロードし、これらの API を Expression-Proposal ループの各フェーズ(Validate / Execute / Route)から呼び出します。SourceVault 経由で取得した ObjectSpec を `NBValidateHeldExpr` / `NBAuthorize` に渡すことで、ファイル・値レベルのプライバシー情報を式検証ロジックに統合できます。NBAccess 単体でも全 API がそのまま利用できます(後方互換性については「後方互換性について」の節を参照してください)。

#### EffectClass ベースの検証モデル

`NBValidateHeldExpr` の検証ロジックは、従来の AllowedHeads / ApprovalHeads / DenyHeads の照合に加えて、式に含まれる head の副作用クラス（EffectClass）から承認適格性（ApprovalEligibility）を集約し、ベース判定と合成して最終判定を行うように拡張されました。

- 純粋な数学関数（`Total`、`IntegerPart`、`Round`、`Floor`、`Ceiling` など副作用のないもの）は `PureComputation` として扱われ、ブロックされにくくなります。`System`` 系の副作用のない関数も同様に純粋計算として扱われます。
- `Module` / `Block` / `With` のスコープ局所変数や、`Set` / `SetDelayed` で定義したローカル関数名は承認対象から除外され、過剰な承認要求を抑制します。
- ユーザーが承認 UI で明示承認した場合（UserApproved）や、directLLM rescue などの自動 commit 互換経路（CommitterAutoApprove）では、検証済みパスに対して実行が許可されます。
- 式中の head が `System` 系の純粋関数か否かを文字列パースに頼らずに判定できるよう改善され、`NotebookWrite[nb, Cell[...]]` のように未知 head（`Cell` 等）を含む式が誤って NeedsApproval 扱いされる過剰判定が抑制されています。
- `"Evaluate"` は Deny 対象から除去されており、`ParametricPlot[Evaluate[...]]` のように `Evaluate` を含む一般的なプロット・計算式が不必要に拒否・承認待ちになることがなくなっています。

これに伴い、旧来の `NBExecuteHeldExpr` の `"TimeConstraint"` オプションおよび `NBValidateHeldExpr` の `"AllowedHeads"` / `"ApprovalHeads"` / `"DenyHeads"` / `"LabelCheck"` をオプション引数で逐一指定する方式は **廃止** され、グローバル変数（`$NBAllowedHeads` / `$NBApprovalHeads` / `$NBDenyHeads` 等）と EffectClass ベース判定に統合されています。API のシグネチャ（`HoldComplete[...]` と PrivacySpec を渡す形）は変わっていません。

#### 出力モードと遅延バッファ

ClaudeRuntime 経由の式実行では、出力の扱い方を 2 つのモードから選べます。

- **Streaming（逐次・既定）**: 評価の進行に合わせて出力を逐次表示します。
- **Batch（集約）**: 出力を遅延バッファに溜め込み、`NBFlushDeferredOutput[]` を呼び出した時点で一括表示します。scheduled タスクなど多数の出力を生成する処理で、表示順序を整えたい場合に有用です。バッファへの追加は評価コンテキストを問わず安全ですが、最終的な一括出力（フラッシュ）はメインカーネル評価で行う必要があります。

### ClaudeTestKit によるテスト自動化

[ClaudeTestKit](https://github.com/transreal/ClaudeTestKit) は NBAccess および ClaudeRuntime のテストを自動化するためのユーティリティパッケージです。プライバシーフィルタリング・アクセス制御ロジックの回帰テスト、および ClaudeRuntime のルーティング判定・ポリシーゲートの動作検証に使用します。ClaudeTestKit は開発・検証用パッケージであり、エンドユーザーが通常利用する際には必須ではありません。

### claudecode との連携

NBAccess は [claudecode](https://github.com/transreal/claudecode) パッケージの基盤として設計されています。claudecode は NBAccess を内部的に利用し、Claude AI とのインタラクティブなノートブック操作を実現します。エンコーディング処理や `$Path` の設定は claudecode 経由で自動化されるため、通常は claudecode を通じて利用することを推奨します。

### [実験的] ノートブックファイルのプライバシー分割処理

NBAccess は claudecode パッケージの `ClaudeProcessFile` 機能に対して、ノートブックファイル（.nb）のセル単位のプライバシーレベル判定とマージ処理を提供します。各セルのプライバシーレベルは 3 段階（0.0: 公開、0.75: 秘匿依存、1.0: 秘匿）で判定され、claudecode 側でクラウド LLM とプライベート LLM への自動振り分けに使用されます。

ファイル型ノートブックの操作には専用の API 群（`NBFileOpen` / `NBFileClose` / `NBFileSave` / `NBFileReadCells` / `NBFileReadAllCells` / `NBFileWriteCell` / `NBFileWriteAllCells`）を **必ず経由する** 設計になっており、`NotebookOpen` / `NotebookGet` を直接使用してはいけません。これにより、ファイル単位の `NBFileSpec` によるプライバシー判定と整合的な読み書きが保証されます。処理結果は `NBMergeNotebookCells` により元のセル構造を保ったままマージされます。

### Job 管理による非同期出力

`NBBeginJob` / `NBEndJob` API は、ClaudeQuery などの非同期処理の出力位置を管理します。評価セルの直後にスロットセルを挿入し、プログレス通知・完了メッセージ・レスポンス本体をそれぞれ独立して書き込めます。これにより、長時間実行される AI クエリの途中経過をリアルタイムに表示できます。

### 後方互換性について

NBAccess は ClaudeRuntime・ClaudeTestKit・SourceVault の導入後も、既存のコードとの後方互換性を完全に維持しています。

- **ClaudeRuntime 未導入環境**: ClaudeRuntime から利用される API(`NBValidateHeldExpr`、`NBExecuteHeldExpr`、`NBAuthorize` 等)も NBAccess 本体に含まれており、`Needs["NBAccess`"]` だけで個別に呼び出せます。それ以外の従来 API も含めて、すべての機能が ClaudeRuntime なしで動作します。
- **SourceVault 未導入環境**: `NBFileSpec` / `NBNormalizePath` / `NBValueSpec` / `NBPrivacyLevelToRoutes` などの ObjectSpec API は NBAccess 本体に含まれており、SourceVault を導入していなくても利用できます。SourceVault を併用すると、レジストリ層を介した機密リソースの一元管理が可能になります。
- **AccessPathRef API**: `NBSetAccessiblePathRefs` / `NBGetAccessiblePathRefs` / `NBNormalizeAccessPathRef` / `NBResolvePathRef` は新規追加 API です。旧形式の `NBSetAccessibleDirs` / `NBGetAccessibleDirs` は後方互換 API として引き続き利用可能です。`NBGetAccessiblePathRefs` は旧形式（絶対パス文字列リスト）で設定されたノートブックに対しても自動変換して返す read fallback を備えています。
- **既存の PrivacySpec・プライバシーフィルタリング API**: 変更なく利用可能です。
- **HistoryDB・TaggingRules API**: 変更なく利用可能です。
- **セル操作 API（`NBCellRead`、`NBCellWriteText`、`NBGetCells` 等）**: 変更なく利用可能です。
- **グローバル変数（`$NBPrivacySpec`、`$NBConfidentialSymbols`、`$NBSendDataSchema` 等）**: 初期値・動作に変更はありません。
- **`$NBConfidentialHeads`（新規追加）**: 「返り値が機密たり得る関数ヘッド」の登録レジストリ（`<|name -> level|>` 形式）です。`$NBConfidentialSymbols`（秘密変数レジストリ）のヘッド版にあたります。SourceVault 等のデータ層パッケージがロード時に `NBRegisterConfidentialHead` で自動登録し、claudecode が LLM 生成コード書き込みセルの自動機密マーク判定と CellEpilog の依存秘密判定に使用します。ユーザーが手動で設定する必要はありません。
- **検証・実行 API のオプション**: `NBValidateHeldExpr` / `NBExecuteHeldExpr` のシグネチャは不変ですが、旧来の `"TimeConstraint"` / `"AllowedHeads"` / `"ApprovalHeads"` / `"DenyHeads"` / `"LabelCheck"` オプションは削除されています。これらを明示指定していたコードのみ、グローバル変数による設定へ置き換えてください（明示指定しても効果はありません）。

ClaudeRuntime / SourceVault 導入前に作成したノートブックはそのまま使い続けることができます。新機能を利用したい場合は、個別の関数呼び出し時に `NBAuthorize` や `NBFileSpec` を任意で追加するだけで構いません。強制的な移行作業は不要です。

## 詳細説明

### 動作環境

| 項目 | 要件 |
|------|------|
| Mathematica | 13.0 以上（推奨: 14.x） |
| OS | Windows 11 |
| 関連パッケージ（推奨） | [claudecode](https://github.com/transreal/claudecode)（自動パス設定あり） |
| 関連パッケージ（オプション） | [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime)（式検証・ルーティング強化） |
| 関連パッケージ（オプション） | [SourceVault](https://github.com/transreal/SourceVault)（機密リソースのレジストリ層） |
| テストユーティリティ（開発用） | [ClaudeTestKit](https://github.com/transreal/ClaudeTestKit)（回帰テスト・検証用） |

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

**方法 C: ClaudeRuntime / SourceVault と併用する場合（オプション）**

式検証・ルーティング機能を強化する場合は ClaudeRuntime を、機密リソースのレジストリ層を導入する場合は SourceVault を追加で読み込みます。

```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["NBAccess`", "NBAccess.wl"]];
Block[{$CharacterEncoding = "UTF-8"},
  Needs["SourceVault`", "SourceVault.wl"]];
Block[{$CharacterEncoding = "UTF-8"},
  Needs["ClaudeRuntime`", "ClaudeRuntime.wl"]];
(* または claudecode.wl 経由で自動ロードされます *)
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

(* 10. API キーの取得（クラウド・ローカル LLM を統一インターフェースで管理） *)
NBGetAPIKey["anthropic"]   (* クラウド LLM *)
NBGetAPIKey["openai"]      (* クラウド LLM *)
NBGetAPIKey["lmstudio"]    (* ローカル LLM (LM Studio) *)

(* 11. アクセス可能ディレクトリの設定（AccessPathRef 形式が正本） *)
refs = {NBNormalizeAccessPathRef["C:/Projects/myapp"]}
NBSetAccessiblePathRefs[nb, refs]              (* 正本 API *)
NBGetAccessiblePathRefs[nb]                    (* read fallback: 旧形式ノートブックも自動変換 *)
NBResolvePathRef[First[refs]["PathRef"]]       (* 実パスへ解決 *)

(* 12. クラウド公開宣言と必要アクセスレベルの確認 *)
NBNotebookRequiredAccessLevel[nb]              (* Private 宣言時は 1.0、それ以外は 0.0 *)

(* 13. SourceVault 統合: ファイル・パスをプライバシーレベル付きで参照 *)
spec   = NBFileSpec["C:/Data/secret.csv"];     (* メタ情報 + PrivacyLevel *)
routes = NBPrivacyLevelToRoutes[spec["PrivacyLevel"]];  (* {"local"} 等 *)
path   = NBNormalizePath["C:/Data/secret.csv"]; (* SymbolicPath 情報 *)

(* 14. [オプション] ClaudeRuntime 導入時: ルーティング判定と式の事前検証 *)
(* NBRouteDecision[0.5]  *)
(* NBValidateHeldExpr[HoldComplete[1 + 1], <|"AccessLevel" -> 0.5|>] *)

(* 15. カレンダー・$onWork タスクの読み取り（アクセスレベルに応じて段階開示） *)
(* NBCalendarFreeBusy[Now, Now + Quantity[7, "Days"]] *)
(* NBOnWorkTasks["ModifiedWithinDays" -> 30] *)
```

#### 主要設定変数

| 変数 | 説明 | 初期値 |
|------|------|--------|
| `$NBPrivacySpec` | デフォルトのプライバシーフィルタ | `<\|"AccessLevel" -> 0.5\|>` |
| `$NBConfidentialSymbols` | 機密変数テーブル | `<\|\|>` |
| `$NBConfidentialHeads` | 機密たり得る関数ヘッドのレジストリ | `<\|\|>` |
| `$NBSendDataSchema` | 秘密依存 Output のスキーマ情報送信フラグ | `True` |
| `$NBVerbose` | 内部詳細ログ出力フラグ | `False` |
| `$NBAutoEvalProhibitedPatterns` | 自動実行ブロックパターンリスト | `{}` |
| `$NBLLMQueryFunc` | 非同期 LLM 呼び出し用コールバック関数 | `None` |
| `$NBSeparationIgnoreList` | 分離検査で無視するパッケージ名 | `{"NBAccess", "NotebookExtensions"}` |
| `$NBConfidentialCellOpts` | 機密マーク（直接）のセル表示オプション | 赤背景 + WarningSign |
| `$NBDependentCellOpts` | 依存機密マークのセル表示オプション | 橙背景 + LockIcon |
| `$NBCredentialBackend` | 暗号鍵ストアのバックエンド | `"Memory"` |
| `$NBCalendarMandatoryPatterns` | 出席必須イベントを判定する文字列パターンリスト | `{}` |
| `$NBCalendarCacheSeconds` | カレンダーソースのインメモリ解析キャッシュ TTL（秒） | `300` |
| `$NBCalendarCredentialName` | ICS カレンダー所在地（パス/URL）を保持する `SystemCredential` キー名 | `"ics-calendar"` |
| `$NBCalendarIdentityKeyRef` | イベント安定 ID 生成用 HMAC 鍵の KeyRef | `Missing["None"]` |

> ClaudeRuntime を導入すると、式検証用に `$NBAllowedHeads` / `$NBApprovalHeads` / `$NBDenyHeads` などのグローバル変数が追加されます。既存コードがこれらのシンボル名を独自に使用している場合は名前の衝突を確認してください。

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
- **`NBParentNotebookOfCurrentCell[]`** — EvaluationCell の親ノートブックを返します
- **`NBEvaluatePreviousCell[nb]`** — 直前のセルを選択して評価します
- **`NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]`** — セルのプライバシーレベルに応じた LLM を自動選択し、非同期でセルを変換します
- **`NBInvalidateCellsCache[]`** / **`NBInvalidateCellsCache[nb]`** — 内部セルキャッシュをクリアします（`nb` 省略時は全ノートブック分）
- **`NBUserNotebooks[]`** — WindowFrame が通常のユーザーノートブックのみを返します（パレット・ダイアログ等を除外）
- **`NBRefreshCellsCache[]`** — ユーザーノートブックのセルキャッシュをスマートに再検証し、変更があったノートブックのリストを返します

#### プライバシー制御

- **`NBCellPrivacyLevel[nb, idx]`** — セルのプライバシーレベル（0.0〜1.0）を返します
- **`NBIsAccessible[nb, idx, PrivacySpec -> ps]`** — セルがアクセス可能か判定します
- **`NBFilterCellIndices[nb, indices, PrivacySpec -> ps]`** — インデックスリストをフィルタリングします
- **`NBGetCells[nb, PrivacySpec -> ps]`** — 全セルをフィルタリングして返します
- **`NBGetPrivacySpec[]`** — 現在の `$NBPrivacySpec` を返します
- **`NBConfidentialHandlingAllowedQ[mode, permissionMode]`** — ConfidentialHandling モード（EncryptedBundle / ReferenceOnly / Redacted / PlaintextDebug）が permissionMode で許容されるか返します（PlaintextDebug ゲート）
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
- **`NBGetConfidentialVars[]`** — 現在登録済みの機密変数テーブルを返します
- **`NBRegisterConfidentialHead[name, level]`** — 機密たり得る関数ヘッドを `$NBConfidentialHeads` に登録します（データ層パッケージがロード時に自動登録）
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
- **`NBNotebookRequiredAccessLevel[nb]`** — ノートブックが要求するアクセスレベルを返します（`CloudPublishable -> False` の Private 宣言時は 1.0、それ以外は 0.0）

#### ノートブックキャッシュ修復（新機能）

外部ツールで直接編集された `.nb` ファイルのバイト位置キャッシュを正規化し、開くたびのダイアログ再表示や読み込み失敗を解消します。

- **`NBRepairNotebookCache[path]`** — 対象ファイルを FrontEnd 経由で開いて `NotebookSave` することでキャッシュを再生成します（Notebook 式の内容は変更しません）
- **`NBRepairNotebookCacheFolder[dir, opts]`** — ディレクトリ配下の `.nb` を一括修復します（`"Recursive" -> True` が既定）
- **`NBRepairNotebookCacheStrict[path]`** — 通常修復が効かない場合の強力版フォールバック。`NotebookImport` で読み込み、`CreateDocument` で新規ノートブックを作成し直して元パスへ上書き保存します（TaggingRules 等の帯同オプションも引き継ぎます）
- **`NBCleanupTmpFiles[dir, opts]`** — 修復処理で残る `.nb.tmp-*` 残骸ファイルを削除します

#### カレンダーアクセス (iCal/ICS)（新機能）

ユーザーの iCal/ICS カレンダーをアクセスレベルに応じて安全に読み取ります。

- **`NBCalendarEvents[from, to, opts]`** — 指定期間の予定を Association リストとして返します（RRULE 展開対応）。返却フィールドはアクセスレベルにより 3 段階（0.5: メタ情報のみ / 0.7: 件名等追加 / 1.0: 全フィールド）で開示されます
- **`NBCalendarFreeBusy[from, to, opts]`** — 予定内容を含まない、マージ済みの空き時間ブロックを返します
- **`NBCalendarBusyQ[t, opts]`** — 指定時刻が会議中か判定します（ソース取得失敗時は安全側で `False`）
- **`NBICSParseEvents[icsText]`** — 生の ICS テキストをイベント Association のリストへパースします（アクセス制御なしの純粋パーサ）
- **`NBICSEventOccurrences[event, from, to]`** — パース済みイベントを期間内のオカレンスへ展開します

#### $onWork タスクメタデータ（新機能）

`$onWork` ディレクトリ配下のタスク管理ノートブックを、本文を読まずにメタデータのみアクセスレベルに応じて列挙します。

- **`NBOnWorkTasks[opts]`** — `$onWork` .nb ファイルを列挙し、アクセスレベル別に射影されたタスクレコード（Due/State/Title/Keywords 等）を返します
- **`NBOnWorkTaskSafeExtract[held]`** — HELD 式から許可されたキーのみを **式を評価せずに** 安全抽出する内部セキュリティコアです

#### SourceVault 統合 / ObjectSpec API

[SourceVault](https://github.com/transreal/SourceVault) との統合により、ファイル・パス・値オブジェクトをプライバシーレベル付きの正規化された Association として扱えます。SourceVault 未導入の環境でも、これらの API は NBAccess 本体に含まれているため利用可能です。

- **`NBFileSpec[path]`** — ファイルのメタ情報とプライバシーレベルを Association として返します（`PrivacyLevel`: `< 0.5`=クラウド可、`>= 0.5`=ローカルのみ、`{0.5, 1.0}`=混在）
- **`NBFileSpecCacheClear[]`** — `NBFileSpec` の base/projection キャッシュをクリアします
- **`NBNormalizePath[path]`** — 絶対パスをシンボリックパス情報の Association（`Kind`・`RootId`・`Parts`・`SymbolicPath`・`PhysicalPath`・`ResolutionStatus`・`MatchedBy`）に正規化します
- **`NBValueSpec[expr, privacyLevel]`** — 値オブジェクトの型情報とプライバシーレベルを Association として返します
- **`NBPrivacyLevelToRoutes[privacyLevel]`** — プライバシーレベルから必要なモデルルートリスト（`{"cloud"}` / `{"local"}` / `{"cloud", "local"}`）を返します

#### アクセス可能ディレクトリ / パス参照管理

- **`NBSetAccessiblePathRefs[nb, refs]`** — Claude Code が参照可能な AccessPathRef リストを設定します（正本形式）。各 ref は `<|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|>` の Association です
- **`NBGetAccessiblePathRefs[nb]`** — 設定済み AccessPathRef リストを取得します。旧形式（絶対パス文字列リスト）のノートブックに対しては自動変換して返す read fallback を備えています
- **`NBNormalizeAccessPathRef[path]`** — パスを AccessPathRef 形式に正規化します
- **`NBResolvePathRef[pathRef]`** — PathRef を現在の PC 上の実パスへ解決します。別 PC のエイリアスにしか一致しない場合やルート未定義の場合は `Missing[...]` を返します
- **`NBSetAccessibleDirs[nb, dirs]`** — Claude Code が参照可能なディレクトリリストを設定します（後方互換 API）
- **`NBGetAccessibleDirs[nb]`** — 設定済みディレクトリリストを取得します（後方互換 API）

#### Allowed Expression Surface / Iterative Agent Loop (主に ClaudeRuntime から利用)

以下の API は NBAccess 本体に含まれており、`Needs["NBAccess`"]` だけで利用可能です。主に [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) の Expression-Proposal ループから呼び出されることを想定して設計されています。検証ロジックは EffectClass ベースの判定モデルに刷新されており、旧来のオプション引数（`"TimeConstraint"` / `"AllowedHeads"` 等）は廃止されています。

- **`NBValidateHeldExpr[heldExpr, privacySpec]`** — LLM が生成した式を Allowed Expression Surface に照合し、実行前に安全性を検証します
- **`NBExecuteHeldExpr[heldExpr, opts]`** — 検証済み式をポリシーに従って安全に実行します
- **`NBFlushDeferredOutput[]`** — Batch 出力モードで遅延バッファに溜めた出力を一括フラッシュします
- **`NBRedactExecutionResult[result, accessSpec, opts]`** — 実行結果を redact し、安全な形で返します
- **`NBMakeContextPacket[nb, accessSpec, opts]`** — ノートブックから安全な context packet を構築します
- **`NBAuthorize[obj, req]`** — PolicyGate・ScoreGate・EnvironmentGate を統合したアクセス制御判定を行います
- **`NBInferExprRequirements[heldExpr, accessSpec]`** — 式が必要とするアクセスレベル・読み書き対象を静的に推定します
- **`NBReleaseResult[result, accessSpec, opts]`** — 実行結果を指定 sink に安全に release します(redaction + routing check)
- **`NBMakeRetryPacket[failureAssoc, accessSpec]`** — 失敗情報から秘密を含まない安全な retry packet を構築します
- **`NBRouteDecision[riskScore]`** — リスクスコアに基づき CloudLLM / PrivateLLM / LocalOnly へのルーティング推奨を返します
- **`GuardedApply[f, args, policy]`** — 関数単位のセキュリティポリシーを適用します
- **`Declassify[labeled, policy]`** — 情報ラベルを引き下げます

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

#### API キー管理

- **`NBGetAPIKey[provider]`** — `SystemCredential` 経由で API キーを取得します（`"anthropic"` / `"openai"` / `"github"` / `"lmstudio"`）。クラウド LLM とローカル LLM（LM Studio 等）の API キーを統一インターフェースで管理できます

#### 暗号鍵ストア (NBAccess_crypto)

`NBAccess_crypto.wl`（本体とは別ファイルだが同じ `NBAccess`` コンテキスト）が提供する鍵隔離層です。鍵材料は公開 API から一切露出しません。

- **`$NBCredentialBackend`** — 鍵ストアのバックエンド（`"Memory"`=既定/揮発性/開発用、`"SystemCredential"`=OS 資格情報ストアに永続化/本番想定）。鍵生成・使用の前に設定します
- **`NBGenerateSymmetricKeyRef[keyRef, metadata]`** — AES256 対称鍵を生成して保存します
- **`NBGenerateMacKeyRef[keyRef, metadata]`** — 256bit HMAC 鍵を生成して保存します
- **`NBGenerateAsymmetricKeyRefPair[keyRef, metadata]`** — RSA 鍵対を生成し、秘密鍵を保存・公開鍵を index に保持します
- **`NBStoreCredentialKey` / `NBKeyStatus` / `NBListCredentialKeyRefs` / `NBDeleteCredentialKey`** — 鍵の保存・状態確認（metadata のみ）・一覧・削除
- **`NBEncryptWithKeyRef` / `NBDecryptWithKeyRef`** — KeyRef による対称暗号化・復号（暗号文は Base64、鍵材料は返しません）
- **`NBMacWithKeyRef` / `NBVerifyMacWithKeyRef`** — HMAC-SHA256 の生成と constant-time 検証
- **`NBGetPublicKeyForKeyRef`** — 非対称鍵の公開鍵（秘密でない）を取得します
- **`NBExportWrappedKeys` / `NBImportWrappedKeys`** — 可搬鍵バンドル用プリミティブ（出力は暗号文のみ）
- **`NBCryptoSelfTest[]`** — 鍵隔離・暗号/MAC roundtrip・誤鍵検出を検査します

#### [実験的] ノートブックファイルのセル操作

閉じた .nb ファイルを対象とする操作は、必ず以下の API を経由してください。`NotebookOpen` / `NotebookGet` を直接使用してはいけません。

- **`NBFileOpen[path]`** — .nb ファイルを invisible モード (Visible -> False) で開き、NotebookObject を返します
- **`NBFileClose[nb]`** — NBFileOpen で開いたノートブックを閉じます
- **`NBFileSave[nb, path]`** — ノートブックを指定パスに保存します（path が None なら上書き保存）
- **`NBFileReadCells[nb, opts]`** — 全セルを PrivacySpec でフィルタリングし `{<|cellIdx, style, text, privacyLevel|>, ...}` を返します。秘密セルは `"[CONFIDENTIAL]"` に置換されます
- **`NBFileReadAllCells[nb]`** — 全セルをアクセスレベル別に分類して返します（秘密セルも含む、ローカルモデル用）
- **`NBFileWriteCell[nb, cellIdx, newText]`** — 指定セルのテキストを置換します（属性保持）
- **`NBFileWriteAllCells[nb, replacements]`** — `<|cellIdx -> newText, ...|>` に従って一括置換します
- **`NBMergeNotebookCells[src, results, outputPath]`** — 処理済みセルを元の構造にマージして保存します

#### ノートブック TaggingRules

- **`NBGetTaggingRule[nb, key]`** — TaggingRules から値を取得します（ネストパス対応）
- **`NBSetTaggingRule[nb, key, value]`** — TaggingRules に値を設定します
- **`NBDeleteTaggingRule[nb, key]`** — TaggingRules からキーを削除します
- **`NBListTaggingRuleKeys[nb, prefix]`** — TaggingRules のキー一覧を返します

### ドキュメント一覧

| ファイル | 内容 |
|----------|------|
| `docs/api.md` | API リファレンス（全関数・オプション・グローバル変数・SourceVault 統合 API の詳細仕様） |
| `docs/api_crypto.md` | 暗号鍵ストア API リファレンス（NBAccess_crypto の鍵生成・暗号/MAC・鍵バンドル仕様） |
| `docs/setup.md` | セットアップガイド（インストール・設定・AccessPathRef・ClaudeRuntime/SourceVault/ClaudeTestKit 連携・EffectClass 検証モデル・出力モード・トラブルシューティング） |
| `docs/user_manual.md` | ユーザーマニュアル（機能カテゴリ別の使い方・AccessPathRef・ノートブックモデル選択・カレンダー/$onWork タスク・ノートブックキャッシュ修復・SourceVault 統合・ClaudeRuntime 統合・後方互換性） |
| `docs/examples/example.md` | 使用例集（実践的なコード例） |
| `NBAccess_crypto.wl` | 暗号鍵ストア（鍵隔離層。鍵材料を露出せず KeyRef で暗号化/MAC/署名を提供） |

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

(* 機密変数に依存するセルを自動検出・マーク（登録済み機密変数を利用） *)
NBScanDependentCells[nb, Keys[NBGetConfidentialVars[]], deps];

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

### 暗号鍵ストア (NBAccess_crypto)

鍵材料を NBAccess の外に出さずに、KeyRef を介して暗号化・MAC・復号を行います。

```mathematica
(* バックエンドを鍵生成より前に設定（永続データには SystemCredential） *)
$NBCredentialBackend = "SystemCredential";

(* 対称鍵と MAC 鍵を別々に生成 *)
NBGenerateSymmetricKeyRef["MyApp:master:atrest:v1"];
NBGenerateMacKeyRef["MyApp:master:mac:v1"];

(* 暗号化（鍵材料は返らない。CiphertextB64 は Base64 化した EncryptedObject） *)
pt  = StringToByteArray["保護したい本文", "UTF-8"];
enc = NBEncryptWithKeyRef["MyApp:master:atrest:v1", pt];

(* encrypt-then-MAC で完全性を付与し、検証してから復号 *)
ctBytes = StringToByteArray[enc["CiphertextB64"], "UTF-8"];
mac = NBMacWithKeyRef["MyApp:master:mac:v1", ctBytes];
If[NBVerifyMacWithKeyRef["MyApp:master:mac:v1", ctBytes, mac],
  ByteArrayToString[NBDecryptWithKeyRef["MyApp:master:atrest:v1", enc["CiphertextB64"]], "UTF-8"],
  $Failed
]

(* 鍵隔離・roundtrip・誤鍵検出のセルフテスト *)
NBCryptoSelfTest[]
```

### フォールバックモデル制御と API キー管理

```mathematica
(* プロバイダー別アクセスレベル設定 *)
NBSetProviderMaxAccessLevel["lmstudio", 1.0];   (* ローカル: 全データ可 *)
NBSetProviderMaxAccessLevel["anthropic", 0.5]; (* クラウド: 非機密のみ *)

(* ノートブックが要求するアクセスレベルを確認 *)
NBNotebookRequiredAccessLevel[nb]  (* Private 宣言時は 1.0、それ以外は 0.0 *)

(* 機密データで利用可能なモデルを取得 *)
NBGetAvailableFallbackModels[0.8] (* → ローカルモデルのみ *)

(* API キー取得（クラウド・ローカル LLM を統一インターフェースで管理） *)
NBGetAPIKey["anthropic"]  (* クラウド LLM *)
NBGetAPIKey["openai"]     (* クラウド LLM *)
NBGetAPIKey["lmstudio"]   (* ローカル LLM (LM Studio) *)
```

### アクセス可能ディレクトリの AccessPathRef 管理

```mathematica
(* パスを AccessPathRef 形式に正規化して保存（正本 API） *)
refs = {NBNormalizeAccessPathRef["C:/Projects/myapp"]}
NBSetAccessiblePathRefs[nb, refs]

(* 取得（旧形式ノートブックは自動変換して返す） *)
NBGetAccessiblePathRefs[nb]

(* 実パスへ解決（別 PC・未定義ルートは Missing を返す） *)
NBResolvePathRef[First[refs]["PathRef"]]

(* 旧形式 API（後方互換） *)
NBSetAccessibleDirs[nb, {"C:/Projects/myapp", "C:/Data/public"}]
NBGetAccessibleDirs[nb]
```

### SourceVault 統合 / ObjectSpec API の使用例

```mathematica
(* ファイルのメタ情報とプライバシーレベルを取得 *)
spec = NBFileSpec["C:/Data/secret.csv"]
(* 例: <|"PrivacyLevel" -> 1.0, "PhysicalPath" -> "C:/Data/secret.csv", ...|> *)

(* プライバシーレベルから利用可能なモデルルートを判定 *)
routes = NBPrivacyLevelToRoutes[spec["PrivacyLevel"]]
(* 例: {"local"}（=ローカル LLM のみ送信可） *)

(* パスをシンボリックパス情報に正規化（PC間移植性の確保） *)
norm = NBNormalizePath["C:/Data/secret.csv"]
(* 例: <|"Kind" -> "File", "RootId" -> "...", "SymbolicPath" -> "...",
        "PhysicalPath" -> "C:/Data/secret.csv",
        "ResolutionStatus" -> "ResolvedOnThisPC",
        "MatchedBy" -> "LocalRoot"|> *)

(* 値オブジェクトの型情報を抽出（値そのものは LLM に渡さない） *)
NBValueSpec[someDataset, 0.75]

(* キャッシュのクリア *)
NBFileSpecCacheClear[];
```

### カレンダーアクセスと $onWork タスク管理

```mathematica
(* 今後7日間の空き時間ブロックのみを取得（内容は含まない、AccessLevel 0.5 で利用可） *)
NBCalendarFreeBusy[Now, Now + Quantity[7, "Days"]]

(* 現在会議中かを判定（ソース取得失敗時は安全側で False） *)
NBCalendarBusyQ[Now]

(* アクセスレベル 1.0 なら件名・場所・説明まで含む全予定を取得（RRULE 展開込み） *)
NBCalendarEvents[Now, Now + Quantity[1, "Weeks"],
  PrivacySpec -> <|"AccessLevel" -> 1.0|>]

(* $onWork ディレクトリ配下のタスクを、本文を読まずメタデータのみ列挙 *)
NBOnWorkTasks["ModifiedWithinDays" -> 30, "IncludeDone" -> False]
(* 例: {<|"Due" -> DateObject[...], "DueKind" -> "Deadline", "State" -> "Open",
         "FileDigest" -> "...", "ModificationDate" -> DateObject[...]|>, ...} *)
```

### ファイル型ノートブックの操作

```mathematica
(* invisible モードでファイルを開く *)
nbFile = NBFileOpen["C:/Notebooks/sample.nb"];

(* 全セルをプライバシーフィルタ付きで読み取り *)
cells = NBFileReadCells[nbFile, PrivacySpec -> <|"AccessLevel" -> 0.5|>];

(* 特定セルのテキストを置換 *)
NBFileWriteCell[nbFile, 3, "新しい内容"];

(* ファイルを保存して閉じる *)
NBFileSave[nbFile, None];
NBFileClose[nbFile];
```

### 安全実行・ルーティング API の使用例

```mathematica
(* リスクスコアに基づくルーティング判定 *)
NBRouteDecision[0.5]
(* 例: <|"Route" -> "CloudLLM", "EffectiveRiskScore" -> 0.5, ...|> *)

(* LLM が生成した式の事前検証（EffectClass ベース判定） *)
NBValidateHeldExpr[HoldComplete[1 + 1], <|"AccessLevel" -> 0.5|>]

(* ポリシーゲートを統合したアクセス制御判定 *)
NBAuthorize[<|"AccessLevel" -> 0.8, "Provider" -> "lmstudio"|>]

(* Batch 出力モード: 遅延バッファに溜めた出力を一括フラッシュ *)
NBFlushDeferredOutput[]
```

---

## 免責事項

本ソフトウェアは "as is"（現状有姿）で提供されており、明示・黙示を問わずいかなる保証もありません。
本ソフトウェアの使用または使用不能から生じるいかなる損害についても責任を負いません。
今後の動作保証のための更新が行われるとは限りません。
本ソフトウェアとドキュメントはほぼすべてが生成AIによって生成されたものです。
Windows 11上での実行を想定しており、MacOS, LinuxのMathematicaでの動作検証は一切していません(生成AIの処理で対応可能と想定されます)。

---

## ライセンス

```
MIT License

Copyright (c) 2026 Katsunobu Imai

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
