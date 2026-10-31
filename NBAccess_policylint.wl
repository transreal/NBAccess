(* ::Package:: *)

(* ============================================================
   NBAccess_policylint.wl -- パッケージソースのポリシー検査 (構文木ベース)

   This file is encoded in UTF-8.
   Load: NBAccess.wl の末尾で自動的に読み込まれる。
         単独: Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess_policylint.wl"]]

   設計: ドキュメント/NBAccess_policy_lint_redesign_proposal_v0_1.md

   規則:
     SEP-   NBAccess 分離 (旧 ClaudeCheckSeparation の a〜j を構文木で照合し直したもの)
     CRED-  認証情報
     PRIV-  プライバシーレベル (Phase 2)
     ACC-   アクセスレベル (Phase 2)
   棚卸し (Inventory): AccessLevel の指定箇所・機密解除の呼び出し・ネットワーク送信 (Phase 2)
   waiver: 該当行か直前行に :PolicyWaiver: RuleID 理由、ファイル先頭 40 行に
           :PolicyLintIgnore: RuleID 理由 をコメントで書く (Phase 2)

   方式:
     - CodeParser`CodeParse の構文木で照合する。文字列とコメントは葉なので、
       その中の文字列を誤って違反にしない。複数行にまたがる式も 1 つの節点になる。
     - 0 桁目のトップレベル形式をまとめた単位で解析し、単位の内容ハッシュでキャッシュする。
       規則の手がかりになる語を含まない単位は解析を省く。
     - 解析できない範囲が残ったら Status "Failed" (fail-closed)。

   依存: なし。CodeParser は Wolfram 標準 paclet で、初回の検査時に読み込む。
         LLM・FrontEnd・ネットワークを使わず、ファイルを読むだけ (書き込みなし)。

   注意: Wolfram のコメントは入れ子になるので、コメント本文にコメントの開始・終了記号を書かない。
   ============================================================ *)

BeginPackage["NBAccess`"];

NBAuditPackageSource::usage =
  "NBAuditPackageSource[files] はパッケージソース (.wl) を構文木で検査し、規則違反を返す。\n" <>
  "files は 1 つのパスかパスのリスト。規則は NBAccess 分離 (SEP-)・認証情報 (CRED-)・\n" <>
  "プライバシーレベル (PRIV-)・アクセスレベル (ACC-)。一覧は NBAuditPackageSourceRules[]。\n" <>
  "戻り値: <|\"Status\" -> \"OK\"|\"Violations\"|\"Failed\", \"Files\",\n" <>
  "  \"Coverage\" -> <|\"Parsed\", \"Failed\", \"Units\"|>,\n" <>
  "  \"Findings\" -> {<|\"RuleID\", \"Severity\", \"File\", \"FileName\", \"Line\", \"Column\", \"EndLine\",\n" <>
  "     \"Definition\", \"Head\", \"Code\", \"Message\", \"Remedy\", \"Basis\", \"AutoFix\", \"Waived\"|>..},\n" <>
  "  \"Counts\" (waiver の無いもの), \"Waived\", \"Inventory\" -> <|\"AccessSites\", \"DeclassifySites\", \"EgressSites\"|>,\n" <>
  "  \"RulesVersion\", \"Seconds\"|>。\n" <>
  "解析できない範囲が残ったファイルがあれば \"Failed\"、FailOn の重大度で waiver の無い違反があれば \"Violations\"。\n" <>
  "waiver: 該当行か直前行のコメントに :PolicyWaiver: RuleID 理由、ファイル先頭 40 行のコメントに\n" <>
  "  :PolicyLintIgnore: RuleID 理由 (RuleID はカンマ区切りで複数可、* は全規則。理由は必須)。\n" <>
  "Options: \"Rules\" -> All | {ruleID..}, \"FailOn\" -> {\"Error\"},\n" <>
  "  \"Cache\" -> True (カーネル内 + ディスク $UserBaseDirectory/ApplicationData/NBAccess/policylint_cache.wxf) | \"Memory\" | False,\n" <>
  "  \"TimeBudget\" -> Infinity (秒。超えたファイルは未検査として Failed に数える), \"MaxMergeLines\" -> 4000,\n" <>
  "  \"IncludeInventory\" -> True。";

NBAuditPackageSourceText::usage =
  "NBAuditPackageSourceText[code, name] はファイルに保存していないソース文字列 code を\n" <>
  "ファイル名 name のものとして NBAuditPackageSource と同じ規則で検査する (ゲートウェイの判定に name を使う)。\n" <>
  "戻り値とオプションは NBAuditPackageSource と同じ。";

NBAuditPackageSourceRules::usage =
  "NBAuditPackageSourceRules[] は NBAuditPackageSource の規則表\n" <>
  "<|RuleID -> <|\"Severity\", \"Basis\", \"Gateways\", \"AutoFix\", \"Message\", \"Remedy\"|>|> と版を返す。\n" <>
  "AutoFix は LLM による機械的な修正案の対象にしてよいか (セキュリティ判断を含む規則は False)。";

Begin["`Private`"];

(* 規則・照合の中身を変えたら上げる (キャッシュのキーに入る) *)
$iNBPLVersion = "2026-10-31.9";

$iNBPLSepGateways = {"NBAccess*", "NotebookExtensions*"};

$iNBPLRules = <|
  "SEP-CELL" -> <|"Severity" -> "Error", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "セル・FrontEnd を直接操作しています。",
    "Remedy" -> "NBAccess の公開 API (NBWriteCell, NBCellRead, NBMoveAfterCell, NBCellIndicesByTag, NBBeginJobAtEvalCell, NBEvaluatePreviousCell など) を使う。"|>,
  "SEP-ATTR" -> <|"Severity" -> "Error", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "TaggingRules / CellTags / CellEpilog などのセル属性を直接読み書きしています。",
    "Remedy" -> "NBCellGetTaggingRule / NBCellSetOptions / NBInstallCellEpilog / NBInstallConfidentialEpilog などを使う。"|>,
  "SEP-PRIVATE" -> <|"Severity" -> "Error", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "NBAccess`Private` の内部シンボルを参照しています。",
    "Remedy" -> "NBAccess の公開 API を使う。足りなければ NBAccess に公開 API を追加する。"|>,
  "SEP-GLOBAL" -> <|"Severity" -> "Error", "Basis" -> "rules/00, rules/10",
    (* localInit.wl は利用者の起動設定で、$NBCredentialBackend などをパッケージ読み込み前に決める役目 *)
    "Gateways" -> Append[$iNBPLSepGateways, "localInit*"], "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "NBAccess の公開グローバル ($NB...) を直接書き換えています。",
    "Remedy" -> "setter API (NBRegisterConfidentialVar, NBSetConfidentialVars, NBSetAccessibleDirs など) を使う。"|>,
  "SEP-CELLOBJ" -> <|"Severity" -> "Review", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> False,
    "Message" -> "::usage を持つ公開関数が CellObject を引数に取っています。",
    "Remedy" -> "セル番号ベースの NBAccess API に置き換え、CellObject を公開 API に出さない。"|>,
  "CRED-SYSCRED" -> <|"Severity" -> "Error", "Basis" -> "rules/20",
    "Gateways" -> {"NBAccess*"}, "SeparationIgnore" -> False, "AutoFix" -> True,
    "Message" -> "SystemCredential を直接呼んでいます。",
    "Remedy" -> "NBAccess`NBGetAPIKey / NBAccess`NBGetCredential を使う。"|>,
  "CRED-LITERAL" -> <|"Severity" -> "Error", "Basis" -> "rules/20",
    "Gateways" -> {}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "API キーやトークンらしい文字列がソースに書かれています (Code 欄は伏せ字)。",
    "Remedy" -> "鍵をソースから消して credential store に置き、NBGetAPIKey で取得する。漏れた鍵は無効化する。"|>,
  (* 2026-10-31 Phase 4: 既存の 21 件を仕分け (NBAccess API へ置き換え 3・理由付き waiver 18) て Review から Error に上げた *)
  "PRIV-NB-READ" -> <|"Severity" -> "Error", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "PrivacyLevel を見ずに .nb を読んでいます。",
    "Remedy" -> "NBAccess`NBFileOpen / NBFileReadCellsInRange / NBFileReadAllCells / NBReadHeader / NBReadTodos を使う。正当な理由があれば :PolicyWaiver: で理由を残す。"|>,
  "PRIV-NB-WRITE" -> <|"Severity" -> "Error", "Basis" -> "rules/10",
    "Gateways" -> $iNBPLSepGateways, "SeparationIgnore" -> True, "AutoFix" -> True,
    "Message" -> "Notebook を Export で直接書き出しています (セルの秘匿属性が消える)。",
    "Remedy" -> "NBAccess`NBFileWriteAllCells と NBAccess`NBFileSave を使う。"|>,
  "PRIV-LLM-CHANNEL" -> <|"Severity" -> "Error", "Basis" -> "rules/21",
    "Gateways" -> {}, "SeparationIgnore" -> False, "AutoFix" -> True,
    "Message" -> "LLMSynthesize / LLMFunction など、privacy ルータと課金 API フラグを通らない別チャネルの LLM を呼んでいます。",
    "Remedy" -> "ClaudeCode`ClaudeQuerySync[prompt, \"PrivacyLevel\" -> pl] などの privacy・課金対応ルータを使う。既定を外れる理由があれば :PolicyWaiver: に書く。"|>,
  "PRIV-EGRESS-LLM" -> <|"Severity" -> "Review", "Basis" -> "rules/21",
    "Gateways" -> {"claudecode*", "NBAccess*"}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "LLM API のエンドポイントへ直接通信しています (privacy ルータと課金 API フラグを迂回)。",
    "Remedy" -> "ClaudeQuerySync などのルータ経由にする。モデル一覧の取得など内容を送らない用途なら :PolicyWaiver: で理由を残す。"|>,
  "PRIV-LEVEL-LITERAL" -> <|"Severity" -> "Review", "Basis" -> "rule 61",
    "Gateways" -> {"NBAccess*"}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "PrivacyLevel を 0.5 未満の定数で決め打ちしています。",
    "Remedy" -> "ノートブックの宣言 (Public / Private / Unspecified) や NBAccess の判定から決める。公開物で正当なら :PolicyWaiver: で理由を残す。"|>,
  "PRIV-MODEL-OVERRIDE" -> <|"Severity" -> "Review", "Basis" -> "rules/00, rules/21",
    "Gateways" -> {"claudecode*", "NBAccess*", "localInit*"}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "$ClaudeModel / $ClaudePrivateModel / $ClaudeTestModel / $ClaudeFallbackModels を書き換えています。",
    "Remedy" -> "モデル選択は ClaudeQuerySync の Model / PrivacyLevel オプションに任せる。明示的に切り替える理由があれば :PolicyWaiver: に書く。"|>,
  "ACC-ELEVATED" -> <|"Severity" -> "Review", "Basis" -> "rules/10",
    "Gateways" -> {"NBAccess*"}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "AccessLevel を 0.7 以上の定数で指定しています (書き込み系・秘匿データ相当の権限)。",
    "Remedy" -> "必要性を確認し、:PolicyWaiver: で理由を残す。"|>,
  "ACC-UNTRUSTED" -> <|"Severity" -> "Review", "Basis" -> "rules/10, rule 107",
    "Gateways" -> {"NBAccess*"}, "SeparationIgnore" -> False, "AutoFix" -> False,
    "Message" -> "AccessLevel が呼び出し側の引数・オプションから決まっています (呼び出し側が権限を上げられる)。",
    "Remedy" -> "NBAccess の判定関数 (NBGetProviderMaxAccessLevel, NBLocalLLMEffectiveMaxAccessLevel, NBMakeRuntimeAccessSpec など) で上限をかける。"|>
|>;

$iNBPLCellHeads = {"Cells", "NotebookRead", "NotebookWrite", "SelectionMove", "CellPrint",
  "EvaluationCell", "SelectedCells", "SetSelectedNotebook", "SelectionEvaluate",
  "SelectionEvaluateCreateCell", "FrontEndTokenExecute"};
$iNBPLAttrHeads = {"CurrentValue", "AbsoluteCurrentValue", "SetOptions"};
$iNBPLAttrSyms = {"TaggingRules", "CellTags", "CellEpilog", "CellProlog",
  "NotebookEventActions", "CellDynamicExpression", "NotebookDynamicExpression"};
$iNBPLMutators = {"Set", "SetDelayed", "AppendTo", "PrependTo", "AssociateTo", "KeyDropFrom",
  "Unset", "AddTo", "SubtractFrom", "TimesBy", "DivideBy", "Increment", "Decrement",
  "PreIncrement", "PreDecrement", "ApplyTo"};
$iNBPLClearers = {"Clear", "ClearAll"};
$iNBPLBlockHeads = {"Block", "System`Block", "Internal`InheritedBlock"};
$iNBPLNbReadHeads = {"NotebookImport", "NotebookGet", "NotebookOpen"};
$iNBPLLLMChannelHeads = {"LLMSynthesize", "LLMFunction", "ChatEvaluate", "LLMResourceFunction",
  "LLMExampleFunction"};
$iNBPLNetHeads = {"URLRead", "URLExecute", "URLSubmit", "URLFetch", "URLFetchAsynchronous",
  "URLSave", "URLSaveAsynchronous", "URLDownload", "ServiceExecute"};
$iNBPLProcHeads = {"RunProcess", "StartProcess"};
$iNBPLDeclassifyHeads = {"NBSetCloudPublishable", "NBUnmarkCell", "NBClearWriteConfidential",
  "NBSetSnapshotPrivacyLevel"};
$iNBPLModelVars = {"$ClaudeModel", "$ClaudePrivateModel", "$ClaudeTestModel", "$ClaudeFallbackModels"};

(* 鍵の形式 (ASCII で定義される書式なので ASCII クラスでよい) *)
$iNBPLSecretRE = RegularExpression[
  "sk-[A-Za-z0-9_\\-]{32,}|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|" <>
  "xox[baprs]-[A-Za-z0-9\\-]{10,}|AIza[0-9A-Za-z_\\-]{35}|Bearer\\s+[A-Za-z0-9._\\-]{30,}"];

(* LLM API のホスト。provider を足したらここに足す (構造化データなので .wl に置く) *)
$iNBPLLLMHostRE = RegularExpression[
  "api\\.anthropic\\.com|api\\.openai\\.com|generativelanguage\\.googleapis\\.com|" <>
  "api\\.z\\.ai|open\\.bigmodel\\.cn|api\\.deepseek\\.com|openrouter\\.ai|api\\.groq\\.com|" <>
  "api\\.x\\.ai|api\\.mistral\\.ai|api\\.cohere\\.(?:ai|com)"];

$iNBPLIdentRE = "(?:[\\p{L}$][\\p{L}\\p{N}$]*`)*[\\p{L}$][\\p{L}\\p{N}$]*";
(* 0 桁目が「識別子 + [ / := / = / :: / ( / /: / ^=」の行と、0 桁目のコメント開始が単位の境界 *)
$iNBPLStartRE = RegularExpression[
  "(?:" <> $iNBPLIdentRE <> ")\\s*(?:\\[|::|:?=|\\(|/:|\\^:?=)"];

(* waiver: RuleID はカンマ区切り、* は全規則、理由は必須 *)
$iNBPLWaiverIDs = "([A-Z*][A-Z0-9*\\-]*(?:\\s*,\\s*[A-Z*][A-Z0-9*\\-]*)*)";
$iNBPLWaiverRE = RegularExpression["\\(\\*\\s*:PolicyWaiver:\\s*" <> $iNBPLWaiverIDs <> "\\s+(.*?)\\s*\\*\\)"];
$iNBPLIgnoreRE = RegularExpression["\\(\\*\\s*:PolicyLintIgnore:\\s*" <> $iNBPLWaiverIDs <> "\\s+(.*?)\\s*\\*\\)"];

If[!AssociationQ[$iNBPLCache], $iNBPLCache = <||>];

iNBPLEnsureCodeParser[] := (
  If[!MemberQ[$Packages, "CodeParser`"], Quiet @ Check[Needs["CodeParser`"], Null]];
  MemberQ[$Packages, "CodeParser`"]);

iNBPLShort[s_String] := Last[StringSplit[s, "`"]];

(* 文脈なし、または指定の文脈 (既定 System) の名前だけを対象の関数とみなす *)
iNBPLHeadIn[s_String, heads_List] := iNBPLHeadIn[s, heads, "System"];
iNBPLHeadIn[s_String, heads_List, ctx_String] := With[{p = StringSplit[s, "`"]},
  MemberQ[heads, Last[p]] && (Length[p] === 1 || (Length[p] === 2 && First[p] === ctx))];

iNBPLErrorNodeQ[n_] := With[{h = Head[n]},
  MatchQ[h, _Symbol] && Context[h] === "CodeParser`" &&
    StringMatchQ[SymbolName[h], "*ErrorNode" | "*Missing*" | "Unterminated*"]];

iNBPLParse[s_String] := Module[{a = Quiet @ Check[CodeParser`CodeParse[s], $Failed]},
  If[MatchQ[a, _CodeParser`ContainerNode] && FreeQ[a, n_ /; iNBPLErrorNodeQ[n]], a, $Failed]];

iNBPLPos[d_Association] := Replace[Lookup[d, CodeParser`Source, None],
  Except[{{_Integer, _Integer}, {_Integer, _Integer}}] -> {{1, 1}, {1, 1}}];

iNBPLHit[rule_String, head_String, d_Association, def_String] :=
  <|"RuleID" -> rule, "Head" -> head, "Pos" -> iNBPLPos[d], "Definition" -> def|>;

(* 文字列・数値リテラルの値。リテラルの字句を読むだけなので評価の副作用は無い *)
iNBPLStrVal[CodeParser`LeafNode[String, s_String, _]] :=
  Replace[Quiet @ Check[ToExpression[s, InputForm], $Failed], Except[_String] -> s];
iNBPLStrVal[_] := None;
iNBPLNumVal[CodeParser`LeafNode[Integer | Real, s_String, _]] :=
  With[{v = Quiet @ Check[ToExpression[s, InputForm], $Failed]}, If[NumericQ[v], N[v], $Failed]];
iNBPLNumVal[_] := $Failed;

(* ── 定義名 ── *)
iNBPLLHSName[CodeParser`CallNode[CodeParser`LeafNode[Symbol,
    "Condition" | "HoldPattern" | "Verbatim" | "PatternTest", _], {x_, ___}, _]] := iNBPLLHSName[x];
iNBPLLHSName[CodeParser`CallNode[CodeParser`LeafNode[Symbol, "MessageName", _], {x_, ___}, _]] :=
  iNBPLLHSName[x];
iNBPLLHSName[CodeParser`CallNode[h_, _, _]] := iNBPLLHSName[h];
iNBPLLHSName[CodeParser`LeafNode[Symbol, s_String, _]] := iNBPLShort[s];
iNBPLLHSName[_] := "";

$iNBPLDefOps = {"Set", "SetDelayed", "UpSet", "UpSetDelayed", "TagSet", "TagSetDelayed"};
iNBPLDefLHS[CodeParser`CallNode[CodeParser`LeafNode[Symbol, op_String, _], args_List, _]] /;
    MemberQ[$iNBPLDefOps, op] && args =!= {} := First[args];
iNBPLDefLHS[_] := None;
iNBPLDefName[t_] := Replace[iNBPLDefLHS[t], {None -> "", lhs_ :> iNBPLLHSName[lhs]}];

(* 定義の左辺にあるパターン変数名 (引数) *)
iNBPLParamNames[t_] := With[{lhs = iNBPLDefLHS[t]},
  If[lhs === None, {},
    DeleteDuplicates @ Cases[{lhs}, CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Pattern", _],
      {CodeParser`LeafNode[Symbol, n_String, _], ___}, _] :> iNBPLShort[n], Infinity]]];

iNBPLUsageNames[t_] := Cases[{t},
  CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Set" | "SetDelayed", _],
    {CodeParser`CallNode[CodeParser`LeafNode[Symbol, "MessageName", _],
       {CodeParser`LeafNode[Symbol, s_String, _], CodeParser`LeafNode[String, u_String, _], ___}, _], _},
    _] /; StringMatchQ[u, "\"usage\"" | "usage"] :> iNBPLShort[s]];

(* ── 照合の部品 ── *)
iNBPLShallow1[CodeParser`LeafNode[Symbol, s_String, _]] := {iNBPLShort[s]};
iNBPLShallow1[CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Rule" | "RuleDelayed", _], {lhs_, ___}, _]] :=
  iNBPLShallow1[lhs];
iNBPLShallow1[_] := {};
iNBPLShallow[CodeParser`CallNode[CodeParser`LeafNode[Symbol, "List", _], items_List, _]] :=
  Flatten[iNBPLShallow1 /@ items];
iNBPLShallow[x_] := iNBPLShallow1[x];

(* 引数 (と引数のリストの要素) にある文字列リテラルの値 *)
iNBPLShallowStrings[args_List] := Select[Flatten[Replace[args, {
    CodeParser`CallNode[CodeParser`LeafNode[Symbol, "List", _], items_List, _] :> (iNBPLStrVal /@ items),
    x_ :> iNBPLStrVal[x]}, {1}]], StringQ];

(* CurrentValue[obj, TaggingRules] / CurrentValue[obj, {TaggingRules, ...}] / SetOptions[obj, CellTags -> ...] *)
iNBPLAttrArgsQ[args_List] := AnyTrue[args, IntersectingQ[iNBPLShallow[#], $iNBPLAttrSyms] &];

iNBPLNbPathQ[x_] := With[{v = iNBPLStrVal[x]}, StringQ[v] && StringEndsQ[ToLowerCase[v], ".nb"]];
(* Import[path, "Notebook"] / Import["x.nb"] / Get["x.nb"] *)
iNBPLNbReadArgsQ[args_List] := args =!= {} &&
  (iNBPLNbPathQ[First[args]] || IntersectingQ[iNBPLShallowStrings[Rest[args]], {"Notebook", "NB"}]);
(* Export["x.nb", ...] / Export[path, expr, "NB"] / Export[path, Notebook[...]] *)
iNBPLNbWriteArgsQ[args_List] := args =!= {} &&
  (iNBPLNbPathQ[First[args]] || IntersectingQ[iNBPLShallowStrings[Rest[args]], {"Notebook", "NB"}] ||
    (Length[args] >= 2 && MatchQ[args[[2]],
      CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Notebook" | "System`Notebook", _], _, _]]));

iNBPLBaseSymbol[CodeParser`LeafNode[Symbol, s_String, _]] := s;
iNBPLBaseSymbol[CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Part", _], {b_, ___}, _]] :=
  iNBPLBaseSymbol[b];
iNBPLBaseSymbol[CodeParser`CallNode[h_, _, _]] := iNBPLBaseSymbol[h];
iNBPLBaseSymbol[_] := "";

iNBPLGlobalQ[s_String] := StringMatchQ[s, RegularExpression["(?:NBAccess`)?\\$NB[\\p{L}\\p{N}]+"]];
iNBPLGlobalQ[_] := False;
iNBPLModelVarQ[s_String] := iNBPLHeadIn[s, $iNBPLModelVars, "ClaudeCode"];
iNBPLModelVarQ[_] := False;

iNBPLPrivacyKeyQ[k_] := MatchQ[k, CodeParser`LeafNode[String, "\"PrivacyLevel\"", _]] ||
  MatchQ[k, CodeParser`LeafNode[Symbol, "PrivacyLevel" | "ClaudeCode`PrivacyLevel", _]];
iNBPLLowLiteralQ[v_] := With[{x = iNBPLNumVal[v]}, NumericQ[x] && 0 <= x < 0.5];

(* ── ACC ── 戻り値 {findings, inventory} *)
iNBPLAccSource[v_, params_List] := Which[
  MatchQ[v, CodeParser`LeafNode[Integer | Real, _, _]], "Literal",
  MatchQ[v, CodeParser`CallNode[CodeParser`LeafNode[Symbol, s_String /;
      StringStartsQ[iNBPLShort[s], "NB"] && iNBPLHeadIn[s, {iNBPLShort[s]}, "NBAccess"], _], _, _]], "NBAccessAPI",
  MatchQ[v, CodeParser`CallNode[CodeParser`LeafNode[Symbol, "OptionValue" | "System`OptionValue", _], _, _]], "Option",
  MatchQ[v, CodeParser`LeafNode[Symbol, s_String /; MemberQ[params, iNBPLShort[s]], _]], "Parameter",
  True, "Other"];

(* 公開関数 (::usage あり) の引数に _CellObject があるか。usage はファイル全体で集めてから照合する *)
iNBPLCellObjDefs[t_, def_String] := If[def === "", {},
  Cases[{t},
    CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Set" | "SetDelayed", _], {lhs_, _}, d_Association] /;
      !FreeQ[lhs, CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Blank" | "BlankSequence" | "BlankNullSequence", _],
        {CodeParser`LeafNode[Symbol, "CellObject" | "System`CellObject", _]}, _]] :>
      <|"RuleID" -> "SEP-CELLOBJ", "Head" -> "CellObject", "Definition" -> def,
        "Pos" -> If[MatchQ[lhs, _CodeParser`CallNode], iNBPLPos[Last[lhs]], iNBPLPos[d]]|>]];

(* トップレベルの文を取り出す。CodeParse は BeginPackage/EndPackage・Begin/End の間を
   PackageNode / ContextNode / NewContextPathNode に包むので、その内側まで展開する *)
iNBPLTops[CodeParser`CallNode[CodeParser`LeafNode[Symbol, "CompoundExpression", _], ch_List, _]] :=
  Flatten[iNBPLTops /@ ch, 1];
iNBPLTops[n:(_CodeParser`PackageNode | _CodeParser`ContextNode | _CodeParser`NewContextPathNode)] /;
    Length[n] >= 2 && ListQ[n[[2]]] :=
  Flatten[iNBPLTops /@ n[[2]], 1];
iNBPLTops[n_] := {n};

(* 1 つのトップレベル文を検査する。呼び出し・文字列・NBAccess`Private` 参照を 1 回ずつ集め、
   規則ごとに関数名で引く (規則ごとに構文木を走査し直すと全体の時間が数倍になる) *)
iNBPLCallRec[s_String, args_List, d_Association] := With[{p = StringSplit[s, "`"]},
  <|"S" -> s, "Short" -> Last[p], "Ctx" -> If[Length[p] === 1, "", StringRiffle[Most[p], "`"]],
    "Args" -> args, "D" -> d|>];

$iNBPLSysCtx = {"", "System"};

iNBPLAnalyzeTop[t_] := Module[{def = iNBPLDefName[t], calls, byShort, get, hit, strs, hasHost,
    blockPos, mut, params, accSites, findings, inv},
  calls = Cases[{t}, CodeParser`CallNode[CodeParser`LeafNode[Symbol, s_String, _], args_List, d_Association] :>
    iNBPLCallRec[s, args, d], Infinity];
  byShort = GroupBy[calls, #Short &];
  get[heads_List, ctxs_List] := Select[Flatten[Lookup[byShort, heads, {}], 1], MemberQ[ctxs, #Ctx] &];
  hit[rule_String, c_Association] := iNBPLHit[rule, c["Short"], c["D"], def];
  strs = Cases[{t}, CodeParser`LeafNode[String, s_String, d_Association] :> {s, d}, Infinity];
  hasHost = AnyTrue[strs, StringContainsQ[#[[1]], $iNBPLLLMHostRE] &];
  (* Block[{$X = ...}, ...] の束縛位置: 一時的な上書きとして区別する *)
  blockPos = Flatten[Function[c,
      If[c["Args"] =!= {} && MatchQ[First[c["Args"]], CodeParser`CallNode[CodeParser`LeafNode[Symbol, "List", _], _List, _]],
        iNBPLPos[Last[#]] & /@ Cases[First[c["Args"]][[2]],
          CodeParser`CallNode[CodeParser`LeafNode[Symbol, "Set" | "SetDelayed", _], _, _]],
        {}]] /@ get[{"Block", "InheritedBlock"}, {"", "System", "Internal"}], 1];
  mut = Select[get[$iNBPLMutators, $iNBPLSysCtx], #Args =!= {} &];
  findings = Join[
    (* SEP / CRED *)
    hit["SEP-CELL", #] & /@ get[$iNBPLCellHeads, $iNBPLSysCtx],
    hit["SEP-ATTR", #] & /@ Select[get[$iNBPLAttrHeads, $iNBPLSysCtx], iNBPLAttrArgsQ[#Args] &],
    DeleteDuplicatesBy[
      Cases[{t}, CodeParser`LeafNode[Symbol, s_String /; StringStartsQ[s, "NBAccess`Private`"], d_Association] :>
        iNBPLHit["SEP-PRIVATE", s, d, def], Infinity],
      #Pos[[1, 1]] &],
    Function[c, With[{sym = iNBPLBaseSymbol[First[c["Args"]]]},
        If[MemberQ[blockPos, iNBPLPos[c["D"]]],
          Join[iNBPLHit["SEP-GLOBAL", sym, c["D"], def], <|"Severity" -> "Review", "Note" -> "Block"|>],
          iNBPLHit["SEP-GLOBAL", sym, c["D"], def]]]] /@
      Select[mut, iNBPLGlobalQ[iNBPLBaseSymbol[First[#Args]]] &],
    hit["SEP-GLOBAL", #] & /@
      Select[get[$iNBPLClearers, $iNBPLSysCtx], AnyTrue[#Args, Function[a, iNBPLGlobalQ[iNBPLBaseSymbol[a]]]] &],
    hit["CRED-SYSCRED", #] & /@ get[{"SystemCredential"}, $iNBPLSysCtx],
    iNBPLHit["CRED-LITERAL", "", #[[2]], def] & /@ Select[strs, StringContainsQ[#[[1]], $iNBPLSecretRE] &],
    (* PRIV *)
    hit["PRIV-NB-READ", #] & /@ Join[get[$iNBPLNbReadHeads, $iNBPLSysCtx],
      Select[get[{"Import", "Get"}, $iNBPLSysCtx], iNBPLNbReadArgsQ[#Args] &]],
    hit["PRIV-NB-WRITE", #] & /@ Select[get[{"Export"}, $iNBPLSysCtx], iNBPLNbWriteArgsQ[#Args] &],
    hit["PRIV-LLM-CHANNEL", #] & /@ get[$iNBPLLLMChannelHeads, $iNBPLSysCtx],
    (* 同じ定義の中に LLM API のホストが書かれていれば、その定義のネットワーク送信・外部プロセスを数える *)
    If[hasHost, hit["PRIV-EGRESS-LLM", #] & /@ get[Join[$iNBPLNetHeads, $iNBPLProcHeads], $iNBPLSysCtx], {}],
    iNBPLHit["PRIV-LEVEL-LITERAL", "PrivacyLevel", #D, def] & /@
      Select[get[{"Rule", "RuleDelayed"}, $iNBPLSysCtx],
        Length[#Args] === 2 && iNBPLPrivacyKeyQ[#Args[[1]]] && iNBPLLowLiteralQ[#Args[[2]]] &],
    Function[c, With[{sym = iNBPLShort[iNBPLBaseSymbol[First[c["Args"]]]]},
        If[MemberQ[blockPos, iNBPLPos[c["D"]]],
          Join[iNBPLHit["PRIV-MODEL-OVERRIDE", sym, c["D"], def], <|"Note" -> "Block"|>],
          iNBPLHit["PRIV-MODEL-OVERRIDE", sym, c["D"], def]]]] /@
      Select[mut, iNBPLModelVarQ[iNBPLBaseSymbol[First[#Args]]] &]];
  (* ACC: "AccessLevel" -> v / spec["AccessLevel"] = v の v の出所 *)
  params = iNBPLParamNames[t];
  accSites = Join[
    {#Args[[2]], #D} & /@ Select[get[{"Rule", "RuleDelayed"}, $iNBPLSysCtx],
      Length[#Args] === 2 && MatchQ[#Args[[1]], CodeParser`LeafNode[String, "\"AccessLevel\"", _]] &],
    {#Args[[2]], #D} & /@ Select[get[{"Set", "SetDelayed"}, $iNBPLSysCtx],
      Length[#Args] === 2 &&
        MatchQ[#Args[[1]], CodeParser`CallNode[_, {CodeParser`LeafNode[String, "\"AccessLevel\"", _]}, _]] &]];
  findings = Join[findings, Flatten[Function[{v, d},
      With[{src = iNBPLAccSource[v, params], x = iNBPLNumVal[v]},
        Which[
          src === "Literal" && NumericQ[x] && x >= 0.7, {iNBPLHit["ACC-ELEVATED", "AccessLevel", d, def]},
          MemberQ[{"Option", "Parameter"}, src], {iNBPLHit["ACC-UNTRUSTED", "AccessLevel", d, def]},
          True, {}]]] @@@ accSites, 1]];
  inv = Join[
    Function[{v, d}, <|"Kind" -> "Access", "Head" -> "AccessLevel", "Pos" -> iNBPLPos[d], "Definition" -> def,
      "Detail" -> With[{src = iNBPLAccSource[v, params]},
        If[src === "Literal", "Literal " <> ToString[iNBPLNumVal[v]], src]]|>] @@@ accSites,
    <|"Kind" -> "Access", "Head" -> "NBMakeRuntimeAccessSpec", "Pos" -> iNBPLPos[#D], "Definition" -> def,
      "Detail" -> "NBAccessAPI"|> & /@ get[{"NBMakeRuntimeAccessSpec"}, {"", "NBAccess"}],
    <|"Kind" -> "Declassify", "Head" -> #Short, "Pos" -> iNBPLPos[#D], "Definition" -> def,
      "Detail" -> If[Length[#Args] >= 2, Replace[#Args[[2]],
        {CodeParser`LeafNode[Symbol, v_String, _] :> v, n_ :> Replace[iNBPLNumVal[n], $Failed -> ""]}], ""]|> & /@
      get[$iNBPLDeclassifyHeads, {"", "NBAccess"}],
    <|"Kind" -> "Egress", "Head" -> #Short, "Pos" -> iNBPLPos[#D], "Definition" -> def,
      "Detail" -> If[hasHost, "LLMHost", ""]|> & /@ get[$iNBPLNetHeads, $iNBPLSysCtx]];
  <|"Findings" -> findings, "Inventory" -> inv,
    "Usage" -> iNBPLUsageNames[t],
    "CellObjDefs" -> iNBPLCellObjDefs[t, def]|>];

iNBPLAnalyzeChunk[ast_CodeParser`ContainerNode] := Module[{parts},
  parts = iNBPLAnalyzeTop /@ Flatten[iNBPLTops /@ ast[[2]], 1];
  <|"Findings" -> Flatten[Lookup[parts, "Findings", {}], 1],
    "Inventory" -> Flatten[Lookup[parts, "Inventory", {}], 1],
    "Usage" -> Flatten[Lookup[parts, "Usage", {}]],
    "CellObjDefs" -> Flatten[Lookup[parts, "CellObjDefs", {}], 1]|>];

(* どの規則にも当たりえない単位は構文解析を省く (CodeParse が全体の時間の大半を占めるため)。
   規則の手がかりになる語を 1 つも含まない単位は、どう解析しても検出も棚卸しも出ない。
   ただし文字列・コメント・括弧が閉じていない単位は省かずに解析し、隣の単位と結合させる *)
(* 手がかりは各規則が成り立つための必要条件にする (例: PRIV-LEVEL-LITERAL は PrivacyLevel -> 数値 の形が
   本文に無ければ成り立たない)。語が出てくるだけで解析すると、解析する単位が 1.7 倍に増えた *)
$iNBPLTriggerWords = DeleteDuplicates @ Join[$iNBPLCellHeads, $iNBPLNbReadHeads,
  $iNBPLLLMChannelHeads, $iNBPLNetHeads, $iNBPLDeclassifyHeads, $iNBPLModelVars,
  {"NBAccess`Private`", "$NB", "SystemCredential", "_CellObject", "NBMakeRuntimeAccessSpec"}];
$iNBPLTriggerREs = {
  RegularExpression["PrivacyLevel\"?\\s*[-:]>\\s*[0-9.]"],        (* PRIV-LEVEL-LITERAL *)
  RegularExpression["\"AccessLevel\"\\s*(?:[-:]>|\\]\\s*:?=)"],   (* ACC- と AccessSites *)
  $iNBPLSecretRE, $iNBPLLLMHostRE};
iNBPLTriggerQ[text_String] := StringContainsQ[text, $iNBPLTriggerWords] ||
  (StringContainsQ[text, $iNBPLAttrHeads] && StringContainsQ[text, $iNBPLAttrSyms]) ||
  (StringContainsQ[text, {"Import", "Get", "<<", "Export"}] &&
    StringContainsQ[text, {".nb", "\"Notebook\"", "\"NB\""}, IgnoreCase -> True]) ||
  AnyTrue[$iNBPLTriggerREs, StringContainsQ[text, #] &];

(* 字句的に閉じているか (近似)。文字列を消し、入れ子のコメントを内側から消して、
   残りに引用符・コメント記号が無く括弧の数が揃っていれば閉じているとみなす。
   判定を誤って「閉じていない」とした場合は解析に回るだけなので安全側 *)
iNBPLBalancedQ[text_String] := Module[{t, prev = None},
  t = StringReplace[text, RegularExpression["\"(?:[^\"\\\\]|\\\\.)*\""] -> "\"\""];
  t = StringDelete[t, "\"\""];
  While[t =!= prev,
    prev = t;
    t = StringReplace[t, RegularExpression["(?s)\\(\\*(?:(?!\\(\\*|\\*\\)).)*\\*\\)"] -> " "]];
  !StringContainsQ[t, "\"" | "(*" | "*)"] &&
    StringCount[t, "["] === StringCount[t, "]"] &&
    StringCount[t, "{"] === StringCount[t, "}"] &&
    StringCount[t, "("] === StringCount[t, ")"]];

iNBPLUsageByRegex[text_String] := iNBPLShort /@ StringCases[text,
  RegularExpression["(?m)^(" <> $iNBPLIdentRE <> ")::usage\\s*="] :> "$1"];

(* ── キャッシュ ──
   単位の結果を「規則の版 + 単位の本文」のハッシュをキーに保持する。中身は規則 ID・位置・定義名などで、
   コード片や鍵の文字列は入らない (Code 欄は検査のたびに本文から作る)。
   "Cache" -> True はカーネル内 + ディスク (マシンごとの $UserBaseDirectory 配下)、"Memory" はカーネル内だけ。
   ディスクはカーネルを起動し直したときの初回 (全パッケージで数分) を省くため *)
If[!StringQ[$iNBPLDiskCachePath],
  $iNBPLDiskCachePath = FileNameJoin[{$UserBaseDirectory, "ApplicationData", "NBAccess", "policylint_cache.wxf"}]];
If[!BooleanQ[$iNBPLDiskLoaded], $iNBPLDiskLoaded = False];
$iNBPLDiskDirty = False;
$iNBPLDiskMaxEntries = 40000;
$iNBPLCacheHits = 0;

iNBPLCacheKey[text_String] :=
  Hash[StringToByteArray[$iNBPLVersion <> "\n" <> text, "UTF-8"], "SHA256", "HexString"];

iNBPLDiskLoad[] := Module[{d},
  $iNBPLDiskLoaded = True;
  If[!StringQ[$iNBPLDiskCachePath] || !FileExistsQ[$iNBPLDiskCachePath], Return[Null, Module]];
  d = Quiet @ Check[BinaryDeserialize[ReadByteArray[$iNBPLDiskCachePath]], $Failed];
  (* 版が違う (規則を変えた) キャッシュは使わない *)
  If[AssociationQ[d] && Lookup[d, "Version", None] === $iNBPLVersion && AssociationQ[Lookup[d, "Entries", None]],
    $iNBPLCache = Join[d["Entries"], $iNBPLCache]]];

iNBPLDiskSave[] := Module[{dir, tmp, entries = $iNBPLCache, ok},
  If[!TrueQ[$iNBPLDiskDirty] || !StringQ[$iNBPLDiskCachePath], Return[Null, Module]];
  If[Length[entries] > $iNBPLDiskMaxEntries, entries = Take[entries, -$iNBPLDiskMaxEntries]];
  dir = DirectoryName[$iNBPLDiskCachePath];
  If[!DirectoryQ[dir], Quiet @ CreateDirectory[dir, CreateIntermediateDirectories -> True]];
  tmp = $iNBPLDiskCachePath <> ".tmp";
  ok = Quiet @ Check[
    With[{st = OpenWrite[tmp, BinaryFormat -> True]},
      BinaryWrite[st, BinarySerialize[<|"Version" -> $iNBPLVersion, "Entries" -> entries|>]]; Close[st]; True],
    False];
  If[ok,
    If[Quiet @ Check[RenameFile[tmp, $iNBPLDiskCachePath, OverwriteTarget -> True], $Failed] === $Failed,
      Quiet @ DeleteFile[$iNBPLDiskCachePath]; Quiet @ RenameFile[tmp, $iNBPLDiskCachePath]];
    $iNBPLDiskDirty = False,
    Quiet @ DeleteFile[tmp]]];

(* 単位 1 つ分の結果 (単位内の相対位置)。構文が閉じなければ $Failed *)
iNBPLChunkResult[text_String, useCache_] := Module[{key, ast, r},
  key = iNBPLCacheKey[text];
  If[useCache =!= False && KeyExistsQ[$iNBPLCache, key],
    $iNBPLCacheHits++; Return[$iNBPLCache[key], Module]];
  r = If[!iNBPLTriggerQ[text] && iNBPLBalancedQ[text],
    <|"Findings" -> {}, "Inventory" -> {}, "Usage" -> iNBPLUsageByRegex[text], "CellObjDefs" -> {},
      "Skipped" -> True|>,
    ast = iNBPLParse[text];
    If[ast === $Failed, $Failed, iNBPLAnalyzeChunk[ast]]];
  If[useCache =!= False, $iNBPLCache[key] = r; $iNBPLDiskDirty = True];
  r];

iNBPLBoundaryQ[l_String] := StringStartsQ[l, $iNBPLStartRE] || StringStartsQ[l, "(*"];

(* CodeParse は 1 回ごとの固定コストが大きいので、トップレベル形式をいくつかまとめて 1 単位にする。
   区切りは形式の先頭行のハッシュで決めるので、一部を編集しても他の単位の内容は変わらずキャッシュが効く *)
$iNBPLCutModulus = 16;
$iNBPLUnitMaxLines = 400;

(* {{開始行, 終了行, 結果 | $Failed}..}。
   単位の構文が閉じなければ、その単位の中は形式ごとに解析し直し、閉じない形式は次の形式と
   結合する (複数行文字列やコメントの中の偽の境界を吸収し、失敗範囲を最小にする) *)
iNBPLChunks[lines_List, maxMerge_Integer, useCache_] :=
  Module[{n = Length[lines], starts, forms, cut, m, pos = 1, e, stop, j, a, b, r},
    starts = Union[{1}, Select[Range[n], iNBPLBoundaryQ[lines[[#]]] &]];
    m = Length[starts];
    forms = Table[{starts[[i]], If[i < m, starts[[i + 1]] - 1, n]}, {i, m}];
    cut = (Mod[Hash[lines[[#]], "CRC32"], $iNBPLCutModulus] === 0) & /@ starts;
    First[Last[Reap[
      While[pos <= m,
        e = pos;
        While[e < m && !cut[[e]] && forms[[e, 2]] - forms[[pos, 1]] + 1 < $iNBPLUnitMaxLines, e++];
        a = forms[[pos, 1]]; b = forms[[e, 2]];
        r = iNBPLChunkResult[StringRiffle[lines[[a ;; b]], "\n"], useCache];
        If[r =!= $Failed,
          Sow[{a, b, r}]; pos = e + 1,
          stop = e;
          While[pos <= stop,
            a = forms[[pos, 1]]; j = pos;
            While[True,
              b = forms[[j, 2]];
              r = iNBPLChunkResult[StringRiffle[lines[[a ;; b]], "\n"], useCache];
              If[r =!= $Failed || j >= m || b - a > maxMerge, Break[]];
              j++];
            Sow[{a, b, r}];
            pos = j + 1]]]],
      {{}}]]];

iNBPLShift[f_Association, off_Integer] := Append[f, "Pos" -> (f["Pos"] /. {l_Integer, c_Integer} :> {l + off, c})];

iNBPLGatewayQ[ruleID_String, fileName_String] := Module[{rule = $iNBPLRules[ruleID], base = FileBaseName[fileName], ig},
  AnyTrue[Lookup[rule, "Gateways", {}], StringMatchQ[base, #] &] ||
    (TrueQ[Lookup[rule, "SeparationIgnore", False]] && ListQ[ig = NBAccess`$NBSeparationIgnoreList] &&
      AnyTrue[ig, StringQ[#] && (base === # || StringStartsQ[base, # <> "_"]) &])];

(* waiver。ファイル単位 (先頭 40 行の :PolicyLintIgnore:) と行単位 (該当行か直前行の :PolicyWaiver:) *)
iNBPLParseWaivers[line_String, re_] := StringCases[line, re :> {StringTrim /@ StringSplit["$1", ","], StringTrim["$2"]}];
iNBPLFileIgnores[lines_List] := Flatten[Table[
  ({#[[1]], #[[2]], i} & /@ iNBPLParseWaivers[lines[[i]], $iNBPLIgnoreRE]), {i, Min[40, Length[lines]]}], 1];
iNBPLIDMatchQ[ids_List, rule_String] := MemberQ[ids, rule] || MemberQ[ids, "*"];

iNBPLWaiverFor[rule_String, l_Integer, lines_List, fileIgnores_List] := Module[{fi, cands},
  fi = SelectFirst[fileIgnores, iNBPLIDMatchQ[#[[1]], rule] && #[[2]] =!= "" &, None];
  If[fi =!= None, Return[<|"Kind" -> "File", "Reason" -> fi[[2]], "Line" -> fi[[3]]|>, Module]];
  cands = Join[
    If[l >= 2 && l - 1 <= Length[lines], {#, l - 1} & /@ iNBPLParseWaivers[lines[[l - 1]], $iNBPLWaiverRE], {}],
    If[1 <= l <= Length[lines], {#, l} & /@ iNBPLParseWaivers[lines[[l]], $iNBPLWaiverRE], {}]];
  Replace[SelectFirst[cands, iNBPLIDMatchQ[#[[1, 1]], rule] && #[[1, 2]] =!= "" &, None],
    {None -> False, {{_, reason_}, wl_} :> <|"Kind" -> "Line", "Reason" -> reason, "Line" -> wl|>}]];

iNBPLCodeAt[lines_List, l_Integer] := If[1 <= l <= Length[lines], StringTake[StringTrim[lines[[l]]], UpTo[160]], ""];

iNBPLFinalize[f_Association, path_String, lines_List, fileIgnores_List] := Module[{rule = $iNBPLRules[f["RuleID"]], l, code},
  l = f["Pos"][[1, 1]];
  code = iNBPLCodeAt[lines, l];
  If[f["RuleID"] === "CRED-LITERAL", code = StringReplace[code, $iNBPLSecretRE -> "[REDACTED]"]];
  <|"RuleID" -> f["RuleID"], "Severity" -> Lookup[f, "Severity", rule["Severity"]],
    "File" -> path, "FileName" -> FileNameTake[path], "Line" -> l, "Column" -> f["Pos"][[1, 2]],
    "EndLine" -> f["Pos"][[2, 1]], "Definition" -> f["Definition"], "Head" -> f["Head"], "Code" -> code,
    "Message" -> If[Lookup[f, "Note", ""] === "Block",
      rule["Message"] <> " (Block による一時的な上書き)", rule["Message"]],
    "Remedy" -> rule["Remedy"], "Basis" -> rule["Basis"], "AutoFix" -> TrueQ[rule["AutoFix"]],
    "Waived" -> iNBPLWaiverFor[f["RuleID"], l, lines, fileIgnores]|>];

iNBPLFinalizeInv[v_Association, path_String, lines_List] :=
  <|"Kind" -> v["Kind"], "File" -> path, "FileName" -> FileNameTake[path], "Line" -> v["Pos"][[1, 1]],
    "Definition" -> v["Definition"], "Head" -> v["Head"], "Detail" -> v["Detail"],
    "Code" -> StringReplace[iNBPLCodeAt[lines, v["Pos"][[1, 1]]], $iNBPLSecretRE -> "[REDACTED]"]|>;

iNBPLReadText[path_String] := Module[{b},
  If[!FileExistsQ[path], Return[$Failed]];
  b = Quiet @ Check[ReadByteArray[path], $Failed];
  Which[
    ByteArrayQ[b], Quiet @ Check[ByteArrayToString[b, "UTF-8"], $Failed],
    b === EndOfFile, "",
    True, $Failed]];

(* 本文 text を path のファイルとして検査する *)
iNBPLAuditText[text0_String, path_String, ids_List, maxMerge_Integer, useCache_] :=
  Module[{text, lines, chunks, okChunks, usage, raw, cellObj, all, inv, fileIgnores, fileName = FileNameTake[path]},
    text = StringDelete[StringDelete[text0, StartOfString ~~ "\:feff"], "\r"];
    lines = StringSplit[text, "\n", All];
    chunks = iNBPLChunks[lines, maxMerge, useCache];
    okChunks = Cases[chunks, {a_, _, r_Association} :> {a, r}];
    usage = DeleteDuplicates[Flatten[#[[2]]["Usage"] & /@ okChunks]];
    raw = Flatten[Function[{a, r}, iNBPLShift[#, a - 1] & /@ r["Findings"]] @@@ okChunks, 1];
    cellObj = Flatten[Function[{a, r}, iNBPLShift[#, a - 1] & /@
      Select[r["CellObjDefs"], MemberQ[usage, #Definition] &]] @@@ okChunks, 1];
    all = Select[Join[raw, cellObj], MemberQ[ids, #RuleID] && !iNBPLGatewayQ[#RuleID, fileName] &];
    all = DeleteDuplicatesBy[all, {#RuleID, #Pos} &];
    inv = Flatten[Function[{a, r}, iNBPLShift[#, a - 1] & /@ Lookup[r, "Inventory", {}]] @@@ okChunks, 1];
    fileIgnores = iNBPLFileIgnores[lines];
    <|"File" -> path,
      "Findings" -> (iNBPLFinalize[#, path, lines, fileIgnores] & /@ all),
      "Inventory" -> (iNBPLFinalizeInv[#, path, lines] & /@ inv),
      "Failed" -> Cases[chunks, {a_, b_, $Failed} :>
        <|"File" -> path, "Reason" -> "ParseFailed", "Lines" -> {a, b}|>],
      "Units" -> <|"Parsed" -> Count[okChunks, {_, r_} /; !TrueQ[Lookup[r, "Skipped", False]]],
        "Skipped" -> Count[okChunks, {_, r_} /; TrueQ[Lookup[r, "Skipped", False]]]|>|>];

iNBPLAuditFile[path_String, ids_List, maxMerge_Integer, useCache_] := Module[{text = iNBPLReadText[path]},
  If[!StringQ[text],
    <|"File" -> path, "Findings" -> {}, "Inventory" -> {}, "Units" -> <||>,
      "Failed" -> {<|"File" -> path, "Reason" -> If[FileExistsQ[path], "ReadFailed", "NotFound"]|>}|>,
    iNBPLAuditText[text, path, ids, maxMerge, useCache]]];

Options[NBAuditPackageSource] = {"Rules" -> All, "FailOn" -> {"Error"}, "Cache" -> True,
  "TimeBudget" -> Infinity, "MaxMergeLines" -> 4000, "IncludeInventory" -> True};
Options[NBAuditPackageSourceText] = Options[NBAuditPackageSource];

(* 対象 (ファイルまたは本文) ごとに audit を呼び、結果をまとめる *)
iNBPLRun[targets_List, audit_, opts_List] := Module[{t0 = AbsoluteTime[], ids, unknown, budget, maxMerge,
    useCache, failOn, per, findings, failed, open, inv, status},
  ids = Replace[OptionValue[NBAuditPackageSource, opts, "Rules"], All -> Keys[$iNBPLRules]];
  If[!ListQ[ids], ids = {ids}];
  unknown = Complement[ids, Keys[$iNBPLRules]];
  If[unknown =!= {},
    Return[Failure["UnknownRule", <|"MessageTemplate" -> "未知の規則 ID: `1`",
      "MessageParameters" -> {unknown}|>], Module]];
  If[!iNBPLEnsureCodeParser[],
    Return[Failure["NoCodeParser", <|"MessageTemplate" -> "CodeParser` を読み込めません。"|>], Module]];
  budget = OptionValue[NBAuditPackageSource, opts, "TimeBudget"];
  maxMerge = Replace[OptionValue[NBAuditPackageSource, opts, "MaxMergeLines"], Except[_Integer?Positive] -> 4000];
  (* True: カーネル内 + ディスク / "Memory": カーネル内だけ / False: 使わない *)
  useCache = Replace[OptionValue[NBAuditPackageSource, opts, "Cache"], {True -> True, "Memory" -> "Memory", _ -> False}];
  If[useCache === True && !TrueQ[$iNBPLDiskLoaded], iNBPLDiskLoad[]];
  $iNBPLCacheHits = 0;
  failOn = Replace[OptionValue[NBAuditPackageSource, opts, "FailOn"], s_String :> {s}];
  per = Map[
    If[NumericQ[budget] && AbsoluteTime[] - t0 > budget,
      <|"File" -> #[[1]], "Findings" -> {}, "Inventory" -> {}, "Units" -> <||>,
        "Failed" -> {<|"File" -> #[[1]], "Reason" -> "TimeBudget"|>}|>,
      audit[#, ids, maxMerge, useCache]] &,
    targets];
  findings = SortBy[Flatten[Lookup[per, "Findings", {}], 1], {#FileName &, #Line &, #Column &}];
  failed = Flatten[Lookup[per, "Failed", {}], 1];
  open = Select[findings, Lookup[#, "Waived", False] === False &];
  status = Which[
    failed =!= {}, "Failed",
    AnyTrue[open, MemberQ[failOn, #Severity] &], "Violations",
    True, "OK"];
  inv = Flatten[Lookup[per, "Inventory", {}], 1];
  If[useCache === True, iNBPLDiskSave[]];
  <|"Status" -> status, "Files" -> (#[[1]] & /@ targets),
    "Coverage" -> <|"Parsed" -> Count[per, p_ /; p["Failed"] === {}], "Failed" -> failed,
      (* 構文解析した単位 / 規則の手がかりが無く解析を省いた単位 / そのうちキャッシュから取った単位 *)
      "Units" -> Merge[Lookup[per, "Units", <||>], Total], "CacheHits" -> $iNBPLCacheHits|>,
    "Findings" -> findings,
    "Counts" -> KeySort[Counts[Lookup[open, "RuleID", {}]]],
    "Waived" -> Length[findings] - Length[open],
    "Inventory" -> If[TrueQ[OptionValue[NBAuditPackageSource, opts, "IncludeInventory"]],
      <|"AccessSites" -> Select[inv, #Kind === "Access" &],
        "DeclassifySites" -> Select[inv, #Kind === "Declassify" &],
        "EgressSites" -> Select[inv, #Kind === "Egress" &]|>, <||>],
    "RulesVersion" -> $iNBPLVersion,
    "Seconds" -> Round[AbsoluteTime[] - t0, 0.01]|>];

NBAuditPackageSource[file_String, opts:OptionsPattern[]] := NBAuditPackageSource[{file}, opts];
NBAuditPackageSource[files:{___String}, opts:OptionsPattern[]] :=
  iNBPLRun[{#} & /@ DeleteDuplicates[files],
    Function[{tg, ids, mm, uc}, iNBPLAuditFile[tg[[1]], ids, mm, uc]], {opts}];
NBAuditPackageSource[___] :=
  Failure["BadArgs", <|"MessageTemplate" -> "NBAuditPackageSource[file | {files..}, opts] の形で呼んでください。"|>];

NBAuditPackageSourceText[code_String, name_String, opts:OptionsPattern[]] :=
  iNBPLRun[{{name, code}},
    Function[{tg, ids, mm, uc}, iNBPLAuditText[tg[[2]], tg[[1]], ids, mm, uc]], {opts}];
NBAuditPackageSourceText[___] :=
  Failure["BadArgs", <|"MessageTemplate" -> "NBAuditPackageSourceText[code, name, opts] の形で呼んでください。"|>];

NBAuditPackageSourceRules[] :=
  <|"Version" -> $iNBPLVersion,
    "Rules" -> (KeyTake[#, {"Severity", "Basis", "Gateways", "AutoFix", "Message", "Remedy"}] & /@ $iNBPLRules)|>;

End[];

EndPackage[];
