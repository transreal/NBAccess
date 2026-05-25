# NBAccess Phase 4: PrivacyLevel を超えたアクセス制御方針 改訂版 3  
## — 現行 `NBAuthorize` 実装確認を反映し、ScoreGate 主導防御を追加した実装前仕様

作成日: 2026-05-23  
改訂: 2026-05-23 revised3 — 現行 `NBAuthorize` のラベル未設定時 Pass 挙動、`EffectiveRiskScore` 補完、`Sink -> "CloudLLM"` 整合を反映  
対象: `NBAccess.wl`, `claudecode.wl`, `SourceVault.wl`, `ClaudeRuntime.wl`, `ClaudeOrchestrator.wl`  
位置づけ: cross-PC path 正規化 Phase 4 / NBAccess privacy policy v0.1 準拠の設計補足

---

## 0. 結論

`ReadableByAgent` / `WritableByAgent` / `CloudSendAllowed` / `PrivacyLevel` の 4 分離という方向性は妥当である。

ただし、`ReadableByAgent` や `CloudSendAllowed` を、NBAccess の中に独立した Boolean 権限としてアドホックに追加するのは避けるべきである。

採用すべき方針は、次である。

> `CloudSendAllowed` 等は一次ポリシーではなく、  
> `PolicyLabel + AccessRequest + Environment + EffectiveRiskScore` による `NBAuthorize` 判定結果の **projection field** として定義する。

さらに、現行 `NBAccess.wl` / `api.md` との関係を明確化する。

> `NBAuthorize[obj, req]` は現行 API に存在する。  
> 一方、`NBAuthorizeFile` / `NBMakeFileAccessRequest` / `NBAuthorizeContextBundle` / `NBPermitQ` は現行 API として前提にしてはいけない。  
> これらは Phase 4 で追加する wrapper / helper として扱う。

Phase 4 の基本方針は次の 6 点である。

```text
1. PrivacyLevel は当面凍結する。
2. CloudSendAllowed 等は NBAuthorize の projection として追加する。
3. NBAuthorizeFile は新しい authorization engine ではなく、
   既存 NBAuthorize[obj, req] に fileSpec を渡すための薄い adapter とする。
4. ただし、NBFileSpec の返り値をそのまま NBAuthorize に渡してはならない。
   必ず NBFileAuthorizationSpec へ正規化してから渡す。
5. 現行 NBAuthorize はラベル未設定時に fail-closed ではなく Pass へ倒れる。
   そのため、PrivacyLevel 由来の EffectiveRiskScore を必ず補完し、
   ScoreGate で cloud send を止められるようにする。
6. projection Boolean は fail-closed とする。
   Permit 以外、判定不能、例外、$Failed はすべて False。
```

---

## 1. 問題設定

現状の `iNBFilePrivacyLevel` は、概念的には次のような判定をしている。

```text
1. ノート自身に CloudPublishable 宣言があれば低い PrivacyLevel
2. $packageDirectory / $ClaudeAccessibleDirs 配下なら PrivacyLevel -> 0.5
3. それ以外は PrivacyLevel -> 1.0
```

この設計には、次の混同がある。

```text
$ClaudeAccessibleDirs 配下である
  = ローカル agent が読んでよい

PrivacyLevel <= 0.5
  = クラウド LLM に送ってよい
```

この 2 つは本来別である。

例えば、次のようなディレクトリは十分あり得る。

```text
ローカル Claude agent は読んでよい。
しかし、クラウド LLM には送ってはいけない。
```

つまり、`$ClaudeAccessibleDirs` は本来 **read authorization** に関する設定であり、**external send authorization** ではない。

---

## 2. PrivacyLevel の限界

`PrivacyLevel` は `[0,1]` の数値であり、現在は claudecode 側でモデルルーティングに広く使われている。

典型的には、

```text
PrivacyLevel <= 0.5  → cloud LLM に送る
PrivacyLevel >  0.5  → local LM Studio 等に送る
```

のような扱いである。

この運用は実用上便利だが、`PrivacyLevel` だけでは以下を区別できない。

| 区別したい内容 | PrivacyLevel だけで表せるか |
|---|---|
| ローカル agent が読んでよいか | 不十分 |
| ローカル agent が書いてよいか | 不十分 |
| クラウド API に送ってよいか | 不十分 |
| ログファイルに残してよいか | 不十分 |
| notebook cell に表示してよいか | 不十分 |
| 対話中だけ許可するか | 不十分 |
| 特定 provider だけ許可するか | 不十分 |

したがって、`PrivacyLevel` は今後も便利な risk score / routing hint として残してよいが、最終的な許可判定そのものにしてはいけない。

---

## 3. privacy spec v0.1 との整合

`NBAccess.wl / claudecode.wl 向け プライバシー・アクセス制御仕様案 v0.1` では、以下の二層モデルが示されている。

```text
BasePrivacyScore:
  [0,1] の補助的スコア

PolicyLabel:
  誰が読めるか、どのモジュールがどう使えるかを表す authoritative なポリシー値
```

重要なのは、仕様上、`[0,1]` スコアは補助的であり、最終的な access 可否は

```text
PolicyLabel + AccessRequest + Environment
```

で決める、という点である。

また、実際の判定には、

```mathematica
EffectiveLabel[obj, req] :=
  LabelJoin[
    obj["PolicyLabel"],
    obj["ContainerLabel"],
    SinkLabel[req["Sink"]],
    EnvironmentLabel[req["Environment"]]
  ]
```

および、

```mathematica
EffectiveRiskScore[obj, req] :=
  Max[
    obj["BasePrivacyScore"],
    obj["ContainerRisk"],
    SinkRisk[req["Sink"]],
    EnvironmentRisk[req["Environment"]],
    AuditRisk[obj, req]
  ]
```

を使う方針である。

したがって、Phase 4 でやるべきことは、

```text
PrivacyLevel とは別に CloudSendAllowed Boolean を生やす
```

ではなく、

```text
CloudSendAllowed を、SendExternal / ExternalAPI という AccessRequest に対する
NBAuthorize 結果の projection として定義する
```

ことである。

---

## 4. 現行 NBAccess API との関係

### 4.1 現行 API に存在するもの

現行 `api.md` では、少なくとも以下が確認できる。

```mathematica
NBAuthorize[obj, req]
NBPolicyGate[obj, req]
NBScoreGate[obj, req]
NBEnvironmentGate[obj, req]
```

`NBAuthorize[obj, req]` は、

```text
PolicyGate + ScoreGate + EnvironmentGate を統合した AccessDecision を返す
```

API として定義されている。

また、現行 ObjectSpec API には以下もある。

```mathematica
NBFileSpec[path]
NBValueSpec[expr, privacyLevel]
NBPrivacyLevelToRoutes[privacyLevel]
```

さらに provider / routing 関連として、以下もある。

```mathematica
$NBRoutingThresholds
NBSetProviderMaxAccessLevel[provider, level]
NBGetProviderMaxAccessLevel[provider]
NBGetAvailableFallbackModels[accessLevel]
NBProviderCanAccess[provider, accessLevel]
```

したがって、Phase 4 は既存の `NBAuthorize` と routing API を活かすべきである。

### 4.2 現行 API に存在する前提で書いてはいけないもの

一方で、以下は現行 `api.md` では確認できない。

```mathematica
NBAuthorizeFile
NBMakeFileAccessRequest
NBAuthorizeContextBundle
NBPermitQ
```

したがって、これらを既存 API として自由に使う書き方は不正確である。

これらは、Phase 4 で追加する helper として明記する。

```text
NBAuthorizeFile:
  NBFileSpec / fileSpec を NBAuthorize に渡すための adapter。

NBMakeFileAccessRequest:
  file 用 AccessRequest Association を組み立てる helper。

NBAuthorizeContextBundle:
  複数 file / cell / source span からなる context bundle を認可する将来 API。
  Phase 4.1 では本格実装しない。

NBPermitQ:
  AccessDecision を Boolean projection に落とす fail-closed helper。
```


### 4.3 現行 `NBAuthorize` 実装確認から判明した重要点

現行 `NBAuthorize` 系の実装確認により、Phase 4 設計に関わる重要な事実が判明した。

```text
(a) obj に PolicyLabel / BasePrivacyScore 等の必須キーは無い。
    NBPolicyGate はラベルが無ければ "NoLabelsConfigured" として Pass へ倒れる。
    NBScoreGate も多段 Lookup によりキー欠落に頑健である。

(b) PolicyLabel 機構自体は実装済みである。
    NBLabelQ / NBEffectiveLabel / NBCanFlowToQ / NBCanDeclassifyQ 等が存在し、
    DLM 風のラベル機構はある。
    ただしラベル未設定なら NBPolicyGate は Pass する。

(c) NBAuthorize の Decision 値域は、
    "Permit" / "Deny" / "RequireApproval" / "Screen" の 4 値である。
```

この確認により、revised2 で主に懸念していた

```text
キー欠落により NBAuthorize がエラーまたは常時 Deny になり、
projection がすべて False になる
```

というリスクよりも、むしろ次のリスクが重要になる。

```text
ラベル未設定なので PolicyGate が Pass し、
CloudSendAllowed が安易に True になり得る。
```

したがって Phase 4.1 の主防御は、`PolicyLabel` の自動生成ではなく、

```text
PrivacyLevel 由来の EffectiveRiskScore を object spec に補完し、
現行 NBScoreGate に cloud send を止めさせること
```

である。

本書ではこれを **ScoreGate 主導案** と呼ぶ。


---

## 5. 推奨方針: policy 準拠の projection field 案

### 5.1 何を追加するか

`NBFileSpec[path]` の返り値には、将来的に次のような情報を加える。

```mathematica
<|
  "Path" -> "...",
  "CanonicalPath" -> "...",
  "SymbolicPath" -> {"$onWork", "project", "file.nb"},

  "PrivacyLevel" -> 0.5,              (* legacy / routing hint *)
  "BasePrivacyScore" -> 0.5,          (* policy v0.1 準拠 *)
  "PolicyLabel" -> label,
  "ContainerRisk" -> 0.0,
  "Tags" -> {...},

  "ReadableByAgent" -> True,
  "WritableByAgent" -> False,
  "CloudSendAllowed" -> False,

  "ReadDecision" -> <|...|>,
  "WriteDecision" -> <|...|>,
  "CloudSendDecision" -> <|...|>,

  "ProjectionSource" -> "NBAuthorize",
  "ProjectionComputedAt" -> DateObject[...]
|>
```

ここで重要なのは、下の 3 つである。

```mathematica
"ReadableByAgent" -> ...
"WritableByAgent" -> ...
"CloudSendAllowed" -> ...
```

これらは一次ポリシーではない。

これらは、次のような `AccessRequest` に対して `NBAuthorize` を呼んだ結果である。

| Projection field | 対応する Operation | Sink | Networked |
|---|---|---|---|
| `ReadableByAgent` | `"ReadValue"` | `"KernelValue"` | `False` |
| `WritableByAgent` | `"WriteCell"` または `"WriteLog"` | `"NotebookCell"` / `"FileSystem"` | `False` |
| `CloudSendAllowed` | `"SendExternal"` | `"ExternalAPI"` | `True` |

---

## 6. Phase 4.1: File authorization adapter

### 6.1 目的

privacy spec v0.1 / Phase 14 の `NBAuthorize[obj, req]` を、`NBFileSpec[path]` に対して使えるようにする。

ただし、`NBFileSpec[path]` の返り値をそのまま `NBAuthorize` に渡してはならない。

理由は、現行 `NBFileSpec` は `PrivacyLevel` 中心の legacy object spec であり、privacy spec v0.1 / Phase 14 の `NBAuthorize` が参照し得る次のキーを必ず持つとは限らないためである。

```mathematica
"BasePrivacyScore"
"EffectiveRiskScore"
"PolicyLabel"
"ContainerLabel"
"ContainerRisk"
```

現行 `NBAuthorize` はラベル未設定時には `NBPolicyGate` が後方互換のため Pass へ倒れる。
したがって、ラベル未設定の段階で cloud send を止めるには、`EffectiveRiskScore` を `PrivacyLevel` 由来で補完し、`NBScoreGate` を確実に効かせる必要がある。

したがって Phase 4.1 では、`NBAuthorizeFile` と同時に、

```mathematica
iNBFileSpecForAuthorize
```

または公開 API としての

```mathematica
NBFileAuthorizationSpec
```

を導入する。

### 6.2 追加するもの

```mathematica
NBMakeFileAccessRequest[pathOrSpec_, operation_String, opts___]
NBAuthorizeFile[pathOrSpec_, req_Association]
NBPermitQ[decision_]

(* 内部または将来公開候補 *)
iNBFileSpecForAuthorize[spec_Association]
NBFileAuthorizationSpec[pathOrSpec_]
```

### 6.3 追加しないもの

Phase 4.1 では、以下を追加しない。

```text
- 新しい authorization engine
- NBAuthorize とは別系統の file permission 判定
- NBAuthorizeContextBundle の本格実装
- DLM / LabelJoin / SinkLabel の完全実装
```

`NBAuthorizeFile` は、あくまで `NBAuthorize[obj, req]` に file authorization spec を渡すための adapter である。

### 6.4 最小実装イメージ: AccessRequest helper

```mathematica
Options[NBMakeFileAccessRequest] = {
  "Subject" -> "ClaudeAgent",
  "Module" -> "claudecode",
  "Sink" -> Automatic,
  "Networked" -> False,
  "Route" -> Automatic,
  "Provider" -> Automatic,
  "ModelIntent" -> Automatic,
  "AccessLevel" -> Automatic
};

NBMakeFileAccessRequest[pathOrSpec_, operation_String, opts : OptionsPattern[]] :=
 Module[{sink, networked, accessLevel},
   sink = Replace[OptionValue["Sink"], Automatic :>
     Switch[operation,
       "ReadValue", "KernelValue",
       "WriteCell", "NotebookCell",
       "WriteLog", "LogFile",
       "SendExternal", "CloudLLM",
       _, "KernelValue"
     ]
   ];

   networked = TrueQ[OptionValue["Networked"]];

   accessLevel = Replace[OptionValue["AccessLevel"], Automatic :>
     Switch[operation,
       "SendExternal", Lookup[$NBRoutingThresholds, "Cloud", 0.5],
       _, 1.0
     ]
   ];

   <|
     "Subject" -> OptionValue["Subject"],
     "Module" -> OptionValue["Module"],
     "Operation" -> operation,
     "Sink" -> sink,
     "Environment" -> <|
       "Networked" -> networked,
       "Route" -> OptionValue["Route"],
       "Provider" -> OptionValue["Provider"],
       "ModelIntent" -> OptionValue["ModelIntent"]
     |>,
     "AccessLevel" -> accessLevel
   |>
 ];
```

---

## 7. `NBAuthorize` 入力契約と `NBFileAuthorizationSpec`

### 7.1 問題

`NBAuthorizeFile[pathOrSpec, req]` を単に次のように実装すると危険である。

```mathematica
NBAuthorizeFile[pathOrSpec_, req_Association] :=
 Module[{spec},
   spec =
     If[AssociationQ[pathOrSpec],
       pathOrSpec,
       NBFileSpec[pathOrSpec, "IncludeProjections" -> False]
     ];

   NBAuthorize[spec, req]
 ]
```

理由は、`spec` が `NBAuthorize` の期待する object contract を満たさない可能性があるためである。

現行 `NBFileSpec` の base spec は、おそらく次のような情報を中心に持つ。

```mathematica
<|
  "Path" -> "...",
  "FileType" -> "...",
  "PrivacyLevel" -> 0.5 | 1.0 | {0.5, 1.0},
  "CellCount" -> ...
|>
```

一方、privacy spec v0.1 / Phase 14 の `NBAuthorize` は、少なくとも以下を参照する可能性がある。

```mathematica
"BasePrivacyScore"
"PolicyLabel"
"ContainerLabel"
"ContainerRisk"
```

この差を埋めないまま `NBAuthorize` に渡しても、現行実装では必ずしもエラーや Deny にはならない。

むしろ現行 `NBAuthorize` は、ラベル未設定時に後方互換のため次のように振る舞う。

```text
PolicyLabel なし:
  NBPolicyGate は "NoLabelsConfigured" として Pass。

AllowedSinks 等なし:
  NBEnvironmentGate も多くの場合 Pass。

残る主防御:
  NBScoreGate。
```

したがって、Phase 4.1 の本当のリスクは、

```text
キー欠落で全部 False になる
```

ではなく、

```text
ラベル未設定なので PolicyGate が Pass し、
CloudSendAllowed が安易に True になる
```

ことである。

このリスクを避けるため、`NBFileAuthorizationSpec` には `PrivacyLevel` 由来の `EffectiveRiskScore` を必ず補完する。
`BasePrivacyScore` だけでは不十分である。現行 `NBScoreGate` が `EffectiveRiskScore` を優先して参照するためである。

したがって、Phase 4.1 と Phase 4.2 は文書上は分けてもよいが、**実装・テスト上はセットで扱う**。

### 7.2 方針

`NBAuthorizeFile` は、`NBFileSpec` の生 Association をそのまま `NBAuthorize` に渡してはならない。

必ず、次の正規化を行う。

```text
1. projection key を落とす。
2. PrivacyLevel から BasePrivacyScore を補う。
3. PrivacyLevel から EffectiveRiskScore を補う。
4. PolicyLabel は、明示されていなければ Missing["NoPolicyLabel"] として残す。
   数値 PrivacyLevel から DLM reader policy を自動生成しない。
5. ContainerLabel は、明示されていなければ Missing["NoContainerLabel"] として残す。
6. ContainerRisk が無ければ 0.0 を補う。
7. Tags が無ければ {} を補う。
8. SourceSpecVersion を付ける。
```

この正規化済み object を、本書では

```text
NBFileAuthorizationSpec
```

と呼ぶ。

### 7.3 projection key は authorization 入力から落とす

`NBFileSpec[path, "IncludeProjections" -> True]` の結果には、次のような projection key が含まれる。

```mathematica
$NBFileProjectionKeys = {
  "ReadableByAgent",
  "WritableByAgent",
  "CloudSendAllowed",
  "ReadDecision",
  "WriteDecision",
  "CloudSendDecision",
  "ProjectionSource",
  "ProjectionComputedAt"
};
```

これらは、`NBAuthorize` に渡す object の一次属性ではない。

したがって、`iNBFileSpecForAuthorize` はこれらを落としてから正規化する。

### 7.4 最小実装イメージ: authorization spec 正規化

```mathematica
$NBFileProjectionKeys = {
  "ReadableByAgent",
  "WritableByAgent",
  "CloudSendAllowed",
  "ReadDecision",
  "WriteDecision",
  "CloudSendDecision",
  "ProjectionSource",
  "ProjectionComputedAt"
};

iNBPrivacyScoreFromPrivacyLevel[pl_] :=
  Which[
    NumericQ[pl],
      pl,

    ListQ[pl] && AllTrue[pl, NumericQ],
      Max[pl],

    True,
      1.0
  ];

iNBFileSpecForAuthorize[spec_Association] :=
 Module[{base, pl, score},
   base = KeyDrop[spec, $NBFileProjectionKeys];

   pl = Lookup[base, "PrivacyLevel", 1.0];
   score = iNBPrivacyScoreFromPrivacyLevel[pl];

   <|
     "Kind" -> Lookup[base, "Kind", "File"],
     "Path" -> Lookup[base, "Path", Missing["Path"]],
     "CanonicalPath" -> Lookup[base, "CanonicalPath", Lookup[base, "Path", Missing[]]],

     "PrivacyLevel" -> pl,

     (* policy v0.1 風の補助スコア。 *)
     "BasePrivacyScore" ->
       Lookup[base, "BasePrivacyScore", score],

     (* 現行 NBScoreGate が優先的に見る score。
        ラベル未設定時の主防御なので必ず補完する。 *)
     "EffectiveRiskScore" ->
       Lookup[base, "EffectiveRiskScore", score],

     (* PrivacyLevel から DLM reader policy を自動生成しない。
        明示ラベルが無ければ Missing のままにし、
        現行 NBPolicyGate の後方互換 Pass に委ねる。 *)
     "PolicyLabel" ->
       Lookup[base, "PolicyLabel", Missing["NoPolicyLabel"]],

     "ContainerLabel" ->
       Lookup[base, "ContainerLabel", Missing["NoContainerLabel"]],

     "ContainerRisk" ->
       Lookup[base, "ContainerRisk", 0.0],

     "Tags" ->
       Lookup[base, "Tags", {}],

     "SourceSpecVersion" -> "NBFileAuthorizationSpec/v1"
   |>
 ];
```

### 7.5 default label は自動生成しない

Phase 4 初期では、`PrivacyLevel` から DLM / reader policy 形式の `PolicyLabel` を自動生成しない。

理由は、`PolicyLabel` は本来、

```text
誰が読めるか
どの module がどう使えるか
どの owner がどの readers に許可したか
```

を表す authoritative なラベルであり、単なる数値である `PrivacyLevel` から意味のある reader policy を機械生成するのは無理があるためである。

採用しない例:

```text
PrivacyLevel -> 1.0 だから誰も読めない PolicyLabel を合成する
PrivacyLevel -> 0.5 だから CloudLLM も読める PolicyLabel を合成する
```

このような変換は、privacy spec v0.1 のラベル意味論を歪める。

Phase 4 初期では、ラベルが明示されていなければ、

```mathematica
"PolicyLabel" -> Missing["NoPolicyLabel"]
"ContainerLabel" -> Missing["NoContainerLabel"]
```

として残す。

その結果、現行 `NBPolicyGate` は後方互換のため Pass する。
この Pass は認めるが、cloud send の防御は `EffectiveRiskScore` による `NBScoreGate` に担わせる。

つまり Phase 4.1 の基本は次である。

```text
ラベルが無い間:
  ScoreGate で守る。

ラベルが付いた後:
  PolicyGate + ScoreGate で守る。
```


### 7.6 ScoreGate 主導案

現行 `NBAuthorize` はラベル未設定時に `NBPolicyGate` が Pass するため、Phase 4.1 で cloud send を止める主経路は `NBScoreGate` である。

そのため、`iNBFileSpecForAuthorize` は、`PrivacyLevel` から次の両方を補完する。

```mathematica
"BasePrivacyScore" -> score
"EffectiveRiskScore" -> score
```

ここで `score` は `PrivacyLevel` から次のように得る。

```text
数値 PrivacyLevel:
  その値。

{0.5, 1.0} のような混在 PrivacyLevel:
  Max を取る。
  whole-file projection では安全側に倒す。

不明:
  1.0。
```

この設計により、例えば private notebook は次のように判定される。

```text
object:
  EffectiveRiskScore -> 1.0

request:
  Operation -> "SendExternal"
  Sink -> "CloudLLM"
  AccessLevel -> 0.5

NBScoreGate:
  cloud threshold を超えるため Screen または非 Permit。

NBPermitQ:
  "Permit" 以外なので False。

結果:
  CloudSendAllowed -> False。
```

この方式の利点は、`NBAuthorize` / `NBScoreGate` 本体を変更しないことである。
防御は、`NBAuthorize` への入力正規化に閉じる。

採用しない案:

```text
1. PrivacyLevel から PolicyLabel を自動生成する。
2. NBAuthorize の結果を NBAuthorizeFile 側で後から force deny する。
```

前者は DLM ラベル意味論を歪め、後者は `CloudSendAllowed` が純粋な `NBAuthorize` projection ではなくなるため採用しない。

### 7.7 最小実装イメージ: `NBAuthorizeFile`

```mathematica
NBAuthorizeFile[pathOrSpec_, req_Association] :=
 Module[{rawSpec, authSpec, decision},
   rawSpec =
     If[AssociationQ[pathOrSpec],
       pathOrSpec,
       NBFileSpec[pathOrSpec, "IncludeProjections" -> False]
     ];

   authSpec = iNBFileSpecForAuthorize[rawSpec];

   decision = Quiet @ Check[
     NBAuthorize[authSpec, req],
     <|
       "Decision" -> "Deny",
       "ReasonClass" -> "AuthorizationError",
       "VisibleExplanation" -> "File authorization failed."
     |>
   ];

   decision
 ];
```

### 7.8 実装上の注意

`iNBFileSpecForAuthorize` は、呼び出し側がどの形の Association を渡しても、`NBAuthorize` に入る object spec を安定化するための関数である。

したがって、次のどちらでも `NBAuthorize` に渡る形は同じになるべきである。

```mathematica
NBAuthorizeFile[
  NBFileSpec[path, "IncludeProjections" -> False],
  req
]

NBAuthorizeFile[
  NBFileSpec[path, "IncludeProjections" -> True],
  req
]
```

---

## 8. `NBPermitQ`: fail-closed Boolean projection

`ReadableByAgent` / `WritableByAgent` / `CloudSendAllowed` は Boolean projection である。

そのため、判定不能時に True へ倒れてはいけない。

`NBPermitQ` は次のように定義する。

```mathematica
NBPermitQ[decision_] :=
  Quiet @ Check[
    TrueQ[
      AssociationQ[decision] &&
      Lookup[decision, "Decision", None] === "Permit"
    ],
    False
  ];
```

このルールでは、以下の扱いになる。

| Decision / 状態 | projection Boolean |
|---|---:|
| `"Permit"` | `True` |
| `"Deny"` | `False` |
| `"Screen"` | `False` |
| `"RequireApproval"` | `False` |
| `"NeedsApproval"` | `False` |
| `"RepairNeeded"` | `False` |
| `"Indeterminate"` | `False` |
| `$Failed` | `False` |
| `Missing[...]` | `False` |
| 例外 | `False` |

特に `CloudSendAllowed` は、次を原則とする。

```text
判定不能なら送らない。
```

ただし、debug / audit のために raw decision は捨てず、次のように残す。

```mathematica
<|
  "CloudSendAllowed" -> NBPermitQ[cloudDecision],
  "CloudSendDecision" -> cloudDecision
|>
```

---

## 9. `NBFileSpec` の呼び出しコストと cache 設計

### 9.1 問題

`NBFileSpec` が呼ばれるたびに

```mathematica
ReadableByAgent
WritableByAgent
CloudSendAllowed
```

をそれぞれ `NBAuthorizeFile` で計算すると、実装次第では非常に重くなる。

特に `.nb` について、privacy summary の取得が

```text
NBFileOpen
→ 全セル走査
→ NBFileClose
```

を伴う場合、1 回の `NBFileSpec` で notebook を複数回開く危険がある。

これは避けるべきである。

### 9.2 方針

`NBFileSpec` は、base spec と projection を分離する。

```mathematica
NBFileSpec[path, "IncludeProjections" -> False]
```

は軽量な base spec だけを返す。

```mathematica
NBFileSpec[path, "IncludeProjections" -> True]
```

は、base spec を一度作った後、その結果を使って projection を計算する。

### 9.3 内部構造

```mathematica
iNBFileSpecBase[path_] :=
  (* path canonicalization, file metadata, privacy summary を1回だけ計算 *)

iNBFileSpecProjections[baseSpec_] :=
  (* baseSpec を使って Readable / Writable / CloudSend を計算。
     ここでは notebook を開き直さない。 *)

NBFileSpec[path_, opts___] :=
 Module[{base, projections},
   base = iNBFileSpecBaseCached[path];

   If[!TrueQ[OptionValue["IncludeProjections"]],
     Return[base]
   ];

   projections = iNBFileSpecProjectionsCached[base];

   Join[base, projections]
 ]
```

### 9.4 cache key

Phase 4 初期の cache key は、最低限次でよい。

```mathematica
<|
  "CanonicalPath" -> canonicalPath,
  "FileMTime" -> FileDate[path],
  "FileByteCount" -> FileByteCount[path]
|>
```

`.nb` については、将来的に次を組み合わせる。

```text
SourceUUID
ContentHash
NotebookRef
SnapshotId
```

ただし、Phase 4 初期では mtime + size cache で十分である。

### 9.5 projection cache の注意

projection は、file content だけでなく policy にも依存する。

したがって、cache key には将来的に以下も入れるべきである。

```text
$NBPrivacySpec
$NBRoutingThresholds
provider max access level
$ClaudeAccessibleDirs / NBGetAccessibleDirs
Policy version
```

Phase 4 初期では、単純化してよいが、文書上は以下を明記する。

```text
projection cache は content metadata だけでなく policy metadata にも依存する。
policy が変わったら projection cache は無効化する。
```

### 9.6 `ProjectionComputedAt` の意味

`ProjectionComputedAt` は、projection が実際に計算された時刻である。

cache hit 時には、現在時刻ではなく、cache entry 作成時刻を返す。

```text
ProjectionComputedAt:
  projection を実際に計算した時刻。
  cache hit 時には cache entry 作成時刻。
  現在時刻ではない。
```

重要な規則:

```text
cache key / equality 判定には ProjectionComputedAt を含めない。
```

理由は、`ProjectionComputedAt` を cache key に含めると、時刻が変わるたびに cache miss になり、cache の意味がなくなるからである。

将来、返却時刻が必要になった場合は、別フィールドとして次を追加する。

```mathematica
"ProjectionReturnedAt" -> DateObject[]
```

ただし、Phase 4 では不要である。

---

## 10. AccessLevel の扱い

### 10.1 問題

以前の案では、

```mathematica
CloudSendAllowed:
  AccessLevel -> Lookup[fileSpec, "PrivacyLevel", 0.0)

ReadableByAgent:
  AccessLevel -> 0.5
```

のように不統一があった。

これは避けるべきである。

### 10.2 AccessLevel の意味

Phase 4 初期では、`AccessLevel` の意味を次のように固定する。

```text
AccessLevel は object 側 PrivacyLevel ではなく、
request / sink / route が許容する最大 privacy score である。
```

つまり、区別は次である。

```text
Object 側:
  PrivacyLevel / BasePrivacyScore

Request 側:
  AccessLevel
```

### 10.3 projection ごとの初期値

Phase 4 初期の既定値は次のようにする。

| Projection | AccessLevel 既定値 | 理由 |
|---|---:|---|
| `ReadableByAgent` | `1.0` | ローカル agent の read 可否は path / policy で制限し、score threshold では落としすぎない |
| `WritableByAgent` | `1.0` | write 可否は operation policy で制限する |
| `CloudSendAllowed` | `$NBRoutingThresholds["Cloud"]` または `NBGetProviderMaxAccessLevel[provider]` | cloud/provider 側の最大許容レベルを使う |

### 10.4 legacy compatibility mode

必要であれば、Phase 4 初期に限り、次の compatibility mode を用意してもよい。

```mathematica
$NBAccessLegacyProjectionUsesPrivacyLevelAsAccessLevel = False;
```

`True` の場合のみ、

```mathematica
AccessLevel -> Lookup[fileSpec, "PrivacyLevel", ...]
```

を使う。

ただし、この mode は推奨しない。

理由は、object 自身の `PrivacyLevel` を request の `AccessLevel` に入れると、

```text
object risk <= object privacy level
```

に近い自己参照的な判定になり、ScoreGate が実質的に弱くなるためである。

---


## 11. Cloud send request の `Sink` / `Route` 整合

Phase 4.1 では、cloud send request の `Sink` / `Route` を、現行 `NBScoreGate` が実際に参照する名前に合わせる。

実装確認によれば、現行 `NBScoreGate` は cloud 判定で概念的に次を見ている。

```text
sink === "CloudLLM"
```

そのため、Phase 4.1 の `CloudSendAllowed` 用 request では、抽象仕様上自然な

```mathematica
"Sink" -> "ExternalAPI"
"Environment" -> <|"Route" -> "CloudLLM"|>
```

ではなく、現行実装との互換性を優先して次を使う。

```mathematica
"Sink" -> "CloudLLM"
"Environment" -> <|
  "Networked" -> True,
  "Route" -> "CloudLLM"
|>
```

これは Phase 4.1 の互換措置である。

将来、`NBScoreGate` / `NBEnvironmentGate` が `Environment["Route"]` や `Sink -> "ExternalAPI"` を正式に見るようになった段階で、AccessRequest の抽象仕様に合わせて

```mathematica
"Sink" -> "ExternalAPI"
"Environment" -> <|"Route" -> "CloudLLM"|>
```

へ移行してよい。

ただし、その変更は Phase 4.1 では行わない。
Phase 4.1 では authorization 本体を変更せず、request 形状を現行 gate に合わせる。

## 12. `CloudSendAllowed` の定義

`CloudSendAllowed` は、例えば次のように定義する。

```mathematica
iNBCloudSendAllowedQ[fileSpec_Association, opts___] :=
 Module[{req, decision, provider, accessLevel},
   provider = OptionValue["Provider"];

   accessLevel =
     If[StringQ[provider],
       NBGetProviderMaxAccessLevel[provider],
       Lookup[$NBRoutingThresholds, "Cloud", 0.5]
     ];

   req = NBMakeFileAccessRequest[
     fileSpec,
     "SendExternal",
     "Sink" -> "CloudLLM",
     "Networked" -> True,
     "Route" -> "CloudLLM",
     "Provider" -> provider,
     "ModelIntent" -> OptionValue["ModelIntent"],
     "AccessLevel" -> accessLevel
   ];

   decision = NBAuthorizeFile[fileSpec, req];

   NBPermitQ[decision]
 ]
```

原則:

```text
$ClaudeAccessibleDirs 配下であることは CloudSendAllowed の根拠にしない。
CloudPublishable 明示宣言、PolicyLabel、provider max access level、Sink/Environment gate の結果で決める。
```

---

## 13. `ReadableByAgent` の定義

`ReadableByAgent` は、ローカル agent が対象ファイルを読めるかを表す projection である。

```mathematica
iNBReadableByAgentQ[fileSpec_Association] :=
 Module[{req, decision},
   req = NBMakeFileAccessRequest[
     fileSpec,
     "ReadValue",
     "Sink" -> "KernelValue",
     "Networked" -> False,
     "Route" -> "LocalAgent",
     "AccessLevel" -> 1.0
   ];

   decision = NBAuthorizeFile[fileSpec, req];

   NBPermitQ[decision]
 ]
```

ここでは、`$ClaudeAccessibleDirs` 配下であることは `ReadableByAgent` を True にする根拠になり得る。

しかし、それだけで `CloudSendAllowed` を True にしてはならない。

---

## 14. `WritableByAgent` の定義

`WritableByAgent` は、ローカル agent が対象ファイルまたは notebook に書き込めるかを表す projection である。

```mathematica
iNBWritableByAgentQ[fileSpec_Association] :=
 Module[{req, decision},
   req = NBMakeFileAccessRequest[
     fileSpec,
     "WriteCell",
     "Sink" -> "NotebookCell",
     "Networked" -> False,
     "Route" -> "LocalAgent",
     "AccessLevel" -> 1.0
   ];

   decision = NBAuthorizeFile[fileSpec, req];

   NBPermitQ[decision]
 ]
```

読み取り許可と書き込み許可も本来別である。

特に SourceVault / NBAccess では、以下を分けるべきである。

```text
read source
write notebook tagging rules
write source file
write cache
write audit log
write generated artifact
```

---

## 15. PrivacyLevel は当面凍結する

Phase 4 で最も避けるべきことは、`PrivacyLevel` の意味を静かに変えることである。

現状、`PrivacyLevel` は claudecode 側でモデルルーティングに広く使われている可能性が高い。

したがって、Phase 4 初期では次を守る。

```text
PrivacyLevel の値と計算ロジックは原則として変更しない。
```

理由は次である。

1. 既存のモデルルーティングを壊さない。
2. 回帰範囲を小さくできる。
3. `NBFileSpec` の出力拡張だけで導入できる。
4. 新しい policy 判定へ段階的に移行できる。

ただし、文書上は `PrivacyLevel` を次のように格下げしておく。

```text
PrivacyLevel:
  legacy / routing hint / BasePrivacyScore 相当の補助スコア。
  最終的な access authorization ではない。
```

---

## 16. claudecode 側の移行方針

### 16.1 現状

claudecode 側では、おそらく以下のような判定が複数箇所に存在する。

```mathematica
If[privacyLevel <= 0.5,
  useCloudModel[],
  useLocalModel[]
]
```

この判定は、将来的には不十分である。

### 16.2 移行後

新規コードでは、次のようにする。

```mathematica
spec = NBFileSpec[path, "IncludeProjections" -> True];

If[TrueQ[spec["CloudSendAllowed"]],
  useCloudModel[],
  useLocalModel[]
]
```

さらに望ましくは、Boolean projection すら直接見ず、実際の送信直前に次を行う。

```mathematica
decision = NBAuthorizeFile[
  spec,
  NBMakeFileAccessRequest[
    spec,
    "SendExternal",
    "Sink" -> "ExternalAPI",
    "Networked" -> True,
    "Route" -> "CloudLLM",
    "Provider" -> provider,
    "ModelIntent" -> modelIntent,
    "AccessLevel" -> NBGetProviderMaxAccessLevel[provider]
  ]
];

If[NBPermitQ[decision],
  sendToCloudLLM[],
  useLocalFallback[]
]
```

この設計なら、provider や model intent に応じた将来拡張も自然に入る。

---

## 17. SourceVault との関係

SourceVault の path 正規化では、以下を分ける。

```text
SymbolicPath:
  cross-PC identity / snapshot identity 用

PhysicalPath:
  現 PC での実体アクセス用

NBAccess authorization:
  実際に読んでよいか、書いてよいか、外部送信してよいかの判定用
```

SourceVault は、`SymbolicPath` を使って identity を安定化できる。

しかし、SourceVault が `CloudSendAllowed` を直接決めてはならない。

SourceVault が外部送信や LLM context assembly を行う場合は、NBAccess に対して次を問い合わせる。

```mathematica
NBAuthorizeFile[
  fileSpec,
  NBMakeFileAccessRequest[
    fileSpec,
    "SendExternal",
    "Sink" -> "CloudLLM",
    "Networked" -> True,
    ...
  ]
]
```

つまり、SourceVault は path identity の管理者ではあってよいが、privacy authorization の最終決定者ではない。

---

## 18. Context bundle authorization は別フェーズ

`NBAuthorizeContextBundle` は便利だが、Phase 4.1 の主作業に入れると範囲が広がりすぎる。

理由:

1. context bundle は複数 source / file / cell に依存する。
2. 依存元ごとの `PolicyLabel` / `PrivacyLevel` / `ContainerRisk` を join する必要がある。
3. SourceVault の EvidenceBundle / SourceSpan / Claim との整合が必要になる。
4. LLM prompt に渡す context は、raw file よりも declassify / redaction / summary を経由する場合がある。

したがって、Phase 4.1 では次だけを行う。

```text
single fileSpec に対して NBAuthorize を呼ぶ adapter を作る。
```

`NBAuthorizeContextBundle` は Phase 4.4 以降、または SourceVault integration phase に回す。

---

## 19. 実装順序案

### Phase 4.0 — 文書化

- `PrivacyLevel` は authorization ではなく legacy / routing hint であると明記する。
- `CloudSendAllowed` 等は projection field であると明記する。
- `$ClaudeAccessibleDirs` は read authorization の根拠であり、cloud send authorization ではないと明記する。
- 未実装 API を現行 API として書かない。
- `NBAuthorize` に渡す object spec の契約を文書化する。

### Phase 4.1 — File authorization adapter + authorization spec 正規化

追加候補:

```mathematica
NBMakeFileAccessRequest[pathOrSpec, operation, opts]
NBAuthorizeFile[pathOrSpec, req]
NBPermitQ[decision]
iNBFileSpecForAuthorize[spec]
```

実装方針:

```text
NBAuthorizeFile は NBFileSpec / file object spec を作り、
iNBFileSpecForAuthorize で NBFileAuthorizationSpec へ正規化し、
PrivacyLevel 由来の EffectiveRiskScore を補完し、
既存 NBAuthorize[obj, req] に渡す薄い wrapper とする。
```

注意:

```text
Phase 4.1 と Phase 4.2 は文書上は分けるが、
実装・テスト上はセットで扱う。
```

### Phase 4.2 — NBFileSpec 出力拡張

`NBFileSpec` に以下を追加する。

```mathematica
"BasePrivacyScore"
"PolicyLabel"
"ContainerRisk"
"ReadableByAgent"
"WritableByAgent"
"CloudSendAllowed"
"ReadDecision"
"WriteDecision"
"CloudSendDecision"
"ProjectionSource"
"ProjectionComputedAt"
```

ただし、`ReadableByAgent` 等は保存された手入力値ではなく、毎回または cache refresh 時に `NBAuthorize` から計算する。

### Phase 4.3 — projection cache

- `iNBFileSpecBaseCached`
- `iNBFileSpecProjectionsCached`

を導入する。

cache invalidation は最低限次に依存する。

```text
CanonicalPath
FileMTime
FileByteCount
PolicyVersion
$NBRoutingThresholds
ProviderMaxAccessLevel
NBGetAccessibleDirs
```

`ProjectionComputedAt` は cache entry 作成時刻であり、cache key には含めない。

### Phase 4.4 — claudecode 側の段階移行

新規コードから順に、

```text
PrivacyLevel <= 0.5
```

を直接見るのではなく、

```text
CloudSendAllowed
```

または

```text
NBAuthorizeFile[..., Operation -> "SendExternal"]
```

を見るようにする。

### Phase 4.5 — 送信直前チェック

クラウド LLM 呼び出し直前に、必ず `NBAuthorizeFile` を通す。

複数ファイル・複数セル・複数 source に依存する context の場合は、この段階では conservative に扱う。

```text
いずれかの source が CloudSendAllowed False なら bundle 全体を cloud 不可。
```

正式な label join / declassify / ReleasePolicy は後続 Phase で扱う。

### Phase 4.6 — PrivacyLevel 再定義の検討

十分に移行した後でのみ、次を検討する。

```text
PrivacyLevel を CloudSendAllowed / EffectiveRiskScore 由来に再定義するか
```

この段階では、必要に応じて transitional flag を導入する。

候補:

```mathematica
$NBAccessLegacyAccessibleDirsImplyCloudPublic = True | False
```

ただし、Phase 4 初期では導入しない。

---

## 20. 採用しない案

### 21.1 単純な Boolean 追加案

```mathematica
<|
  "ReadableByAgent" -> True,
  "CloudSendAllowed" -> False
|>
```

を単に `NBFileSpec` に追加し、それぞれ別々の if 文で計算する案。

これは採用しない。

理由:

- NBAccess privacy spec v0.1 の PolicyLabel / AccessRequest モデルから外れる。
- Boolean が一次ポリシー化しやすい。
- 将来 `Provider`, `ModelIntent`, `Sink`, `Environment` に依存する判定に拡張しにくい。
- `CloudSendAllowed` の根拠が不透明になる。

### 21.2 PrivacyLevel 即時再定義案

`PrivacyLevel` をただちに `CloudSendAllowed` 由来に変える案。

これは採用しない。

理由:

- claudecode 側の既存 routing への影響が大きい。
- 回帰範囲が広すぎる。
- どの箇所が `PrivacyLevel` をどう解釈しているかを完全に確認する必要がある。
- Phase 1〜3 の「authorization 不変で進める」方針から急に外れる。

### 20.3 `$ClaudeAccessibleDirs` を CloudPublic とみなす案

`$ClaudeAccessibleDirs` 配下なら `CloudSendAllowed -> True` とする案。

これは採用しない。

理由:

- 「ローカルで読める」と「クラウド LLM に送れる」を混同する。
- 今回の Phase 4 の中心問題を解決しない。
- ユーザーの期待に反して、ローカル作業用ディレクトリの内容が外部送信可能扱いになる。

### 20.4 `NBAuthorizeFile` を独立 engine にする案

`NBAuthorizeFile` を `NBAuthorize` とは別の新しい権限判定器として実装する案。

これは採用しない。

理由:

- NBAccess 内に二重の authorization logic ができる。
- privacy spec v0.1 / Phase 14 API とずれる。
- 将来の PolicyLabel / ScoreGate / EnvironmentGate 拡張と分裂する。

`NBAuthorizeFile` はあくまで adapter とする。

### 20.5 projection key 入り spec をそのまま `NBAuthorize` に渡す案

`NBFileSpec[path, "IncludeProjections" -> True]` の結果を、そのまま `NBAuthorize` に渡す案。

これは採用しない。

理由:

- authorization input の素性が不安定になる。
- `ReadableByAgent` や `CloudSendAllowed` のような projection 結果が、次回の authorization 入力に混ざる。
- authorization の一次属性と派生属性が混ざる。
- 将来の cache / audit / diff が複雑になる。

必ず `iNBFileSpecForAuthorize` で projection key を落としてから `NBAuthorize` に渡す。

---

## 21. テスト観点

### 21.1 最小テストケース

| ケース | ReadableByAgent | CloudSendAllowed | 期待 |
|---|---:|---:|---|
| `$ClaudeAccessibleDirs` 配下、宣言なし | True | False | ローカル読取可、クラウド不可 |
| `CloudPublishable -> True` notebook | True | True | クラウド可 |
| `$packageDirectory` 配下の公開 package | True | policy次第 | package 公開方針に依存 |
| Dropbox 上の private notebook | policy次第 | False | cloud root だけでは cloud 可にしない |
| SourceVault cache | True | False | cache は原則 cloud 不可 |
| 明示 declassify 済み summary | True | True | 要約のみ cloud 可 |
| NBAuthorize が `$Failed` | False | False | fail-closed |
| NBAuthorize が `"RequireApproval"` | False | False | Boolean projection では不可 |
| base spec に PolicyLabel が無い | policy次第 | policy次第 | iNBFileSpecForAuthorize が補完する |
| projection 入り spec を渡す | 同じ | 同じ | projection key を落として同じ結果になる |
| ラベル未設定で PrivacyLevel 1.0 | True または policy次第 | False | PolicyGate は Pass でも ScoreGate で cloud 不可 |
| ラベル未設定で PrivacyLevel {0.5,1.0} | True または policy次第 | False | whole-file projection では Max[PrivacyLevel] を使う |
| CloudSend request の Sink が ExternalAPI | 実装依存 | 原則使わない | Phase 4.1 では Sink -> CloudLLM を使う |

### 21.2 回帰テスト

- `PrivacyLevel` の既存値が Phase 4 導入前後で変わらないこと。
- `NBFileSpec[path]["PrivacyLevel"]` の既存読み手が壊れないこと。
- `NBFileSpec[path, "IncludeProjections" -> False]` が軽量に返ること。
- `NBFileSpec[path, "IncludeProjections" -> True]` が notebook を重複 open しないこと。
- `NBFileSpec[path]["CloudSendAllowed"]` が `$ClaudeAccessibleDirs` だけでは True にならないこと。
- `CloudPublishable` 明示宣言がある場合だけ `CloudSendAllowed` が True になること。
- 送信直前に `NBAuthorizeFile[..., "SendExternal"]` を通らない cloud call が存在しないこと。
- `NBPermitQ` が `"Permit"` 以外をすべて False にすること。
- policy / routing 設定を変えたとき projection cache が無効化されること。
- `iNBFileSpecForAuthorize` が `BasePrivacyScore` / `EffectiveRiskScore` / `PolicyLabel` / `ContainerLabel` / `ContainerRisk` を補完すること。
- `iNBFileSpecForAuthorize` が projection key を落とすこと。
- `EffectiveRiskScore` が `PrivacyLevel` 由来で補完され、`{0.5, 1.0}` では `1.0` になること。
- `CloudSendAllowed` 用 request が Phase 4.1 では `Sink -> "CloudLLM"` を使うこと。
- `ProjectionComputedAt` が cache hit 時に現在時刻へ更新されないこと.
- cache key / equality 判定に `ProjectionComputedAt` が含まれないこと。

---

## 22. 最終方針

Phase 4 の設計判断は次のように定める。

```text
1. PrivacyLevel は当面凍結する。
2. PrivacyLevel は legacy / routing hint であり、authorization ではないと明記する。
3. ReadableByAgent / WritableByAgent / CloudSendAllowed は追加してよい。
4. ただし、それらは一次ポリシーではなく NBAuthorize の projection field とする。
5. CloudSendAllowed は Operation -> "SendExternal", Sink -> "ExternalAPI" の AccessRequest により判定する。
6. $ClaudeAccessibleDirs は ReadableByAgent の根拠にはなってよいが、CloudSendAllowed の根拠にはしない。
7. NBAuthorizeFile は既存 NBAuthorize の fileSpec adapter とする。
8. ただし、NBFileSpec を直接 NBAuthorize に渡さず、NBFileAuthorizationSpec に正規化する。
9. NBFileAuthorizationSpec には PrivacyLevel 由来の EffectiveRiskScore を必ず補完する。
10. CloudSend request は Phase 4.1 では現行 NBScoreGate に合わせて Sink -> "CloudLLM" とする。
11. NBPermitQ は fail-closed とする。
12. NBFileSpec は base spec と projection を分離し、cache する。
13. ProjectionComputedAt は projection 計算時刻であり、cache key には含めない。
14. claudecode 側は段階的に PrivacyLevel 直接参照から CloudSendAllowed / NBAuthorizeFile 参照へ移行する。
15. PrivacyLevel 自体の再定義は Phase 5 以降の別タスクとする.
```

この方針により、相手のいう「加算フィールド案」の後方互換性は保ちつつ、ユーザーの懸念である「アドホックにフィールドを追加せず、privacy spec に準拠すべき」という要求も満たせる。

さらに、現行 `api.md` に存在しない API を既存前提で書かず、Phase 4 の実装範囲を現実的に限定できる。

---

## 23. 短い実装メモ

### 23.1 NBFileSpec projection の形

```mathematica
Options[NBFileSpec] = {
  "IncludeProjections" -> False
};

NBFileSpec[path_, opts : OptionsPattern[]] :=
 Module[{base, projections},
   base = iNBFileSpecBaseCached[path];

   If[!TrueQ[OptionValue["IncludeProjections"]],
     Return[base]
   ];

   projections = iNBFileSpecProjectionsCached[base];

   Join[base, projections]
 ]
```

### 23.2 projection calculation

```mathematica
iNBFileSpecProjections[base_Association] :=
 Module[{readReq, writeReq, cloudReq, readDec, writeDec, cloudDec},
   readReq = NBMakeFileAccessRequest[
     base,
     "ReadValue",
     "Sink" -> "KernelValue",
     "Networked" -> False,
     "AccessLevel" -> 1.0
   ];

   writeReq = NBMakeFileAccessRequest[
     base,
     "WriteCell",
     "Sink" -> "NotebookCell",
     "Networked" -> False,
     "AccessLevel" -> 1.0
   ];

   cloudReq = NBMakeFileAccessRequest[
     base,
     "SendExternal",
     "Sink" -> "CloudLLM",
     "Networked" -> True,
     "Route" -> "CloudLLM",
     "AccessLevel" -> Lookup[$NBRoutingThresholds, "Cloud", 0.5]
   ];

   readDec = NBAuthorizeFile[base, readReq];
   writeDec = NBAuthorizeFile[base, writeReq];
   cloudDec = NBAuthorizeFile[base, cloudReq];

   <|
     "ReadableByAgent" -> NBPermitQ[readDec],
     "WritableByAgent" -> NBPermitQ[writeDec],
     "CloudSendAllowed" -> NBPermitQ[cloudDec],

     "ReadDecision" -> readDec,
     "WriteDecision" -> writeDec,
     "CloudSendDecision" -> cloudDec,

     "ProjectionSource" -> "NBAuthorize",
     "ProjectionComputedAt" -> DateObject[]
   |>
 ]
```

注: `ProjectionComputedAt` は、この association が実際に作成された時刻である。cache hit 時には、この時刻は更新しない。

### 23.3 NBAuthorizeFile

```mathematica
NBAuthorizeFile[pathOrSpec_, req_Association] :=
 Module[{rawSpec, authSpec, decision},
   rawSpec =
     If[AssociationQ[pathOrSpec],
       pathOrSpec,
       NBFileSpec[pathOrSpec, "IncludeProjections" -> False]
     ];

   authSpec = iNBFileSpecForAuthorize[rawSpec];

   decision = Quiet @ Check[
     NBAuthorize[authSpec, req],
     <|
       "Decision" -> "Deny",
       "ReasonClass" -> "AuthorizationError",
       "VisibleExplanation" -> "File authorization failed."
     |>
   ];

   decision
 ];
```

### 23.4 Cloud call 直前の必須チェック

```mathematica
iClaudeSendExternalForFile[fileSpec_, provider_, model_, opts___] :=
 Module[{req, decision, accessLevel},
   accessLevel = NBGetProviderMaxAccessLevel[provider];

   req = NBMakeFileAccessRequest[
     fileSpec,
     "SendExternal",
     "Sink" -> "CloudLLM",
     "Networked" -> True,
     "Route" -> "CloudLLM",
     "Provider" -> provider,
     "Model" -> model,
     "AccessLevel" -> accessLevel
   ];

   decision = NBAuthorizeFile[fileSpec, req];

   If[!NBPermitQ[decision],
     Return[Failure["CloudSendDenied", <|
       "Decision" -> decision,
       "Provider" -> provider,
       "Model" -> model
     |>]]
   ];

   iActuallySendExternal[fileSpec, provider, model, opts]
 ]
```

注: context bundle 用の authorization は Phase 4.4 以降に分離する。Phase 4.1 では single fileSpec のみを対象にする。

---

## 24. 関連する今後の課題

この文書の射程は Phase 4 の設計方針までである。

以下は別タスクとして扱う。

1. `GrantedBy` / `GrantedAt` / audit trail の本格導入
2. `Declassify` / `ReleasePolicy` による要約だけの cloud send
3. `GuardedApply` による秘密関数実行制御
4. `AuditState` による反復問い合わせの推定漏えい対策
5. `PrivacyLevel` の再定義または廃止
6. `NBPathRegistry.wl` のような共通 path registry パッケージの新設検討
7. SourceVault bundle 単位の `NBAuthorizeContextBundle`
8. DLM / LabelJoin / SinkLabel / EnvironmentLabel の本格実装
9. provider / model intent 別 cloud send policy
10. SourceVault EvidenceBundle と NBAccess policy の統合
11. `NBFileAuthorizationSpec` を公開 API にするか、Private helper に留めるかの判断
12. `Sink -> "CloudLLM"` と `Sink -> "ExternalAPI"` / `Environment["Route"]` の長期的な整理
13. 現行 `NBScoreGate` が参照する score key (`EffectiveRiskScore`, `AccessLevel`) の仕様固定
