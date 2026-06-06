# ClaudeEval / ClaudeRuntime / ClaudeOrchestrator / NBAccess 強制境界・非同期互換 最終実装仕様 (v3)

作成日: 2026-06-03 (v3 改訂: 2026-06-03)  
対象: `NBAccess.wl`, `claudecode.wl`, `ClaudeRuntime.wl`, `ClaudeOrchestrator.wl`, `SourceVault_promptrouter.wl`, Claude Directives  
位置づけ: v1〜v6、Phase A0追補、Unknown head / C-lite安全分類、`$ClaudePermissionMode`、承認action registry整合を統合した単独参照用の最終仕様に、実装で判明した重要な変更を反映した v3。

---

## v3 改訂サマリ (実装で判明した初期仕様からの変更)

実装・実機検証の結果、初期仕様 (v2) から以下の重要な変更を施した。本仕様書は
これらを反映済みである。各変更は該当章にも反映し、ここでは一覧として示す。

1. **`Evaluate` を無条件 deny しない (I6 / 5.2 を改訂)** —
   初期仕様は「`Evaluate` を `$NBDenyHeads` に維持」だったが、これは
   `ParametricPlot[Evaluate[..]]` 等の描画の定石を巻き込んで全 deny し、
   「式と図で説明」のような通常依頼で何も表示できなくなる過剰禁止だった。
   `Evaluate` を DenyHeads から除去した。**中身の危険 head は
   `iExtractAllHeads` が `{1, Infinity}` で別途捕捉し deny する**ため、
   `Evaluate` 自体を deny する必要はない (安全性は中身の head で担保)。
   → §I6, §5.2, §5A.5 に反映。

2. **スコープ局所変数を unknown head から除外 (5A.6 を改訂)** —
   `Module[{traj}, traj[x_]:=..]` の `traj` は held のままでは `Global`` 文脈
   head に見え、unknown → NeedsApproval になっていた。LLM が説明用に補助関数を
   定義するのはごく普通であり、これを全て承認要求にすると計算がほぼ全滅する。
   `Module`/`Block`/`With`/`Function`/`DynamicModule`/`Manipulate` の束縛変数、
   `SetDelayed`/`Set` の定義関数名、パターン変数を unknown から除外する
   (`iNBExtractScopedSymbols`)。中身の危険 head は依然 deny される。
   → §5A.6 に反映。

3. **head フィルタは base 判定層と mode 変換層の両方に必要 (5A.9 を補強)** —
   `NBValidateHeldExpr` は「base 判定 (`iNBValidateHeldExprBase`)」と
   「mode 変換層 (EffectClass 集約)」の2層構造。base が Permit でも、mode 変換層
   が別途全 head を取って EffectClass を集約するため、そこにローカル変数が
   混入すると eligibility が AskUserAllowed に昇格し NeedsApproval になる
   (ReasonClass=None の NeedsApproval が目印)。**スコープ局所変数の除外は
   両層に入れる必要がある**。→ §5A.9 に反映。

4. **出力モード (逐次/バッチ) の新設 (§5C を新設)** —
   FrontEnd/カーネルブロック回避を最優先しつつ、ブロックしないなら逐次出力
   (計算状況が見える)、非同期並列の多数処理ではバッチ集約、を選択可能にする
   `$ClaudeOutputMode` / `NBResolveOutputMode` / 出力遅延バッファ
   (`NBBeginDeferredOutput` 等) を新設。`ClaudeEval` / `ClaudeRunOrchestration`
   に `OutputMode` オプションを追加。→ §5C を新設。

5. **非 desktop final action の実行経路 (5B.8 を拡張)** —
   action registry に `WriteNotebookCell` を追加し、notebook 出力系の
   final action を `NBExecuteApprovedAction` 経由で実行可能にした。
   → §5B.8 に反映。

6. **Deny は実行ボタンを出さない (5A.9 / Phase 25b の DenyOverride 廃止)** —
   旧 DenyOverride (Deny を承認待ちに遷移させ実行ボタンを出す) を廃止し、
   Deny は即 Failed + 拒否理由表示に変更済み (本セッション前に完了)。

7. **今後の課題: 非同期版の出力集約 (§22 を新設)** —
   `ClaudeRunOrchestrationAsync` / `RepeatInterval` / 連鎖呼び出しは
   scheduled task 内実行で罠 #30 の壁にぶつかり、出力集約が未配線。
   関連事項を §22 に整理。

---

## 0. 目的

本仕様は、`ClaudeEval` 系実行基盤を次の最終構成へ移行するための実装仕様である。

```text
NBAccess
  = Notebook / Wolfram Kernel / File / External Side Effect への最終強制境界

claudecode.wl
  = 後方互換APIおよびLegacyStandalone実行器
  = ClaudeRuntime / ClaudeOrchestratorロード後は旧実行経路を閉鎖

ClaudeRuntime
  = 単一LLM呼び出しの正式実行層

ClaudeOrchestrator
  = 複数stepワークフローの正式制御層
  = 各stepの実行はClaudeRuntime/NBAccess経由

SourceVault / Claude Directives
  = prompt, evidence, safety rule, async rule, route policy の周辺基盤
```

最終目標は次である。

> エージェント由来のWolfram式、Notebook書き換え、ファイル操作、外部副作用は、どの実行経路から来ても必ずNBAccessを通る。  
> ただし、Mathematica frontendをブロックしないために苦労して構築された既存の非同期基盤、特に `StartProcess + polling tick` および提案式本体実行に使われている `ParallelSubmit` 経路は棄損しない。

---

## 1. 背景と現状認識

### 1.1 ClaudeEvalの3実行形態

現状、`ClaudeEval` には実質的に次の3経路がある。

```text
1. claudecode.wl 単独実行
2. ClaudeRuntime による単一LLM呼び出し
3. ClaudeOrchestrator によるワークフロー実行
```

将来方針は次である。

```text
claudecode.wl
  = legacy compatibility layer

ClaudeRuntime
  = official single-call execution layer

ClaudeOrchestrator
  = official workflow execution layer
```

ただし、既存ユーザーには

```wl
Get["NBAccess.wl"];
Get["claudecode.wl"];
ClaudeEval[...]
```

だけで運用しているNotebookがある。  
この互換性は壊してはならない。

### 1.2 LegacyStandalone互換

`NBAccess + claudecode.wl` のみをロードした環境では、`ClaudeEval` は従来通り動く必要がある。

ただし、内部的には次の形へ移行する。

```text
ClaudeEval
  -> claudecode legacy path
    -> NBAccess enforced execution
      -> ReleaseHold
```

旧来の

```text
claudecode legacy path
  -> direct ReleaseHold
```

は廃止する。

### 1.3 Runtime / Orchestratorロード後の旧経路閉鎖

`ClaudeRuntime` または `ClaudeOrchestrator` がロードされた時点で、`claudecode.wl` の旧実行経路は閉じる。

```text
ClaudeRuntime loaded:
  ClaudeEval -> ClaudeRuntimeEvaluate
  claudecode raw legacy execution -> disabled

ClaudeOrchestrator loaded:
  workflow execution -> ClaudeOrchestrator
  per-step execution -> ClaudeRuntime
  claudecode raw legacy execution -> disabled
```

ロード順に依存してはならない。

---

## 2. 基本アーキテクチャ

### 2.1 単一LLM呼び出し

```text
User / Notebook
  -> ClaudeEval
    -> claudecode dispatcher
      -> ClaudeRuntimeEvaluate
        -> prompt materialization
        -> route decision
        -> LLM call
        -> output parse
        -> NBAccess request
          -> NBExecuteHeldExpr / NBExecuteHeldExprSubkernelRaw
            -> ReleaseHold
```

### 2.2 ワークフロー実行

```text
User / Notebook
  -> ClaudeOrchestratorRun
    -> workflow plan / step scope / checkpoint / snapshot
      -> ClaudeRuntimeEvaluate per step
        -> NBAccess request
          -> NBExecuteHeldExpr / NBExecuteHeldExprSubkernelRaw
            -> ReleaseHold
```

### 2.3 最終許可の合成規則

RuntimeやOrchestratorはNBAccessの許可を広げてはならない。  
できるのは、文脈を追加し、許可範囲を狭めることだけである。

```text
final permission
  = NBAccess base policy
    ∩ Runtime call scope
    ∩ Orchestrator workflow scope
    ∩ Orchestrator step scope
```

---

## 3. 不変条件

### I1. エージェント由来式の唯一の評価境界

エージェント由来の `HoldComplete[...]` を評価する経路は、必ずNBAccessを通る。

許可される評価点:

```text
NBAccess`NBExecuteHeldExpr[...]              main kernel, Association result
NBAccess`NBExecuteHeldExprSubkernelRaw[...]  subkernel, raw-compatible result
```

禁止される経路:

```wl
ReleaseHold[heldExpr]

ParallelSubmit[ReleaseHold[heldExpr]]

ParallelSubmit[
  TimeConstrained[ReleaseHold[heldExpr], ...]
]
```

### I2. `ReleaseHold` はNBAccess内部に閉じる

P0完了時点で、エージェント由来式の評価に関する `ReleaseHold` はNBAccess内部にのみ存在する。

許容される例外:

| 分類 | 内容 |
|---|---|
| B | NBAccess内部の正式実行点 |
| C | `Cell[...]` / `BoxData[...]` 等の構造復元で評価を伴わないunwrapping |
| D | テストfixture |

例外は `releasehold_inventory.md` に明示し、未分類 `ReleaseHold` はCI失敗にする。

### I3. P0ではfuture result shapeを変えない

現行Runtimeはfutureの結果を生値として扱う。  
P0ではこれを維持する。

```text
subkernel future result:
  success -> raw value
  timeout -> $TimedOut
  failure -> $Failed
```

`NBExecuteHeldExprSubkernelRaw` はAssociationを返さない。

### I4. redactionはmain側を正とする

P0ではredactionは現行通りmain側で行う。

```text
RedactResult
NBRedactExecutionResult
adapter-specific result finalization
```

RawResultがsubkernelからmainへ渡るため、subkernelへ送れる式は `NBSubkernelExecutableQ` で厳格に限定する。

### I5. snapshot modeではカテゴリ定義系globalを参照しない

snapshot modeの `NBValidateHeldExpr` は、snapshotに含まれる導出済みhead listだけを判定入力にする。

snapshot mode中に参照禁止:

```wl
$NBAllowedHeadsByCategory
$NBDisabledCategories
NBCategoryEnabled
iRecomputeAllowedHeads[]

$NBAllowedHeads
$NBApprovalHeads
$NBDenyHeads
$NBConfidentialSymbols
```

理由:

`iRecomputeAllowedHeads[]` 自体は軽い処理だが、`$NBAllowedHeadsByCategory` と `$NBDisabledCategories` の状態がsubkernelでmain kernelと一致する保証がない。  
subkernelで再計算すると、mainで発行したsnapshotと異なるpolicyで判定してしまう。

### I6. `Evaluate` は常にdeny

現行 `$NBDenyHeads` に `"Evaluate"` があるため、これは維持する。

```wl
HoldComplete[Evaluate[expr]]
```

はmain/subkernelとも拒否される。

> **【v3 改訂】この不変条件 I6 は撤廃した。**
> `Evaluate` を無条件 deny すると `ParametricPlot[Evaluate[..]]`、
> `Plot[Evaluate[Table[..]]]` 等の描画の定石を巻き込んで全 deny し、
> 「放物運動を式と図で説明」のような通常依頼で図が一切出ない過剰禁止に
> なっていた。`Evaluate` を `$NBDenyHeads` から除去した。
> **安全性の担保**: `Evaluate` の中身の危険 head (`DeleteFile`, `SystemOpen`
> 等) は `iExtractAllHeads[held]` が `{1, Infinity}` で全階層から抽出して
> deny するため、`Evaluate` 自体を deny する必要はない。
> `Evaluate[DeleteFile[..]]` は中身の `DeleteFile` で依然 deny される
> (回帰テスト EDT-4/5 で確認済み)。subkernel 禁止リスト
> `$iNBSubkernelForbiddenHeads` の `Evaluate` は維持 (描画は結局メイン
> カーネルで一瞬実行されるため問題なし)。詳細は §5.2 / §5A.5。

### I7. `NotebookWrite` はP0で明示的にapproval headへ昇格する

現行コードでは素の `NotebookWrite` は `$NBApprovalHeads`, `$NBDenyHeads`, `$NBAllowedHeads` のいずれにも含まれていない。  
そのため未知headとして `RepairNeeded` になり得る。

P0では、`NotebookWrite` を `$NBApprovalHeads` の初期定義に直接追加する。  
これにより、`NotebookWrite` は `RepairNeeded` ではなく `NeedsApproval` になる。

これは自動実行許可ではない。  
`NBExecuteHeldExpr` は既定では `NeedsApproval` を実行しない。


### I8. 未知headは原則 `RepairNeeded` ではなく安全分類へ送る

`RepairNeeded` は、構文・構造・形式が壊れており、LLMまたは修復器に式を直させるべき場合に限定する。

構文上妥当なheadがallow listに無いだけの場合は、原則として次のいずれかへ分類する。

```text
System` builtin unknown, pure-ish
  -> Permit or NeedsApproval, ExecutionPlacementを付与

System` builtin unknown, side-effect-ish
  -> NeedsApproval or Deny

Global` / user context / package context unknown
  -> NeedsApproval

malformed / unsafe structure / unresolved symbolic wrapper
  -> RepairNeeded
```

したがって、`Integrate`, `Exp`, `Solve`, `Simplify` などの通常の数学・記号処理headを、単にunknownであるという理由だけで `RepairNeeded` にしてはならない。

### I9. `AllowedHeads` は「唯一の許可集合」ではなく「無承認Permit高速パス」とする

`AllowedHeads` は、無承認で即時 `Permit` してよい既知安全head集合である。  
しかし、`AllowedHeads` に含まれないことは、ただちに拒否を意味しない。

最終判定は次の優先順にする。

```text
1. DenyHeads
   -> Deny

2. ApprovalHeads
   -> NeedsApproval

3. AllowedHeads
   -> Permit

4. System` unknown heads
   -> C-lite structural classification

5. User/package unknown heads
   -> NeedsApproval

6. malformed / unsupported structures
   -> RepairNeeded
```

### I10. 安全性判定と実行配置判定を分離する

`Decision` と `ExecutionPlacement` は別軸とする。

```text
Decision:
  Permit / NeedsApproval / Deny / RepairNeeded

ExecutionPlacement:
  SubkernelSafe / MainKernelOnly / FrontEndRequired /
  ExternalProcess / FileSystem / Network / DesktopAction
```

副作用が無いが長時間走る計算は、`Decision -> Permit` でも `BlockingRisk -> PossiblyLong` を持ち得る。  
FrontEnd操作やdesktop actionは、`Decision -> NeedsApproval` かつ `RequiresFinalNode -> True` にする。

### I11. 自動ワークフローではFrontEnd/副作用/ブロックリスクをfinal nodeへ分離する

Orchestratorは、可能な限り次の分離を行う。

```text
safe computation node:
  SubkernelSafe
  no FrontEnd
  no side effect
  async可
  timeoutあり

preparation / validation node:
  read-only filesystem or pure transformation

final action node:
  FrontEndRequired / DesktopAction / FileSystemWrite / ExternalProcess
  NeedsApproval
  自動実行しない、または明示承認後のみ実行
```

`ClaudeEval["init.mの入っているフォルダを開いて"]` のような要求では、path計算・存在確認と、実際にフォルダを開くdesktop actionを分ける。  
desktop actionはfinal nodeへ集約する。

---


### I12. PermissionModeはaccessSpec/snapshotで固定し、実行中にglobalを読み直さない

`$ClaudePermissionMode` はユーザーレベル設定であるが、実行中の判定ではglobalを直接読み直してはならない。

必須規則:

```text
main kernelでaccessSpec作成時:
  PermissionMode -> current $ClaudePermissionMode

snapshot / subkernel実行時:
  accessSpec["PermissionMode"] を正とする
  global $ClaudePermissionMode を再参照しない

NBValidateHeldExpr:
  mode変換は accessSpec["PermissionMode"] に基づく
```

理由:

- main kernelが `"InteractiveSafe"` で作成した実行要求を、subkernelが別modeで再判定する不整合を防ぐ。
- snapshot modeの「判定入力を固定する」という原則と整合させる。
- Orchestrator workflow再開時に、途中でglobal modeが変わっても、既存stepの判定を再現可能にする。

`$ClaudePermissionMode` を変更した場合は、新しいaccessSpec/snapshotから有効になる。

## 4. NBAccess P0 API仕様

### 4.1 `NBPolicySnapshot[]`

main kernelで現在のNBAccess動的状態を固定する。

```wl
NBPolicySnapshot[] -> Association
```

P0必須キー:

```wl
<|
  "SnapshotID" -> _String,
  "CreatedAt" -> DateObject[] | _Real,
  "NBAccessPolicyVersion" -> _String | _Integer | None,
  "PermissionMode" -> _String,
  "AllowedHeads" -> _List,
  "ApprovalHeads" -> _List,
  "DenyHeads" -> _List,
  "ConfidentialSymbols" -> _List | _Association,
  "Digest" -> _String,
  "Source" -> "CurrentGlobals"
|>
```

P0では次を必須キーにしない。

```wl
"DenyPatterns"
"ApprovalPatterns"
"AllowedHeadsByCategory"
"DisabledCategories"
```

理由:

- `DenyPatterns` / `ApprovalPatterns` は現行実装に対応globalがない。
- `AllowedHeadsByCategory` / `DisabledCategories` はsnapshot modeで参照しない。
- snapshot modeでは導出済み `AllowedHeads` を正とする。

snapshot作成手順:

1. main kernelで一度だけ `iRecomputeAllowedHeads[]` を呼び、導出済み `$NBAllowedHeads` を最新化する。
2. `AllowedHeads`, `ApprovalHeads`, `DenyHeads`, `ConfidentialSymbols`, `PermissionMode` を取得する。`PermissionMode` はaccessSpec作成時の `$ClaudePermissionMode` を固定した値である。
3. digest用payloadを正規化する。
4. `iNBComputePolicyDigest[payload]` でdigestを作る。
5. snapshot Associationを返す。

`$NBAccessPolicyVersion` が未定義なら `None` または `"unversioned"` を入れる。

### 4.2 snapshot digest helper

生成側と検証側は必ず同じ内部ヘルパーを使う。

```wl
iNBNormalizePolicySnapshotPayload[snapshotOrPayload_Association] -> Association
iNBComputePolicyDigest[snapshotOrPayload_Association] -> _String
```

digest対象キー:

```wl
{
  "NBAccessPolicyVersion",
  "PermissionMode",
  "AllowedHeads",
  "ApprovalHeads",
  "DenyHeads",
  "ConfidentialSymbols"
}
```

正規化規則:

```wl
iNBNormalizeHeadList[list_] :=
  Sort @ DeleteDuplicates @ ToString /@ Replace[list, Except[_List] -> {}];

iNBNormalizeConfidentialSymbols[conf_Association] :=
  SortBy[
    Normal[conf] /. Rule[k_, v_] :> {ToString[k], ToString[v, InputForm]},
    First
  ];

iNBNormalizeConfidentialSymbols[conf_List] :=
  Sort @ DeleteDuplicates @ ToString /@ conf;

iNBNormalizeConfidentialSymbols[_] := {};

iNBNormalizePolicySnapshotPayload[snapshotOrPayload_Association] :=
  KeySort @ <|
    "NBAccessPolicyVersion" ->
      ToString[Lookup[snapshotOrPayload, "NBAccessPolicyVersion", "unversioned"]],
    "PermissionMode" ->
      ToString[Lookup[snapshotOrPayload, "PermissionMode", Lookup[snapshotOrPayload, "ClaudePermissionMode", "InteractiveSafe"]]],
    "AllowedHeads" ->
      iNBNormalizeHeadList[Lookup[snapshotOrPayload, "AllowedHeads", {}]],
    "ApprovalHeads" ->
      iNBNormalizeHeadList[Lookup[snapshotOrPayload, "ApprovalHeads", {}]],
    "DenyHeads" ->
      iNBNormalizeHeadList[Lookup[snapshotOrPayload, "DenyHeads", {}]],
    "ConfidentialSymbols" ->
      iNBNormalizeConfidentialSymbols[
        Lookup[snapshotOrPayload, "ConfidentialSymbols", {}]]
  |>;
```

digest計算:

```wl
iNBComputePolicyDigest[snapshotOrPayload_Association] :=
  IntegerString[
    Hash[
      ToString[
        InputForm[iNBNormalizePolicySnapshotPayload[snapshotOrPayload]]
      ],
      "SHA256"
    ],
    16
  ];
```

`ExportString[..., "WL"]` を使ってもよいが、標準は `InputForm` 文字列化とする。  
digest前に `KeySort` は必須である。

受け入れ条件:

```wl
p1 = <|
  "AllowedHeads" -> {"Plus", "Times"},
  "ApprovalHeads" -> {"NotebookWrite"},
  "DenyHeads" -> {"Evaluate"},
  "ConfidentialSymbols" -> {"secretX"},
  "NBAccessPolicyVersion" -> "unversioned"
|>;

p2 = <|
  "DenyHeads" -> {"Evaluate"},
  "ConfidentialSymbols" -> {"secretX"},
  "ApprovalHeads" -> {"NotebookWrite"},
  "NBAccessPolicyVersion" -> "unversioned",
  "AllowedHeads" -> {"Times", "Plus"}
|>;

iNBComputePolicyDigest[p1] === iNBComputePolicyDigest[p2]
```

### 4.3 `NBAcceptPolicySnapshot[snapshot]`

subkernel側でsnapshotを検証し、snapshot-aware validationで利用可能にする。

```wl
NBAcceptPolicySnapshot[snapshot_Association] -> Association
```

返り値:

```wl
<|
  "Valid" -> True | False,
  "Digest" -> _String | None,
  "Reason" -> _String | None
|>
```

必須挙動:

1. P0必須キーが揃っていることを確認する。
2. `iNBComputePolicyDigest[snapshot]` を呼び、`snapshot["Digest"]` と一致確認する。
3. 一致した場合、必要ならsubkernel内 `$NBActivePolicySnapshot` に保存してよい。
4. ただし、実行判定の正本は実行ごとの `accessSpec["PolicySnapshot"]` とする。
5. snapshot installは許可拡張に使ってはならない。

### 4.4 `NBValidateHeldExpr` のsnapshot-aware化

追加Options:

```wl
"PolicySnapshot" -> Automatic
"RecomputeAllowedHeads" -> Automatic
```

判定規則:

```wl
snapshot = Replace[OptionValue["PolicySnapshot"],
  Automatic -> Lookup[accessSpec, "PolicySnapshot", None]];

If[AssociationQ[snapshot],
  (* snapshot mode *)
  If[! TrueQ[NBAcceptPolicySnapshot[snapshot]["Valid"]],
    Return[<|
      "Decision" -> "Deny",
      "ReasonClass" -> "InvalidPolicySnapshot"
    |>]
  ];

  allowed  = snapshot["AllowedHeads"];
  approval = snapshot["ApprovalHeads"];
  deny     = snapshot["DenyHeads"];
  conf     = snapshot["ConfidentialSymbols"];

  validationAccessSpec =
    Join[accessSpec, <|"ConfidentialSymbols" -> conf|>];

  (* snapshot modeでは以下を呼ばない・見ない:
     iRecomputeAllowedHeads[],
     NBCategoryEnabled,
     $NBAllowedHeadsByCategory,
     $NBDisabledCategories,
     $NBAllowedHeads,
     $NBApprovalHeads,
     $NBDenyHeads,
     $NBConfidentialSymbols
  *);
,
  (* current/global mode *)
  If[TrueQ[OptionValue["RecomputeAllowedHeads"]] ||
     OptionValue["RecomputeAllowedHeads"] === Automatic,
    iRecomputeAllowedHeads[]
  ];

  allowed  = Replace[OptionValue["AllowedHeads"],  Automatic -> $NBAllowedHeads];
  approval = Replace[OptionValue["ApprovalHeads"], Automatic -> $NBApprovalHeads];
  deny     = Replace[OptionValue["DenyHeads"],     Automatic -> $NBDenyHeads];
  conf     = Lookup[accessSpec, "ConfidentialSymbols", $NBConfidentialSymbols];

  validationAccessSpec =
    Join[accessSpec, <|"ConfidentialSymbols" -> conf|>];
]
```

必須修正:

- `iContainsConfidentialLeak` は既存の2引数シグネチャを維持する。
- snapshot modeでは `validationAccessSpec["ConfidentialSymbols"]` にsnapshot由来値を必ず入れる。
- これにより、`iContainsConfidentialLeak[heldExpr, validationAccessSpec]` 内部で `$NBConfidentialSymbols` へフォールバックしないようにする。
- snapshot mode中にhelperがカテゴリAPIを呼ばないようにする。
- snapshot不正時は `Decision -> "Deny"`, `ReasonClass -> "InvalidPolicySnapshot"`。

### 4.5 `iContainsConfidentialLeak`

シグネチャは変更しない。

```wl
iContainsConfidentialLeak[heldExpr_, accessSpec_Association]
```

**実装上の注意:** 本節はAPI外形と呼び出し契約を定義する。内部実装では、Phase A0追補の **A0-1. `iContainsConfidentialLeak` の Association/ListQ 不整合をPhase Bで修正する** に従い、`ConfidentialSymbols` がAssociationの場合はvaluesではなくkeysを照合名として扱うこと。

snapshot modeでは、`NBValidateHeldExpr` 側で次を保証する。

```wl
KeyExistsQ[validationAccessSpec, "ConfidentialSymbols"] === True
```

禁止事項:

- snapshot mode中に `$NBConfidentialSymbols` の直接参照へフォールバックしてはならない。
- そのため、snapshot modeでは必ず `ConfidentialSymbols` をaccessSpecに注入してから呼ぶ。

### 4.6 `NBMakeRuntimeAccessSpec[contextPacket, role]`

Runtime/OrchestratorからNBAccessへ渡すaccessSpecを作る。

```wl
NBMakeRuntimeAccessSpec[contextPacket_Association, role_String:"ProposalEval"]
```

必須キー:

```wl
<|
  "ExecutionRole" -> "ProposalEval" | "Committer" | "VisionFallback" | "ManualDispatch",
  "ExecutionKernel" -> "Main" | "SubkernelAllowed" | "MainOnly",
  "PermissionMode" -> _String,
  "ModeSnapshot" -> <|"ClaudePermissionMode" -> _String|> | None,
  "MayUseFrontEnd" -> True | False,
  "MayWriteNotebook" -> True | False,
  "MayUseExternalProcess" -> True | False,
  "MayAccessFileSystem" -> True | False | "ReadOnly",
  "MayUseNetwork" -> True | False,
  "ResultMayCrossKernel" -> True | False,
  "ConfidentialSymbols" -> _List | _Association,
  "Secrets" -> _List,
  "AllowedNotebookActions" -> _List,
  "PolicySnapshot" -> NBPolicySnapshot[],
  "Caller" -> _String,
  "WorkflowID" -> _String | None,
  "StepID" -> _String | None
|>
```

role既定値:

| Role | Kernel | FE | Notebook write | ResultMayCrossKernel | AllowedNotebookActions |
|---|---:|---:|---:|---:|---|
| `ProposalEval` | `SubkernelAllowed` | False | False | 条件付きTrue | `{}` |
| `Committer` | `MainOnly` | True | True | False | `{ "MoveSelectionAfterNotebook" }` |
| `VisionFallback` | `MainOnly` | False | False | False | `{}` |
| `ManualDispatch` | 原則MainOnly | False | False | False | `{}` |

### 4.7 `NBSubkernelExecutableQ[held, accessSpec]`

`iShouldExecuteAsync` の正式な判定本体。  
旧 `iCodeRefsConfidential`, `iCodeRefsLocalContext`, `iCodeRefsForbiddenOrApprovalHead` は内部ヘルパーへ格下げする。

```wl
NBSubkernelExecutableQ[held_HoldComplete, accessSpec_Association] -> True | False
```

False条件:

- `accessSpec["ExecutionRole"] =!= "ProposalEval"`
- `accessSpec["ExecutionKernel"] =!= "SubkernelAllowed"`
- `accessSpec["MayUseFrontEnd"] === True`
- `accessSpec["MayWriteNotebook"] === True`
- `accessSpec["MayUseExternalProcess"] === True`
- `accessSpec["MayUseNetwork"] === True`
- `accessSpec["ResultMayCrossKernel"] =!= True`
- `accessSpec["PolicySnapshot"]` が無効
- `ConfidentialSymbols` / `Secrets` / private source refsを参照する
- local context依存を参照する
- snapshot内 `DenyHeads` または `ApprovalHeads` に該当するheadを含む
- `Evaluate` を含む
- `NotebookWrite`, `SelectionMove`, `CellPrint`, `FrontEndExecute`, `RunProcess`, `StartProcess`, `ExternalEvaluate`, `Import`, `Export`, `URLRead`, `URLExecute` 等の副作用候補を含む

`$ClaudeRuntimeAsyncForce = True` の扱い:

- `NBSubkernelExecutableQ` がFalseの場合、Forceは無視する。
- Forceは性能heuristicだけを上書きできる。
- ForceはNBAccessの安全判定を上書きできない。

### 4.8 `NBExecuteHeldExpr`

main kernel同期実行の正式API。

```wl
NBExecuteHeldExpr[held_HoldComplete, accessSpec_Association, opts___] -> Association
```

Options:

```wl
"TimeConstraint" -> 30
"ScreenMode" -> "Block"
"PolicySnapshot" -> Automatic
"PreExecutionNotebookActions" -> {}
"Audit" -> True
"ApprovalMode" -> "None"
```

返り値:

```wl
<|
  "Success" -> True | False,
  "Decision" -> "Permit" | "Screen" | "NeedsApproval" | "Deny" | "RepairNeeded",
  "RawResult" -> _,
  "HeldExpr" -> held,
  "Error" -> None | _String,
  "AuditID" -> _String | None
|>
```

必須挙動:

1. `HoldComplete[_]` でない入力は拒否。
2. `accessSpec` を正規化。
3. `NBValidateHeldExpr[held, accessSpec, "PolicySnapshot" -> snapshot]` を呼ぶ。
4. `Deny` / `RepairNeeded` は実行しない。
5. `NeedsApproval` は既定では実行しない。
6. `NeedsApproval` を実行できるのは、P1のExecutionTicket、またはP0暫定の明示承認モードがある場合だけである。
7. P0暫定承認を入れる場合でも、`accessSpec["ExecutionRole"]`, `AllowedNotebookActions`, `MayWriteNotebook`, target notebookを必ず照合する。
8. `Screen` は既定ではBlock。
9. `ScreenMode -> "WarnOnly"` の場合のみmain kernelで実行可。ただしauditに `"ScreenWarnOnlyExecuted" -> True` を残す。
10. `PreExecutionNotebookActions` を検証し、許可されたものだけを `ReleaseHold` 直前に実行する。
11. `TimeConstraint === Infinity` の場合は `TimeConstrained` を使わず、`Quiet[ReleaseHold[held]]` を実行する。
12. `ReleaseHold` はこの関数内部だけに存在する。

### 4.9 `NBExecuteHeldExprSubkernelRaw`

P0でfuture result shapeを維持するためのsubkernel専用wrapper。

```wl
NBExecuteHeldExprSubkernelRaw[held_HoldComplete, accessSpec_Association, opts___]
```

戻り値:

- 成功時: 生の評価結果
- timeout: `$TimedOut`
- 検証失敗・実行失敗: `$Failed`

内部挙動:

1. `snapshot = accessSpec["PolicySnapshot"]` を取り出す。
2. `NBAcceptPolicySnapshot[snapshot]` が `"Valid" -> True` でなければ `$Failed`。
3. `NBSubkernelExecutableQ[held, accessSpec]` がFalseなら `$Failed`。
4. `NBValidateHeldExpr[held, accessSpec, "PolicySnapshot" -> snapshot, "RecomputeAllowedHeads" -> False]` を呼ぶ。
5. `Decision === "Permit"` の場合のみ内部で `ReleaseHold`。
6. `Screen`, `NeedsApproval`, `Deny`, `RepairNeeded` はすべて `$Failed`。
7. subkernelではWarnOnly実行をしない。
8. `TimeConstraint === Infinity` の場合は `TimeConstrained` を使わない。
9. Association resultは返さない。現行future shapeを維持するためである。

### 4.10 `PreExecutionNotebookActions`

P0で必須実装するactionは1つだけでよい。

```wl
<|
  "Action" -> "MoveSelectionAfterNotebook",
  "Notebook" -> _NotebookObject,
  "Reason" -> _String
|>
```

意味:

```wl
SelectionMove[notebook, After, Notebook]
```

検証規則:

- `accessSpec["AllowedNotebookActions"]` に同じaction名が含まれる場合のみ許可。
- `AllowedNotebookActions` の語彙はactionの `"Action"` 値と一致させる。
- `"SelectionMove"` と `"MoveSelectionAfterNotebook"` を混在させない。
- P0では `"MoveSelectionAfterNotebook"` を外部公開語彙、`SelectionMove` を内部実装名とする。
- `MayUseFrontEnd -> True` かつ `MayWriteNotebook -> True` かつ `ExecutionKernel -> "MainOnly"` のaccessSpecでのみ実行可。
- NotebookObjectがtarget notebookと一致しない場合は拒否。
- 実行順序は必ず次にする。

```text
NBValidateHeldExpr
  -> NBValidateNotebookPreActions
    -> pre-actions
      -> ReleaseHold
        -> Audit
```

### 4.11 `NBHashHeldExpr`

```wl
NBHashHeldExpr[held_HoldComplete, "Mode" -> "ExactWL"]
NBHashHeldExpr[held_HoldComplete, "Mode" -> "SourceFingerprint"]
```

`ExactWL` はticket/audit用で、Contextやsymbol identityを含む完全同一性を見る。

禁止:

```wl
Hash[Unevaluated[heldExpr], "SHA256"]
```

これはシンボル `heldExpr` 自体をhashしてしまう危険がある。

P0ではaudit用途として `ExactWL` だけ実装してよい。  
P1のExecutionTicketで厳密に使う場合は、`held_HoldComplete` を値として受け、`Hash[held, "SHA256"]` または安定化したserialized表現を使う。

---

## 5. NBAccess head policy補正

### 5.1 `NotebookWrite` のapproval昇格

`NotebookWrite` はロード後のAppendではなく、`$NBApprovalHeads` の初期リスト定義に直接追加する。

推奨実装:

```wl
If[!ListQ[$NBApprovalHeads],
  $NBApprovalHeads = {
    "NBCellWriteCode", "NBCellWriteText", "NBWriteText", "NBWriteCode",
    "NBWriteSmartCode", "NBWriteInputCellAndMaybeEvaluate",
    "NBInsertTextCells", "NBCellSetOptions", "NBCellSetStyle",
    "NBCellSetTaggingRule", "NBSelectCell",
    "NBDeleteCellsByTag", "NBMoveAfterCell",
    "NBMarkCellConfidential", "NBMarkCellDependent", "NBUnmarkCell",
    "NBSetConfidentialTag", "NBSetTaggingRule", "NBDeleteTaggingRule",
    "NBSetSnapshotPrivacyLevel",
    "NBFileWriteCell", "NBFileWriteAllCells",
    "NBMergeNotebookCells",

    "NotebookWrite",

    "NBFileOpen", "NBFileClose", "NBFileSave",
    "NBSplitNotebookCells"
  }];
```

理由:

- snapshot digestの安定性を保つ。
- ロード順依存を避ける。
- LegacyStandalone環境でも分類を一致させる。
- Phase A0/A1のpolicy dump差分を明確にする。

受け入れ条件:

```wl
MemberQ[$NBApprovalHeads, "NotebookWrite"] === True
MemberQ[$NBDenyHeads, "NotebookWrite"] === False
```

### 5.2 `Evaluate` deny維持 → 【v3 改訂: deny を撤廃】

~~`Evaluate` は `$NBDenyHeads` に維持する。`Evaluate` を許可headへ移す修正は禁止。~~

**v3 改訂**: 上記方針は撤回した。`Evaluate` を `$NBDenyHeads` から **除去** する。

理由と安全性:

- 初期方針 (deny 維持) は `ReleaseHold` 経由の明示的 eval 阻止が目的だったが、
  `ParametricPlot[Evaluate[traj[θ]]]` のような描画の正当な定石まで巻き込み、
  描画を伴う依頼がほぼ全滅していた (実機 result39 で「Forbidden heads:
  Evaluate」多発、図が一切出ない事象を確認)。
- `Evaluate` の中身の危険性は **中身の head が `iExtractAllHeads` で別途捕捉**
  される。`Evaluate[DeleteFile["..."]]` なら `DeleteFile` が抽出され deny。
  したがって `Evaluate` 自体を deny する必要はない。
- `Evaluate` は allowlist (`HoldComplete`/`Hold`/`ReleaseHold` と同じ行) に
  あり許可扱い。
- subkernel 禁止リスト `$iNBSubkernelForbiddenHeads` の `Evaluate` は維持する
  (subkernel で評価順序が変わるのを避ける。描画は結局メインカーネルで
  一瞬実行されるので実害なし)。

回帰テスト (`PhaseEvaluateDenyFix_test.wl`, 10/10 PASS):

- EDT-1〜3: `ParametricPlot[Evaluate[..]]` / `Plot[Evaluate[..]]` / 素の
  `Evaluate` が deny されない。
- EDT-4/5: `Evaluate[DeleteFile[..]]` / `Evaluate[SystemOpen[..]]` は中身で
  依然 deny (安全性の要)。
- EDT-7/8: `Module[{traj}, traj[θ_]:=..; Show[ParametricPlot[..]]]` が Permit
  (§5A.6 のスコープ局所変数除外と併せて)。
- EDT-9/10: ローカル除外しても危険 head は deny、Module ローカルでない未知
  head は依然 NeedsApproval。

---


## 5A. Unknown head / C-lite安全分類仕様

### 5A.1 採用方針

本仕様では、案Aと案C-liteを採用し、案Bは標準モードでは採用しない。

```text
採用:
  Unknown head = RepairNeeded ではなく NeedsApproval またはC-lite分類へ送る
  Deny headは絶対拒否
  Allowed headは無承認Permit高速パス
  System` builtin unknownは構造的に再分類
  user-defined / package unknownはNeedsApproval

不採用:
  default permit + deny list only
```

案B、すなわち「DenyにないものはすべてPermit」は、Mathematicaの副作用関数を網羅的にDeny list化できないため標準モードでは採用しない。  
Deny漏れが即実行に直結するため、NBAccessを最終強制境界とする本設計と相性が悪い。

### 5A.2 Decision enum

`NBValidateHeldExpr` は、次のdecisionを返す。

```text
Permit
NeedsApproval
Deny
RepairNeeded
```

意味:

| Decision | 意味 |
|---|---|
| `Permit` | 無承認で実行してよい。ただしExecutionPlacementとBlockingRiskには従う。 |
| `NeedsApproval` | 構文は妥当だが、自動実行には承認が必要。 |
| `Deny` | 承認しても実行しない。危険head、明示deny、policy違反。 |
| `RepairNeeded` | 式の構造・形式が不適切で、修復が必要。単なるunknown headには使わない。 |

### 5A.3 Unknown headの扱い

従来の

```text
unknown head -> RepairNeeded
```

は廃止する。

新方針:

```text
unknown but syntactically valid head
  -> C-lite classification

malformed / unresolved / unsafe structure
  -> RepairNeeded
```

例:

```wl
HoldComplete[Integrate[E^x, {x, 0, 1}]]
```

は、`Integrate` がallow listに無い場合でも `RepairNeeded` にしてはならない。  
`System`` 文脈の副作用を示唆しない組み込みheadとして分類し、`Permit` または軽い `NeedsApproval` にする。

### 5A.4 判定優先順

`NBValidateHeldExpr` のhead分類は次の順に行う。

```text
1. explicit DenyHeads
   -> Deny

2. explicit ApprovalHeads
   -> NeedsApproval

3. explicit AllowedHeads
   -> Permit

4. System` unknown heads
   -> C-lite builtin classification

5. Global` / user-defined / package unknown heads
   -> NeedsApproval

6. malformed / unsupported / unresolved structures
   -> RepairNeeded
```

Denyは最優先であり、承認UIを出してはならない。  
Approvalは明示承認があれば実行可能だが、承認ticketまたは `ApprovalMode` が `NBExecuteHeldExpr` まで届く必要がある。

### 5A.5 System` builtin unknown のC-lite分類

System` 文脈の未知headは、名前・文脈・副作用語幹で再分類する。

#### 5A.5.1 明示Deny

Deny listに該当するheadは常にDeny。

例:

```text
Run
StartProcess
ExternalEvaluate
LibraryFunctionLoad
LinkLaunch
SocketConnect
URLSubmit
DeleteFile
DeleteDirectory
```

#### 5A.5.2 明示Approval

Approval listに該当するheadはNeedsApproval。

例:

```text
NotebookWrite
SelectionMove
SystemOpen  (* raw SystemOpenを許す場合。ただし専用action推奨 *)
```

#### 5A.5.3 side-effect-ish pattern

System` unknown headの名前が次の語幹を含む、またはこれらで始まる/終わる場合は `NeedsApproval` または `Deny` にする。

```text
Open
Write
Save
Export
Import
Delete
Remove
Run
Start
Create
Put
Read
URL
Socket
Send
Submit
Connect
Launch
Install
Load
Library
External
Notebook
FrontEnd
Dialog
Cloud
HTTP
Mail
```

原則:

```text
destructive / external execution / network
  -> Deny

desktop action / file read/write / notebook write
  -> NeedsApproval or dedicated NBAccess action
```

#### 5A.5.4 pure-ish System` builtin

副作用語幹に当たらず、通常の数学・記号・リスト・文字列・グラフ等の計算関数と見なせるものは、`Permit` または `NeedsApproval` にする。

代表例:

```text
Plus
Times
Power
Exp
Log
Sin
Cos
Integrate
NIntegrate
Sum
Product
Solve
NSolve
Reduce
Simplify
FullSimplify
Expand
Factor
D
Limit
Series
Normal
Table
Range
Total
Mean
Sort
SortBy
Map
Apply
Select
Cases
Graph
FindShortestPath
```

注意:

- `Plot` 系は副作用というよりgraphics生成であり、通常は `SubkernelSafe` だが、結果が大きい・時間がかかる可能性があるため `BlockingRisk -> PossiblyLongOrLargeResult` を付ける。
- `NIntegrate`, `FindRoot`, `FindMinimum`, `DSolve`, `NDSolve` 等は長時間実行リスクを持つため、`TimeConstraint` とsubkernel実行候補にする。

### 5A.6 user-defined / package unknown heads

`Global`` やユーザーpackage文脈のheadは、標準では `NeedsApproval` にする。

理由:

```wl
myFunction[x]
```

は見た目が純粋でも、内部でファイル操作・外部プロセス・FrontEnd操作をする可能性があるためである。

ただし、将来的にユーザー定義関数へ安全metadataを付与する仕組みを導入してよい。

例:

```wl
NBDeclarePureFunction[myFunction]
NBDeclareSubkernelSafe[myFunction]
NBDeclareNeedsApproval[myFunction]
```

これはP1以降とする。

> **【v3 追加】スコープ局所変数・パターン変数・定義関数名は unknown から除外する**
>
> `Module`/`Block`/`With`/`Function`/`DynamicModule`/`Manipulate` の束縛変数、
> `SetDelayed`/`Set` の左辺で定義される関数名、パターン変数 (`x_` 等) は、
> held のままでは `Global`` 文脈 head に見えるが、これらは **ユーザーが新規に
> 束縛する安全なローカル** であり、`NeedsApproval` の対象にしてはならない。
>
> 例: `Module[{v0=20, g=9.8, traj}, traj[θ_]:=..; Show[ParametricPlot[..]]]`
> の `traj` を未知 head 扱いすると、LLM が説明用に補助関数を定義しただけで
> 全て承認要求になり、計算がほぼ全滅する (実機 result41 で
> 「NeedsApproval (UnknownHeadRequiresApproval)」を確認)。
>
> `iNBExtractScopedSymbols[held]` がこれらの束縛シンボルを抽出し、unknown head
> 算出時に除外する。実装は **文字列ベース** (held を `HoldForm` 経由で
> `InputForm` 文字列化し、実績ある `iExtractScopeVars`/`iExtractPatternVars` +
> 定義関数名の正規表現で抽出)。held 式の `Cases` パターンマッチは `Set` 等の
> 評価副作用リスクがあるため避ける。
>
> **除外しても安全性は保たれる**: スコープ局所変数を除外しても、`Module` 本体
> 内の危険 head (`DeleteFile` 等) は別途 `iExtractAllHeads` で捕捉され deny
> される (EDT-9)。Module ローカルでない真の未知 head は依然 NeedsApproval
> (EDT-10、除外が効きすぎないことを保証)。
>
> **重要 (§5A.9 と関連)**: この除外は base 判定層
> (`iNBValidateHeldExprBase` の unknown 算出) と mode 変換層
> (`NBValidateHeldExpr` ラッパーの EffectClass 集約) の **両方** に入れる
> 必要がある。片方だけだと、base が Permit でも mode 変換層で
> NeedsApproval に昇格する。

### 5A.7 ExecutionPlacement

`NBValidateHeldExpr` は、必要に応じてdecisionに加え、次のmetadataを返す。

```wl
<|
  "Decision" -> "Permit",
  "ExecutionPlacement" -> "SubkernelSafe",
  "BlockingRisk" -> "PossiblyLong",
  "MayRunAsync" -> True,
  "MayUseFrontEnd" -> False,
  "RequiresFinalNode" -> False
|>
```

ExecutionPlacement候補:

| Placement | 意味 |
|---|---|
| `SubkernelSafe` | FrontEnd不要・副作用なし・subkernel実行候補 |
| `MainKernelOnly` | subkernelには出せないが、FrontEnd不要 |
| `FrontEndRequired` | FrontEnd操作が必要 |
| `DesktopAction` | OS/desktop actionを伴う |
| `ExternalProcess` | 外部プロセス実行 |
| `FileSystemReadOnly` | read-only file access |
| `FileSystemWrite` | file write/destructive action |
| `Network` | network access |

`NBSubkernelExecutableQ` は `ExecutionPlacement -> "SubkernelSafe"` かつ `MayRunAsync -> True` の場合だけTrueにしてよい。

### 5A.8 BlockingRisk

自動実行やOrchestrator分割のため、可能なら次を返す。

```text
None
PossiblyLong
PossiblyLongOrLargeResult
MayBlockFrontEnd
ExternalWait
UserInteractionRequired
```

`MayBlockFrontEnd` / `UserInteractionRequired` は自動実行禁止またはfinal node集約の対象である。

### 5A.9 承認UIと最終NBAccess判定の一致

承認UIは `NBValidateHeldExpr` の最終decisionに従う。

```text
Deny
  -> 実行/中止ボタンを出さない
  -> 拒否理由だけ表示

NeedsApproval
  -> 実行/中止ボタンを出す
  -> 実行ボタン押下時、承認情報をNBExecuteHeldExprへ渡す

Permit
  -> 自動実行可
  -> ただしExecutionPlacement/BlockingRiskに従う

RepairNeeded
  -> 実行ボタンを出さない
  -> 修復またはLLM再生成へ回す
```

現在の問題である

```text
SystemOpenで承認UIが出る
-> 押してもNBAccess最終判定でDenyされる
```

は、UIとNBAccess最終判定の不一致である。  
Denyならボタンを出さない。NeedsApprovalなら承認が `NBExecuteHeldExpr` の `ApprovalMode` またはP1のticketへ届くようにする。

> **【v3 追加】`NBValidateHeldExpr` の2層構造と head フィルタの一貫性**
>
> `NBValidateHeldExpr` は内部的に2層で判定する:
> 1. **base 判定** (`iNBValidateHeldExprBase`): allowlist/approval/deny/unknown
>    head から `BaseDecision` を生成。
> 2. **mode 変換層** (`NBValidateHeldExpr` ラッパー): 別途
>    `iNBHeadNameContextPairs` で全 head を取り、各 head の EffectClass を集約
>    して ApprovalEligibility を決め、PermissionMode と合成して最終 Decision を
>    生成。base eligibility と EffectClass eligibility の **厳しい方** を採る。
>
> 帰結として、**base が Permit でも mode 変換層で NeedsApproval に昇格しうる**。
> 昇格時は base の `ReasonClass` が引き継がれず `ReasonClass=None` の
> NeedsApproval になる。これがデバッグの目印 (実機 result26 で確認)。
>
> したがって head フィルタ (§5A.6 のスコープ局所変数除外など) は **base 判定層
> と mode 変換層の両方に入れる必要がある**。片方だけだと不整合が起き、
> 「承認UIと最終判定の不一致」と同種の問題 (片層 Permit / 他層 NeedsApproval)
> を生む。
>
> **DenyOverride の廃止 (Phase 25b)**: 旧実装は Deny を承認待ち
> (AwaitingApproval) に遷移させ実行/中止ボタンを出していたが、押しても
> 実行されない混乱を生むため廃止済み。Deny は `iRecordFatalFailure` で即 Failed
> とし、`LastFailure` に Decision=Deny + VisibleExplanation を格納、表示時に
> 拒否理由を併記する。NeedsApproval は従来通り AwaitingApproval 遷移。

### 5A.10 `SystemOpen` の推奨扱い

raw `SystemOpen[...]` を広く許すより、専用のNBAccess actionへ寄せる。

推奨:

```wl
NBOpenFolderWithApproval[path]
```

このactionは内部で次を検査する。

```text
pathがfolderである
pathが許可範囲内である
URLではない
実行ファイルではない
承認済みである
ExecutionPlacement -> DesktopAction
RequiresFinalNode -> True
```

短期互換としてraw `SystemOpen` を `ApprovalHeads` に置く場合でも、承認後にpath検査を行う。  
URL、実行ファイル、許可範囲外pathは拒否する。

### 5A.11 Prompt / Directivesへの追加指示

LLMには次を指示する。

```text
- 可能な限り、Wolfram式はFrontEndを使わない純粋なkernel計算として生成すること。
- NotebookWrite, SelectionMove, FrontEndExecute, CreateDialog, SystemOpen,
  Run, StartProcess, ExternalEvaluate, URLRead, URLSubmit などを通常stepに混ぜないこと。
- 副作用・FrontEnd操作・外部プロセス・ファイル書き込みはfinal actionとして分離すること。
- 長時間計算になり得る式は、TimeConstrained / subkernel async 実行可能な形にすること。
- 安全な計算結果を先に返し、危険操作は承認付きfinal actionとして提示すること。
```

これは安全境界ではない。  
最終判断は必ずNBAccessで行う。

### 5A.12 例

#### 例1: `ClaudeEval["1から100までの和"]`

生成候補:

```wl
Sum[i, {i, 1, 100}]
```

期待:

```text
Decision -> Permit
ExecutionPlacement -> SubkernelSafe
MayRunAsync -> True
```

#### 例2: `ClaudeEval["e^xを0から1まで積分した値"]`

生成候補:

```wl
Integrate[E^x, {x, 0, 1}]
```

期待:

```text
Decision -> Permit or NeedsApproval
ExecutionPlacement -> SubkernelSafe
BlockingRisk -> PossiblyLong
MayRunAsync -> True
```

少なくとも `RepairNeeded` にはしない。

#### 例3: `ClaudeEval["init.mの入っているフォルダを開いて"]`

推奨workflow:

```text
Step 1:
  init.m候補pathを計算
  Decision -> Permit
  ExecutionPlacement -> SubkernelSafe or MainKernelOnly

Step 2:
  path存在確認
  Decision -> Permit
  ExecutionPlacement -> FileSystemReadOnly

Step 3:
  folderを開く
  Decision -> NeedsApproval
  ExecutionPlacement -> DesktopAction
  RequiresFinalNode -> True
```

raw `SystemOpen[path]` を直接生成するより、

```wl
NBOpenFolderWithApproval[path]
```

へ寄せる。

#### 例4: `Run["..."]`

期待:

```text
Decision -> Deny
UI -> 実行ボタンなし
```

### 5A.13 実装優先度

P0.5として、Phase B/Cに次を追加する。

1. unknown headを一律 `RepairNeeded` にしない。
2. unknown System` builtinをC-lite分類へ送る。
3. user/package unknownは `NeedsApproval`。
4. `RepairNeeded` は構造修復が必要な場合に限定する。
5. 承認UIは `NeedsApproval` のときだけ出す。
6. Denyでは承認UIを出さない。
7. 承認押下時に `ApprovalMode` またはticketが `NBExecuteHeldExpr` まで届くようにする。
8. `ExecutionPlacement` と `BlockingRisk` metadataを返す。


## 5B. `$ClaudePermissionMode` と承認エスカレーション仕様

### 5B.1 目的

`NBOpenFolderWithApproval[path]` のような用途別actionを多数追加するのではなく、まずNBAccess/ClaudeRuntime共通のpermission modeで次を制御する。

```text
auto permit:
  無承認で実行してよい

approval eligible:
  ユーザーにApprove/Cancelを提示してよい

hard deny:
  ユーザー承認があっても実行しない

repair needed:
  式の修復・再生成が必要
```

これにより、

```text
危険そうに見えるが、限定条件つきならユーザー判断に委ねてよい操作
```

を、個別のアドホック関数ではなく、汎用の承認エスカレーションとして扱う。

### 5B.2 基本方針

headから直接 `Decision` を決めるのではなく、まず構造分類を行う。

```text
heldExpr
  -> EffectClass
  -> ApprovalEligibility
  -> ExecutionPlacement
  -> BlockingRisk
  -> $ClaudePermissionMode
  -> final Decision
```

`Decision` は最終結果である。  
その前段として、次を返す。

```wl
<|
  "EffectClass" -> "...",
  "ApprovalEligibility" -> "AutoPermit" | "AskUserAllowed" | "HardDeny" | "RepairRequired",
  "ExecutionPlacement" -> "...",
  "BlockingRisk" -> "...",
  "RequiresFinalNode" -> True | False,
  "Decision" -> ...
|>
```


### 5B.2A 移行方針: 既存Decisionと新metadataを併存させる

P0.5では、既存コードを壊さないため、`NBValidateHeldExpr` は従来通り `Decision` を返す。  
同時に、新しい分類情報を追加キーとして返す。

```wl
<|
  "Decision" -> "Permit" | "NeedsApproval" | "Deny" | "RepairNeeded",
  "BaseDecision" -> "Permit" | "NeedsApproval" | "Deny" | "RepairNeeded",
  "EffectClass" -> "...",
  "ApprovalEligibility" -> "AutoPermit" | "AskUserAllowed" | "HardDeny" | "RepairRequired",
  "ExecutionPlacement" -> "...",
  "BlockingRisk" -> "...",
  "RequiresFinalNode" -> True | False,
  "PermissionMode" -> accessSpec["PermissionMode"],
  "ModeTransformApplied" -> True
|>
```

実装順序:

```text
1. head / structure を分類する
2. EffectClass を決める
3. ApprovalEligibility を決める
4. PermissionMode を accessSpec から読む
5. ApprovalEligibility × PermissionMode で final Decision を作る
6. 従来コード向けに Decision キーは維持する
```

`BaseDecision` はmode変換前の概念的判定である。  
既存の `Switch[decision["Decision"], ...]` は当面そのまま動く。

重要:

- mode変換は `NBValidateHeldExpr` の最後に一度だけ適用する。
- `NBExecuteHeldExpr` は、再検証後の最終 `Decision` と `ApprovalEligibility` の両方を見る。
- `Decision -> "NeedsApproval"` でも、`ApprovalEligibility -> "HardDeny"` であってはならない。これは実装バグとして扱う。

### 5B.3 `$ClaudePermissionMode`

グローバル設定:

```wl
$ClaudePermissionMode = "InteractiveSafe";
```

推奨モード:

| Mode | 用途 | 自動実行 | 承認UI | HardDeny |
|---|---|---:|---:|---:|
| `"ReviewOnly"` | 提案だけ。実行しない | なし | なし | 全停止 |
| `"StrictSafe"` | 最も保守的 | `AutoPermit` のみ | なし | 実行不可 |
| `"InteractiveSafe"` | 標準推奨 | `AutoPermit` | `AskUserAllowed` | 不可 |
| `"WorkflowSafe"` | Orchestrator用 | safe nodeは自動、final nodeは承認 | final nodeのみ | 不可 |
| `"LegacyInteractive"` | 旧Notebook互換 | `AutoPermit` + 一部承認 | あり | 不可 |
| `"DangerFullAccess"` | 明示的な開発者モード | 広い | あり/省略可 | ただしHardDenyの一部は維持可能 |

標準値は `"InteractiveSafe"` とする。  
自動ワークフローでは `"WorkflowSafe"` を使う。

### 5B.4 mode別のfinal decision生成

#### ReviewOnly

ReviewOnlyでは、`AutoPermit` も含めて実行しない。  
承認ボタンも出さない。

P0.5の互換実装では、既存 `Decision` enumを壊さないため、次の形を標準とする。

```wl
<|
  "Decision" -> "NeedsApproval",
  "ExecutionDisposition" -> "ReviewOnly",
  "AllowApprovalUI" -> False,
  "MayExecute" -> False
|>
```

P1で `Decision -> "ReviewOnly"` を正式enumへ追加してもよい。  
ただしP0.5では既存 `Decision` 依存コードを壊さないため、`ExecutionDisposition` で表す。

変換:

```text
AutoPermit        -> Decision NeedsApproval + ExecutionDisposition ReviewOnly + no UI
AskUserAllowed    -> Decision NeedsApproval + ExecutionDisposition ReviewOnly + no UI
HardDeny          -> Deny
RepairRequired    -> RepairNeeded
```

目的は「提案だけを返す」ことであり、Approve/Cancel UIを出さない。

#### StrictSafe

```text
AutoPermit        -> Permit
AskUserAllowed    -> Deny or NeedsApprovalWithoutButton
HardDeny          -> Deny
RepairRequired    -> RepairNeeded
```

`AskUserAllowed` に対してもApproveボタンを出さない。  
安全性確認用・CI・無人実行向け。

#### InteractiveSafe

```text
AutoPermit        -> Permit
AskUserAllowed    -> NeedsApproval
HardDeny          -> Deny
RepairRequired    -> RepairNeeded
```

標準推奨。  
ユーザーがいる対話環境では、限定的に危険な操作をユーザー判断へ委ねる。

#### WorkflowSafe

```text
AutoPermit + SubkernelSafe
  -> Permit

AskUserAllowed or FrontEndRequired or DesktopAction or FileSystemWrite
  -> NeedsApproval + RequiresFinalNode -> True

HardDeny
  -> Deny

RepairRequired
  -> RepairNeeded
```

Orchestratorは `RequiresFinalNode -> True` を持つstepを通常stepに混ぜず、final action nodeへ分離する。

#### DangerFullAccess

開発者が明示指定した場合だけ使う。

```text
AutoPermit        -> Permit
AskUserAllowed    -> Permit or NeedsApproval
HardDeny          -> Deny unless explicitly overridden by separate developer flag
RepairRequired    -> RepairNeeded
```

`DangerFullAccess` でも、`HardDeny` を無条件でPermitにしない。  
`Run`, `ExternalEvaluate`, `LibraryFunctionLoad`, `SocketConnect`, destructive filesystem などは、さらに別の明示フラグがない限りDenyのままにできる。

例:

```wl
$ClaudePermissionMode = "DangerFullAccess";
$ClaudeAllowHardDenyOverride = False;  (* default *)
```

### 5B.5 EffectClass

P0.5で導入するEffectClass。

重要原則:

```text
EffectClass table は許可の必須条件ではない。
未登録headは必ずフォールバック分類へ進む。
tableは分類精度を上げるための任意上書きである。
```

したがって、`Integrate`, `NIntegrate`, `Plot` などをすべてtableへ登録しなければ実行できない、という状態に戻してはならない。

分類優先順:

```text
1. explicit DenyHeads / ApprovalHeads / AllowedHeads
2. EffectClass override table
3. side-effect stem heuristic
4. System` pure-ish fallback
5. user/package unknown fallback
6. malformed fallback
```

P0.5で導入するEffectClass:

| EffectClass | 例 | 既定ApprovalEligibility |
|---|---|---|
| `PureComputation` | `Integrate`, `Exp`, `Solve`, `Total` | `AutoPermit` or `AskUserAllowed` |
| `LongRunningComputation` | `NIntegrate`, `NDSolve`, `FindMinimum` | `AutoPermit` with timeout or `AskUserAllowed` |
| `GraphicsComputation` | `Plot`, `GraphPlot`, `Manipulate`なしのgraphics | `AutoPermit` or `AskUserAllowed` |
| `ReadOnlyFileSystem` | `FileExistsQ`, `FileNames` in allowed dirs | `AutoPermit` or `AskUserAllowed` |
| `NotebookMutation` | `NotebookWrite`, `SelectionMove` | `AskUserAllowed` |
| `FrontEndAction` | `FrontEndExecute`, dialogs | `AskUserAllowed` or `HardDeny` |
| `DesktopAction` | `SystemOpen` for folder | `AskUserAllowed` |
| `ExternalProcess` | `Run`, `StartProcess` | `HardDeny` |
| `NetworkAccess` | `URLRead`, `URLSubmit`, sockets | `HardDeny` or policy-specific `AskUserAllowed` |
| `FileSystemWrite` | `Export`, `WriteString`, `CreateFile` | `AskUserAllowed` or `HardDeny` |
| `DestructiveFileSystem` | `DeleteFile`, `DeleteDirectory` | `HardDeny` |
| `LibraryOrLinkLoading` | `LibraryFunctionLoad`, `LinkLaunch` | `HardDeny` |
| `KernelControl` | `Quit`, `Abort`, `Exit` | `HardDeny` |
| `UnknownUserCode` | `Global`foo[x] | `AskUserAllowed` |
| `MalformedExpression` | 不完全・未解決wrapper | `RepairRequired` |


### 5B.5A EffectClass override table とフォールバック

EffectClass判定は、次の2層に分ける。

#### override table

精度を上げたいheadだけ登録する。

```wl
$NBEffectClassOverrides = <|
  "NIntegrate" -> <|
    "EffectClass" -> "LongRunningComputation",
    "BlockingRisk" -> "PossiblyLong",
    "ExecutionPlacement" -> "SubkernelSafe"
  |>,
  "NDSolve" -> <|
    "EffectClass" -> "LongRunningComputation",
    "BlockingRisk" -> "PossiblyLong",
    "ExecutionPlacement" -> "SubkernelSafe"
  |>,
  "Plot" -> <|
    "EffectClass" -> "GraphicsComputation",
    "BlockingRisk" -> "PossiblyLongOrLargeResult",
    "ExecutionPlacement" -> "SubkernelSafe"
  |>
|>;
```

#### fallback

tableに無いSystem` builtinは、side-effect stemに当たらなければ `PureComputation` へ倒す。

```text
System` unknown + side-effect stem match
  -> corresponding side-effect EffectClass

System` unknown + no side-effect stem
  -> PureComputation

Global` / package unknown
  -> UnknownUserCode

malformed
  -> MalformedExpression
```

これにより、EffectClass tableはallowlistではなく、分類精度向上用metadataになる。

### 5B.6 ApprovalEligibility

```text
AutoPermit:
  modeが許せば自動実行可能

AskUserAllowed:
  ユーザーにApprove/Cancelを出してよい

HardDeny:
  Approveボタンを出してはならない

RepairRequired:
  実行UIを出さず、式の修復へ回す
```

重要:

```text
Deny
```

は最終Decisionであり、`ApprovalEligibility` ではない。  
「普段は止めるが、ユーザーに聞いてよいもの」は `HardDeny` ではなく `AskUserAllowed` に分類する。

### 5B.7 raw SystemOpenの扱い

`SystemOpen` を単純に常時Denyするのではなく、対象とmodeにより分類する。

#### folder path

```text
EffectClass -> DesktopAction
ApprovalEligibility -> AskUserAllowed
ExecutionPlacement -> DesktopAction
RequiresFinalNode -> True
```

条件:

- pathが文字列または安全に正規化可能なFile object
- URLではない
- 実行ファイルではない
- folderである
- 許可されたroot配下、またはユーザーが明示要求した既知folderである
- `"InteractiveSafe"` または `"WorkflowSafe"` である

#### URL / executable / unknown target

```text
EffectClass -> DesktopAction or ExternalProcess
ApprovalEligibility -> HardDeny
```

#### 推奨実装

`NBOpenFolderWithApproval[path]` を個別に乱立させるのではなく、内部では汎用actionとして表現する。

```wl
<|
  "Action" -> "OpenDesktopItem",
  "TargetType" -> "Folder",
  "Path" -> path,
  "EffectClass" -> "DesktopAction",
  "ApprovalEligibility" -> "AskUserAllowed",
  "ExecutionPlacement" -> "DesktopAction",
  "RequiresFinalNode" -> True
|>
```

`NBOpenFolderWithApproval[path]` は必要なら薄い互換wrapperとして定義してよい。

```wl
NBOpenFolderWithApproval[path_] :=
  NBExecuteApprovedAction[
    <|"Action" -> "OpenDesktopItem", "TargetType" -> "Folder", "Path" -> path|>
  ]
```

ただし、正本は汎用action registryとpermission modeである。

### 5B.8 Action registry

Notebook/desktop/filesystemなどの承認対象操作は、raw headではなくaction registryへ寄せる。

```wl
NBRegisterAction[
  "OpenDesktopItem",
  <|
    "EffectClass" -> "DesktopAction",
    "DefaultApprovalEligibility" -> "AskUserAllowed",
    "AllowedTargetTypes" -> {"Folder"},
    "RequiresFinalNode" -> True,
    "Validator" -> NBValidateOpenDesktopItemAction,
    "Executor" -> NBExecuteOpenDesktopItemAction
  |>
]
```

実行時:

```wl
NBValidateAction[action_Association, accessSpec_Association]
NBExecuteApprovedAction[action_Association, accessSpec_Association, opts___]
```

P0.5では `"OpenDesktopItem"` だけ実装してよい。  
P1で `NotebookMutation`, `FileSystemWrite`, `ReadOnlyFileSystem` を追加する。

> **【v3 追加】`WriteNotebookCell` action を実装済み**
>
> 非 desktop final action (notebook 出力系) を `NBExecuteApprovedAction` 経由で
> 実行するため、`WriteNotebookCell` を registry に登録した。
>
> ```wl
> NBRegisterAction["WriteNotebookCell",
>   <|"EffectClass" -> "FrontEndWrite",
>     "DefaultApprovalEligibility" -> "AskUserAllowed",
>     "AllowedTargetTypes" -> {"Cell"},
>     "RequiresFinalNode" -> True,
>     "BlockingRisk" -> "MayBlockFrontEnd",
>     "ExecutionPlacement" -> "FrontEndRequired",
>     "Validator" -> iNBValidateWriteNotebookCell,
>     "Executor" -> iNBExecuteWriteNotebookCell|>]
> ```
>
> - action 構造: `<|"Action"->"WriteNotebookCell", "Cell"-><Cell式>,
>   "TargetNotebook"-><nb> (省略可)|>`。
> - Validator: Cell 式であることを検証。Cell でなければ HardDeny。
>   `InitializationCell->True` / `CellAutoOverwrite->True` 等の自動評価設定が
>   ある Cell は HardDeny (書き込み時に勝手に評価されるのを防ぐ)。
> - Executor: 承認後メイン評価で `NBWriteCell`/`CellPrint` で書き込む
>   (FrontEnd 操作なのでメイン評価前提、罠 #30)。
> - Orchestrator 側 (`iOrchDesktopActionButton`) は、final action の held が
>   `NotebookWrite[nb,cell]`/`CellPrint[cell]`/`NBWriteCell[..]` のとき
>   `iOrchExtractWritableCell` で Cell を**評価せず構造マッチで**取り出し、
>   「実行 / Run」ボタンを出す。押下時 (Method->Queued = メイン評価) に
>   `NBExecuteApprovedAction` で書き込む。Cell が取れない (file write 等) なら
>   従来通り「手動実行」表示 (無制限実行にしない)。
> - 回帰テスト FNS-19〜22: 有効 Cell→NeedsApproval、非 Cell→Deny、
>   自動評価 Cell→Deny、RequiresFinalNode True。

#### NBAccess境界との関係

action executorはNBAccess内部に置く。  
`OpenDesktopItem` が最終的に `SystemOpen` を呼ぶ場合、そのraw `SystemOpen` 呼び出しはNBAccess内部のexecutorだけに閉じる。

```text
ClaudeRuntime / Orchestrator
  -> action association
  -> NBValidateAction
  -> approval UI
  -> NBExecuteApprovedAction
  -> NBAccess internal executor
  -> SystemOpen
```

Runtime/Orchestrator/claudecode側がraw `SystemOpen` を直接実行してはならない。

#### TOCTOU対策

executorは実行直前に必ず再validateする。

```text
check time:
  approval UI表示前

use time:
  executor実行直前
```

承認後にpathやtarget typeが変わった場合は実行しない。

```wl
<|
  "Success" -> False,
  "Decision" -> "Deny",
  "ReasonClass" -> "PostApprovalValidationFailed"
|>
```

これは time-of-check-to-time-of-use 対策であり、承認後再拒否として許容される。

### 5B.9 承認UIとの関係

承認UIは `Decision` だけでなく、`ApprovalEligibility` と `$ClaudePermissionMode` から決める。

```text
ApprovalEligibility -> HardDeny
  -> UIにApproveボタンを出さない

ApprovalEligibility -> AskUserAllowed
  and $ClaudePermissionMode in {"InteractiveSafe", "WorkflowSafe", "LegacyInteractive"}
  -> Approve/Cancelを出す

ApprovalEligibility -> AskUserAllowed
  and $ClaudePermissionMode == "StrictSafe"
  -> 実行不可。理由表示のみ。

ApprovalEligibility -> AutoPermit
  -> modeが許せば自動実行

ApprovalEligibility -> RepairRequired
  -> 修復へ回す
```

承認後は、UIが作った承認情報を `NBExecuteHeldExpr` まで渡す。

P0では:

```wl
"ApprovalMode" -> "UserApproved"
```

P1では:

```wl
"ExecutionTicket" -> ticket
```

承認UIでApproveされたにもかかわらず、同じ操作が最終NBAccessで `Deny` される状態は原則バグである。  
ただし、承認後にpathやenvironmentが変化した場合の再拒否は許される。その場合は `"ReasonClass" -> "PostApprovalValidationFailed"` を返す。


### 5B.9A CommitterAutoApprove / UserApproved の位置づけ

既存の `CommitterAutoApprove` や `ApprovalMode -> "UserApproved"` は、P0.5では承認情報を `NBExecuteHeldExpr` へ伝える手段として扱う。

対応関係:

```text
ApprovalEligibility -> AskUserAllowed
  + PermissionMode allows approval
  + ApprovalMode -> "UserApproved"
  -> NBExecuteHeldExpr may execute

CommitterAutoApprove
  -> WorkflowSafe の final node で、Orchestratorが既に承認済みとみなす限定的な UserApproved
```

`CommitterAutoApprove` は一般の自動承認ではない。  
次の条件を満たす場合だけ有効にする。

```text
ExecutionRole -> "Committer"
RequiresFinalNode -> True
Workflow step が final action node として分離済み
EffectClass が NotebookMutation または許可済み action
HardDeny ではない
Audit に ApprovalBypass / CommitterAutoApprove を記録する
```

`HardDeny` は `CommitterAutoApprove` でも実行不可である。

### 5B.10 `$ClaudePermissionMode` と `$ClaudeRuntimeAsyncForce`

`$ClaudeRuntimeAsyncForce` は性能heuristicだけを上書きする。  
permission modeやNBAccessの安全判定を上書きしてはならない。

```text
$ClaudeRuntimeAsyncForce=True
  can override:
    cost heuristic
    small expression sync preference

  cannot override:
    HardDeny
    AskUserAllowed requiring approval
    FrontEndRequired
    DesktopAction
    FileSystemWrite
    NetworkAccess
```

### 5B.11 Prompt / Directivesへの追加

Claude Directivesには次を追加する。

```text
- Permission modeを前提に、raw SystemOpen/NotebookWrite/Run等を直接混ぜない。
- DesktopAction, FrontEndAction, FileSystemWrite, ExternalProcess, NetworkAccess は final action として分離する。
- ユーザー承認が妥当な操作は、raw Wolfram headではなく action association として提示する。
- 安全な計算部分は PureComputation / SubkernelSafe として先に分離する。
- HardDeny対象は承認を要求せず、代替案を提示する。
```

### 5B.12 実装優先度

P0.5:

1. `$ClaudePermissionMode` を導入する。
2. `EffectClass` / `ApprovalEligibility` / `ExecutionPlacement` / `BlockingRisk` を `NBValidateHeldExpr` の結果に追加する。
3. `Unknown head -> RepairNeeded` を廃止し、C-lite分類へ送る。
4. `AskUserAllowed` を modeに応じて `NeedsApproval` に変換する。
5. `HardDeny` ではApproveボタンを出さない。
6. Approve後に `ApprovalMode -> "UserApproved"` が `NBExecuteHeldExpr` まで届くようにする。
7. `SystemOpen[folder]` を `"OpenDesktopItem"` actionへ正規化する。
8. Orchestratorは `RequiresFinalNode -> True` をfinal nodeへ分離する。

P1:

1. Action registryを拡充する。
2. ExecutionTicketを導入する。
3. user-defined function safety metadataを導入する。
4. permission modeをUI/Doctorで表示・変更可能にする。


## 5C. 出力モード (逐次 / バッチ) 【v3 新設】

### 5C.1 目的と方針

FrontEnd/カーネルのブロック回避を **最優先** としつつ、出力の出し方を選択可能
にする。

- 集約 (最後にまとめて出力) は目的ではなく、ブロックを避けられない場合の
  方策である。
- ブロックしないなら、結果が出るたびに **逐次出力** する方が、計算状況が見えて
  望ましい (既定)。
- 非同期並列の多数処理では、ノートブックに何も出さず完全バックグラウンドで
  処理し、最後に集約出力する **バッチ** が望ましい。
- 逐次 (`"Streaming"`) とバッチ (`"Batch"`) を選択可能にする。

### 5C.2 `$ClaudeOutputMode` と `NBResolveOutputMode`

- `$ClaudeOutputMode` (NBAccess、既定 `"Streaming"`): `"Streaming"` か
  `"Batch"`。実行中は accessSpec/runtime メタデータに焼き込んだ値を正とする
  (I12 と同じ方針)。
- `NBResolveOutputMode[mode, blockingRisk]` → `"Immediate"` | `"Deferred"`:
  - `blockingRisk == "MayBlockFrontEnd"` なら **mode 不問で `"Deferred"`**
    (ブロック回避が最優先)。
  - `mode == "Batch"` なら `"Deferred"`。
  - それ以外 (Streaming かつブロックなし) は `"Immediate"`。
  - 不正な mode は安全側 `"Immediate"` (出力が消えるより出る方が安全)。

### 5C.3 出力遅延バッファ

`NBWriteCell` の 1 箇所にゲートを設け、99 箇所の呼び出し側を無変更で集約する。

- `$iNBDeferActive` (内部、既定 `False`) / `$iNBDeferredCells` (バッファ)。
- `NBBeginDeferredOutput[]` / `NBEndDeferredOutput[]`: 集約区間の開始/終了。
- `NBFlushDeferredOutput[nb]`: 溜めた Cell を一括 `NotebookWrite`。
  `NBFlushDeferredOutput[]` (nb 省略) は `CellPrint`。
- `NBDeferredOutputActiveQ[]` / `NBDeferredOutputCount[]` /
  `NBDiscardDeferredOutput[]`。
- `NBWriteCell` ゲート: `$iNBDeferActive==True` かつ `where===After` のとき
  バッファに溜める。位置指定 (After 以外) は順序整合のため遅延に乗せず即書き。
- **後方互換**: `$iNBDeferActive` 既定 False で `NBWriteCell` は 100% 従来通り。
  集約有効化は呼び出し側が `NBBeginDeferredOutput` を明示的に呼んだときだけ。

> **罠 #30 との関係**: バッファへの `AppendTo` は変数操作なので評価コンテキスト
> 不問 (scheduled task でも安全)。しかし `NBFlushDeferredOutput`
> (`NotebookWrite`/`CellPrint`) は FrontEnd 操作なので **メインカーネル評価で
> 呼ぶこと**。

### 5C.4 ClaudeEval / ClaudeRunOrchestration オプション

- `ClaudeEval[..., OutputMode -> Automatic]` (Automatic = `$ClaudeOutputMode`)。
- `ClaudeRunOrchestration[..., "OutputMode" -> Automatic]`。
  `iOrchResolveOutputMode` で解決。Batch または commit がブロックリスクを
  持つとき (§5C.5)、committer 出力を `NBBeginDeferredOutput` → commit →
  `NBFlushDeferredOutput` で囲む。同期版はメイン評価なので Flush が効く。
- **NBAccess/claudecode 単体の単発実行ではオプションは実質無影響** (出力 1 個
  なので逐次=バッチ。エラーにはならない)。マルチターン/RepeatInterval/
  Orchestrator 並列で差が出る。

### 5C.5 BlockingRisk 連携 (ブロック回避の自動集約)

同期版 `ClaudeRunOrchestration` の commit 判定で、`outputMode` と commit の
ブロックリスク見積もりを `NBResolveOutputMode` に渡す。

- `iOrchEstimateCommitBlockingRisk[reduceResult]`: artifact 数が閾値 (8) 以上
  なら `"MayBlockFrontEnd"`。
- これにより **Streaming でも artifact が多いと自動集約** され、ブロックを
  回避する。Orchestrator の並列ワーカーは元々 artifact producer に限定
  (NotebookWrite 禁止) で出力は committer に集約される設計なので、この
  committer 出力を Batch/ブロックリスク時にまとめる。

### 5C.6 マルチターンは逐次のままが正しい (実装しない判断)

`ContinueEval` (ユーザー駆動マルチターン) は各呼び出しがメイン評価で、
ユーザーが 1 回ずつ呼ぶので **その都度出力されるのが自然**。集約すると各ターンの
結果が見られなくなり、§5C.1 の方針 (ブロックしないなら逐次が望ましい) に
反する。したがってマルチターン集約は実装しない。RepeatInterval / 連鎖呼び出しは
scheduled task 内実行で罠 #30 の壁にぶつかり、§22 (非同期版集約) と同じ問題に
なる。


## 6. claudecode.wl 改修仕様

### 6.1 Backend registry

`claudecode.wl` に最小の実行バックエンドレジストリを置く。

```wl
If[! AssociationQ[$ClaudeExecutionBackends],
  $ClaudeExecutionBackends = <||>
];

$ClaudeManagedExecutionInstalled = False;

ClaudeRegisterExecutionBackend[name_String, evaluator_, meta_: <||>] :=
 Module[{},
   $ClaudeExecutionBackends[name] = <|
     "Evaluator" -> evaluator,
     "Meta" -> meta
   |>;

   If[TrueQ[Lookup[meta, "DisablesLegacy", False]],
     $ClaudeManagedExecutionInstalled = True
   ];

   name
 ];
```

### 6.2 Backend resolution

```wl
ClaudeCurrentExecutionBackend[capability_: "SingleCall"] :=
 Module[{candidates},
   candidates =
     Select[
       Normal[$ClaudeExecutionBackends],
       MemberQ[Lookup[#["Meta"], "Capabilities", {}], capability] &
     ];

   If[candidates === {},
     Return["Legacy"]
   ];

   First @ ReverseSortBy[
     candidates,
     Lookup[#["Meta"], "Precedence", 0] &
   ]
 ];
```

### 6.3 `ClaudeEval` dispatcher

```wl
ClaudeEval[args___] :=
 Module[{backend},
   backend = ClaudeCurrentExecutionBackend["SingleCall"];

   If[backend === "Legacy",
     Return[ClaudeCodeLegacyEvaluate[args]]
   ];

   backend["Evaluator"][args]
 ];
```

### 6.4 Legacy execution guard

Runtime/Orchestratorロード後、旧実行器は失敗させる。

```wl
ClaudeAssertLegacyExecutionAllowed[] :=
 If[TrueQ[$ClaudeManagedExecutionInstalled],
   Throw[
     Failure[
       "LegacyExecutionDisabled",
       <|
         "Message" -> "Raw claudecode execution is disabled under managed execution.",
         "Backend" -> ClaudeCurrentExecutionBackend[]
       |>
     ],
     $ClaudeExecutionAbortTag
   ]
 ];
```

旧実行入口では必ず呼ぶ。

```wl
ClaudeCodeLegacyEvaluate[args___] :=
 Module[{},
   ClaudeAssertLegacyExecutionAllowed[];
   ClaudeCodeLegacyEvaluateImpl[args]
 ];
```

### 6.5 LegacyStandalone warning

既存Notebookを壊さないため、LegacyStandaloneでは初回のみ警告にする。

```wl
ClaudeLegacyModeWarning[] :=
 If[! TrueQ[$ClaudeLegacyModeWarningShown],
   Message[ClaudeEval::legacy,
     "claudecode legacy execution path is active. Load ClaudeRuntime for managed execution."
   ];
   $ClaudeLegacyModeWarningShown = True;
 ];
```

### 6.6 `iShouldExecuteAsync`

`iShouldExecuteAsync` は薄いwrapperへ変更する。

```wl
iShouldExecuteAsync[heldExpr_, accessSpec_Association, effectiveTimeout_] :=
  Module[{},
    If[! TrueQ[NBAccess`NBSubkernelExecutableQ[heldExpr, accessSpec]],
      Return[False]
    ];

    (* 性能heuristic。ForceがTrueならこの部分だけ上書き可 *)
    True
  ]
```

旧 `iCodeRefsConfidential`, `iCodeRefsLocalContext`, `iCodeRefsForbiddenOrApprovalHead` は、公開判断点ではなく `NBSubkernelExecutableQ` の内部ヘルパーへ格下げする。

### 6.7 `iSubmitParallelExecution`

```wl
iSubmitParallelExecution[heldExpr_, accessSpec_Association, effectiveTimeout_] :=
  Module[{nKernels, ok, future},
    nKernels = iEnsureParallelKernelsForRuntime[];
    If[!IntegerQ[nKernels] || nKernels === 0, Return[None]];

    If[! TrueQ[NBAccess`NBSubkernelExecutableQ[heldExpr, accessSpec]],
      Return[None]
    ];

    ok = iEnsureNBAccessOnParallelKernels[accessSpec];
    If[! TrueQ[ok], Return[None]];

    future = Quiet @ Check[
      With[{he = heldExpr, spec = accessSpec, tt = effectiveTimeout},
        ParallelSubmit[
          NBAccess`NBExecuteHeldExprSubkernelRaw[
            he, spec, "TimeConstraint" -> tt
          ]
        ]
      ],
      $Failed
    ];

    If[future === $Failed, Return[None]];

    <|
      "Async" -> True,
      "Future" -> future,
      "HeldExpr" -> heldExpr,
      "Timeout" -> effectiveTimeout,
      "StartTime" -> AbsoluteTime[],
      "ResultShape" -> "RawCompatible",
      "AccessSpecDigest" ->
        Lookup[Lookup[accessSpec, "PolicySnapshot", <||>], "Digest", None]
    |>
  ]
```

### 6.8 `iEnsureNBAccessOnParallelKernels`

```wl
iEnsureNBAccessOnParallelKernels[accessSpec_Association] -> True | False
```

必須挙動:

1. subkernelに `NBAccess`` をロードする。
2. `NBExecuteHeldExprSubkernelRaw`, `NBSubkernelExecutableQ`, `NBAcceptPolicySnapshot`, `iNBComputePolicyDigest` が存在することを確認する。
3. `accessSpec["PolicySnapshot"]` を各subkernelに渡し、`NBAcceptPolicySnapshot[snapshot]` が `"Valid" -> True` を返すことを確認する。
4. 1つでも失敗したらFalse。
5. Falseの場合、`iSubmitParallelExecution` はasync投入せず `None` を返す。
6. 失敗理由はdebug logに残す。

### 6.9 同期fallback

Phase35 / vision fallback / `effectiveTimeout === Infinity` の直 `ReleaseHold` は廃止する。

置換:

```wl
NBAccess`NBExecuteHeldExpr[
  heldExpr,
  accessSpec,
  "TimeConstraint" -> effectiveTimeout
]
```

### 6.10 accessSpec作成と呼び出し点確認

ExecuteProposalの冒頭で `NBMakeRuntimeAccessSpec` を呼び、`confVarNames` を `accessSpec["ConfidentialSymbols"]` に統合する。

Phase B作業項目として、既存の

```wl
iSubmitParallelExecution[heldExpr, effectiveTimeout]
```

呼び出し点で `accessSpec` が既に構築済みであることを確認し、

```wl
iSubmitParallelExecution[heldExpr, accessSpec, effectiveTimeout]
```

に変更する。

---

## 7. `With` / `ParallelSubmit` / `Evaluate` の確認仕様

### 7.1 事前判断

`With[{he = heldExpr}, ParallelSubmit[... he ...]]` の `he` は、すでに評価済みの `HoldComplete[...]` に束縛される。  
`HoldComplete` が保たれている限り、内部式の `Evaluate[...]` が意図せず露出・実行されることはない。

ただし、`ParallelSubmit` はsubkernelへ送る式を準備する過程があるため、Phase A0では実証テストを行う。

### 7.2 Phase A0確認fixture

```wl
held = HoldComplete[Evaluate[1 + 1]];

res = With[{he = held},
  HoldComplete[
    NBAccess`NBExecuteHeldExprSubkernelRaw[
      he,
      <|"PolicySnapshot" -> snapshot|>,
      "TimeConstraint" -> Infinity
    ]
  ]
];
```

期待:

- `res` 内の `he` は `HoldComplete[Evaluate[1 + 1]]` として保持される。
- `Evaluate[1 + 1]` が事前に `2` へ変化しない。

### 7.3 ParallelSubmit実証

```wl
future = With[{he = held, spec = accessSpec},
  ParallelSubmit[
    NBAccess`NBExecuteHeldExprSubkernelRaw[
      he, spec, "TimeConstraint" -> Infinity
    ]
  ]
];

WaitAll[{future}]
```

期待:

- `NBSubkernelExecutableQ[held, accessSpec]` はFalse。
- `iSubmitParallelExecution` はfuture投入前に `None` を返す。
- 直接 `NBExecuteHeldExprSubkernelRaw` を呼んだ場合でも `$Failed` を返す。
- `Evaluate[1 + 1]` が実行されて `2` になることはない。

### 7.4 二重安全

`Evaluate` を含む式は、main側 `NBSubkernelExecutableQ` でfuture投入前に拒否する。  
`NBExecuteHeldExprSubkernelRaw` 側の拒否は二重安全策である。

---

## 8. ClaudeRuntime.wl 改修仕様

### 8.1 Runtimeの責務

`ClaudeRuntime` は単一LLM呼び出しを1つの安全なtransactionとして扱う。

責務:

1. prompt materialization
2. route decision
3. LLM call
4. output parsing
5. held expression normalization
6. NBAccess accessSpec construction
7. optional execution through NBAccess
8. result packaging
9. audit/log

Runtimeは自前で `ReleaseHold` しない。

### 8.2 Backend登録

`ClaudeRuntime.wl` ロード時:

```wl
ClaudeRegisterExecutionBackend[
  "Runtime",
  ClaudeRuntimeEvaluate,
  <|
    "Precedence" -> 100,
    "Capabilities" -> {"SingleCall"},
    "DisablesLegacy" -> True
  |>
]
```

### 8.3 Async result shape

P0ではasync future result shapeを変えない。

```text
Future result = raw value | $Failed | $TimedOut
```

`iAsyncExecutionTickFn` はfutureの生値を従来通り `RawResult` に包む。  
将来のAssociation result移行に備えて `iNormalizeAsyncExecutionResult` を追加してもよいが、P0 acceptanceはRawCompatible維持である。

### 8.4 Async inventory

Phase B前に以下をinventoryする。

```text
Future
RawResult
WaitNext
iAsyncExecutionFinalize
iAsyncExecutionTickFn
iExecuteAndContinueSyncFinalize
RedactResult
LastExecutionResult
SaveLastPrompt
ContinuationInput
ShouldContinue
NotebookCallback
```

成果物:

```text
async_result_shape_inventory.md
```

---

## 9. ClaudeOrchestrator.wl 改修仕様

### 9.1 Orchestratorの責務

`ClaudeOrchestrator` は、複数Runtime callやtool callからなるworkflow全体を制御する。

責務:

- workflow plan
- step scope
- checkpoint
- approval gate
- snapshot / restore
- cumulative risk budget
- privacy taint propagation
- evidence bundle
- SourceVault記録

Orchestratorは自前で `ReleaseHold` しない。

### 9.2 Runtimeを経由しないReleaseHoldは禁止

以下はP0で改修する。

- Committerの `ReleaseHold[rewritten]`
- directLLM code rescueの `ToExpression -> iRewriteCommitterHeldExpr -> ReleaseHold`

### 9.3 Committerはmain kernel限定

Committerは `iSubmitParallelExecution` を通らない。

```text
Committer
  -> NBMakeRuntimeAccessSpec[..., "Committer"]
  -> NBExecuteHeldExpr[..., "PreExecutionNotebookActions" -> {...}]
  -> ReleaseHold is internal to NBExecuteHeldExpr
```

### 9.4 `SelectionMove` の時系列維持

現行Committerでは、描画位置制御のために `ReleaseHold` 直前に

```wl
SelectionMove[targetNb, After, Notebook]
```

を行っている。  
この順序は維持する。

置換先:

```wl
"PreExecutionNotebookActions" -> {
  <|
    "Action" -> "MoveSelectionAfterNotebook",
    "Notebook" -> targetNb,
    "Reason" -> "CommitterTargetInsertionPoint"
  |>
}
```

`NBExecuteHeldExpr` はこのpre-actionを `ReleaseHold` 直前に実行する。

### 9.5 Committerと`NotebookWrite`

`NotebookWrite` はP0でapproval headになる。  
したがってCommitterがraw `NotebookWrite` を含む場合、既定では `NeedsApproval` で停止する。

P0の選択肢:

1. workflowをapproval待ちで停止する。
2. 既存UI上で明示承認されたCommitter stepだけ `ApprovalMode -> "PreApprovedCommitter"` 相当で実行する。
3. raw `NotebookWrite` を使わず、NBAccessの承認済みNotebook action APIへ書き換える。

P0の安全標準は 1。  
既存自動commit互換を優先する場合のみ 2 を採用する。

2を採用する場合はauditに必ず残す。

```wl
<|
  "ApprovalBypass" -> "PreApprovedCommitter",
  "ExecutionRole" -> "Committer",
  "Head" -> "NotebookWrite"
|>
```

### 9.6 `iParseAsCellList` 等の構造復元ReleaseHold

`Cell[...]` / `BoxData[...]` の構造復元目的で、評価を伴わないunwrappingは実行境界の対象外にできる。

ただし分類表でC分類として明示し、未分類ReleaseHoldはCI失敗にする。

### 9.7 Orchestrator backend登録

`ClaudeOrchestrator.wl` ロード時:

```wl
ClaudeRegisterExecutionBackend[
  "Orchestrator",
  ClaudeOrchestratorRun,
  <|
    "Precedence" -> 200,
    "Capabilities" -> {"Workflow"},
    "DisablesLegacy" -> True
  |>
]
```

単一呼び出しは原則Runtimeへ残す。

```text
ClaudeEval[...]                 -> ClaudeRuntimeEvaluate
ClaudeWorkflowRun[...]          -> ClaudeOrchestratorRun
ClaudeEval[..., "ExecutionMode" -> "Workflow"] -> Orchestrator optional
```

---

## 10. Claude Directives / 非同期基盤保全

### 10.1 保全すべき現行設計

Claude Directivesの `rules/95` / `rules/100` の趣旨を守る。

P0不変条件:

- frontendを長時間ブロックしない。
- `AsyncToolExecScheduled` は早期returnする。
- 独自のScheduledTaskをむやみに増やさない。
- 共有polling tickを壊さない。
- `StartProcess + polling tick` の既存設計を壊さない。
- `ParallelSubmit` は全面禁止ではない。
- ただし、tool並列実行へ安易に `ParallelSubmit` を新規導入しない。
- 提案式本体の非同期実行に既に使われている `ParallelSubmit` は維持し、内部評価点をNBAccessへ差し替える。

### 10.2 `ParallelSubmit` の位置づけ

誤った理解:

```text
ParallelSubmit is forbidden.
```

正しい理解:

```text
ParallelSubmit for existing proposal evaluation is preserved.
ParallelSubmit[ReleaseHold[...]] is forbidden.
ParallelSubmit[NBExecuteHeldExprSubkernelRaw[...]] is allowed.
```

### 10.3 subkernel実行の制約

subkernelは安全な純粋計算だけを行う。  
次はsubkernel不可:

- FrontEnd利用
- Notebook書き換え
- ファイル書き込み
- 外部プロセス起動
- ネットワーク
- confidential/local context参照
- approval/deny/unknown head
- `Screen(WarnOnly)` 実行

---

## 11. SourceVault / PromptRouterとの関係

SourceVault / PromptRouterは、本仕様の直接P0対象ではないが、以下を守る。

- PromptRouter route decisionはaccessSpecの `Caller`, `WorkflowID`, `StepID`, `PermissionMode`, `PolicySnapshot` と整合させる。
- SourceVaultからprivate materialを取り出したstepは、Orchestratorのtaint propagationにより後続stepへ伝播する。
- Cloud routeへ送る場合、NBAccess/SourceVault側のprivacy policyを超えてはならない。
- EncryptedVaultやKeyRefは別仕様で扱う。ただし、本仕様のNBAccess強制境界を迂回してはならない。

---

## 12. Phase A0: 実装前調査成果物

P0実装前に、次の成果物を作る。

### 12.1 `nbaccess_policy_snapshot_inventory.md`

含める内容:

- `$NBAllowedHeads`
- `$NBApprovalHeads`
- `$NBDenyHeads`
- `$NBConfidentialSymbols`
- `$NBAllowedHeadsByCategory`
- `$NBDisabledCategories`
- `NBCategoryEnabled` の挙動
- `NotebookWrite` の分類結果
- `Evaluate` の分類結果
- snapshot modeで参照禁止にすべきhelper一覧

必須確認:

```text
NotebookWrite:
  現行分類 = unknown / RepairNeeded
  P0補正後 = NeedsApproval

Evaluate:
  現行分類 = Deny
  P0補正後 = Deny維持
```

### 12.2 `async_result_shape_inventory.md`

含める内容:

- future resultが生値である前提の箇所
- `$Failed` / `$TimedOut` の扱い
- `RawResult` 包装箇所
- redactionが走る箇所
- continuation判定が生値を期待している箇所

### 12.3 `releasehold_inventory.md`

全 `ReleaseHold` を分類する。

| 分類 | 意味 | P0扱い |
|---|---|---|
| A | エージェント由来式の実行 | NBAccessへ移行必須 |
| B | NBAccess内部の唯一実行点 | 許可 |
| C | 構造復元・unwrappingのみ | 明示allowlist |
| D | テストfixture | テスト専用allowlist |

CI規則:

- 分類表にない `ReleaseHold` が1つでも出たら失敗。
- 新規 `ReleaseHold` はdefaultでA分類扱い、すなわちCI失敗。
- allowlistには行番号だけでなく、周辺テキストhashを持たせる。

### 12.4 snapshot decision fixture

Phase A0で実際のpolicy dumpから代表headを選ぶ。

最低3種類:

1. allowed headのみの式
2. approval headを含む式
3. confidential symbolを参照する式

テスト形:

```wl
mainDecision =
  NBValidateHeldExpr[held, spec, "PolicySnapshot" -> snapshot];

subDecision =
  First @ ParallelEvaluate[
    NBAccess`NBValidateHeldExpr[held, spec, "PolicySnapshot" -> snapshot]
  ];

mainDecision["Decision"] === subDecision["Decision"]
```

fixture選定規則:

- allowed headは実際の `$NBAllowedHeads` から選ぶ。
- approval headは実際の `$NBApprovalHeads` から選ぶ。
- confidential fixtureはPhase A0で一時的に `$NBConfidentialSymbols` に登録したsymbolを使う。
- `NotebookWrite` はP0補正前後の差分fixtureとして別枠にする。

### 12.5 `Evaluate` fixture

```wl
held = HoldComplete[Evaluate[1 + 1]]
```

期待:

- main snapshot-aware validation: `Decision -> "Deny"`
- `NBSubkernelExecutableQ`: `False`
- `iSubmitParallelExecution`: `None`
- subkernel raw wrapper: `$Failed`

追加確認:

`With[{he = heldExpr}, ParallelSubmit[...he...]]` の値展開により、`HoldComplete[...]` の中へ意図しない `Evaluate` が混入・実行されないことを実証する。

---

## 13. Phase A1: NBAccess policy補正

### 13.1 `NotebookWrite` の初期approval化

`$NBApprovalHeads` 初期定義に `"NotebookWrite"` を直接追加する。

期待:

```wl
NBValidateHeldExpr[HoldComplete[NotebookWrite[...]], spec]["Decision"]
  === "NeedsApproval"
```

### 13.2 `Evaluate` deny維持

`Evaluate` は `$NBDenyHeads` に維持する。

### 13.3 snapshot helper整備

P0で実装する内部ヘルパー:

```wl
iNBNormalizePolicySnapshotPayload
iNBComputePolicyDigest
iNBSnapshotAllowedHeads
iNBSnapshotApprovalHeads
iNBSnapshotDenyHeads
iNBSnapshotConfidentialSymbols
```

これらはsnapshot modeの判定入力をすべてsnapshotから取り出すためのヘルパーである。  
カテゴリglobalへフォールバックしてはならない。

---

## 14. Phase B: snapshot-aware validation / C-lite classification

実装項目:

1. `NBValidateHeldExpr` に `"PolicySnapshot"` / `"RecomputeAllowedHeads"` options追加。
2. snapshot modeではカテゴリglobal/API参照を完全排除。
3. `iContainsConfidentialLeak` は2引数のまま維持。
4. snapshot modeではaccessSpecにsnapshot由来 `ConfidentialSymbols` を注入。
5. main/subkernel decision一致テスト。
6. snapshot不正時は `Deny / InvalidPolicySnapshot`。
7. unknown headを一律 `RepairNeeded` にしない。
8. unknown System` builtinをC-lite分類へ送る。
9. user-defined / package unknown headは `NeedsApproval` にする。
10. `RepairNeeded` は構造修復が必要な場合に限定する。
11. `ExecutionPlacement`, `BlockingRisk`, `MayRunAsync`, `RequiresFinalNode` metadataを返す。
12. `EffectClass` と `ApprovalEligibility` を返す。
13. `$ClaudePermissionMode` によるfinal decision変換を入れる。

---

## 15. Phase C: NBExecuteHeldExpr / subkernel raw / approval execution

実装項目:

1. `NBExecuteHeldExpr` を唯一のmain実行点にする。
2. `NBExecuteHeldExprSubkernelRaw` を実装する。
3. `NBSubkernelExecutableQ` を実装する。
4. `iShouldExecuteAsync` を薄いwrapper化する。
5. `iSubmitParallelExecution` を `NBExecuteHeldExprSubkernelRaw` 経由へ変更する。
6. `iEnsureNBAccessOnParallelKernels` をTrue/False返却へ変更する。
7. `Phase35` / vision fallback等の直 `ReleaseHold` を撤去する。
8. `TimeConstraint === Infinity` は `TimeConstrained` を使わず処理する。
9. `ApprovalMode -> "UserApproved"` を受け取り、`AskUserAllowed` 由来の `NeedsApproval` を実行可能にする。
10. `HardDeny` 由来の `Deny` は `ApprovalMode` があっても実行しない。

---

## 16. Phase D: Orchestrator / legacy closure

実装項目:

1. Orchestrator Committerのdirect `ReleaseHold` を撤去。
2. directLLM rescueのdirect `ReleaseHold` を撤去。
3. `iParseAsCellList` 等の構造復元ReleaseHoldをC分類としてinventory化。
4. `claudecode.wl` legacy pathはRuntime/Orchestratorロード後に閉鎖。
5. `ClaudeExecutionStatus[]` / Doctor系に現在modeを表示。

---

## 17. テスト・受け入れ条件

### 17.1 snapshot digest

- `NBPolicySnapshot[]` が返すdigestを `NBAcceptPolicySnapshot` が同じヘルパーで検証する。
- digestはAssociation key順序に依存しない。
- head listの順序に依存しない。
- `ConfidentialSymbols` がListでもAssociationでも正規化される。
- main/subkernelでdigest一致する。

### 17.2 snapshot-aware validation

- snapshot modeでは `iRecomputeAllowedHeads[]` が呼ばれない。
- snapshot modeでは `NBCategoryEnabled` が呼ばれない。
- snapshot modeでは `$NBAllowedHeadsByCategory` / `$NBDisabledCategories` を参照しない。
- main/subkernelで同じsnapshotを使ったdecisionが一致する。
- global `$NBConfidentialSymbols` を変更しても、snapshot mode decisionはsnapshot由来confに従う。

### 17.3 `NotebookWrite`

補正後:

```wl
HoldComplete[NotebookWrite[...]]
```

期待:

- `NBValidateHeldExpr`: `NeedsApproval`
- `NBSubkernelExecutableQ`: `False`
- `iSubmitParallelExecution`: `None`
- `NBExecuteHeldExpr`: 既定では実行しない
- 承認済みCommitter pathを採用する場合だけmain kernelで実行可能

### 17.4 `Evaluate`

```wl
HoldComplete[Evaluate[1 + 1]]
```

期待:

- `NBValidateHeldExpr`: `Deny`
- `NBSubkernelExecutableQ`: `False`
- `NBExecuteHeldExprSubkernelRaw`: `$Failed`
- `NBExecuteHeldExpr`: 実行しない
- `ParallelSubmit` 経由でも `Evaluate` が事前実行されない

### 17.5 Unknown head / C-lite classification

`Integrate[E^x, {x, 0, 1}]` のようなSystem` builtin計算式は、allow listにない場合でも `RepairNeeded` にならない。

期待:

```text
Decision -> Permit or NeedsApproval
ExecutionPlacement -> SubkernelSafe
BlockingRisk -> PossiblyLong
```

`Global` / user-defined unknown headは標準で `NeedsApproval` になる。

副作用語幹を持つSystem` unknown headは `NeedsApproval` または `Deny` になる。

`RepairNeeded` は、構文・構造・形式が壊れており再生成が必要な場合に限定される。

### 17.6 承認UI整合

- `Deny` では実行/中止ボタンを出さない。
- `NeedsApproval` でのみ承認UIを出す。
- 承認された場合、`ApprovalMode` またはticketが `NBExecuteHeldExpr` まで届く。
- 承認後に最終NBAccess判定で再び `Deny` されるようなUI不一致をなくす。
- `SystemOpen` はraw実行より専用 `NBOpenFolderWithApproval[path]` へ寄せる。

### 17.7 Async互換

- `ParallelSubmit` 自体は提案式本体実行のため維持される。
- `ParallelSubmit[ReleaseHold[...]]` は残らない。
- `NBExecuteHeldExprSubkernelRaw` 経由になっている。
- future result shapeは生値互換のまま。
- redactionはmain側で走る。
- `$ClaudeRuntimeAsyncForce=True` でもNBAccessのsubkernel拒否は上書き不可。

### 17.8 Orchestrator Committer

- Committerはmain kernel限定。
- `SelectionMove[targetNb, After, Notebook]` 相当のpre-actionは `ReleaseHold` 直前に実行される。
- raw `ReleaseHold[rewritten]` は残らない。
- `NotebookWrite` がapproval headになっているため、既定では承認なしに実行されない。
- 自動commit互換を維持する場合は、明示承認済みCommitter modeをaudit付きで導入する。

### 17.9 LegacyStandalone

`NBAccess + claudecode.wl` のみをロードした環境で:

```wl
ClaudeEval[...]
```

が動作する。

ただし内部実行はNBAccessを通る。

### 17.10 Runtime/Orchestratorロード後

Runtimeロード後:

```text
ClaudeEval -> ClaudeRuntimeEvaluate
legacy raw execution -> Failure["LegacyExecutionDisabled"]
```

Orchestratorロード後:

```text
Workflow -> ClaudeOrchestratorRun
SingleCall -> ClaudeRuntimeEvaluate
legacy raw execution -> Failure["LegacyExecutionDisabled"]
```

### 17.11 ReleaseHold inventory CI

- 未分類 `ReleaseHold` はCI失敗。
- 新規 `ReleaseHold` はdefault deny。
- allowlistは分類・ファイル・周辺テキストhashを持つ。

---

## 18. `ClaudeExecutionStatus[]`

運用上、現在どの経路で動いているか確認できる関数を追加する。

```wl
ClaudeExecutionStatus[] -> Association
```

例: LegacyStandalone

```wl
<|
  "Mode" -> "LegacyStandalone",
  "ManagedExecutionInstalled" -> False,
  "LegacyExecutionAllowed" -> True,
  "SingleCallBackend" -> "claudecode",
  "WorkflowBackend" -> None,
  "NBAccessEnforced" -> True
|>
```

例: RuntimeManaged

```wl
<|
  "Mode" -> "RuntimeManaged",
  "ManagedExecutionInstalled" -> True,
  "LegacyExecutionAllowed" -> False,
  "SingleCallBackend" -> "Runtime",
  "WorkflowBackend" -> None,
  "NBAccessEnforced" -> True
|>
```

例: OrchestratorManaged

```wl
<|
  "Mode" -> "OrchestratorManaged",
  "ManagedExecutionInstalled" -> True,
  "LegacyExecutionAllowed" -> False,
  "SingleCallBackend" -> "Runtime",
  "WorkflowBackend" -> "Orchestrator",
  "NBAccessEnforced" -> True
|>
```

Doctor系にも組み込む。

---

## 19. 依存API一覧

### P0必須

```wl
NBPolicySnapshot
NBAcceptPolicySnapshot
NBValidateHeldExpr  (* snapshot-aware化 *)
NBMakeRuntimeAccessSpec
NBSubkernelExecutableQ
NBExecuteHeldExpr
NBExecuteHeldExprSubkernelRaw
NBHashHeldExpr
ClaudeRegisterExecutionBackend
ClaudeCurrentExecutionBackend
ClaudeExecutionStatus
```

内部helper:

```wl
iNBNormalizePolicySnapshotPayload
iNBComputePolicyDigest
iNBSnapshotAllowedHeads
iNBSnapshotApprovalHeads
iNBSnapshotDenyHeads
iNBSnapshotConfidentialSymbols
NBValidateNotebookPreActions
```

### P1以降

```wl
NBIssueExecutionTicket
NBVerifyExecutionTicket
ClaudeRuntimeEvaluate  (* 本体が未整備ならP0では薄いshim可 *)
ClaudeOrchestratorEvaluate
PlanningFailedQ
SourceVaultEncryptedPut
SourceVaultEncryptedGet
```

ExecutionTicketはP1でよい。  
P0では `NBExecuteHeldExpr` の再検証とsnapshot-aware validationで安全境界を確保する。

---

## 20. 実装順序

### Phase A0: inventory / fixture作成

1. `nbaccess_policy_snapshot_inventory.md`
2. `async_result_shape_inventory.md`
3. `releasehold_inventory.md`
4. snapshot decision fixtures
5. `Evaluate` fixture
6. `With` / `ParallelSubmit` / `Evaluate` 事前評価確認

### Phase A1: NBAccess policy補正

1. `$NBApprovalHeads` 初期定義に `"NotebookWrite"` 追加
2. `Evaluate` deny維持確認
3. digest helper実装
4. `NBPolicySnapshot[]` 実装
5. `NBAcceptPolicySnapshot[]` 実装

### Phase B: snapshot-aware validation

1. `NBValidateHeldExpr` options追加
2. snapshot modeでカテゴリglobal/API参照排除
3. `ConfidentialSymbols` をaccessSpecへ注入
4. main/subkernel decision一致テスト

### Phase C: NBAccess execution boundary

1. `NBExecuteHeldExpr`
2. `NBExecuteHeldExprSubkernelRaw`
3. `NBSubkernelExecutableQ`
4. `iShouldExecuteAsync`
5. `iSubmitParallelExecution`
6. `iEnsureNBAccessOnParallelKernels`
7. direct `ReleaseHold`撤去

### Phase D: Runtime / Orchestrator / legacy closure

1. Runtime backend登録
2. Orchestrator backend登録
3. legacy raw path閉鎖
4. Committer direct ReleaseHold撤去
5. `ClaudeExecutionStatus[]`
6. Doctor統合

---


## 20A. `$ClaudePermissionMode` 導入の実装順序

現行実装からの差分は、次の順序で入れる。

### Step 1: metadata併存

`NBValidateHeldExpr` が既存 `Decision` を返し続けたまま、次を追加する。

```wl
"EffectClass"
"ApprovalEligibility"
"ExecutionPlacement"
"BlockingRisk"
"RequiresFinalNode"
"PermissionMode"
"ModeTransformApplied"
```

この段階では既存 `Decision` 依存コードを壊さない。

### Step 2: mode変換層

`ApprovalEligibility × PermissionMode -> Decision` を `NBValidateHeldExpr` の最後に一度だけ適用する。

```wl
NBApplyPermissionMode[classification_Association, accessSpec_Association]
```

`PermissionMode` はglobalではなく `accessSpec["PermissionMode"]` を使う。

### Step 3: action registry最小実装

`OpenDesktopItem` だけを実装する。

```text
SystemOpen[folder]
  -> OpenDesktopItem action
  -> AskUserAllowed
  -> InteractiveSafeなら承認UI
  -> 承認後 NBExecuteApprovedAction
```

### Step 4: Orchestrator final node分離

`RequiresFinalNode -> True` のstepを通常stepから分離し、final action nodeへ集約する。

### Step 5: P1拡張

ExecutionTicket、追加action、user function safety metadata、UI/Doctor統合を行う。

## 21. 最終判断

本仕様は、v1〜v6の議論を統合した最終版である。

最重要判断は次である。

1. `NBAccess + claudecode.wl` のみのLegacyStandalone互換は維持する。
2. `ClaudeRuntime` / `ClaudeOrchestrator` ロード後は、`claudecode.wl` の旧実行経路を閉鎖する。
3. Runtimeは単一LLM呼び出しの安全transaction層、Orchestratorはworkflow安全制御層、NBAccessは両者が必ず通る最終強制境界とする。
4. 提案式本体実行に使われる既存 `ParallelSubmit` は維持する。ただし中の評価は `NBExecuteHeldExprSubkernelRaw` 経由にする。
5. future result shapeはP0では変えない。
6. redactionはmain側を正とし、subkernelへ送れる式を厳格に制限する。
7. snapshot modeではカテゴリglobal/APIを参照せず、導出済みhead listだけでmain/subkernel decisionを一致させる。
8. `NotebookWrite` は初期approval headに追加し、`Evaluate` はdeny維持する。
9. `iContainsConfidentialLeak` は既存2引数を維持し、snapshot由来 `ConfidentialSymbols` はaccessSpecへ注入する。
10. digestは `KeySort` 済みpayloadの `InputForm` 文字列で計算する。
11. 未分類 `ReleaseHold` はCI失敗にする。
12. unknown headは一律 `RepairNeeded` にせず、C-lite分類へ送る。
13. `AllowedHeads` は唯一の許可集合ではなく、無承認Permit高速パスとする。
14. 安全性判定と実行配置判定を分離し、`ExecutionPlacement` / `BlockingRisk` を返す。
15. FrontEnd/副作用/ブロックリスクの高い処理はOrchestratorのfinal nodeへ分離する。
16. 案B、すなわちdefault permit + deny list only方式は標準モードでは採用しない。
17. `$ClaudePermissionMode` を導入し、`AutoPermit` / `AskUserAllowed` / `HardDeny` / `RepairRequired` をmodeごとに最終Decisionへ変換する。
18. `NBOpenFolderWithApproval` のような個別関数は正本にせず、`OpenDesktopItem` などの汎用action registry + permission modeで扱う。
19. Approveボタンは `AskUserAllowed` かつpermission modeが許す場合だけ出す。`HardDeny` では出さない。
20. 承認後は `ApprovalMode` またはExecutionTicketが `NBExecuteHeldExpr` まで届くようにする。
21. `NBValidateHeldExpr` は既存 `Decision` を維持しつつ、`EffectClass` / `ApprovalEligibility` を追加キーとして返す段階移行にする。
22. EffectClass tableは必須allowlistではなく、分類精度向上の任意上書きとする。
23. Action executorはNBAccess内部に置き、実行直前に再validateしてTOCTOUを防ぐ。
24. PermissionModeはaccessSpec/snapshotに固定し、実行中にglobalを読み直さない。

この仕様により、既存のMathematica非同期実行基盤を壊さず、通常の数学・記号計算を過剰拒否しない形で、`ClaudeEval` 系全体をNBAccess強制実行境界へ収容できる。


---

# Phase A0 追補 — 実コード突合後に必ず反映する具体事項

作成日: 2026-06-03  
位置づけ: `phaseA0_findings.md` を反映した最終仕様への追補。  
この追補は本仕様の骨格を変更しないが、実装時の必須事項として扱う。

---

## A0-1. `iContainsConfidentialLeak` の Association/ListQ 不整合をPhase Bで修正する

本項は §4.5 のAPI外形を具体化する内部実装修正である。実装時は §4.5 と本項を一体として扱う。

### 問題

現行 `NBAccess.wl` の `iContainsConfidentialLeak` は、概ね次の構造になっている。

```wl
iContainsConfidentialLeak[heldExpr_, accessSpec_Association] :=
  Module[{confSyms, exprStr},
    confSyms = Lookup[accessSpec, "ConfidentialSymbols",
      If[ListQ[$NBConfidentialSymbols], $NBConfidentialSymbols, {}]];
    If[Length[confSyms] === 0, Return[False]];
    exprStr = ToString[heldExpr, InputForm];
    AnyTrue[confSyms, StringContainsQ[exprStr, ToString[#]] &]
  ];
```

この実装には2つの問題がある。

1. `$NBConfidentialSymbols` はAssociationであるのに、fallback側が `ListQ` の場合だけ採用するため、`accessSpec["ConfidentialSymbols"]` が無い場合はconfidential検査が実質無効になる。
2. `ConfidentialSymbols` がAssociationの場合、`AnyTrue` はAssociationのvalues側を走査するため、confidential symbol名、すなわちkeysではなく登録metadataを文字列照合してしまう。

このため、最終仕様の「snapshot modeでは `validationAccessSpec["ConfidentialSymbols"]` にsnapshot由来値を注入する」という方針だけでは不十分である。helper内部もAssociation対応に修正しなければならない。

### 必須修正

シグネチャは2引数のまま維持する。

```wl
iContainsConfidentialLeak[heldExpr_, accessSpec_Association] :=
  Module[{raw, confNames, exprStr},
    raw = Lookup[accessSpec, "ConfidentialSymbols", $NBConfidentialSymbols];

    confNames = Which[
      AssociationQ[raw],
        ToString /@ Keys[raw],
      ListQ[raw],
        ToString /@ raw,
      True,
        {}
    ];

    If[Length[confNames] === 0, Return[False]];

    exprStr = ToString[heldExpr, InputForm];
    AnyTrue[confNames, StringContainsQ[exprStr, #] &]
  ];
```

### 意図

- `ConfidentialSymbols` がAssociationならkeysをsymbol名として扱う。
- `ConfidentialSymbols` がListなら要素をsymbol名として扱う。
- fallback先は `$NBConfidentialSymbols` でよい。Association分岐でkeysを見るためである。
- snapshot digestではAssociationのkey/valueを正規化に含める一方、leak検査ではkey、つまりsymbol名だけを見る。この非対称は意図的である。

### 受け入れ条件

```wl
$NBConfidentialSymbols = <|"secretX" -> <|"Reason" -> "fixture"|>|>;

iContainsConfidentialLeak[
  HoldComplete[secretX + 1],
  <||>
] === True
```

```wl
iContainsConfidentialLeak[
  HoldComplete[secretX + 1],
  <|"ConfidentialSymbols" -> <|"secretX" -> <|"Reason" -> "snapshot"|>|>|>
] === True
```

```wl
iContainsConfidentialLeak[
  HoldComplete[publicX + 1],
  <|"ConfidentialSymbols" -> <|"secretX" -> <|"Reason" -> "snapshot"|>|>|>
] === False
```

Phase Bの作業項目「`iContainsConfidentialLeak` は2引数のまま維持し、snapshot由来 `ConfidentialSymbols` をaccessSpecへ注入する」に、この内部修正を含める。

---

## A0-2. `NBExecuteHeldExpr` のOptions拡張はPhase Cの明示タスクとする

現行 `NBExecuteHeldExpr` のOptionsは次だけである。

```wl
Options[NBExecuteHeldExpr] = {"TimeConstraint" -> 30};
```

最終仕様では次を要求する。

```wl
"TimeConstraint" -> 30
"ScreenMode" -> "Block"
"PolicySnapshot" -> Automatic
"PreExecutionNotebookActions" -> {}
"Audit" -> True
"ApprovalMode" -> "None"
```

Phase Cでは、現行の正式実行点を流用しつつ、次を被せる。

1. `NBValidateHeldExpr` の再呼び出し
2. `PolicySnapshot` 対応
3. `ScreenMode` 対応
4. `PreExecutionNotebookActions` の検証と `ReleaseHold` 直前実行
5. `TimeConstraint === Infinity` 分岐
6. Association戻り整形
7. audit

Phase C冒頭で、現行 `NBExecuteHeldExpr` の戻り値形状を確認する。  
sync経路の消費側がAssociationを期待しているため、最終形はAssociation戻りに統一する。

---

## A0-3. ReleaseHold inventory の確定事項

Phase A0調査により、A分類のエージェント由来 `ReleaseHold` は `claudecode.wl` と `ClaudeOrchestrator.wl` で実質5箇所と見なせる。  
また、CommitterとdirectLLM rescueは `ClaudeOrchestrator.wl` 側の1点に集約されているため、rescue専用の別実行点を新たに探す必要はない。

CIの `ReleaseHold[` 検出では、コメント文や文字列リスト内のtokenも拾う。  
したがって、次のどちらかを必須にする。

1. コメント・文字列を除外するgrep/parseロジックを入れる。
2. N分類、すなわち非コード検出箇所をallowlistに含める。

allowlistのhash計算では、CRLF/LF混在でhashがぶれないよう、改行正規化を行う。

---

## A0-4. Async future shape は現行維持でよい

Phase A0調査により、`NBExecuteHeldExprSubkernelRaw` が

```text
raw value | $TimedOut | $Failed
```

を返す限り、現行tick処理の3分岐は維持できる。

したがって、P0ではfuture result shapeを変更しないという最終仕様の判断を維持する。

---

## A0-5. Policy snapshot の確認済み前提

Phase A0調査で次が確認された。

```text
NotebookWrite:
  現行 = unknown / RepairNeeded
  P0補正後 = NeedsApproval

Evaluate:
  現行 = Deny
  P0補正後 = Deny維持

$NBConfidentialSymbols:
  現行 = Association

$NBAccessPolicyVersion:
  現行 = 未定義
```

したがって、最終仕様の判断を維持する。

- `NotebookWrite` は `$NBApprovalHeads` 初期定義に直接追加する。
- `Evaluate` は `$NBDenyHeads` に維持する。
- `NBPolicySnapshot[]` は `NBAccessPolicyVersion` 未定義時のfallbackを持つ。
- digest正規化はAssociation主経路を正とする。

---

## A0-6. 残る実走確認

Phase A0で静的には確認できたが、実Mathematica環境での実走が必要な残件は次である。

1. `$NBAllowedHeads` の実行時導出値の全列挙。
2. main/subkernel decision一致テスト。
3. `With[{he = held}, ParallelSubmit[...]]` で `HoldComplete[Evaluate[...]]` が事前評価されないことの実証。

これらはPhase A0完了条件として残す。

---

## A0-7. 実装順序への補足

Phase A1へ入る前に、`iContainsConfidentialLeak` のAssociation対応修正をPhase B必須タスクとして確定する。

推奨順序:

```text
1. NBAccess基盤:
   snapshot / digest / validate / confidential leak修正

2. NBExecuteHeldExpr:
   options拡張 / Association戻り / pre-action / Infinity対応

3. NBExecuteHeldExprSubkernelRaw:
   raw-compatible wrapper

4. claudecode:
   iSubmitParallelExecution差し替え

5. Orchestrator:
   Committer / directLLM rescue の direct ReleaseHold撤去
```

この追補により、最終仕様の意図とPhase A0の実コード突合結果が一致する。

---

# 22. 今後の課題: 非同期版の出力集約 (未実装)

作成日: 2026-06-03 (v3)

対策2 (出力モード) の NBAccess 基盤・ClaudeEval/ClaudeRunOrchestration
オプション・同期版 Orchestrator の committer 集約・BlockingRisk 連携は実装
済み (§5C)。しかし **非同期実行経路の出力集約は未配線** である。本章は今後の
着手のため、現在判明している関連事項を整理する。

## 22.1 問題の本質 (罠 #30)

FrontEnd 操作 (`NotebookWrite` / `CellPrint` / `SystemOpen` /
`NBFlushDeferredOutput`) は、**`SessionSubmit` / `ScheduledTask` / 共有 polling
tick の評価コンテキストでは silent no-op** になり、**メインカーネルのトップ
レベル評価 (Button 本体 `Method->"Queued"` を含む) でのみ効く**。

非同期実行経路はすべてこの壁にぶつかる:

- `ClaudeRunOrchestrationAsync`: 完了フック `iOnOrchestrationComplete` が
  scheduled task 内。commit も DAG ノード (scheduled task) で実行され FrontEnd
  を持たない。
- `RepeatInterval`: `SessionSubmit[ScheduledTask[...]]` で繰り返し実行。各回の
  出力が scheduled task 内。
- 連鎖呼び出し (ClaudeEval がコード内で ClaudeEval/ContinueEval を生成): 非同期
  経路。

これらは「集約バッファに溜める」ことはできる (`AppendTo` は変数操作なので
scheduled task でも安全) が、**最後の `NBFlushDeferredOutput` が scheduled task
内では効かない** ため、集約しても出力できない。

## 22.2 確立済みの解決パターン (§5.1 / ClaudeOrchestrationShowFinalActions)

同種の罠 #30 問題は、final action の承認 UI で既に解決している:

1. 完了フック (scheduled task) は **状態に保存するだけ**。notebook 書き込みは
   しない。
2. ユーザーがメインカーネル評価で取得 API
   (`ClaudeOrchestrationShowFinalActions[orchId]`) を呼んだとき、初めて
   FrontEnd 操作 (CellPrint / ボタン提示 / SystemOpen) を行う。

非同期版の出力集約も、この **「scheduled task では状態保存のみ → メイン評価の
取得 API でフラッシュ」** パターンで解くのが筋が良い。

## 22.3 想定される設計 (未確定)

1. 非同期版 commit (DAG ノード) で Batch モードなら、出力 Cell を notebook に
   書かず **orch 状態に保存** する (グローバルバッファ `$iNBDeferredCells` は
   scheduled task とメイン評価で同一カーネルなら共有されるが、確実性のため
   orch 状態に明示保存する方が安全)。
2. ユーザーがメイン評価で `ClaudeOrchestrationShowFinalActions` (または出力
   専用の取得 API、例えば `ClaudeOrchestrationFlushOutput[orchId]`) を呼んだ
   とき、保存された Cell をまとめて出力する。
3. §5.1 の final action 提示と統合すると自然 (完了時に「結果を表示」ボタンを
   出し、押下=メイン評価でフラッシュ)。

## 22.4 着手前に必要な調査 (リスク高)

- **非同期版の現状出力挙動の実機確認**: 現状 `ClaudeRunOrchestrationAsync` が
  commit 出力を notebook にどう出しているか (罠 #30 で元々出ていない可能性が
  高い) を実機で確認する。出ていないなら、そもそも非同期版は §5.1 の取得 API
  に依存している可能性がある。
- **DAG / ClaudeRuntime 深部の commit 実行経路の特定**: 非同期版の commit は
  `ClaudeCommitArtifacts` を DAG ノードのどこで呼ぶか (ClaudeRuntime 側の
  `iMakeTurnNodes` 等に埋まっている可能性) を追う必要がある。
- これらの調査が前提のため着手リスクが高い。実機で現状挙動を確認してからの
  着手を推奨する。

## 22.5 関連する実装済み資産

- `NBResolveOutputMode` / 出力遅延バッファ一式 (§5C.2, §5C.3): 非同期版でも
  そのまま使える (バッファ追加は scheduled task でも安全)。Flush だけが
  メイン評価制約を持つ。
- `ClaudeOrchestrationShowFinalActions` (§5.1): メイン評価でのフラッシュ
  パターンの実装例。
- `iOrchResolveOutputMode` / `iOrchEstimateCommitBlockingRisk` (§5C): 非同期版
  でもモード解決・ブロックリスク見積もりに再利用できる。

## 22.6 マルチターン集約は対象外

§5C.6 の通り、`ContinueEval` のマルチターンは逐次のままが正しい (ユーザーが
1 回ずつメイン評価で呼ぶので、その都度出力が自然)。本課題の対象は、scheduled
task 内で多数の出力が発生する非同期並列・繰り返し経路に限る。
