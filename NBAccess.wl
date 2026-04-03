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
  "\:30b7\:30b0\:30cd\:30c1\:30e3: $NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> bool]\n" <>
  "callback \:306f\:5fdc\:7b54\:6587\:5b57\:5217\:3092\:53d7\:3051\:53d6\:308b\:95a2\:6570\:3002nb \:306f\:51fa\:529b\:5148 NotebookObject\:3002\n" <>
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
  "PrivacyLevel: 0.5=\:30af\:30e9\:30a6\:30c9LLM\:53ef, 1.0=\:30ed\:30fc\:30ab\:30eb\:306e\:307f, {0.5,1.0}=\:6df7\:5728(.nb)\:3002\n" <>
  "\:4f8b: NBFileSpec[\"C:\\\\path\\\\file.nb\"]";

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
  "NBMarkCellConfidential[nb, cellIdx] \:306f\:30bb\:30eb\:306b\:6a5f\:5bc6\:30de\:30fc\:30af\:ff08\:8d64\:80cc\:666f + WarningSign\:ff09\:3092\:4ed8\:3051\:308b\:3002";

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

(* ---- \:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb / \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb API ---- *)
NBSetFallbackModels::usage =
  "NBSetFallbackModels[models] \:306f\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:30e2\:30c7\:30eb\:30ea\:30b9\:30c8\:3092\:8a2d\:5b9a\:3059\:308b\:3002\n" <>
  "models: {{\"provider\",\"model\"}, {\"provider\",\"model\",\"url\"}, ...}\n" <>
  "\:4f8b: NBSetFallbackModels[{{\"anthropic\",\"claude-opus-4-6\"},{\"lmstudio\",\"gpt-oss-20b\",\"http://127.0.0.1:1234\"}}]";

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

(* ---- \:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea API ---- *)
NBSetAccessibleDirs::usage =
  "NBSetAccessibleDirs[nb, {dir1, dir2, ...}] \:306f Claude Code \:304c\n" <>
  "\:53c2\:7167\:53ef\:80fd\:306a\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:30ea\:30b9\:30c8\:3092 TaggingRules \:306b\:4fdd\:5b58\:3059\:308b\:3002\n" <>
  "NBSetAccessibleDirs[{dir1, dir2, ...}] \:306f EvaluationNotebook[] \:306b\:4fdd\:5b58\:3059\:308b\:3002";

NBGetAccessibleDirs::usage =
  "NBGetAccessibleDirs[nb] \:306f\:4fdd\:5b58\:3055\:308c\:305f\:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\n" <>
  "NBGetAccessibleDirs[] \:306f EvaluationNotebook[] \:304b\:3089\:53d6\:5f97\:3059\:308b\:3002";


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
  "NBWriteCell[nb, cellExpr, pos] \:306f pos (After/Before/All) \:3092\:6307\:5b9a\:53ef\:80fd\:3002";

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

Begin["`Private`"];

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
  $iFallbackModels = {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}];

(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:5225\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb: \:672a\:767b\:9332\:306f 0.5 *)
If[!AssociationQ[$iProviderMaxAccessLevel],
  $iProviderMaxAccessLevel = <|
    "claudecode" -> 0.5,
    "anthropic"  -> 0.5,
    "openai"     -> 0.5,
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

(* セルスタイルを変更する。Cell 式の第2引数を書き換え、他オプションは保持する。
   SetOptions[cell, CellStyle -> ...] ではセルスタイルは変わらないため、
   Cell 式全体を読み書きする。 *)
NBAccess`NBCellSetStyle[nb_NotebookObject, cellIdx_Integer, newStyle_String] :=
  Module[{cell, cellExpr, newCellExpr},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    cellExpr = Quiet @ NotebookRead[cell];
    newCellExpr = Replace[cellExpr,
      {Cell[content_, _String, rest___] :> Cell[content, newStyle, rest],
       Cell[content_, rest___]          :> Cell[content, newStyle, rest]}];
    NotebookWrite[cell, newCellExpr, All, AutoScroll -> False]];

(* 既存セルにコードを BoxData + Input スタイルで書き込む。
   FEParser で構文カラーリング付き BoxData に変換し、
   Cell 式全体を内容とスタイルで置換する（TaggingRules 等は保持）。 *)
NBAccess`NBCellWriteCode[nb_NotebookObject, cellIdx_Integer, code_String] :=
  Module[{cell, cellExpr, result, box, newContent, newCellExpr},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[$Failed]];
    (* FEParser でコードを BoxData に変換 *)
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
    (* Cell 式全体を読み出し、内容とスタイルを Input に置換 *)
    cellExpr = Quiet @ NotebookRead[cell];
    newCellExpr = Replace[cellExpr,
      {Cell[_, _String, rest___] :> Cell[newContent, "Input", rest],
       Cell[_, rest___]          :> Cell[newContent, "Input", rest],
       _                         :> Cell[newContent, "Input"]}];
    NotebookWrite[cell, newCellExpr, All, AutoScroll -> False]];

(* CellObject を返す。外部パッケージが低レベルのセル参照を必要とする場合に使用。
   指定インデックスが無効な場合は $Failed を返す。 *)
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

NBAccess`NBCellPrivacyLevel[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell, tag, depTag},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[0.0]];
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

Options[NBAccess`NBCellTransformWithLLM] = {Fallback -> False, InputText -> Automatic};

NBAccess`NBCellTransformWithLLM[nb_NotebookObject, cellIdx_Integer,
    promptFn_, completionFn_, opts:OptionsPattern[]] :=
  Module[{text, inputOverride, privLevel, useFallback, prompt, cellTag},
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
          doneFn = completionFn, tag = cellTag},
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
        Fallback -> useFallback]
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

NBAccess`NBMarkCellConfidential[nb_NotebookObject, cellIdx_Integer] := (
  NBAccess`NBSetConfidentialTag[nb, cellIdx, True];
  NBAccess`NBCellSetOptions[nb, cellIdx, Sequence @@ NBAccess`$NBConfidentialCellOpts]
);

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
    cc   = DeleteCases[cc, "dependent" -> _];
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
  Module[{cell, text, matches},
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


(* ============================================================
   API \:30ad\:30fc\:30a2\:30af\:30bb\:30b5\:30fc
   ============================================================ *)

$iAPIKeyMap = <|
  "anthropic"  -> "ANTHROPIC_API_KEY",
  "openai"     -> "OPENAI_API_KEY",
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

NBGetAPIKey::unkn = "\:672a\:77e5\:306e\:30d7\:30ed\:30d0\:30a4\:30c0: `1`\:3002\"anthropic\"\:3001\"openai\"\:3001\"github\" \:306e\:3044\:305a\:308c\:304b\:3092\:6307\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002";
NBGetAPIKey::nokey = "`1` \:306e API \:30ad\:30fc\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002SystemCredential[\"`2`\"] \:3092\:8a2d\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002";


(* ============================================================
   \:30a2\:30af\:30bb\:30b9\:53ef\:80fd\:30c7\:30a3\:30ec\:30af\:30c8\:30ea API
   ============================================================ *)

NBAccess`NBSetAccessibleDirs[nb_NotebookObject, dirs_List] :=
  NBAccess`NBSetTaggingRule[nb, "claudeAccessibleDirs",
    Select[dirs, StringQ[#] && StringLength[#] > 0 &]];

NBAccess`NBSetAccessibleDirs[dirs_List] :=
  NBAccess`NBSetAccessibleDirs[EvaluationNotebook[], dirs];

NBAccess`NBGetAccessibleDirs[nb_NotebookObject] :=
  Module[{val},
    val = NBAccess`NBGetTaggingRule[nb, "claudeAccessibleDirs"];
    If[ListQ[val], val, {}]
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

(* \:30a2\:30f3\:30ab\:30fc\:306e\:76f4\:5f8c\:306b\:30ab\:30fc\:30bd\:30eb\:3092\:79fb\:52d5 *)
NBAccess`NBJobMoveToAnchor[jobId_String] :=
  Module[{entry, nb, cells},
    entry = Lookup[$NBJobTable, jobId, $Failed];
    If[entry === $Failed, Return[$Failed]];
    nb = entry["nb"];
    cells = Quiet[Cells[nb, CellTags -> entry["anchorTag"]]];
    If[ListQ[cells] && Length[cells] > 0,
      Quiet[SelectionMove[First[cells], After, Cell, AutoScroll -> False]]];
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
NBAccess`NBWriteCell[nb_NotebookObject, cellExpr_Cell, where_:After] :=
  Quiet[NotebookWrite[nb, cellExpr, where]];

(* \:901a\:77e5\:7528 Print \:30bb\:30eb\:66f8\:304d\:8fbc\:307f
   CellTags "claudecode-notice" \:3092\:4ed8\:4e0e\:3057\:3066 NBScanDependentCells \:306e\:30de\:30fc\:30ad\:30f3\:30b0\:5bfe\:8c61\:5916\:306b\:3059\:308b *)
NBAccess`NBWritePrintNotice[None, text_String, color_] :=
  CellPrint[Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}]];
NBAccess`NBWritePrintNotice[nb_NotebookObject, text_String, color_] :=
  NotebookWrite[nb, Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}], After];

(* CellPrint ラッパー: 評価セルの直後に出力セルを挿入。
   NotebookWrite と異なりカーソル位置に依存しない。
   ClaudeBackupDataset 等のタグ付き出力セルに使用する。 *)
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
NBAccess`NBFileOpen[path_String] :=
  Module[{nb},
    If[!FileExistsQ[path],
      Message[NBAccess`NBFileOpen::notfound, path]; Return[$Failed]];
    nb = Quiet @ NotebookOpen[path, Visible -> False];
    If[Head[nb] =!= NotebookObject,
      Message[NBAccess`NBFileOpen::openfail, path]; Return[$Failed]];
    nb
  ];
NBAccess`NBFileOpen::notfound = "\:30d5\:30a1\:30a4\:30eb\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: `1`";
NBAccess`NBFileOpen::openfail  = "\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:958b\:3051\:307e\:305b\:3093\:3067\:3057\:305f: `1`";

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBFileClose: \:958b\:3044\:305f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:9589\:3058\:308b
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
NBAccess`NBFileClose[nb_NotebookObject] :=
  Quiet @ NotebookClose[nb];

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

(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:5225\:6700\:5927\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:7ba1\:7406 *)
NBAccess`NBSetProviderMaxAccessLevel[provider_String, level_?NumericQ] :=
  ($iProviderMaxAccessLevel[ToLowerCase[provider]] = Clip[level, {0., 1.}]);

NBAccess`NBGetProviderMaxAccessLevel[provider_String] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5];

(* \:30d7\:30ed\:30d0\:30a4\:30c0\:30fc\:304c\:30a2\:30af\:30bb\:30b9\:30ec\:30d9\:30eb\:306b\:5bfe\:5fdc\:53ef\:80fd\:304b\:5224\:5b9a *)
NBAccess`NBProviderCanAccess[provider_String, accessLevel_?NumericQ] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5] >= accessLevel;

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

(* \:30d5\:30a1\:30a4\:30eb\:306e\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30ec\:30d9\:30eb\:3092\:6c7a\:5b9a\:3059\:308b (pure, \:30d5\:30a1\:30a4\:30eb\:30b7\:30b9\:30c6\:30e0\:60c5\:5831\:3060\:3051\:4f7f\:7528) *)
iNBFilePrivacyLevel[path_String] :=
  Module[{dir, pkgDir, accessDirs, isSafe},
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
    If[baseLevel === 0.5,
      (* $packageDirectory \:5185 .nb \:306f\:5e38\:306b\:30a2\:30af\:30bb\:30b9\:53ef *)
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
      True,                 0.5            (* \:5168\:3066\:516c\:958b \[LongDash] \:30d5\:30a1\:30a4\:30eb\:306f1.0\:3060\:304c\:30bb\:30eb\:304c\:5168\:516c\:958b *)
    ]
  ];

(* \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]
   NBObjectSpec: \:30d5\:30a1\:30a4\:30eb\:307e\:305f\:306f\:5024\:306e\:30e1\:30bf\:60c5\:5831 + PrivacyLevel
   \[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine]\[HorizontalLine] *)
Options[NBAccess`NBFileSpec] = {PrivacySpec -> Automatic};
NBAccess`NBFileSpec[path_String, opts:OptionsPattern[]] :=
  Module[{exists, ext, fsize, privLevel, nb2, allCells,
          nConf = 0, nPublic = 0, nTotal = 0},
    exists = FileExistsQ[path];
    If[!exists,
      Return[<|"Type" -> "File", "Path" -> path, "Exists" -> False,
               "PrivacyLevel" -> 1.0|>]];
    ext   = ToLowerCase[FileExtension[path]];
    fsize = Quiet @ Check[FileByteCount[path], 0];
    (* .nb \:30d5\:30a1\:30a4\:30eb\:306f\:30bb\:30eb\:60c5\:5831\:3082\:53d6\:5f97 *)
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
    <|
      "Type"          -> "File",
      "FileType"      -> If[ext =!= "", ext, "unknown"],
      "Path"          -> path,
      "Exists"        -> True,
      "FileSize"      -> fsize,
      "PrivacyLevel"  -> privLevel,
      (* .nb \:56fa\:6709\:30d5\:30a3\:30fc\:30eb\:30c9 *)
      If[ext === "nb", "CellCount"            -> nTotal,   Nothing],
      If[ext === "nb", "PublicCellCount"       -> nPublic,  Nothing],
      If[ext === "nb", "ConfidentialCellCount" -> nConf,    Nothing]
    |>
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
  Which[
    privacyLevel === 0.5 || privacyLevel == 0.5,
      {"cloud"},                   (* ClaudeCode/API \:306e\:307f *)
    privacyLevel === 1.0 || privacyLevel == 1.0,
      {"local"},                   (* $ClaudePrivateModel \:306e\:307f *)
    ListQ[privacyLevel] && Length[privacyLevel] == 2,
      {"cloud", "local"},          (* \:4e26\:52172\:30ce\:30fc\:30c9 *)
    True,
      {"cloud"}
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


End[];
EndPackage[];
