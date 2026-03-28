---

Notebook[{

Cell[CellGroupData[{

Cell["NBAccess ユーザーマニュアル", "Title"],

Cell["NBAccess は、Wolfram Language / Mathematica ノートブックに対してセルインデックスベースの読み書き・プライバシーフィルタリング・LLM 連携・履歴管理などの機能を提供するユーティリティパッケージです。本マニュアルでは主要な機能と API の使い方を説明します。", "Text"],

Cell[CellGroupData[{

Cell["概要", "Section"],

Cell["NBAccess パッケージは以下の機能グループで構成されています。", "Text"],

Cell["\:2022 セルユーティリティ API — セルの読み書き・スタイル取得・タグ操作\n\:2022 プライバシー API — セルのアクセスレベル判定とフィルタリング\n\:2022 LLM 連携 API — 非同期 LLM 呼び出しとセル変換\n\:2022 TaggingRules API — ノートブック・セルへのメタデータ永続化\n\:2022 履歴データベース API — 会話履歴の差分圧縮保存\n\:2022 依存グラフ API — 変数依存関係の解析とマーキング\n\:2022 ファイル型ノートブック操作 API — 非表示ノートブックの読み書き\n\:2022 Job 管理 API — 非同期出力スロットの管理", "Text"]

}, Open]],

Cell[CellGroupData[{

Cell["TaggingRules について", "Section"],

Cell[CellGroupData[{

Cell["TaggingRules とは何か", "Subsection"],

Cell["TaggingRules は Mathematica の標準オプションの一つで、ノートブックおよび個々のセルに対して任意のメタデータを添付するための仕組みです。値にはルールのリスト（または Association）を指定でき、保存時にも維持されるため、永続的なメタデータストアとして機能します。", "Text"],

Cell["Mathematica の標準的な使い方では、TaggingRules を直接 SetOptions で操作しますが、NBAccess はより高水準で安全な API を提供しています。", "Text"],

Cell["\:2022 評価されない — TaggingRules の値は Mathematica によって評価されず、純粋なデータとして保存されます。\n\:2022 永続化される — ノートブックを保存すると TaggingRules も保存されます。再度開いたときも値が維持されます。\n\:2022 ネスト可能 — Association を使ってキーを階層的に管理できます。\n\:2022 ノートブックとセルの両方に付与可能 — ノートブック全体に対するメタデータと、セル単位のメタデータを独立して管理できます。", "Text"],

Cell["標準的な Mathematica での直接操作例（NBAccess を使わない場合）:", "Text"],

Cell["(* ノートブックの TaggingRules を直接読む *)\nCurrentValue[EvaluationNotebook[], TaggingRules]\n\n(* セルの TaggingRules を設定する *)\nSetOptions[cellObj, TaggingRules -> {\"mykey\" -> \"myvalue\"}]", "Code"],

Cell["NBAccess では、これらの低水準操作を直接行う代わりに、後述する NBGetTaggingRule / NBSetTaggingRule 等の API を使用してください。", "Text"]

}, Open]],

Cell[CellGroupData[{

Cell["NBAccess における TaggingRules の用途", "Subsection"],

Cell["NBAccess は TaggingRules を以下の目的で活用しています。", "Text"],

Cell[CellGroupData[{

Cell["ノートブックレベルのメタデータ", "Subsubsection"],

Cell["\:2022 会話履歴の保存 — ClaudeCode との会話履歴（NBHistoryData 系 API）は、ノートブックの TaggingRules に差分圧縮形式で保存されます。\n\:2022 アクセス可能ディレクトリの設定 — Claude Code がアクセス可能なディレクトリの一覧（NBSetAccessibleDirs / NBGetAccessibleDirs）を TaggingRules に保存します。\n\:2022 フォールバックモデルの設定 — LLM フォールバックモデルの一覧（NBSetFallbackModels 等）もノートブックの TaggingRules に保存できます。", "Text"]

}, Open]],

Cell[CellGroupData[{

Cell["セルレベルのメタデータ", "Subsubsection"],

Cell["\:2022 機密マーク — セルが Confidential（機密）であることを示すフラグ（{\"claudecode\", \"confidential\"}）が、セルの TaggingRules に保存されます。\n\:2022 依存機密マーク — セルが機密変数に間接依存していることを示すフラグ（{\"claudecode\", \"dependent\"}）もセルの TaggingRules に保存されます。\n\:2022 任意のメタデータ — NBCellSetTaggingRule を使って任意のキー・値ペアをセルに付与できます。", "Text"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["ノートブックレベル TaggingRules API", "Subsection"],

Cell["以下の API でノートブック全体に対するメタデータを操作できます。", "Text"],

Cell[CellGroupData[{

Cell["NBGetTaggingRule — 値の読み取り", "Subsubsection"],

Cell["NBGetTaggingRule[nb, key] は、ノートブック nb の TaggingRules から key に対応する値を返します。キーが存在しない場合は Missing[] を返します。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* 単一キーの読み取り *)\nNBGetTaggingRule[nb, \"mykey\"]\n(* => \"myvalue\" または Missing[] *)\n\n(* ネストしたキーパスの読み取り *)\nNBGetTaggingRule[nb, {\"claudecode\", \"history\", \"session1\"}]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBSetTaggingRule — 値の設定", "Subsubsection"],

Cell["NBSetTaggingRule[nb, key, value] は、ノートブック nb の TaggingRules に key -> value を設定します。既存のキーがある場合は上書きします。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* 単一キーの設定 *)\nNBSetTaggingRule[nb, \"mykey\", \"myvalue\"]\n\n(* ネストしたキーパスの設定 *)\nNBSetTaggingRule[nb, {\"session\", \"created\"}, DateString[]]\n\n(* Association を値として設定 *)\nNBSetTaggingRule[nb, \"config\", <|\"maxTokens\" -> 4096, \"model\" -> \"claude-opus-4-6\"|>]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBDeleteTaggingRule — キーの削除", "Subsubsection"],

Cell["NBDeleteTaggingRule[nb, key] は、ノートブック nb の TaggingRules から key を削除します。", "Text"],

Cell["nb = EvaluationNotebook[];\nNBDeleteTaggingRule[nb, \"mykey\"]\nNBDeleteTaggingRule[nb, {\"session\", \"created\"}]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBListTaggingRuleKeys — キー一覧の取得", "Subsubsection"],

Cell["NBListTaggingRuleKeys[nb] は、ノートブック nb の TaggingRules の全トップレベルキーを返します。NBListTaggingRuleKeys[nb, prefix] は prefix で始まるキーのみ返します。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* 全キー一覧 *)\nNBListTaggingRuleKeys[nb]\n(* => {\"claudecode\", \"config\", \"history_session1\", ...} *)\n\n(* \"history_\" で始まるキーのみ *)\nNBListTaggingRuleKeys[nb, \"history_\"]", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["セルレベル TaggingRules API", "Subsection"],

Cell["以下の API で個々のセルに対するメタデータを操作できます。", "Text"],

Cell[CellGroupData[{

Cell["NBCellGetTaggingRule — セルの TaggingRules 読み取り", "Subsubsection"],

Cell["NBCellGetTaggingRule[nb, cellIdx, path] は、セル cellIdx の TaggingRules からネストしたパス path の値を返します。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* セル 3 の機密フラグを読む *)\nNBCellGetTaggingRule[nb, 3, {\"claudecode\", \"confidential\"}]\n(* => True または Missing[] *)\n\n(* 任意のメタデータを読む *)\nNBCellGetTaggingRule[nb, 5, {\"documentation\", \"note\"}]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBCellSetTaggingRule — セルの TaggingRules 書き込み", "Subsubsection"],

Cell["NBCellSetTaggingRule[nb, cellIdx, path, value] は、セル cellIdx の TaggingRules のネストしたパス path に value を設定します。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* セル 3 にメモを記録する *)\nNBCellSetTaggingRule[nb, 3, {\"documentation\", \"idea\"}, \"\u5143\u306e\u30a2\u30a4\u30c7\u30a2\"]\n\n(* セル 5 にレビュー済みフラグを付与する *)\nNBCellSetTaggingRule[nb, 5, {\"review\", \"done\"}, True]", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["TaggingRules-Reference — 内部キー構造", "Subsection"],

Cell["NBAccess が内部的に使用する TaggingRules のキー構造を以下に示します。", "Text"],

Cell[CellGroupData[{

Cell["ノートブックレベルのキー", "Subsubsection"],

Cell["TaggingRules の最上位キーはすべて文字列です。NBAccess が使用する標準的なキーは以下の通りです。", "Text"],

Cell["\:2022 \"claudecode\" — ClaudeCode パッケージが使用するメタデータの名前空間。値は Association。\n    \:2022 \"history\" — 会話履歴データ（NBHistoryData 系 API が管理）。\n    \:2022 \"accessibleDirs\" — Claude Code がアクセス可能なディレクトリのリスト（NBSetAccessibleDirs が管理）。\n    \:2022 \"fallbackModels\" — フォールバック LLM モデルのリスト（NBSetFallbackModels が管理）。\n    \:2022 \"providerMaxAccessLevel\" — プロバイダーごとの最大アクセスレベル（NBSetProviderMaxAccessLevel が管理）。", "Text"],

Cell["NBAccess が管理するノートブックレベル TaggingRules の典型的な構造は次のようになります。", "Text"],

Cell["TaggingRules -> {\n  \"claudecode\" -> <|\n    \"accessibleDirs\" -> {\n      \"C:\\\\Users\\\\username\\\\Documents\",\n      \"C:\\\\projects\\\\myproject\"\n    },\n    \"fallbackModels\" -> {\n      {\"anthropic\", \"claude-opus-4-6\"},\n      {\"lmstudio\", \"local-model\", \"http://127.0.0.1:1234\"}\n    },\n    \"providerMaxAccessLevel\" -> <|\n      \"anthropic\" -> 0.5,\n      \"lmstudio\" -> 1.0\n    |>\n  |>,\n  \"history_session_abc123\" -> <|\n    \"header\" -> <|\"created\" -> \"2026-03-01\", \"diffFields\" -> {\"fullPrompt\",\"response\"}|>,\n    \"entries\" -> { ... (* \u5dee\u5206\u5727\u7e2e\u30a8\u30f3\u30c8\u30ea *) }\n  |>\n}", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["セルレベルのキー", "Subsubsection"],

Cell["セル単位の TaggingRules では、{\"claudecode\", ...} というパスが NBAccess によって予約されています。", "Text"],

Cell["\:2022 {\"claudecode\", \"confidential\"} — True のとき、そのセルは Confidential（機密）としてマークされています。NBMarkCellConfidential / NBGetConfidentialTag / NBSetConfidentialTag が読み書きします。\n\:2022 {\"claudecode\", \"dependent\"} — True のとき、そのセルは機密変数への依存セル（Dependent）としてマークされています。NBMarkCellDependent が書き込みます。\n\:2022 その他のパス — NBCellGetTaggingRule / NBCellSetTaggingRule で任意のメタデータを自由に格納できます。", "Text"],

Cell["セルの TaggingRules の典型的な構造は次のようになります。", "Text"],

Cell["(* 機密セルのオプション例 *)\nCell[\n  \"privateData = Import[...]\",\n  \"Input\",\n  TaggingRules -> {\n    \"claudecode\" -> <|\n      \"confidential\" -> True\n    |>\n  },\n  Background -> RGBColor[1, 0.9, 0.9]\n]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["履歴データの構造", "Subsubsection"],

Cell["NBAccess の履歴 API（NBHistoryData 系）は、会話履歴を TaggingRules に差分圧縮形式で保存します。一般ユーザーは NBHistoryData 等の高水準 API を通じて操作するため、内部構造を直接意識する必要はありませんが、参考として以下に示します。", "Text"],

Cell["(*\n  ノートブックの TaggingRules に保存される履歴データ構造:\n  タグ = \"history_\" <> sessionId\n\n  <|\n    \"header\" -> <|\n      \"created\"   -> \"2026-03-01T10:00:00\",\n      \"diffFields\" -> {\"fullPrompt\", \"response\", \"code\"},\n      \"parent\"     -> Missing[] (* \u89aa\u30bb\u30c3\u30b7\u30e7\u30f3\u304c\u3042\u308c\u3070 sessionId *),\n      \"inherit\"    -> False,\n      \"attachments\" -> {}\n    |>,\n    \"entries\" -> {\n      (* \u5404\u30a8\u30f3\u30c8\u30ea\u306f\u5dee\u5206\u5727\u7e2e\u3055\u308c\u3066\u3044\u308b *)\n      <|\n        \"role\"        -> \"user\",\n        \"fullPrompt\"  -> (* Diff\u30aa\u30d6\u30b8\u30a7\u30af\u30c8 *),\n        \"response\"    -> (* Diff\u30aa\u30d6\u30b8\u30a7\u30af\u30c8 *),\n        \"code\"        -> (* Diff\u30aa\u30d6\u30b8\u30a7\u30af\u30c8 *),\n        \"timestamp\"   -> \"2026-03-01T10:05:00\",\n        \"privacyLevel\" -> 0.5\n      |>,\n      ...\n    }\n  |>\n*)", "Code"],

Cell["差分圧縮（Diff）は、連続するエントリ間でテキストの重複部分を除去することで TaggingRules のサイズを最小化します。NBHistoryEntries 等を呼び出すと自動的に復元されます。", "Text"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["TaggingRules を直接操作しないための注意事項", "Subsection"],

Cell["TaggingRules は Mathematica の低水準オプションであるため、直接操作すると既存の値を上書きしてしまう危険があります。NBAccess は以下のルールに従って安全に操作しています。", "Text"],

Cell["\:2022 マージ更新 — NBSetTaggingRule は既存の TaggingRules 全体を上書きするのではなく、指定したキーのみを更新します。他のキーの値は保持されます。\n\:2022 ネストされた Association の部分更新 — {key1, key2, ...} というパス指定により、深いネストレベルの値だけを変更できます。\n\:2022 Missing[] の扱い — 存在しないキーへのアクセスは Missing[] を返します（エラーにはなりません）。\n\:2022 外部パッケージとの共存 — \"claudecode\" 名前空間以外のキーは NBAccess によって変更されないため、他のパッケージが使用している TaggingRules と共存できます。", "Text"],

Cell["(* \u30c0\u30e1\u306a\u4f8b: TaggingRules \u5168\u4f53\u3092\u4e0a\u66f8\u304d *)\n(* SetOptions[nb, TaggingRules -> {\"newkey\" -> \"val\"}]  <- \u65e2\u5b58\u306e\u5168\u30ad\u30fc\u304c\u6d88\u3048\u308b *)\n\n(* \u826f\u3044\u4f8b: NBAccess API \u3067\u90e8\u5206\u66f8\u304d\u8fbc\u307f *)\nnb = EvaluationNotebook[];\nNBSetTaggingRule[nb, \"newkey\", \"val\"]  (* \u65e2\u5b58\u30ad\u30fc\u306f\u4fdd\u6301\u3055\u308c\u308b *)", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["プライバシー API", "Section"],

Cell["NBAccess はセルのプライバシーレベルを 0.0〜1.0 の実数で管理します。", "Text"],

Cell["\:2022 0.0 — 非機密（クラウド LLM に送信可能）\n\:2022 0.5 — クラウド LLM 安全なデータのみ（デフォルト）\n\:2022 1.0 — 機密（ローカル LLM のみ）", "Text"],

Cell[CellGroupData[{

Cell["NBCellPrivacyLevel", "Subsection"],

Cell["NBCellPrivacyLevel[nb, cellIdx] は、セルのプライバシーレベルを返します。Confidential マークまたは機密変数参照によって決まります。", "Text"],

Cell["nb = EvaluationNotebook[];\nNBCellPrivacyLevel[nb, 3]\n(* => 0.0 (\u975e\u6a5f\u5bc6), 0.5 (\u4e2d\u9593), 1.0 (\u6a5f\u5bc6) *)", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBIsAccessible / NBFilterCellIndices", "Subsection"],

Cell["NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] は、指定 PrivacySpec でセルにアクセス可能かどうかを返します。", "Text"],

Cell["nb = EvaluationNotebook[];\nps = <|\"AccessLevel\" -> 0.5|>;\n\n(* \u6307\u5b9a\u30bb\u30eb\u304c\u30a2\u30af\u30bb\u30b9\u53ef\u80fd\u304b\u5224\u5b9a *)\nNBIsAccessible[nb, 3, PrivacySpec -> ps]\n\n(* \u30bb\u30eb\u30a4\u30f3\u30c7\u30c3\u30af\u30b9\u30ea\u30b9\u30c8\u3092\u30d5\u30a3\u30eb\u30bf\u30ea\u30f3\u30b0 *)\nNBFilterCellIndices[nb, Range[10], PrivacySpec -> ps]", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["履歴データベース API", "Section"],

Cell["ClaudeCode との会話履歴は、NBAccess の履歴 API を通じてノートブックの TaggingRules に保存されます。", "Text"],

Cell[CellGroupData[{

Cell["基本的な使い方", "Subsection"],

Cell["nb = EvaluationNotebook[];\ntag = \"my_session\";\n\n(* \u65b0\u3057\u3044\u5c65\u6b74 DB \u306e\u4f5c\u6210 *)\nNBHistoryCreate[nb, tag, {\"fullPrompt\", \"response\", \"code\"}]\n\n(* \u30a8\u30f3\u30c8\u30ea\u306e\u8ffd\u52a0 *)\nNBHistoryAppend[nb, tag, <|\n  \"role\" -> \"user\",\n  \"fullPrompt\" -> \"\u8cea\u554f\u5185\u5bb9\",\n  \"response\" -> \"LLM \u306e\u5fdc\u7b54\",\n  \"code\" -> \"result = 42\"\n|>]\n\n(* \u5c65\u6b74\u306e\u8aad\u307f\u51fa\u3057 *)\nNBHistoryEntries[nb, tag]\n\n(* \u5c65\u6b74\u306e\u524a\u9664 *)\nNBHistoryDelete[nb, tag]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["タグ一覧の取得と全削除", "Subsection"],

Cell["nb = EvaluationNotebook[];\n\n(* \"history_\" \u3067\u59cb\u307e\u308b\u30bf\u30b0\u4e00\u89a7 *)\nNBHistoryListTags[nb, \"history_\"]\n\n(* \u5168\u5c65\u6b74\u3092\u524a\u9664\uff08\u30ce\u30fc\u30c8\u30d6\u30c3\u30af\u3092\u4ed6\u8005\u306b\u6e21\u3059\u524d\u306e\u30af\u30ea\u30fc\u30f3\u30a2\u30c3\u30d7\u306b\u4f7f\u7528\uff09 *)\nNBHistoryClearAll[nb, \"history_\", PrivacySpec -> <|\"AccessLevel\" -> 1.0|>]", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["セルマーク API", "Section"],

Cell["セルに機密マークや依存マークを付与・解除する API です。", "Text"],

Cell[CellGroupData[{

Cell["NBMarkCellConfidential / NBMarkCellDependent / NBUnmarkCell", "Subsection"],

Cell["nb = EvaluationNotebook[];\n\n(* \u6a5f\u5bc6\u30de\u30fc\u30af\uff08\u8d64\u80cc\u666f + WarningSign\uff09 *)\nNBMarkCellConfidential[nb, 3]\n\n(* \u4f9d\u5b58\u6a5f\u5bc6\u30de\u30fc\u30af\uff08\u6a59\u80cc\u666f + LockIcon\uff09 *)\nNBMarkCellDependent[nb, 5]\n\n(* \u30de\u30fc\u30af\u89e3\u9664 *)\nNBUnmarkCell[nb, 3]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["NBGetConfidentialTag / NBSetConfidentialTag", "Subsection"],

Cell["TaggingRules に保存された機密タグを直接読み書きする低水準 API です。通常は NBMarkCellConfidential の使用を推奨します。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* TaggingRules \u304b\u3089\u6a5f\u5bc6\u30bf\u30b0\u3092\u8aad\u3080: True/False/Missing[] *)\nNBGetConfidentialTag[nb, 3]\n\n(* TaggingRules \u306b\u6a5f\u5bc6\u30bf\u30b0\u3092\u66f8\u304d\u8fbc\u3080 *)\nNBSetConfidentialTag[nb, 3, True]", "Code"]

}, Open]]

}, Open]],

Cell[CellGroupData[{

Cell["依存グラフ API", "Section"],

Cell["機密変数に依存するセルを自動検出してマーキングする API です。", "Text"],

Cell["nb = EvaluationNotebook[];\n\n(* \u9ad8\u901f\u7248: \u5f53\u8a72\u30ce\u30fc\u30c8\u30d6\u30c3\u30af\u306e\u307f *)\ndeps = NBBuildVarDependencies[nb]\n\n(* \u6a5f\u5bc6\u5909\u6570\u540d\u30ea\u30b9\u30c8\u3092\u53d6\u5f97 *)\nconfVars = Keys[$NBConfidentialSymbols]\n\n(* \u4f9d\u5b58\u30b0\u30e9\u30d5\u3092\u4f7f\u3063\u3066\u4f9d\u5b58\u30bb\u30eb\u306b\u81ea\u52d5\u30de\u30fc\u30af *)\nNBScanDependentCells[nb, confVars, deps]\n\n(* \u4f9d\u5b58\u30b0\u30e9\u30d5\u306e\u53ef\u8996\u5316 *)\nNBPlotDependencyGraph[nb, \"Scope\" -> \"Local\"]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["ファイル型ノートブック操作 API", "Section"],

Cell["閉じた .nb ファイルを非表示で開いて読み書きする API です。翻訳・バッチ処理などに使用します。", "Text"],

Cell["(* \u975e\u8868\u793a\u3067\u958b\u304f *)\nnb2 = NBFileOpen[FileNameJoin[{Quiet @ Check[NotebookDirectory[], $packageDirectory], \"target.nb\"}]]\n\n(* \u30bb\u30eb\u3092\u8aad\u3080 *)\ncells = NBFileReadCells[nb2, PrivacySpec -> <|\"AccessLevel\" -> 0.5|>]\n\n(* \u30bb\u30eb\u3092\u66f8\u304d\u8fbc\u3080 *)\nNBFileWriteCell[nb2, 3, \"\u65b0\u3057\u3044\u5185\u5bb9\"]\n\n(* \u4fdd\u5b58 *)\nNBFileSave[nb2, None]\n\n(* \u9589\u3058\u308b *)\nNBFileClose[nb2]", "Code"]

}, Open]],

Cell[CellGroupData[{

Cell["グローバル変数", "Section"],

Cell["\:2022 $NBPrivacySpec — デフォルトの PrivacySpec。初期値は <|\"AccessLevel\" -> 0.5|>。ローカル LLM 環境では <|\"AccessLevel\" -> 1.0|> に変更してください。\n\:2022 $NBConfidentialSymbols — 機密変数名とプライバシーレベルのテーブル。ClaudeCode パッケージが自動管理します。\n\:2022 $NBVerbose — True にすると NBAccess 内部の詳細ログを Messages に出力します。\n\:2022 $NBAutoEvalProhibitedPatterns — NBEvaluatePreviousCell で自動実行をブロックするパターンのリスト。\n\:2022 $NBSendDataSchema — True（デフォルト）のとき、機密依存 Output でもデータ型・サイズ等のスキーマ情報をクラウド LLM に送信します。\n\:2022 $NBSeparationIgnoreList — ClaudeCheckSeparation の検査対象外にするパッケージ名のリスト。", "Text"]

}, Open]],

Cell[CellGroupData[{

Cell["関連リンク", "Section"],

Cell["\:2022 GitHub リポジトリ: https://github.com/transreal/NBAccess\n\:2022 ClaudeCode パッケージ: https://github.com/transreal/claudecode\n\:2022 NotebookExtensions パッケージ: https://github.com/transreal/NotebookExtensions", "Text"]

}, Open]]

}, Open]]

}]