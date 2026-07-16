(* ::Package:: *)

(* NBAccess.wl -- Notebook Access Utility Package
   This file is encoded in UTF-8.
   Load via: Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
   Or use claudecode.wl which handles encoding automatically. *)

(* ============================================================
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30a2\:30af\:30bb\:30b9\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3\:30d1\:30c3\:30b1\:30fc\:30b8
   \:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30d9\:30fc\:30b9\:3067\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8aad\:307f\:66f8\:304d\:3068\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3092\:63d0\:4f9b\:3059\:308b\:3002
   ============================================================ *)

BeginPackage["NBAccess`"];


(* ---- \:30aa\:30d7\:30b7\:30e7\:30f3\:540d ---- *)
(* Decompress: NBAccess \:5c65\:6b74\:95a2\:6570\:306e\:30aa\:30d7\:30b7\:30e7\:30f3\:3002
   True (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8): Diff \:5dee\:5206\:3092\:5fa9\:5143\:3057\:3066\:5e73\:6587\:3067\:8fd4\:3059\:3002
   False: Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:306e\:307e\:307e\:8fd4\:3059 (\:5dee\:5206\:691c\:67fb\:7528)\:3002
   \:6ce8: System`Decompress \:3092\:30aa\:30d7\:30b7\:30e7\:30f3\:30e9\:30d9\:30eb\:3068\:3057\:3066\:4f7f\:7528 (\:30b7\:30f3\:30dc\:30eb\:306e\:65b0\:898f\:5b9a\:7fa9\:306f\:3057\:306a\:3044)\:3002 *)

PrivacySpec::usage =
  "PrivacySpec \:306f NBAccess \:95a2\:6570\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:30aa\:30d7\:30b7\:30e7\:30f3\:3002\n" <>
  "\:4f8b: PrivacySpec -> <|\"AccessLevel\" -> 0.5|>\n" <>
  "  AccessLevel \[LessEqual] \:30bb\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb \:306e\:30bb\:30eb\:306e\:307f\:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:3002\n" <>
  "  0.5: \:30af\:30e9\:30a6\:30c9LLM\:5b89\:5168\:306a\:30c7\:30fc\:30bf\:306e\:307f (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8)\n" <>
  "  1.0: \:30ed\:30fc\:30ab\:30ebLLM\:74b0\:5883\:306a\:3069\:3059\:3079\:3066\:306e\:30c7\:30fc\:30bf";

(* ---- \:30b0\:30ed\:30fc\:30d0\:30eb\:5909\:6570 ---- *)
$NBPrivacySpec::usage =
  "$NBPrivacySpec \:306f NBAccess \:95a2\:6570\:306e\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8 PrivacySpec\:3002\n" <>
  "\:521d\:671f\:5024: <|\"AccessLevel\" -> 0.5|> (\:30af\:30e9\:30a6\:30c9LLM\:5b89\:5168\:306a\:30c7\:30fc\:30bf\:306e\:307f)\:3002\n" <>
  "\:30ed\:30fc\:30ab\:30ebLLM\:74b0\:5883\:304b\:3089\:5229\:7528\:3059\:308b\:5834\:5408: $NBPrivacySpec = <|\"AccessLevel\" -> 1.0|>";

$NBConfidentialSymbols::usage =
  "$NBConfidentialSymbols \:306f\:79d8\:5bc6\:5909\:6570\:540d\:3068\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:306e\:30c6\:30fc\:30d6\:30eb\:3002\n" <>
  "<|\"\:5909\:6570\:540d\" -> privacyLevel, ...|> \:306e\:5f62\:5f0f\:3002\n" <>
  "ClaudeCode \:30d1\:30c3\:30b1\:30fc\:30b8\:304c\:81ea\:52d5\:7684\:306b\:66f4\:65b0\:3059\:308b\:3002";

$NBSendDataSchema::usage =
  "$NBSendDataSchema \:306f\:79d8\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf\:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:3092\:30af\:30e9\:30a6\:30c9LLM\:306b\:9001\:4fe1\:3059\:308b\:304b\:3092\:5236\:5fa1\:3059\:308b\:3002\n" <>
  "True (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8): \:79d8\:5bc6\:4f9d\:5b58 Output \:3067\:3082\:30c7\:30fc\:30bf\:578b\:30fb\:30b5\:30a4\:30ba\:30fb\:30ad\:30fc\:7b49\:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:3092\:9001\:4fe1\:3059\:308b\:3002\n" <>
  "False: \:79d8\:5bc6\:4f9d\:5b58 Output \:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:3092\:4e00\:5207\:9001\:4fe1\:3057\:306a\:3044\:3002\n" <>
  "\:975e\:79d8\:5bc6 Output \:306f\:5e38\:306b\:30b9\:30de\:30fc\:30c8\:8981\:7d04\:4ed8\:304d\:3067\:9001\:4fe1\:3055\:308c\:308b\:3002";

$NBVerbose::usage =
  "$NBVerbose \:306f NBAccess \:30d1\:30c3\:30b1\:30fc\:30b8\:306e\:8a73\:7d30\:30ed\:30b0\:51fa\:529b\:3092\:5236\:5fa1\:3059\:308b\:30d5\:30e9\:30b0\:3002\n" <>
  "True: NBAccess \:5185\:90e8\:306e\:8a73\:7d30\:30ed\:30b0\:3092 Messages \:306b\:51fa\:529b\:3059\:308b\:3002\n" <>
  "False (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8): \:91cd\:5927\:30a8\:30e9\:30fc\:4ee5\:5916\:306e NBAccess \:30ed\:30b0\:3092\:6291\:5236\:3059\:308b\:3002";

$NBAutoEvalProhibitedPatterns::usage =
  "$NBAutoEvalProhibitedPatterns \:306f NBEvaluatePreviousCell \:3067\:81ea\:52d5\:5b9f\:884c\:3092\:30d6\:30ed\:30c3\:30af\:3059\:308b\:30d1\:30bf\:30fc\:30f3\:306e\:30ea\:30b9\:30c8\:3002\n" <>
  "RegularExpression \:307e\:305f\:306f StringExpression \:306e\:30ea\:30b9\:30c8\:3002\n" <>
  "\:30bb\:30eb\:5185\:5bb9\:304c\:3044\:305a\:308c\:304b\:306e\:30d1\:30bf\:30fc\:30f3\:306b\:30de\:30c3\:30c1\:3059\:308b\:5834\:5408\:3001\:8a55\:4fa1\:3092\:30b9\:30ad\:30c3\:30d7\:3057\:3066\:8b66\:544a\:3092\:8868\:793a\:3059\:308b\:3002\n" <>
  "ClaudeCode \:30d1\:30c3\:30b1\:30fc\:30b8\:304c\:30ed\:30fc\:30c9\:6642\:306b\:30d1\:30bf\:30fc\:30f3\:3092\:767b\:9332\:3059\:308b\:3002\:30c7\:30d5\:30a9\:30eb\:30c8\:306f\:7a7a\:30ea\:30b9\:30c8\:3002";

(* ---- \:30bb\:30eb\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3 API (\:65b0\:898f) ---- *)
NBCellCount::usage =
  "NBCellCount[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:5168\:30bb\:30eb\:6570\:3092\:8fd4\:3059\:3002";
NBCurrentCellIndex::usage =
  "NBCurrentCellIndex[nb] \:306f EvaluationCell[] \:306e\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:3092\:8fd4\:3059\:3002\n" <>
  "\:898b\:3064\:304b\:3089\:306a\:3044\:5834\:5408\:306f 0 \:3092\:8fd4\:3059\:3002";
NBSelectedCellIndices::usage =
  "NBSelectedCellIndices[nb] \:306f\:9078\:629e\:4e2d\:30bb\:30eb\:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "\:30bb\:30eb\:30d6\:30e9\:30b1\:30c3\:30c8\:9078\:629e\:307e\:305f\:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306e\:30bb\:30eb\:3092\:8fd4\:3059\:3002";
NBCellIndicesByTag::usage =
  "NBCellIndicesByTag[nb, tag] \:306f\:6307\:5b9a CellTags \:3092\:6301\:3064\:30bb\:30eb\:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002";
NBCellIndicesByStyle::usage =
  "NBCellIndicesByStyle[nb, style] \:306f\:6307\:5b9a CellStyle \:306e\:30bb\:30eb\:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "NBCellIndicesByStyle[nb, {style1, style2, ...}] \:306f\:8907\:6570\:30b9\:30bf\:30a4\:30eb\:3092\:6307\:5b9a\:53ef\:80fd\:3002";
NBDeleteCellsByTag::usage =
  "NBDeleteCellsByTag[nb, tag] \:306f\:6307\:5b9a CellTags \:3092\:6301\:3064\:30bb\:30eb\:3092\:5168\:3066\:524a\:9664\:3059\:308b\:3002";
NBMoveAfterCell::usage =
  "NBMoveAfterCell[nb, cellIdx] \:306f\:30bb\:30eb\:306e\:5f8c\:308d\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5\:3059\:308b\:3002";
NBCellRead::usage =
  "NBCellRead[nb, cellIdx] \:306f NotebookRead \:3067 Cell \:5f0f\:3092\:8fd4\:3059\:3002";
NBCellReadInputText::usage =
  "NBCellReadInputText[nb, cellIdx] \:306f FrontEnd \:7d4c\:7531\:3067 InputText \:5f62\:5f0f\:3092\:53d6\:5f97\:3059\:308b\:3002\n" <>
  "\:5931\:6557\:6642\:306f NBCellExprToText \:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3002";
NBCellStyle::usage =
  "NBCellStyle[nb, cellIdx] \:306f\:30bb\:30eb\:306e CellStyle \:3092\:8fd4\:3059\:3002";
NBCellLabel::usage =
  "NBCellLabel[nb, cellIdx] \:306f\:30bb\:30eb\:306e CellLabel (\:4f8b: \"In[3]:=\") \:3092\:8fd4\:3059\:3002\n" <>
  "\:30e9\:30d9\:30eb\:306a\:3057\:306e\:5834\:5408\:306f \"\" \:3092\:8fd4\:3059\:3002";
NBCellSetOptions::usage =
  "NBCellSetOptions[nb, cellIdx, opts] \:306f\:30bb\:30eb\:306b SetOptions \:3092\:9069\:7528\:3059\:308b\:3002";
NBCellSetStyle::usage =
  "NBCellSetStyle[nb, cellIdx, style] \:306f\:30bb\:30eb\:306e\:30b9\:30bf\:30a4\:30eb\:3092\:5909\:66f4\:3059\:308b\:3002\n" <>
  "Cell \:5f0f\:306e\:7b2c2\:5f15\:6570\:3092\:66f8\:304d\:63db\:3048\:308b\:3002TaggingRules \:7b49\:306e\:5c5e\:6027\:306f\:4fdd\:6301\:3055\:308c\:308b\:3002\n" <>
  "\:4f8b: NBCellSetStyle[nb, 3, \"Input\"]";
NBCellWriteCode::usage =
  "NBCellWriteCode[nb, cellIdx, code] \:306f\:65e2\:5b58\:30bb\:30eb\:306b\:30b3\:30fc\:30c9\:3092 BoxData + Input \:30b9\:30bf\:30a4\:30eb\:3067\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "FEParser \:3067\:69cb\:6587\:30ab\:30e9\:30fc\:30ea\:30f3\:30b0\:4ed8\:304d BoxData \:306b\:5909\:63db\:3057\:3001\n" <>
  "Cell \:5f0f\:5168\:4f53\:3092\:5185\:5bb9\:ff08BoxData\:ff09\:3068\:30b9\:30bf\:30a4\:30eb\:ff08Input\:ff09\:3067\:7f6e\:63db\:3059\:308b\:3002\n" <>
  "\:4f8b: NBCellWriteCode[nb, 3, \"Plot[Sin[x], {x, 0, 2Pi}]\"]";
NBSelectCell::usage =
  "NBSelectCell[nb, cellIdx] \:306f\:30bb\:30eb\:30d6\:30e9\:30b1\:30c3\:30c8\:3092\:9078\:629e\:72b6\:614b\:306b\:3059\:308b\:3002\n" <>
  "\:30d1\:30ec\:30c3\:30c8\:64cd\:4f5c\:5f8c\:306e\:30bb\:30eb\:9078\:629e\:5fa9\:5143\:306b\:4f7f\:7528\:3059\:308b\:3002";
NBResolveCell::usage =
  "NBResolveCell[nb, cellIdx] \:306f CellObject \:3092\:8fd4\:3059\:3002\n" <>
  "\:6307\:5b9a\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:304c\:7121\:52b9\:306a\:5834\:5408\:306f $Failed \:3092\:8fd4\:3059\:3002";
NBCellGetTaggingRule::usage =
  "NBCellGetTaggingRule[nb, cellIdx, path] \:306f TaggingRules \:306e\:30cd\:30b9\:30c8\:5024\:3092\:8fd4\:3059\:3002\n" <>
  "\:4f8b: NBCellGetTaggingRule[nb, 3, {\"claudecode\", \"confidential\"}]";
NBCellRasterize::usage =
  "NBCellRasterize[nb, cellIdx, file, opts] \:306f\:30bb\:30eb\:3092 Rasterize \:3057\:3066 file \:306b\:4fdd\:5b58\:3059\:308b\:3002";

NBCellHasImage::usage =
  "NBCellHasImage[cellExpr] \:306f Cell \:5f0f\:304c\:753b\:50cf (RasterBox/GraphicsBox) \:3092\:542b\:3080\:304b\:5224\:5b9a\:3059\:308b\:3002\n" <>
  "cellExpr \:306f NBCellRead \:306e\:623b\:308a\:5024\:3092\:60f3\:5b9a\:3002";

NBCellWriteText::usage =
  "NBCellWriteText[nb, cellIdx, newText] \:306f\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:5185\:5bb9\:3092 newText \:306b\:7f6e\:304d\:63db\:3048\:308b\:3002\n" <>
  "\:30bb\:30eb\:30b9\:30bf\:30a4\:30eb\:30fbTaggingRules\:30fb\:30aa\:30d7\:30b7\:30e7\:30f3\:7b49\:306e\:5c5e\:6027\:306f\:305d\:306e\:307e\:307e\:4fdd\:6301\:3055\:308c\:308b\:3002\n" <>
  "\:4f8b: NBCellWriteText[nb, 3, \"\:65b0\:3057\:3044\:30c6\:30ad\:30b9\:30c8\"]";

NBCellSetTaggingRule::usage =
  "NBCellSetTaggingRule[nb, cellIdx, path, value] \:306f\:30bb\:30eb\:306e TaggingRules \:306b\:30cd\:30b9\:30c8\:5024\:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "NBCellGetTaggingRule \:306e\:5bfe\:3068\:306a\:308b\:30bb\:30c3\:30bf\:30fc\:95a2\:6570\:3002\n" <>
  "\:4f8b: NBCellSetTaggingRule[nb, 3, {\"documentation\", \"idea\"}, \"\:5143\:306e\:30a2\:30a4\:30c7\:30a2\"]";

(* ---- LLM \:9023\:643a API ---- *)
$NBLLMQueryFunc::usage =
  "$NBLLMQueryFunc \:306f\:975e\:540c\:671f LLM \:547c\:3073\:51fa\:3057\:7528\:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:95a2\:6570\:3002\n" <>
  "ClaudeCode \:30d1\:30c3\:30b1\:30fc\:30b8\:304c\:81ea\:52d5\:7684\:306b ClaudeQueryAsync \:3092\:767b\:9332\:3059\:308b\:3002\n" <>
  "\:30b7\:30b0\:30cd\:30c1\:30e3: $NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool, Integrations -> {...}]\n" <>
  "callback \:306f\:5fdc\:7b54\:6587\:5b57\:5217\:3092\:53d7\:3051\:53d6\:308b\:95a2\:6570\:3002nb \:306f\:51fa\:529b\:5148 NotebookObject\:3002\n" <>
  "Integrations \:306f LM Studio MCP \:7528 (lmstudio \:30e2\:30c7\:30eb\:6642\:306e\:307f\:6709\:52b9\:3001Automatic \:306a\:3089\:7121\:8996)\:3002\n" <>
  "\:30ab\:30fc\:30cd\:30eb\:3092\:30d6\:30ed\:30c3\:30af\:3057\:306a\:3044\:3002";

NBCellGetText::usage =
  "NBCellGetText[nb, cellIdx] \:306f\:30bb\:30eb\:304b\:3089\:30c6\:30ad\:30b9\:30c8\:3092\:5805\:7262\:306b\:53d6\:5f97\:3059\:308b\:3002\n" <>
  "FrontEnd InputText \[RightArrow] NBCellToText \[RightArrow] NBCellExprToText \:306e\:9806\:3067\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3002\n" <>
  "\:30c6\:30ad\:30b9\:30c8\:53d6\:5f97\:4e0d\:53ef\:306e\:5834\:5408\:306f \"\" \:3092\:8fd4\:3059\:3002";

NBCellTransformWithLLM::usage =
  "NBCellTransformWithLLM[nb, cellIdx, promptFn, completionFn] \:306f\:975e\:540c\:671f\:3067\:30bb\:30eb\:3092 LLM \:5909\:63db\:3059\:308b\:3002\n" <>
  "promptFn \:306f\:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:3092\:53d7\:3051\:53d6\:308a\:30d7\:30ed\:30f3\:30d7\:30c8\:6587\:5b57\:5217\:3092\:8fd4\:3059\:95a2\:6570\:3002\n" <>
  "completionFn \:306f\:7d50\:679c Association \:3092\:53d7\:3051\:53d6\:308b\:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:3002\:30a8\:30e9\:30fc\:6642\:306f $Failed \:3092\:53d7\:3051\:53d6\:308b\:3002\n" <>
  "\:30ab\:30fc\:30cd\:30eb\:3092\:30d6\:30ed\:30c3\:30af\:3057\:306a\:3044\:3002\:30bb\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:306b\:5fdc\:3058\:3066\:9069\:5207\:306a LLM \:3092\:81ea\:52d5\:9078\:629e\:3059\:308b\:3002\n" <>
  "Options:\n" <>
  "  Fallback -> False\n" <>
  "  InputText -> Automatic: \:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:306e\:4ee3\:308f\:308a\:306b\:4f7f\:7528\:3059\:308b\:5165\:529b\:30c6\:30ad\:30b9\:30c8\:3002\n" <>
  "  Integrations -> Automatic: LM Studio MCP \:30b5\:30fc\:30d0\:30fc\:30ea\:30b9\:30c8 (lmstudio \:30e2\:30c7\:30eb\:6642\:306e\:307f)\:3002\n" <>
  "completionFn \:304c\:53d7\:3051\:53d6\:308b Association:\n" <>
  "  <|\"Response\" -> text, \"OriginalText\" -> orig, \"PrivacyLevel\" -> pl|>\n" <>
  "\:4f8b: NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]";

(* ---- \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc API ---- *)
NBCellPrivacyLevel::usage =
  "NBCellPrivacyLevel[nb, cellIdx] \:306f\:30bb\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb (0.0\:301c1.0) \:3092\:8fd4\:3059\:3002\n" <>
  "0.0: \:975e\:79d8\:5bc6, 1.0: \:79d8\:5bc6 (Confidential\:30de\:30fc\:30af or \:79d8\:5bc6\:5909\:6570\:53c2\:7167)";

NBIsAccessible::usage =
  "NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] \:306f\:30bb\:30eb\:304c\:6307\:5b9a\:306e\n" <>
  "PrivacySpec \:3067\:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:304b\:3069\:3046\:304b\:3092\:8fd4\:3059 (True/False)\:3002";

NBFilterCellIndices::usage =
  "NBFilterCellIndices[nb, indices, PrivacySpec -> ps] \:306f\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30ea\:30b9\:30c8\:3092\n" <>
  "PrivacySpec \:3067\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3057\:3066\:8fd4\:3059\:3002";

(* ---- \:30c6\:30ad\:30b9\:30c8\:62bd\:51fa API ---- *)
NBCellExprToText::usage =
  "NBCellExprToText[cellExpr] \:306f NotebookRead \:306e\:7d50\:679c (Cell\:5f0f) \:304b\:3089\n" <>
  "\:30c6\:30ad\:30b9\:30c8\:3092\:62bd\:51fa\:3059\:308b\:3002";

NBCellToText::usage =
  "NBCellToText[nb, cellIdx] \:306f\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:5185\:5bb9\:3092\:8fd4\:3059\:3002";

NBGetCells::usage =
  "NBGetCells[nb, PrivacySpec -> ps] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:306e\:5168\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:3092\n" <>
  "PrivacySpec \:3067\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3057\:3066\:8fd4\:3059\:3002";

NBGetContext::usage =
  "NBGetContext[nb, afterIdx, PrivacySpec -> ps] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:306e\n" <>
  "afterIdx \:756a\:76ee\:4ee5\:964d\:306e\:30bb\:30eb\:304b\:3089 LLM \:30d7\:30ed\:30f3\:30d7\:30c8\:7528\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:6587\:5b57\:5217\:3092\:69cb\:7bc9\:3059\:308b\:3002\n" <>
  "PrivacySpec \:3067\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3055\:308c\:308b\:3002\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8: AccessLevel 0.5\:3002";

(* ---- \:66f8\:304d\:8fbc\:307f API ---- *)
NBWriteText::usage =
  "NBWriteText[nb, text, style] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b\:30c6\:30ad\:30b9\:30c8\:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "style \:306e\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8\:306f \"Text\"\:3002";

NBWriteCode::usage =
  "NBWriteCode[nb, code] \:306f\:69cb\:6587\:30ab\:30e9\:30fc\:30ea\:30f3\:30b0\:4ed8\:304d Input \:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002";

NBWriteSmartCode::usage =
  "NBWriteSmartCode[nb, code] \:306f CellPrint[] \:30d1\:30bf\:30fc\:30f3\:3092\:81ea\:52d5\:691c\:51fa\:3057\:3066\n" <>
  "\:30b9\:30de\:30fc\:30c8\:306b\:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002";

NBWriteInputCellAndMaybeEvaluate::usage =
  "NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate] \:306f\n" <>
  "\:73fe\:5728\:306e\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306e\:5f8c\:308d\:306b Input \:30bb\:30eb\:3092\:633f\:5165\:3057\:3001\:30ab\:30fc\:30bd\:30eb\:3092\:30bb\:30eb\:5148\:982d\:306b\:79fb\:52d5\:3059\:308b\:3002\n" <>
  "autoEvaluate \:304c True \:306e\:5834\:5408\:306f\:3055\:3089\:306b SelectionEvaluate \:3092\:884c\:3046\:3002";

NBInsertTextCells::usage =
  "NBInsertTextCells[nbFile, name, prompt] \:306f .nb \:30d5\:30a1\:30a4\:30eb\:3092\:975e\:8868\:793a\:3067\:958b\:304d\:3001\n" <>
  "\:672b\:5c3e\:306b Subsection \:30bb\:30eb (name) \:3068 Text \:30bb\:30eb (prompt) \:3092\:633f\:5165\:3057\:3066\:4fdd\:5b58\:30fb\:9589\:3058\:308b\:3002";

(* ---- \:30d5\:30a1\:30a4\:30eb\:578b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:64cd\:4f5c API ---- *)
(* \:9589\:3058\:305f .nb \:30d5\:30a1\:30a4\:30eb\:3092\:5bfe\:8c61\:3068\:3057\:305f\:8aad\:307f\:66f8\:304d\:64cd\:4f5c\:3002
   \:79d8\:533f\:30bb\:30eb\:306e\:6709\:7121\:306b\:95a2\:308f\:3089\:305a\:3001\:5fc5\:305a\:3053\:306e API \:3092\:7d4c\:7531\:3059\:308b\:3002
   \:898f\:5247: claudecode.wl \:7b49\:306e\:4e0a\:4f4d\:5c64\:304b\:3089 .nb \:30d5\:30a1\:30a4\:30eb\:3092\:76f4\:63a5 NotebookOpen/NotebookGet
         \:306a\:3069\:3067\:958b\:3044\:3066\:306f\:306a\:3089\:306a\:3044\:3002\:5fc5\:305a NBFileOpen \:3092\:4f7f\:3046\:3053\:3068\:3002              *)
NBFileOpen::usage =
  "NBFileOpen[path] \:306f .nb \:30d5\:30a1\:30a4\:30eb\:3092\:975e\:8868\:793a (Visible->False) \:3067\:958b\:304d\n" <>
  "NotebookObject \:3092\:8fd4\:3059\:3002\:5931\:6557\:6642\:306f $Failed \:3092\:8fd4\:3059\:3002\n" <>
  "\:5fc5\:305a NBFileClose \:3067\:9589\:3058\:308b\:3053\:3068\:3002\n" <>
  "\:4f8b: nb2 = NBFileOpen[\"C:\\\\path\\\\to\\\\file.nb\"]";

NBFileClose::usage =
  "NBFileClose[nb] \:306f NBFileOpen \:3067\:958b\:3044\:305f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:9589\:3058\:308b\:3002\n" <>
  "\:4f8b: NBFileClose[nb2]";

NBFileSave::usage =
  "NBFileSave[nb, path] \:306f\:958b\:3044\:3066\:3044\:308b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:6307\:5b9a\:30d1\:30b9\:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "path \:304c None \:306e\:5834\:5408\:306f\:4e0a\:66f8\:304d\:4fdd\:5b58\:3002\n" <>
  "\:4f8b: NBFileSave[nb2, \"C:\\\\path\\\\to\\\\translated.nb\"]";

NBFileReadCells::usage =
  "NBFileReadCells[nb, PrivacySpec -> ps] \:306f\:958b\:3044\:3066\:3044\:308b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:5168\:30bb\:30eb\:3092\n" <>
  "PrivacySpec \:306b\:5f93\:3063\:3066\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3057\:3001{<|cellIdx, style, text, privacyLevel|>, ...} \:3092\:8fd4\:3059\:3002\n" <>
  "privacyLevel > PrivacySpec \:306e\:79d8\:533f\:30bb\:30eb\:306f\:30c6\:30ad\:30b9\:30c8\:3092 \"[CONFIDENTIAL]\" \:306b\:7f6e\:63db\:3059\:308b\:3002\n" <>
  "\:4f8b: cells = NBFileReadCells[nb2, PrivacySpec -> <|\"AccessLevel\"->0.5|>]";

NBFileReadAllCells::usage =
  "NBFileReadAllCells[nb] \:306f\:958b\:3044\:3066\:3044\:308b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:5168\:30bb\:30eb\:3092\n" <>
  "\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:5225\:306b\:5206\:985e\:3057\:3066\:8fd4\:3059\:3002\:79d8\:533f\:30bb\:30eb\:3082\:542b\:3080\:5168\:30bb\:30eb\:3092\:8fd4\:3059\:304c\n" <>
  "PrivacyLevel \:30d5\:30a3\:30fc\:30eb\:30c9\:3067\:8b58\:5225\:3067\:304d\:308b\:3002\:30ed\:30fc\:30ab\:30eb\:30e2\:30c7\:30eb\:3067\:51e6\:7406\:3059\:308b\:969b\:306b\:4f7f\:7528\:3002\n" <>
  "\:4f8b: cells = NBFileReadAllCells[nb2]";

NBFileWriteCell::usage =
  "NBFileWriteCell[nb, cellIdx, newText] \:306f\:958b\:3044\:3066\:3044\:308b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\n" <>
  "\:6307\:5b9a\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:3092 newText \:3067\:7f6e\:304d\:63db\:3048\:308b\:3002\n" <>
  "\:30bb\:30eb\:30b9\:30bf\:30a4\:30eb\:30fbTaggingRules\:30fb\:79d8\:533f\:30de\:30fc\:30af\:7b49\:306e\:5c5e\:6027\:306f\:305d\:306e\:307e\:307e\:4fdd\:6301\:3055\:308c\:308b\:3002\n" <>
  "\:4f8b: NBFileWriteCell[nb2, 3, \"This is a pen.\"]";

NBFileWriteAllCells::usage =
  "NBFileWriteAllCells[nb, replacements] \:306f {cellIdx -> newText, ...} \:306e\n" <>
  "Associaiton \:307e\:305f\:306f List \:306b\:5f93\:3063\:3066\:8907\:6570\:30bb\:30eb\:3092\:4e00\:62ec\:7f6e\:63db\:3059\:308b\:3002\n" <>
  "\:4f8b: NBFileWriteAllCells[nb2, <|2->\"text\", 3->\"[CONFIDENTIAL]\"|>]";

(* ---- ObjectSpec API ---- *)
NBFileSpec::usage =
  "NBFileSpec[path] \:306f\:30d5\:30a1\:30a4\:30eb\:306e\:30e1\:30bf\:60c5\:5831\:3068 PrivacyLevel \:3092 Association \:3067\:8fd4\:3059\:3002\n" <>
  "PrivacyLevel: <0.5=\:30af\:30e9\:30a6\:30c9LLM\:53ef, >=0.5=\:30ed\:30fc\:30ab\:30eb\:306e\:307f, {0.5,1.0}=\:6df7\:5728(.nb)\:3002\n" <>
  "\:4f8b: NBFileSpec[\"C:\\\\path\\\\file.nb\"]";

NBFileSpecCacheClear::usage =
  "NBFileSpecCacheClear[] clears the NBFileSpec base/projection caches introduced in Phase 4.3.";

NBNormalizePath::usage =
  "NBNormalizePath[path] \:306f\:7d76\:5bfe\:30d1\:30b9\:3092\:3001\:8907\:6570 PC \:9593\:3067\:5b89\:5b9a\:306a\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:60c5\:5831\:306e Association \:306b\:6b63\:898f\:5316\:3059\:308b\:3002\n" <>
  "\:623b\:308a\:5024: <|\"Kind\", \"RootId\", \"Parts\", \"SymbolicPath\", \"PhysicalPath\", \"ResolutionStatus\", \"MatchedBy\"|>\:3002\n" <>
  "  ResolutionStatus: \"ResolvedOnThisPC\" (\:73fe PC \:5b9f\:4f53\:30eb\:30fc\:30c8\:914d\:4e0b) | \"AliasOnly\" (\:5225 PC \:30a8\:30a4\:30ea\:30a2\:30b9\:306b\:306e\:307f\:4e00\:81f4) | \"Unrooted\" (\:3069\:306e\:30eb\:30fc\:30c8\:306b\:3082\:975e\:8a72\:5f53)\:3002\n" <>
  "  MatchedBy: \"LocalRoot\" | \"Alias\" | \"None\"\:3002\n" <>
  "SourceVault \:304c\:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089 iSVSymbolicPath \:306e\:30af\:30ed\:30b9 PC \:6b63\:898f\:5316 (\:30a8\:30a4\:30ea\:30a2\:30b9\:5bfe\:5fdc) \:3092\:5229\:7528\:3059\:308b\:3002\n" <>
  "\:91cd\:8981: \:623b\:308a\:5024\:306f\:540c\:4e00\:6027 (identity) \:306e\:305f\:3081\:306e\:60c5\:5831\:3067\:3042\:308a\:3001\:30a2\:30af\:30bb\:30b9\:6a29\:9650\:3092\:4e0e\:3048\:308b\:3082\:306e\:3067\:306f\:306a\:3044\:3002\n" <>
  "\:6a29\:9650\:5224\:5b9a\:306f\:5fc5\:305a PhysicalPath \:3092\:73fe PC \:3067\:89e3\:6c7a\:30fb\:5b9f\:5728\:78ba\:8a8d\:3057\:305f\:4e0a\:3067 access mode \:3068 privacy \:3092\:898b\:308b\:3053\:3068 (rule 104)\:3002";

NBValueSpec::usage =
  "NBValueSpec[expr, privacyLevel] \:306f\:5024\:306e\:578b\:60c5\:5831\:3068 PrivacyLevel \:3092\:8fd4\:3059\:3002\n" <>
  "\:4f8b: NBValueSpec[dataset, 1.0]";

NBPrivacyLevelToRoutes::usage =
  "NBPrivacyLevelToRoutes[privacyLevel] \:306f\:5fc5\:8981\:306a\:30e2\:30c7\:30eb\:30eb\:30fc\:30c8\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "0.5 -> {\"cloud\"}, 1.0 -> {\"local\"}, {0.5,1.0} -> {\"cloud\",\"local\"}\n" <>
  "\:4f8b: NBPrivacyLevelToRoutes[{0.5, 1.0}]";

NBFileReadCellsInRange::usage =
  "NBFileReadCellsInRange[nb, lo, hi] \:306f PrivacyLevel \:304c lo\:301chi \:306e\:30bb\:30eb\:306e\:307f\:8fd4\:3059\:3002\n" <>
  "\:4f8b: NBFileReadCellsInRange[nb2, 0.5, 0.5]  (* \:516c\:958b\:30bb\:30eb\:306e\:307f *)\n" <>
  "    NBFileReadCellsInRange[nb2, 0.9, 1.0]  (* \:79d8\:533f\:30bb\:30eb\:306e\:307f *)";
NBSplitNotebookCells::usage =
  "NBSplitNotebookCells[path, threshold] \:306f .nb \:30d5\:30a1\:30a4\:30eb\:306e\:30bb\:30eb\:3092\n" <>
  "PrivacyLevel <= threshold (public) \:3068 > threshold (private) \:306b2\:5206\:5272\:3059\:308b\:3002\n" <>
  "\:623b\:308a\:5024: {publicCells, privateCells}\n" <>
  "\:4f8b: {pub, priv} = NBAccess`NBSplitNotebookCells[\"file.nb\", 0.5]";
NBMergeNotebookCells::usage =
  "NBMergeNotebookCells[sourcePath, outputPath, results1, results2] \:306f\n" <>
  "2\:3064\:306e <|cellIdx->newText|> \:3092\:5143\:30bb\:30eb\:9806\:306b\:30de\:30fc\:30b8\:3057\:3066 outputPath \:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "\:4f8b: NBAccess`NBMergeNotebookCells[src, dst, pubResults, privResults]";

(* ---- \:30bb\:30eb\:30de\:30fc\:30af API ---- *)
NBGetConfidentialTag::usage =
  "NBGetConfidentialTag[nb, cellIdx] \:306f TaggingRules \:304b\:3089\:6a5f\:5bc6\:30bf\:30b0\:3092\:8fd4\:3059: True/False/Missing[]\:3002";

NBSetConfidentialTag::usage =
  "NBSetConfidentialTag[nb, cellIdx, val] \:306f\:30bb\:30eb\:306e\:6a5f\:5bc6\:30bf\:30b0\:3092 val (True/False) \:306b\:8a2d\:5b9a\:3059\:308b\:3002";

NBMarkCellConfidential::usage =
  "NBMarkCellConfidential[nb, cellIdx] \:306f\:30bb\:30eb\:3092\:6a5f\:5bc6 (PrivacyLevel 1.0) \:306b\:8a2d\:5b9a\:3057\:8d64\:80cc\:666f\:30de\:30fc\:30af\:3092\:4ed8\:3051\:308b\:3002\n" <>
  "NBMarkCellConfidential[nb, cellIdx, level] \:306f\:30bb\:30eb\:306e PrivacyLevel \:3092\:4efb\:610f\:306e\:6570\:5024 (0.0-1.0) \:306b\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "level > 0.5 \:306e\:3068\:304d\:8d64\:80cc\:666f\:30de\:30fc\:30af\:3092\:4ed8\:3051\:3001level <= 0.5 \:306a\:3089\:30de\:30fc\:30af\:3092\:5916\:3059\:3002\n" <>
  "Options: PrivacySpec -> Automatic\:3002\n" <>
  "\:3053\:306e\:95a2\:6570\:306f $NBApprovalHeads \:306b\:767b\:9332\:3055\:308c\:3066\:304a\:308a\:3001\:5b9f\:884c\:6642\:306b\:627f\:8a8d\:30b2\:30fc\:30c8\:3092\:767a\:706b\:3055\:305b\:308b\:3002";

NBSetSnapshotPrivacyLevel::usage =
  "NBSetSnapshotPrivacyLevel[snapshotId, level] \:306f SourceVault snapshot \:306e PrivacyLevel \:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "snapshot \:306e PrivacyLevel \:306f\:901a\:5e38\:30bb\:30eb\:5224\:5b9a\:304b\:3089\:306e\:5c0e\:51fa\:5024\:3060\:304c\:3001\:4eba\:9593\:304c\:660e\:793a\:7684\:306b\:4e0a\:66f8\:304d\:3057\:305f\:3044\:5834\:5408\:306b\:4f7f\:3046\:3002\n" <>
  "Options: PrivacySpec -> Automatic\:3002SourceVault \:304c\:30ed\:30fc\:30c9\:3055\:308c\:3066\:3044\:308b\:5fc5\:8981\:304c\:3042\:308b\:3002\n" <>
  "\:3053\:306e\:95a2\:6570\:306f $NBApprovalHeads \:306b\:767b\:9332\:3055\:308c\:3001\:5b9f\:884c\:6642\:306b\:627f\:8a8d\:30b2\:30fc\:30c8\:3092\:767a\:706b\:3055\:305b\:308b\:3002";

NBInsertArtifactCell::usage =
  "NBInsertArtifactCell[nb, uri, opts] \:306f SourceVault artifact URI (sv://artifact/<id> / sv://hash/sha256/<hex>) \:306e\:5185\:5bb9\:3092\n" <>
  "\:89e3\:6c7a\:3057\:3001media \:7a2e\:5225\:306b\:5fdc\:3058\:305f\:30bb\:30eb\:3068\:3057\:3066\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3078\:633f\:5165\:3059\:308b: Image \:306f\:753b\:50cf\:30bb\:30eb\:3001Video/Binary \:306f\:30d5\:30a1\:30a4\:30eb\:30ea\:30f3\:30af\:3001Text \:306f\:672c\:6587\:3002\n" <>
  "\:30bb\:30eb\:306b\:306f artifact \:306e PrivacyLevel \:304c\:5fc5\:305a\:713c\:304d\:8fbc\:307e\:308c (TaggingRules claudecode privacyLevel/confidential)\:3001level > 0.5 \:306a\:3089\n" <>
  "$NBConfidentialCellOpts \:306e\:6a5f\:5bc6\:30de\:30fc\:30af (\:8d64\:80cc\:666f+\:8b66\:544a dingbat) \:4ed8\:304d\:3067\:51fa\:529b\:3055\:308c\:308b\:3002\:751f\:30c7\:30fc\:30bf\:3092\:88f8\:3067\:8fd4\:3059 API \:3067\:306f\:306a\:304f\:3001\n" <>
  "\:5b9f\:4f53\:5316\:306f\:5e38\:306b privacy marking \:3068\:4e00\:4f53 (SourceVault \:306e\:30ac\:30fc\:30c9\:3092\:5265\:304c\:3055\:306a\:3044)\:3002NBInsertArtifactCell[uri] \:306f EvaluationNotebook[] \:3078\:3002\n" <>
  "\:5185\:5bb9\:89e3\:6c7a\:306f SourceVault`SourceVaultResolveArtifactContent (sanctioned reader) \:306b\:59d4\:8b72\:3059\:308b\:3002SourceVault \:672a\:30ed\:30fc\:30c9\:306a\:3089 Error\:3002\n" <>
  "opts: \"VideoCell\" -> False (True \:3067 Video[file] \:30bb\:30eb\:3001\:65e2\:5b9a\:306f\:30d5\:30a1\:30a4\:30eb\:30ea\:30f3\:30af)\:3001\"MaxImageSize\" -> 480 (\:8868\:793a\:4e0a\:306e\:6700\:5927\:5e45 px\:3001None \:3067\:539f\:5bf8)\:3001\n" <>
  "\"Materialize\" -> Automatic\:3002\:623b\:308a\:5024 <|Status, URI, MediaKind, PrivacyLevel, Marked|>\:3002";

NBMarkCellDependent::usage =
  "NBMarkCellDependent[nb, cellIdx] \:306f\:30bb\:30eb\:306b\:4f9d\:5b58\:6a5f\:5bc6\:30de\:30fc\:30af\:ff08\:6a59\:80cc\:666f + LockIcon\:ff09\:3092\:4ed8\:3051\:308b\:3002\n" <>
  "\:6a5f\:5bc6\:5909\:6570\:306b\:4f9d\:5b58\:3059\:308b\:8a08\:7b97\:7d50\:679c\:306a\:3069\:3001\:9593\:63a5\:7684\:306b\:6a5f\:5bc6\:306a\:30bb\:30eb\:306b\:4f7f\:7528\:3059\:308b\:3002";

NBUnmarkCell::usage =
  "NBUnmarkCell[nb, cellIdx] \:306f\:30bb\:30eb\:306e\:6a5f\:5bc6\:30de\:30fc\:30af\:ff08\:8996\:899a\:30fb\:30bf\:30b0\:ff09\:3092\:3059\:3079\:3066\:89e3\:9664\:3059\:308b\:3002";

(* ---- \:30bb\:30eb\:5185\:5bb9\:5206\:6790 API (claudecode\:304b\:3089\:79fb\:8a2d) ---- *)
NBCellUsesConfidentialSymbol::usage =
  "NBCellUsesConfidentialSymbol[nb, cellIdx] \:306f\:30bb\:30eb\:304c\:6a5f\:5bc6\:5909\:6570\:3092\:53c2\:7167\:3057\:3066\:3044\:308b\:304b\:3092\:8fd4\:3059\:3002";

NBCellExtractVarNames::usage =
  "NBCellExtractVarNames[nb, cellIdx] \:306f\:30bb\:30eb\:5185\:5bb9\:304b\:3089 Set/SetDelayed \:306e LHS \:5909\:6570\:540d\:3092\:62bd\:51fa\:3059\:308b\:3002";

NBCellExtractAssignedNames::usage =
  "NBCellExtractAssignedNames[nb, cellIdx] \:306f\:30bb\:30eb\:5185\:5bb9\:304b\:3089 Confidential[] \:5185\:306e\:4ee3\:5165\:5148\:5909\:6570\:540d\:3092\:62bd\:51fa\:3059\:308b\:3002";

NBShouldExcludeFromPrompt::usage =
  "NBShouldExcludeFromPrompt[nb, cellIdx] \:306f\:30bb\:30eb\:304c\:30d7\:30ed\:30f3\:30d7\:30c8\:304b\:3089\:9664\:5916\:3059\:3079\:304d\:304b\:3092\:8fd4\:3059\:3002";

NBIsClaudeFunctionCell::usage =
  "NBIsClaudeFunctionCell[nb, cellIdx] \:306f\:30bb\:30eb\:304c Claude \:95a2\:6570\:547c\:3073\:51fa\:3057\:30bb\:30eb\:304b\:3092\:8fd4\:3059\:3002";

(* ---- \:4f9d\:5b58\:30b0\:30e9\:30d5 API ---- *)
NBAccess`iCellToInputText::usage =
  "iCellToInputText[cell] \:306f FrontEnd\:7d4c\:7531\:3067\:30bb\:30eb\:306e InputText\:5f62\:5f0f\:3092\:53d6\:5f97\:3059\:308b\:3002"
  "\:5931\:6557\:6642\:306f NBCellExprToText \:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3002";

NBBuildVarDependencies::usage =
  "NBBuildVarDependencies[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306eInput\:30bb\:30eb\:3092\:89e3\:6790\:3057\:3066\n" <>
  "\:5909\:6570\:4f9d\:5b58\:95a2\:4fc2\:30b0\:30e9\:30d5 <|\"var\" -> {\"dep1\",...}|> \:3092\:8fd4\:3059\:3002\n" <>
  "\:6587\:5b57\:5217\:30ea\:30c6\:30e9\:30eb\:5185\:306e\:8b58\:5225\:5b50\:306f\:9664\:5916\:3055\:308c\:308b\:3002";

NBBuildGlobalVarDependencies::usage =
  "NBBuildGlobalVarDependencies[] \:306f Notebooks[] \:5168\:4f53\:306e Input \:30bb\:30eb\:3092\:8d70\:67fb\:3057\:3066\n" <>
  "\:7d71\:5408\:3055\:308c\:305f\:5909\:6570\:4f9d\:5b58\:95a2\:4fc2\:30b0\:30e9\:30d5 <|\"var\" -> {\"dep1\",...}|> \:3092\:8fd4\:3059\:3002\n" <>
  "LLM \:547c\:3073\:51fa\:3057\:76f4\:524d\:306e\:7cbe\:5bc6\:30c1\:30a7\:30c3\:30af\:3067\:4f7f\:7528\:3059\:308b\:3002\n" <>
  "\:901a\:5e38\:306e\:30bb\:30eb\:5b9f\:884c\:6642\:306f\:8efd\:91cf\:7248 NBBuildVarDependencies[nb] \:3092\:4f7f\:7528\:3059\:308b\:3053\:3068\:3002";

NBUpdateGlobalVarDependencies::usage =
  "NBUpdateGlobalVarDependencies[existingDeps, afterLine] \:306f\:65e2\:5b58\:306e\:4f9d\:5b58\:30b0\:30e9\:30d5\:306b\n" <>
  "CellLabel In[x] (x > afterLine) \:306e\:30bb\:30eb\:306e\:307f\:3092\:8ffd\:52a0\:8d70\:67fb\:3057\:3066\:30de\:30fc\:30b8\:3059\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024\:306f {updatedDeps, newLastLine}\:3002\n" <>
  "\:5b8c\:5168\:306a\:30b0\:30e9\:30d5\:3092\:6bce\:56de\:69cb\:7bc9\:3059\:308b\:30b3\:30b9\:30c8\:3092\:56de\:907f\:3059\:308b\:30a4\:30f3\:30af\:30ea\:30e1\:30f3\:30bf\:30eb\:7248\:3002";

NBTransitiveDependents::usage =
  "NBTransitiveDependents[deps, confVars] \:306f deps \:30b0\:30e9\:30d5\:4e0a\:3067\n" <>
  "confVars \:306b\:76f4\:63a5\:30fb\:9593\:63a5\:4f9d\:5b58\:3059\:308b\:5168\:5909\:6570\:540d\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002";

NBScanDependentCells::usage =
  "NBScanDependentCells[nb, confVarNames] \:306f\:4f9d\:5b58\:30b0\:30e9\:30d5\:3092\:4f7f\:3063\:3066\:6a5f\:5bc6\:5909\:6570\:306b\:4f9d\:5b58\:3059\:308b\:30bb\:30eb\:306b\n" <>
  "NBMarkCellDependent \:3092\:9069\:7528\:3057\:3001\:65b0\:305f\:306b\:30de\:30fc\:30af\:3057\:305f\:30bb\:30eb\:6570\:3092\:8fd4\:3059\:3002\n" <>
  "NBScanDependentCells[nb, confVarNames, deps] \:306f\:4e8b\:524d\:8a08\:7b97\:6e08\:307f\:306e\:4f9d\:5b58\:30b0\:30e9\:30d5 deps \:3092\:4f7f\:3046\:ff08\:4e8c\:91cd\:8a08\:7b97\:56de\:907f\:ff09\:3002\n" <>
  "Claude\:95a2\:6570\:547c\:3073\:51fa\:3057\:30bb\:30eb (ClaudeQuery \:7b49) \:306f\:9664\:5916\:3055\:308c\:308b\:3002";

NBFilterHistoryEntry::usage =
  "NBFilterHistoryEntry[entry, confVars] \:306f\:5c65\:6b74\:30a8\:30f3\:30c8\:30ea\:5185\:306e response/instruction \:306b\:73fe\:6642\:70b9\:306e\:6a5f\:5bc6\:5909\:6570\:540d\:307e\:305f\:306f\:5024\:304c\:542b\:307e\:308c\:308b\:5834\:5408\:306b\n" <>
  "\:305d\:306e\:30d5\:30a3\:30fc\:30eb\:30c9\:3092\:30d6\:30ed\:30c3\:30af\:3059\:308b\:3002confVars \:306f\:73fe\:5728\:306e\:6a5f\:5bc6\:5909\:6570\:540d\:30ea\:30b9\:30c8\:3002";

NBDependencyEdges::usage =
  "NBDependencyEdges[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:5909\:6570\:4f9d\:5b58\:95a2\:4fc2\:3092\:30a8\:30c3\:30b8\:30ea\:30b9\:30c8\:3067\:8fd4\:3059\:3002\n" <>
  "\:623b\:308a\:5024: {DirectedEdge[\"dep\", \"var\"], ...}\n" <>
  "\"dep\" \[RightArrow] \"var\" \:306f \"var \:304c dep \:306b\:4f9d\:5b58\:3059\:308b\" \:3092\:610f\:5473\:3059\:308b\:3002\n" <>
  "NBDependencyEdges[nb, confVars] \:306f\:6a5f\:5bc6\:5909\:6570 confVars \:306b\:95a2\:9023\:3059\:308b\:30a8\:30c3\:30b8\:306e\:307f\:8fd4\:3059\:3002";

NBDebugDependencies::usage =
  "NBDebugDependencies[nb, confVars] \:306f\:4f9d\:5b58\:30b0\:30e9\:30d5\:30fb\:63a8\:79fb\:4f9d\:5b58\:30fb\:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:3092 Print \:3067\:8868\:793a\:3059\:308b\:30c7\:30d0\:30c3\:30b0\:95a2\:6570\:3002\n" <>
  "\:5404 Input \:30bb\:30eb\:306b\:3064\:3044\:3066 InputText \:53d6\:5f97\:7d50\:679c\:3001\:4ee3\:5165\:89e3\:6790\:7d50\:679c\:3001\:4f9d\:5b58\:5224\:5b9a\:7d50\:679c\:3092\:51fa\:529b\:3059\:308b\:3002";

NBPlotDependencyGraph::usage =
  "NBPlotDependencyGraph[] \:306f\:5168\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:7d71\:5408\:306e\:4f9d\:5b58\:30b0\:30e9\:30d5\:3092\:30d7\:30ed\:30c3\:30c8\:3059\:308b (\:30c7\:30d5\:30a9\:30eb\:30c8)\:3002\n" <>
  "NBPlotDependencyGraph[nb] \:306f\:6307\:5b9a\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:4f9d\:5b58\:30b0\:30e9\:30d5\:3092\:30d7\:30ed\:30c3\:30c8\:3059\:308b\:3002\n" <>
  "\:30ce\:30fc\:30c9\:306f\:5909\:6570\:540d\:30fbOut[n]\:3067\:3001\:76f4\:63a5\:79d8\:5bc6\:306f\:8d64\:3001\:4f9d\:5b58\:79d8\:5bc6\:306f\:6a59\:3067\:7740\:8272\:3002\n" <>
  "NB\:5185\:30a8\:30c3\:30b8\:306f\:6fc3\:3044\:5b9f\:7dda\:3001\:30af\:30ed\:30b9NB\:30a8\:30c3\:30b8\:306f\:8584\:3044\:7834\:7dda\:3067\:63cf\:753b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"Scope\" -> \"Global\" (\:30c7\:30d5\:30a9\:30eb\:30c8) | \"Local\"\n" <>
  "  PrivacySpec -> <|\"AccessLevel\" -> 1.0|> \:3067\:8868\:793a\:7bc4\:56f2\:3092\:5236\:5fa1\:3002\n" <>
  "\:4f8b: NBPlotDependencyGraph[EvaluationNotebook[], \"Scope\" -> \"Local\"]";

(* ---- \:95a2\:6570\:5b9a\:7fa9\:89e3\:6790 ---- *)
NBGetFunctionGlobalDeps::usage =
  "NBGetFunctionGlobalDeps[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:306e\:5168\:95a2\:6570\:5b9a\:7fa9\:3092\:89e3\:6790\:3057\:3001\n" <>
  "\:5404\:95a2\:6570\:304c\:4f9d\:5b58\:3057\:3066\:3044\:308b\:5927\:57df\:5909\:6570\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "\:623b\:308a\:5024: <|\"\:95a2\:6570\:540d\" -> {\"\:5927\:57df\:5909\:65701\", ...}, ...|>\n" <>
  "\:30d1\:30bf\:30fc\:30f3\:5909\:6570\:3068\:30b9\:30b3\:30fc\:30d4\:30f3\:30b0\:5c40\:6240\:5909\:6570 (Module/Block/With/Function) \:306f\:9664\:5916\:3055\:308c\:308b\:3002";

(* ---- \:30ce\:30fc\:30c8\:30d6\:30c3\:30af TaggingRules API ---- *)
NBGetTaggingRule::usage =
  "NBGetTaggingRule[nb, key] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:304b\:3089 key \:306e\:5024\:3092\:8fd4\:3059\:3002\n" <>
  "NBGetTaggingRule[nb, {key1, key2, ...}] \:306f\:30cd\:30b9\:30c8\:3057\:305f\:30d1\:30b9\:3092\:6307\:5b9a\:53ef\:80fd\:3002\n" <>
  "\:30ad\:30fc\:304c\:5b58\:5728\:3057\:306a\:3044\:5834\:5408\:306f Missing[] \:3092\:8fd4\:3059\:3002";

NBSetNotebookDefaultModel::usage =
  "NBSetNotebookDefaultModel[nb, provider, modelName] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30c7\:30d5\:30a9\:30eb\:30c8\:30e2\:30c7\:30eb\n" <>
  "(claudecode \:30d1\:30ec\:30c3\:30c8\:8a2d\:5b9a paletteProvider/paletteModelName) \:3092\:66f8\:304d\:63db\:3048\:308b\:3002\n" <>
  "NBAccess \:4ee5\:5916\:304c\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:90e8\:30c7\:30fc\:30bf\:3092\:66f8\:304d\:63db\:3048\:306a\:3044\:539f\:5247\:306b\:5f93\:3044\:66f8\:304d\:8fbc\:307f\:306f NBAccess \:304c\:884c\:3046\:3002";

NBGetNotebookDefaultModel::usage =
  "NBGetNotebookDefaultModel[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30c7\:30d5\:30a9\:30eb\:30c8\:30e2\:30c7\:30eb {provider, modelName} \:3092\:8fd4\:3059\:3002\:672a\:8a2d\:5b9a\:306a\:3089 Missing[\"NotDeclared\"]\:3002";

NBSetTaggingRule::usage =
  "NBSetTaggingRule[nb, key, value] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:306b key -> value \:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "NBSetTaggingRule[nb, {key1, key2}, value] \:306f\:30cd\:30b9\:30c8\:3057\:305f\:30d1\:30b9\:3092\:6307\:5b9a\:53ef\:80fd\:3002";

NBDeleteTaggingRule::usage =
  "NBDeleteTaggingRule[nb, key] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:304b\:3089 key \:3092\:524a\:9664\:3059\:308b\:3002";

NBListTaggingRuleKeys::usage =
  "NBListTaggingRuleKeys[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:306e\:5168\:30ad\:30fc\:3092\:8fd4\:3059\:3002\n" <>
  "NBListTaggingRuleKeys[nb, prefix] \:306f prefix \:3067\:59cb\:307e\:308b\:30ad\:30fc\:306e\:307f\:8fd4\:3059\:3002";

(* ---- \:6c4e\:7528\:5c65\:6b74\:30c7\:30fc\:30bf\:30d9\:30fc\:30b9 API ---- *)
NBHistoryData::usage =
  "NBHistoryData[nb, tag] \:306f TaggingRules \:304b\:3089\:5c65\:6b74\:30c7\:30fc\:30bf\:3092\:8aad\:307f\:53d6\:308a\:3001\n" <>
  "\:5dee\:5206\:5727\:7e2e\:3055\:308c\:305f\:30a8\:30f3\:30c8\:30ea\:3092\:5fa9\:5143\:3057\:3066\:8fd4\:3059\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3 Decompress -> False \:3067 Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:306e\:307e\:307e\:8fd4\:3059\:3002\n" <>
  "\:623b\:308a\:5024: <|\"header\" -> <|...|>, \"entries\" -> {<|...|>, ...}|>";

NBHistoryRawData::usage =
  "NBHistoryRawData[nb, tag] \:306f\:5dee\:5206\:5727\:7e2e\:3092\:89e3\:9664\:305b\:305a\:306b\:5c65\:6b74\:30c7\:30fc\:30bf\:3092\:8fd4\:3059 (\:5185\:90e8\:7528)\:3002";

NBHistorySetData::usage =
  "NBHistorySetData[nb, tag, data] \:306f TaggingRules \:306b\:5c65\:6b74\:30c7\:30fc\:30bf\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "data \:306f <|\"header\" -> ..., \"entries\" -> {...}|> \:306e\:5f62\:5f0f\:3002\n" <>
  "entries \:306f\:5dee\:5206\:5727\:7e2e\:3055\:308c\:3066\:3044\:306a\:3044\:5e73\:6587\:3067\:6e21\:3059\:3053\:3068\:3002\:81ea\:52d5\:7684\:306b\:5727\:7e2e\:3055\:308c\:308b\:3002";

NBHistoryAppend::usage =
  "NBHistoryAppend[nb, tag, entry] \:306f\:30a8\:30f3\:30c8\:30ea\:3092\:5c65\:6b74\:306b\:8ffd\:52a0\:3059\:308b\:3002\n" <>
  "\:5dee\:5206\:5727\:7e2e: \:76f4\:524d\:306e\:30a8\:30f3\:30c8\:30ea\:306e fullPrompt/response/code \:3092 Diff \:3067\:5727\:7e2e\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3 PrivacySpec -> ps \:3067 privacylevel \:3092\:30a8\:30f3\:30c8\:30ea\:306b\:8a18\:9332\:3002";

NBHistoryEntries::usage =
  "NBHistoryEntries[nb, tag] \:306f\:5dee\:5206\:5727\:7e2e\:3092\:5fa9\:5143\:3057\:305f\:5168\:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3 Decompress -> False \:3067 Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:306e\:307e\:307e\:8fd4\:3059\:3002";

NBHistoryUpdateLast::usage =
  "NBHistoryUpdateLast[nb, tag, updates] \:306f\:6700\:5f8c\:306e\:30a8\:30f3\:30c8\:30ea\:3092\:66f4\:65b0\:3059\:308b\:3002\n" <>
  "updates \:306f <|\"response\" -> ..., \"code\" -> ..., ...|> \:306e\:5f62\:5f0f\:3002";

NBHistoryReadHeader::usage =
  "NBHistoryReadHeader[nb, tag] \:306f\:5c65\:6b74\:306e\:30d8\:30c3\:30c0\:30fc Association \:3092\:8fd4\:3059\:3002";

NBHistoryWriteHeader::usage =
  "NBHistoryWriteHeader[nb, tag, header] \:306f\:5c65\:6b74\:306e\:30d8\:30c3\:30c0\:30fc\:3092\:66f8\:304d\:8fbc\:3080\:3002";

NBHistoryEntriesWithInherit::usage =
  "NBHistoryEntriesWithInherit[nb, tag] \:306f\:89aa\:5c65\:6b74\:3092\:542b\:3080\:5168\:30a8\:30f3\:30c8\:30ea\:3092\:8fd4\:3059\:3002\n" <>
  "header \:306e parent/inherit/created \:306b\:5f93\:3063\:3066\:89aa\:30c1\:30a7\:30fc\:30f3\:3092\:8fbf\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3 Decompress -> False \:3067 Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:306e\:307e\:307e\:8fd4\:3059\:3002";

NBHistoryListTags::usage =
  "NBHistoryListTags[nb, prefix] \:306f prefix \:3067\:59cb\:307e\:308b\:5c65\:6b74\:30bf\:30b0\:4e00\:89a7\:3092\:8fd4\:3059\:3002";

NBHistoryDelete::usage =
  "NBHistoryDelete[nb, tag] \:306f\:6307\:5b9a\:30bf\:30b0\:306e\:5c65\:6b74\:3092 TaggingRules \:304b\:3089\:524a\:9664\:3059\:308b\:3002";

NBHistoryReplaceEntries::usage =
  "NBHistoryReplaceEntries[nb, tag, entries] \:306f\:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8\:5168\:4f53\:3092\:7f6e\:63db\:3059\:308b\:3002\n" <>
  "\:30b3\:30f3\:30d1\:30af\:30b7\:30e7\:30f3\:3084\:30d0\:30c3\:30c1\:66f4\:65b0\:306b\:4f7f\:7528\:3059\:308b\:3002";

NBHistoryUpdateHeader::usage =
  "NBHistoryUpdateHeader[nb, tag, updates] \:306f\:30d8\:30c3\:30c0\:30fc\:306b\:30ad\:30fc\:3092\:8ffd\:52a0\:30fb\:66f4\:65b0\:3059\:308b\:3002\n" <>
  "\:65e2\:5b58\:30ad\:30fc\:306f\:4e0a\:66f8\:304d\:3001\:65b0\:898f\:30ad\:30fc\:306f\:8ffd\:52a0\:3055\:308c\:308b\:3002";

NBHistoryCreate::usage =
  "NBHistoryCreate[nb, tag, diffFields] \:306f\:65b0\:3057\:3044\:5c65\:6b74\:30c7\:30fc\:30bf\:30d9\:30fc\:30b9\:3092\:4f5c\:6210\:3059\:308b\:3002\n" <>
  "diffFields \:306f\:5dee\:5206\:5727\:7e2e\:5bfe\:8c61\:306e\:30d5\:30a3\:30fc\:30eb\:30c9\:540d\:30ea\:30b9\:30c8 (\:4f8b: {\"fullPrompt\", \"response\", \"code\"})\:3002\n" <>
  "NBHistoryCreate[nb, tag, diffFields, headerOverrides] \:3067\:30d8\:30c3\:30c0\:30fc\:3092\:4e0a\:66f8\:304d\:53ef\:80fd\:3002\n" <>
  "\:65e2\:5b58 DB \:306b diffFields \:304c\:3042\:308b\:5834\:5408\:306f\:65e2\:5b58\:30d8\:30c3\:30c0\:30fc\:3092\:8fd4\:3059 (\:51aa\:7b49)\:3002";

(* ---- \:30bb\:30c3\:30b7\:30e7\:30f3\:30a2\:30bf\:30c3\:30c1\:30e1\:30f3\:30c8 API ---- *)
NBHistoryAddAttachment::usage =
  "NBHistoryAddAttachment[nb, tag, path] \:306f\:30bb\:30c3\:30b7\:30e7\:30f3\:306b\:30d5\:30a1\:30a4\:30eb\:3092\:30a2\:30bf\:30c3\:30c1\:3059\:308b\:3002\n" <>
  "\:30d8\:30c3\:30c0\:30fc\:306e \"attachments\" \:30ea\:30b9\:30c8\:306b\:30d1\:30b9\:3092\:8ffd\:52a0 (\:91cd\:8907\:9664\:53bb)\:3002";

NBHistoryRemoveAttachment::usage =
  "NBHistoryRemoveAttachment[nb, tag, path] \:306f\:30bb\:30c3\:30b7\:30e7\:30f3\:304b\:3089\:30d5\:30a1\:30a4\:30eb\:3092\:30c7\:30bf\:30c3\:30c1\:3059\:308b\:3002";

NBHistoryGetAttachments::usage =
  "NBHistoryGetAttachments[nb, tag] \:306f\:30bb\:30c3\:30b7\:30e7\:30f3\:306e\:30a2\:30bf\:30c3\:30c1\:30e1\:30f3\:30c8\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002";

NBHistoryClearAttachments::usage =
  "NBHistoryClearAttachments[nb, tag] \:306f\:30bb\:30c3\:30b7\:30e7\:30f3\:306e\:5168\:30a2\:30bf\:30c3\:30c1\:30e1\:30f3\:30c8\:3092\:30af\:30ea\:30a2\:3059\:308b\:3002";

NBHistoryClearAll::usage =
  "NBHistoryClearAll[nb, prefix, PrivacySpec -> ps] \:306f prefix \:3067\:59cb\:307e\:308b\:5168\:5c65\:6b74\:3092\:524a\:9664\:3059\:308b\:3002\n" <>
  "PrivacySpec -> <|\"AccessLevel\" -> 1.0|> \:304c\:5fc5\:9808\:3002\n" <>
  "\:30bb\:30eb\:30ec\:30d9\:30eb\:306e\:6a5f\:5bc6\:30fb\:6a5f\:5bc6\:4f9d\:5b58\:30bf\:30b0\:306f\:524a\:9664\:3057\:306a\:3044\:3002\n" <>
  "\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:4ed6\:8005\:306b\:6e21\:3059\:969b\:306e\:5c65\:6b74\:60c5\:5831\:9664\:53bb\:7528\:3002";

(* ---- API \:30ad\:30fc\:30a2\:30af\:30bb\:30b5\:30fc ---- *)
NBGetAPIKey::usage =
  "NBGetAPIKey[provider] \:306f AI \:30d7\:30ed\:30d0\:30a4\:30c0\:306e API \:30ad\:30fc\:3092\:8fd4\:3059\:3002\n" <>
  "provider: \"anthropic\" | \"openai\" | \"github\"\n" <>
  "AccessLevel >= 1.0 \:304c\:5fc5\:9808\:3002\:547c\:3073\:51fa\:3057\:5074\:3067 PrivacySpec -> <|\"AccessLevel\" -> 1.0|> \:3092\:660e\:793a\:6307\:5b9a\:3059\:308b\:3053\:3068\:3002\n" <>
  "SystemCredential \:3078\:306e\:30a2\:30af\:30bb\:30b9\:3092\:4e00\:5143\:7ba1\:7406\:3059\:308b\:3002";

NBListProviderModels::usage =
  "NBListProviderModels[provider] \:306f\:30af\:30e9\:30a6\:30c9\:30d7\:30ed\:30d0\:30a4\:30c0 (anthropic / openai) \:306e\n" <>
  "\:5229\:7528\:53ef\:80fd\:30e2\:30c7\:30eb ID \:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002API \:30ad\:30fc\:306f\:5185\:90e8\:3067 SystemCredential \:304b\:3089\:8aad\:307f\:3001\n" <>
  "\:5916\:90e8\:306b\:306f\:51fa\:3055\:306a\:3044\:3002\:8fd4\:3059\:306e\:306f\:30e2\:30c7\:30eb\:540d\:30ea\:30b9\:30c8 (\:79d8\:533f\:6027\:306a\:3057) \:3060\:3051\:306a\:306e\:3067\:3001\n" <>
  "PrivacySpec / AccessLevel \:306e\:6307\:5b9a\:306f\:4e0d\:8981\:3002\:4e00\:822c\:30d1\:30c3\:30b1\:30fc\:30b8 (SourceVault \:7b49) \:304b\:3089\n" <>
  "API \:30ad\:30fc\:3092\:76f4\:63a5\:8aad\:307e\:305a\:306b\:30e2\:30c7\:30eb\:4e00\:89a7\:3092\:53d6\:5f97\:3059\:308b\:305f\:3081\:306e\:516c\:958b\:95a2\:6570\:3002\n" <>
  "provider: \"anthropic\" | \"openai\"\:3002\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> _, \"Provider\" -> _, \"Models\" -> {_String..}|>\:3002";

(* ---- \:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:30fc\:306e API \:30ad\:30fc\:30a2\:30af\:30bb\:30b5\:30fc ---- *)
NBGetLocalLLMAPIKey::usage =
  "NBGetLocalLLMAPIKey[provider, url] \:306f \:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:30fc (LM Studio \:7b49) \:306e\n" <>
  "API \:30ad\:30fc\:3092 SystemCredential \:304b\:3089\:8fd4\:3059\:3002\:7167\:5408\:306f {provider, url} \:30da\:30a2\:3002\n" <>
  "\:4f8b: NBGetLocalLLMAPIKey[\"lmstudio\", \"http://127.0.0.1:1234\"]\n" <>
  "AccessLevel >= 1.0 \:304c\:5fc5\:9808\:3002PrivacySpec -> <|\"AccessLevel\"->1.0|> \:3092\:660e\:793a\:6307\:5b9a\:3059\:308b\:3053\:3068\:3002\n" <>
  "\:89e3\:6c7a\:512a\:5148\:5ea6: (1) \:5b8c\:5168\:4e00\:81f4 (2) localhost\[LeftRightArrow]127.0.0.1 \:7f6e\:63db\:7248 (3) \{provider, \"*\"\} \:30ef\:30a4\:30eb\:30c9\:30ab\:30fc\:30c9 (4) \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:540d ToUpperCase[provider]<>\"_API_KEY\"\:3002";

NBSetLocalLLMAPIKey::usage =
  "NBSetLocalLLMAPIKey[provider, url, credentialName] \:306f\:3001{provider, url} \[RightArrow] credentialName \:306e\n" <>
  "\:30de\:30c3\:30d4\:30f3\:30b0\:3092\:767b\:9332\:3059\:308b\:3002SystemCredential \:306e\:5b9f\:5024\:81ea\:4f53\:306f\:66f8\:304d\:8fbc\:307e\:306a\:3044 (\:540d\:524d\:306e\:7d10\:4ed8\:3051\:306e\:307f)\:3002\n" <>
  "\:4f8b: NBSetLocalLLMAPIKey[\"lmstudio\", \"http://192.168.1.10:1234\", \"LMSTUDIO_STUDY_KEY\"]\n" <>
  "\:8fd4\:308a\:5024: {provider, normalizedUrl} -> credentialName \:306e Rule\:3002";

NBStoreLocalLLMAPIKey::usage =
  "NBStoreLocalLLMAPIKey[provider, url, credentialName, key] \:306f\:4e0a\:8a18\:30de\:30c3\:30d4\:30f3\:30b0\:767b\:9332\:306b\:52a0\:3048\:3066\n" <>
  "SystemCredential[credentialName] = key \:3082\:540c\:6642\:306b\:8a2d\:5b9a\:3059\:308b\:3002\:521d\:56de\:30bb\:30c3\:30c8\:30a2\:30c3\:30d7\:7528\:3002";

NBRemoveLocalLLMAPIKey::usage =
  "NBRemoveLocalLLMAPIKey[provider, url] \:306f {provider, url} \:306e\:30a8\:30f3\:30c8\:30ea\:3092\:524a\:9664\:3059\:308b\:3002\n" <>
  "SystemCredential \:672c\:4f53\:306f\:5909\:66f4\:3057\:306a\:3044\:3002";

NBLocalLLMAPIKeyMap::usage =
  "NBLocalLLMAPIKeyMap[] \:306f\:73fe\:5728\:767b\:9332\:3055\:308c\:3066\:3044\:308b\:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:30fc\[RightArrow]API\:30ad\:30fc\:540d\:30de\:30c3\:30d4\:30f3\:30b0\:3092\n" <>
  "Dataset \:3067\:8fd4\:3059\:3002Configured \:5217\:306f SystemCredential \:304c\:5b9f\:969b\:306b\:8a2d\:5b9a\:6e08\:307f\:304b\:3069\:3046\:304b\:3092\:793a\:3059\:3002";

NBLocalLLMCredentialName::usage =
  "NBLocalLLMCredentialName[provider, url] \:306f SystemCredential \:540d\:306e\:307f\:3092\:8fd4\:3059 (\:5024\:306f\:53d6\:5f97\:3057\:306a\:3044)\:3002\n" <>
  "AccessLevel \:30c1\:30a7\:30c3\:30af\:306a\:3057\:3002\:767b\:9332\:78ba\:8a8d\:7528\:3002";

(* ---- \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb / \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb API ---- *)
NBSetFallbackModels::usage =
  "NBSetFallbackModels[models] \:306f\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:30ea\:30b9\:30c8\:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "models: {{\"provider\",\"model\"}, {\"provider\",\"model\",\"url\"}, ...}\n" <>
  "\:4f8b: NBSetFallbackModels[{{\"anthropic\",\"claude-opus-4-6\"},{\"lmstudio\",\"gpt-oss-20b\",\"http://127.0.0.1:1234\"}}]";

NBRegisterTrustedLocalServer::usage =
  "NBRegisterTrustedLocalServer[assoc] \:306f\:4fe1\:983c\:3067\:304d\:308b\:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:3092\:767b\:9332\:3059\:308b\:3002\n" <>
  "assoc: <|\"MachineName\" -> _, \"Subnet\" -> _, \"Provider\" -> _, \"URL\" -> _|>\:3002\n" <>
  "IP / \:30b5\:30d6\:30cd\:30c3\:30c8\:306f\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:5883\:754c\:306a\:306e\:3067 NBAccess \:304c\:7ba1\:7406\:3059\:308b\:3002\:30e2\:30c7\:30eb\:540d (Qwen \:306e\:679d\:756a\:7b49) \:306f\n" <>
  "\:542b\:3081\:306a\:3044 (\:305d\:308c\:306f SourceVault \:304c intent \:89e3\:6c7a\:3067\:6271\:3046)\:3002\:8d77\:52d5\:30d5\:30a1\:30a4\:30eb\:304b\:3089\:547c\:3093\:3067\:4fe1\:983c\:30ea\:30b9\:30c8\:306b\:8ffd\:52a0\:3059\:308b\:3002\n" <>
  "\:4f8b: NBRegisterTrustedLocalServer[<|\"MachineName\"->\"phoenix\", \"Subnet\"->\"192.168.2\", \"Provider\"->\"lmstudio\", \"URL\"->\"http://192.168.2.110:1234\"|>]";

NBResolveLocalServer::usage =
  "NBResolveLocalServer[] \:306f\:73fe\:5728\:306e\:30de\:30b7\:30f3\:74b0\:5883 ($MachineName \:3068\:81ea IP \:306e\:30b5\:30d6\:30cd\:30c3\:30c8) \:3092\:4fe1\:983c\:30ea\:30b9\:30c8\:3068\n" <>
  "\:7167\:5408\:3057\:3001\:4fe1\:983c\:3067\:304d\:308b\:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0 <|\"Provider\" -> _, \"URL\" -> _, \"Trusted\" -> _, ...|> \:3092\:8fd4\:3059\:3002\n" <>
  "\:672a\:77e5\:306e\:30b5\:30d6\:30cd\:30c3\:30c8 (\:4fe1\:983c\:30ea\:30b9\:30c8\:306b\:7121\:3044) \:3067\:306f\:5b89\:5168\:5074\:306b\:5012\:3057\:3001localhost (127.0.0.1) \:306e\:30ed\:30fc\:30ab\:30eb\:30b5\:30fc\:30d0\:306e\:307f\:3092\:8fd4\:3059\:3002\n" <>
  "\:30ea\:30e2\:30fc\:30c8 IP \:306e LM Studio \:306b\:306f\:4fe1\:983c\:30b5\:30d6\:30cd\:30c3\:30c8\:5185\:3067\:306e\:307f\:63a5\:7d9a\:3059\:308b\:3002\:30e2\:30c7\:30eb\:540d\:306f\:8fd4\:3055\:306a\:3044 (SourceVault \:304c\:89e3\:6c7a)\:3002";

NBTrustedLocalServers::usage =
  "NBTrustedLocalServers[] \:306f\:73fe\:5728\:767b\:9332\:3055\:308c\:3066\:3044\:308b\:4fe1\:983c\:30ed\:30fc\:30ab\:30eb\:30b5\:30fc\:30d0\:306e\:30ea\:30b9\:30c8 (Dataset) \:3092\:8fd4\:3059\:3002";

NBSyncClaudeModelVars::usage =
  "NBSyncClaudeModelVars[opts] \:306f SourceVault \:306b\:30ad\:30e3\:30c3\:30b7\:30e5\:3055\:308c\:3066\:3044\:308b\:30e2\:30c7\:30eb\:3067\n" <>
  "ClaudeCode \:306e $ClaudeModel / $ClaudeDocModel / $ClaudePrivateModel / $ClaudeFallbackModels \:3092\n" <>
  "\:66f4\:65b0\:3059\:308b\:3002SourceVault \:304c intent \:5272\:308a\:5f53\:3066\:30de\:30c3\:30d7 (SourceVaultModelIntentMap) \:3092\:4fdd\:6301\:3057\:3001\n" <>
  "NBAccess \:304c\:305d\:308c\:3092\:8aad\:307f\:53d6\:3063\:3066 SourceVaultResolve \:3067\:30e2\:30c7\:30eb ID \:306b\:89e3\:6c7a\:3057\:3001\:30ed\:30fc\:30ab\:30eb\:30b5\:30fc\:30d0\:306e\n" <>
  "URL \:306f NBResolveLocalServer \:3067\:5b89\:5168\:306b\:89e3\:6c7a\:3057\:3066\:5b9f\:5909\:6570\:3078\:4ee3\:5165\:3059\:308b\:3002\:30e2\:30c7\:30eb\:5909\:6570\:306e\:4ee3\:5165\:306f\n" <>
  "\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:60c5\:5831 ($ClaudePrivateModel \:306e URL) \:3092\:542b\:3080\:305f\:3081\:3001\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:5883\:754c\:3092\:7ba1\:7406\:3059\:308b\n" <>
  "NBAccess \:306b\:4e00\:5143\:5316\:3059\:308b\:3002SourceVault \:304c\:672a\:30ed\:30fc\:30c9\:306a\:3089\:4f55\:3082\:3057\:306a\:3044 (claudecode \:5358\:4f53\:306e\:5f8c\:65b9\:4e92\:63db)\:3002\n" <>
  "SourceVault \:30ed\:30fc\:30c9\:6642\:306b\:81ea\:52d5\:5b9f\:884c\:3055\:308c\:308b\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: Verbose (\:65e2\:5b9a False)\:3002";

NBGetFallbackModels::usage =
  "NBGetFallbackModels[] \:306f\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:30ea\:30b9\:30c8\:5168\:4f53\:3092\:8fd4\:3059\:3002";

NBSetProviderMaxAccessLevel::usage =
  "NBSetProviderMaxAccessLevel[provider, level] \:306f\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:306e\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "level: 0.0\:301c1.0\:3002\:3053\:306e\:30ec\:30d9\:30eb\:3092\:8d85\:3048\:308b\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306e\:30ea\:30af\:30a8\:30b9\:30c8\:306b\:306f\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3057\:306a\:3044\:3002\n" <>
  "\:4f8b: NBSetProviderMaxAccessLevel[\"anthropic\", 0.5]\n" <>
  "    NBSetProviderMaxAccessLevel[\"lmstudio\", 1.0]";

NBGetProviderMaxAccessLevel::usage =
  "NBGetProviderMaxAccessLevel[provider] \:306f\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:306e\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3092\:8fd4\:3059\:3002\n" <>
  "\:672a\:767b\:9332\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:306f 0.5 \:3092\:8fd4\:3059\:3002";

NBGetAvailableFallbackModels::usage =
  "NBGetAvailableFallbackModels[accessLevel] \:306f\:6307\:5b9a\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3067\:5229\:7528\:53ef\:80fd\:306a\n" <>
  "\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:306e MaxAccessLevel >= accessLevel \:306e\:30e2\:30c7\:30eb\:306e\:307f\:542b\:307e\:308c\:308b\:3002\n" <>
  "\:4f8b: NBGetAvailableFallbackModels[0.8] \[RightArrow] lmstudio \:306e\:307f\n" <>
  "    NBGetAvailableFallbackModels[0.5] \[RightArrow] \:5168\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc";

NBProviderCanAccess::usage =
  "NBProviderCanAccess[provider, accessLevel] \:306f\:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:304c\:6307\:5b9a\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306e\n" <>
  "\:30c7\:30fc\:30bf\:306b\:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:304b\:3092\:8fd4\:3059 (True/False)\:3002\n" <>
  "MaxAccessLevel >= accessLevel \:306a\:3089 True\:3002";

NBModelCanHandleAccessLevel::usage =
  "NBModelCanHandleAccessLevel[modelSpec, accessLevel] \:306f\:30e2\:30c7\:30eb\:6307\:5b9a\:304c\:305d\:306e\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306e\n" <>
  "\:30c7\:30fc\:30bf\:3092\:6271\:3048\:308b\:304b\:3092\:8fd4\:3059 (True/False)\:3002Private \:30ce\:30fc\:30c8 (\:30ec\:30d9\:30eb 1.0) \:3067\:30af\:30e9\:30a6\:30c9\:30e2\:30c7\:30eb\n" <>
  "(claudecode/anthropic/openai = 0.5) \:3092\:62d2\:5426\:3057\:3001\:30ed\:30fc\:30ab\:30eb LLM (lmstudio = 1.0) \:306e\:307f\:901a\:3059\:305f\:3081\:306b\:4f7f\:3046\:3002\n" <>
  "modelSpec: {provider, model} | {provider, model, url} | \"model\" | Automatic (\:672a\:6307\:5b9a\:306f True)\:3002";

NBModelProviderName::usage =
  "NBModelProviderName[modelSpec] \:306f modelSpec \:304b\:3089 provider \:6587\:5b57\:5217\:3092\:53d6\:308a\:51fa\:3059\:3002";

NBNotebookRequiredAccessLevel::usage =
  "NBNotebookRequiredAccessLevel[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:8981\:6c42\:3059\:308b\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3092\:8fd4\:3059\:3002\n" <>
  "Private \:5ba3\:8a00 (CloudPublishable -> False) \:306a\:3089 1.0 (\:30af\:30e9\:30a6\:30c9\:7981\:6b62)\:3001\:305d\:308c\:4ee5\:5916\:306f 0.0\:3002";

(* ---- \:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea API ---- *)
NBSetAccessibleDirs::usage =
  "NBSetAccessibleDirs[nb, {dir1, dir2, ...}] \:306f Claude Code \:304c\n" <>
  "\:53c2\:7167\:53ef\:80fd\:306a\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:30ea\:30b9\:30c8\:3092 TaggingRules \:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "NBSetAccessibleDirs[{dir1, dir2, ...}] \:306f EvaluationNotebook[] \:306b\:4fdd\:5b58\:3059\:308b\:3002";

NBGetAccessibleDirs::usage =
  "NBGetAccessibleDirs[nb] \:306f\:4fdd\:5b58\:3055\:308c\:305f\:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "NBGetAccessibleDirs[] \:306f EvaluationNotebook[] \:304b\:3089\:53d6\:5f97\:3059\:308b\:3002";

NBResolvePathRef::usage =
  "NBResolvePathRef[pathRef] \:306f PathRef (NBNormalizePath \:304c\:8fd4\:3059 Association\:3001\:307e\:305f\:306f {\"$onWork\", ...} \:5f62\:5f0f\:306e\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:30ea\:30b9\:30c8) \:3092\:73fe PC \:306e\:5b9f\:30d1\:30b9\:3078\:89e3\:6c7a\:3059\:308b\:3002\n" <>
  "\:73fe PC \:3067\:89e3\:6c7a\:3067\:304d\:5b9f\:5728\:3059\:308c\:3070\:7d76\:5bfe\:30d1\:30b9\:6587\:5b57\:5217\:3001\:89e3\:6c7a\:3067\:304d\:306a\:3044 (\:30eb\:30fc\:30c8\:672a\:5b9a\:7fa9\:30fb\:5225 PC \:30a8\:30a4\:30ea\:30a2\:30b9\:306e\:307f) \:306a\:3089 Missing[...] \:3092\:8fd4\:3059\:3002\n" <>
  "SourceVault \:304c\:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089 iSVResolvePath \:3092\:5229\:7528\:3059\:308b\:3002\n" <>
  "rule 104: alias-only / root-missing \:306a PathRef \:306f\:5b9f\:30d1\:30b9\:306b\:89e3\:6c7a\:3055\:308c\:306a\:3044\:3002settings.json \:3078\:306e materialize \:306b\:306f\:89e3\:6c7a\:3067\:304d\:305f\:3082\:306e\:3060\:3051\:3092\:4f7f\:3046\:3002";

NBSetAccessiblePathRefs::usage =
  "NBSetAccessiblePathRefs[nb, refs] \:306f AccessPathRef \:306e\:30ea\:30b9\:30c8\:3092 notebook \:306e TaggingRules (claudeAccessiblePathRefs) \:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "NBSetAccessiblePathRefs[refs] \:306f EvaluationNotebook[] \:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "\:5404 AccessPathRef \:306f <|\"PathRef\" -> _, \"Mode\" -> \"List\"|\"Read\"|\"ReadWrite\", \"CloudSend\" -> False|True|\"Ask\"|> \:306e Association\:3002\n" <>
  "Phase 2 \:3067\:306f claudeAccessiblePathRefs \:3092\:6b63\:672c (canonical) \:3068\:3059\:308b\:3002\:65e7 claudeAccessibleDirs \:306f read fallback \:3068\:3057\:3066\:306e\:307f\:6b8b\:3059\:3002\n" <>
  "rule 104: PathRef \:306f\:540c\:4e00\:6027\:3067\:3042\:308a\:3001\:4fdd\:5b58\:81ea\:4f53\:304c\:6a29\:9650\:3092\:4e0e\:3048\:308b\:3082\:306e\:3067\:306f\:306a\:3044\:3002";

NBGetAccessiblePathRefs::usage =
  "NBGetAccessiblePathRefs[nb] \:306f notebook \:306b\:4fdd\:5b58\:3055\:308c\:305f AccessPathRef \:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "NBGetAccessiblePathRefs[] \:306f EvaluationNotebook[] \:304b\:3089\:53d6\:5f97\:3059\:308b\:3002\n" <>
  "claudeAccessiblePathRefs \:304c\:7121\:3044\:65e7 notebook \:3067\:306f\:3001claudeAccessibleDirs (\:65e7\:5f62\:5f0f\:306e\:7d76\:5bfe\:30d1\:30b9\:30ea\:30b9\:30c8) \:3092 AccessPathRef \:306b\:5909\:63db\:3057\:3066\:8fd4\:3059 (read fallback)\:3002\n" <>
  "\:623b\:308a\:5024\:306f notebook \:306b\:6c38\:7d9a\:5316\:3059\:308b canonical \:306a\:53c2\:7167\:30ea\:30b9\:30c8\:3002\:5b9f\:30d1\:30b9\:3078\:306e\:89e3\:6c7a\:306f NBResolvePathRef / NBGetAccessibleDirs \:3067\:884c\:3046\:3002";

NBNormalizeAccessPathRef::usage =
  "NBNormalizeAccessPathRef[dirOrRef] \:306f\:3001\:65e7\:5f62\:5f0f\:306e\:7d76\:5bfe\:30d1\:30b9\:6587\:5b57\:5217\:307e\:305f\:306f\:90e8\:5206\:7684\:306a\:6307\:5b9a\:3092\:3001\:5b8c\:5168\:306a AccessPathRef Association \:306b\:6b63\:898f\:5316\:3059\:308b\:3002\n" <>
  "\:6587\:5b57\:5217\:304c\:6e21\:3055\:308c\:305f\:5834\:5408\:306f NBNormalizePath \:3067 PathRef \:5316\:3057\:3001Mode -> \"Read\"\:3001CloudSend -> \"Ask\" \:3092\:65e2\:5b9a\:3068\:3059\:308b\:3002\n" <>
  "\:65e2\:306b AccessPathRef Association \:306a\:3089\:4e0d\:8db3\:30ad\:30fc\:3092\:65e2\:5b9a\:3067\:88dc\:3046\:3002NBSetAccessibleDirs \:4e92\:63db\:30e9\:30c3\:30d1\:304c\:5185\:90e8\:3067\:4f7f\:3046\:3002";


NBMoveToEnd::usage =
  "NBMoveToEnd[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:672b\:5c3e\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5\:3059\:308b\:3002";

(* ---- Job \:7ba1\:7406 API: ClaudeQuery/ClaudeEval \:306e\:975e\:540c\:671f\:51fa\:529b\:4f4d\:7f6e\:7ba1\:7406 ---- *)
NBBeginJob::usage =
  "NBBeginJob[nb, evalCell] \:306f\:8a55\:4fa1\:30bb\:30eb\:306e\:76f4\:5f8c\:306b3\:3064\:306e\:4e0d\:53ef\:8996\:30b9\:30ed\:30c3\:30c8\:30bb\:30eb\:3092\:633f\:5165\:3057\:30b8\:30e7\:30d6ID\:3092\:8fd4\:3059\:3002\n" <>
  "evalCell \:304c CellObject \:3067\:306a\:3044\:5834\:5408\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e\:306b\:633f\:5165\:3059\:308b\:3002\n" <>
  "\:30b9\:30ed\:30c3\:30c81: \:30b7\:30b9\:30c6\:30e0\:30e1\:30c3\:30bb\:30fc\:30b8\:ff08\:30d7\:30ed\:30b0\:30ec\:30b9\:30fb\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:901a\:77e5\:ff09\n" <>
  "\:30b9\:30ed\:30c3\:30c82: \:5b8c\:4e86\:30e1\:30c3\:30bb\:30fc\:30b8\n" <>
  "\:30a2\:30f3\:30ab\:30fc: \:30ec\:30b9\:30dd\:30f3\:30b9\:66f8\:304d\:8fbc\:307f\:4f4d\:7f6e\:30de\:30fc\:30ab\:30fc";

NBWriteSlot::usage =
  "NBWriteSlot[jobId, slotIdx, cellExpr] \:306f\:30b8\:30e7\:30d6\:306e\:30b9\:30ed\:30c3\:30c8\:306b Cell \:5f0f\:3092\:66f8\:304d\:8fbc\:307f\:53ef\:8996\:306b\:3059\:308b\:3002\n" <>
  "\:540c\:3058\:30b9\:30ed\:30c3\:30c8\:306b\:518d\:5ea6\:66f8\:304d\:8fbc\:3080\:3068\:4e0a\:66f8\:304d\:3055\:308c\:308b\:3002";

NBJobMoveToAnchor::usage =
  "NBJobMoveToAnchor[jobId] \:306f\:30a2\:30f3\:30ab\:30fc\:30bb\:30eb\:306e\:76f4\:5f8c\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5\:3059\:308b\:3002\n" <>
  "\:30ec\:30b9\:30dd\:30f3\:30b9\:30b3\:30f3\:30c6\:30f3\:30c4\:306e\:66f8\:304d\:8fbc\:307f\:524d\:306b\:547c\:3076\:3002";

NBEndJob::usage =
  "NBEndJob[jobId] \:306f\:30b8\:30e7\:30d6\:3092\:6b63\:5e38\:7d42\:4e86\:3059\:308b\:3002\n" <>
  "\:672a\:66f8\:304d\:8fbc\:307f\:30b9\:30ed\:30c3\:30c8\:3068\:30a2\:30f3\:30ab\:30fc\:3092\:524a\:9664\:3057\:30c6\:30fc\:30d6\:30eb\:3092\:30af\:30ea\:30a2\:3059\:308b\:3002";

NBAbortJob::usage =
  "NBAbortJob[jobId, errorMsg] \:306f\:30a8\:30e9\:30fc\:30e1\:30c3\:30bb\:30fc\:30b8\:3092\:66f8\:304d\:8fbc\:307f\:30b8\:30e7\:30d6\:3092\:7d42\:4e86\:3059\:308b\:3002";



(* ---- \:5206\:96e2API: claudecode\:304b\:3089\:306e\:9593\:63a5\:30a2\:30af\:30bb\:30b9\:7528 ---- *)
NBBeginJobAtEvalCell::usage =
  "NBBeginJobAtEvalCell[nb] \:306f EvaluationCell[] \:3092\:5185\:90e8\:53d6\:5f97\:3057\:3066\:305d\:306e\:76f4\:5f8c\:306bJob \:30b9\:30ed\:30c3\:30c8\:3092\:633f\:5165\:3059\:308b\:3002\n" <>
  "claudecode \:304c CellObject \:3092\:4fdd\:6301\:3059\:308b\:5fc5\:8981\:304c\:306a\:3044\:3002";

NBExtractAssignments::usage =
  "NBExtractAssignments[text] \:306f\:30c6\:30ad\:30b9\:30c8\:304b\:3089 Set/SetDelayed \:306e LHS \:5909\:6570\:540d\:3092\:62bd\:51fa\:3059\:308b\:3002";

NBSetConfidentialVars::usage =
  "NBSetConfidentialVars[assoc] \:306f\:6a5f\:5bc6\:5909\:6570\:30c6\:30fc\:30d6\:30eb\:3092\:4e00\:62ec\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "assoc: <|\"varName\" -> True, ...|>";

NBGetConfidentialVars::usage =
  "NBGetConfidentialVars[] \:306f\:73fe\:5728\:306e\:6a5f\:5bc6\:5909\:6570\:30c6\:30fc\:30d6\:30eb\:3092\:8fd4\:3059\:3002";

NBClearConfidentialVars::usage =
  "NBClearConfidentialVars[] \:306f\:6a5f\:5bc6\:5909\:6570\:30c6\:30fc\:30d6\:30eb\:3092\:30af\:30ea\:30a2\:3059\:308b\:3002";

NBRegisterConfidentialVar::usage =
  "NBRegisterConfidentialVar[name, level] \:306f\:6a5f\:5bc6\:5909\:6570\:30921\:3064\:767b\:9332\:3059\:308b (level \:30c7\:30d5\:30a9\:30eb\:30c8 1.0)\:3002";

NBUnregisterConfidentialVar::usage =
  "NBUnregisterConfidentialVar[name] \:306f\:6a5f\:5bc6\:5909\:6570\:30921\:3064\:89e3\:9664\:3059\:308b\:3002";

NBRegisterConfidentialHead::usage =
  "NBRegisterConfidentialHead[name, level] \:306f\:300c\:8fd4\:308a\:5024\:304c\:6a5f\:5bc6\:305f\:308a\:5f97\:308b\:95a2\:6570\:30d8\:30c3\:30c9\:300d\:3092\:767b\:9332\:3059\:308b (level \:65e2\:5b9a 1.0)\:3002SourceVault \:7b49\:306e\:30c7\:30fc\:30bf\:5c64\:304c\:30ed\:30fc\:30c9\:6642\:306b\:767b\:9332\:3057\:3001claudecode \:304c LLM \:751f\:6210\:30b3\:30fc\:30c9\:306e\:66f8\:304d\:8fbc\:307f\:30bb\:30eb\:81ea\:52d5\:6a5f\:5bc6\:30de\:30fc\:30af\:3068 CellEpilog \:306e\:4f9d\:5b58\:79d8\:5bc6\:5224\:5b9a\:306b\:4f7f\:3046\:3002";

NBUnregisterConfidentialHead::usage =
  "NBUnregisterConfidentialHead[name] \:306f\:6a5f\:5bc6\:751f\:6210\:30d8\:30c3\:30c9\:306e\:767b\:9332\:30921\:3064\:89e3\:9664\:3059\:308b\:3002";

NBGetConfidentialHeads::usage =
  "NBGetConfidentialHeads[] \:306f\:767b\:9332\:6e08\:307f\:306e\:6a5f\:5bc6\:751f\:6210\:30d8\:30c3\:30c9\:8868 (<|name -> level|>) \:3092\:8fd4\:3059\:3002";

NBTextUsesConfidentialHead::usage =
  "NBTextUsesConfidentialHead[text] \:306f text \:304c\:767b\:9332\:6e08\:307f\:306e\:6a5f\:5bc6\:751f\:6210\:30d8\:30c3\:30c9\:3092\:53c2\:7167\:3057\:3066\:3044\:308c\:3070 True \:3092\:8fd4\:3059\:3002\:8b58\:5225\:5b50\:5883\:754c (Unicode) \:3067\:5224\:5b9a\:3057\:3001Map \:7b49\:3078\:95a2\:6570\:5024\:3068\:3057\:3066\:6e21\:3055\:308c\:308b\:5f62 (\:30d6\:30e9\:30b1\:30c3\:30c8\:306a\:3057) \:3082\:691c\:51fa\:3059\:308b\:3002";

NBGetPrivacySpec::usage =
  "NBGetPrivacySpec[] \:306f\:73fe\:5728\:306e $NBPrivacySpec \:3092\:8fd4\:3059\:3002";

NBInstallCellEpilog::usage =
  "NBInstallCellEpilog[nb, key, expr] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e CellEpilog \:306b\:5f0f\:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "key \:306f\:8b58\:5225\:7528\:6587\:5b57\:5217\:3002\:65e2\:306b\:30a4\:30f3\:30b9\:30c8\:30fc\:30eb\:6e08\:307f\:306a\:3089\:4f55\:3082\:3057\:306a\:3044\:3002";

NBCellEpilogInstalledQ::usage =
  "NBCellEpilogInstalledQ[nb, key] \:306f CellEpilog \:304c key \:3067\:65e2\:306b\:30a4\:30f3\:30b9\:30c8\:30fc\:30eb\:3055\:308c\:3066\:3044\:308b\:304b\:8fd4\:3059\:3002";

NBEvaluatePreviousCell::usage =
  "NBEvaluatePreviousCell[nb] \:306f\:76f4\:524d\:306e\:30bb\:30eb\:3092\:9078\:629e\:3057\:3066\:8a55\:4fa1\:3059\:308b\:3002";

NBInsertInputTemplate::usage =
  "NBInsertInputTemplate[nb, boxes] \:306f Input \:30bb\:30eb\:30c6\:30f3\:30d7\:30ec\:30fc\:30c8\:3092\:633f\:5165\:3059\:308b\:3002";

NBParentNotebookOfCurrentCell::usage =
  "NBParentNotebookOfCurrentCell[] \:306f EvaluationCell \:306e\:89aa\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:8fd4\:3059\:3002";

$NBSeparationIgnoreList::usage =
  "$NBSeparationIgnoreList \:306f\:5206\:96e2\:691c\:67fb (ClaudeCheckSeparation) \:3067\:7121\:8996\:3059\:308b\n" <>
  "\:30d5\:30a1\:30a4\:30eb\:540d\:307e\:305f\:306f\:30d1\:30c3\:30b1\:30fc\:30b8\:540d\:306e\:30ea\:30b9\:30c8\:3002\n" <>
  "NBAccess \:3068 NotebookExtensions \:306f\:30c7\:30d5\:30a9\:30eb\:30c8\:3067\:767b\:9332\:6e08\:307f\:3002\n" <>
  "\:4f8b: AppendTo[$NBSeparationIgnoreList, \"MyPackage\"]";

(* ---- \:5206\:96e2API\:8ffd\:52a0: \:30bb\:30eb\:66f8\:304d\:8fbc\:307f ---- *)
NBWriteCell::usage =
  "NBWriteCell[nb, cellExpr] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b Cell \:5f0f\:3092\:66f8\:304d\:8fbc\:3080 (After)\:3002\n" <>
  "NBWriteCell[nb, cellExpr, pos] \:306f pos (After/Before/All) \:3092\:6307\:5b9a\:53ef\:80fd\:3002\n" <>
  "\:9045\:5ef6\:51fa\:529b\:304c\:6709\:52b9 (NBBeginDeferredOutput \:5f8c) \:306e\:3068\:304d\:306f After \:66f8\:304d\:8fbc\:307f\:3092\n" <>
  "\:30d0\:30c3\:30d5\:30a1\:306b\:6e9c\:3081\:3001NBFlushDeferredOutput \:3067\:4e00\:62ec\:51fa\:529b\:3059\:308b\:3002";

NBBeginDeferredOutput::usage =
  "NBBeginDeferredOutput[] \:306f\:51fa\:529b\:9045\:5ef6 (\:96c6\:7d04) \:30e2\:30fc\:30c9\:3092\:6709\:52b9\:306b\:3059\:308b\:3002\:4ee5\:964d NBWriteCell[nb, cell] (After) \:306f notebook \:306b\:5373\:66f8\:304d\:305b\:305a\:30d0\:30c3\:30d5\:30a1\:306b\:6e9c\:3081\:308b\:3002\:5bfe\:7b562: \:975e\:540c\:671f\:4e26\:5217\:51e6\:7406\:3084\:30d6\:30ed\:30c3\:30af\:56de\:907f\:6642\:306b\:4f7f\:3046\:3002NBEndDeferredOutput \:3068\:5bfe\:3002";
NBEndDeferredOutput::usage =
  "NBEndDeferredOutput[] \:306f\:51fa\:529b\:9045\:5ef6\:30e2\:30fc\:30c9\:3092\:7121\:52b9\:306b\:623b\:3059 (\:30d0\:30c3\:30d5\:30a1\:306f\:6b8b\:308b\:306e\:3067 NBFlushDeferredOutput \:3067\:51fa\:529b\:3059\:308b\:3053\:3068)\:3002";
NBFlushDeferredOutput::usage =
  "NBFlushDeferredOutput[nb] \:306f\:6e9c\:3081\:305f Cell \:3092 notebook \:306b\:4e00\:62ec\:66f8\:304d\:8fbc\:307f\:30d0\:30c3\:30d5\:30a1\:3092\:30af\:30ea\:30a2\:3059\:308b\:3002\:623b\:308a\:5024: \:51fa\:529b\:3057\:305f Cell \:6570\:3002\:7f60 #30: FrontEnd \:64cd\:4f5c\:306a\:306e\:3067\:30e1\:30a4\:30f3\:30ab\:30fc\:30cd\:30eb\:8a55\:4fa1\:3067\:547c\:3076\:3053\:3068\:3002NBFlushDeferredOutput[] (nb \:7701\:7565) \:306f CellPrint \:3067\:51fa\:529b\:3059\:308b\:3002";
NBDeferredOutputActiveQ::usage =
  "NBDeferredOutputActiveQ[] \:306f\:51fa\:529b\:9045\:5ef6\:30e2\:30fc\:30c9\:304c\:6709\:52b9\:304b\:3092\:8fd4\:3059\:3002";
NBDeferredOutputCount::usage =
  "NBDeferredOutputCount[] \:306f\:30d0\:30c3\:30d5\:30a1\:306b\:6e9c\:307e\:3063\:3066\:3044\:308b Cell \:6570\:3092\:8fd4\:3059\:3002";
NBDiscardDeferredOutput::usage =
  "NBDiscardDeferredOutput[] \:306f\:30d0\:30c3\:30d5\:30a1\:3092\:30d5\:30e9\:30c3\:30b7\:30e5\:305b\:305a\:7834\:68c4\:3059\:308b\:3002";

NBWritePrintNotice::usage =
  "NBWritePrintNotice[nb, text, color] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b\:901a\:77e5\:7528 Print \:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "nb \:304c None \:306e\:5834\:5408\:306f CellPrint \:3092\:4f7f\:7528 (\:540c\:671f In/Out \:9593\:51fa\:529b)\:3002";

NBCellPrint::usage =
  "NBCellPrint[cellExpr] \:306f\:8a55\:4fa1\:4e2d\:306e\:30bb\:30eb\:306e\:76f4\:5f8c\:306b\:51fa\:529b\:30bb\:30eb\:3092\:63ff\:5165\:3059\:308b (CellPrint \:30e9\:30c3\:30d1\:30fc)\:3002\n" <>
  "\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:4f9d\:5b58\:305b\:305a\:3001\:5e38\:306b EvaluationCell \:306e\:76f4\:5f8c\:306b\:914d\:7f6e\:3055\:308c\:308b\:3002\n" <>
  "ClaudeBackupDataset \:7b49\:306e\:30bf\:30b0\:4ed8\:304d\:51fa\:529b\:30bb\:30eb\:306b\:4f7f\:7528\:3059\:308b\:3002";

NBWriteDynamicCell::usage =
  "NBWriteDynamicCell[nb, dynBoxExpr, tag] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b Dynamic \:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "tag \:304c \"\" \:3067\:306a\:3044\:5834\:5408\:306f CellTags \:3092\:8a2d\:5b9a\:3059\:308b\:3002";

NBWriteExternalLanguageCell::usage =
  "NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate] \:306f ExternalLanguage \:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "autoEvaluate \:304c True \:306a\:3089\:76f4\:524d\:30bb\:30eb\:3092\:8a55\:4fa1\:3059\:308b\:3002";

NBInsertAndEvaluateInput::usage =
  "NBInsertAndEvaluateInput[nb, boxes] \:306f Input \:30bb\:30eb\:3092\:633f\:5165\:3057\:3066\:5373\:5ea7\:306b\:8a55\:4fa1\:3059\:308b\:3002";

NBInsertInputAfter::usage =
  "NBInsertInputAfter[nb, boxes] \:306f Input \:30bb\:30eb\:3092 After \:306b\:66f8\:304d\:8fbc\:307f Before CellContents \:306b\:79fb\:52d5\:3059\:308b\:3002";

NBWriteAnchorAfterEvalCell::usage =
  "NBWriteAnchorAfterEvalCell[nb, tag] \:306f EvaluationCell \:76f4\:5f8c\:306b\:4e0d\:53ef\:8996\:30a2\:30f3\:30ab\:30fc\:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080\:3002\n" <>
  "EvaluationCell \:304c\:53d6\:5f97\:3067\:304d\:306a\:3044\:5834\:5408\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e\:306b\:66f8\:304d\:8fbc\:3080\:3002";

NBInstallConfidentialEpilog::usage =
  "NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol] \:306f\:6a5f\:5bc6\:5909\:6570\:8ffd\:8de1\:7528 CellEpilog \:3092\:30a4\:30f3\:30b9\:30c8\:30fc\:30eb\:3059\:308b\:3002\n" <>
  "checkSymbol \:306f FreeQ \:30c1\:30a7\:30c3\:30af\:7528\:306e\:30de\:30fc\:30ab\:30fc\:30b7\:30f3\:30dc\:30eb\:3002\:65e2\:306b\:30a4\:30f3\:30b9\:30c8\:30fc\:30eb\:6e08\:307f\:306a\:3089\:4f55\:3082\:3057\:306a\:3044\:3002";

NBConfidentialEpilogInstalledQ::usage =
  "NBConfidentialEpilogInstalledQ[nb, checkSymbol] \:306f\:6a5f\:5bc6\:8ffd\:8de1 CellEpilog \:304c\:30a4\:30f3\:30b9\:30c8\:30fc\:30eb\:6e08\:307f\:304b\:8fd4\:3059\:3002\n" <>
  "checkSymbol \:306f FreeQ \:30c1\:30a7\:30c3\:30af\:7528\:306e\:30de\:30fc\:30ab\:30fc\:30b7\:30f3\:30dc\:30eb\:3002";

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: Allowed Expression Surface & Runtime Integration API
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

$NBAllowedHeads::usage =
  "$NBAllowedHeads \:306f LLM \:304c\:81ea\:7531\:306b\:5b9f\:884c\:53ef\:80fd\:306a head \:306e\:30ea\:30b9\:30c8\:3002";

$NBApprovalHeads::usage =
  "$NBApprovalHeads \:306f\:4eba\:9593\:627f\:8a8d\:3092\:8981\:3059\:308b head \:306e\:30ea\:30b9\:30c8\:3002";

$NBDenyHeads::usage =
  "$NBDenyHeads \:306f\:5e38\:306b\:62d2\:5426\:3059\:308b head \:306e\:30ea\:30b9\:30c8\:3002";

NBValidateHeldExpr::usage =
  "NBValidateHeldExpr[heldExpr, accessSpec, opts] \:306f HoldComplete[...] \:5f0f\:3092\n" <>
  "Allowed Expression Surface \:306b\:7167\:5408\:3057 AccessDecision \:3092\:8fd4\:3059\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"Decision\" -> \"Permit\"|\"Deny\"|\"NeedsApproval\"|\"RepairNeeded\", ...)|>";

NBExecuteHeldExpr::usage =
  "NBExecuteHeldExpr[heldExpr, accessSpec, opts] \:306f\:691c\:8a3c\:6e08\:307f\:5f0f\:3092\:5b89\:5168\:306b\:5b9f\:884c\:3057\:7d50\:679c\:3092\:8fd4\:3059\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"Success\" -> True/False, \"RawResult\" -> ..., \"Error\" -> ...|>";

NBTryExecuteFinalActionHeld::usage =
  "NBTryExecuteFinalActionHeld[held, accessSpec, opts] \:306f\:627f\:8a8d wrapper (NBOpenFolderWithApproval \:7b49) \:3092\n" <>
  "head \:306e context \:306b\:4f9d\:5b58\:305b\:305a (SymbolName \:3067\:691c\:51fa)\:3001\:5f15\:6570\:30d1\:30b9\:5f0f\:3092\:5b89\:5168\:8a55\:4fa1\:3057\:3066\n" <>
  "OpenDesktopItem action \:306b\:6b63\:898f\:5316\:3057\:3001NBExecuteApprovedAction \:7d4c\:7531\:3067\:5b9f\:884c\:3059\:308b\:3002\n" <>
  "Global` shadow \:3084 $ContextPath \:306b\:5de6\:53f3\:3055\:308c\:306a\:3044\:3002\:5bfe\:8c61\:5916\:306a\:3089 <|\"Handled\" -> False|>\:3002";

NBResolveDesktopActionPath::usage =
  "NBResolveDesktopActionPath[held, accessSpec] \:306f desktop action wrapper \:304b\:3089\n" <>
  "SystemOpen \:3092\:547c\:3070\:305a\:30d1\:30b9\:3092\:5b89\:5168\:89e3\:6c7a\:30fb\:691c\:8a3c\:3060\:3051\:884c\:3046\:3002SystemOpen \:306f SessionSubmit/\n" <>
  "ScheduledTask \:7cfb\:3067\:306f\:52b9\:304b\:305a\:30e1\:30a4\:30f3\:30ab\:30fc\:30cd\:30eb\:8a55\:4fa1\:3067\:306e\:307f\:52b9\:304f\:305f\:3081\:3001\:5b9f\:884c\:306f\:547c\:3073\:51fa\:3057\:5074\:306b\:59d4\:306d\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"IsDesktopAction\" -> .., \"Validated\" -> .., \"Path\" -> ..|>";

NBRedactExecutionResult::usage =
  "NBRedactExecutionResult[result, accessSpec, opts] \:306f\:5b9f\:884c\:7d50\:679c\:3092 redact \:3057\:5b89\:5168\:306a\:5f62\:3067\:8fd4\:3059\:3002\n" <>
  "accessSpec \:306b \"ConfidentialLineNumbers\" -> {n, ...} \:304c\:3042\:308c\:3070\:3001\:5b9f\:884c\:5f0f\:304c\n" <>
  "Out[n] / In[n] / InString[n] / % \:7b49\:3067\:6a5f\:5bc6\:30bb\:30eb\:3092\:53c2\:7167\:3057\:305f\:5834\:5408\:3082\:6a5f\:5bc6\:4f9d\:5b58\:3068\:3057\:3066\:30b9\:30ad\:30fc\:30de\:5316\:3059\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"RedactedResult\" -> ..., \"Summary\" -> String|>";

NBConfidentialLineNumbers::usage =
  "NBConfidentialLineNumbers[nb, accessSpec] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:306e\:6a5f\:5bc6\:30fb\:6a5f\:5bc6\:4f9d\:5b58\n" <>
  "Input/Code/Output \:30bb\:30eb\:306e\:8a55\:4fa1\:884c\:756a\:53f7 (\:6574\:6570 n; In[n] \:3068 Out[n] \:306f\:540c\:4e00 n) \:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "LLM \:304c Out[n] / In[n] / InString[n] / % \:3067\:6a5f\:5bc6\:30bb\:30eb\:3092\:76f4\:63a5\:53c2\:7167\:3057\:305f\:3068\:304d\:306e\n" <>
  "\:6f0f\:6d29\:691c\:51fa (NBRedactExecutionResult) \:306b\:7528\:3044\:308b\:3002";

NBMakeContextPacket::usage =
  "NBMakeContextPacket[nb, accessSpec, opts] \:306f notebook \:304b\:3089\:5b89\:5168\:306a context packet \:3092\:69cb\:7bc9\:3059\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"Input\" -> ..., \"Cells\" -> ..., \"AccessSpec\" -> ..., ...)|>";

$NBRoutingThresholds::usage =
  "$NBRoutingThresholds \:306f routing \:95be\:5024\:306e Association\:3002\n" <>
  "<|\"Cloud\" -> 0.5, \"Private\" -> 0.8|>\n" <>
  "EffectiveRiskScore < Cloud \[RightArrow] CloudLLM \:5019\:88dc\n" <>
  "Cloud <= score < Private \[RightArrow] PrivateLLM \:5019\:88dc\n" <>
  "Private <= score \[RightArrow] LocalOnly";

NBRouteDecision::usage =
  "NBRouteDecision[scoreOrAccessSpec] \:306f\:6570\:5024\:30b9\:30b3\:30a2\:307e\:305f\:306f accessSpec \:304b\:3089\n" <>
  "routing \:63a8\:5968\:3092\:8fd4\:3059 (advisory, not gatekeeping)\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"Route\" -> \"CloudLLM\"|\"PrivateLLM\"|\"LocalOnly\",\n" <>
  "  \"EffectiveRiskScore\" -> n, \"Thresholds\" -> ...,\n" <>
  "  \"Reason\" -> String|>";

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: Iterative Agent Loop Support APIs
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

NBInferExprRequirements::usage =
  "NBInferExprRequirements[heldExpr, accessSpec] \:306f\:5f0f\:304c\:5fc5\:8981\:3068\:3059\:308b\n" <>
  "\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:30fb\:66f8\:304d\:8fbc\:307f\:30bf\:30fc\:30b2\:30c3\:30c8\:30fb\:53c2\:7167\:30bb\:30eb\:7b49\:3092\:9759\:7684\:306b\:63a8\:5b9a\:3059\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"ReadCells\" -> {...}, \"WriteCells\" -> {...},\n" <>
  "  \"RequiredAccessLevel\" -> n, \"HasSideEffects\" -> True/False, ...)|>";

NBReleaseResult::usage =
  "NBReleaseResult[result, accessSpec, opts] \:306f\:5b9f\:884c\:7d50\:679c\:3092\n" <>
  "\:6307\:5b9a\:3055\:308c\:305f sink \:306b\:5b89\:5168\:306b release \:3059\:308b\:3002\n" <>
  "redaction + routing check \:3092\:884c\:3044\:3001release \:53ef\:80fd\:306a\:5f62\:3092\:8fd4\:3059\:3002";

NBMakeRetryPacket::usage =
  "NBMakeRetryPacket[failureAssoc, accessSpec] \:306f\:5931\:6557\:60c5\:5831\:304b\:3089\n" <>
  "\:79d8\:5bc6\:3092\:542b\:307e\:306a\:3044\:5b89\:5168\:306a retry packet \:3092\:69cb\:7bc9\:3059\:308b\:3002";

NBMakeFileAccessRequest::usage =
  "NBMakeFileAccessRequest[pathOrSpec, operation, opts] \:306f file \:7528\:306e AccessRequest Association \:3092\:7d44\:307f\:7acb\:3066\:308b helper\:3002\n" <>
  "operation: \"ReadValue\" | \"WriteCell\" | \"WriteLog\" | \"SendExternal\" \:7b49\:3002\n" <>
  "Sink / Networked / Route / Provider / AccessLevel \:306f operation \:304b\:3089\:65e2\:5b9a\:304c\:6c7a\:307e\:308b (\:30aa\:30d7\:30b7\:30e7\:30f3\:3067\:4e0a\:66f8\:304d\:53ef)\:3002\n" <>
  "Phase 4.1: cloud send \:306f Sink -> \"CloudLLM\"\:3001local read/write \:306f Sink -> \"LocalOnly\" / \"Notebook\" \:3068\:3059\:308b\:3002";

NBAuthorizeFile::usage =
  "NBAuthorizeFile[pathOrSpec, req] \:306f NBFileSpec / file spec \:3092 NBAuthorize \:306b\:6e21\:3059\:305f\:3081\:306e adapter\:3002\n" <>
  "pathOrSpec \:304c\:6587\:5b57\:5217\:306a\:3089 NBFileSpec \:3067 base spec \:3092\:53d6\:5f97\:3001Association \:306a\:3089\:305d\:306e\:307e\:307e\:4f7f\:3046\:3002\n" <>
  "\:3044\:305a\:308c\:3082 iNBFileSpecForAuthorize \:3067\:6b63\:898f\:5316 (projection key \:9664\:53bb\:30fbPrivacyLevel \:7531\:6765\:306e score \:88dc\:5b8c) \:3057\:3066\:304b\:3089 NBAuthorize \:306b\:6e21\:3059\:3002\n" <>
  "\:65b0\:3057\:3044 authorization engine \:3067\:306f\:306a\:304f\:3001\:65e2\:5b58 NBAuthorize \:3078\:306e\:8584\:3044 adapter \:3067\:3042\:308b\:3002";

NBPermitQ::usage =
  "NBPermitQ[decision] \:306f NBAuthorize \:306e AccessDecision \:3092 Boolean projection \:306b\:843d\:3068\:3059 fail-closed helper\:3002\n" <>
  "Decision \:304c \"Permit\" \:306e\:3068\:304d\:3060\:3051 True\:3002\"Deny\" / \"Screen\" / \"RequireApproval\" / $Failed / Missing / \:4f8b\:5916\:306f\:3059\:3079\:3066 False\:3002\n" <>
  "\:5224\:5b9a\:4e0d\:80fd\:306a\:3089 False \:306b\:5012\:3059 (\:7279\:306b cloud send \:306f\:300c\:5224\:5b9a\:4e0d\:80fd\:306a\:3089\:9001\:3089\:306a\:3044\:300d)\:3002";

NBDefaultFilePolicyLabel::usage =
  "NBDefaultFilePolicyLabel[spec] \:306f Phase 4 \:521d\:671f\:306e placeholder file policy label \:3092\:8fd4\:3059\:3002\n" <>
  "DLM / LabelJoin \:306e\:5b8c\:5168\:5b9f\:88c5\:307e\:3067\:306e\:6700\:5c0f\:5b9f\:88c5\:3002";

NBNoExtraContainerLabel::usage =
  "NBNoExtraContainerLabel[] \:306f Phase 4 \:521d\:671f\:306e placeholder container label \:3092\:8fd4\:3059\:3002";

NBAuthorize::usage =
  "NBAuthorize[obj, req] \:306f PolicyGate + ScoreGate + EnvironmentGate \:3092\n" <>
  "\:7d71\:5408\:3057\:305f AccessDecision \:3092\:8fd4\:3059\:3002\n" <>
  "\:8fd4\:308a\:5024: <|\"Decision\" -> \"Permit\"|\"Deny\"|\"Screen\"|\"RequireApproval\",\n" <>
  "  \"ReasonClass\" -> ..., \"RequiredAction\" -> ...,\n" <>
  "  \"VisibleExplanation\" -> ..., \"RouteAdvice\" -> ...|>";

NBPolicyGate::usage =
  "NBPolicyGate[obj, req] \:306f\:534a\:9806\:5e8f\:30e9\:30d9\:30eb\:306b\:57fa\:3065\:304f flow \:5224\:5b9a\:3092\:8fd4\:3059\:3002\n" <>
  "PolicyLabel / ContainerLabel / SinkLabel \:3092\:8003\:616e\:3059\:308b\:3002";

NBScoreGate::usage =
  "NBScoreGate[obj, req] \:306f\:6570\:5024\:30b9\:30b3\:30a2\:306b\:57fa\:3065\:304f routing/screening \:5224\:5b9a\:3092\:8fd4\:3059\:3002\n" <>
  "advisory \:4f53\:7cfb: \:5224\:5b9a\:306f routing \:306b\:5f71\:97ff\:3059\:308b\:304c permit/deny \:306e\:4e3b\:4f53\:3067\:306f\:306a\:3044\:3002";

NBEnvironmentGate::usage =
  "NBEnvironmentGate[obj, req] \:306f\:5b9f\:884c\:74b0\:5883\:306b\:57fa\:3065\:304f\:5236\:7d04\:30c1\:30a7\:30c3\:30af\:3092\:8fd4\:3059\:3002\n" <>
  "Sink / Environment / Principal \:3092\:8003\:616e\:3059\:308b\:3002";

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 20: Function Security API
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

NBRegisterFunctionSecurity::usage =
  "NBRegisterFunctionSecurity[sym, spec] \:306f\:95a2\:6570 sym \:306b\n" <>
  "\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:30e1\:30bf\:30c7\:30fc\:30bf\:3092\:767b\:9332\:3059\:308b\:3002\n" <>
  "spec: <|\"DefinitionLabel\" -> label,\n" <>
  "  \"ExecPolicy\" -> \"Open\"|\"Guarded\"|\"Denied\",\n" <>
  "  \"ReleasePolicy\" -> <|...|>|>";

NBFunctionDefinitionLabel::usage =
  "NBFunctionDefinitionLabel[f] \:306f\:95a2\:6570 f \:306e\:5b9a\:7fa9\:30e9\:30d9\:30eb\:3092\:8fd4\:3059\:3002\n" <>
  "\:5b9a\:7fa9\:30e9\:30d9\:30eb\:306f\:30b3\:30fc\:30c9\:81ea\:4f53\:306e\:95b2\:89a7\:53ef\:5426\:3092\:5236\:5fa1\:3059\:308b\:3002";

NBFunctionExecPolicy::usage =
  "NBFunctionExecPolicy[f] \:306f\:95a2\:6570 f \:306e\:5b9f\:884c\:30dd\:30ea\:30b7\:30fc\:3092\:8fd4\:3059\:3002\n" <>
  "\"Open\"|\"Guarded\"|\"Denied\"";

NBFunctionReleasePolicy::usage =
  "NBFunctionReleasePolicy[f] \:306f\:95a2\:6570 f \:306e\:7d50\:679c\:30ea\:30ea\:30fc\:30b9\:30dd\:30ea\:30b7\:30fc\:3092\:8fd4\:3059\:3002\n" <>
  "\:7d50\:679c\:306e\:30e9\:30d9\:30eb\:5f15\:304d\:4e0b\:3052\:6761\:4ef6\:3092\:5b9a\:7fa9\:3059\:308b\:3002";

GuardedApply::usage =
  "GuardedApply[req, f, args] \:306f f[args] \:3092\n" <>
  "\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:30dd\:30ea\:30b7\:30fc\:306b\:5f93\:3063\:3066\:5b9f\:884c\:3059\:308b\:3002\n" <>
  "ExecPolicy \:304c \"Guarded\" \:306e\:5834\:5408\:3001flow \:30c1\:30a7\:30c3\:30af\:5f8c\:306b\:5b9f\:884c\:3057\:3001\n" <>
  "\:7d50\:679c\:306b\:9069\:5207\:306a\:30e9\:30d9\:30eb\:3092\:4ed8\:4e0e\:3059\:308b\:3002";

Declassify::usage =
  "Declassify[obj, req, releaseSpec] \:306f obj \:306e\:30e9\:30d9\:30eb\:3092\n" <>
  "releaseSpec \:306b\:5f93\:3063\:3066\:5f15\:304d\:4e0b\:3052\:308b\:3002\n" <>
  "req \:306e Principal \:304c acts-for \:6a29\:9650\:3092\:6301\:3064\:5834\:5408\:306e\:307f\:8a31\:53ef\:3002";

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: Label Algebra (\:6700\:5c0f API)
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

NBLabelQ::usage =
  "NBLabelQ[label] \:306f label \:304c\:6709\:52b9\:306a NBAccess \:30e9\:30d9\:30eb\:304b\:3092\:5224\:5b9a\:3059\:308b\:3002";

NBLabelBottom::usage =
  "NBLabelBottom[] \:306f\:6700\:5c0f\:5236\:7d04\:30e9\:30d9\:30eb (public) \:3092\:8fd4\:3059\:3002";

NBLabelTop::usage =
  "NBLabelTop[] \:306f\:6700\:5927\:5236\:7d04\:30e9\:30d9\:30eb (\:5168\:62d2\:5426) \:3092\:8fd4\:3059\:3002";

NBLabelJoin::usage =
  "NBLabelJoin[l1, l2] \:306f\:30e9\:30d9\:30eb\:306e join (\:6700\:5927\:4e0b\:754c\:306e\:53cc\:5bfe = \:3088\:308a\:5236\:7d04\:7684) \:3092\:8fd4\:3059\:3002\n" <>
  "\:4e21\:65b9\:306e\:5236\:7d04\:3092\:6e80\:305f\:3059\:65b9\:5411\:3002";

NBLabelMeet::usage =
  "NBLabelMeet[l1, l2] \:306f\:30e9\:30d9\:30eb\:306e meet (\:6700\:5c0f\:4e0a\:754c = \:3088\:308a\:7de9\:3044) \:3092\:8fd4\:3059\:3002";

NBLabelLEQ::usage =
  "NBLabelLEQ[l1, l2] \:306f l1 \[PrecedesEqual] l2 (l1 \:306e\:60c5\:5831\:304c l2 \:3078 flow \:53ef\:80fd) \:3092\:5224\:5b9a\:3059\:308b\:3002";

NBRegisterPrincipal::usage =
  "NBRegisterPrincipal[name, opts] \:306f\:30a2\:30af\:30bb\:30b9\:4e3b\:4f53\:3092\:767b\:9332\:3059\:308b\:3002";

NBGrantActsFor::usage =
  "NBGrantActsFor[p, q] \:306f principal p \:304c q \:3068\:3057\:3066\:884c\:52d5\:3067\:304d\:308b\:59d4\:4efb\:3092\:767b\:9332\:3059\:308b\:3002";

NBActsForQ::usage =
  "NBActsForQ[p, q] \:306f p \:304c q \:3068\:3057\:3066\:884c\:52d5\:53ef\:80fd\:304b\:5224\:5b9a\:3059\:308b\:3002";

NBCanFlowToQ::usage =
  "NBCanFlowToQ[srcLabel, dstLabel] \:306f src \:304b\:3089 dst \:3078\:306e flow \:304c\:8a31\:53ef\:3055\:308c\:308b\:304b\:5224\:5b9a\:3059\:308b\:3002";

NBCanDeclassifyQ::usage =
  "NBCanDeclassifyQ[srcLabel, dstLabel, req] \:306f declassify \:304c\:6b63\:5f53\:304b\:5224\:5b9a\:3059\:308b\:3002";

NBEffectiveLabel::usage =
  "NBEffectiveLabel[obj, req] \:306f\:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:3068\:8981\:6c42\:304b\:3089\:5b9f\:52b9\:30e9\:30d9\:30eb\:3092\:8a08\:7b97\:3059\:308b\:3002";

$NBAllowedHeadsByCategory::usage =
  "$NBAllowedHeadsByCategory \:306f\:30ab\:30c6\:30b4\:30ea\:5225\:306e\:8a31\:53ef head \:30ea\:30b9\:30c8 (Association)\:3002";

$NBDisabledCategories::usage =
  "$NBDisabledCategories \:306f\:7121\:52b9\:5316\:3055\:308c\:305f\:30ab\:30c6\:30b4\:30ea\:306e\:8ffd\:8de1 (Association)\:3002";

NBEnableCategory::usage =
  "NBEnableCategory[cat] \:306f\:30ab\:30c6\:30b4\:30ea\:3092\:6709\:52b9\:5316\:3059\:308b\:3002";

NBDisableCategory::usage =
  "NBDisableCategory[cat] \:306f\:30ab\:30c6\:30b4\:30ea\:3092\:7121\:52b9\:5316\:3059\:308b\:3002";

NBCategoryEnabled::usage =
  "NBCategoryEnabled[cat] \:306f\:30ab\:30c6\:30b4\:30ea\:304c\:6709\:52b9\:304b\:3092\:8fd4\:3059\:3002";


(* ============================================================
   Notebook semantic access API (Stage 9 P1 Step 6 \:7528)
   ------------------------------------------------------------
   \:30d5\:30a1\:30a4\:30eb\:76f4\:63a5\:7d4c\:8def (Import[\"Notebook\"] / Export[\"NB\"]) \:3067 closed notebook \:3082\:64cd\:4f5c\:53ef\:3002
   FrontEnd \:4e0d\:8981\:3002AccessSpec Association \:3067 RBAC \:5236\:5fa1\:3002
   \:8aad\:307f\:53d6\:308a\:7cfb\:306f\:30c7\:30d5\:30a9\:30eb\:30c8\:3067 AccessLevel = 0.5 (Public) \:6271\:3044\:3002\:66f8\:304d\:8fbc\:307f\:7cfb\:306f\:5225\:9014\:8ffd\:52a0\:3002
   ============================================================ *)

NBReadHeader::usage =
  "NBReadHeader[path, opts:OptionsPattern[]] \:306f notebook \:306e SourceVault \:30d8\:30c3\:30c0\:30fc\:3092\:62bd\:51fa\:3059\:308b\:3002\n" <>
  "\:5bfe\:8c61\:30bb\:30eb: TaggingRules \= \"SourceVault\" \:307e\:305f\:306f Header style cell\:3002\n" <>
  "Stage 9 P1 \:5225\:4ef6 2: Input cell \:5185\:306e BoxData (\:751f Association) \:3082 MakeExpression \:7d4c\:7531\:3067\:53d6\:5f97\:53ef\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.5, ...|>   - NBAccess RBAC \:6307\:5b9a\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\",\n" <>
  "  \"Keywords\" -> {...}, \"Status\" -> _, \"Deadline\" -> _, \"NextReview\" -> _,\n" <>
  "  \"Owner\" -> _, \"PathHint\" -> _, ...\n" <>
  "  \"RawHeader\" -> <|...|>,\n" <>
  "  \"Source\" -> \"TaggingRules\"|\"HeaderCell\"|\"BoxData\"|\"None\"|>";

NBReadTodos::usage =
  "NBReadTodos[path, opts:OptionsPattern[]] \:306f notebook \:306e Todo cell \:3092\:5168\:62bd\:51fa\:3059\:308b\:3002\n" <>
  "\:5bfe\:8c61\:30bb\:30eb: Item style cell\:3001\:307e\:305f\:306f TaggingRules \= \"SourceVault\" \:3067 TodoStatus \:8a2d\:5b9a\:6e08\:3002\n" <>
  "CellGroupData \:30cd\:30b9\:30c8\:3082\:518d\:5e30\:7684\:306b\:5c55\:958b\:3057\:3066\:5168\:30bb\:30eb\:3092\:8d70\:67fb\:3059\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.5, ...|>   - NBAccess RBAC \:6307\:5b9a\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\",\n" <>
  "  \"Todos\" -> { <|\"Index\" -> n, \"Text\" -> ..., \"Status\" -> \"Open\"|\"Done\"|\"Pass\",\n" <>
  "                  \"CellPath\" -> {_Integer...}, \"StatusSource\" -> \"TaggingRules\"|\"StyleHeuristic\"|...,\n" <>
  "                  \"ExpressionUUID\" -> _String|_Missing |> ... } |>";

NBFindCellByPredicate::usage =
  "NBFindCellByPredicate[path, predicate, opts:OptionsPattern[]] \:306f predicate \:304c True \:3092\:8fd4\:3059 cell \:3092\:8fd4\:3059\:3002\n" <>
  "predicate: Function \:3001Cell expr \:3092\:53d7\:3051\:53d6\:308a True/False \:3092\:8fd4\:3059\:3002\n" <>
  "CellGroupData \:30cd\:30b9\:30c8\:3082\:518d\:5e30\:7684\:306b\:5c55\:958b\:3057\:3066\:5168\:30bb\:30eb\:3092\:8d70\:67fb\:3059\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|...|>                          - NBAccess RBAC\n" <>
  "  \"MaxResults\" -> All|_Integer                     - All \:307e\:305f\:306f\:6700\:5927\:4ef6\:6570\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\",\n" <>
  "  \"Matches\" -> { <|\"CellIndex\" -> n (flat index), \"CellPath\" -> {_Integer...},\n" <>
  "                    \"Cell\" -> HoldComplete[Cell[...]],\n" <>
  "                    \"Style\" -> _, \"ExpressionUUID\" -> _String|_Missing |> ... } |>";


(* \[HorizontalLine]\[HorizontalLine] \:66f8\:304d\:8fbc\:307f\:7cfb (Stage 9 P1 Step 6 \:7528) \[HorizontalLine]\[HorizontalLine] *)

NBSetCellOptionsByPredicate::usage =
  "NBSetCellOptionsByPredicate[path, predicate, optionRules_List, opts:OptionsPattern[]] \:306f\n" <>
  "predicate \:304c True \:3092\:8fd4\:3059 cell \:306e options \:3092 optionRules \:3067\:4e0a\:66f8\:304d\:3059\:308b\:3002\n" <>
  "optionRules: \:4f8b {FontVariations -> {\"StrikeThrough\" -> True}, FontColor -> RGBColor[0,0.5,0]}\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.7, ...|>    - \:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981 (default 0.7)\n" <>
  "  \"DryRun\" -> True|False                            - True \:306f\:30d7\:30ec\:30d3\:30e5\:30fc\:306e\:307f (default True)\n" <>
  "  \"MaxResults\" -> All|_Integer                       - \:7de8\:96c6\:5bfe\:8c61\:30bb\:30eb\:6570\:4e0a\:9650 (default All)\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\"|\"DryRunOK\",\n" <>
  "  \"Modified\" -> { <|\"CellPath\" -> ..., \"Before\" -> ..., \"After\" -> ...|> ... },\n" <>
  "  \"DryRun\" -> _Boolean, \"AccessLevel\" -> _Real|>";

NBSetCellTaggingRuleByPredicate::usage =
  "NBSetCellTaggingRuleByPredicate[path, predicate, taggingKeyPath_List, value, opts:OptionsPattern[]] \:306f\n" <>
  "predicate \:304c True \:3092\:8fd4\:3059 cell \:306e TaggingRules \:5185\:90e8\:306e key \:30d1\:30b9\:3092 value \:3067\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "\:4f8b: taggingKeyPath = {\"SourceVault\", \"TodoStatus\"}, value = \"Done\"\n" <>
  "      \[RightArrow] Cell \:306e TaggingRules \:306b <|\"SourceVault\" -> <|\"TodoStatus\" -> \"Done\"|>|> \:3092\:30de\:30fc\:30b8\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3: NBSetCellOptionsByPredicate \:3068\:540c\:69d8\:3002\n" <>
  "\:623b\:308a\:5024: NBSetCellOptionsByPredicate \:3068\:540c\:5f62\:3002";

NBWriteHeader::usage =
  "NBWriteHeader[path, key, value, opts:OptionsPattern[]] \:306f notebook \:306e SourceVault \:30d8\:30c3\:30c0\:30fc 1 \:30d5\:30a3\:30fc\:30eb\:30c9\:3092\:66f4\:65b0\:3059\:308b\:3002\n" <>
  "Notebook \:5168\:4f53\:306e TaggingRules \= SourceVault \:914d\:4e0b\:306b key -> value \:3092\:30de\:30fc\:30b8\:3059\:308b\:3002\n" <>
  "key: \"Status\"/\"Keywords\"/\"Deadline\"/\"NextReview\"/\"Owner\"/\"PathHint\" \:7b49\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.7, ...|>    - \:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981 (default 0.7)\n" <>
  "  \"DryRun\" -> True|False                            - True \:306f\:30d7\:30ec\:30d3\:30e5\:30fc\:306e\:307f (default True)\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\"|\"DryRunOK\",\n" <>
  "  \"Before\" -> _, \"After\" -> _, \"DryRun\" -> _Boolean, \"Path\" -> _String|>";

NBWriteTodoStatus::usage =
  "NBWriteTodoStatus[path, todoKey, newStatus, opts:OptionsPattern[]] \:306f\n" <>
  "todoKey \:3067\:7279\:5b9a\:3055\:308c\:308b Todo cell \:306e Status \:3092 newStatus \:306b\:5909\:66f4\:3059\:308b\:3002\n" <>
  "todoKey: <|\"Index\" -> n, \"Text\" -> \"...\"|>  (\:4e21\:65b9\:4e00\:81f4\:3059\:308b cell \:306e\:307f\:7de8\:96c6\:3001\:5b89\:5168\:5074)\n" <>
  "newStatus: \"Open\"/\"Done\"/\"Pass\"\n" <>
  "\:5909\:66f4\:5185\:5bb9: FontVariations StrikeThrough on/off + FontColor (\:7dd1/\:7070) + TaggingRules SourceVault TodoStatus\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.7, ...|>    - \:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981 (default 0.7)\n" <>
  "  \"DryRun\" -> True|False                            - True \:306f\:30d7\:30ec\:30d3\:30e5\:30fc\:306e\:307f (default True)\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\"|\"DryRunOK\",\n" <>
  "  \"MatchedTodo\" -> <|\"Index\" -> ..., \"Text\" -> ...|>,\n" <>
  "  \"OldStatus\" -> _, \"NewStatus\" -> _, \"CellPath\" -> {_Integer...}|>";


(* \[HorizontalLine]\[HorizontalLine] \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5358\:4f4d\:30af\:30e9\:30a6\:30c9\:516c\:958b\:5ba3\:8a00 (Stage 9 P1 \:62e1\:5f35) \[HorizontalLine]\[HorizontalLine] *)

NBGetCloudPublishable::usage =
  "NBGetCloudPublishable[path] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:81ea\:8eab\:306e\:30af\:30e9\:30a6\:30c9\:516c\:958b\:5ba3\:8a00\:3092\:8aad\:307f\:53d6\:308b\:3002\n" <>
  "Notebook \:5168\:4f53\:306e TaggingRules > SourceVault > \"CloudPublishable\" \:3092\:8aad\:3080\:3002\n" <>
  "\:623b\:308a\:5024:\n" <>
  "  True                          - \:30af\:30e9\:30a6\:30c9 LLM \:53ef\:3068\:5ba3\:8a00\:6e08\:307f\n" <>
  "  False                         - \:660e\:793a\:7684\:306b\:30af\:30e9\:30a6\:30c9\:7981\:6b62\:3068\:5ba3\:8a00\:6e08\:307f\n" <>
  "  Missing[\"NotDeclared\"]        - \:5ba3\:8a00\:7121\:3057 (\:30c7\:30d5\:30a9\:30eb\:30c8: \:30d1\:30b9\:30d9\:30fc\:30b9\:5224\:5b9a\:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af)\n" <>
  "  Missing[\"NoHeader\"] / Missing[\"NoRawHeader\"] - \:5185\:90e8\:30a8\:30e9\:30fc";

NBSetCloudPublishable::usage =
  "NBSetCloudPublishable[path, True|False, opts:OptionsPattern[]] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:81ea\:8eab\:306e\n" <>
  "\:30af\:30e9\:30a6\:30c9\:516c\:958b\:5ba3\:8a00\:3092\:8a2d\:5b9a\:3059\:308b (Notebook \:5168\:4f53\:306e TaggingRules > SourceVault > CloudPublishable)\:3002\n" <>
  "\:5ba3\:8a00\:8a2d\:5b9a\:5f8c\:306f\:30bb\:30eb\:6a5f\:5bc6\:30c1\:30a7\:30c3\:30af\:3068\:7d44\:307f\:5408\:308f\:3055\:308a\:3066 NBFileSpec \:306e PrivacyLevel \:304c\:81ea\:52d5\:7684\:306b\n" <>
  "0.4 / 0.5 / 1.0 / {0.5, 1.0} \:306b\:6c7a\:5b9a\:3055\:308c\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.7, ...|>    - \:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981 (default 0.7)\n" <>
  "  \"DryRun\" -> True|False                            - default False (\:30c8\:30b0\:30eb\:64cd\:4f5c\:306a\:306e\:3067\:5b9f\:884c\:5074)\n" <>
  "\:623b\:308a\:5024: NBWriteHeader \:3068\:540c\:5f62 (<|\"Status\" -> ..., \"Before\" -> _, \"After\" -> True|False, ...|>)";

NBClearCloudPublishable::usage =
  "NBClearCloudPublishable[path, opts:OptionsPattern[]] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30af\:30e9\:30a6\:30c9\:516c\:958b\:5ba3\:8a00\:3092\n" <>
  "\:300c\:672a\:6307\:5b9a\:300d\:72b6\:614b\:306b\:623b\:3059 (TaggingRules > SourceVault > CloudPublishable \:30ad\:30fc\:3092\:524a\:9664)\:3002\n" <>
  "\:524a\:9664\:5f8c SourceVault Association \:304c\:7a7a\:306b\:306a\:308c\:3070 SourceVault \:30ad\:30fc\:3082\:524a\:9664\:3001TaggingRules \:304c\n" <>
  "\:7a7a\:306b\:306a\:308c\:3070 TaggingRules \:30aa\:30d7\:30b7\:30e7\:30f3\:81ea\:4f53\:3082\:524a\:9664 (\:30af\:30ea\:30fc\:30f3\:30a2\:30c3\:30d7)\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"AccessSpec\" -> <|\"AccessLevel\" -> 0.7, ...|>    - \:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981 (default 0.7)\n" <>
  "  \"DryRun\" -> True|False                            - default False\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"DryRunOK\"|\"Failed\",\n" <>
  "  \"Before\" -> True|False|Missing[\"NotPresent\"], \"After\" -> Missing[\"Removed\"|\"NotPresent\"],\n" <>
  "  \"NoOp\" -> True (\:30ad\:30fc\:304c\:5143\:3005\:7121\:3044\:5834\:5408\:306e\:307f), \"Path\" -> _String|>";

NBSetNotebookPrivate::usage =
  "NBSetNotebookPrivate[nb] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5168\:4f53\:3092 Private (CloudPublishable -> False) \:5ba3\:8a00\:3057\:3001\n" <>
  "\:5168\:30bb\:30eb\:306e PrivacyLevel \:3092 1.0 \:306b\:3057\:3066\:30af\:30e9\:30a6\:30c9 LLM \:3078\:306e\:6295\:5165\:3092\:7981\:6b62\:3059\:308b\:3002\n" <>
  "\:30e9\:30a4\:30d6\:306e NotebookObject \:306b\:5373\:6642\:53cd\:6620\:3057 (\:4fdd\:5b58\:306a\:3057\:3067\:3082\:6709\:52b9)\:3001\:4fdd\:5b58\:6e08\:307f\:306a\:3089\n" <>
  "NBSetCloudPublishable \:3067\:30d5\:30a1\:30a4\:30eb\:30d8\:30c3\:30c0\:306b\:3082\:6c38\:7d9a\:5316\:3059\:308b\:3002\n" <>
  "NBSetNotebookPrivate[nb, False] \:3067\:5ba3\:8a00\:3092\:89e3\:9664\:3002\n" <>
  "NBSetNotebookPrivate[] \:306f EvaluationNotebook[] \:3092\:5bfe\:8c61\:306b\:3059\:308b\:3002";


(* \[HorizontalLine]\[HorizontalLine] .nb \:30d5\:30a1\:30a4\:30eb\:306e outline cache \:4fee\:5fa9 (Stage 9 P1 Step 2 Hotfix 4) \[HorizontalLine]\[HorizontalLine] *)

NBRepairNotebookCache::usage =
  "NBRepairNotebookCache[path] \:306f .nb \:30d5\:30a1\:30a4\:30eb\:306e outline cache \:3092\:6b63\:898f\:5316\:3059\:308b\:3002\n" <>
  "\:7528\:9014: \:300c\:5f00\:3053\:3046\:3068\:3057\:305f\:30d5\:30a1\:30a4\:30eb\:306f Wolfram \:30b7\:30b9\:30c6\:30e0\:5916\:3067\:7de8\:96c6\:3055\:308c\:305f\:3088\:3046\:3067\:3059\:300d\n" <>
  "\:30c0\:30a4\:30a2\:30ed\:30b0\:304c\:7e70\:308a\:8fd4\:3057\:51fa\:308b .nb \:3092\:30af\:30ea\:30fc\:30f3\:30a2\:30c3\:30d7\:3059\:308b\:3002frontend \:7d4c\:7531\:3067\n" <>
  "NotebookSave \:3092\:547c\:3076\:3068\:30d8\:30c3\:30c0\:306e NotebookDataLength / OutlinePosition / CellTagsIndexPosition\n" <>
  "\:7b49\:306e\:30d0\:30a4\:30c8\:4f4d\:7f6e\:30ad\:30e3\:30c3\:30b7\:30e5\:304c\:518d\:751f\:6210\:3055\:308c\:308b\:3002\n" <>
  "\:30d5\:30a1\:30a4\:30eb\:306e\:5185\:5bb9 (Notebook expression) \:306f\:5909\:308f\:3089\:306a\:3044\:3002\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\", \"Path\" -> _String, \"WasAlreadyOpen\" -> True|False|>";

NBRepairNotebookCacheFolder::usage =
  "NBRepairNotebookCacheFolder[dir, opts:OptionsPattern[]] \:306f dir \:914d\:4e0b\:306e .nb \:3092\:5168\:90e8\:4fee\:5fa9\:3059\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"Recursive\" -> True|False    - \:30b5\:30d6\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:3082\:30b9\:30ad\:30e3\:30f3 (default True)\n" <>
  "\:623b\:308a\:5024: <|\"Status\", \"Directory\", \"TotalFiles\", \"Succeeded\", \"Failed\", \"Details\"|>";

NBCleanupTmpFiles::usage =
  "NBCleanupTmpFiles[dir, opts:OptionsPattern[]] \:306f dir \:914d\:4e0b\:306e .nb.tmp-* \:6b8b\:9ab8\:3092\:524a\:9664\:3059\:308b\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3:\n" <>
  "  \"Recursive\" -> True|False    - \:30b5\:30d6\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:3082\:30b9\:30ad\:30e3\:30f3 (default True)\n" <>
  "\:623b\:308a\:5024: <|\"Status\", \"Directory\", \"Deleted\", \"Files\"|>";

NBRepairNotebookCacheStrict::usage =
  "NBRepairNotebookCacheStrict[path] \:306f NBRepairNotebookCache \:304c\:6548\:679c\:306a\:304b\:3063\:305f\:5834\:5408\:306e\n" <>
  "\:5f37\:529b\:7248 fallback\:3002\:30d5\:30a1\:30a4\:30eb\:3092 NotebookImport \:3067\:8aad\:307f\:3001CreateDocument \:3067\:65b0\:30ce\:30fc\:30c8\:3092\n" <>
  "\:4f5c\:6210\:3057\:3066 NotebookSave[..., path] \:3067\:5143\:30d1\:30b9\:306b\:4e0a\:66f8\:304d\:4fdd\:5b58\:3059\:308b\:3002\:5e2f\:540c\:30aa\:30d7\:30b7\:30e7\:30f3\n" <>
  "(TaggingRules\:7b49) \:3082\:53d6\:308a\:8fbc\:3080\:3002\:5b9f\:884c\:524d\:306b\:65e2\:306b\:958b\:304b\:308c\:3066\:3044\:308b\:30ce\:30fc\:30c8\:306f\:9589\:3058\:3089\:308c\:308b\:3002\n" <>
  "\:623b\:308a\:5024: <|\"Status\" -> \"OK\"|\"Failed\", \"Path\", \"Method\" -> \"RecreateAndSave\"|>";




NBAuditCodexAccessibleDirs::usage =
  "NBAuditCodexAccessibleDirs[dirs] audits the directories that would be exposed to ChatGPT Codex for files whose contents could exceed the Codex provider max access level (.env, *secret*, *credential*, *token*, private keys, API-key-like content). It is the mandatory gate before generating a Codex permission profile. Default behaviour is fail-stop: a Failure is returned when a dangerous file is found, so Codex is not started with that directory exposed. Options: \"MaxDepth\" (default Infinity, no depth limit; a finite limit that leaves part of the tree unscanned makes the audit fail-closed), \"OnDanger\" (\"Fail\" default | \"DenyAndContinue\" opt-in), \"ScanContents\" (default True), \"MaxFileScanBytes\". Returns <|\"Status\", \"Gate\", \"Findings\", \"AuditedDirs\", \"FileCount\", \"Truncated\", \"SuggestedDenyRules\"|> on pass or opt-in continue.";


(* ============================================================
   Phase A1 (ClaudeEval async-compat spec): Policy Snapshot API
   - main kernel \:306e\:52d5\:7684 NBAccess policy \:3092\:51cd\:7d50\:3057\:3001subkernel \:3078
     accessSpec \:7d4c\:7531\:3067\:6e21\:3059\:305f\:3081\:306e snapshot \:6a5f\:69cb\:3002
   - \:65b0\:898f\:8ffd\:52a0\:306e\:307f\:3002\:65e2\:5b58 head \:96c6\:5408\:30fbiRecomputeAllowedHeads \:7b49\:306e
     \:5b9a\:7fa9\:306b\:306f\:4e00\:5207\:89e6\:308c\:306a\:3044\:3002
   ============================================================ *)

NBPolicySnapshot::usage =
  "NBPolicySnapshot[] \:306f\:73fe\:5728\:306e NBAccess \:52d5\:7684 policy (\:5c0e\:51fa\:6e08\:307f AllowedHeads, ApprovalHeads, DenyHeads, ConfidentialSymbols) \:3092\:51cd\:7d50\:3057\:305f Association \:3092\:8fd4\:3059\:3002snapshot mode \:306e NBValidateHeldExpr / subkernel \:691c\:8a3c\:306f\:3053\:306e snapshot \:3092\:5224\:5b9a\:5165\:529b\:3068\:3057\:3001\:30ab\:30c6\:30b4\:30ea\:5b9a\:7fa9\:7cfb global \:3092\:53c2\:7167\:3057\:306a\:3044\:3002\:30ad\:30fc: \"SnapshotID\", \"CreatedAt\", \"NBAccessPolicyVersion\", \"AllowedHeads\", \"ApprovalHeads\", \"DenyHeads\", \"ConfidentialSymbols\", \"Digest\", \"Source\"\:3002";

NBAcceptPolicySnapshot::usage =
  "NBAcceptPolicySnapshot[snapshot] \:306f snapshot \:306e\:5fc5\:9808\:30ad\:30fc\:3068 Digest \:3092\:691c\:8a3c\:3057\:3001<|\"Valid\" -> True|False, \"Digest\" -> _, \"Reason\" -> _|> \:3092\:8fd4\:3059\:3002Digest \:306f NBPolicySnapshot \:751f\:6210\:6642\:3068\:540c\:4e00\:306e\:5185\:90e8 helper \:3067\:518d\:8a08\:7b97\:3057\:3066\:7167\:5408\:3059\:308b\:3002Valid \:306e\:3068\:304d subkernel \:5185 $NBActivePolicySnapshot \:306b\:4fdd\:5b58\:3057\:3066\:3088\:3044\:304c\:3001\:5b9f\:884c\:5224\:5b9a\:306e\:6b63\:672c\:306f\:5b9f\:884c\:3054\:3068\:306e accessSpec[\"PolicySnapshot\"] \:3068\:3059\:308b\:3002snapshot install \:306f\:8a31\:53ef\:62e1\:5f35\:306b\:4f7f\:3063\:3066\:306f\:306a\:3089\:306a\:3044\:3002";

$NBActivePolicySnapshot::usage =
  "$NBActivePolicySnapshot \:306f NBAcceptPolicySnapshot \:304c Valid \:3068\:5224\:5b9a\:3057\:305f\:6700\:65b0 snapshot \:3092\:4fdd\:6301\:3059\:308b (\:4e3b\:306b subkernel \:5074)\:3002\:53c2\:8003\:60c5\:5831\:3067\:3042\:308a\:3001\:5b9f\:884c\:5224\:5b9a\:306e\:6b63\:672c\:3067\:306f\:306a\:3044\:3002";

NBValidateNotebookPreActions::usage =
  "NBValidateNotebookPreActions[actions, accessSpec] \:306f PreExecutionNotebookActions \:306e\:30ea\:30b9\:30c8\:3092\:691c\:8a3c\:3057\:3001\:8a31\:53ef\:3055\:308c\:305f action \:3060\:3051\:3092\:8fd4\:3059\:3002P0 \:3067\:5fc5\:9808\:306e action \:306f \"MoveSelectionAfterNotebook\" (\:5185\:90e8\:5b9f\:88c5 SelectionMove[nb, After, Notebook])\:3002\:8a31\:53ef\:6761\:4ef6: action \:540d\:304c accessSpec[\"AllowedNotebookActions\"] \:306b\:542b\:307e\:308c\:3001MayUseFrontEnd/MayWriteNotebook \:304c True\:3001ExecutionKernel \:304c \"MainOnly\"\:3001Notebook \:304c target \:3068\:4e00\:81f4\:3059\:308b\:3053\:3068\:3002";

NBSubkernelExecutableQ::usage =
  "NBSubkernelExecutableQ[held, accessSpec] \:306f held \:304c subkernel \:3067\:5b89\:5168\:306b\:5b9f\:884c\:3067\:304d\:308b\:304b\:3092\:8fd4\:3059\:3002iShouldExecuteAsync \:306e\:6b63\:5f0f\:306a\:5224\:5b9a\:672c\:4f53\:3002False \:6761\:4ef6: ExecutionRole \:304c \"ProposalEval\" \:3067\:306a\:3044 / ExecutionKernel \:304c \"SubkernelAllowed\" \:3067\:306a\:3044 / MayUseFrontEnd\:30fbMayWriteNotebook\:30fbMayUseExternalProcess\:30fbMayUseNetwork \:306e\:3044\:305a\:308c\:304b\:304c True / ResultMayCrossKernel \:304c True \:3067\:306a\:3044 / PolicySnapshot \:304c\:7121\:52b9 / confidential \:53c2\:7167 / snapshot \:306e DenyHeads\:30fbApprovalHeads \:8a72\:5f53 head \:3092\:542b\:3080 / \:526f\:4f5c\:7528\:5019\:88dc head (NotebookWrite, SelectionMove, Import, Export, RunProcess, StartProcess, Evaluate \:7b49) \:3092\:542b\:3080\:3002$ClaudeRuntimeAsyncForce \:304c True \:3067\:3082\:5b89\:5168\:5224\:5b9a\:306f\:4e0a\:66f8\:304d\:3057\:306a\:3044\:3002";

NBExecuteHeldExprSubkernelRaw::usage =
  "NBExecuteHeldExprSubkernelRaw[held, accessSpec, opts] \:306f subkernel \:5c02\:7528\:306e\:5b9f\:884c wrapper\:3002\:623b\:308a\:5024\:306f\:751f\:306e\:8a55\:4fa1\:7d50\:679c / $TimedOut / $Failed (Association \:306f\:8fd4\:3055\:306a\:3044\:3002future shape \:7dad\:6301\:306e\:305f\:3081)\:3002snapshot \:691c\:8a3c\:30fbNBSubkernelExecutableQ\:30fbsnapshot \:57fa\:6e96\:306e\:518d\:691c\:8a3c\:3092\:3059\:3079\:3066\:901a\:904e\:3057 Decision \:304c Permit \:306e\:3068\:304d\:306e\:307f\:5185\:90e8\:3067 ReleaseHold \:3059\:308b\:3002Screen/NeedsApproval/Deny/RepairNeeded \:306f\:3059\:3079\:3066 $Failed (subkernel \:3067\:306f WarnOnly \:5b9f\:884c\:3092\:3057\:306a\:3044)\:3002TimeConstraint \:304c Infinity \:306e\:3068\:304d\:306f TimeConstrained \:3092\:4f7f\:308f\:306a\:3044\:3002";

NBMakeRuntimeAccessSpec::usage =
  "NBMakeRuntimeAccessSpec[contextPacket, role] \:306f Runtime/Orchestrator \:304b\:3089 NBAccess \:3078\:6e21\:3059 accessSpec \:3092\:4f5c\:308b\:3002role \:306f \"ProposalEval\" (\:65e2\:5b9a\:3001SubkernelAllowed)\:3001\"Committer\" (MainOnly, FE/\:66f8\:8fbc\:53ef, MoveSelectionAfterNotebook \:8a31\:53ef)\:3001\"VisionFallback\"\:3001\"ManualDispatch\"\:3002PolicySnapshot \:306f\:751f\:6210\:6642\:70b9\:306e policy \:3092 NBPolicySnapshot[] \:3067\:51cd\:7d50\:3057\:3066\:57cb\:3081\:308b\:3002contextPacket \:304b\:3089 ConfidentialSymbols/Secrets/Caller/WorkflowID/StepID/PermissionMode \:3092\:53d6\:308a\:8fbc\:3080\:3002";

$ClaudePermissionMode::usage =
  "$ClaudePermissionMode \:306f ClaudeEval/NBAccess \:5171\:901a\:306e\:6a29\:9650\:30e2\:30fc\:30c9 (spec 5B)\:3002\:5024: \"ReviewOnly\"(\:63d0\:6848\:306e\:307f)/\"StrictSafe\"(AutoPermit \:306e\:307f\:5b9f\:884c)/\"InteractiveSafe\"(\:6a19\:6e96\:3001AskUserAllowed \:306f\:627f\:8a8d UI)/\"WorkflowSafe\"(Orchestrator\:3001final node \:5206\:96e2)/\"LegacyInteractive\"/\"DangerFullAccess\"\:3002\:6a19\:6e96\:5024 InteractiveSafe\:3002\:5b9f\:884c\:4e2d\:306e\:5224\:5b9a\:3067\:306f accessSpec/snapshot \:306b\:713c\:304d\:8fbc\:3093\:3060\:5024\:3092\:6b63\:3068\:3057 global \:3092\:8aad\:307f\:76f4\:3055\:306a\:3044 (I12)\:3002";

$ClaudeAllowHardDenyOverride::usage =
  "$ClaudeAllowHardDenyOverride \:306f DangerFullAccess \:30e2\:30fc\:30c9\:3067\:306e\:307f\:610f\:5473\:3092\:6301\:3064\:3002True \:306e\:3068\:304d HardDeny \:76f8\:5f53 (Run/ExternalEvaluate/\:7834\:58ca\:7684 IO \:7b49) \:3092\:627f\:8a8d\:53ef\:80fd (NeedsApproval) \:3078\:6607\:683c\:3059\:308b\:3002\:65e2\:5b9a False (HardDeny \:306f\:627f\:8a8d\:3057\:3066\:3082\:5b9f\:884c\:3057\:306a\:3044)\:3002";

$ClaudeOutputMode::usage =
  "$ClaudeOutputMode \:306f ClaudeEval/NBAccess \:5171\:901a\:306e\:51fa\:529b\:30e2\:30fc\:30c9\:3002\:5024: \"Streaming\"(\:9010\:6b21\:3001\:65e2\:5b9a\:3002\:7d50\:679c\:304c\:51fa\:308b\:305f\:3073\:306b notebook \:3078\:51fa\:529b\:3002\:8a08\:7b97\:72b6\:6cc1\:304c\:898b\:3048\:308b)/\"Batch\"(\:96c6\:7d04\:3002notebook \:3078\:5373\:6642\:51fa\:529b\:305b\:305a\:30d0\:30c3\:30d5\:30a1\:306b\:6e9c\:3081\:3001\:6700\:5f8c\:306b\:307e\:3068\:3081\:3066\:51fa\:529b\:3002\:975e\:540c\:671f\:4e26\:5217\:306e\:591a\:6570\:51e6\:7406\:5411\:3051)\:3002\:6700\:512a\:5148\:4e8b\:9805\:306f FrontEnd/\:30ab\:30fc\:30cd\:30eb\:306e\:30d6\:30ed\:30c3\:30af\:56de\:907f\:3067\:3042\:308a\:3001BlockingRisk \:304c MayBlockFrontEnd \:306e\:51fa\:529b\:306f Streaming \:3067\:3082\:81ea\:52d5\:7684\:306b\:96c6\:7d04\:5074\:3078\:56de\:3059\:3002\:5358\:767a ClaudeEval (\:51fa\:529b1\:500b) \:3067\:306f Streaming/Batch \:3067\:7d50\:679c\:306f\:540c\:3058 (\:5b9f\:8cea\:7121\:5f71\:97ff)\:3002\:30de\:30eb\:30c1\:30bf\:30fc\:30f3/RepeatInterval/Orchestrator \:4e26\:5217\:3067\:5dee\:304c\:51fa\:308b\:3002\:5b9f\:884c\:4e2d\:306f accessSpec/runtime \:30e1\:30bf\:30c7\:30fc\:30bf\:306b\:713c\:304d\:8fbc\:3093\:3060\:5024\:3092\:6b63\:3068\:3059\:308b\:3002";

NBResolveOutputMode::usage =
  "NBResolveOutputMode[mode, blockingRisk] \:306f\:5b9f\:969b\:306b\:5373\:51fa\:529b (\"Immediate\") \:3059\:308b\:304b\:96c6\:7d04 (\"Deferred\") \:3059\:308b\:304b\:3092\:8fd4\:3059\:3002\:6700\:512a\:5148\:306f\:30d6\:30ed\:30c3\:30af\:56de\:907f: blockingRisk \:304c \"MayBlockFrontEnd\" \:306a\:3089 mode \:306b\:95a2\:308f\:3089\:305a \"Deferred\"\:3002mode \:304c \"Batch\" \:306a\:3089 \"Deferred\"\:3002\:305d\:308c\:4ee5\:5916\:306f \"Immediate\"\:3002";

$NBEffectClassOverrides::usage =
  "$NBEffectClassOverrides \:306f head \:540d -> <|EffectClass, BlockingRisk, ExecutionPlacement, RequiresFinalNode|> \:306e\:4efb\:610f\:4e0a\:66f8\:304d\:30c6\:30fc\:30d6\:30eb (spec 5B.5A)\:3002allowlist \:3067\:306f\:306a\:304f\:5206\:985e\:7cbe\:5ea6\:5411\:4e0a\:7528\:3002\:672a\:767b\:9332 head \:306f\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:5206\:985e (System` \:7d14\:7c8b -> PureComputation \:7b49) \:306b\:9032\:3080\:3002";

$NBTrustedPackageHeads::usage =
  "$NBTrustedPackageHeads \:306f\:300cpackage \:6587\:8108\:3060\:304c\:627f\:8a8d\:4e0d\:8981\:3068\:307f\:306a\:3059 head\:300d\:306e\:767b\:9332\:30c6\:30fc\:30d6\:30eb (<|context -> {\:540d\:524d\:30d1\:30bf\:30fc\:30f3...}|>)\:3002\:65e2\:5b9a <|\"SourceVault`\" -> {\"SourceVault*\"}|>\:3002SourceVault* \:516c\:958b\:95a2\:6570\:306f\:5168\:7d4c\:8def\:3067 PrivacyLevel \:3092\:8003\:616e\:3057\:305f\:5b89\:5168\:8a2d\:8a08 (release gate / fail-closed / \:627f\:8a8d\:306f\:95a2\:6570\:5185\:90e8\:306e gate \:304c\:62c5\:3046) \:306e\:305f\:3081\:3001unknown-head \:627f\:8a8d\:3092\:514d\:9664\:3059\:308b\:3002$NBDenyHeads / $NBApprovalHeads \:306e\:660e\:793a\:767b\:9332\:306f\:3053\:306e\:4fe1\:983c\:3088\:308a\:512a\:5148\:3055\:308c\:308b (deny/approval \:30c1\:30a7\:30c3\:30af\:304c\:5148\:306b\:8d70\:308b)\:3002\:904e\:5270\:5b9f\:884c\:306f $NBTrustedHeadIterationLimit \:306e\:9759\:7684 guard \:3068 SourceVault \:5074 SourceVaultRateLimit \:306e\:5b9f\:884c\:6642 guard \:3067\:4fdd\:8b77\:3059\:308b\:3002";

$NBTrustedHeadIterationLimit::usage =
  "$NBTrustedHeadIterationLimit \:306f trusted package head \:3092\:542b\:3080\:53cd\:5fa9\:69cb\:9020 (Do/Table/For/Nest/Map over Range \:7b49) \:306e literal \:53cd\:5fa9\:6570\:304c\:3053\:306e\:5024\:4ee5\:4e0a\:306e\:3068\:304d NeedsApproval \:306b\:6607\:683c\:3055\:305b\:308b\:95be\:5024 (\:65e2\:5b9a 100)\:3002SourceVaultIngest \:3092 1 \:4e07\:56de\:547c\:3076\:3088\:3046\:306a\:751f\:6210\:30b3\:30fc\:30c9\:306e\:904e\:5270\:5b9f\:884c\:5bfe\:7b56\:3002";

NBRegisterAction::usage =
  "NBRegisterAction[name, spec] \:306f\:627f\:8a8d\:5bfe\:8c61\:64cd\:4f5c (desktop/notebook/filesystem) \:3092 action registry \:306b\:767b\:9332\:3059\:308b (spec 5B.8)\:3002spec \:30ad\:30fc: EffectClass, DefaultApprovalEligibility, AllowedTargetTypes, RequiresFinalNode, Validator, Executor\:3002raw head \:3092\:4e71\:7acb\:3055\:305b\:305a\:6c4e\:7528 action \:306b\:5bc4\:305b\:308b\:305f\:3081\:306e\:4ed5\:7d44\:307f\:3002";

NBValidateAction::usage =
  "NBValidateAction[action, accessSpec] \:306f action association \:3092 registry \:306e Validator + PermissionMode \:5909\:63db\:3067\:691c\:8a3c\:3057 Decision \:3092\:8fd4\:3059\:3002\:8fd4\:308a\:5024\:306f NBValidateHeldExpr \:3068\:540c\:5f62 (Decision/ApprovalEligibility/EffectClass/AllowApprovalUI/MayExecute \:7b49)\:3002";

NBExecuteApprovedAction::usage =
  "NBExecuteApprovedAction[action, accessSpec, opts] \:306f\:627f\:8a8d\:6e08\:307f action \:3092\:5b9f\:884c\:3059\:308b\:3002\:5b9f\:884c\:76f4\:524d\:306b\:518d validate \:3057 (TOCTOU \:5bfe\:7b56)\:3001\:627f\:8a8d\:5f8c\:306b path/target \:304c\:5909\:5316\:3057\:3066\:3044\:308c\:3070 PostApprovalValidationFailed \:3067\:62d2\:5426\:3002registry \:306e Executor \:306f NBAccess \:5185\:90e8\:306b\:3042\:308a\:3001raw SystemOpen \:7b49\:306f\:3053\:306e executor \:3060\:3051\:304c\:547c\:3076 (I1/I2)\:3002";

NBOpenFolderWithApproval::usage =
  "NBOpenFolderWithApproval[path] \:306f OpenDesktopItem action (TargetType Folder) \:306e\:8584\:3044\:4e92\:63db wrapper\:3002\:6b63\:672c\:306f action registry + permission mode\:3002";

NBEnqueueFinalAction::usage =
  "NBEnqueueFinalAction[action, accessSpec, opts] \:306f\:627f\:8a8d\:6e08\:307f final action (FrontEnd \:30d6\:30ed\:30c3\:30af\:30ea\:30b9\:30af\:306e\:3042\:308b desktop/notebook \:64cd\:4f5c) \:3092 PendingFinalActionQueue \:306b\:7a4d\:3080 (spec \:68483-lite)\:3002\:76f4\:63a5\:540c\:671f\:5b9f\:884c\:305b\:305a\:3001\:5171\:6709 polling tick \:304c\:5b89\:5168\:6761\:4ef6\:3092\:6e80\:305f\:3057\:305f\:3068\:304d 1 \:4ef6\:305a\:3064\:5b9f\:884c\:3059\:308b\:3002ActionID \:3092\:8fd4\:3059\:3002";

NBFinalActionTick::usage =
  "NBFinalActionTick[] \:306f\:5171\:6709 polling tick \:304b\:3089\:547c\:3070\:308c\:3001PendingFinalActionQueue \:306e\:5b89\:5168\:6761\:4ef6\:3092\:78ba\:8a8d\:3057\:3066\:6700\:5927 1 \:4ef6\:3060\:3051\:5b9f\:884c\:3059\:308b\:3002\:65b0\:898f ScheduledTask \:306f\:4f5c\:3089\:306a\:3044\:3002\:5b89\:5168\:6761\:4ef6: AsyncActive \:3067\:306a\:3044 / final action \:5b9f\:884c\:4e2d\:3067\:306a\:3044 / \:627f\:8a8d\:6e08\:307f / \:518d validate \:6210\:529f / \:671f\:9650\:5185\:3002";

NBFinalActionStatus::usage =
  "NBFinalActionStatus[actionID] \:306f queue item \:306e\:72b6\:614b\:3092\:8fd4\:3059\:3002actionID \:7701\:7565\:6642\:306f\:5168 item\:3002\:72b6\:614b: Pending/Running/Completed/Failed/Expired/Cancelled/NeedsRetryAfterAsync\:3002";

NBCancelFinalAction::usage =
  "NBCancelFinalAction[actionID] \:306f queue item \:3092 Cancelled \:306b\:3059\:308b\:3002";

NBFinalActionQueueSnapshot::usage =
  "NBFinalActionQueueSnapshot[] \:306f queue \:5168\:4f53\:306e snapshot \:3092\:8fd4\:3059 (debug/Doctor \:7528)\:3002";

NBFinalActionRunningQ::usage =
  "NBFinalActionRunningQ[] \:306f Running \:72b6\:614b\:306e final action \:304c\:3042\:308b\:304b\:8fd4\:3059\:3002";

$NBFinalActionAsyncActiveFunction::usage =
  "$NBFinalActionAsyncActiveFunction \:306f AsyncActive \:5224\:5b9a\:306e callback\:3002Automatic \:306e\:3068\:304d ClaudeRuntime \:304c\:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089 ClaudeRuntimeAsyncActiveQ \:3092\:4f7f\:3044\:3001\:672a\:30ed\:30fc\:30c9\:306a\:3089 False\:3002NBAccess \:5358\:4f53\:30c6\:30b9\:30c8\:3067\:306f\:95a2\:6570\:3092\:5dee\:3057\:66ff\:3048\:3066 queue \:57fa\:76e4\:3092\:72ec\:7acb\:691c\:8a3c\:3067\:304d\:308b\:3002";

(* === External job cooperative I/O guards (Phase 4.B, v7 \[Section]13/\[Section]16) === *)

NBCheckFileRead::usage =
  "NBCheckFileRead[path, accessSpec] \:306f path \:306e\:8aad\:307f\:53d6\:308a\:304c accessSpec \:306e MayAccessFileSystem / AllowedDirectories scope \:5185\:304b\:691c\:67fb\:3057 <|\"Allowed\"->_, \"Reason\"->_|> \:3092\:8fd4\:3059\:3002";
NBCheckFileWrite::usage =
  "NBCheckFileWrite[path, accessSpec] \:306f path \:3078\:306e\:66f8\:304d\:8fbc\:307f\:304c scope \:5185\:304b\:691c\:67fb\:3059\:308b\:3002";
NBCheckNetworkAccess::usage =
  "NBCheckNetworkAccess[target, accessSpec] \:306f target (URL \:6587\:5b57\:5217\:307e\:305f\:306f <|Scheme,Host,Port|>) \:304c AllowedNetworkTargets scope \:5185\:304b\:691c\:67fb\:3059\:308b\:3002";
NBCheckExternalProcess::usage =
  "NBCheckExternalProcess[cmd, accessSpec] \:306f\:5916\:90e8\:30b3\:30de\:30f3\:30c9\:304c AllowedExternalCommands \:5185\:304b\:691c\:67fb\:3059\:308b\:3002";
NBCheckedImport::usage = "NBCheckedImport[path, fmt, accessSpec] \:306f NBCheckFileRead \:901a\:904e\:5f8c\:306b Import \:3059\:308b\:3002\:9055\:53cd\:6642\:306f AccessSpecViolation \:3092\:8fd4\:3059\:3002";
NBCheckedExport::usage = "NBCheckedExport[path, expr, fmt, accessSpec] \:306f NBCheckFileWrite \:901a\:904e\:5f8c\:306b Export \:3059\:308b\:3002";
NBCheckedURLRead::usage = "NBCheckedURLRead[url, accessSpec] \:306f NBCheckNetworkAccess \:901a\:904e\:5f8c\:306b URLRead \:3059\:308b\:3002";
NBCheckedFileWrite::usage = "NBCheckedFileWrite[path, content, accessSpec] \:306f NBCheckFileWrite \:901a\:904e\:5f8c\:306b\:66f8\:304d\:8fbc\:3080\:3002";
NBCheckedFileRead::usage = "NBCheckedFileRead[path, accessSpec] \:306f NBCheckFileRead \:901a\:904e\:5f8c\:306b\:8aad\:307f\:53d6\:308b\:3002";
NBApplyPolicySnapshot::usage =
  "NBApplyPolicySnapshot[snapshot] \:306f snapshot \:306e digest \:3092\:691c\:8a3c\:3057\:3001\:6b63\:898f\:5316\:3057\:305f snapshot \:3092\:8fd4\:3059 (P0 \[Section]8.3: global \:5fa9\:5143\:306f\:305b\:305a accessSpec \:6ce8\:5165\:306e\:88dc\:52a9\:306b\:9650\:5b9a)\:3002<|\"Valid\"->_, \"Snapshot\"->_, \"Reason\"->_|>\:3002";
NBConfidentialHandlingAllowedQ::usage =
  "NBConfidentialHandlingAllowedQ[mode, permissionMode] \:306f ConfidentialHandling mode (EncryptedBundle/ReferenceOnly/Redacted/PlaintextDebug) \:304c\:5f53\:8a72 permissionMode \:3067\:8a31\:5bb9\:3055\:308c\:308b\:304b (PlaintextDebug gate, v7 \[Section]13D.1) \:3092\:8fd4\:3059\:3002";
NBResolveCredentialRef::usage =
  "NBResolveCredentialRef[ref, accessSpec] \:306f credential-ref \:3092\:89e3\:6c7a\:3057\:3001secret \:672c\:4f53\:3067\:306f\:306a\:304f\:53d6\:5f97\:7528 descriptor (<|\"Provider\"->_, ...|>) \:3092\:8fd4\:3059\:3002handler \:306f\:3053\:306e descriptor \:3067 NBGetAPIKey \:3092\:547c\:3076 (rules/20: \:9375\:3092\:8fd4\:3059\:88dc\:52a9\:95a2\:6570\:3092\:4f5c\:3089\:306a\:3044)\:3002";

(* === Calendar access (iCal/ICS), access-level gated === *)

NBCalendarEvents::usage =
  "NBCalendarEvents[from, to, opts] reads the owner's iCal/ICS calendar and returns \
event occurrences overlapping [from, to) as a list of Associations sorted by Start. \
Recurring events (RRULE) are expanded to individual occurrences (FREQ DAILY/WEEKLY/\
MONTHLY/YEARLY, INTERVAL, UNTIL, COUNT, BYDAY incl. ordinal like 2MO, BYMONTHDAY incl. \
negative, EXDATE, RECURRENCE-ID overrides incl. cancelled instances). This fixes the \
legacy NotebookExtensions`calendardata recurrence bugs (single-offset expansion, \
ignored INTERVAL, approximate month arithmetic, unhandled DAILY/COUNT/BYDAY/EXDATE). \
Returned fields depend on the caller's access level (PrivacySpec option, default \
$NBPrivacySpec): >=0.5 free/busy + identity metadata only (Start/End/AllDay/Busy/\
Mandatory/Recurring/UIDDigest + R0b identity: EventId/OriginalStart/SemanticDigest/\
ObservedRevision), >=0.7 adds Summary/Categories/Status, >=1.0 full fields \
(Description/Location/UID). Below 0.5 returns Failure[\"NBCalendarAccessDenied\"]. \
R0b identity/revision fields (returned at EVERY level, all opaque): \"EventId\" = \
HMAC-keyed stable id of the UID ($NBCalendarIdentityKeyRef; unkeyed fallback) \[Dash] \
same across recurring occurrences; \"OriginalStart\" = the occurrence's original \
series slot (RECURRENCE-ID for overrides, generated slot otherwise; a MOVED start \
appears only in Start, not here) \[Dash] the stable per-occurrence token; \
\"SemanticDigest\" = digest of the behaviour-bearing fields (OriginalStart, effective \
Start/End, Status, Busy, AllDay) for supersede detection; \"ObservedRevision\" = \
digest of SEQUENCE/DTSTAMP (observation-only; a DTSTAMP-only change does NOT change \
SemanticDigest). Options: PrivacySpec -> Automatic ($NBPrivacySpec), \"Source\" -> \
Automatic (SystemCredential[$NBCalendarCredentialName]; or an explicit .ics path / \
http(s) URL), \"ICSText\" -> raw ICS text (injection seam for tests; bypasses Source), \
\"MandatoryPatterns\" -> Automatic ($NBCalendarMandatoryPatterns; string patterns \
matched case-insensitively against Summary/Categories/Description to set the \
Mandatory flag, which survives all access levels), \"MaxEvents\" -> 500, \
\"Refresh\" -> False (bypass the parse cache), \"Wrap\" -> False (when True, return \
<|\"Events\"->{...}, \"ObservedAtUTC\", \"Count\", \"Truncated\", \"Completeness\" \
(<1 when MaxEvents truncated), \"IdentityKeyed\"|> instead of a bare list).";

NBCalendarFreeBusy::usage =
  "NBCalendarFreeBusy[from, to, opts] returns merged busy blocks (overlapping busy \
occurrences coalesced) in [from, to) as {<|\"Start\", \"End\", \"Mandatory\", \
\"Count\"|>...}. Events with TRANSP:TRANSPARENT are excluded. Content-free \
(metadata only), available from AccessLevel 0.5. Same source options as \
NBCalendarEvents.";

NBCalendarBusyQ::usage =
  "NBCalendarBusyQ[t, opts] returns True when instant t falls inside a busy calendar \
block (meeting in progress). \"Detailed\" -> True returns <|\"Busy\", \"Mandatory\", \
\"Block\"|> instead. Returns False (not Failure) when the source is unavailable, so \
notification gating fails open to 'not busy'. Same source options as NBCalendarEvents.";

NBICSParseEvents::usage =
  "NBICSParseEvents[icsText] parses raw iCal/ICS text into a list of event \
Associations (UID/Summary/Description/Location/Status/Categories/Busy/Start/End/\
AllDay/RRule/ExDates/RecurrenceId). Pure parser: no credential, network, or access \
gating; malformed VEVENT blocks are skipped. Handles folded lines, TEXT escapes, \
TZID/UTC/floating and VALUE=DATE (all-day) date forms, and DURATION.";

NBICSEventOccurrences::usage =
  "NBICSEventOccurrences[event, from, to] expands one parsed event (from \
NBICSParseEvents) into its occurrences overlapping [from, to), applying the RRULE/\
EXDATE semantics described in NBCalendarEvents. Pure; returns a list of event \
Associations with occurrence Start/End and \"Recurring\" -> True|False.";

$NBCalendarMandatoryPatterns::usage =
  "$NBCalendarMandatoryPatterns is the default list of string patterns marking a \
calendar event as attendance-mandatory (matched case-insensitively against Summary/\
Categories/Description). Default {}. The owner sets this at runtime; the derived \
Mandatory flag is exposed at every access level.";

$NBCalendarCacheSeconds::usage =
  "$NBCalendarCacheSeconds is the in-memory parse-cache TTL (seconds) for calendar \
sources read by NBCalendarEvents. Default 300.";

$NBCalendarCredentialName::usage =
  "$NBCalendarCredentialName is the SystemCredential key holding the ICS calendar \
location (file path or URL). Default \"ics-calendar\".";

(* === $onWork task metadata (access-level gated, NON-EVALUATING read) === *)

NBOnWorkTaskSafeExtract::usage =
  "NBOnWorkTaskSafeExtract[held] extracts a $onWork notebook's task metadata from a \
HELD expression (HoldComplete[...] or Hold[...] wrapping the metadata Association, \
or a list whose first element is it) WITHOUT EVALUATING ANYTHING (routine spec 3.3 \
/ P1-2 / AC-013). Only whitelisted string keys (Title/Status/Deadline/NextReview/\
EventDate/Keywords/Effort/Movable/DependsOn/TaskId) with literal values (String, \
Integer, Real, True/False, DateObject[{ints..},(gran)], Quantity[num,unit], list of \
strings) are kept; every other key/value is dropped. Side-effect expressions, \
Notebook boxes, huge expressions and UpValue symbols are never evaluated. The \
implementation contains NO ReleaseHold (static AC-033). Returns a safe Association.";

NBOnWorkTasks::usage =
  "NBOnWorkTasks[opts] enumerates $onWork .nb files and returns access-level-\
projected task records read via NBOnWorkTaskSafeExtract (metadata ONLY: the \
notebook body/output is never read at any level). Each record derives \"Due\" \
(Deadline, else NextReview; a NextReview Quantity is resolved as ModificationDate + \
offset, matching NotebookExtensions) and \"State\" (Done/Pass/Keep from Status, else \
Open). Fields by access level: 0.5 = Due/DueKind/State/FileDigest/ModificationDate; \
0.7 adds Title/Keywords/TaskId/Effort/Movable/DependsOn; 1.0 adds Path. Options: \
\"Directory\" -> Automatic (Global`$onWork), \"ModifiedWithinDays\" -> Automatic \
(all), \"IncludeDone\" -> False (drop Status Done/Pass), PrivacySpec -> Automatic, \
\"MaxFiles\" -> 2000, \"Files\" -> Automatic (test seam: a list of <|\"Path\"->_, \
\"Held\"->HoldComplete[...], (\"ModificationDate\"->_)|> bypassing the filesystem). A \
file that is unreadable or whose metadata fails the safe parse becomes a record with \
\"State\"->\"Unknown\" and \"ParseFailed\"->True; it never aborts the whole scan.";

$NBCalendarIdentityKeyRef::usage =
  "$NBCalendarIdentityKeyRef is the SystemCredential key holding the HMAC identity \
key used to derive each event's opaque, stable \"EventId\" (routine spec R0b, \
kept SEPARATE from any signing/MAC key). The EventId is returned at EVERY access \
level so a caller at AccessLevel 0.5 gets stable identity without the raw UID. \
Default Missing[\"None\"]: when unset, EventId degrades to a non-keyed \
\"unkeyed:<digest>\" form and NBCalendarEvents \"Wrap\"->True reports \
\"IdentityKeyed\"->False. Rotating the key changes the embedded KeyId, so \
callers must migrate their stored EventId mappings (routine spec P0-1).";

(* ============================================================
   \:30c7\:30a3\:30d5\:30a9\:30eb\:30c8\:5024
   ============================================================ *)

(* \:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb 0.5 = \:30af\:30e9\:30a6\:30c9LLM\:5b89\:5168\:306a\:30c7\:30fc\:30bf\:306e\:307f *)
If[!AssociationQ[NBAccess`$NBPrivacySpec],
  NBAccess`$NBPrivacySpec = <|"AccessLevel" -> 0.5|>];

(* \:79d8\:5bc6\:5909\:6570\:540d -> \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb (0.0..1.0) *)
If[!AssociationQ[NBAccess`$NBConfidentialSymbols],
  NBAccess`$NBConfidentialSymbols = <||>];

(* \:79d8\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf\:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:9001\:4fe1\:30d5\:30e9\:30b0 (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8 True) *)
If[NBAccess`$NBSendDataSchema =!= False,
  NBAccess`$NBSendDataSchema = True];

(* NBAccess \:8a73\:7d30\:30ed\:30b0\:51fa\:529b\:30d5\:30e9\:30b0 (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8 False: \:91cd\:5927\:30a8\:30e9\:30fc\:4ee5\:5916\:306e\:30ed\:30b0\:3092\:6291\:5236) *)
If[NBAccess`$NBVerbose =!= True,
  NBAccess`$NBVerbose = False];

(* AutoEvaluate \:7981\:6b62\:30d1\:30bf\:30fc\:30f3 (\:30c7\:30a3\:30d5\:30a9\:30eb\:30c8 \:7a7a: ClaudeCode \:304c\:30ed\:30fc\:30c9\:6642\:306b\:767b\:9332) *)
If[!ListQ[NBAccess`$NBAutoEvalProhibitedPatterns],
  NBAccess`$NBAutoEvalProhibitedPatterns = {}];

(* \:5206\:96e2\:691c\:67fb\:3067\:7121\:8996\:3059\:308b\:30d1\:30c3\:30b1\:30fc\:30b8\:540d\:30ea\:30b9\:30c8 *)
If[!ListQ[NBAccess`$NBSeparationIgnoreList],
  NBAccess`$NBSeparationIgnoreList = {"NBAccess", "NotebookExtensions"}];

(* LLM \:30b3\:30fc\:30eb\:30d0\:30c3\:30af: ClaudeCode \:304c\:30ed\:30fc\:30c9\:6642\:306b\:767b\:9332\:3059\:308b\:3002\:672a\:767b\:9332\:6642\:306f None\:3002 *)
If[!MatchQ[NBAccess`$NBLLMQueryFunc, _Function | _Symbol],
  NBAccess`$NBLLMQueryFunc = None];

(* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:30ea\:30b9\:30c8: {{provider, model}, {provider, model, url}, ...} *)
If[!ListQ[$iFallbackModels],
  $iFallbackModels = {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5.5"}}];

(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:5225\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb: \:672a\:767b\:9332\:306f 0.5 *)
If[!AssociationQ[$iProviderMaxAccessLevel],
  $iProviderMaxAccessLevel = <|
    "claudecode" -> 0.5,
    "anthropic"  -> 0.5,
    "openai"     -> 0.5,
    "zai"        -> 0.25,
    "lmstudio"   -> 1.0
  |>];

(* ============================================================
   \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: \:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9 \[RightArrow] CellObject \:89e3\:6c7a
   $iCellsCache \:306b\:3088\:308a Cells[nb] \:306e FrontEnd round-trip \:3092\:30ad\:30e3\:30c3\:30b7\:30e5\:3002
   iPrecisionConfidentialCheck \:7b49\:306e\:91cd\:3044\:8d70\:67fb\:3067\:6570\:5343\:56de\:306e Cells[] \:547c\:3073\:51fa\:3057\:3092
   NB\:6570\:56de\:ff085NB \:306a\:3089 5\:56de\:ff09\:306b\:524a\:6e1b\:3059\:308b\:3002
   ============================================================ *)

$iCellsCache = <||>;
$iCellStyleCache = <||>;

(* Phase 4.3: NBFileSpec caches.
   Base cache depends only on file content metadata.
   Projection cache additionally depends on policy fingerprint. *)
If[!AssociationQ[$iNBFileSpecBaseCache], $iNBFileSpecBaseCache = <||>];
If[!AssociationQ[$iNBFileSpecProjectionCache], $iNBFileSpecProjectionCache = <||>];
If[!IntegerQ[$iNBFileProjectionPolicyVersion], $iNBFileProjectionPolicyVersion = 1];

iResolveCells[nb_NotebookObject] :=
  Module[{cached},
    cached = Lookup[$iCellsCache, nb, None];
    If[ListQ[cached], Return[cached]];
    cached = Quiet[Cells[nb]];
    If[ListQ[cached], $iCellsCache[nb] = cached, cached = {}];
    cached];

(* \:5168\:30bb\:30eb\:306e\:30b9\:30bf\:30a4\:30eb\:3092\:4e00\:62ec\:53d6\:5f97\:3057\:3066\:30ad\:30e3\:30c3\:30b7\:30e5 *)
iResolveCellStyles[nb_NotebookObject] :=
  Module[{cached, cells, styles},
    cached = Lookup[$iCellStyleCache, nb, None];
    If[ListQ[cached], Return[cached]];
    cells = iResolveCells[nb];
    styles = Map[
      Module[{s = Quiet[CurrentValue[#, CellStyle]]},
        Which[StringQ[s], s, ListQ[s] && Length[s] > 0, First[s], True, ""]] &,
      cells];
    $iCellStyleCache[nb] = styles;
    styles];

iResolveCell[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cells = iResolveCells[nb]},
    If[cellIdx < 1 || cellIdx > Length[cells],
      $Failed, cells[[cellIdx]]]
  ];

(* \:30ad\:30e3\:30c3\:30b7\:30e5\:7121\:52b9\:5316 *)
NBAccess`NBInvalidateCellsCache[] := (
  $iCellsCache = <||>; $iCellStyleCache = <||>);
NBAccess`NBInvalidateCellsCache[nb_NotebookObject] := (
  $iCellsCache = KeyDrop[$iCellsCache, nb];
  $iCellStyleCache = KeyDrop[$iCellStyleCache, nb]);

(* \:30e6\:30fc\:30b6\:30fc\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:307f\:53d6\:5f97:
   Notebooks[] \:306f\:30d1\:30ec\:30c3\:30c8\:3001\:30d8\:30eb\:30d7\:30d6\:30e9\:30a6\:30b6\:3001\:30c0\:30a4\:30a2\:30ed\:30b0\:7b49\:306e\:30b7\:30b9\:30c6\:30e0NB\:3082\:542b\:3080\:3002
   \:3053\:308c\:3089\:306b Cells[] \:3084 CurrentValue \:3092\:547c\:3076\:3068 FrontEnd \:304c\:30d6\:30ed\:30c3\:30af/\:30d5\:30ea\:30fc\:30ba\:3059\:308b\:3002
   WindowFrame \:304c "Normal" \:306eNB\:306e\:307f\:3092\:5b89\:5168\:306b\:8d70\:67fb\:5bfe\:8c61\:3068\:3059\:308b\:3002 *)
NBAccess`NBUserNotebooks[] :=
  Module[{allNBs, result = {}},
    allNBs = Quiet[Notebooks[]];
    If[!ListQ[allNBs], Return[{}]];
    Do[
      Quiet @ Module[{frame},
        frame = CurrentValue[nbx, WindowFrame];
        If[frame === "Normal", AppendTo[result, nbx]]],
    {nbx, allNBs}];
    result
  ];

iUserNotebooks[] := NBAccess`NBUserNotebooks[];

(* \:30b9\:30de\:30fc\:30c8\:30ea\:30d5\:30ec\:30c3\:30b7\:30e5: \:5909\:5316\:306e\:306a\:3044NB\:306e\:30ad\:30e3\:30c3\:30b7\:30e5\:3092\:4fdd\:6301\:3002
   \:8fd4\:308a\:5024: \:5909\:5316\:304c\:3042\:3063\:305fNB\:306e NotebookObject \:30ea\:30b9\:30c8\:3002
   \:5224\:5b9a\:65b9\:6cd5:
     1. CurrentValue[nb, "ModifiedInMemory"] \:304c False \[RightArrow] \:5b8c\:5168\:30b9\:30ad\:30c3\:30d7 (0 FE call\:8ffd\:52a0)
     2. Cells[nb] \:30ea\:30b9\:30c8\:304c\:524d\:56de\:3068\:540c\:4e00 \[RightArrow] \:30ad\:30e3\:30c3\:30b7\:30e5\:4fdd\:6301 (1 FE call)
     3. \:305d\:308c\:4ee5\:5916 \[RightArrow] \:30ad\:30e3\:30c3\:30b7\:30e5\:66f4\:65b0 (1 FE call + N CellStyle calls) *)
NBAccess`NBRefreshCellsCache[] :=
  Module[{allNBs, freshCells, cachedCells, changedNBs = {}, activeSet},
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[{}]];
    (* \:9589\:3058\:3089\:308c\:305fNB\:306e\:30ad\:30e3\:30c3\:30b7\:30e5\:3092\:9664\:53bb *)
    activeSet = Association[# -> True & /@ allNBs];
    $iCellsCache = KeySelect[$iCellsCache, KeyExistsQ[activeSet, #] &];
    $iCellStyleCache = KeySelect[$iCellStyleCache, KeyExistsQ[activeSet, #] &];
    Do[
      (* \:672a\:5909\:66f4\:30c1\:30a7\:30c3\:30af: \:4fdd\:5b58\:6e08\:307f + \:7de8\:96c6\:306a\:3057 \[RightArrow] FE call \:306a\:3057\:3067\:30b9\:30ad\:30c3\:30d7 *)
      If[Quiet[CurrentValue[nbx, "ModifiedInMemory"]] === False &&
         KeyExistsQ[$iCellsCache, nbx],
        Continue[]];
      (* Cells[] \:3092\:53d6\:5f97\:3057\:3066\:524d\:56de\:3068\:6bd4\:8f03 *)
      freshCells = Quiet[Cells[nbx]];
      If[!ListQ[freshCells], Continue[]];
      cachedCells = Lookup[$iCellsCache, nbx, None];
      If[ListQ[cachedCells] && freshCells === cachedCells,
        (* CellObject \:30ea\:30b9\:30c8\:304c\:5b8c\:5168\:4e00\:81f4 \[RightArrow] \:30bb\:30eb\:306e\:8ffd\:52a0/\:524a\:9664\:306a\:3057 \[RightArrow] \:30ad\:30e3\:30c3\:30b7\:30e5\:4fdd\:6301 *)
        Null,
        (* \:5909\:5316\:3042\:308a \[RightArrow] \:30ad\:30e3\:30c3\:30b7\:30e5\:66f4\:65b0 *)
        $iCellsCache[nbx] = freshCells;
        $iCellStyleCache = KeyDrop[$iCellStyleCache, nbx];
        AppendTo[changedNBs, nbx]],
    {nbx, allNBs}];
    changedNBs
  ];

(* ============================================================
   \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: PrivacySpec \:89e3\:6c7a
   ============================================================ *)

iResolvePS[Automatic]       := NBAccess`$NBPrivacySpec;
iResolvePS[ps_Association]  := ps;
iResolvePS[_]               := NBAccess`$NBPrivacySpec;

iAccessLevel[ps_] := Lookup[iResolvePS[ps], "AccessLevel", 0.5];

(* ============================================================
   \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: TaggingRules \:304b\:3089\:79d8\:5bc6\:30bf\:30b0\:3092\:8aad\:307f\:51fa\:3059
   ============================================================ *)

iGetConfTag[cell_CellObject] :=
  Module[{tags, cc},
    tags = Quiet[CurrentValue[cell, TaggingRules]];
    If[!MatchQ[tags, _List | _Association], Return[Missing[]]];
    cc = Lookup[tags, "claudecode", {}];
    If[!MatchQ[cc, _List | _Association], Return[Missing[]]];
    Replace[Lookup[cc, "confidential", Missing[]], Except[True | False] -> Missing[]]
  ];

(* ============================================================
   \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: \:79d8\:5bc6\:5909\:6570\:53c2\:7167\:30c1\:30a7\:30c3\:30af (CellObject\:7248\:3001\:5185\:90e8\:7528)
   ============================================================ *)

iCellUsesConfSymbol[nb_NotebookObject, cell_CellObject] :=
  Module[{text, names},
    If[Length[NBAccess`$NBConfidentialSymbols] === 0, Return[False]];
    text = Quiet[NBAccess`NBCellExprToText[Quiet[NotebookRead[cell]]]];
    If[!StringQ[text] || StringLength[text] === 0, Return[False]];
    names = Keys[NBAccess`$NBConfidentialSymbols];
    AnyTrue[names,
      StringContainsQ[text, RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <> "(?![\\p{L}\\p{N}$])"]] &]
  ];

(* ============================================================
   \:30bb\:30eb\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3 API (\:65b0\:898f)
   ============================================================ *)

NBAccess`NBCellCount[nb_NotebookObject] :=
  Length[iResolveCells[nb]];

NBAccess`NBCurrentCellIndex[nb_NotebookObject] :=
  Module[{ec, cells, pos},
    ec = Quiet[EvaluationCell[]];
    If[Head[ec] =!= CellObject, Return[0]];
    cells = Quiet[Cells[nb]];
    If[!ListQ[cells], Return[0]];
    (* Cells[] \:3092\:76f4\:63a5\:547c\:3093\:3060\:306e\:3067\:3001\:30ad\:30e3\:30c3\:30b7\:30e5\:3082\:540c\:671f\:3059\:308b *)
    $iCellsCache[nb] = cells;
    $iCellStyleCache = KeyDrop[$iCellStyleCache, nb];
    pos = First[Flatten[Position[cells, ec]], 0];
    pos
  ];

NBAccess`NBSelectedCellIndices[nb_NotebookObject] :=
  Module[{allCells, sel, selSet, indices},
    allCells = Quiet[Cells[nb]];
    If[!ListQ[allCells], Return[{}]];
    (* \:307e\:305a\:30bb\:30eb\:30d6\:30e9\:30b1\:30c3\:30c8\:9078\:629e\:3092\:8a66\:307f\:308b *)
    sel = Quiet[SelectedCells[nb]];
    If[!ListQ[sel] || Length[sel] === 0,
      (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: \:73fe\:5728\:306e\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306e\:30bb\:30eb\:3092\:53d6\:5f97 *)
      Quiet[
        SelectionMove[nb, All, Cell];
        sel = SelectedCells[nb];
        SelectionMove[nb, After, CellContents];
      ];
    ];
    If[!ListQ[sel] || Length[sel] === 0, Return[{}]];
    (* Cells[] \:3092\:76f4\:63a5\:547c\:3093\:3060\:306e\:3067\:3001\:30ad\:30e3\:30c3\:30b7\:30e5\:3082\:540c\:671f\:3059\:308b *)
    $iCellsCache[nb] = allCells;
    $iCellStyleCache = KeyDrop[$iCellStyleCache, nb];
    selSet = Association[# -> True & /@ sel];
    indices = Flatten[MapIndexed[
      If[KeyExistsQ[selSet, #1], First[#2], Nothing] &,
      allCells]];
    indices
  ];

NBAccess`NBCellIndicesByTag[nb_NotebookObject, tag_String] :=
  Module[{allCells, taggedCells, tagSet},
    allCells = Quiet[Cells[nb]];
    If[!ListQ[allCells], Return[{}]];
    taggedCells = Quiet[Cells[nb, CellTags -> tag]];
    If[!ListQ[taggedCells] || Length[taggedCells] === 0, Return[{}]];
    tagSet = Association[# -> True & /@ taggedCells];
    Flatten[MapIndexed[
      If[KeyExistsQ[tagSet, #1], First[#2], Nothing] &,
      allCells]]
  ];

NBAccess`NBCellIndicesByStyle[nb_NotebookObject, style_String] :=
  Module[{styles = iResolveCellStyles[nb]},
    Flatten[Position[styles, style]]
  ];

NBAccess`NBCellIndicesByStyle[nb_NotebookObject, styles_List] :=
  Module[{allStyles = iResolveCellStyles[nb]},
    Select[Range[Length[allStyles]], MemberQ[styles, allStyles[[#]]] &]
  ];

NBAccess`NBDeleteCellsByTag[nb_NotebookObject, tag_String] :=
  Module[{cells},
    cells = Quiet[Cells[nb, CellTags -> tag]];
    If[ListQ[cells] && Length[cells] > 0,
      Quiet[NotebookDelete /@ cells]]
  ];

NBAccess`NBMoveAfterCell[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell =!= $Failed,
      Quiet[SelectionMove[cell, After, Cell]]]
  ];

(* \:30bb\:30eb\:30d6\:30e9\:30b1\:30c3\:30c8\:3092\:9078\:629e\:72b6\:614b\:306b\:3059\:308b\:ff08\:30ab\:30fc\:30bd\:30eb\:3092\:30bb\:30eb\:5185\:3067\:306f\:306a\:304f\:30d6\:30e9\:30b1\:30c3\:30c8\:9078\:629e\:ff09\:3002
   \:30d1\:30ec\:30c3\:30c8\:64cd\:4f5c\:5f8c\:306b\:30bb\:30eb\:9078\:629e\:3092\:5fa9\:5143\:3059\:308b\:305f\:3081\:306b\:4f7f\:7528\:3059\:308b\:3002 *)
NBAccess`NBSelectCell[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell =!= $Failed,
      Quiet[SelectionMove[cell, All, Cell, AutoScroll -> False]]]
  ];

NBAccess`NBCellRead[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, $Failed, Quiet[NotebookRead[cell]]]
  ];

NBAccess`NBCellStyle[nb_NotebookObject, cellIdx_Integer] :=
  Module[{styles = iResolveCellStyles[nb]},
    If[cellIdx < 1 || cellIdx > Length[styles], "", styles[[cellIdx]]]
  ];

NBAccess`NBCellLabel[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell, lbl},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[""]];
    lbl = Quiet[CurrentValue[cell, CellLabel]];
    If[StringQ[lbl], lbl, ""]
  ];

NBAccess`NBCellSetOptions[nb_NotebookObject, cellIdx_Integer, opts__] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell =!= $Failed, Quiet[SetOptions[cell, opts]]]
  ];

(* \:30bb\:30eb\:30b9\:30bf\:30a4\:30eb\:3092\:5909\:66f4\:3059\:308b\:3002Cell \:5f0f\:306e\:7b2c2\:5f15\:6570\:3092\:66f8\:304d\:63db\:3048\:3001\:4ed6\:30aa\:30d7\:30b7\:30e7\:30f3\:306f\:4fdd\:6301\:3059\:308b\:3002
   SetOptions[cell, CellStyle -> ...] \:3067\:306f\:30bb\:30eb\:30b9\:30bf\:30a4\:30eb\:306f\:5909\:308f\:3089\:306a\:3044\:305f\:3081\:3001
   Cell \:5f0f\:5168\:4f53\:3092\:8aad\:307f\:66f8\:304d\:3059\:308b\:3002 *)
NBAccess`NBCellSetStyle[nb_NotebookObject, cellIdx_Integer, newStyle_String] :=
  Module[{cell, cellExpr, newCellExpr},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    cellExpr = Quiet @ NotebookRead[cell];
    newCellExpr = Replace[cellExpr,
      {Cell[content_, _String, rest___] :> Cell[content, newStyle, rest],
       Cell[content_, rest___]          :> Cell[content, newStyle, rest]}];
    NotebookWrite[cell, newCellExpr, All, AutoScroll -> False]];

(* \:65e2\:5b58\:30bb\:30eb\:306b\:30b3\:30fc\:30c9\:3092 BoxData + Input \:30b9\:30bf\:30a4\:30eb\:3067\:66f8\:304d\:8fbc\:3080\:3002
   FEParser \:3067\:69cb\:6587\:30ab\:30e9\:30fc\:30ea\:30f3\:30b0\:4ed8\:304d BoxData \:306b\:5909\:63db\:3057\:3001
   Cell \:5f0f\:5168\:4f53\:3092\:5185\:5bb9\:3068\:30b9\:30bf\:30a4\:30eb\:3067\:7f6e\:63db\:3059\:308b\:ff08TaggingRules \:7b49\:306f\:4fdd\:6301\:ff09\:3002 *)
NBAccess`NBCellWriteCode[nb_NotebookObject, cellIdx_Integer, code_String] :=
  Module[{cell, cellExpr, result, box, newContent, newCellExpr},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    (* FEParser \:3067\:30b3\:30fc\:30c9\:3092 BoxData \:306b\:5909\:63db *)
    result = Quiet @ Check[
      MathLink`CallFrontEnd[
        FrontEnd`UndocumentedTestFEParserPacket[code, False]],
      $Failed];
    box = Which[
      MatchQ[result, {_BoxData, ___}],             First[result],
      MatchQ[result, {Cell[_BoxData, ___], ___}],  First[result][[1]],
      MatchQ[result, _BoxData],                    result,
      True,                                        $Failed];
    newContent = If[MatchQ[box, _BoxData], box, code];
    (* Cell \:5f0f\:5168\:4f53\:3092\:8aad\:307f\:51fa\:3057\:3001\:5185\:5bb9\:3068\:30b9\:30bf\:30a4\:30eb\:3092 Input \:306b\:7f6e\:63db *)
    cellExpr = Quiet @ NotebookRead[cell];
    newCellExpr = Replace[cellExpr,
      {Cell[_, _String, rest___] :> Cell[newContent, "Input", rest],
       Cell[_, rest___]          :> Cell[newContent, "Input", rest],
       _                         :> Cell[newContent, "Input"]}];
    NotebookWrite[cell, newCellExpr, All, AutoScroll -> False]];

(* CellObject \:3092\:8fd4\:3059\:3002\:5916\:90e8\:30d1\:30c3\:30b1\:30fc\:30b8\:304c\:4f4e\:30ec\:30d9\:30eb\:306e\:30bb\:30eb\:53c2\:7167\:3092\:5fc5\:8981\:3068\:3059\:308b\:5834\:5408\:306b\:4f7f\:7528\:3002
   \:6307\:5b9a\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:304c\:7121\:52b9\:306a\:5834\:5408\:306f $Failed \:3092\:8fd4\:3059\:3002 *)
NBAccess`NBResolveCell[nb_NotebookObject, cellIdx_Integer] :=
  iResolveCell[nb, cellIdx];

NBAccess`NBCellGetTaggingRule[nb_NotebookObject, cellIdx_Integer, path_] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Missing[],
      Quiet[CurrentValue[cell, Prepend[If[ListQ[path], path, {path}], TaggingRules]]]]
  ];

NBAccess`NBCellRasterize[nb_NotebookObject, cellIdx_Integer, file_String, opts___] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, $Failed,
      Quiet[Export[file, Rasterize[cell, opts, ImageResolution -> 144], "PNG"]];
      If[FileExistsQ[file], file, $Failed]]
  ];

(* Cell \:5f0f\:304c\:753b\:50cf\:3092\:542b\:3080\:304b\:5224\:5b9a (RasterBox/GraphicsBox \:306e\:6709\:7121) *)
NBAccess`NBCellHasImage[cellExpr_] :=
  Length[Cases[cellExpr, _RasterBox | _GraphicsBox, Infinity]] > 0;

NBAccess`NBCellHasImage[$Failed] := False;
NBAccess`NBCellHasImage[{}] := False;

(* \:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:5185\:5bb9\:3092\:7f6e\:304d\:63db\:3048\:308b\:3002\:30b9\:30bf\:30a4\:30eb\:30fb\:30aa\:30d7\:30b7\:30e7\:30f3\:30fbTaggingRules \:306f\:4fdd\:6301\:3002
   \:30e9\:30a4\:30d6\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304a\:3088\:3073 NBFileOpen \:3067\:958b\:3044\:305f\:975e\:8868\:793a\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:4e21\:65b9\:3067\:52d5\:4f5c\:3059\:308b\:3002 *)
NBAccess`NBCellWriteText[nb_NotebookObject, cellIdx_Integer, newText_String] :=
  Module[{cellObj, cellExpr, newCellExpr},
    cellObj = iResolveCell[nb, cellIdx];
    If[cellObj === $Failed, Return[$Failed]];
    cellExpr = Quiet @ NotebookRead[cellObj];
    (* \:30c6\:30ad\:30b9\:30c8\:90e8\:5206\:306e\:307f\:7f6e\:63db\:3001\:4ed6\:306e\:5168\:30aa\:30d7\:30b7\:30e7\:30f3\:30fb\:5c5e\:6027\:306f\:305d\:306e\:307e\:307e *)
    newCellExpr = Replace[cellExpr,
      {Cell[_String,     rest___] :> Cell[newText, rest],
       Cell[TextData[_], rest___] :> Cell[newText, rest],
       Cell[BoxData[_],  rest___] :> Cell[newText, rest],
       other_                     :> other}];
    NotebookWrite[cellObj, newCellExpr];
    (* NotebookWrite \:5f8c\:3001\:30ab\:30fc\:30bd\:30eb\:306f\:30bb\:30eb\:76f4\:5f8c\:306b\:79fb\:52d5\:3059\:308b\:3002
       \:66f8\:304d\:8fbc\:3093\:3060\:30bb\:30eb\:306e\:30d6\:30e9\:30b1\:30c3\:30c8\:3092\:9078\:629e\:72b6\:614b\:306b\:623b\:3059\:3002
       \:3053\:308c\:306b\:3088\:308a\:6b21\:306e NBSelectedCellIndices \:304c\:6b63\:3057\:3044\:30bb\:30eb\:3092\:8fd4\:3059\:3002 *)
    Quiet[SelectionMove[nb, Previous, Cell]];
    NBAccess`NBInvalidateCellsCache[nb];
    cellIdx
  ];

(* \:30bb\:30eb\:306e TaggingRules \:306b\:30cd\:30b9\:30c8\:5024\:3092\:8a2d\:5b9a\:3059\:308b\:3002
   NBCellGetTaggingRule \:306e\:5bfe\:3068\:306a\:308b\:30bb\:30c3\:30bf\:30fc\:3002
   path \:306f\:5358\:4e00\:30ad\:30fc\:307e\:305f\:306f\:30cd\:30b9\:30c8\:3057\:305f\:30ad\:30fc\:30ea\:30b9\:30c8\:3002
   value \:304c Inherited \:306e\:5834\:5408\:306f\:30ad\:30fc\:3092\:524a\:9664\:3059\:308b\:3002
   NBSetConfidentialTag \:3068\:540c\:3058 SetOptions \:30d1\:30bf\:30fc\:30f3\:3067\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:4fdd\:5b58\:6642\:306b\:6c38\:7d9a\:5316\:3055\:308c\:308b\:3002 *)
NBAccess`NBCellSetTaggingRule[nb_NotebookObject, cellIdx_Integer, path_, value_] :=
  Module[{cell, keys, tags, k1, k2, sub},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    keys = If[ListQ[path], path, {path}];
    (* \:73fe\:5728\:306e TaggingRules \:3092\:8aad\:307f\:53d6\:308a (SetOptions \:3067\:66f8\:304d\:623b\:3059\:305f\:3081) *)
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    If[AssociationQ[tags], tags = Normal[tags]];
    Which[
      (* \:5358\:4e00\:30ad\:30fc: {"key"} *)
      Length[keys] === 1,
        k1 = keys[[1]];
        tags = DeleteCases[tags, k1 -> _];
        If[value =!= Inherited, tags = Append[tags, k1 -> value]],
      (* 2\:6bb5\:30cd\:30b9\:30c8: {"key1", "key2"} *)
      Length[keys] === 2,
        k1 = keys[[1]]; k2 = keys[[2]];
        sub = Replace[Lookup[tags, k1, {}],
                Except[_List | _Association] -> {}];
        If[AssociationQ[sub], sub = Normal[sub]];
        sub = DeleteCases[sub, k2 -> _];
        If[value =!= Inherited, sub = Append[sub, k2 -> value]];
        tags = DeleteCases[tags, k1 -> _];
        If[Length[sub] > 0, tags = Append[tags, k1 -> sub]],
      (* 3\:6bb5\:4ee5\:4e0a: \:6c4e\:7528\:518d\:5e30 *)
      True,
        Module[{setNested},
          setNested[lst_, {k_}, v_] := Module[{r = DeleteCases[lst, k -> _]},
            If[v =!= Inherited, Append[r, k -> v], r]];
          setNested[lst_, {k_, rest__}, v_] := Module[{r, child},
            child = Replace[Lookup[lst, k, {}], Except[_List | _Association] -> {}];
            If[AssociationQ[child], child = Normal[child]];
            child = setNested[child, {rest}, v];
            r = DeleteCases[lst, k -> _];
            If[Length[child] > 0, Append[r, k -> child], r]];
          tags = setNested[tags, keys, value]]
    ];
    (* SetOptions \:3067\:66f8\:304d\:623b\:3057: \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:4fdd\:5b58\:6642\:306b\:6c38\:7d9a\:5316\:3055\:308c\:308b *)
    Quiet[SetOptions[cell, TaggingRules -> tags]];
    value
  ];

(* ============================================================
   \:30bb\:30eb\:5185\:5bb9\:30c6\:30ad\:30b9\:30c8\:53d6\:5f97 (InputText \:5f62\:5f0f)
   ============================================================ *)

NBAccess`iCellToInputText[cell_CellObject] :=
  Module[{raw, result},
    result = Quiet[
      FrontEndExecute[
        FrontEnd`ExportPacket[NotebookRead[cell], "InputText"]]];
    If[MatchQ[result, {_String, ___}] && StringLength[First[result]] > 0,
      Return[First[result]]];
    NBAccess`NBCellExprToText[Quiet[NotebookRead[cell]]]
  ];

NBAccess`NBCellReadInputText[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, "", iCellToInputText[cell]]
  ];

(* ============================================================
   \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb: 0.0..1.0
   ============================================================ *)

(* Stage 9 P1.5: NotebookObject \:304c Private (CloudPublishable -> False) \:3068
   \:660e\:793a\:5ba3\:8a00\:3055\:308c\:3066\:3044\:308b\:304b\:3092 frontend memory \:306e TaggingRules \:304b\:3089\:8efd\:91cf\:306b\:8aad\:3080\:3002
   NBCellPrivacyLevel \:304b\:3089\:30bb\:30eb\:6bce\:306b\:547c\:3070\:308c\:308b\:306e\:3067\:30d5\:30a1\:30a4\:30eb I/O \:3092\:907f\:3051\:308b\:3002
   \:683c\:7d0d\:5834\:6240: {TaggingRules, "SourceVault", "CloudPublishable"}\:3002
   False \:306e\:3068\:304d\:306e\:307f True\:3002True/\:672a\:5ba3\:8a00\:306f False (\:30aa\:30fc\:30d0\:30fc\:30e9\:30a4\:30c9\:3057\:306a\:3044)\:3002 *)
iNBNotebookDeclaredPrivateQ[nb_NotebookObject] :=
  Module[{tr, sv, cp},
    tr = Quiet @ CurrentValue[nb, TaggingRules];
    If[ListQ[tr], tr = Association @@ Cases[tr, _Rule | _RuleDelayed]];
    If[!AssociationQ[tr], Return[False]];
    sv = Lookup[tr, "SourceVault", <||>];
    If[ListQ[sv], sv = Association @@ Cases[sv, _Rule | _RuleDelayed]];
    If[!AssociationQ[sv], Return[False]];
    cp = Lookup[sv, "CloudPublishable", Missing["NotDeclared"]];
    cp === False
  ];
iNBNotebookDeclaredPrivateQ[___] := False;

(* \:958b\:3044\:3066\:3044\:308b NotebookObject \:5168\:4f53\:3092 Private (CloudPublishable -> False) \:5ba3\:8a00\:3059\:308b
   \:30ef\:30f3\:30b7\:30e7\:30c3\:30c8\:30d8\:30eb\:30d1\:30fc (2026-06-06)\:3002iNBNotebookDeclaredPrivateQ \:306f\:30e9\:30a4\:30d6 NB \:306e
   TaggingRules \:3092\:8aad\:3080\:305f\:3081\:3001\:4fdd\:5b58\:306a\:3057\:3067\:3082\:5373\:5ea7\:306b\:5168\:30bb\:30eb PrivacyLevel 1.0 \:306b\:306a\:308a
    \:30af\:30e9\:30a6\:30c9 LLM \:3078\:6295\:5165\:3055\:308c\:306a\:304f\:306a\:308b (NBCellPrivacyLevel \:304c\:30bb\:30eb\:3092\:8aad\:3080\:524d\:306b\:77ed\:7d61)\:3002
   \:4fdd\:5b58\:6e08\:307f\:306a\:3089 NBSetCloudPublishable \:3067\:30d5\:30a1\:30a4\:30eb\:30d8\:30c3\:30c0\:306b\:3082\:6c38\:7d9a\:5316\:3059\:308b\:3002
   makePrivate=False \:3067\:5ba3\:8a00\:3092\:300c\:30af\:30e9\:30a6\:30c9\:516c\:958b\:53ef\:300d\:306b\:5207\:308a\:66ff\:3048\:308b\:3002
   \:516c\:958b ::usage \:5ba3\:8a00\:306f BeginPackage \:76f4\:5f8c\:306e\:516c\:958b\:90e8 (NBClearCloudPublishable::usage \:306e\:76f4\:5f8c)
   \:306b\:3042\:308b\:3002\:3053\:3053\:306f Private \:90e8\:306a\:306e\:3067\:672c\:4f53\:5b9a\:7fa9\:306e\:307f\:7f6e\:304f\:3002 *)
NBAccess`NBSetNotebookPrivate[nb_NotebookObject, makePrivate:(True | False):True] :=
  Module[{path, cpVal},
    (* CloudPublishable -> False \:304c Private\:3002makePrivate=True \:306a\:3089 False \:3092\:66f8\:304f\:3002 *)
    cpVal = !makePrivate;
    (* 1. \:30e9\:30a4\:30d6 NB \:306e TaggingRules \:3092\:5373\:6642\:8a2d\:5b9a (iNBNotebookDeclaredPrivateQ \:306e\:8aad\:3080\:7d4c\:8def) *)
    Quiet[CurrentValue[nb,
      {TaggingRules, "SourceVault", "CloudPublishable"}] = cpVal];
    (* 2. \:4fdd\:5b58\:6e08\:307f\:306a\:3089\:30d5\:30a1\:30a4\:30eb\:30d8\:30c3\:30c0\:306b\:3082\:6c38\:7d9a\:5316 (best-effort) *)
    path = Quiet[NotebookFileName[nb]];
    If[StringQ[path],
      Quiet @ Check[NBAccess`NBSetCloudPublishable[path, cpVal], Null]];
    <|"Notebook" -> nb,
      "Path" -> If[StringQ[path], path, None],
      "CloudPublishable" -> cpVal,
      "DeclaredPrivate" -> makePrivate,
      "Persisted" -> StringQ[path]|>
  ];
NBAccess`NBSetNotebookPrivate[makePrivate:(True | False):True] :=
  NBAccess`NBSetNotebookPrivate[EvaluationNotebook[], makePrivate];

NBAccess`NBCellPrivacyLevel[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell, tag, depTag, numTag},
    (* Stage 9 P1.5: \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5168\:4f53\:304c Private (CloudPublishable -> False) \:5ba3\:8a00\:6e08\:307f\:306a\:3089\:3001
       \:5168\:30bb\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:3092 1.0 \:3068\:3057\:3066\:6271\:3046 (\:30af\:30e9\:30a6\:30c9 LLM \:3078\:306e
       \:6295\:5165\:3092\:660e\:793a\:7684\:306b\:7981\:6b62)\:3002\:500b\:5225\:30bb\:30eb\:306e\:6a5f\:5bc6\:30bf\:30b0\:3088\:308a\:512a\:5148\:3059\:308b\:3002 *)
    If[iNBNotebookDeclaredPrivateQ[nb], Return[1.0]];
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[0.0]];
    (* Stage 9 P1 Step 7: \:6570\:5024 privacyLevel \:30bf\:30b0\:304c\:3042\:308c\:3070\:6700\:512a\:5148 *)
    numTag = iGetCellPrivacyLevelTag[cell];
    If[NumericQ[numTag], Return[numTag]];
    tag    = iGetConfTag[cell];
    depTag = Quiet[CurrentValue[cell, {TaggingRules, "claudecode", "dependent"}]];
    Which[
      tag === False,                 0.0,
      TrueQ[depTag],                 0.75,
      tag === True,                  1.0,
      iCellUsesConfSymbol[nb, cell], 1.0,
      True,                          0.0
    ]
  ];

(* ============================================================
   \:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:5224\:5b9a\:95a2\:6570
   ============================================================ *)

Options[NBAccess`NBIsAccessible] = {PrivacySpec -> Automatic};
NBAccess`NBIsAccessible[nb_NotebookObject, cellIdx_Integer,
    opts:OptionsPattern[]] :=
  NBAccess`NBCellPrivacyLevel[nb, cellIdx] <= iAccessLevel[OptionValue[PrivacySpec]];

Options[NBAccess`NBFilterCellIndices] = {PrivacySpec -> Automatic};
NBAccess`NBFilterCellIndices[nb_NotebookObject, indices_List,
    opts:OptionsPattern[]] :=
  Select[indices, NBAccess`NBIsAccessible[nb, #, opts] &];

(* ============================================================
   \:30c6\:30ad\:30b9\:30c8\:62bd\:51fa\:95a2\:6570
   ============================================================ *)

NBAccess`NBCellExprToText[cellExpr_] :=
  Module[{cellContent},
    cellContent = Replace[cellExpr,
      {Cell[BoxData[bd_],  ___] :> bd,
       Cell[str_String,    ___] :> str,
       Cell[TextData[td_], ___] :> td,
       _                        :> ""}];
    StringTrim @ StringJoin @ Riffle[
      Cases[cellContent, tok_String /; StringLength[tok] > 0, Infinity], " "]
  ];

NBAccess`NBCellToText[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, "",
      NBAccess`NBCellExprToText[Quiet[NotebookRead[cell]]]]
  ];

(* ============================================================
   \:5805\:7262\:30c6\:30ad\:30b9\:30c8\:53d6\:5f97 (\:8907\:6570\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:4ed8\:304d)
   ============================================================ *)

NBAccess`NBCellGetText[nb_NotebookObject, cellIdx_Integer] :=
  Module[{text, cellExpr},
    (* 1st: FrontEnd \:7d4c\:7531 InputText (\:6700\:3082\:78ba\:5b9f) *)
    text = Quiet[NBAccess`NBCellReadInputText[nb, cellIdx]];
    If[StringQ[text] && StringTrim[text] =!= "", Return[StringTrim[text]]];
    (* 2nd: NBCellToText (Cases \:30d9\:30fc\:30b9) *)
    text = Quiet[NBAccess`NBCellToText[nb, cellIdx]];
    If[StringQ[text] && StringTrim[text] =!= "", Return[StringTrim[text]]];
    (* 3rd: NotebookRead + NBCellExprToText \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af *)
    cellExpr = Quiet[NBAccess`NBCellRead[nb, cellIdx]];
    If[cellExpr =!= $Failed && cellExpr =!= {},
      text = Quiet[NBAccess`NBCellExprToText[cellExpr]];
      If[StringQ[text] && StringTrim[text] =!= "", Return[StringTrim[text]]]];
    ""
  ];

(* ============================================================
   LLM \:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:65b9\:5f0f\:30bb\:30eb\:5909\:63db
   \:30bb\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:306b\:5fdc\:3058\:3066\:9069\:5207\:306a LLM \:3092\:9078\:629e\:3057\:3001
   promptFn \:3067\:751f\:6210\:3057\:305f\:30d7\:30ed\:30f3\:30d7\:30c8\:3092\:5b9f\:884c\:3057\:3066\:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:3092\:7f6e\:304d\:63db\:3048\:308b\:3002
   $NBLLMQueryFunc \:306f ClaudeCode \:304c\:30ed\:30fc\:30c9\:6642\:306b\:767b\:9332\:3059\:308b\:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:3002
   ============================================================ *)

Options[NBAccess`NBCellTransformWithLLM] = {Fallback -> False, InputText -> Automatic, Integrations -> Automatic};

NBAccess`NBCellTransformWithLLM[nb_NotebookObject, cellIdx_Integer,
    promptFn_, completionFn_, opts:OptionsPattern[]] :=
  Module[{text, inputOverride, privLevel, useFallback, integ, prompt, cellTag},
    NBAccess`NBInvalidateCellsCache[nb];

    (* \:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:672a\:767b\:9332\:30c1\:30a7\:30c3\:30af *)
    If[!MatchQ[NBAccess`$NBLLMQueryFunc, _Function | _Symbol],
      completionFn[$Failed]; Return[]];

    (* \:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:53d6\:5f97: InputText \:30aa\:30d7\:30b7\:30e7\:30f3\:304c\:3042\:308c\:3070\:305d\:308c\:3092\:4f7f\:3046 *)
    inputOverride = OptionValue[InputText];
    text = If[StringQ[inputOverride] && StringTrim[inputOverride] =!= "",
      inputOverride,
      NBAccess`NBCellGetText[nb, cellIdx]];
    If[!StringQ[text] || StringTrim[text] === "",
      completionFn[$Failed]; Return[]];

    (* \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:53d6\:5f97 *)
    privLevel = NBAccess`NBCellPrivacyLevel[nb, cellIdx];
    useFallback = TrueQ[OptionValue[Fallback]];
    integ = OptionValue[Integrations];

    (* \:30d7\:30ed\:30f3\:30d7\:30c8\:69cb\:7bc9 *)
    prompt = promptFn[text];
    If[!StringQ[prompt] || StringTrim[prompt] === "",
      completionFn[$Failed]; Return[]];

    (* \:30bb\:30eb\:306b\:30e6\:30cb\:30fc\:30af\:30bf\:30b0\:3092\:4ed8\:4e0e: \:975e\:540c\:671f\:30b3\:30fc\:30eb\:30d0\:30c3\:30af\:3067\:30bb\:30eb\:3092\:518d\:767a\:898b\:3059\:308b\:305f\:3081\:3002
       Job \:30b7\:30b9\:30c6\:30e0\:304c\:9032\:6357\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b\:3068\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:304c\:305a\:308c\:308b\:305f\:3081\:3001
       \:30bf\:30b0\:30d9\:30fc\:30b9\:306e\:518d\:691c\:7d22\:304c\:5fc5\:8981\:3002 *)
    cellTag = "doc-transform-" <> ToString[UnixTime[]] <> "-" <> ToString[RandomInteger[99999]];
    NBAccess`NBCellSetTaggingRule[nb, cellIdx, {"documentation", "transformTag"}, cellTag];

    (* \:975e\:540c\:671f LLM \:547c\:3073\:51fa\:3057 *)
    With[{nb2 = nb, origIdx = cellIdx, origText = text, pl = privLevel,
          doneFn = completionFn, tag = cellTag, ig = integ},
      NBAccess`$NBLLMQueryFunc[prompt,
        Function[response,
          Module[{idx},
            (* \:30bf\:30b0\:304b\:3089\:30bb\:30eb\:3092\:518d\:691c\:7d22 *)
            NBAccess`NBInvalidateCellsCache[nb2];
            idx = iFindCellByTag[nb2, tag];
            If[idx === 0, idx = origIdx]; (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: \:30bf\:30b0\:691c\:7d22\:5931\:6557\:6642\:306f\:5143\:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9 *)
            (* \:30bf\:30b0\:3092\:9664\:53bb *)
            NBAccess`NBCellSetTaggingRule[nb2, idx, {"documentation", "transformTag"}, Inherited];
            If[StringQ[response] && !StringStartsQ[response, "Error"],
              Module[{trimmed = StringTrim[response]},
                If[StringStartsQ[trimmed, "[ERROR]:"] ||
                   StringStartsQ[trimmed, "[ERROR]\:ff1a"],
                  Module[{errMsg = StringTrim[
                      StringReplace[trimmed, StartOfString ~~ "[ERROR]" ~~ (":" | "\:ff1a") -> ""]]},
                    NBAccess`NBMoveAfterCell[nb2, idx];
                    NBAccess`NBWriteCell[nb2,
                      Cell[errMsg, "Text",
                        CellTags -> {"documentation-error"},
                        FontColor -> RGBColor[0.7, 0.3, 0.0],
                        FontSize -> 11]];
                    doneFn[$Failed]],
                  (* \:6b63\:5e38\:5fdc\:7b54 *)
                  doneFn[<|
                    "Response"      -> trimmed,
                    "OriginalText"  -> origText,
                    "PrivacyLevel"  -> pl,
                    "CellIdx"       -> idx
                  |>];
                  NBAccess`NBInvalidateCellsCache[nb2];
                  NBAccess`NBCellWriteText[nb2, idx, trimmed]]],
              (* API \:30a8\:30e9\:30fc *)
              doneFn[$Failed]]]],
        nb,
        PrivacyLevel -> privLevel,
        Fallback -> useFallback,
        Integrations -> ig]
    ];
  ];

(* \:30e6\:30cb\:30fc\:30af\:30bf\:30b0\:304b\:3089\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:3092\:691c\:7d22\:3059\:308b *)
iFindCellByTag[nb_NotebookObject, tag_String] :=
  Module[{nCells, val},
    nCells = NBAccess`NBCellCount[nb];
    Do[
      val = NBAccess`NBCellGetTaggingRule[nb, i, {"documentation", "transformTag"}];
      If[val === tag, Return[i, Module]],
    {i, nCells}];
    0
  ];

(* ============================================================
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:30bb\:30eb\:4e00\:89a7\:53d6\:5f97 (PrivacySpec \:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:4ed8\:304d)
   ============================================================ *)

Options[NBAccess`NBGetCells] = {PrivacySpec -> Automatic};
NBAccess`NBGetCells[nb_NotebookObject, opts:OptionsPattern[]] :=
  Module[{n},
    n = NBAccess`NBCellCount[nb];
    If[n === 0, Return[{}]];
    NBAccess`NBFilterCellIndices[nb, Range[n], opts]
  ];

(* \:6a5f\:5bc6\:5909\:6570\:3092\:542b\:3080\:884c\:306e\:51e6\:7406 *)
iRedactConfidentialLines[text_String] :=
  Module[{names, lines, anyRedacted = False, redacted},
    If[Length[NBAccess`$NBConfidentialSymbols] === 0, Return[{text, False}]];
    names = Keys[NBAccess`$NBConfidentialSymbols];
    lines = StringSplit[text, "\n"];
    redacted = Map[
      Function[line,
        Module[{hasConf, lhsMatch},
          hasConf = AnyTrue[names,
            StringMatchQ[line, ___ ~~ RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <> "(?![\\p{L}\\p{N}$])"] ~~ ___] &];
          If[!hasConf, line,
            anyRedacted = True;
            lhsMatch = StringCases[line,
              RegularExpression["^\\s*([\\p{L}$][\\p{L}\\p{N}$]*)\\s*=(?!=)"] -> "$1"];
            If[Length[lhsMatch] > 0,
              First[lhsMatch] <> " = (* [\:6a5f\:5bc6\:5909\:6570\:306b\:4f9d\:5b58: \:5024\:306f\:975e\:8868\:793a] *)",
              "(* [\:6a5f\:5bc6\:5909\:6570\:3092\:542b\:3080\:884c: \:975e\:8868\:793a] *)"]]]],
      lines];
    {StringJoin @ Riffle[redacted, "\n"], anyRedacted}
  ];

(* ============================================================
   Output \:30b9\:30de\:30fc\:30c8\:8981\:7d04 (\:5168 Output \:3092\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:306b\:542b\:3081\:308b\:305f\:3081\:306e\:8981\:7d04\:6a5f\:69cb)
   \:77ed\:3044\:51fa\:529b\:306f\:305d\:306e\:307e\:307e\:542b\:3081\:3001\:9577\:3044\:51fa\:529b\:306f\:30c7\:30fc\:30bf\:578b\:30fb\:30b5\:30a4\:30ba\:30fb\:5148\:982d\:5024\:7b49\:3092\:8981\:7d04\:3059\:308b\:3002
   ============================================================ *)

$iOutputSummaryMaxLen = 200;

(* Output \:30c6\:30ad\:30b9\:30c8\:304b\:3089\:30c7\:30fc\:30bf\:69cb\:9020\:60c5\:5831\:3092\:691c\:51fa *)
iDetectDataInfo[text_String] :=
  Module[{len = StringLength[text]},
    Which[
      (* Association: <|...|> *)
      StringContainsQ[text, "<|"],
        Module[{keys},
          keys = DeleteDuplicates @ Join[
            StringCases[text,
              RegularExpression["\"([^\"]{1,50})\"\\s*->"] :> "$1", 20],
            StringCases[text,
              RegularExpression["(?<=[<|,])\\s*([\\p{L}$][\\p{L}\\p{N}$]*)\\s*->"] :> "$1", 20]];
          keys = Take[keys, UpTo[10]];
          "Association, " <> ToString[Max[1, StringCount[text, "->"]]] <> " keys" <>
            If[Length[keys] > 0,
              ": {" <> StringRiffle[keys, ", "] <> "}",
              ""]],
      (* Dataset *)
      StringContainsQ[text, "Dataset["],
        Module[{keys},
          keys = DeleteDuplicates @ StringCases[text,
            RegularExpression["\"([^\"]{1,50})\"\\s*->"] :> "$1", 20];
          keys = Take[keys, UpTo[10]];
          "Dataset" <>
            If[Length[keys] > 0,
              ", columns: {" <> StringRiffle[keys, ", "] <> "}",
              ""]],
      (* Nested list / matrix: {{...}, ...} *)
      StringMatchQ[text, RegularExpression["^\\s*\\{\\s*\\{"]],
        Module[{nRows = StringCount[text, RegularExpression["\\}\\s*,\\s*\\{"]] + 1},
          "NestedList/Matrix, ~" <> ToString[nRows] <> " rows"],
      (* Simple list: {...} *)
      StringMatchQ[text, RegularExpression["^\\s*\\{"]],
        Module[{nElems = StringCount[text, ","] + 1},
          "List, ~" <> ToString[nElems] <> " elements"],
      (* SparseArray, NumericArray \:7b49 *)
      StringContainsQ[text, "SparseArray["],
        "SparseArray",
      StringContainsQ[text, "NumericArray["],
        "NumericArray",
      (* Image *)
      StringContainsQ[text, RegularExpression["Image\\[|Graphics\\[|Graphics3D\\["]],
        "Graphics/Image",
      (* Default: \:30b5\:30a4\:30ba\:60c5\:5831\:306e\:307f *)
      True,
        ToString[len] <> " chars"
    ]
  ];

(* \:30bb\:30eb\:30c6\:30ad\:30b9\:30c8\:306e\:5805\:7262\:306a\:53d6\:5f97:
   NBCellToText (Cases \:30d9\:30fc\:30b9) \:306f\:7279\:6b8a\:306a BoxData \:5f62\:5f0f\:3067\:7a7a\:306b\:306a\:308b\:3053\:3068\:304c\:3042\:308b\:3002
   FrontEnd`ExportPacket \:7d4c\:7531\:306e NBCellReadInputText \:3092\:512a\:5148\:3057\:3001
   \:5931\:6557\:6642\:306b NBCellToText \:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3059\:308b\:3002 *)
iRobustCellText[nb_NotebookObject, oIdx_Integer] :=
  Module[{txt},
    (* \:512a\:5148: FrontEnd ExportPacket (InputText \:5f62\:5f0f) *)
    txt = Quiet[NBAccess`NBCellReadInputText[nb, oIdx]];
    If[StringQ[txt] && StringLength[StringTrim[txt]] > 0,
      Return[StringTrim[txt]]];
    (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: BoxData \:5185\:306e\:6587\:5b57\:5217\:30c8\:30fc\:30af\:30f3\:53ce\:96c6 *)
    txt = ToString[NBAccess`NBCellToText[nb, oIdx]];
    If[StringQ[txt] && StringLength[StringTrim[txt]] > 0,
      Return[StringTrim[txt]]];
    ""
  ];

(* \:975e\:79d8\:5bc6 Output \:306e\:30b9\:30de\:30fc\:30c8\:8981\:7d04: \:77ed\:3051\:308c\:3070\:305d\:306e\:307e\:307e\:3001\:9577\:3051\:308c\:3070\:69cb\:9020 + \:5148\:982d\:5024 *)
iSmartOutputSummary[nb_NotebookObject, oIdx_Integer] :=
  Module[{outTxt, len},
    outTxt = iRobustCellText[nb, oIdx];
    If[outTxt === "", Return["(\:51fa\:529b\:53d6\:5f97\:5931\:6557)"]];
    len = StringLength[outTxt];
    If[len <= $iOutputSummaryMaxLen, Return[outTxt]];
    (* \:9577\:3044\:51fa\:529b: \:69cb\:9020\:60c5\:5831 + \:5148\:982d\:30d7\:30ec\:30d3\:30e5\:30fc *)
    Module[{info = iDetectDataInfo[outTxt], preview},
      preview = StringTake[outTxt, UpTo[100]];
      "(* " <> info <> " *) " <> preview <> " \[Ellipsis]"
    ]
  ];

(* \:79d8\:5bc6\:4f9d\:5b58 Output \:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831: \:30c7\:30fc\:30bf\:578b\:30fb\:30b5\:30a4\:30ba\:30fb\:30ad\:30fc\:306e\:307f\:3001\:5024\:306f\:542b\:307e\:306a\:3044 *)
iOutputSchemaText[nb_NotebookObject, oIdx_Integer] :=
  Module[{outTxt, info},
    outTxt = iRobustCellText[nb, oIdx];
    If[outTxt === "", Return["(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: \:53d6\:5f97\:5931\:6557] *)"]];
    info = iDetectDataInfo[outTxt];
    "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: " <> info <> "] *)"
  ];

Options[NBAccess`NBGetContext] = {PrivacySpec -> Automatic};
NBAccess`NBGetContext[nb_NotebookObject, afterIdx_Integer,
    opts:OptionsPattern[]] :=
  Module[{allCells, nCells, cellPos, inIndices, outIndices,
          msgIndices, suppressedOutPos,
          inLines, msgText, outText},
    allCells = Quiet[Cells[nb]];
    If[!ListQ[allCells], Return[""]];
    nCells = Length[allCells];
    cellPos = Association[MapIndexed[#1 -> First[#2] &, allCells]];
    (* \:5168 Input/Code \:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:3092\:53d6\:5f97 *)
    inIndices = Sort[Join[
      NBAccess`NBCellIndicesByStyle[nb, "Input"],
      NBAccess`NBCellIndicesByStyle[nb, "Code"]]];
    outIndices = NBAccess`NBCellIndicesByStyle[nb, "Output"];
    suppressedOutPos = {};
    inLines = StringJoin @ Riffle[
      Map[
        Function[iIdx,
          Module[{txt, result, wasRedacted, cellLabel, depTag,
                  shouldSuppress, nextOutIndices, nextInIdx, cellPriv},
            (* \:30bb\:30eb\:30ec\:30d9\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30c1\:30a7\:30c3\:30af: \:30de\:30fc\:30af\:6e08\:307f\:30bb\:30eb\:306f\:9664\:5916 *)
            cellPriv = NBAccess`NBCellPrivacyLevel[nb, iIdx];
            If[cellPriv > iAccessLevel[OptionValue[PrivacySpec]],
              (* \:30bb\:30eb\:5168\:4f53\:304c\:79d8\:5bc6: \:30c6\:30ad\:30b9\:30c8\:3092\:51fa\:3055\:305a\:3001\:5bfe\:5fdc Output \:3082\:6291\:5236 *)
              nextOutIndices = Select[outIndices, # > iIdx &];
              If[Length[nextOutIndices] > 0,
                nextInIdx = SelectFirst[inIndices, # > iIdx &, Infinity];
                nextOutIndices = Select[nextOutIndices, # < nextInIdx &];
                suppressedOutPos = Join[suppressedOutPos, nextOutIndices]];
              cellLabel = NBAccess`NBCellLabel[nb, iIdx];
              If[cellLabel =!= "",
                cellLabel <> " (* [\:6a5f\:5bc6\:30bb\:30eb: \:975e\:8868\:793a] *)",
                Nothing],
              (* \:901a\:5e38\:51e6\:7406: \:5909\:6570\:540d\:30d9\:30fc\:30b9\:306e\:30ea\:30c0\:30af\:30b7\:30e7\:30f3 *)
              txt = ToString[NBAccess`NBCellToText[nb, iIdx]];
              {result, wasRedacted} = iRedactConfidentialLines[
                StringTake[txt, UpTo[500]]];
              cellLabel = NBAccess`NBCellLabel[nb, iIdx];
              depTag = NBAccess`NBCellGetTaggingRule[nb, iIdx,
                {"claudecode", "dependent"}];
              shouldSuppress = wasRedacted || TrueQ[depTag];
              If[shouldSuppress,
                nextOutIndices = Select[outIndices, # > iIdx &];
                If[Length[nextOutIndices] > 0,
                  nextInIdx = SelectFirst[inIndices, # > iIdx &, Infinity];
                  nextOutIndices = Select[nextOutIndices, # < nextInIdx &];
                  suppressedOutPos = Join[suppressedOutPos, nextOutIndices]]];
              If[cellLabel =!= "",
                cellLabel <> " " <> result,
                result]
            ]]],
        inIndices],
      "\n"];
    (* Output: \:5168 Output \:3092\:542b\:3081\:308b\:304c\:3001\:30b9\:30de\:30fc\:30c8\:8981\:7d04\:30fb\:30b9\:30ad\:30fc\:30de\:51e6\:7406\:3092\:9069\:7528
       afterIdx \:30d5\:30a3\:30eb\:30bf\:306f\:64a4\:5ec3\:3057\:3001\:79d8\:5bc6\:4f9d\:5b58 Output \:306f\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:306e\:307f\:9001\:4fe1 *)
    Module[{supSet = Association[# -> True & /@ suppressedOutPos],
            accessLvl = iAccessLevel[OptionValue[PrivacySpec]],
            normalOuts = {}, schemaOuts = {}, outLines = {}},
      Do[Module[{priv = NBAccess`NBCellPrivacyLevel[nb, oi],
                 isSuppressed = KeyExistsQ[supSet, oi]},
          Which[
            (* \:975e\:79d8\:5bc6\:304b\:3064\:975e\:6291\:5236 \[RightArrow] \:30b9\:30de\:30fc\:30c8\:8981\:7d04\:4ed8\:304d\:3067\:542b\:3081\:308b *)
            !isSuppressed && priv <= accessLvl,
              AppendTo[normalOuts, oi],
            (* \:79d8\:5bc6\:4f9d\:5b58\:3060\:304c\:30b9\:30ad\:30fc\:30de\:30d5\:30e9\:30b0 ON \[RightArrow] \:30b9\:30ad\:30fc\:30de\:60c5\:5831\:306e\:307f *)
            TrueQ[NBAccess`$NBSendDataSchema],
              AppendTo[schemaOuts, oi],
            (* \:305d\:308c\:4ee5\:5916 \[RightArrow] \:5b8c\:5168\:30b9\:30ad\:30c3\:30d7 *)
            True, Null]],
        {oi, outIndices}];

      (* Normal outputs: \:30b9\:30de\:30fc\:30c8\:8981\:7d04 *)
      Do[Module[{outLabel = NBAccess`NBCellLabel[nb, oi],
                 outSummary = iSmartOutputSummary[nb, oi]},
          AppendTo[outLines,
            If[outLabel =!= "",
              StringReplace[outLabel, "=" -> "="] <> " " <> outSummary,
              outSummary]]],
        {oi, normalOuts}];
      (* Schema outputs: \:30c7\:30fc\:30bf\:578b\:30fb\:30b5\:30a4\:30ba\:30fb\:30ad\:30fc\:60c5\:5831\:306e\:307f *)
      Do[Module[{outLabel = NBAccess`NBCellLabel[nb, oi],
                 schema = iOutputSchemaText[nb, oi]},
          AppendTo[outLines,
            If[outLabel =!= "",
              StringReplace[outLabel, "=" -> "="] <> " " <> schema,
              schema]]],
        {oi, schemaOuts}];

      outText = If[Length[outLines] > 0,
        "=== Output \:4e00\:89a7 ===\n" <>
          StringJoin[Riffle[outLines, "\n"]] <> "\n\n",
        ""]];

    (* Message \:306f afterIdx \:4ee5\:964d\:306e\:307f *)
    msgIndices = Select[
      Sort[Join[
        NBAccess`NBCellIndicesByStyle[nb, "Message"],
        NBAccess`NBCellIndicesByStyle[nb, "MSG"]]],
      # > afterIdx &];
    With[{safeSet = Association[
            # -> True & /@ NBAccess`NBFilterCellIndices[nb, msgIndices, opts]]},
      msgIndices = Select[msgIndices, KeyExistsQ[safeSet, #] &]];
    msgText = If[Length[msgIndices] > 0,
      "=== \:30a8\:30e9\:30fc\:30e1\:30c3\:30bb\:30fc\:30b8 ===\n" <>
        StringJoin[Riffle[
          ToString[NBAccess`NBCellToText[nb, #]] & /@ msgIndices,
          "\n"]] <> "\n\n",
      ""];
    If[StringLength[inLines] > 0,
      "=== \:5b9f\:884c\:3055\:308c\:305f\:30b3\:30fc\:30c9 ===\n" <> inLines <> "\n\n", ""] <>
    msgText <> outText
  ];

(* ============================================================
   \:66f8\:304d\:8fbc\:307f\:95a2\:6570
   ============================================================ *)

NBAccess`NBWriteText[nb_NotebookObject, text_String,
    style_String:"Text"] :=
  NotebookWrite[nb, Cell[text, style], After];

(*  MakeBoxes \:3067\:30bf\:30a4\:30d7\:30bb\:30c3\:30c8\:3059\:308b\:3068\:5371\:967a\:306a\:30c8\:30c3\:30d7\:30ec\:30d9\:30eb\:30d8\:30c3\:30c9
    Module/Block \:7b49\:306e\:30b9\:30b3\:30fc\:30d4\:30f3\:30b0\:69cb\:9020\:306f MakeBoxes \:3067\:5909\:6570\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:304c\:58ca\:308c\:308b *)
$iMakeBoxesUnsafeHeads = {
  Module, Block, With, DynamicModule, Manipulate,
  Do, For, While, Scan, CompoundExpression,
  Set, SetDelayed, Function,
  Show, Graphics, Graphics3D,
  Plot, Plot3D, ListPlot, ListLinePlot, ParametricPlot,
  StreamPlot, ContourPlot, DensityPlot, VectorPlot,
  RegionPlot, LogPlot, LogLogPlot, LogLinearPlot,
  GraphicsRow, GraphicsColumn, GraphicsGrid,
  Column, Row, Grid, Panel, Pane, TabView, Dynamic,
  If, Which, Switch
};

(* HoldComplete[expr] \:306e\:30c8\:30c3\:30d7\:30ec\:30d9\:30eb\:30d8\:30c3\:30c9\:304c MakeBoxes \:306b\:5b89\:5168\:304b\:5224\:5b9a *)
(* \:591a\:5f15\:6570(CompoundExpression\:76f8\:5f53)\:3084\:8907\:96d1\:306a\:5f0f\:306f\:5b89\:5168\:3067\:306a\:3044\:3068\:307f\:306a\:3059 *)
iIsMakeBoxesSafe[held_HoldComplete] :=
  Module[{len, head},
    len = Length[held];
    (* \:591a\:5f15\:6570 = CompoundExpression \[RightArrow] \:5b89\:5168\:3067\:306a\:3044 *)
    If[len =!= 1, Return[False]];
    head = Replace[held, HoldComplete[x_] :> Head[x]];
    (* \:30d1\:30bf\:30fc\:30f3\:30de\:30c3\:30c1\:5931\:6557\:6642\:ff08\:4f55\:3089\:304b\:306e\:7406\:7531\:3067 Head \:304c\:53d6\:308c\:306a\:3044\:ff09\[RightArrow] \:5b89\:5168\:3067\:306a\:3044 *)
    If[head === HoldComplete, Return[False]];
    !MemberQ[$iMakeBoxesUnsafeHeads, head]
  ];

NBAccess`NBWriteCode[nb_NotebookObject, code_String] :=
  Module[{trimmed = StringTrim[code], result, box, held, boxes, cell},
    Catch[
      (* --- \:5b89\:5168\:306a\:6570\:5f0f\:306e\:307f MakeBoxes[StandardForm] \:3067\:30bf\:30a4\:30d7\:30bb\:30c3\:30c8:
            Integrate\[RightArrow]\[Integral], Sum\[RightArrow]\[CapitalSigma], Subscript\[RightArrow]\:4e0b\:4ed8\:304d, Sqrt\[RightArrow]\[Sqrt] \:7b49 --- *)
      held = Quiet @ Check[
        ToExpression[trimmed, InputForm, HoldComplete], $Failed];
      If[held =!= $Failed && iIsMakeBoxesSafe[held],
        boxes = Quiet @ Check[
          held /. HoldComplete[e_] :>
            MakeBoxes[e, StandardForm],
          $Failed];
        If[boxes =!= $Failed,
          NotebookWrite[nb,
            Cell[BoxData[boxes], "Input"], After];
          Throw[Null, "done"]]
      ];
      (* --- \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: FEParser\:ff08Module/Block/\:8907\:96d1\:306a\:30b3\:30fc\:30c9\:5411\:3051\:ff09--- *)
      result = Quiet @ Check[
        MathLink`CallFrontEnd[
          FrontEnd`UndocumentedTestFEParserPacket[code, False]],
        $Failed
      ];
      box = Which[
        MatchQ[result, {_BoxData, ___}],              First[result],
        MatchQ[result, {Cell[_BoxData, ___], ___}],   First[result][[1]],
        MatchQ[result, _BoxData],                     result,
        True,                                         $Failed
      ];
      cell = If[MatchQ[box, _BoxData],
        Cell[box, "Input"],
        Cell[code, "Input", CellAutoOverwrite -> True]
      ];
      NotebookWrite[nb, cell, After]
    , "done"]
  ];

NBAccess`NBWriteSmartCode[nb_NotebookObject, code_String] :=
  Module[{trimmed = StringTrim[code], held,
          cellArgHold, restHold, cellExpr, restBoxes, boxes},
    If[trimmed === "", Return[]];
    held = Quiet @ Check[
      ToExpression[trimmed, InputForm, HoldComplete], $Failed];

    iCellFromHold[h_HoldComplete] :=
      Module[{head},
        head = Replace[h, HoldComplete[x_] :> Head[x]];
        If[MemberQ[{Cell, TextCell, ExpressionCell}, head],
          Quiet @ Check[ReleaseHold[h], $Failed],
          $Failed]
      ];

    Catch[
      If[held =!= $Failed,
        Which[
          MatchQ[held, HoldComplete[CellPrint[_]]],
            cellArgHold = held /.
              HoldComplete[CellPrint[arg_]] :> HoldComplete[arg];
            cellExpr = iCellFromHold[cellArgHold];
            If[MatchQ[cellExpr, Cell[__]],
              NotebookWrite[nb, cellExpr, After];
              Throw[Null, "done"]],

          MatchQ[held, HoldComplete[CompoundExpression[CellPrint[_], __]]],
            cellArgHold = held /.
              HoldComplete[CompoundExpression[CellPrint[arg_], rest__]] :>
                HoldComplete[arg];
            restHold = held /.
              HoldComplete[CompoundExpression[CellPrint[arg_], rest__]] :>
                HoldComplete[CompoundExpression[rest]];
            cellExpr = iCellFromHold[cellArgHold];
            If[MatchQ[cellExpr, Cell[__]],
              NotebookWrite[nb, cellExpr, After];
              restBoxes = restHold /.
                HoldComplete[e_] :> MakeBoxes[e, StandardForm];
              NotebookWrite[nb, Cell[BoxData[restBoxes], "Input"], After];
              Throw[Null, "done"]],

          (* --- \:5b89\:5168\:306a\:6570\:5f0f\:306e\:307f MakeBoxes[StandardForm] \:3067\:30bf\:30a4\:30d7\:30bb\:30c3\:30c8
                Integrate\[RightArrow]\[Integral], Sum\[RightArrow]\[CapitalSigma], Subscript\[RightArrow]\:4e0b\:4ed8\:304d, Sqrt\[RightArrow]\[Sqrt] \:7b49
                Module/Block/Show \:7b49\:306e\:624b\:7d9a\:304d\:7684\:30b3\:30fc\:30c9\:306f FEParser \:3078 --- *)
          iIsMakeBoxesSafe[held],
            boxes = Quiet @ Check[
              held /. HoldComplete[e_] :>
                MakeBoxes[e, StandardForm],
              $Failed];
            If[boxes =!= $Failed,
              NotebookWrite[nb,
                Cell[BoxData[boxes], "Input"], After];
              Throw[Null, "done"]]
        ]
      ];
      (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: FEParser \:30d9\:30fc\:30b9 *)
      NBAccess`NBWriteCode[nb, trimmed]
    , "done"]
  ];

(* ============================================================
   \:30ed\:30fc\:30c9\:6642\:30e1\:30c3\:30bb\:30fc\:30b8
   ============================================================ *)


(* ============================================================
   \:30bb\:30eb\:30de\:30fc\:30af\:95a2\:6570 (\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:7248)
   ============================================================ *)

NBAccess`NBGetConfidentialTag[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Missing[], iGetConfTag[cell]]
  ];

NBAccess`NBSetConfidentialTag[nb_NotebookObject, cellIdx_Integer, val_] :=
  Module[{cell, tags, cc},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    cc   = Replace[Lookup[tags, "claudecode", {}],
             Except[_List | _Association] -> {}];
    cc   = If[AssociationQ[cc], Normal[cc], cc];
    cc   = DeleteCases[cc, "confidential" -> _];
    cc   = Append[cc, "confidential" -> val];
    tags = If[AssociationQ[tags], Normal[tags], tags];
    tags = DeleteCases[tags, "claudecode" -> _];
    tags = Append[tags, "claudecode" -> cc];
    Quiet[SetOptions[cell, TaggingRules -> tags]]
  ];

(* ============================================================
   Stage 9 P1 Step 7: \:30bb\:30eb\:5358\:4f4d\:306e\:6570\:5024 PrivacyLevel
   ------------------------------------------------------------
   \:5f93\:6765\:306e confidential \:30bf\:30b0 (True/False) \:306b\:52a0\:3048\:3001
   claudecode \:30bf\:30ae\:30f3\:30b0\:30eb\:30fc\:30eb\:5185\:306b "privacyLevel" \:6570\:5024\:30ad\:30fc\:3092\:6301\:3064\:3002
   NBCellPrivacyLevel \:306f\:3053\:306e\:6570\:5024\:3092\:6700\:512a\:5148\:3067\:8aad\:3080\:3002
   ============================================================ *)

(* \:30bb\:30eb\:306e\:6570\:5024 privacyLevel \:30bf\:30b0\:3092\:8aad\:3080\:3002\:7121\:3051\:308c\:3070 Missing[]\:3002 *)
iGetCellPrivacyLevelTag[cell_] :=
  Module[{v},
    v = Quiet[CurrentValue[cell,
      {TaggingRules, "claudecode", "privacyLevel"}]];
    If[NumericQ[v], N[v], Missing[]]
  ];

(* \:30bb\:30eb\:306e\:6570\:5024 privacyLevel \:30bf\:30b0\:3092\:8a2d\:5b9a\:3002level \:304c Missing/None \:306a\:3089\:524a\:9664\:3002 *)
iSetCellPrivacyLevelTag[nb_NotebookObject, cellIdx_Integer, level_] :=
  Module[{cell, tags, cc},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    cc   = Replace[Lookup[tags, "claudecode", {}],
             Except[_List | _Association] -> {}];
    cc   = If[AssociationQ[cc], Normal[cc], cc];
    cc   = DeleteCases[cc, "privacyLevel" -> _];
    cc   = If[NumericQ[level],
      Append[cc, "privacyLevel" -> N[level]], cc];
    tags = If[AssociationQ[tags], Normal[tags], tags];
    tags = DeleteCases[tags, "claudecode" -> _];
    tags = Append[tags, "claudecode" -> cc];
    Quiet[SetOptions[cell, TaggingRules -> tags]]
  ];

(* \:6a5f\:5bc6\:30de\:30fc\:30af: \:8d64\:80cc\:666f + WarningSign\:ff08\:67a0\:306a\:3057 \[LongDash] CellFrame \:306f documentation \:7cfb\:304c\:7ba1\:7406\:ff09 *)
NBAccess`$NBConfidentialCellOpts = {
  Background    -> RGBColor[1, 0.90, 0.90],
  CellDingbat  -> Cell["\[WarningSign]",
    FontColor -> RGBColor[0.75, 0.1, 0.1], FontSize -> 14]
};

(* \:4f9d\:5b58\:6a5f\:5bc6\:30de\:30fc\:30af: \:6a59\:80cc\:666f + WarningSign\:ff08\:67a0\:306a\:3057\:ff09 *)
NBAccess`$NBDependentCellOpts = {
  Background    -> RGBColor[1, 0.95, 0.85],
  CellDingbat  -> Cell["\[WarningSign]",
    FontColor -> RGBColor[0.85, 0.50, 0.10], FontSize -> 12]
};

(* \:6a5f\:5bc6\:89e3\:9664\:6e08\:307f\:ff08\:76f4\:63a5\:6a5f\:5bc6\:3060\:3063\:305f\:3082\:306e\:ff09: \:3054\:304f\:8584\:3044\:8d64\:80cc\:666f + \:30c1\:30a7\:30c3\:30af\:30de\:30fc\:30af *)
NBAccess`$NBDeclassifiedDirectCellOpts = {
  Background     -> RGBColor[1, 0.97, 0.97],
  CellDingbat    -> Cell["\[CheckmarkedBox]",
    FontColor -> RGBColor[0.65, 0.35, 0.35], FontSize -> 12]
};

(* \:6a5f\:5bc6\:89e3\:9664\:6e08\:307f\:ff08\:4f9d\:5b58\:6a5f\:5bc6\:3060\:3063\:305f\:3082\:306e\:ff09: \:3054\:304f\:8584\:3044\:6a59\:80cc\:666f + \:30c1\:30a7\:30c3\:30af\:30de\:30fc\:30af *)
NBAccess`$NBDeclassifiedDependentCellOpts = {
  Background     -> RGBColor[1, 0.98, 0.95],
  CellDingbat    -> Cell["\[CheckmarkedBox]",
    FontColor -> RGBColor[0.70, 0.50, 0.25], FontSize -> 12]
};

(* Stage 9 P1 Step 7: NBMarkCellConfidential \:3092\:6570\:5024\:30ec\:30d9\:30eb\:5bfe\:5fdc\:306b\:62e1\:5f35\:3002
   - NBMarkCellConfidential[nb, idx]            \[Rule] level = 1.0 (\:5f93\:6765\:4e92\:63db)
   - NBMarkCellConfidential[nb, idx, level]     \[Rule] \:4efb\:610f\:306e\:6570\:5024 0.0-1.0
   level > 0.5 \:306e\:3068\:304d\:8996\:899a\:30de\:30fc\:30af (\:80cc\:666f\:8272) \:3092\:4ed8\:3051\:3001
   level <= 0.5 \:306a\:3089\:8996\:899a\:30de\:30fc\:30af\:3092\:5916\:3059\:3002
   confidential \:30bf\:30b0 (True/False) \:3082 level \:306b\:5fdc\:3058\:3066\:9023\:52d5\:3055\:305b\:3001
   \:65e7\:30b3\:30fc\:30c9\:3068\:306e\:4e92\:63db\:6027\:3092\:4fdd\:3064\:3002
   NBAccess \:898f\:7d04\:306b\:5f93\:3044 PrivacySpec \:30aa\:30d7\:30b7\:30e7\:30f3\:3092\:6301\:3064\:3002 *)
Options[NBAccess`NBMarkCellConfidential] = {PrivacySpec -> Automatic};

NBAccess`NBMarkCellConfidential[nb_NotebookObject, cellIdx_Integer,
    opts:OptionsPattern[]] :=
  NBAccess`NBMarkCellConfidential[nb, cellIdx, 1.0, opts];

NBAccess`NBMarkCellConfidential[nb_NotebookObject, cellIdx_Integer,
    level_?NumericQ, opts:OptionsPattern[]] :=
  Module[{lv},
    lv = N[Clip[level, {0.0, 1.0}]];
    (* \:6570\:5024 privacyLevel \:30bf\:30b0\:3092\:8a2d\:5b9a *)
    iSetCellPrivacyLevelTag[nb, cellIdx, lv];
    (* confidential \:30bf\:30b0\:3092 level \:306b\:9023\:52d5 (> 0.5 \:3067 True) *)
    NBAccess`NBSetConfidentialTag[nb, cellIdx, lv > 0.5];
    (* \:8996\:899a\:30de\:30fc\:30af: level > 0.5 \:306a\:3089\:6a5f\:5bc6\:8272\:3001\:305d\:308c\:4ee5\:4e0b\:306f\:89e3\:9664 *)
    If[lv > 0.5,
      NBAccess`NBCellSetOptions[nb, cellIdx,
        Sequence @@ NBAccess`$NBConfidentialCellOpts],
      NBAccess`NBCellSetOptions[nb, cellIdx,
        Background -> Inherited, CellDingbat -> Inherited]];
    lv
  ];

(* ============================================================
   NBInsertArtifactCell: SourceVault artifact URI \:306e privacy-marking \:4ed8\:304d\:8868\:793a
   ------------------------------------------------------------
   - \:5185\:5bb9\:89e3\:6c7a\:306f SourceVault`SourceVaultResolveArtifactContent (sanctioned reader)\:3002
     bytes \:304c PrivacyLevel \:306a\:3057\:3067\:88f8\:306e\:307e\:307e\:547c\:3073\:51fa\:3057\:5074\:3078\:6e21\:308b\:7d4c\:8def\:3092\:4f5c\:3089\:306a\:3044\:3002
   - privacy marking \:306f\:30bb\:30eb\:5f0f\:306b\:69cb\:7bc9\:6642\:306b\:713c\:304d\:8fbc\:3080:
     TaggingRules "claudecode" {privacyLevel, confidential(>0.5)} \:306f
     NBMarkCellConfidential \:304c\:66f8\:304f\:3082\:306e\:3068\:540c\:4e00\:30c7\:30fc\:30bf\:3002\:8996\:899a\:30de\:30fc\:30af\:306f
     $NBConfidentialCellOpts \:3092\:53c2\:7167 (\:91cd\:8907\:5b9a\:7fa9\:3057\:306a\:3044)\:3002
     \:66f8\:304d\:8fbc\:307f\:5f8c\:306e cell index \:63a2\:7d22\:3092\:3057\:306a\:3044\:305f\:3081 deferred output \:3068\:3082\:6574\:5408\:3057\:3001
     \:30ec\:30fc\:30b9\:304c\:7121\:3044\:3002
   ============================================================ *)

(* artifact \:8868\:793a\:30bb\:30eb\:5f0f\:3092\:69cb\:7bc9\:3059\:308b\:7d14\:95a2\:6570 (headless \:30c6\:30b9\:30c8\:53ef\:80fd)\:3002 *)
iNBArtifactCellExpr[content_Association, dispOpts_Association] := Module[
  {kind, pl, mt, uri, fname, file, inner, tagRules, confOpts, img, maxSz, videoCell},
  kind = Lookup[content, "MediaKind", "Binary"];
  pl = With[{p = Lookup[content, "PrivacyLevel", Missing[]]},
    If[NumericQ[p], N @ Clip[p, {0., 1.}], 1.0]];   (* \:6b20\:843d\:306f fail-closed 1.0 *)
  mt = Lookup[content, "MediaType", "application/octet-stream"];
  uri = Lookup[content, "URI", Missing[]];
  fname = Lookup[content, "Filename", Missing[]];
  file = Lookup[content, "File", Missing[]];
  maxSz = Lookup[dispOpts, "MaxImageSize", 480];
  videoCell = TrueQ @ Lookup[dispOpts, "VideoCell", False];
  inner = Switch[kind,
    "Image",
      img = Quiet @ Check[ImportByteArray[Lookup[content, "Bytes", $Failed]], $Failed];
      If[ImageQ[img],
        Cell[BoxData[ToBoxes[
          If[NumericQ[maxSz], Image[img, ImageSize -> UpTo[maxSz]], img]]], "Output"],
        Cell["[\:753b\:50cf\:3092\:8aad\:307f\:8fbc\:3081\:307e\:305b\:3093\:3067\:3057\:305f: " <> ToString[uri] <> "]", "Text"]],
    "Text",
      Cell[Lookup[content, "Text", ""], "Text"],
    _,  (* Video / Binary: \:30d5\:30a1\:30a4\:30eb\:30ea\:30f3\:30af (Video \:306f option \:3067 Video \:30bb\:30eb) *)
      Which[
        ! StringQ[file],
          Cell["[\:30d5\:30a1\:30a4\:30eb\:672a materialize: " <> ToString[uri] <> "]", "Text"],
        kind === "Video" && videoCell && FileExistsQ[file],
          (* Video \:69cb\:7bc9\:304c\:5931\:6557\:3059\:308b\:74b0\:5883 (codec \:7b49) \:3067\:306f Hyperlink \:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af *)
          With[{vb = Quiet @ Check[BoxData[ToBoxes[Video[file]]], $Failed]},
            If[vb === $Failed,
              Cell[BoxData[ToBoxes[Hyperlink[
                "\[FilledRightTriangle] " <> If[StringQ[fname], fname, FileNameTake[file]],
                File[file]]]], "Output"],
              Cell[vb, "Output"]]],
        True,
          Cell[BoxData[ToBoxes[
            Hyperlink[
              "\[FilledRightTriangle] " <> If[StringQ[fname], fname, FileNameTake[file]],
              File[file]]]], "Output"]]];
  tagRules = {
    "claudecode" -> {"privacyLevel" -> pl, "confidential" -> (pl > 0.5)},
    "SourceVault" -> {"ArtifactCell" -> {
      "URI" -> If[StringQ[uri], uri, ToString[uri]],
      "ArtifactId" -> Lookup[content, "ArtifactId", Missing[]],
      "MediaKind" -> kind, "MediaType" -> mt}}};
  confOpts = If[pl > 0.5, NBAccess`$NBConfidentialCellOpts, {}];
  (* Cell[content, style] \:306b options \:3092\:5408\:6210 (Append \:306e\:591a\:5f15\:6570\:5316\:3092\:907f\:3051\:308b) *)
  Cell @@ Join[List @@ inner, {TaggingRules -> tagRules}, confOpts]];

Options[NBAccess`NBInsertArtifactCell] = {
  "VideoCell" -> False, "MaxImageSize" -> 480, "Materialize" -> Automatic};

NBAccess`NBInsertArtifactCell[nb_NotebookObject, uri_String,
    opts:OptionsPattern[]] := Module[{resolveFn, content, cell, pl},
  If[Length[Names["SourceVault`SourceVaultResolveArtifactContent"]] === 0,
    Return[<|"Status" -> "Error", "Reason" -> "SourceVaultNotLoaded",
      "Detail" -> "SourceVault (SourceVault_core) \:304c\:30ed\:30fc\:30c9\:3055\:308c\:3066\:3044\:307e\:305b\:3093\:3002"|>]];
  resolveFn = Symbol["SourceVault`SourceVaultResolveArtifactContent"];
  content = Quiet @ Check[
    resolveFn[uri, "Materialize" -> OptionValue["Materialize"]], $Failed];
  If[! AssociationQ[content],
    Return[<|"Status" -> "Error", "Reason" -> "ResolveFailed", "URI" -> uri|>]];
  If[Lookup[content, "Status", ""] =!= "OK", Return[content]];
  cell = iNBArtifactCellExpr[Join[content, <|"URI" -> uri|>],
    <|"VideoCell" -> OptionValue["VideoCell"],
      "MaxImageSize" -> OptionValue["MaxImageSize"]|>];
  NBAccess`NBWriteCell[nb, cell];
  pl = With[{p = Lookup[content, "PrivacyLevel", Missing[]]},
    If[NumericQ[p], N[p], 1.0]];
  <|"Status" -> "OK", "URI" -> uri,
    "MediaKind" -> Lookup[content, "MediaKind", Missing[]],
    "PrivacyLevel" -> pl, "Marked" -> (pl > 0.5)|>];

NBAccess`NBInsertArtifactCell[uri_String, opts:OptionsPattern[]] :=
  NBAccess`NBInsertArtifactCell[EvaluationNotebook[], uri, opts];

(* ============================================================
   Stage 9 P1 Step 7: NBSetSnapshotPrivacyLevel (API \:30b9\:30bf\:30d6)
   ------------------------------------------------------------
   SourceVault snapshot \:306e PrivacyLevel \:30d5\:30a3\:30fc\:30eb\:30c9\:3092\:66f4\:65b0\:3059\:308b\:3002
   snapshot \:306e PrivacyLevel \:306f\:901a\:5e38\:30bb\:30eb\:5224\:5b9a\:304b\:3089\:306e\:5c0e\:51fa\:5024\:3060\:304c\:3001
   \:4eba\:9593\:304c\:660e\:793a\:7684\:306b\:4e0a\:66f8\:304d\:3057\:305f\:3044\:5834\:5408\:306b\:4f7f\:3046\:3002
   \:3053\:306e\:95a2\:6570\:306f $NBApprovalHeads \:306b\:767b\:9332\:3055\:308c\:3001\:5b9f\:884c\:6642\:306b\:627f\:8a8d\:30b2\:30fc\:30c8\:3092\:767a\:706b\:3055\:305b\:3002
   NBAccess \:898f\:7d04\:306b\:5f93\:3044 PrivacySpec \:30aa\:30d7\:30b7\:30e7\:30f3\:3092\:6301\:3064\:3002

   \:73fe\:6bb5\:968e\:306f\:6700\:5c0f\:5b9f\:88c5: SourceVault \:304c\:30ed\:30fc\:30c9\:3055\:308c\:3066\:3044\:308c\:3070\:3001
   snapshot record \:306e PrivacyLevel \:3092\:66f4\:65b0\:3059\:308b\:95a2\:6570\:3092\:547c\:3076\:3002 *)
Options[NBAccess`NBSetSnapshotPrivacyLevel] = {PrivacySpec -> Automatic};

NBAccess`NBSetSnapshotPrivacyLevel[snapshotId_String, level_?NumericQ,
    opts:OptionsPattern[]] :=
  Module[{lv, fn},
    lv = N[Clip[level, {0.0, 1.0}]];
    (* SourceVault \:304c\:30ed\:30fc\:30c9\:3055\:308c\:3066\:3044\:308c\:3070\:59d4\:8b72 *)
    If[Length[Names["SourceVault`SourceVaultSetSnapshotPrivacyLevel"]] > 0,
      fn = Symbol["SourceVault`SourceVaultSetSnapshotPrivacyLevel"];
      fn[snapshotId, lv],
      <|"Status" -> "Failed",
        "Reason" -> "SourceVaultNotLoaded",
        "Detail" ->
          "SourceVault \:304c\:30ed\:30fc\:30c9\:3055\:308c\:3066\:3044\:307e\:305b\:3093\:3002snapshot \:64cd\:4f5c\:306b\:306f SourceVault \:304c\:5fc5\:8981\:3067\:3059\:3002"|>]
  ];

NBAccess`NBMarkCellDependent[nb_NotebookObject, cellIdx_Integer] := (
  Module[{cell, tags, cc},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    cc   = Replace[Lookup[tags, "claudecode", {}],
             Except[_List | _Association] -> {}];
    cc   = If[AssociationQ[cc], Normal[cc], cc];
    cc   = DeleteCases[cc, "confidential" -> _ | "dependent" -> _];
    cc   = Append[cc, "confidential" -> True];
    cc   = Append[cc, "dependent"    -> True];
    tags = If[AssociationQ[tags], Normal[tags], tags];
    tags = DeleteCases[tags, "claudecode" -> _];
    tags = Append[tags, "claudecode" -> cc];
    Quiet[SetOptions[cell, TaggingRules -> tags]]
  ];
  NBAccess`NBCellSetOptions[nb, cellIdx, Sequence @@ NBAccess`$NBDependentCellOpts]
);

NBAccess`NBUnmarkCell[nb_NotebookObject, cellIdx_Integer] := (
  NBAccess`NBSetConfidentialTag[nb, cellIdx, False];
  Module[{cell, tags, cc},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    cc   = Replace[Lookup[tags, "claudecode", {}],
             Except[_List | _Association] -> {}];
    cc   = If[AssociationQ[cc], Normal[cc], cc];
    (* Stage 9 P1 Step 7: \:6570\:5024 privacyLevel \:30bf\:30b0\:3082\:30af\:30ea\:30a2 *)
    cc   = DeleteCases[cc, "dependent" -> _ | "privacyLevel" -> _];
    tags = If[AssociationQ[tags], Normal[tags], tags];
    tags = DeleteCases[tags, "claudecode" -> _];
    If[Length[cc] > 0, tags = Append[tags, "claudecode" -> cc]];
    Quiet[SetOptions[cell, TaggingRules -> tags]]];
  Module[{cell2 = iResolveCell[nb, cellIdx]},
    If[cell2 =!= $Failed,
      Quiet[SetOptions[cell2, {
        Background     -> Inherited,
        CellDingbat    -> Inherited
      }]]]]
);

(* \:4f9d\:5b58\:30de\:30fc\:30af\:306e\:307f\:30ea\:30bb\:30c3\:30c8\:ff08\:672a\:5224\:5b9a\:72b6\:614b\:306b\:623b\:3059\:ff09 *)
iResetDependentMark[nb_NotebookObject, cellIdx_Integer] := (
  Module[{cell, tags, cc},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    tags = Replace[Quiet[CurrentValue[cell, TaggingRules]],
             Except[_List | _Association] -> {}];
    cc   = Replace[Lookup[tags, "claudecode", {}],
             Except[_List | _Association] -> {}];
    cc   = If[AssociationQ[cc], Normal[cc], cc];
    cc   = DeleteCases[cc, "confidential" -> _ | "dependent" -> _];
    tags = If[AssociationQ[tags], Normal[tags], tags];
    tags = DeleteCases[tags, "claudecode" -> _];
    If[Length[cc] > 0, tags = Append[tags, "claudecode" -> cc]];
    Quiet[SetOptions[cell, TaggingRules -> tags]]];
  Module[{cell2 = iResolveCell[nb, cellIdx]},
    If[cell2 =!= $Failed,
      Quiet[SetOptions[cell2, {
        Background     -> Inherited,
        CellDingbat    -> Inherited
      }]]]]
);

(* ============================================================
   \:30bb\:30eb\:5185\:5bb9\:5206\:6790 API (claudecode\:304b\:3089\:79fb\:8a2d)
   ============================================================ *)

(* \:79d8\:5bc6\:5909\:6570\:3092\:53c2\:7167\:3057\:3066\:3044\:308b\:304b *)
NBAccess`NBCellUsesConfidentialSymbol[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[False]];
    iCellUsesConfSymbol[nb, cell]
  ];

(* \:30bb\:30eb\:5185\:5bb9\:304b\:3089 Set/SetDelayed \:306e LHS \:5909\:6570\:540d\:3092\:62bd\:51fa *)
NBAccess`NBCellExtractVarNames[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell, text, matches, style},
    (* \:51fa\:529b/\:30c6\:30ad\:30b9\:30c8/\:898b\:51fa\:3057\:7b49\:306e\:30bb\:30eb\:306f var = ... \:306e\:5b9a\:7fa9\:3092\:6301\:305f\:306a\:3044\:3002
       \:7279\:306b\:5de8\:5927\:306a Output (Dataset \:7b49) \:306b\:5bfe\:3057\:4e0b\:306e NotebookRead \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:304c
       \:8d70\:308b\:3068\:30bb\:30eb\:5168\:4f53\:3092\:30ab\:30fc\:30cd\:30eb\:3078\:8aad\:307f\:8fbc\:307f\:3001FrontEnd \:304c\:300c\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30b3\:30f3\:30c6\:30f3\:30c4\:3092
       \:30d5\:30a9\:30fc\:30de\:30c3\:30c8\:3057\:3066\:3044\:307e\:3059\:300d\:306e\:307e\:307e\:9577\:6642\:9593\:30d6\:30ed\:30c3\:30af\:3059\:308b (2026-06-06)\:3002
       \:5909\:6570\:5b9a\:7fa9\:304c\:3042\:308a\:5f97\:308b Input/Code/ExternalLanguage \:4ee5\:5916\:306f\:5373 {} \:3092\:8fd4\:3059\:3002 *)
    style = Quiet[NBAccess`NBCellStyle[nb, cellIdx]];
    If[!MemberQ[{"Input", "Code", "ExternalLanguage"}, style], Return[{}]];
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[{}]];
    text = Quiet[iCellToInputText[cell]];
    If[!StringQ[text] || StringLength[text] === 0,
      text = NBAccess`NBCellExprToText[Quiet[NotebookRead[cell]]]];
    If[!StringQ[text] || StringLength[text] === 0, Return[{}]];
    matches = StringCases[text,
      RegularExpression[
        "(?:^|;|\\n)\\s*((?:[\\p{L}$][\\p{L}\\p{N}$]*))\\s*:?=(?!=)"
      ] :> "$1"];
    DeleteDuplicates[Select[matches,
      !MemberQ[{"If","Module","With","Block","Do","Table","Map","Select",
                "Function","While","For","Switch","Which","Return",
                "Set","SetDelayed","Rule","RuleDelayed"}, #] &]]
  ];

(* Confidential[] \:5185\:306e\:4ee3\:5165\:5148\:5909\:6570\:540d\:3092\:62bd\:51fa *)
NBAccess`NBCellExtractAssignedNames[nb_NotebookObject, cellIdx_Integer] :=
  Module[{text, matches},
    text = NBAccess`NBCellToText[nb, cellIdx];
    If[!StringQ[text] || StringLength[text] === 0, Return[{}]];
    matches = StringCases[text,
      RegularExpression["(?<![\\p{L}\\p{N}$])([\\p{L}$][\\p{L}\\p{N}$]*)\\s*=\\s*Confidential\\b"] :> "$1"];
    matches = Join[matches, StringCases[text,
      RegularExpression["Confidential\\s*\\[\\s*([\\p{L}$][\\p{L}\\p{N}$]*)\\s*="] :> "$1"]];
    DeleteDuplicates[matches]
  ];

(* \:30d7\:30ed\:30f3\:30d7\:30c8\:304b\:3089\:9664\:5916\:3059\:3079\:304d\:304b *)
NBAccess`NBShouldExcludeFromPrompt[nb_NotebookObject, cellIdx_Integer] :=
  Module[{tag, depTag},
    tag = NBAccess`NBGetConfidentialTag[nb, cellIdx];
    Which[
      tag === True, True,
      tag === False, False,
      NBAccess`NBCellUsesConfidentialSymbol[nb, cellIdx], True,
      True, False
    ]
  ];

(* Claude \:95a2\:6570\:547c\:3073\:51fa\:3057\:30bb\:30eb\:304b\:5224\:5b9a *)
$iClaudeFunctions = {"ClaudeQuery","ClaudeEval","ContinueEval",
                     "ClaudeMath","ClaudeSpec","ClaudeExtractCode","ClaudeExtractAllCode"};

NBAccess`NBIsClaudeFunctionCell[nb_NotebookObject, cellIdx_Integer] :=
  Module[{text},
    text = NBAccess`NBCellToText[nb, cellIdx];
    If[!StringQ[text], Return[False]];
    AnyTrue[$iClaudeFunctions,
      StringContainsQ[text, RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <> "\\s*\\["]] &]
  ];

(* ============================================================
   \:4f9d\:5b58\:30b0\:30e9\:30d5: \:5909\:6570\[RightArrow]\:4f9d\:5b58\:5909\:6570\:30bb\:30c3\:30c8
   ============================================================ *)

$iIgnoredIdents = {
  "If","Module","With","Block","Do","Table","Map","Select","Cases","Position",
  "Plus","Times","Power","Divide","List","Set","SetDelayed","Rule","RuleDelayed",
  "True","False","Null","Return","Function","And","Or","Not","All","None",
  "Integer","Real","String","Symbol","Head","Length","Range","Part","Slot",
  "Apply","Scan","NestList","Nest","FixedPoint","While","For","Switch","Which",
  "Print","Throw","Catch","Check","Quiet","Association","Lookup","Keys","Values",
  "First","Last","Rest","Take","Drop","Append","Prepend","Join","Union",
  "Intersection","Complement","Sort","Riffle","StringJoin","StringSplit",
  "ToString","ToExpression","NumberQ","StringQ","ListQ","NumericQ","AtomQ",
  "Sum","Product","Total","Mean","Max","Min","Abs","Round","Floor","Ceiling",
  "Sin","Cos","Tan","Exp","Log","Sqrt","N","Re","Im","Conjugate",
  "Replace","ReplaceAll","ReplaceRepeated","StringReplace","StringCases",
  "Dimensions","Flatten","Transpose","Reverse","RotateLeft","RotateRight",
  "DeleteDuplicates","DeleteCases","Select","Pick","Gather","GatherBy",
  "SortBy","GroupBy","Tally","Counts","Merge","AssociationMap",
  "KeyValueMap","KeySelect","KeyDrop","KeyTake","KeyExistsQ",
  "Map","MapAt","MapIndexed","MapThread","Through","Operate",
  "Fold","FoldList","Accumulate","Inner","Outer",
  "Import","Export","FileExistsQ","DirectoryQ","FileNames",
  "DateString","AbsoluteTime","DateObject","Now","Today",
  "Style","Row","Column","Grid","Graphics","Show","Plot","ListPlot",
  "Dataset","Normal","Query","Interpreter",
  "Needs","Get","Begin","End","BeginPackage","EndPackage",
  "SetAttributes","Attributes","ClearAll","Clear","Remove",
  "HoldForm","HoldComplete","Hold","Unevaluated","Evaluate","ReleaseHold",
  "MatchQ","FreeQ","MemberQ","AnyTrue","AllTrue","NoneTrue",
  "Confidential","MarkConfidential","UnmarkConfidential","IsConfidential"
};

iStripStrings[text_String] :=
  StringReplace[text, RegularExpression["\"(?:[^\"\\\\]|\\\\.)*\""] -> " "];

(* ;; (Span) \:3092\:4fdd\:8b77\:3057\:3066 ; (CompoundExpression) \:3068 \n \:3067\:5206\:5272
   InputText \:5f62\:5f0f\:3067\:306f "1 ;; 2" \:306e\:3088\:3046\:306b\:30b9\:30da\:30fc\:30b9\:304c\:5165\:308b\:5834\:5408\:304c\:3042\:308b\:3002
   ";" \:3068 ";" \:306e\:9593\:306b\:30b9\:30da\:30fc\:30b9\:304c\:3042\:3063\:3066\:3082 Span \:3068\:3057\:3066\:4fdd\:8b77\:3059\:308b\:3002 *)
$iSpanPlaceholder = "__NBACCESS_SPAN__";
iSplitStatements[text_String] :=
  Module[{safe, lines},
    (* ;; \:304a\:3088\:3073 ; ; \:ff08\:30b9\:30da\:30fc\:30b9\:542b\:3080\:ff09\:3092\:4e00\:62ec\:4fdd\:8b77 *)
    safe = StringReplace[text, RegularExpression[";\\s*;"] -> $iSpanPlaceholder];
    lines = StringSplit[safe, RegularExpression["[;\\n]"]];
    StringReplace[#, $iSpanPlaceholder -> ";;"] & /@ lines
  ];

iExtractAssignments[text_String] :=
  Module[{stripped, unwrapped, lines, result = {}},
    stripped = iStripStrings[text];
    (* Confidential[expr] \:30e9\:30c3\:30d1\:30fc\:3092\:9664\:53bb\:3057\:3066\:5185\:90e8\:306e\:4ee3\:5165\:3092\:691c\:51fa *)
    unwrapped = StringReplace[stripped,
      RegularExpression["\\bConfidential\\s*\\["] -> ""];
    lines = iSplitStatements[unwrapped];
    Do[
      Module[{trimmed, lhs, rhs, rhsVars, outRefs},
        trimmed = StringTrim[line];
        If[StringMatchQ[trimmed,
             RegularExpression["[\\p{L}$][\\p{L}\\p{N}$]*\\s*:?=(?!=).*"]],
          lhs = First[StringCases[trimmed,
            RegularExpression["^([\\p{L}$][\\p{L}\\p{N}$]*)\\s*:?="] -> "$1"], None];
          If[lhs =!= None,
            rhs = StringReplace[trimmed,
              RegularExpression["^[\\p{L}$][\\p{L}\\p{N}$]*\\s*:?=\\s*"] -> ""];
            rhsVars = DeleteDuplicates @ Select[
              StringCases[rhs,
                RegularExpression["(?<![\\p{L}\\p{N}$])([\\p{L}$][\\p{L}\\p{N}$]*)(?![\\p{L}\\p{N}$])"] -> "$1"],
              !MemberQ[NBAccess`Private`$iIgnoredIdents, #] &];
            outRefs = Join[
              StringCases[rhs, RegularExpression["%([0-9]+)"] -> "Out$1"],
              StringCases[rhs, RegularExpression["Out\\[([0-9]+)\\]"] -> "Out$1"]];
            rhsVars = DeleteDuplicates[Join[rhsVars, outRefs]];
            AppendTo[result, {lhs, rhsVars}]]]],
      {line, lines}];
    result
  ];

(* \:95a2\:6570\:5b9a\:7fa9\:89e3\:6790 *)
iIsFuncDefLine[s_String] :=
  StringMatchQ[s,
    RegularExpression["[\\p{L}$][\\p{L}\\p{N}$]*\\s*\\x5B[^\\x5D]*_.*"]];

iExtractFuncName[s_String] :=
  First[StringCases[s,
    RegularExpression["^\\s*([\\p{L}$][\\p{L}\\p{N}$]*)\\s*\\x5B"] :> "$1"],
  None];

iExtractPatternVars[lhs_String] :=
  DeleteDuplicates[StringCases[lhs,
    RegularExpression["([\\p{L}$][\\p{L}\\p{N}$]*)_"] :> "$1"]];

iExtractScopeVars[rhs_String] :=
  DeleteDuplicates[Flatten[
    Map[Function[vl,
      StringCases[vl,
        RegularExpression["(?:^|,)\\s*([\\p{L}$][\\p{L}\\p{N}$]*)"] :> "$1"]],
    StringCases[rhs,
      RegularExpression[
        "(?:Module|Block|With|Function)\\s*\\x5B\\s*\\{([^}]*)\\}"] :> "$1"]]
  ]];

iExtractAllIdents[rhs_String] :=
  DeleteDuplicates @ Select[
    StringCases[rhs,
      RegularExpression[
        "(?<![\\p{L}\\p{N}$])([\\p{L}$][\\p{L}\\p{N}$]*)(?![\\p{L}\\p{N}$])"]
        :> "$1"],
    !MemberQ[$iIgnoredIdents, #] &];

iExtractFuncDefs[text_String] :=
  Module[{stripped, lines, result = {}, trimmed, funcName,
          lhsPart, rhsPart, pos, patVars, scopeVars, allIds, globalDeps},
    stripped = iStripStrings[text];
    lines = iSplitStatements[stripped];
    Do[
      trimmed = StringTrim[line];
      If[iIsFuncDefLine[trimmed],
        funcName = iExtractFuncName[trimmed];
        If[funcName =!= None && !MemberQ[$iIgnoredIdents, funcName],
          pos = StringPosition[trimmed, ":="];
          If[Length[pos] > 0,
            lhsPart = StringTake[trimmed, pos[[1, 1]] - 1];
            rhsPart = StringTrim[StringDrop[trimmed, pos[[1, 2]]]],
            pos = StringPosition[trimmed, RegularExpression["=(?!=)"]];
            If[Length[pos] > 0,
              lhsPart = StringTake[trimmed, pos[[1, 1]] - 1];
              rhsPart = StringTrim[StringDrop[trimmed, pos[[1, 2]]]],
              lhsPart = ""; rhsPart = ""]];
          If[rhsPart =!= "",
            patVars   = iExtractPatternVars[lhsPart];
            scopeVars = iExtractScopeVars[rhsPart];
            allIds    = iExtractAllIdents[rhsPart];
            globalDeps = Complement[allIds, patVars, scopeVars, {funcName}];
            AppendTo[result, {funcName, globalDeps}]]]],
    {line, lines}];
    result
  ];

iIsFuncDefText[text_String] :=
  Length[iExtractFuncDefs[text]] > 0;

iCellNumber[cell_CellObject] :=
  Module[{lbl},
    lbl = Quiet[CurrentValue[cell, CellLabel]];
    If[!StringQ[lbl], Return[None]];
    First[StringCases[lbl,
      RegularExpression["In\\[(\\d+)\\]"] -> "$1"], None]
  ];

NBAccess`NBGetFunctionGlobalDeps[nb_NotebookObject] :=
  Module[{inIndices, result = <||>, text, fd},
    inIndices = NBAccess`NBCellIndicesByStyle[nb, "Input"];
    Do[
      text = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      If[StringQ[text] && text =!= "",
        fd = iExtractFuncDefs[text];
        Do[
          result[First[f]] = Last[f],
          {f, fd}]],
    {idx, inIndices}];
    result
  ];

NBAccess`NBBuildVarDependencies[nb_NotebookObject] :=
  Module[{inIndices, deps = <||>, text, assignments, funcDefs,
          cellLabel, cellNum, definedVars},
    inIndices = NBAccess`NBCellIndicesByStyle[nb, "Input"];
    Do[
      (* InputText \:5f62\:5f0f\:3067\:53d6\:5f97\:30022D\:8868\:793a (Sum, Integral\:7b49) \:3082\:6b63\:3057\:304f\:5909\:63db\:3055\:308c\:308b *)
      text = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      If[!StringQ[text] || text === "", Continue[]];

      (* --- Variable assignments: var = expr --- *)
      assignments = iExtractAssignments[text];
      (* \:30bb\:30eb\:756a\:53f7\:304b\:3089 Out$n \:4eee\:60f3\:5909\:6570\:3092\:5b9a\:7fa9 *)
      cellLabel = NBAccess`NBCellLabel[nb, idx];
      cellNum = If[StringQ[cellLabel],
        First[StringCases[cellLabel,
          RegularExpression["In\\[(\\d+)\\]"] -> "$1"], None],
        None];
      definedVars = Map[First, assignments];
      If[cellNum =!= None && Length[definedVars] > 0,
        With[{allRhsVars = DeleteDuplicates[
                Join @@ Map[Last, assignments]]},
          deps["Out$" <> cellNum] =
            DeleteDuplicates[Join[
              Lookup[deps, "Out$" <> cellNum, {}],
              allRhsVars]]]];
      Do[
        With[{lhs = First[a], rhsVars = Last[a]},
          deps[lhs] = DeleteDuplicates[
            Join[Lookup[deps, lhs, {}], rhsVars]]],
        {a, assignments}];

      (* --- Function definitions: f[x_] := body --- *)
      funcDefs = iExtractFuncDefs[text];
      Do[
        With[{fname = First[fd], globalDeps = Last[fd]},
          deps[fname] = DeleteDuplicates[
            Join[Lookup[deps, fname, {}], globalDeps]]],
        {fd, funcDefs}],

    {idx, inIndices}];
    deps
  ];

(* ============================================================
   \:5168\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:7d71\:5408\:4f9d\:5b58\:30b0\:30e9\:30d5 (LLM\:9001\:4fe1\:76f4\:524d\:306e\:7cbe\:5bc6\:30c1\:30a7\:30c3\:30af\:7528)
   Notebooks[] \:5168\:4f53\:306e Input \:30bb\:30eb\:3092\:8d70\:67fb\:3057\:3001\:5909\:6570\:4f9d\:5b58\:95a2\:4fc2\:3092
   1\:3064\:306e Association \:306b\:30de\:30fc\:30b8\:3057\:3066\:8fd4\:3059\:3002
   \:901a\:5e38\:306e\:30bb\:30eb\:5b9f\:884c\:6642\:306f NBBuildVarDependencies[nb] \:3092\:4f7f\:7528\:3057\:3001
   ClaudeQuery/ClaudeEval/ContinueEval \:306e\:76f4\:524d\:306b\:306e\:307f\:547c\:3073\:51fa\:3059\:3053\:3068\:3002
   ============================================================ *)

NBAccess`NBBuildGlobalVarDependencies[] :=
  Module[{allNBs, deps = <||>, cells, text, assignments, funcDefs},
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[deps]];
    Do[
      cells = Quiet[Cells[nbx]];
      If[!ListQ[cells], Continue[]];
      Do[
        (* Input/Code \:30bb\:30eb\:306e\:307f\:89e3\:6790
           CurrentValue[cell, CellStyle] \:306f\:30ea\:30b9\:30c8 {"Input"} \:3092\:8fd4\:3059\:305f\:3081
           ContainsAny \:3067\:5224\:5b9a\:3059\:308b *)
        If[!ContainsAny[
             Flatten[{Quiet[CurrentValue[c, CellStyle]]}],
             {"Input", "Code"}],
          Continue[]];
        text = Quiet[iCellToInputText[c]];
        If[!StringQ[text] || text === "", Continue[]];

        (* --- Variable assignments: var = expr --- *)
        assignments = iExtractAssignments[text];
        Do[
          With[{lhs = First[a], rhsVars = Last[a]},
            deps[lhs] = DeleteDuplicates[
              Join[Lookup[deps, lhs, {}], rhsVars]]],
          {a, assignments}];

        (* --- Function definitions: f[x_] := body --- *)
        funcDefs = iExtractFuncDefs[text];
        Do[
          With[{fname = First[fd], globalDeps = Last[fd]},
            deps[fname] = DeleteDuplicates[
              Join[Lookup[deps, fname, {}], globalDeps]]],
          {fd, funcDefs}],
      {c, cells}],
    {nbx, allNBs}];
    deps
  ];

(* \:30a4\:30f3\:30af\:30ea\:30e1\:30f3\:30bf\:30eb\:7248: \:65e2\:5b58\:30b0\:30e9\:30d5\:306b\:65b0\:3057\:3044\:30bb\:30eb\:306e\:307f\:8ffd\:52a0
   CellLabel In[x] \:306e x \:304c afterLine \:3088\:308a\:5927\:304d\:3044\:30bb\:30eb\:3060\:3051\:3092\:8d70\:67fb\:3057\:3001
   \:65e2\:5b58\:306e\:4f9d\:5b58\:30b0\:30e9\:30d5\:306b\:30de\:30fc\:30b8\:3059\:308b\:3002
   \:8fd4\:308a\:5024: {updatedDeps, newMaxLine} *)
NBAccess`NBUpdateGlobalVarDependencies[existingDeps_Association,
    afterLine_Integer] :=
  Module[{allNBs, deps = existingDeps, maxLine = afterLine,
          cells, text, assignments, funcDefs, lineNum},
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[{deps, maxLine}]];
    Do[
      cells = Quiet[Cells[nbx]];
      If[!ListQ[cells], Continue[]];
      Do[
        If[!ContainsAny[
             Flatten[{Quiet[CurrentValue[c, CellStyle]]}],
             {"Input", "Code"}],
          Continue[]];
        (* CellLabel \:304b\:3089 In[x] \:306e x \:3092\:53d6\:5f97\:3057\:3001afterLine \:4ee5\:4e0b\:306a\:3089\:30b9\:30ad\:30c3\:30d7 *)
        lineNum = iCellNumber[c];
        If[lineNum === None, Continue[]];
        lineNum = Quiet @ Check[ToExpression[lineNum], 0];
        If[!IntegerQ[lineNum] || lineNum <= afterLine, Continue[]];
        If[lineNum > maxLine, maxLine = lineNum];

        text = Quiet[iCellToInputText[c]];
        If[!StringQ[text] || text === "", Continue[]];

        assignments = iExtractAssignments[text];
        Do[
          With[{lhs = First[a], rhsVars = Last[a]},
            deps[lhs] = DeleteDuplicates[
              Join[Lookup[deps, lhs, {}], rhsVars]]],
          {a, assignments}];

        funcDefs = iExtractFuncDefs[text];
        Do[
          With[{fname = First[fd], globalDeps = Last[fd]},
            deps[fname] = DeleteDuplicates[
              Join[Lookup[deps, fname, {}], globalDeps]]],
          {fd, funcDefs}],
      {c, cells}],
    {nbx, allNBs}];
    {deps, maxLine}
  ];

NBAccess`NBTransitiveDependents[deps_Association, confVars_List] :=
  NBAccess`NBTransitiveDependents[deps, confVars, {}];

(* excludeVars: \:89e3\:9664\:6e08\:307f\:5909\:6570\:3002\:4f1d\:642c\:306e\:30d5\:30a1\:30a4\:30a2\:30a6\:30a9\:30fc\:30eb\:3068\:3057\:3066\:6a5f\:80fd\:3057\:3001
   \:3053\:308c\:3089\:306e\:5909\:6570\:306b\:306f\:4f1d\:642c\:305b\:305a\:3001\:3053\:308c\:3089\:7d4c\:7531\:306e\:9593\:63a5\:4f9d\:5b58\:3082\:691c\:51fa\:3057\:306a\:3044 *)
NBAccess`NBTransitiveDependents[deps_Association, confVars_List, excludeVars_List] :=
  Module[{marked = Union[confVars], excSet = Association[# -> True & /@ excludeVars],
          changed = True},
    While[changed,
      changed = False;
      Do[
        If[!MemberQ[marked, v] && !TrueQ[excSet[v]] &&
           Length[Intersection[Lookup[deps, v, {}], marked]] > 0,
          AppendTo[marked, v];
          changed = True],
        {v, Keys[deps]}]];
    marked
  ];

(* \:6a5f\:5bc6\:89e3\:9664\:6e08\:307f\:30bb\:30eb\:306e\:5909\:6570\:540d\:3092\:53ce\:96c6 *)
NBAccess`NBCollectDeclassifiedVarNames[nb_NotebookObject] :=
  Module[{nCells, result = {}, rawVN},
    nCells = NBAccess`NBCellCount[nb];
    Do[With[{dk = NBAccess`NBCellGetTaggingRule[nb, i, {"claudecode", "declassified"}]},
        If[StringQ[dk],
          rawVN = Quiet[NBAccess`NBCellExtractVarNames[nb, i]];
          If[ListQ[rawVN], result = Join[result, rawVN]]]],
      {i, nCells}];
    DeleteDuplicates[result]
  ];

(* deps \:3092\:7701\:7565\:3057\:305f\:5834\:5408\:306f\:5185\:90e8\:3067\:8a08\:7b97\:3059\:308b\:5f93\:6765\:4e92\:63db\:7248 *)
Options[NBAccess`NBScanDependentCells] = {"ExcludeVars" -> {}};

NBAccess`NBScanDependentCells[nb_NotebookObject,
    confVarNames_List, opts:OptionsPattern[]] :=
  NBAccess`NBScanDependentCells[nb, confVarNames,
    NBAccess`NBBuildVarDependencies[nb], opts];

(* deps \:3092\:4e8b\:524d\:8a08\:7b97\:6e08\:307f\:3067\:6e21\:305b\:308b\:30aa\:30fc\:30d0\:30fc\:30ed\:30fc\:30c9\:ff08\:4e8c\:91cd\:8a08\:7b97\:3092\:56de\:907f\:ff09 *)
NBAccess`NBScanDependentCells[nb_NotebookObject,
    confVarNames_List, deps_Association, opts:OptionsPattern[]] :=
  Module[{dependentVars, allDepVars, nCells, inIndices,
          marked = 0, excludeVars},
    excludeVars = OptionValue[NBAccess`NBScanDependentCells, {opts}, "ExcludeVars"];
    If[!ListQ[excludeVars], excludeVars = {}];
    allDepVars = NBAccess`NBTransitiveDependents[deps, confVarNames, excludeVars];
    dependentVars = Complement[allDepVars, confVarNames];

    nCells = NBAccess`NBCellCount[nb];
    If[nCells === 0, Return[0]];
    inIndices = NBAccess`NBCellIndicesByStyle[nb, "Input"];

    (* Phase 1: \:4e8b\:524d\:30af\:30ea\:30fc\:30cb\:30f3\:30b0 \[LongDash] \:5168\:30bb\:30eb\:306e dependent \:30de\:30fc\:30af\:3092\:30ea\:30bb\:30c3\:30c8 *)
    Do[If[TrueQ[NBAccess`NBCellGetTaggingRule[nb, i,
                  {"claudecode", "dependent"}]],
        iResetDependentMark[nb, i]],
    {i, nCells}];

    (* Phase 2: \:5168\:30bb\:30eb\:3092\:9806\:756a\:306b\:8d70\:67fb\:3057 Input/Output \:30da\:30a2\:3092\:691c\:51fa
       \:76f4\:524d\:306e Input \:30bb\:30eb\:304c\:4f9d\:5b58\:79d8\:5bc6 \[RightArrow] Output \:3092\:6a59
       \:76f4\:524d\:306e Input \:30bb\:30eb\:304c\:76f4\:63a5\:79d8\:5bc6 \[RightArrow] Output \:3092\:8d64
       \:76f4\:524d\:306e Input \:30bb\:30eb\:304c\:6a5f\:5bc6\:89e3\:9664\:6e08\:307f \[RightArrow] Output \:3092\:89e3\:9664\:6e08\:307f\:30b9\:30bf\:30a4\:30eb
       
       \:3053\:306e\:65b9\:5f0f\:306b\:3088\:308a\:3001\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:306e "nextOut" \:691c\:7d22\:306e
       \:305a\:308c\:554f\:984c\:3092\:5b8c\:5168\:306b\:56de\:907f\:3059\:308b\:3002 *)
    Module[{lastInputIdx = 0, lastInputText = "", lastInputTag = Missing[],
            lastInputDepTag = Missing[], lastInputIsDep = False,
            lastInputIsDirectConf = False,
            lastInputDeclKind = None,
            style, text, assigns,
            noticeCells, allC, noticeIdxSet = <||>},
      (* \:901a\:77e5\:30bb\:30eb (claudecode-notice) \:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:3092\:53ce\:96c6: \:30de\:30fc\:30ad\:30f3\:30b0\:5bfe\:8c61\:5916 *)
      noticeCells = Quiet[Cells[nb, CellTags -> "claudecode-notice"]];
      If[ListQ[noticeCells] && Length[noticeCells] > 0,
        allC = Quiet[Cells[nb]];
        If[ListQ[allC],
          Do[Module[{pos = Position[allC, nc]},
            If[Length[pos] > 0, noticeIdxSet[pos[[1, 1]]] = True]],
          {nc, noticeCells}]]];
      Do[
        style = NBAccess`NBCellStyle[nb, i];
        Which[
          (* Input/Code \:30bb\:30eb: \:30c6\:30ad\:30b9\:30c8\:3092\:89e3\:6790\:3057\:3066\:4f9d\:5b58\:5224\:5b9a *)
          MemberQ[{"Input", "Code"}, style],
            lastInputIdx = i;
            lastInputTag = NBAccess`NBGetConfidentialTag[nb, i];
            lastInputDepTag = NBAccess`NBCellGetTaggingRule[nb, i,
              {"claudecode", "dependent"}];
            lastInputIsDirectConf = TrueQ[lastInputTag] && !TrueQ[lastInputDepTag];
            lastInputIsDep = False;
            (* \:6a5f\:5bc6\:89e3\:9664\:6e08\:307f\:5224\:5b9a *)
            lastInputDeclKind = NBAccess`NBCellGetTaggingRule[nb, i,
              {"claudecode", "declassified"}];
            If[!StringQ[lastInputDeclKind], lastInputDeclKind = None];
            (* \:76f4\:63a5\:79d8\:5bc6\:30fb\:660e\:793a\:975e\:79d8\:5bc6\:30fbClaude\:95a2\:6570\:30bb\:30eb\:306f\:30b9\:30ad\:30c3\:30d7 *)
            If[!TrueQ[lastInputTag] && lastInputTag =!= False &&
               lastInputDeclKind === None &&
               !NBAccess`NBIsClaudeFunctionCell[nb, i],
              text = Quiet[NBAccess`NBCellReadInputText[nb, i]];
              If[StringQ[text] && text =!= "" && !iIsFuncDefText[text],
                assigns = iExtractAssignments[text];
                lastInputIsDep = (
                  (* \:6761\:4ef61: LHS\:5909\:6570\:304c\:63a8\:79fb\:7684\:4f9d\:5b58\:5909\:6570 *)
                  AnyTrue[assigns, MemberQ[dependentVars, First[#]] &] ||
                  (* \:6761\:4ef62: \:4ee3\:5165\:306a\:3057\:5f0f\:3067\:6a5f\:5bc6\:5909\:6570\:3092\:53c2\:7167 *)
                  (Length[assigns] === 0 &&
                   AnyTrue[allDepVars,
                     StringContainsQ[iStripStrings[text],
                       RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <>
                         "(?![\\p{L}\\p{N}$])"]] &]) ||
                  (* \:6761\:4ef63: RHS \:304c\:6a5f\:5bc6\:5909\:6570\:3092\:53c2\:7167 *)
                  (Length[assigns] > 0 &&
                   AnyTrue[assigns,
                     Function[a,
                       Length[Intersection[Last[a], allDepVars]] > 0]])
                );
                If[lastInputIsDep, marked++]]],

          (* Output/Print \:30bb\:30eb: \:76f4\:524d\:306e Input \:306b\:57fa\:3065\:3044\:3066\:30de\:30fc\:30af *)
          MemberQ[{"Output", "Print"}, style] && lastInputIdx > 0,
            (* \:901a\:77e5\:30bb\:30eb (claudecode-notice) \:306f\:30b9\:30ad\:30c3\:30d7 *)
            If[!TrueQ[Lookup[noticeIdxSet, i, False]],
              Which[
                (* \:6a5f\:5bc6\:89e3\:9664\:6e08\:307f\:30bb\:30eb\:306e Output \[RightArrow] \:89e3\:9664\:6e08\:307f\:30b9\:30bf\:30a4\:30eb *)
                lastInputDeclKind === "direct",
                  NBAccess`NBSetConfidentialTag[nb, i, False];
                  NBAccess`NBCellSetTaggingRule[nb, i,
                    {"claudecode", "declassified"}, "direct"];
                  NBAccess`NBCellSetOptions[nb, i,
                    Sequence @@ NBAccess`$NBDeclassifiedDirectCellOpts],
                lastInputDeclKind === "dependent",
                  NBAccess`NBSetConfidentialTag[nb, i, False];
                  NBAccess`NBCellSetTaggingRule[nb, i,
                    {"claudecode", "declassified"}, "dependent"];
                  NBAccess`NBCellSetOptions[nb, i,
                    Sequence @@ NBAccess`$NBDeclassifiedDependentCellOpts],
                (* \:76f4\:63a5\:79d8\:5bc6\:30bb\:30eb\:306e Output \[RightArrow] \:8d64\:30de\:30fc\:30af *)
                lastInputIsDirectConf &&
                  NBAccess`NBGetConfidentialTag[nb, i] =!= False,
                  NBAccess`NBMarkCellConfidential[nb, i],
                (* \:4f9d\:5b58\:79d8\:5bc6\:30bb\:30eb\:306e Output \[RightArrow] \:6a59\:30de\:30fc\:30af *)
                lastInputIsDep &&
                  NBAccess`NBGetConfidentialTag[nb, i] =!= False,
                  NBAccess`NBMarkCellDependent[nb, i]
              ]
            ];
            (* \:540c\:3058 Input \:306e Output \:306f1\:56de\:3060\:3051\:30de\:30fc\:30af *)
            (* lastInputIdx \:306f\:5909\:66f4\:3057\:306a\:3044 \[LongDash] \:8907\:6570 Output \:30bb\:30eb\:304c\:3042\:308b\:5834\:5408\:3082\:5bfe\:5fdc *),

          (* \:305d\:308c\:4ee5\:5916\:306e\:30bb\:30eb (Text\:7b49) \:306f lastInput \:3092\:30ea\:30bb\:30c3\:30c8\:3057\:306a\:3044 *)
          True, Null
        ],
      {i, nCells}]];

    marked
  ];

(* ============================================================
   \:4f9d\:5b58\:95a2\:4fc2\:30a8\:30c3\:30b8\:30ea\:30b9\:30c8
   ============================================================ *)

NBAccess`NBDependencyEdges[nb_NotebookObject] :=
  Module[{deps},
    deps = NBAccess`NBBuildVarDependencies[nb];
    DeleteDuplicates @ Flatten[
      KeyValueMap[
        Function[{var, depList},
          DirectedEdge[#, var] & /@ depList],
        deps]]
  ];

NBAccess`NBDependencyEdges[nb_NotebookObject, confVars_List] :=
  Module[{deps, allDepVars, relevantVars, edges},
    deps = NBAccess`NBBuildVarDependencies[nb];
    allDepVars = NBAccess`NBTransitiveDependents[deps, confVars];
    edges = DeleteDuplicates @ Flatten[
      KeyValueMap[
        Function[{var, depList},
          DirectedEdge[#, var] & /@ depList],
        deps]];
    (* \:6a5f\:5bc6\:5909\:6570\:307e\:305f\:306f\:63a8\:79fb\:7684\:4f9d\:5b58\:5909\:6570\:304c\:95a2\:4e0e\:3059\:308b\:30a8\:30c3\:30b8\:306e\:307f *)
    Select[edges, MemberQ[allDepVars, #[[1]]] || MemberQ[allDepVars, #[[2]]] &]
  ];

(* ============================================================
   \:5305\:62ec\:7684\:30c7\:30d0\:30c3\:30b0\:95a2\:6570
   ============================================================ *)

NBAccess`NBDebugDependencies[nb_NotebookObject, confVars_List] :=
  Module[{deps, allDepVars, dependentVars, inIndices, outIndices, nCells, edges},
    deps = NBAccess`NBBuildVarDependencies[nb];
    allDepVars = NBAccess`NBTransitiveDependents[deps, confVars];
    dependentVars = Complement[allDepVars, confVars];
    nCells = NBAccess`NBCellCount[nb];
    inIndices  = NBAccess`NBCellIndicesByStyle[nb, "Input"];
    outIndices = NBAccess`NBCellIndicesByStyle[nb, "Output"];

    Print[Style["===== \:4f9d\:5b58\:30b0\:30e9\:30d5 (dep -> var) =====", Bold, Blue]];
    edges = NBAccess`NBDependencyEdges[nb];
    Do[Print["  ", e], {e, edges}];
    If[Length[edges] === 0, Print["  (\:30a8\:30c3\:30b8\:306a\:3057)"]];

    Print[Style["\n===== \:6a5f\:5bc6\:95a2\:9023\:30a8\:30c3\:30b8\:306e\:307f =====", Bold, Red]];
    Module[{confEdges = NBAccess`NBDependencyEdges[nb, confVars]},
      Do[Print["  ", e], {e, confEdges}];
      If[Length[confEdges] === 0, Print["  (\:30a8\:30c3\:30b8\:306a\:3057)"]]];

    Print[Style["\n===== \:5909\:6570\:30c6\:30fc\:30d6\:30eb =====", Bold]];
    Do[Print["  ", k, " -> deps: ", deps[k]], {k, Keys[deps]}];

    Print[Style["\n===== \:76f4\:63a5\:6a5f\:5bc6\:5909\:6570 =====", Bold, Red]];
    Print["  ", confVars];

    Print[Style["\n===== \:63a8\:79fb\:7684\:4f9d\:5b58\:5909\:6570 (\:6a5f\:5bc6\:542b\:3080) =====", Bold]];
    Print["  ", allDepVars];

    Print[Style["\n===== \:4f9d\:5b58\:306e\:307f (\:6a5f\:5bc6\:9664\:304f) =====", Bold, RGBColor[0.85, 0.5, 0.1]]];
    Print["  ", dependentVars];

    Print[Style["\n===== \:95a2\:6570\:5b9a\:7fa9\:306e\:89e3\:6790 =====", Bold]];
    Do[Module[{txt, fd},
      txt = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      If[StringQ[txt],
        fd = iExtractFuncDefs[txt];
        If[Length[fd] > 0,
          Do[Print["  In[", idx, "] ", First[f], " \[RightArrow] globalDeps: ", Last[f]],
          {f, fd}]]]],
    {idx, inIndices}];

    Print[Style["\n===== \:5168 Input \:30bb\:30eb\:8a73\:7d30 =====", Bold]];
    Do[Module[{inputText, boxText, assigns, lhsVars, rhsVars, isDep,
               nextInI, nextOutI, tag, depTag, confTag},
      inputText = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      boxText   = Quiet[NBAccess`NBCellToText[nb, idx]];
      tag       = NBAccess`NBGetConfidentialTag[nb, idx];
      depTag    = NBAccess`NBCellGetTaggingRule[nb, idx, {"claudecode", "dependent"}];
      confTag   = Which[tag === True, "\:79d8\:5bc6", tag === False, "\:975e\:79d8\:5bc6(Unmark\:6e08)", True, "\:672a\:8a2d\:5b9a"];

      Print[Style["--- \:30bb\:30ebIndex=" <> ToString[idx] <>
        " (" <> NBAccess`NBCellLabel[nb, idx] <> ") tag=" <> confTag <> " ---",
        Bold]];
      Print["  InputText: ", If[StringQ[inputText], StringTake[inputText, UpTo[120]], "(\:53d6\:5f97\:5931\:6557)"]];
      If[inputText =!= boxText,
        Print["  BoxText  : ", If[StringQ[boxText], StringTake[boxText, UpTo[120]], "(\:53d6\:5f97\:5931\:6557)"]]];

      If[StringQ[inputText] && inputText =!= "",
        assigns = iExtractAssignments[inputText];
        Print["  \:4ee3\:5165\:89e3\:6790 : ", assigns];
        isDep = AnyTrue[assigns, MemberQ[dependentVars, First[#]] &] ||
          (Length[assigns] === 0 &&
           AnyTrue[allDepVars,
             StringContainsQ[NBAccess`Private`iStripStrings[inputText],
               RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <> "(?![\\p{L}\\p{N}$])"]] &]) ||
          (Length[assigns] > 0 &&
           AnyTrue[assigns,
             Function[a,
               Length[Intersection[Last[a], allDepVars]] > 0]]);
        Print["  isDep    : ", isDep];
        If[isDep,
          nextInI  = SelectFirst[inIndices, # > idx &, Infinity];
          nextOutI = SelectFirst[outIndices, # > idx &, None];
          Print["  nextOut  : idx=", nextOutI,
            " (nextIn=", If[nextInI === Infinity, "\[Infinity]", nextInI], ")",
            " markable=", nextOutI =!= None && nextOutI < nextInI]],
        Print["  isDep    : (\:30c6\:30ad\:30b9\:30c8\:53d6\:5f97\:5931\:6557\:306e\:305f\:3081\:30b9\:30ad\:30c3\:30d7)"]
      ]],
    {idx, inIndices}];

    Print[Style["\n===== \:30bb\:30eb\:69cb\:6210 (\:5168 " <> ToString[nCells] <> " \:30bb\:30eb) =====", Bold]];
    Do[Module[{style, lbl, tag2},
      style = ToString[NBAccess`NBCellStyle[nb, i]];
      lbl   = NBAccess`NBCellLabel[nb, i];
      tag2  = NBAccess`NBGetConfidentialTag[nb, i];
      Print["  [", i, "] ", style,
        If[lbl =!= "", " " <> lbl, ""],
        If[tag2 === True, " \[FivePointedStar]\:79d8\:5bc6", ""],
        If[TrueQ[NBAccess`NBCellGetTaggingRule[nb, i, {"claudecode", "dependent"}]],
          " \[FilledDiamond]\:4f9d\:5b58\:79d8\:5bc6", ""]]],
    {i, nCells}];
  ];


(* ============================================================
   \:4f9d\:5b58\:30b0\:30e9\:30d5\:30d7\:30ed\:30c3\:30c8
   ============================================================ *)


Options[NBAccess`NBPlotDependencyGraph] = {
  PrivacySpec -> <|"AccessLevel" -> 1.0|>,
  "Scope" -> "Global",
  GraphLayout -> "LayeredDigraphEmbedding"
};

(* \:5f15\:6570\:306a\:3057: \:30c7\:30d5\:30a9\:30eb\:30c8 Scope="Global" \:3067\:5168NB\:7d71\:5408 *)
NBAccess`NBPlotDependencyGraph[opts : OptionsPattern[]] :=
  NBAccess`NBPlotDependencyGraph[None, opts];

(* \:30e1\:30a4\:30f3\:5b9f\:88c5: nb=None \:306a\:3089\:5168NB\:3001nb \:6307\:5b9a\:306a\:3089 Scope \:306b\:5f93\:3046 *)
NBAccess`NBPlotDependencyGraph[nb : (_NotebookObject | None),
    opts : OptionsPattern[]] :=
  Module[{accessLevel, scope, targetNBs, allNBs,
          nbNames = <||>, nbList = {},
          directConfVars = {}, deps = <||>,
          varNBSource = <||>, varCellNum = <||>,
          funcSet = <||>,
          allDepVars,
          allEdges, fullGraph,
          confInGraph, transDepVerts, depOnly,
          varPrivacy, visibleVars, subg,
          legend, nbColorMap, scopeLabel, isMultiNB, layout},

    accessLevel = iAccessLevel[OptionValue[PrivacySpec]];
    scope = OptionValue["Scope"];
    layout = OptionValue[GraphLayout];

    (* === Step 1: \:5bfe\:8c61\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:6c7a\:5b9a === *)
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[Style["(\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306a\:3057)", Gray, Italic]]];
    targetNBs = If[scope === "Local" && nb =!= None,
      {nb},   (* Local: \:6307\:5b9aNB\:306e\:307f *)
      allNBs  (* Global: \:5168NB *)
    ];
    isMultiNB = Length[targetNBs] > 1;
    scopeLabel = If[scope === "Local",
      "Local (1 NB)",
      "Global (" <> ToString[Length[targetNBs]] <> " NBs)"];

    (* NB \:540d\:524d\:30de\:30c3\:30d4\:30f3\:30b0 *)
    Do[Module[{name},
      name = Quiet @ Check[
        Module[{fn = NotebookFileName[nbx]},
          If[StringQ[fn], FileBaseName[fn],
            "NB" <> ToString[Hash[nbx, "CRC32"]]]],
        "NB" <> ToString[Hash[nbx, "CRC32"]]];
      nbNames[nbx] = name;
      If[!MemberQ[nbList, name], AppendTo[nbList, name]]],
    {nbx, targetNBs}];

    (* NB \:3054\:3068\:306b\:8272\:3092\:5272\:308a\:5f53\:3066 *)
    nbColorMap = Association[MapIndexed[
      #1 -> ColorData[97][First[#2]] &, nbList]];

    (* === Step 2: \:79d8\:5bc6\:5909\:6570\:3092\:53ce\:96c6 ===
       Global \:30e2\:30fc\:30c9\:3067\:306f\:5168NB\:8d70\:67fb\:3001Local \:30e2\:30fc\:30c9\:3067\:3082\:5168NB\:8d70\:67fb
       \:ff08\:5225NB\:306e\:79d8\:5bc6\:5909\:6570\:304c\:73fe\:5728NB\:306e\:5909\:6570\:306b\:5f71\:97ff\:3059\:308b\:305f\:3081\:ff09 *)
    Do[Module[{cells},
      cells = Quiet[Cells[nbx]];
      If[ListQ[cells],
        Do[Module[{tag, depTag, txt, assigns},
          tag    = iGetConfTag[c];
          depTag = Quiet[CurrentValue[c,
                     {TaggingRules, "claudecode", "dependent"}]];
          If[TrueQ[tag] && !TrueQ[depTag],
            txt = Quiet[iCellToInputText[c]];
            If[StringQ[txt],
              assigns = iExtractAssignments[txt];
              directConfVars =
                Join[directConfVars, Map[First, assigns]]]]],
        {c, cells}]]],
    {nbx, allNBs}];
    directConfVars = DeleteDuplicates[directConfVars];

    (* === Step 3: \:4f9d\:5b58\:30b0\:30e9\:30d5\:69cb\:7bc9 + \:5909\:6570\:306eNB\:30bd\:30fc\:30b9\:8ffd\:8de1 === *)
    Do[Module[{cells, nbName},
      cells = Quiet[Cells[nbx]];
      nbName = Lookup[nbNames, nbx, "?"];
      If[ListQ[cells],
        Do[
          If[!ContainsAny[
               Flatten[{Quiet[CurrentValue[c, CellStyle]]}],
               {"Input", "Code"}],
            Continue[]];
          Module[{text, assignments, funcDefs, cNum},
            text = Quiet[iCellToInputText[c]];
            If[!StringQ[text] || text === "", Continue[]];
            cNum = iCellNumber[c];
            assignments = iExtractAssignments[text];
            Do[With[{lhs = First[a], rhsVars = Last[a]},
              deps[lhs] = DeleteDuplicates[
                Join[Lookup[deps, lhs, {}], rhsVars]];
              varNBSource[lhs] = nbName;
              If[cNum =!= None, varCellNum[lhs] = cNum]],
            {a, assignments}];
            (* Out$n \:4eee\:60f3\:5909\:6570 *)
            If[cNum =!= None && Length[assignments] > 0,
              With[{outKey = "Out$" <> cNum,
                    allRhs = DeleteDuplicates[
                      Join @@ Map[Last, assignments]]},
                deps[outKey] = DeleteDuplicates[
                  Join[Lookup[deps, outKey, {}], allRhs]];
                varCellNum[outKey] = cNum;
                varNBSource[outKey] = nbName]];
            funcDefs = iExtractFuncDefs[text];
            Do[With[{fname = First[fd], globalDeps = Last[fd]},
              deps[fname] = DeleteDuplicates[
                Join[Lookup[deps, fname, {}], globalDeps]];
              varNBSource[fname] = nbName;
              funcSet[fname] = True],
            {fd, funcDefs}]],
        {c, cells}]]],
    {nbx, targetNBs}];

    (* \:672a\:53c2\:7167\:306e Out$n \:3092\:9664\:53bb *)
    With[{refd = DeleteDuplicates[
            Select[Flatten[Values[deps]],
              StringMatchQ[#, "Out$" ~~ DigitCharacter ..] &]]},
      deps = KeyDrop[deps,
        Complement[
          Select[Keys[deps],
            StringMatchQ[#, "Out$" ~~ DigitCharacter ..] &],
          refd]]];

    (* === Step 4: \:63a8\:79fb\:7684\:4f9d\:5b58\:3092\:8a08\:7b97 === *)
    allDepVars = NBAccess`NBTransitiveDependents[deps, directConfVars];
    If[!ListQ[allDepVars], allDepVars = directConfVars];

    (* === Step 5: \:30b0\:30e9\:30d5\:69cb\:7bc9 === *)
    allEdges = DeleteDuplicates @ Flatten[
      KeyValueMap[
        Function[{var, depList},
          DirectedEdge[#, var] & /@ depList],
        deps]];

    If[Length[allEdges] === 0,
      Return[Style["(\:30a8\:30c3\:30b8\:306a\:3057)", Gray, Italic]]];

    fullGraph = Graph[allEdges,
      GraphLayout      -> layout,
      VertexSize       -> {"Scaled", 0.007},
      VertexStyle      -> Directive[
        EdgeForm[{Thin, GrayLevel[0.55]}],
        RGBColor[0.85, 0.93, 1.0]],
      EdgeStyle        -> Directive[GrayLevel[0.5], Arrowheads[0.012]],
      ImageSize        -> {1000, 700},
      ImagePadding     -> 40];

    confInGraph = Intersection[directConfVars, VertexList[fullGraph]];
    transDepVerts = If[Length[confInGraph] > 0,
      VertexOutComponent[fullGraph, confInGraph],
      {}];
    depOnly = Complement[transDepVerts, confInGraph];

    varPrivacy = Association[Map[
      # -> Which[
        MemberQ[confInGraph, #], 1.0,
        MemberQ[depOnly, #],    0.75,
        True,                   0.0] &,
      VertexList[fullGraph]]];

    visibleVars = Select[VertexList[fullGraph],
      Lookup[varPrivacy, #, 0.0] <= accessLevel &];

    If[Length[visibleVars] === 0,
      Return[Style["(\:8868\:793a\:53ef\:80fd\:306a\:30ce\:30fc\:30c9\:306a\:3057)", Gray, Italic]]];

    subg = Subgraph[fullGraph, visibleVars];

    (* === Step 6: \:63cf\:753b === *)
    Module[{iDispName, confSet, depSet, pubSet,
            confLabels, depLabels, pubLabels, allLabels,
            vStyles, eStyles, edgeTooltips,
            highlighted, nbLegendItems},

      (* \:30e9\:30d9\:30eb: \:79d8\:5bc6\:30fb\:4f9d\:5b58\:79d8\:5bc6\:306e\:307f\:5909\:6570\:540d\:3092\:8868\:793a\:3002\:516c\:958b\:306f\:30e9\:30d9\:30eb\:306a\:3057\:3002
         \:5168\:30ce\:30fc\:30c9\:306b Tooltip \:3067\:5909\:6570\:540d+NB\:540d\:3092\:8868\:793a\:3002 *)
      iDispName[v_String] :=
        If[StringMatchQ[v, "Out$" ~~ DigitCharacter ..],
          "Out[" <> StringDrop[v, 4] <> "]", v];

      iTooltipText[v_String] :=
        Module[{base, src},
          base = iDispName[v];
          src = Lookup[varNBSource, v, ""];
          If[src =!= "", base <> "\n" <> src, base]];

      confSet = Intersection[confInGraph, visibleVars];
      depSet  = Intersection[depOnly, visibleVars];
      pubSet  = Complement[visibleVars, confSet, depSet];

      (* \:79d8\:5bc6\:30fb\:4f9d\:5b58\:79d8\:5bc6: Above \:306b\:5909\:6570\:540d\:30e9\:30d9\:30eb\:8868\:793a + Tooltip \:3067NB\:540d
         Tooltip[\:8868\:793a\:30e9\:30d9\:30eb, \:30db\:30d0\:30fc\:30c6\:30ad\:30b9\:30c8] \:3092 Placed[..., Above] \:3067\:914d\:7f6e *)
      confLabels = Map[# -> Placed[
        Tooltip[Style[iDispName[#], Bold, 7, RGBColor[0.7, 0.1, 0.1]],
                iTooltipText[#]], Above] &,
        confSet];
      depLabels = Map[# -> Placed[
        Tooltip[Style[iDispName[#], Bold, 7, RGBColor[0.8, 0.45, 0.05]],
                iTooltipText[#]], Above] &,
        depSet];
      (* \:516c\:958b\:5909\:6570: \:30e9\:30d9\:30eb\:306a\:3057\:3001Tooltip \:306e\:307f *)
      pubLabels = Map[# -> Placed[iTooltipText[#], Tooltip] &, pubSet];

      allLabels = Join[confLabels, depLabels, pubLabels];

      (* \:30ce\:30fc\:30c9\:30b9\:30bf\:30a4\:30eb:
         \:5909\:6570: \:5857\:308a\:3064\:3076\:3057 (\:79d8\:5bc6=\:8d64, \:4f9d\:5b58\:79d8\:5bc6=\:6a59, \:516c\:958b=\:9752), \:7e01\:53d6\:308a\:306a\:3057
         \:95a2\:6570: \:767d\:5730 + \:7e01\:53d6\:308a (\:79d8\:5bc6=\:8d64, \:4f9d\:5b58\:79d8\:5bc6=\:6a59, \:516c\:958b=\:9752) *)
      vStyles = Map[
        Function[v,
          Module[{priv, isFunc, clr},
            priv = Lookup[varPrivacy, v, 0.0];
            isFunc = TrueQ[Lookup[funcSet, v, False]];
            clr = Which[
              priv === 1.0,  RGBColor[0.82, 0.15, 0.15],   (* \:8d64 *)
              priv === 0.75, RGBColor[0.90, 0.55, 0.10],   (* \:6a59 *)
              True,          RGBColor[0.35, 0.55, 0.82]];   (* \:9752 *)
            v -> If[isFunc,
              (* \:95a2\:6570: \:767d\:5730 + \:8272\:4ed8\:304d\:7e01\:53d6\:308a *)
              Directive[EdgeForm[{AbsoluteThickness[2], clr}], White],
              (* \:5909\:6570: \:5857\:308a\:3064\:3076\:3057 + \:7e01\:53d6\:308a\:306a\:3057 *)
              Directive[EdgeForm[None], clr]]]],
        visibleVars];

      (* \:30a8\:30c3\:30b8\:30b9\:30bf\:30a4\:30eb: NB\:5185\:306f\:6fc3\:3044\:5b9f\:7dda\:3001\:30af\:30ed\:30b9NB\:306f\:8584\:3044\:7834\:7dda *)
      eStyles = Map[
        Function[e,
          Module[{srcNB, dstNB, isCross},
            srcNB = Lookup[varNBSource, e[[1]], "?src"];
            dstNB = Lookup[varNBSource, e[[2]], "?dst"];
            isCross = isMultiNB && (srcNB =!= dstNB);
            e -> If[isCross,
              (* \:30af\:30ed\:30b9NB: \:8584\:3044\:7834\:7dda *)
              Directive[GrayLevel[0.72], Dashing[{0.01, 0.008}],
                Arrowheads[0.012]],
              (* NB\:5185 (\:307e\:305f\:306f Local \:30e2\:30fc\:30c9): \:6fc3\:3044\:5b9f\:7dda *)
              Directive[GrayLevel[0.35], AbsoluteThickness[1.5],
                Arrowheads[0.012]]]]],
        EdgeList[subg]];

      (* \:30a8\:30c3\:30b8\:30c4\:30fc\:30eb\:30c1\:30c3\:30d7: \:30bb\:30eb\:756a\:53f7 *)
      edgeTooltips = DeleteCases[
        Map[Function[e,
          With[{cn = Lookup[varCellNum, e[[2]], None]},
            If[cn =!= None,
              e -> Placed["In[" <> cn <> "]", Tooltip], Nothing]]],
        EdgeList[subg]], Nothing];

      highlighted = Graph[subg,
        VertexStyle  -> vStyles,
        VertexLabels -> allLabels,
        VertexSize   -> {"Scaled", 0.007},
        EdgeStyle    -> eStyles,
        EdgeLabels   -> edgeTooltips,
        GraphLayout  -> layout,
        ImageSize    -> {1000, 700},
        ImagePadding -> 40,
        PlotLabel    -> Style[
          "\:4f9d\:5b58\:30b0\:30e9\:30d5 \[LongDash] " <> scopeLabel <>
          " (AccessLevel=" <> ToString[accessLevel] <> ")",
          Bold, 14]];

      (* \:51e1\:4f8b *)
      legend = Column[{
        SwatchLegend[
          {RGBColor[0.82, 0.15, 0.15], RGBColor[0.90, 0.55, 0.10],
           RGBColor[0.35, 0.55, 0.82]},
          {"\:79d8\:5bc6 (\:76f4\:63a5)", "\:4f9d\:5b58\:79d8\:5bc6 (\:63a8\:79fb\:7684)", "\:516c\:958b"},
          LegendMarkerSize -> 14, LabelStyle -> 10],
        Row[{
          Graphics[{RGBColor[0.35, 0.55, 0.82], Disk[{0, 0}, 0.4]},
            ImageSize -> 14, PlotRange -> 1],
          Style[" \:5909\:6570", 9], Spacer[10],
          Graphics[{White, EdgeForm[{AbsoluteThickness[2], RGBColor[0.35, 0.55, 0.82]}],
            Disk[{0, 0}, 0.4]}, ImageSize -> 14, PlotRange -> 1],
          Style[" \:95a2\:6570", 9]}],
        If[isMultiNB,
          Column[{
            Spacer[4],
            Row[Flatten[{
              Style["NB: ", Bold, 10],
              Riffle[
                KeyValueMap[
                  Function[{name, clr},
                    Row[{Graphics[{clr, Disk[]}, ImageSize -> 12], " ", name}]],
                  nbColorMap],
                "  "]}]],
            Spacer[2],
            Row[{
              Graphics[{GrayLevel[0.35], AbsoluteThickness[1.5],
                Line[{{0,0},{1,0}}]}, ImageSize -> {30, 8}],
              Style[" NB\:5185", 9],
              Spacer[10],
              Graphics[{GrayLevel[0.72], Dashing[{0.03, 0.02}],
                Line[{{0,0},{1,0}}]}, ImageSize -> {30, 8}],
              Style[" \:30af\:30ed\:30b9NB", 9]}]
          }, Spacings -> 0.3],
          Nothing]
        }, Spacings -> 0.5];

      Legended[highlighted, Placed[legend, Below]]
    ]
  ];



(* ============================================================
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af TaggingRules API
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30ec\:30d9\:30eb\:306e TaggingRules \:3078\:306e\:8aad\:307f\:66f8\:304d\:3092\:4e00\:5143\:7ba1\:7406\:3059\:308b\:3002
   \:30bb\:30c3\:30b7\:30e7\:30f3\:5c65\:6b74\:306a\:3069\:306e\:6c38\:7d9a\:30c7\:30fc\:30bf\:306e\:683c\:7d0d\:306b\:4f7f\:7528\:3002
   ============================================================ *)

NBAccess`NBGetTaggingRule[nb_NotebookObject, key_String] :=
  Module[{val},
    val = Quiet[CurrentValue[nb, {TaggingRules, key}]];
    If[val === Inherited || MatchQ[val, _CurrentValue], Missing[], val]
  ];

NBAccess`NBGetTaggingRule[nb_NotebookObject, path_List] :=
  Module[{val},
    val = Quiet[CurrentValue[nb, Prepend[path, TaggingRules]]];
    If[val === Inherited || MatchQ[val, _CurrentValue], Missing[], val]
  ];

NBAccess`NBSetTaggingRule[nb_NotebookObject, key_String, value_] :=
  Quiet[CurrentValue[nb, {TaggingRules, key}] = value];

NBAccess`NBSetTaggingRule[nb_NotebookObject, path_List, value_] :=
  Quiet[CurrentValue[nb, Prepend[path, TaggingRules]] = value];

NBAccess`NBDeleteTaggingRule[nb_NotebookObject, key_String] :=
  Module[{tr},
    tr = Quiet[CurrentValue[nb, TaggingRules]];
    If[AssociationQ[tr],
      Quiet[SetOptions[nb, TaggingRules -> KeyDrop[tr, key]]],
      (* List \:5f62\:5f0f\:306e TaggingRules *)
      If[ListQ[tr],
        Quiet[SetOptions[nb, TaggingRules -> DeleteCases[tr, key -> _]]]]
    ]
  ];

NBAccess`NBListTaggingRuleKeys[nb_NotebookObject] :=
  Module[{tr},
    tr = Quiet[CurrentValue[nb, TaggingRules]];
    Which[
      AssociationQ[tr], Keys[tr],
      ListQ[tr],        Cases[tr, (k_ -> _) :> k],
      True,             {}
    ]
  ];

NBAccess`NBListTaggingRuleKeys[nb_NotebookObject, prefix_String] :=
  Select[NBAccess`NBListTaggingRuleKeys[nb],
    StringQ[#] && StringMatchQ[#, prefix ~~ ___] &];

(* Stage 9 P1.5: \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30c7\:30d5\:30a9\:30eb\:30c8\:30e2\:30c7\:30eb (claudecode \:30d1\:30ec\:30c3\:30c8\:8a2d\:5b9a) \:3092
   \:66f8\:304d\:63db\:3048\:308b\:3002NBAccess \:4ee5\:5916\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5185\:90e8\:30c7\:30fc\:30bf\:3092\:66f8\:304d\:63db\:3048\:3066\:306f
   \:306a\:3089\:306a\:3044\:539f\:5247\:306b\:5f93\:3044\:3001\:66f8\:304d\:8fbc\:307f\:306f\:3053\:306e\:95a2\:6570 (NBAccess) \:304c\:5b9f\:884c\:3059\:308b\:3002
   claudecode \:306f Private/Public \:5207\:66ff\:6642\:306b\:66f8\:304d\:8fbc\:3080\:3079\:304d {provider, modelName} \:3092
   \:5f15\:6570\:3067\:6e21\:3059 ((1) \:65b9\:5f0f)\:3002\:30ad\:30fc\:69cb\:9020\:306f claudecode \:306e
   iLoadPaletteSettings / iSavePaletteSettings \:3068\:6574\:5408\:3092\:53d6\:308b:
   {TaggingRules, "claudecode", "paletteProvider" / "paletteModelName"}\:3002 *)
NBAccess`NBSetNotebookDefaultModel[nb_NotebookObject,
    provider_String, modelName_String] :=
  Module[{},
    Quiet[CurrentValue[nb,
      {TaggingRules, "claudecode", "paletteProvider"}] = provider];
    Quiet[CurrentValue[nb,
      {TaggingRules, "claudecode", "paletteModelName"}] = modelName];
    <|"Status" -> "OK", "Provider" -> provider, "ModelName" -> modelName|>
  ];
NBAccess`NBSetNotebookDefaultModel[___] :=
  <|"Status" -> "Failed", "Reason" -> "InvalidArguments"|>;

(* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30c7\:30d5\:30a9\:30eb\:30c8\:30e2\:30c7\:30eb\:3092\:8aad\:3080 ({provider, modelName} \:307e\:305f\:306f Missing) *)
NBAccess`NBGetNotebookDefaultModel[nb_NotebookObject] :=
  Module[{p, m},
    p = Quiet[CurrentValue[nb,
      {TaggingRules, "claudecode", "paletteProvider"}]];
    m = Quiet[CurrentValue[nb,
      {TaggingRules, "claudecode", "paletteModelName"}]];
    If[StringQ[p] && StringQ[m],
      {p, m},
      Missing["NotDeclared"]]
  ];
NBAccess`NBGetNotebookDefaultModel[___] := Missing["NotDeclared"];


(* ============================================================
   API \:30ad\:30fc\:30a2\:30af\:30bb\:30b5\:30fc
   ============================================================ *)

$iAPIKeyMap = <|
  "anthropic"  -> "ANTHROPIC_API_KEY",
  "openai"     -> "OPENAI_API_KEY",
  "zai"        -> "ZAI_API_KEY",
  "github"     -> "GITHUB_TOKEN",
  "gh"         -> "GITHUB_TOKEN",
  "github_pat" -> "GITHUB_TOKEN"
|>;

Options[NBAccess`NBGetAPIKey] = {PrivacySpec -> Automatic};

NBAccess`NBGetAPIKey[provider_String, opts:OptionsPattern[]] :=
  Module[{al, credName, key},
    al = iAccessLevel[OptionValue[PrivacySpec]];
    If[al < 1.0,
      Return[$Failed]];
    credName = Lookup[$iAPIKeyMap, ToLowerCase[provider], None];
    If[credName === None,
      Message[NBGetAPIKey::unkn, provider];
      Return[$Failed]];
    key = Quiet[SystemCredential[credName]];
    If[!StringQ[key] || StringLength[key] === 0,
      Message[NBGetAPIKey::nokey, provider, credName];
      Return[$Failed]];
    key
  ];

NBGetAPIKey::unkn = "\:672a\:77e5\:306e\:30d7\:30ed\:30d0\:30a4\:30c0: `1`\:3002\"anthropic\"\:3001\"openai\"\:3001\"zai\"\:3001\"github\" \:306e\:3044\:305a\:308c\:304b\:3092\:6307\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002";
NBGetAPIKey::nokey = "`1` \:306e API \:30ad\:30fc\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002SystemCredential[\"`2`\"] \:3092\:8a2d\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002";


(* ============================================================
   NBListProviderModels: \:30af\:30e9\:30a6\:30c9\:30d7\:30ed\:30d0\:30a4\:30c0\:306e\:30e2\:30c7\:30eb\:4e00\:89a7\:53d6\:5f97\:3002

   API \:30ad\:30fc\:306f SystemCredential \:304b\:3089\:5185\:90e8\:3067\:8aad\:307f\:3001\:5916\:90e8\:306b\:51fa\:3055\:306a\:3044\:3002
   \:8fd4\:3059\:306e\:306f\:30e2\:30c7\:30eb\:540d\:30ea\:30b9\:30c8 (\:79d8\:533f\:6027\:306a\:3057) \:3060\:3051\:306a\:306e\:3067\:3001PrivacySpec /
   AccessLevel \:306f\:4e0d\:8981\:3002\:4e00\:822c\:30d1\:30c3\:30b1\:30fc\:30b8 (SourceVault \:7b49) \:304c API \:30ad\:30fc\:3092
   \:76f4\:63a5\:8aad\:307e\:305a\:306b\:30e2\:30c7\:30eb\:4e00\:89a7\:3092\:53d6\:5f97\:3059\:308b\:305f\:3081\:306e\:516c\:958b\:95a2\:6570 (\:30ad\:30fc\:3092\:4f7f\:3046\:51e6\:7406\:306f
   NBAccess \:306b\:9589\:3058\:8fbc\:3081\:308b\:3068\:3044\:3046\:8a2d\:8a08\:65b9\:91dd\:306b\:5f93\:3046)\:3002
   ============================================================ *)

$iProviderModelsURL = <|
  "anthropic" -> "https://api.anthropic.com/v1/models",
  "openai"    -> "https://api.openai.com/v1/models",
  (* z.ai (GLM) \:306f OpenAI \:4e92\:63db\:306e /models \:3092\:6301\:3064 *)
  "zai"       -> "https://api.z.ai/api/paas/v4/models"
|>;

(* OpenAI \:4e92\:63db /v1/models JSON \:304b\:3089 model id \:3092\:62bd\:51fa\:3059\:308b\:3002
   {"data": [{"id": "..."}, ...]} \:5f62\:5f0f\:3002 *)
iNBExtractModelIds[body_String] :=
  Module[{json, data},
    json = Quiet @ Check[
      Developer`ReadRawJSONString[body], $Failed];
    If[!AssociationQ[json], Return[{}]];
    data = Lookup[json, "data", {}];
    If[!ListQ[data], Return[{}]];
    Select[
      Map[Lookup[#, "id", Missing[]] &,
        Select[data, AssociationQ]],
      StringQ]];
iNBExtractModelIds[_] := {};

NBAccess`NBListProviderModels[provider_String] :=
  Module[{prov, url, credName, key, headers, resp, status, body, ids},
    prov = ToLowerCase[provider];
    url = Lookup[$iProviderModelsURL, prov, None];
    If[url === None,
      Return[<|"Status" -> "Failed", "Provider" -> provider,
        "Reason" -> "UnknownProvider", "Models" -> {}|>]];
    (* API \:30ad\:30fc\:306f\:5185\:90e8\:3067\:53d6\:5f97 (\:3053\:306e\:95a2\:6570\:81ea\:4f53\:304c NBAccess \:306a\:306e\:3067
       SystemCredential \:306b\:76f4\:63a5\:30a2\:30af\:30bb\:30b9\:3067\:304d\:308b)\:3002\:5916\:90e8\:306b\:306f\:51fa\:3055\:306a\:3044\:3002 *)
    credName = Lookup[$iAPIKeyMap, prov, None];
    If[credName === None,
      Return[<|"Status" -> "Failed", "Provider" -> provider,
        "Reason" -> "NoCredentialMapping", "Models" -> {}|>]];
    key = Quiet[SystemCredential[credName]];
    If[!StringQ[key] || StringLength[key] === 0,
      Return[<|"Status" -> "NoAPIKey", "Provider" -> provider,
        "Reason" -> "CredentialNotSet",
        "CredentialName" -> credName, "Models" -> {}|>]];
    headers = Which[
      prov === "anthropic",
        {"x-api-key" -> key, "anthropic-version" -> "2023-06-01"},
      prov === "openai" || prov === "zai",
        {"Authorization" -> "Bearer " <> key},
      True, {}];
    resp = Quiet @ Check[
      URLRead[HTTPRequest[url, <|"Headers" -> headers|>]], $Failed];
    If[Head[resp] =!= HTTPResponse,
      Return[<|"Status" -> "Failed", "Provider" -> provider,
        "Reason" -> "RequestFailed", "Models" -> {}|>]];
    status = resp["StatusCode"];
    If[status =!= 200,
      Return[<|"Status" -> "Failed", "Provider" -> provider,
        "Reason" -> "HTTP" <> ToString[status], "Models" -> {}|>]];
    body = Quiet @ Check[resp["Body"], ""];
    ids = iNBExtractModelIds[If[StringQ[body], body, ""]];
    <|"Status" -> "OK", "Provider" -> provider, "Models" -> ids|>
  ];
NBAccess`NBListProviderModels[___] :=
  <|"Status" -> "Failed", "Reason" -> "InvalidArguments", "Models" -> {}|>;


(* ============================================================
   \:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:30fc (LM Studio \:7b49) \:306e API \:30ad\:30fc\:7ba1\:7406
   \:30ad\:30fc\:306f {provider, normalizedUrl} \:306e\:30ea\:30b9\:30c8\:3002\:5024\:306f SystemCredential \:540d\:3002
   (2026-04-24 \:8ffd\:52a0)
   ============================================================ *)

(* ---- \:65e2\:5b9a\:30de\:30c3\:30d4\:30f3\:30b0 ---- *)
If[!AssociationQ[$iLocalLLMAPIKeyMap],
  $iLocalLLMAPIKeyMap = <|
    {"lmstudio", "http://127.0.0.1:1234"} -> "LMSTUDIO_API_KEY"
  |>
];

(* ---- URL \:6b63\:898f\:5316 ----
   \:7565: \:672b\:5c3e\:30b9\:30e9\:30c3\:30b7\:30e5\:9664\:53bb, \:30d1\:30b9\:9664\:53bb (scheme://host[:port] \:306e\:307f\:6b8b\:3059)\:3002
   localhost \:3068 127.0.0.1 \:306f\:5225\:6271\:3044 (\:30e6\:30fc\:30b6\:30fc\:304c\:660e\:793a\:7684\:306b\:5206\:3051\:305f\:3044\:5834\:5408\:306b\:4f1d\:8fbe)\:3002 *)

iNormalizeLocalLLMURL[url_String] :=
  Module[{u = StringTrim[url], m},
    While[StringEndsQ[u, "/"], u = StringDrop[u, -1]];
    m = StringCases[u,
          RegularExpression["^([a-zA-Z][a-zA-Z0-9+.\\-]*://[^/]+)"] :> "$1"];
    If[ListQ[m] && Length[m] > 0 && StringQ[m[[1]]],
      u = m[[1]]];
    u
  ];
iNormalizeLocalLLMURL[_] := "";

(* ---- credentialName \:3092\:5f15\:304f\:30d8\:30eb\:30d1 ----
   \:89e3\:6c7a\:512a\:5148\:5ea6:
     (1) {prov, nu} \:5b8c\:5168\:4e00\:81f4
     (2) localhost\[LeftRightArrow]127.0.0.1 \:7f6e\:63db\:7248
     (3) {prov, "*"} \:30ef\:30a4\:30eb\:30c9\:30ab\:30fc\:30c9
     (4) \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: ToUpperCase[prov] <> "_API_KEY" *)

iLocalLLMLookupCredential[provider_String, url_String] :=
  Module[{prov = ToLowerCase[provider], nu = iNormalizeLocalLLMURL[url],
          cred, altURL},
    cred = Lookup[$iLocalLLMAPIKeyMap, Key[{prov, nu}], None];
    If[StringQ[cred], Return[cred]];
    altURL = Which[
      StringContainsQ[nu, "127.0.0.1"],
        StringReplace[nu, "127.0.0.1" -> "localhost"],
      StringContainsQ[nu, "localhost"],
        StringReplace[nu, "localhost" -> "127.0.0.1"],
      True, None];
    If[StringQ[altURL],
      cred = Lookup[$iLocalLLMAPIKeyMap, Key[{prov, altURL}], None];
      If[StringQ[cred], Return[cred]]];
    cred = Lookup[$iLocalLLMAPIKeyMap, Key[{prov, "*"}], None];
    If[StringQ[cred], Return[cred]];
    ToUpperCase[prov] <> "_API_KEY"
  ];

(* ---- Public: \:540d\:524d\:306e\:307f\:89e3\:6c7a (SystemCredential \:306f\:89e6\:3089\:306a\:3044) ---- *)

NBAccess`NBLocalLLMCredentialName[provider_String, url_String] :=
  iLocalLLMLookupCredential[provider, url];

(* ---- Public: SystemCredential \:304b\:3089\:5b9f\:5024\:53d6\:5f97 ---- *)

Options[NBAccess`NBGetLocalLLMAPIKey] = {PrivacySpec -> Automatic};

NBAccess`NBGetLocalLLMAPIKey[provider_String, url_String,
                             opts:OptionsPattern[]] :=
  Module[{al, credName, key},
    al = iAccessLevel[OptionValue[PrivacySpec]];
    If[al < 1.0, Return[$Failed]];
    credName = iLocalLLMLookupCredential[provider, url];
    If[!StringQ[credName] || credName === "",
      Message[NBGetLocalLLMAPIKey::unkn, provider, url];
      Return[$Failed]];
    key = Quiet[SystemCredential[credName]];
    If[!StringQ[key] || StringLength[key] === 0,
      Message[NBGetLocalLLMAPIKey::nokey, provider, url, credName];
      Return[$Failed]];
    key
  ];

NBGetLocalLLMAPIKey::unkn =
  "\:30ed\:30fc\:30ab\:30eb LLM `1` (`2`) \:306e API \:30ad\:30fc\:540d\:304c\:89e3\:6c7a\:3067\:304d\:307e\:305b\:3093\:3002" <>
  "NBSetLocalLLMAPIKey[`1`, `2`, \"YOUR_CREDENTIAL_NAME\"] \:3067\:767b\:9332\:3057\:3066\:304f\:3060\:3055\:3044\:3002";
NBGetLocalLLMAPIKey::nokey =
  "\:30ed\:30fc\:30ab\:30eb LLM `1` (`2`) \:306b\:5bfe\:3059\:308b API \:30ad\:30fc\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002" <>
  "SystemCredential[\"`3`\"] = \"<your key>\" \:3092\:8a2d\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002";

(* ---- Public: \:30de\:30c3\:30d4\:30f3\:30b0\:767b\:9332 ---- *)

NBAccess`NBSetLocalLLMAPIKey[provider_String, url_String,
                             credName_String] :=
  Module[{prov = ToLowerCase[provider], nu},
    nu = If[url === "*", "*", iNormalizeLocalLLMURL[url]];
    $iLocalLLMAPIKeyMap[{prov, nu}] = credName;
    {prov, nu} -> credName
  ];

(* ---- Public: \:30de\:30c3\:30d4\:30f3\:30b0\:767b\:9332 + SystemCredential \:8a2d\:5b9a ---- *)

NBAccess`NBStoreLocalLLMAPIKey[provider_String, url_String,
                               credName_String, key_String] :=
  Module[{prov = ToLowerCase[provider], nu, storeResult},
    nu = If[url === "*", "*", iNormalizeLocalLLMURL[url]];
    storeResult = Quiet @ Check[SystemCredential[credName] = key, $Failed];
    If[storeResult === $Failed,
      Message[NBStoreLocalLLMAPIKey::cantstore, credName];
      Return[$Failed]];
    $iLocalLLMAPIKeyMap[{prov, nu}] = credName;
    True
  ];
NBStoreLocalLLMAPIKey::cantstore =
  "SystemCredential[\"`1`\"] \:3078\:306e\:66f8\:304d\:8fbc\:307f\:306b\:5931\:6557\:3057\:307e\:3057\:305f\:3002" <>
  "OS \:306e\:30ad\:30fc\:30c1\:30a7\:30fc\:30f3\:30a2\:30af\:30bb\:30b9\:6a29\:3084\:30a2\:30f3\:30ed\:30c3\:30af\:72b6\:614b\:3092\:78ba\:8a8d\:3057\:3066\:304f\:3060\:3055\:3044\:3002";

(* ---- Public: \:30de\:30c3\:30d4\:30f3\:30b0\:524a\:9664 ---- *)

NBAccess`NBRemoveLocalLLMAPIKey[provider_String, url_String] :=
  Module[{prov = ToLowerCase[provider], nu},
    nu = If[url === "*", "*", iNormalizeLocalLLMURL[url]];
    $iLocalLLMAPIKeyMap = KeyDrop[$iLocalLLMAPIKeyMap, {{prov, nu}}];
    Null
  ];

(* ---- Public: \:30de\:30c3\:30d4\:30f3\:30b0\:4e00\:89a7 (Dataset) ---- *)

NBAccess`NBLocalLLMAPIKeyMap[] :=
  Module[{rows},
    rows = KeyValueMap[
      Function[{k, v},
        Module[{credSet = False},
          credSet = Quiet @ Check[
            Module[{s = SystemCredential[v]},
              StringQ[s] && StringLength[s] > 0],
            False];
          <|"Provider"       -> k[[1]],
            "URL"            -> k[[2]],
            "CredentialName" -> v,
            "Configured"     -> credSet|>
        ]],
      $iLocalLLMAPIKeyMap];
    Dataset[rows]
  ];


(* ============================================================
   \:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea API
   ============================================================ *)

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   Phase 2: AccessPathRef API + NBSetAccessibleDirs \:4e92\:63db\:30e9\:30c3\:30d1
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   cross-PC path policy v3 \[Section]5.3 / \[Section]12.2 \:6e96\:62e0\:3002
   claudeAccessiblePathRefs \:3092\:6b63\:672c (canonical) \:3068\:3057\:3001\:65e7 claudeAccessibleDirs \:306f
   read fallback \:3068\:3057\:3066\:306e\:307f\:6b8b\:3059\:3002rule 104: PathRef \:306f identity \:3067\:3042\:3063\:3066\:6a29\:9650\:3067\:306f\:306a\:3044\:3002 *)

(* PathRef (Association \:307e\:305f\:306f {"$root", ...} \:30ea\:30b9\:30c8) \:304b\:3089
   {RootId, Parts} \:306e\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:30ea\:30b9\:30c8\:3092\:53d6\:308a\:51fa\:3059\:3002
   \:53d6\:308a\:51fa\:305b\:306a\:3051\:308c\:3070 Missing[]\:3002 *)
iNBPathRefToSymList[pathRef_] :=
  Which[
    (* {"$onWork", "a", "b.nb"} \:5f62\:5f0f\:306e\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:30ea\:30b9\:30c8 *)
    ListQ[pathRef] && Length[pathRef] >= 1 && AllTrue[pathRef, StringQ],
      pathRef,
    (* NBNormalizePath \:304c\:8fd4\:3059 Association *)
    AssociationQ[pathRef] && KeyExistsQ[pathRef, "SymbolicPath"] &&
      ListQ[pathRef["SymbolicPath"]],
      pathRef["SymbolicPath"],
    (* {RootId, Parts} \:3060\:3051\:6301\:3064 Association *)
    AssociationQ[pathRef] && KeyExistsQ[pathRef, "RootId"] &&
      KeyExistsQ[pathRef, "Parts"] && StringQ[pathRef["RootId"]] &&
      ListQ[pathRef["Parts"]],
      Prepend[pathRef["Parts"], pathRef["RootId"]],
    True,
      Missing["InvalidPathRef"]
  ];

(* PathRef \:3092\:73fe PC \:306e\:5b9f\:30d1\:30b9\:3078\:89e3\:6c7a\:3059\:308b\:3002
   SourceVault \:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089 iSVResolvePath \:306b\:59d4\:8b72\:3002
   \:89e3\:6c7a\:3067\:304d\:306a\:3044 (\:30eb\:30fc\:30c8\:672a\:5b9a\:7fa9\:30fb\:5225 PC \:30a8\:30a4\:30ea\:30a2\:30b9\:306e\:307f) \:306a\:3089 Missing[...]\:3002
   rule 104: alias-only / root-missing \:306f\:5b9f\:30d1\:30b9\:306b\:89e3\:6c7a\:3057\:306a\:3044\:3002 *)
NBAccess`NBResolvePathRef[pathRef_] :=
  Module[{symList, head, resolved},
    symList = iNBPathRefToSymList[pathRef];
    If[MissingQ[symList], Return[symList]];
    If[symList === {}, Return[Missing["EmptyPathRef"]]];
    head = First[symList];
    (* <ABS> \:306f\:7d76\:5bfe\:30d1\:30b9\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: \:305d\:306e\:307e\:307e\:5b9f\:30d1\:30b9\:6271\:3044 *)
    If[head === "<ABS>",
      Return[If[Length[symList] >= 2 && StringQ[symList[[2]]],
        symList[[2]], Missing["InvalidAbsPathRef"]]]];
    (* SourceVault \:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089 iSVResolvePath \:306b\:59d4\:8b72 *)
    If[iNBSourceVaultPathAvailableQ[] &&
       Quiet @ Check[DownValues[SourceVault`iSVResolvePath] =!= {}, False],
      resolved = Quiet @ Check[SourceVault`iSVResolvePath[symList], Missing[]];
      If[StringQ[resolved], Return[resolved]];
      Return[Missing["RootMissing"]]];
    (* SourceVault \:672a\:30ed\:30fc\:30c9: \:73fe PC \:5b9f\:4f53\:30eb\:30fc\:30c8\:306e\:307f\:3067\:89e3\:6c7a *)
    Module[{bare, v},
      bare = StringTrim[head, "$"];
      v = Quiet @ ToExpression["Global`$" <> bare];
      If[!StringQ[v] || !DirectoryQ[v],
        Return[Missing["RootMissing"]]];
      If[Length[symList] === 1,
        ExpandFileName[v],
        FileNameJoin[Prepend[Rest[symList], ExpandFileName[v]]]]]
  ];

NBAccess`NBResolvePathRef[___] := Missing["InvalidPathRefArgument"];

(* \:65e7\:5f62\:5f0f\:306e\:7d76\:5bfe\:30d1\:30b9\:6587\:5b57\:5217\:3001\:307e\:305f\:306f\:90e8\:5206\:7684\:306a\:6307\:5b9a\:3092\:5b8c\:5168\:306a AccessPathRef \:306b\:6b63\:898f\:5316\:3002
   \:6587\:5b57\:5217\:306a\:3089 NBNormalizePath \:3067 PathRef \:5316\:3001Mode -> "Read"\:3001CloudSend -> "Ask" \:65e2\:5b9a\:3002
   \:65e2\:306b AccessPathRef Association \:306a\:3089\:4e0d\:8db3\:30ad\:30fc\:3092\:88dc\:3046\:3002 *)
NBAccess`NBNormalizeAccessPathRef[dir_String] :=
  Module[{norm},
    norm = Quiet @ Check[NBAccess`NBNormalizePath[dir], $Failed];
    <|
      "PathRef" -> If[AssociationQ[norm],
        KeyTake[norm, {"Kind", "RootId", "Parts"}],
        Missing["NormalizeFailed"]],
      "SymbolicPath" -> If[AssociationQ[norm],
        Lookup[norm, "SymbolicPath", Missing[]], Missing[]],
      "Mode" -> "Read",
      "CloudSend" -> "Ask",
      "LegacyDir" -> dir
    |>
  ];

NBAccess`NBNormalizeAccessPathRef[ref_Association] :=
  Module[{pr, sym},
    pr = Lookup[ref, "PathRef", Missing["NoPathRef"]];
    sym = Lookup[ref, "SymbolicPath", Missing[]];
    <|
      "PathRef" -> pr,
      "SymbolicPath" -> sym,
      "Mode" -> Lookup[ref, "Mode", "Read"],
      "CloudSend" -> Lookup[ref, "CloudSend", "Ask"]
    |>
  ];

NBAccess`NBNormalizeAccessPathRef[other_] :=
  <|"PathRef" -> Missing["InvalidAccessPathRef"],
    "Mode" -> "None", "CloudSend" -> False|>;

(* \[HorizontalLine]\[HorizontalLine] AccessPathRef \:3092 notebook TaggingRules \:306b\:4fdd\:5b58\:30fb\:53d6\:5f97 \[HorizontalLine]\[HorizontalLine] *)

NBAccess`NBSetAccessiblePathRefs[nb_NotebookObject, refs_List] :=
  NBAccess`NBSetTaggingRule[nb, "claudeAccessiblePathRefs",
    Map[NBAccess`NBNormalizeAccessPathRef, refs]];

NBAccess`NBSetAccessiblePathRefs[refs_List] :=
  NBAccess`NBSetAccessiblePathRefs[EvaluationNotebook[], refs];

NBAccess`NBGetAccessiblePathRefs[nb_NotebookObject] :=
  Module[{val, legacy},
    val = NBAccess`NBGetTaggingRule[nb, "claudeAccessiblePathRefs"];
    If[ListQ[val] && val =!= {},
      Return[Select[val, AssociationQ]]];
    (* read fallback: \:65e7 claudeAccessibleDirs \:3092 AccessPathRef \:306b\:5909\:63db *)
    legacy = NBAccess`NBGetTaggingRule[nb, "claudeAccessibleDirs"];
    If[ListQ[legacy],
      Map[NBAccess`NBNormalizeAccessPathRef,
        Select[legacy, StringQ[#] && StringLength[#] > 0 &]],
      {}]
  ];

NBAccess`NBGetAccessiblePathRefs[] :=
  NBAccess`NBGetAccessiblePathRefs[EvaluationNotebook[]];

(* \[HorizontalLine]\[HorizontalLine] \:5f8c\:65b9\:4e92\:63db API: NBSetAccessibleDirs / NBGetAccessibleDirs \[HorizontalLine]\[HorizontalLine]
   policy v3 \[Section]12.2: claudeAccessiblePathRefs \:3092\:6b63\:672c\:3068\:3057\:3001\:65e7 dir \:30ea\:30b9\:30c8\:306f
   read fallback\:3002NBGetAccessibleDirs \:306f\:5f93\:6765\:901a\:308a\:300c\:73fe PC \:5b9f\:30d1\:30b9\:306e List\:300d\:3092\:8fd4\:3059
   \:5951\:7d04\:3092\:7dad\:6301\:3059\:308b (claudecode.wl \:5074\:3092\:5909\:66f4\:4e0d\:8981\:306b\:3059\:308b\:305f\:3081)\:3002 *)

NBAccess`NBSetAccessibleDirs[nb_NotebookObject, dirs_List] :=
  NBAccess`NBSetAccessiblePathRefs[nb,
    Map[NBAccess`NBNormalizeAccessPathRef,
      Select[dirs, StringQ[#] && StringLength[#] > 0 &]]];

NBAccess`NBSetAccessibleDirs[dirs_List] :=
  NBAccess`NBSetAccessibleDirs[EvaluationNotebook[], dirs];

NBAccess`NBGetAccessibleDirs[nb_NotebookObject] :=
  Module[{refs, resolved},
    refs = NBAccess`NBGetAccessiblePathRefs[nb];
    (* \:5404 AccessPathRef \:3092\:73fe PC \:306e\:5b9f\:30d1\:30b9\:3078 materialize\:3002
       alias-only / root-missing \:306f\:89e3\:6c7a\:3055\:308c\:305a\:9664\:5916\:3055\:308c\:308b (rule 104)\:3002 *)
    resolved = Map[
      Function[r,
        Module[{pr, p},
          pr = Lookup[r, "PathRef", Missing[]];
          p = NBAccess`NBResolvePathRef[pr];
          If[StringQ[p] && (DirectoryQ[p] || FileExistsQ[p]),
            p,
            (* PathRef \:304c\:89e3\:6c7a\:3067\:304d\:306a\:3044\:5834\:5408\:3001\:65e7 dir \:6587\:5b57\:5217\:304c\:3042\:308c\:3070\:6700\:5f8c\:306e\:624b\:6bb5\:3067\:4f7f\:3046 *)
            With[{ld = Lookup[r, "LegacyDir", Missing[]]},
              If[StringQ[ld] && DirectoryQ[ld], ld, Nothing]]]]],
      refs];
    DeleteDuplicates[Select[resolved, StringQ]]
  ];

NBAccess`NBGetAccessibleDirs[] :=
  NBAccess`NBGetAccessibleDirs[EvaluationNotebook[]];


(* ============================================================
   \:6c4e\:7528\:5c65\:6b74\:30c7\:30fc\:30bf\:30d9\:30fc\:30b9 API
   TaggingRules \:3092\:7528\:3044\:305f\:9806\:6b21\:683c\:7d0d\:578b\:5c65\:6b74\:30b7\:30b9\:30c6\:30e0\:3002
   \:30fb\:5404\:30bf\:30b0\:306b <|"header" -> ..., "entries" -> {...}|> \:3092\:683c\:7d0d
   \:30fbheader \:306e "diffFields" \:306b\:5dee\:5206\:5727\:7e2e\:5bfe\:8c61\:30d5\:30a3\:30fc\:30eb\:30c9\:540d\:30ea\:30b9\:30c8\:3092\:683c\:7d0d
   \:30fbentries \:306e\:5dee\:5206\:5bfe\:8c61\:30d5\:30a3\:30fc\:30eb\:30c9\:306f Diff \:306b\:3088\:308b\:5dee\:5206\:5727\:7e2e
     \:ff08\:6700\:65b0\:30a8\:30f3\:30c8\:30ea\:306f\:5e73\:6587\:3001\:305d\:308c\:4ee5\:524d\:306f Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:ff09
   \:30fbPrivacySpec \:30aa\:30d7\:30b7\:30e7\:30f3\:3067 privacylevel \:3092\:30a8\:30f3\:30c8\:30ea\:306b\:8a18\:9332
   ============================================================ *)

(* ---- \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: \:30d8\:30c3\:30c0\:30fc\:304b\:3089\:5dee\:5206\:5727\:7e2e\:30d5\:30a3\:30fc\:30eb\:30c9\:3092\:53d6\:5f97 ---- *)
(* \:5f8c\:65b9\:4e92\:63db: diffFields \:672a\:8a2d\:5b9a\:306e\:65e7 DB \:306b\:306f\:7a7a\:30ea\:30b9\:30c8\:3092\:8fd4\:3059 *)
iGetDiffFields[header_Association] :=
  Lookup[header, "diffFields", {}];

iGetDiffFields[nb_NotebookObject, tag_String] :=
  iGetDiffFields[Lookup[NBAccess`NBHistoryRawData[nb, tag], "header", <||>]];

(* \:30a8\:30f3\:30c8\:30ea\:306e\:5dee\:5206\:30d5\:30a3\:30fc\:30eb\:30c9\:304c\:307e\:3060\:5e73\:6587\:ff08\:672a\:5727\:7e2e\:ff09\:304b\:3092\:5224\:5b9a *)
iIsPlainEntry[entry_Association, diffFields_List] :=
  AnyTrue[diffFields,
    Function[f, StringQ[Lookup[entry, f, Missing[]]]]];

(* prev \:30a8\:30f3\:30c8\:30ea\:3092 next \:30a8\:30f3\:30c8\:30ea\:3068\:306e\:5dee\:5206\:3067\:5727\:7e2e\:3059\:308b *)
iCompressOneEntry[prev_Association, next_Association, diffFields_List] :=
  Fold[
    Function[{e, field},
      Module[{pv = Lookup[e, field, ""], nv = Lookup[next, field, ""]},
        If[StringQ[pv] && StringQ[nv],
          <|e, field -> Diff[nv, pv]|>,
          e]]],
    prev,
    diffFields];

(* \:5dee\:5206\:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:3092 nextPlain \:306e\:5e73\:6587\:3067\:5fa9\:5143\:3059\:308b *)
iDecompressOneEntry[entry_Association, nextPlain_Association, diffFields_List] :=
  Fold[
    Function[{e, field},
      Module[{sv = Lookup[e, field, ""], nv = Lookup[nextPlain, field, ""]},
        If[!StringQ[sv] && StringQ[nv],
          (* Diff \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 \[RightArrow] DiffApply \:3067\:5fa9\:5143 *)
          <|e, field -> Quiet@Check[DiffApply[sv, nv], "(\:5fa9\:5143\:5931\:6557)"]|>,
          e]]],
    entry,
    diffFields];

(* \:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8\:5168\:4f53\:3092\:5fa9\:5143 (\:6700\:65b0=\:672b\:5c3e \:304c\:5e73\:6587\:3001\:305d\:308c\:4ee5\:524d\:3092\:9806\:6b21\:5fa9\:5143) *)
iDecompressAllEntries[entries_List, diffFields_List] :=
  Which[
    Length[entries] <= 1, entries,
    Length[diffFields] === 0, entries,
    True, Module[{n = Length[entries], result},
      result = entries;
      Do[result[[i]] = iDecompressOneEntry[result[[i]], result[[i + 1]], diffFields],
        {i, n - 1, 1, -1}];
      result]
  ];

(* \:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8\:5168\:4f53\:3092\:5727\:7e2e (\:6700\:65b0\:3092\:5e73\:6587\:306e\:307e\:307e\:3001\:305d\:308c\:4ee5\:524d\:3092 Diff \:5316) *)
iCompressAllEntries[entries_List, diffFields_List] :=
  Which[
    Length[entries] <= 1, entries,
    Length[diffFields] === 0, entries,
    True, Module[{n = Length[entries], result},
      result = entries;
      Do[result[[i]] = iCompressOneEntry[result[[i]], result[[i + 1]], diffFields],
        {i, n - 1, 1, -1}];
      result]
  ];

(* ---- NBHistoryRawData: \:5727\:7e2e\:72b6\:614b\:306e\:307e\:307e\:8aad\:307f\:53d6\:308a (\:30ad\:30e3\:30c3\:30b7\:30e5\:4ed8\:304d) ----
   ClaudeQuery 1\:56de\:3067\:540c\:3058\:5c65\:6b74\:30927\:56de\:4ee5\:4e0a\:8aad\:3080\:305f\:3081\:3001\:30ad\:30e3\:30c3\:30b7\:30e5\:3067 FE \:901a\:4fe1\:3092\:524a\:6e1b\:3002
   \:66f8\:304d\:8fbc\:307f\:7cfb\:95a2\:6570\:306f iHistoryCacheUpdate / iHistoryCacheInvalidate \:3067\:30ad\:30e3\:30c3\:30b7\:30e5\:3092\:540c\:671f\:3059\:308b\:3002 *)

$iNBHistoryCache = <||>;

iHistoryCacheKey[nb_NotebookObject, tag_String] :=
  {nb, tag};

iHistoryCacheInvalidate[nb_NotebookObject, tag_String] :=
  ($iNBHistoryCache = KeyDrop[$iNBHistoryCache, Key[{nb, tag}]]);

iHistoryCacheUpdate[nb_NotebookObject, tag_String, val_] :=
  ($iNBHistoryCache[{nb, tag}] = val);

(* \:5168\:30ad\:30e3\:30c3\:30b7\:30e5\:30af\:30ea\:30a2\:ff08\:30d1\:30c3\:30b1\:30fc\:30b8\:518d\:30ed\:30fc\:30c9\:30fb\:30bb\:30c3\:30b7\:30e7\:30f3\:5207\:66ff\:6642\:ff09 *)
NBAccess`NBHistoryCacheClear[] := ($iNBHistoryCache = <||>);

NBAccess`NBHistoryRawData[nb_NotebookObject, tag_String] := Module[{key, val},
  key = {nb, tag};
  If[KeyExistsQ[$iNBHistoryCache, key],
    Return[$iNBHistoryCache[key]]];
  val = NBAccess`NBGetTaggingRule[nb, tag];
  val = If[AssociationQ[val] && KeyExistsQ[val, "entries"], val,
    <|"header" -> <||>, "entries" -> {}|>];
  $iNBHistoryCache[key] = val;
  val
];

(* ---- NBHistoryCreate: DB \:4f5c\:6210 (\:51aa\:7b49) ---- *)
NBAccess`NBHistoryCreate[nb_NotebookObject, tag_String, diffFields_List] :=
  NBAccess`NBHistoryCreate[nb, tag, diffFields, <||>];

NBAccess`NBHistoryCreate[nb_NotebookObject, tag_String, diffFields_List,
    headerOverrides_Association] :=
  Module[{raw, existingHdr, hdr},
    raw = NBAccess`NBHistoryRawData[nb, tag];
    existingHdr = Lookup[raw, "header", <||>];
    (* diffFields \:8a2d\:5b9a\:6e08\:307f\:306a\:3089\:51aa\:7b49: \:65e2\:5b58\:30d8\:30c3\:30c0\:30fc\:3092\:8fd4\:3059 *)
    If[AssociationQ[existingHdr] && KeyExistsQ[existingHdr, "diffFields"],
      Return[existingHdr]];
    (* \:65b0\:898f\:4f5c\:6210 or \:65e7 DB \:306b diffFields \:3092\:8ffd\:52a0 *)
    hdr = <|
      "type"       -> "history_header",
      "name"       -> "$default",
      "parent"     -> None,
      "inherit"    -> True,
      "created"    -> AbsoluteTime[],
      existingHdr,
      headerOverrides,
      "diffFields" -> diffFields
    |>;
    With[{newData = <|raw, "header" -> hdr|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]];
    hdr
  ];

(* ---- NBHistoryData: \:5fa9\:5143\:6e08\:307f\:30c7\:30fc\:30bf (Decompress->False \:3067\:5727\:7e2e\:72b6\:614b) ---- *)
Options[NBAccess`NBHistoryData] = {Decompress -> True};

NBAccess`NBHistoryData[nb_NotebookObject, tag_String, opts:OptionsPattern[]] :=
  Module[{raw, entries, hdr, diffFields},
    raw = NBAccess`NBHistoryRawData[nb, tag];
    entries = Lookup[raw, "entries", {}];
    If[TrueQ[OptionValue[NBAccess`NBHistoryData, {opts}, Decompress]],
      hdr = Lookup[raw, "header", <||>];
      diffFields = iGetDiffFields[hdr];
      entries = iDecompressAllEntries[entries, diffFields]];
    <|raw, "entries" -> entries|>
  ];

(* ---- NBHistorySetData: \:5727\:7e2e\:3057\:3066\:66f8\:304d\:8fbc\:307f ---- *)
NBAccess`NBHistorySetData[nb_NotebookObject, tag_String, data_Association] :=
  Module[{entries, compressed, hdr, diffFields},
    entries = Lookup[data, "entries", {}];
    hdr = Lookup[data, "header", <||>];
    diffFields = iGetDiffFields[hdr];
    compressed = iCompressAllEntries[entries, diffFields];
    With[{newData = <|data, "entries" -> compressed|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryEntries: \:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8 (Decompress->False \:3067\:5727\:7e2e\:72b6\:614b) ---- *)
Options[NBAccess`NBHistoryEntries] = {Decompress -> True};

NBAccess`NBHistoryEntries[nb_NotebookObject, tag_String, opts:OptionsPattern[]] :=
  Lookup[NBAccess`NBHistoryData[nb, tag,
    Decompress -> OptionValue[NBAccess`NBHistoryEntries, {opts}, Decompress]],
    "entries", {}];

(* ---- NBHistoryReadHeader ---- *)
NBAccess`NBHistoryReadHeader[nb_NotebookObject, tag_String] := Module[{data, hdr},
  data = NBAccess`NBHistoryRawData[nb, tag];
  hdr = Lookup[data, "header", <||>];
  If[AssociationQ[hdr] && Length[hdr] > 0, hdr,
    <|"type" -> "history_header", "name" -> "$default",
      "parent" -> None, "inherit" -> True, "created" -> 0|>]
];

(* ---- NBHistoryWriteHeader ---- *)
NBAccess`NBHistoryWriteHeader[nb_NotebookObject, tag_String, header_Association] :=
  Module[{data},
    data = NBAccess`NBHistoryRawData[nb, tag];
    With[{newData = <|data, "header" -> header|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryAppend: \:30a8\:30f3\:30c8\:30ea\:8ffd\:52a0 (\:5dee\:5206\:5727\:7e2e + privacylevel) ---- *)
Options[NBAccess`NBHistoryAppend] = {PrivacySpec -> Automatic};

NBAccess`NBHistoryAppend[nb_NotebookObject, tag_String,
    entry_Association, opts:OptionsPattern[]] :=
  Module[{data, entries, ps, newEntry, n, hdr, diffFields},
    data = NBAccess`NBHistoryRawData[nb, tag];
    If[!AssociationQ[data], data = <|"header" -> <||>, "entries" -> {}|>];
    entries = Lookup[data, "entries", {}];
    hdr = Lookup[data, "header", <||>];
    diffFields = iGetDiffFields[hdr];
    n = Length[entries];

    (* privacylevel \:3092\:4ed8\:4e0e *)
    ps = OptionValue[PrivacySpec];
    If[ps === Automatic, ps = NBAccess`$NBPrivacySpec];
    newEntry = <|entry, "privacylevel" -> ps|>;

    (* \:4e8c\:3064\:524d\:306e\:30a8\:30f3\:30c8\:30ea\:304c\:672a\:5727\:7e2e\:306a\:3089\:3001\:76f4\:524d\:306e\:30a8\:30f3\:30c8\:30ea\:3068\:306e\:5dee\:5206\:3067\:5727\:7e2e\:3002
       \:76f4\:524d\:30a8\:30f3\:30c8\:30ea (entries[[-1]]) \:306f\:524d\:56de\:306e updateLast \:3067\:78ba\:5b9a\:6e08\:307f\:3002
       \:203b entries[[-1]] \:306f\:307e\:3060\:5e73\:6587\:306a\:306e\:3067\:3053\:306e\:6bb5\:968e\:3067\:5727\:7e2e\:53ef\:80fd\:3002 *)
    If[n >= 2 && iIsPlainEntry[entries[[-2]], diffFields],
      entries[[-2]] = iCompressOneEntry[entries[[-2]], entries[[-1]], diffFields]];

    entries = Append[entries, newEntry];
    With[{newData = <|data, "entries" -> entries|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryUpdateLast: \:6700\:7d42\:30a8\:30f3\:30c8\:30ea\:306e\:66f4\:65b0 ---- *)
NBAccess`NBHistoryUpdateLast[nb_NotebookObject, tag_String,
    updates_Association] :=
  Module[{data, entries},
    data = NBAccess`NBHistoryRawData[nb, tag];
    entries = Lookup[data, "entries", {}];
    If[Length[entries] === 0, Return[]];
    entries = MapAt[Merge[{#, updates}, Last] &, entries, -1];
    With[{newData = <|data, "entries" -> entries|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];


(* ---- NBHistoryReplaceEntries: \:30a8\:30f3\:30c8\:30ea\:30ea\:30b9\:30c8\:5168\:4f53\:306e\:7f6e\:63db ---- *)
NBAccess`NBHistoryReplaceEntries[nb_NotebookObject, tag_String, entries_List] :=
  Module[{data},
    data = NBAccess`NBHistoryRawData[nb, tag];
    If[!AssociationQ[data], data = <|"header" -> <||>, "entries" -> {}|>];
    With[{newData = <|data, "entries" -> entries|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryUpdateHeader: \:30d8\:30c3\:30c0\:30fc\:306e\:90e8\:5206\:66f4\:65b0 ---- *)
NBAccess`NBHistoryUpdateHeader[nb_NotebookObject, tag_String, updates_Association] :=
  Module[{data, hdr},
    data = NBAccess`NBHistoryRawData[nb, tag];
    hdr = Lookup[data, "header", <||>];
    hdr = Merge[{hdr, updates}, Last];
    With[{newData = <|data, "header" -> hdr|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryEntriesWithInherit: \:89aa\:30c1\:30a7\:30fc\:30f3\:3092\:8fbf\:3063\:305f\:5168\:5c65\:6b74 ---- *)
Options[NBAccess`NBHistoryEntriesWithInherit] = {Decompress -> True};

NBAccess`NBHistoryEntriesWithInherit[nb_NotebookObject, tag_String,
    opts:OptionsPattern[]] :=
  Module[{hdr, parentTag, parentHist, ownHist, createdTime, dec},
    dec = OptionValue[NBAccess`NBHistoryEntriesWithInherit, {opts}, Decompress];
    hdr = NBAccess`NBHistoryReadHeader[nb, tag];
    ownHist = NBAccess`NBHistoryEntries[nb, tag, Decompress -> dec];
    parentTag = Lookup[hdr, "parent", None];
    If[parentTag === None || Lookup[hdr, "inherit", True] === False,
      ownHist,
      createdTime = Lookup[hdr, "created", Infinity];
      parentHist = If[StringQ[parentTag],
        NBAccess`NBHistoryEntriesWithInherit[nb, parentTag, Decompress -> dec],
        {}];
      If[NumericQ[createdTime] && createdTime < Infinity,
        parentHist = Select[parentHist,
          Function[entry, Lookup[entry, "time", 0] <= createdTime]]];
      Join[parentHist, ownHist]]
  ];

(* ---- NBHistoryListTags ---- *)
NBAccess`NBHistoryListTags[nb_NotebookObject, prefix_String] :=
  NBAccess`NBListTaggingRuleKeys[nb, prefix];

(* ---- NBHistoryDelete ---- *)
NBAccess`NBHistoryDelete[nb_NotebookObject, tag_String] := (
  NBAccess`NBDeleteTaggingRule[nb, tag];
  iHistoryCacheInvalidate[nb, tag]);

(* ---- \:30bb\:30c3\:30b7\:30e7\:30f3\:30a2\:30bf\:30c3\:30c1\:30e1\:30f3\:30c8 API ---- *)

NBAccess`NBHistoryAddAttachment[nb_NotebookObject, tag_String, path_String] :=
  Module[{hdr, atts, norm},
    norm = ExpandFileName[path];
    hdr = NBAccess`NBHistoryReadHeader[nb, tag];
    atts = Lookup[hdr, "attachments", {}];
    If[!ListQ[atts], atts = {}];
    If[!MemberQ[atts, norm],
      atts = Append[atts, norm];
      NBAccess`NBHistoryWriteHeader[nb, tag, <|hdr, "attachments" -> atts|>]];
    atts
  ];

NBAccess`NBHistoryRemoveAttachment[nb_NotebookObject, tag_String, path_String] :=
  Module[{hdr, atts, norm},
    norm = ExpandFileName[path];
    hdr = NBAccess`NBHistoryReadHeader[nb, tag];
    atts = Lookup[hdr, "attachments", {}];
    If[!ListQ[atts], atts = {}];
    atts = DeleteCases[atts, norm];
    NBAccess`NBHistoryWriteHeader[nb, tag, <|hdr, "attachments" -> atts|>];
    atts
  ];

NBAccess`NBHistoryGetAttachments[nb_NotebookObject, tag_String] :=
  Module[{hdr, atts},
    hdr = NBAccess`NBHistoryReadHeader[nb, tag];
    atts = Lookup[hdr, "attachments", {}];
    If[ListQ[atts], atts, {}]
  ];

NBAccess`NBHistoryClearAttachments[nb_NotebookObject, tag_String] :=
  Module[{hdr},
    hdr = NBAccess`NBHistoryReadHeader[nb, tag];
    NBAccess`NBHistoryWriteHeader[nb, tag, <|hdr, "attachments" -> {}|>];
  ];

(* ---- NBHistoryClearAll: \:5168\:5c65\:6b74\:524a\:9664 (AccessLevel 1.0 \:5fc5\:9808) ---- *)
Options[NBAccess`NBHistoryClearAll] = {PrivacySpec -> Automatic};
NBAccess`NBHistoryClearAll[nb_NotebookObject, prefix_String,
    opts : OptionsPattern[]] :=
  Module[{al, tags, count},
    al = iAccessLevel[OptionValue[PrivacySpec]];
    If[al < 1.0,
      Message[NBHistoryClearAll::acl, al];
      Return[$Failed]];
    tags = NBAccess`NBHistoryListTags[nb, prefix];
    count = Length[tags];
    Scan[NBAccess`NBHistoryDelete[nb, #] &, tags];
    count
  ];
NBHistoryClearAll::acl =
  "AccessLevel `1` < 1.0: \:5168\:5c65\:6b74\:524a\:9664\:306b\:306f PrivacySpec -> <|\"AccessLevel\" -> 1.0|> \:304c\:5fc5\:8981\:3067\:3059\:3002";


(* ============================================================
   \:5c65\:6b74\:30d7\:30e9\:30a4\:30d0\:30b7\:30d5\:30a3\:30eb\:30bf\:30fc
   ============================================================ *)

iHistoryFieldLeaksConfidential[text_String, confVars_List] :=
  If[!StringQ[text] || Length[confVars] === 0, False,
    AnyTrue[confVars,
      StringContainsQ[text,
        RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <>
                         "(?![\\p{L}\\p{N}$])"] ] &]
  ];

NBAccess`NBFilterHistoryEntry[entry_Association, confVars_List] :=
  NBAccess`NBFilterHistoryEntry[entry, confVars, <||>];

NBAccess`NBFilterHistoryEntry[entry_Association, confVars_List, confVarTimes_Association] :=
  Module[{resp, code, entryTime, minConfTime, blocked},
    entryTime = Lookup[entry, "time", 0];
    If[Length[confVars] > 0 && NumberQ[entryTime],
      minConfTime = Min @ Map[
        Function[v, Lookup[confVarTimes, v, Infinity]], confVars];
      If[NumberQ[minConfTime] && minConfTime < Infinity && entryTime > minConfTime,
        Return[entry]]];

    resp    = Lookup[entry, "response", ""];
    code    = Lookup[entry, "code", ""];
    blocked = False;

    If[iHistoryFieldLeaksConfidential[resp, confVars],
      resp = "(\:6a5f\:5bc6\:5909\:6570\:306e\:5024\:3092\:542b\:3080\:305f\:3081\:3053\:306e\:30b9\:30c6\:30c3\:30d7\:306e\:5c65\:6b74\:306f\:975e\:8868\:793a)";
      blocked = True];

    If[!blocked && iHistoryFieldLeaksConfidential[code, confVars],
      code = "(\:6a5f\:5bc6\:5909\:6570\:3092\:542b\:3080\:305f\:3081\:975e\:8868\:793a)";
      blocked = True];

    ReplacePart[entry, {"response" -> resp, "code" -> code}]
  ];


(* ============================================================
   Job \:7ba1\:7406: ClaudeQuery/ClaudeEval \:306e\:975e\:540c\:671f\:51fa\:529b\:4f4d\:7f6e\:7ba1\:7406
   \:8a2d\:8a08:
     \:30fb\:8a55\:4fa1\:30bb\:30eb\:306e\:76f4\:5f8c\:306b 3 \:3064\:306e\:4e0d\:53ef\:8996\:30b9\:30ed\:30c3\:30c8\:30bb\:30eb\:3092\:4e88\:7d04
     \:30fb\:30b9\:30ed\:30c3\:30c81: \:30b7\:30b9\:30c6\:30e0\:30e1\:30c3\:30bb\:30fc\:30b8\:ff08\:30d7\:30ed\:30b0\:30ec\:30b9\:30fb\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:901a\:77e5\:ff09
     \:30fb\:30b9\:30ed\:30c3\:30c82: \:5b8c\:4e86\:30e1\:30c3\:30bb\:30fc\:30b8
     \:30fb\:30a2\:30f3\:30ab\:30fc: \:30ec\:30b9\:30dd\:30f3\:30b9\:66f8\:304d\:8fbc\:307f\:4f4d\:7f6e\:30de\:30fc\:30ab\:30fc
     \:30fbCellObject \:306f NBAccess \:5185\:90e8\:3067\:306e\:307f\:7ba1\:7406\:3001ClaudeCode \:5074\:306b\:306f jobId \:306e\:307f\:516c\:958b
   ============================================================ *)

$NBJobTable = <||>;

(* \:4e0d\:53ef\:8996\:30d7\:30ec\:30fc\:30b9\:30db\:30eb\:30c0\:30fc\:30bb\:30eb *)
$iInvisibleCellOpts = Sequence[CellOpen -> False, ShowCellBracket -> False,
  CellMargins -> {{0, 0}, {0, 0}}, CellElementSpacings -> {"CellMinHeight" -> 0}];

(* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5 *)
NBAccess`NBMoveToEnd[nb_NotebookObject] :=
  Quiet[SelectionMove[nb, After, Notebook]];

NBAccess`NBBeginJob[nb_NotebookObject, evalCell_] :=
  Module[{jobId, t1, t2, tA},
    jobId = "cjob" <> ToString[UnixTime[]] <> "x" <> ToString[RandomInteger[99999]];
    t1 = jobId <> "-s1";
    t2 = jobId <> "-s2";
    tA = jobId <> "-anchor";
    (* evalCell \:304c CellObject \:306a\:3089\:305d\:306e\:76f4\:5f8c\:3001\:305d\:3046\:3067\:306a\:3051\:308c\:3070\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e *)
    If[Head[evalCell] === CellObject,
      Quiet[SelectionMove[evalCell, After, Cell, AutoScroll -> False]],
      Quiet[SelectionMove[nb, After, Notebook, AutoScroll -> False]]];
    (* 3\:3064\:306e\:4e0d\:53ef\:8996\:30bb\:30eb\:3092\:9806\:306b\:633f\:5165 *)
    NotebookWrite[nb,
      Cell["", "Text", CellTags -> {t1}, $iInvisibleCellOpts], After];
    NotebookWrite[nb,
      Cell["", "Text", CellTags -> {t2}, $iInvisibleCellOpts], After];
    NotebookWrite[nb,
      Cell["", "Text", CellTags -> {tA}, $iInvisibleCellOpts], After];
    $NBJobTable[jobId] = <|
      "nb"       -> nb,
      "slotTags" -> {t1, t2},
      "anchorTag" -> tA,
      "written"  -> {False, False}
    |>;
    jobId
  ];

(* \:30b9\:30ed\:30c3\:30c8\:306b Cell \:5f0f\:3092\:66f8\:304d\:8fbc\:307f\:53ef\:8996\:306b\:3059\:308b *)
NBAccess`NBWriteSlot[jobId_String, slotIdx_Integer, cellExpr_Cell] :=
  Module[{entry, tag, nb, cells, newCell},
    entry = Lookup[$NBJobTable, jobId, $Failed];
    If[entry === $Failed, Return[$Failed]];
    If[slotIdx < 1 || slotIdx > Length[entry["slotTags"]], Return[$Failed]];
    nb  = entry["nb"];
    tag = entry["slotTags"][[slotIdx]];
    cells = Quiet[Cells[nb, CellTags -> tag]];
    If[!ListQ[cells] || Length[cells] === 0, Return[$Failed]];
    (* \:65b0\:3057\:3044\:30bb\:30eb\:306b\:540c\:3058\:30bf\:30b0\:3092\:4ed8\:4e0e\:3057\:3066\:7f6e\:63db *)
    newCell = Append[cellExpr, CellTags -> {tag}];
    Quiet[SelectionMove[First[cells], All, Cell, AutoScroll -> False]];
    NotebookWrite[nb, newCell, All];
    (* \:66f8\:304d\:8fbc\:307f\:6e08\:307f\:30d5\:30e9\:30b0\:3092\:66f4\:65b0 *)
    $NBJobTable[jobId, "written"] =
      ReplacePart[entry["written"], slotIdx -> True];
  ];

(* \:30a2\:30f3\:30ab\:30fc\:306e\:76f4\:5f8c\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5\:3002
   2026-06-24 (B-fix): \:623b\:308a\:5024\:3092 True/False \:306b\:3057\:3001\:4f4d\:7f6e\:3092\:78ba\:5b9a\:3067\:304d\:305f\:3089 True \:3092\:8fd4\:3059\:3002
   \:5f93\:6765\:306f\:30a2\:30f3\:30ab\:30fc\:30bb\:30eb\:304c\:6d88\:3048\:3066\:3044\:308b (NBEndJob \:6e08\:307f / kernel restart \:3067 $NBJobTable
   \:518d\:69cb\:7bc9) \:3068\:7121\:8a00\:3067 no-op \:306b\:306a\:308a\:3001\:547c\:3073\:51fa\:3057\:5074\:306e\:9078\:629e\:4f4d\:7f6e\:304c\:76f4\:524d\:306e\:51fa\:529b\:30bb\:30eb\:5185\:5bb9\:306b\:6b8b\:308b\:3002
   \:76f4\:524d\:304c\:7de8\:96c6\:53ef\:80fd Grid (SourceVaultMailView \:4e00\:89a7) \:306e\:3068\:304d\:5f8c\:7d9a NBWriteCell \:304c
   \:305d\:306e Grid \:30bb\:30eb\:5185\:3078 \!\(\*Cell[...]\) \:3068\:3057\:3066\:57cb\:3081\:8fbc\:307e\:308c\:308b\:4e0d\:5177\:5408\:306e\:4e00\:56e0 (result2.nb)\:3002
   entry \:306f\:3042\:308b\:304c\:30a2\:30f3\:30ab\:30fc\:6d88\:5931\:306e\:5834\:5408\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e (\:30bb\:30eb\:5883\:754c) \:3078\:9000\:907f\:3057 True \:3092\:8fd4\:3059\:3002
   jobId \:304c $NBJobTable \:306b\:7121\:3044 (nb \:4e0d\:660e) \:5834\:5408\:306e\:307f False \:3092\:8fd4\:3057\:3001\:547c\:3073\:51fa\:3057\:5074\:3067\:672b\:5c3e\:9000\:907f\:3055\:305b\:308b\:3002 *)
NBAccess`NBJobMoveToAnchor[jobId_String] :=
  Module[{entry, nb, cells},
    entry = Lookup[$NBJobTable, jobId, $Failed];
    If[entry === $Failed, Return[False]];
    nb = entry["nb"];
    cells = Quiet[Cells[nb, CellTags -> entry["anchorTag"]]];
    If[ListQ[cells] && Length[cells] > 0,
      Quiet[SelectionMove[First[cells], After, Cell, AutoScroll -> False]],
      Quiet[SelectionMove[nb, After, Notebook, AutoScroll -> False]]];
    True
  ];

(* \:30b8\:30e7\:30d6\:6b63\:5e38\:7d42\:4e86: \:672a\:66f8\:304d\:8fbc\:307f\:30b9\:30ed\:30c3\:30c8\:3068\:30a2\:30f3\:30ab\:30fc\:3092\:524a\:9664 *)
NBAccess`NBEndJob[jobId_String] :=
  Module[{entry, nb},
    entry = Lookup[$NBJobTable, jobId, $Failed];
    If[entry === $Failed, Return[]];
    nb = entry["nb"];
    (* \:672a\:66f8\:304d\:8fbc\:307f\:30b9\:30ed\:30c3\:30c8\:3092\:524a\:9664 *)
    Do[If[!entry["written"][[i]],
      NBAccess`NBDeleteCellsByTag[nb, entry["slotTags"][[i]]]],
    {i, Length[entry["slotTags"]]}];
    (* \:30a2\:30f3\:30ab\:30fc\:3092\:524a\:9664 *)
    NBAccess`NBDeleteCellsByTag[nb, entry["anchorTag"]];
    $NBJobTable = KeyDrop[$NBJobTable, jobId];
  ];

(* \:30b9\:30ed\:30c3\:30c8\:306e written \:30d5\:30e9\:30b0\:3092 False \:306b\:30ea\:30bb\:30c3\:30c8 (NBEndJob \:3067\:306e\:524a\:9664\:5bfe\:8c61\:306b\:3059\:308b) *)
NBAccess`NBJobResetSlotWritten[jobId_String, slotIdx_Integer] :=
  If[KeyExistsQ[$NBJobTable, jobId],
    $NBJobTable[jobId, "written"] =
      ReplacePart[$NBJobTable[jobId]["written"], slotIdx -> False]];

(* \:30b8\:30e7\:30d6\:7570\:5e38\:7d42\:4e86: \:30a8\:30e9\:30fc\:30e1\:30c3\:30bb\:30fc\:30b8\:3092\:66f8\:304d\:8fbc\:307f\:30af\:30ea\:30fc\:30f3\:30a2\:30c3\:30d7 *)
NBAccess`NBAbortJob[jobId_String, errorMsg_String] :=
  Module[{entry, firstUnwritten = 0},
    entry = Lookup[$NBJobTable, jobId, $Failed];
    If[entry === $Failed, Return[]];
    (* \:6700\:521d\:306e\:672a\:66f8\:304d\:8fbc\:307f\:30b9\:30ed\:30c3\:30c8\:306b\:30a8\:30e9\:30fc\:3092\:66f8\:304d\:8fbc\:3080 *)
    Do[If[!entry["written"][[i]],
      firstUnwritten = i; Break[]],
    {i, Length[entry["slotTags"]]}];
    If[firstUnwritten > 0,
      NBAccess`NBWriteSlot[jobId, firstUnwritten,
        Cell[errorMsg, "Print", FontWeight -> Bold,
          FontColor -> RGBColor[0.8, 0, 0], FontSize -> 11]]];
    (* \:6b8b\:308a\:306e\:672a\:66f8\:304d\:8fbc\:307f\:30b9\:30ed\:30c3\:30c8\:3068\:30a2\:30f3\:30ab\:30fc\:3092\:524a\:9664 *)
    NBAccess`NBEndJob[jobId];
  ];



(* ============================================================
   \:5206\:96e2API\:5b9f\:88c5: claudecode \:304c CellObject/Private \:306b\:76f4\:63a5\:89e6\:3089\:306a\:3044\:305f\:3081\:306e\:516c\:958bAPI
   ============================================================ *)

(* EvaluationCell \:3092\:5185\:90e8\:53d6\:5f97\:3057\:3066 Job \:3092\:958b\:59cb\:3059\:308b *)
NBAccess`NBBeginJobAtEvalCell[nb_NotebookObject] :=
  Module[{evalCell},
    evalCell = Quiet[EvaluationCell[]];
    NBAccess`NBBeginJob[nb, evalCell]
  ];

(* \:30c6\:30ad\:30b9\:30c8\:304b\:3089\:4ee3\:5165\:5909\:6570\:540d\:3092\:62bd\:51fa (Private`iExtractAssignments \:306e\:516c\:958b\:7248) *)
NBAccess`NBExtractAssignments[text_String] :=
  iExtractAssignments[text];

(* \:6a5f\:5bc6\:5909\:6570\:30c6\:30fc\:30d6\:30eb\:64cd\:4f5cAPI *)
NBAccess`NBSetConfidentialVars[assoc_Association] :=
  (NBAccess`$NBConfidentialSymbols = assoc);

NBAccess`NBGetConfidentialVars[] :=
  If[AssociationQ[NBAccess`$NBConfidentialSymbols],
    NBAccess`$NBConfidentialSymbols, <||>];

NBAccess`NBClearConfidentialVars[] :=
  (NBAccess`$NBConfidentialSymbols = <||>);

NBAccess`NBRegisterConfidentialVar[name_String, level_:1.0] :=
  (NBAccess`$NBConfidentialSymbols[name] = level);

NBAccess`NBUnregisterConfidentialVar[name_String] :=
  (NBAccess`$NBConfidentialSymbols = KeyDrop[NBAccess`$NBConfidentialSymbols, name]);

(* \:6a5f\:5bc6\:751f\:6210\:30d8\:30c3\:30c9\:8868: \:300c\:3053\:306e\:95a2\:6570\:306e\:8fd4\:308a\:5024\:306f\:6a5f\:5bc6\:305f\:308a\:5f97\:308b\:300d\:3068\:3044\:3046\:5ba3\:8a00\:30ec\:30b8\:30b9\:30c8\:30ea\:3002
   SourceVault \:7b49\:306e\:30c7\:30fc\:30bf\:5c64\:304c\:30ed\:30fc\:30c9\:6642\:306b\:767b\:9332\:3057\:3001claudecode \:304c
   (a) LLM \:751f\:6210\:30b3\:30fc\:30c9/\:5fdc\:7b54\:3092\:66f8\:304d\:8fbc\:3093\:3060\:65b0\:898f\:30bb\:30eb\:306e\:81ea\:52d5\:6a5f\:5bc6\:30de\:30fc\:30af\:5224\:5b9a\:3001
   (b) CellEpilog \:306e\:4f9d\:5b58\:79d8\:5bc6\:5224\:5b9a (snaps = SourceVaultSearch...[..] \:7b49)
   \:306b\:4f7f\:3046\:3002\:79d8\:5bc6\:300c\:5909\:6570\:300d\:30ec\:30b8\:30b9\:30c8\:30ea ($NBConfidentialSymbols) \:306e\:30d8\:30c3\:30c9\:7248\:3002 *)
NBAccess`NBRegisterConfidentialHead[name_String, level_:1.0] :=
  (If[!AssociationQ[NBAccess`$NBConfidentialHeads],
     NBAccess`$NBConfidentialHeads = <||>];
   NBAccess`$NBConfidentialHeads[name] = level);

NBAccess`NBUnregisterConfidentialHead[name_String] :=
  (NBAccess`$NBConfidentialHeads =
     KeyDrop[NBAccess`NBGetConfidentialHeads[], name]);

NBAccess`NBGetConfidentialHeads[] :=
  If[AssociationQ[NBAccess`$NBConfidentialHeads],
    NBAccess`$NBConfidentialHeads, <||>];

(* text \:304c\:767b\:9332\:30d8\:30c3\:30c9\:3092\:53c2\:7167\:3057\:3066\:3044\:308b\:304b\:3002\:8b58\:5225\:5b50\:5883\:754c (Unicode) \:3067\:8aa4\:30de\:30c3\:30c1\:3092\:9632\:3050\:3002
   Map[head, ...] \:306e\:3088\:3046\:306a\:95a2\:6570\:5024\:6e21\:3057\:3082\:691c\:51fa\:3059\:308b\:305f\:3081 "[" \:306f\:8981\:6c42\:3057\:306a\:3044\:3002 *)
NBAccess`NBTextUsesConfidentialHead[text_String] :=
  Module[{heads = Keys[NBAccess`NBGetConfidentialHeads[]]},
    heads =!= {} && AnyTrue[heads,
      StringContainsQ[text,
        RegularExpression[
          "(?<![\\p{L}\\p{N}$])" <> # <> "(?![\\p{L}\\p{N}$])"]] &]];
NBAccess`NBTextUsesConfidentialHead[_] := False;

NBAccess`NBGetPrivacySpec[] :=
  If[AssociationQ[NBAccess`$NBPrivacySpec],
    NBAccess`$NBPrivacySpec, <|"AccessLevel" -> 0.5|>];

(* CellEpilog \:7ba1\:7406 *)
NBAccess`NBInstallCellEpilog[nb_NotebookObject, key_String, expr_] :=
  Module[{current},
    current = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    If[FreeQ[current, key],
      Quiet[SetOptions[nb, CellEpilog :> expr]]]];

NBAccess`NBCellEpilogInstalledQ[nb_NotebookObject, key_String] :=
  Module[{epi},
    epi = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    !FreeQ[epi, key]];

(* \:30bb\:30eb\:8a55\:4fa1\:30d8\:30eb\:30d1\:30fc: AutoEvaluate \:7981\:6b62\:64cd\:4f5c\:30ac\:30fc\:30c9\:4ed8\:304d
   $NBAutoEvalProhibitedPatterns \:306b\:30de\:30c3\:30c1\:3059\:308b\:30bb\:30eb\:306f\:8a55\:4fa1\:3092\:30b9\:30ad\:30c3\:30d7\:3057\:8b66\:544a\:3092\:8868\:793a\:3059\:308b\:3002
   \:3053\:308c\:306f\:5168 AutoEvaluate \:30d1\:30b9\:306e\:6700\:7d42\:9632\:885b\:7dda\:3067\:3042\:308a\:3001\:30d0\:30a4\:30d1\:30b9\:4e0d\:53ef\:80fd\:3002 *)
NBAccess`NBEvaluatePreviousCell[nb_NotebookObject] :=
  Module[{cellExpr, cellText, prohibited = False},
    Quiet[SelectionMove[nb, Previous, Cell]];
    (* \:7981\:6b62\:30d1\:30bf\:30fc\:30f3\:30c1\:30a7\:30c3\:30af *)
    If[ListQ[NBAccess`$NBAutoEvalProhibitedPatterns] &&
       Length[NBAccess`$NBAutoEvalProhibitedPatterns] > 0,
      cellExpr = Quiet[NotebookRead[nb]];
      cellText = Which[
        MatchQ[cellExpr, Cell[BoxData[_], ___]],
          Quiet @ Check[NBAccess`NBCellExprToText[cellExpr], ""],
        MatchQ[cellExpr, Cell[s_String, ___]],
          First[cellExpr],
        True, ""];
      If[StringQ[cellText] && StringLength[cellText] > 0,
        prohibited = AnyTrue[NBAccess`$NBAutoEvalProhibitedPatterns,
          StringContainsQ[cellText, #] &]]];
    If[prohibited,
      (* \:7981\:6b62\:64cd\:4f5c\:691c\:51fa: \:8a55\:4fa1\:3092\:30b9\:30ad\:30c3\:30d7\:3057\:3066\:8b66\:544a\:3092\:8868\:793a *)
      Quiet[SelectionMove[nb, After, Cell]];
      NBAccess`NBWritePrintNotice[nb,
        "\:26d4 \:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:4fdd\:8b77: \:4e0a\:306e\:30bb\:30eb\:306f\:30a2\:30af\:30bb\:30b9\:7bc4\:56f2\:3092\:5909\:66f4\:3059\:308b\:64cd\:4f5c\:3092\:542b\:3080\:305f\:3081\:81ea\:52d5\:5b9f\:884c\:3092\:30d6\:30ed\:30c3\:30af\:3057\:307e\:3057\:305f\:3002\:5185\:5bb9\:3092\:78ba\:8a8d\:3057\:3066\:304b\:3089 Shift+Enter \:3067\:624b\:52d5\:5b9f\:884c\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
        RGBColor[0.8, 0, 0]],
      (* \:901a\:5e38: \:8a55\:4fa1\:5b9f\:884c *)
      Quiet[SelectionEvaluate[nb]];
      Quiet[SelectionMove[nb, After, Cell]]]];

(* Input \:30c6\:30f3\:30d7\:30ec\:30fc\:30c8\:633f\:5165 *)
NBAccess`NBInsertInputTemplate[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], All];
  SelectionMove[nb, All, CellContents]);

(* EvaluationCell \:306e\:89aa\:30ce\:30fc\:30c8\:30d6\:30c3\:30af *)
NBAccess`NBParentNotebookOfCurrentCell[] :=
  Quiet @ Check[ParentNotebook[EvaluationCell[]], InputNotebook[]];


(* ============================================================
   \:5206\:96e2API\:8ffd\:52a0\:5b9f\:88c5: \:30bb\:30eb\:66f8\:304d\:8fbc\:307f\:30fb\:30c6\:30f3\:30d7\:30ec\:30fc\:30c8\:30fbCellEpilog
   ============================================================ *)

(* \:6c4e\:7528\:30bb\:30eb\:66f8\:304d\:8fbc\:307f *)
(* ============================================================
   \:51fa\:529b\:9045\:5ef6\:30d0\:30c3\:30d5\:30a1 (\:5bfe\:7b562 \:6bb5\:968e2, 2026-06-03)
   ============================================================
   $iNBDeferActive \:304c True \:306e\:3068\:304d\:3001NBWriteCell \:306f notebook \:3078\:5373\:66f8\:304d\:8fbc\:307f\:305b\:305a
   $iNBDeferredCells \:306b\:6e9c\:3081\:308b\:3002\:6700\:5f8c\:306b NBFlushDeferredOutput[nb] \:3067\:4e00\:62ec\:51fa\:529b\:3002
   \:65e2\:5b9a $iNBDeferActive=False \:3067\:306f NBWriteCell \:306f\:5b8c\:5168\:306b\:5f93\:6765\:901a\:308a (\:5f8c\:65b9\:4e92\:63db)\:3002

   \:6709\:52b9\:5316/\:7121\:52b9\:5316\:306f\:547c\:3073\:51fa\:3057\:5074 (Orchestrator \:4e26\:5217\:30ef\:30fc\:30ab\:30fc\:96c6\:7d04\:3084\:3001\:30de\:30eb\:30c1\:30bf\:30fc\:30f3\:306e
   \:30d0\:30c3\:30c1\:533a\:9593) \:304c NBBeginDeferredOutput / NBEndDeferredOutput \:3067\:660e\:793a\:5236\:5fa1\:3059\:308b\:3002
   $ClaudeOutputMode \:306f\:300c\:65e2\:5b9a\:306e\:5e0c\:671b\:30e2\:30fc\:30c9\:300d\:3067\:3001\:5b9f\:969b\:306b\:30d0\:30c3\:30d5\:30a1\:3059\:308b\:304b\:306f
   NBResolveOutputMode \:306e\:5224\:5b9a + \:547c\:3073\:51fa\:3057\:5074\:306e\:5236\:5fa1\:306b\:3088\:308b\:3002

   \:7f60 #30: \:30d0\:30c3\:30d5\:30a1\:3078\:306e\:8ffd\:52a0\:306f\:5909\:6570\:64cd\:4f5c\:306a\:306e\:3067\:8a55\:4fa1\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:4e0d\:554f (scheduled
   task \:3067\:3082\:5b89\:5168)\:3002\:305f\:3060\:3057 NBFlushDeferredOutput (NotebookWrite) \:306f FrontEnd
   \:64cd\:4f5c\:306a\:306e\:3067\:30e1\:30a4\:30f3\:30ab\:30fc\:30cd\:30eb\:8a55\:4fa1\:3067\:547c\:3076\:3053\:3068\:3002 *)
If[!BooleanQ[$iNBDeferActive], $iNBDeferActive = False];
If[!ListQ[$iNBDeferredCells], $iNBDeferredCells = {}];

NBAccess`NBBeginDeferredOutput[] := ($iNBDeferActive = True;);
NBAccess`NBEndDeferredOutput[] := ($iNBDeferActive = False;);
NBAccess`NBDeferredOutputActiveQ[] := TrueQ[$iNBDeferActive];
NBAccess`NBDeferredOutputCount[] := Length[$iNBDeferredCells];

(* \:6e9c\:3081\:305f Cell \:3092\:4e00\:62ec\:66f8\:304d\:8fbc\:307f\:3057\:3066\:30d0\:30c3\:30d5\:30a1\:3092\:30af\:30ea\:30a2\:3059\:308b\:3002\:30e1\:30a4\:30f3\:8a55\:4fa1\:3067\:547c\:3076\:3053\:3068\:3002 *)
NBAccess`NBFlushDeferredOutput[nb_NotebookObject] :=
  Module[{cells},
    cells = $iNBDeferredCells;
    $iNBDeferredCells = {};
    If[Length[cells] > 0,
      Quiet[NotebookWrite[nb, cells, After]]];
    Length[cells]];
NBAccess`NBFlushDeferredOutput[] :=
  Module[{cells},
    cells = $iNBDeferredCells;
    $iNBDeferredCells = {};
    If[Length[cells] > 0,
      Quiet[CellPrint[cells]]];
    Length[cells]];

(* \:30d0\:30c3\:30d5\:30a1\:3092\:7834\:68c4 (\:30d5\:30e9\:30c3\:30b7\:30e5\:305b\:305a\:6368\:3066\:308b)\:3002 *)
NBAccess`NBDiscardDeferredOutput[] := ($iNBDeferredCells = {};);

NBAccess`NBWriteCell[nb_NotebookObject, cellExpr_Cell, where_:After] :=
  If[TrueQ[$iNBDeferActive],
    (* Batch/Deferred: \:30d0\:30c3\:30d5\:30a1\:306b\:6e9c\:3081\:308b (NotebookWrite \:3057\:306a\:3044)\:3002
       where \:304c After \:4ee5\:5916 (\:4f4d\:7f6e\:6307\:5b9a) \:306e\:5834\:5408\:306f\:9045\:5ef6\:306b\:4e57\:305b\:305a\:5373\:66f8\:304d\:8fbc\:307f\:3059\:308b
       (\:4f4d\:7f6e\:4f9d\:5b58\:306e\:633f\:5165\:306f\:30d0\:30c3\:30d5\:30a1\:9806\:5e8f\:3068\:6574\:5408\:3057\:306a\:3044\:305f\:3081)\:3002 *)
    If[where === After,
      AppendTo[$iNBDeferredCells, cellExpr]; Null,
      Quiet[NotebookWrite[nb, cellExpr, where]]],
    (* Streaming/Immediate: \:5f93\:6765\:901a\:308a\:5373\:66f8\:304d\:8fbc\:307f *)
    Quiet[NotebookWrite[nb, cellExpr, where]]];

(* \:901a\:77e5\:7528 Print \:30bb\:30eb\:66f8\:304d\:8fbc\:307f
   CellTags "claudecode-notice" \:3092\:4ed8\:4e0e\:3057\:3066 NBScanDependentCells \:306e\:30de\:30fc\:30ad\:30f3\:30b0\:5bfe\:8c61\:5916\:306b\:3059\:308b *)
NBAccess`NBWritePrintNotice[None, text_String, color_] :=
  CellPrint[Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}]];
NBAccess`NBWritePrintNotice[nb_NotebookObject, text_String, color_] :=
  NotebookWrite[nb, Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}], After];

(* CellPrint \:30e9\:30c3\:30d1\:30fc: \:8a55\:4fa1\:30bb\:30eb\:306e\:76f4\:5f8c\:306b\:51fa\:529b\:30bb\:30eb\:3092\:633f\:5165\:3002
   NotebookWrite \:3068\:7570\:306a\:308a\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:4f9d\:5b58\:3057\:306a\:3044\:3002
   ClaudeBackupDataset \:7b49\:306e\:30bf\:30b0\:4ed8\:304d\:51fa\:529b\:30bb\:30eb\:306b\:4f7f\:7528\:3059\:308b\:3002 *)
NBAccess`NBCellPrint[cellExpr_Cell] :=
  Quiet[CellPrint[cellExpr]];

(* Dynamic \:30bb\:30eb\:66f8\:304d\:8fbc\:307f *)
NBAccess`NBWriteDynamicCell[nb_NotebookObject, dynBoxExpr_, tag_String:"", opts___] :=
  If[tag === "",
    NotebookWrite[nb, Cell[BoxData[dynBoxExpr], "Print", opts], After],
    NotebookWrite[nb, Cell[BoxData[dynBoxExpr], "Print", CellTags -> {tag}, opts], After]];

(* ExternalLanguage \:30bb\:30eb\:66f8\:304d\:8fbc\:307f *)
NBAccess`NBWriteExternalLanguageCell[nb_NotebookObject, code_String,
    lang_String, autoEvaluate_:False] := (
  NotebookWrite[nb,
    Cell[code, "ExternalLanguage", CellEvaluationLanguage -> lang], After];
  If[TrueQ[autoEvaluate],
    Quiet[SelectionMove[nb, Previous, Cell]];
    Quiet[SelectionEvaluate[nb]];
    Quiet[SelectionMove[nb, After, Cell]]]);

(* Input \:30bb\:30eb\:3092\:633f\:5165\:3057\:3066\:5373\:5ea7\:306b\:8a55\:4fa1 *)
NBAccess`NBInsertAndEvaluateInput[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  Quiet[SelectionEvaluate[nb]]);

(* Input \:30bb\:30eb\:3092 After \:306b\:66f8\:304d\:8fbc\:307f\:3001Before CellContents \:306b\:79fb\:52d5 *)
NBAccess`NBInsertInputAfter[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  SelectionMove[nb, Before, CellContents]);

(* \:30ab\:30fc\:30bd\:30eb\:5f8c\:306b Input \:30bb\:30eb\:3092\:633f\:5165\:3057\:3001\:30ab\:30fc\:30bd\:30eb\:914d\:7f6e + \:6761\:4ef6\:4ed8\:304d\:8a55\:4fa1 *)
NBAccess`NBWriteInputCellAndMaybeEvaluate[nb_NotebookObject, boxes_,
    autoEvaluate_:False] := (
  Quiet[SelectionMove[nb, After, Cell]];
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  Quiet[SelectionMove[nb, Previous, Cell]];
  Quiet[SelectionMove[nb, Before, CellContents]];
  SetSelectedNotebook[nb];
  If[TrueQ[autoEvaluate], Quiet[SelectionEvaluate[nb]]]);

(* EvaluationCell \:76f4\:5f8c\:306b\:4e0d\:53ef\:8996\:30a2\:30f3\:30ab\:30fc\:30bb\:30eb\:3092\:66f8\:304d\:8fbc\:3080 *)
NBAccess`NBWriteAnchorAfterEvalCell[nb_NotebookObject, tag_String] :=
  Module[{evalCell},
    evalCell = Quiet[EvaluationCell[]];
    If[Head[evalCell] === CellObject,
      Quiet[SelectionMove[evalCell, After, Cell, AutoScroll -> False]],
      Quiet[SelectionMove[nb, After, Notebook, AutoScroll -> False]]];
    NotebookWrite[nb,
      Cell["", "Text", CellTags -> {tag}, CellOpen -> False], After]];

(* \:6a5f\:5bc6\:8ffd\:8de1\:7528 CellEpilog \:30a4\:30f3\:30b9\:30c8\:30fc\:30eb (\:5c02\:7528API)
   epilogExpr: CellEpilog \:306b\:8a2d\:5b9a\:3059\:308b\:5f0f\:ff08HoldRest \:306b\:3088\:308a\:672a\:8a55\:4fa1\:3067\:53d7\:3051\:53d6\:308b\:ff09
   checkSymbol: FreeQ \:30c1\:30a7\:30c3\:30af\:7528\:306e\:30de\:30fc\:30ab\:30fc\:30b7\:30f3\:30dc\:30eb (\:4f8b: ClaudeCode`Private`iConfidentialCellEpilog) *)
SetAttributes[NBAccess`NBInstallConfidentialEpilog, HoldRest];
NBAccess`NBInstallConfidentialEpilog[nb_NotebookObject, epilogExpr_, checkSymbol_] :=
  Module[{current},
    current = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    If[FreeQ[current, checkSymbol],
      Quiet[SetOptions[nb, CellEpilog :> epilogExpr]]]];

NBAccess`NBConfidentialEpilogInstalledQ[nb_NotebookObject, checkSymbol_] :=
  Module[{epi},
    epi = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    !FreeQ[epi, checkSymbol]];


(* .nb \:30d5\:30a1\:30a4\:30eb\:3092\:958b\:3044\:3066\:30c6\:30ad\:30b9\:30c8\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b (\:30c6\:30f3\:30d7\:30ec\:30fc\:30c8\:521d\:671f\:5316\:7528) *)
NBAccess`NBInsertTextCells[nbFile_String, name_String, prompt_String] :=
  Module[{nb},
    nb = Quiet @ NotebookOpen[nbFile, Visible -> False];
    If[Head[nb] =!= NotebookObject, Return[$Failed]];
    SelectionMove[nb, After, Notebook];
    NotebookWrite[nb, Cell["Package: " <> name, "Subsection"]];
    NotebookWrite[nb, Cell[prompt, "Text"]];
    Quiet @ NotebookSave[nb];
    Quiet @ NotebookClose[nb]];


(* ============================================================
   \:30d5\:30a1\:30a4\:30eb\:578b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:64cd\:4f5c API
   \:9589\:3058\:305f .nb \:30d5\:30a1\:30a4\:30eb\:3092\:5bfe\:8c61\:3068\:3057\:305f\:3001PrivacySpec \:5bfe\:5fdc\:306e\:8aad\:307f\:66f8\:304d\:3002

   \:8a2d\:8a08\:539f\:5247:
     - \:4e0a\:4f4d\:5c64 (claudecode.wl \:7b49) \:306f .nb \:30d5\:30a1\:30a4\:30eb\:3092\:76f4\:63a5
       NotebookOpen/NotebookGet/Cells[] \:306a\:3069\:3067\:64cd\:4f5c\:3057\:3066\:306f\:306a\:3089\:306a\:3044\:3002
       \:5fc5\:305a\:672c API \:3092\:7d4c\:7531\:3059\:308b\:3053\:3068 (rules/10-nbaccess.md \:53c2\:7167)\:3002
     - \:30bb\:30eb\:306e\:79d8\:533f\:5c5e\:6027 (TaggingRules["claudecode"]["confidential"])
       \:306f\:8aad\:307f\:66f8\:304d\:6642\:306b\:5fc5\:305a\:4fdd\:6301\:30fb\:5c0a\:91cd\:3059\:308b\:3002
     - CellEpilog / CellDingbat \:7b49\:306e\:30de\:30fc\:30af\:5c5e\:6027\:306f\:4e00\:5207\:5909\:66f4\:3057\:306a\:3044\:3002
   ============================================================ *)

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileOpen: .nb \:30d5\:30a1\:30a4\:30eb\:3092\:975e\:8868\:793a\:3067\:958b\:304f
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
(* NBFileOpen \:304c\:300c\:81ea\:5206\:3067\:958b\:3044\:305f\:300dnotebook \:306e\:767b\:9332\:7c3f\:3002NBFileClose \:306f\:3053\:308c\:306b
   \:5165\:3063\:3066\:3044\:308b\:3082\:306e\:3060\:3051\:3092\:9589\:3058\:308b\:3002\:65e2\:306b\:5229\:7528\:8005\:304c\:958b\:3044\:3066\:3044\:305f\:30a6\:30a4\:30f3\:30c9\:30a6\:3092
   NotebookClose \:3067\:6d88\:3057\:3066\:3057\:307e\:3046\:4e8b\:6545\:3092\:9632\:3050\:3002 *)
If[! ListQ[$iNBFileOpenedByUs], $iNBFileOpenedByUs = {}];

NBAccess`NBFileOpen[path_String] :=
  Module[{nb, abs, already},
    If[!FileExistsQ[path],
      Message[NBAccess`NBFileOpen::notfound, path]; Return[$Failed]];
    abs = ExpandFileName[path];
    (* \:65e2\:306b\:958b\:3044\:3066\:3044\:308b\:30a6\:30a4\:30f3\:30c9\:30a6 (\:5229\:7528\:8005\:306e\:4f5c\:696d\:4e2d\:30a6\:30a4\:30f3\:30c9\:30a6\:7b49) \:304c\:3042\:308c\:3070\:3001\:305d\:308c\:3092\:8fd4\:3059\:304c
       \:300c\:81ea\:5206\:3067\:958b\:3044\:305f\:300d\:767b\:9332\:306f\:3057\:306a\:3044\:3002NotebookOpen[..., Visible->False] \:306f\:65e2\:958b\:304d\:306e
       \:30a6\:30a4\:30f3\:30c9\:30a6\:306b\:306f\:7121\:52b9\:3067\:3001\:305d\:306e\:307e\:307e\:9589\:3058\:308b\:3068\:5229\:7528\:8005\:306e\:30a6\:30a4\:30f3\:30c9\:30a6\:304c\:6d88\:3048\:308b\:305f\:3081\:3002 *)
    already = SelectFirst[Quiet@Check[Notebooks[], {}],
      Function[w,
        Module[{fn = Quiet@Check[NotebookFileName[w], $Failed]},
          StringQ[fn] && ExpandFileName[fn] === abs]], None];
    If[Head[already] === NotebookObject, Return[already]];
    nb = Quiet @ NotebookOpen[path, Visible -> False];
    If[Head[nb] =!= NotebookObject,
      Message[NBAccess`NBFileOpen::openfail, path]; Return[$Failed]];
    $iNBFileOpenedByUs = Append[$iNBFileOpenedByUs, nb];
    nb
  ];
NBAccess`NBFileOpen::notfound = "\:30d5\:30a1\:30a4\:30eb\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: `1`";
NBAccess`NBFileOpen::openfail  = "\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:958b\:3051\:307e\:305b\:3093\:3067\:3057\:305f: `1`";

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileClose: \:958b\:3044\:305f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:9589\:3058\:308b
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileClose[nb_NotebookObject] :=
  (* \:81ea\:5206\:3067\:958b\:3044\:305f notebook \:306e\:307f\:9589\:3058\:308b\:3002\:65e2\:306b\:958b\:3044\:3066\:3044\:305f\:5229\:7528\:8005\:30a6\:30a4\:30f3\:30c9\:30a6\:306f\:9589\:3058\:306a\:3044
     (NBFileOpen \:304c\:767b\:9332\:3057\:3066\:3044\:306a\:3044 = \:65e2\:958b\:304d) \:3053\:3068\:3067\:3001\:8a55\:4fa1\:4e2d\:30a6\:30a4\:30f3\:30c9\:30a6\:304c\:7a81\:7136\:9589\:3058\:308b
     \:4e8b\:6545\:3092\:9632\:3050\:3002 *)
  If[MemberQ[$iNBFileOpenedByUs, nb],
    $iNBFileOpenedByUs = DeleteCases[$iNBFileOpenedByUs, nb];
    Quiet @ NotebookClose[nb],
    Null];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileSave: \:6307\:5b9a\:30d1\:30b9\:306b\:4fdd\:5b58 (path=None \:306a\:3089\:4e0a\:66f8\:304d)
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileSave[nb_NotebookObject, path_: None] :=
  If[path === None,
    Quiet @ NotebookSave[nb],
    Quiet @ NotebookSave[nb, path]
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   \:5185\:90e8\:30d8\:30eb\:30d1\:30fc: Cell \:5f0f\:304b\:3089\:30b9\:30bf\:30a4\:30eb\:30fb\:79d8\:533f\:30d5\:30e9\:30b0\:30fb\:30c6\:30ad\:30b9\:30c8\:3092\:53d6\:5f97
   (\:958b\:3044\:3066\:3044\:308b nb \:3092\:5fc5\:8981\:3068\:305b\:305a Cell \:5f0f\:3060\:3051\:3067\:52d5\:4f5c\:3059\:308b\:305f\:3081
    FrontEnd \:3078\:306e\:30e9\:30a6\:30f3\:30c9\:30c8\:30ea\:30c3\:30d7\:304c\:4e0d\:8981)
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
iNBFileCellGetTaggingRules[cellExpr_] :=
  Quiet @ Replace[cellExpr,
    {Cell[_, _, rest___] :>
       (TaggingRules /. {rest} /. TaggingRules -> {}),
     Cell[_, rest___] :>
       (TaggingRules /. {rest} /. TaggingRules -> {}),
     _ :> {}}];

iNBFileCellGetClaudeCodeCC[cellExpr_] :=
  Module[{tr = iNBFileCellGetTaggingRules[cellExpr], cc},
    If[!ListQ[tr] && !AssociationQ[tr], Return[{}]];
    cc = Quiet @ Lookup[tr, "claudecode", {}];
    If[!ListQ[cc] && !AssociationQ[cc], {}, cc]
  ];

iNBFileCellIsConfidential[cellExpr_] :=
  Module[{cc = iNBFileCellGetClaudeCodeCC[cellExpr]},
    If[!ListQ[cc] && !AssociationQ[cc], False,
      TrueQ[Quiet @ Lookup[cc, "confidential", False]]]];

iNBFileCellPrivacyLevel[cellExpr_] :=
  Module[{cc = iNBFileCellGetClaudeCodeCC[cellExpr]},
    If[!ListQ[cc] && !AssociationQ[cc], Return[0.0]];
    Which[
      TrueQ[Quiet @ Lookup[cc, "confidential", False]], 1.0,
      TrueQ[Quiet @ Lookup[cc, "dependent", False]],    0.75,
      True,                                              0.0
    ]
  ];

iNBFileCellStyle[cellExpr_] :=
  Replace[cellExpr,
    {Cell[_, style_String, ___] :> style,
     _                          :> ""}];

(* Cell \:5f0f\:304b\:3089\:5e73\:6587\:30c6\:30ad\:30b9\:30c8\:3092\:62bd\:51fa *)
iNBFileCellText[cellExpr_] :=
  Module[{content},
    content = Replace[cellExpr,
      {Cell[BoxData[bd_],   ___] :> bd,
       Cell[str_String,     ___] :> str,
       Cell[TextData[td_],  ___] :> td,
       Cell[RawBoxes[rb_],  ___] :> rb,
       _                         :> ""}];
    StringTrim @ StringJoin @
      Riffle[Cases[content, tok_String /; StringLength[tok] > 0, {0, Infinity}], " "]
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileReadCells: \:5168\:30bb\:30eb\:3092 PrivacySpec \:30d5\:30a3\:30eb\:30bf\:4ed8\:304d\:3067\:8aad\:3080
   \:623b\:308a\:5024:
     { <|"CellIdx"->i, "Style"->s, "Text"->t,
          "PrivacyLevel"->p, "IsConfidential"->b,
          "CellExpr"->cell|>, ... }
   PrivacyLevel > accessLevel \:306e\:79d8\:533f\:30bb\:30eb\:306e Text \:306f "[CONFIDENTIAL]" \:306b\:7f6e\:63db\:3002
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
Options[NBAccess`NBFileReadCells] = {PrivacySpec -> Automatic};
NBAccess`NBFileReadCells[nb_NotebookObject, opts:OptionsPattern[]] :=
  Module[{n, accessLevel, result},
    n = NBAccess`NBCellCount[nb];
    If[n === 0, Return[{}]];
    accessLevel = iAccessLevel[OptionValue[PrivacySpec]];
    result = Table[
      Module[{cellObj, cellExpr, privLvl, style, text, isConf},
        cellObj  = iResolveCell[nb, i];
        If[cellObj === $Failed, Nothing,
          cellExpr = Quiet @ NotebookRead[cellObj];
          isConf   = iNBFileCellIsConfidential[cellExpr];
          privLvl  = iNBFileCellPrivacyLevel[cellExpr];
          style    = iNBFileCellStyle[cellExpr];
          text     = If[privLvl <= accessLevel,
            iNBFileCellText[cellExpr],
            "[CONFIDENTIAL]"];
          <|"CellIdx"        -> i,
            "Style"          -> style,
            "Text"           -> text,
            "PrivacyLevel"   -> privLvl,
            "IsConfidential" -> isConf,
            "CellExpr"       -> cellExpr
          |>]],
      {i, n}];
    Select[result, AssociationQ]
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileReadAllCells: \:79d8\:533f\:30bb\:30eb\:3082\:542b\:3081\:5168\:30bb\:30eb\:3092\:305d\:306e\:307e\:307e\:8fd4\:3059
   (\:30ed\:30fc\:30ab\:30eb\:30e2\:30c7\:30eb / PrivacySpec=1.0 \:7528\:9014)
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileReadAllCells[nb_NotebookObject] :=
  NBAccess`NBFileReadCells[nb,
    PrivacySpec -> <|"AccessLevel" -> 1.0|>];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileWriteCell: \:6307\:5b9a\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:3092\:7f6e\:304d\:63db\:3048\:308b
   \:30b9\:30bf\:30a4\:30eb\:30fbTaggingRules\:30fbCellEpilog\:30fbCellDingbat \:7b49\:306e\:5c5e\:6027\:306f
   \:3059\:3079\:3066\:305d\:306e\:307e\:307e\:4fdd\:6301\:3057\:3001\:30c6\:30ad\:30b9\:30c8\:90e8\:5206\:306e\:307f\:3092\:5dee\:3057\:66ff\:3048\:308b\:3002
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileWriteCell[nb_NotebookObject, cellIdx_Integer,
                          newText_String] :=
  Module[{cellObj, cellExpr, newCellExpr},
    cellObj  = iResolveCell[nb, cellIdx];
    If[cellObj === $Failed, Return[$Failed]];
    cellExpr = Quiet @ NotebookRead[cellObj];
    (* \:30c6\:30ad\:30b9\:30c8\:90e8\:5206\:306e\:307f\:7f6e\:63db\:3001\:4ed6\:306e\:5168\:30aa\:30d7\:30b7\:30e7\:30f3\:30fb\:5c5e\:6027\:306f\:305d\:306e\:307e\:307e *)
    newCellExpr = Replace[cellExpr,
      {Cell[_String,    rest___] :> Cell[newText, rest],
       Cell[TextData[_],rest___] :> Cell[newText, rest],
       Cell[BoxData[_], rest___] :> Cell[newText, rest],
       other_                    :> other}];
    NotebookWrite[cellObj, newCellExpr];
    cellIdx
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileWriteAllCells: \:8907\:6570\:30bb\:30eb\:3092\:4e00\:62ec\:7f6e\:63db
   replacements: <|cellIdx -> newText, ...|> \:307e\:305f\:306f
                 {{cellIdx, newText}, ...}
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileWriteAllCells[nb_NotebookObject,
                              replacements_Association] :=
  KeyValueMap[
    Function[{idx, txt},
      NBAccess`NBFileWriteCell[nb, idx, txt]],
    replacements];

NBAccess`NBFileWriteAllCells[nb_NotebookObject,
                              replacements_List] :=
  Scan[
    Function[pair,
      NBAccess`NBFileWriteCell[nb, pair[[1]], pair[[2]]]],
    replacements];


(* ============================================================
   \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb / \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb API
   ============================================================ *)

(* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:30ea\:30b9\:30c8\:7ba1\:7406 *)
NBAccess`NBSetFallbackModels[models_List] :=
  ($iFallbackModels = models);

NBAccess`NBGetFallbackModels[] :=
  If[ListQ[$iFallbackModels], $iFallbackModels, {}];


(* ============================================================
   \:4fe1\:983c\:3067\:304d\:308b\:30ed\:30fc\:30ab\:30eb LLM \:30b5\:30fc\:30d0\:306e\:89e3\:6c7a (\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:5883\:754c)

   IP / \:30b5\:30d6\:30cd\:30c3\:30c8\:306e\:5224\:5b9a\:306f\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:306b\:76f4\:7d50\:3059\:308b\:306e\:3067 NBAccess \:304c
   \:7ba1\:7406\:3059\:308b\:3002\:4fe1\:983c\:30ea\:30b9\:30c8\:306f {MachineName, Subnet, Provider, URL} \:306e
   \:7d44\:3067\:3001IP \[Times] \:30b5\:30d6\:30cd\:30c3\:30c8\:306f\:30cf\:30fc\:30c9\:30b3\:30fc\:30c9\:53ef (\:6ec5\:591a\:306b\:5909\:308f\:3089\:306a\:3044)\:3002
   \:305d\:306e\:4e0a\:3067\:52d5\:304f\:30e2\:30c7\:30eb\:540d (Qwen \:306e\:679d\:756a\:7b49) \:306f\:542b\:3081\:306a\:3044\:3002\:30e2\:30c7\:30eb\:306f
   SourceVault \:304c intent \:89e3\:6c7a\:3067\:6271\:3046\:3002

   \:672a\:77e5\:306e\:30b5\:30d6\:30cd\:30c3\:30c8\:3067\:306f\:5b89\:5168\:5074\:306b\:5012\:3057\:3001localhost \:306e\:307f\:3092\:8fd4\:3059\:3002
   ============================================================ *)

(* \:30c7\:30d5\:30a9\:30eb\:30c8\:4fe1\:983c\:30b5\:30fc\:30d0 (\:8d77\:52d5\:30d5\:30a1\:30a4\:30eb\:304b\:3089 NBRegisterTrustedLocalServer \:3067
   \:8ffd\:52a0\:30fb\:4e0a\:66f8\:304d\:3067\:304d\:308b)\:3002\:7a7a\:3067\:521d\:671f\:5316\:3057\:3001\:30e6\:30fc\:30b6\:30fc\:304c\:767b\:9332\:3059\:308b\:65b9\:5f0f (Q3=(a))\:3002 *)
If[!ListQ[$iTrustedLocalServers],
  $iTrustedLocalServers = {}];

NBAccess`NBRegisterTrustedLocalServer[assoc_Association] :=
  Module[{entry},
    entry = <|
      "MachineName" -> Lookup[assoc, "MachineName", All],
      "Subnet"      -> Lookup[assoc, "Subnet", All],
      "Provider"    -> Lookup[assoc, "Provider", "lmstudio"],
      "URL"         -> Lookup[assoc, "URL", ""]|>;
    (* \:540c\:4e00 {MachineName, Subnet, URL} \:306f\:7f6e\:304d\:63db\:3048\:308b *)
    $iTrustedLocalServers = Append[
      Select[$iTrustedLocalServers,
        !(Lookup[#, "MachineName", All] === entry["MachineName"] &&
          Lookup[#, "Subnet", All] === entry["Subnet"] &&
          Lookup[#, "URL", ""] === entry["URL"]) &],
      entry];
    entry];
NBAccess`NBRegisterTrustedLocalServer[___] :=
  <|"Status" -> "Failed", "Reason" -> "InvalidArguments"|>;

NBAccess`NBTrustedLocalServers[] :=
  If[$iTrustedLocalServers === {},
    Dataset[{}],
    Dataset[$iTrustedLocalServers]];

(* \:81ea\:30de\:30b7\:30f3\:306e IP \:30a2\:30c9\:30ec\:30b9\:4e00\:89a7\:3092\:53d6\:5f97\:3059\:308b\:3002$MachineAddresses \:304c\:4f7f\:3048\:308b
   \:74b0\:5883\:3067\:306f\:305d\:308c\:3092\:3001\:7121\:3051\:308c\:3070 SystemInformation \:304b\:3089\:62fe\:3046\:3002\:5931\:6557\:6642\:306f {}\:3002 *)
iNBMachineIPAddresses[] :=
  Module[{addrs},
    addrs = Quiet @ Check[
      Which[
        ValueQ[$MachineAddresses] && ListQ[$MachineAddresses],
          $MachineAddresses,
        True,
          (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: \:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:60c5\:5831\:304b\:3089 IPv4 \:3092\:62fe\:3046 *)
          Cases[
            Flatten[{
              Quiet @ SystemInformation["Network", "IPAddresses"]}],
            _String]],
      {}];
    If[!ListQ[addrs], addrs = {}];
    Select[addrs, StringQ]];

(* IP \:6587\:5b57\:5217\:304c subnet \:30d7\:30ec\:30d5\:30a3\:30c3\:30af\:30b9 (\:4f8b "192.168.2") \:306b\:5c5e\:3059\:308b\:304b *)
iNBIPInSubnet[ip_String, subnet_String] :=
  StringStartsQ[ip, subnet <> "."] || ip === subnet;
iNBIPInSubnet[_, _] := False;

(* URL \:304c localhost / 127.0.0.1 \:3092\:6307\:3059\:304b *)
iNBIsLocalhostURL[url_String] :=
  StringContainsQ[url, "127.0.0.1"] ||
  StringContainsQ[url, "localhost"] ||
  StringContainsQ[url, "[::1]"];
iNBIsLocalhostURL[_] := False;

NBAccess`NBResolveLocalServer[] :=
  Module[{machine, ips, matched, localhostEntry},
    machine = Quiet @ Check[$MachineName, ""];
    If[!StringQ[machine], machine = ""];
    ips = iNBMachineIPAddresses[];

    (* (1) \:30de\:30b7\:30f3\:540d\:3068\:30b5\:30d6\:30cd\:30c3\:30c8\:306e\:4e21\:65b9 (\:307e\:305f\:306f All) \:3067\:30de\:30c3\:30c1\:3059\:308b
       \:4fe1\:983c\:30b5\:30fc\:30d0\:3092\:63a2\:3059\:3002\:30b5\:30d6\:30cd\:30c3\:30c8\:304c All \:3067\:306a\:3051\:308c\:3070\:81ea IP \:306e\:3044\:305a\:308c\:304b\:304c
       \:305d\:306e\:30b5\:30d6\:30cd\:30c3\:30c8\:306b\:5c5e\:3059\:308b\:3053\:3068\:3092\:8981\:6c42\:3059\:308b\:3002 *)
    matched = Select[$iTrustedLocalServers,
      Function[srv,
        Module[{mn, sn, url, mnOK, snOK},
          mn = Lookup[srv, "MachineName", All];
          sn = Lookup[srv, "Subnet", All];
          url = Lookup[srv, "URL", ""];
          mnOK = (mn === All) || (StringQ[mn] && mn === machine);
          snOK = (sn === All) ||
            (StringQ[sn] &&
             (iNBIsLocalhostURL[url] ||
              AnyTrue[ips, iNBIPInSubnet[#, sn] &]));
          mnOK && snOK]]];

    (* (2) \:30de\:30c3\:30c1\:3057\:305f\:4e2d\:3067\:3001\:30ea\:30e2\:30fc\:30c8 URL \:306f\:4fe1\:983c\:30b5\:30d6\:30cd\:30c3\:30c8\:78ba\:8a8d\:6e08\:307f\:306e\:3082\:306e
       \:3060\:3051\:3092\:8a31\:53ef\:3002localhost URL \:306f\:5e38\:306b\:8a31\:53ef\:3002\:512a\:5148\:9806\:4f4d: \:3088\:308a\:5177\:4f53\:7684\:306a
       (MachineName \:6307\:5b9a\:3042\:308a > Subnet \:6307\:5b9a\:3042\:308a > All) \:3092\:5148\:306b\:3002 *)
    matched = SortBy[matched,
      Function[srv,
        {If[Lookup[srv, "MachineName", All] === All, 1, 0],
         If[Lookup[srv, "Subnet", All] === All, 1, 0]}]];

    If[matched =!= {},
      Return[Module[{best = First[matched]},
        <|"Provider" -> Lookup[best, "Provider", "lmstudio"],
          "URL" -> Lookup[best, "URL", ""],
          "Trusted" -> True,
          "MatchedBy" -> <|
            "MachineName" -> Lookup[best, "MachineName", All],
            "Subnet" -> Lookup[best, "Subnet", All]|>,
          "Machine" -> machine|>]]];

    (* (3) \:30de\:30c3\:30c1\:7121\:3057 = \:672a\:77e5\:30b5\:30d6\:30cd\:30c3\:30c8\:3002\:5b89\:5168\:5074: localhost \:306e\:307f\:3002
       \:4fe1\:983c\:30ea\:30b9\:30c8\:306b localhost \:30a8\:30f3\:30c8\:30ea\:304c\:3042\:308c\:3070\:305d\:308c\:3092\:3001\:7121\:3051\:308c\:3070
       \:65e2\:5b9a\:306e 127.0.0.1:1234 \:3092\:8fd4\:3059\:3002 *)
    localhostEntry = SelectFirst[$iTrustedLocalServers,
      iNBIsLocalhostURL[Lookup[#, "URL", ""]] &, None];
    If[localhostEntry =!= None,
      Return[<|"Provider" -> Lookup[localhostEntry, "Provider", "lmstudio"],
        "URL" -> Lookup[localhostEntry, "URL", "http://127.0.0.1:1234"],
        "Trusted" -> True, "MatchedBy" -> "localhost-fallback",
        "Machine" -> machine|>]];
    <|"Provider" -> "lmstudio",
      "URL" -> "http://127.0.0.1:1234",
      "Trusted" -> False,
      "MatchedBy" -> "default-localhost",
      "Machine" -> machine,
      "Note" -> "unknown subnet; restricted to localhost for safety"|>
  ];



(* ============================================================
   NBSyncClaudeModelVars: SourceVault \:30ad\:30e3\:30c3\:30b7\:30e5\:306e\:30e2\:30c7\:30eb\:3067
   ClaudeCode \:306e\:30e2\:30c7\:30eb\:5909\:6570\:3092\:66f4\:65b0\:3059\:308b\:3002

   \:8cac\:52d9\:5206\:96e2:
   - intent \:5272\:308a\:5f53\:3066\:30de\:30c3\:30d7 ($ClaudeModel -> {provider, intent} \:7b49) \:306f
     SourceVault \:304c\:4fdd\:6301\:3057\:3001SourceVault`SourceVaultModelIntentMap[] \:3067\:8aad\:3080\:3002
   - \:5404 intent \:3092 SourceVault`SourceVaultResolve \:3067\:30e2\:30c7\:30eb ID \:306b\:89e3\:6c7a\:3002
   - \:30ed\:30fc\:30ab\:30eb\:30b5\:30fc\:30d0\:306e URL \:306f NBResolveLocalServer \:3067\:5b89\:5168\:306b\:89e3\:6c7a
     (\:672a\:77e5\:30b5\:30d6\:30cd\:30c3\:30c8\:306f localhost \:306e\:307f)\:3002
   - \:3053\:308c\:3089\:3092\:5408\:6210\:3057\:3066 ClaudeCode \:306e\:5b9f\:5909\:6570\:306b\:4ee3\:5165\:3059\:308b\:3002

   \:30e2\:30c7\:30eb\:5909\:6570\:306e\:4ee3\:5165\:306f\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:60c5\:5831 ($ClaudePrivateModel \:306e URL) \:3092
   \:542b\:3080\:305f\:3081\:3001\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:5883\:754c\:3092\:7ba1\:7406\:3059\:308b NBAccess \:306b\:4e00\:5143\:5316\:3059\:308b\:3002
   SourceVault \:304c\:672a\:30ed\:30fc\:30c9\:306a\:3089\:4f55\:3082\:3057\:306a\:3044 (claudecode \:5358\:4f53\:306e\:5f8c\:65b9\:4e92\:63db)\:3002
   ============================================================ *)

(* spec {provider, intent} \:3092 SourceVaultResolve \:3067 {provider, modelId} \:306b
   \:89e3\:6c7a\:3059\:308b\:3002SourceVault \:5fc5\:9808\:3002\:5931\:6557\:6642\:306f Missing\:3002 *)
iNBResolveIntentTuple[spec_] :=
  Module[{provider, intent, resolved, mid},
    If[!ListQ[spec] || Length[spec] < 2, Return[Missing["BadSpec", spec]]];
    provider = spec[[1]]; intent = spec[[2]];
    If[!StringQ[provider], provider = ToString[provider]];
    If[!StringQ[intent], intent = ToString[intent]];
    If[provider === "" || intent === "", Return[Missing["EmptySpec", spec]]];
    resolved = Quiet @ Check[
      SourceVault`SourceVaultResolve["Model",
        <|"Provider" -> provider, "Intent" -> intent|>],
      $Failed];
    If[!AssociationQ[resolved], Return[Missing["Unresolved", {provider, intent}]]];
    mid = Lookup[resolved, "ModelId", Missing[]];
    If[!StringQ[mid], Return[Missing["NoModelId", {provider, intent}]]];
    {provider, mid}];

Options[NBAccess`NBSyncClaudeModelVars] = {"Verbose" -> False};

NBAccess`NBSyncClaudeModelVars[opts:OptionsPattern[]] :=
  Module[{verbose, report = <||>, intentMap, mainSpec, docSpec,
          privSpec, fbSpec, mainTuple, docTuple, privTuple,
          localServer, fbResolved},
    verbose = TrueQ[OptionValue["Verbose"]];

    (* SourceVault \:304c\:672a\:30ed\:30fc\:30c9\:306a\:3089 no-op (\:5f8c\:65b9\:4e92\:63db) *)
    If[Length[Names["SourceVault`SourceVaultModelIntentMap"]] === 0,
      If[verbose,
        Print["[NBSyncClaudeModelVars] SourceVault not loaded; no-op"]];
      Return[<|"Status" -> "Skipped",
        "Reason" -> "SourceVaultNotLoaded"|>]];

    (* intent \:30de\:30c3\:30d4\:30f3\:30b0\:3092 SourceVault \:304b\:3089\:53d6\:5f97 *)
    intentMap = Quiet @ Check[
      SourceVault`SourceVaultModelIntentMap[], <||>];
    If[!AssociationQ[intentMap] || Length[intentMap] === 0,
      Return[<|"Status" -> "Skipped",
        "Reason" -> "EmptyIntentMap"|>]];

    (* --- $ClaudeModel --- *)
    mainSpec = Lookup[intentMap, "$ClaudeModel", {"claudecode", "code-heavy"}];
    mainTuple = iNBResolveIntentTuple[mainSpec];
    If[ListQ[mainTuple],
      ClaudeCode`$ClaudeModel = mainTuple;
      report["$ClaudeModel"] = mainTuple,
      report["$ClaudeModel_FAILED"] =
        <|"Spec" -> mainSpec, "Result" -> mainTuple|>];

    (* --- $ClaudeDocModel --- *)
    docSpec = Lookup[intentMap, "$ClaudeDocModel", {"claudecode", "extraction"}];
    docTuple = iNBResolveIntentTuple[docSpec];
    If[ListQ[docTuple],
      ClaudeCode`$ClaudeDocModel = docTuple;
      report["$ClaudeDocModel"] = docTuple,
      report["$ClaudeDocModel_FAILED"] =
        <|"Spec" -> docSpec, "Result" -> docTuple|>];

    (* --- $ClaudePrivateModel ---
       provider/URL \:306f NBResolveLocalServer (\:30bb\:30ad\:30e5\:30ea\:30c6\:30a3\:5883\:754c)\:3001
       \:30e2\:30c7\:30eb\:540d\:306f SourceVault \:306e intent \:89e3\:6c7a\:3002\:4e21\:8005\:3092\:5408\:6210\:3002 *)
    localServer = Quiet @ Check[NBAccess`NBResolveLocalServer[], <||>];
    privSpec = Lookup[intentMap, "$ClaudePrivateModel", {"lmstudio", "extraction"}];
    privTuple = iNBResolveIntentTuple[privSpec];
    If[AssociationQ[localServer] &&
       StringQ[Lookup[localServer, "URL", Missing[]]],
      Module[{prov, url, mid, privModel},
        prov = Lookup[localServer, "Provider", "lmstudio"];
        url = Lookup[localServer, "URL", "http://127.0.0.1:1234"];
        mid = If[ListQ[privTuple] && Length[privTuple] >= 2,
          privTuple[[2]], Missing[]];
        privModel = If[StringQ[mid], {prov, mid, url}, {prov, url}];
        ClaudeCode`$ClaudePrivateModel = privModel;
        report["$ClaudePrivateModel"] = privModel;
        report["LocalServerTrusted"] = Lookup[localServer, "Trusted", False]]];

    (* --- $ClaudeFallbackModels --- *)
    fbSpec = Lookup[intentMap, "$ClaudeFallbackModels", {}];
    If[ListQ[fbSpec],
      fbResolved = DeleteCases[Map[iNBResolveIntentTuple, fbSpec], _Missing];
      If[fbResolved =!= {},
        ClaudeCode`$ClaudeFallbackModels = fbResolved;
        report["$ClaudeFallbackModels"] = fbResolved]];

    If[verbose, Print["[NBSyncClaudeModelVars] ", report]];
    <|"Status" -> "OK", "Assigned" -> report|>
  ];
NBAccess`NBSyncClaudeModelVars[___] :=
  <|"Status" -> "Failed", "Reason" -> "InvalidArguments"|>;


(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:5225\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:7ba1\:7406 *)
NBAccess`NBSetProviderMaxAccessLevel[provider_String, level_?NumericQ] :=
  ($iProviderMaxAccessLevel[ToLowerCase[provider]] = Clip[level, {0., 1.}]);

NBAccess`NBGetProviderMaxAccessLevel[provider_String] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5];

(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:304c\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306b\:5bfe\:5fdc\:53ef\:80fd\:304b\:5224\:5b9a *)
NBAccess`NBProviderCanAccess[provider_String, accessLevel_?NumericQ] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5] >= accessLevel;

(* Stage 9 P1.5: \:30e2\:30c7\:30eb\:6307\:5b9a (modelSpec) \:304c\:6307\:5b9a\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306e
   \:30c7\:30fc\:30bf\:3092\:6271\:3048\:308b\:304b\:5224\:5b9a\:3059\:308b\:3002Private \:30ce\:30fc\:30c8 (\:30ec\:30d9\:30eb 1.0) \:3067
   \:30af\:30e9\:30a6\:30c9\:30e2\:30c7\:30eb (claudecode/anthropic/openai = 0.5) \:3092\:62d2\:5426\:3057\:3001
   \:30ed\:30fc\:30ab\:30eb LLM (lmstudio = 1.0) \:306e\:307f\:901a\:3059\:305f\:3081\:306b\:4f7f\:3046\:3002
   modelSpec: {provider, model} | {provider, model, url} | "model" (= claudecode) |
              Automatic (\:30e2\:30c7\:30eb\:6307\:5b9a\:7121\:3057\:3002\:5224\:5b9a\:5bfe\:8c61\:5916\:3068\:3057\:3066 True)\:3002 *)
NBAccess`NBModelCanHandleAccessLevel[modelSpec_, accessLevel_?NumericQ] :=
  Module[{provider},
    provider = Which[
      (* Automatic: \:30e2\:30c7\:30eb\:672a\:6307\:5b9a\:3002\:547c\:3073\:51fa\:3057\:5074\:304c $ClaudePrivateModel \:7b49\:306b
         \:632f\:308a\:5206\:3051\:308b\:306e\:3067\:3001\:3053\:3053\:3067\:306f\:5236\:7d04\:3057\:306a\:3044 (True) *)
      modelSpec === Automatic, Return[True],
      (* {provider, ...} \:5f62\:5f0f *)
      ListQ[modelSpec] && Length[modelSpec] >= 1 && StringQ[modelSpec[[1]]],
        modelSpec[[1]],
      (* "model" \:6587\:5b57\:5217\:5358\:4f53 = claudecode \:6271\:3044 *)
      StringQ[modelSpec], "claudecode",
      True, Missing["BadModelSpec"]];
    If[!StringQ[provider], Return[False]];
    NBAccess`NBProviderCanAccess[provider, accessLevel]
  ];
NBAccess`NBModelCanHandleAccessLevel[___] := False;

(* modelSpec \:304b\:3089 provider \:6587\:5b57\:5217\:3092\:53d6\:308a\:51fa\:3059\:88dc\:52a9 (\:62d2\:5426\:30e1\:30c3\:30bb\:30fc\:30b8\:7528) *)
NBAccess`NBModelProviderName[modelSpec_] :=
  Which[
    modelSpec === Automatic, "Automatic",
    ListQ[modelSpec] && Length[modelSpec] >= 1 && StringQ[modelSpec[[1]]],
      modelSpec[[1]],
    StringQ[modelSpec], "claudecode",
    True, "unknown"];

(* Stage 9 P1.5: \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:8981\:6c42\:3059\:308b\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3092\:8fd4\:3059\:3002
   Private \:5ba3\:8a00 (CloudPublishable -> False) \:306a\:3089 1.0 (\:30af\:30e9\:30a6\:30c9\:7981\:6b62)\:3002
   \:305d\:308c\:4ee5\:5916\:306f 0.0 (\:500b\:5225\:30bb\:30eb\:306e\:6a5f\:5bc6\:6027\:306f\:30bb\:30eb\:5358\:4f4d\:3067\:5224\:5b9a\:3055\:308c\:308b)\:3002
   claudecode \:304c Private \:691c\:8a3c\:306b\:4f7f\:3046\:516c\:958b\:95a2\:6570\:3002 *)
NBAccess`NBNotebookRequiredAccessLevel[nb_NotebookObject] :=
  If[iNBNotebookDeclaredPrivateQ[nb], 1.0, 0.0];
NBAccess`NBNotebookRequiredAccessLevel[___] := 0.0;

(* \:6307\:5b9a\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:3067\:5229\:7528\:53ef\:80fd\:306a\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:306e\:307f\:8fd4\:3059 *)
NBAccess`NBGetAvailableFallbackModels[requestedLevel_?NumericQ] :=
  Select[$iFallbackModels,
    Function[entry,
      Lookup[$iProviderMaxAccessLevel, ToLowerCase[entry[[1]]], 0.5] >= requestedLevel
    ]
  ];


(* ============================================================
   ObjectSpec: \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:306e\:30e1\:30bf\:60c5\:5831 + \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb

   PrivacyLevel \:306e\:610f\:5473:
     0.5        \[LongDash] \:30af\:30e9\:30a6\:30c9 LLM \:3067\:30a2\:30af\:30bb\:30b9\:53ef\:80fd
     1.0        \[LongDash] \:30ed\:30fc\:30ab\:30eb\:30e2\:30c7\:30eb\:306e\:307f
     {0.5, 1.0} \[LongDash] \:6df7\:5728: \:516c\:958b\:90e8\:5206\:306f 0.5, \:79d8\:5bc6\:90e8\:5206\:306f 1.0

   \:30d5\:30a1\:30a4\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:898f\:5247:
     $packageDirectory \:307e\:305f\:306f $ClaudeAccessibleDirs \:5185 \[RightArrow] 0.5
     \:305d\:308c\:4ee5\:5916                                         \[RightArrow] 1.0
     .nb \:30d5\:30a1\:30a4\:30eb\:306f\:79d8\:533f\:30bb\:30eb\:306e\:6709\:7121\:3067 {0.5,1.0} \:306b\:5909\:308f\:308b\:53ef\:80fd\:6027
   ============================================================ *)

(* \:30d5\:30a1\:30a4\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:3092\:6c7a\:5b9a\:3059\:308b\:3002
   Stage 9 P1 Step \:300c\:30af\:30e9\:30a6\:30c9\:516c\:958b\:5ba3\:8a00\:300d \:62e1\:5f35:
     (1) \:30ce\:30fc\:30c8\:81ea\:8eab\:306e TaggingRules > SourceVault > CloudPublishable \:3092\:6700\:512a\:5148
         True  \[Rule] 0.4 (\:30af\:30e9\:30a6\:30c9 LLM \:53ef)
         False \[Rule] 1.0 (\:30ed\:30fc\:30ab\:30eb\:306e\:307f, \:660e\:793a\:7684\:7981\:6b62)
     (2) \:5ba3\:8a00\:7121\:3057\:306e\:5834\:5408\:306f\:5f93\:6765\:901a\:308a $packageDirectory / $ClaudeAccessibleDirs \:3092\:898b\:308b
     (3) \:305d\:308c\:4ee5\:5916\:306f 1.0
   \:6ce8: \:6df7\:5728\:5224\:5b9a (\:6a5f\:5bc6\:30bb\:30eb\:306e\:6709\:7121) \:306f iNBFileCellPrivacyRange \:5074\:3067 refine \:3055\:308c\:308b\:306e\:3067\:3001
       \:3053\:3053\:3067\:306f base level (\:30d5\:30a1\:30a4\:30eb\:5168\:4f53\:5ba3\:8a00) \:306e\:307f\:8fd4\:3059\:3002 *)
iNBFilePrivacyLevel[path_String] :=
  Module[{declared, dir, pkgDir, accessDirs, isSafe},
    (* (1) \:30ce\:30fc\:30c8\:81ea\:8eab\:306e\:5ba3\:8a00 *)
    declared = iNBFileDeclaredPublishable[path];
    If[TrueQ[declared],    Return[0.4]];
    If[declared === False, Return[1.0]];

    (* (2) \:65e2\:5b58: \:30d1\:30b9\:5e95\:306e\:5b89\:5168\:5224\:5b9a *)
    dir        = DirectoryName[path];
    pkgDir     = Quiet @ Symbol["Global`$packageDirectory"];
    accessDirs = Quiet @ If[ListQ[Symbol["Global`$ClaudeAccessibleDirs"]],
      Symbol["Global`$ClaudeAccessibleDirs"], {}];
    isSafe = AnyTrue[
      Select[Flatten[{pkgDir, accessDirs}], StringQ],
      Function[d,
        StringStartsQ[StringReplace[dir, "\\"->"/" ],
          StringReplace[d,  "\\"->"/"]]
      ]];
    If[TrueQ[isSafe], 0.5, 1.0]
  ];

(* .nb \:30d5\:30a1\:30a4\:30eb\:56fa\:6709: \:79d8\:533f\:30bb\:30eb\:306e\:6709\:7121\:3067 PrivacyLevel \:30ec\:30f3\:30b8\:3092\:8fd4\:3059 *)
iNBFileCellPrivacyRange[path_String] :=
  Module[{nb2, allCells, hasConf, hasPublic, baseLevel},
    baseLevel = iNBFilePrivacyLevel[path];
    If[NumericQ[baseLevel] && baseLevel < 0.5,
      (* Explicit CloudPublishable -> True: cloud-safe score must be below 0.5. *)
      Return[baseLevel]];
    If[baseLevel === 0.5,
      (* Path-accessible but not cloud-send by default. *)
      Return[0.5]];
    nb2 = Quiet @ NBAccess`NBFileOpen[path];
    If[Head[nb2] =!= NotebookObject, Return[1.0]];
    allCells  = Quiet @ NBAccess`NBFileReadAllCells[nb2];
    Quiet @ NBAccess`NBFileClose[nb2];
    If[!ListQ[allCells] || Length[allCells] === 0, Return[1.0]];
    hasConf   = AnyTrue[allCells, TrueQ[#["IsConfidential"]] &];
    hasPublic = AnyTrue[allCells, !TrueQ[#["IsConfidential"]] &];
    Which[
      hasConf && hasPublic, {0.5, 1.0},   (* \:6df7\:5728 *)
      hasConf,              1.0,           (* \:5168\:3066\:79d8\:533f *)
      (* Stage 9 P1 \:62e1\:5f35: \:30ce\:30fc\:30c8\:81ea\:8eab\:304c CloudPublishable -> False \:3068\:660e\:793a\:5ba3\:8a00\:3057\:3066\:3044\:308b\:5834\:5408\:306f\:3001
         \:5168\:30bb\:30eb\:516c\:958b\:3067\:3082\:5f37\:5236 1.0 (\:65e2\:5b58\:7de9\:548c\:3092 skip)\:3002 *)
      iNBFileDeclaredPublishable[path] === False, 1.0,
      True,                 0.5            (* \:5168\:3066\:516c\:958b \[LongDash] \:30d5\:30a1\:30a4\:30eb\:306f1.0\:3060\:304c\:30bb\:30eb\:304c\:5168\:516c\:958b *)
    ]
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBObjectSpec: \:30d5\:30a1\:30a4\:30eb\:307e\:305f\:306f\:5024\:306e\:30e1\:30bf\:60c5\:5831 + PrivacyLevel
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBNormalizePath: \:7d76\:5bfe\:30d1\:30b9 \[RightArrow] \:30af\:30ed\:30b9 PC \:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:60c5\:5831
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   Phase 1 (\:51fa\:529b\:62e1\:5f35\:306e\:307f)\:3002authorization \:30ed\:30b8\:30c3\:30af\:306f\:4e00\:5207\:5909\:66f4\:3057\:306a\:3044\:3002
   rule 104: \:623b\:308a\:5024\:306f identity \:3067\:3042\:3063\:3066\:6a29\:9650\:3067\:306f\:306a\:3044\:3002

   root \:89e3\:6c7a\:65b9\:91dd (SourceVault \:59d4\:8b72\:6848):
   - SourceVault \:304c\:30ed\:30fc\:30c9\:6e08\:307f (iSVSymbolicPath \:304c\:5b9a\:7fa9\:6e08\:307f) \:306a\:3089\:3001\:305d\:308c\:306b\:59d4\:8b72\:3059\:308b\:3002
     iSVSymbolicPath \:306f\:30af\:30ed\:30b9 PC \:30a8\:30a4\:30ea\:30a2\:30b9 ($SourceVaultCloudRootAliases) \:306b\:5bfe\:5fdc\:3059\:308b\:3002
   - \:672a\:30ed\:30fc\:30c9\:306a\:3089\:73fe PC \:5b9f\:4f53\:30eb\:30fc\:30c8\:306e\:307f\:3067\:7c21\:6613\:89e3\:6c7a\:3057\:3001\:30a8\:30a4\:30ea\:30a2\:30b9\:7167\:5408\:306f\:3057\:306a\:3044\:3002
   \:3044\:305a\:308c\:306e\:5834\:5408\:3082 $NBPathRootRegistry \:306e\:3088\:3046\:306a\:65b0\:3057\:3044\:72b6\:614b\:306f NBAccess \:306b\:6301\:305f\:305b\:306a\:3044
   (\:4e8c\:91cd\:7ba1\:7406\:3092\:907f\:3051\:308b\:3002rule 104 / cross-PC path policy \[Section]6.1.1)\:3002 *)

(* SourceVault`iSVSymbolicPath \:304c\:5229\:7528\:53ef\:80fd\:304b (\:5b9a\:7fa9\:6e08\:307f\:304b) \:3092\:5224\:5b9a\:3002 *)
iNBSourceVaultPathAvailableQ[] :=
  Quiet @ Check[
    DownValues[SourceVault`iSVSymbolicPath] =!= {},
    False];

(* \:73fe PC \:5b9f\:4f53\:30eb\:30fc\:30c8\:306e\:307f\:306e\:7c21\:6613\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:5316 (SourceVault \:672a\:30ed\:30fc\:30c9\:6642\:306e fallback)\:3002
   SourceVault \:3068\:540c\:3058 root \:540d\:96c6\:5408 / \:540c\:3058 Global \:5909\:6570\:89e3\:6c7a\:65b9\:5f0f\:3092\:4f7f\:3046\:304c\:3001
   \:30a8\:30a4\:30ea\:30a2\:30b9\:306f\:898b\:306a\:3044\:3002\:3069\:306e\:30eb\:30fc\:30c8\:306b\:3082\:5f53\:305f\:3089\:306a\:3051\:308c\:3070 {"<ABS>", abs}\:3002 *)
iNBLocalSymbolicPath[abs_String] :=
  Module[{rootNames, cands, best, sep},
    sep = "/";
    rootNames = {"$packageDirectory", "$dropbox", "$onWork",
                 "$offWork", "$mathematicaWork"};
    cands = Map[
      Function[symName,
        Module[{bare, v, rootAbs, rootKey, absKey},
          bare = StringTrim[symName, "$"];
          v = Quiet @ ToExpression["Global`$" <> bare];
          If[!StringQ[v] || !DirectoryQ[v], Nothing,
            rootAbs = ExpandFileName[v];
            (* \:30bb\:30d1\:30ec\:30fc\:30bf\:7d71\:4e00 + \:672b\:5c3e\:9664\:53bb + \:5c0f\:6587\:5b57\:5316 (Windows \:5927\:5c0f\:7121\:8996) *)
            rootKey = ToLowerCase @ StringReplace[
              StringReplace[rootAbs, "\\" -> sep],
              RegularExpression["/+$"] -> ""];
            absKey = ToLowerCase @ StringReplace[
              StringReplace[abs, "\\" -> sep],
              RegularExpression["/+$"] -> ""];
            If[rootKey =!= "" &&
               (absKey === rootKey ||
                StringStartsQ[absKey, rootKey <> sep]),
              {symName, rootKey,
               StringReplace[StringReplace[abs, "\\" -> sep],
                 RegularExpression["/+$"] -> ""]},
              Nothing]]]],
      rootNames];
    If[cands === {},
      {"<ABS>", abs},
      (* \:6700\:9577\:30de\:30c3\:30c1 (\:5165\:308c\:5b50\:30eb\:30fc\:30c8\:5bfe\:7b56) *)
      best = First @ SortBy[cands, -StringLength[#[[2]]] &];
      Module[{symName = best[[1]], rootKey = best[[2]],
              absSlash = best[[3]], rest},
        rest = StringDrop[absSlash, StringLength[rootKey]];
        rest = StringSplit[StringTrim[rest, sep], sep];
        Prepend[rest, symName]]]
  ];

(* \:7d76\:5bfe\:30d1\:30b9\:3092\:6b63\:898f\:5316\:3057 identity \:7528 Association \:3092\:8fd4\:3059\:3002 *)
NBAccess`NBNormalizePath[path_String] :=
  Module[{abs, symPath, head, rootId, parts, matchedBy,
          resolutionStatus, physicalPath},
    abs = ExpandFileName[path];
    (* \:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9\:53d6\:5f97: SourceVault \:512a\:5148\:3001\:7121\:3051\:308c\:3070 local fallback *)
    symPath = If[iNBSourceVaultPathAvailableQ[],
      Quiet @ Check[SourceVault`iSVSymbolicPath[abs], {"<ABS>", abs}],
      iNBLocalSymbolicPath[abs]];
    If[!ListQ[symPath] || symPath === {},
      symPath = {"<ABS>", abs}];
    head = First[symPath];
    If[head === "<ABS>",
      (* \:3069\:306e\:30eb\:30fc\:30c8\:306b\:3082\:5f53\:305f\:3089\:306a\:3044\:30d5\:30a1\:30a4\:30eb *)
      Return[<|
        "Kind" -> "AbsolutePath",
        "RootId" -> Missing["Unrooted"],
        "Parts" -> {},
        "SymbolicPath" -> symPath,
        "PhysicalPath" -> abs,
        "ResolutionStatus" -> "Unrooted",
        "MatchedBy" -> "None"|>]];
    (* \:30eb\:30fc\:30c8\:4ed8\:304d\:30b7\:30f3\:30dc\:30ea\:30c3\:30af\:30d1\:30b9 *)
    rootId = head;
    parts = Rest[symPath];
    (* \:73fe PC \:5b9f\:4f53\:30eb\:30fc\:30c8\:306b\:5f53\:305f\:308b\:304b: PhysicalPath \:304c\:73fe PC \:306b\:5b58\:5728\:3059\:308b\:304b\:3067\:5224\:5b9a\:3002
       SourceVault \:59d4\:8b72\:6642\:3001iSVSymbolicPath \:306f\:30a8\:30a4\:30ea\:30a2\:30b9\:306b\:3082\:5f53\:305f\:308b\:305f\:3081\:3001
       \:5b9f\:4f53\:89e3\:6c7a\:3067\:304d\:305f\:304b\:3069\:3046\:304b\:3092\:3053\:3053\:3067\:78ba\:304b\:3081\:308b\:3002 *)
    physicalPath = abs;
    Which[
      DirectoryQ[abs] || FileExistsQ[abs],
        resolutionStatus = "ResolvedOnThisPC";
        matchedBy = "LocalRoot",
      True,
        (* path \:304c\:73fe PC \:306b\:5b58\:5728\:3057\:306a\:3044: \:5225 PC \:306e\:30a8\:30a4\:30ea\:30a2\:30b9\:7531\:6765\:3068\:307f\:306a\:3059\:3002
           identity \:306b\:306f\:4f7f\:3048\:308b\:304c PhysicalPath \:306f\:4fe1\:7528\:3057\:306a\:3044\:3002 *)
        resolutionStatus = "AliasOnly";
        matchedBy = "Alias";
        physicalPath = Missing["AliasOnly"]
    ];
    <|
      "Kind" -> "RootedPath",
      "RootId" -> rootId,
      "Parts" -> parts,
      "SymbolicPath" -> symPath,
      "PhysicalPath" -> physicalPath,
      "ResolutionStatus" -> resolutionStatus,
      "MatchedBy" -> matchedBy|>
  ];

NBAccess`NBNormalizePath[_] := Missing["InvalidPathArgument"];

(* NBFileSpec \:3078\:30de\:30fc\:30b8\:3059\:308b PathRef \:7cfb\:30d5\:30a3\:30fc\:30eb\:30c9\:3092 Association \:3067\:8fd4\:3059\:3002
   NBNormalizePath \:304c\:5931\:6557\:3057\:3066\:3082 NBFileSpec \:5168\:4f53\:306f\:58ca\:3055\:306a\:3044 (Missing \:3092\:8fd4\:3059\:3060\:3051)\:3002
   rule 104: \:3053\:308c\:3089\:306f identity \:7528\:30d5\:30a3\:30fc\:30eb\:30c9\:3067\:3042\:308a authorization \:306b\:306f\:4f7f\:308f\:306a\:3044\:3002 *)
iNBPathRefFields[path_String] :=
  Module[{pr},
    pr = Quiet @ Check[NBAccess`NBNormalizePath[path], $Failed];
    If[AssociationQ[pr],
      <|
        "PathRef" -> KeyTake[pr, {"Kind", "RootId", "Parts"}],
        "SymbolicPath" -> Lookup[pr, "SymbolicPath", Missing[]],
        "PathResolutionStatus" -> Lookup[pr, "ResolutionStatus", "Unknown"]
      |>,
      <|
        "PathRef" -> Missing["NormalizeFailed"],
        "SymbolicPath" -> Missing["NormalizeFailed"],
        "PathResolutionStatus" -> "Unknown"
      |>]
  ];
iNBPathRefFields[_] :=
  <|"PathRef" -> Missing["InvalidPathArgument"],
    "SymbolicPath" -> Missing["InvalidPathArgument"],
    "PathResolutionStatus" -> "Unknown"|>;

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 4.1 / 4.2: File authorization adapter + projection field
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   cross-PC path policy Phase 4 (revised3) \:6e96\:62e0\:3002
   CloudSendAllowed \:7b49\:306f\:4e00\:6b21\:30dd\:30ea\:30b7\:30fc\:3067\:306f\:306a\:304f NBAuthorize \:7d50\:679c\:306e projection\:3002
   NBAuthorizeFile \:306f\:65b0 engine \:3067\:306f\:306a\:304f\:65e2\:5b58 NBAuthorize \:3078\:306e adapter\:3002 *)

(* NBFileSpec \:306e projection key \:4e00\:89a7\:3002authorization \:5165\:529b\:304b\:3089\:306f\:843d\:3068\:3059\:3002 *)
$NBFileProjectionKeys = {
  "ReadableByAgent", "WritableByAgent", "CloudSendAllowed",
  "ReadDecision", "WriteDecision", "CloudSendDecision",
  "ProjectionSource", "ProjectionComputedAt"};

(* Phase 4 \:521d\:671f\:306e placeholder label\:3002DLM \:5b8c\:5168\:5b9f\:88c5\:307e\:3067\:306f\:3053\:306e\:6700\:5c0f\:5f62\:3002 *)
NBAccess`NBDefaultFilePolicyLabel[spec_Association] :=
  <|"Kind" -> "DefaultFilePolicyLabel"|>;
NBAccess`NBDefaultFilePolicyLabel[_] :=
  <|"Kind" -> "DefaultFilePolicyLabel"|>;
NBAccess`NBNoExtraContainerLabel[] :=
  <|"Kind" -> "NoExtraContainerLabel"|>;

(* PrivacyLevel \:304b\:3089 score \:3092\:5f97\:308b\:3002
   \:6570\:5024\:306a\:3089\:305d\:306e\:5024\:3002{0.5,1.0} \:7b49\:306e\:6df7\:5728\:306f Max (whole-file projection \:306f\:5b89\:5168\:5074)\:3002
   \:4e0d\:660e\:306f 1.0 (\:6700\:3082\:53b3\:683c)\:3002 *)
iNBPrivacyLevelToScore[pl_] :=
  Which[
    NumericQ[pl], N[pl],
    ListQ[pl] && pl =!= {} && AllTrue[pl, NumericQ], N[Max[pl]],
    True, 1.0
  ];

(* NBFileSpec \:306e\:751f Association \:3092 NBAuthorize \:306e object \:5951\:7d04\:306b\:6b63\:898f\:5316\:3059\:308b\:3002
   - projection key \:3092\:843d\:3068\:3059
   - PrivacyLevel \:304b\:3089 BasePrivacyScore \:3068 EffectiveRiskScore \:3092\:88dc\:5b8c
     (revised3 ScoreGate \:4e3b\:5c0e\:6848: \:73fe\:884c NBScoreGate \:306f EffectiveRiskScore \:3092\:512a\:5148\:53c2\:7167\:3059\:308b\:3002
      BasePrivacyScore \:3060\:3051\:3067\:306f ScoreGate \:304c\:52b9\:304b\:306a\:3044\:3002)
   - PolicyLabel / ContainerLabel / ContainerRisk / Tags \:3092\:65e2\:5b9a\:3067\:88dc\:5b8c *)
iNBFileSpecForAuthorize[spec_Association] :=
  Module[{base, score},
    base = KeyDrop[spec, $NBFileProjectionKeys];
    score = iNBPrivacyLevelToScore[Lookup[base, "PrivacyLevel", 1.0]];
    <|
      "Kind" -> Lookup[base, "Kind", "File"],
      "Path" -> Lookup[base, "Path", Missing["Path"]],
      "CanonicalPath" ->
        Lookup[base, "CanonicalPath", Lookup[base, "Path", Missing[]]],
      "PrivacyLevel" -> Lookup[base, "PrivacyLevel", 1.0],
      "BasePrivacyScore" -> Lookup[base, "BasePrivacyScore", score],
      (* \:73fe\:884c NBScoreGate \:304c\:512a\:5148\:7684\:306b\:898b\:308b score\:3002\:3053\:308c\:304c\:9632\:5fa1\:306e\:4e3b\:7d4c\:8def\:3002 *)
      "EffectiveRiskScore" -> Lookup[base, "EffectiveRiskScore", score],
      "PolicyLabel" ->
        Lookup[base, "PolicyLabel", NBAccess`NBDefaultFilePolicyLabel[base]],
      "ContainerLabel" ->
        Lookup[base, "ContainerLabel", NBAccess`NBNoExtraContainerLabel[]],
      "ContainerRisk" -> Lookup[base, "ContainerRisk", 0.0],
      "Tags" -> Lookup[base, "Tags", {}],
      "SourceSpecVersion" -> "NBFileAuthorizationSpec/v1"
    |>
  ];
iNBFileSpecForAuthorize[_] :=
  <|"Kind" -> "File", "PrivacyLevel" -> 1.0,
    "BasePrivacyScore" -> 1.0, "EffectiveRiskScore" -> 1.0,
    "SourceSpecVersion" -> "NBFileAuthorizationSpec/v1"|>;

(* file \:7528 AccessRequest \:3092\:7d44\:307f\:7acb\:3066\:308b\:3002
   Sink / Networked / AccessLevel \:306f operation \:304b\:3089\:65e2\:5b9a\:304c\:6c7a\:307e\:308b\:3002
   Phase 4.1: cloud send \:306f\:73fe\:884c NBScoreGate \:306b\:5408\:308f\:305b Sink -> "CloudLLM"\:3002 *)
Options[NBAccess`NBMakeFileAccessRequest] = {
  "Subject" -> "ClaudeAgent", "Module" -> "claudecode",
  "Sink" -> Automatic, "Networked" -> Automatic, "Route" -> Automatic,
  "Provider" -> Automatic, "ModelIntent" -> Automatic,
  "AccessLevel" -> Automatic};

NBAccess`NBMakeFileAccessRequest[
    pathOrSpec_, operation_String, opts:OptionsPattern[]] :=
  Module[{sink, networked, route, accessLevel, cloudTh},
    cloudTh = Lookup[$NBRoutingThresholds, "Cloud", 0.5];
    (* Sink \:65e2\:5b9a: \:73fe\:884c NBEnvironmentGate \:306e AllowedSinks \:65e2\:5b9a\:96c6\:5408
       {"CloudLLM","PrivateLLM","LocalOnly","Notebook"} \:306b\:5408\:308f\:305b\:308b\:3002
       "KernelValue" / "NotebookCell" \:306f\:96c6\:5408\:5916\:306a\:306e\:3067 SinkNotAllowed \:3067 Deny \:3055\:308c\:308b\:3002
       Phase 4.1 \:3067\:306f AccessRequest \:306e\:62bd\:8c61\:540d\:3088\:308a\:73fe\:884c gate \:304c\:8a8d\:8b58\:3059\:308b\:540d\:3092\:512a\:5148\:3059\:308b\:3002 *)
    sink = Replace[OptionValue["Sink"], Automatic :>
      Switch[operation,
        "SendExternal", "CloudLLM",
        "ReadValue",    "LocalOnly",
        "WriteCell",    "Notebook",
        "WriteLog",     "LocalOnly",
        _,              "LocalOnly"]];
    networked = Replace[OptionValue["Networked"], Automatic :>
      (operation === "SendExternal")];
    route = Replace[OptionValue["Route"], Automatic :>
      If[operation === "SendExternal", "CloudLLM", "LocalAgent"]];
    (* AccessLevel \:65e2\:5b9a: cloud \:306f threshold\:3001\:305d\:306e\:4ed6\:306f\:30ed\:30fc\:30ab\:30eb\:306a\:306e\:3067\:7de9\:3044 1.0\:3002
       \:6ce8: \:73fe\:884c NBScoreGate \:306f obj \:5074 EffectiveRiskScore \:3092\:512a\:5148\:53c2\:7167\:3059\:308b\:305f\:3081\:3001
       obj \:306b score \:304c\:3042\:308b\:9650\:308a req["AccessLevel"] \:306f\:5224\:5b9a\:306b\:76f4\:63a5\:306f\:52b9\:304b\:306a\:3044\:3002 *)
    accessLevel = Replace[OptionValue["AccessLevel"], Automatic :>
      Switch[operation, "SendExternal", cloudTh, _, 1.0]];
    <|
      "Subject" -> OptionValue["Subject"],
      "Module" -> OptionValue["Module"],
      "Operation" -> operation,
      "Sink" -> sink,
      "Environment" -> <|
        "Networked" -> TrueQ[networked],
        "Route" -> route,
        "Provider" -> OptionValue["Provider"],
        "ModelIntent" -> OptionValue["ModelIntent"]|>,
      "AccessLevel" -> accessLevel
    |>
  ];

(* file spec \:3092 NBAuthorize \:306b\:6e21\:3059 adapter\:3002
   \:751f spec \:3092\:305d\:306e\:307e\:307e\:6e21\:3055\:305a iNBFileSpecForAuthorize \:3067\:6b63\:898f\:5316\:3059\:308b\:3002
   NBAuthorize \:304c\:5931\:6557\:3057\:305f\:3089 Deny \:306b\:5012\:3059 (fail-closed)\:3002 *)
NBAccess`NBAuthorizeFile[pathOrSpec_, req_Association] :=
  Module[{rawSpec, authSpec},
    rawSpec = If[AssociationQ[pathOrSpec],
      pathOrSpec,
      Quiet @ Check[
        NBAccess`NBFileSpec[pathOrSpec, "IncludeProjections" -> False],
        $Failed]];
    If[!AssociationQ[rawSpec],
      Return[<|"Decision" -> "Deny",
        "ReasonClass" -> "FileSpecError",
        "VisibleExplanation" -> "Could not build file spec."|>]];
    authSpec = iNBFileSpecForAuthorize[rawSpec];
    Quiet @ Check[
      NBAccess`NBAuthorize[authSpec, req],
      <|"Decision" -> "Deny",
        "ReasonClass" -> "AuthorizationError",
        "VisibleExplanation" -> "File authorization failed."|>]
  ];

(* AccessDecision \:3092 fail-closed \:306a Boolean projection \:306b\:843d\:3068\:3059\:3002
   "Permit" \:306e\:3068\:304d\:3060\:3051 True\:3002\:305d\:308c\:4ee5\:5916\:30fb$Failed\:30fbMissing\:30fb\:4f8b\:5916\:306f\:3059\:3079\:3066 False\:3002 *)
NBAccess`NBPermitQ[decision_] :=
  TrueQ @ Quiet @ Check[
    AssociationQ[decision] &&
      Lookup[decision, "Decision", None] === "Permit",
    False];

(* NBFileSpec base spec \:304b\:3089 projection field \:3092\:8a08\:7b97\:3059\:308b\:3002
   notebook \:3092\:958b\:304d\:76f4\:3055\:306a\:3044 (base spec \:306e\:60c5\:5831\:3060\:3051\:3092\:4f7f\:3046)\:3002
   3 \:3064\:306e projection \:306f\:540c\:4e00\:306e base \:306b\:5bfe\:3059\:308b NBAuthorizeFile \:306e\:7d50\:679c\:3002 *)
iNBFileSpecProjections[base_Association] :=
  Module[{readReq, writeReq, cloudReq, readDec, writeDec, cloudDec},
    readReq = NBAccess`NBMakeFileAccessRequest[base, "ReadValue",
      "Sink" -> "LocalOnly", "Networked" -> False, "AccessLevel" -> 1.0];
    writeReq = NBAccess`NBMakeFileAccessRequest[base, "WriteCell",
      "Sink" -> "Notebook", "Networked" -> False, "AccessLevel" -> 1.0];
    cloudReq = NBAccess`NBMakeFileAccessRequest[base, "SendExternal",
      "Sink" -> "CloudLLM", "Networked" -> True, "Route" -> "CloudLLM"];
    readDec  = NBAccess`NBAuthorizeFile[base, readReq];
    writeDec = NBAccess`NBAuthorizeFile[base, writeReq];
    cloudDec = NBAccess`NBAuthorizeFile[base, cloudReq];
    <|
      "ReadableByAgent" -> NBAccess`NBPermitQ[readDec],
      "WritableByAgent" -> NBAccess`NBPermitQ[writeDec],
      "CloudSendAllowed" -> NBAccess`NBPermitQ[cloudDec],
      "ReadDecision" -> readDec,
      "WriteDecision" -> writeDec,
      "CloudSendDecision" -> cloudDec,
      "ProjectionSource" -> "NBAuthorize",
      (* projection \:3092\:5b9f\:969b\:306b\:8a08\:7b97\:3057\:305f\:6642\:523b\:3002cache key \:306b\:306f\:542b\:3081\:306a\:3044\:3002 *)
      "ProjectionComputedAt" -> DateObject[]
    |>
  ];

(* Phase 4.3: file content cache key for NBFileSpec base cache. *)
iNBFileContentCacheKey[path_String] :=
  Module[{canonical, exists, mtime, bytes},
    canonical = Quiet @ Check[ExpandFileName[path], path];
    exists = FileExistsQ[canonical];
    mtime = If[exists, Quiet @ Check[FileDate[canonical], Missing["FileDateFailed"]],
      Missing["FileDoesNotExist"]];
    bytes = If[exists && !DirectoryQ[canonical],
      Quiet @ Check[FileByteCount[canonical], Missing["FileByteCountFailed"]],
      Missing["NoByteCount"]];
    <|
      "CanonicalPath" -> canonical,
      "Exists" -> exists,
      "FileMTime" -> mtime,
      "FileByteCount" -> bytes
    |>
  ];
iNBFileContentCacheKey[other_] :=
  <|"InvalidPath" -> HoldComplete[other]|>;

iNBProviderMaxAccessLevelsSnapshot[] :=
  If[AssociationQ[$iProviderMaxAccessLevel],
    Association @ SortBy[Normal[$iProviderMaxAccessLevel], ToString[First[#], InputForm] &],
    <||>];

iNBNormalizePolicyPathForFingerprint[path_String] :=
  Quiet @ Check[ExpandFileName[path], path];
iNBNormalizePolicyPathForFingerprint[other_] := other;

iNBNormalizedAccessibleDirsSnapshot[] :=
  Module[{dirs},
    dirs = Quiet @ Check[NBAccess`NBGetAccessibleDirs[], {}];
    If[!ListQ[dirs], dirs = {}];
    SortBy[
      DeleteDuplicates[Map[iNBNormalizePolicyPathForFingerprint, dirs]],
      ToString[#, InputForm] &]
  ];

(* Phase 4.3: projection policy fingerprint.
   Do not include ProjectionComputedAt or current time. *)
iNBProjectionPolicyFingerprint[] :=
  Hash[
    <|
      "NBRoutingThresholds" -> If[AssociationQ[$NBRoutingThresholds],
        Association @ SortBy[Normal[$NBRoutingThresholds], ToString[First[#], InputForm] &],
        $NBRoutingThresholds],
      "NBPrivacySpec" -> NBAccess`$NBPrivacySpec,
      "AccessibleDirs" -> iNBNormalizedAccessibleDirsSnapshot[],
      "ProviderMaxAccessLevels" -> iNBProviderMaxAccessLevelsSnapshot[],
      "ProjectionPolicyVersion" -> $iNBFileProjectionPolicyVersion
    |>,
    "SHA256"
  ];

(* Base spec without projection fields. This is the old NBFileSpec body. *)
iNBFileSpecBase[path_String] :=
  Module[{exists, ext, fsize, privLevel, declared, nb2, allCells,
          nConf = 0, nPublic = 0, nTotal = 0},
    exists = FileExistsQ[path];
    If[!exists,
      Return[<|"Type" -> "File", "Path" -> path, "Exists" -> False,
               "PrivacyLevel" -> 1.0|>]];
    ext   = ToLowerCase[FileExtension[path]];
    fsize = Quiet @ Check[FileByteCount[path], 0];
    (* .nb file: get cell privacy summary. *)
    If[ext === "nb",
      privLevel = iNBFileCellPrivacyRange[path];
      nb2 = Quiet @ NBAccess`NBFileOpen[path];
      If[Head[nb2] === NotebookObject,
        allCells = Quiet @ NBAccess`NBFileReadAllCells[nb2];
        Quiet @ NBAccess`NBFileClose[nb2];
        If[ListQ[allCells],
          nTotal  = Length[allCells];
          nConf   = Count[allCells, _?(TrueQ[#["IsConfidential"]] &)];
          nPublic = nTotal - nConf]]];
    If[ext =!= "nb",
      privLevel = iNBFilePrivacyLevel[path]];

    (* Phase 4.6c: final file-spec override.
       Notebook-level CloudPublishable declaration must win at the NBFileSpec
       boundary too, so downstream code never sees 0.5 for an explicitly
       publishable notebook. *)
    If[ext === "nb",
      declared = iNBFileDeclaredPublishable[path];
      If[TrueQ[declared], privLevel = 0.4];
      If[declared === False, privLevel = 1.0]];

    Join[
      <|
        "Type"          -> "File",
        "FileType"      -> If[ext =!= "", ext, "unknown"],
        "Path"          -> path,
        "Exists"        -> True,
        "FileSize"      -> fsize,
        "PrivacyLevel"  -> privLevel,
        If[ext === "nb", "CellCount"            -> nTotal,   Nothing],
        If[ext === "nb", "PublicCellCount"       -> nPublic,  Nothing],
        If[ext === "nb", "ConfidentialCellCount" -> nConf,    Nothing]
      |>,
      iNBPathRefFields[path]
    ]
  ];

iNBFileSpecBaseCached[path_String] :=
  Module[{keyData, key},
    keyData = iNBFileContentCacheKey[path];
    key = Hash[keyData, "SHA256"];
    If[KeyExistsQ[$iNBFileSpecBaseCache, key],
      Return[$iNBFileSpecBaseCache[key]]];
    $iNBFileSpecBaseCache[key] = iNBFileSpecBase[path]
  ];

(* Phase 4.6d: repair at NBFileSpec public boundary.
   This is intentionally applied after the base cache, so stale or older base
   spec construction cannot hide an explicit notebook-level CloudPublishable
   declaration from projections. *)
iNBApplyDeclaredPublishableToFileSpec[base_Association] :=
  Module[{path, fileType, declared},
    path = Lookup[base, "Path", Missing["NoPath"]];
    fileType = ToLowerCase @ ToString @ Lookup[base, "FileType",
      If[StringQ[path], FileExtension[path], ""]];
    If[!StringQ[path] || ToLowerCase[FileExtension[path]] =!= "nb",
      Return[base]];

    (* Phase 4.6e: use the public reader here.
       result7.nb showed NBGetCloudPublishable[path] -> True while the
       private declared helper did not reach the public NBFileSpec boundary. *)
    declared = Quiet @ Check[NBAccess`NBGetCloudPublishable[path],
      Missing["CloudPublishableReadFailed"]];

    Which[
      TrueQ[declared],
        Join[base, <|"PrivacyLevel" -> 0.4,
                    "DeclaredCloudPublishable" -> True,
                    "DeclaredCloudPublishableSource" -> "NBGetCloudPublishable"|>],
      declared === False,
        Join[base, <|"PrivacyLevel" -> 1.0,
                    "DeclaredCloudPublishable" -> False,
                    "DeclaredCloudPublishableSource" -> "NBGetCloudPublishable"|>],
      True,
        base
    ]
  ];
iNBApplyDeclaredPublishableToFileSpec[other_] := other;

iNBFileSpecProjectionsCached[base_Association] :=
  Module[{path, baseKeyData, keyData, key},
    path = Lookup[base, "Path", Missing["NoPath"]];
    baseKeyData = If[StringQ[path],
      iNBFileContentCacheKey[path],
      Hash[KeyDrop[base, $NBFileProjectionKeys], "SHA256"]];
    keyData = <|
      "BaseKey" -> baseKeyData,
      "PolicyFingerprint" -> iNBProjectionPolicyFingerprint[]
    |>;
    key = Hash[keyData, "SHA256"];
    If[KeyExistsQ[$iNBFileSpecProjectionCache, key],
      Return[$iNBFileSpecProjectionCache[key]]];
    $iNBFileSpecProjectionCache[key] = iNBFileSpecProjections[base]
  ];

NBAccess`NBFileSpecCacheClear[] :=
  (
    $iNBFileSpecBaseCache = <||>;
    $iNBFileSpecProjectionCache = <||>;
    Null
  );

Options[NBAccess`NBFileSpec] = {
  PrivacySpec -> Automatic,
  "IncludeProjections" -> False};
NBAccess`NBFileSpec[path_String, opts:OptionsPattern[]] :=
  Module[{base},
    base = iNBApplyDeclaredPublishableToFileSpec[
      iNBFileSpecBaseCached[path]];
    If[TrueQ[OptionValue["IncludeProjections"]],
      Join[base, iNBFileSpecProjectionsCached[base]],
      base]
  ];

(* \:5909\:6570/\:5024\:306e ObjectSpec (\:578b\:60c5\:5831 + \:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb) *)
NBAccess`NBValueSpec[expr_, privacyLevel_:0.5] :=
  Module[{h = Head[expr], len, keys, dims},
    len  = Quiet @ Check[Length[expr], 0];
    keys = If[AssociationQ[expr], Keys[expr], {}];
    dims = Quiet @ Check[Dimensions[expr], {}];
    <|
      "Type"         -> "Value",
      "Head"         -> ToString[h],
      "Length"       -> len,
      "Keys"         -> Take[keys, UpTo[20]],
      "Dimensions"   -> dims,
      "PrivacyLevel" -> privacyLevel
    |>
  ];

(* PrivacyLevel \:304b\:3089\:5fc5\:8981\:306a\:30e2\:30c7\:30eb\:30eb\:30fc\:30c8\:3092\:6c7a\:5b9a *)
NBAccess`NBPrivacyLevelToRoutes[privacyLevel_] :=
  Module[{routes},
    Which[
      NumericQ[privacyLevel],
        If[privacyLevel < 0.5, {"cloud"}, {"local"}],
      ListQ[privacyLevel] && AllTrue[privacyLevel, NumericQ],
        routes = DeleteDuplicates[If[# < 0.5, "cloud", "local"] & /@ privacyLevel];
        If[routes === {}, {"local"}, routes],
      True,
        {"local"}
    ]
  ];

(* \:30bb\:30eb\:3092\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:7bc4\:56f2\:3067\:30d5\:30a3\:30eb\:30bf:
   lo <= privacyLevel <= hi \:306e\:30bb\:30eb\:306e\:307f\:8fd4\:3059 *)
Options[NBAccess`NBFileReadCellsInRange] = {};
NBAccess`NBFileReadCellsInRange[nb_NotebookObject,
                                 lo_?NumericQ, hi_?NumericQ] :=
  Module[{n, result},
    n = NBAccess`NBCellCount[nb];
    If[n === 0, Return[{}]];
    result = Table[
      Module[{cellObj, cellExpr, privLvl, style, text, isConf},
        cellObj  = iResolveCell[nb, i];
        If[cellObj === $Failed, Nothing,
          cellExpr = Quiet @ NotebookRead[cellObj];
          isConf   = iNBFileCellIsConfidential[cellExpr];
          privLvl  = iNBFileCellPrivacyLevel[cellExpr];
          If[privLvl >= lo && privLvl <= hi,
            style = iNBFileCellStyle[cellExpr];
            text  = iNBFileCellText[cellExpr];
            <|"CellIdx"        -> i,
              "Style"          -> style,
              "Text"           -> text,
              "PrivacyLevel"   -> privLvl,
              "IsConfidential" -> isConf,
              "CellExpr"       -> cellExpr
            |>,
            Nothing]]],
      {i, n}];
    Select[result, AssociationQ]
  ];


(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBSplitNotebookCells: PrivacyLevel threshold \:3067\:30bb\:30eb\:30922\:5206\:5272
   \:623b\:308a\:5024: {publicCells, privateCells}
     \:5404\:8981\:7d20\:306f {<|"CellIdx"->n, "Style"->s, "Text"->t, "PrivacyLevel"->p, "CellExpr"->e|>, ...}
   threshold: 0.5 \:4ee5\:4e0b\:306f public, 0.5 \:8d85\:306f private
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBSplitNotebookCells[path_String, threshold_:0.5] :=
  Module[{nb2, allCells, public, private},
    If[!FileExistsQ[path], Return[{{},{}}]];
    nb2 = NBAccess`NBFileOpen[path];
    If[Head[nb2] =!= NotebookObject, Return[{{},{}}]];
    allCells = Quiet @ NBAccess`NBFileReadAllCells[nb2];
    Quiet @ NBAccess`NBFileClose[nb2];
    If[!ListQ[allCells] || Length[allCells] === 0, Return[{{},{}}]];
    public  = Select[allCells, #["PrivacyLevel"] <= threshold &];
    private = Select[allCells, #["PrivacyLevel"] >  threshold &];
    {public, private}
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBMergeNotebookCells: 2\:3064\:306e\:7d50\:679c Association \:3092\:5143\:306e\:30bb\:30eb\:9806\:306b\:30de\:30fc\:30b8\:3057\:3066\:4fdd\:5b58
   results1, results2: <|cellIdx -> newText, ...|>
   \:5143\:30d5\:30a1\:30a4\:30eb\:3092\:958b\:3044\:3066\:66f8\:304d\:623b\:3057\:3001outputPath \:306b\:4fdd\:5b58\:3059\:308b\:3002
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBMergeNotebookCells[sourcePath_String, outputPath_String,
                               results1_Association, results2_Association] :=
  Module[{nb2, merged, normOut},
    (* \:51fa\:529b\:30d1\:30b9\:306b\:95a2\:9023\:3059\:308b\:65e2\:5b58 invisible \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:9589\:3058\:308b (\:30d1\:30b9\:6b63\:898f\:5316) *)
    normOut = StringReplace[outputPath, "\\" -> "/"];
    Scan[Function[n,
      Module[{fn = Quiet[NotebookFileName[n]]},
        If[StringQ[fn] && StringReplace[fn, "\\" -> "/"] === normOut,
          Quiet @ NotebookClose[n]]]],
      Quiet @ Notebooks[]];
    (* \:30bd\:30fc\:30b9\:30d1\:30b9\:3082\:540c\:69d8\:306b\:9589\:3058\:308b (\:524d\:56de\:306e NBSplitNotebookCells \:304c\:6b8b\:3057\:3066\:3044\:308b\:5834\:5408) *)
    Module[{normSrc = StringReplace[sourcePath, "\\" -> "/"]},
      Scan[Function[n,
        Module[{fn = Quiet[NotebookFileName[n]]},
          If[StringQ[fn] && StringReplace[fn, "\\" -> "/"] === normSrc &&
             Quiet[CurrentValue[n, Visible]] === False,
            Quiet @ NotebookClose[n]]]],
        Quiet @ Notebooks[]]];
    nb2 = NBAccess`NBFileOpen[sourcePath];
    If[Head[nb2] =!= NotebookObject, Return[$Failed]];
    merged = Join[results1, results2];
    If[Length[merged] > 0,
      NBAccess`NBFileWriteAllCells[nb2, merged]];
    NBAccess`NBFileSave[nb2, outputPath];
    NBAccess`NBFileClose[nb2];
    (* \:4fdd\:5b58\:5f8c\:3001outputPath \:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c invisible \:3067\:6b8b\:3063\:3066\:3044\:306a\:3044\:304b\:518d\:78ba\:8a8d *)
    Scan[Function[n,
      Module[{fn = Quiet[NotebookFileName[n]]},
        If[StringQ[fn] && StringReplace[fn, "\\" -> "/"] === normOut,
          Quiet @ NotebookClose[n]]]],
      Quiet @ Notebooks[]];
    outputPath
  ];


(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: Allowed Expression Surface
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

If[!AssociationQ[$NBAllowedHeadsByCategory],
  $NBAllowedHeadsByCategory = <|
    "NBAccess_ReadOnly" -> {
      "NBCellRead", "NBCellReadInputText", "NBCellCount",
      "NBCurrentCellIndex", "NBSelectedCellIndices",
      "NBCellIndicesByTag", "NBCellIndicesByStyle",
      "NBCellStyle", "NBCellLabel", "NBCellGetText",
      "NBGetCells", "NBGetContext", "NBResolveCell",
      "NBCellGetTaggingRule", "NBCellHasImage",
      "NBCellPrivacyLevel", "NBIsAccessible",
      "NBFilterCellIndices", "NBCellExprToText", "NBCellToText",
      "NBFileReadCells", "NBFileReadAllCells", "NBFileReadCellsInRange",
      "NBFileSpec", "NBValueSpec", "NBPrivacyLevelToRoutes",
      "NBGetConfidentialTag", "NBCellUsesConfidentialSymbol",
      "NBCellExtractVarNames", "NBCellExtractAssignedNames",
      "NBShouldExcludeFromPrompt", "NBIsClaudeFunctionCell",
      "NBBuildVarDependencies", "NBTransitiveDependents",
      "NBDependencyEdges", "NBGetTaggingRule"
    },
    "Control" -> {
      "CompoundExpression", "Module", "With", "Block",
      "If", "Which", "Switch", "Do", "Table",
      "Return", "Break", "Continue", "Throw", "Catch",
      "While", "For", "Nest", "NestList", "FixedPoint",
      "Sequence", "Nothing", "Slot", "Function"
    },
    "Arithmetic" -> {
      "Plus", "Times", "Power", "Subtract", "Divide",
      "Minus", "Sqrt", "Abs", "Min", "Max", "Mod",
      "Equal", "Unequal", "Less", "Greater",
      "LessEqual", "GreaterEqual", "And", "Or", "Not",
      "True", "False", "Null",
      "IntegerPart", "Round", "Floor", "Ceiling",
      (* Phase D-3 fix (2026-06-03): \:6700\:983b\:51fa\:306e\:96c6\:8a08\:30fb\:521d\:7b49\:6570\:5b66\:95a2\:6570\:3002
         \:3044\:305a\:308c\:3082\:526f\:4f5c\:7528\:306e\:306a\:3044\:7d14\:6570\:5b66\:95a2\:6570\:3002"1\:304b\:3089100\:307e\:3067\:306e\:548c" \:306e\:3088\:3046\:306a
         \:57fa\:672c\:7684\:306a ClaudeEval \:7528\:9014\:3067 Sum \:304c\:672a\:77e5 head \:6271\:3044\:306b\:306a\:308a
         RepairNeeded \:3067\:6b62\:307e\:3063\:3066\:3044\:305f\:3002 *)
      "Sum", "Product", "GCD", "LCM", "Factorial", "Binomial",
      "Quotient", "Rational", "Re", "Im", "Conjugate", "Sign",
      "Exp", "Log", "Log2", "Log10",
      "Sin", "Cos", "Tan", "ArcSin", "ArcCos", "ArcTan",
      "Sinh", "Cosh", "Tanh",
      "Pi", "E", "Degree", "GoldenRatio", "Infinity",
      "N", "Rationalize", "Chop", "Clip",
      "Prime", "PrimeQ", "EvenQ", "OddQ", "Divisible",
      "FactorInteger", "Fibonacci", "PowerMod",
      "Numerator", "Denominator", "Mean", "Median", "Variance",
      "StandardDeviation", "Total", "Accumulate", "Differences"
    },
    "DataOps" -> {
      "Map", "Select", "Cases", "Association", "Lookup",
      "List", "Rule", "RuleDelayed",
      "Sort", "SortBy", "Reverse", "Take", "Drop",
      "Append", "Prepend", "Join", "Flatten",
      "Range", "ConstantArray", "Total", "Mean",
      "AssociationMap", "KeyValueMap", "GroupBy", "Counts", "Tally",
      "DeleteDuplicates", "Union", "Intersection", "Complement",
      "Position", "FirstPosition", "First", "Last", "Rest", "Most",
      "AllTrue", "AnyTrue", "NoneTrue", "Count", "MemberQ", "FreeQ",
      "MapIndexed", "MapAt", "MapThread", "Scan", "Fold",
      "Apply", "Thread", "Through",
      "Transpose", "Dimensions", "ArrayDepth",
      "Head", "MatchQ", "Replace", "ReplaceAll",
      "Echo", "Identity", "Composition",
      "Missing", "FailureQ",
      "Short", "Length", "Part", "Keys", "Values"
    },
    "StringOps" -> {
      "Print", "ToString", "StringJoin", "StringLength",
      "StringTake", "StringDrop", "StringReplace",
      "StringCases", "StringContainsQ", "StringSplit",
      "StringForm",
      "StringRepeat", "StringPadLeft", "StringPadRight",
      "StringRiffle", "StringTrim", "StringCount",
      "StringPosition", "StringInsert", "StringDelete",
      "StringMatchQ", "StringStartsQ", "StringEndsQ",
      "TextString", "Characters", "CharacterRange",
      "ToUpperCase", "ToLowerCase"
    },
    "TypeChecks" -> {
      "StringQ", "NumberQ", "IntegerQ", "ListQ", "AssociationQ",
      "NumericQ", "AtomQ", "ValueQ", "OptionValue",
      "Depth", "ByteCount"
    },
    "KernelRead" -> {
      "Notebooks", "InputNotebook", "EvaluationNotebook",
      "Cells", "NotebookRead", "CellObject",
      "Options", "CurrentValue", "AbsoluteOptions",
      "Names", "Context", "Contexts",
      "Needs",
      "DateString", "AbsoluteTime", "Now"
    },
    "Formatting" -> {
      "Row", "Column", "Grid", "TableForm",
      "NumberForm",
      "Style", "Bold", "Italic", "Red", "Blue", "Green",
      "RGBColor", "GrayLevel", "FontSize", "FontColor",
      "Framed", "Panel", "Labeled", "Tooltip",
      "InputForm", "OutputForm", "TraditionalForm",
      "MatrixForm"
    },
    (* Phase D-3 (2026-06-03): Notebook \:30c7\:30fc\:30bf\:69cb\:9020\:30b3\:30f3\:30b9\:30c8\:30e9\:30af\:30bf\:3002
       NotebookWrite (approval head) \:306e\:5f15\:6570\:3068\:3057\:3066\:73fe\:308c\:308b Cell / TextData /
       BoxData / StyleBox / CellGroupData \:7b49\:306f\:526f\:4f5c\:7528\:3092\:6301\:305f\:306a\:3044 inert \:306a
       \:8868\:73fe\:69cb\:9020\:3067\:3042\:308a\:3001\:5358\:4f53\:3067\:306f\:4f55\:3082\:5b9f\:884c\:3057\:306a\:3044\:3002\:3053\:308c\:3089\:304c allowed \:306b
       \:306a\:3044\:3068\:3001NotebookWrite[nb, Cell[...]] \:5168\:4f53\:304c\:672a\:77e5 head (Cell) \:3092\:542b\:3080\:3068
       \:5224\:5b9a\:3055\:308c RepairNeeded \:306b\:306a\:308a\:3001Committer \:627f\:8a8d\:7d4c\:8def\:3067\:5b9f\:884c\:3067\:304d\:306a\:304f\:306a\:308b\:3002
       \:5b9f\:969b\:306e\:66f8\:304d\:8fbc\:307f\:306f NotebookWrite (approval) \:3092\:901a\:3063\:305f\:3068\:304d\:306b\:306e\:307f\:8d77\:304d\:308b\:3002 *)
    "NotebookData" -> {
      "Cell", "CellGroupData", "TextData", "BoxData", "StyleBox",
      "RowBox", "FractionBox", "SuperscriptBox", "SubscriptBox",
      "GridBox", "TagBox", "InterpretationBox", "FormBox",
      "ButtonBox", "TemplateBox", "ExpressionUUID",
      "TextCell", "ExpressionCell", "BoxData",
      "CellTags", "CellLabel", "GeneratedCell"
    }
  |>];

(* \:30ab\:30c6\:30b4\:30ea\:5225\:6709\:52b9/\:7121\:52b9\:5207\:308a\:66ff\:3048 *)
If[!AssociationQ[$NBDisabledCategories],
  $NBDisabledCategories = <||>];

NBEnableCategory[cat_String] := ($NBDisabledCategories[cat] = False);
NBDisableCategory[cat_String] := ($NBDisabledCategories[cat] = True);
NBCategoryEnabled[cat_String] := !TrueQ[$NBDisabledCategories[cat]];

(* $NBAllowedHeads \:306f $NBAllowedHeadsByCategory \:304b\:3089\:81ea\:52d5\:5c0e\:51fa\:ff08\:5f8c\:65b9\:4e92\:63db\:ff09 *)
(* Set/SetDelayed \:306f\:6587\:8108\:4f9d\:5b58\:30c1\:30a7\:30c3\:30af: Module/With/Block \:5185\:306e\:307f\:8a31\:53ef\:3002
   $NBAllowedHeads \:304b\:3089\:306f\:9664\:5916\:3057\:3001iExtractGlobalSets \:3067\:5224\:5b9a\:3059\:308b\:3002
   Phase 16: \:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7\:306e Set \:306f NeedsApproval \:306b\:683c\:4e0a\:3052 *)
If[!ListQ[$NBAllowedHeads],
  $NBAllowedHeads = Flatten[Values[
    Select[$NBAllowedHeadsByCategory,
      NBCategoryEnabled[First[#]] &] /. 
    Rule[k_, v_] :> If[NBCategoryEnabled[k], v, Nothing]]]];
(* \:5b9f\:969b\:306b\:306f\:6bce\:56de\:518d\:8a08\:7b97: \:52d5\:7684\:30ab\:30c6\:30b4\:30ea\:5207\:308a\:66ff\:3048\:5bfe\:5fdc *)
iRecomputeAllowedHeads[] := (
  $NBAllowedHeads = Flatten @ KeyValueMap[
    If[NBCategoryEnabled[#1], #2, {}] &,
    $NBAllowedHeadsByCategory]);
iRecomputeAllowedHeads[];

If[!ListQ[$NBApprovalHeads],
  $NBApprovalHeads = {
    (* NBAccess \:66f8\:304d\:8fbc\:307f\:7cfb *)
    "NBCellWriteCode", "NBCellWriteText", "NBWriteText", "NBWriteCode",
    "NBWriteSmartCode", "NBWriteInputCellAndMaybeEvaluate",
    "NBInsertTextCells", "NBCellSetOptions", "NBCellSetStyle",
    "NBCellSetTaggingRule", "NBSelectCell",
    "NBDeleteCellsByTag", "NBMoveAfterCell",
    "NBMarkCellConfidential", "NBMarkCellDependent", "NBUnmarkCell",
    "NBSetConfidentialTag", "NBSetTaggingRule", "NBDeleteTaggingRule",
    "NBSetSnapshotPrivacyLevel",
    (* desktop action wrapper (spec 5B.7/5B.8): \:627f\:8a8d\:4ed8\:304d\:3067\:30d5\:30a9\:30eb\:30c0\:7b49\:3092\:958b\:304f\:3002
       \:5185\:90e8\:3067 action registry -> iNBExecuteOpenDesktopItem (path \:691c\:67fb) \:3092\:901a\:3059\:3002
       raw SystemOpen \:306f\:4f9d\:7136 Deny\:3002\:3053\:308c\:304c\:6b63\:672c\:306e\:7d4c\:8def\:3002 *)
    "NBOpenFolderWithApproval", "NBExecuteApprovedAction",
    "NBFileWriteCell", "NBFileWriteAllCells",
    "NBMergeNotebookCells",
    (* \:30d5\:30a1\:30a4\:30eb\:64cd\:4f5c *)
    "NBFileOpen", "NBFileClose", "NBFileSave",
    "NBSplitNotebookCells",
    (* Phase A1 (ClaudeEval async-compat spec 5.1):
       \:7d20\:306e NotebookWrite \:306f\:65e2\:5b58\:306e\:3069\:306e head \:96c6\:5408\:306b\:3082\:5165\:3063\:3066\:304a\:3089\:305a
       (\:672a\:77e5 head \:6271\:3044 = RepairNeeded \:306b\:306a\:308b)\:3001
       \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:7531\:6765\:5f0f\:304c notebook \:3092\:76f4\:63a5\:66f8\:304d\:63db\:3048\:308b\:306e\:3092
       \:627f\:8a8d\:30b2\:30fc\:30c8\:306b\:4e57\:305b\:308b\:305f\:3081 approval head \:306b\:6607\:683c\:3059\:308b\:3002 *)
    "NotebookWrite"
  }];

If[!ListQ[$NBDenyHeads],
  $NBDenyHeads = {
    "DeleteFile", "RenameFile", "CopyFile",
    "SystemOpen", "Run", "RunProcess", "StartProcess",
    "Import", "Export",
    "Get", "Put", "PutAppend", "Save",
    "Install", "Uninstall", "URLExecute",
    "CreateProcess", "KillProcess",
    "FileRemove", "DeleteDirectory",
    "SendMail", "CloudDeploy", "CloudPut",
    "Quit", "Exit", "Abort",
    "Unset", "Clear", "Remove",
    (* Phase C-lite (2026-06-03\:3001spec 5A.5.1): \:5916\:90e8\:5b9f\:884c\:30fb\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:30fb
       \:7834\:58ca\:7684 IO \:306e\:660e\:793a Deny \:3092\:88dc\:5f37\:3002C-lite \:306e\:8a9e\:5e79\:5206\:985e\:3067\:3082\:62fe\:3048\:308b\:304c\:3001
       \:660e\:793a\:5217\:6319\:3057\:3066\:304a\:304f\:3053\:3068\:3067\:627f\:8a8d UI \:3092\:51fa\:3055\:305a\:78ba\:5b9f\:306b Deny \:3059\:308b\:3002 *)
    "ExternalEvaluate", "ExternalFunction", "LibraryFunctionLoad",
    "LinkLaunch", "LinkConnect", "Install",
    "SocketConnect", "SocketOpen", "URLSubmit", "URLDownload",
    "URLDownloadSubmit", "CreateFile", "CreateDirectory",
    "OpenWrite", "OpenAppend", "BinaryWrite", "WriteString", "Write",
    "DumpSave", "CloudEvaluate", "CloudSubmit", "CloudDeploy",
    "ServiceExecute", "SendMessage", "MailReceiverFunction",
    "Splice", "FilePrint", "CopyDirectory", "SetDirectory",
    "ResetDirectory", "CreateArchive", "ExtractArchive"
    (* 2026-06-03: "Evaluate" \:3092 Deny \:304b\:3089\:9664\:53bb\:3002ParametricPlot[Evaluate[..]] \:7b49
       \:63cf\:753b\:306e\:5b9a\:77f3\:3092\:5dfb\:304d\:8fbc\:3093\:3067\:5168 Deny \:3057\:3066\:3044\:305f\:3002Evaluate \:306e\:4e2d\:8eab\:306e\:5371\:967a head \:306f
       iExtractAllHeads \:304c {1,Infinity} \:3067\:5225\:9014\:6355\:6349\:3057 Deny \:3059\:308b\:305f\:3081\:3001Evaluate
       \:81ea\:4f53\:3092 Deny \:3059\:308b\:5fc5\:8981\:306f\:306a\:3044\:3002Evaluate \:306f allowlist (HoldComplete \:7b49\:3068
       \:540c\:3058\:884c) \:306b\:3042\:308a\:8a31\:53ef\:6271\:3044\:3002 *)
  }];

(* Phase permission-modes (2026-06-03, spec 5B.3): \:30b0\:30ed\:30fc\:30d0\:30eb permission mode\:3002
   \:6a19\:6e96\:5024 InteractiveSafe\:3002\:81ea\:52d5\:30ef\:30fc\:30af\:30d5\:30ed\:30fc\:3067\:306f WorkflowSafe \:3092\:4f7f\:3046\:3002
   \:63a8\:5968\:5024: ReviewOnly / StrictSafe / InteractiveSafe / WorkflowSafe /
           LegacyInteractive / DangerFullAccess\:3002
   I12: \:5b9f\:884c\:4e2d\:306e\:5224\:5b9a\:3067\:306f global \:3092\:76f4\:63a5\:8aad\:307e\:305a\:3001accessSpec/snapshot \:306b
   \:713c\:304d\:8fbc\:3093\:3060\:5024\:3092\:6b63\:3068\:3059\:308b\:3002 *)
If[!StringQ[$ClaudePermissionMode],
  $ClaudePermissionMode = "InteractiveSafe"];

(* spec 5B.4: DangerFullAccess \:3067\:3082 HardDeny \:3092\:7121\:6761\:4ef6 Permit \:306b\:3057\:306a\:3044\:3002
   \:5225\:30d5\:30e9\:30b0\:3067\:306e\:307f HardDeny \:3092\:627f\:8a8d\:53ef\:80fd\:306b\:6607\:683c\:3059\:308b (\:65e2\:5b9a False)\:3002 *)
If[!BooleanQ[$ClaudeAllowHardDenyOverride],
  $ClaudeAllowHardDenyOverride = False];

(* \:51fa\:529b\:30e2\:30fc\:30c9 (\:5bfe\:7b562, 2026-06-03)\:3002Streaming=\:9010\:6b21 (\:65e2\:5b9a) / Batch=\:96c6\:7d04\:3002
   \:6700\:512a\:5148\:306f FrontEnd/\:30ab\:30fc\:30cd\:30eb\:30d6\:30ed\:30c3\:30af\:56de\:907f\:3002BlockingRisk \:304c MayBlockFrontEnd \:306e
   \:51fa\:529b\:306f Streaming \:3067\:3082\:81ea\:52d5\:96c6\:7d04\:3002\:5b9f\:884c\:4e2d\:306f accessSpec/runtime \:30e1\:30bf\:30c7\:30fc\:30bf\:306e
   \:713c\:304d\:8fbc\:307f\:5024\:3092\:6b63\:3068\:3059\:308b\:3002 *)
If[!StringQ[$ClaudeOutputMode],
  $ClaudeOutputMode = "Streaming"];

(* NBResolveOutputMode[mode, blockingRisk]: \:5b9f\:969b\:306b\:300c\:9010\:6b21\:51fa\:529b\:300d\:3059\:308b\:304b
   \:300c\:96c6\:7d04 (\:9045\:5ef6\:51fa\:529b)\:300d\:3059\:308b\:304b\:3092\:8fd4\:3059\:7d14\:7c8b\:95a2\:6570\:3002\:6700\:512a\:5148\:306f\:30d6\:30ed\:30c3\:30af\:56de\:907f:
   - blockingRisk \:304c "MayBlockFrontEnd" \:306a\:3089\:3001mode \:304c Streaming \:3067\:3082
     "Deferred" \:3092\:8fd4\:3059 (\:30d6\:30ed\:30c3\:30af\:3059\:308b\:304f\:3089\:3044\:306a\:3089\:6700\:5f8c\:306b\:307e\:3068\:3081\:308b)\:3002
   - mode \:304c "Batch" \:306a\:3089\:5e38\:306b "Deferred"\:3002
   - \:305d\:308c\:4ee5\:5916 (Streaming \:304b\:3064\:30d6\:30ed\:30c3\:30af\:306a\:3057) \:306f "Immediate"\:3002
   \:8fd4\:308a\:5024: "Immediate" (\:5373\:51fa\:529b) | "Deferred" (\:96c6\:7d04)\:3002 *)
NBResolveOutputMode[mode_String, blockingRisk_String] :=
  Which[
    blockingRisk === "MayBlockFrontEnd", "Deferred",
    mode === "Batch", "Deferred",
    True, "Immediate"];
NBResolveOutputMode[mode_String] := NBResolveOutputMode[mode, "None"];
NBResolveOutputMode[] := NBResolveOutputMode[$ClaudeOutputMode, "None"];
(* \:4e0d\:6b63\:306a mode \:306f\:5b89\:5168\:5074 (\:5373\:51fa\:529b) \:306b\:5012\:3059\:3002Batch \:3067\:30d6\:30ed\:30c3\:30af\:306a\:3057\:306e\:8aa4\:5165\:529b\:3067\:3082
   \:51fa\:529b\:304c\:6d88\:3048\:308b\:3088\:308a\:51fa\:308b\:65b9\:304c\:5b89\:5168\:3002 *)
NBResolveOutputMode[___] := "Immediate";

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: NBValidateHeldExpr
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBValidateHeldExpr] = {"AllowedHeads" -> Automatic,
  "ApprovalHeads" -> Automatic, "DenyHeads" -> Automatic,
  "LabelCheck" -> Automatic, "PolicySnapshot" -> None};
Options[iNBValidateHeldExprBase] = Options[NBValidateHeldExpr];

(* Phase permission-modes (2026-06-03, spec 5B.2A): \:65e2\:5b58\:306e\:5224\:5b9a\:672c\:4f53\:3092
   iNBValidateHeldExprBase \:306b\:5206\:96e2\:3002\:3053\:308c\:304c\:5f93\:6765\:306e Decision \:3092\:8fd4\:3059
   \:300cBaseDecision \:751f\:6210\:5668\:300d\:3002NBValidateHeldExpr \:306f\:3053\:308c\:3092\:547c\:3073\:3001
   \:672b\:5c3e\:3067 EffectClass/ApprovalEligibility/PermissionMode \:5909\:63db\:3092
   \:4e00\:5ea6\:3060\:3051\:9069\:7528\:3059\:308b\:8584\:3044\:30e9\:30c3\:30d1\:30fc (\:4e0b\:90e8\:3067\:5b9a\:7fa9)\:3002 *)
iNBValidateHeldExprBase[heldExpr_, accessSpec_Association, opts:OptionsPattern[]] :=
  Module[{allowed, approval, deny, heads, denied, needsApproval, unknown,
          scopedSyms,
          labelCheck, snapshot, effectiveAccessSpec},
    If[!MatchQ[heldExpr, HoldComplete[_]],
      Return[<|"Decision" -> "Deny",
        "ReasonClass" -> "ModelFormatError",
        "VisibleExplanation" -> "Expected HoldComplete[expr], got " <> ToString[Head[heldExpr]],
        "SanitizedExpr" -> None|>]];

    (* Phase B: snapshot mode \:5224\:5b9a\:3002
       PolicySnapshot \:304c\:6e21\:3055\:308c\:305f\:5834\:5408\:306f snapshot \:3092\:5224\:5b9a\:5165\:529b\:306e\:6b63\:672c\:3068\:3057\:3001
       iRecomputeAllowedHeads[] \:3084\:30ab\:30c6\:30b4\:30ea global \:3092\:53c2\:7167\:3057\:306a\:3044\:3002
       snapshot \:306a\:3057 (None) \:306e\:5834\:5408\:306f\:5f93\:6765\:901a\:308a\:3002 *)
    snapshot = OptionValue["PolicySnapshot"];
    If[AssociationQ[snapshot],
      (* snapshot mode: \:5404 head \:96c6\:5408\:306f snapshot \:7531\:6765\:3002
         opts \:660e\:793a\:6307\:5b9a\:304c\:3042\:308c\:3070\:305d\:308c\:3092\:512a\:5148\:3057\:3001\:306a\:3051\:308c\:3070 snapshot\:3002
         iRecomputeAllowedHeads[] \:306f\:547c\:3070\:306a\:3044\:3002 *)
      allowed  = Replace[OptionValue["AllowedHeads"],  Automatic -> Lookup[snapshot, "AllowedHeads", {}]];
      approval = Replace[OptionValue["ApprovalHeads"], Automatic -> Lookup[snapshot, "ApprovalHeads", {}]];
      deny     = Replace[OptionValue["DenyHeads"],     Automatic -> Lookup[snapshot, "DenyHeads", {}]];
      (* confidential \:691c\:67fb\:7528: snapshot \:7531\:6765 ConfidentialSymbols \:3092 accessSpec \:306b\:6ce8\:5165\:3002
         accessSpec \:5074\:306b\:65e2\:306b\:660e\:793a\:6307\:5b9a\:304c\:3042\:308c\:3070\:305d\:3061\:3089\:3092\:5c0a\:91cd\:3059\:308b\:3002 *)
      effectiveAccessSpec = If[KeyExistsQ[accessSpec, "ConfidentialSymbols"],
        accessSpec,
        Append[accessSpec, "ConfidentialSymbols" -> Lookup[snapshot, "ConfidentialSymbols", {}]]],
      (* non-snapshot mode: \:5f93\:6765\:901a\:308a global \:3092\:518d\:8a08\:7b97\:3057\:3066\:53c2\:7167 *)
      iRecomputeAllowedHeads[];
      allowed  = Replace[OptionValue["AllowedHeads"],  Automatic -> $NBAllowedHeads];
      approval = Replace[OptionValue["ApprovalHeads"], Automatic -> $NBApprovalHeads];
      deny     = Replace[OptionValue["DenyHeads"],     Automatic -> $NBDenyHeads];
      effectiveAccessSpec = accessSpec
    ];

    (* \:5f0f\:4e2d\:306e\:5168 head \:3092\:62bd\:51fa *)
    heads = iExtractAllHeads[heldExpr];
    
    (* \:7981\:6b62 head \:30c1\:30a7\:30c3\:30af *)
    denied = Select[heads, MemberQ[deny, #] &];
    If[Length[denied] > 0,
      Return[<|"Decision" -> "Deny",
        "ReasonClass" -> "ForbiddenHead",
        "VisibleExplanation" -> "Forbidden heads: " <> StringRiffle[denied, ", "],
        "SanitizedExpr" -> iSanitizeExpr[heldExpr]|>]];
    
    (* \:627f\:8a8d\:8981 head \:30c1\:30a7\:30c3\:30af *)
    needsApproval = Select[heads, MemberQ[approval, #] &];
    If[Length[needsApproval] > 0,
      Return[<|"Decision" -> "NeedsApproval",
        "ReasonClass" -> "AccessEscalationRequired",
        "VisibleExplanation" -> "Heads requiring approval: " <> StringRiffle[needsApproval, ", "],
        (* P0 \:6697\:5b9a\:627f\:8a8d\:30e2\:30fc\:30c9 (Committer) \:7528\:306b\:3001\:627f\:8a8d\:3092\:8981\:3057\:305f
           head \:30ea\:30b9\:30c8\:3092\:69cb\:9020\:5316\:3057\:3066\:8fd4\:3059\:3002iNBExecPermitCheck \:304c
           \:300c\:5168 head \:304c\:627f\:8a8d\:53ef\:80fd head \:304b\:300d\:3092\:6587\:5b57\:5217\:30d1\:30fc\:30b9\:305b\:305a\:5224\:5b9a\:3067\:304d\:308b\:3002 *)
        "ApprovalHeads" -> needsApproval,
        "SanitizedExpr" -> heldExpr|>]];
    
    (* \:672a\:77e5 head \:30c1\:30a7\:30c3\:30af \[LongDash] \:305f\:3060\:3057 Set/SetDelayed \:306f\:6587\:8108\:4f9d\:5b58\:3067\:5224\:5b9a *)
    (* Phase 16: Set/SetDelayed \:306f\:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7\:306a\:3089 NeedsApproval *)
    Module[{globalSets, setHeadsInExpr},
      setHeadsInExpr = Select[heads, MemberQ[{"Set", "SetDelayed"}, #] &];
      If[Length[setHeadsInExpr] > 0,
        globalSets = iExtractGlobalSets[heldExpr];
        If[Length[globalSets] > 0,
          Return[<|"Decision" -> "NeedsApproval",
            "ReasonClass" -> "GlobalSetRequiresApproval",
            "VisibleExplanation" ->
              "Global-scope " <> StringRiffle[DeleteDuplicates[globalSets], "/"] <>
              " detected. Only Set/SetDelayed inside Module/With/Block is auto-permitted.",
            "SanitizedExpr" -> heldExpr|>]]]];
    
    (* \:904e\:5270\:53cd\:5fa9\:30ac\:30fc\:30c9 (2026-06-29): trusted package head (SourceVault* \:7b49) \:3092
       \:5927\:304d\:306a literal \:53cd\:5fa9\:3067\:56de\:3059\:751f\:6210\:30b3\:30fc\:30c9 (\:4f8b: Do[SourceVaultIngest[..], {10000}])
       \:306f\:3001head \:81ea\:4f53\:304c\:627f\:8a8d\:4e0d\:8981\:3067\:3082 NeedsApproval \:306b\:6607\:683c\:3055\:305b\:308b\:3002
       \:95be\:5024 $NBTrustedHeadIterationLimit (\:65e2\:5b9a 100)\:3002\:5b9f\:884c\:6642\:306e\:9632\:6ce2\:5824\:306f
       SourceVault \:5074 SourceVaultRateLimit\:3002 *)
    Module[{iterHits = iNBExcessiveTrustedIterationHits[heldExpr]},
      If[Length[iterHits] > 0,
        Return[<|"Decision" -> "NeedsApproval",
          "ReasonClass" -> "ExcessiveIterationRequiresApproval",
          "VisibleExplanation" ->
            "Trusted-package head inside large literal iteration (" <>
            StringRiffle[
              (Lookup[#, "Construct", "?"] <> " x " <>
               ToString[Lookup[#, "Count", "?"]]) & /@ iterHits, ", "] <>
            "); limit = " <> ToString[$NBTrustedHeadIterationLimit],
          "IterationHits" -> iterHits,
          "SanitizedExpr" -> heldExpr|>]]];

    (* unknown head \:306e\:6271\:3044 (Phase C-lite, spec I8/I9/5A)\:3002
       \:5f93\:6765\:306f\:4e00\:5f8b RepairNeeded \:3060\:3063\:305f\:304c\:3001Mathematica \:306e\:7d14\:7c8b\:95a2\:6570\:3092
       allow list \:5316\:3059\:308b\:306e\:306f\:975e\:73fe\:5b9f\:7684\:306a\:305f\:3081\:3001\:6587\:8108 + \:526f\:4f5c\:7528\:8a9e\:5e79\:3067\:518d\:5206\:985e\:3059\:308b\:3002
       \:3053\:3053\:306b\:6765\:308b head \:306f Deny \:3067\:3082 Approval \:3067\:3082 Allowed \:3067\:3082
       Set/SetDelayed \:3067\:3082\:306a\:3044\:3082\:306e\:3002 *)
    (* held \:4e2d\:306e Module/Block/With/Function \:7b49\:306e\:5c40\:6240\:5909\:6570\:30fb\:30d1\:30bf\:30fc\:30f3\:5909\:6570\:30fb
       \:5b9a\:7fa9\:95a2\:6570\:540d\:3092\:627f\:8a8d\:5bfe\:8c61\:304b\:3089\:9664\:5916\:3059\:308b (\:3053\:308c\:3089\:306f\:30e6\:30fc\:30b6\:30fc\:5b9a\:7fa9\:306e\:5b89\:5168\:306a\:30ed\:30fc\:30ab\:30eb)\:3002
       2026-06-03: Module[{traj},traj[x_]:=..] \:306e traj \:304c NeedsApproval \:306b
       \:306a\:308b\:904e\:5270\:5224\:5b9a\:3078\:306e\:5bfe\:51e6\:3002 *)
    scopedSyms = iNBExtractScopedSymbols[heldExpr];
    unknown = Select[heads,
      !MemberQ[allowed, #] && !MemberQ[approval, #] && !MemberQ[deny, #] &&
      !MemberQ[{"Set", "SetDelayed"}, #] &&
      !MemberQ[scopedSyms, #] &];
    If[Length[unknown] > 0,
      (* confidential leak \:306f\:5206\:985e\:3088\:308a\:5148\:306b\:78ba\:8a8d (leak \:306f\:627f\:8a8d\:3057\:3066\:3082\:4e0d\:53ef)\:3002
         snapshot mode \:3067\:306f effectiveAccessSpec \:306b snapshot \:7531\:6765 conf \:6ce8\:5165\:6e08\:307f\:3002 *)
      If[iContainsConfidentialLeak[heldExpr, effectiveAccessSpec],
        Return[<|"Decision" -> "Deny",
          "ReasonClass" -> "ConfidentialLeakRisk",
          "VisibleExplanation" -> "Expression may leak confidential data",
          "SanitizedExpr" -> iSanitizeExpr[heldExpr]|>]];
      (* C-lite \:69cb\:9020\:5206\:985e\:3002unknown head \:306e\:540d\:524d-\:6587\:8108\:30da\:30a2\:3092\:53d6\:308a\:3001
         System` \:7d14\:7c8b -> Permit\:3001System` \:526f\:4f5c\:7528\:8a9e\:5e79 / user \:6587\:8108 -> NeedsApproval\:3002 *)
      Module[{pairs, unknownPairs, cls},
        pairs = iNBHeadNameContextPairs[heldExpr];
        unknownPairs = Select[pairs, MemberQ[unknown, First[#]] &];
        cls = iNBClassifyUnknownHeads[unknownPairs];
        Which[
          cls["Decision"] === "Permit",
            (* System` \:7d14\:7c8b\:3063\:307d\:3044\:7d44\:307f\:8fbc\:307f\:306e\:307f\:3002allowed \:5916\:3060\:304c\:5b89\:5168\:3068\:307f\:306a\:3057 Permit\:3002
               \:4ee5\:964d\:306e confidential / label \:30c1\:30a7\:30c3\:30af\:3078\:9032\:3080\:305f\:3081 Return \:305b\:305a\:901a\:904e\:3002 *)
            Null,
          cls["Decision"] === "NeedsApproval",
            Return[<|"Decision" -> "NeedsApproval",
              "ReasonClass" -> "UnknownHeadRequiresApproval",
              "VisibleExplanation" ->
                "Unlisted heads requiring approval: " <>
                StringRiffle[Lookup[cls, "ApprovalHeads", unknown], ", "],
              "ApprovalHeads" -> Lookup[cls, "ApprovalHeads", unknown],
              "SanitizedExpr" -> heldExpr|>],
          True,
            Return[<|"Decision" -> "NeedsApproval",
              "ReasonClass" -> "UnknownHeadRequiresApproval",
              "VisibleExplanation" ->
                "Unlisted heads: " <> StringRiffle[unknown, ", "],
              "ApprovalHeads" -> unknown,
              "SanitizedExpr" -> heldExpr|>]
        ]]];
    
    (* confidential leak \:30c1\:30a7\:30c3\:30af (allowed head \:306e\:307f\:306e\:5f0f\:306b\:5bfe\:3057\:3066\:3082\:5b9f\:65bd) *)
    (* snapshot mode \:3067\:306f effectiveAccessSpec \:306b snapshot \:7531\:6765 conf \:304c\:6ce8\:5165\:6e08\:307f\:3002 *)
    If[iContainsConfidentialLeak[heldExpr, effectiveAccessSpec],
      Return[<|"Decision" -> "Deny",
        "ReasonClass" -> "ConfidentialLeakRisk",
        "VisibleExplanation" -> "Expression may leak confidential data",
        "SanitizedExpr" -> iSanitizeExpr[heldExpr]|>]];
    
    (* \[HorizontalLine]\[HorizontalLine] Phase 15: label-aware validation \[HorizontalLine]\[HorizontalLine]
       accessSpec \:306b PolicyLabel / SinkLabel \:304c\:8a2d\:5b9a\:3055\:308c\:3066\:3044\:308b\:5834\:5408\:306e\:307f\:5b9f\:884c\:3002
       head \:30c1\:30a7\:30c3\:30af\:901a\:904e\:5f8c\:306b\:3001\:30e9\:30d9\:30eb\:534a\:9806\:5e8f\:306b\:57fa\:3065\:304f flow \:5224\:5b9a\:3092\:884c\:3046\:3002 *)
    labelCheck = Replace[OptionValue["LabelCheck"], Automatic ->
      KeyExistsQ[accessSpec, "PolicyLabel"] ||
      KeyExistsQ[accessSpec, "SinkLabel"]];
    If[TrueQ[labelCheck],
      Module[{obj, req, authResult, authDecision},
        obj = <|
          "PolicyLabel"       -> Lookup[accessSpec, "PolicyLabel", NBLabelBottom[]],
          "ContainerLabel"    -> Lookup[accessSpec, "ContainerLabel", NBLabelBottom[]],
          "AccessLevel"       -> Lookup[accessSpec, "AccessLevel", 0.5],
          "EffectiveRiskScore" -> Lookup[accessSpec, "EffectiveRiskScore",
            Lookup[accessSpec, "AccessLevel", 0.5]]|>;
        req = <|
          "SinkLabel"   -> Lookup[accessSpec, "SinkLabel", NBLabelBottom[]],
          "Sink"        -> Lookup[accessSpec, "Sink", "CloudLLM"],
          "Environment" -> Lookup[accessSpec, "Environment", "Notebook"],
          "Principal"   -> Lookup[accessSpec, "Principal", None]|>;
        authResult = NBAuthorize[obj, req];
        authDecision = authResult["Decision"];
        
        (* NBAuthorize \:306e\:7d50\:679c\:3092 validation decision \:306b\:30de\:30c3\:30d4\:30f3\:30b0 *)
        Which[
          authDecision === "Deny",
            Return[<|"Decision" -> "Deny",
              "ReasonClass" -> authResult["ReasonClass"],
              "VisibleExplanation" -> authResult["VisibleExplanation"],
              "SanitizedExpr" -> iSanitizeExpr[heldExpr],
              "RouteAdvice" -> authResult["RouteAdvice"]|>],
          authDecision === "RequireApproval",
            Return[<|"Decision" -> "NeedsApproval",
              "ReasonClass" -> authResult["ReasonClass"],
              "VisibleExplanation" -> authResult["VisibleExplanation"],
              "SanitizedExpr" -> heldExpr,
              "RouteAdvice" -> authResult["RouteAdvice"]|>],
          authDecision === "Screen",
            (* Screen \:306f advisory \[LongDash] Permit \:3059\:308b\:304c RouteAdvice \:306b\:53cd\:6620 *)
            Null,
          True, (* Permit *)
            Null
        ]]];
    
    <|"Decision" -> "Permit",
      "ReasonClass" -> "None",
      "VisibleExplanation" -> "",
      "SanitizedExpr" -> heldExpr,
      "RouteAdvice" -> NBRouteDecision[accessSpec]|>
  ];

(* ============================================================
   Phase permission-modes (2026-06-03, spec 5B.2A): NBValidateHeldExpr
   \:30e9\:30c3\:30d1\:30fc = base \:5224\:5b9a + EffectClass/ApprovalEligibility + mode \:5909\:63db
   ============================================================
   1. iNBValidateHeldExprBase \:3067\:5f93\:6765\:306e Decision (= BaseDecision) \:3092\:5f97\:308b
   2. \:5f0f\:4e2d\:306e head \:304b\:3089 EffectClass \:3092\:96c6\:7d04\:3057 ApprovalEligibility \:3092\:6c7a\:3081\:308b
   3. base Decision \:3068 EffectClass eligibility \:3092\:5408\:6210 (\:53b3\:3057\:3044\:65b9)
   4. accessSpec["PermissionMode"] (I12: global \:3092\:8aad\:307f\:76f4\:3055\:306a\:3044) \:3067\:5909\:63db
   5. Decision (\:5909\:63db\:5f8c) \:3068 BaseDecision \:3092\:4f75\:5b58\:3055\:305b\:3001\:8ffd\:52a0 metadata \:3092\:8fd4\:3059
   \:65e2\:5b58\:306e Switch[r["Decision"], ...] \:306f Decision \:30ad\:30fc\:3067\:305d\:306e\:307e\:307e\:52d5\:304f\:3002 *)
NBValidateHeldExpr[heldExpr_, accessSpec_Association, opts:OptionsPattern[]] :=
  Module[{base, baseDecision, mode, pairs, ecInfos, aggEC, aggPlacement,
          aggBlocking, requiresFinal, baseElig, ecElig, finalElig,
          transformed, result},
    base = iNBValidateHeldExprBase[heldExpr, accessSpec, opts];
    baseDecision = Lookup[base, "Decision", "Deny"];

    (* permission mode \:306f accessSpec \:304b\:3089\:8aad\:3080 (I12)\:3002\:7121\:3051\:308c\:3070 global \:3092
       \:521d\:671f\:5024\:3068\:3057\:3066\:4f7f\:3046\:304c\:3001\:5b9f\:884c\:7d4c\:8def\:3067\:306f accessSpec \:306b\:713c\:304d\:8fbc\:307e\:308c\:3066\:3044\:308b\:524d\:63d0\:3002 *)
    mode = Lookup[accessSpec, "PermissionMode", $ClaudePermissionMode];
    If[!StringQ[mode], mode = "InteractiveSafe"];

    (* base Decision \:3092 ApprovalEligibility \:306b\:30de\:30c3\:30d7 *)
    baseElig = Switch[baseDecision,
      "Deny", "HardDeny",
      "RepairNeeded", "RepairRequired",
      "NeedsApproval", "AskUserAllowed",
      "Permit", "AutoPermit",
      _, "AskUserAllowed"];

    (* \:5f0f\:4e2d\:306e head \:304b\:3089 EffectClass \:3092\:96c6\:7d04 (heldExpr \:304c HoldComplete \:306e\:3068\:304d) *)
    (* \:5f0f\:4e2d\:306e head \:304b\:3089 EffectClass \:3092\:96c6\:7d04 (heldExpr \:304c HoldComplete \:306e\:3068\:304d)\:3002
       2026-06-03: base \:5224\:5b9a\:3068\:540c\:69d8\:3001Module/Block/With \:7b49\:306e\:30b9\:30b3\:30fc\:30d7\:5c40\:6240\:5909\:6570
       (traj \:7b49\:306e\:30e6\:30fc\:30b6\:30fc\:5b9a\:7fa9\:30ed\:30fc\:30ab\:30eb\:95a2\:6570) \:3092\:9664\:5916\:3059\:308b\:3002\:3053\:308c\:3092\:9664\:5916\:3057\:306a\:3044\:3068
       traj \:304c Global` \:6587\:8108\:306e UnknownUserCode \:3068\:5224\:5b9a\:3055\:308c\:3001base \:304c Permit \:3067\:3082
       mode \:5909\:63db\:5c64\:3067 eligibility \:304c AskUserAllowed \:306b\:6607\:683c\:3057 NeedsApproval \:306b
       \:306a\:308b (Reason=None \:306e NeedsApproval \:306e\:539f\:56e0)\:3002 *)
    pairs = If[MatchQ[heldExpr, HoldComplete[_]],
      Module[{allPairs, scoped},
        allPairs = iNBHeadNameContextPairs[heldExpr];
        scoped = iNBExtractScopedSymbols[heldExpr];
        Select[allPairs, !MemberQ[scoped, First[#]] &]],
      {}];
    ecInfos = iNBHeadEffectClass[#[[1]], #[[2]]] & /@ pairs;
    (* \:6700\:3082\:53b3\:3057\:3044 EffectClass eligibility \:3092\:63a1\:308b *)
    ecElig = If[Length[ecInfos] === 0, "AutoPermit",
      Module[{eligs},
        eligs = iNBEffectClassToEligibility[Lookup[#, "EffectClass", "PureComputation"]] & /@ ecInfos;
        First @ MaximalBy[eligs, iNBEligibilityRank, 1]]];
    (* ExecutionPlacement / BlockingRisk / RequiresFinalNode \:3092\:96c6\:7d04 *)
    aggPlacement = If[Length[ecInfos] === 0, "SubkernelSafe",
      Module[{places},
        places = Lookup[#, "ExecutionPlacement", "SubkernelSafe"] & /@ ecInfos;
        (* \:53b3\:3057\:3055\:9806: DesktopAction/FrontEndRequired > MainKernelOnly > Subkernel *)
        Which[
          MemberQ[places, "DesktopAction"], "DesktopAction",
          MemberQ[places, "FrontEndRequired"], "FrontEndRequired",
          MemberQ[places, "FileSystemWrite"], "FileSystemWrite",
          MemberQ[places, "MainKernelOnly"], "MainKernelOnly",
          MemberQ[places, "FileSystemReadOnly"], "FileSystemReadOnly",
          True, "SubkernelSafe"]]];
    aggBlocking = If[Length[ecInfos] === 0, "None",
      Module[{risks},
        risks = Lookup[#, "BlockingRisk", "None"] & /@ ecInfos;
        Which[
          MemberQ[risks, "MayBlockFrontEnd"], "MayBlockFrontEnd",
          MemberQ[risks, "PossiblyLongOrLargeResult"], "PossiblyLongOrLargeResult",
          MemberQ[risks, "PossiblyLong"], "PossiblyLong",
          True, "None"]]];
    requiresFinal = AnyTrue[ecInfos, TrueQ[Lookup[#, "RequiresFinalNode", False]] &];
    aggEC = If[Length[ecInfos] === 0, "PureComputation",
      Module[{ecs},
        ecs = Lookup[#, "EffectClass", "PureComputation"] & /@ ecInfos;
        (* \:4ee3\:8868 EffectClass \:306f specificity \:9806\:3067\:63a1\:308b\:3002eligibility \:540c\:7387
           (\:4f8b: Plot=GraphicsComputation \:3082 Sin=PureComputation \:3082 AutoPermit)
           \:306e\:3068\:304d eligibility rank \:3060\:3051\:3067\:306f head \:8d70\:67fb\:9806\:306b\:4f9d\:5b58\:3057\:3066\:3057\:307e\:3046\:305f\:3081\:3001
           \:3088\:308a\:5177\:4f53\:7684\:306a (= PureComputation \:3067\:306a\:3044\:3001override \:7531\:6765\:306e) EffectClass
           \:3092\:512a\:5148\:3059\:308b\:3002\:7b2c1\:30ad\:30fc: eligibility rank\:3001\:7b2c2\:30ad\:30fc: specificity rank\:3002 *)
        First @ MaximalBy[ecs,
          {iNBEligibilityRank[iNBEffectClassToEligibility[#]],
           iNBEffectClassSpecificity[#]} &, 1]]];

    (* base eligibility \:3068 EffectClass eligibility \:306e\:53b3\:3057\:3044\:65b9\:3092\:63a1\:308b\:3002
       \:4f8b: base \:304c Permit (AutoPermit) \:3067\:3082 EffectClass \:304c DesktopAction
       (AskUserAllowed) \:306a\:3089 AskUserAllowed \:306b\:4e0a\:3052\:308b\:3002
       \:9006\:306b base \:304c Deny (HardDeny) \:306a\:3089 EffectClass \:304c\:3069\:3046\:3042\:308c HardDeny\:3002 *)
    finalElig = If[iNBEligibilityRank[baseElig] >= iNBEligibilityRank[ecElig],
      baseElig, ecElig];

    (* PermissionMode \:5909\:63db *)
    transformed = iNBApplyPermissionMode[finalElig, mode];

    (* \:7d50\:679c\:5408\:6210: base \:3092\:4fdd\:3061\:3064\:3064 Decision \:3092\:5909\:63db\:5f8c\:306b\:5dee\:3057\:66ff\:3048\:3001
       BaseDecision \:3068 metadata \:3092\:8ffd\:52a0\:3002VisibleExplanation/ReasonClass/
       ApprovalHeads/SanitizedExpr \:7b49\:306e base \:7531\:6765\:30ad\:30fc\:306f\:4fdd\:6301\:3002 *)
    result = base;
    result["BaseDecision"] = baseDecision;
    result["Decision"] = transformed["Decision"];
    result["EffectClass"] = aggEC;
    result["ApprovalEligibility"] = finalElig;
    result["ExecutionPlacement"] = aggPlacement;
    result["BlockingRisk"] = aggBlocking;
    result["RequiresFinalNode"] = requiresFinal;
    result["ExecutionDisposition"] = transformed["ExecutionDisposition"];
    result["AllowApprovalUI"] = transformed["AllowApprovalUI"];
    result["MayExecute"] = transformed["MayExecute"];
    result["PermissionMode"] = mode;
    result["ModeTransformApplied"] = True;
    result
  ];


(* head \:62bd\:51fa\:30d8\:30eb\:30d1\:30fc: \:5f0f\:4e2d\:306e\:5168\:30b7\:30f3\:30dc\:30eb head \:3092\:6587\:5b57\:5217\:30ea\:30b9\:30c8\:3067\:8fd4\:3059\:3002 *)
iExtractAllHeads[held_HoldComplete] :=
  DeleteDuplicates @ Cases[
    held,
    s_Symbol[___] :> SymbolName[Unevaluated[s]],
    {1, Infinity}];

iExtractAllHeads[_] := {};

(* iNBExtractScopedSymbols: held \:5f0f\:4e2d\:306e Module/Block/With/Function/
   DynamicModule/Manipulate \:7b49\:306e\:30b9\:30b3\:30fc\:30d7\:5c40\:6240\:5909\:6570\:3068\:3001SetDelayed/Function \:306e
   \:30d1\:30bf\:30fc\:30f3\:5909\:6570 (f[x_]:=.. \:306e x \:7b49\:3001\:5b9a\:7fa9\:3055\:308c\:305f\:95a2\:6570\:540d f \:3082\:542b\:3080) \:306e\:30b7\:30f3\:30dc\:30eb\:540d\:3092
   \:62bd\:51fa\:3059\:308b\:3002\:3053\:308c\:3089\:306f\:30e6\:30fc\:30b6\:30fc\:304c\:65b0\:898f\:306b\:675f\:7e1b\:3059\:308b\:5b89\:5168\:306a\:30ed\:30fc\:30ab\:30eb\:3067\:3042\:308a\:3001unknown
   head \:306e\:627f\:8a8d\:5bfe\:8c61\:304b\:3089\:9664\:5916\:3059\:308b (L388 \:306e\:65b9\:91dd: \:30b9\:30b3\:30fc\:30d4\:30f3\:30b0\:5c40\:6240\:5909\:6570\:306f\:9664\:5916)\:3002
   2026-06-03: C-lite \:306e held \:5f0f\:30d9\:30fc\:30b9 unknown \:5224\:5b9a\:306b\:30ed\:30fc\:30ab\:30eb\:9664\:5916\:304c\:7121\:304f\:3001
   Module[{traj},traj[x_]:=..] \:306e traj \:304c Global` \:6587\:8108 head \:3068\:3057\:3066
   NeedsApproval \:306b\:306a\:3063\:3066\:3044\:305f\:554f\:984c\:3078\:306e\:5bfe\:51e6\:3002 *)
iNBExtractScopedSymbols[held_HoldComplete] :=
  Module[{codeStr, scopeVars, patVars, definedFns},
    (* held \:3092 InputForm \:6587\:5b57\:5217\:5316\:3057\:3001\:5b9f\:7e3e\:3042\:308b\:6587\:5b57\:5217\:30d9\:30fc\:30b9\:62bd\:51fa\:3092\:518d\:5229\:7528\:3059\:308b\:3002
       held \:5f0f\:30d1\:30bf\:30fc\:30f3\:30de\:30c3\:30c1\:306f Set \:7b49\:306e\:8a55\:4fa1\:526f\:4f5c\:7528\:30ea\:30b9\:30af\:304c\:3042\:308b\:305f\:3081\:907f\:3051\:308b\:3002
       2026-06-03: \:5f53\:521d Cases \:30d9\:30fc\:30b9\:3067\:5b9f\:88c5\:3057\:305f\:304c EDT-7/8 \:304c Fail\:3002\:6587\:5b57\:5217\:65b9\:5f0f\:306b\:5909\:66f4\:3002 *)
    codeStr = Quiet @ Check[
      ToString[held /. HoldComplete[e_] :> HoldForm[e], InputForm],
      ""];
    If[!StringQ[codeStr] || codeStr === "", Return[{}, Module]];
    (* Module/Block/With/Function \:306e\:5c40\:6240\:5909\:6570 {a, b=1, c} \:306e\:540d\:524d *)
    scopeVars = iExtractScopeVars[codeStr];
    (* \:30d1\:30bf\:30fc\:30f3\:5909\:6570 x_ / x__ \:306e\:540d\:524d *)
    patVars = iExtractPatternVars[codeStr];
    (* \:5b9a\:7fa9\:95a2\:6570\:540d: f[..]:=.. \:3084 f[..]=.. \:3084 g=.. \:306e\:5de6\:8fba\:30b7\:30f3\:30dc\:30eb\:3002
       := (SetDelayed) \:3068 = (Set) \:306e\:4e21\:65b9\:3092\:8a31\:3059\:3002== (Equal) \:306f\:9664\:5916\:3002 *)
    definedFns = DeleteDuplicates @ StringCases[codeStr,
      RegularExpression[
        "(?<![\\p{L}\\p{N}$`])([\\p{L}$][\\p{L}\\p{N}$]*)\\s*(?:\\[[^\\]]*\\])?\\s*(?::=|(?<![=<>!])=(?!=))"] :>
        "$1"];
    DeleteDuplicates @ Flatten[{scopeVars, patVars, definedFns}]
  ];

iNBExtractScopedSymbols[_] := {};

(* ============================================================
   Phase C-lite (2026-06-03, spec 5A): unknown head \:306e\:69cb\:9020\:7684\:5b89\:5168\:5206\:985e
   ============================================================
   \:5f93\:6765\:306f allowed \:306b\:7121\:3044 head \:3092\:4e00\:5f8b RepairNeeded \:306b\:3057\:3066\:3044\:305f\:304c\:3001
   Mathematica \:306e\:6570\:4e07\:306e\:7d14\:7c8b\:95a2\:6570\:3092 allow list \:5316\:3059\:308b\:306e\:306f\:975e\:73fe\:5b9f\:7684\:3002
   I8/I9 \:306b\:5f93\:3044\:3001unknown head \:3092\:300c\:6587\:8108 + \:526f\:4f5c\:7528\:8a9e\:5e79\:300d\:3067\:518d\:5206\:985e\:3059\:308b:
     - System` \:6587\:8108 \:304b\:3064 \:526f\:4f5c\:7528\:8a9e\:5e79\:306b\:5f53\:305f\:3089\:306a\:3044 -> Permit (\:9ad8\:901f\:3060\:304c allowed \:5916)
     - System` \:6587\:8108 \:304b\:3064 \:526f\:4f5c\:7528\:8a9e\:5e79\:306b\:5f53\:305f\:308b     -> NeedsApproval
     - Global`/user/package \:6587\:8108              -> NeedsApproval
   Deny head \:306f\:672c\:95a2\:6570\:306b\:6765\:308b\:524d\:306b\:65e2\:306b\:5f3e\:304b\:308c\:3066\:3044\:308b (\:512a\:5148\:9806\:4f4d 1)\:3002 *)

(* head \:306e {\:540d\:524d, \:6587\:8108} \:30da\:30a2\:3092\:672a\:8a55\:4fa1\:3067\:53d6\:5f97\:3059\:308b\:3002
   Context[Unevaluated[s]] \:306f\:30b7\:30f3\:30dc\:30eb\:3092\:8a55\:4fa1\:305b\:305a\:6587\:8108\:3060\:3051\:8fd4\:3059\:306e\:3067\:5b89\:5168\:3002
   \:540d\:524d\:304c allowed/approval/deny \:306e\:6587\:5b57\:5217\:7167\:5408\:3068\:4e00\:81f4\:3059\:308b\:3088\:3046 SymbolName \:3092\:4f7f\:3046\:3002 *)
iNBHeadNameContextPairs[held_HoldComplete] :=
  DeleteDuplicates @ Cases[
    held,
    s_Symbol[___] :> {SymbolName[Unevaluated[s]], Context[Unevaluated[s]]},
    {1, Infinity}];
iNBHeadNameContextPairs[_] := {};

(* \:526f\:4f5c\:7528\:8a9e\:5e79\:30ea\:30b9\:30c8 (spec 5A.5.3)\:3002System` unknown head \:540d\:304c\:3053\:308c\:3089\:306e\:8a9e\:3092
   \:542b\:3080\:5834\:5408\:306f\:526f\:4f5c\:7528\:306e\:7591\:3044\:304c\:3042\:308b\:3068\:3057\:3066 NeedsApproval \:5074\:306b\:5012\:3059\:3002
   \:7834\:58ca\:7684\:30fb\:5916\:90e8\:5b9f\:884c\:30fb\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:7cfb\:306f\:660e\:793a Deny \:306b\:5165\:3063\:3066\:3044\:308b\:306e\:3067\:3001
   \:3053\:3053\:306b\:6765\:308b\:6642\:70b9\:3067\:6b8b\:308b\:306e\:306f\:300c\:8a9e\:5e79\:306f\:526f\:4f5c\:7528\:3063\:307d\:3044\:304c Deny \:660e\:793a\:306f\:3055\:308c\:3066\:3044\:306a\:3044\:300d\:3082\:306e\:3002
   \:5b89\:5168\:5074\:306b\:5012\:3059\:305f\:3081 NeedsApproval \:3068\:3059\:308b\:3002 *)
$iNBSideEffectStems = {
  "Open", "Write", "Save", "Export", "Import", "Delete", "Remove",
  "Run", "Start", "Create", "Put", "Read", "URL", "Socket",
  "Send", "Submit", "Connect", "Launch", "Install", "Load",
  "Library", "External", "Notebook", "FrontEnd", "Dialog",
  "Cloud", "HTTP", "Mail", "Process", "Kernel", "Link",
  "Directory", "File", "Stream", "Channel", "Datbin", "Print",
  "Speak", "Audio", "EmitSound", "SetOptions", "SetEnvironment"
};

(* \:526f\:4f5c\:7528\:8a9e\:5e79\:306b\:90e8\:5206\:4e00\:81f4\:3059\:308b\:304c\:3001\:5b9f\:969b\:306f\:7d14\:7c8b (\:5f0f\:30fb\:30ea\:30b9\:30c8\:30fb\:6587\:5b57\:5217\:30fb\:753b\:50cf\:30fb
   \:30b0\:30e9\:30d5\:64cd\:4f5c) \:3067\:526f\:4f5c\:7528\:3092\:6301\:305f\:306a\:3044 System` \:95a2\:6570\:306e\:9664\:5916\:30ea\:30b9\:30c8\:3002
   2026-06-05: $iNBSideEffectStems \:306f\:90e8\:5206\:6587\:5b57\:5217\:30de\:30c3\:30c1\:306a\:306e\:3067\:3001\:4f8b\:3048\:3070
   DeleteDuplicates \:304c "Delete" \:8a9e\:5e79\:306b\:8a72\:5f53 -> DestructiveFileSystem ->
   HardDeny \:3068\:306a\:308a\:3001\:666e\:901a\:306e\:30b3\:30fc\:30c9\:304c\:627f\:8a8d UI \:3082\:51fa\:305a Deny \:3055\:308c\:308b\:4e8b\:6545\:304c\:8d77\:304d\:308b
   (ConnectedComponents \:306e "Connect" -> NetworkAccess -> HardDeny \:3082\:540c\:69d8)\:3002
   override table \:3068\:9055\:3044\:3053\:308c\:306f\:8a9e\:5e79\:5224\:5b9a\:305d\:306e\:3082\:306e\:3092\:6551\:3046\:305f\:3081 base \:5206\:985e\:5c64
   (iNBClassifyUnknownHeads) \:3068 EffectClass \:96c6\:7d04\:5c64 (iNBHeadEffectClass) \:306e
   \:4e21\:65b9\:306b\:4e00\:5ea6\:306b\:52b9\:304f\:3002\:8a9e\:5e79\:30d2\:30e5\:30fc\:30ea\:30b9\:30c6\:30a3\:30c3\:30af\:306f\:672c\:8cea\:7684\:306b\:6f0f\:308c\:308b\:305f\:3081\:3001\:65b0\:305f\:306a
   \:8aa4\:5224\:5b9a\:304c\:898b\:3064\:304b\:308c\:3070\:3053\:3053\:306b\:8ffd\:8a18\:3059\:308b\:3002 *)
$iNBSideEffectStemExceptions = {
  (* "Delete" \:8a9e\:5e79\:3060\:304c\:7d14\:7c8b *)
  "DeleteDuplicates", "DeleteDuplicatesBy", "DeleteCases", "DeleteMissing",
  "DeleteStopwords", "DeleteElements", "DeleteSmallComponents",
  "DeleteBorderComponents", "DeleteAnomalies",
  (* "Remove" \:8a9e\:5e79\:3060\:304c\:7d14\:7c8b *)
  "RemoveDiacritics", "RemoveBackground", "RemoveAlphaChannel",
  (* "Connect" \:8a9e\:5e79\:3060\:304c\:7d14\:7c8b\:306a\:30b0\:30e9\:30d5/\:30e1\:30c3\:30b7\:30e5/\:5206\:5b50\:64cd\:4f5c *)
  "ConnectedComponents", "WeaklyConnectedComponents", "ConnectedGraphQ",
  "WeaklyConnectedGraphQ", "ConnectedMeshComponents", "ConnectedMoleculeQ",
  "ConnectedMoleculeComponents", "KEdgeConnectedComponents",
  "KVertexConnectedComponents", "VertexConnectivity", "EdgeConnectivity",
  (* "Open" \:8a9e\:5e79\:3060\:304c\:7d14\:7c8b\:306a UI \:69cb\:7bc9\:5b50 *)
  "OpenerView"
};

(* head \:540d\:304c\:526f\:4f5c\:7528\:8a9e\:5e79\:3092\:542b\:3080\:304b (\:9664\:5916\:30ea\:30b9\:30c8\:306b\:3042\:308b\:7d14\:7c8b\:95a2\:6570\:306f False) *)
iNBSideEffectishQ[name_String] :=
  !MemberQ[$iNBSideEffectStemExceptions, name] &&
  AnyTrue[$iNBSideEffectStems, StringContainsQ[name, #] &];
iNBSideEffectishQ[_] := True;  (* \:4e0d\:660e\:306f\:5b89\:5168\:5074 *)

(* System` \:6587\:8108\:304b (\:7d44\:307f\:8fbc\:307f\:95a2\:6570\:304b) \:3092\:6587\:8108\:6587\:5b57\:5217\:3067\:5224\:5b9a\:3002
   System` \:306e\:307f\:3092\:300c\:7d44\:307f\:8fbc\:307f\:300d\:3068\:307f\:306a\:3059\:3002\:305d\:308c\:4ee5\:5916 (Global`, \:30e6\:30fc\:30b6\:30fc package`,
   ClaudeCode`, SourceVault` \:7b49) \:306f user/package \:3068\:307f\:306a\:3059\:3002 *)
iNBIsSystemContextQ[ctx_String] := (ctx === "System`");
iNBIsSystemContextQ[_] := False;

(* \[HorizontalLine]\[HorizontalLine] trusted package heads (2026-06-29) \[HorizontalLine]\[HorizontalLine]
   SourceVault* \:516c\:958b\:95a2\:6570\:306f PrivacyLevel \:3092\:8003\:616e\:3057\:305f\:5b89\:5168\:8a2d\:8a08 (\:5185\:90e8 gate /
   fail-closed) \:306e\:305f\:3081\:3001package \:6587\:8108\:7531\:6765\:306e unknown-head \:627f\:8a8d\:3092\:514d\:9664\:3059\:308b\:3002
   deny/approval \:660e\:793a\:30ea\:30b9\:30c8\:306f\:3053\:306e\:30c1\:30a7\:30c3\:30af\:3088\:308a\:5148\:306b\:8a55\:4fa1\:3055\:308c\:308b\:306e\:3067\:3001\:500b\:5225\:306b
   \:53b3\:683c\:5316\:3057\:305f\:3044 head \:306f $NBApprovalHeads / $NBDenyHeads \:3078\:767b\:9332\:3059\:308c\:3070\:3088\:3044\:3002
   \:904e\:5270\:5b9f\:884c\:306f iNBExcessiveTrustedIterationHits (\:9759\:7684) \:3068 SourceVault \:5074\:306e
   SourceVaultRateLimit (\:5b9f\:884c\:6642) \:304c\:53d7\:3051\:6301\:3064\:3002 *)
If[!AssociationQ[$NBTrustedPackageHeads],
  $NBTrustedPackageHeads = <|"SourceVault`" -> {"SourceVault*"}|>];
If[!IntegerQ[$NBTrustedHeadIterationLimit],
  $NBTrustedHeadIterationLimit = 100];

iNBTrustedPackageHeadQ[nm_String, ctx_String] :=
  Module[{pats},
    pats = If[AssociationQ[$NBTrustedPackageHeads],
      Lookup[$NBTrustedPackageHeads, ctx, {}], {}];
    ListQ[pats] && AnyTrue[pats, StringQ[#] && StringMatchQ[nm, #] &]];
iNBTrustedPackageHeadQ[___] := False;

(* HoldComplete \:7247\:304c trusted package head \:3092\:542b\:3080\:304b (\:9069\:7528\:5f62\:3068\:30d9\:30a2 symbol \:306e\:4e21\:65b9:
   Map[SourceVaultIngest, ...] \:306e\:3088\:3046\:306b\:30d9\:30a2\:3067\:6e21\:308b\:30b1\:30fc\:30b9\:3092\:53d6\:308a\:3053\:307c\:3055\:306a\:3044)\:3002 *)
iNBContainsTrustedHeadQ[hc_HoldComplete] :=
  Length[DeleteDuplicates @ Cases[hc,
    s_Symbol :> {SymbolName[Unevaluated[s]], Context[Unevaluated[s]]},
    {1, Infinity}, Heads -> True]] > 0 &&
  AnyTrue[DeleteDuplicates @ Cases[hc,
      s_Symbol :> {SymbolName[Unevaluated[s]], Context[Unevaluated[s]]},
      {1, Infinity}, Heads -> True],
    iNBTrustedPackageHeadQ[#[[1]], #[[2]]] &];
iNBContainsTrustedHeadQ[_] := False;

(* trusted head \:3092\:542b\:3080\:53cd\:5fa9\:69cb\:9020\:306e literal \:53cd\:5fa9\:6570 >= limit \:3092\:9759\:7684\:691c\:51fa\:3059\:308b\:3002
   \:691c\:51fa\:5bfe\:8c61:
   - Do/Table[body, specs..]: specs \:4e2d\:306e literal Integer \:306e\:6700\:5927\:5024
   - Nest/NestList[f, x, n]: n
   - Map/Scan/AssociationMap/ParallelMap/ParallelTable \:7b49\:3067\:7b2c 2 \:5f15\:6570\:304c
     Range[n] / ConstantArray[_, n]
   Seed -> 999999 \:306e\:3088\:3046\:306a body \:5074\:306e\:5927\:304d\:306a\:6574\:6570\:3067\:306f\:767a\:706b\:3057\:306a\:3044 (\:53cd\:5fa9\:6570
   position \:306e\:307f\:6570\:3048\:308b)\:3002\:8fd4\:308a\:5024: {<|"Construct","Count"|>...} (\:8d85\:904e\:5206\:306e\:307f)\:3002 *)
iNBExcessiveTrustedIterationHits[held_HoldComplete] :=
  Module[{limit, hits = {}, doTab, nests, maps},
    limit = If[IntegerQ[$NBTrustedHeadIterationLimit],
      $NBTrustedHeadIterationLimit, 100];
    (* \:30d1\:30bf\:30fc\:30f3\:5f0f\:306e\:8a55\:4fa1\:3092\:9632\:3050\:305f\:3081 HoldPattern \:3067\:5305\:3080 (Range[n_Integer] \:7b49\:306f
       \:88f8\:3060\:3068\:30d1\:30bf\:30fc\:30f3\:69cb\:7bc9\:6642\:306b\:8a55\:4fa1\:3055\:308c Range::range \:30ce\:30a4\:30ba\:3092\:51fa\:3059)\:3002 *)
    doTab = Cases[held,
      HoldPattern[(h : (Do | Table | ParallelDo | ParallelTable))[body_, specs__]] :>
        {ToString[h], HoldComplete[body],
         Max[0, Cases[HoldComplete[{specs}], n_Integer, {2, Infinity}]]},
      {1, Infinity}];
    nests = Cases[held,
      HoldPattern[(h : (Nest | NestList))[f_, _, n_Integer]] :>
        {ToString[h], HoldComplete[f], n},
      {1, Infinity}];
    maps = Cases[held,
      HoldPattern[(h : (Map | Scan | AssociationMap | ParallelMap | MapIndexed))[f_,
          (Range[n_Integer] | ConstantArray[_, n_Integer]), ___]] :>
        {ToString[h], HoldComplete[f], n},
      {1, Infinity}];
    Scan[Function[rec,
      If[rec[[3]] >= limit && iNBContainsTrustedHeadQ[rec[[2]]],
        AppendTo[hits, <|"Construct" -> rec[[1]], "Count" -> rec[[3]]|>]]],
      Join[doTab, nests, maps]];
    hits];
iNBExcessiveTrustedIterationHits[_] := {};

(* unknown head \:7fa4 (\:540d\:524d-\:6587\:8108\:30da\:30a2) \:3092\:5206\:985e\:3057\:3001\:6700\:3082\:53b3\:3057\:3044\:7d50\:679c\:3092\:8fd4\:3059\:3002
   \:8fd4\:308a\:5024: <|"Decision" -> "Permit"|"NeedsApproval", "Reason" -> _,
            "PlacementHint" -> _, "Unknowns" -> {\:540d\:524d...}|>
   RepairNeeded \:306f\:3053\:3053\:3067\:306f\:8fd4\:3055\:306a\:3044 (\:69cb\:9020\:7834\:640d\:306f\:5225\:9014 malformed \:5224\:5b9a\:3067\:6271\:3046)\:3002 *)
iNBClassifyUnknownHeads[pairs_List] :=
  Module[{sysSideEffect = {}, sysPure = {}, userCtx = {}},
    Do[
      Module[{nm = pair[[1]], ctx = pair[[2]], ov, ovEC},
        (* override \:30c6\:30fc\:30d6\:30eb\:3092\:6700\:512a\:5148\:53c2\:7167 (spec 5B.5A)\:3002\:7d14\:7c8b\:7cfb EffectClass \:306b
           \:660e\:793a\:767b\:9332\:3055\:308c\:305f head \:306f\:3001\:526f\:4f5c\:7528\:8a9e\:5e79\:306b\:5f15\:3063\:304b\:304b\:3063\:3066\:3082\:7d14\:7c8b\:6271\:3044\:306b\:3059\:308b\:3002
           \:4f8b: FileNameJoin/DirectoryName \:306f "File"/"Directory" \:8a9e\:5e79\:8a72\:5f53\:3060\:304c
           override \:3067 PureComputation -> sysPure\:3002 *)
        ov = If[AssociationQ[$NBEffectClassOverrides],
          Lookup[$NBEffectClassOverrides, nm, None], None];
        ovEC = If[AssociationQ[ov], Lookup[ov, "EffectClass", None], None];
        Which[
          (* override \:304c AutoPermit \:76f8\:5f53\:306e\:7d14\:7c8b\:7cfb\:306a\:3089 sysPure *)
          MemberQ[{"PureComputation", "ReadOnlyFileSystem",
                   "GraphicsComputation", "LongRunningComputation"}, ovEC],
            AppendTo[sysPure, nm],
          (* trusted package head (SourceVault* \:7b49): PrivacyLevel \:8003\:616e\:306e
             \:5b89\:5168\:8a2d\:8a08\:3092\:4fe1\:983c\:3057\:627f\:8a8d\:4e0d\:8981\:3002deny/approval \:660e\:793a\:30ea\:30b9\:30c8\:306f\:3053\:3053\:3088\:308a
             \:5148\:306b\:8a55\:4fa1\:6e08\:307f\:3002\:904e\:5270\:5b9f\:884c\:306f iteration guard (\:9759\:7684) \:3068
             SourceVaultRateLimit (\:5b9f\:884c\:6642) \:304c\:53d7\:3051\:6301\:3064\:3002 *)
          iNBTrustedPackageHeadQ[nm, ctx],
            AppendTo[sysPure, nm],
          ! iNBIsSystemContextQ[ctx],
            (* Global`/user/package \:6587\:8108: \:5185\:90e8\:3067\:4f55\:3092\:3059\:308b\:304b\:4e0d\:660e -> NeedsApproval *)
            AppendTo[userCtx, nm],
          iNBSideEffectishQ[nm],
            (* System` \:3060\:304c\:526f\:4f5c\:7528\:8a9e\:5e79\:306b\:8a72\:5f53 -> NeedsApproval *)
            AppendTo[sysSideEffect, nm],
          True,
            (* System` \:7d14\:7c8b\:3063\:307d\:3044\:7d44\:307f\:8fbc\:307f -> Permit (\:9ad8\:901f\:30d1\:30b9\:5916\:3060\:304c\:5b89\:5168\:3068\:307f\:306a\:3059) *)
            AppendTo[sysPure, nm]
        ]],
      {pair, pairs}];
    Which[
      Length[userCtx] > 0,
        <|"Decision" -> "NeedsApproval",
          "Reason" -> "UserOrPackageContextHead",
          "Unknowns" -> Join[userCtx, sysSideEffect, sysPure],
          "ApprovalHeads" -> Join[userCtx, sysSideEffect]|>,
      Length[sysSideEffect] > 0,
        <|"Decision" -> "NeedsApproval",
          "Reason" -> "SideEffectishBuiltin",
          "Unknowns" -> Join[sysSideEffect, sysPure],
          "ApprovalHeads" -> sysSideEffect|>,
      True,
        (* \:5168\:3066 System` \:7d14\:7c8b\:3063\:307d\:3044 -> Permit *)
        <|"Decision" -> "Permit",
          "Reason" -> "PureSystemBuiltin",
          "Unknowns" -> sysPure,
          "ApprovalHeads" -> {}|>
    ]
  ];
iNBClassifyUnknownHeads[_] :=
  <|"Decision" -> "NeedsApproval", "Reason" -> "Unknown",
    "Unknowns" -> {}, "ApprovalHeads" -> {}|>;


(* ============================================================
   Phase permission-modes (2026-06-03, spec 5B): EffectClass /
   ApprovalEligibility / PermissionMode \:5909\:63db\:5c64
   ============================================================
   spec 5B.2: heldExpr -> EffectClass -> ApprovalEligibility
              -> ExecutionPlacement/BlockingRisk -> PermissionMode
              -> final Decision
   \:500b\:5225 action \:95a2\:6570 (NBOpenFolderWithApproval \:7b49) \:3092\:4e71\:7acb\:3055\:305b\:305a\:3001
   \:64cd\:4f5c\:306e\:6027\:8cea (EffectClass) \:3068\:74b0\:5883\:30dd\:30ea\:30b7\:30fc (PermissionMode) \:306e
   \:639b\:3051\:5408\:308f\:305b\:3067\:6700\:7d42\:5224\:5b9a\:3092\:751f\:6210\:3059\:308b\:3002 *)

(* ---- EffectClass override table (spec 5B.5A) ----
   \[FivePointedStar]\:91cd\:8981\:539f\:5247: \:3053\:308c\:306f allowlist \:3067\:306f\:306a\:3044\:3002\:672a\:767b\:9332 head \:306f\:5fc5\:305a
   \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:5206\:985e\:3078\:9032\:3080\:3002table \:306f\:5206\:985e\:7cbe\:5ea6\:3092\:4e0a\:3052\:308b\:4efb\:610f\:4e0a\:66f8\:304d\:3002
   Integrate/NIntegrate/Plot \:7b49\:3092\:5168\:3066\:767b\:9332\:3057\:306a\:3044\:3068\:5b9f\:884c\:3067\:304d\:306a\:3044\:72b6\:614b\:306b
   \:623b\:3057\:3066\:306f\:306a\:3089\:306a\:3044\:3002 *)
If[!AssociationQ[$NBEffectClassOverrides],
  $NBEffectClassOverrides = <|
    "NIntegrate" -> <|"EffectClass" -> "LongRunningComputation",
      "BlockingRisk" -> "PossiblyLong",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "NDSolve" -> <|"EffectClass" -> "LongRunningComputation",
      "BlockingRisk" -> "PossiblyLong",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "NSolve" -> <|"EffectClass" -> "LongRunningComputation",
      "BlockingRisk" -> "PossiblyLong",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FindMinimum" -> <|"EffectClass" -> "LongRunningComputation",
      "BlockingRisk" -> "PossiblyLong",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FindRoot" -> <|"EffectClass" -> "LongRunningComputation",
      "BlockingRisk" -> "PossiblyLong",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "Plot" -> <|"EffectClass" -> "GraphicsComputation",
      "BlockingRisk" -> "PossiblyLongOrLargeResult",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "Plot3D" -> <|"EffectClass" -> "GraphicsComputation",
      "BlockingRisk" -> "PossiblyLongOrLargeResult",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "ContourPlot" -> <|"EffectClass" -> "GraphicsComputation",
      "BlockingRisk" -> "PossiblyLongOrLargeResult",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "GraphPlot" -> <|"EffectClass" -> "GraphicsComputation",
      "BlockingRisk" -> "PossiblyLongOrLargeResult",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "NotebookWrite" -> <|"EffectClass" -> "NotebookMutation",
      "ExecutionPlacement" -> "MainKernelOnly", "RequiresFinalNode" -> True|>,
    "SelectionMove" -> <|"EffectClass" -> "NotebookMutation",
      "ExecutionPlacement" -> "MainKernelOnly", "RequiresFinalNode" -> True|>,
    "FrontEndExecute" -> <|"EffectClass" -> "FrontEndAction",
      "ExecutionPlacement" -> "FrontEndRequired", "RequiresFinalNode" -> True|>,
    "SystemOpen" -> <|"EffectClass" -> "DesktopAction",
      "ExecutionPlacement" -> "DesktopAction", "RequiresFinalNode" -> True|>,
    "FileExistsQ" -> <|"EffectClass" -> "ReadOnlyFileSystem",
      "ExecutionPlacement" -> "FileSystemReadOnly"|>,
    "FileNames" -> <|"EffectClass" -> "ReadOnlyFileSystem",
      "ExecutionPlacement" -> "FileSystemReadOnly"|>,
    "DirectoryQ" -> <|"EffectClass" -> "ReadOnlyFileSystem",
      "ExecutionPlacement" -> "FileSystemReadOnly"|>,
    (* \:627f\:8a8d wrapper head (spec \:68483-lite): FrontEnd \:30d6\:30ed\:30c3\:30af\:30ea\:30b9\:30af\:306e\:3042\:308b
       desktop action \:3092\:8868\:3059\:5f0f\:3002queue \:5316\:5206\:5c90\:304c\:3053\:306e metadata \:3092\:898b\:3066\:3001
       \:627f\:8a8d\:5f8c\:306b\:76f4\:63a5\:5b9f\:884c\:305b\:305a PendingFinalActionQueue \:3078\:7a4d\:3080\:3002 *)
    "NBOpenFolderWithApproval" -> <|"EffectClass" -> "DesktopAction",
      "BlockingRisk" -> "MayBlockFrontEnd",
      "ExecutionPlacement" -> "DesktopAction", "RequiresFinalNode" -> True|>,
    "NBExecuteApprovedAction" -> <|"EffectClass" -> "DesktopAction",
      "BlockingRisk" -> "MayBlockFrontEnd",
      "ExecutionPlacement" -> "DesktopAction", "RequiresFinalNode" -> True|>,
    (* \:7d14\:7c8b\:306a\:30d1\:30b9\:6587\:5b57\:5217\:64cd\:4f5c (\:30d5\:30a1\:30a4\:30eb\:30b7\:30b9\:30c6\:30e0\:306b\:89e6\:308c\:306a\:3044) \:306f PureComputation\:3002
       "File"/"Directory" \:8a9e\:5e79\:306b\:8a72\:5f53\:3057\:3066\:526f\:4f5c\:7528\:8aa4\:5224\:5b9a\:3055\:308c\:308b\:306e\:3092 override \:3067\:6551\:3046\:3002 *)
    "FileNameJoin" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileNameSplit" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileNameTake" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileNameDrop" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "DirectoryName" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileBaseName" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileExtension" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>,
    "FileNameDepth" -> <|"EffectClass" -> "PureComputation",
      "ExecutionPlacement" -> "SubkernelSafe"|>
  |>];

(* ---- EffectClass \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:5206\:985e (spec 5B.5A) ----
   \:512a\:5148\:9806: explicit Deny/Approval/Allowed \:306f\:547c\:3073\:51fa\:3057\:5074\:3067\:51e6\:7406\:6e08\:307f\:306e\:60f3\:5b9a\:3002
   \:3053\:3053\:306f\:300c\:5206\:985e\:5c64\:300d\:3068\:3057\:3066 head \:540d+\:6587\:8108\:304b\:3089 EffectClass \:3092\:6c7a\:3081\:308b\:3002
   1. override table
   2. side-effect stem -> \:5bfe\:5fdc EffectClass
   3. System` pure-ish -> PureComputation
   4. user/package -> UnknownUserCode
   \:5165\:529b: name (head \:540d), ctx (\:6587\:8108\:6587\:5b57\:5217)
   \:51fa\:529b: <|"EffectClass" -> _, "ExecutionPlacement" -> _,
           "BlockingRisk" -> _, "RequiresFinalNode" -> _|> *)
iNBHeadEffectClass[name_String, ctx_String] :=
  Module[{ov},
    (* 1. override table *)
    ov = Lookup[$NBEffectClassOverrides, name, None];
    If[AssociationQ[ov],
      Return[<|
        "EffectClass" -> Lookup[ov, "EffectClass", "PureComputation"],
        "ExecutionPlacement" -> Lookup[ov, "ExecutionPlacement", "SubkernelSafe"],
        "BlockingRisk" -> Lookup[ov, "BlockingRisk", "None"],
        "RequiresFinalNode" -> TrueQ[Lookup[ov, "RequiresFinalNode", False]]|>]];
    (* 1b. trusted package head (SourceVault* \:7b49): \:540d\:524d\:306b "Notebook"/"Generate"
       \:7b49\:306e\:526f\:4f5c\:7528\:8a9e\:5e79\:3092\:542b\:3093\:3067\:3082\:3001\:5185\:90e8 gate \:304c\:5b89\:5168\:3092\:62c5\:4fdd\:3059\:308b\:4fe1\:983c\:6e08\:307f\:95a2\:6570\:3068\:3057\:3066
       PureComputation \:6271\:3044 (\:627f\:8a8d\:4e0d\:8981)\:3002unknown-head \:5206\:985e\:3068 EffectClass \:5c64\:306e
       \:4e21\:65b9\:3067 trusted \:3092\:5c0a\:91cd\:3057\:306a\:3044\:3068\:3001\:7247\:65b9\:304c Permit \:3067\:3082\:4ed6\:65b9\:304c\:627f\:8a8d\:3078\:4e0a\:3052\:308b
       (\:4f8b: GenerateToNotebook \:306f "Notebook" \:8a9e\:5e79\:3067 NotebookMutation \:306b\:306a\:308b)\:3002
       \:904e\:5270\:5b9f\:884c\:306f iNBExcessiveTrustedIterationHits + SourceVaultRateLimit \:3067\:9632\:3050\:3002
       BlockingRisk \:306f\:63a7\:3048\:3081\:306b PossiblyLong \:3068\:3057 (\:751f\:6210\:306f\:6570\:5341\:79d2\:304b\:304b\:308a\:3046\:308b)\:3001
       \:30d6\:30ed\:30c3\:30af\:56de\:907f\:306e\:51fa\:529b\:96c6\:7d04\:304c\:52b9\:304f\:3088\:3046\:306b\:3059\:308b\:3002 *)
    If[iNBTrustedPackageHeadQ[name, ctx],
      Return[<|"EffectClass" -> "PureComputation",
        "ExecutionPlacement" -> "MainKernelOnly",
        "BlockingRisk" -> "PossiblyLong", "RequiresFinalNode" -> False|>]];
    (* 2-4. \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af *)
    Which[
      ! iNBIsSystemContextQ[ctx],
        (* user/package \:6587\:8108: \:5185\:90e8\:4e0d\:660e *)
        <|"EffectClass" -> "UnknownUserCode",
          "ExecutionPlacement" -> "MainKernelOnly",
          "BlockingRisk" -> "None", "RequiresFinalNode" -> False|>,
      iNBSideEffectishQ[name],
        (* System` \:3060\:304c\:526f\:4f5c\:7528\:8a9e\:5e79\:8a72\:5f53: \:8a9e\:5e79\:304b\:3089 EffectClass \:3092\:63a8\:5b9a *)
        <|"EffectClass" -> iNBSideEffectStemToClass[name],
          "ExecutionPlacement" -> "MainKernelOnly",
          "BlockingRisk" -> "None", "RequiresFinalNode" -> True|>,
      True,
        (* System` \:7d14\:7c8b *)
        <|"EffectClass" -> "PureComputation",
          "ExecutionPlacement" -> "SubkernelSafe",
          "BlockingRisk" -> "None", "RequiresFinalNode" -> False|>
    ]
  ];
iNBHeadEffectClass[name_String] := iNBHeadEffectClass[name, "System`"];

(* \:526f\:4f5c\:7528\:8a9e\:5e79\:304b\:3089 EffectClass \:3092\:63a8\:5b9a (spec 5B.5 \:306e\:30ab\:30c6\:30b4\:30ea\:3078\:30de\:30c3\:30d7)\:3002
   \:7834\:58ca\:7684\:30fb\:5916\:90e8\:30fb\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:306f\:660e\:793a Deny \:3067\:65e2\:306b\:5f3e\:304b\:308c\:3066\:3044\:308b\:524d\:63d0\:3060\:304c\:3001
   \:4e07\:4e00\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:306b\:6765\:305f\:5834\:5408\:3082\:5b89\:5168\:5074 EffectClass \:306b\:5012\:3059\:3002 *)
iNBSideEffectStemToClass[name_String] :=
  Which[
    StringContainsQ[name, "Notebook"] || StringContainsQ[name, "Cell"],
      "NotebookMutation",
    StringContainsQ[name, "FrontEnd"] || StringContainsQ[name, "Dialog"],
      "FrontEndAction",
    StringContainsQ[name, "URL"] || StringContainsQ[name, "Socket"] ||
      StringContainsQ[name, "HTTP"] || StringContainsQ[name, "Connect"] ||
      StringContainsQ[name, "Send"] || StringContainsQ[name, "Submit"],
      "NetworkAccess",
    StringContainsQ[name, "Library"] || StringContainsQ[name, "Link"] ||
      StringContainsQ[name, "Install"] || StringContainsQ[name, "External"],
      "LibraryOrLinkLoading",
    StringContainsQ[name, "Delete"] || StringContainsQ[name, "Remove"],
      "DestructiveFileSystem",
    StringContainsQ[name, "Write"] || StringContainsQ[name, "Export"] ||
      StringContainsQ[name, "Save"] || StringContainsQ[name, "Create"] ||
      StringContainsQ[name, "Put"],
      "FileSystemWrite",
    StringContainsQ[name, "Open"] || StringContainsQ[name, "Run"] ||
      StringContainsQ[name, "Start"] || StringContainsQ[name, "Launch"] ||
      StringContainsQ[name, "Process"],
      "DesktopAction",
    True, "FrontEndAction"  (* \:6b8b\:308a\:306f\:8981\:627f\:8a8d\:306e\:526f\:4f5c\:7528\:6271\:3044 *)
  ];

(* ---- EffectClass -> \:65e2\:5b9a ApprovalEligibility (spec 5B.5 \:30c6\:30fc\:30d6\:30eb) ----
   \:65e2\:5b9a\:5024\:3002policy \:3067\:4e0a\:66f8\:304d\:3055\:308c\:5f97\:308b\:304c P0.5 \:3067\:306f\:56fa\:5b9a\:30de\:30c3\:30d7\:3002 *)
$iNBEffectClassEligibility = <|
  "PureComputation" -> "AutoPermit",
  "LongRunningComputation" -> "AutoPermit",
  "GraphicsComputation" -> "AutoPermit",
  "ReadOnlyFileSystem" -> "AutoPermit",
  "NotebookMutation" -> "AskUserAllowed",
  "FrontEndAction" -> "AskUserAllowed",
  "DesktopAction" -> "AskUserAllowed",
  "ExternalProcess" -> "HardDeny",
  "NetworkAccess" -> "HardDeny",
  "FileSystemWrite" -> "AskUserAllowed",
  "DestructiveFileSystem" -> "HardDeny",
  "LibraryOrLinkLoading" -> "HardDeny",
  "KernelControl" -> "HardDeny",
  "UnknownUserCode" -> "AskUserAllowed",
  "MalformedExpression" -> "RepairRequired"
|>;
iNBEffectClassToEligibility[ec_String] :=
  Lookup[$iNBEffectClassEligibility, ec, "AskUserAllowed"];

(* ---- ApprovalEligibility \:306e\:53b3\:3057\:3055\:9806 (\:5408\:6210\:7528) ----
   \:8907\:6570 head \:306e EffectClass \:3092\:96c6\:7d04\:3059\:308b\:969b\:3001\:6700\:3082\:53b3\:3057\:3044 eligibility \:3092\:63a1\:308b\:3002
   HardDeny > RepairRequired > AskUserAllowed > AutoPermit *)
iNBEligibilityRank["HardDeny"] = 4;
iNBEligibilityRank["RepairRequired"] = 3;
iNBEligibilityRank["AskUserAllowed"] = 2;
iNBEligibilityRank["AutoPermit"] = 1;
iNBEligibilityRank[_] = 2;

(* EffectClass \:306e specificity (\:4ee3\:8868\:9078\:629e\:306e\:7b2c2\:30ad\:30fc)\:3002
   PureComputation \:304c\:6700\:3082\:6c4e\:7528 (\:3069\:3093\:306a\:5f0f\:306b\:3082\:73fe\:308c\:308b Sin/List/Plus \:7b49) \:306a\:306e\:3067
   \:6700\:4f4e\:4f4d\:3068\:3057\:3001\:3088\:308a\:5177\:4f53\:7684\:30fb\:7279\:5fb4\:7684\:306a EffectClass \:3092\:4ee3\:8868\:306b\:63a1\:308b\:3002
   eligibility \:540c\:7387\:6642\:306b\:300cPlot \:3092\:542b\:3080\:5f0f\:306e\:4ee3\:8868\:306f GraphicsComputation\:300d\:3068
   \:306a\:308b\:3088\:3046\:306b\:3059\:308b\:305f\:3081\:306e\:3082\:306e\:3002 *)
iNBEffectClassSpecificity["PureComputation"] = 0;
iNBEffectClassSpecificity["ReadOnlyFileSystem"] = 1;
iNBEffectClassSpecificity["GraphicsComputation"] = 2;
iNBEffectClassSpecificity["LongRunningComputation"] = 3;
iNBEffectClassSpecificity[_] = 5;  (* \:526f\:4f5c\:7528\:7cfb\:30fbunknown \:7b49\:306f\:3088\:308a\:7279\:5fb4\:7684 *)

(* ---- PermissionMode \:5909\:63db (spec 5B.4) ----
   ApprovalEligibility \[Times] PermissionMode -> final Decision + metadata\:3002
   \:8fd4\:308a\:5024: <|"Decision" -> _, "ExecutionDisposition" -> _,
            "AllowApprovalUI" -> _, "MayExecute" -> _|>
   mode \:306f accessSpec["PermissionMode"] (I12: global \:3092\:8aad\:307f\:76f4\:3055\:306a\:3044)\:3002 *)
iNBApplyPermissionMode[eligibility_String, mode_String] :=
  Module[{m = mode, e = eligibility},
    Switch[m,
      "ReviewOnly",
        (* \:63d0\:6848\:3060\:3051\:3002AutoPermit \:3082\:542b\:3081\:5b9f\:884c\:3057\:306a\:3044\:3002\:627f\:8a8d UI \:3082\:51fa\:3055\:306a\:3044\:3002 *)
        Switch[e,
          "HardDeny", <|"Decision" -> "Deny",
            "ExecutionDisposition" -> "Blocked",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>,
          "RepairRequired", <|"Decision" -> "RepairNeeded",
            "ExecutionDisposition" -> "Repair",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>,
          _, <|"Decision" -> "NeedsApproval",
            "ExecutionDisposition" -> "ReviewOnly",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>],
      "StrictSafe",
        (* AutoPermit \:306e\:307f\:5b9f\:884c\:3002AskUserAllowed \:306f\:627f\:8a8d\:30dc\:30bf\:30f3\:3092\:51fa\:3055\:305a\:62d2\:5426\:3002 *)
        Switch[e,
          "AutoPermit", <|"Decision" -> "Permit",
            "ExecutionDisposition" -> "Execute",
            "AllowApprovalUI" -> False, "MayExecute" -> True|>,
          "RepairRequired", <|"Decision" -> "RepairNeeded",
            "ExecutionDisposition" -> "Repair",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>,
          _, <|"Decision" -> "Deny",
            "ExecutionDisposition" -> "Blocked",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>],
      "WorkflowSafe",
        (* safe node \:306f\:81ea\:52d5\:3001final node \:76f8\:5f53 (AskUserAllowed) \:306f\:627f\:8a8d +
           RequiresFinalNode\:3002HardDeny \:306f Deny\:3002 *)
        Switch[e,
          "AutoPermit", <|"Decision" -> "Permit",
            "ExecutionDisposition" -> "Execute",
            "AllowApprovalUI" -> False, "MayExecute" -> True|>,
          "AskUserAllowed", <|"Decision" -> "NeedsApproval",
            "ExecutionDisposition" -> "FinalNode",
            "AllowApprovalUI" -> True, "MayExecute" -> False|>,
          "HardDeny", <|"Decision" -> "Deny",
            "ExecutionDisposition" -> "Blocked",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>,
          _, <|"Decision" -> "RepairNeeded",
            "ExecutionDisposition" -> "Repair",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>],
      "DangerFullAccess",
        (* HardDeny \:306f\:5225\:30d5\:30e9\:30b0\:306a\:3057\:306b\:306f Deny \:306e\:307e\:307e (spec 5B.4)\:3002 *)
        Switch[e,
          "AutoPermit", <|"Decision" -> "Permit",
            "ExecutionDisposition" -> "Execute",
            "AllowApprovalUI" -> False, "MayExecute" -> True|>,
          "AskUserAllowed", <|"Decision" -> "Permit",
            "ExecutionDisposition" -> "Execute",
            "AllowApprovalUI" -> True, "MayExecute" -> True|>,
          "HardDeny",
            If[TrueQ[$ClaudeAllowHardDenyOverride],
              <|"Decision" -> "NeedsApproval",
                "ExecutionDisposition" -> "FinalNode",
                "AllowApprovalUI" -> True, "MayExecute" -> False|>,
              <|"Decision" -> "Deny",
                "ExecutionDisposition" -> "Blocked",
                "AllowApprovalUI" -> False, "MayExecute" -> False|>],
          _, <|"Decision" -> "RepairNeeded",
            "ExecutionDisposition" -> "Repair",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>],
      (* InteractiveSafe / LegacyInteractive (\:6a19\:6e96) *)
      _,
        Switch[e,
          "AutoPermit", <|"Decision" -> "Permit",
            "ExecutionDisposition" -> "Execute",
            "AllowApprovalUI" -> False, "MayExecute" -> True|>,
          "AskUserAllowed", <|"Decision" -> "NeedsApproval",
            "ExecutionDisposition" -> "Interactive",
            "AllowApprovalUI" -> True, "MayExecute" -> False|>,
          "HardDeny", <|"Decision" -> "Deny",
            "ExecutionDisposition" -> "Blocked",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>,
          _, <|"Decision" -> "RepairNeeded",
            "ExecutionDisposition" -> "Repair",
            "AllowApprovalUI" -> False, "MayExecute" -> False|>]
    ]
  ];
iNBApplyPermissionMode[e_String] :=
  iNBApplyPermissionMode[e, "InteractiveSafe"];



(* sanitize: \:6587\:5b57\:5217\:30ea\:30c6\:30e9\:30eb\:3092\:4f0f\:305b\:308b *)
iSanitizeExpr[heldExpr_] :=
  Replace[heldExpr,
    s_String /; StringLength[s] > 0 :> "[STRING]",
    {2, Infinity}];

(* confidential leak \:7c21\:6613\:30c1\:30a7\:30c3\:30af *)
(* Phase A0-1 fix: $NBConfidentialSymbols \:306f Association \:306a\:306e\:3067
   \:65e7\:5b9f\:88c5\:306e ListQ \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3060\:3068\:5e38\:306b {} \:306b\:306a\:308a\:7121\:52b9\:3060\:3063\:305f\:3002
   \:307e\:305f AnyTrue \:304c Association \:306e values \:3092\:8d70\:67fb\:3057\:3066\:3057\:307e\:3046\:305f\:3081\:3001
   \:30b7\:30f3\:30dc\:30eb\:540d (keys) \:3067\:7167\:5408\:3059\:308b\:3088\:3046\:4fee\:6b63\:3059\:308b\:3002
   snapshot mode \:3067\:306f accessSpec[\"ConfidentialSymbols\"] \:306b
   snapshot \:7531\:6765\:5024\:304c\:6ce8\:5165\:3055\:308c\:3066\:6e21\:308b (\:30b7\:30b0\:30cd\:30c1\:30e3\:306f\:5909\:3048\:306a\:3044)\:3002 *)
iContainsConfidentialLeak[heldExpr_, accessSpec_Association] :=
  Module[{raw, confNames, exprStr},
    raw = Lookup[accessSpec, "ConfidentialSymbols", $NBConfidentialSymbols];
    confNames = Which[
      AssociationQ[raw], ToString /@ Keys[raw],
      ListQ[raw],        ToString /@ raw,
      True,              {}
    ];
    confNames = DeleteDuplicates @ Select[confNames, StringLength[#] > 0 &];
    If[Length[confNames] === 0, Return[False]];
    exprStr = ToString[heldExpr, InputForm];
    AnyTrue[confNames, StringContainsQ[exprStr, #] &]
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 16: Set/SetDelayed \:6587\:8108\:4f9d\:5b58\:30c1\:30a7\:30c3\:30af
   
   Set/SetDelayed \:306f $NBAllowedHeads \:304b\:3089\:306f\:9664\:5916\:3055\:308c\:3066\:3044\:308b\:3002
   Module/With/Block \:5185\:306e\:30ed\:30fc\:30ab\:30eb\:30b9\:30b3\:30fc\:30d7\:306e Set \:306e\:307f\:8a31\:53ef\:3057\:3001
   \:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7\:306e Set \:306f NeedsApproval \:306b\:683c\:4e0a\:3052\:3059\:308b\:3002
   
   \:65b9\:5f0f: ReplaceAll \:3067\:30b9\:30b3\:30fc\:30d7\:69cb\:9020\:3092\:9664\:53bb\:3057\:3001\:6b8b\:3063\:305f Set \:3092\:691c\:51fa\:3002
   HoldAll + Set \:30d1\:30bf\:30fc\:30f3\:306e\:885d\:7a81\:3092\:56de\:907f\:3059\:308b\:5b89\:5168\:306a\:69cb\:9020\:7684\:30a2\:30d7\:30ed\:30fc\:30c1\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

(* \[HorizontalLine]\[HorizontalLine] \:30d8\:30eb\:30d1\:30fc: \:5f0f\:4e2d\:306e\:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7 Set/SetDelayed \:3092\:691c\:51fa \[HorizontalLine]\[HorizontalLine] *)
(* \:6226\:7565:
   1. HoldComplete \:5185\:306e\:5f0f\:304b\:3089 Module/With/Block/Function \:3092
      \:4e38\:3054\:3068\:4e2d\:7acb\:5024 (Null) \:306b\:7f6e\:63db
   2. \:7f6e\:63db\:5f8c\:306b\:6b8b\:308b Set/SetDelayed \:306f\:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7\:306e\:3082\:306e
   3. FreeQ \:3067\:6b8b\:5b58\:3092\:5224\:5b9a
   
   \:8fd4\:308a\:5024: \:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7\:306b\:3042\:308b Set/SetDelayed \:306e head \:540d\:30ea\:30b9\:30c8\:3002
   \:7a7a\:30ea\:30b9\:30c8 = \:5168\:3066\:5b89\:5168 (\:30ed\:30fc\:30ab\:30eb\:30b9\:30b3\:30fc\:30d7\:5185) *)

iExtractGlobalSets[held_HoldComplete] :=
  Module[{stripped, result = {}},
    (* \:30b9\:30b3\:30fc\:30d7\:69cb\:9020\:3092\:9664\:53bb: Module/With/Block/Function \:306e\:5168\:4f53\:3092 Null \:306b\:7f6e\:63db\:3002
       ReplaceAll \:306f HoldComplete \:5185\:3067\:3082\:69cb\:9020\:7684\:306b\:52d5\:4f5c\:3059\:308b\:3002
       \:30b9\:30b3\:30fc\:30d7\:5185\:306e Set/SetDelayed \:306f\:4e00\:7dd2\:306b\:6d88\:3048\:308b\:3002 *)
    stripped = held /. {
      HoldPattern[(Module | With | Block)[_, _]] :> Null,
      HoldPattern[Function[_]] :> Null,
      HoldPattern[Function[_, _]] :> Null,
      HoldPattern[Function[_, _, _]] :> Null
    };
    
    (* \:6b8b\:3063\:305f Set/SetDelayed \:306f\:30b0\:30ed\:30fc\:30d0\:30eb\:30b9\:30b3\:30fc\:30d7 *)
    If[!FreeQ[stripped, HoldPattern[_Set]], AppendTo[result, "Set"]];
    If[!FreeQ[stripped, HoldPattern[_SetDelayed]], AppendTo[result, "SetDelayed"]];
    result
  ];

iExtractGlobalSets[_] := {};

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: NBExecuteHeldExpr
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBExecuteHeldExpr] = {
  "TimeConstraint" -> 30,
  "ScreenMode" -> "Block",
  "PolicySnapshot" -> Automatic,
  "PreExecutionNotebookActions" -> {},
  "Audit" -> True,
  "ApprovalMode" -> "None"};

(* ============================================================
   Phase C-1: \:5b9f\:884c\:524d\:518d\:691c\:8a3c helper (main / subkernel \:5171\:7528)
   ============================================================ *)

(* snapshot \:30aa\:30d7\:30b7\:30e7\:30f3\:5024\:3092 NBValidateHeldExpr \:7528\:306b\:6b63\:898f\:5316\:3059\:308b\:3002
   Automatic / None \:306f None \:6271\:3044 (non-snapshot mode)\:3001
   Association \:306f\:305d\:306e\:307e\:307e snapshot mode\:3002 *)
iNBResolveExecSnapshot[snapOpt_] :=
  Which[
    AssociationQ[snapOpt], snapOpt,
    True, None
  ];

(* P0 \:6697\:5b9a\:627f\:8a8d\:30e2\:30fc\:30c9 (Committer) \:3067 NeedsApproval \:3092\:5b9f\:884c\:53ef\:306b\:6607\:683c\:3067\:304d\:308b\:304b\:5224\:5b9a\:3002
   spec 4.8 \:633a\:52d5 6-7 / 17.6: \:81ea\:52d5 commit \:4e92\:63db\:7dad\:6301\:306e\:305f\:3081\:306e\:660e\:793a\:627f\:8a8d\:30e2\:30fc\:30c9\:3002
   \:6b21\:3092\:3059\:3079\:3066\:6e80\:305f\:3059\:5834\:5408\:306e\:307f True:
   - ApprovalMode === "CommitterAutoApprove"
   - accessSpec[\"ExecutionRole\"] === "Committer"
   - accessSpec[\"MayWriteNotebook\"] === True
   - accessSpec[\"ExecutionKernel\"] === "MainOnly"
   - accessSpec[\"TargetNotebook\"] \:304c NotebookObject (\:66f8\:304d\:8fbc\:307f\:5148\:306e\:660e\:793a)
   - \:627f\:8a8d\:3092\:8981\:3057\:305f head \:304c\:3059\:3079\:3066\:81ea\:52d5\:627f\:8a8d\:53ef\:80fd head (= snapshot/global \:306e
     ApprovalHeads \:306b\:5165\:308b\:66f8\:304d\:8fbc\:307f\:7cfb head) \:306b\:9650\:3089\:308c\:308b\:3002
     Deny head \:306f NeedsApproval \:3088\:308a\:5148\:306b Deny \:5224\:5b9a\:3055\:308c\:308b\:306e\:3067\:3053\:3053\:306b\:306f\:5165\:3089\:306a\:3044\:3002 *)
iNBCommitterAutoApproveQ[validation_Association, accessSpec_Association,
    approvalMode_String] :=
  Module[{approvalHeads},
    If[approvalMode =!= "CommitterAutoApprove", Return[False]];
    If[Lookup[accessSpec, "ExecutionRole", None] =!= "Committer", Return[False]];
    If[! TrueQ[Lookup[accessSpec, "MayWriteNotebook", False]], Return[False]];
    If[Lookup[accessSpec, "ExecutionKernel", None] =!= "MainOnly", Return[False]];
    If[! MatchQ[Lookup[accessSpec, "TargetNotebook", None], _NotebookObject],
      Return[False]];
    (* \:627f\:8a8d\:3092\:8981\:3057\:305f head \:30ea\:30b9\:30c8\:3002\:7a7a\:306a\:3089 (NeedsApproval \:3060\:304c head \:4e0d\:660e) \:662f\:8a8d\:3057\:306a\:3044\:3002 *)
    approvalHeads = Lookup[validation, "ApprovalHeads", {}];
    If[! ListQ[approvalHeads] || Length[approvalHeads] === 0, Return[False]];
    (* \:5168 head \:304c\:81ea\:52d5\:627f\:8a8d\:53ef\:80fd head \:304b\:3002\:81ea\:52d5\:627f\:8a8d\:53ef\:80fd head \:96c6\:5408\:306f
       \:73fe\:884c\:306e ApprovalHeads (\:66f8\:304d\:8fbc\:307f\:7cfb + NotebookWrite) \:3068\:3059\:308b\:3002 *)
    AllTrue[approvalHeads,
      MemberQ[If[ListQ[$NBApprovalHeads], $NBApprovalHeads, {}], #] &]
  ];

(* \:5b9f\:884c\:53ef\:5426\:3092\:5224\:5b9a\:3059\:308b\:3002NBValidateHeldExpr \:3092\:547c\:3073\:3001
   Decision \:3068 ScreenMode / ApprovalMode \:3092\:8003\:616e\:3057\:3066
   <|\"Permit\" -> True|False, \"Decision\" -> _, \"ReasonClass\" -> _,
     \"VisibleExplanation\" -> _, \"ScreenWarnOnly\" -> True|False,
     \"CommitterAutoApproved\" -> True|False|> \:3092\:8fd4\:3059\:3002 *)
iNBExecPermitCheck[heldExpr_, accessSpec_Association, snapshot_,
    screenMode_String, approvalMode_String] :=
  Module[{validation, decision},
    validation = If[snapshot === None,
      NBValidateHeldExpr[heldExpr, accessSpec],
      NBValidateHeldExpr[heldExpr, accessSpec, "PolicySnapshot" -> snapshot]];
    decision = Lookup[validation, "Decision", "Deny"];
    Which[
      decision === "Permit",
        <|"Permit" -> True, "Decision" -> "Permit",
          "ReasonClass" -> "None", "VisibleExplanation" -> "",
          "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> False|>,
      decision === "Screen",
        (* Screen: \:65e2\:5b9a Block\:3002WarnOnly \:306e\:3068\:304d\:306e\:307f\:5b9f\:884c\:8a31\:53ef *)
        If[screenMode === "WarnOnly",
          <|"Permit" -> True, "Decision" -> "Screen",
            "ReasonClass" -> Lookup[validation, "ReasonClass", "Screen"],
            "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
            "ScreenWarnOnly" -> True, "CommitterAutoApproved" -> False|>,
          <|"Permit" -> False, "Decision" -> "Screen",
            "ReasonClass" -> Lookup[validation, "ReasonClass", "Screen"],
            "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
            "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> False|>],
      decision === "NeedsApproval",
        (* NeedsApproval \:306e Permit \:6607\:683c\:306f\:6b21\:306e 2 \:30e2\:30fc\:30c9\:306e\:307f:
           1. UserApproved: \:30e6\:30fc\:30b6\:30fc\:304c\:627f\:8a8d UI \:3067\:660e\:793a\:627f\:8a8d\:3057\:305f\:4e00\:822c\:30b1\:30fc\:30b9\:3002
              Committer \:5236\:7d04\:306a\:3057\:3067 NeedsApproval \:3092 Permit \:306b\:6607\:683c\:3059\:308b\:3002
              Deny \:306f decision \:304c "Deny" \:3067\:3053\:3053\:306b\:6765\:306a\:3044\:305f\:3081\:3001\:6607\:683c\:5bfe\:8c61\:306f
              Approval head / unknown head \:306b\:9650\:3089\:308c\:5b89\:5168 (spec 5A.9)\:3002
           2. CommitterAutoApprove: directLLM rescue \:7b49\:306e\:81ea\:52d5 commit \:4e92\:63db (D-3)\:3002
              Committer \:30ed\:30fc\:30eb + TargetNotebook \:4e00\:81f4 + \:627f\:8a8d head \:5168\:66f8\:8fbc\:7cfb\:306e\:307f\:3002 *)
        Which[
          approvalMode === "UserApproved",
            <|"Permit" -> True, "Decision" -> "NeedsApproval",
              "ReasonClass" -> Lookup[validation, "ReasonClass", "AccessEscalationRequired"],
              "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
              "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> False,
              "UserApproved" -> True|>,
          iNBCommitterAutoApproveQ[validation, accessSpec, approvalMode],
            <|"Permit" -> True, "Decision" -> "NeedsApproval",
              "ReasonClass" -> Lookup[validation, "ReasonClass", "AccessEscalationRequired"],
              "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
              "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> True,
              "UserApproved" -> False|>,
          True,
            <|"Permit" -> False, "Decision" -> "NeedsApproval",
              "ReasonClass" -> Lookup[validation, "ReasonClass", "AccessEscalationRequired"],
              "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
              "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> False,
              "UserApproved" -> False|>],
      True, (* Deny / RepairNeeded *)
        <|"Permit" -> False, "Decision" -> decision,
          "ReasonClass" -> Lookup[validation, "ReasonClass", "Denied"],
          "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
          "ScreenWarnOnly" -> False, "CommitterAutoApproved" -> False|>
    ]
  ];

(* ============================================================
   Phase C-2: PreExecutionNotebookActions \:691c\:8a3c\:30fb\:5b9f\:884c
   ============================================================ *)

(* \:5358\:4e00 action \:304c\:5b9f\:884c\:8a31\:53ef\:304b\:3092\:5224\:5b9a\:3059\:308b\:3002
   P0 \:3067\:5fc5\:9808\:306e action \:306f "MoveSelectionAfterNotebook" \:306e\:307f\:3002 *)
iNBNotebookPreActionAllowedQ[action_Association, accessSpec_Association] :=
  Module[{name, allowed, mayFE, mayWrite, kernel, nb, targetNb},
    name = Lookup[action, "Action", None];
    allowed = Lookup[accessSpec, "AllowedNotebookActions", {}];
    mayFE = Lookup[accessSpec, "MayUseFrontEnd", False];
    mayWrite = Lookup[accessSpec, "MayWriteNotebook", False];
    kernel = Lookup[accessSpec, "ExecutionKernel", "MainOnly"];
    (* action \:540d\:304c allowlist \:306b\:3042\:308b\:304b *)
    If[! MemberQ[allowed, name], Return[False]];
    (* \:6a29\:9650\:30d5\:30e9\:30b0 *)
    If[! TrueQ[mayFE], Return[False]];
    If[! TrueQ[mayWrite], Return[False]];
    If[kernel =!= "MainOnly", Return[False]];
    (* action \:56fa\:6709\:306e\:691c\:8a3c *)
    Which[
      name === "MoveSelectionAfterNotebook",
        nb = Lookup[action, "Notebook", None];
        targetNb = Lookup[accessSpec, "TargetNotebook", None];
        (* NotebookObject \:304c target \:3068\:4e00\:81f4\:3059\:308b\:3053\:3068\:3002
           target \:672a\:6307\:5b9a\:306e\:5834\:5408\:306f NotebookObject \:3067\:3042\:308b\:3053\:3068\:3060\:3051\:78ba\:8a8d\:3002 *)
        If[targetNb =!= None,
          MatchQ[nb, _NotebookObject] && nb === targetNb,
          MatchQ[nb, _NotebookObject]],
      True, False
    ]
  ];

iNBNotebookPreActionAllowedQ[_, _] := False;

(* actions \:30ea\:30b9\:30c8\:3092\:691c\:8a3c\:3057\:3001\:8a31\:53ef\:3055\:308c\:305f\:3082\:306e\:3060\:3051\:8fd4\:3059\:3002 *)
NBValidateNotebookPreActions[actions_List, accessSpec_Association] :=
  Select[actions, iNBNotebookPreActionAllowedQ[#, accessSpec] &];
NBValidateNotebookPreActions[_, _] := {};

(* \:691c\:8a3c\:6e08\:307f action \:3092\:5b9f\:884c\:3059\:308b (ReleaseHold \:76f4\:524d\:306b\:547c\:3076)\:3002
   \:5b9f\:884c\:3057\:305f action \:540d\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002 *)
iNBRunNotebookPreActions[validatedActions_List] :=
  Module[{executed = {}},
    Do[
      Module[{name = Lookup[action, "Action", None], nb},
        Which[
          name === "MoveSelectionAfterNotebook",
            nb = Lookup[action, "Notebook", None];
            If[MatchQ[nb, _NotebookObject],
              Quiet[SelectionMove[nb, After, Notebook]];
              executed = Append[executed, name]],
          True, Null
        ]],
      {action, validatedActions}];
    executed
  ];

NBExecuteHeldExpr[heldExpr_, accessSpec_Association, opts:OptionsPattern[]] :=
  Module[{result, timeout, screenMode, snapshot, approvalMode, audit,
          permitCheck, preActions, validatedPreActions, executedPreActions = {}},
    If[!MatchQ[heldExpr, HoldComplete[_]],
      Return[<|"Success" -> False, "Decision" -> "Deny",
        "RawResult" -> None, "HeldExpr" -> heldExpr,
        "Error" -> "Invalid HoldComplete expression", "AuditID" -> None|>]];

    timeout      = OptionValue["TimeConstraint"];
    screenMode   = OptionValue["ScreenMode"];
    approvalMode = OptionValue["ApprovalMode"];
    audit        = OptionValue["Audit"];
    snapshot     = iNBResolveExecSnapshot[OptionValue["PolicySnapshot"]];
    preActions   = OptionValue["PreExecutionNotebookActions"];

    (* I2: \:5b9f\:884c\:524d\:306b\:5fc5\:305a\:518d\:691c\:8a3c\:3002Permit \:4ee5\:5916\:306f\:5b9f\:884c\:3057\:306a\:3044\:3002 *)
    permitCheck = iNBExecPermitCheck[heldExpr, accessSpec, snapshot,
      screenMode, approvalMode];
    If[! TrueQ[permitCheck["Permit"]],
      Return[<|"Success" -> False,
        "Decision" -> permitCheck["Decision"],
        "RawResult" -> None,
        "HeldExpr" -> heldExpr,
        "Error" -> "Execution refused: " <> permitCheck["Decision"] <>
          " (" <> ToString[permitCheck["ReasonClass"]] <> ")",
        "AuditID" -> None|>]];

    (* C-2: pre-actions \:691c\:8a3c\[RightArrow]\:5b9f\:884c (ReleaseHold \:76f4\:524d)\:3002
       \:5b9f\:884c\:9806\:5e8f: NBValidateHeldExpr \[RightArrow] \:691c\:8a3c\[RightArrow] pre-actions \[RightArrow] ReleaseHold *)
    validatedPreActions = If[ListQ[preActions] && Length[preActions] > 0,
      NBValidateNotebookPreActions[preActions, accessSpec], {}];
    If[Length[validatedPreActions] > 0,
      executedPreActions = iNBRunNotebookPreActions[validatedPreActions]];

    (* Phase 30 fix Trap #16: Check \:3092\:4f7f\:308f\:305a Quiet \:306e\:307f\:3002
       Trap (Infinity): TimeConstraint === Infinity \:306f TimeConstrained \:3092
       \:4f7f\:308f\:305a\:76f4\:63a5 ReleaseHold (timc \:30e1\:30c3\:30bb\:30fc\:30b8\:56de\:907f)\:3002 *)
    result = If[timeout === Infinity,
      Quiet[ReleaseHold[heldExpr]],
      Quiet[TimeConstrained[ReleaseHold[heldExpr], timeout, $TimedOut]]
    ];

    If[result === $TimedOut,
      <|"Success" -> False,
        "Decision" -> permitCheck["Decision"],
        "RawResult" -> None,
        "HeldExpr" -> heldExpr,
        "Error" -> "Execution timed out after " <> ToString[timeout] <> "s",
        "AuditID" -> None|>,
      (* \:627f\:8a8d wrapper context \:4fee\:6b63 (2026-06-03): ReleaseHold \:306e\:7d50\:679c\:304c
         \:672a\:89e3\:6c7a\:306e\:627f\:8a8d wrapper (Global` \:7b49\:306e NBOpenFolderWithApproval[...])
         \:306a\:3089\:3001\:5b9f\:884c\:3067\:304d\:3066\:3044\:306a\:3044\:306e\:3067 Success \:6271\:3044\:306b\:3057\:306a\:3044\:3002 *)
      If[iNBUnresolvedApprovalWrapperQ[HoldComplete[result]],
        <|"Success" -> False, "Decision" -> "Deny",
          "RawResult" -> result, "HeldExpr" -> heldExpr,
          "ReasonClass" -> "UnresolvedApprovalWrapperSymbol",
          "Error" -> "Approval wrapper did not resolve to NBAccess` symbol",
          "AuditID" -> None|>,
      <|"Success" -> True,
        "Decision" -> permitCheck["Decision"],
        "RawResult" -> result,
        "HeldExpr" -> heldExpr,
        "Error" -> None,
        "AuditID" -> None,
        "ScreenWarnOnlyExecuted" -> TrueQ[permitCheck["ScreenWarnOnly"]],
        "CommitterAutoApproveExecuted" ->
          TrueQ[permitCheck["CommitterAutoApproved"]],
        "ExecutedPreActions" -> executedPreActions|>
    ]]
  ];

(* ============================================================
   Phase frontend-blocking-queue (2026-06-03, \:627f\:8a8d wrapper context \:4fee\:6b63):
   NBTryExecuteFinalActionHeld / iNBUnresolvedApprovalWrapperQ
   ============================================================
   \:554f\:984c: LLM \:304c\:751f\:6210\:3057\:305f NBOpenFolderWithApproval[...] \:304c Global` \:306a\:3069
   NBAccess` \:4ee5\:5916\:306e context \:306e\:30b7\:30f3\:30dc\:30eb\:3068\:3057\:3066\:4fdd\:5b58\:3055\:308c\:3001ReleaseHold \:3057\:3066\:3082
   \:672a\:5b9a\:7fa9 \[RightArrow] \:672a\:8a55\:4fa1\:5f0f\:306e\:307e\:307e\:8fd4\:308a SystemOpen \:306b\:5230\:9054\:3057\:306a\:3044\:3002
   NBValidateHeldExpr \:306f head \:540d\:3092\:6587\:5b57\:5217\:7167\:5408\:3059\:308b\:306e\:3067\:627f\:8a8d UI \:306f\:51fa\:308b\:304c\:3001
   \:5b9f\:884c\:6642\:306b context \:304c\:9055\:3046\:3068\:5b9a\:7fa9\:306b\:5c4a\:304b\:306a\:3044\:3002
   \:5bfe\:7b56: head \:306e context \:306b\:4f9d\:5b58\:305b\:305a SymbolName \:3067\:627f\:8a8d wrapper \:3092\:691c\:51fa\:3057\:3001
   \:5f15\:6570\:30d1\:30b9\:3092\:5b89\:5168\:8a55\:4fa1\:3057\:3066 OpenDesktopItem action \:3078\:6b63\:898f\:5316\:3001
   NBExecuteApprovedAction \:7d4c\:7531 (NBAccess \:5185\:90e8 executor) \:3067\:5b9f\:884c\:3059\:308b\:3002 *)

(* head \:304c NBAccess` \:4ee5\:5916\:306e context \:306e\:672a\:89e3\:6c7a\:627f\:8a8d wrapper \:304b\:5224\:5b9a\:3002
   \:8a55\:4fa1\:3092\:631f\:307e\:306a\:3044\:3088\:3046 Extract \:3067 head \:3092\:53d6\:308a\:51fa\:3059\:3002 *)
iNBUnresolvedApprovalWrapperQ[heldResult_HoldComplete] :=
  Module[{nm, ctx},
    (* heldResult = HoldComplete[expr]\:3002expr \:304c f[___] \:5f62\:304b *)
    If[!MatchQ[heldResult, HoldComplete[_[___]]], Return[False]];
    nm = Quiet @ Check[Extract[heldResult, {1, 0}, SymbolName], ""];
    ctx = Quiet @ Check[Extract[heldResult, {1, 0}, Context], ""];
    MemberQ[{"NBOpenFolderWithApproval", "NBExecuteApprovedAction"}, nm] &&
      ctx =!= "NBAccess`"
  ];
iNBUnresolvedApprovalWrapperQ[_] := False;

(* held = HoldComplete[ <anyContext>`NBOpenFolderWithApproval[pathExpr] ] \:3092
   context \:975e\:4f9d\:5b58\:306b\:691c\:51fa\:3057 OpenDesktopItem action \:3078\:6b63\:898f\:5316\:3057\:3066\:5b9f\:884c\:3002
   \:5bfe\:8c61\:5916\:306a\:3089 <|"Handled" -> False|>\:3002 *)
Options[NBTryExecuteFinalActionHeld] = {"ApprovalMode" -> "UserApproved"};
NBTryExecuteFinalActionHeld[held_HoldComplete, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{nm, pathHeld, pathResult, path, action, execResult, approvalMode},
    approvalMode = OptionValue["ApprovalMode"];
    (* head \:304c f[___] \:5f62\:3067\:306a\:3051\:308c\:3070\:5bfe\:8c61\:5916 *)
    If[!MatchQ[held, HoldComplete[_[___]]],
      Return[<|"Handled" -> False|>]];
    (* head \:540d\:3092\:8a55\:4fa1\:305b\:305a\:53d6\:5f97 (context \:975e\:4f9d\:5b58) *)
    nm = Quiet @ Check[Extract[held, {1, 0}, SymbolName], ""];
    If[nm =!= "NBOpenFolderWithApproval",
      Return[<|"Handled" -> False|>]];
    (* \:7b2c 1 \:5f15\:6570\:3092\:8a55\:4fa1\:305b\:305a\:53d6\:308a\:51fa\:3059: HoldComplete[pathExpr] *)
    pathHeld = Quiet @ Check[Extract[held, {1, 1}, HoldComplete], $Failed];
    If[pathHeld === $Failed || !MatchQ[pathHeld, HoldComplete[_]],
      Return[<|"Handled" -> True, "Success" -> False,
        "Decision" -> "Deny",
        "ReasonClass" -> "InvalidFinalActionArguments"|>]];
    (* path \:5f0f\:3092\:5b89\:5168\:8a55\:4fa1 (FrontEnd \:306a\:3057\:30fb\:66f8\:8fbc\:306a\:3057\:30fb\:77ed timeout) *)
    pathResult = NBExecuteHeldExpr[pathHeld,
      Join[accessSpec, <|"ExecutionRole" -> "ProposalEval",
        "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False|>],
      "ApprovalMode" -> "UserApproved", "TimeConstraint" -> 10];
    If[!TrueQ[Lookup[pathResult, "Success", False]],
      Return[Append[pathResult, "Handled" -> True]]];
    path = Lookup[pathResult, "RawResult", None];
    (* OpenDesktopItem action \:3078\:6b63\:898f\:5316 *)
    action = <|"Action" -> "OpenDesktopItem", "TargetType" -> "Folder",
      "Path" -> path|>;
    execResult = NBExecuteApprovedAction[action, accessSpec,
      "ApprovalMode" -> approvalMode];
    Append[execResult, "Handled" -> True]
  ];
NBTryExecuteFinalActionHeld[_, _, ___] := <|"Handled" -> False|>;

(* held = HoldComplete[<anyContext>`NBOpenFolderWithApproval[pathExpr]] \:304b\:3089\:3001
   SystemOpen \:3092\:547c\:3070\:305a\:306b\:30d1\:30b9\:3092\:5b89\:5168\:89e3\:6c7a\:3057\:691c\:8a3c\:3060\:3051\:884c\:3046\:3002
   \:627f\:8a8d\:30dc\:30bf\:30f3\:672c\:4f53 (\:30e1\:30a4\:30f3\:30ab\:30fc\:30cd\:30eb\:8a55\:4fa1\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8) \:304c\:3001\:3053\:306e\:691c\:8a3c\:6e08\:307f\:30d1\:30b9\:306b\:5bfe\:3057\:3066
   raw SystemOpen \:3092\:76f4\:63a5\:547c\:3076\:305f\:3081\:306b\:4f7f\:3046\:3002
   SystemOpen \:306f SessionSubmit/ScheduledTask \:7cfb\:3067\:306f\:52b9\:304b\:305a\:3001\:30e1\:30a4\:30f3\:30ab\:30fc\:30cd\:30eb\:306e
   \:30c8\:30c3\:30d7\:30ec\:30d9\:30eb\:8a55\:4fa1\:3067\:306e\:307f\:52b9\:304f\:305f\:3081\:3001\:5b9f\:884c\:306f\:3053\:3053\:3067\:306f\:884c\:308f\:305a\:547c\:3073\:51fa\:3057\:5074\:306b\:59d4\:306d\:308b\:3002
   \:8fd4\:308a\:5024: <|"IsDesktopAction"->True/False, "Validated"->.., "Path"->.., ...|> *)
NBResolveDesktopActionPath[held_HoldComplete, accessSpec_Association] :=
  Module[{nm, pathHeld, pathResult, path, action, validation},
    If[!MatchQ[held, HoldComplete[_[___]]],
      Return[<|"IsDesktopAction" -> False|>]];
    nm = Quiet @ Check[Extract[held, {1, 0}, SymbolName], ""];
    If[nm =!= "NBOpenFolderWithApproval",
      Return[<|"IsDesktopAction" -> False|>]];
    pathHeld = Quiet @ Check[Extract[held, {1, 1}, HoldComplete], $Failed];
    If[pathHeld === $Failed || !MatchQ[pathHeld, HoldComplete[_]],
      Return[<|"IsDesktopAction" -> True, "Validated" -> False,
        "ReasonClass" -> "InvalidFinalActionArguments"|>]];
    (* path \:5f0f\:3092\:5b89\:5168\:8a55\:4fa1 (FrontEnd \:306a\:3057\:30fb\:66f8\:8fbc\:306a\:3057\:30fb\:77ed timeout) *)
    pathResult = NBExecuteHeldExpr[pathHeld,
      Join[accessSpec, <|"ExecutionRole" -> "ProposalEval",
        "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False|>],
      "ApprovalMode" -> "UserApproved", "TimeConstraint" -> 10];
    If[!TrueQ[Lookup[pathResult, "Success", False]],
      Return[<|"IsDesktopAction" -> True, "Validated" -> False,
        "ReasonClass" -> "PathEvaluationFailed",
        "PathResult" -> pathResult|>]];
    path = Lookup[pathResult, "RawResult", None];
    (* OpenDesktopItem \:3068\:3057\:3066\:691c\:8a3c (\:5b9f\:884c\:306f\:3057\:306a\:3044)\:3002\:9055\:53cd\:306f HardDeny \:3092\:8fd4\:3059\:3002 *)
    action = <|"Action" -> "OpenDesktopItem", "TargetType" -> "Folder",
      "Path" -> path|>;
    validation = NBValidateAction[action, accessSpec];
    If[Lookup[validation, "Decision", "Deny"] === "Deny" ||
       Lookup[validation, "ApprovalEligibility", "HardDeny"] === "HardDeny",
      Return[<|"IsDesktopAction" -> True, "Validated" -> False,
        "ReasonClass" -> Lookup[validation, "ReasonClass", "ValidationDenied"],
        "VisibleExplanation" -> Lookup[validation, "VisibleExplanation", ""],
        "Path" -> path|>]];
    (* \:627f\:8a8d\:6e08\:307f (UserApproved) \:306a\:3089 NeedsApproval \:306f\:8a31\:5bb9\:3002\:691c\:8a3c OK\:3002 *)
    <|"IsDesktopAction" -> True, "Validated" -> True, "Path" -> path,
      "Action" -> action|>
  ];
NBResolveDesktopActionPath[_, _] := <|"IsDesktopAction" -> False|>;


(* ============================================================
   Phase C-3: NBSubkernelExecutableQ / NBExecuteHeldExprSubkernelRaw
   ============================================================ *)

(* subkernel \:3078\:9001\:308c\:308b\:526f\:4f5c\:7528\:5019\:88dc head\:3002
   \:3053\:308c\:3089\:3092\:542b\:3080\:5f0f\:306f subkernel \:5b9f\:884c\:4e0d\:53ef (RawResult \:304c kernel \:9593\:3092\:8de8\:3050\:30ea\:30b9\:30af)\:3002 *)
$iNBSubkernelForbiddenHeads = {
  "NotebookWrite", "SelectionMove", "CellPrint", "FrontEndExecute",
  "RunProcess", "StartProcess", "ExternalEvaluate",
  "Import", "Export", "URLRead", "URLExecute", "URLFetch",
  "Evaluate"
};

NBSubkernelExecutableQ[held_HoldComplete, accessSpec_Association] :=
  Module[{snapshot, accept, heads, denyH, approvalH},
    (* accessSpec \:30ed\:30fc\:30eb / \:30ab\:30fc\:30cd\:30eb / \:6a29\:9650\:30d5\:30e9\:30b0 *)
    If[Lookup[accessSpec, "ExecutionRole", None] =!= "ProposalEval",
      Return[False]];
    If[Lookup[accessSpec, "ExecutionKernel", None] =!= "SubkernelAllowed",
      Return[False]];
    If[Lookup[accessSpec, "MayUseFrontEnd", False] === True, Return[False]];
    If[Lookup[accessSpec, "MayWriteNotebook", False] === True, Return[False]];
    If[Lookup[accessSpec, "MayUseExternalProcess", False] === True, Return[False]];
    If[Lookup[accessSpec, "MayUseNetwork", False] === True, Return[False]];
    If[Lookup[accessSpec, "ResultMayCrossKernel", False] =!= True, Return[False]];

    (* PolicySnapshot \:304c\:6709\:52b9\:304b *)
    snapshot = Lookup[accessSpec, "PolicySnapshot", None];
    If[! AssociationQ[snapshot], Return[False]];
    accept = NBAcceptPolicySnapshot[snapshot];
    If[! TrueQ[Lookup[accept, "Valid", False]], Return[False]];

    (* confidential / secrets \:53c2\:7167 *)
    If[iContainsConfidentialLeak[held, accessSpec], Return[False]];

    (* \:5f0f\:4e2d\:306e head \:3092\:62bd\:51fa (held \:306e\:307f\:3002pre-action \:5185\:90e8\:306b\:306f\:53cd\:5fdc\:3057\:306a\:3044) *)
    heads = iExtractAllHeads[held];

    (* snapshot \:306e DenyHeads / ApprovalHeads \:8a72\:5f53 head \:3092\:542b\:3080\:304b *)
    denyH     = Lookup[snapshot, "DenyHeads", {}];
    approvalH = Lookup[snapshot, "ApprovalHeads", {}];
    If[AnyTrue[heads, MemberQ[denyH, #] || MemberQ[approvalH, #] &],
      Return[False]];

    (* \:526f\:4f5c\:7528\:5019\:88dc head \:3092\:542b\:3080\:304b *)
    If[AnyTrue[heads, MemberQ[$iNBSubkernelForbiddenHeads, #] &],
      Return[False]];

    True
  ];

NBSubkernelExecutableQ[___] := False;

(* subkernel \:5c02\:7528\:5b9f\:884c wrapper\:3002
   \:623b\:308a: \:751f\:306e\:8a55\:4fa1\:7d50\:679c / $TimedOut / $Failed (Association \:306f\:8fd4\:3055\:306a\:3044)\:3002
   future shape \:7dad\:6301\:306e\:305f\:3081\:3002 *)
Options[NBExecuteHeldExprSubkernelRaw] = {"TimeConstraint" -> 30};

NBExecuteHeldExprSubkernelRaw[held_HoldComplete, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{snapshot, accept, validation, decision, timeout, result},
    timeout = OptionValue["TimeConstraint"];

    (* 1. snapshot \:53d6\:5f97 *)
    snapshot = Lookup[accessSpec, "PolicySnapshot", None];

    (* 2. snapshot \:691c\:8a3c *)
    If[! AssociationQ[snapshot], Return[$Failed]];
    accept = NBAcceptPolicySnapshot[snapshot];
    If[! TrueQ[Lookup[accept, "Valid", False]], Return[$Failed]];

    (* 3. subkernel \:5b9f\:884c\:53ef\:5426 *)
    If[! TrueQ[NBSubkernelExecutableQ[held, accessSpec]], Return[$Failed]];

    (* 4. snapshot \:57fa\:6e96\:3067\:518d\:691c\:8a3c (recompute \:3057\:306a\:3044) *)
    validation = NBValidateHeldExpr[held, accessSpec,
      "PolicySnapshot" -> snapshot];
    decision = Lookup[validation, "Decision", "Deny"];

    (* 5/6/7. Permit \:4ee5\:5916\:306f\:3059\:3079\:3066 $Failed (WarnOnly \:3082\:8a31\:53ef\:3057\:306a\:3044) *)
    If[decision =!= "Permit", Return[$Failed]];

    (* 8. Infinity \:306f TimeConstrained \:3092\:4f7f\:308f\:306a\:3044 *)
    result = If[timeout === Infinity,
      Quiet[ReleaseHold[held]],
      Quiet[TimeConstrained[ReleaseHold[held], timeout, $TimedOut]]
    ];

    (* 9. \:751f\:5024 / $TimedOut / ($Failed \:306f\:4e0a\:8a18\:7d4c\:8def) \:3092\:305d\:306e\:307e\:307e\:8fd4\:3059 *)
    result
  ];

NBExecuteHeldExprSubkernelRaw[___] := $Failed;

(* ============================================================
   Phase D-1: NBMakeRuntimeAccessSpec
   Runtime/Orchestrator \:304b\:3089 NBAccess \:3078\:6e21\:3059 accessSpec \:3092\:4f5c\:308b\:3002
   role \:5225\:65e2\:5b9a\:5024 (spec 4.6 \:30c6\:30fc\:30d6\:30eb)\:3002
   ============================================================ *)

(* MayAccessFileSystem enum \:6b63\:898f\:5316 (v7 \[Section]13B, Phase 2a)\:3002
   Boolean / legacy \:5024 / \:4e0d\:660e\:5024\:3092 None/ReadOnly/ScopedRead/ScopedWrite/ScopedReadWrite
   \:306e\:3044\:305a\:308c\:304b\:3078\:6b63\:898f\:5316\:3059\:308b\:3002\:4e0d\:660e\:5024\:306f\:5b89\:5168\:5074 "None"\:3002\:65e2\:5b58 role \:306e "ReadOnly" \:7b49\:306f\:4e0d\:5909\:3002 *)
iNBFSEnumNormalize[v_] := Switch[v,
  True,  "ScopedReadWrite",
  False, "None",
  "None" | "ReadOnly" | "ScopedRead" | "ScopedWrite" | "ScopedReadWrite", v,
  "Scoped", "ScopedReadWrite",
  _, "None"
];
iNBNormalizeFSAccessSpec[spec_Association] :=
  If[KeyExistsQ[spec, "MayAccessFileSystem"],
    Append[spec, "MayAccessFileSystem" -> iNBFSEnumNormalize[spec["MayAccessFileSystem"]]],
    spec];

(* v7 \[Section]13A: \:65e2\:77e5 role \:96c6\:5408\:3002\:672a\:77e5 role \:306f silent \:306b\:6700\:5c0f\:6a29\:9650\:5316\:305b\:305a\:3001\:8b66\:544a +
   RoleValid->False \:3067\:660e\:793a\:3059\:308b (catch-all \:306f\:6700\:3082\:5236\:9650\:7684\:306e\:307e\:307e fail-closed)\:3002 *)
iNBKnownRoleQ[r_String] := MemberQ[
  {"ProposalEval", "Committer", "VisionFallback", "ManualDispatch",
   "SubkernelTask", "WolframScriptTask", "MainKernelTask", "FinalAction"}, r];
iNBKnownRoleQ[_] := False;

NBMakeRuntimeAccessSpec::unkrole =
  "\:672a\:77e5\:306e ExecutionRole `1` \:3067\:3059\:3002\:6700\:3082\:5236\:9650\:7684\:306a AccessSpec (RoleValid->False) \:3092\:8fd4\:3057\:307e\:3059\:3002\:65e2\:77e5 role \:306f ProposalEval / Committer / VisionFallback / ManualDispatch / SubkernelTask / WolframScriptTask / MainKernelTask / FinalAction\:3002";

NBMakeRuntimeAccessSpec[contextPacket_Association, role_String:"ProposalEval"] :=
  Module[{roleDefaults, conf, secrets, snapshot},
    If[! iNBKnownRoleQ[role], Message[NBMakeRuntimeAccessSpec::unkrole, role]];
    (* role \:5225\:306e\:65e2\:5b9a\:5024 *)
    roleDefaults = Switch[role,
      "ProposalEval",
        <|"ExecutionKernel" -> "SubkernelAllowed",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "ReadOnly",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> True,
          "AllowedNotebookActions" -> {}|>,
      "Committer",
        <|"ExecutionKernel" -> "MainOnly",
          "MayUseFrontEnd" -> True, "MayWriteNotebook" -> True,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "ReadOnly",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "AllowedNotebookActions" -> {"MoveSelectionAfterNotebook"}|>,
      "VisionFallback",
        <|"ExecutionKernel" -> "MainOnly",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "ReadOnly",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "AllowedNotebookActions" -> {}|>,
      "ManualDispatch",
        <|"ExecutionKernel" -> "MainOnly",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "ReadOnly",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "AllowedNotebookActions" -> {}|>,
      (* === External executor task placement v7 \[Section]13A \:306e role \:65e2\:5b9a (Phase 2a, \:7d14\:52a0\:6cd5) === *)
      "SubkernelTask",
        (* v7 \[Section]13A.1: serializable\:30fbtransfer-safe \:306a\:7d14\:7c8b\:8a08\:7b97\:7528 *)
        <|"ExecutionKernel" -> "SubkernelAllowed",
          "ExecutionBackend" -> "SubkernelAsync",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "None",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> True,
          "AllowedNotebookActions" -> {}|>,
      "WolframScriptTask",
        (* v7 \[Section]13A.2: \:5916\:90e8 process executor\:3002
           MayUseExternalProcess -> True \:306f resolved wolframscript runner \:8d77\:52d5\:5c02\:7528\:306e
           \:9650\:5b9a\:8a31\:53ef\:3067\:3042\:308a\:3001\:4efb\:610f\:5916\:90e8 process \:8a31\:53ef\:3067\:306f\:306a\:3044 (\:5b9f\:52b9\:7684\:306a command \:4e00\:81f4\:691c\:67fb\:306f
           Phase 2b scoped-permit / runner I/O guard \:3067\:884c\:3046)\:3002
           MayUseNetwork \:306f\:65e2\:5b9a False\:3002AllowedNetworkTargets \:3092\:4f34\:3046 scope \:6307\:5b9a\:6642\:306b
           Phase 2b \:306e scoped-permit \:3067 NetworkAccess \:306e HardDeny \:3092\:6607\:683c\:3059\:308b\:3002 *)
        <|"ExecutionKernel" -> "ExternalProcess",
          "ExecutionBackend" -> "WolframScriptProcess",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> True, "MayAccessFileSystem" -> "ScopedReadWrite",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> True,
          "AllowedNotebookActions" -> {},
          "AllowedDirectories" -> {}, "AllowedNetworkTargets" -> {},
          "AllowedExternalCommands" -> {"wolframscript-runner"},
          "CredentialRefs" -> {}, "SecretRefs" -> {},
          "ConfidentialHandling" -> "ReferenceOnly"|>,
      "MainKernelTask",
        (* v7 \[Section]13A.3: \:77ed\:6642\:9593\:306e main session state \:4f9d\:5b58\:51e6\:7406 *)
        <|"ExecutionKernel" -> "MainOnly",
          "ExecutionBackend" -> "MainKernelAsync",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "None",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "AllowedNotebookActions" -> {}|>,
      "FinalAction",
        (* v7 \[Section]13A.4: FE/Notebook \:53cd\:6620\:3002\:627f\:8a8d\:5fc5\:9808 (single committer)\:3002 *)
        <|"ExecutionKernel" -> "MainOnly",
          "ExecutionBackend" -> "FinalActionQueue",
          "MayUseFrontEnd" -> True, "MayWriteNotebook" -> True,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "None",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "RequiresApproval" -> True,
          "AllowedNotebookActions" -> {"MoveSelectionAfterNotebook"}|>,
      _,  (* \:4e0d\:660e\:306a role \:306f\:6700\:3082\:5236\:9650\:7684 (ProposalEval \:76f8\:5f53\:3060\:304c subkernel \:4e0d\:53ef) *)
        <|"ExecutionKernel" -> "MainOnly",
          "MayUseFrontEnd" -> False, "MayWriteNotebook" -> False,
          "MayUseExternalProcess" -> False, "MayAccessFileSystem" -> "ReadOnly",
          "MayUseNetwork" -> False, "ResultMayCrossKernel" -> False,
          "AllowedNotebookActions" -> {}|>
    ];

    (* contextPacket \:304b\:3089 conf / secrets \:3092\:53d6\:5f97 (\:7121\:3051\:308c\:3070\:7a7a) *)
    conf = Lookup[contextPacket, "ConfidentialSymbols",
      If[AssociationQ[$NBConfidentialSymbols] || ListQ[$NBConfidentialSymbols],
        $NBConfidentialSymbols, {}]];
    secrets = Lookup[contextPacket, "Secrets", {}];

    (* snapshot \:306f\:751f\:6210\:6642\:70b9\:306e policy \:3092\:51cd\:7d50 *)
    snapshot = NBPolicySnapshot[];

    Join[
      iNBNormalizeFSAccessSpec[roleDefaults],
      <|
        "ExecutionRole" -> role,
        "RoleValid" -> iNBKnownRoleQ[role],   (* v7 \[Section]13A: \:672a\:77e5 role \:306f False *)
        (* I12 (spec 5B): contextPacket \:306b\:660e\:793a\:304c\:306a\:3051\:308c\:3070 accessSpec \:4f5c\:6210\:6642\:70b9\:306e
           global $ClaudePermissionMode \:3092\:713c\:304d\:8fbc\:3080\:3002\:4ee5\:964d\:306e\:5b9f\:884c (subkernel \:542b\:3080)
           \:306f\:3053\:306e\:713c\:304d\:8fbc\:3093\:3060\:5024\:3092\:6b63\:3068\:3057\:3001global \:3092\:8aad\:307f\:76f4\:3055\:306a\:3044\:3002 *)
        "PermissionMode" -> Lookup[contextPacket, "PermissionMode",
          If[StringQ[$ClaudePermissionMode], $ClaudePermissionMode,
            "InteractiveSafe"]],
        "ConfidentialSymbols" -> conf,
        "Secrets" -> secrets,
        "PolicySnapshot" -> snapshot,
        "Caller" -> Lookup[contextPacket, "Caller", "Unknown"],
        "WorkflowID" -> Lookup[contextPacket, "WorkflowID", None],
        "StepID" -> Lookup[contextPacket, "StepID", None]
      |>
    ]
  ];

NBMakeRuntimeAccessSpec[role_String:"ProposalEval"] :=
  NBMakeRuntimeAccessSpec[<||>, role];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase permission-modes (2026-06-03, spec 5B.8): Action registry
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   NBOpenFolderWithApproval \:306e\:3088\:3046\:306a\:500b\:5225\:95a2\:6570\:3092\:4e71\:7acb\:3055\:305b\:305a\:3001\:627f\:8a8d\:5bfe\:8c61\:64cd\:4f5c\:3092
   \:6c4e\:7528 action registry \:306b\:5bc4\:305b\:308b\:3002EffectClass + PermissionMode \:3067\:5224\:5b9a\:3057\:3001
   raw SystemOpen \:7b49\:306f NBAccess \:5185\:90e8 executor \:3060\:3051\:304c\:547c\:3076 (I1/I2)\:3002 *)

If[!AssociationQ[$NBActionRegistry], $NBActionRegistry = <||>];

NBRegisterAction[name_String, spec_Association] :=
  ($NBActionRegistry[name] = spec; name);

(* ---- OpenDesktopItem: \:30d5\:30a9\:30eb\:30c0\:7b49\:3092\:958b\:304f ---- *)

(* path \:304c\:5b89\:5168\:306a folder target \:304b\:691c\:67fb (spec 5B.7)\:3002
   \:8fd4\:308a\:5024: <|"Valid" -> _, "Reason" -> _, "NormalizedPath" -> _,
            "ApprovalEligibility" -> _|>
   URL / \:5b9f\:884c\:30d5\:30a1\:30a4\:30eb / folder \:3067\:306a\:3044\:3082\:306e \:306f HardDeny\:3002 *)
iNBValidateOpenDesktopItem[action_Association] :=
  Module[{path, targetType, normPath, ext},
    path = Lookup[action, "Path", None];
    targetType = Lookup[action, "TargetType", "Folder"];
    (* path \:306f\:6587\:5b57\:5217\:306e\:307f\:8a31\:53ef (File[...] \:306f ToString \:3067\:6b63\:898f\:5316\:3092\:8a66\:307f\:308b) *)
    Which[
      StringQ[path], normPath = path,
      MatchQ[path, _File], normPath = First[path],
      True, Return[<|"Valid" -> False, "Reason" -> "PathNotString",
        "ApprovalEligibility" -> "HardDeny"|>]];
    If[!StringQ[normPath] || StringLength[normPath] === 0,
      Return[<|"Valid" -> False, "Reason" -> "EmptyPath",
        "ApprovalEligibility" -> "HardDeny"|>]];
    (* URL \:306f\:4e0d\:53ef *)
    If[StringMatchQ[normPath,
        (("http" ~~ ("s" | "") ~~ "://") | "ftp://" | "file://" | "mailto:") ~~ ___,
        IgnoreCase -> True],
      Return[<|"Valid" -> False, "Reason" -> "URLNotAllowed",
        "ApprovalEligibility" -> "HardDeny"|>]];
    (* \:5b9f\:884c\:30d5\:30a1\:30a4\:30eb\:62e1\:5f35\:5b50\:306f\:4e0d\:53ef *)
    ext = ToLowerCase[FileExtension[normPath]];
    If[MemberQ[{"exe", "bat", "cmd", "com", "scr", "ps1", "vbs", "js",
                "msi", "app", "command", "sh", "jar"}, ext],
      Return[<|"Valid" -> False, "Reason" -> "ExecutableNotAllowed",
        "ApprovalEligibility" -> "HardDeny"|>]];
    (* Folder target \:306f\:5b9f\:969b\:306b\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:3067\:3042\:308b\:3053\:3068\:3092\:8981\:6c42 *)
    If[targetType === "Folder",
      If[!TrueQ[Quiet[DirectoryQ[normPath]]],
        Return[<|"Valid" -> False, "Reason" -> "NotADirectory",
          "ApprovalEligibility" -> "HardDeny"|>]]];
    (* \:691c\:67fb\:901a\:904e: folder \:3092\:958b\:304f\:306e\:306f\:8981\:627f\:8a8d (AskUserAllowed) *)
    <|"Valid" -> True, "Reason" -> "OK", "NormalizedPath" -> normPath,
      "ApprovalEligibility" -> "AskUserAllowed"|>
  ];

(* OpenDesktopItem \:306e Executor\:3002NBAccess \:5185\:90e8\:3067 raw SystemOpen \:3092\:547c\:3076
   \:552f\:4e00\:306e\:5834\:6240\:3002\:627f\:8a8d\:6e08\:307f + \:518d validate \:901a\:904e\:5f8c\:306b\:306e\:307f\:5230\:9054\:3059\:308b\:3002 *)
iNBExecuteOpenDesktopItem[action_Association] :=
  Module[{check, normPath},
    check = iNBValidateOpenDesktopItem[action];
    If[!TrueQ[check["Valid"]],
      Return[<|"Success" -> False, "Decision" -> "Deny",
        "ReasonClass" -> "PostApprovalValidationFailed",
        "VisibleExplanation" -> "Action target failed re-validation: " <>
          Lookup[check, "Reason", "unknown"]|>]];
    normPath = check["NormalizedPath"];
    Quiet[SystemOpen[normPath]];
    <|"Success" -> True, "Decision" -> "Permit",
      "RawResult" -> Null, "ActionExecuted" -> "OpenDesktopItem",
      "Path" -> normPath|>
  ];

(* ---- WriteNotebookCell action (\:975e desktop final action \:5b9f\:884c\:7d4c\:8def) ----
   LLM \:304c\:751f\:6210\:3057\:305f notebook cell \:3092\:627f\:8a8d\:5f8c\:306b\:66f8\:304d\:8fbc\:3080 final action\:3002
   action \:69cb\:9020: <|"Action"->"WriteNotebookCell", "Cell"-><Cell\:5f0f>,
                 "TargetNotebook"-><nb> (\:7701\:7565\:53ef\:3001Executor \:3067\:88dc\:5b8c)|>
   notebook write \:306f FrontEnd \:64cd\:4f5c (\:7f60 #30) \:306a\:306e\:3067 Executor \:306f\:30e1\:30a4\:30f3\:8a55\:4fa1\:3067
   \:547c\:3070\:308c\:308b\:524d\:63d0 (NBExecuteApprovedAction \:304c\:627f\:8a8d\:5f8c\:30e1\:30a4\:30f3\:8a55\:4fa1\:3067\:547c\:3076)\:3002 *)
iNBValidateWriteNotebookCell[action_Association] :=
  Module[{cell, opts, hasAutoEval},
    cell = Lookup[action, "Cell", None];
    (* Cell \:5f0f\:3067\:3042\:308b\:3053\:3068 *)
    If[!MatchQ[cell, _Cell],
      Return[<|"Valid" -> False, "Reason" -> "NotACell",
        "ApprovalEligibility" -> "HardDeny"|>]];
    (* Cell \:30aa\:30d7\:30b7\:30e7\:30f3\:306b\:81ea\:52d5\:8a55\:4fa1\:7cfb\:306e\:5371\:967a\:8a2d\:5b9a\:304c\:306a\:3044\:304b\:8efd\:304f\:30c1\:30a7\:30c3\:30af\:3002
       Evaluatable->True \:5358\:4f53\:306f\:8a31\:3059\:304c\:3001Initialization \:3084\:81ea\:52d5\:5b9f\:884c\:3092\:4ed5\:8fbc\:3093\:3060
       Cell \:306f\:62d2\:5426\:3059\:308b (\:66f8\:304d\:8fbc\:307f\:6642\:306b\:52dd\:624b\:306b\:8a55\:4fa1\:3055\:308c\:308b\:306e\:3092\:9632\:3050)\:3002 *)
    opts = Cases[cell, (Rule | RuleDelayed)[k_, v_] :> {SymbolName[k], v},
      {0, Infinity}];
    hasAutoEval = AnyTrue[opts,
      MemberQ[{"InitializationCell", "CellAutoOverwrite"}, First[#]] &&
        TrueQ[Last[#]] &];
    If[hasAutoEval,
      Return[<|"Valid" -> False, "Reason" -> "AutoEvalCellNotAllowed",
        "ApprovalEligibility" -> "HardDeny"|>]];
    (* notebook write \:306f FrontEnd \:64cd\:4f5c\:3002\:627f\:8a8d\:3092\:8981\:3059\:308b (final node)\:3002 *)
    <|"Valid" -> True, "ApprovalEligibility" -> "AskUserAllowed"|>
  ];

iNBExecuteWriteNotebookCell[action_Association] :=
  Module[{check, cell, nb},
    check = iNBValidateWriteNotebookCell[action];
    If[!TrueQ[check["Valid"]],
      Return[<|"Success" -> False, "Decision" -> "Deny",
        "ReasonClass" -> "PostApprovalValidationFailed",
        "VisibleExplanation" -> "Action target failed re-validation: " <>
          Lookup[check, "Reason", "unknown"]|>]];
    cell = Lookup[action, "Cell", None];
    nb = Lookup[action, "TargetNotebook", Automatic];
    (* TargetNotebook \:304c NotebookObject \:306a\:3089\:305d\:3053\:3078\:3001\:306a\:3051\:308c\:3070 CellPrint \:3067
       \:8a55\:4fa1\:30bb\:30eb\:76f4\:5f8c\:306b\:51fa\:3059 (\:3069\:3061\:3089\:3082\:30e1\:30a4\:30f3\:8a55\:4fa1\:524d\:63d0\:3001\:7f60 #30)\:3002 *)
    If[MatchQ[nb, _NotebookObject],
      Quiet[NBAccess`NBWriteCell[nb, cell, After]],
      Quiet[CellPrint[cell]]];
    <|"Success" -> True, "Decision" -> "Permit",
      "RawResult" -> Null, "ActionExecuted" -> "WriteNotebookCell"|>
  ];

NBRegisterAction["OpenDesktopItem",
  <|"EffectClass" -> "DesktopAction",
    "DefaultApprovalEligibility" -> "AskUserAllowed",
    "AllowedTargetTypes" -> {"Folder"},
    "RequiresFinalNode" -> True,
    "BlockingRisk" -> "MayBlockFrontEnd",
    "ExecutionPlacement" -> "DesktopAction",
    "Validator" -> iNBValidateOpenDesktopItem,
    "Executor" -> iNBExecuteOpenDesktopItem|>];

(* notebook cell \:66f8\:304d\:8fbc\:307f action (\:975e desktop final action)\:3002
   FrontEnd \:64cd\:4f5c\:306a\:306e\:3067 final node (\:30e1\:30a4\:30f3\:8a55\:4fa1\:3067\:5b9f\:884c)\:3002 *)
NBRegisterAction["WriteNotebookCell",
  <|"EffectClass" -> "FrontEndWrite",
    "DefaultApprovalEligibility" -> "AskUserAllowed",
    "AllowedTargetTypes" -> {"Cell"},
    "RequiresFinalNode" -> True,
    "BlockingRisk" -> "MayBlockFrontEnd",
    "ExecutionPlacement" -> "FrontEndRequired",
    "Validator" -> iNBValidateWriteNotebookCell,
    "Executor" -> iNBExecuteWriteNotebookCell|>];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   ExternalTask action + scoped-permit (v7 \[Section]14 / Phase 2b)

   \:8a2d\:8a08: NetworkAccess / ExternalProcess \:306e categorical HardDeny
   (\:30b0\:30ed\:30fc\:30d0\:30eb $iNBEffectClassEligibility) \:306f\:4e00\:5207\:5909\:66f4\:3057\:306a\:3044\:3002
   scoped-permit \:306f\:672c action \:306e Validator \:5185\:3060\:3051\:306b\:9589\:3058\:8fbc\:3081\:308b\:3002
   \:3088\:3063\:3066\:65e2\:5b58\:306e held-expr \:691c\:8a3c (NBValidateHeldExpr) \:306f\:7121\:50b7\:3067\:3042\:308a\:3001
   \:5ba3\:8a00\:7684 ExternalTask (WolframScriptTask role + scope) \:306e\:307f\:304c\:6607\:683c\:3059\:308b\:3002

   P0: scope \:5185\:306f AskUserAllowed \:6b62\:307e\:308a (AutoPermit / workflow pre-approval \:306f
   Phase 3 \:4ee5\:964d)\:3002scope \:5916\:30fbrole \:4e0d\:4e00\:81f4\:306f HardDeny\:3002StrictSafe \:7b49\:3067\:306e\:6700\:7d42\:7684\:306a
   \:62d2\:5426\:306f\:5f8c\:6bb5\:306e iNBApplyPermissionMode \:304c\:62c5\:3046\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

(* network target (host+port) \:304c scope \:5185\:304b\:3002P0 \:306f host+port \:5b8c\:5168\:4e00\:81f4\:3002
   allow \:5074\:304c "Scheme" \:3092\:6307\:5b9a\:3057\:3066\:3044\:308c\:3070 scheme \:3082\:4e00\:81f4\:3092\:8981\:6c42\:3002
   wildcard (HostPattern) \:306f P0 \:672a\:5b9f\:88c5\:306e\:305f\:3081 scope \:4ed8\:4e0e\:3057\:306a\:3044 (v7 \[Section]7.2)\:3002 *)
iNBNetTargetMatch[req_Association, allow_Association] :=
  And[
    ! KeyExistsQ[allow, "HostPattern"],
    StringQ[Lookup[req, "Host", None]],
    Lookup[req, "Host", None] === Lookup[allow, "Host", Null],
    Lookup[req, "Port", None] === Lookup[allow, "Port", Null],
    (Lookup[allow, "Scheme", Automatic] === Automatic ||
       Lookup[allow, "Scheme", Null] === Lookup[req, "Scheme", None])
  ];
iNBNetTargetMatch[_, _] := False;
iNBNetTargetInScope[req_, allowedList_List] :=
  ListQ[allowedList] && AnyTrue[allowedList, iNBNetTargetMatch[req, #] &];

(* directory \:304c scope \:5185\:304b\:3002P0 \:306f exact \:307e\:305f\:306f prefix \:4e00\:81f4\:3002 *)
iNBDirInScope[d_, allowedDirs_List] :=
  StringQ[d] && AnyTrue[allowedDirs,
    (StringQ[#] && (d === # || StringStartsQ[d, # ])) &];

(* v7 \[Section]6.3: workflow pre-approval\:3002accessSpec["ApprovedNetworkTargets"] \:306b
   host+port \:4e00\:81f4 \:304b\:3064 \:672a\:5931\:52b9 (ExpiresAt \:306f UnixTime \:79d2\:3001\:6b20\:843d/\:975e\:6570\:5024\:306f\:672a\:5931\:52b9\:6271\:3044)
   \:306e\:30a8\:30f3\:30c8\:30ea\:304c\:3042\:308c\:3070\:3001\:305d\:306e target \:306f pre-approved\:3002 *)
iNBNotExpiredQ[entry_Association, now_] :=
  With[{e = Lookup[entry, "ExpiresAt", None]},
    e === None || ! NumericQ[e] || e > now];
iNBNotExpiredQ[_, _] := True;

iNBPreApprovedNetQ[req_, accessSpec_Association, now_] :=
  Module[{approved},
    approved = Lookup[accessSpec, "ApprovedNetworkTargets", {}];
    ListQ[approved] &&
      AnyTrue[approved, iNBNetTargetMatch[req, #] && iNBNotExpiredQ[#, now] &]
  ];

(* ExternalTask Validator (2 \:5f15\:6570; ValidatorWantsAccessSpec)\:3002
   action \:306e DeclaredEffectClasses \:3068 Target \:3092\:3001accessSpec \:306e role + scope
   \:306b\:7a81\:5408\:3057\:3001effect \:3054\:3068\:306e eligibility \:3092\:6700\:3082\:53b3\:3057\:3044\:5074\:306b\:96c6\:7d04\:3057\:3066\:8fd4\:3059\:3002
   v7 \[Section]6.3: WorkflowSafe \:304b\:3064\:5168 NetworkTarget \:304c pre-approved \:306a\:3089 AutoPermit\:3002 *)
iNBValidateExternalTask[action_Association, accessSpec_Association] :=
  Module[{role, effects, reqNets, reqDirs, allowNets, allowDirs, allowCmds,
          fsMode, isWS, eligs, agg, reasons = {}},
    role     = Lookup[accessSpec, "ExecutionRole", None];
    isWS     = (role === "WolframScriptTask");
    effects  = Lookup[action, "DeclaredEffectClasses",
                 Lookup[action, "EffectClasses", {}]];
    reqNets  = Lookup[Lookup[action, "Target", <||>], "NetworkTargets", {}];
    reqDirs  = Lookup[Lookup[action, "Target", <||>], "Directories", {}];
    allowNets = Lookup[accessSpec, "AllowedNetworkTargets", {}];
    allowDirs = Lookup[accessSpec, "AllowedDirectories", {}];
    allowCmds = Lookup[accessSpec, "AllowedExternalCommands", {}];
    fsMode   = Lookup[accessSpec, "MayAccessFileSystem", "None"];

    (* role \:304c WolframScriptTask \:4ee5\:5916\:306a\:3089\:5916\:90e8 task \:306e scope \:6607\:683c\:306f\:4e00\:5207\:3057\:306a\:3044 *)
    If[! isWS,
      Return[<|"Valid" -> False, "Reason" -> "RoleNotWolframScriptTask",
        "ApprovalEligibility" -> "HardDeny"|>]];

    eligs = Map[
      Function[ec,
        Switch[ec,
          "NetworkAccess",
            If[ListQ[reqNets] && reqNets =!= {} &&
               AllTrue[reqNets, iNBNetTargetInScope[#, allowNets] &],
              (* scope \:5185\:3002WorkflowSafe \:304b\:3064\:5168 target \:304c\:672a\:5931\:52b9 pre-approved \:306a\:3089 AutoPermit *)
              If[Lookup[accessSpec, "PermissionMode", "InteractiveSafe"] === "WorkflowSafe" &&
                 AllTrue[reqNets, iNBPreApprovedNetQ[#, accessSpec, UnixTime[]] &],
                "AutoPermit", "AskUserAllowed"],
              (AppendTo[reasons, "NetworkTargetOutOfScope"]; "HardDeny")],
          "ExternalProcess",
            (* \:4efb\:610f\:5916\:90e8 process \:306f\:4e0d\:53ef\:3002runner \:8d77\:52d5\:5c02\:7528 command \:306e\:307f\:3002 *)
            If[MemberQ[allowCmds, "wolframscript-runner"],
              "AskUserAllowed",
              (AppendTo[reasons, "ExternalCommandNotAllowed"]; "HardDeny")],
          "FileSystemWrite",
            If[MemberQ[{"ScopedWrite", "ScopedReadWrite"}, fsMode] &&
               (reqDirs === {} || AllTrue[reqDirs, iNBDirInScope[#, allowDirs] &]),
              "AskUserAllowed",
              (AppendTo[reasons, "FileWriteOutOfScope"]; "HardDeny")],
          "FileSystemRead" | "ReadOnlyFileSystem",
            If[MemberQ[{"ReadOnly", "ScopedRead", "ScopedReadWrite"}, fsMode] &&
               (reqDirs === {} || AllTrue[reqDirs, iNBDirInScope[#, allowDirs] &]),
              "AskUserAllowed",
              (AppendTo[reasons, "FileReadOutOfScope"]; "HardDeny")],
          "PureComputation" | "LongRunningComputation",
            "AutoPermit",
          _,
            (* \:672a\:77e5 effect \:306f\:5b89\:5168\:5074 *)
            (AppendTo[reasons, "UnknownEffectClass:" <> ToString[ec]]; "HardDeny")
        ]
      ],
      If[ListQ[effects], effects, {}]
    ];
    (* effect \:672a\:5ba3\:8a00\:306f\:5b89\:5168\:5074\:3067\:627f\:8a8d\:8981\:6c42 (\:5b9f\:52b9\:5883\:754c\:306f runner \:5074\:306e NBCheck \:7cfb guard) *)
    If[eligs === {}, eligs = {"AskUserAllowed"}];

    agg = First @ MaximalBy[eligs, iNBEligibilityRank, 1];
    <|"Valid" -> (agg =!= "HardDeny"),
      "ApprovalEligibility" -> agg,
      "Reason" -> If[reasons === {}, "OK", StringRiffle[DeleteDuplicates[reasons], ","]]|>
  ];
iNBValidateExternalTask[action_Association] :=
  (* accessSpec \:7121\:3057\:547c\:3073\:51fa\:3057\:306f scope \:4e0d\:660e -> \:5b89\:5168\:5074 HardDeny *)
  <|"Valid" -> False, "Reason" -> "NoAccessSpec",
    "ApprovalEligibility" -> "HardDeny"|>;

NBRegisterAction["ExternalTask",
  <|"EffectClass" -> "ExternalProcess",
    "DefaultApprovalEligibility" -> "HardDeny",
    "AllowedTargetTypes" -> {"NetworkTarget", "Directory"},
    "RequiresFinalNode" -> False,
    "BlockingRisk" -> "LowMainKernel",
    "ExecutionPlacement" -> "WolframScriptProcess",
    "ValidatorWantsAccessSpec" -> True,
    "Validator" -> iNBValidateExternalTask|>];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Cooperative I/O guards (Phase 4.B): runner handler \:304c I/O \:76f4\:524d\:306b\:547c\:3076\:3002
   scope-match \:306f ExternalTask \:306e iNBDirInScope / iNBNetTargetInScope \:3092\:518d\:5229\:7528\:3002
   \:771f\:306e OS sandbox \:3067\:306f\:306a\:3044 (handler \:304c\:81ea\:767a\:7684\:306b\:901a\:3059\:524d\:63d0; lint \:3067 raw I/O \:3092\:691c\:51fa)\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

iNBAllow[]            := <|"Allowed" -> True,  "Reason" -> "OK"|>;
iNBDeny[reason_String] := <|"Allowed" -> False, "Reason" -> reason|>;

NBCheckFileWrite[path_String, accessSpec_Association] :=
  Module[{fs, dirs},
    fs   = iNBFSEnumNormalize[Lookup[accessSpec, "MayAccessFileSystem", "None"]];
    dirs = Lookup[accessSpec, "AllowedDirectories", {}];
    Which[
      ! MemberQ[{"ScopedWrite", "ScopedReadWrite"}, fs], iNBDeny["FileWriteNotPermitted:" <> fs],
      iNBDirInScope[path, dirs], iNBAllow[],
      True, iNBDeny["PathOutOfScope"]
    ]
  ];
NBCheckFileWrite[_, _] := iNBDeny["BadArguments"];

NBCheckFileRead[path_String, accessSpec_Association] :=
  Module[{fs, dirs},
    fs   = iNBFSEnumNormalize[Lookup[accessSpec, "MayAccessFileSystem", "None"]];
    dirs = Lookup[accessSpec, "AllowedDirectories", {}];
    Which[
      fs === "ReadOnly", iNBAllow[],   (* legacy broad read *)
      MemberQ[{"ScopedRead", "ScopedReadWrite"}, fs] && iNBDirInScope[path, dirs], iNBAllow[],
      MemberQ[{"ScopedRead", "ScopedReadWrite"}, fs], iNBDeny["PathOutOfScope"],
      True, iNBDeny["FileReadNotPermitted:" <> fs]
    ]
  ];
NBCheckFileRead[_, _] := iNBDeny["BadArguments"];

(* target \:306f <|Scheme,Host,Port|> \:307e\:305f\:306f URL \:6587\:5b57\:5217 *)
iNBNormalizeNetTarget[t_Association] := t;
iNBNormalizeNetTarget[url_String] :=
  Module[{p},
    p = Quiet @ Check[URLParse[url], <||>];
    <|"Scheme" -> Lookup[p, "Scheme", None],
      "Host"   -> Lookup[p, "Domain", None],
      "Port"   -> Replace[Lookup[p, "Port", None],
                    None :> Switch[Lookup[p, "Scheme", ""],
                      "https", 443, "http", 80, "imap", 993, _, None]]|>
  ];
iNBNormalizeNetTarget[_] := <||>;

NBCheckNetworkAccess[target_, accessSpec_Association] :=
  Module[{allow, tgt},
    allow = Lookup[accessSpec, "AllowedNetworkTargets", {}];
    tgt   = iNBNormalizeNetTarget[target];
    Which[
      ! ListQ[allow] || allow === {}, iNBDeny["NoNetworkScope"],
      iNBNetTargetInScope[tgt, allow], iNBAllow[],
      True, iNBDeny["NetworkTargetOutOfScope"]
    ]
  ];

NBCheckExternalProcess[cmd_, accessSpec_Association] :=
  Module[{allow, name},
    allow = Lookup[accessSpec, "AllowedExternalCommands", {}];
    name  = Which[
      StringQ[cmd], cmd,
      ListQ[cmd] && Length[cmd] > 0 && StringQ[First[cmd]], First[cmd],
      True, ""];
    If[ListQ[allow] && (MemberQ[allow, name] ||
        MemberQ[allow, "wolframscript-runner"] &&
          StringContainsQ[ToLowerCase[name], "wolframscript"]),
      iNBAllow[], iNBDeny["ExternalCommandNotAllowed"]]
  ];

(* ---- NBChecked* wrappers: check \:3057\:3066\:304b\:3089 I/O\:3002\:9055\:53cd\:306f AccessSpecViolation ---- *)
iNBViolation[chk_] := <|"Status" -> "Failed",
  "ReasonClass" -> "AccessSpecViolation", "Reason" -> Lookup[chk, "Reason", "denied"]|>;

NBCheckedExport[path_String, expr_, fmt_String, accessSpec_Association] :=
  Module[{chk}, chk = NBCheckFileWrite[path, accessSpec];
    If[TrueQ[chk["Allowed"]],
      <|"Status" -> "OK", "Result" -> Quiet @ Export[path, expr, fmt], "Path" -> path|>,
      iNBViolation[chk]]];

NBCheckedFileWrite[path_String, content_, accessSpec_Association] :=
  Module[{chk}, chk = NBCheckFileWrite[path, accessSpec];
    If[TrueQ[chk["Allowed"]],
      <|"Status" -> "OK",
        "Result" -> Quiet @ Module[{s = OpenWrite[path]}, WriteString[s, content]; Close[s]],
        "Path" -> path|>,
      iNBViolation[chk]]];

NBCheckedImport[path_String, fmt_String, accessSpec_Association] :=
  Module[{chk}, chk = NBCheckFileRead[path, accessSpec];
    If[TrueQ[chk["Allowed"]],
      <|"Status" -> "OK", "Result" -> Quiet @ Import[path, fmt]|>, iNBViolation[chk]]];

NBCheckedFileRead[path_String, accessSpec_Association] :=
  Module[{chk}, chk = NBCheckFileRead[path, accessSpec];
    If[TrueQ[chk["Allowed"]],
      <|"Status" -> "OK", "Result" -> Quiet @ ReadString[path]|>, iNBViolation[chk]]];

NBCheckedURLRead[url_String, accessSpec_Association] :=
  Module[{chk}, chk = NBCheckNetworkAccess[url, accessSpec];
    If[TrueQ[chk["Allowed"]],
      <|"Status" -> "OK", "Result" -> Quiet @ URLRead[url]|>, iNBViolation[chk]]];

(* ---- PolicySnapshot per-call \:9069\:7528 (P0 \[Section]8.3: digest \:691c\:8a3c + \:6b63\:898f\:5316\:306e\:307f) ---- *)
NBApplyPolicySnapshot[snapshot_Association] :=
  Module[{acc},
    acc = NBAcceptPolicySnapshot[snapshot];
    If[TrueQ[Lookup[acc, "Valid", False]],
      <|"Valid" -> True, "Snapshot" -> snapshot, "Reason" -> None|>,
      <|"Valid" -> False, "Snapshot" -> None,
        "Reason" -> Lookup[acc, "Reason", "Invalid"]|>]
  ];
NBApplyPolicySnapshot[_] := <|"Valid" -> False, "Snapshot" -> None, "Reason" -> "NotAssociation"|>;

(* ---- ConfidentialHandling gate (v7 \[Section]13D.1) ---- *)
NBConfidentialHandlingAllowedQ[mode_String, permissionMode_String] :=
  Switch[mode,
    "EncryptedBundle" | "ReferenceOnly" | "Redacted", True,
    "PlaintextDebug",
      TrueQ[Quiet @ Check[$ClaudeAllowPlaintextExternalJobDebug === True, False]] &&
        MemberQ[{"DangerFullAccess"}, permissionMode],
    _, False
  ];
NBConfidentialHandlingAllowedQ[___] := False;

(* ---- credential-ref \:89e3\:6c7a (secret \:306f\:8fd4\:3055\:306a\:3044; descriptor \:306e\:307f) ---- *)
NBResolveCredentialRef[ref_String, accessSpec_Association:<||>] :=
  Module[{refs, provider},
    refs = Lookup[accessSpec, "CredentialRefs", {}];
    (* accessSpec \:304c CredentialRefs \:3092\:5ba3\:8a00\:3057\:3066\:3044\:308b\:306a\:3089\:3001\:305d\:306e ref \:306e\:307f\:8a31\:53ef *)
    If[ListQ[refs] && refs =!= {} && ! MemberQ[refs, ref],
      Return[<|"Resolved" -> False, "Reason" -> "CredentialRefNotInScope"|>]];
    provider = Which[
      StringContainsQ[ref, "anthropic"], "anthropic",
      StringContainsQ[ref, "openai"],    "openai",
      StringContainsQ[ref, "github"],    "github",
      True, None];
    If[provider === None,
      <|"Resolved" -> False, "Reason" -> "UnknownCredentialRef",
        "Note" -> "IMAP/OAuth \:306f SystemCredential \:30d9\:30fc\:30b9\:306e\:62e1\:5f35\:304c\:5fc5\:8981 (Phase 5)"|>,
      (* secret \:306f\:8fd4\:3055\:306a\:3044: handler \:304c NBGetAPIKey[provider] \:3092\:547c\:3076\:305f\:3081\:306e descriptor *)
      <|"Resolved" -> True, "Provider" -> provider,
        "Accessor" -> "NBGetAPIKey"|>]
  ];

(* ---- NBValidateAction: action \:3092\:691c\:8a3c\:3057 Decision \:3092\:8fd4\:3059 ---- *)
NBValidateAction[action_Association, accessSpec_Association] :=
  Module[{name, reg, vfn, vres, baseElig, ec, mode, transformed,
          requiresFinal},
    name = Lookup[action, "Action", None];
    reg = Lookup[$NBActionRegistry, name, None];
    If[!AssociationQ[reg],
      Return[<|"Decision" -> "Deny", "BaseDecision" -> "Deny",
        "ReasonClass" -> "UnknownAction",
        "VisibleExplanation" -> "Unknown action: " <> ToString[name],
        "ApprovalEligibility" -> "HardDeny", "AllowApprovalUI" -> False,
        "MayExecute" -> False|>]];
    ec = Lookup[reg, "EffectClass", "DesktopAction"];
    requiresFinal = TrueQ[Lookup[reg, "RequiresFinalNode", True]];
    (* registry \:306e Validator \:3067 path \:7b49\:3092\:691c\:67fb\:3057 eligibility \:3092\:78ba\:5b9a *)
    vfn = Lookup[reg, "Validator", None];
    (* Validator \:306f\:65e2\:5b9a\:3067 vfn[action] (1 \:5f15\:6570, \:5f8c\:65b9\:4e92\:63db)\:3002
       registry \:304c "ValidatorWantsAccessSpec" -> True \:3092\:5ba3\:8a00\:3059\:308b action \:306e\:307f
       vfn[action, accessSpec] (2 \:5f15\:6570) \:3092\:547c\:3076\:3002scoped-permit (Phase 2b) \:3067
       role/scope \:3092\:898b\:308b\:305f\:3081\:306b ExternalTask validator \:304c\:4f7f\:3046\:3002 *)
    vres = Which[
      vfn === None,
        <|"Valid" -> True,
          "ApprovalEligibility" -> Lookup[reg, "DefaultApprovalEligibility", "AskUserAllowed"]|>,
      TrueQ[Lookup[reg, "ValidatorWantsAccessSpec", False]],
        vfn[action, accessSpec],
      True,
        vfn[action]];
    baseElig = If[TrueQ[Lookup[vres, "Valid", False]],
      Lookup[vres, "ApprovalEligibility",
        Lookup[reg, "DefaultApprovalEligibility", "AskUserAllowed"]],
      "HardDeny"];
    (* PermissionMode \:5909\:63db (I12: accessSpec \:306e\:5024\:3092\:6b63\:3068\:3059\:308b) *)
    mode = Lookup[accessSpec, "PermissionMode",
      If[StringQ[$ClaudePermissionMode], $ClaudePermissionMode, "InteractiveSafe"]];
    If[!StringQ[mode], mode = "InteractiveSafe"];
    transformed = iNBApplyPermissionMode[baseElig, mode];
    <|"Decision" -> transformed["Decision"],
      "BaseDecision" -> If[baseElig === "HardDeny", "Deny", "NeedsApproval"],
      "EffectClass" -> ec,
      "ApprovalEligibility" -> baseElig,
      "ExecutionPlacement" -> Lookup[reg, "ExecutionPlacement", "DesktopAction"],
      "RequiresFinalNode" -> requiresFinal,
      "ExecutionDisposition" -> transformed["ExecutionDisposition"],
      "AllowApprovalUI" -> transformed["AllowApprovalUI"],
      "MayExecute" -> transformed["MayExecute"],
      "PermissionMode" -> mode,
      "ReasonClass" -> If[baseElig === "HardDeny",
        Lookup[vres, "Reason", "ActionDenied"], "AccessEscalationRequired"],
      "VisibleExplanation" -> If[baseElig === "HardDeny",
        "Action refused: " <> Lookup[vres, "Reason", "denied"],
        "Action requires approval: " <> ToString[name]]|>
  ];

(* ---- NBExecuteApprovedAction: \:627f\:8a8d\:6e08\:307f action \:3092\:5b9f\:884c ----
   TOCTOU \:5bfe\:7b56: \:5b9f\:884c\:76f4\:524d\:306b\:518d validate (NBValidateAction)\:3002
   \:627f\:8a8d\:6e08\:307f\:3067\:3082 HardDeny / path \:5909\:5316\:306a\:3089\:62d2\:5426\:3002 *)
Options[NBExecuteApprovedAction] = {"ApprovalMode" -> "UserApproved"};
NBExecuteApprovedAction[action_Association, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{name, reg, recheck, decision, approvalMode, efn},
    approvalMode = OptionValue["ApprovalMode"];
    name = Lookup[action, "Action", None];
    reg = Lookup[$NBActionRegistry, name, None];
    If[!AssociationQ[reg],
      Return[<|"Success" -> False, "Decision" -> "Deny",
        "ReasonClass" -> "UnknownAction",
        "VisibleExplanation" -> "Unknown action: " <> ToString[name]|>]];
    (* \:518d validate (TOCTOU) *)
    recheck = NBValidateAction[action, accessSpec];
    decision = Lookup[recheck, "Decision", "Deny"];
    (* \:627f\:8a8d\:6e08\:307f (UserApproved) \:306e\:3068\:304d NeedsApproval \:3092\:8a31\:53ef\:3002Deny \:306f\:4e0d\:53ef\:3002 *)
    Which[
      decision === "Deny",
        <|"Success" -> False, "Decision" -> "Deny",
          "ReasonClass" -> Lookup[recheck, "ReasonClass", "ActionDenied"],
          "VisibleExplanation" -> Lookup[recheck, "VisibleExplanation", ""]|>,
      decision === "Permit" ||
        (decision === "NeedsApproval" && approvalMode === "UserApproved"),
        (* Executor \:3092\:547c\:3076 (NBAccess \:5185\:90e8\:3001raw SystemOpen \:306f\:3053\:3053\:3060\:3051) *)
        efn = Lookup[reg, "Executor", None];
        If[efn === None,
          <|"Success" -> False, "Decision" -> "Deny",
            "ReasonClass" -> "NoExecutor",
            "VisibleExplanation" -> "No executor for action: " <> ToString[name]|>,
          efn[action]],
      True,
        <|"Success" -> False, "Decision" -> decision,
          "ReasonClass" -> "ApprovalRequired",
          "VisibleExplanation" -> "Action not approved: " <> ToString[name]|>
    ]
  ];

(* ---- NBOpenFolderWithApproval: \:8584\:3044\:4e92\:63db wrapper (spec 5B.7) ---- *)
NBOpenFolderWithApproval[path_] :=
  NBExecuteApprovedAction[
    <|"Action" -> "OpenDesktopItem", "TargetType" -> "Folder",
      "Path" -> path|>,
    NBMakeRuntimeAccessSpec[<||>, "Committer"]];
NBOpenFolderWithApproval[path_, accessSpec_Association] :=
  NBExecuteApprovedAction[
    <|"Action" -> "OpenDesktopItem", "TargetType" -> "Folder",
      "Path" -> path|>, accessSpec];


(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase frontend-blocking-queue (2026-06-03, spec \:68483-lite):
   PendingFinalActionQueue
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   FrontEnd \:30d6\:30ed\:30c3\:30af\:30ea\:30b9\:30af\:306e\:3042\:308b\:627f\:8a8d\:6e08\:307f action \:3092\:76f4\:63a5\:540c\:671f\:5b9f\:884c\:305b\:305a\:3001
   queue \:306b\:7a4d\:3093\:3067\:5171\:6709 polling tick \:304c\:5b89\:5168\:306a\:9699\:306b 1 \:4ef6\:305a\:3064\:5b9f\:884c\:3059\:308b\:3002
   \:65b0\:898f ScheduledTask \:306f\:4f5c\:3089\:306a\:3044 (claudecode \:306e\:5171\:6709 tick \:306b\:76f8\:4e57\:308a)\:3002
   AsyncActive \:4e2d\:306f WaitAll \:305b\:305a Pending \:306e\:307e\:307e\:5f85\:3064\:3002 *)

If[!AssociationQ[$NBFinalActionQueue], $NBFinalActionQueue = <||>];
If[!IntegerQ[$NBFinalActionCounter], $NBFinalActionCounter = 0];
(* AsyncActive \:5224\:5b9a callback\:3002Automatic \:306e\:3068\:304d ClaudeRuntime \:306b\:5f31\:4f9d\:5b58\:3002 *)
If[!ValueQ[$NBFinalActionAsyncActiveFunction],
  $NBFinalActionAsyncActiveFunction = Automatic];
(* queue item \:306e\:30c7\:30d5\:30a9\:30eb\:30c8\:5bff\:547d (\:79d2)\:3002 *)
If[!NumericQ[$NBFinalActionDefaultTTL], $NBFinalActionDefaultTTL = 60];

(* ---- AsyncActive \:5224\:5b9a (spec 5A.1) ---- *)
iNBFinalActionAsyncActiveQ[] :=
  Module[{fn = $NBFinalActionAsyncActiveFunction},
    Which[
      fn === Automatic,
        (* ClaudeRuntime \:304c\:30ed\:30fc\:30c9\:6e08\:307f\:306a\:3089\:8a3a\:65ad\:3092\:4f7f\:3046\:3002\:672a\:30ed\:30fc\:30c9\:306a\:3089 False\:3002 *)
        If[Length[Names["ClaudeRuntime`ClaudeRuntimeAsyncActiveQ"]] > 0,
          TrueQ @ Quiet @ Check[
            Symbol["ClaudeRuntime`ClaudeRuntimeAsyncActiveQ"][], False],
          False],
      fn === None || fn === False, False,
      True, TrueQ @ Quiet @ Check[fn[], False]
    ]
  ];

(* ---- FinalActionRunningQ (spec 5A.2): queue \:72b6\:614b\:3060\:3051\:3067\:5224\:5b9a ---- *)
NBFinalActionRunningQ[] :=
  AnyTrue[Values[$NBFinalActionQueue],
    AssociationQ[#] && Lookup[#, "Status", ""] === "Running" &];

(* ---- enqueue (spec 12: Approve = queue \:6295\:5165\:8a31\:53ef) ---- *)
Options[NBEnqueueFinalAction] = {"TTL" -> Automatic,
  "ApprovalStatus" -> "UserApproved", "MaxRetries" -> 100};
NBEnqueueFinalAction[action_Association, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{name, reg, validation, actionID, ttl, now, item},
    name = Lookup[action, "Action", None];
    reg = Lookup[$NBActionRegistry, name, None];
    If[!AssociationQ[reg],
      Return[<|"Enqueued" -> False, "ReasonClass" -> "UnknownAction",
        "VisibleExplanation" -> "Unknown action: " <> ToString[name]|>]];
    (* enqueue \:524d\:691c\:8a3c: HardDeny \:306f queue \:306b\:7a4d\:307e\:306a\:3044 (spec 14)\:3002 *)
    validation = NBValidateAction[action, accessSpec];
    If[Lookup[validation, "ApprovalEligibility", "HardDeny"] === "HardDeny" ||
       Lookup[validation, "Decision", "Deny"] === "Deny",
      Return[<|"Enqueued" -> False, "ReasonClass" -> "HardDenyNotQueued",
        "VisibleExplanation" -> Lookup[validation, "VisibleExplanation",
          "Action is hard-denied"]|>]];
    now = AbsoluteTime[];
    ttl = OptionValue["TTL"];
    If[ttl === Automatic, ttl = $NBFinalActionDefaultTTL];
    $NBFinalActionCounter++;
    actionID = "finalaction-" <> ToString[$NBFinalActionCounter] <> "-" <>
      ToString[Round[now]];
    item = <|
      "ActionID" -> actionID,
      "Action" -> name,
      "ActionAssoc" -> action,
      "AccessSpec" -> accessSpec,
      "EffectClass" -> Lookup[validation, "EffectClass", "DesktopAction"],
      "ExecutionPlacement" -> Lookup[validation, "ExecutionPlacement", "DesktopAction"],
      "BlockingRisk" -> Lookup[reg, "BlockingRisk", "MayBlockFrontEnd"],
      "ApprovalStatus" -> OptionValue["ApprovalStatus"],
      "RequiresFinalNode" -> TrueQ[Lookup[reg, "RequiresFinalNode", True]],
      "Status" -> "Pending",
      "CreatedAt" -> now,
      "ExpiresAt" -> now + ttl,
      "RetryCount" -> 0,
      "MaxRetries" -> OptionValue["MaxRetries"],
      "Result" -> None|>;
    $NBFinalActionQueue[actionID] = item;
    <|"Enqueued" -> True, "ActionID" -> actionID, "Status" -> "Pending"|>
  ];

(* held expr \:7248 (spec \:68483-lite): action association \:3067\:306f\:306a\:304f held expression
   (NBOpenFolderWithApproval[path] \:7b49\:306e wrapper \:3092\:542b\:3080\:5f0f) \:3092 queue \:5316\:3059\:308b\:3002
   LLM \:304c\:751f\:6210\:3057\:305f FrontEnd \:30d6\:30ed\:30c3\:30af\:30ea\:30b9\:30af\:306e\:3042\:308b\:5f0f\:3092\:3001\:627f\:8a8d\:5f8c\:306b\:76f4\:63a5\:540c\:671f\:5b9f\:884c\:305b\:305a
   queue \:7d4c\:7531\:3067\:5b89\:5168\:306a\:9699\:306b\:5b9f\:884c\:3059\:308b\:305f\:3081\:306e\:7d4c\:8def\:3002executor \:306f NBExecuteHeldExpr\:3002 *)
NBEnqueueFinalAction[heldExpr_HoldComplete, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{validation, actionID, ttl, now, item},
    (* enqueue \:524d\:691c\:8a3c: HardDeny / Deny \:306f\:7a4d\:307e\:306a\:3044 (spec 14)\:3002 *)
    validation = NBValidateHeldExpr[heldExpr, accessSpec];
    If[Lookup[validation, "ApprovalEligibility", "HardDeny"] === "HardDeny" ||
       Lookup[validation, "Decision", "Deny"] === "Deny",
      Return[<|"Enqueued" -> False, "ReasonClass" -> "HardDenyNotQueued",
        "VisibleExplanation" -> Lookup[validation, "VisibleExplanation",
          "Expression is hard-denied"]|>]];
    now = AbsoluteTime[];
    ttl = OptionValue["TTL"];
    If[ttl === Automatic, ttl = $NBFinalActionDefaultTTL];
    $NBFinalActionCounter++;
    actionID = "finalaction-" <> ToString[$NBFinalActionCounter] <> "-" <>
      ToString[Round[now]];
    item = <|
      "ActionID" -> actionID,
      "Action" -> "HeldExpr",
      "HeldExpr" -> heldExpr,
      "AccessSpec" -> accessSpec,
      "EffectClass" -> Lookup[validation, "EffectClass", "DesktopAction"],
      "ExecutionPlacement" -> Lookup[validation, "ExecutionPlacement", "DesktopAction"],
      "BlockingRisk" -> Lookup[validation, "BlockingRisk", "MayBlockFrontEnd"],
      "ApprovalStatus" -> OptionValue["ApprovalStatus"],
      "RequiresFinalNode" -> TrueQ[Lookup[validation, "RequiresFinalNode", True]],
      "Status" -> "Pending",
      "CreatedAt" -> now,
      "ExpiresAt" -> now + ttl,
      "RetryCount" -> 0,
      "MaxRetries" -> OptionValue["MaxRetries"],
      "Result" -> None|>;
    $NBFinalActionQueue[actionID] = item;
    <|"Enqueued" -> True, "ActionID" -> actionID, "Status" -> "Pending"|>
  ];

(* ---- tick (spec 6 \:306e 12 \:30b9\:30c6\:30c3\:30d7): \:5b89\:5168\:6761\:4ef6\:78ba\:8a8d + \:6700\:5927 1 \:4ef6\:5b9f\:884c ---- *)
NBFinalActionTick[opts___] :=
  Module[{pendingIDs, id, item, now, recheck, approvalMode, efn, reg, result},
    (* 1. final action \:5b9f\:884c\:4e2d\:306a\:3089\:4f55\:3082\:3057\:306a\:3044 *)
    If[NBFinalActionRunningQ[], Return[<|"Ticked" -> False, "Reason" -> "FinalActionRunning"|>]];
    (* 2. AsyncActive \:306a\:3089\:4f55\:3082\:3057\:306a\:3044 (WaitAll \:3057\:306a\:3044\:3001Pending \:306e\:307e\:307e) *)
    If[iNBFinalActionAsyncActiveQ[],
      Return[<|"Ticked" -> False, "Reason" -> "AsyncActive"|>]];
    (* 3. \:5148\:982d\:306e Pending item (CreatedAt \:6607\:9806) *)
    now = AbsoluteTime[];
    pendingIDs = Select[Keys[$NBFinalActionQueue],
      AssociationQ[$NBFinalActionQueue[#]] &&
      Lookup[$NBFinalActionQueue[#], "Status", ""] === "Pending" &];
    pendingIDs = SortBy[pendingIDs, Lookup[$NBFinalActionQueue[#], "CreatedAt", 0] &];
    (* 4. Pending \:304c\:7121\:3051\:308c\:3070 return *)
    If[Length[pendingIDs] === 0, Return[<|"Ticked" -> False, "Reason" -> "NoPending"|>]];
    id = First[pendingIDs];
    item = $NBFinalActionQueue[id];
    (* 5. \:671f\:9650\:5207\:308c *)
    If[now > Lookup[item, "ExpiresAt", now + 1],
      item["Status"] = "Expired";
      item["ReasonClass"] = "FinalActionQueueTimeout";
      item["CompletedAt"] = now;
      $NBFinalActionQueue[id] = item;
      Return[<|"Ticked" -> True, "ActionID" -> id, "Status" -> "Expired"|>]];
    (* 6. \:672a\:627f\:8a8d *)
    If[Lookup[item, "ApprovalStatus", ""] =!= "UserApproved",
      item["Status"] = "Failed";
      item["ReasonClass"] = "NotApproved";
      item["CompletedAt"] = now;
      $NBFinalActionQueue[id] = item;
      Return[<|"Ticked" -> True, "ActionID" -> id, "Status" -> "Failed"|>]];
    (* 9. Running \:306b\:9077\:79fb (7,8 \:306f executor \:5185 TOCTOU \:518dvalidate \:306b\:59d4\:8b72) *)
    item["Status"] = "Running";
    $NBFinalActionQueue[id] = item;
    (* 10. NBAccess \:5185\:90e8 executor \:7d4c\:7531\:3067\:5b9f\:884c (UserApproved \:3067 NeedsApproval \:8a31\:53ef) *)
    (* 10. NBAccess \:5185\:90e8 executor \:7d4c\:7531\:3067\:5b9f\:884c (UserApproved \:3067 NeedsApproval \:8a31\:53ef)\:3002
       item \:304c held expr \:306a\:3089 NBExecuteHeldExpr\:3001action \:306a\:3089 NBExecuteApprovedAction\:3002 *)
    result = Quiet @ Check[
      If[Lookup[item, "Action", ""] === "HeldExpr",
        NBExecuteHeldExpr[item["HeldExpr"], item["AccessSpec"],
          "ApprovalMode" -> "UserApproved"],
        NBExecuteApprovedAction[item["ActionAssoc"], item["AccessSpec"],
          "ApprovalMode" -> "UserApproved"]],
      <|"Success" -> False, "Decision" -> "Deny",
        "ReasonClass" -> "ExecutorError"|>];
    (* 11,12. \:7d50\:679c\:683c\:7d0d + Completed/Failed *)
    item = $NBFinalActionQueue[id];
    item["Result"] = result;
    item["CompletedAt"] = AbsoluteTime[];
    If[TrueQ[Lookup[result, "Success", False]],
      item["Status"] = "Completed",
      item["Status"] = "Failed";
      item["ReasonClass"] = Lookup[result, "ReasonClass", "ExecutorFailed"]];
    $NBFinalActionQueue[id] = item;
    <|"Ticked" -> True, "ActionID" -> id, "Status" -> item["Status"],
      "Result" -> result|>
  ];

(* ---- status / cancel / snapshot ---- *)
NBFinalActionStatus[actionID_String] :=
  Lookup[$NBFinalActionQueue, actionID, <|"Status" -> "Unknown"|>];
NBFinalActionStatus[All] := $NBFinalActionQueue;
NBFinalActionStatus[] := $NBFinalActionQueue;

NBCancelFinalAction[actionID_String] :=
  Module[{item},
    item = Lookup[$NBFinalActionQueue, actionID, None];
    If[!AssociationQ[item], Return[<|"Cancelled" -> False, "ReasonClass" -> "Unknown"|>]];
    If[MemberQ[{"Pending", "NeedsRetryAfterAsync"}, Lookup[item, "Status", ""]],
      item["Status"] = "Cancelled";
      item["ReasonClass"] = "UserCancelled";
      item["CompletedAt"] = AbsoluteTime[];
      $NBFinalActionQueue[actionID] = item;
      <|"Cancelled" -> True, "ActionID" -> actionID|>,
      <|"Cancelled" -> False, "ReasonClass" -> "NotCancellable",
        "CurrentStatus" -> Lookup[item, "Status", ""]|>]
  ];

NBFinalActionQueueSnapshot[] :=
  <|"QueueSize" -> Length[$NBFinalActionQueue],
    "Pending" -> Count[Values[$NBFinalActionQueue],
      a_?AssociationQ /; Lookup[a, "Status", ""] === "Pending"],
    "Running" -> Count[Values[$NBFinalActionQueue],
      a_?AssociationQ /; Lookup[a, "Status", ""] === "Running"],
    "AsyncActive" -> iNBFinalActionAsyncActiveQ[],
    "Items" -> $NBFinalActionQueue|>;


(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: NBRedactExecutionResult
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBRedactExecutionResult] = {"MaxSummaryLength" -> 500};

NBRedactExecutionResult[result_Association, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{raw, redacted, maxLen, confSyms, confVarNames, secrets, heldExpr,
          refsConfidential = False, schemaInfo, confOutLines},
    raw = Lookup[result, "RawResult", None];
    maxLen = OptionValue["MaxSummaryLength"];
    
    (* \:6a5f\:5bc6\:5909\:6570\:30ea\:30b9\:30c8\:3092\:7d71\:5408 *)
    confVarNames = Lookup[accessSpec, "ConfidentialSymbols",
      If[ListQ[$NBConfidentialSymbols],
        Keys[$NBConfidentialSymbols], {}]];
    (* Association \:5f62\:5f0f\:306e $NBConfidentialSymbols \:304b\:3089\:30ad\:30fc\:3092\:53d6\:5f97 *)
    If[AssociationQ[$NBConfidentialSymbols],
      confVarNames = DeleteDuplicates @ Join[confVarNames,
        Keys[$NBConfidentialSymbols]]];
    secrets = Lookup[accessSpec, "Secrets", {}];
    (* confSyms = \:5168\:691c\:51fa\:5bfe\:8c61 (\:5909\:6570\:540d + API \:30ad\:30fc\:7b49) *)
    confSyms = DeleteDuplicates @ Join[confVarNames, secrets];
    
    (* \[HorizontalLine]\[HorizontalLine] \:6a5f\:5bc6\:4f9d\:5b58\:30c1\:30a7\:30c3\:30af (Phase 17 fix) \[HorizontalLine]\[HorizontalLine]
       \:5b9f\:884c\:3057\:305f\:5f0f (HeldExpr) \:304c\:6a5f\:5bc6\:5909\:6570\:3092\:53c2\:7167\:3057\:3066\:3044\:308b\:304b\:3092
       \:9759\:7684\:306b\:30c1\:30a7\:30c3\:30af\:3059\:308b\:3002\:53c2\:7167\:3057\:3066\:3044\:308c\:3070\:7d50\:679c\:5168\:4f53\:3092 redact\:3002
       \:3053\:308c\:306b\:3088\:308a\:300c2*v (v=1)\[RightArrow]\:7d50\:679c2\:300d\:306e\:3088\:3046\:306a\:5024\:30ea\:30fc\:30af\:3092\:9632\:3050\:3002
       \:6ce8: HeldExpr \:30c1\:30a7\:30c3\:30af\:306f confVarNames \:306e\:307f (Secrets \:306f\:30b3\:30fc\:30c9\:5185\:306b\:73fe\:308c\:306a\:3044) *)
    heldExpr = Lookup[result, "HeldExpr", None];
    If[MatchQ[heldExpr, HoldComplete[_]] && Length[confVarNames] > 0,
      Module[{exprStr = ToString[heldExpr, InputForm]},
        refsConfidential = AnyTrue[confVarNames,
          StringContainsQ[exprStr,
            RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <>
              "(?![\\p{L}\\p{N}$])"]] &]]];
    
    (* \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af: HeldExpr \:304c\:306a\:3044\:5834\:5408\:306f\:7d50\:679c\:6587\:5b57\:5217\:30d9\:30fc\:30b9\:3067\:30c1\:30a7\:30c3\:30af
       \:6ce8: confVarNames \:306e\:307f\:4f7f\:7528 (Secrets \:306f StringReplace \:3067\:51e6\:7406) *)
    If[!refsConfidential && Length[confVarNames] > 0,
      Module[{rawStr = ToString[Short[raw, 10]]},
        refsConfidential = AnyTrue[confVarNames,
          StringContainsQ[rawStr,
            RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <>
              "(?![\\p{L}\\p{N}$])"]] &]]];

    (* \[HorizontalLine]\[HorizontalLine] Out[n] / In[n] / InString[n] / % \:53c2\:7167\:30c1\:30a7\:30c3\:30af (2026-06-06 \:6f0f\:6d29\:4fee\:6b63) \[HorizontalLine]\[HorizontalLine]
       \:5909\:6570\:540d\:30d9\:30fc\:30b9\:306e\:691c\:51fa\:3060\:3051\:3067\:306f\:3001LLM \:304c Out[13] / In[13] / InString[13] / %13 / %
       \:306e\:3088\:3046\:306b\:6a5f\:5bc6\:30bb\:30eb\:306e\:5165\:529b\:30fb\:51fa\:529b\:3092\:884c\:756a\:53f7\:3067\:76f4\:63a5\:53c2\:7167\:3057\:3066\:5024\:3092\:8aad\:3093\:3060
       \:5834\:5408\:3092\:6355\:6349\:3067\:304d\:306a\:3044 (Out[13] \:306b\:3082\:751f\:7d50\:679c 1 \:306b\:3082\:5909\:6570\:540d\:306f\:73fe\:308c\:305a\:3001
       InString[13] \:306f\:5165\:529b\:6587\:5b57\:5217 \"\:79d8\:533f\:5909\:6570 = Confidential[1]\" \:3092\:305d\:306e\:307e\:307e\:8fd4\:3059)\:3002
       In[n] \:3068 Out[n] \:306f\:540c\:4e00\:306e\:8a55\:4fa1\:884c\:756a\:53f7 n \:3092\:5171\:6709\:3059\:308b\:3002
       accessSpec[\"ConfidentialLineNumbers\"] \:306b\:6a5f\:5bc6\:884c\:756a\:53f7\:304c\:3042\:308c\:3070\:305d\:308c\:3068\:7167\:5408\:3057\:3001
       \:7121\:3051\:308c\:3070\:6a5f\:5bc6\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:5b58\:5728\:6642\:306f\:4fdd\:5b88\:7684\:306b redact \:3059\:308b\:3002 *)
    confOutLines = Lookup[accessSpec, "ConfidentialLineNumbers",
      Lookup[accessSpec, "ConfidentialOutputLines", Automatic]];
    If[!refsConfidential && MatchQ[heldExpr, HoldComplete[_]],
      Module[{refArgs, literalLines = {}, hasRelativeRef = False},
        (* Out[..] \:306f\:6b63\:6574\:6570/\:7a7a/\:8ca0\:3001In[..]/InString[..] \:306f\:5404\:884c\:53c2\:7167 *)
        refArgs = Cases[heldExpr,
          HoldPattern[(Out | In | InString)[a___]] :> HoldComplete[a],
          {0, Infinity}];
        Scan[
          Function[h,
            Replace[h, {
              HoldComplete[n_Integer] /; n > 0 :> AppendTo[literalLines, n],
              _ :> (hasRelativeRef = True)}]],
          refArgs];
        Which[
          (* \:884c\:756a\:53f7\:30de\:30c3\:30d7\:304c\:660e\:793a\:6e21\:3055\:308c\:305f\:5834\:5408: \:7cbe\:5bc6\:7167\:5408 *)
          ListQ[confOutLines],
            If[(hasRelativeRef && Length[confOutLines] > 0) ||
               Length[Intersection[literalLines, confOutLines]] > 0,
              refsConfidential = True],
          (* \:884c\:756a\:53f7\:30de\:30c3\:30d7\:672a\:6307\:5b9a (\:65e7\:547c\:3073\:51fa\:3057): \:6a5f\:5bc6\:30b3\:30f3\:30c6\:30ad\:30b9\:30c8\:304c\:3042\:308b\:306a\:3089
             Out/In/InString/% \:53c2\:7167\:306f\:5b89\:5168\:5224\:5b9a\:3067\:304d\:306a\:3044\:305f\:3081\:4fdd\:5b88\:7684\:306b redact *)
          (Length[literalLines] > 0 || hasRelativeRef) && Length[confSyms] > 0,
            refsConfidential = True
        ]
      ]];

    If[refsConfidential,
      (* \[HorizontalLine]\[HorizontalLine] \:6a5f\:5bc6\:4f9d\:5b58: \:578b\:30fb\:30b5\:30a4\:30ba\:30fbHead \:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:306e\:307f\:8fd4\:3059 \[HorizontalLine]\[HorizontalLine] *)
      schemaInfo = iMakeResultSchema[raw];
      <|"RedactedResult" -> schemaInfo,
        "Summary" -> schemaInfo,
        "ConfidentialDependent" -> True|>,
      (* \[HorizontalLine]\[HorizontalLine] \:975e\:6a5f\:5bc6: \:5f93\:6765\:901a\:308a\:306e redaction \[HorizontalLine]\[HorizontalLine] *)
      redacted = ToString[Short[raw, 10]];
      (* \:5909\:6570\:540d\:3068 Secrets \:306e\:4e21\:65b9\:3092\:6587\:5b57\:5217\:7f6e\:63db *)
      Do[redacted = StringReplace[redacted,
          RegularExpression["(?<![\\p{L}\\p{N}$])" <> s <>
            "(?![\\p{L}\\p{N}$])"] -> "[REDACTED]"],
        {s, confSyms}];
      <|"RedactedResult" -> StringTake[redacted, UpTo[maxLen]],
        "Summary" -> StringTake[redacted, UpTo[200]],
        "ConfidentialDependent" -> False|>
    ]
  ];

(* \:6a5f\:5bc6\:30fb\:6a5f\:5bc6\:4f9d\:5b58 In/Out \:30bb\:30eb\:306e\:8a55\:4fa1\:884c\:756a\:53f7 n \:3092 CellLabel \"In[n]:=\" /
   \"Out[n]=\" \:304b\:3089\:62bd\:51fa\:3059\:308b\:3002In[n] \:3068 Out[n] \:306f\:540c\:4e00 n \:3092\:5171\:6709\:3059\:308b\:305f\:3081\:3001
   In/Out \:3069\:3061\:3089\:306e\:30e9\:30d9\:30eb\:304b\:3089\:3067\:3082\:540c\:3058\:884c\:756a\:53f7\:304c\:5f97\:3089\:308c\:308b\:3002 *)
iExtractLineNumber[lbl_String] :=
  Module[{m},
    m = StringCases[lbl,
      RegularExpression["(?:In|Out)\\[(\\d+)\\]"] :> "$1"];
    If[Length[m] > 0,
      Quiet @ Check[ToExpression[First[m]], Missing[]],
      Missing[]]];
iExtractLineNumber[_] := Missing[];

NBConfidentialLineNumbers[nb_NotebookObject, accessSpec_:<||>] :=
  Module[{threshold, indices, lines = {}},
    threshold = If[AssociationQ[accessSpec],
      Lookup[accessSpec, "AccessLevel", 0.5], 0.5];
    (* \:6a5f\:5bc6\:5165\:529b (Input/Code) \:3068\:6a5f\:5bc6\:51fa\:529b (Output) \:306e\:4e21\:65b9\:3092\:5bfe\:8c61\:306b\:3059\:308b\:3002
       In[13] \:3082 Out[13] \:3082\:884c\:756a\:53f7 13 \:3092\:5171\:6709\:3059\:308b\:306e\:3067\:3001\:3069\:3061\:3089\:304b\:3089\:3067\:3082\:53d6\:5f97\:53ef\:3002 *)
    indices = Quiet @ Check[
      Sort @ DeleteDuplicates @ Join[
        NBAccess`NBCellIndicesByStyle[nb, "Input"],
        NBAccess`NBCellIndicesByStyle[nb, "Code"],
        NBAccess`NBCellIndicesByStyle[nb, "Output"]], {}];
    If[!ListQ[indices], Return[{}]];
    Do[Module[{priv, lbl, n},
        priv = Quiet @ Check[
          NBAccess`NBCellPrivacyLevel[nb, ci], 0];
        If[NumericQ[priv] && priv > threshold,
          lbl = Quiet @ Check[NBAccess`NBCellLabel[nb, ci], ""];
          n = iExtractLineNumber[lbl];
          If[IntegerQ[n], AppendTo[lines, n]]]],
      {ci, indices}];
    DeleteDuplicates[lines]
  ];
NBConfidentialLineNumbers[_, ___] := {};

(* \:5b9f\:884c\:7d50\:679c\:306e\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:751f\:6210\:ff08\:6a5f\:5bc6\:4f9d\:5b58\:6642\:306b\:5024\:306e\:4ee3\:308f\:308a\:306b\:8fd4\:3059\:ff09 *)
iMakeResultSchema[raw_] :=
  Module[{head, info},
    head = Head[raw];
    info = Which[
      raw === Null, "(* [\:6a5f\:5bc6\:4f9d\:5b58: \:526f\:4f5c\:7528\:306e\:307f] *)",
      head === Integer, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: Integer] *)",
      head === Real, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: Real] *)",
      head === Complex, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: Complex] *)",
      head === String, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: String, " <>
        ToString[StringLength[raw]] <> " chars] *)",
      head === List, Module[{dims = Quiet @ Check[Dimensions[raw], {Length[raw]}]},
        "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: List, dimensions " <> ToString[dims] <> "] *)"],
      head === Association, Module[{keys = Take[Keys[raw], UpTo[10]]},
        "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: Association, " <> ToString[Length[raw]] <>
        " keys: {" <> StringRiffle[ToString /@ keys, ", "] <> "}] *)"],
      head === Dataset, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: Dataset] *)",
      head === SparseArray, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: SparseArray] *)",
      MatchQ[raw, _Image | _Graphics | _Graphics3D],
        "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: " <> ToString[head] <> "] *)",
      True, "(* [\:6a5f\:5bc6\:4f9d\:5b58\:30c7\:30fc\:30bf: " <> ToString[head] <> "] *)"
    ];
    info
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 7: NBMakeContextPacket
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBMakeContextPacket] = {
  "CellRange" -> All,
  "IncludeSelection" -> True,
  "MaxCells" -> 50
};

NBMakeContextPacket[nb_, accessSpec_Association, opts:OptionsPattern[]] :=
  Module[{cells = {}, selectedIdx = {}, cellRange, maxCells, packet,
          totalCellCount = 0, threshold},
    cellRange = OptionValue["CellRange"];
    maxCells  = OptionValue["MaxCells"];
    threshold = Lookup[accessSpec, "AccessLevel", 0.5];
    
    (* notebook \:304c\:6709\:52b9\:304b *)
    If[nb === $Failed || nb === None,
      Return[<|"Input" -> None, "Cells" -> {},
        "SelectedCells" -> {}, "AccessSpec" -> accessSpec,
        "NotebookValid" -> False, "TotalCellCount" -> 0|>]];
    
    (* \:5168\:30bb\:30eb\:6570\:3092\:5148\:306b\:53d6\:5f97\:ff08\:30d5\:30a3\:30eb\:30bf\:524d\:ff09 *)
    totalCellCount = Quiet @ Check[NBAccess`NBCellCount[nb], 0];
    
    (* \:30bb\:30eb\:8aad\:307f\:53d6\:308a \[LongDash] Phase 17 fix:
       NBGetCells \:306f\:6574\:6570\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:305f\:3081\:3001
       \:5404\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:304b\:3089\:30bb\:30eb Association \:3092\:69cb\:7bc9\:3059\:308b\:3002
       \:65e7 NBGetContext \:3068\:540c\:7b49\:306e\:6a5f\:5bc6\:51e6\:7406\:3092\:9069\:7528:
       - \:6a5f\:5bc6\:30bb\:30eb (PrivacyLevel > threshold) \[RightArrow] \:30c6\:30ad\:30b9\:30c8\:975e\:8868\:793a\:30de\:30fc\:30ab\:30fc
       - \:6a5f\:5bc6\:5909\:6570\:3092\:542b\:3080\:884c \[RightArrow] iRedactConfidentialLines \:3067\:58a8\:6d88\:3057
       - \:6a5f\:5bc6\:4f9d\:5b58 Output \[RightArrow] iOutputSchemaText \:3067\:30b9\:30ad\:30fc\:30de\:60c5\:5831\:306e\:307f *)
    cells = Quiet @ Check[
      Module[{indices, cellAssocs = {}},
        indices = Range[Min[maxCells, totalCellCount]];
        If[!ListQ[indices], indices = {}];
        
        Do[Module[{privLevel, style, text, redactedText, wasRedacted,
                   depTag},
          privLevel = Quiet @ Check[
            NBAccess`NBCellPrivacyLevel[nb, idx], 0];
          style = Quiet @ Check[
            NBAccess`NBCellStyle[nb, idx], "Unknown"];
          
          If[privLevel > threshold,
            (* Confidential cell. (2026-06-06) Output cells send SCHEMA only
               (data type / size / keys via iOutputSchemaText \[LongDash] no values) when
               $NBSendDataSchema is True, so a cloud LLM can still understand the
               structure and propose code without the actual data (e.g. mail rows)
               leaking. Non-Output confidential cells (Input/Text/...) stay fully
               masked. $NBSendDataSchema = False \:3067\:5f93\:6765\:901a\:308a\:5168\:30de\:30b9\:30af\:3002 *)
            If[style === "Output" && NBAccess`$NBSendDataSchema =!= False,
              AppendTo[cellAssocs, <|
                "CellIndex" -> idx,
                "CellStyle" -> style,
                "InputText" -> iOutputSchemaText[nb, idx],
                "PrivacyLevel" -> privLevel,
                "ConfidentialDependent" -> True|>],
              AppendTo[cellAssocs, <|
                "CellIndex" -> idx,
                "CellStyle" -> style,
                "InputText" -> "(* [\:6a5f\:5bc6\:30bb\:30eb: \:975e\:8868\:793a] *)",
                "PrivacyLevel" -> privLevel,
                "Confidential" -> True|>]],
            (* \[HorizontalLine]\[HorizontalLine] \:975e\:6a5f\:5bc6\:30bb\:30eb: \:6a5f\:5bc6\:5909\:6570\:306e\:58a8\:6d88\:3057\:51e6\:7406 \[HorizontalLine]\[HorizontalLine] *)
            text = Quiet @ Check[
              NBAccess`NBCellGetText[nb, idx], ""];
            If[!StringQ[text], text = ""];
            text = StringTake[text, UpTo[500]];
            {redactedText, wasRedacted} =
              iRedactConfidentialLines[text];
            (* \:6a5f\:5bc6\:5909\:6570\:4f9d\:5b58\:306e Output \:304b\:30c1\:30a7\:30c3\:30af *)
            depTag = Quiet @ Check[
              NBAccess`NBCellGetTaggingRule[nb, idx,
                {"claudecode", "dependent"}], False];
            If[TrueQ[depTag] && (style === "Output"),
              (* \:6a5f\:5bc6\:4f9d\:5b58 Output: \:30b9\:30ad\:30fc\:30de\:60c5\:5831\:306e\:307f *)
              AppendTo[cellAssocs, <|
                "CellIndex" -> idx,
                "CellStyle" -> style,
                "InputText" -> iOutputSchemaText[nb, idx],
                "PrivacyLevel" -> privLevel,
                "ConfidentialDependent" -> True|>],
              (* \:901a\:5e38\:30bb\:30eb / \:58a8\:6d88\:3057\:6e08\:307f\:30bb\:30eb *)
              AppendTo[cellAssocs, <|
                "CellIndex" -> idx,
                "CellStyle" -> style,
                "InputText" -> redactedText,
                "PrivacyLevel" -> privLevel,
                "Redacted" -> wasRedacted|>]
            ]
          ]
        ],
        {idx, indices}];
        cellAssocs
      ],
      {}];
    
    (* \:9078\:629e\:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9 *)
    If[TrueQ[OptionValue["IncludeSelection"]],
      selectedIdx = Quiet @ Check[
        NBAccess`NBSelectedCellIndices[nb], {}]];
    
    packet = <|
      "Input" -> None, (* caller \:304c\:8a2d\:5b9a *)
      "Cells" -> cells,
      "SelectedCells" -> selectedIdx,
      "AccessSpec" -> accessSpec,
      "NotebookValid" -> True,
      "TotalCellCount" -> totalCellCount,
      "CellCount" -> Length[cells],
      "Timestamp" -> AbsoluteTime[]
    |>;
    packet
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 11: Score \[RightArrow] Advisory Routing
   
   \:6570\:5024\:30b9\:30b3\:30a2\:306f access control \:306e\:4e3b\:4f53\:3067\:306f\:306a\:304f\:3001
   routing / audit / visibility \:306e advisory \:4f53\:7cfb\:3068\:3057\:3066\:4f4d\:7f6e\:3065\:3051\:308b\:3002
   \:5c06\:6765\:7684\:306b\:534a\:9806\:5e8f\:30e9\:30d9\:30eb\:304c access control \:306e\:4e3b\:4f53\:7cfb\:3068\:306a\:308b\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

(* \[HorizontalLine]\[HorizontalLine] Routing Thresholds \[HorizontalLine]\[HorizontalLine] *)
If[!AssociationQ[$NBRoutingThresholds],
  $NBRoutingThresholds = <|
    "Cloud"   -> 0.5,  (* score < 0.5 \[RightArrow] cloud LLM \:5019\:88dc *)
    "Private" -> 0.8   (* 0.5 <= score < 0.8 \[RightArrow] private LLM \:5019\:88dc *)
                       (* 0.8 <= score \[RightArrow] local only *)
  |>];

(* \[HorizontalLine]\[HorizontalLine] NBRouteDecision \[HorizontalLine]\[HorizontalLine] *)
NBRouteDecision[score_?NumericQ] :=
  Module[{cloudTh, privateTh, route, reason},
    cloudTh   = Lookup[$NBRoutingThresholds, "Cloud", 0.5];
    privateTh = Lookup[$NBRoutingThresholds, "Private", 0.8];
    Which[
      score < cloudTh,
        route = "CloudLLM";
        reason = "RiskBelowCloudThreshold",
      score < privateTh,
        route = "PrivateLLM";
        reason = "RiskAboveCloudThreshold",
      True,
        route = "LocalOnly";
        reason = "RiskAbovePrivateThreshold"
    ];
    <|"Route" -> route,
      "EffectiveRiskScore" -> score,
      "Thresholds" -> $NBRoutingThresholds,
      "Reason" -> reason|>
  ];

NBRouteDecision[accessSpec_Association] :=
  NBRouteDecision[Lookup[accessSpec, "AccessLevel",
    Lookup[accessSpec, "EffectiveRiskScore", 0.5]]];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: NBInferExprRequirements
   
   \:5f0f\:304c\:5fc5\:8981\:3068\:3059\:308b\:30ea\:30bd\:30fc\:30b9\:3092\:9759\:7684\:306b\:63a8\:5b9a\:3059\:308b\:3002
   \:5c06\:6765\:306e label-aware validation \:306e\:57fa\:76e4\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBInferExprRequirements] = {"Depth" -> Infinity};

NBInferExprRequirements[heldExpr_, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{heads, readHeads, writeHeads, readCells = {}, writeCells = {},
          hasSideEffects, requiredLevel, cellRefs},
    If[!MatchQ[heldExpr, HoldComplete[_]],
      Return[<|"Error" -> "Expected HoldComplete"|>]];
    
    heads = iExtractAllHeads[heldExpr];
    
    readHeads  = Select[heads, MemberQ[$NBAllowedHeads, #] &];
    writeHeads = Select[heads, MemberQ[$NBApprovalHeads, #] &];
    hasSideEffects = Length[writeHeads] > 0;
    
    (* \:30bb\:30eb\:53c2\:7167\:306e\:62bd\:51fa: NBCellRead[nb, 3] \[RightArrow] {3} *)
    cellRefs = Cases[heldExpr,
      HoldPattern[_Symbol[_, idx_Integer]] :> idx, {0, Infinity}];
    readCells  = DeleteDuplicates[cellRefs];
    
    (* \:5fc5\:8981\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:63a8\:5b9a *)
    requiredLevel = Which[
      Length[writeHeads] > 0, 0.8,
      MemberQ[heads, "NBCellPrivacyLevel" | "NBGetConfidentialTag"], 0.7,
      True, Lookup[accessSpec, "AccessLevel", 0.5]];
    
    <|"ReadHeads"            -> readHeads,
      "WriteHeads"           -> writeHeads,
      "ReadCells"            -> readCells,
      "WriteCells"           -> {},  (* TODO: \:66f8\:304d\:8fbc\:307f\:5148\:7279\:5b9a *)
      "HasSideEffects"       -> hasSideEffects,
      "RequiredAccessLevel"  -> requiredLevel,
      "AllHeads"             -> heads,
      "RouteAdvice"          -> NBRouteDecision[requiredLevel]|>
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: NBReleaseResult
   
   \:5b9f\:884c\:7d50\:679c\:3092 redact + routing check \:3057\:3066\:5b89\:5168\:306b release \:3059\:308b\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

Options[NBReleaseResult] = {
  "Sink" -> "CloudLLM",
  "MaxSummaryLength" -> 500
};

NBReleaseResult[result_Association, accessSpec_Association,
    opts:OptionsPattern[]] :=
  Module[{redacted, sink, route, score},
    (* \:307e\:305a redact *)
    redacted = NBRedactExecutionResult[result, accessSpec,
      "MaxSummaryLength" -> OptionValue["MaxSummaryLength"]];
    
    (* routing \:30c1\:30a7\:30c3\:30af *)
    sink  = OptionValue["Sink"];
    route = NBRouteDecision[accessSpec];
    score = Lookup[route, "EffectiveRiskScore", 0.5];
    
    Which[
      sink === "CloudLLM" && Lookup[route, "Route", ""] =!= "CloudLLM",
        <|"Released" -> False,
          "Reason"   -> "RiskTooHighForCloud",
          "Score"    -> score,
          "Route"    -> route,
          "Redacted" -> redacted|>,
      sink === "PrivateLLM" && Lookup[route, "Route", ""] === "LocalOnly",
        <|"Released" -> False,
          "Reason"   -> "RiskTooHighForPrivate",
          "Score"    -> score,
          "Route"    -> route,
          "Redacted" -> redacted|>,
      True,
        <|"Released"      -> True,
          "RedactedResult" -> redacted["RedactedResult"],
          "Summary"       -> redacted["Summary"],
          "Route"         -> route|>
    ]
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: NBMakeRetryPacket
   
   \:5931\:6557\:60c5\:5831\:304b\:3089\:79d8\:5bc6\:3092\:9664\:53bb\:3057\:305f\:5b89\:5168\:306a retry packet \:3092\:69cb\:7bc9\:3059\:308b\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

NBMakeRetryPacket[failureAssoc_Association, accessSpec_Association] :=
  Module[{safePacket, secrets, confSyms},
    safePacket = <|
      "Type"              -> "RetryPacket",
      "ReasonClass"       -> Lookup[failureAssoc, "ReasonClass", "UnknownFailure"],
      "VisibleExplanation" -> Lookup[failureAssoc, "VisibleExplanation", ""],
      "Decision"          -> Lookup[failureAssoc, "Decision", "Deny"],
      "Timestamp"         -> AbsoluteTime[]
    |>;
    
    (* \:79d8\:5bc6\:60c5\:5831\:306e redaction *)
    secrets  = Lookup[accessSpec, "Secrets", {}];
    confSyms = Lookup[accessSpec, "ConfidentialSymbols",
      If[ListQ[$NBConfidentialSymbols], $NBConfidentialSymbols, {}]];
    
    Module[{explanation = safePacket["VisibleExplanation"]},
      Do[explanation = StringReplace[explanation, ToString[s] -> "[REDACTED]"],
        {s, confSyms}];
      Do[explanation = StringReplace[explanation, s -> "[REDACTED]"],
        {s, secrets}];
      safePacket["VisibleExplanation"] = explanation];
    
    (* SanitizedExpr \:306f\:6587\:5b57\:5217\:5316\:3057\:3066\:79d8\:5bc6\:3092\:9664\:53bb *)
    If[KeyExistsQ[failureAssoc, "SanitizedExpr"],
      Module[{exprStr = ToString[failureAssoc["SanitizedExpr"]]},
        Do[exprStr = StringReplace[exprStr, s -> "[REDACTED]"],
          {s, secrets}];
        safePacket["SanitizedExprStr"] = StringTake[exprStr, UpTo[500]]]];
    
    safePacket
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 14: Label Algebra (\:6700\:5c0f API)
   
   DLM \:98a8\:306e\:534a\:9806\:5e8f\:30e9\:30d9\:30eb\:4f53\:7cfb\:3002
   \:521d\:671f\:5b9f\:88c5\:306f reader policy \:30d9\:30fc\:30b9\:3002
   \:5c06\:6765\:7684\:306b AccessLevel \:6570\:5024\:306b\:4ee3\:308f\:308b\:4e3b\:4f53\:7cfb\:3068\:306a\:308b\:3002
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

(* \[HorizontalLine]\[HorizontalLine] Principal \:7ba1\:7406 \[HorizontalLine]\[HorizontalLine] *)

If[!AssociationQ[$iNBPrincipals], $iNBPrincipals = <||>];
If[!AssociationQ[$iNBActsFor],    $iNBActsFor = <||>];

NBRegisterPrincipal[name_String, opts___Rule] :=
  Module[{spec = Association[opts]},
    $iNBPrincipals[name] = <|
      "Name"       -> name,
      "Type"       -> Lookup[spec, "Type", "User"],
      "Registered" -> AbsoluteTime[]
    |>;
    name
  ];

NBGrantActsFor[p_String, q_String] :=
  Module[{},
    If[!KeyExistsQ[$iNBPrincipals, p],
      NBRegisterPrincipal[p]];
    If[!KeyExistsQ[$iNBPrincipals, q],
      NBRegisterPrincipal[q]];
    $iNBActsFor[{p, q}] = True;
    {p, q}
  ];

NBActsForQ[p_String, q_String] :=
  Catch[Module[{visited, queue, cur, delegates},
    (* \:81ea\:5df1\:540c\:4e00\:6027 *)
    If[p === q, Throw[True, "actsfor"]];
    (* \:76f4\:63a5\:59d4\:4efb *)
    If[TrueQ[$iNBActsFor[{p, q}]], Throw[True, "actsfor"]];
    (* \:63a8\:79fb\:7684\:9589\:5305: BFS \:3067 p \[RightArrow] ... \[RightArrow] q \:306e\:30d1\:30b9\:3092\:63a2\:7d22 *)
    visited = {p}; queue = {p};
    While[Length[queue] > 0,
      cur = First[queue];
      queue = Rest[queue];
      delegates = Select[Keys[$iNBActsFor],
        MatchQ[#, {cur, _}] && TrueQ[$iNBActsFor[#]] &];
      Do[
        Module[{target = d[[2]]},
          If[target === q, Throw[True, "actsfor"]];
          If[!MemberQ[visited, target],
            AppendTo[visited, target];
            AppendTo[queue, target]]],
        {d, delegates}]];
    False
  ], "actsfor"];

(* \[HorizontalLine]\[HorizontalLine] Label \:69cb\:9020 \[HorizontalLine]\[HorizontalLine] *)

(*
  Label \:5f62\:5f0f:
  <|"ReaderPolicies" -> <|owner1 -> {reader1, ...}, ...|>,
    "Categories"     -> {"Grades", "MethodIP", ...}|>
  
  ReaderPolicies \:304c\:7a7a = public (bottom)
  ReaderPolicies \:304c <|"*" -> {}|> = \:8ab0\:3082\:8aad\:3081\:306a\:3044 (top)
*)

NBLabelQ[label_] := AssociationQ[label] &&
  KeyExistsQ[label, "ReaderPolicies"] &&
  AssociationQ[label["ReaderPolicies"]];

NBLabelBottom[] := <|"ReaderPolicies" -> <||>, "Categories" -> {}|>;

NBLabelTop[] := <|"ReaderPolicies" -> <|"*" -> {}|>,
  "Categories" -> {"TopSecret"}|>;

NBLabelJoin[l1_?NBLabelQ, l2_?NBLabelQ] :=
  Module[{rp1, rp2, merged, owners, cats},
    rp1 = l1["ReaderPolicies"];
    rp2 = l2["ReaderPolicies"];
    owners = DeleteDuplicates[Join[Keys[rp1], Keys[rp2]]];
    (* Join = \:5404 owner \:306e reader set \:306e\:4ea4\:5dee (\:3088\:308a\:5236\:7d04\:7684) *)
    merged = Association @ Map[
      Function[{owner},
        owner -> Intersection[
          Lookup[rp1, owner, {}],
          Lookup[rp2, owner, {}]]],
      owners];
    cats = DeleteDuplicates[Join[
      Lookup[l1, "Categories", {}],
      Lookup[l2, "Categories", {}]]];
    <|"ReaderPolicies" -> merged, "Categories" -> cats|>
  ];

NBLabelJoin[l1_?NBLabelQ] := l1;

NBLabelJoin[l1_?NBLabelQ, l2_?NBLabelQ, rest__?NBLabelQ] :=
  NBLabelJoin[NBLabelJoin[l1, l2], rest];

NBLabelMeet[l1_?NBLabelQ, l2_?NBLabelQ] :=
  Module[{rp1, rp2, merged, owners, cats},
    rp1 = l1["ReaderPolicies"];
    rp2 = l2["ReaderPolicies"];
    owners = DeleteDuplicates[Join[Keys[rp1], Keys[rp2]]];
    (* Meet = \:5404 owner \:306e reader set \:306e\:548c\:96c6\:5408 (\:3088\:308a\:7de9\:3044) *)
    merged = Association @ Map[
      Function[{owner},
        owner -> DeleteDuplicates[Join[
          Lookup[rp1, owner, {}],
          Lookup[rp2, owner, {}]]]],
      owners];
    cats = Intersection[
      Lookup[l1, "Categories", {}],
      Lookup[l2, "Categories", {}]];
    <|"ReaderPolicies" -> merged, "Categories" -> cats|>
  ];

NBLabelLEQ[l1_?NBLabelQ, l2_?NBLabelQ] :=
  Module[{rp1, rp2},
    rp1 = l1["ReaderPolicies"];
    rp2 = l2["ReaderPolicies"];
    (* l1 \[PrecedesEqual] l2 iff l1 \:306e\:5168 owner \:306b\:3064\:3044\:3066\:3001
       l2 \:306b\:3082\:540c owner \:304c\:3042\:308a readers(l2) \[SubsetEqual] readers(l1)\:3002
       \:3064\:307e\:308a l2 \:304c l1 \:4ee5\:4e0a\:306b\:5236\:7d04\:7684\:306a\:3089 flow OK\:3002
       Keys[rp1] \:3067\:53cd\:5fa9\:3059\:308b: l1 \:306e\:5404 owner \:304c l2 \:306b\:3082\:5b58\:5728\:3057\:3001
       l2 \:306e readers \:304c l1 \:306e readers \:306e\:90e8\:5206\:96c6\:5408\:3067\:3042\:308b\:3053\:3068\:3092\:78ba\:8a8d\:3002 *)
    If[Length[rp1] === 0, Return[True]]; (* bottom \[PrecedesEqual] anything *)
    AllTrue[Keys[rp1],
      Function[{owner},
        KeyExistsQ[rp2, owner] &&
        SubsetQ[
          Lookup[rp1, owner, {}],
          Lookup[rp2, owner, {}]]]]
  ];

(* \[HorizontalLine]\[HorizontalLine] Flow / Declassify \:5224\:5b9a \[HorizontalLine]\[HorizontalLine] *)

NBCanFlowToQ[srcLabel_?NBLabelQ, dstLabel_?NBLabelQ] :=
  NBLabelLEQ[srcLabel, dstLabel];

NBCanDeclassifyQ[srcLabel_?NBLabelQ, dstLabel_?NBLabelQ,
    req_Association] :=
  Module[{principal, hasAuthority},
    principal = Lookup[req, "Principal", None];
    If[!StringQ[principal], Return[False]];
    (* principal \:304c src \:306e\:5168 owner \:306b\:5bfe\:3057\:3066 acts-for \:3092\:6301\:3064\:304b *)
    hasAuthority = AllTrue[Keys[srcLabel["ReaderPolicies"]],
      NBActsForQ[principal, #] &];
    hasAuthority
  ];

(* \[HorizontalLine]\[HorizontalLine] EffectiveLabel \[HorizontalLine]\[HorizontalLine] *)

NBEffectiveLabel[obj_Association, req_Association] :=
  Module[{objLabel, containerLabel, sinkLabel},
    objLabel = Lookup[obj, "PolicyLabel", NBLabelBottom[]];
    containerLabel = Lookup[obj, "ContainerLabel", NBLabelBottom[]];
    sinkLabel = Lookup[req, "SinkLabel", NBLabelBottom[]];
    If[!NBLabelQ[objLabel], objLabel = NBLabelBottom[]];
    If[!NBLabelQ[containerLabel], containerLabel = NBLabelBottom[]];
    NBLabelJoin[objLabel, containerLabel]
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 15: NBAuthorize \:5206\:96e2
   
   NBAuthorize \:3092 PolicyGate / ScoreGate / EnvironmentGate \:306b
   \:5185\:90e8\:5206\:96e2\:3057\:3001\:69cb\:9020\:5316\:3055\:308c\:305f AccessDecision \:3092\:8fd4\:3059\:3002
   
   \:8a2d\:8a08\:539f\:5247:
   - PolicyGate (label-based): authoritative \[LongDash] flow \:5224\:5b9a\:306e\:4e3b\:4f53\:7cfb
   - ScoreGate (score-based): advisory \[LongDash] routing \:5224\:5b9a\:306e\:526f\:4f53\:7cfb
   - EnvironmentGate: \:74b0\:5883\:5236\:7d04\:30c1\:30a7\:30c3\:30af
   
   \:8fd4\:308a\:5024 AccessDecision:
   <|"Decision" -> "Permit"|"Deny"|"Screen"|"RequireApproval",
     "ReasonClass" -> String,
     "RequiredAction" -> "None"|"RepairProposal"|"HumanApproval"|"Declassify",
     "VisibleExplanation" -> String,
     "RouteAdvice" -> <|...|>,
     "GateResults" -> <|"Policy"->..., "Score"->..., "Environment"->...|>|>
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

(* \[HorizontalLine]\[HorizontalLine] PolicyGate: \:534a\:9806\:5e8f\:30e9\:30d9\:30eb\:306b\:57fa\:3065\:304f flow \:5224\:5b9a \[HorizontalLine]\[HorizontalLine] *)

NBPolicyGate[obj_Association, req_Association] :=
  Module[{effLabel, sinkLabel, canFlow, principal, canDecl},
    effLabel  = NBEffectiveLabel[obj, req];
    sinkLabel = Lookup[req, "SinkLabel", NBLabelBottom[]];
    
    (* \:30e9\:30d9\:30eb\:304c\:8a2d\:5b9a\:3055\:308c\:3066\:3044\:306a\:3044\:5834\:5408\:306f\:901a\:904e\:ff08\:5f8c\:65b9\:4e92\:63db\:ff09 *)
    If[!NBLabelQ[effLabel] || !NBLabelQ[sinkLabel],
      Return[<|"Gate" -> "Policy", "Decision" -> "Pass",
        "Reason" -> "NoLabelsConfigured"|>]];
    
    canFlow = NBCanFlowToQ[effLabel, sinkLabel];
    If[canFlow,
      Return[<|"Gate" -> "Policy", "Decision" -> "Pass",
        "Reason" -> "FlowPermitted"|>]];
    
    (* flow \:4e0d\:53ef \[RightArrow] declassify \:53ef\:80fd\:304b\:78ba\:8a8d *)
    principal = Lookup[req, "Principal", None];
    If[StringQ[principal],
      canDecl = NBCanDeclassifyQ[effLabel, sinkLabel, req];
      If[canDecl,
        Return[<|"Gate" -> "Policy", "Decision" -> "RequireApproval",
          "Reason" -> "DeclassifyRequired",
          "RequiredAction" -> "Declassify"|>]]];
    
    <|"Gate" -> "Policy", "Decision" -> "Deny",
      "Reason" -> "PolicyFlowViolation",
      "RequiredAction" -> "None"|>
  ];

(* \[HorizontalLine]\[HorizontalLine] ScoreGate: \:6570\:5024\:30b9\:30b3\:30a2\:306b\:57fa\:3065\:304f advisory routing \[HorizontalLine]\[HorizontalLine] *)

NBScoreGate[obj_Association, req_Association] :=
  Module[{score, sink, route, cloudTh, privateTh},
    score     = Lookup[obj, "EffectiveRiskScore",
      Lookup[obj, "AccessLevel",
        Lookup[req, "AccessLevel", 0.5]]];
    sink      = Lookup[req, "Sink", "CloudLLM"];
    route     = NBRouteDecision[score];
    cloudTh   = Lookup[$NBRoutingThresholds, "Cloud", 0.5];
    privateTh = Lookup[$NBRoutingThresholds, "Private", 0.8];
    
    Which[
      (* sink \:304c CloudLLM \:3060\:304c\:30b9\:30b3\:30a2\:304c\:9ad8\:3059\:304e\:308b *)
      sink === "CloudLLM" && score >= cloudTh,
        <|"Gate" -> "Score", "Decision" -> "Screen",
          "Reason" -> "RiskAboveCloudThreshold",
          "Score" -> score, "Route" -> route|>,
      (* sink \:304c PrivateLLM \:3060\:304c\:30b9\:30b3\:30a2\:304c\:9ad8\:3059\:304e\:308b *)
      sink === "PrivateLLM" && score >= privateTh,
        <|"Gate" -> "Score", "Decision" -> "Screen",
          "Reason" -> "RiskAbovePrivateThreshold",
          "Score" -> score, "Route" -> route|>,
      (* \:901a\:904e *)
      True,
        <|"Gate" -> "Score", "Decision" -> "Pass",
          "Reason" -> "ScoreWithinThreshold",
          "Score" -> score, "Route" -> route|>
    ]
  ];

(* \[HorizontalLine]\[HorizontalLine] EnvironmentGate: \:5b9f\:884c\:74b0\:5883\:5236\:7d04\:30c1\:30a7\:30c3\:30af \[HorizontalLine]\[HorizontalLine] *)

NBEnvironmentGate[obj_Association, req_Association] :=
  Module[{env, sink, principal, allowedSinks, deniedEnvs},
    env       = Lookup[req, "Environment", "Notebook"];
    sink      = Lookup[req, "Sink", "CloudLLM"];
    principal = Lookup[req, "Principal", None];
    
    (* \:74b0\:5883\:5236\:7d04: \:5c06\:6765\:62e1\:5f35\:30dd\:30a4\:30f3\:30c8 *)
    allowedSinks = Lookup[obj, "AllowedSinks", {"CloudLLM", "PrivateLLM", "LocalOnly", "Notebook"}];
    deniedEnvs   = Lookup[obj, "DeniedEnvironments", {}];
    
    Which[
      ListQ[allowedSinks] && !MemberQ[allowedSinks, sink],
        <|"Gate" -> "Environment", "Decision" -> "Deny",
          "Reason" -> "SinkNotAllowed",
          "RequiredAction" -> "None"|>,
      ListQ[deniedEnvs] && MemberQ[deniedEnvs, env],
        <|"Gate" -> "Environment", "Decision" -> "Deny",
          "Reason" -> "EnvironmentDenied",
          "RequiredAction" -> "None"|>,
      True,
        <|"Gate" -> "Environment", "Decision" -> "Pass",
          "Reason" -> "EnvironmentPermitted"|>
    ]
  ];

(* \[HorizontalLine]\[HorizontalLine] NBAuthorize: \:7d71\:5408\:5224\:5b9a \[HorizontalLine]\[HorizontalLine] *)

NBAuthorize[obj_Association, req_Association] :=
  Module[{policyResult, scoreResult, envResult, decision, reasonClass,
          requiredAction, explanation},
    
    (* \:5404\:30b2\:30fc\:30c8\:3092\:9806\:756a\:306b\:5b9f\:884c *)
    policyResult = NBPolicyGate[obj, req];
    scoreResult  = NBScoreGate[obj, req];
    envResult    = NBEnvironmentGate[obj, req];
    
    (* \:5224\:5b9a\:7d71\:5408: \:6700\:3082\:5236\:7d04\:306e\:53b3\:3057\:3044\:7d50\:679c\:3092\:63a1\:7528
       \:512a\:5148\:9806\:4f4d: Deny > RequireApproval > Screen > Pass *)
    Which[
      (* \:3044\:305a\:308c\:304b\:304c Deny \[RightArrow] \:5168\:4f53 Deny *)
      policyResult["Decision"] === "Deny",
        decision       = "Deny";
        reasonClass    = policyResult["Reason"];
        requiredAction = "None";
        explanation    = "Policy gate denied: " <> reasonClass,
      envResult["Decision"] === "Deny",
        decision       = "Deny";
        reasonClass    = envResult["Reason"];
        requiredAction = "None";
        explanation    = "Environment gate denied: " <> reasonClass,
      
      (* RequireApproval *)
      policyResult["Decision"] === "RequireApproval",
        decision       = "RequireApproval";
        reasonClass    = policyResult["Reason"];
        requiredAction = Lookup[policyResult, "RequiredAction", "HumanApproval"];
        explanation    = "Policy gate requires approval: " <> reasonClass,
      
      (* Score \:304c Screen \[RightArrow] advisory warning \:3060\:304c\:901a\:904e *)
      scoreResult["Decision"] === "Screen",
        decision       = "Screen";
        reasonClass    = scoreResult["Reason"];
        requiredAction = "None";
        explanation    = "Score gate screening: " <> reasonClass <>
          " (score=" <> ToString[Lookup[scoreResult, "Score", "?"]] <> ")",
      
      (* \:5168 Pass *)
      True,
        decision       = "Permit";
        reasonClass    = "None";
        requiredAction = "None";
        explanation    = ""
    ];
    
    <|"Decision"            -> decision,
      "ReasonClass"         -> reasonClass,
      "RequiredAction"      -> requiredAction,
      "VisibleExplanation"  -> explanation,
      "RouteAdvice"         -> Lookup[scoreResult, "Route",
        NBRouteDecision[Lookup[obj, "AccessLevel", 0.5]]],
      "GateResults"         -> <|
        "Policy"      -> policyResult,
        "Score"       -> scoreResult,
        "Environment" -> envResult|>
    |>
  ];

(* \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550
   Phase 20: Function Security \[LongDash] \:5b9f\:88c5
   
   \:95a2\:6570\:3054\:3068\:306b\:5b9a\:7fa9\:30e9\:30d9\:30eb\:30fb\:5b9f\:884c\:30dd\:30ea\:30b7\:30fc\:30fb\:30ea\:30ea\:30fc\:30b9\:30dd\:30ea\:30b7\:30fc\:3092
   \:767b\:9332\:3057\:3001GuardedApply \:3067\:5b89\:5168\:306a\:5b9f\:884c\:3001Declassify \:3067
   \:7d50\:679c\:306e\:30e9\:30d9\:30eb\:5f15\:304d\:4e0b\:3052\:3092\:884c\:3046\:3002
   
   \:8a2d\:8a08\:539f\:5247:
   - \:5b9a\:7fa9\:30e9\:30d9\:30eb (DefinitionLabel): \:30b3\:30fc\:30c9\:81ea\:4f53\:306e\:95b2\:89a7\:53ef\:5426
   - \:5b9f\:884c\:30dd\:30ea\:30b7\:30fc (ExecPolicy): Open / Guarded / Denied
   - \:30ea\:30ea\:30fc\:30b9\:30dd\:30ea\:30b7\:30fc (ReleasePolicy): \:7d50\:679c\:306e\:30e9\:30d9\:30eb\:5f15\:304d\:4e0b\:3052\:6761\:4ef6
   - GuardedApply \:306f flow \:30c1\:30a7\:30c3\:30af\:5f8c\:306b\:5b9f\:884c\:3057\:7d50\:679c\:306b\:30e9\:30d9\:30eb\:3092\:4ed8\:4e0e
   - Declassify \:306f acts-for + ReleasePolicy \:306e\:4e21\:65b9\:3092\:8981\:6c42
   \:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550\:2550 *)

If[!AssociationQ[$iFunctionSecurityDB], $iFunctionSecurityDB = <||>];

NBRegisterFunctionSecurity[sym_Symbol, spec_Association] :=
  Module[{entry},
    entry = <|
      "Symbol"          -> sym,
      "SymbolName"      -> SymbolName[sym],
      "DefinitionLabel" -> Lookup[spec, "DefinitionLabel", NBLabelBottom[]],
      "ExecPolicy"      -> Lookup[spec, "ExecPolicy", "Open"],
      "ReleasePolicy"   -> Lookup[spec, "ReleasePolicy", <||>],
      "Timestamp"       -> AbsoluteTime[]
    |>;
    $iFunctionSecurityDB[sym] = entry;
    entry
  ];

NBFunctionDefinitionLabel[f_Symbol] :=
  Module[{entry = Lookup[$iFunctionSecurityDB, f, None]},
    If[AssociationQ[entry],
      Lookup[entry, "DefinitionLabel", NBLabelBottom[]],
      NBLabelBottom[]]
  ];

NBFunctionExecPolicy[f_Symbol] :=
  Module[{entry = Lookup[$iFunctionSecurityDB, f, None]},
    If[AssociationQ[entry],
      Lookup[entry, "ExecPolicy", "Open"],
      "Open"]
  ];

NBFunctionReleasePolicy[f_Symbol] :=
  Module[{entry = Lookup[$iFunctionSecurityDB, f, None]},
    If[AssociationQ[entry],
      Lookup[entry, "ReleasePolicy", <||>],
      <||>]
  ];

(* \[HorizontalLine]\[HorizontalLine] GuardedApply: \:30dd\:30ea\:30b7\:30fc\:30c1\:30a7\:30c3\:30af\:4ed8\:304d\:95a2\:6570\:5b9f\:884c \[HorizontalLine]\[HorizontalLine]
   1. ExecPolicy \:304c "Denied" \[RightArrow] \:5373\:62d2\:5426
   2. ExecPolicy \:304c "Open" \[RightArrow] \:901a\:5e38\:5b9f\:884c\:3001\:7d50\:679c\:306b\:30e9\:30d9\:30eb\:4ed8\:4e0e
   3. ExecPolicy \:304c "Guarded" \[RightArrow] flow \:30c1\:30a7\:30c3\:30af \[RightArrow] \:5b9f\:884c \[RightArrow] \:30e9\:30d9\:30eb\:4ed8\:4e0e
   
   \:8fd4\:308a\:5024: <|"Success"->Bool, "Result"->...,
             "ResultLabel"->label, "Error"->None|String|> *)
GuardedApply[req_Association, f_Symbol, args___] :=
  Module[{policy, defLabel, reqLabel, rawResult, resultLabel,
          releasePolicy},
    policy   = NBFunctionExecPolicy[f];
    defLabel = NBFunctionDefinitionLabel[f];
    
    (* Denied \[RightArrow] \:5373\:62d2\:5426 *)
    If[policy === "Denied",
      Return[<|"Success" -> False,
        "Error" -> "ExecPolicy=Denied for " <> SymbolName[f],
        "ResultLabel" -> NBLabelTop[]|>]];
    
    (* Guarded \[RightArrow] flow \:30c1\:30a7\:30c3\:30af *)
    If[policy === "Guarded",
      reqLabel = Lookup[req, "SinkLabel", NBLabelBottom[]];
      If[NBLabelQ[defLabel] && NBLabelQ[reqLabel] &&
         !NBCanFlowToQ[defLabel, reqLabel],
        (* flow \:4e0d\:53ef \[RightArrow] declassify \:53ef\:80fd\:304b *)
        If[!NBCanDeclassifyQ[defLabel, reqLabel, req],
          Return[<|"Success" -> False,
            "Error" -> "PolicyFlowViolation: cannot flow " <>
              SymbolName[f] <> " result to sink",
            "ResultLabel" -> defLabel|>]]]];
    
    (* \:5b9f\:884c *)
    rawResult = Quiet @ Check[f[args], $Failed];
    
    (* \:7d50\:679c\:30e9\:30d9\:30eb: \:95a2\:6570\:306e\:5b9a\:7fa9\:30e9\:30d9\:30eb\:4ee5\:4e0a *)
    resultLabel = defLabel;
    releasePolicy = NBFunctionReleasePolicy[f];
    
    <|"Success" -> (rawResult =!= $Failed),
      "Result"       -> rawResult,
      "ResultLabel"  -> resultLabel,
      "ReleasePolicy" -> releasePolicy,
      "Error"        -> If[rawResult === $Failed,
        "Execution failed", None]|>
  ];

(* \[HorizontalLine]\[HorizontalLine] Declassify: \:30e9\:30d9\:30eb\:5f15\:304d\:4e0b\:3052 \[HorizontalLine]\[HorizontalLine]
   \:6761\:4ef6:
   1. req \:306e Principal \:304c src \:306e\:5168 owner \:306b acts-for \:3092\:6301\:3064
   2. releaseSpec \:304c ReleasePolicy \:306e\:6761\:4ef6\:3092\:6e80\:305f\:3059
   
   \:8fd4\:308a\:5024: <|"Success"->Bool, "DeclassifiedLabel"->label,
             "Error"->None|String|> *)
Declassify[obj_Association, req_Association, releaseSpec_Association] :=
  Module[{srcLabel, dstLabel, principal, releasePolicy,
          requiredFields, missingFields},
    srcLabel = Lookup[obj, "ResultLabel",
      Lookup[obj, "PolicyLabel", NBLabelBottom[]]];
    dstLabel = Lookup[releaseSpec, "TargetLabel", NBLabelBottom[]];
    principal = Lookup[req, "Principal", None];
    
    (* Principal \:306e\:6a29\:9650\:30c1\:30a7\:30c3\:30af *)
    If[!StringQ[principal],
      Return[<|"Success" -> False,
        "Error" -> "No principal in request",
        "DeclassifiedLabel" -> srcLabel|>]];
    
    If[!NBCanDeclassifyQ[srcLabel, dstLabel, req],
      Return[<|"Success" -> False,
        "Error" -> "ActsForInsufficient: " <> principal <>
          " cannot declassify",
        "DeclassifiedLabel" -> srcLabel|>]];
    
    (* ReleasePolicy \:6761\:4ef6\:30c1\:30a7\:30c3\:30af *)
    releasePolicy = Lookup[obj, "ReleasePolicy", <||>];
    requiredFields = Lookup[releasePolicy, "RequiredFields", {}];
    missingFields = Select[requiredFields,
      !KeyExistsQ[releaseSpec, #] &];
    If[Length[missingFields] > 0,
      Return[<|"Success" -> False,
        "Error" -> "ReleasePolicyMissing: " <>
          StringRiffle[missingFields, ", "],
        "DeclassifiedLabel" -> srcLabel|>]];
    
    <|"Success"           -> True,
      "DeclassifiedLabel" -> dstLabel,
      "Error"             -> None|>
  ];


(* ============================================================
   Notebook semantic access API \:5b9f\:88c5
   Stage 9 P1 Step 6 \:7528\:3001\:8aad\:307f\:53d6\:308a\:7cfb\:306e\:307f (\:66f8\:304d\:8fbc\:307f\:7cfb\:306f\:5225\:9014\:8ffd\:52a0)
   ============================================================ *)

(* ---- \:30c7\:30d5\:30a9\:30eb\:30c8 AccessSpec / \:30d0\:30ea\:30c7\:30fc\:30b7\:30e7\:30f3 ---- *)

iNBDefaultAccessSpec[] := <|
  "AccessLevel" -> 0.5,
  "Environment" -> "Notebook",
  "AllowedSinks" -> {"LocalOnly", "Notebook"}
|>;

iNBNormalizeAccessSpec[accessSpec_] := Which[
  AssociationQ[accessSpec],
    Join[iNBDefaultAccessSpec[], accessSpec],
  True,
    iNBDefaultAccessSpec[]
];

(* ---- File I/O ---- *)

(* notebook \:30d5\:30a1\:30a4\:30eb\:3092 Notebook[\:30bb\:30eb\:30ea\:30b9\:30c8, options...] \:5f0f\:3068\:3057\:3066\:8aad\:307f\:8fbc\:3080 (\:7f60 #21 \:6e96\:62e0)
   \:623b\:308a\:5024:
     \:6210\:529f \[Rule] <|\"Status\" -> \"OK\", \"NotebookExpr\" -> Notebook[...]|>
     \:5931\:6557 \[Rule] <|\"Status\" -> \"Failed\", \"Reason\" -> _String|>
*)
iNBFileLoadAsExpr[path_String] :=
  Module[{abs, raw, nbExpr},
    abs = ExpandFileName[path];
    If[!FileExistsQ[abs],
      Return[<|"Status" -> "Failed", "Reason" -> "FileNotFound", "Path" -> abs|>]];
    raw = Quiet @ Import[abs, "Notebook"];
    Which[
      MatchQ[raw, _Notebook],
        <|"Status" -> "OK", "NotebookExpr" -> raw, "Path" -> abs|>,
      MatchQ[raw, HoldComplete[_Notebook]],
        nbExpr = ReleaseHold[raw];
        <|"Status" -> "OK", "NotebookExpr" -> nbExpr, "Path" -> abs|>,
      MatchQ[raw, $Failed],
        <|"Status" -> "Failed", "Reason" -> "ImportFailed", "Path" -> abs|>,
      True,
        <|"Status" -> "Failed", "Reason" -> "UnexpectedImportShape",
          "Path" -> abs, "ImportHeadName" -> SymbolName[Head[raw]]|>
    ]
  ];

(* Notebook[...] \:304b\:3089\:5168\:30bb\:30eb\:30ea\:30b9\:30c8\:3092\:53d6\:5f97\:3002\:7f60 #23 \:6e96\:62e0\:3067 SymbolName[Head[]] \:6bd4\:8f03\:3002 *)
iNBNotebookCells[nbExpr_] :=
  If[Length[nbExpr] >= 1 && ListQ[nbExpr[[1]]],
    nbExpr[[1]],
    {}
  ];

(* \:5168\:30bb\:30eb\:30ea\:30b9\:30c8\:3092\:8d70\:67fb\:3002CellGroupData \:30cd\:30b9\:30c8\:3082\:5c55\:958b\:3057\:3066 Cell \:3060\:3051\:3092\:8a2a\:308c\:308b\:3002
   fn \:306f Function[{cell, cellPath, accInOut}, ...] \:3067\:3001
     cellPath: \:30c8\:30c3\:30d7\:304b\:3089\:306e\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30ea\:30b9\:30c8 ({2, 1, 3} \:7b49)
     acc \:3092\:66f4\:65b0\:3057\:305f Association \:3092\:8fd4\:3059\:3002
   \:7d50\:679c\:306f acc\:3002\:7f60 #26: Import[\"Notebook\"] \:306f Cell[CellGroupData[{...}, Open]] \:3067\:30cd\:30b9\:30c8\:3055\:308c\:308b\:3002 *)
iNBWalkCells[cells_List, fn_, initAcc_] :=
  Module[{flatList, acc = initAcc},
    flatList = iNBFlattenCells[cells, {}];
    Do[
      acc = fn[entry[[1]], entry[[2]], acc],
      {entry, flatList}];
    acc
  ];

(* cells (List of Cell or Cell[CellGroupData[...]]) \:3092 flatten \:3057\:3066
   {{cell, path}, {cell, path}, ...} \:3092\:8fd4\:3059\:3002\:518d\:5e30\:5c55\:958b\:3002 *)
iNBFlattenCells[cells_List, basePath_List] :=
  Module[{result = {}, n = Length[cells], cell, hName, innerCells, sub},
    Do[
      cell = cells[[i]];
      hName = SymbolName[Head[cell]];
      Which[
        (* Cell[CellGroupData[{...}, Open|Closed|...]] \:306e\:30cd\:30b9\:30c8 *)
        hName === "Cell" && Length[cell] >= 1 &&
          SymbolName[Head[cell[[1]]]] === "CellGroupData" &&
          Length[cell[[1]]] >= 1 && ListQ[cell[[1, 1]]],
          innerCells = cell[[1, 1]];
          sub = iNBFlattenCells[innerCells, Append[basePath, i]];
          result = Join[result, sub],
        (* \:901a\:5e38\:306e Cell *)
        hName === "Cell",
          AppendTo[result, {cell, Append[basePath, i]}],
        True, Null
      ],
      {i, n}];
    result
  ];

(* Cell expr \:304b\:3089 ExpressionUUID \:3092\:62bd\:51fa (\:7121\:3051\:308c\:3070 Missing) *)
iNBCellExpressionUUID[cell_] :=
  Module[{opts, uuid},
    If[!(SymbolName[Head[cell]] === "Cell" && Length[cell] >= 2),
      Return[Missing["NotACell"]]];
    opts = Drop[List @@ cell, 2];
    uuid = Lookup[Association @@ Cases[opts, _Rule | _RuleDelayed],
      ExpressionUUID, Missing["NotPresent"]];
    If[StringQ[uuid], uuid, Missing["NotPresent"]]
  ];

(* Cell expr \:306e Style \:3092\:62bd\:51fa (String \:307e\:305f\:306f List \:306e\:5148\:982d) *)
iNBCellStyle[cell_] :=
  Module[{style},
    If[!(SymbolName[Head[cell]] === "Cell" && Length[cell] >= 2),
      Return[Missing["NotACell"]]];
    style = cell[[2]];
    Which[
      StringQ[style], style,
      ListQ[style] && Length[style] > 0 && StringQ[First[style]], First[style],
      True, Missing["UnknownStyleShape"]
    ]
  ];

(* Cell expr \:306e TaggingRules \:3092\:62bd\:51fa (Association \:307e\:305f\:306f Missing) *)
iNBCellTaggingRules[cell_] :=
  Module[{opts, tr},
    If[!(SymbolName[Head[cell]] === "Cell" && Length[cell] >= 2),
      Return[Missing["NotACell"]]];
    opts = Drop[List @@ cell, 2];
    tr = Lookup[Association @@ Cases[opts, _Rule | _RuleDelayed],
      TaggingRules, Missing["NotPresent"]];
    Which[
      AssociationQ[tr], tr,
      ListQ[tr], Association @@ Cases[tr, _Rule | _RuleDelayed],
      True, Missing["NotPresent"]
    ]
  ];


(* ---- \:4e2d\:30ec\:30d9\:30eb API: NBFindCellByPredicate ---- *)

Options[NBFindCellByPredicate] = {
  "AccessSpec" -> Automatic,
  "MaxResults" -> All
};

NBFindCellByPredicate[path_String, predicate_, opts:OptionsPattern[]] :=
  Module[{accessSpec, maxResults, loaded, cells, matches, maxN, flatIdx},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];
    maxResults = OptionValue["MaxResults"];
    maxN = If[IntegerQ[maxResults] && maxResults >= 0, maxResults, Infinity];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK",
      Return[loaded]];

    cells = iNBNotebookCells[Lookup[loaded, "NotebookExpr"]];
    flatIdx = 0;
    matches = iNBWalkCells[cells,
      Function[{cell, cellPath, acc},
        flatIdx = flatIdx + 1;
        If[Length[acc] < maxN && TrueQ[predicate[cell]],
          Append[acc, <|
            "CellIndex" -> flatIdx,
            "CellPath" -> cellPath,
            "Cell" -> HoldComplete[cell],
            "Style" -> iNBCellStyle[cell],
            "ExpressionUUID" -> iNBCellExpressionUUID[cell]|>],
          acc]],
      {}];

    <|"Status" -> "OK", "Matches" -> matches,
      "Path" -> Lookup[loaded, "Path"],
      "AccessSpec" -> accessSpec|>
  ];


(* ---- \:9ad8\:30ec\:30d9\:30eb API: NBReadHeader ---- *)

Options[NBReadHeader] = {
  "AccessSpec" -> Automatic
};

(* Notebook \:5168\:4f53\:306e TaggingRules \:304b\:3089 SourceVault \:30d8\:30c3\:30c0\:30fc\:3092\:62bd\:51fa
   \:307e\:305f\:306f Header style cell \:304b\:3089 fallback \:3067\:62bd\:51fa\:3002 *)
iNBExtractHeaderFromNotebookTaggingRules[nbExpr_] :=
  Module[{opts, tr, svHeader},
    opts = Drop[List @@ nbExpr, 1];
    tr = Lookup[Association @@ Cases[opts, _Rule | _RuleDelayed],
      TaggingRules, Missing["NotPresent"]];
    Which[
      AssociationQ[tr],
        svHeader = Lookup[tr, "SourceVault", Missing["NotPresent"]];
        Which[
          AssociationQ[svHeader], svHeader,
          iNBIsHeaderLikeAssoc[tr], tr,
          True, Missing["NotPresent"]],
      ListQ[tr],
        Module[{trAssoc, sv},
          trAssoc = Association @@ Cases[tr, _Rule | _RuleDelayed];
          sv = Lookup[trAssoc, "SourceVault", Missing["NotPresent"]];
          Which[
            AssociationQ[sv], sv,
            iNBIsHeaderLikeAssoc[trAssoc], trAssoc,
            True, Missing["NotPresent"]]],
      True, Missing["NotPresent"]
    ]
  ];

(* Header \:3089\:3057\:3055\:306e\:5224\:5b9a: Header \:3068\:3057\:3066\:6709\:610f\:7fa9\:306a\:30ad\:30fc\:3092\:5c11\:306a\:304f\:3068\:30821\:3064\:542b\:3080 Association
   \:30c8\:30c3\:30d7\:30ec\:30d9\:30eb\:306b TodoStatus \:5358\:72ec\:306e Association \:306f Todo cell \:306e metadata \:306a\:306e\:3067\:6392\:9664 *)
iNBIsHeaderLikeAssoc[assoc_Association] :=
  AnyTrue[{"Keywords", "Status", "Deadline", "NextReview",
    "Owner", "PathHint", "Title", "CloudPublishable"},
    KeyExistsQ[assoc, #] &] &&
  Length[assoc] > 0;
iNBIsHeaderLikeAssoc[_] := False;

(* InitializationCell \:30b9\:30bf\:30a4\:30eb / Input \:30b9\:30bf\:30a4\:30eb\:306e Cell \:304b\:3089 BoxData \:5185\:306e
   Association \:3092 MakeExpression \:7d4c\:7531\:3067\:62bd\:51fa\:3059\:308b (\:7f60 #22 \:6e96\:62e0)\:3002
   whitelist \:306a\:3057 (\:751f Association \:3092\:8fd4\:3059\:3001NBAccess \:306f\:4e2d\:7acb\:7684\:30d5\:30a1\:30a4\:30eb I/O \:5c64) *)
iNBExtractHeaderFromBoxData[nbExpr_] :=
  Module[{cells, flat, found = Missing["NotPresent"]},
    cells = iNBNotebookCells[nbExpr];
    flat = iNBFlattenCells[cells, {}];
    (* \:5404 Cell \:3092\:8d70\:67fb\:3001Initialization Input \:307e\:305f\:306f Input \:30b9\:30bf\:30a4\:30eb\:306e\:30bb\:30eb\:304b\:3089\:8a66\:3057\:3066\:3001
       \:5408\:81f4\:3059\:308b\:3082\:306e\:3092\:898b\:3064\:3051\:305f\:6642\:70b9\:3067\:7d42\:4e86 *)
    Scan[Function[entry,
      If[MissingQ[found],
        Module[{cell, style, content, isInitInput, isInput, held, value},
          cell = entry[[1]];
          style = iNBCellStyle[cell];
          If[!(StringQ[style] && MemberQ[{"Input"}, style]),
            Return[Null, Module]];
          content = cell[[1]];
          (* \:5024\:304c BoxData \:307e\:305f\:306f\:751f\:6587\:5b57\:5217 \:3092\:60f3\:5b9a *)
          If[!(MatchQ[content, _BoxData] || StringQ[content]),
            Return[Null, Module]];
          held = Quiet[MakeExpression[content, StandardForm]];
          If[!MatchQ[held, HoldComplete[_Association]],
            Return[Null, Module]];
          value = ReleaseHold[held];
          If[AssociationQ[value], found = value]]]], flat];
    found
  ];

NBReadHeader[path_String, opts:OptionsPattern[]] :=
  Module[{accessSpec, loaded, nbExpr, headerFromNB, headerFromCells,
          headerFromBoxData, header, source},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];

    (* 1. Notebook \:5168\:4f53\:306e TaggingRules \:7d4c\:7531\:3092\:512a\:5148 *)
    headerFromNB = iNBExtractHeaderFromNotebookTaggingRules[nbExpr];
    (* Header \:3089\:3057\:3055\:30c1\:30a7\:30c3\:30af *)
    If[!MissingQ[headerFromNB] && !iNBIsHeaderLikeAssoc[headerFromNB],
      headerFromNB = Missing["NotHeaderLike"]];

    (* 2. fallback: cell \:5358\:4f4d\:306e TaggingRules \:304b\:3089 (Header \:3089\:3057\:3055\:30d5\:30a3\:30eb\:30bf\:30fc\:9069\:7528) *)
    headerFromCells = If[!MissingQ[headerFromNB], <||>,
      Module[{cells, found},
        cells = iNBNotebookCells[nbExpr];
        found = iNBWalkCells[cells,
          Function[{cell, cellPath, acc},
            If[acc === None,
              Module[{tr, sv},
                tr = iNBCellTaggingRules[cell];
                If[AssociationQ[tr],
                  sv = Lookup[tr, "SourceVault", Missing["NotPresent"]];
                  (* Header \:3089\:3057\:3044 SourceVault Association \:306e\:307f\:63a1\:7528 *)
                  If[AssociationQ[sv] && iNBIsHeaderLikeAssoc[sv], sv, acc],
                  acc]],
              acc]],
          None];
        If[AssociationQ[found], found, <||>]
      ]];

    (* 3. fallback (Stage 9 P1 \:5225\:4ef6 2): Input cell \:306e BoxData \:5185\:306e Association \:3092 MakeExpression \:7d4c\:7531\:3067 *)
    headerFromBoxData = If[!MissingQ[headerFromNB] ||
        (AssociationQ[headerFromCells] && Length[headerFromCells] > 0),
      Missing["NotAttempted"],
      iNBExtractHeaderFromBoxData[nbExpr]];

    Which[
      AssociationQ[headerFromNB],
        header = headerFromNB; source = "TaggingRules",
      AssociationQ[headerFromCells] && Length[headerFromCells] > 0,
        header = headerFromCells; source = "HeaderCell",
      AssociationQ[headerFromBoxData],
        header = headerFromBoxData; source = "BoxData",
      True,
        header = <||>; source = "None"
    ];

    <|"Status" -> "OK",
      "Keywords" -> Lookup[header, "Keywords", {}],
      "Status" -> Lookup[header, "Status", Missing["NotPresent"]],
      "Deadline" -> Lookup[header, "Deadline", Missing["NotPresent"]],
      "NextReview" -> Lookup[header, "NextReview", Missing["NotPresent"]],
      "Owner" -> Lookup[header, "Owner", Missing["NotPresent"]],
      "PathHint" -> Lookup[header, "PathHint", Missing["NotPresent"]],
      "RawHeader" -> header,
      "Source" -> source,
      "Path" -> Lookup[loaded, "Path"],
      "AccessSpec" -> accessSpec|>
  ];


(* ---- \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:81ea\:5df1\:5ba3\:8a00: CloudPublishable ----
   NBReadHeader \:7d4c\:7531\:3067 TaggingRules > SourceVault > "CloudPublishable" \:3092\:8aad\:3080\:3002
   \:6ce8: NBReadHeader \:306e\:623b\:308a\:5024\:306e \"Status\" \:30ad\:30fc\:306f Association \:6700\:7d42\:69cb\:7bc9\:6642\:306b
       Header \:5185\:306e \"Status\" (Todo / Done / ...) \:3067\:4e0a\:66f8\:304d\:3055\:308c\:308b\:305f\:3081\:3001
       \:5b9f\:884c\:6210\:5426\:5224\:5b9a\:306b\:306f \"RawHeader\" \:30ad\:30fc\:306e\:5b58\:5728\:6709\:7121\:3092\:898b\:308b (Path \:30ad\:30fc\:3082\:53ef)\:3002
   \:623b\:308a\:5024:
     True                          - \:30af\:30e9\:30a6\:30c9\:516c\:958b\:8a31\:53ef\:3068\:5ba3\:8a00\:6e08\:307f
     False                         - \:660e\:793a\:7684\:306b\:30af\:30e9\:30a6\:30c9\:7981\:6b62\:3068\:5ba3\:8a00\:6e08\:307f
     Missing["NotDeclared"]        - Header \:306f\:3042\:308b\:304c CloudPublishable \:5ba3\:8a00\:7121\:3057
     Missing["NoHeader"]           - NBReadHeader \:81ea\:4f53\:304c\:5931\:6557 (RawHeader \:306a\:3057)
     Missing["NoRawHeader"]        - RawHeader \:30d5\:30a3\:30fc\:30eb\:30c9\:306a\:3057 *)
iNBCloudPublishableValue[raw_Association] :=
  Module[{direct, sv},
    direct = Lookup[raw, "CloudPublishable", Missing["NotDeclared"]];
    If[MemberQ[{True, False}, direct], Return[direct]];
    sv = Lookup[raw, "SourceVault", Missing["NotPresent"]];
    If[AssociationQ[sv],
      direct = Lookup[sv, "CloudPublishable", Missing["NotDeclared"]];
      If[MemberQ[{True, False}, direct], Return[direct]]];
    Missing["NotDeclared"]
  ];
iNBCloudPublishableValue[_] := Missing["NotDeclared"];

iNBFileDeclaredPublishable[path_String] :=
  Module[{header, raw},
    header = Quiet @ NBAccess`NBReadHeader[path,
      "AccessSpec" -> <|"AccessLevel" -> 1.0|>];
    (* NBReadHeader \:304c\:30d5\:30a1\:30a4\:30eb\:5931\:6557\:7b49\:3067 "RawHeader" \:7121\:3057\:306e\:8fd4\:308a\:5024\:3092\:51fa\:3057\:305f\:5834\:5408 *)
    If[!AssociationQ[header] || !KeyExistsQ[header, "RawHeader"],
      Return[Missing["NoHeader"]]];
    raw = Lookup[header, "RawHeader", <||>];
    If[!AssociationQ[raw], Return[Missing["NoRawHeader"]]];
    iNBCloudPublishableValue[raw]
  ];


(* ---- \:9ad8\:30ec\:30d9\:30eb API: NBReadTodos ---- *)

Options[NBReadTodos] = {
  "AccessSpec" -> Automatic
};

(* \:30bb\:30eb\:304c Todo \:5bfe\:8c61\:304b\:5224\:5b9a (Item / TodoItem* style \:307e\:305f\:306f TaggingRules=TodoStatus) *)
iNBIsTodoCell[cell_] :=
  Module[{style, tr},
    style = iNBCellStyle[cell];
    If[StringQ[style] &&
       (style === "Item" || StringStartsQ[style, "TodoItem"]),
      Return[True]];
    tr = iNBCellTaggingRules[cell];
    If[AssociationQ[tr],
      Module[{sv},
        sv = Lookup[tr, "SourceVault", Missing["NotPresent"]];
        If[AssociationQ[sv] && KeyExistsQ[sv, "TodoStatus"], Return[True]]]];
    False
  ];

(* Cell expr \:304b\:3089 Todo Status \:3092\:5224\:5b9a\:3002
   \:512a\:5148\:5ea6: (1) TaggingRules SourceVault TodoStatus, (2) StrikeThrough\:30fbFontColor, (3) Open *)
iNBTodoStatusFromCell[cell_] :=
  Module[{tr, sv, status, opts, fontVar, fontColor, hasStrike,
          isGray, isGreen},
    tr = iNBCellTaggingRules[cell];
    If[AssociationQ[tr],
      sv = Lookup[tr, "SourceVault", Missing["NotPresent"]];
      If[AssociationQ[sv],
        status = Lookup[sv, "TodoStatus", Missing["NotPresent"]];
        If[MemberQ[{"Open", "Done", "Pass"}, status],
          Return[<|"Status" -> status, "Source" -> "TaggingRules"|>]]]];

    (* StrikeThrough \:30fb FontColor \:6307\:5b9a\:304b\:3089\:5224\:5b9a *)
    opts = Drop[List @@ cell, 2];
    fontVar = Lookup[Association @@ Cases[opts, _Rule | _RuleDelayed],
      FontVariations, Missing["NotPresent"]];
    fontColor = Lookup[Association @@ Cases[opts, _Rule | _RuleDelayed],
      FontColor, Missing["NotPresent"]];

    hasStrike = Which[
      MissingQ[fontVar], False,
      AssociationQ[fontVar],
        TrueQ[Lookup[fontVar, "StrikeThrough", False]],
      ListQ[fontVar],
        MemberQ[fontVar, Rule["StrikeThrough", True]] ||
        MemberQ[fontVar, RuleDelayed["StrikeThrough", True]],
      True, False
    ];

    isGray = !MissingQ[fontColor] &&
      (MatchQ[fontColor, GrayLevel[_?(0.3 <= # <= 0.7 &)]] ||
       MatchQ[fontColor, RGBColor[r_, g_, b_] /;
         NumericQ[r] && NumericQ[g] && NumericQ[b] &&
         Abs[r - g] < 0.1 && Abs[g - b] < 0.1 && 0.3 <= r <= 0.7]);
    isGreen = !MissingQ[fontColor] &&
      MatchQ[fontColor, RGBColor[r_, g_, b_] /;
        NumericQ[r] && NumericQ[g] && NumericQ[b] &&
        g > r && g > b && g > 0.4];

    Which[
      !TrueQ[hasStrike],
        <|"Status" -> "Open", "Source" -> "StyleHeuristic"|>,
      TrueQ[hasStrike] && isGreen,
        <|"Status" -> "Done", "Source" -> "StyleHeuristic"|>,
      TrueQ[hasStrike] && isGray,
        <|"Status" -> "Pass", "Source" -> "StyleHeuristic"|>,
      TrueQ[hasStrike],
        <|"Status" -> "Done", "Source" -> "StyleHeuristicDefault"|>,
      True,
        <|"Status" -> "Open", "Source" -> "StyleHeuristicFallback"|>
    ]
  ];

(* Cell expr \:304b\:3089\:30c6\:30ad\:30b9\:30c8\:3092\:62bd\:51fa\:3002\:6700\:5c0f\:5b9f\:88c5: String / TextData[..] / RowBox \:7b49\:3092 ToString *)
iNBCellTextExtract[cell_] :=
  Module[{content, raw},
    If[!(SymbolName[Head[cell]] === "Cell" && Length[cell] >= 1),
      Return[""]];
    content = cell[[1]];
    Which[
      StringQ[content], content,
      MatchQ[content, _BoxData] || MatchQ[content, _TextData],
        raw = StringReplace[ToString[content, InputForm],
          {"BoxData[" -> "", "TextData[" -> "", "RowBox[" -> "",
           "\"" -> "", "]" -> "", "{" -> "", "}" -> "",
           "," -> "", "  " -> " "}];
        StringTrim[raw],
      True,
        StringTrim @ StringReplace[ToString[content, InputForm],
          {"\"" -> ""}]
    ]
  ];

NBReadTodos[path_String, opts:OptionsPattern[]] :=
  Module[{accessSpec, loaded, nbExpr, cells, todos, todoCount},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];
    cells = iNBNotebookCells[nbExpr];

    todoCount = 0;
    todos = iNBWalkCells[cells,
      Function[{cell, cellPath, acc},
        If[iNBIsTodoCell[cell],
          todoCount = todoCount + 1;
          Module[{statusInfo, txt},
            statusInfo = iNBTodoStatusFromCell[cell];
            txt = iNBCellTextExtract[cell];
            Append[acc, <|
              "Index" -> todoCount,
              "Text" -> txt,
              "Status" -> Lookup[statusInfo, "Status", "Open"],
              "StatusSource" -> Lookup[statusInfo, "Source", "Unknown"],
              "CellPath" -> cellPath,
              "ExpressionUUID" -> iNBCellExpressionUUID[cell],
              "Style" -> iNBCellStyle[cell]|>]],
          acc]],
      {}];

    <|"Status" -> "OK",
      "Todos" -> todos,
      "Count" -> todoCount,
      "Path" -> Lookup[loaded, "Path"],
      "AccessSpec" -> accessSpec|>
  ];


(* ============================================================
   Notebook semantic access API \:5b9f\:88c5 (\:66f8\:304d\:8fbc\:307f\:7cfb)
   Stage 9 P1 Step 6 \:7528\:3001\:30d5\:30a1\:30a4\:30eb\:76f4\:63a5\:7de8\:96c6\:7d4c\:8def
   ============================================================ *)

(* AccessLevel \:30c1\:30a7\:30c3\:30af (\:66f8\:304d\:8fbc\:307f\:306b\:306f >= 0.7 \:5fc5\:8981) *)
iNBCheckWriteAccess[accessSpec_Association] :=
  Module[{level},
    level = Lookup[accessSpec, "AccessLevel", 0.0];
    If[!NumericQ[level], level = 0.0];
    If[level >= 0.7,
      <|"Status" -> "OK", "Level" -> level|>,
      <|"Status" -> "Failed",
        "Reason" -> "AccessLevelTooLow",
        "Required" -> 0.7,
        "Provided" -> level|>]
  ];

(* Notebook expr \:3092 atomic \:306b\:30d5\:30a1\:30a4\:30eb\:306b\:66f8\:304d\:8fbc\:3080
   tmp \:30d5\:30a1\:30a4\:30eb\:7d4c\:7531 + Rename\:3002Export[..., "NB"] \:3092\:4f7f\:7528\:3002
   Stage 9 P1 Step 2 Hotfix 3: Rename \:5931\:6557\:6642 \:306b\:306f\:76f4\:63a5 Export \:3078 fallback\:3002
   Stage 9 P1 Step 2 Hotfix 4: Export \:5f8c\:306b frontend \:7d4c\:7531\:306e\:30ea\:30bb\:30fc\:30d6\:3067 outline cache \:3092\:6b63\:898f\:5316\:3002
   Export \:306f Notebook expr \:3092 S \:5f0f\:30c6\:30ad\:30b9\:30c8\:306b\:5909\:63db\:3059\:308b\:304c\:3001\:30d8\:30c3\:30c0\:306e
   NotebookDataLength / NotebookOutlinePosition / CellTagsIndexPosition \:7b49\:306e\:30d0\:30a4\:30c8\:4f4d\:7f6e\:30ad\:30e3\:30c3\:30b7\:30e5\:3092\:6b63\:3057\:304f\:66f8\:304d\:76f4\:3055\:306a\:3044\:305f\:3081\:3001
   frontend \:304c\:300c\:30b7\:30b9\:30c6\:30e0\:5916\:3067\:7de8\:96c6\:3055\:308c\:305f\:300d\:3068\:8b66\:544a\:3092\:51fa\:3059\:3002
   frontend \:7d4c\:7531\:3067\:30ea\:30bb\:30fc\:30d6\:3059\:308b\:3068\:30ad\:30e3\:30c3\:30b7\:30e5\:304c\:6b63\:898f\:5316\:3055\:308c\:308b\:3002 *)
iNBFileSaveExpr[path_String, nbExpr_] :=
  Module[{abs, tmpPath, result, renameOk, directOk, writeMode},
    abs = ExpandFileName[path];
    tmpPath = abs <> ".tmp-" <> ToString[$ProcessID] <> "-" <>
      ToString[Hash[SessionTime[]]];
    result = Quiet @ Check[
      Export[tmpPath, nbExpr, "NB"],
      $Failed];
    If[result === $Failed || !FileExistsQ[tmpPath],
      Quiet[DeleteFile[tmpPath]];
      Return[<|"Status" -> "Failed", "Reason" -> "ExportFailed",
        "Path" -> abs|>]];

    (* (1) Atomic rename \:3092\:8a66\:884c (Windows \:3067 abs \:304c\:5b58\:5728\:3059\:308c\:3070\:5148\:306b\:524a\:9664) *)
    renameOk = TrueQ @ Quiet @ Check[
      If[FileExistsQ[abs], DeleteFile[abs]];
      RenameFile[tmpPath, abs];
      True,
      False];
    writeMode = If[renameOk, "Rename", "DirectExport"];

    If[!renameOk,
      (* (2) Rename \:304c\:5931\:6557 \[Rule] \:76f4\:63a5 Export \:3078 fallback *)
      Quiet[DeleteFile[tmpPath]];
      directOk = TrueQ @ Quiet @ Check[
        Export[abs, nbExpr, "NB"];
        True,
        False];
      If[!directOk,
        Return[<|"Status" -> "Failed", "Reason" -> "RenameFailed",
          "Path" -> abs, "TmpPath" -> tmpPath|>]]];

    (* (3) Hotfix 4: frontend \:7d4c\:7531\:3067 outline cache \:3092\:6b63\:898f\:5316 *)
    iNBNormalizeNotebookCache[abs];

    <|"Status" -> "OK", "Path" -> abs, "WriteMode" -> writeMode|>
  ];


(* Frontend \:7d4c\:7531\:3067 .nb \:306e outline cache \:3092\:6b63\:898f\:5316\:3059\:308b\:3002
   \:65e2\:306b\:958b\:304b\:308c\:3066\:3044\:308b NotebookObject \:304c\:3042\:308c\:3070\:305d\:308c\:3092\:4f7f\:7528\:3057\:3001
   \:7121\:3051\:308c\:3070 Visible -> False \:3067\:30b5\:30a4\:30ec\:30f3\:30c8\:306b\:958b\:304d\:301c\:9589\:3058\:308b\:3002
   \:5931\:6557\:3057\:3066\:3082\:8b66\:544a\:7b49\:306f\:7121\:3057 (best-effort)\:3002 *)
iNBNormalizeNotebookCache[abs_String] :=
  Module[{absExp, allNbs, openedNb, openedHere = False, nb},
    absExp = ExpandFileName[abs];
    allNbs = Quiet @ Notebooks[];
    If[!ListQ[allNbs], Return[Null]];
    openedNb = SelectFirst[allNbs,
      With[{p = Quiet @ NotebookFileName[#]},
        StringQ[p] && ExpandFileName[p] === absExp] &,
      None];
    nb = If[openedNb =!= None,
      openedNb,
      openedHere = True;
      Quiet @ NotebookOpen[absExp, Visible -> False]];
    If[Head[nb] === NotebookObject,
      (* Hotfix 4.1: \:30c0\:30fc\:30c6\:30a3\:5316\:3057\:3066 NotebookSave \:3092\:78ba\:5b9f\:306b\:5b9f\:884c\:3055\:305b\:308b *)
      Quiet @ Check[
        SetOptions[nb, NotebookEventActions -> {}];
        SetOptions[nb, NotebookEventActions -> Inherited],
        Null];
      Quiet @ NotebookSave[nb];
      If[openedHere, Quiet @ NotebookClose[nb]]];
    Null
  ];

(* Cell expr (List \[Function]) \:306e options \:90e8\:5206\:3092 newOpts \:3067\:30de\:30fc\:30b8\:3002
   newOpts: List of Rule, \:65e2\:5b58\:540c key \:306f\:4e0a\:66f8\:304d *)
iNBMergeCellOptions[cell_, newOpts_List] :=
  Module[{content, style, existingOpts, optsAssoc, newAssoc, mergedAssoc,
          mergedOpts},
    If[!(SymbolName[Head[cell]] === "Cell" && Length[cell] >= 2),
      Return[cell]];
    content = cell[[1]];
    style = cell[[2]];
    existingOpts = Drop[List @@ cell, 2];
    optsAssoc = Association @@ Cases[existingOpts, _Rule | _RuleDelayed];
    newAssoc = Association @@ Cases[newOpts, _Rule | _RuleDelayed];
    mergedAssoc = Join[optsAssoc, newAssoc];
    mergedOpts = Normal[mergedAssoc];
    (* \:7d50\:679c\:3092 Cell[content, style, opts...] \:3068\:3057\:3066\:518d\:69cb\:7bc9 *)
    Apply[Cell, Join[{content, style}, mergedOpts]]
  ];

(* Cell expr \:306e TaggingRules \:5185\:90e8\:306e key \:30d1\:30b9\:306b value \:3092\:30de\:30fc\:30b8\:3002
   taggingKeyPath: List \:3001\:4f8b {\"SourceVault\", \"TodoStatus\"} \[RightArrow] \:5185\:5074\:306b\:306c\:308b *)
iNBMergeCellTaggingRule[cell_, taggingKeyPath_List, value_] :=
  Module[{tr, trAssoc, updated, opts},
    tr = iNBCellTaggingRules[cell];
    trAssoc = If[AssociationQ[tr], tr, <||>];
    (* Nested association \:306b value \:3092 set *)
    updated = iNBSetNestedAssoc[trAssoc, taggingKeyPath, value];
    iNBMergeCellOptions[cell, {TaggingRules -> updated}]
  ];

(* Association \:306b key \:30d1\:30b9\:7d4c\:7531\:3067 value \:3092 set (\:5165\:308c\:5b50\:81ea\:52d5\:751f\:6210) *)
iNBSetNestedAssoc[assoc_Association, {}, value_] := value;
iNBSetNestedAssoc[assoc_Association, {k_, rest___}, value_] :=
  Module[{inner, currentInner},
    currentInner = Lookup[assoc, k, <||>];
    inner = If[AssociationQ[currentInner], currentInner, <||>];
    Append[assoc, k -> iNBSetNestedAssoc[inner, {rest}, value]]
  ];

(* CellPath ({2, 1, 3}) \:3067 nbExpr \:5185\:306e Cell \:306b\:30a2\:30af\:30bb\:30b9\:3002
   CellPath \:306f cells[[i]] -> cells[[i,1,1,j]] -> ... \:306e\:69cb\:9020\:3002
   \:5024\:306f Cell \:3092\:65b0\:3057\:3044 newCell \:3067\:7f6e\:63db\:3057\:305f nbExpr \:3092\:8fd4\:3059\:3002 *)
iNBReplaceCellByPath[nbExpr_, cellPath_List, newCell_] :=
  Module[{cells, newCells},
    cells = iNBNotebookCells[nbExpr];
    newCells = iNBReplaceCellInList[cells, cellPath, newCell];
    ReplacePart[nbExpr, 1 -> newCells]
  ];

(* cells (List) \:5185\:306e path \:4f4d\:7f6e\:306e Cell \:3092 newCell \:3067\:7f6e\:63db\:3002
   path \:306f {i, j, k, ...} \:3067\:3001CellGroupData \:30cd\:30b9\:30c8\:3092\:6271\:3046\:3002 *)
iNBReplaceCellInList[cells_List, {i_Integer}, newCell_] :=
  ReplacePart[cells, i -> newCell];

iNBReplaceCellInList[cells_List, {i_Integer, rest__}, newCell_] :=
  Module[{cell, inner, newInner, newCellGroup, hName},
    cell = cells[[i]];
    hName = SymbolName[Head[cell]];
    If[hName === "Cell" && Length[cell] >= 1 &&
        SymbolName[Head[cell[[1]]]] === "CellGroupData",
      inner = cell[[1, 1]];
      newInner = iNBReplaceCellInList[inner, {rest}, newCell];
      newCellGroup = ReplacePart[cell[[1]], 1 -> newInner];
      ReplacePart[cells, i -> ReplacePart[cell, 1 -> newCellGroup]],
      (* path \:304c\:5408\:308f\:306a\:3044\:5834\:5408\:306f\:5143\:306e\:307e\:307e *)
      cells]
  ];


(* ---- \:4e2d\:30ec\:30d9\:30eb API: NBSetCellOptionsByPredicate ---- *)

Options[NBSetCellOptionsByPredicate] = {
  "AccessSpec" -> Automatic,
  "DryRun" -> True,
  "MaxResults" -> All
};

NBSetCellOptionsByPredicate[path_String, predicate_, optionRules_List,
    opts:OptionsPattern[]] :=
  Module[{accessSpec, dryRun, maxResults, accessCheck,
          loaded, nbExpr, cells, flat, matches, maxN,
          newNbExpr, modified, saveResult},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];
    dryRun = TrueQ[OptionValue["DryRun"]];
    maxResults = OptionValue["MaxResults"];
    maxN = If[IntegerQ[maxResults] && maxResults >= 0, maxResults, Infinity];

    accessCheck = iNBCheckWriteAccess[accessSpec];
    If[Lookup[accessCheck, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed",
        "Reason" -> Lookup[accessCheck, "Reason", "AccessDenied"]|>,
        accessCheck]]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];
    cells = iNBNotebookCells[nbExpr];

    flat = iNBFlattenCells[cells, {}];
    matches = Select[flat,
      TrueQ[predicate[#[[1]]]] &];
    matches = Take[matches, UpTo[maxN]];

    If[Length[matches] === 0,
      Return[<|"Status" -> "OK",
        "Modified" -> {},
        "DryRun" -> dryRun,
        "AccessLevel" -> Lookup[accessSpec, "AccessLevel"],
        "Path" -> Lookup[loaded, "Path"],
        "Note" -> "NoMatch"|>]];

    (* \:5404\:30de\:30c3\:30c1\:306b\:5bfe\:3057 nbExpr \:5185\:3092\:9806\:6b21\:7f6e\:63db *)
    newNbExpr = nbExpr;
    modified = {};
    Do[
      Module[{cell, cellPath, newCell},
        cell = entry[[1]];
        cellPath = entry[[2]];
        newCell = iNBMergeCellOptions[cell, optionRules];
        newNbExpr = iNBReplaceCellByPath[newNbExpr, cellPath, newCell];
        AppendTo[modified, <|
          "CellPath" -> cellPath,
          "Before" -> With[{c = cell}, HoldComplete[c]],
          "After" -> With[{nc = newCell}, HoldComplete[nc]]|>]],
      {entry, matches}];

    If[dryRun,
      Return[<|"Status" -> "DryRunOK",
        "Modified" -> modified,
        "DryRun" -> True,
        "AccessLevel" -> Lookup[accessSpec, "AccessLevel"],
        "Path" -> Lookup[loaded, "Path"]|>]];

    (* \:5b9f\:884c\:30e2\:30fc\:30c9: \:30d5\:30a1\:30a4\:30eb\:306b\:66f8\:304d\:8fbc\:3080 *)
    saveResult = iNBFileSaveExpr[Lookup[loaded, "Path"], newNbExpr];
    If[Lookup[saveResult, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed"|>, saveResult]]];

    <|"Status" -> "OK",
      "Modified" -> modified,
      "DryRun" -> False,
      "AccessLevel" -> Lookup[accessSpec, "AccessLevel"],
      "Path" -> Lookup[loaded, "Path"]|>
  ];


(* ---- \:4e2d\:30ec\:30d9\:30eb API: NBSetCellTaggingRuleByPredicate ---- *)

Options[NBSetCellTaggingRuleByPredicate] = {
  "AccessSpec" -> Automatic,
  "DryRun" -> True,
  "MaxResults" -> All
};

NBSetCellTaggingRuleByPredicate[path_String, predicate_,
    taggingKeyPath_List, value_, opts:OptionsPattern[]] :=
  Module[{accessSpec, dryRun, maxResults, accessCheck,
          loaded, nbExpr, cells, flat, matches, maxN,
          newNbExpr, modified, saveResult},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];
    dryRun = TrueQ[OptionValue["DryRun"]];
    maxResults = OptionValue["MaxResults"];
    maxN = If[IntegerQ[maxResults] && maxResults >= 0, maxResults, Infinity];

    accessCheck = iNBCheckWriteAccess[accessSpec];
    If[Lookup[accessCheck, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed",
        "Reason" -> Lookup[accessCheck, "Reason", "AccessDenied"]|>,
        accessCheck]]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];
    cells = iNBNotebookCells[nbExpr];

    flat = iNBFlattenCells[cells, {}];
    matches = Select[flat,
      TrueQ[predicate[#[[1]]]] &];
    matches = Take[matches, UpTo[maxN]];

    If[Length[matches] === 0,
      Return[<|"Status" -> "OK", "Modified" -> {},
        "DryRun" -> dryRun, "Path" -> Lookup[loaded, "Path"],
        "Note" -> "NoMatch"|>]];

    newNbExpr = nbExpr;
    modified = {};
    Do[
      Module[{cell, cellPath, newCell},
        cell = entry[[1]];
        cellPath = entry[[2]];
        newCell = iNBMergeCellTaggingRule[cell, taggingKeyPath, value];
        newNbExpr = iNBReplaceCellByPath[newNbExpr, cellPath, newCell];
        AppendTo[modified, <|
          "CellPath" -> cellPath,
          "Before" -> With[{c = cell}, HoldComplete[c]],
          "After" -> With[{nc = newCell}, HoldComplete[nc]]|>]],
      {entry, matches}];

    If[dryRun,
      Return[<|"Status" -> "DryRunOK", "Modified" -> modified,
        "DryRun" -> True, "Path" -> Lookup[loaded, "Path"]|>]];

    saveResult = iNBFileSaveExpr[Lookup[loaded, "Path"], newNbExpr];
    If[Lookup[saveResult, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed"|>, saveResult]]];

    <|"Status" -> "OK", "Modified" -> modified,
      "DryRun" -> False, "Path" -> Lookup[loaded, "Path"]|>
  ];


(* ---- \:9ad8\:30ec\:30d9\:30eb API: NBWriteHeader ---- *)

Options[NBWriteHeader] = {
  "AccessSpec" -> Automatic,
  "DryRun" -> True
};

NBWriteHeader[path_String, key_String, value_, opts:OptionsPattern[]] :=
  Module[{accessSpec, dryRun, accessCheck,
          loaded, nbExpr, nbOpts, optsAssoc, trCurrent, svCurrent,
          svUpdated, trUpdated, newNbExpr, before, after, saveResult},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];
    dryRun = TrueQ[OptionValue["DryRun"]];

    accessCheck = iNBCheckWriteAccess[accessSpec];
    If[Lookup[accessCheck, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed",
        "Reason" -> Lookup[accessCheck, "Reason", "AccessDenied"]|>,
        accessCheck]]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];

    nbOpts = Drop[List @@ nbExpr, 1];
    optsAssoc = Association @@ Cases[nbOpts, _Rule | _RuleDelayed];
    trCurrent = Lookup[optsAssoc, TaggingRules, <||>];
    If[ListQ[trCurrent],
      trCurrent = Association @@ Cases[trCurrent, _Rule | _RuleDelayed]];
    If[!AssociationQ[trCurrent], trCurrent = <||>];

    svCurrent = Lookup[trCurrent, "SourceVault", <||>];
    If[!AssociationQ[svCurrent], svCurrent = <||>];

    before = Lookup[svCurrent, key, Missing["NotPresent"]];
    svUpdated = Append[svCurrent, key -> value];
    trUpdated = Append[trCurrent, "SourceVault" -> svUpdated];

    newNbExpr = Apply[Notebook,
      Join[
        {Lookup[loaded, "NotebookExpr"][[1]]},
        Normal[Append[optsAssoc, TaggingRules -> trUpdated]]]];
    after = value;

    If[dryRun,
      Return[<|"Status" -> "DryRunOK",
        "Key" -> key, "Before" -> before, "After" -> after,
        "DryRun" -> True, "Path" -> Lookup[loaded, "Path"]|>]];

    saveResult = iNBFileSaveExpr[Lookup[loaded, "Path"], newNbExpr];
    If[Lookup[saveResult, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed"|>, saveResult]]];

    <|"Status" -> "OK",
      "Key" -> key, "Before" -> before, "After" -> after,
      "DryRun" -> False, "Path" -> Lookup[loaded, "Path"]|>
  ];


(* ---- \:9ad8\:30ec\:30d9\:30eb API: NBGetCloudPublishable / NBSetCloudPublishable ----
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5358\:4f4d\:306e\:300c\:30af\:30e9\:30a6\:30c9 LLM \:516c\:958b\:8a31\:53ef\:300d\:5ba3\:8a00\:3092\:8aad\:307f\:66f8\:304d\:3059\:308b\:3002
   \:683c\:7d0d\:5148: Notebook \:5168\:4f53\:306e TaggingRules > SourceVault > "CloudPublishable"\:3002
   \:8aad\:307f\:53d6\:308a\:306f iNBFileDeclaredPublishable \:7d4c\:7531 (\:30bb\:30eb\:6a5f\:5bc6\:5224\:5b9a\:3068\:306f\:72ec\:7acb)\:3002 *)

NBGetCloudPublishable[path_String] :=
  iNBFileDeclaredPublishable[path];

Options[NBSetCloudPublishable] = {
  "AccessSpec" -> Automatic,    (* Automatic \:306f\:6e96\:5099\:6cd5\:5185\:3067 AccessLevel 0.7 \:306b\:5c55\:958b *)
  "DryRun" -> False     (* \:30c8\:30b0\:30eb\:64cd\:4f5c\:306a\:306e\:3067 default \:306f\:5b9f\:884c *)
};

(* \:66f8\:304d\:8fbc\:307f\:306b\:306f AccessLevel >= 0.7 \:5fc5\:9808\:3002Automatic \:306e\:6642\:306f 0.7 \:3092\:88dc\:5145\:3059\:308b\:3002
   (\:5168\:74b0\:5883\:30c7\:30d5\:30a9\:30eb\:30c8 NBAccess`$NBPrivacySpec = AccessLevel 0.5 \:3060\:3068\:62d2\:5426\:3055\:308c\:308b\:305f\:3081) *)
NBSetCloudPublishable[path_String, val:(True|False),
    opts:OptionsPattern[]] :=
  Module[{accessSpec, result},
    accessSpec = OptionValue["AccessSpec"];
    If[accessSpec === Automatic,
      accessSpec = <|"AccessLevel" -> 0.7|>];
    result = NBWriteHeader[path, "CloudPublishable", val,
      "AccessSpec" -> accessSpec,
      "DryRun" -> TrueQ[OptionValue["DryRun"]]];
    If[AssociationQ[result] && Lookup[result, "Status", ""] === "OK",
      Quiet @ NBFileSpecCacheClear[]];
    result
  ];


(* ---- NBClearCloudPublishable: TaggingRules \:304b\:3089 CloudPublishable \:30ad\:30fc\:3092\:524a\:9664 ----
   "\:672a\:6307\:5b9a" \:72b6\:614b\:306b\:623b\:3059\:3002\:524a\:9664\:5f8c SourceVault Association \:304c\:7a7a\:306b\:306a\:308c\:3070\:3055\:3089\:306b SourceVault \:30ad\:30fc\:3082\:524a\:9664\:3001
   TaggingRules Association \:304c\:7a7a\:306b\:306a\:308c\:3070 TaggingRules option \:81ea\:4f53\:3082\:524a\:9664 (\:30af\:30ea\:30fc\:30f3\:30a2\:30c3\:30d7)\:3002 *)

Options[NBClearCloudPublishable] = {
  "AccessSpec" -> Automatic,
  "DryRun" -> False
};

NBClearCloudPublishable[path_String, opts:OptionsPattern[]] :=
  Module[{accessSpec, dryRun, accessCheck,
          loaded, nbExpr, nbOpts, optsAssoc, trCurrent, svCurrent,
          svUpdated, trUpdated, newOptsAssoc, newNbExpr, before, saveResult},
    accessSpec = OptionValue["AccessSpec"];
    If[accessSpec === Automatic,
      accessSpec = <|"AccessLevel" -> 0.7|>];
    accessSpec = iNBNormalizeAccessSpec[accessSpec];
    dryRun = TrueQ[OptionValue["DryRun"]];

    accessCheck = iNBCheckWriteAccess[accessSpec];
    If[Lookup[accessCheck, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed",
        "Reason" -> Lookup[accessCheck, "Reason", "AccessDenied"]|>,
        accessCheck]]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];

    nbOpts = Drop[List @@ nbExpr, 1];
    optsAssoc = Association @@ Cases[nbOpts, _Rule | _RuleDelayed];
    trCurrent = Lookup[optsAssoc, TaggingRules, <||>];
    If[ListQ[trCurrent],
      trCurrent = Association @@ Cases[trCurrent, _Rule | _RuleDelayed]];
    If[!AssociationQ[trCurrent], trCurrent = <||>];

    svCurrent = Lookup[trCurrent, "SourceVault", <||>];
    If[!AssociationQ[svCurrent], svCurrent = <||>];

    before = Lookup[svCurrent, "CloudPublishable", Missing["NotPresent"]];

    (* \:30ad\:30fc\:304c\:5143\:3005\:7121\:3044\:5834\:5408\:306f no-op (\:30d5\:30a1\:30a4\:30eb\:66f8\:304d\:8fbc\:307f\:81ea\:4f53\:3092\:30b9\:30ad\:30c3\:30d7) *)
    If[MissingQ[before],
      Return[<|"Status" -> "OK",
        "Key" -> "CloudPublishable",
        "Before" -> Missing["NotPresent"],
        "After" -> Missing["NotPresent"],
        "DryRun" -> dryRun,
        "NoOp" -> True,
        "Path" -> Lookup[loaded, "Path"]|>]];

    svUpdated = KeyDrop[svCurrent, "CloudPublishable"];
    trUpdated = If[Length[svUpdated] === 0,
      (* SourceVault Association \:304c\:7a7a \[RightArrow] SourceVault \:30ad\:30fc\:3054\:3068\:524a\:9664 *)
      KeyDrop[trCurrent, "SourceVault"],
      Append[trCurrent, "SourceVault" -> svUpdated]];

    newOptsAssoc = If[Length[trUpdated] === 0,
      (* TaggingRules Association \:304c\:7a7a \[RightArrow] TaggingRules \:30aa\:30d7\:30b7\:30e7\:30f3\:81ea\:4f53\:3092\:524a\:9664 *)
      KeyDrop[optsAssoc, TaggingRules],
      Append[optsAssoc, TaggingRules -> trUpdated]];

    newNbExpr = Apply[Notebook,
      Join[{nbExpr[[1]]}, Normal[newOptsAssoc]]];

    If[dryRun,
      Return[<|"Status" -> "DryRunOK",
        "Key" -> "CloudPublishable",
        "Before" -> before,
        "After" -> Missing["Removed"],
        "DryRun" -> True,
        "Path" -> Lookup[loaded, "Path"]|>]];

    saveResult = iNBFileSaveExpr[Lookup[loaded, "Path"], newNbExpr];
    If[Lookup[saveResult, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed"|>, saveResult]]];

    <|"Status" -> "OK",
      "Key" -> "CloudPublishable",
      "Before" -> before,
      "After" -> Missing["Removed"],
      "DryRun" -> False,
      "Path" -> Lookup[loaded, "Path"]|>
  ];


(* \[HorizontalLine]\[HorizontalLine] .nb \:30d5\:30a1\:30a4\:30eb\:306e outline cache \:4fee\:5fa9 (Stage 9 P1 Step 2 Hotfix 4) \[HorizontalLine]\[HorizontalLine]
   iNBNormalizeNotebookCache \:3092\:516c\:958b API \:3068\:3057\:3066\:30e9\:30c3\:30d7\:3059\:308b\:3002 *)

NBRepairNotebookCache[path_String] :=
  Module[{absExp, allNbs, openedNb, openedHere = False, nb,
          origWindowSize, dummyDirtied},
    If[!FileExistsQ[path],
      Return[<|"Status" -> "Failed", "Reason" -> "FileNotFound",
        "Path" -> path|>]];
    absExp = ExpandFileName[path];
    allNbs = Quiet @ Notebooks[];
    If[!ListQ[allNbs], allNbs = {}];
    openedNb = SelectFirst[allNbs,
      With[{p = Quiet @ NotebookFileName[#]},
        StringQ[p] && ExpandFileName[p] === absExp] &,
      None];
    nb = If[openedNb =!= None,
      openedNb,
      openedHere = True;
      Quiet @ NotebookOpen[absExp, Visible -> False]];
    If[Head[nb] =!= NotebookObject,
      Return[<|"Status" -> "Failed", "Reason" -> "OpenFailed",
        "Path" -> absExp|>]];

    (* Hotfix 4.1: frontend \:306b\:300c\:5909\:66f4\:3042\:308a\:300d\:3068\:5f37\:5236\:8a8d\:8b58\:3055\:305b\:308b\:305f\:3081
       NotebookEventActions \:30c0\:30df\:30fc SetOptions \:3092\:884c\:3046\:3002
       \:5024\:306f\:5143\:306b\:623b\:3059\:306e\:3067 .nb \:30d5\:30a1\:30a4\:30eb\:5185\:5bb9\:306f\:5b9f\:8cea\:5909\:308f\:3089\:306a\:3044\:304c\:3001
       frontend \:306e\:30c0\:30fc\:30c6\:30a3\:30d5\:30e9\:30b0\:304c\:7acb\:3061\:3001NotebookSave \:3067\:78ba\:5b9f\:306b\:518d\:751f\:6210\:3055\:308c\:308b\:3002 *)
    dummyDirtied = Quiet @ Check[
      SetOptions[nb, NotebookEventActions -> {}];
      SetOptions[nb, NotebookEventActions -> Inherited];
      True,
      False];

    Quiet @ NotebookSave[nb];

    If[openedHere, Quiet @ NotebookClose[nb]];
    <|"Status" -> "OK", "Path" -> absExp,
      "WasAlreadyOpen" -> (openedNb =!= None),
      "Dirtied" -> TrueQ[dummyDirtied]|>
  ];


Options[NBRepairNotebookCacheFolder] = {"Recursive" -> True};

NBRepairNotebookCacheFolder[dir_String, opts:OptionsPattern[]] :=
  Module[{files, results, succeeded, failed},
    files = If[TrueQ[OptionValue["Recursive"]],
      FileNames["*.nb", dir, Infinity],
      FileNames["*.nb", dir]];
    files = Select[files, !StringContainsQ[FileBaseName[#], ".tmp-"] &];
    results = Map[NBRepairNotebookCache, files];
    succeeded = Count[results,
      _?(AssociationQ[#] && Lookup[#, "Status", ""] === "OK" &)];
    failed = Length[results] - succeeded;
    <|"Status" -> "OK",
      "Directory" -> ExpandFileName[dir],
      "TotalFiles" -> Length[files],
      "Succeeded" -> succeeded,
      "Failed"    -> failed,
      "Details"   -> results|>
  ];


Options[NBCleanupTmpFiles] = {"Recursive" -> True};

NBCleanupTmpFiles[dir_String, opts:OptionsPattern[]] :=
  Module[{files},
    files = If[TrueQ[OptionValue["Recursive"]],
      FileNames["*.tmp-*", dir, Infinity],
      FileNames["*.tmp-*", dir]];
    files = Select[files, StringContainsQ[FileBaseName[#], ".nb"] &];
    Quiet @ DeleteFile /@ files;
    <|"Status" -> "OK",
      "Directory" -> ExpandFileName[dir],
      "Deleted" -> Length[files],
      "Files" -> files|>
  ];


(* ---- NBRepairNotebookCacheStrict: \:5f37\:529b\:7248\:4fee\:5fa9 (Stage 9 P1 Step 2 Hotfix 4.1) ----
   NBRepairNotebookCache \:304c\:300c\:30c0\:30fc\:30c6\:30a3\:5316 \[Rule] NotebookSave\:300d\:3067\:6548\:679c\:7121\:3057\:306e\:5834\:5408\:306e fallback\:3002
   \:30d5\:30a1\:30a4\:30eb\:3092 NotebookImport \:3067\:8aad\:3093\:3067 cells \:3092\:5f97\:308b \[Rule] CreateDocument \:3067\:65b0\:30ce\:30fc\:30c8\:3092\:4f5c\:308b \[Rule]
   NotebookSave[..., path] \:3067\:5143\:30d1\:30b9\:306b\:4e0a\:66f8\:304d \[Rule] \:65b0\:30ce\:30fc\:30c8\:3092\:9589\:3058\:308b\:3002
   \:5e2f\:540c\:30aa\:30d7\:30b7\:30e7\:30f3 (TaggingRules \:7b49) \:3082\:53d6\:308a\:8fbc\:3080\:3002 *)

NBRepairNotebookCacheStrict[path_String] :=
  Module[{absExp, allNbs, openedNb, importedCells, importedOpts,
          newNb, saveResult},
    If[!FileExistsQ[path],
      Return[<|"Status" -> "Failed", "Reason" -> "FileNotFound",
        "Path" -> path|>]];
    absExp = ExpandFileName[path];

    (* \:65e2\:306b frontend \:3067\:958b\:3044\:3066\:3044\:308c\:3070\:5148\:306b\:9589\:3058\:308b (\:30ed\:30c3\:30af\:56de\:907f) *)
    allNbs = Quiet @ Notebooks[];
    If[ListQ[allNbs],
      openedNb = SelectFirst[allNbs,
        With[{p = Quiet @ NotebookFileName[#]},
          StringQ[p] && ExpandFileName[p] === absExp] &,
        None];
      If[openedNb =!= None,
        Quiet @ NotebookClose[openedNb, Interrupt -> False]]];

    (* \:30d5\:30a1\:30a4\:30eb\:3092 Import \:3057\:3066 cells \:3068 options \:3092\:53d6\:308a\:51fa\:3059 *)
    importedCells = Quiet @ Check[
      Import[absExp, "Notebook"],
      $Failed];
    If[Head[importedCells] =!= Notebook,
      Return[<|"Status" -> "Failed", "Reason" -> "ImportFailed",
        "Path" -> absExp|>]];

    (* CreateDocument \:3067\:65b0\:30ce\:30fc\:30c8\:3092\:4f5c\:6210 (\:898b\:3048\:306a\:3044\:3088\:3046\:306b) *)
    newNb = Quiet @ Check[
      CreateDocument[
        Sequence @@ Apply[List, importedCells],
        Visible -> False],
      $Failed];
    If[Head[newNb] =!= NotebookObject,
      Return[<|"Status" -> "Failed", "Reason" -> "CreateDocumentFailed",
        "Path" -> absExp|>]];

    (* \:65b0\:30ce\:30fc\:30c8\:3092 path \:306b\:4fdd\:5b58 \[Rule] frontend \:304c\:6b63\:3057\:3044\:30ad\:30e3\:30c3\:30b7\:30e5\:3092\:751f\:6210 *)
    saveResult = Quiet @ Check[
      NotebookSave[newNb, absExp];
      True,
      False];

    (* \:65b0\:30ce\:30fc\:30c8\:3092\:9589\:3058\:308b *)
    Quiet @ NotebookClose[newNb, Interrupt -> False];

    If[TrueQ[saveResult],
      <|"Status" -> "OK", "Path" -> absExp,
        "Method" -> "RecreateAndSave"|>,
      <|"Status" -> "Failed", "Reason" -> "SaveFailed",
        "Path" -> absExp|>]
  ];


(* ---- \:9ad8\:30ec\:30d9\:30eb API: NBWriteTodoStatus ---- *)

(* Status \:3068 cell options \:306e\:5bfe\:5fdc\:8868 *)
iNBStatusToCellOpts[status_String] :=
  Switch[status,
    "Open",
      {FontVariations -> {"StrikeThrough" -> False},
       FontColor -> Automatic},
    "Done",
      {FontVariations -> {"StrikeThrough" -> True},
       FontColor -> RGBColor[0.0, 0.5, 0.0]},
    "Pass",
      {FontVariations -> {"StrikeThrough" -> True},
       FontColor -> GrayLevel[0.5]},
    _, {}
  ];

Options[NBWriteTodoStatus] = {
  "AccessSpec" -> Automatic,
  "DryRun" -> True
};

NBWriteTodoStatus[path_String, todoKey_Association, newStatus_String,
    opts:OptionsPattern[]] :=
  Module[{accessSpec, dryRun, accessCheck,
          loaded, nbExpr, cells, flat, todoCount, candidates,
          matched, cell, cellPath, oldStatusInfo, newCell,
          newNbExpr, saveResult, idxKey, textKey},
    accessSpec = iNBNormalizeAccessSpec[OptionValue["AccessSpec"]];
    dryRun = TrueQ[OptionValue["DryRun"]];

    If[!MemberQ[{"Open", "Done", "Pass"}, newStatus],
      Return[<|"Status" -> "Failed",
        "Reason" -> "InvalidNewStatus",
        "NewStatus" -> newStatus,
        "ValidValues" -> {"Open", "Done", "Pass"}|>]];

    accessCheck = iNBCheckWriteAccess[accessSpec];
    If[Lookup[accessCheck, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed",
        "Reason" -> Lookup[accessCheck, "Reason", "AccessDenied"]|>,
        accessCheck]]];

    idxKey = Lookup[todoKey, "Index", Missing["NotPresent"]];
    textKey = Lookup[todoKey, "Text", Missing["NotPresent"]];

    loaded = iNBFileLoadAsExpr[path];
    If[Lookup[loaded, "Status", ""] =!= "OK", Return[loaded]];
    nbExpr = Lookup[loaded, "NotebookExpr"];
    cells = iNBNotebookCells[nbExpr];

    (* Todo cell \:3092\:5217\:6319\:3057 Index \:3092\:632f\:308b *)
    flat = iNBFlattenCells[cells, {}];
    todoCount = 0;
    candidates = {};
    Do[
      Module[{c, p},
        c = entry[[1]]; p = entry[[2]];
        If[iNBIsTodoCell[c],
          todoCount = todoCount + 1;
          AppendTo[candidates, <|
            "Index" -> todoCount,
            "Text" -> iNBCellTextExtract[c],
            "Cell" -> c,
            "CellPath" -> p,
            "ExpressionUUID" -> iNBCellExpressionUUID[c]|>]]],
      {entry, flat}];

    (* Index + Text \:4e21\:65b9\:4e00\:81f4\:3059\:308b cell \:3092\:9078\:629e (\:5b89\:5168\:5074) *)
    matched = Select[candidates,
      And[
        IntegerQ[idxKey] && #["Index"] === idxKey,
        StringQ[textKey] && #["Text"] === textKey
      ] &];

    Which[
      Length[matched] === 0,
        Return[<|"Status" -> "Failed",
          "Reason" -> "NoMatchingTodo",
          "TodoKey" -> todoKey,
          "Candidates" -> candidates,
          "Path" -> Lookup[loaded, "Path"]|>],
      Length[matched] > 1,
        Return[<|"Status" -> "Failed",
          "Reason" -> "AmbiguousTodoKey",
          "TodoKey" -> todoKey,
          "Matched" -> matched,
          "Path" -> Lookup[loaded, "Path"]|>]
    ];

    matched = First[matched];
    cell = matched["Cell"];
    cellPath = matched["CellPath"];
    oldStatusInfo = iNBTodoStatusFromCell[cell];

    (* Cell \:3092\:5909\:66f4: cell options + TaggingRules \:540c\:6642\:8a2d\:5b9a *)
    newCell = iNBMergeCellOptions[cell, iNBStatusToCellOpts[newStatus]];
    newCell = iNBMergeCellTaggingRule[newCell,
      {"SourceVault", "TodoStatus"}, newStatus];

    newNbExpr = iNBReplaceCellByPath[nbExpr, cellPath, newCell];

    If[dryRun,
      Return[<|"Status" -> "DryRunOK",
        "MatchedTodo" -> <|"Index" -> matched["Index"],
          "Text" -> matched["Text"]|>,
        "OldStatus" -> Lookup[oldStatusInfo, "Status", "Unknown"],
        "NewStatus" -> newStatus,
        "CellPath" -> cellPath,
        "ExpressionUUID" -> matched["ExpressionUUID"],
        "Before" -> With[{c = cell}, HoldComplete[c]],
        "After" -> With[{nc = newCell}, HoldComplete[nc]],
        "DryRun" -> True,
        "Path" -> Lookup[loaded, "Path"]|>]];

    saveResult = iNBFileSaveExpr[Lookup[loaded, "Path"], newNbExpr];
    If[Lookup[saveResult, "Status", ""] =!= "OK",
      Return[Join[<|"Status" -> "Failed"|>, saveResult]]];

    <|"Status" -> "OK",
      "MatchedTodo" -> <|"Index" -> matched["Index"],
        "Text" -> matched["Text"]|>,
      "OldStatus" -> Lookup[oldStatusInfo, "Status", "Unknown"],
      "NewStatus" -> newStatus,
      "CellPath" -> cellPath,
      "ExpressionUUID" -> matched["ExpressionUUID"],
      "DryRun" -> False,
      "Path" -> Lookup[loaded, "Path"]|>
  ];


(* ===================================================================
   Phase 2.1: Codex provider max access + accessible-dirs audit
   (Codex integration spec 5th review, sections 10.1 / 10.3)
   NBAccess is the single source of truth for provider max access.
   =================================================================== *)

(* ---- spec 10.1: Codex provider max access level ----
   $iProviderMaxAccessLevel is initialised earlier; here we backfill
   the Codex providers without overwriting a user-set value. *)
If[AssociationQ[$iProviderMaxAccessLevel],
  If[!KeyExistsQ[$iProviderMaxAccessLevel, "chatgptcodex"],
    $iProviderMaxAccessLevel["chatgptcodex"] = 0.5];
  If[!KeyExistsQ[$iProviderMaxAccessLevel, "codex"],
    $iProviderMaxAccessLevel["codex"] = 0.5]];

(* z.ai (GLM \:30b7\:30ea\:30fc\:30ba) \:306f OpenAI \:4e92\:63db\:306e\:8ab2\:91d1 API \:30d7\:30ed\:30d0\:30a4\:30c0\:3002
   \:5916\:90e8\:306e\:30af\:30e9\:30a6\:30c9\:306a\:306e\:3067\:4f4e\:4fe1\:983c\:6271\:3044\:3068\:3057\:3066 MaxAccessLevel = 0.25\:3002
   \:65e2\:5b58\:306e $iProviderMaxAccessLevel \:3092\:4e0a\:66f8\:304d\:305b\:305a\:306b backfill \:3059\:308b
   (\:30e6\:30fc\:30b6\:30fc\:304c NBSetProviderMaxAccessLevel \:3067\:5909\:66f4\:6e08\:307f\:306a\:3089\:5c0a\:91cd)\:3002 *)
If[AssociationQ[$iProviderMaxAccessLevel],
  If[!KeyExistsQ[$iProviderMaxAccessLevel, "zai"],
    $iProviderMaxAccessLevel["zai"] = 0.25]];

(* ---- spec 10.3: accessible-dirs audit ---- *)

(* dangerous file name heuristics -> reason string or Null *)
iCodexDangerFileName[name_String] :=
  Module[{lc},
    lc = ToLowerCase[name];
    Which[
      lc === ".env" || StringStartsQ[lc, ".env."],
        "filename matches .env",
      StringContainsQ[lc, "secret"],
        "filename contains \"secret\"",
      StringContainsQ[lc, "credential"],
        "filename contains \"credential\"",
      StringContainsQ[lc, "token"],
        "filename contains \"token\"",
      StringContainsQ[lc, "apikey"] ||
        StringContainsQ[lc, "api_key"] ||
        StringContainsQ[lc, "api-key"],
        "filename suggests an API key",
      StringMatchQ[lc, "id_rsa" ~~ ___] ||
        StringMatchQ[lc, "id_dsa" ~~ ___] ||
        StringMatchQ[lc, "id_ecdsa" ~~ ___] ||
        StringMatchQ[lc, "id_ed25519" ~~ ___],
        "filename suggests an SSH private key",
      StringMatchQ[lc, ___ ~~ (".pem" | ".key" | ".p12" | ".pfx")],
        "filename suggests a private key or certificate",
      True, Null]];

iCodexDangerFileName[_] := Null;

(* dangerous file content heuristics -> reason string or Null *)
iCodexDangerContent[path_String, maxBytes_] :=
  Module[{bytes, text, patterns, hit},
    If[!FileExistsQ[path], Return[Null]];
    If[!IntegerQ[maxBytes] || FileByteCount[path] > maxBytes,
      Return[Null]];
    bytes = Quiet @ ReadByteArray[path];
    If[!ByteArrayQ[bytes], Return[Null]];
    (* skip binary-looking files: a NUL byte is present *)
    If[MemberQ[Normal[bytes], 0], Return[Null]];
    text = Quiet @ ByteArrayToString[bytes, "UTF-8"];
    If[!StringQ[text], Return[Null]];
    patterns = {
      "sk-[A-Za-z0-9]{20,}" ->
        "possible API secret key (sk- prefix)",
      "AKIA[0-9A-Z]{16}" ->
        "possible AWS access key id",
      "ghp_[A-Za-z0-9]{30,}" ->
        "possible GitHub personal access token",
      "xox[baprs]-[A-Za-z0-9-]{10,}" ->
        "possible Slack token",
      "AIza[0-9A-Za-z_-]{30,}" ->
        "possible Google API key",
      "-----BEGIN [A-Z ]*PRIVATE KEY-----" ->
        "PEM private key block"};
    hit = SelectFirst[patterns,
      StringContainsQ[text, RegularExpression[First[#]]] &,
      Null];
    If[hit === Null, Null, Last[hit]]];

iCodexDangerContent[___] := Null;

(* collect files under dirs; report truncation for a finite MaxDepth *)
iCodexAuditCollectFiles[dirs_List, maxDepth_] :=
  Module[{files, truncated},
    files = {};
    truncated = False;
    Do[
      If[StringQ[d] && DirectoryQ[d],
        Module[{got, deeper},
          got = Quiet @ FileNames["*", d,
            If[maxDepth === Infinity, Infinity, maxDepth]];
          If[!ListQ[got], got = {}];
          got = Select[got, !DirectoryQ[#] &];
          files = Join[files, got];
          If[maxDepth =!= Infinity && IntegerQ[maxDepth],
            deeper = Quiet @ FileNames["*", d, maxDepth + 1];
            If[ListQ[deeper] &&
              Length[Select[deeper, !DirectoryQ[#] &]] >
                Length[got],
              truncated = True]]]],
      {d, dirs}];
    {DeleteDuplicates[files], truncated}];

Options[NBAuditCodexAccessibleDirs] = {
  "MaxDepth"         -> Infinity,
  "OnDanger"         -> "Fail",
  "ScanContents"     -> True,
  "MaxFileScanBytes" -> 262144
};

NBAuditCodexAccessibleDirs[dirs_List, opts:OptionsPattern[]] :=
  Module[{maxDepth, onDanger, scanContents, maxBytes,
          allFiles, truncated, findings, fileCount, gate, status,
          report},
    maxDepth     = OptionValue["MaxDepth"];
    onDanger     = OptionValue["OnDanger"];
    scanContents = TrueQ[OptionValue["ScanContents"]];
    maxBytes     = OptionValue["MaxFileScanBytes"];

    {allFiles, truncated} =
      iCodexAuditCollectFiles[dirs, maxDepth];
    fileCount = Length[allFiles];

    findings = {};
    Do[
      Module[{nameReason, contentReason},
        nameReason = iCodexDangerFileName[FileNameTake[f]];
        If[StringQ[nameReason],
          AppendTo[findings, <|
            "Path"     -> f,
            "Category" -> "filename",
            "Reason"   -> nameReason|>]];
        If[scanContents && !StringQ[nameReason],
          contentReason = iCodexDangerContent[f, maxBytes];
          If[StringQ[contentReason],
            AppendTo[findings, <|
              "Path"     -> f,
              "Category" -> "content",
              "Reason"   -> contentReason|>]]]],
      {f, allFiles}];

    gate = If[findings === {} && !truncated, "Pass", "Fail"];
    status = Which[
      findings =!= {}, "DangerFound",
      truncated,       "Incomplete",
      True,            "OK"];

    report = <|
      "Status"             -> status,
      "Gate"               -> gate,
      "Findings"           -> findings,
      "AuditedDirs"        -> dirs,
      "FileCount"          -> fileCount,
      "Truncated"          -> truncated,
      "SuggestedDenyRules" ->
        DeleteDuplicates[Lookup[#, "Path"] & /@ findings]|>;

    Which[
      gate === "Pass",
        report,
      onDanger === "DenyAndContinue",
        report,
      True,
        Failure["CodexAccessibleDirsAudit", <|
          "MessageTemplate" ->
            "Codex accessible-dirs audit failed: `n` finding(s)" <>
            (If[truncated, " and an unscanned sub-tree", ""]) <>
            "; do not start Codex with these directories exposed.",
          "MessageParameters" -> <|"n" -> Length[findings]|>,
          "Report" -> report|>]]];

NBAuditCodexAccessibleDirs[___] :=
  Failure["CodexAccessibleDirsAudit", <|
    "MessageTemplate" ->
      "NBAuditCodexAccessibleDirs expects a list of directories.",
    "MessageParameters" -> <||>|>];



(* ============================================================
   Phase A1: Policy Snapshot \:5b9f\:88c5\:672c\:4f53
   ============================================================ *)

(* ---- digest \:6b63\:898f\:5316 helper ----
   \:751f\:6210\:5074 (NBPolicySnapshot) \:3068\:691c\:8a3c\:5074 (NBAcceptPolicySnapshot) \:3067
   \:5fc5\:305a\:540c\:4e00\:306e helper \:3092\:901a\:3059\:3053\:3068\:3067\:3001Association key \:9806\:5e8f\:3084
   head list \:9806\:5e8f\:3001Wolfram version \:5dee\:306b\:4f9d\:5b58\:3057\:306a\:3044 digest \:3092\:5f97\:308b\:3002 *)

iNBNormalizeHeadList[list_List] :=
  Sort @ DeleteDuplicates[ToString /@ list];
iNBNormalizeHeadList[_] := {};

iNBNormalizeConfidentialSymbols[conf_Association] :=
  SortBy[
    Map[
      Function[kv, {ToString[First[kv]], ToString[Last[kv], InputForm]}],
      Normal[conf]
    ],
    First
  ];
iNBNormalizeConfidentialSymbols[conf_List] :=
  Sort @ DeleteDuplicates[ToString /@ conf];
iNBNormalizeConfidentialSymbols[_] := {};

iNBNormalizePolicySnapshotPayload[snapshotOrPayload_Association] :=
  KeySort @ <|
    "NBAccessPolicyVersion" ->
      ToString[
        Lookup[snapshotOrPayload, "NBAccessPolicyVersion", "unversioned"]],
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

(* snapshot mode \:5c02\:7528 accessor\:3002
   snapshot \:304b\:3089\:5224\:5b9a\:5165\:529b\:3092\:53d6\:308a\:51fa\:3059\:3002\:30ab\:30c6\:30b4\:30ea global \:3078\:306f
   \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3057\:306a\:3044 (snapshot \:304c\:6b63\:672c)\:3002 *)
iNBSnapshotAllowedHeads[snapshot_Association] :=
  Lookup[snapshot, "AllowedHeads", {}];
iNBSnapshotApprovalHeads[snapshot_Association] :=
  Lookup[snapshot, "ApprovalHeads", {}];
iNBSnapshotDenyHeads[snapshot_Association] :=
  Lookup[snapshot, "DenyHeads", {}];
iNBSnapshotConfidentialSymbols[snapshot_Association] :=
  Lookup[snapshot, "ConfidentialSymbols", {}];

(* ---- NBPolicySnapshot[] ----
   main kernel \:3067\:73fe\:5728\:306e\:52d5\:7684 policy \:3092\:51cd\:7d50\:3059\:308b\:3002
   \:6ce8\:610f: $NBAccessPolicyVersion \:306f\:73fe\:884c\:30b3\:30fc\:30c9\:306b\:5b58\:5728\:3057\:306a\:3044\:305f\:3081\:3001
   ValueQ \:3067\:5b58\:5728\:78ba\:8a8d\:3057\:3001\:7121\:3051\:308c\:3070 "unversioned" \:3092\:5165\:308c\:308b\:3002 *)

$NBActivePolicySnapshot = None;

NBPolicySnapshot[] :=
  Module[{ver, allowed, approval, deny, conf, payload, digest},
    (* 1. \:5c0e\:51fa\:6e08\:307f AllowedHeads \:3092\:6700\:65b0\:5316 *)
    iRecomputeAllowedHeads[];

    (* 2. \:5404\:96c6\:5408\:3092\:53d6\:5f97 *)
    ver = If[ValueQ[$NBAccessPolicyVersion],
      $NBAccessPolicyVersion, "unversioned"];
    allowed  = If[ListQ[$NBAllowedHeads],  $NBAllowedHeads,  {}];
    approval = If[ListQ[$NBApprovalHeads], $NBApprovalHeads, {}];
    deny     = If[ListQ[$NBDenyHeads],     $NBDenyHeads,     {}];
    conf     = If[AssociationQ[$NBConfidentialSymbols] ||
                  ListQ[$NBConfidentialSymbols],
                  $NBConfidentialSymbols, {}];

    (* 3. digest payload (digest \:5bfe\:8c61\:30ad\:30fc\:306e\:307f) *)
    payload = <|
      "NBAccessPolicyVersion" -> ver,
      "AllowedHeads"          -> allowed,
      "ApprovalHeads"         -> approval,
      "DenyHeads"             -> deny,
      "ConfidentialSymbols"   -> conf
    |>;

    (* 4. digest *)
    digest = iNBComputePolicyDigest[payload];

    (* 5. snapshot Association *)
    <|
      "SnapshotID"            -> CreateUUID[],
      "CreatedAt"             -> AbsoluteTime[],
      "NBAccessPolicyVersion" -> ver,
      "AllowedHeads"          -> allowed,
      "ApprovalHeads"         -> approval,
      "DenyHeads"             -> deny,
      "ConfidentialSymbols"   -> conf,
      "Digest"                -> digest,
      "Source"                -> "CurrentGlobals"
    |>
  ];

(* ---- NBAcceptPolicySnapshot[snapshot] ----
   subkernel \:5074\:3067 snapshot \:3092\:691c\:8a3c\:3059\:308b\:3002 *)

NBAcceptPolicySnapshot[snapshot_Association] :=
  Module[{requiredKeys, recomputed, stored},
    requiredKeys = {
      "SnapshotID", "CreatedAt", "NBAccessPolicyVersion",
      "AllowedHeads", "ApprovalHeads", "DenyHeads",
      "ConfidentialSymbols", "Digest", "Source"
    };

    (* 1. \:5fc5\:9808\:30ad\:30fc\:78ba\:8a8d *)
    If[! AllTrue[requiredKeys, KeyExistsQ[snapshot, #] &],
      Return[<|
        "Valid"  -> False,
        "Digest" -> None,
        "Reason" -> "MissingRequiredKeys"
      |>]];

    (* 2. digest \:518d\:8a08\:7b97\:30fb\:7167\:5408 *)
    recomputed = iNBComputePolicyDigest[snapshot];
    If[recomputed =!= Lookup[snapshot, "Digest", None],
      Return[<|
        "Valid"  -> False,
        "Digest" -> recomputed,
        "Reason" -> "DigestMismatch"
      |>]];

    (* 3. Valid: \:53c2\:8003\:7528\:306b\:4fdd\:5b58 (\:6b63\:672c\:3067\:306f\:306a\:3044) *)
    $NBActivePolicySnapshot = snapshot;

    <|
      "Valid"  -> True,
      "Digest" -> recomputed,
      "Reason" -> None
    |>
  ];

NBAcceptPolicySnapshot[_] :=
  <|"Valid" -> False, "Digest" -> None, "Reason" -> "NotAnAssociation"|>;

(* ════════════════════════════════════════════════════════════════════
   Inc7 (session episode spec §16.2/§16.3/§13.2):
     - WritableStagingRoot 包含検査 (単一 staging root、FinalTargetRefs 拒否)
     - IsolationLevel の順序判定
     - ToolCallId scoped permit (Phase 2b 予告の実装: one-shot・期限付き)
   すべて純加法。既存の AllowedDirectories ベースの検査 (NBCheckFileWrite
   等) は不変。定義は完全修飾で public 化する。
   注意: path 正規化は ExpandFileName ベース (相対 path / ".." を解決)。
   symlink/junction の実体解決は未対応 (実運用強化は Inc9 以降)。
   ════════════════════════════════════════════════════════════════════ *)

NBAccess`NBCheckStagingWrite::usage =
  "NBCheckStagingWrite[path, accessSpec] は path が accessSpec の\n" <>
  "WritableStagingRoot 配下にある場合のみ Permit を返す (§16.2)。\n" <>
  "FinalTargetRefs 配下・staging 外は Deny。戻り値\n" <>
  "<|\"Decision\"->\"Permit\"|\"Deny\", \"Reason\", \"Path\"|>。fail-closed。";

NBAccess`NBIsolationRank::usage =
  "NBIsolationRank[level] は IsolationLevel の強度 (CooperativeKernel=0 <\n" <>
  "WorkspaceOverlay=1 < ExternalProcess=2 < Container=3)。不明は -1。";

NBAccess`NBIsolationSatisfiedQ::usage =
  "NBIsolationSatisfiedQ[required, actual] は actual の isolation が\n" <>
  "required 以上なら True (§7.2/§20.3。CooperativeKernel は hard isolation\n" <>
  "必須 task に選ばれない)。不明値は fail-closed で False。";

NBAccess`NBGrantToolCallPermit::usage =
  "NBGrantToolCallPermit[toolCallId, opts] は ToolCallId 一件だけを解禁する\n" <>
  "one-shot permit を登録する (§13.2)。\"ExpiresInSeconds\"->300 既定。";

NBAccess`NBToolCallPermitValidQ::usage =
  "NBToolCallPermitValidQ[toolCallId] は未消費・未期限切れの permit が\n" <>
  "あれば True。";

NBAccess`NBConsumeToolCallPermit::usage =
  "NBConsumeToolCallPermit[toolCallId] は permit を一度だけ消費して True。\n" <>
  "無い/消費済み/期限切れは False (one-shot §13.2)。";

NBAccess`NBToolCallPermits::usage =
  "NBToolCallPermits[] は permit registry を返す (検査用)。";

NBAccess`NBToolCallPermitReset::usage =
  "NBToolCallPermitReset[] は permit registry をクリアする。テスト用。";

iNBStagingNormalize[p_String] :=
  Module[{e = ExpandFileName[p]},
    If[$OperatingSystem === "Windows", ToLowerCase[e], e]];

NBAccess`NBCheckStagingWrite[path_String, accessSpec_Association] :=
  Module[{root, p, r, finals, insideRoot, underFinal},
    root = Lookup[accessSpec, "WritableStagingRoot", None];
    If[!StringQ[root] || root === "",
      Return[<|"Decision" -> "Deny",
        "Reason" -> "NoWritableStagingRoot", "Path" -> path|>]];
    p = iNBStagingNormalize[path];
    r = iNBStagingNormalize[root];
    insideRoot = (p === r) ||
      StringStartsQ[p, r <> $PathnameSeparator];
    If[!insideRoot,
      Return[<|"Decision" -> "Deny",
        "Reason" -> "PathOutOfStagingRoot", "Path" -> p|>]];
    (* FinalTargetRefs は staging 内にあっても直接 write 禁止 (§16.2) *)
    finals = Select[Lookup[accessSpec, "FinalTargetRefs", {}], StringQ];
    underFinal = AnyTrue[finals,
      Function[f, Module[{fn = iNBStagingNormalize[f]},
        p === fn || StringStartsQ[p, fn <> $PathnameSeparator]]]];
    If[underFinal,
      <|"Decision" -> "Deny",
        "Reason" -> "FinalTargetDirectWriteForbidden", "Path" -> p|>,
      <|"Decision" -> "Permit", "Reason" -> None, "Path" -> p|>]
  ];

NBAccess`NBCheckStagingWrite[___] :=
  <|"Decision" -> "Deny", "Reason" -> "InvalidArguments"|>;

NBAccess`NBIsolationRank[level_] :=
  Switch[level,
    "CooperativeKernel", 0,
    "WorkspaceOverlay", 1,
    "ExternalProcess", 2,
    "Container", 3,
    _, -1];

NBAccess`NBIsolationSatisfiedQ[required_, actual_] :=
  Module[{rq = NBAccess`NBIsolationRank[required],
          ac = NBAccess`NBIsolationRank[actual]},
    rq >= 0 && ac >= 0 && ac >= rq];

If[!AssociationQ[NBAccess`Private`$iNBToolCallPermits],
  NBAccess`Private`$iNBToolCallPermits = <||>];

Options[NBAccess`NBGrantToolCallPermit] = {
  "ExpiresInSeconds" -> 300,
  "EffectClasses" -> All,
  "GrantedBy" -> "user"};

NBAccess`NBGrantToolCallPermit[toolCallId_String,
    opts:OptionsPattern[NBAccess`NBGrantToolCallPermit]] := (
  AssociateTo[NBAccess`Private`$iNBToolCallPermits,
    toolCallId -> <|
      "ToolCallId" -> toolCallId,
      "EffectClasses" -> OptionValue["EffectClasses"],
      "GrantedBy" -> OptionValue["GrantedBy"],
      "GrantedAt" -> AbsoluteTime[],
      "ExpiresAt" -> AbsoluteTime[] +
        OptionValue["ExpiresInSeconds"],
      "Used" -> False|>];
  <|"Status" -> "Granted", "ToolCallId" -> toolCallId|>);

NBAccess`NBToolCallPermitValidQ[toolCallId_String] :=
  Module[{p = Lookup[NBAccess`Private`$iNBToolCallPermits,
            toolCallId, None]},
    AssociationQ[p] && !TrueQ[Lookup[p, "Used", True]] &&
    AbsoluteTime[] <= Lookup[p, "ExpiresAt", 0]];

NBAccess`NBToolCallPermitValidQ[___] := False;

NBAccess`NBConsumeToolCallPermit[toolCallId_String] :=
  If[NBAccess`NBToolCallPermitValidQ[toolCallId],
    Module[{p = NBAccess`Private`$iNBToolCallPermits[toolCallId]},
      p["Used"] = True;
      p["UsedAt"] = AbsoluteTime[];
      AssociateTo[NBAccess`Private`$iNBToolCallPermits,
        toolCallId -> p];
      True],
    False];

NBAccess`NBConsumeToolCallPermit[___] := False;

NBAccess`NBToolCallPermits[] := NBAccess`Private`$iNBToolCallPermits;

NBAccess`NBToolCallPermitReset[] := (
  NBAccess`Private`$iNBToolCallPermits = <||>;
  <|"Status" -> "Reset"|>);

(* ============================================================
   Calendar access (iCal/ICS): access-level gated read.
   Pure parser + deterministic RRULE expansion. Fixes the legacy
   NotebookExtensions`calendardata recurrence bugs (single-offset
   expansion, ignored INTERVAL, approximate month arithmetic,
   unhandled DAILY/COUNT/BYDAY/EXDATE/RECURRENCE-ID).
   Wrapped in an explicit Begin/End so the iNBCal*/iNBICS* helpers stay in
   NBAccess`Private` (public API keeps its explicit NBAccess` prefix) even if
   the ambient context was popped early by a cross-loaded package.
   ============================================================ *)

Begin["NBAccess`Private`"];

If[!ListQ[NBAccess`$NBCalendarMandatoryPatterns],
  NBAccess`$NBCalendarMandatoryPatterns = {}];
If[!NumberQ[NBAccess`$NBCalendarCacheSeconds],
  NBAccess`$NBCalendarCacheSeconds = 300];
If[!StringQ[NBAccess`$NBCalendarCredentialName],
  NBAccess`$NBCalendarCredentialName = "ics-calendar"];
If[!MatchQ[NBAccess`$NBCalendarIdentityKeyRef, _String],
  NBAccess`$NBCalendarIdentityKeyRef = Missing["None"]];
If[!AssociationQ[$iNBCalCache], $iNBCalCache = <||>];

$iNBCalMaxOccurrences = 1000;
$iNBCalMaxPeriods = 4000;

$iNBICSDayMap = <|"MO" -> 1, "TU" -> 2, "WE" -> 3, "TH" -> 4,
  "FR" -> 5, "SA" -> 6, "SU" -> 7|>;
$iNBICSDayNames = {Monday, Tuesday, Wednesday, Thursday, Friday,
  Saturday, Sunday};

iNBCalDayIndex[d_] := Module[{p = FirstPosition[$iNBICSDayNames, DayName[d]]},
  If[MissingQ[p], 1, p[[1]]]];

iNBCalLeapQ[y_Integer] := Mod[y, 4] == 0 && (Mod[y, 100] != 0 || Mod[y, 400] == 0);
iNBCalDaysInMonth[y_Integer, mo_Integer] :=
  {31, 28 + If[iNBCalLeapQ[y], 1, 0], 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}[[mo]];

iNBCalMakeDate[y_, mo_, d_, h_, mi_, s_, tz_] :=
  DateObject[{y, mo, d, h, mi, s}, TimeZone -> tz];
iNBCalShiftDays[d_, n_] := DatePlus[d, {n, "Day"}];
iNBCalFromAbs[abs_, tz_] :=
  Quiet@Check[DateObject[FromAbsoluteTime[abs], TimeZone -> tz], FromAbsoluteTime[abs]];

iNBCalMinuteKey[d_] := Round[AbsoluteTime[d]/60];
iNBCalDayKey[d_] := DateString[d, {"Year", "-", "Month", "-", "Day"}];

(* ---- ICS text layer ---- *)

iNBICSUnfoldLines[text_String] := Module[{t},
  t = StringReplace[text, {"\r\n" -> "\n", "\r" -> "\n"}];
  StringSplit[StringReplace[t, {"\n " -> "", "\n\t" -> ""}], "\n"]];

iNBICSUnescapeText[s_String] := StringReplace[s,
  {"\\\\" -> "\\", "\\n" -> "\n", "\\N" -> "\n", "\\," -> ",", "\\;" -> ";"}];

iNBICSSplitLine[line_String] := Module[
  {chars = Characters[line], inQ = False, cut = 0, i = 1, head, val, toks, name, params},
  While[i <= Length[chars] && cut == 0,
    Which[chars[[i]] === "\"", inQ = !inQ,
      chars[[i]] === ":" && !inQ, cut = i];
    i++];
  If[cut == 0, Missing["NoColon"],
    head = StringTake[line, cut - 1];
    val = StringTake[line, {cut + 1, StringLength[line]}];
    toks = StringSplit[head, ";"];
    name = ToUpperCase[First[toks, ""]];
    params = Association[Map[
      Function[p, Module[{kv = StringSplit[p, "=", 2]},
        If[Length[kv] == 2, ToUpperCase[kv[[1]]] -> kv[[2]], Nothing]]],
      Rest[toks]]];
    <|"Name" -> name, "Params" -> params, "Value" -> val|>]];

$iNBCalWindowsTZMap = <|
  "Tokyo Standard Time" -> "Asia/Tokyo",
  "UTC" -> 0,
  "GMT Standard Time" -> "Europe/London",
  "Pacific Standard Time" -> "America/Los_Angeles",
  "Eastern Standard Time" -> "America/New_York",
  "China Standard Time" -> "Asia/Shanghai",
  "Korea Standard Time" -> "Asia/Seoul"|>;

iNBCalTZResolve[tzid_String] := Module[{cand = Lookup[$iNBCalWindowsTZMap, tzid, tzid]},
  Quiet@Check[
    (AbsoluteTime[DateObject[{2026, 1, 1, 0, 0, 0}, TimeZone -> cand]]; cand),
    $TimeZone]];
iNBCalTZResolve[___] := $TimeZone;

iNBICSParseDateValue[v_String, params_Association] := Module[
  {val = v, dateOnly, utc, y, mo, d, h = 0, mi = 0, s = 0, tzres},
  dateOnly = TrueQ[ToUpperCase[Lookup[params, "VALUE", ""]] == "DATE"] ||
    (StringLength[v] == 8 && StringMatchQ[v, DigitCharacter ..]);
  utc = StringEndsQ[val, "Z"] || StringEndsQ[val, "z"];
  If[utc, val = StringDrop[val, -1]];
  If[StringLength[val] < 8 || !StringMatchQ[StringTake[val, 8], DigitCharacter ..],
    Missing["BadDate"],
    y = ToExpression[StringTake[val, 4]];
    mo = ToExpression[StringTake[val, {5, 6}]];
    d = ToExpression[StringTake[val, {7, 8}]];
    If[!dateOnly && StringLength[val] >= 15 &&
        ToUpperCase[StringTake[val, {9, 9}]] == "T",
      h = ToExpression[StringTake[val, {10, 11}]];
      mi = ToExpression[StringTake[val, {12, 13}]];
      s = Quiet@Check[ToExpression[StringTake[val, {14, 15}]], 0]];
    If[!(IntegerQ[y] && IntegerQ[mo] && IntegerQ[d] && 1 <= mo <= 12 && 1 <= d <= 31),
      Missing["BadDate"],
      tzres = Which[
        utc, 0,
        KeyExistsQ[params, "TZID"], iNBCalTZResolve[params["TZID"]],
        True, $TimeZone];
      <|"Date" -> DateObject[{y, mo, d, h, mi, s}, TimeZone -> tzres],
        "AllDay" -> dateOnly|>]]];

iNBICSParseByDay[s_String] := DeleteMissing[Map[
  Function[p, Module[{pp = ToUpperCase[StringTrim[p]], dayCode, ordStr, ord},
    If[StringLength[pp] < 2, Missing["Bad"],
      dayCode = StringTake[pp, -2];
      ordStr = StringDrop[pp, -2];
      If[!KeyExistsQ[$iNBICSDayMap, dayCode], Missing["Bad"],
        ord = If[ordStr === "", Missing["None"],
          Quiet@Check[Round@ToExpression[StringReplace[ordStr, "+" -> ""]],
            Missing["None"]]];
        <|"Ord" -> ord, "Day" -> $iNBICSDayMap[dayCode]|>]]]],
  StringSplit[s, ","]]];

(* PT1H30M / P1D / P2W style durations -> seconds *)
iNBICSParseDuration[s_String] := Module[{sign = 1, body = ToUpperCase[StringTrim[s]], w, dd, h, mi, sec},
  If[StringStartsQ[body, "-"], sign = -1; body = StringDrop[body, 1]];
  If[StringStartsQ[body, "+"], body = StringDrop[body, 1]];
  If[!StringStartsQ[body, "P"], 0,
    w = Quiet@Check[ToExpression@First[StringCases[body, (x : DigitCharacter ..) ~~ "W" :> x], "0"], 0];
    dd = Quiet@Check[ToExpression@First[StringCases[body, (x : DigitCharacter ..) ~~ "D" :> x], "0"], 0];
    h = Quiet@Check[ToExpression@First[StringCases[body, (x : DigitCharacter ..) ~~ "H" :> x], "0"], 0];
    mi = Quiet@Check[ToExpression@First[StringCases[body, (x : DigitCharacter ..) ~~ "M" :> x], "0"], 0];
    sec = Quiet@Check[ToExpression@First[StringCases[body, (x : DigitCharacter ..) ~~ "S" :> x], "0"], 0];
    sign*(w*7*86400 + dd*86400 + h*3600 + mi*60 + sec)]];

iNBICSParseRRule[value_String] := Module[{assoc},
  assoc = Association[Map[
    Function[p, Module[{kv = StringSplit[p, "=", 2]},
      If[Length[kv] == 2, ToUpperCase[kv[[1]]] -> kv[[2]], Nothing]]],
    StringSplit[value, ";"]]];
  <|"Freq" -> ToUpperCase[Lookup[assoc, "FREQ", ""]],
    "Interval" -> Max[1, Quiet@Check[Round@ToExpression[Lookup[assoc, "INTERVAL", "1"]], 1]],
    "Count" -> If[KeyExistsQ[assoc, "COUNT"],
      Quiet@Check[Round@ToExpression[assoc["COUNT"]], Missing["None"]], Missing["None"]],
    "Until" -> If[KeyExistsQ[assoc, "UNTIL"],
      Module[{pd = iNBICSParseDateValue[assoc["UNTIL"], <||>]},
        If[AssociationQ[pd], pd["Date"], Missing["None"]]], Missing["None"]],
    "ByDay" -> If[KeyExistsQ[assoc, "BYDAY"],
      iNBICSParseByDay[assoc["BYDAY"]], Missing["None"]],
    "ByMonthDay" -> If[KeyExistsQ[assoc, "BYMONTHDAY"],
      DeleteCases[Map[Function[x, Quiet@Check[Round@ToExpression[x], Missing["Bad"]]],
        StringSplit[assoc["BYMONTHDAY"], ","]], _Missing], Missing["None"]],
    "Raw" -> value|>];

iNBICSParseEvent[lines_List] := Module[
  {props, propGet, propGetAll, dtstart, sd, startD, allday, dtend, durProp, endD,
   tz, rrProp, exdates, recProp, recId, uidProp, seqProp, dtstampProp},
  props = DeleteMissing[iNBICSSplitLine /@ lines];
  propGet[nm_] := SelectFirst[props, #["Name"] === nm &, Missing["None"]];
  propGetAll[nm_] := Select[props, #["Name"] === nm &];
  dtstart = propGet["DTSTART"];
  If[!AssociationQ[dtstart], Missing["NoStart"],
    sd = iNBICSParseDateValue[dtstart["Value"], dtstart["Params"]];
    If[!AssociationQ[sd], Missing["BadStart"],
      startD = sd["Date"];
      allday = TrueQ[sd["AllDay"]];
      tz = Quiet@Check[startD["TimeZone"], $TimeZone];
      dtend = propGet["DTEND"];
      durProp = propGet["DURATION"];
      endD = Which[
        AssociationQ[dtend],
        Module[{ed = iNBICSParseDateValue[dtend["Value"], dtend["Params"]]},
          If[AssociationQ[ed], ed["Date"], Missing["Bad"]]],
        AssociationQ[durProp],
        iNBCalFromAbs[AbsoluteTime[startD] + iNBICSParseDuration[durProp["Value"]], tz],
        True, Missing["None"]];
      If[!DateObjectQ[endD],
        endD = If[allday, iNBCalShiftDays[startD, 1], startD]];
      If[AbsoluteTime[endD] < AbsoluteTime[startD], endD = startD];
      rrProp = propGet["RRULE"];
      exdates = Flatten[Map[
        Function[ex, Map[
          Function[v, Module[{pd = iNBICSParseDateValue[v, ex["Params"]]},
            If[AssociationQ[pd], pd["Date"], Nothing]]],
          StringSplit[ex["Value"], ","]]],
        propGetAll["EXDATE"]]];
      recProp = propGet["RECURRENCE-ID"];
      recId = If[AssociationQ[recProp],
        Module[{pd = iNBICSParseDateValue[recProp["Value"], recProp["Params"]]},
          If[AssociationQ[pd], pd["Date"], Missing["None"]]],
        Missing["None"]];
      seqProp = propGet["SEQUENCE"];
      dtstampProp = propGet["DTSTAMP"];
      uidProp = propGet["UID"];
      <|"UID" -> If[AssociationQ[uidProp], uidProp["Value"],
          "nouid-" <> ToString[Hash[lines]]],
        "Summary" -> With[{x = propGet["SUMMARY"]},
          If[AssociationQ[x], iNBICSUnescapeText[x["Value"]], ""]],
        "Description" -> With[{x = propGet["DESCRIPTION"]},
          If[AssociationQ[x], iNBICSUnescapeText[x["Value"]], Missing["None"]]],
        "Location" -> With[{x = propGet["LOCATION"]},
          If[AssociationQ[x], iNBICSUnescapeText[x["Value"]], Missing["None"]]],
        "Status" -> With[{x = propGet["STATUS"]},
          If[AssociationQ[x], ToUpperCase[x["Value"]], "CONFIRMED"]],
        "Categories" -> Flatten[Map[
          Function[c, iNBICSUnescapeText /@ StringSplit[c["Value"], ","]],
          propGetAll["CATEGORIES"]]],
        "Busy" -> With[{x = propGet["TRANSP"]},
          !(AssociationQ[x] && ToUpperCase[x["Value"]] === "TRANSPARENT")],
        "Start" -> startD, "End" -> endD, "AllDay" -> allday,
        "RRule" -> If[AssociationQ[rrProp],
          iNBICSParseRRule[rrProp["Value"]], Missing["None"]],
        "ExDates" -> exdates,
        "RecurrenceId" -> recId,
        "Sequence" -> If[AssociationQ[seqProp],
          Quiet@Check[Round@ToExpression[seqProp["Value"]], 0], 0],
        "Dtstamp" -> If[AssociationQ[dtstampProp], dtstampProp["Value"], Missing["None"]]|>]]];

NBAccess`NBICSParseEvents[text_String] := Module[{lines, blocks = {}, cur = None},
  lines = iNBICSUnfoldLines[text];
  Do[Which[
    StringMatchQ[ln, "BEGIN:VEVENT", IgnoreCase -> True], cur = {},
    StringMatchQ[ln, "END:VEVENT", IgnoreCase -> True],
      If[ListQ[cur], AppendTo[blocks, cur]]; cur = None,
    ListQ[cur], AppendTo[cur, ln]], {ln, lines}];
  Select[Quiet[iNBICSParseEvent /@ blocks], AssociationQ]];
NBAccess`NBICSParseEvents[___] := {};

(* ---- RRULE expansion (deterministic, chronological) ---- *)

iNBCalNthWeekdayOfMonth[y_, mo_, ord_Integer, wday_Integer, h_, mi_, s_, tz_] := Module[
  {dim = iNBCalDaysInMonth[y, mo], firstIdx, lastIdx, d},
  If[ord > 0,
    firstIdx = iNBCalDayIndex[DateObject[{y, mo, 1}]];
    d = 1 + Mod[wday - firstIdx, 7] + 7*(ord - 1),
    lastIdx = iNBCalDayIndex[DateObject[{y, mo, dim}]];
    d = dim - Mod[lastIdx - wday, 7] + 7*(ord + 1)];
  If[1 <= d <= dim, iNBCalMakeDate[y, mo, d, h, mi, s, tz], Missing["None"]]];

iNBCalMonthCandidates[start_, interval_, k_, byday_, bymday_, h_, mi_, s_, tz_] := Module[
  {y0 = DateValue[start, "Year"], m0 = DateValue[start, "Month"], idx, y, mo},
  idx = 12*y0 + (m0 - 1) + k*interval;
  y = Quotient[idx, 12]; mo = Mod[idx, 12] + 1;
  Which[
    MatchQ[byday, {__Association}] && AllTrue[byday, IntegerQ[#["Ord"]] &],
    SortBy[DeleteMissing[Map[
      Function[b, iNBCalNthWeekdayOfMonth[y, mo, b["Ord"], b["Day"], h, mi, s, tz]],
      byday]], AbsoluteTime],
    MatchQ[bymday, {__Integer}],
    SortBy[DeleteMissing[Map[
      Function[md, Module[{d = If[md > 0, md, iNBCalDaysInMonth[y, mo] + 1 + md]},
        If[1 <= d <= iNBCalDaysInMonth[y, mo],
          iNBCalMakeDate[y, mo, d, h, mi, s, tz], Missing["None"]]]],
      bymday]], AbsoluteTime],
    True,
    Module[{d = DateValue[start, "Day"]},
      If[d <= iNBCalDaysInMonth[y, mo],
        {iNBCalMakeDate[y, mo, d, h, mi, s, tz]}, {}]]]];

iNBCalPeriodCandidates[freq_, interval_, k_, start_, h_, mi_, s_, tz_, byday_, bymday_] :=
  Switch[freq,
    "DAILY", {iNBCalShiftDays[start, k*interval]},
    "WEEKLY",
    If[MatchQ[byday, {__Association}],
      Module[{anchorMonday = iNBCalShiftDays[start, 1 - iNBCalDayIndex[start]], weekStart},
        weekStart = iNBCalShiftDays[anchorMonday, 7*k*interval];
        SortBy[Map[Function[b, iNBCalShiftDays[weekStart, b["Day"] - 1]], byday],
          AbsoluteTime]],
      {iNBCalShiftDays[start, 7*k*interval]}],
    "MONTHLY", iNBCalMonthCandidates[start, interval, k, byday, bymday, h, mi, s, tz],
    "YEARLY",
    Module[{y = DateValue[start, "Year"] + k*interval,
        mo = DateValue[start, "Month"], d = DateValue[start, "Day"]},
      If[d <= iNBCalDaysInMonth[y, mo],
        {iNBCalMakeDate[y, mo, d, h, mi, s, tz]}, {}]],
    _, $Failed];

iNBCalExcludedQ[c_, allday_, exMinKeys_, exDayKeys_] :=
  If[TrueQ[allday], MemberQ[exDayKeys, iNBCalDayKey[c]],
    MemberQ[exMinKeys, iNBCalMinuteKey[c]]];

iNBCalExpandRRule[ev_Association, fromAbs_, toAbs_] := Module[
  {rr = ev["RRule"], start = ev["Start"], startAbs, durSec, tz, h, mi, s, allday,
   untilAbs, count, interval, freq, byday, bymday, exMinKeys, exDayKeys,
   occs = {}, produced = 0, k = 0, done = False, guard = 0, cands},
  startAbs = AbsoluteTime[start];
  durSec = Max[0, AbsoluteTime[ev["End"]] - startAbs];
  allday = TrueQ[ev["AllDay"]];
  tz = Quiet@Check[start["TimeZone"], $TimeZone];
  {h, mi, s} = If[allday, {0, 0, 0},
    Round /@ (DateValue[start, {"Hour", "Minute", "Second"}] /. x_Real :> Round[x])];
  freq = Lookup[rr, "Freq", ""];
  interval = Lookup[rr, "Interval", 1];
  count = Lookup[rr, "Count", Missing["None"]];
  untilAbs = With[{u = Lookup[rr, "Until", Missing["None"]]},
    If[DateObjectQ[u], AbsoluteTime[u], Infinity]];
  byday = Lookup[rr, "ByDay", Missing["None"]];
  bymday = Lookup[rr, "ByMonthDay", Missing["None"]];
  exMinKeys = iNBCalMinuteKey /@ ev["ExDates"];
  exDayKeys = iNBCalDayKey /@ ev["ExDates"];
  While[!done && guard++ < $iNBCalMaxPeriods,
    cands = iNBCalPeriodCandidates[freq, interval, k, start, h, mi, s, tz, byday, bymday];
    If[cands === $Failed, done = True,
      cands = Select[cands, AbsoluteTime[#] >= startAbs - 1 &];
      Do[
        If[!done,
          Module[{cAbs = AbsoluteTime[c]},
            Which[
              cAbs > untilAbs + 1.0, done = True,
              IntegerQ[count] && produced >= count, done = True,
              True,
              (produced++;
               Which[
                 cAbs >= toAbs, done = True,
                 cAbs + durSec > fromAbs &&
                   !iNBCalExcludedQ[c, allday, exMinKeys, exDayKeys],
                 (AppendTo[occs,
                    <|"Start" -> c, "End" -> iNBCalFromAbs[cAbs + durSec, tz]|>];
                  If[Length[occs] >= $iNBCalMaxOccurrences, done = True])])]]],
        {c, cands}]];
    k++];
  occs];

NBAccess`NBICSEventOccurrences[ev_Association, from_, to_] := Module[
  {fromAbs = Quiet@Check[AbsoluteTime[from], $Failed],
   toAbs = Quiet@Check[AbsoluteTime[to], $Failed], rr},
  If[!NumberQ[fromAbs] || !NumberQ[toAbs] || toAbs <= fromAbs, {},
    rr = Lookup[ev, "RRule", Missing["None"]];
    If[AssociationQ[rr] && StringQ[Lookup[rr, "Freq", ""]] &&
        MemberQ[{"DAILY", "WEEKLY", "MONTHLY", "YEARLY"}, Lookup[rr, "Freq", ""]],
      Map[Function[o, Join[KeyDrop[ev, {"RRule", "ExDates", "RecurrenceId"}],
        <|"Start" -> o["Start"], "End" -> o["End"],
          "OriginalStart" -> o["Start"], "Recurring" -> True|>]],
        iNBCalExpandRRule[ev, fromAbs, toAbs]],
      Module[{sAbs = Quiet@Check[AbsoluteTime[ev["Start"]], $Failed],
          eAbs = Quiet@Check[AbsoluteTime[ev["End"]], $Failed],
          recId = Lookup[ev, "RecurrenceId", Missing["None"]]},
        If[NumberQ[sAbs] && NumberQ[eAbs] && sAbs < toAbs && Max[eAbs, sAbs + 1] > fromAbs,
          {Join[KeyDrop[ev, {"RRule", "ExDates", "RecurrenceId"}],
            <|"OriginalStart" -> If[DateObjectQ[recId], recId, ev["Start"]],
              "Recurring" -> False|>]}, {}]]]]];
NBAccess`NBICSEventOccurrences[___] := {};

iNBCalOccurrencesAll[events_List, fromAbs_, toAbs_] := Module[
  {overrides, masters, ovByUid, out = {}},
  overrides = Select[events, DateObjectQ[Lookup[#, "RecurrenceId", Missing[]]] &];
  masters = Select[events, !DateObjectQ[Lookup[#, "RecurrenceId", Missing[]]] &];
  ovByUid = GroupBy[overrides, Lookup[#, "UID", ""] &];
  Do[Module[{evx = ev, ovs = Lookup[ovByUid, Lookup[ev, "UID", ""], {}]},
      If[ovs =!= {},
        evx = Append[ev, "ExDates" ->
          Join[Lookup[ev, "ExDates", {}], Map[#["RecurrenceId"] &, ovs]]]];
      out = Join[out, NBAccess`NBICSEventOccurrences[evx,
        iNBCalFromAbs[fromAbs, $TimeZone], iNBCalFromAbs[toAbs, $TimeZone]]]],
    {ev, masters}];
  Do[Module[{sAbs = Quiet@Check[AbsoluteTime[ov["Start"]], $Failed],
      eAbs = Quiet@Check[AbsoluteTime[ov["End"]], $Failed],
      recId = Lookup[ov, "RecurrenceId", Missing["None"]]},
      If[NumberQ[sAbs] && NumberQ[eAbs] && sAbs < toAbs && Max[eAbs, sAbs + 1] > fromAbs,
        AppendTo[out, Join[KeyDrop[ov, {"RRule", "ExDates", "RecurrenceId"}],
          <|"OriginalStart" -> If[DateObjectQ[recId], recId, ov["Start"]],
            "Recurring" -> True|>]]]],
    {ov, overrides}];
  out = Select[out, Lookup[#, "Status", "CONFIRMED"] =!= "CANCELLED" &];
  SortBy[out, {AbsoluteTime[#["Start"]] &, Lookup[#, "UID", ""] &}]];

(* ---- source resolution / fetch / cache ---- *)

iNBCalResolveSource[Automatic] := Module[
  {cred = Quiet@Check[SystemCredential[NBAccess`$NBCalendarCredentialName], $Failed], sec},
  sec = Which[
    StringQ[cred], cred,
    cred === $Failed || MissingQ[cred] || cred === None, $Failed,
    True, Quiet@Check[cred["Secret"], $Failed]];
  If[StringQ[sec], sec, $Failed]];
iNBCalResolveSource[src_String] := src;
iNBCalResolveSource[___] := $Failed;

iNBCalFetchICSText[source_String] := Which[
  StringStartsQ[ToLowerCase[source], "http"],
  Module[{r = Quiet@Check[URLRead[source], $Failed]},
    If[MatchQ[r, _HTTPResponse] && r["StatusCode"] === 200,
      Quiet@Check[ByteArrayToString[r["BodyByteArray"], "UTF-8"],
        Quiet@Check[r["Body"], $Failed]],
      $Failed]],
  FileExistsQ[source],
  Quiet@Check[ByteArrayToString[ReadByteArray[source], "UTF-8"],
    Quiet@Check[Import[source, "Text"], $Failed]],
  True, $Failed];
iNBCalFetchICSText[___] := $Failed;

iNBCalGetEvents[source_String, refresh_] := Module[
  {key = ToString[Hash[source, "SHA256"]], now = AbsoluteTime[], entry, text, evs},
  entry = Lookup[$iNBCalCache, key, Missing["None"]];
  If[!TrueQ[refresh] && AssociationQ[entry] &&
      now - entry["At"] <= NBAccess`$NBCalendarCacheSeconds,
    entry["Events"],
    text = iNBCalFetchICSText[source];
    If[!StringQ[text], $Failed,
      evs = NBAccess`NBICSParseEvents[text];
      AssociateTo[$iNBCalCache, key -> <|"At" -> now, "Events" -> evs|>];
      evs]]];

(* ---- access level resolution / field filtering ---- *)

iNBCalResolveLevel[spec_] := Module[{s = If[spec === Automatic, NBAccess`$NBPrivacySpec, spec]},
  Which[
    AssociationQ[s] && NumberQ[Lookup[s, "AccessLevel", Missing[]]],
      N[s["AccessLevel"]],
    NumberQ[s], N[s],
    True, 0.5]];

(* R0b identity fields are returned at EVERY level (all opaque). *)
$iNBCalIdentityFields = {"EventId", "OriginalStart", "SemanticDigest", "ObservedRevision"};
iNBCalLevelFields[level_] := Which[
  level >= 1.0, All,
  level >= 0.7, Join[{"Start", "End", "AllDay", "Busy", "Mandatory", "Recurring",
    "Summary", "Categories", "Status", "UIDDigest"}, $iNBCalIdentityFields],
  True, Join[{"Start", "End", "AllDay", "Busy", "Mandatory", "Recurring", "UIDDigest"},
    $iNBCalIdentityFields]];

iNBCalFilterFields[assoc_, All] := assoc;
iNBCalFilterFields[assoc_, fields_List] := KeyTake[assoc, fields];

iNBCalMandatoryQ[occ_, patterns_List] := Module[{hay},
  If[patterns === {}, False,
    hay = StringRiffle[Select[Flatten[{Lookup[occ, "Summary", ""],
      Lookup[occ, "Categories", {}],
      Lookup[occ, "Description", ""]}], StringQ], " "];
    AnyTrue[patterns,
      Function[p, TrueQ[Quiet@Check[StringContainsQ[hay, p, IgnoreCase -> True], False]]]]]];

iNBCalUIDDigest[uid_] := StringTake[
  IntegerString[Hash[If[StringQ[uid], uid, ToString[uid]], "SHA256"], 36] <>
    "0000000000000000", 16];

(* ---- R0b: identity / revision (returned at every access level) ---- *)

(* HMAC-SHA256 (RFC 2104), hex. Verified against RFC 4231 test vector 2. *)
iNBCalHMAC[key_String, msg_String] := Module[
  {b = 64, kb, k0, ipad, opad, inner},
  kb = Normal[StringToByteArray[key, "UTF-8"]];
  If[Length[kb] > b, kb = Normal[Hash[StringToByteArray[key, "UTF-8"], "SHA256", "ByteArray"]]];
  k0 = PadRight[kb, b, 0];
  ipad = BitXor[k0, ConstantArray[16^^36, b]];
  opad = BitXor[k0, ConstantArray[16^^5C, b]];
  inner = Normal[Hash[ByteArray[Join[ipad, Normal[StringToByteArray[msg, "UTF-8"]]]],
    "SHA256", "ByteArray"]];
  IntegerString[Hash[ByteArray[Join[opad, inner]], "SHA256"], 16]];

iNBCalIdentityKey[] := Module[
  {ref = NBAccess`$NBCalendarIdentityKeyRef, cred},
  If[!StringQ[ref] || ref === "", Missing["Unkeyed"],
    cred = Quiet@Check[SystemCredential[ref], $Failed];
    Which[
      StringQ[cred] && cred =!= "", cred,
      cred === $Failed || MissingQ[cred] || cred === None, Missing["Unkeyed"],
      True, With[{s = Quiet@Check[cred["Secret"], $Failed]},
        If[StringQ[s] && s =!= "", s, Missing["Unkeyed"]]]]]];

(* stable short id for the key itself (does not expose the key) *)
iNBCalKeyId[key_String] := StringTake[
  IntegerString[Hash["nbcal-idkey:" <> key, "SHA256"], 36] <> "00000000", 8];

iNBCalEventId[uid_String, key_String] :=
  "idv1:" <> iNBCalKeyId[key] <> ":" <> StringTake[iNBCalHMAC[key, uid], 32];
iNBCalEventId[uid_String, _] := "unkeyed:" <> iNBCalUIDDigest[uid];
iNBCalEventId[uid_, k_] := iNBCalEventId[If[StringQ[uid], uid, ToString[uid]], k];

(* canonical, TZ-independent instant for digesting *)
iNBCalDigestTime[d_] := If[DateObjectQ[d], Round[AbsoluteTime[d]], "none"];

iNBCalSemanticDigest[o_Association] := IntegerString[Hash[{
  "os", iNBCalDigestTime[Lookup[o, "OriginalStart", Missing["None"]]],
  "s", iNBCalDigestTime[Lookup[o, "Start", Missing["None"]]],
  "e", iNBCalDigestTime[Lookup[o, "End", Missing["None"]]],
  "st", ToUpperCase[ToString[Lookup[o, "Status", "CONFIRMED"]]],
  "b", TrueQ[Lookup[o, "Busy", True]],
  "ad", TrueQ[Lookup[o, "AllDay", False]]}, "SHA256"], 36];

iNBCalObservedRevision[o_Association] := IntegerString[Hash[{
  "seq", Lookup[o, "Sequence", 0],
  "ts", ToString[Lookup[o, "Dtstamp", ""]]}, "SHA256"], 36];

(* ---- public API ---- *)

Options[NBAccess`NBCalendarEvents] = {
  PrivacySpec -> Automatic,
  "Source" -> Automatic,
  "ICSText" -> Missing["None"],
  "MandatoryPatterns" -> Automatic,
  "MaxEvents" -> 500,
  "Refresh" -> False,
  "Wrap" -> False};

NBAccess`NBCalendarEvents[from_, to_, OptionsPattern[]] := Module[
  {level, fromAbs, toAbs, evs, occs, patterns, fields, maxE, idKey, keyed,
   totalCount, truncated, result},
  level = iNBCalResolveLevel[OptionValue[PrivacySpec]];
  fromAbs = Quiet@Check[AbsoluteTime[from], $Failed];
  toAbs = Quiet@Check[AbsoluteTime[to], $Failed];
  Which[
    !NumberQ[level] || level < 0.5,
    Failure["NBCalendarAccessDenied", <|
      "MessageTemplate" -> "AccessLevel below 0.5 cannot read calendar data.",
      "RequiredAccessLevel" -> 0.5|>],
    !NumberQ[fromAbs] || !NumberQ[toAbs] || toAbs <= fromAbs,
    Failure["NBCalendarBadWindow", <|
      "MessageTemplate" -> "Invalid from/to window for NBCalendarEvents."|>],
    True,
    evs = If[StringQ[OptionValue["ICSText"]],
      NBAccess`NBICSParseEvents[OptionValue["ICSText"]],
      Module[{src = iNBCalResolveSource[OptionValue["Source"]]},
        If[!StringQ[src], $Failed,
          iNBCalGetEvents[src, OptionValue["Refresh"]]]]];
    If[evs === $Failed,
      Failure["NBCalendarSourceUnavailable", <|
        "MessageTemplate" ->
          "Calendar source could not be read (credential/file/URL)."|>],
      patterns = If[OptionValue["MandatoryPatterns"] === Automatic,
        NBAccess`$NBCalendarMandatoryPatterns, OptionValue["MandatoryPatterns"]];
      If[!ListQ[patterns], patterns = {}];
      idKey = iNBCalIdentityKey[];
      keyed = StringQ[idKey];
      occs = iNBCalOccurrencesAll[evs, fromAbs, toAbs];
      totalCount = Length[occs];
      maxE = OptionValue["MaxEvents"];
      truncated = IntegerQ[maxE] && maxE > 0 && totalCount > maxE;
      If[truncated, occs = Take[occs, maxE]];
      fields = iNBCalLevelFields[level];
      result = Map[Function[o, Module[{enriched},
        enriched = Join[o, <|
          "Mandatory" -> iNBCalMandatoryQ[o, patterns],
          "UIDDigest" -> iNBCalUIDDigest[Lookup[o, "UID", ""]],
          "EventId" -> iNBCalEventId[Lookup[o, "UID", ""], idKey],
          "SemanticDigest" -> iNBCalSemanticDigest[o],
          "ObservedRevision" -> iNBCalObservedRevision[o]|>];
        iNBCalFilterFields[KeyDrop[enriched, {"Sequence", "Dtstamp"}], fields]]], occs];
      If[TrueQ[OptionValue["Wrap"]],
        <|"Events" -> result,
          "ObservedAtUTC" -> DateString[Now, "ISODateTime", TimeZone -> 0] <> "Z",
          "Count" -> Length[result],
          "Truncated" -> truncated,
          "Completeness" -> If[truncated && totalCount > 0,
            N[Length[result]/totalCount], 1.0],
          "IdentityKeyed" -> keyed|>,
        result]]]];

Options[NBAccess`NBCalendarFreeBusy] = {
  PrivacySpec -> Automatic,
  "Source" -> Automatic,
  "ICSText" -> Missing["None"],
  "MandatoryPatterns" -> Automatic,
  "Refresh" -> False};

NBAccess`NBCalendarFreeBusy[from_, to_, opts : OptionsPattern[]] := Module[
  {evres, busy, blocks = {}},
  evres = NBAccess`NBCalendarEvents[from, to,
    "MaxEvents" -> 10000,
    PrivacySpec -> OptionValue[PrivacySpec],
    "Source" -> OptionValue["Source"],
    "ICSText" -> OptionValue["ICSText"],
    "MandatoryPatterns" -> OptionValue["MandatoryPatterns"],
    "Refresh" -> OptionValue["Refresh"]];
  If[!ListQ[evres], evres,
    busy = SortBy[Select[evres, TrueQ[#["Busy"]] &], AbsoluteTime[#["Start"]] &];
    Do[Module[{s = AbsoluteTime[b["Start"]], e = AbsoluteTime[b["End"]],
        m = TrueQ[b["Mandatory"]], last},
      If[blocks === {} || s > blocks[[-1]]["EndAbs"],
        AppendTo[blocks, <|"StartAbs" -> s, "EndAbs" -> e,
          "Mandatory" -> m, "Count" -> 1|>],
        last = blocks[[-1]];
        blocks[[-1]] = <|"StartAbs" -> last["StartAbs"],
          "EndAbs" -> Max[last["EndAbs"], e],
          "Mandatory" -> (last["Mandatory"] || m),
          "Count" -> last["Count"] + 1|>]],
      {b, busy}];
    Map[Function[b, <|"Start" -> iNBCalFromAbs[b["StartAbs"], $TimeZone],
      "End" -> iNBCalFromAbs[b["EndAbs"], $TimeZone],
      "Mandatory" -> b["Mandatory"], "Count" -> b["Count"]|>], blocks]]];

Options[NBAccess`NBCalendarBusyQ] = {
  PrivacySpec -> Automatic,
  "Source" -> Automatic,
  "ICSText" -> Missing["None"],
  "MandatoryPatterns" -> Automatic,
  "Refresh" -> False,
  "Detailed" -> False};

NBAccess`NBCalendarBusyQ[t_, OptionsPattern[]] := Module[
  {tAbs = Quiet@Check[AbsoluteTime[t], $Failed], fb, hit},
  If[!NumberQ[tAbs],
    If[TrueQ[OptionValue["Detailed"]], <|"Busy" -> False, "Reason" -> "BadTime"|>, False],
    fb = NBAccess`NBCalendarFreeBusy[
      iNBCalFromAbs[tAbs - 32*86400, $TimeZone],
      iNBCalFromAbs[tAbs + 60, $TimeZone],
      PrivacySpec -> OptionValue[PrivacySpec],
      "Source" -> OptionValue["Source"],
      "ICSText" -> OptionValue["ICSText"],
      "MandatoryPatterns" -> OptionValue["MandatoryPatterns"],
      "Refresh" -> OptionValue["Refresh"]];
    If[!ListQ[fb],
      If[TrueQ[OptionValue["Detailed"]],
        <|"Busy" -> False, "Reason" -> "SourceUnavailable"|>, False],
      hit = SelectFirst[fb,
        AbsoluteTime[#["Start"]] <= tAbs < AbsoluteTime[#["End"]] &, Missing["None"]];
      If[TrueQ[OptionValue["Detailed"]],
        If[MissingQ[hit], <|"Busy" -> False|>,
          <|"Busy" -> True, "Mandatory" -> TrueQ[hit["Mandatory"]],
            "Block" -> KeyTake[hit, {"Start", "End"}]|>],
        !MissingQ[hit]]]]];

End[]; (* NBAccess`Private` for the calendar block *)

(* ============================================================
   $onWork task metadata: access-level gated, NON-EVALUATING read.
   The security core (NBOnWorkTaskSafeExtract) processes a HELD expression and
   evaluates nothing but whitelisted literal values it rebuilds itself; it never
   calls ReleaseHold (static AC-033). Wrapped in its own Begin/End Private.
   ============================================================ *)

Begin["NBAccess`Private`"];

$iNBOnwWhitelist = {"Title", "Status", "Deadline", "NextReview", "EventDate",
  "Keywords", "Effort", "Movable", "DependsOn", "TaskId"};

(* ---- safe value matcher: pattern-match a HELD value, rebuild only literals ---- *)
iNBOnwSafeValue[Hold[s_String]] := <|"OK" -> True, "Value" -> s|>;
iNBOnwSafeValue[Hold[n_Integer]] := <|"OK" -> True, "Value" -> n|>;
iNBOnwSafeValue[Hold[r_Real]] := <|"OK" -> True, "Value" -> r|>;
iNBOnwSafeValue[Hold[True]] := <|"OK" -> True, "Value" -> True|>;
iNBOnwSafeValue[Hold[False]] := <|"OK" -> True, "Value" -> False|>;
iNBOnwSafeValue[Hold[DateObject[d : {__Integer}]]] :=
  <|"OK" -> True, "Value" -> DateObject[d]|>;
iNBOnwSafeValue[Hold[DateObject[d : {__Integer}, g_String]]] :=
  <|"OK" -> True, "Value" -> DateObject[d, g]|>;
iNBOnwSafeValue[Hold[Quantity[n : (_Integer | _Real), u_String]]] :=
  <|"OK" -> True, "Value" -> Quantity[n, u]|>;
iNBOnwSafeValue[Hold[{ss___String}]] := <|"OK" -> True, "Value" -> {ss}|>;
iNBOnwSafeValue[_] := <|"OK" -> False, "Value" -> Missing["Unsafe"]|>;

(* one held rule -> a (possibly empty) safe fragment. Whitelisted string key only. *)
iNBOnwRuleFromHold[Hold[(Rule | RuleDelayed)[k_String, v_]]] :=
  If[MemberQ[$iNBOnwWhitelist, k],
    With[{sv = iNBOnwSafeValue[Hold[v]]},
      If[TrueQ[sv["OK"]], <|k -> sv["Value"]|>, <||>]],
    <||>];
iNBOnwRuleFromHold[_] := <||>;

(* collect held rules without evaluating any value *)
SetAttributes[iNBOnwCollect, HoldAllComplete];
iNBOnwCollect[rs___] := Module[{heldRules = List @@ (Hold /@ Hold[rs])},
  Association[Flatten[Normal /@ (iNBOnwRuleFromHold /@ heldRules)]]];

NBAccess`NBOnWorkTaskSafeExtract[h_] := Module[{held1},
  held1 = Which[
    MatchQ[h, _HoldComplete], Replace[h, HoldComplete[a_] :> Hold[a]],
    MatchQ[h, _Hold], h,
    True, Return[<||>]];
  (* metadata cells are often authored as Defer[<|...|>] (see newNote[]); strip
     the display wrapper without evaluating anything inside. *)
  held1 = Replace[held1, Hold[(Defer | HoldForm | Identity)[e_]] :> Hold[e]];
  (* optional outer list (NotebookExtensions took icell[[1]]) *)
  held1 = Replace[held1, Hold[{first_, ___}] :> Hold[first]];
  held1 = Replace[held1, Hold[(Defer | HoldForm | Identity)[e_]] :> Hold[e]];
  Replace[held1, {
    Hold[Association[rs___]] :> iNBOnwCollect[rs],
    _ :> <||>}]];
NBAccess`NBOnWorkTaskSafeExtract[___] := <||>;

(* ---- file read glue: held expression from a .nb WITHOUT evaluating cells ----
   NOTE: Import[path,"Cells"] returns cell STYLE STRINGS, not Cell[] boxes; the
   real Cell[] structure comes from Import[path,"Notebook"]. We locate the first
   InitializationCell (or first Input cell) and MakeExpression its boxes -> a
   HoldComplete[...] that is never evaluated (NBOnWorkTaskSafeExtract rebuilds
   only whitelisted literals). *)
(* parse cache keyed by path -> <|"D" -> fileDateAbs, "H" -> held|>, PERSISTED to a
   LOCAL (non-Dropbox) .wxf so a fresh kernel re-parses only files whose FileDate
   changed instead of Import-ing every .nb again (~0.3s/file over Dropbox). *)
If[!AssociationQ[$iNBOnwCache], $iNBOnwCache = <||>];
If[!BooleanQ[$iNBOnwCacheLoaded], $iNBOnwCacheLoaded = False];
If[!BooleanQ[$iNBOnwCacheDirty], $iNBOnwCacheDirty = False];

iNBOnwCacheFile[] := Module[{base, la = Environment["LOCALAPPDATA"]},
  base = If[StringQ[la] && StringLength[la] > 0,
    FileNameJoin[{la, "NBAccess"}], FileNameJoin[{$TemporaryDirectory, "NBAccess"}]];
  Quiet@Check[If[!DirectoryQ[base],
    CreateDirectory[base, CreateIntermediateDirectories -> True]], Null];
  FileNameJoin[{base, "onwork_parse_cache.wxf"}]];

iNBOnwEnsureCacheLoaded[] := If[!TrueQ[$iNBOnwCacheLoaded],
  Module[{f = iNBOnwCacheFile[], loaded},
    If[FileExistsQ[f],
      loaded = Quiet@Check[Import[f, "WXF"], $Failed];
      If[AssociationQ[loaded], $iNBOnwCache = loaded]];
    $iNBOnwCacheLoaded = True]];

(* write once per scan, only if something was (re)parsed; atomic via temp+rename *)
iNBOnwPersistCache[] := If[TrueQ[$iNBOnwCacheDirty],
  Module[{f = iNBOnwCacheFile[], tmp},
    tmp = f <> ".tmp" <> ToString[$ProcessID];
    Quiet@Check[Export[tmp, $iNBOnwCache, "WXF"];
      RenameFile[tmp, f, OverwriteTarget -> True], Null];
    $iNBOnwCacheDirty = False]];

iNBOnwHeldFromFile[path_String] := Module[{fd, cached, held},
  fd = Quiet@Check[AbsoluteTime[FileDate[path]], $Failed];
  cached = $iNBOnwCache[path];
  If[AssociationQ[cached] && fd =!= $Failed && cached["D"] === fd,
    Return[cached["H"]]];
  held = Module[{nb0, inits0, bd0, h0},
    nb0 = Quiet@Check[Import[path, "Notebook"], $Failed];
    If[Head[nb0] =!= Notebook, Missing["Unreadable"],
      inits0 = Cases[nb0, Cell[bx_, ___, InitializationCell -> True, ___] :> bx, Infinity];
      If[inits0 === {},
        inits0 = Cases[nb0, Cell[b_BoxData, "Input", ___] :> b, Infinity]];
      If[inits0 === {}, Missing["NoInit"],
        bd0 = First[inits0];
        h0 = Quiet@Check[MakeExpression[bd0, StandardForm], $Failed];
        If[MatchQ[h0, _HoldComplete], h0, Missing["ParseFailed"]]]]];
  If[fd =!= $Failed,
    $iNBOnwCache[path] = <|"D" -> fd, "H" -> held|>; $iNBOnwCacheDirty = True];
  held];
iNBOnwHeldFromFile[___] := Missing["Unreadable"];

(* ---- derivation: safe metadata -> normalized task record ---- *)
iNBOnwState[meta_] := Module[{st = Lookup[meta, "Status", Missing["None"]]},
  Which[
    !StringQ[st], "Open",
    MemberQ[{"Done", "Pass"}, st], st,
    st === "Keep", "Keep",
    True, "Open"]];

iNBOnwDue[meta_, modDate_] := Module[{dl = Lookup[meta, "Deadline", Missing["None"]],
   nr = Lookup[meta, "NextReview", Missing["None"]]},
  Which[
    DateObjectQ[dl], <|"Due" -> dl, "DueKind" -> "Deadline"|>,
    DateObjectQ[nr], <|"Due" -> nr, "DueKind" -> "NextReview"|>,
    (* NextReview as an offset Quantity resolves against ModificationDate *)
    MatchQ[nr, _Quantity] && DateObjectQ[modDate],
      <|"Due" -> DatePlus[modDate, nr], "DueKind" -> "NextReview"|>,
    True, <|"Due" -> Missing["None"], "DueKind" -> Missing["None"]|>]];

iNBOnwDigest[s_] := StringTake[
  IntegerString[Hash[If[StringQ[s], s, ToString[s]], "SHA256"], 36] <>
    "0000000000000000", 16];

iNBOnwLevel[spec_] := Module[{s = If[spec === Automatic, NBAccess`$NBPrivacySpec, spec]},
  Which[AssociationQ[s] && NumberQ[Lookup[s, "AccessLevel", Missing[]]], N[s["AccessLevel"]],
    NumberQ[s], N[s], True, 0.5]];

iNBOnwProject[rec_, level_] := Module[{base},
  base = KeyTake[rec, {"Due", "DueKind", "State", "FileDigest", "ModificationDate",
    "ParseFailed"}];
  Which[
    level >= 1.0, rec,
    level >= 0.7, Join[base, KeyTake[rec,
      {"Title", "Keywords", "TaskId", "Effort", "Movable", "DependsOn"}]],
    True, base]];

(* build one normalized record from (path, held-metadata, modDate) *)
iNBOnwRecord[path_, held_, modDate_] := Module[{meta, due, parseFailed, rec},
  parseFailed = MissingQ[held] || !MatchQ[held, _HoldComplete | _Hold];
  meta = If[parseFailed, <||>, NBAccess`NBOnWorkTaskSafeExtract[held]];
  If[!AssociationQ[meta], meta = <||>; parseFailed = True];
  due = iNBOnwDue[meta, modDate];
  rec = <|
    "TaskId" -> Lookup[meta, "TaskId", Missing["None"]],
    "Title" -> Lookup[meta, "Title", Missing["None"]],
    "Keywords" -> Lookup[meta, "Keywords", {}],
    "Effort" -> Lookup[meta, "Effort", Missing["None"]],
    "Movable" -> Lookup[meta, "Movable", Missing["None"]],
    "DependsOn" -> Lookup[meta, "DependsOn", {}],
    "Due" -> due["Due"], "DueKind" -> due["DueKind"],
    "State" -> If[parseFailed, "Unknown", iNBOnwState[meta]],
    "ModificationDate" -> modDate,
    "FileDigest" -> iNBOnwDigest[path],
    "Path" -> path,
    "ParseFailed" -> parseFailed|>;
  rec];

Options[NBAccess`NBOnWorkTasks] = {
  "Directory" -> Automatic, "ModifiedWithinDays" -> Automatic,
  "IncludeDone" -> False, PrivacySpec -> Automatic, "MaxFiles" -> 2000,
  "Files" -> Automatic};

NBAccess`NBOnWorkTasks[OptionsPattern[]] := Module[
  {level, dir, files, recs, maxF = OptionValue["MaxFiles"], within, cutoff},
  level = iNBOnwLevel[OptionValue[PrivacySpec]];
  If[!NumberQ[level] || level < 0.5,
    Return[Failure["NBOnWorkAccessDenied", <|
      "MessageTemplate" -> "AccessLevel below 0.5 cannot read $onWork tasks.",
      "RequiredAccessLevel" -> 0.5|>]]];
  recs = Which[
    (* test seam: injected files with held metadata *)
    ListQ[OptionValue["Files"]],
      Map[Function[f, iNBOnwRecord[Lookup[f, "Path", "injected"],
        Lookup[f, "Held", Missing["None"]],
        Lookup[f, "ModificationDate", Missing["None"]]]], OptionValue["Files"]],
    True,
      dir = OptionValue["Directory"];
      If[dir === Automatic, dir = Quiet@Check[Symbol["Global`$onWork"], $Failed]];
      If[!StringQ[dir] || !DirectoryQ[dir],
        Return[Failure["NBOnWorkNoDirectory", <|
          "MessageTemplate" -> "$onWork directory not found."|>]]];
      files = Quiet@Check[
        FileNames["*.nb", dir, Infinity], {}];
      within = OptionValue["ModifiedWithinDays"];
      If[NumberQ[within],
        cutoff = AbsoluteTime[] - within*86400;
        files = Select[files,
          Quiet@Check[AbsoluteTime[FileDate[#]] >= cutoff, True] &]];
      If[IntegerQ[maxF] && maxF > 0 && Length[files] > maxF,
        files = Take[files, maxF]];
      iNBOnwEnsureCacheLoaded[];
      With[{out = Map[Function[p, iNBOnwRecord[p, iNBOnwHeldFromFile[p],
          Quiet@Check[FileDate[p], Missing["None"]]]], files]},
        iNBOnwPersistCache[]; out]];
  (* IncludeDone filter *)
  If[!TrueQ[OptionValue["IncludeDone"]],
    recs = Select[recs, !MemberQ[{"Done", "Pass"}, Lookup[#, "State", "Open"]] &]];
  iNBOnwProject[#, level] & /@ recs];
NBAccess`NBOnWorkTasks[___] :=
  Failure["NBOnWorkBadArgs", <|"MessageTemplate" -> "Bad NBOnWorkTasks arguments."|>];

End[]; (* NBAccess`Private` for the $onWork block *)

EndPackage[];
