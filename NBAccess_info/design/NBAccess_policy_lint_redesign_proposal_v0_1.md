# パッケージソースのポリシー検査 再設計案 v0.1

対象: `ClaudeCheckSeparation` / `ClaudeFixSeparation`（claudecode.wl）の置き換え
作成: 2026-10-31（Claude Code 調査セッション）
状態: r6（Phase 0〜4 実施済み、残っていた送信経路 2 つも修正）

改訂履歴:
- r0（2026-10-31）: 初版
- r1（2026-10-31）: 方針決定を反映。置き場所は NBAccess 補助モジュール、`.nb` 直読みは Review から段階的に Error へ、コミット時は警告のみ、LLM 仕分けは任意機能（既定 Off）として残す（§11）
- r2（2026-10-31）: Phase 0 と Phase 1 を実施。§3 に実装した速度対策、§12 に Phase 1 の結果を追記
- r3（2026-10-31）: Phase 2 を実施。§13 に結果を追記
- r4（2026-10-31）: Phase 3 を実施。§14 に結果を追記し、§11 の残りの未決事項 2・3 を決めた
- r5（2026-10-31）: Phase 4 を実施。PRIV-NB-READ の 21 件を仕分けて Error に格上げ。§15 に結果を追記
- r6（2026-10-31）: §15 で残した送信経路（cloud の音声・Resonite へのパス指定）を直した。§16 に追記。§15 の「未宣言 .nb の機密度」の記述を訂正

---

## 0. なぜ作り直すか

2026-10-31 の調査で、現行の検査は「アクセスレベル・プライバシーレベルのポリシー検査」として機能していないことが分かった。実測の要点:

| 問題 | 実測・根拠 |
|---|---|
| 自動修正がコードを壊す | `iForceAccessLevelLiterals` の置換先 `"${1}0.5"` は WL の後方参照にならず、`<\|"AccessLevel" -> lvl\|>` を `<\|${1}0.5\|>` に、`Lookup[...]` を `${1}0.5[...]` に書き換える |
| 壊す修正が 1 引数呼び出しから届く | `ClaudeUpdatePackage[pkg]`（1 引数形）は `ClaudeFixSeparation[pkg]` を呼ぶ（ClaudePackageManager.wl 2243 行） |
| k 規則が数値リテラルを誤検知 | 正規表現 `"AccessLevel"\s*->\s*(?![0-9])` はバックトラックで `"AccessLevel" -> 1.0` に一致。149 ファイルで k は 128 件、うち 74 件がリテラル |
| k 規則が現行設計と矛盾 | 「AccessLevel はリテラルのみ」は rules/・skills/ に無い。rule 107 の `NBLocalLLMEffectiveMaxAccessLevel`（0.25 強制）や `NBMakeRuntimeAccessSpec` は計算値を渡す設計。0.5 への一律置換はアクセス権を上げる方向にも働く |
| プライバシーレベル規則が未検査 | `LLMSynthesize`、LLM エンドポイントへの直接 `URLRead`、要約 `"PrivacyLevel" -> 0.0` 決め打ち、`Import[path, "Notebook"]`、`NotebookOpen`、`"AccessLevel" :> x`、`spec["AccessLevel"] = x`、複数行の `CurrentValue[...]` はすべて 0 件 |
| 行単位の正規表現 | 単語境界が無く `NBAccess`NBFileReadAllCells[` を `Cells[`、`NBAccess`NBCellPrint[` を `CellPrint[` として検出。文字列リテラル内の検出が約 111 件、ブロックコメント内も検出 |
| LLM 段階がほぼ動かない | 日本語応答を `ImportString[..., "RawJSON"]` で解析して `$Failed`（rule 30 の既知の罠）。3MB の claudecode.wl を全文 1 プロンプトで送信 |
| 検査範囲が狭い | パッケージ名指定で `<pkg>.wl` しか見ない。`SourceVault_*.wl` 55 本などの補助モジュールは未検査 |
| ルータ迂回 | `iSeparationQuery` が `$ClaudeModel` を直接差し替え（中断時に戻らない）、`CodePrivacyLevel` を見ずに全文をクラウドへ送る |
| LLM 指示文が .wl に直書き | 規則 a〜k の説明プロンプトが claudecode.wl の文字列（rule 03 違反） |

結論: 正規表現の手直しでは足りない。**構文木ベースの静的検査を NBAccess に置き、規則を privacy/access 中心に組み直し、自動修正からアクセス値の書き換えを外す。**

---

## 1. 目的と非目的

### 目的

1. `$packageDirectory` のパッケージソース（`.wl`）について、NBAccess 分離・プライバシーレベル・アクセスレベル・認証情報に関する規則違反を、機械的かつ再現可能に検出する。
2. 旧 k 規則の本来の狙い（「機密アクセス箇所をコード検索で監査できるようにする」）を、リテラル強制ではなく **アクセス箇所の棚卸し（inventory）** で実現する。
3. コミット前のゲートとして使える、fail-closed の判定（解析できないファイルがあれば OK にしない）を返す。

### 非目的

- 実行時の強制。これは `NBAuthorize` / `NBValidateHeldExpr` / `NBCheck*` の責務。
- 悪意ある回避（`ToExpression` による名前合成など）の検出。既存の `NBAccess_claudecode_privacy_spec_v0_1.md` と同じく「通常実装での誤用防止」に限る。
- アクセスレベル・プライバシーレベルの値を自動で書き換えること。これはセキュリティ判断なので人間が行う。

---

## 2. 配置と責務分担

| 層 | 置き場所 | 責務 |
|---|---|---|
| 静的検査エンジンと規則表 | **NBAccess の補助モジュール `NBAccess_policylint.wl`（新設）** | ソースの読み取り専用解析。LLM・FE・ネットワークを使わない。rule 11 に従い他パッケージに依存しない（CodeParser は Wolfram 標準 paclet） |
| 対象の解決・表示・任意の LLM 仕分け | claudecode.wl の `ClaudeCheckSeparation`（互換のため名前を残し薄いラッパー化） | パッケージ名 → 主ソース＋補助モジュール、`All` → 全パッケージ。表示。Review 件の LLM 仕分け（任意） |
| 規則の説明文・LLM 向け仕分け指示 | `Claude Directives/skills/nbaccess-separation-check` | rule 03 に従い、.wl には規則 ID と構造化パターンだけを置く |
| コミット時の警告 | github.wl の `PackageCommit` 系 | `CodePrivacyLevel` 関所と同じ位置で呼び、結果を表示する。コミットは止めない（下記） |

NBAccess に置く理由（決定）: プライバシー判定・アクセスレベル判定の管轄は NBAccess（rules/10）で、`NBAuditCodexAccessibleDirs` という監査関数の前例もある。

### 公開 API（案）

```wl
NBAuditPackageSource[files : {__String} | _String, opts]
  (* 戻り値は §6 の契約 *)
NBAuditPackageSourceRules[]
  (* 規則表 <|RuleID -> <|"Severity", "Basis", "Gateways", "Remedy"|>|> を返す *)
```

オプション: `"Rules" -> All | {ruleID..}`、`"FailOn" -> {"Error"}`（既定）| `{"Error", "Review"}`、`"IncludeInventory" -> True`、`"Baseline" -> None | path`（Phase 3）、`"TimeBudget" -> Infinity | 秒数`。

### コミット時の警告（決定: 警告のみ）

- `PackageCommit` / `GitHubRefreshAndCommit` の実コミット経路と `PackageCommitPlan` / `PackageCommitDiff` の DryRun 経路の両方で、`CodePrivacyLevel` 関所の直後に `NBAuditPackageSource` を呼ぶ。両経路で同じ結果を出す（補助モジュールが DryRun 側だけに見えなかった過去の不整合を繰り返さない）。
- 対象はコミットに含まれる `.wl`（主ソースと補助モジュール）だけ。
- 結果は件数の要約と、waiver の無い Error の一覧を表示する。**コミットは止めない**。戻り値には `"PolicyLint" -> <|"Status", "Counts", ...|>` として載せ、コミットログにも要約を残す。
- 速度対策として、内容ハッシュのキャッシュ（§3）を使い、`"TimeBudget"`（既定 60 秒程度）を超えたファイルは「未検査」と表示する。未検査を「問題なし」と表示しない。
- github.wl は NBAccess を使う側なので、依存の向きは rule 11 に沿っている。NBAccess が読み込まれていない環境では「検査できなかった」と表示して続行する。

---

## 3. 解析方式

- `CodeParser`CodeParse[File[path]]` で構文木を作る。
  - 文字列リテラルとコメントは葉ノードになるため、「文字列やコメントの中で拾う」誤検知は構造上起きない。
  - 複数行にまたがる式も 1 つのノードになる。
  - 各ノードに行・桁の位置情報が付く。
- 呼び出しの照合は完全名で行う。`NBAccess`NBCellPrint` と `CellPrint` は別物として扱う。context 修飾が無いシンボルは、ファイル内の `BeginPackage` / `Begin` を見て解決する（最小限: System 名と `NBAccess`` 公開名の区別ができれば足りる）。
- 各検出に「囲んでいる定義」（直近の `SetDelayed` / `Set` の左辺 head 名）を付ける。例外指定・waiver・LLM 仕分けはこの単位で扱う。
- 構文エラーなどで解析できないファイルがあれば `Status -> "Failed"`（fail-closed）。
- 文字列の中身を見る必要がある規則（CRED-LITERAL、PRIV-EGRESS-HTTP のエンドポイント判定）は、String 葉ノードの値だけを対象にする。

**速度対策（必須）**: 実測（§10）では claudecode.wl（3.1MB）の 1 回の `CodeParse` に 346 秒かかった。SourceVault.wl（0.85MB）は 11.8 秒で、サイズに対して非線形に遅くなる。そこで次の 2 つを入れる。

1. **トップレベル単位の分割解析**: 0 桁目から始まる定義の境界でソースを区切り、塊ごとに `CodeParse` して行番号に開始行のオフセットを足す。塊の解析で構文エラーが出たら次の塊と結合して再解析する。
2. **内容ハッシュのキャッシュ**: 塊（またはファイル）の内容ハッシュをキーに検出結果を保存し、変わった塊だけを再解析する。規則表のバージョンもキーに含める。

それでも足りない場合の代替: `Import[path, "HeldExpressions"]` で式単位に保持し、位置は式の開始行だけにする。

**Phase 1 で実装した形**（`NBAccess_policylint.wl`）:

1. **形式**: 0 桁目が「識別子 + `[` / `:=` / `=` / `::` / `(` / `/:` / `^=`」の行と、0 桁目のコメント開始を境界とし、境界から次の境界の手前までを 1 形式とする。
2. **単位**: `CodeParse` は 1 回ごとの固定コストが大きい（claudecode.wl を形式ごとに解析すると 4,233 回）ので、形式をまとめて単位にする。単位の終わりは「先頭行の CRC32 を 16 で割った余りが 0 の形式」または 400 行で、内容から決まる。一部を編集しても、ほかの単位の内容は変わらずキャッシュが効く。
3. **閉じない単位**: 構文が閉じない単位は形式ごとの解析に戻し、閉じない形式は次の形式と結合する（最大 `"MaxMergeLines"` 行）。それでも閉じなければ、その範囲を `ParseFailed` として報告する。
4. **解析の省略**: 規則の手がかりになる語（対象の関数名・`NBAccess`Private``・`$NB`・`SystemCredential`・`CellObject`・鍵の書式）を 1 つも含まない単位は、どう解析しても検出が出ないので `CodeParse` を省く。ただし字句的に閉じていない単位（文字列・コメント・括弧の数）は省かずに解析する。省いた単位の `::usage` 名は正規表現で集める。
5. **展開**: `CodeParse` は BeginPackage〜EndPackage、Begin〜End を PackageNode / ContextNode / NewContextPathNode に包むので、その内側まで展開してからトップレベルの文を数える。
6. **キャッシュ**: 単位の結果を、規則の版と単位の本文のハッシュをキーにしてカーネル内に保持する。ディスクには保存しない。

---

## 4. 規則体系

規則 ID は安定 ID とし、旧 a〜j は SEP-* に対応づける。Severity は Error（違反が確定）/ Review（人間の確認が必要）/ Info（棚卸しのみ）。

### 4.1 SEP — NBAccess 分離（旧 a〜j を構文木化）

| ID | 検出 | Severity | 根拠 | 旧 |
|---|---|---|---|---|
| SEP-CELL | `Cells` / `NotebookRead` / `NotebookWrite` / `SelectionMove` / `CellPrint` / `EvaluationCell` / `SelectedCells` / `SetSelectedNotebook` / `SelectionEvaluate*` / `FrontEndTokenExecute` の呼び出し | Error | rules/10 | b, f, i |
| SEP-ATTR | `CurrentValue` / `AbsoluteCurrentValue` / `SetOptions` の第 2 引数が `TaggingRules` / `CellTags` / `CellEpilog` / `CellProlog` / `NotebookEventActions` / `CellDynamicExpression` / `NotebookDynamicExpression` | Error | rules/10 | c, g |
| SEP-PRIVATE | `NBAccess`Private`*` の参照 | Error | rules/10 | d |
| SEP-GLOBAL | NBAccess 公開グローバル（`$NB*`）への `Set` / `AppendTo` / `AssociateTo` / `PrependTo` / `KeyDropFrom` / `Unset` / Part 代入 | Error | rules/00, 10 | e, j |
| SEP-CELLOBJ | `::usage` を持つ公開関数の引数パターンに `_CellObject` | Review | rules/10 | h |

例外（gateway）: `NBAccess*.wl`、`NotebookExtensions.wl`。既存の `$NBSeparationIgnoreList` はファイル単位の SEP-* 除外として読み替えて互換を保つ。

### 4.2 PRIV — プライバシーレベル

| ID | 検出 | Severity | 根拠 |
|---|---|---|---|
| PRIV-NB-READ | PrivacyLevel を無視して `.nb` を読む: `Import[_, "Notebook" \| "NB"]`、`NotebookImport`、`NotebookGet`、`NotebookOpen`、`.nb` リテラルへの `Get` | Review → Error（§4.6 の手順で段階的に上げる） | rules/10 「.nb ファイル操作の絶対禁止事項」 |
| PRIV-NB-WRITE | `Export[_, _, "NB"]`、`Notebook[...]` の `Export` | Error | rules/10（秘匿属性が消える） |
| PRIV-LLM-CHANNEL | `LLMSynthesize` / `LLMFunction` / `ChatEvaluate` などの別チャネル LLM | Error | rules/21 |
| PRIV-EGRESS-HTTP | `URLRead` / `URLExecute` / `URLSubmit` / `URLFetch` / `ServiceExecute`。文字列引数に LLM エンドポイントのホストを含む場合は Error、それ以外は Info（egress の棚卸し） | Error / Info | rules/10, 21 |
| PRIV-LEVEL-LITERAL | レコード構築中の `"PrivacyLevel" -> 0.5 未満のリテラル` | Review | rule 61（要約の PL を一律 0.0 にしない） |
| PRIV-DECLASSIFY | `NBSetCloudPublishable[_, True]`、`NBUnmarkCell`、`NBClearWriteConfidential`、`NBSetSnapshotPrivacyLevel` への低い値 | Info（棚卸し） | rule 61、rules/10 |
| PRIV-MODEL-OVERRIDE | `$ClaudeModel` / `$ClaudePrivateModel` / `$ClaudeTestModel` への代入・`Block` | 他パッケージでは Error、claudecode 内では Review | rules/00, 21（ルータに委ねる） |

LLM エンドポイントのホスト一覧は provider の追加で変わるため、規則表とは別のデータ表にし、登録関数かオプションで差し替えられるようにする。gateway（claudecode のクエリ層・provider アダプタ）は Phase 1 の baseline を見て確定する。

### 4.3 ACC — アクセスレベル（旧 k を置き換え）

| ID | 検出 | Severity |
|---|---|---|
| ACC-INVENTORY | `"AccessLevel" -> rhs`、`"AccessLevel" :> rhs`、`spec["AccessLevel"] = rhs`、`PrivacySpec -> <\|...\|>`、`NBMakeRuntimeAccessSpec[...]` のすべて。rhs を Literal / NBAccess API 呼び出し / その他に分類して位置とともに列挙 | Info |
| ACC-ELEVATED | NBAccess 外での `AccessLevel` リテラル 0.7 以上（書き込み系の閾値）または 1.0 | Review（waiver で理由を残す） |
| ACC-UNTRUSTED | rhs が囲んでいる定義内で `OptionValue[...]` や関数引数から来ている（呼び出し側がアクセス権を上げられる） | Review |

計算値の AccessLevel そのものは違反にしない。rhs が NBAccess の API（`NBGetProviderMaxAccessLevel`、`NBLocalLLMEffectiveMaxAccessLevel`、`NBNotebookRequiredAccessLevel`、`NBMakeRuntimeAccessSpec` など）由来なら OK とする。

### 4.4 CRED — 認証情報

| ID | 検出 | Severity | 根拠 |
|---|---|---|---|
| CRED-SYSCRED | NBAccess 外の `SystemCredential` 呼び出し | Error | rules/20 |
| CRED-LITERAL | String 葉ノードがキー形式（`sk-ant-`、`sk-`、`AKIA`、`Bearer ` + 長いトークンなど）に一致 | Error | rules/20 |

### 4.5 廃止するもの

- 旧 k 規則（「AccessLevel はリテラルのみ」）と `iForceAccessLevelLiterals`。
- 行単位の正規表現走査 `iStaticSeparationScan`（Phase 2 で削除）。

### 4.6 規則の段階的な格上げ（決定: PRIV-NB-READ に適用）

既存コードに多数の該当がある規則は、いきなり Error にせず次の順で上げる。

1. **Review で導入**: Phase 2 で Review として有効にし、全パッケージの件数と箇所を baseline として記録する。
2. **仕分け**: 各箇所を次のどれかに分ける。
   - NBAccess API（`NBFileOpen`、`NBFileReadCellsInRange`、`NBReadHeader` など）に置き換えられる → 置き換える。
   - 正当な用途で、PrivacyLevel を見ずに読んでもよい理由がある（例: 自分で生成したばかりのノートブックを開く、ユーザー操作で開く）→ 理由付きの waiver を付ける。
   - NBAccess に API が足りない → rules/10 の「判断」に従い、NBAccess に責務を追加する課題として起票する。
3. **Error へ格上げ**: waiver の無い Review が 0 件になった時点で、規則表の Severity を Error に変える。格上げは規則表のデータ変更だけで行い、コードは変えない。

rule 102（`Import[path, "Notebook"]` を標準手段として勧める）との関係: rule 102 は「手書きパースより標準関数」という一般原則で、NBAccess 自身の実装や、PrivacyLevel が関係しない用途には引き続き当てはまる。パッケージから利用者のノートブックを読む経路には rules/10 が優先する。この整理は rule 102 に注記として追加する（Phase 2）。

---

## 5. 例外（waiver）

- **規則ごとの gateway モジュール**: 規則表のデータとして持つ（例: SEP-* は NBAccess / NotebookExtensions、CRED-SYSCRED は NBAccess）。
- **インライン waiver**: 検出行の直前行に `(* :PolicyWaiver: <RuleID> <理由> *)`。理由は必須。レポートには `Waived` として必ず残す（件数から消さない）。
- **ファイル単位**: 先頭付近に `(* :PolicyLintIgnore: <RuleID> <理由> *)`。既存の `:CodePrivacyLevel:` マーカーと同じ書式・同じ読み取り方。

waiver の付いた箇所は、ACC-INVENTORY と同じく「機密アクセス箇所の一覧」として検索できる。

---

## 6. 出力契約

```wl
<|
  "Status"   -> "OK" | "Violations" | "Failed",
  "Files"    -> {path..},
  "Coverage" -> <|"Parsed" -> n, "Failed" -> {<|"File", "Reason"|>..}|>,
  "Findings" -> {<|"RuleID", "Severity", "File", "Line", "Column",
                   "Definition", "Code", "Message", "Remedy", "Basis",
                   "Waived" -> False | <|"Reason" -> _String|>|>..},
  "Inventory" -> <|"AccessSites" -> {..}, "DeclassifySites" -> {..},
                   "EgressSites" -> {..}|>,
  "Counts"   -> <|RuleID -> n..|>
|>
```

- 1 ファイルでも解析に失敗したら `"Failed"`。
- waiver の無い Error が 1 件でもあれば `"Violations"`。
- Review は既定では Status に影響しない（`"FailOn"` で変更可）。

---

## 7. LLM 仕分け（決定: 任意機能として残す・claudecode 側）

- 既定は Off。On のとき対象は Review 件だけ。コミット時の警告（§2）からは呼ばない。
- 送るのは「囲んでいる定義」の抜粋（上限行数あり）だけで、ファイル全文は送らない。
- 送信は privacy 対応ルータ（`ClaudeQuerySync[..., PrivacyLevel -> pl]`）経由。`pl` はファイルの `:CodePrivacyLevel:` マーカーから取り、0.5 以上なら private model に回る。課金 API フラグにも従う。`$ClaudeModel` は書き換えない。
- 応答 JSON は `ImportByteArray[StringToByteArray[resp, "UTF-8"], "RawJSON"]` で解析する。解析に失敗した件は「仕分け不能」として Review のまま残し、偽の違反を作らない。
- LLM ができるのは「Review を Info に下げる提案」まで。Error を消すことはできない（fail-closed）。
- 仕分け指示文は skills/nbaccess-separation-check に置く（rule 03）。

---

## 8. 修正機能（ClaudeFixSeparation）

- `iForceAccessLevelLiterals` は削除する。
- ACC-* / PRIV-* / CRED-* は自動修正の対象外にする（セキュリティ判断は人間）。
- 自動修正は SEP-* の機械的な API 置換だけにする。`DryRun -> True` を既定にし、差分プレビュー、atomic write、修正後の再検査で「件数が増えていない・解析できる」ことを確かめてから書く（rules/85, 103）。
- `ClaudeUpdatePackage[pkg]`（1 引数形）からは修正を起動しない。検査結果の表示と案内だけにする。

---

## 9. 段階導入

| Phase | 内容 | 差分の大きさ |
|---|---|---|
| 0（即時・**済**） | `iForceAccessLevelLiterals` の呼び出し 3 か所を外す。k 規則を静的走査と LLM プロンプトから外す。`ClaudeUpdatePackage[pkg]` 1 引数形を検査のみにする。RawJSON の解析を `ImportByteArray` に直す | 小（claudecode.wl・ClaudePackageManager.wl） |
| 1（**済**、§12） | `NBAccess_policylint.wl`: 構文木エンジン、SEP / CRED 規則、fixture テスト、149 ファイルの baseline | 中（新規ファイル中心） |
| 2（**済**、§13） | PRIV / ACC 規則（PRIV-NB-READ は Review）、inventory、waiver。`ClaudeCheckSeparation` をラッパー化し、補助モジュールと `All` に対応。`iStaticSeparationScan` を削除。skill と rule 102 の注記を更新 | 中 |
| 3（**済**、§14） | コミット時の警告（github.wl、警告のみ）、前回コミットとの差分、LLM 仕分け（任意・既定 Off）、ディスクキャッシュ | 中 |
| 4（**済**、§15） | PRIV-NB-READ の仕分け（§4.6）と、完了後の Error への格上げ | 10 ファイル（置き換え 3・waiver 18。あわせて送信側の判定を 2 か所直した） |

---

## 10. 検証計画

- **fixture テスト**（`test codes/NBAccess_policylint_test.wl`）:
  - 誤検知ケースが 0 件: コメント内、文字列内、`NBAccess`NBFileReadAllCells[...]`、`NBAccess`NBCellPrint[...]`、`"AccessLevel" -> 1.0`
  - 見逃しケースが全件検出: 複数行 `CurrentValue`、`"AccessLevel" :> x`、`spec["AccessLevel"] = x`、`LLMSynthesize`、LLM ホストへの `URLRead`、`Import[path, "Notebook"]`、`NotebookOpen`、`"PrivacyLevel" -> 0.0`
- **baseline 比較**: 149 ファイルで旧方式と新方式の件数を規則別に並べる。
- **headless**: wolframscript で動くこと（FE 不要）。
- **性能**: CodeParser の実測は下記。

### CodeParser 実測（2026-10-31）

Mathematica 15.0、wolframscript（headless）、`CodeParser`CodeParse` は標準で読み込めた。

| 対象 | サイズ | 解析時間 | 構文エラー | `"AccessLevel"` ルール位置（構文木で分類） | egress 呼び出し |
|---|---|---|---|---|---|
| SourceVault_privacy.wl | 小 | 2.8 秒 | 0 | 0 | 0 |
| SourceVault.wl | 0.85MB | 11.8 秒 | 0 | Literal 4 / Symbol 1 / `label[...]` 3 | `URLRead` 2 |
| claudecode.wl | 3.1MB | **346 秒** | 0 | Literal 28 / Symbol 14 / `OptionValue` 2 / `Lookup` 1 | `URLRead` 14、`URLSubmit` 1 |

claudecode.wl では、旧 k 規則が 47 件を違反にしていたのに対し、構文木では 45 か所のうち 28 か所がリテラルと分かり、残り 17 か所だけが ACC-UNTRUSTED の確認対象になる。

fixture（10 行）での確認:

- コメント内の `NotebookWrite[...]` と文字列内の `Cells[...]` は検出されない。
- `NBAccess`NBFileReadAllCells` と `NBAccess`NBCellPrint` は完全名で取れ、`Cells` / `CellPrint` と区別できる。
- 2 行にまたがる `CurrentValue[...]` は 1 件として検出され、位置は 5 行目〜6 行目。
- `LLMSynthesize` を検出できる。
- `"AccessLevel" -> 1.0` は Literal、`"AccessLevel" :> lvl` は Symbol、`"AccessLevel" -> NBAccess`NBLocalLLMEffectiveMaxAccessLevel[...]` は NBAccess 呼び出しに分類される。

結論: fixture で試したケースでは、旧方式の誤検知と見逃しが構文木方式で解消した。`spec["AccessLevel"] = x`、`Import[path, "Notebook"]`、`NotebookOpen`、LLM ホストへの `URLRead`、`"PrivacyLevel" -> 0.0` は今回の fixture に入れておらず、Phase 1 のテストで確認する。速度は大きいファイルで問題になるため、§3 の分割解析とキャッシュを前提にする。

---

## 11. 決定事項と残りの未決事項

### 決定（2026-10-31）

| 項目 | 決定 | 反映先 |
|---|---|---|
| 検査エンジンの置き場所 | NBAccess の補助モジュール `NBAccess_policylint.wl` | §2 |
| `.nb` 直読み（PRIV-NB-READ） | Review で導入し、仕分け後に Error へ段階的に上げる | §4.2, §4.6, §9 |
| コミットとの連携 | github.wl で警告のみ表示する。コミットは止めない | §2, §9 |
| LLM 仕分け | 任意機能として残す（既定 Off、Review 件のみ、抜粋のみ、ルータ経由） | §7 |

参考: 粗い grep では、`Import[..., "Notebook"]` が ResoniteRealtime_tablet / SourceVault / SourceVault_issues / SourceVault_mailagenda に、`NotebookOpen` が SlideWorkflow と SourceVault 系 6 本に見つかる。§4.6 の仕分け対象の目安。

### 残りの未決事項（実装中に決めてよい小さなもの）

1. **関数名**: `NBAuditPackageSource`（`NBAuditCodexAccessibleDirs` と並べる）を暫定名とする。`ClaudeCheckSeparation` の名前は互換のため残す。
2. **`SourceVaultPrivacyAudit` との関係**: あちらは SourceVault の呼び出しグラフで「私的ストアに届く公開関数が Class を宣言しているか」を見る。本案は全パッケージ共通のソース規則なので重複しない。→ **Phase 3 で決定**: コミット時の警告には本案の検査だけを出し、並べて表示はしない。SourceVault を変えたときの privacy gate（3 本のテスト、commit を止める）は package-auto-commit skill の手順どおり別に通す。止める検査と止めない警告を混ぜないため。
3. **`"TimeBudget"` の既定値**: → **Phase 3 で決定**: 直接呼ぶときは `Infinity`（全部見る）、コミット時は `"PolicyLintTimeBudget" -> 60` 秒。超えたファイルは「未検査」として警告に出す。

---

## 12. Phase 1 実施結果（2026-10-31）

### 追加・変更したファイル

| ファイル | 内容 |
|---|---|
| `NBAccess_policylint.wl`（新規） | `NBAuditPackageSource[files, opts]` と `NBAuditPackageSourceRules[]`。規則 SEP-CELL / SEP-ATTR / SEP-PRIVATE / SEP-GLOBAL / SEP-CELLOBJ / CRED-SYSCRED / CRED-LITERAL |
| `NBAccess.wl` | 末尾に補助モジュールの自動読み込みを追加（失敗しても NBAccess 本体は止めない。局所変数は `NBAccess`Private`` 完全名にして呼び出し側の文脈にシンボルを作らない） |
| `test codes/NBAccess_policylint_test.wl`（新規） | wolframscript で実行する fixture テスト。一時フォルダだけを使う |
| `Claude Directives/skills/nbaccess-separation-check/SKILL.md` | 新しい検査の説明を追記 |

旧方式からの意図的な変更:
- 旧 b の `Cell[CellGroupData[...]]` の構築は、セルを書き込んでいないので規則から外した。
- 旧 h（`_CellObject` が出てくればすべて違反）は、「`::usage` を持つ公開関数の引数」だけを Review にした。私的な補助関数の `_CellObject` は対象外。
- CRED-SYSCRED のゲートウェイは NBAccess だけにした（旧方式は NotebookExtensions も除外していた。rules/20 は NBAccess 以外の直接呼び出しを禁じている）。

### fixture テスト

全項目合格。主な確認内容:
- **誤検知 0 件**: コメント内、文字列内、`NBAccess`NBFileReadAllCells[...]`、`NBAccess`NBCellPrint[...]`、`SetOptions[nb, WindowSize -> 400]`、私的関数の `_CellObject`、`"AccessLevel" -> 1.0`、0 桁目から始まる複数行文字列の中の `NotebookWrite[...]`。
- **見逃し 0 件**: 2 行にまたがる `CurrentValue[...]`、`SetOptions[cell, CellTags -> ...]`、`NBAccess`Private`` 参照、`AppendTo[NBAccess`$NB...]`、`NBAccess`$NBPrivacySpec["AccessLevel"] = 1.0`、`Block[{NBAccess`$NBVerbose = True}, ...]`（Review）、公開関数の `_CellObject`（Review）、`SystemCredential[...]`、鍵文字列（`Code` は `[REDACTED]`）。
- **その他**: ゲートウェイ、構文が閉じないファイルの Failed（範囲つき）、存在しないファイル、規則の絞り込み、`"FailOn"`、`"TimeBudget"`、キャッシュの有無で結果が同じこと、解析省略の判定。

### $packageDirectory 直下の全 .wl（150 ファイル、約 35 万行）

| | 新方式（構文木） | 旧方式（行単位の正規表現） |
|---|---|---|
| 初回の時間 | 101.8 秒（3,302 単位中 2,519 単位は解析を省略） | 45.4 秒 |
| 2 回目（キャッシュあり） | 3.8 秒 | — |
| 検出数 | 546（すべて Error） | 1,005（ファイル・行・規則で重複を除いた数。生の検出は 1,080） |

規則ごとの突き合わせ（ファイル・行・規則が一致したもの）:

| 規則 | 新方式 | 旧方式 | 両方 | 旧方式だけ | 新方式だけ |
|---|---|---|---|---|---|
| SEP-CELL | 435 | 790 | 413 | 377 | 0 |
| SEP-ATTR | 95 | 110 | 81 | 29 | 14 |
| SEP-PRIVATE | 3 | 13 | 3 | 10 | 0 |
| SEP-GLOBAL | 1 | 40 | 1 | 39 | 0 |
| SEP-CELLOBJ | 0 | 33 | 0 | 33 | 0 |
| CRED-SYSCRED | 12 | 19 | 1 | 18 | 11 |

（表の SEP-CELL の新方式 435 と「両方」413 の差 22 は、同じ行に複数の検出がある分。）

- **旧方式だけ（誤検知）**: 単語境界がないために `ScanConfidentialCells[`・`itStashDisplayCells[`・`NBAccess`NBSplitNotebookCells[` を `Cells[` として拾ったもの、文字列やコメントの中、`NBAccess`$NBLLMQueryFunc[...]` の呼び出しや `=== "Memory"` の比較を「書き換え」としたもの、私的関数の `_CellObject`、`Cell[CellGroupData[...]]` の構築。
- **新方式だけ（旧方式の見逃し）**: 複数行にまたがる `CurrentValue[nb,` / `SetOptions[out,` が 14 件、NotebookExtensions.wl の `SystemCredential` 呼び出しが 11 件。
- **Failed**: `i.wl` の 24〜53 行を解析できなかった。24 行目のコメント `(*{"lmstudio",…})` が `*)` ではなく `})` で終わって閉じておらず、ファイル末尾までがコメントになっている（31〜36 行目の `$ClaudeFallbackModels = {…}` は実行されていないはず）。検査側の誤りではなく、fail-closed が本物の問題を拾った例。

### Phase 2 に残したこと

- `ClaudeCheckSeparation` と `ClaudeSeparationView` を新方式に切り替える（View は `NBAuditPackageSource` の結果を表示できるようにする）。
- PRIV-* / ACC-* 規則、inventory、waiver。
- キャッシュはカーネル内だけなので、カーネルを起動するたびに初回の時間がかかる。コミット時の警告（Phase 3）までにディスクキャッシュの要否を判断する。

---

## 13. Phase 2 実施結果（2026-10-31）

### 変更内容

| ファイル | 内容 |
|---|---|
| `NBAccess_policylint.wl` | 規則を 15 個に拡張（PRIV-NB-READ / PRIV-NB-WRITE / PRIV-LLM-CHANNEL / PRIV-EGRESS-LLM / PRIV-LEVEL-LITERAL / PRIV-MODEL-OVERRIDE / ACC-ELEVATED / ACC-UNTRUSTED を追加）。waiver（行単位 `:PolicyWaiver:`・ファイル単位 `:PolicyLintIgnore:`、理由必須）、棚卸し（AccessSites / DeclassifySites / EgressSites）、規則ごとの `AutoFix`、文字列を検査する `NBAuditPackageSourceText` を追加 |
| `claudecode.wl` | `ClaudeCheckSeparation` を新エンジンのラッパーに置き換え（ファイル全文を LLM に送る判定段階と `iStaticSeparationScan` を削除）。対象解決を `iSeparationTargetFiles`（パッケージ名・パス・リスト・`All`）にまとめた。`iSeparationQuery` は `Block` で `$ClaudeModel` を切り替える（中断しても戻る） |
| `ClaudePackageManager.wl` | `ClaudeSeparationFindings` / `ClaudeSeparationView` を新エンジンに切り替え。規則 ID で分類し、要確認（Review）を区別、ソースの waiver を「済み」として扱い、解析できない範囲を「解析不能」の行として出す。`[修正案]` は AutoFix の規則だけ。修正案の違反数え直しは `NBAuditPackageSourceText` |
| `test codes/ClaudePackageManager_separationview_test.wl`（新規） | View・修正案（LLM はスタブ）・適用・確認済み記録・`ClaudeCheckSeparation` のテスト |
| `test codes/NBAccess_policylint_test.wl` | PRIV / ACC 規則、waiver、棚卸し、文字列入口のテストを追加 |
| `fix-proposal-prompt.md` / `SKILL.md` / `rules/102` | PRIV 系の置き換え方、規則表と waiver の書き方、利用者のノートブックでは rules/10 が優先する旨の注記 |

設計からの変更・追加の判断:
- PRIV-EGRESS-LLM（LLM API への直接通信）と PRIV-MODEL-OVERRIDE は、正当な用途（モデル一覧の取得、音声書き起こし、明示的なモデル切り替え）があるので Review にした。
- ゲートウェイは実コードを見て決めた。PRIV-EGRESS-LLM は `claudecode*` / `NBAccess*`、PRIV-MODEL-OVERRIDE は `claudecode*` / `NBAccess*` / `localInit*`、SEP-GLOBAL には `localInit*` を追加（`$NBCredentialBackend` などをパッケージ読み込み前に決める起動設定のため）。
- 旧方式の「確認済み」記録（分類 a〜j）は、照合キーに規則 ID が入るため新しい行には対応しない。

### 速度

照合は 1 つのトップレベル文につき「呼び出し・文字列・NBAccess`Private` 参照」を 1 回ずつ集め、規則ごとに関数名で引く形にした（規則ごとに構文木を走査し直す版より速い）。解析を省く手がかりは、各規則が成り立つための必要条件（例: `PrivacyLevel -> 数値`、`"AccessLevel" ->`、`CurrentValue` と属性名の両方）にした。

| | 単位（解析 / 省略） | 初回 | 2 回目（キャッシュ） |
|---|---|---|---|
| Phase 1（7 規則） | 783 / 2,519 | 102 秒 | 3.8 秒 |
| Phase 2 初版（15 規則、語の出現で解析） | 1,302 / 1,892 | 306 秒 | 9.6 秒 |
| Phase 2（手がかりを必要条件に絞った版） | 1,015 / 2,179 | 229 秒 | 10.0 秒 |

手がかりを絞っても検出・棚卸しの件数は変わらなかった。初回の時間はカーネルを起動するたびにかかるので、ディスクキャッシュの要否は Phase 3（コミット時の警告）で判断する。

### $packageDirectory 直下の全 .wl（147 ファイル、名前に空白を含むバックアップを除く）

解析できない範囲: 0（`i.wl` は修正済み）。検出 672 件（Error 512・Review 160、waiver 0）。

| 規則 | 件数 | 多いファイル |
|---|---|---|
| SEP-CELL | 397 | SlideWorkflow 187、claudecode 48、maildb_legacy 40、documentation 25 |
| SEP-ATTR | 85 | SlideWorkflow 40、claudecode 34、SourceVault_wiring 6 |
| ACC-ELEVATED（Review） | 55 | claudecode 22、SourceVault_mining 6 |
| PRIV-LEVEL-LITERAL（Review） | 47 | SourceVault_mcp 10、SourceVault_talkqa 10、SourceVault_promptrouter 7 |
| PRIV-NB-READ（Review） | 21 | SlideWorkflow 9、SourceVault 3、SourceVault_issues 2 |
| ACC-UNTRUSTED（Review） | 14 | claudecode 6、SourceVault_mining 5 |
| CRED-SYSCRED | 12 | NotebookExtensions 11、情報工学科成績 1 |
| PRIV-EGRESS-LLM（Review） | 12 | PresentationListener 7、documentation 3 |
| PRIV-MODEL-OVERRIDE（Review） | 11 | i-rap 3、SourceVault 3、i 2 |
| PRIV-LLM-CHANNEL | 8 | NotebookExtensions 4、documentation・EvaluateReports・maildb_legacy 各 1 |
| PRIV-NB-WRITE | 8 | SlideWorkflow 3、ClaudePackageManager・documentation_paper2nb・SourceVault_issues 各 1 |
| SEP-PRIVATE | 2 | claudecode・PresentationListener 各 1 |

棚卸し: AccessLevel の指定箇所 147（Literal 80、Other 42、NBAccessAPI 11、Option 10、Parameter 4）、機密解除の呼び出し 12、ネットワーク送信 76。

### Phase 3 以降に残したこと

- コミット時の警告（github.wl、警告のみ）と、それに合わせたディスクキャッシュの要否。
- LLM 仕分け（任意・既定 Off）。
- PRIV-NB-READ の仕分け（§4.6）と、完了後の Error への格上げ（Phase 4）。
- `ClaudeFixSeparation`（ファイル全文を LLM に書き直させる旧来の修正）の扱い。View の `[修正案]` で代替できるので、廃止を検討する。

---

## 14. Phase 3 実施結果（2026-10-31）

### ディスクキャッシュ（NBAccess_policylint.wl）

- 単位ごとの結果を、カーネル内の記録に加えて `$UserBaseDirectory/ApplicationData/NBAccess/policylint_cache.wxf` に保存する。マシンごとに持ち、Dropbox の外に置く（同期の競合を避けるため）。
- キーは「規則の版 `$iNBPLVersion` + 単位の本文」の SHA256。規則を変えて版を上げると古い記録は使われない。
- 保存するのは規則 ID・位置・定義名・重大度などだけで、コード片や鍵の文字列は入れない。Code 欄は読み出し時に本文から作り直す。
- 書き込みは一時ファイルから名前を変えて置き換える（途中で落ちても壊れたファイルを残さない）。件数の上限は 40000。
- オプション `"Cache" -> True`（既定、カーネル内 + ディスク）| `"Memory"`（カーネル内だけ）| `False`。`Coverage["CacheHits"]` にキャッシュから取った単位の数を出す。
- テストは `NBAccess`Private`$iNBPLDiskCachePath` を一時ファイルに向け、ユーザーのキャッシュには触れない。カーネル内の記録を消してもディスクから同じ検出が返ること、ファイルにコード片が入っていないことを確かめた。
- 実ファイルでの計測（claudecode.wl・github.wl・ClaudePackageManager.wl、別々の wolframscript で 2 回）: 1 回目 21.3 秒（解析 164 単位・省略 257 単位、検出 118 件）、2 回目 0.63 秒（検出 118 件で同じ）。カーネルを起動し直しても初回の時間はかからない。

### コミット時の警告（github.wl、止めない）

- `PackageCommitPlan` が、確認ゲート（ack）を通った後に `PackageCommitDiff` の `ChangedDetail` から追加・変更された `.wl` / `.m` を取り出して検査する。
- 比較の基準はミラー `GithubRepositories/<pkg>`（= 前回コミット）の同じファイルで、これも同じ規則で検査する（`NBAuditPackageSourceText`）。ミラーには書き込まない。
- 検出の照合キーは ファイル名・規則 ID・定義名・正規化したコードで、行番号は使わない。同じキーが複数あるときは個数で引き算する（2 件 → 3 件なら 1 件増えた）。
- 結果は `"PolicyLint" -> <|Status, Files, Counts, New, NewErrors, NewReview, Resolved, Unchecked, Seconds|>`。Status は `OK` | `NewErrors` | `NewReview` | `Incomplete`（時間切れ・解析できないファイルがある）| `Unavailable`（NBAccess の検査関数が無い）。
- `PackageCommit` は DryRun でも実コミットでも、増えた検出があれば `PackageCommit::policylint`、未検査のファイルがあれば `::policylintunchecked` を出す。**コミットは止めない**（§2 の決定どおり）。戻り値（DryRun・Committed）にも `"PolicyLint"` を入れる。
- 時間の上限は `"PolicyLintTimeBudget" -> 60` 秒。超えたファイルは `Unchecked` に入れ、「問題なし」とは扱わない。
- `GitHubRefreshAndCommit` を直接呼んだときも、ミラーを更新する前に差分を取って同じ警告を出す（`"PolicyLint" -> False` で省略）。`PackageCommit` からは二重に検査しないよう `"PolicyLint" -> False` で呼ぶ。
- メッセージ `GitHubRefreshAndCommit::policylint` などは、`PackageCommit` 側のメッセージを定義した後で別名として定義する（先に別名を作ると中身が空になる）。

### LLM 仕分け（ClaudePackageManager.wl、任意・既定 Off）

- `ClaudeSeparationTriage[row]` と、View の詳細欄の [LLM に判定を聞く] ボタン。押したときだけ動く。
- 送るのは違反行を含む定義ブロックだけで、`ClaudeQuerySync[prompt, "PrivacyLevel" -> pl]`（pl はファイルの `:CodePrivacyLevel:`）を通す。ルータとモデル選択の規則（rule 21・61）はそのまま効く。
- 指示文は `Claude Directives/skills/nbaccess-separation-check/triage-prompt.md`（rule 02）。応答の JSON は `ImportByteArray` で読む（rule 30）。読めない応答は `Unsure`。
- 戻り値は `<|Status, Verdict (Legitimate | Violation | Unsure), Reason, SuggestedWaiver, RowID, PrivacyLevel|>`。
- Legitimate のときは [問題なし] の理由欄に理由案を入れ、ソースに書く場合の `:PolicyWaiver:` コメントも表示する。**記録・判定・ソースはどれも自動では変わらない**。LLM の判断で Error が消える経路は作っていない（§7）。

### テスト（すべて PASS）

| テスト | 内容 |
|---|---|
| `test codes/NBAccess_policylint_test.wl` | 規則・waiver・棚卸し・解析省略・fail-closed に、ディスクキャッシュ（書き込み・読み戻し・コード片を含まない）を追加 |
| `test codes/ClaudePackageManager_separationview_test.wl` | View・修正案・適用・確認済み記録に、LLM 仕分け（スタブ。Legitimate / Violation / 読めない応答 → Unsure）を追加 |
| `test codes/github_policylint_commit_test.wl`（新規） | 一時フォルダの前回版・今回版から作った差分で、増えた Error 2・増えた Review 1・解消 1 を数える。行を前にずらしただけの検出は増えたと数えない。時間上限 0 で `Incomplete`。実パッケージで `PackageCommit["NBAccess", "DryRun" -> True, "SkipDocsGate" -> True, "MessageGenerator" -> 固定文]`（読み取りのみ）を実行し、`NBAccess.wl` と `NBAccess_policylint.wl` を検査して増えた検出 0、約 8 秒 |

実コミット（`"DryRun" -> False`）は行っていない。

### Phase 4 以降に残したこと

- PRIV-NB-READ の仕分け（§4.6）と、完了後の Error への格上げ。
- `ClaudeFixSeparation`（ファイル全文を LLM に書き直させる旧来の修正）の廃止。View の [修正案] で代替できる。
- 変更した基盤パッケージ（NBAccess・claudecode・github・ClaudePackageManager）の api.md の再生成と GitHub への反映。

---

## 15. Phase 4 実施結果（2026-10-31）

PRIV-NB-READ の 21 件（10 ファイル）を §4.6 の手順で仕分け、規則表の Severity を Error に上げた（`$iNBPLVersion = "2026-10-31.9"`）。編集前のファイルは `bak/<名前> - 20261031 pre-phase4.wl`。

### 仕分けの結果

| 扱い | 件数 | 箇所 |
|---|---|---|
| NBAccess API に置き換え | 3 | `SourceVault_issues` の `iSVISIdFromNotebookPath`・`SourceVault_mailagenda` の `iSVMARecordIdFromNotebook`（NotebookStatus セルからの逆引き → `NBFindCellByPredicate`）、`SourceVault` の TodoItem TaggingRules（`NotebookImport` → `NBFileLoadSlim` で読み込み済みの式から取り出す） |
| 表示のために開くだけ（waiver） | 8 | 保存済みサマリーノート（SourceVault・eagle・todo）、元ノート（workflowcatalog）、前面に出す（papernb）、イシューノート（issues）、SlideWorkflow の計算ノート・版の複製 |
| ツールが処理対象のノート自身を読む（waiver） | 7 | SlideWorkflow のデッキ読み（`NotebookGet` 6・非表示の `NotebookOpen` 1。うち 1 件は開いているデッキを新しい窓へ複製するだけ） |
| その他の正当な読み（waiver） | 2 | 同梱テンプレートを雛形として読む（SourceVault）、ノート内のシンボル名を手元で調べて直す（diagnostics） |
| 読む前に機密度を確かめる（修正 + waiver） | 1 | ResoniteRealtime_tablet の `.nb` ビューア |

NBAccess に足りない API は無かった。ただし「開いている NotebookObject の式を PrivacyLevel つきで返す」API は無いので、SlideWorkflow は送信側で判定する形にした。

### 仕分けの途中で見つけて直したもの

- **SlideWorkflow の LLM 送信が Private 宣言を見ていなかった。** `iSWRefinePrivacy` はデッキの指示・KG ノード・関連研究の PrivacyLevel の最大だけで決めていて、Private 宣言（CloudPublishable -> False）のデッキでも指示が無ければ 0.0 でクラウドに送られうる状態だった（YouTube の送信は宣言を見ていた）。`NBAccess`NBNotebookRequiredAccessLevel[nb]` を最大の候補に加えた。NBAccess が読み込まれていない環境（headless テスト）では従来どおりで、NBAccess の呼び出しが失敗したら 1.0。
- **Resonite のタブレットで `.nb` をパスで渡すと機密度 0.0 扱いだった。** `sv://` オブジェクトは表示上限で止めていたが、ファイルパスで渡した `.nb` は公開ワールドにも出ていた。読む前に `NBAccess`NBFileSpec` の PrivacyLevel の最大（Public 宣言 0.4、Private 1.0、未宣言は機密セルが無ければ 0.5・あれば 1.0。`$packageDirectory` / `$ClaudeAccessibleDirs` の中の未宣言は 0.5）を表示上限と比べ、超えたら読まずに断る。断るメッセージにファイル名は出さない。結果として、未宣言のノートはオーナーの Private ワールド（上限 1.0）にだけ出せ、Contacts（上限 0.5）・公開ワールドには出ない。Public 宣言のノートも公開ワールド（上限 0.25）には出ない。（r6 で訂正: r5 では「未宣言は置き場所で 0.5 か 1.0」と書いたが、置き場所で決まるのは .nb 以外のファイル）

### 確認

| テスト | 結果 |
|---|---|
| `test codes/NBAccess_policylint_phase4_test.wl`（新規） | PASS（PRIV-NB-READ が Error、18 か所すべてに理由付き waiver、置き換えた 3 関数、Todo TaggingRules が旧 NotebookImport 版と同じ結果、SlideWorkflow の Private 宣言、Resonite の判定） |
| NBAccess_policylint / ClaudePackageManager_separationview / github_policylint_commit | すべて PASS |
| SourceVault_issues_test | 301 PASS・0 FAIL（UTF-8 で Get した場合。`wolframscript -file` ではテスト中の日本語が化けて 14 件落ちる） |
| SourceVault_mailagenda_test | 87 PASS・5 FAIL。5 件は編集前のファイルでも同じに落ちる（表示の PL バッジと AgendaData）。逆引きの項目は前後とも PASS |
| ResoniteRealtime_tablet_test（`wolfram.exe -noinit -script`） | 編集前 221 PASS・57 FAIL、編集後 222 PASS・56 FAIL（同じ一時フォルダで比較）。編集後にだけ落ちる項目は無い |
| slidegraph_test（`-noinit`） | 303 PASS・3 FAIL。T1a は版番号の期待値が 1.62 のまま（パッケージは編集前から 1.64）、T28d は既知の環境依存、T41e は mp4 のメッセージで今回触っていない箇所。編集前の版との比較はしていない |

全 147 ファイルの再集計（124 秒）: 解析失敗 0、waiver の無い検出は Error 512・Review 139（Phase 2 の Review 160 から PRIV-NB-READ の 21 件が抜けた）、waiver 18（すべて PRIV-NB-READ）。

### 残したこと

- rules/10 の「`NotebookOpen[]` 直接使用 — `NBFileOpen` を使う」は文面のまま。表示のために開くだけの箇所は waiver で扱った（§4.6 の例「ユーザー操作で開く」）。rules/10 に注記するかは利用者が決める。
- ~~SlideWorkflow の音声読み上げ（realtime）へ発表の文脈を渡す経路が、渡した先で PrivacyLevel を見ているか~~ → 見ていなかった。§16 で修正。
- ~~Resonite で PDF・画像をパスで渡したときも機密度 0.0 扱い~~ → §16 で修正。
- `ClaudeFixSeparation` の廃止、変更したパッケージの api.md 再生成と GitHub への反映。

---

## 16. 送信経路の追加修正（2026-10-31、r6）

§15 で「確かめていない」とした 2 つの経路を調べ、どちらも機密度を見ずに外へ出していたので直した。編集前のファイルは `bak/<名前> - 20261031 pre-egress.wl`。

### cloud の音声（OpenAI realtime）

- **見つけたこと**: SlideWorkflow が cloud の声（`realtime:`）を使うと、読み上げ原稿・発表の文脈・題名入りの指示文・動画用の音声の原稿が OpenAI に送られる。受け取る `SourceVault_realtime.wl` は開始時に「ノートの有料 API 許可」と「OpenAI にレベル 0.5 まで送ってよいかの全体方針」しか見ておらず、Private 宣言のデッキでも、PrivacyLevel 0.5 以上を指定したデッキでも送っていた。質問への回答（TalkQA）は発表モードで公開分だけに絞る判定が別にあり、こちらは問題ない。
- **SourceVault 側（受け取る側）**: `SourceVaultRealtimeStart` と `SourceVaultRealtimeRender` は、`"Notebook"` のノートが Private 宣言（`NBNotebookRequiredAccessLevel` が 1.0）なら始めない（`Failure["SourceVaultRealtimePrivateNotebook"]`）。有料 API の許可と同じく、このノートを単位に判断する。NBAccess が答えられないときも始めない。Private 宣言のノートから一般の音声会話を始める場合も断られる。
- **SlideWorkflow 側**: デッキの機密度を `iSWDeckPrivacy`（指示の PrivacyLevel と Private 宣言の最大）として切り出し、LLM（`iSWRefinePrivacy`）と cloud の声（`iSWCloudVoiceRefusal`）で共用する。0.5 以上なら cloud の声は使わず、ローカルの声（AivisSpeech）を選ぶよう案内する（`Failure["SlideCloudVoicePrivate"]`）。判定を置いたのは、デッキを cloud の声に渡す 5 か所: 音声応答の開始（`SlideToggleRealtime`）、再生時の音声接続（`iSWEnsureRealtimeBridge`。Live 録音もここを通る）、プレビュー読み上げ（他のデッキで動いている会話をそのまま使うので、開始時の判定とは別に要る）、動画の音声作成、ポスター音声の作成。

### Resonite へパスで渡したファイル

- **見つけたこと**: `ResoniteShowObject` にファイルパスを渡すと機密度 0.0 扱いで、どのワールドにも出た。PDF は「機密度 0.5 以下ならフレンド用の外部サーバへ sftp で写しを置く」仕組みがあり、パスで渡した PDF はディスク上のどれでも写しの対象だった。`ResoniteViewerShow` / `ResonitePDFViewer` にページ仕様 `{"PDF", file, n}` / `{"File", path}` で直に渡す経路も判定が無かった。これらはワールド内の LLM が承認なしで呼べる。
- **修正**: パスで渡したファイルは `NBAccess`NBFileSpec` の機密度の最大（`itFilePL`）で扱い、`sv://` オブジェクトと同じ表示上限（`itGate`）で判定する。.nb 以外は置き場所で決まり（`$packageDirectory` / `$ClaudeAccessibleDirs` の中は 0.5、外は 1.0）、.nb は宣言（Public 0.4 / Private 1.0、未宣言は機密セルが無ければ 0.5）。PDF の写しを置くかもこの値で決まる。ページ仕様で直に渡されたファイルは `itPageSpecFailure` で判定し、機密度を判定済みの内部経路（`sv://` オブジェクト、パス指定の入口）は `$itFilesCleared` を立てて呼ぶ。断るメッセージにファイル名は出さない。
- **影響**: アクセス可能フォルダの外のファイル（.nb 以外）は、どのワールドにも出せなくなった（表示上限は「未満」で比べるので、オーナーの Private ワールドの上限 1.0 でも機密度 1.0 は出ない）。フォルダの中のファイルは、オーナーの Private ワールドにだけ出せる。`sv://` オブジェクトとして渡すものは従来どおりオブジェクトの機密度で判定する。

### 確認

| テスト | 結果 |
|---|---|
| `test codes/NBAccess_policylint_phase4_test.wl`（追加 10 項目） | 全 PASS。パスで渡した PNG が公開ワールドで 4 つの入口とも断られる、判定済みの内部経路は断られない、cloud の声の判定（Private 宣言・指示 0.7 は断る、0.3 は通す）、音声接続は会話の状態を見る前に断る、5 か所すべてに判定がある、SourceVault 側の開始と音声作成に判定がある |
| ResoniteRealtime_tablet_test | テストに `NBAccess`NBFileSpec` のスタブを足した（テスト用ファイルは 0.0、名前に secret を含むものは 1.0）。スタブが無いと機密度不明 = 1.0 でパス指定の約 30 項目が断られる。足した後は 223 PASS・57 FAIL で、新しい 2 項目（secret は 3 つの入口とも断る、断るメッセージにファイル名を出さない）は PASS。§15 の時点から増えた FAIL は、ワールド情報の読み取りを待つ 2 項目が実行ごとに交互に落ちるもので、変更とは関係しない |
| SourceVault_realtime_audiocheck_test | 16 PASS・0 FAIL |
| slidegraph_test（`-noinit`） | 303 PASS・3 FAIL。§15 の時点と同じ 3 項目 |
| slideanswering_test / slidetalkvideo_test（`-noinit`） | 22 PASS・1 FAIL / 46 PASS・1 FAIL。FAIL はどちらも T1a（テストが期待する版番号が 1.53 / 1.59 のまま。パッケージは変更前から 1.64）。音声応答・動画の項目はすべて PASS |
