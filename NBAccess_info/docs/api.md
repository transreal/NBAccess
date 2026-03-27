# NBAccess API Reference

Package: `NBAccess` — Notebook cell-index-based read/write with privacy filtering.
Load: `Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]`
GitHub: https://github.com/transreal/NBAccess

All functions are in the `NBAccess`` context. After `BeginPackage`/`Get`, call without prefix.

## Global Variables

### $NBPrivacySpec
Type: Association, Default: `<|"AccessLevel" -> 0.5|>`
Default PrivacySpec for all NBAccess functions. Set to `<|"AccessLevel" -> 1.0|>` in local LLM environments to allow confidential data access.

### $NBConfidentialSymbols
Type: Association, Default: `<||>`
Table of confidential variable names → privacy level. Format: `<|"varName" -> privacyLevel, ...|>`. Auto-updated by ClaudeCode package.

### $NBSendDataSchema
Type: Boolean, Default: `True`
Controls whether schema info (type, size, keys) of confidential-dependent Output cells is sent to cloud LLM. `False` sends no schema for confidential-dependent outputs. Non-confidential outputs always include smart summary.

### $NBLLMQueryFunc
Type: Function | Symbol | None, Default: `None`
Async LLM call callback. ClaudeCode package registers `ClaudeQueryAsync` at load time. Signature: `$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]`. Non-blocking.

### $NBSeparationIgnoreList
Type: List, Default: `{"NBAccess", "NotebookExtensions"}`
Package names excluded from separation check (`ClaudeCheckSeparation`). Append to add packages.

## Options

### PrivacySpec
Option for NBAccess history/filter functions. Value: `<|"AccessLevel" -> level|>` where level ∈ [0.0, 1.0]. Cells with privacyLevel > AccessLevel are inaccessible. Default AccessLevel: 0.5 (cloud-LLM-safe data only).

## Cell Utility API

### NBCellCount[nb] → Integer
Returns total number of cells in notebook.

### NBCurrentCellIndex[nb] → Integer
Returns cell index of `EvaluationCell[]`. Returns 0 if not found.

### NBSelectedCellIndices[nb] → List
Returns list of indices of currently selected cells. Falls back to cursor-position cell if no bracket selection.

### NBCellIndicesByTag[nb, tag] → List
Returns list of indices of cells with the specified `CellTags` value.

### NBCellIndicesByStyle[nb, style] → List
Returns indices of cells with given `CellStyle`. `style` may be a String or `{style1, style2, ...}` for multiple styles.

### NBDeleteCellsByTag[nb, tag]
Deletes all cells with the specified `CellTags`.

### NBMoveAfterCell[nb, cellIdx]
Moves cursor to after the specified cell.

### NBCellRead[nb, cellIdx] → Cell
Returns cell expression via `NotebookRead`.

### NBCellReadInputText[nb, cellIdx] → String
Retrieves cell content as InputText string via FrontEnd. Falls back to `NBCellExprToText` on failure.

### NBCellStyle[nb, cellIdx] → String
Returns the `CellStyle` of the cell.

### NBCellLabel[nb, cellIdx] → String
Returns `CellLabel` (e.g., `"In[3]:="`). Returns `""` if no label.

### NBCellSetOptions[nb, cellIdx, opts]
Applies `SetOptions` to the specified cell.

### NBCellGetTaggingRule[nb, cellIdx, path] → value
Returns nested value from cell's `TaggingRules` at the given path.
例: `NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]`

### NBCellSetTaggingRule[nb, cellIdx, path, value]
Sets nested value in cell's `TaggingRules` at the given path.
例: `NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "original idea"]`

### NBCellRasterize[nb, cellIdx, file, opts]
Rasterizes the cell and saves to `file`.

### NBCellHasImage[cellExpr] → True | False
Returns True if the Cell expression (from `NBCellRead`) contains images (RasterBox/GraphicsBox).

### NBCellWriteText[nb, cellIdx, newText]
Replaces cell text content with `newText`. Preserves CellStyle, TaggingRules, and other options.

### NBInvalidateCellsCache[]
Clears the internal Cells[] cache for all notebooks.

### NBInvalidateCellsCache[nb]
Clears the internal Cells[] cache for the specified notebook.

## Text Extraction API

### NBCellExprToText[cellExpr] → String
Extracts text from a Cell expression returned by `NotebookRead`.

### NBCellToText[nb, cellIdx] → String
Returns text content of the specified cell.

### NBCellGetText[nb, cellIdx] → String
Robustly retrieves text from a cell. Fallback chain: FrontEnd InputText → `NBCellToText` → `NBCellExprToText`. Returns `""` if text cannot be retrieved.

## Privacy API

### NBCellPrivacyLevel[nb, cellIdx] → Real
Returns privacy level of cell in range [0.0, 1.0]. 0.0 = non-confidential, 1.0 = confidential (Confidential mark or confidential variable reference).

### NBIsAccessible[nb, cellIdx, opts] → True | False
Returns whether cell is accessible under the given PrivacySpec.
Options: `PrivacySpec -> $NBPrivacySpec`

### NBFilterCellIndices[nb, indices, opts] → List
Filters a list of cell indices to only those accessible under PrivacySpec.
Options: `PrivacySpec -> $NBPrivacySpec`

## Cell List / Context API

### NBGetCells[nb, opts] → List
Returns all cell indices in notebook filtered by PrivacySpec.
Options: `PrivacySpec -> $NBPrivacySpec`

### NBGetContext[nb, afterIdx, opts] → String
Builds LLM prompt context string from cells after index `afterIdx`, filtered by PrivacySpec.
Options: `PrivacySpec -> $NBPrivacySpec` (default AccessLevel 0.5)

## LLM Integration API

### NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn, opts]
Asynchronously transforms a cell using LLM. Non-blocking. Automatically selects appropriate LLM based on cell privacy level.
`promptFn`: `String -> String` — receives cell text, returns prompt string.
`completionFn`: `Association -> Null` — receives `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>` or `$Failed` on error.
→ Null
Options: `Fallback -> False`, `InputText -> Automatic` (override cell text)
例: `NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]`

## Write API

### NBWriteText[nb, text, style]
Writes a text cell to the notebook. `style` defaults to `"Text"`.

### NBWriteCode[nb, code]
Writes an Input cell with syntax coloring.

### NBWriteSmartCode[nb, code]
Writes a cell to the notebook, auto-detecting `CellPrint[]` patterns for smart cell insertion.

### NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate]
Inserts an Input cell after the current cursor position and moves cursor to cell start. If `autoEvaluate` is True, additionally calls `SelectionEvaluate`.

### NBInsertTextCells[nbFile, name, prompt]
Opens `.nb` file invisibly, appends a Subsection cell (`name`) and a Text cell (`prompt`) at the end, saves, and closes.

### NBWriteCell[nb, cellExpr]
Writes a Cell expression to the notebook at the After position.

### NBWriteCell[nb, cellExpr, pos]
Writes a Cell expression at `pos` (After/Before/All).

### NBWritePrintNotice[nb, text, color]
Writes a notification Print cell to the notebook. If `nb` is None, uses `CellPrint` (synchronous In/Out placement).

### NBWriteDynamicCell[nb, dynBoxExpr, tag]
Writes a Dynamic cell to the notebook. Sets `CellTags` if `tag` is not `""`.

### NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate]
Writes an ExternalLanguage cell. If `autoEvaluate` is True, evaluates the preceding cell immediately.

### NBInsertAndEvaluateInput[nb, boxes]
Inserts an Input cell and evaluates it immediately.

### NBInsertInputAfter[nb, boxes]
Inserts an Input cell at After position, then moves cursor to Before CellContents.

### NBWriteAnchorAfterEvalCell[nb, tag]
Writes an invisible anchor cell immediately after EvaluationCell. Falls back to notebook end if EvaluationCell cannot be retrieved.

## Cell Mark API

### NBGetConfidentialTag[nb, cellIdx] → True | False | Missing[]
Returns the confidential tag from cell's `TaggingRules`.

### NBSetConfidentialTag[nb, cellIdx, val]
Sets the confidential tag in cell's `TaggingRules` to `val` (True/False).

### NBMarkCellConfidential[nb, cellIdx]
Marks cell as confidential (red background + WarningSign icon).

### NBMarkCellDependent[nb, cellIdx]
Marks cell as dependent-confidential (orange background + LockIcon). Use for cells that are indirectly confidential (e.g., computed from confidential variables).

### NBUnmarkCell[nb, cellIdx]
Removes all confidential marks (visual and tag) from the cell.

## Cell Content Analysis API

### NBCellUsesConfidentialSymbol[nb, cellIdx] → True | False
Returns whether the cell references any variable in `$NBConfidentialSymbols`.

### NBCellExtractVarNames[nb, cellIdx] → List
Extracts LHS variable names from Set/SetDelayed expressions in the cell.

### NBCellExtractAssignedNames[nb, cellIdx] → List
Extracts assignment target variable names inside `Confidential[...]` in the cell.

### NBShouldExcludeFromPrompt[nb, cellIdx] → True | False
Returns whether the cell should be excluded from LLM prompt context.

### NBIsClaudeFunctionCell[nb, cellIdx] → True | False
Returns whether the cell is a Claude function call cell (ClaudeQuery, etc.).

## Internal Cell Helper (Public)

### NBAccess`iCellToInputText[cell] → String
Retrieves InputText format of a CellObject via FrontEnd. Falls back to `NBCellExprToText` on failure.

## Dependency Graph API

### NBBuildVarDependencies[nb] → Association
Analyzes Input cells in notebook and returns variable dependency graph `<|"var" -> {"dep1", ...}, ...|>`. Identifiers inside string literals are excluded. Use for per-cell evaluation; use `NBBuildGlobalVarDependencies[]` for precision LLM pre-checks.

### NBBuildGlobalVarDependencies[] → Association
Scans all Input cells across all open notebooks (`Notebooks[]`) and returns unified dependency graph `<|"var" -> {"dep1", ...}, ...|>`. Use immediately before LLM calls for precise dependency checks. For normal cell execution, use the lighter `NBBuildVarDependencies[nb]`.

### NBUpdateGlobalVarDependencies[existingDeps, afterLine] → {updatedDeps, newLastLine}
Incremental update: scans only cells with `CellLabel In[x]` where x > `afterLine` and merges into `existingDeps`. Avoids full graph rebuild cost.

### NBTransitiveDependents[deps, confVars] → List
Returns all variable names that directly or transitively depend on `confVars` in the dependency graph `deps`.

### NBScanDependentCells[nb, confVarNames] → Integer
Applies `NBMarkCellDependent` to cells that depend on confidential variables. Returns count of newly marked cells. Claude function call cells are excluded.

### NBScanDependentCells[nb, confVarNames, deps]
Same as above but uses pre-computed dependency graph `deps` (avoids redundant computation).

### NBFilterHistoryEntry[entry, confVars] → entry
Blocks `response`/`instruction` fields in a history entry if they contain current confidential variable names or values. `confVars` is the current confidential variable name list.

### NBDependencyEdges[nb] → List
Returns variable dependency relations as edge list `{DirectedEdge["dep", "var"], ...}`. `"dep" → "var"` means "var depends on dep".

### NBDependencyEdges[nb, confVars] → List
Returns only edges related to confidential variables `confVars`.

### NBDebugDependencies[nb, confVars]
Debug function. Prints dependency graph, transitive dependencies, and cell text analysis for each Input cell via `Print`.

### NBPlotDependencyGraph[] → Graphics
Plots unified dependency graph of all open notebooks (default). Nodes are variable names or Out[n]. Direct confidential nodes: red, dependent-confidential: orange. Intra-notebook edges: solid, cross-notebook: dashed.
Options: `"Scope" -> "Global"` (default) | `"Local"`, `PrivacySpec -> <|"AccessLevel" -> 1.0|>`

### NBPlotDependencyGraph[nb] → Graphics
Plots dependency graph for specified notebook.
例: `NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]`

### NBGetFunctionGlobalDeps[nb] → Association
Analyzes all function definitions in notebook and returns `<|"funcName" -> {"globalVar1", ...}, ...|>`. Pattern variables and scoping locals (Module/Block/With/Function) are excluded.

## Notebook TaggingRules API

### NBGetTaggingRule[nb, key] → value | Missing[]
Returns value at `key` in notebook's `TaggingRules`. Returns `Missing[]` if key absent.

### NBGetTaggingRule[nb, {key1, key2, ...}] → value | Missing[]
Returns nested value at the specified key path.

### NBSetTaggingRule[nb, key, value]
Sets `key -> value` in notebook's `TaggingRules`.

### NBSetTaggingRule[nb, {key1, key2}, value]
Sets nested key path in notebook's `TaggingRules`.

### NBDeleteTaggingRule[nb, key]
Removes `key` from notebook's `TaggingRules`.

### NBListTaggingRuleKeys[nb] → List
Returns all top-level keys in notebook's `TaggingRules`.

### NBListTaggingRuleKeys[nb, prefix] → List
Returns only keys starting with `prefix`.

## File-type Notebook API

Rules: Never open `.nb` files with `NotebookOpen`/`NotebookGet` directly from calling code. Always use `NBFileOpen`. Always close with `NBFileClose`.

### NBFileOpen[path] → NotebookObject | $Failed
Opens a `.nb` file invisibly (`Visible -> False`). Must be closed with `NBFileClose`.
例: `nb2 = NBFileOpen["C:\\path\\to\\file.nb"]`

### NBFileClose[nb]
Closes a notebook opened with `NBFileOpen`.

### NBFileSave[nb, path]
Saves the open notebook to `path`. If `path` is None, saves in-place (overwrites).
例: `NBFileSave[nb2, "C:\\path\\to\\translated.nb"]`

### NBFileReadCells[nb, opts] → List
Reads all cells from open notebook, filtered by PrivacySpec. Returns `{<|"cellIdx" -> i, "style" -> s, "text" -> t, "privacyLevel" -> pl|>, ...}`. Cells with privacyLevel exceeding PrivacySpec have text replaced with `"[CONFIDENTIAL]"`.
Options: `PrivacySpec -> $NBPrivacySpec`
例: `cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel" -> 0.5|>]`

### NBFileReadAllCells[nb] → List
Reads all cells including confidential, classified by access level. Use for local model processing. Returns all cells with `PrivacyLevel` field for identification.

### NBFileWriteCell[nb, cellIdx, newText]
Replaces text of specified cell in open notebook. Preserves CellStyle, TaggingRules, and confidential marks.
例: `NBFileWriteCell[nb2, 3, "This is a pen."]`

### NBFileWriteAllCells[nb, replacements]
Batch-replaces multiple cells from an Association or List of `cellIdx -> newText` rules.
例: `NBFileWriteAllCells[nb2, <|2 -> "text", 3 -> "[CONFIDENTIAL]"|>]`

## ObjectSpec API

### NBFileSpec[path] → Association
Returns file metadata and PrivacyLevel as Association. PrivacyLevel: 0.5 = cloud-LLM-accessible, 1.0 = local-only, `{0.5, 1.0}` = mixed (`.nb` file with both).

### NBValueSpec[expr, privacyLevel] → Association
Returns type information and PrivacyLevel of a value.

### NBPrivacyLevelToRoutes[privacyLevel] → List
Returns required model route list from privacy level. `0.5 -> {"cloud"}`, `1.0 -> {"local"}`, `{0.5, 1.0} -> {"cloud", "local"}`.

### NBFileReadCellsInRange[nb, lo, hi] → List
Returns only cells whose PrivacyLevel falls in [lo, hi].
例: `NBFileReadCellsInRange[nb2, 0.5, 0.5]` (public cells only)
`NBFileReadCellsInRange[nb2, 0.9, 1.0]` (confidential cells only)

### NBSplitNotebookCells[path, threshold] → {publicCells, privateCells}
Splits cells of a `.nb` file into public (PrivacyLevel ≤ threshold) and private (> threshold).
例: `{pub, priv} = NBAccess`NBSplitNotebookCells["file.nb", 0.5]`

### NBMergeNotebookCells[sourcePath, outputPath, results1, results2]
Merges two `<|cellIdx -> newText|>` associations in cell-index order and saves to `outputPath`.
例: `NBAccess`NBMergeNotebookCells[src, dst, pubResults, privResults]`

## History Database API

History is stored in notebook `TaggingRules`. Entries use diff compression on fields like `fullPrompt`/`response`/`code`.

### NBHistoryCreate[nb, tag, diffFields]
Creates a new history database. `diffFields` is the list of field names to diff-compress (e.g., `{"fullPrompt", "response", "code"}`). Returns existing header if DB already exists (idempotent).

### NBHistoryCreate[nb, tag, diffFields, headerOverrides]
Same, with header override Association.

### NBHistoryData[nb, tag] → Association
Reads history and decompresses diff-compressed entries. Returns `<|"header" -> <|...|>, "entries" -> {<|...|>, ...}|>`.
Options: `Decompress -> True` (default). `Decompress -> False` returns raw Diff objects.

### NBHistoryRawData[nb, tag] → Association
Returns history without decompressing (internal use).

### NBHistorySetData[nb, tag, data]
Writes history data to `TaggingRules`. `data` format: `<|"header" -> ..., "entries" -> {...}|>`. Pass entries as plain text; auto-compressed on write.

### NBHistoryAppend[nb, tag, entry]
Appends an entry to history. Diff-compresses `fullPrompt`/`response`/`code` fields against the previous entry. Records `privacyLevel` in entry if `PrivacySpec` option is provided.
Options: `PrivacySpec -> $NBPrivacySpec`

### NBHistoryEntries[nb, tag] → List
Returns all entries with diff decompressed.
Options: `Decompress -> True`

### NBHistoryUpdateLast[nb, tag, updates]
Updates the last entry with fields from `updates` Association. Format: `<|"response" -> ..., "code" -> ..., ...|>`.

### NBHistoryReadHeader[nb, tag] → Association
Returns the header Association of the history.

### NBHistoryWriteHeader[nb, tag, header]
Overwrites the header of the history.

### NBHistoryUpdateHeader[nb, tag, updates]
Merges `updates` into existing header (existing keys overwritten, new keys appended).

### NBHistoryEntriesWithInherit[nb, tag] → List
Returns all entries including entries from parent history chains. Traverses `parent`/`inherit`/`created` fields in header.
Options: `Decompress -> True`

### NBHistoryListTags[nb, prefix] → List
Returns all history tag names starting with `prefix`.

### NBHistoryDelete[nb, tag]
Deletes the specified history from `TaggingRules`.

### NBHistoryReplaceEntries[nb, tag, entries]
Replaces the entire entry list. Use for compaction or batch updates.

## Session Attachment API

### NBHistoryAddAttachment[nb, tag, path]
Attaches a file to the session. Appends `path` to `"attachments"` list in header (deduplicates).

### NBHistoryRemoveAttachment[nb, tag, path]
Removes a file from session attachments.

### NBHistoryGetAttachments[nb, tag] → List
Returns the list of attachment paths for the session.

### NBHistoryClearAttachments[nb, tag]
Clears all attachments from the session.

## API Key Accessor

### NBGetAPIKey[provider] → String
Returns the API key for the specified AI provider. Manages `SystemCredential` access.
`provider`: `"anthropic"` | `"openai"` | `"github"`
Options: `PrivacySpec -> <|"AccessLevel" -> 1.0|>` (default)

## Fallback Model / Provider Access Level API

### NBSetFallbackModels[models]
Sets the fallback model list. Format: `{{provider, model}, {provider, model, url}, ...}`.
例: `NBSetFallbackModels[{{"anthropic", "claude-opus-4-6"}, {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}}]`

### NBGetFallbackModels[] → List
Returns the full fallback model list.

### NBSetProviderMaxAccessLevel[provider, level]
Sets the maximum data access level permitted for a provider. LLM requests exceeding this level will not fall back to this provider.
例: `NBSetProviderMaxAccessLevel["anthropic", 0.5]`
`NBSetProviderMaxAccessLevel["lmstudio", 1.0]`

### NBGetProviderMaxAccessLevel[provider] → Real
Returns the maximum access level for a provider. Returns 0.5 for unregistered providers.

### NBGetAvailableFallbackModels[accessLevel] → List
Returns fallback models available for the given access level. Only includes models where provider's MaxAccessLevel ≥ accessLevel.
例: `NBGetAvailableFallbackModels[0.8]` → lmstudio only; `NBGetAvailableFallbackModels[0.5]` → all providers

### NBProviderCanAccess[provider, accessLevel] → True | False
Returns whether provider can handle data at the given access level (MaxAccessLevel ≥ accessLevel).

## Accessible Directory API

### NBSetAccessibleDirs[nb, {dir1, dir2, ...}]
Saves the list of directories accessible to Claude Code in notebook's `TaggingRules`.

### NBSetAccessibleDirs[{dir1, dir2, ...}]
Saves to `EvaluationNotebook[]`.

### NBGetAccessibleDirs[nb] → List
Returns the saved accessible directory list.

### NBGetAccessibleDirs[] → List
Retrieves from `EvaluationNotebook[]`.

## Cursor Navigation

### NBMoveToEnd[nb]
Moves cursor to the end of the notebook.

## Job Management API

Job API manages async output slot positions for ClaudeQuery/ClaudeEval non-blocking output.

### NBBeginJob[nb, evalCell] → jobId
Inserts 3 invisible slot cells immediately after `evalCell` and returns a job ID. If `evalCell` is not a CellObject, inserts at notebook end.
Slot 1: system message (progress/fallback notifications)
Slot 2: completion message
Anchor: marks response write position

### NBBeginJobAtEvalCell[nb] → jobId
Internally retrieves `EvaluationCell[]` and inserts job slots after it. Use when calling code does not hold a CellObject reference.

### NBWriteSlot[jobId, slotIdx, cellExpr]
Writes a Cell expression to slot `slotIdx` of the job and makes it visible. Overwrites if called again for the same slot.

### NBJobMoveToAnchor[jobId]
Moves cursor to immediately after the anchor cell. Call before writing response content.

### NBEndJob[jobId]
Terminates job normally. Deletes unwritten slots and anchor, clears table.

### NBAbortJob[jobId, errorMsg]
Writes error message and terminates job.

## Separation API

Functions for claudecode package to access NBAccess internals without direct CellObject/Private access.

### NBExtractAssignments[text] → List
Extracts LHS variable names from Set/SetDelayed expressions in text.

### NBSetConfidentialVars[assoc]
Bulk-sets the confidential variable table. `assoc`: `<|"varName" -> True, ...|>`.

### NBGetConfidentialVars[] → Association
Returns the current confidential variable table.

### NBClearConfidentialVars[]
Clears the confidential variable table.

### NBRegisterConfidentialVar[name, level]
Registers one confidential variable. `level` defaults to 1.0.

### NBUnregisterConfidentialVar[name]
Unregisters one confidential variable.

### NBGetPrivacySpec[] → Association
Returns the current `$NBPrivacySpec`.

### NBInstallCellEpilog[nb, key, expr]
Sets an expression in the notebook's `CellEpilog` identified by `key`. No-op if already installed.

### NBCellEpilogInstalledQ[nb, key] → True | False
Returns whether `CellEpilog` with the given `key` is already installed.

### NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol]
Installs a confidential variable tracking `CellEpilog`. `checkSymbol` is a marker symbol used for `FreeQ` checking. No-op if already installed.

### NBConfidentialEpilogInstalledQ[nb, checkSymbol] → True | False
Returns whether the confidential tracking `CellEpilog` is installed. `checkSymbol` is the FreeQ marker symbol.

### NBEvaluatePreviousCell[nb]
Selects and evaluates the cell immediately before the current cell.

### NBInsertInputTemplate[nb, boxes]
Inserts an Input cell template.

### NBParentNotebookOfCurrentCell[] → NotebookObject
Returns the parent notebook of `EvaluationCell`.