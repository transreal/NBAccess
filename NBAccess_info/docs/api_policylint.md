# NBAccess_policylint — API Reference (LLM-Optimized)

## Overview

`NBAccess_policylint` performs AST-based policy linting of Wolfram Language package sources (`.wl` files). Uses `CodeParser\`CodeParse` to build a syntax tree, so violations inside strings and comments are never falsely reported. Rules cover four families:
- **SEP-** NBAccess separation (no direct FrontEnd/cell manipulation outside gateway packages)
- **CRED-** Credential safety (no SystemCredential bypass, no literal API keys)
- **PRIV-** Privacy routing (notebook read/write, LLM channel, PrivacyLevel literals)
- **ACC-** Access level safety (elevated or untrusted AccessLevel values)

Loaded automatically by `NBAccess.wl`. No LLM, FrontEnd, or network calls; reads files only. Requires `CodeParser\`` (standard Wolfram paclet, loaded on first audit).

## Public Functions

### NBAuditPackageSource[files, opts]
Audits `.wl` package source files using AST-based policy rules.
`files` is a single path string or a list of path strings.
→ `Association`
Options: `"Rules" -> All` (All or `{ruleID..}`), `"FailOn" -> {"Error"}` (severities triggering "Violations" status), `"Cache" -> True` (True = kernel+disk at `$UserBaseDirectory/ApplicationData/NBAccess/policylint_cache.wxf`; "Memory" = kernel only; False = disabled), `"TimeBudget" -> Infinity` (seconds per file; exceeded files counted as Failed), `"MaxMergeLines" -> 4000` (max lines when merging unparseable chunks), `"IncludeInventory" -> True`

Return schema:
```
<|"Status" -> "OK" | "Violations" | "Failed",
  "Files" -> {path..},
  "Coverage" -> <|"Parsed" -> n, "Failed" -> {failRec..},
                  "Units" -> <|"Parsed"->n, "Skipped"->n|>,
                  "CacheHits" -> n|>,
  "Findings" -> {findingRec..},
  "Counts" -> <|ruleID -> n|>,       (* unwaived only *)
  "Waived" -> n,
  "Inventory" -> <|"AccessSites" -> {..}, "DeclassifySites" -> {..}, "EgressSites" -> {..}|>,
  "RulesVersion" -> "2026-10-31.9",
  "Seconds" -> r|>
```

Each finding record:
```
<|"RuleID" -> str, "Severity" -> "Error"|"Review",
  "File" -> fullPath, "FileName" -> baseName,
  "Line" -> n, "Column" -> n, "EndLine" -> n,
  "Definition" -> str,   (* enclosing function name, "" at top level *)
  "Head" -> str,         (* triggering symbol short name *)
  "Code" -> str,         (* up to 160 chars of source line; CRED-LITERAL is redacted *)
  "Message" -> str, "Remedy" -> str, "Basis" -> str,
  "AutoFix" -> True|False,
  "Waived" -> False | <|"Kind"->"File"|"Line", "Reason"->str, "Line"->n|>|>
```

`"Status"` logic: any unparseable range → `"Failed"`; unwaived finding with severity in `"FailOn"` → `"Violations"`; otherwise `"OK"`. Fail-closed: unresolvable parse errors make the result `"Failed"` rather than silently passing.

例: `NBAuditPackageSource["MyPkg.wl", "FailOn" -> {"Error", "Review"}, "Cache" -> "Memory"]`
例: `NBAuditPackageSource[{"Pkg1.wl", "Pkg2.wl"}, "Rules" -> {"SEP-CELL", "CRED-LITERAL"}]`

### NBAuditPackageSourceText[code, name, opts]
Audits an in-memory source string `code` as if it were the file `name`.
`name` is used for gateway filtering (filename-based rule applicability).
Options and return schema identical to `NBAuditPackageSource`.
→ `Association`

例: `NBAuditPackageSourceText[sourceStr, "MyPkg.wl"]`

### NBAuditPackageSourceRules[] → Association
Returns the current rule table and version string.
```
<|"Version" -> "2026-10-31.9",
  "Rules" -> <|ruleID -> <|"Severity", "Basis", "Gateways",
                             "AutoFix", "Message", "Remedy"|>|>|>
```
`"AutoFix" -> True` means the rule's fix is mechanical and safe for automated application. Rules with security judgment (`CRED-LITERAL`, `SEP-CELLOBJ`, `PRIV-EGRESS-LLM`, `PRIV-LEVEL-LITERAL`, `PRIV-MODEL-OVERRIDE`, `ACC-ELEVATED`, `ACC-UNTRUSTED`) have `AutoFix -> False`.

## Rules Reference

### SEP-CELL
Severity: Error. AutoFix: True.
Direct FrontEnd/cell manipulation (`Cells`, `NotebookRead`, `NotebookWrite`, `SelectionMove`, `CellPrint`, `EvaluationCell`, `SelectedCells`, `SetSelectedNotebook`, `SelectionEvaluate`, `SelectionEvaluateCreateCell`, `FrontEndTokenExecute`).
Remedy: Use NBAccess public API (`NBWriteCell`, `NBCellRead`, `NBMoveAfterCell`, `NBCellIndicesByTag`, `NBBeginJobAtEvalCell`, `NBEvaluatePreviousCell`, etc.).
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### SEP-ATTR
Severity: Error. AutoFix: True.
Direct read/write of cell attributes via `CurrentValue`/`AbsoluteCurrentValue`/`SetOptions` with `TaggingRules`, `CellTags`, `CellEpilog`, `CellProlog`, `NotebookEventActions`, `CellDynamicExpression`, or `NotebookDynamicExpression`.
Remedy: Use `NBCellGetTaggingRule` / `NBCellSetOptions` / `NBInstallCellEpilog` / `NBInstallConfidentialEpilog`.
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### SEP-PRIVATE
Severity: Error. AutoFix: True.
Reference to `NBAccess\`Private\`` internal symbols from outside gateway packages.
Remedy: Use NBAccess public API; add a new public API if needed.
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### SEP-GLOBAL
Severity: Error. AutoFix: True.
Direct mutation of NBAccess public globals (`$NB…` symbols) via assignment operators or `Clear`/`ClearAll`. Findings inside `Block[{$X = …}, …]` are downgraded to Review with `"Note" -> "Block"`.
Remedy: Use setter APIs (`NBRegisterConfidentialVar`, `NBSetConfidentialVars`, `NBSetAccessibleDirs`, etc.).
Gateways: `NBAccess*`, `NotebookExtensions*`, `localInit*` (exempt).

### SEP-CELLOBJ
Severity: Review. AutoFix: False.
A public function (has `::usage`) accepts `_CellObject` as a parameter.
Remedy: Replace with cell-index-based NBAccess API; do not expose `CellObject` in public API.
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### CRED-SYSCRED
Severity: Error. AutoFix: True.
Direct call to `SystemCredential`.
Remedy: Use `NBAccess\`NBGetAPIKey` / `NBAccess\`NBGetCredential`.
Gateways: `NBAccess*` (exempt).

### CRED-LITERAL
Severity: Error. AutoFix: False.
API key or token literal in source matching: `sk-…`, `AKIA…` (AWS), `gh[pousr]_…` (GitHub), `xox…` (Slack), `AIza…` (Google), `Bearer …`.
The `"Code"` field is redacted (`[REDACTED]`).
Remedy: Remove key from source; store in credential store; retrieve with `NBGetAPIKey`. Revoke any leaked key.

### PRIV-NB-READ
Severity: Error. AutoFix: True.
Reads `.nb` files without PrivacyLevel check: `NotebookImport`, `NotebookGet`, `NotebookOpen`, `Import[path, "Notebook"]`, `Import["x.nb"]`, `Get["x.nb"]`.
Remedy: Use `NBFileOpen` / `NBFileReadCellsInRange` / `NBFileReadAllCells` / `NBReadHeader` / `NBReadTodos`.
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### PRIV-NB-WRITE
Severity: Error. AutoFix: True.
`Export` of a `Notebook` object or `.nb` path (strips confidential cell attributes).
Remedy: Use `NBFileWriteAllCells` + `NBFileSave`.
Gateways: `NBAccess*`, `NotebookExtensions*` (exempt).

### PRIV-LLM-CHANNEL
Severity: Error. AutoFix: True.
LLM calls via `LLMSynthesize`, `LLMFunction`, `ChatEvaluate`, `LLMResourceFunction`, `LLMExampleFunction` — bypasses privacy router and billing API flag.
Remedy: Use `ClaudeCode\`ClaudeQuerySync[prompt, "PrivacyLevel" -> pl]` or equivalent privacy/billing-aware router.

### PRIV-EGRESS-LLM
Severity: Review. AutoFix: False.
Network or process call (`URLRead`, `URLExecute`, `URLSubmit`, `URLFetch`, `URLFetchAsynchronous`, `URLSave`, `URLSaveAsynchronous`, `URLDownload`, `ServiceExecute`, `RunProcess`, `StartProcess`) in a definition that also contains an LLM API hostname literal (`api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, `api.z.ai`, `open.bigmodel.cn`, `api.deepseek.com`, `openrouter.ai`, `api.groq.com`, `api.x.ai`, `api.mistral.ai`, `api.cohere.ai/com`).
Remedy: Route through `ClaudeQuerySync` etc. If no content is sent (e.g., model listing), add `:PolicyWaiver:` with reason.
Gateways: `claudecode*`, `NBAccess*` (exempt).

### PRIV-LEVEL-LITERAL
Severity: Review. AutoFix: False.
`PrivacyLevel -> v` where `v` is a numeric literal < 0.5.
Remedy: Derive from notebook declaration (Public/Private/Unspecified) or NBAccess judgment functions. Add `:PolicyWaiver:` if justified for a public artifact.
Gateways: `NBAccess*` (exempt).

### PRIV-MODEL-OVERRIDE
Severity: Review. AutoFix: False.
Mutation of `$ClaudeModel`, `$ClaudePrivateModel`, `$ClaudeTestModel`, or `$ClaudeFallbackModels`. Findings inside `Block` are noted as temporary overrides.
Remedy: Use `Model` / `PrivacyLevel` options on `ClaudeQuerySync`. Add `:PolicyWaiver:` if explicit override is needed.
Gateways: `claudecode*`, `NBAccess*`, `localInit*` (exempt).

### ACC-ELEVATED
Severity: Review. AutoFix: False.
`"AccessLevel" -> v` or `spec["AccessLevel"] = v` where `v` is a numeric literal ≥ 0.7 (write-tier / confidential-data permission).
Remedy: Verify necessity; add `:PolicyWaiver:` with reason.
Gateways: `NBAccess*` (exempt).

### ACC-UNTRUSTED
Severity: Review. AutoFix: False.
`AccessLevel` value derived from a caller's argument or option (caller can escalate their own privilege).
Remedy: Apply an upper-bound via `NBGetProviderMaxAccessLevel`, `NBLocalLLMEffectiveMaxAccessLevel`, or `NBMakeRuntimeAccessSpec`.
Gateways: `NBAccess*` (exempt).

## Waiver Syntax

**Line waiver** — place on the violation line or immediately before it:
```mathematica
(* :PolicyWaiver: RULE-ID reason text here *)
```

**File waiver** — anywhere in the first 40 lines of the file, applies to all violations of that rule:
```mathematica
(* :PolicyLintIgnore: RULE-ID reason text here *)
```

Multiple rule IDs: comma-separated. Wildcard `*` suppresses all rules. Reason text is mandatory; waiver without reason is not recognized.

例: `(* :PolicyWaiver: PRIV-LEVEL-LITERAL public summary endpoint, PrivacyLevel 0.0 is correct here *)`
例 (file-level): `(* :PolicyLintIgnore: PRIV-EGRESS-LLM,SEP-GLOBAL bootstrap only, reviewed 2026-10-31 *)`

A waived finding still appears in `"Findings"` with `"Waived" -> <|"Kind" -> "File"|"Line", "Reason" -> str, "Line" -> n|>`. `"Counts"` and `"Status"` exclude waived findings.

## Inventory

When `"IncludeInventory" -> True` (default), the result's `"Inventory"` key contains three lists tracking sites regardless of rule violations:

`"AccessSites"` — every `"AccessLevel" -> v` or `spec["AccessLevel"] = v` assignment, with `"Detail"` being `"Literal <n>"`, `"NBAccessAPI"`, `"Option"`, `"Parameter"`, or `"Other"`. Also includes `NBMakeRuntimeAccessSpec` calls.

`"DeclassifySites"` — calls to `NBSetCloudPublishable`, `NBUnmarkCell`, `NBClearWriteConfidential`, `NBSetSnapshotPrivacyLevel`.

`"EgressSites"` — all network calls (`URLRead`, `URLExecute`, etc.), with `"Detail" -> "LLMHost"` when the enclosing definition contains an LLM API hostname literal.

Each inventory record: `<|"Kind", "File", "FileName", "Line", "Definition", "Head", "Detail", "Code"|>`.

## Cache

Results are cached keyed by `SHA256($iNBPLVersion + "\n" + chunkText)`. Cache stores rule IDs, positions, and definition names — never actual code or key values.

`"Cache" -> True`: kernel-memory dict + disk at `$UserBaseDirectory/ApplicationData/NBAccess/policylint_cache.wxf` (WXF, up to 40,000 entries; older entries evicted). Disk cache is loaded once per kernel session on first `True`-mode audit; saved after each run. Persists across kernel restarts, eliminating the multi-minute initial scan cost.

`"Cache" -> "Memory"`: kernel dict only, not written to disk.

`"Cache" -> False`: no caching.

Cache is invalidated automatically when `$iNBPLVersion` changes (i.e., when rule matching logic is updated).

## Parse Strategy

Source is split into top-level units at lines starting with an identifier followed by `[`, `::`, `:=`, `=`, `(`, `/:`, `^=`, or at `(*` comment starts. Units are grouped into chunks (cut deterministically by `CRC32 mod 16` of the first line) and passed to `CodeParser\`CodeParse` one chunk at a time.

Units whose text contains none of the rule trigger words or patterns are skipped without parsing (only `iNBPLUsageByRegex` regex is applied to collect `::usage` names). This skip-optimization typically reduces `CodeParse` calls significantly.

If a chunk fails to parse (unbalanced brackets from mid-expression boundaries), the chunk is split back to individual top-level forms and each is parsed independently; unparseable forms are merged with their successor up to `"MaxMergeLines"`. Any range that remains unparseable is reported as a `"ParseFailed"` entry in `"Coverage"."Failed"` and sets `"Status" -> "Failed"` (fail-closed).

## Related Packages

- [NBAccess](https://github.com/transreal/NBAccess) — the package whose separation rules this linter enforces
- [NBAccess_policylint](https://github.com/transreal/NBAccess_policylint) — this package