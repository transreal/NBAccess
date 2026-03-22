(* NBAccess.wl -- Notebook Access Utility Package
   This file is encoded in UTF-8.
   Load via: Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
   Or use claudecode.wl which handles encoding automatically. *)

(* ============================================================
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30a2\:30af\:30bb\:30b9\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3\:30d1\:30c3\:30b1\:30fc\:30b8
   \:30bb\:30eb\:30a4\:30f3\:30c7\:30c3\:30af\:30b9\:30d9\:30fc\:30b9\:3067\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8aad\:307f\:66f8\:304d\:3068\:30d7\:30e9\:30a4\:30d0\:30b7\:30fc\:30d5\:30a3\:30eb\:30bf\:30ea\:30f3\:30b0\:3092\:63d0\:4f9b\:3059\:308b\:3002
   ============================================================ *)

BeginPackage["NBAccess`"];

(* ---- オプション名 ---- *)
(* Decompress: NBAccess 履歴関数のオプション。
   True (ディフォルト): Diff 差分を復元して平文で返す。
   False: Diff オブジェクトのまま返す (差分検査用)。
   注: System`Decompress をオプションラベルとして使用 (シンボルの新規定義はしない)。 *)

PrivacySpec::usage =
  "PrivacySpec は NBAccess 関数のプライバシーフィルタリングオプション。\n" <>
  "例: PrivacySpec -> <|\"AccessLevel\" -> 0.5|>\n" <>
  "  AccessLevel \[LessEqual] セルのプライバシーレベル のセルのみアクセス可能。\n" <>
  "  0.5: クラウドLLM安全なデータのみ (ディフォルト)\n" <>
  "  1.0: ローカルLLM環境などすべてのデータ";

(* ---- グローバル変数 ---- *)
$NBPrivacySpec::usage =
  "$NBPrivacySpec は NBAccess 関数のディフォルト PrivacySpec。\n" <>
  "初期値: <|\"AccessLevel\" -> 0.5|> (クラウドLLM安全なデータのみ)。\n" <>
  "ローカルLLM環境から利用する場合: $NBPrivacySpec = <|\"AccessLevel\" -> 1.0|>";

$NBConfidentialSymbols::usage =
  "$NBConfidentialSymbols は秘密変数名とプライバシーレベルのテーブル。\n" <>
  "<|\"変数名\" -> privacyLevel, ...|> の形式。\n" <>
  "ClaudeCode パッケージが自動的に更新する。";

$NBSendDataSchema::usage =
  "$NBSendDataSchema は秘密依存データのスキーマ情報をクラウドLLMに送信するかを制御する。\n" <>
  "True (ディフォルト): 秘密依存 Output でもデータ型・サイズ・キー等のスキーマ情報を送信する。\n" <>
  "False: 秘密依存 Output のスキーマ情報を一切送信しない。\n" <>
  "非秘密 Output は常にスマート要約付きで送信される。";

(* ---- セルユーティリティ API (新規) ---- *)
NBCellCount::usage =
  "NBCellCount[nb] はノートブックの全セル数を返す。";
NBCurrentCellIndex::usage =
  "NBCurrentCellIndex[nb] は EvaluationCell[] のセルインデックスを返す。\n" <>
  "見つからない場合は 0 を返す。";
NBSelectedCellIndices::usage =
  "NBSelectedCellIndices[nb] は選択中セルのインデックスリストを返す。\n" <>
  "セルブラケット選択またはカーソル位置のセルを返す。";
NBCellIndicesByTag::usage =
  "NBCellIndicesByTag[nb, tag] は指定 CellTags を持つセルのインデックスリストを返す。";
NBCellIndicesByStyle::usage =
  "NBCellIndicesByStyle[nb, style] は指定 CellStyle のセルのインデックスリストを返す。\n" <>
  "NBCellIndicesByStyle[nb, {style1, style2, ...}] は複数スタイルを指定可能。";
NBDeleteCellsByTag::usage =
  "NBDeleteCellsByTag[nb, tag] は指定 CellTags を持つセルを全て削除する。";
NBMoveAfterCell::usage =
  "NBMoveAfterCell[nb, cellIdx] はセルの後ろにカーソルを移動する。";
NBCellRead::usage =
  "NBCellRead[nb, cellIdx] は NotebookRead で Cell 式を返す。";
NBCellReadInputText::usage =
  "NBCellReadInputText[nb, cellIdx] は FrontEnd 経由で InputText 形式を取得する。\n" <>
  "失敗時は NBCellExprToText にフォールバック。";
NBCellStyle::usage =
  "NBCellStyle[nb, cellIdx] はセルの CellStyle を返す。";
NBCellLabel::usage =
  "NBCellLabel[nb, cellIdx] はセルの CellLabel (例: \"In[3]:=\") を返す。\n" <>
  "ラベルなしの場合は \"\" を返す。";
NBCellSetOptions::usage =
  "NBCellSetOptions[nb, cellIdx, opts] はセルに SetOptions を適用する。";
NBCellGetTaggingRule::usage =
  "NBCellGetTaggingRule[nb, cellIdx, path] は TaggingRules のネスト値を返す。\n" <>
  "例: NBCellGetTaggingRule[nb, 3, {\"claudecode\", \"confidential\"}]";
NBCellRasterize::usage =
  "NBCellRasterize[nb, cellIdx, file, opts] はセルを Rasterize して file に保存する。";

NBCellHasImage::usage =
  "NBCellHasImage[cellExpr] は Cell 式が画像 (RasterBox/GraphicsBox) を含むか判定する。\n" <>
  "cellExpr は NBCellRead の戻り値を想定。";

(* ---- プライバシー API ---- *)
NBCellPrivacyLevel::usage =
  "NBCellPrivacyLevel[nb, cellIdx] はセルのプライバシーレベル (0.0〜1.0) を返す。\n" <>
  "0.0: 非秘密, 1.0: 秘密 (Confidentialマーク or 秘密変数参照)";

NBIsAccessible::usage =
  "NBIsAccessible[nb, cellIdx, PrivacySpec -> ps] はセルが指定の\n" <>
  "PrivacySpec でアクセス可能かどうかを返す (True/False)。";

NBFilterCellIndices::usage =
  "NBFilterCellIndices[nb, indices, PrivacySpec -> ps] はセルインデックスリストを\n" <>
  "PrivacySpec でフィルタリングして返す。";

(* ---- テキスト抽出 API ---- *)
NBCellExprToText::usage =
  "NBCellExprToText[cellExpr] は NotebookRead の結果 (Cell式) から\n" <>
  "テキストを抽出する。";

NBCellToText::usage =
  "NBCellToText[nb, cellIdx] はセルのテキスト内容を返す。";

NBGetCells::usage =
  "NBGetCells[nb, PrivacySpec -> ps] はノートブック内の全セルインデックスを\n" <>
  "PrivacySpec でフィルタリングして返す。";

NBGetContext::usage =
  "NBGetContext[nb, afterIdx, PrivacySpec -> ps] はノートブック内の\n" <>
  "afterIdx 番目以降のセルから LLM プロンプト用コンテキスト文字列を構築する。\n" <>
  "PrivacySpec でフィルタリングされる。ディフォルト: AccessLevel 0.5。";

(* ---- 書き込み API ---- *)
NBWriteText::usage =
  "NBWriteText[nb, text, style] はノートブックにテキストセルを書き込む。\n" <>
  "style のディフォルトは \"Text\"。";

NBWriteCode::usage =
  "NBWriteCode[nb, code] は構文カラーリング付き Input セルを書き込む。";

NBWriteSmartCode::usage =
  "NBWriteSmartCode[nb, code] は CellPrint[] パターンを自動検出して\n" <>
  "スマートにセルを書き込む。";

NBWriteInputCellAndMaybeEvaluate::usage =
  "NBWriteInputCellAndMaybeEvaluate[nb, boxes, autoEvaluate] は\n" <>
  "現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動する。\n" <>
  "autoEvaluate が True の場合はさらに SelectionEvaluate を行う。";

NBInsertTextCells::usage =
  "NBInsertTextCells[nbFile, name, prompt] は .nb ファイルを非表示で開き、\n" <>
  "末尾に Subsection セル (name) と Text セル (prompt) を挿入して保存・閉じる。";

(* ---- セルマーク API ---- *)
NBGetConfidentialTag::usage =
  "NBGetConfidentialTag[nb, cellIdx] は TaggingRules から機密タグを返す: True/False/Missing[]。";

NBSetConfidentialTag::usage =
  "NBSetConfidentialTag[nb, cellIdx, val] はセルの機密タグを val (True/False) に設定する。";

NBMarkCellConfidential::usage =
  "NBMarkCellConfidential[nb, cellIdx] はセルに機密マーク（赤背景 + WarningSign）を付ける。";

NBMarkCellDependent::usage =
  "NBMarkCellDependent[nb, cellIdx] はセルに依存機密マーク（橙背景 + LockIcon）を付ける。\n" <>
  "機密変数に依存する計算結果など、間接的に機密なセルに使用する。";

NBUnmarkCell::usage =
  "NBUnmarkCell[nb, cellIdx] はセルの機密マーク（視覚・タグ）をすべて解除する。";

(* ---- セル内容分析 API (claudecodeから移設) ---- *)
NBCellUsesConfidentialSymbol::usage =
  "NBCellUsesConfidentialSymbol[nb, cellIdx] はセルが機密変数を参照しているかを返す。";

NBCellExtractVarNames::usage =
  "NBCellExtractVarNames[nb, cellIdx] はセル内容から Set/SetDelayed の LHS 変数名を抽出する。";

NBCellExtractAssignedNames::usage =
  "NBCellExtractAssignedNames[nb, cellIdx] はセル内容から Confidential[] 内の代入先変数名を抽出する。";

NBShouldExcludeFromPrompt::usage =
  "NBShouldExcludeFromPrompt[nb, cellIdx] はセルがプロンプトから除外すべきかを返す。";

NBIsClaudeFunctionCell::usage =
  "NBIsClaudeFunctionCell[nb, cellIdx] はセルが Claude 関数呼び出しセルかを返す。";

(* ---- 依存グラフ API ---- *)
NBAccess`iCellToInputText::usage =
  "iCellToInputText[cell] は FrontEnd経由でセルの InputText形式を取得する。"
  "失敗時は NBCellExprToText にフォールバック。";

NBBuildVarDependencies::usage =
  "NBBuildVarDependencies[nb] はノートブックのInputセルを解析して\n" <>
  "変数依存関係グラフ <|\"var\" -> {\"dep1\",...}|> を返す。\n" <>
  "文字列リテラル内の識別子は除外される。";

NBBuildGlobalVarDependencies::usage =
  "NBBuildGlobalVarDependencies[] は Notebooks[] 全体の Input セルを走査して\n" <>
  "統合された変数依存関係グラフ <|\"var\" -> {\"dep1\",...}|> を返す。\n" <>
  "LLM 呼び出し直前の精密チェックで使用する。\n" <>
  "通常のセル実行時は軽量版 NBBuildVarDependencies[nb] を使用すること。";

NBUpdateGlobalVarDependencies::usage =
  "NBUpdateGlobalVarDependencies[existingDeps, afterLine] は既存の依存グラフに\n" <>
  "CellLabel In[x] (x > afterLine) のセルのみを追加走査してマージする。\n" <>
  "返り値は {updatedDeps, newLastLine}。\n" <>
  "完全なグラフを毎回構築するコストを回避するインクリメンタル版。";

NBTransitiveDependents::usage =
  "NBTransitiveDependents[deps, confVars] は deps グラフ上で\n" <>
  "confVars に直接・間接依存する全変数名リストを返す。";

NBScanDependentCells::usage =
  "NBScanDependentCells[nb, confVarNames] は依存グラフを使って機密変数に依存するセルに\n" <>
  "NBMarkCellDependent を適用し、新たにマークしたセル数を返す。\n" <>
  "NBScanDependentCells[nb, confVarNames, deps] は事前計算済みの依存グラフ deps を使う（二重計算回避）。\n" <>
  "Claude関数呼び出しセル (ClaudeQuery 等) は除外される。";

NBFilterHistoryEntry::usage =
  "NBFilterHistoryEntry[entry, confVars] は履歴エントリ内の response/instruction に現時点の機密変数名または値が含まれる場合に\n" <>
  "そのフィールドをブロックする。confVars は現在の機密変数名リスト。";

NBDependencyEdges::usage =
  "NBDependencyEdges[nb] はノートブックの変数依存関係をエッジリストで返す。\n" <>
  "戻り値: {DirectedEdge[\"dep\", \"var\"], ...}\n" <>
  "\"dep\" → \"var\" は \"var が dep に依存する\" を意味する。\n" <>
  "NBDependencyEdges[nb, confVars] は機密変数 confVars に関連するエッジのみ返す。";

NBDebugDependencies::usage =
  "NBDebugDependencies[nb, confVars] は依存グラフ・推移依存・セルテキストを Print で表示するデバッグ関数。\n" <>
  "各 Input セルについて InputText 取得結果、代入解析結果、依存判定結果を出力する。";

NBPlotDependencyGraph::usage =
  "NBPlotDependencyGraph[] は全ノートブック統合の依存グラフをプロットする (デフォルト)。\n" <>
  "NBPlotDependencyGraph[nb] は指定ノートブックの依存グラフをプロットする。\n" <>
  "ノードは変数名・Out[n]で、直接秘密は赤、依存秘密は橙で着色。\n" <>
  "NB内エッジは濃い実線、クロスNBエッジは薄い破線で描画。\n" <>
  "オプション:\n" <>
  "  \"Scope\" -> \"Global\" (デフォルト) | \"Local\"\n" <>
  "  PrivacySpec -> <|\"AccessLevel\" -> 1.0|> で表示範囲を制御。\n" <>
  "例: NBPlotDependencyGraph[EvaluationNotebook[], \"Scope\" -> \"Local\"]";

(* ---- 関数定義解析 ---- *)
NBGetFunctionGlobalDeps::usage =
  "NBGetFunctionGlobalDeps[nb] はノートブック内の全関数定義を解析し、\n" <>
  "各関数が依存している大域変数のリストを返す。\n" <>
  "戻り値: <|\"関数名\" -> {\"大域変数1\", ...}, ...|>\n" <>
  "パターン変数とスコーピング局所変数 (Module/Block/With/Function) は除外される。";

(* ---- ノートブック TaggingRules API ---- *)
NBGetTaggingRule::usage =
  "NBGetTaggingRule[nb, key] はノートブックの TaggingRules から key の値を返す。\n" <>
  "NBGetTaggingRule[nb, {key1, key2, ...}] はネストしたパスを指定可能。\n" <>
  "キーが存在しない場合は Missing[] を返す。";

NBSetTaggingRule::usage =
  "NBSetTaggingRule[nb, key, value] はノートブックの TaggingRules に key -> value を設定する。\n" <>
  "NBSetTaggingRule[nb, {key1, key2}, value] はネストしたパスを指定可能。";

NBDeleteTaggingRule::usage =
  "NBDeleteTaggingRule[nb, key] はノートブックの TaggingRules から key を削除する。";

NBListTaggingRuleKeys::usage =
  "NBListTaggingRuleKeys[nb] はノートブックの TaggingRules の全キーを返す。\n" <>
  "NBListTaggingRuleKeys[nb, prefix] は prefix で始まるキーのみ返す。";

(* ---- 汎用履歴データベース API ---- *)
NBHistoryData::usage =
  "NBHistoryData[nb, tag] は TaggingRules から履歴データを読み取り、\n" <>
  "差分圧縮されたエントリを復元して返す。\n" <>
  "オプション Decompress -> False で Diff オブジェクトのまま返す。\n" <>
  "戻り値: <|\"header\" -> <|...|>, \"entries\" -> {<|...|>, ...}|>";

NBHistoryRawData::usage =
  "NBHistoryRawData[nb, tag] は差分圧縮を解除せずに履歴データを返す (内部用)。";

NBHistorySetData::usage =
  "NBHistorySetData[nb, tag, data] は TaggingRules に履歴データを書き込む。\n" <>
  "data は <|\"header\" -> ..., \"entries\" -> {...}|> の形式。\n" <>
  "entries は差分圧縮されていない平文で渡すこと。自動的に圧縮される。";

NBHistoryAppend::usage =
  "NBHistoryAppend[nb, tag, entry] はエントリを履歴に追加する。\n" <>
  "差分圧縮: 直前のエントリの fullPrompt/response/code を Diff で圧縮。\n" <>
  "オプション PrivacySpec -> ps で privacylevel をエントリに記録。";

NBHistoryEntries::usage =
  "NBHistoryEntries[nb, tag] は差分圧縮を復元した全エントリリストを返す。\n" <>
  "オプション Decompress -> False で Diff オブジェクトのまま返す。";

NBHistoryUpdateLast::usage =
  "NBHistoryUpdateLast[nb, tag, updates] は最後のエントリを更新する。\n" <>
  "updates は <|\"response\" -> ..., \"code\" -> ..., ...|> の形式。";

NBHistoryReadHeader::usage =
  "NBHistoryReadHeader[nb, tag] は履歴のヘッダー Association を返す。";

NBHistoryWriteHeader::usage =
  "NBHistoryWriteHeader[nb, tag, header] は履歴のヘッダーを書き込む。";

NBHistoryEntriesWithInherit::usage =
  "NBHistoryEntriesWithInherit[nb, tag] は親履歴を含む全エントリを返す。\n" <>
  "header の parent/inherit/created に従って親チェーンを辿る。\n" <>
  "オプション Decompress -> False で Diff オブジェクトのまま返す。";

NBHistoryListTags::usage =
  "NBHistoryListTags[nb, prefix] は prefix で始まる履歴タグ一覧を返す。";

NBHistoryDelete::usage =
  "NBHistoryDelete[nb, tag] は指定タグの履歴を TaggingRules から削除する。";

NBHistoryReplaceEntries::usage =
  "NBHistoryReplaceEntries[nb, tag, entries] はエントリリスト全体を置換する。\n" <>
  "コンパクションやバッチ更新に使用する。";

NBHistoryUpdateHeader::usage =
  "NBHistoryUpdateHeader[nb, tag, updates] はヘッダーにキーを追加・更新する。\n" <>
  "既存キーは上書き、新規キーは追加される。";

NBHistoryCreate::usage =
  "NBHistoryCreate[nb, tag, diffFields] は新しい履歴データベースを作成する。\n" <>
  "diffFields は差分圧縮対象のフィールド名リスト (例: {\"fullPrompt\", \"response\", \"code\"})。\n" <>
  "NBHistoryCreate[nb, tag, diffFields, headerOverrides] でヘッダーを上書き可能。\n" <>
  "既存 DB に diffFields がある場合は既存ヘッダーを返す (冪等)。";

(* ---- セッションアタッチメント API ---- *)
NBHistoryAddAttachment::usage =
  "NBHistoryAddAttachment[nb, tag, path] はセッションにファイルをアタッチする。\n" <>
  "ヘッダーの \"attachments\" リストにパスを追加 (重複除去)。";

NBHistoryRemoveAttachment::usage =
  "NBHistoryRemoveAttachment[nb, tag, path] はセッションからファイルをデタッチする。";

NBHistoryGetAttachments::usage =
  "NBHistoryGetAttachments[nb, tag] はセッションのアタッチメントリストを返す。";

NBHistoryClearAttachments::usage =
  "NBHistoryClearAttachments[nb, tag] はセッションの全アタッチメントをクリアする。";

(* ---- API キーアクセサー ---- *)
NBGetAPIKey::usage =
  "NBGetAPIKey[provider] は AI プロバイダの API キーを返す。\n" <>
  "provider: \"anthropic\" | \"openai\" | \"github\"\n" <>
  "オプション PrivacySpec -> <|\"AccessLevel\" -> 1.0|> (ディフォルト)。\n" <>
  "SystemCredential へのアクセスを一元管理する。";

(* ---- フォールバックモデル / プロバイダーアクセスレベル API ---- *)
NBSetFallbackModels::usage =
  "NBSetFallbackModels[models] はフォールバックモデルリストを設定する。\n" <>
  "models: {{\"provider\",\"model\"}, {\"provider\",\"model\",\"url\"}, ...}\n" <>
  "例: NBSetFallbackModels[{{\"anthropic\",\"claude-opus-4-6\"},{\"lmstudio\",\"gpt-oss-20b\",\"http://127.0.0.1:1234\"}}]";

NBGetFallbackModels::usage =
  "NBGetFallbackModels[] はフォールバックモデルリスト全体を返す。";

NBSetProviderMaxAccessLevel::usage =
  "NBSetProviderMaxAccessLevel[provider, level] はプロバイダーの最大アクセスレベルを設定する。\n" <>
  "level: 0.0〜1.0。このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。\n" <>
  "例: NBSetProviderMaxAccessLevel[\"anthropic\", 0.5]\n" <>
  "    NBSetProviderMaxAccessLevel[\"lmstudio\", 1.0]";

NBGetProviderMaxAccessLevel::usage =
  "NBGetProviderMaxAccessLevel[provider] はプロバイダーの最大アクセスレベルを返す。\n" <>
  "未登録プロバイダーは 0.5 を返す。";

NBGetAvailableFallbackModels::usage =
  "NBGetAvailableFallbackModels[accessLevel] は指定アクセスレベルで利用可能な\n" <>
  "フォールバックモデルのリストを返す。\n" <>
  "プロバイダーの MaxAccessLevel >= accessLevel のモデルのみ含まれる。\n" <>
  "例: NBGetAvailableFallbackModels[0.8] → lmstudio のみ\n" <>
  "    NBGetAvailableFallbackModels[0.5] → 全プロバイダー";

NBProviderCanAccess::usage =
  "NBProviderCanAccess[provider, accessLevel] はプロバイダーが指定アクセスレベルの\n" <>
  "データにアクセス可能かを返す (True/False)。\n" <>
  "MaxAccessLevel >= accessLevel なら True。";

(* ---- アクセス可能ディレクトリ API ---- *)
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



(* ---- 分離API: claudecodeからの間接アクセス用 ---- *)
NBBeginJobAtEvalCell::usage =
  "NBBeginJobAtEvalCell[nb] は EvaluationCell[] を内部取得してその直後にJob スロットを挿入する。\n" <>
  "claudecode が CellObject を保持する必要がない。";

NBExtractAssignments::usage =
  "NBExtractAssignments[text] はテキストから Set/SetDelayed の LHS 変数名を抽出する。";

NBSetConfidentialVars::usage =
  "NBSetConfidentialVars[assoc] は機密変数テーブルを一括設定する。\n" <>
  "assoc: <|\"varName\" -> True, ...|>";

NBGetConfidentialVars::usage =
  "NBGetConfidentialVars[] は現在の機密変数テーブルを返す。";

NBClearConfidentialVars::usage =
  "NBClearConfidentialVars[] は機密変数テーブルをクリアする。";

NBRegisterConfidentialVar::usage =
  "NBRegisterConfidentialVar[name, level] は機密変数を1つ登録する (level デフォルト 1.0)。";

NBUnregisterConfidentialVar::usage =
  "NBUnregisterConfidentialVar[name] は機密変数を1つ解除する。";

NBGetPrivacySpec::usage =
  "NBGetPrivacySpec[] は現在の $NBPrivacySpec を返す。";

NBInstallCellEpilog::usage =
  "NBInstallCellEpilog[nb, key, expr] はノートブックの CellEpilog に式を設定する。\n" <>
  "key は識別用文字列。既にインストール済みなら何もしない。";

NBCellEpilogInstalledQ::usage =
  "NBCellEpilogInstalledQ[nb, key] は CellEpilog が key で既にインストールされているか返す。";

NBEvaluatePreviousCell::usage =
  "NBEvaluatePreviousCell[nb] は直前のセルを選択して評価する。";

NBInsertInputTemplate::usage =
  "NBInsertInputTemplate[nb, boxes] は Input セルテンプレートを挿入する。";

NBParentNotebookOfCurrentCell::usage =
  "NBParentNotebookOfCurrentCell[] は EvaluationCell の親ノートブックを返す。";

$NBSeparationIgnoreList::usage =
  "$NBSeparationIgnoreList は分離検査 (ClaudeCheckSeparation) で無視する\n" <>
  "ファイル名またはパッケージ名のリスト。\n" <>
  "NBAccess と NotebookExtensions はデフォルトで登録済み。\n" <>
  "例: AppendTo[$NBSeparationIgnoreList, \"MyPackage\"]";

(* ---- 分離API追加: セル書き込み ---- *)
NBWriteCell::usage =
  "NBWriteCell[nb, cellExpr] はノートブックに Cell 式を書き込む (After)。\n" <>
  "NBWriteCell[nb, cellExpr, pos] は pos (After/Before/All) を指定可能。";

NBWritePrintNotice::usage =
  "NBWritePrintNotice[nb, text, color] はノートブックに通知用 Print セルを書き込む。\n" <>
  "nb が None の場合は CellPrint を使用 (同期 In/Out 間出力)。";

NBWriteDynamicCell::usage =
  "NBWriteDynamicCell[nb, dynBoxExpr, tag] はノートブックに Dynamic セルを書き込む。\n" <>
  "tag が \"\" でない場合は CellTags を設定する。";

NBWriteExternalLanguageCell::usage =
  "NBWriteExternalLanguageCell[nb, code, lang, autoEvaluate] は ExternalLanguage セルを書き込む。\n" <>
  "autoEvaluate が True なら直前セルを評価する。";

NBInsertAndEvaluateInput::usage =
  "NBInsertAndEvaluateInput[nb, boxes] は Input セルを挿入して即座に評価する。";

NBInsertInputAfter::usage =
  "NBInsertInputAfter[nb, boxes] は Input セルを After に書き込み Before CellContents に移動する。";

NBWriteAnchorAfterEvalCell::usage =
  "NBWriteAnchorAfterEvalCell[nb, tag] は EvaluationCell 直後に不可視アンカーセルを書き込む。\n" <>
  "EvaluationCell が取得できない場合はノートブック末尾に書き込む。";

NBInstallConfidentialEpilog::usage =
  "NBInstallConfidentialEpilog[nb, epilogExpr, checkSymbol] は機密変数追跡用 CellEpilog をインストールする。\n" <>
  "checkSymbol は FreeQ チェック用のマーカーシンボル。既にインストール済みなら何もしない。";

NBConfidentialEpilogInstalledQ::usage =
  "NBConfidentialEpilogInstalledQ[nb, checkSymbol] は機密追跡 CellEpilog がインストール済みか返す。\n" <>
  "checkSymbol は FreeQ チェック用のマーカーシンボル。";

Begin["`Private`"];

(* ============================================================
   ディフォルト値
   ============================================================ *)

(* アクセスレベル 0.5 = クラウドLLM安全なデータのみ *)
If[!AssociationQ[NBAccess`$NBPrivacySpec],
  NBAccess`$NBPrivacySpec = <|"AccessLevel" -> 0.5|>];

(* 秘密変数名 -> プライバシーレベル (0.0..1.0) *)
If[!AssociationQ[NBAccess`$NBConfidentialSymbols],
  NBAccess`$NBConfidentialSymbols = <||>];

(* 秘密依存データのスキーマ情報送信フラグ (ディフォルト True) *)
If[NBAccess`$NBSendDataSchema =!= False,
  NBAccess`$NBSendDataSchema = True];

(* 分離検査で無視するパッケージ名リスト *)
If[!ListQ[NBAccess`$NBSeparationIgnoreList],
  NBAccess`$NBSeparationIgnoreList = {"NBAccess", "NotebookExtensions"}];

(* フォールバックモデルリスト: {{provider, model}, {provider, model, url}, ...} *)
If[!ListQ[$iFallbackModels],
  $iFallbackModels = {{"anthropic", "claude-opus-4-6"}, {"openai", "gpt-5"}}];

(* プロバイダー別最大アクセスレベル: 未登録は 0.5 *)
If[!AssociationQ[$iProviderMaxAccessLevel],
  $iProviderMaxAccessLevel = <|
    "claudecode" -> 0.5,
    "anthropic"  -> 0.5,
    "openai"     -> 0.5,
    "lmstudio"   -> 1.0
  |>];

(* ============================================================
   内部ヘルパー: セルインデックス → CellObject 解決
   $iCellsCache により Cells[nb] の FrontEnd round-trip をキャッシュ。
   iPrecisionConfidentialCheck 等の重い走査で数千回の Cells[] 呼び出しを
   NB数回（5NB なら 5回）に削減する。
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

(* 全セルのスタイルを一括取得してキャッシュ *)
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

(* キャッシュ無効化 *)
NBAccess`NBInvalidateCellsCache[] := (
  $iCellsCache = <||>; $iCellStyleCache = <||>);
NBAccess`NBInvalidateCellsCache[nb_NotebookObject] := (
  $iCellsCache = KeyDrop[$iCellsCache, nb];
  $iCellStyleCache = KeyDrop[$iCellStyleCache, nb]);

(* ユーザーノートブックのみ取得:
   Notebooks[] はパレット、ヘルプブラウザ、ダイアログ等のシステムNBも含む。
   これらに Cells[] や CurrentValue を呼ぶと FrontEnd がブロック/フリーズする。
   WindowFrame が "Normal" のNBのみを安全に走査対象とする。 *)
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

(* スマートリフレッシュ: 変化のないNBのキャッシュを保持。
   返り値: 変化があったNBの NotebookObject リスト。
   判定方法:
     1. CurrentValue[nb, "ModifiedInMemory"] が False → 完全スキップ (0 FE call追加)
     2. Cells[nb] リストが前回と同一 → キャッシュ保持 (1 FE call)
     3. それ以外 → キャッシュ更新 (1 FE call + N CellStyle calls) *)
NBAccess`NBRefreshCellsCache[] :=
  Module[{allNBs, freshCells, cachedCells, changedNBs = {}, activeSet},
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[{}]];
    (* 閉じられたNBのキャッシュを除去 *)
    activeSet = Association[# -> True & /@ allNBs];
    $iCellsCache = KeySelect[$iCellsCache, KeyExistsQ[activeSet, #] &];
    $iCellStyleCache = KeySelect[$iCellStyleCache, KeyExistsQ[activeSet, #] &];
    Do[
      (* 未変更チェック: 保存済み + 編集なし → FE call なしでスキップ *)
      If[Quiet[CurrentValue[nbx, "ModifiedInMemory"]] === False &&
         KeyExistsQ[$iCellsCache, nbx],
        Continue[]];
      (* Cells[] を取得して前回と比較 *)
      freshCells = Quiet[Cells[nbx]];
      If[!ListQ[freshCells], Continue[]];
      cachedCells = Lookup[$iCellsCache, nbx, None];
      If[ListQ[cachedCells] && freshCells === cachedCells,
        (* CellObject リストが完全一致 → セルの追加/削除なし → キャッシュ保持 *)
        Null,
        (* 変化あり → キャッシュ更新 *)
        $iCellsCache[nbx] = freshCells;
        $iCellStyleCache = KeyDrop[$iCellStyleCache, nbx];
        AppendTo[changedNBs, nbx]],
    {nbx, allNBs}];
    changedNBs
  ];

(* ============================================================
   内部ヘルパー: PrivacySpec 解決
   ============================================================ *)

iResolvePS[Automatic]       := NBAccess`$NBPrivacySpec;
iResolvePS[ps_Association]  := ps;
iResolvePS[_]               := NBAccess`$NBPrivacySpec;

iAccessLevel[ps_] := Lookup[iResolvePS[ps], "AccessLevel", 0.5];

(* ============================================================
   内部ヘルパー: TaggingRules から秘密タグを読み出す
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
   内部ヘルパー: 秘密変数参照チェック (CellObject版、内部用)
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
   セルユーティリティ API (新規)
   ============================================================ *)

NBAccess`NBCellCount[nb_NotebookObject] :=
  Length[iResolveCells[nb]];

NBAccess`NBCurrentCellIndex[nb_NotebookObject] :=
  Module[{ec, cells, pos},
    ec = Quiet[EvaluationCell[]];
    If[Head[ec] =!= CellObject, Return[0]];
    cells = Quiet[Cells[nb]];
    If[!ListQ[cells], Return[0]];
    pos = First[Flatten[Position[cells, ec]], 0];
    pos
  ];

NBAccess`NBSelectedCellIndices[nb_NotebookObject] :=
  Module[{allCells, sel, selSet, indices},
    allCells = Quiet[Cells[nb]];
    If[!ListQ[allCells], Return[{}]];
    (* まずセルブラケット選択を試みる *)
    sel = Quiet[SelectedCells[nb]];
    If[!ListQ[sel] || Length[sel] === 0,
      (* フォールバック: 現在のカーソル位置のセルを取得 *)
      Quiet[
        SelectionMove[nb, All, Cell];
        sel = SelectedCells[nb];
        SelectionMove[nb, After, CellContents];
      ];
    ];
    If[!ListQ[sel] || Length[sel] === 0, Return[{}]];
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

(* Cell 式が画像を含むか判定 (RasterBox/GraphicsBox の有無) *)
NBAccess`NBCellHasImage[cellExpr_] :=
  Length[Cases[cellExpr, _RasterBox | _GraphicsBox, Infinity]] > 0;

NBAccess`NBCellHasImage[$Failed] := False;
NBAccess`NBCellHasImage[{}] := False;

(* ============================================================
   セル内容テキスト取得 (InputText 形式)
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
   プライバシーレベル: 0.0..1.0
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
   アクセス可能判定関数
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
   テキスト抽出関数
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
   ノートブック内セル一覧取得 (PrivacySpec フィルタリング付き)
   ============================================================ *)

Options[NBAccess`NBGetCells] = {PrivacySpec -> Automatic};
NBAccess`NBGetCells[nb_NotebookObject, opts:OptionsPattern[]] :=
  Module[{n},
    n = NBAccess`NBCellCount[nb];
    If[n === 0, Return[{}]];
    NBAccess`NBFilterCellIndices[nb, Range[n], opts]
  ];

(* 機密変数を含む行の処理 *)
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
              First[lhsMatch] <> " = (* [機密変数に依存: 値は非表示] *)",
              "(* [機密変数を含む行: 非表示] *)"]]]],
      lines];
    {StringJoin @ Riffle[redacted, "\n"], anyRedacted}
  ];

(* ============================================================
   Output スマート要約 (全 Output をコンテキストに含めるための要約機構)
   短い出力はそのまま含め、長い出力はデータ型・サイズ・先頭値等を要約する。
   ============================================================ *)

$iOutputSummaryMaxLen = 200;

(* Output テキストからデータ構造情報を検出 *)
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
      (* SparseArray, NumericArray 等 *)
      StringContainsQ[text, "SparseArray["],
        "SparseArray",
      StringContainsQ[text, "NumericArray["],
        "NumericArray",
      (* Image *)
      StringContainsQ[text, RegularExpression["Image\\[|Graphics\\[|Graphics3D\\["]],
        "Graphics/Image",
      (* Default: サイズ情報のみ *)
      True,
        ToString[len] <> " chars"
    ]
  ];

(* セルテキストの堅牢な取得:
   NBCellToText (Cases ベース) は特殊な BoxData 形式で空になることがある。
   FrontEnd`ExportPacket 経由の NBCellReadInputText を優先し、
   失敗時に NBCellToText にフォールバックする。 *)
iRobustCellText[nb_NotebookObject, oIdx_Integer] :=
  Module[{txt},
    (* 優先: FrontEnd ExportPacket (InputText 形式) *)
    txt = Quiet[NBAccess`NBCellReadInputText[nb, oIdx]];
    If[StringQ[txt] && StringLength[StringTrim[txt]] > 0,
      Return[StringTrim[txt]]];
    (* フォールバック: BoxData 内の文字列トークン収集 *)
    txt = ToString[NBAccess`NBCellToText[nb, oIdx]];
    If[StringQ[txt] && StringLength[StringTrim[txt]] > 0,
      Return[StringTrim[txt]]];
    ""
  ];

(* 非秘密 Output のスマート要約: 短ければそのまま、長ければ構造 + 先頭値 *)
iSmartOutputSummary[nb_NotebookObject, oIdx_Integer] :=
  Module[{outTxt, len},
    outTxt = iRobustCellText[nb, oIdx];
    If[outTxt === "", Return["(出力取得失敗)"]];
    len = StringLength[outTxt];
    If[len <= $iOutputSummaryMaxLen, Return[outTxt]];
    (* 長い出力: 構造情報 + 先頭プレビュー *)
    Module[{info = iDetectDataInfo[outTxt], preview},
      preview = StringTake[outTxt, UpTo[100]];
      "(* " <> info <> " *) " <> preview <> " \[Ellipsis]"
    ]
  ];

(* 秘密依存 Output のスキーマ情報: データ型・サイズ・キーのみ、値は含まない *)
iOutputSchemaText[nb_NotebookObject, oIdx_Integer] :=
  Module[{outTxt, info},
    outTxt = iRobustCellText[nb, oIdx];
    If[outTxt === "", Return["(* [機密依存データ: 取得失敗] *)"]];
    info = iDetectDataInfo[outTxt];
    "(* [機密依存データ: " <> info <> "] *)"
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
    (* 全 Input/Code セルインデックスを取得 *)
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
            (* セルレベルのプライバシーチェック: マーク済みセルは除外 *)
            cellPriv = NBAccess`NBCellPrivacyLevel[nb, iIdx];
            If[cellPriv > iAccessLevel[OptionValue[PrivacySpec]],
              (* セル全体が秘密: テキストを出さず、対応 Output も抑制 *)
              nextOutIndices = Select[outIndices, # > iIdx &];
              If[Length[nextOutIndices] > 0,
                nextInIdx = SelectFirst[inIndices, # > iIdx &, Infinity];
                nextOutIndices = Select[nextOutIndices, # < nextInIdx &];
                suppressedOutPos = Join[suppressedOutPos, nextOutIndices]];
              cellLabel = NBAccess`NBCellLabel[nb, iIdx];
              If[cellLabel =!= "",
                cellLabel <> " (* [\:6a5f\:5bc6\:30bb\:30eb: \:975e\:8868\:793a] *)",
                Nothing],
              (* 通常処理: 変数名ベースのリダクション *)
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
    (* Output: 全 Output を含めるが、スマート要約・スキーマ処理を適用
       afterIdx フィルタは撤廃し、秘密依存 Output はスキーマ情報のみ送信 *)
    Module[{supSet = Association[# -> True & /@ suppressedOutPos],
            accessLvl = iAccessLevel[OptionValue[PrivacySpec]],
            normalOuts = {}, schemaOuts = {}, outLines = {}},
      Do[Module[{priv = NBAccess`NBCellPrivacyLevel[nb, oi],
                 isSuppressed = KeyExistsQ[supSet, oi]},
          Which[
            (* 非秘密かつ非抑制 → スマート要約付きで含める *)
            !isSuppressed && priv <= accessLvl,
              AppendTo[normalOuts, oi],
            (* 秘密依存だがスキーマフラグ ON → スキーマ情報のみ *)
            TrueQ[NBAccess`$NBSendDataSchema],
              AppendTo[schemaOuts, oi],
            (* それ以外 → 完全スキップ *)
            True, Null]],
        {oi, outIndices}];

      (* Normal outputs: スマート要約 *)
      Do[Module[{outLabel = NBAccess`NBCellLabel[nb, oi],
                 outSummary = iSmartOutputSummary[nb, oi]},
          AppendTo[outLines,
            If[outLabel =!= "",
              StringReplace[outLabel, "=" -> "="] <> " " <> outSummary,
              outSummary]]],
        {oi, normalOuts}];
      (* Schema outputs: データ型・サイズ・キー情報のみ *)
      Do[Module[{outLabel = NBAccess`NBCellLabel[nb, oi],
                 schema = iOutputSchemaText[nb, oi]},
          AppendTo[outLines,
            If[outLabel =!= "",
              StringReplace[outLabel, "=" -> "="] <> " " <> schema,
              schema]]],
        {oi, schemaOuts}];

      outText = If[Length[outLines] > 0,
        "=== Output 一覧 ===\n" <>
          StringJoin[Riffle[outLines, "\n"]] <> "\n\n",
        ""]];

    (* Message は afterIdx 以降のみ *)
    msgIndices = Select[
      Sort[Join[
        NBAccess`NBCellIndicesByStyle[nb, "Message"],
        NBAccess`NBCellIndicesByStyle[nb, "MSG"]]],
      # > afterIdx &];
    With[{safeSet = Association[
            # -> True & /@ NBAccess`NBFilterCellIndices[nb, msgIndices, opts]]},
      msgIndices = Select[msgIndices, KeyExistsQ[safeSet, #] &]];
    msgText = If[Length[msgIndices] > 0,
      "=== エラーメッセージ ===\n" <>
        StringJoin[Riffle[
          ToString[NBAccess`NBCellToText[nb, #]] & /@ msgIndices,
          "\n"]] <> "\n\n",
      ""];
    If[StringLength[inLines] > 0,
      "=== 実行されたコード ===\n" <> inLines <> "\n\n", ""] <>
    msgText <> outText
  ];

(* ============================================================
   書き込み関数
   ============================================================ *)

NBAccess`NBWriteText[nb_NotebookObject, text_String,
    style_String:"Text"] :=
  NotebookWrite[nb, Cell[text, style], After];

(*  MakeBoxes でタイプセットすると危険なトップレベルヘッド
    Module/Block 等のスコーピング構造は MakeBoxes で変数コンテキストが壊れる *)
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

(* HoldComplete[expr] のトップレベルヘッドが MakeBoxes に安全か判定 *)
(* 多引数(CompoundExpression相当)や複雑な式は安全でないとみなす *)
iIsMakeBoxesSafe[held_HoldComplete] :=
  Module[{len, head},
    len = Length[held];
    (* 多引数 = CompoundExpression → 安全でない *)
    If[len =!= 1, Return[False]];
    head = Replace[held, HoldComplete[x_] :> Head[x]];
    (* パターンマッチ失敗時（何らかの理由で Head が取れない）→ 安全でない *)
    If[head === HoldComplete, Return[False]];
    !MemberQ[$iMakeBoxesUnsafeHeads, head]
  ];

NBAccess`NBWriteCode[nb_NotebookObject, code_String] :=
  Module[{trimmed = StringTrim[code], result, box, held, boxes, cell},
    Catch[
      (* --- 安全な数式のみ MakeBoxes[StandardForm] でタイプセット:
            Integrate→∫, Sum→Σ, Subscript→下付き, Sqrt→√ 等 --- *)
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
      (* --- フォールバック: FEParser（Module/Block/複雑なコード向け）--- *)
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

          (* --- 安全な数式のみ MakeBoxes[StandardForm] でタイプセット
                Integrate→∫, Sum→Σ, Subscript→下付き, Sqrt→√ 等
                Module/Block/Show 等の手続き的コードは FEParser へ --- *)
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
      (* フォールバック: FEParser ベース *)
      NBAccess`NBWriteCode[nb, trimmed]
    , "done"]
  ];

(* ============================================================
   ロード時メッセージ
   ============================================================ *)

Print[Style["NBAccess パッケージ \[LongDash] ノートブックアクセスユーティリティ (セルインデックス版)", Bold]];
Print[
  "  NBCellCount[nb]                      \[RightArrow] セル数\n" <>
  "  NBCurrentCellIndex[nb]               \[RightArrow] 現在セルインデックス\n" <>
  "  NBSelectedCellIndices[nb]            \[RightArrow] 選択セルインデックス\n" <>
  "  NBCellPrivacyLevel[nb, idx]          \[RightArrow] プライバシーレベル (0.0..1.0)\n" <>
  "  NBIsAccessible[nb, idx, PrivacySpec->ps] \[RightArrow] アクセス可能判定\n" <>
  "  NBFilterCellIndices[nb, idxs, PrivacySpec->ps] \[RightArrow] プライバシーフィルタ\n" <>
  "  NBCellToText[nb, idx]                \[RightArrow] セルテキスト抽出\n" <>
  "  NBCellHasImage[cellExpr]             \[RightArrow] Cell式が画像を含むか判定\n" <>
  "  NBGetCells[nb, PrivacySpec->ps]      \[RightArrow] 全セルインデックス取得 (フィルタ付き)\n" <>
  "  NBGetContext[nb, idx, PrivacySpec->ps] \[RightArrow] LLMプロンプト用コンテキスト文字列\n" <>
  "  NBWriteText[nb, text, style]         \[RightArrow] テキストセル書込\n" <>
  "  NBWriteCode[nb, code]                \[RightArrow] コードセル書込 (構文カラーリング付き)\n" <>
  "  NBWriteSmartCode[nb, code]           \[RightArrow] スマートコード書込 (CellPrint対応)\n" <>
  "  NBWriteInputCellAndMaybeEvaluate[nb, boxes, auto] \[RightArrow] Inputセル挿入+条件付き評価\n" <>
  "\n--- アクセス可能ディレクトリ API ---\n" <>
  "  NBSetAccessibleDirs[nb, {dir1,...}] \[RightArrow] Claude Code 参照ディレクトリ設定\n" <>
  "  NBGetAccessibleDirs[nb]            \[RightArrow] 設定済みディレクトリ取得\n" <>
  "\n--- 汎用履歴データベース API ---\n" <>
  "  NBHistoryCreate[nb, tag, diffFields]  \[RightArrow] DB作成 (差分フィールド指定, 冪等)\n" <>
  "  NBHistoryAppend[nb, tag, entry]      \[RightArrow] エントリ追加 (差分圧縮+privacylevel)\n" <>
  "  NBHistoryEntries[nb, tag]            \[RightArrow] 全エントリ (復元済み)\n" <>
  "  NBHistoryUpdateLast[nb, tag, upd]    \[RightArrow] 最終エントリ更新\n" <>
  "  NBHistoryReadHeader[nb, tag]         \[RightArrow] ヘッダー読取\n" <>
  "  NBHistoryWriteHeader[nb, tag, hdr]   \[RightArrow] ヘッダー書込\n" <>
  "  NBHistoryEntriesWithInherit[nb, tag] \[RightArrow] 親チェーン含む全履歴\n" <>
  "  NBHistoryData[nb, tag]               \[RightArrow] 復元済み全データ\n" <>
  "  NBHistorySetData[nb, tag, data]      \[RightArrow] 全データ書込 (自動圧縮)\n" <>
  "  NBHistoryListTags[nb, prefix]        \[RightArrow] タグ一覧\n" <>
  "  NBHistoryDelete[nb, tag]             \[RightArrow] 履歴削除\n" <>
  "  NBHistoryReplaceEntries[nb, tag, e]  \[RightArrow] エントリ全置換\n" <>
  "  NBHistoryUpdateHeader[nb, tag, upd]  \[RightArrow] ヘッダー部分更新\n" <>
  "  NBHistoryAddAttachment[nb, tag, path] \[RightArrow] アタッチメント追加\n" <>
  "  NBHistoryGetAttachments[nb, tag]     \[RightArrow] アタッチメント一覧\n" <>
  "\n$NBPrivacySpec (default): " <>
    ToString[NBAccess`$NBPrivacySpec] <>
  "\n$NBConfidentialSymbols: " <>
    ToString[Length[NBAccess`$NBConfidentialSymbols]] <> " 変数登録済"
];

(* ============================================================
   セルマーク関数 (セルインデックス版)
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

(* 機密マーク: 赤背景 + WarningSign（直接機密） *)
NBAccess`$NBConfidentialCellOpts = {
  Background    -> RGBColor[1, 0.90, 0.90],
  CellFrame     -> {{2, 2}, {1, 1}},
  CellFrameColor -> RGBColor[0.75, 0.15, 0.15],
  CellDingbat  -> Cell["\[WarningSign]",
    FontColor -> RGBColor[0.75, 0.1, 0.1], FontSize -> 14]
};

(* 依存機密マーク: 橙背景 + LockIcon *)
NBAccess`$NBDependentCellOpts = {
  Background    -> RGBColor[1, 0.95, 0.85],
  CellFrame     -> {{2, 2}, {1, 1}},
  CellFrameColor -> RGBColor[0.85, 0.50, 0.10],
  CellDingbat  -> Cell["\[WarningSign]",
    FontColor -> RGBColor[0.85, 0.50, 0.10], FontSize -> 12]
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
        CellFrame      -> Inherited,
        CellFrameColor -> Inherited,
        CellDingbat    -> Inherited
      }]]]]
);

(* 依存マークのみリセット（未判定状態に戻す） *)
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
        CellFrame      -> Inherited,
        CellFrameColor -> Inherited,
        CellDingbat    -> Inherited
      }]]]]
);

(* ============================================================
   セル内容分析 API (claudecodeから移設)
   ============================================================ *)

(* 秘密変数を参照しているか *)
NBAccess`NBCellUsesConfidentialSymbol[nb_NotebookObject, cellIdx_Integer] :=
  Module[{cell},
    cell = iResolveCell[nb, cellIdx];
    If[cell === $Failed, Return[False]];
    iCellUsesConfSymbol[nb, cell]
  ];

(* セル内容から Set/SetDelayed の LHS 変数名を抽出 *)
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

(* Confidential[] 内の代入先変数名を抽出 *)
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

(* プロンプトから除外すべきか *)
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

(* Claude 関数呼び出しセルか判定 *)
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
   依存グラフ: 変数→依存変数セット
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

(* ;; (Span) を保護して ; (CompoundExpression) と \n で分割
   InputText 形式では "1 ;; 2" のようにスペースが入る場合がある。
   ";" と ";" の間にスペースがあっても Span として保護する。 *)
$iSpanPlaceholder = "__NBACCESS_SPAN__";
iSplitStatements[text_String] :=
  Module[{safe, lines},
    (* ;; および ; ; （スペース含む）を一括保護 *)
    safe = StringReplace[text, RegularExpression[";\\s*;"] -> $iSpanPlaceholder];
    lines = StringSplit[safe, RegularExpression["[;\\n]"]];
    StringReplace[#, $iSpanPlaceholder -> ";;"] & /@ lines
  ];

iExtractAssignments[text_String] :=
  Module[{stripped, unwrapped, lines, result = {}},
    stripped = iStripStrings[text];
    (* Confidential[expr] ラッパーを除去して内部の代入を検出 *)
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

(* 関数定義解析 *)
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
      (* InputText 形式で取得。2D表示 (Sum, Integral等) も正しく変換される *)
      text = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      If[!StringQ[text] || text === "", Continue[]];

      (* --- Variable assignments: var = expr --- *)
      assignments = iExtractAssignments[text];
      (* セル番号から Out$n 仮想変数を定義 *)
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
   全ノートブック統合依存グラフ (LLM送信直前の精密チェック用)
   Notebooks[] 全体の Input セルを走査し、変数依存関係を
   1つの Association にマージして返す。
   通常のセル実行時は NBBuildVarDependencies[nb] を使用し、
   ClaudeQuery/ClaudeEval/ContinueEval の直前にのみ呼び出すこと。
   ============================================================ *)

NBAccess`NBBuildGlobalVarDependencies[] :=
  Module[{allNBs, deps = <||>, cells, text, assignments, funcDefs},
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[deps]];
    Do[
      cells = Quiet[Cells[nbx]];
      If[!ListQ[cells], Continue[]];
      Do[
        (* Input/Code セルのみ解析
           CurrentValue[cell, CellStyle] はリスト {"Input"} を返すため
           ContainsAny で判定する *)
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

(* インクリメンタル版: 既存グラフに新しいセルのみ追加
   CellLabel In[x] の x が afterLine より大きいセルだけを走査し、
   既存の依存グラフにマージする。
   返り値: {updatedDeps, newMaxLine} *)
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
        (* CellLabel から In[x] の x を取得し、afterLine 以下ならスキップ *)
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
  Module[{marked = Union[confVars], changed = True},
    While[changed,
      changed = False;
      Do[
        If[!MemberQ[marked, v] &&
           Length[Intersection[Lookup[deps, v, {}], marked]] > 0,
          AppendTo[marked, v];
          changed = True],
        {v, Keys[deps]}]];
    marked
  ];

(* deps を省略した場合は内部で計算する従来互換版 *)
NBAccess`NBScanDependentCells[nb_NotebookObject,
    confVarNames_List, opts:OptionsPattern[]] :=
  NBAccess`NBScanDependentCells[nb, confVarNames,
    NBAccess`NBBuildVarDependencies[nb], opts];

(* deps を事前計算済みで渡せるオーバーロード（二重計算を回避） *)
NBAccess`NBScanDependentCells[nb_NotebookObject,
    confVarNames_List, deps_Association, opts:OptionsPattern[]] :=
  Module[{dependentVars, allDepVars, nCells, inIndices,
          marked = 0},
    allDepVars = NBAccess`NBTransitiveDependents[deps, confVarNames];
    dependentVars = Complement[allDepVars, confVarNames];

    nCells = NBAccess`NBCellCount[nb];
    If[nCells === 0, Return[0]];
    inIndices = NBAccess`NBCellIndicesByStyle[nb, "Input"];

    (* Phase 1: 事前クリーニング — 全セルの dependent マークをリセット *)
    Do[If[TrueQ[NBAccess`NBCellGetTaggingRule[nb, i,
                  {"claudecode", "dependent"}]],
        iResetDependentMark[nb, i]],
    {i, nCells}];

    (* Phase 2: 全セルを順番に走査し Input/Output ペアを検出
       直前の Input セルが依存秘密 → Output を橙
       直前の Input セルが直接秘密 → Output を赤
       
       この方式により、セルインデックスの "nextOut" 検索の
       ずれ問題を完全に回避する。 *)
    Module[{lastInputIdx = 0, lastInputText = "", lastInputTag = Missing[],
            lastInputDepTag = Missing[], lastInputIsDep = False,
            lastInputIsDirectConf = False,
            style, text, assigns,
            noticeCells, allC, noticeIdxSet = <||>},
      (* 通知セル (claudecode-notice) のインデックスを収集: マーキング対象外 *)
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
          (* Input/Code セル: テキストを解析して依存判定 *)
          MemberQ[{"Input", "Code"}, style],
            lastInputIdx = i;
            lastInputTag = NBAccess`NBGetConfidentialTag[nb, i];
            lastInputDepTag = NBAccess`NBCellGetTaggingRule[nb, i,
              {"claudecode", "dependent"}];
            lastInputIsDirectConf = TrueQ[lastInputTag] && !TrueQ[lastInputDepTag];
            lastInputIsDep = False;
            (* 直接秘密・明示非秘密・Claude関数セルはスキップ *)
            If[!TrueQ[lastInputTag] && lastInputTag =!= False &&
               !NBAccess`NBIsClaudeFunctionCell[nb, i],
              text = Quiet[NBAccess`NBCellReadInputText[nb, i]];
              If[StringQ[text] && text =!= "" && !iIsFuncDefText[text],
                assigns = iExtractAssignments[text];
                lastInputIsDep = (
                  (* 条件1: LHS変数が推移的依存変数 *)
                  AnyTrue[assigns, MemberQ[dependentVars, First[#]] &] ||
                  (* 条件2: 代入なし式で機密変数を参照 *)
                  (Length[assigns] === 0 &&
                   AnyTrue[allDepVars,
                     StringContainsQ[iStripStrings[text],
                       RegularExpression["(?<![\\p{L}\\p{N}$])" <> # <>
                         "(?![\\p{L}\\p{N}$])"]] &]) ||
                  (* 条件3: RHS が機密変数を参照 *)
                  (Length[assigns] > 0 &&
                   AnyTrue[assigns,
                     Function[a,
                       Length[Intersection[Last[a], allDepVars]] > 0]])
                );
                If[lastInputIsDep, marked++]]],

          (* Output/Print セル: 直前の Input に基づいてマーク *)
          MemberQ[{"Output", "Print"}, style] && lastInputIdx > 0,
            (* 通知セル (claudecode-notice) はスキップ *)
            If[!TrueQ[Lookup[noticeIdxSet, i, False]] &&
               NBAccess`NBGetConfidentialTag[nb, i] =!= False,
              Which[
                (* 直接秘密セルの Output → 赤マーク *)
                lastInputIsDirectConf,
                  NBAccess`NBMarkCellConfidential[nb, i],
                (* 依存秘密セルの Output → 橙マーク *)
                lastInputIsDep,
                  NBAccess`NBMarkCellDependent[nb, i]
              ]
            ];
            (* 同じ Input の Output は1回だけマーク *)
            (* lastInputIdx は変更しない — 複数 Output セルがある場合も対応 *),

          (* それ以外のセル (Text等) は lastInput をリセットしない *)
          True, Null
        ],
      {i, nCells}]];

    marked
  ];

(* ============================================================
   依存関係エッジリスト
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
    (* 機密変数または推移的依存変数が関与するエッジのみ *)
    Select[edges, MemberQ[allDepVars, #[[1]]] || MemberQ[allDepVars, #[[2]]] &]
  ];

(* ============================================================
   包括的デバッグ関数
   ============================================================ *)

NBAccess`NBDebugDependencies[nb_NotebookObject, confVars_List] :=
  Module[{deps, allDepVars, dependentVars, inIndices, outIndices, nCells, edges},
    deps = NBAccess`NBBuildVarDependencies[nb];
    allDepVars = NBAccess`NBTransitiveDependents[deps, confVars];
    dependentVars = Complement[allDepVars, confVars];
    nCells = NBAccess`NBCellCount[nb];
    inIndices  = NBAccess`NBCellIndicesByStyle[nb, "Input"];
    outIndices = NBAccess`NBCellIndicesByStyle[nb, "Output"];

    Print[Style["===== 依存グラフ (dep -> var) =====", Bold, Blue]];
    edges = NBAccess`NBDependencyEdges[nb];
    Do[Print["  ", e], {e, edges}];
    If[Length[edges] === 0, Print["  (エッジなし)"]];

    Print[Style["\n===== 機密関連エッジのみ =====", Bold, Red]];
    Module[{confEdges = NBAccess`NBDependencyEdges[nb, confVars]},
      Do[Print["  ", e], {e, confEdges}];
      If[Length[confEdges] === 0, Print["  (エッジなし)"]]];

    Print[Style["\n===== 変数テーブル =====", Bold]];
    Do[Print["  ", k, " -> deps: ", deps[k]], {k, Keys[deps]}];

    Print[Style["\n===== 直接機密変数 =====", Bold, Red]];
    Print["  ", confVars];

    Print[Style["\n===== 推移的依存変数 (機密含む) =====", Bold]];
    Print["  ", allDepVars];

    Print[Style["\n===== 依存のみ (機密除く) =====", Bold, RGBColor[0.85, 0.5, 0.1]]];
    Print["  ", dependentVars];

    Print[Style["\n===== 関数定義の解析 =====", Bold]];
    Do[Module[{txt, fd},
      txt = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      If[StringQ[txt],
        fd = iExtractFuncDefs[txt];
        If[Length[fd] > 0,
          Do[Print["  In[", idx, "] ", First[f], " → globalDeps: ", Last[f]],
          {f, fd}]]]],
    {idx, inIndices}];

    Print[Style["\n===== 全 Input セル詳細 =====", Bold]];
    Do[Module[{inputText, boxText, assigns, lhsVars, rhsVars, isDep,
               nextInI, nextOutI, tag, depTag, confTag},
      inputText = Quiet[NBAccess`NBCellReadInputText[nb, idx]];
      boxText   = Quiet[NBAccess`NBCellToText[nb, idx]];
      tag       = NBAccess`NBGetConfidentialTag[nb, idx];
      depTag    = NBAccess`NBCellGetTaggingRule[nb, idx, {"claudecode", "dependent"}];
      confTag   = Which[tag === True, "秘密", tag === False, "非秘密(Unmark済)", True, "未設定"];

      Print[Style["--- セルIndex=" <> ToString[idx] <>
        " (" <> NBAccess`NBCellLabel[nb, idx] <> ") tag=" <> confTag <> " ---",
        Bold]];
      Print["  InputText: ", If[StringQ[inputText], StringTake[inputText, UpTo[120]], "(取得失敗)"]];
      If[inputText =!= boxText,
        Print["  BoxText  : ", If[StringQ[boxText], StringTake[boxText, UpTo[120]], "(取得失敗)"]]];

      If[StringQ[inputText] && inputText =!= "",
        assigns = iExtractAssignments[inputText];
        Print["  代入解析 : ", assigns];
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
            " (nextIn=", If[nextInI === Infinity, "∞", nextInI], ")",
            " markable=", nextOutI =!= None && nextOutI < nextInI]],
        Print["  isDep    : (テキスト取得失敗のためスキップ)"]
      ]],
    {idx, inIndices}];

    Print[Style["\n===== セル構成 (全 " <> ToString[nCells] <> " セル) =====", Bold]];
    Do[Module[{style, lbl, tag2},
      style = ToString[NBAccess`NBCellStyle[nb, i]];
      lbl   = NBAccess`NBCellLabel[nb, i];
      tag2  = NBAccess`NBGetConfidentialTag[nb, i];
      Print["  [", i, "] ", style,
        If[lbl =!= "", " " <> lbl, ""],
        If[tag2 === True, " ★秘密", ""],
        If[TrueQ[NBAccess`NBCellGetTaggingRule[nb, i, {"claudecode", "dependent"}]],
          " ◆依存秘密", ""]]],
    {i, nCells}];
  ];


(* ============================================================
   依存グラフプロット
   ============================================================ *)


Options[NBAccess`NBPlotDependencyGraph] = {
  PrivacySpec -> <|"AccessLevel" -> 1.0|>,
  "Scope" -> "Global",
  GraphLayout -> "LayeredDigraphEmbedding"
};

(* 引数なし: デフォルト Scope="Global" で全NB統合 *)
NBAccess`NBPlotDependencyGraph[opts : OptionsPattern[]] :=
  NBAccess`NBPlotDependencyGraph[None, opts];

(* メイン実装: nb=None なら全NB、nb 指定なら Scope に従う *)
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

    (* === Step 1: 対象ノートブックを決定 === *)
    allNBs = iUserNotebooks[];
    If[!ListQ[allNBs], Return[Style["(ノートブックなし)", Gray, Italic]]];
    targetNBs = If[scope === "Local" && nb =!= None,
      {nb},   (* Local: 指定NBのみ *)
      allNBs  (* Global: 全NB *)
    ];
    isMultiNB = Length[targetNBs] > 1;
    scopeLabel = If[scope === "Local",
      "Local (1 NB)",
      "Global (" <> ToString[Length[targetNBs]] <> " NBs)"];

    (* NB 名前マッピング *)
    Do[Module[{name},
      name = Quiet @ Check[
        Module[{fn = NotebookFileName[nbx]},
          If[StringQ[fn], FileBaseName[fn],
            "NB" <> ToString[Hash[nbx, "CRC32"]]]],
        "NB" <> ToString[Hash[nbx, "CRC32"]]];
      nbNames[nbx] = name;
      If[!MemberQ[nbList, name], AppendTo[nbList, name]]],
    {nbx, targetNBs}];

    (* NB ごとに色を割り当て *)
    nbColorMap = Association[MapIndexed[
      #1 -> ColorData[97][First[#2]] &, nbList]];

    (* === Step 2: 秘密変数を収集 ===
       Global モードでは全NB走査、Local モードでも全NB走査
       （別NBの秘密変数が現在NBの変数に影響するため） *)
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

    (* === Step 3: 依存グラフ構築 + 変数のNBソース追跡 === *)
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
            (* Out$n 仮想変数 *)
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

    (* 未参照の Out$n を除去 *)
    With[{refd = DeleteDuplicates[
            Select[Flatten[Values[deps]],
              StringMatchQ[#, "Out$" ~~ DigitCharacter ..] &]]},
      deps = KeyDrop[deps,
        Complement[
          Select[Keys[deps],
            StringMatchQ[#, "Out$" ~~ DigitCharacter ..] &],
          refd]]];

    (* === Step 4: 推移的依存を計算 === *)
    allDepVars = NBAccess`NBTransitiveDependents[deps, directConfVars];
    If[!ListQ[allDepVars], allDepVars = directConfVars];

    (* === Step 5: グラフ構築 === *)
    allEdges = DeleteDuplicates @ Flatten[
      KeyValueMap[
        Function[{var, depList},
          DirectedEdge[#, var] & /@ depList],
        deps]];

    If[Length[allEdges] === 0,
      Return[Style["(エッジなし)", Gray, Italic]]];

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
      Return[Style["(表示可能なノードなし)", Gray, Italic]]];

    subg = Subgraph[fullGraph, visibleVars];

    (* === Step 6: 描画 === *)
    Module[{iDispName, confSet, depSet, pubSet,
            confLabels, depLabels, pubLabels, allLabels,
            vStyles, eStyles, edgeTooltips,
            highlighted, nbLegendItems},

      (* ラベル: 秘密・依存秘密のみ変数名を表示。公開はラベルなし。
         全ノードに Tooltip で変数名+NB名を表示。 *)
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

      (* 秘密・依存秘密: Above に変数名ラベル表示 + Tooltip でNB名
         Tooltip[表示ラベル, ホバーテキスト] を Placed[..., Above] で配置 *)
      confLabels = Map[# -> Placed[
        Tooltip[Style[iDispName[#], Bold, 7, RGBColor[0.7, 0.1, 0.1]],
                iTooltipText[#]], Above] &,
        confSet];
      depLabels = Map[# -> Placed[
        Tooltip[Style[iDispName[#], Bold, 7, RGBColor[0.8, 0.45, 0.05]],
                iTooltipText[#]], Above] &,
        depSet];
      (* 公開変数: ラベルなし、Tooltip のみ *)
      pubLabels = Map[# -> Placed[iTooltipText[#], Tooltip] &, pubSet];

      allLabels = Join[confLabels, depLabels, pubLabels];

      (* ノードスタイル:
         変数: 塗りつぶし (秘密=赤, 依存秘密=橙, 公開=青), 縁取りなし
         関数: 白地 + 縁取り (秘密=赤, 依存秘密=橙, 公開=青) *)
      vStyles = Map[
        Function[v,
          Module[{priv, isFunc, clr},
            priv = Lookup[varPrivacy, v, 0.0];
            isFunc = TrueQ[Lookup[funcSet, v, False]];
            clr = Which[
              priv === 1.0,  RGBColor[0.82, 0.15, 0.15],   (* 赤 *)
              priv === 0.75, RGBColor[0.90, 0.55, 0.10],   (* 橙 *)
              True,          RGBColor[0.35, 0.55, 0.82]];   (* 青 *)
            v -> If[isFunc,
              (* 関数: 白地 + 色付き縁取り *)
              Directive[EdgeForm[{AbsoluteThickness[2], clr}], White],
              (* 変数: 塗りつぶし + 縁取りなし *)
              Directive[EdgeForm[None], clr]]]],
        visibleVars];

      (* エッジスタイル: NB内は濃い実線、クロスNBは薄い破線 *)
      eStyles = Map[
        Function[e,
          Module[{srcNB, dstNB, isCross},
            srcNB = Lookup[varNBSource, e[[1]], "?src"];
            dstNB = Lookup[varNBSource, e[[2]], "?dst"];
            isCross = isMultiNB && (srcNB =!= dstNB);
            e -> If[isCross,
              (* クロスNB: 薄い破線 *)
              Directive[GrayLevel[0.72], Dashing[{0.01, 0.008}],
                Arrowheads[0.012]],
              (* NB内 (または Local モード): 濃い実線 *)
              Directive[GrayLevel[0.35], AbsoluteThickness[1.5],
                Arrowheads[0.012]]]]],
        EdgeList[subg]];

      (* エッジツールチップ: セル番号 *)
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
          "依存グラフ — " <> scopeLabel <>
          " (AccessLevel=" <> ToString[accessLevel] <> ")",
          Bold, 14]];

      (* 凡例 *)
      legend = Column[{
        SwatchLegend[
          {RGBColor[0.82, 0.15, 0.15], RGBColor[0.90, 0.55, 0.10],
           RGBColor[0.35, 0.55, 0.82]},
          {"秘密 (直接)", "依存秘密 (推移的)", "公開"},
          LegendMarkerSize -> 14, LabelStyle -> 10],
        Row[{
          Graphics[{RGBColor[0.35, 0.55, 0.82], Disk[{0, 0}, 0.4]},
            ImageSize -> 14, PlotRange -> 1],
          Style[" 変数", 9], Spacer[10],
          Graphics[{White, EdgeForm[{AbsoluteThickness[2], RGBColor[0.35, 0.55, 0.82]}],
            Disk[{0, 0}, 0.4]}, ImageSize -> 14, PlotRange -> 1],
          Style[" 関数", 9]}],
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
              Style[" NB内", 9],
              Spacer[10],
              Graphics[{GrayLevel[0.72], Dashing[{0.03, 0.02}],
                Line[{{0,0},{1,0}}]}, ImageSize -> {30, 8}],
              Style[" クロスNB", 9]}]
          }, Spacings -> 0.3],
          Nothing]
        }, Spacings -> 0.5];

      Legended[highlighted, Placed[legend, Below]]
    ]
  ];



(* ============================================================
   ノートブック TaggingRules API
   ノートブックレベルの TaggingRules への読み書きを一元管理する。
   セッション履歴などの永続データの格納に使用。
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
      (* List 形式の TaggingRules *)
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
   API キーアクセサー
   ============================================================ *)

$iAPIKeyMap = <|
  "anthropic"  -> "ANTHROPIC_API_KEY",
  "openai"     -> "OPENAI_API_KEY",
  "github"     -> "GITHUB_TOKEN",
  "gh"         -> "GITHUB_TOKEN",
  "github_pat" -> "GITHUB_TOKEN"
|>;

Options[NBAccess`NBGetAPIKey] = {PrivacySpec -> <|"AccessLevel" -> 1.0|>};

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

NBGetAPIKey::unkn = "未知のプロバイダ: `1`。\"anthropic\"、\"openai\"、\"github\" のいずれかを指定してください。";
NBGetAPIKey::nokey = "`1` の API キーが見つかりません。SystemCredential[\"`2`\"] を設定してください。";


(* ============================================================
   アクセス可能ディレクトリ API
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
   汎用履歴データベース API
   TaggingRules を用いた順次格納型履歴システム。
   ・各タグに <|"header" -> ..., "entries" -> {...}|> を格納
   ・header の "diffFields" に差分圧縮対象フィールド名リストを格納
   ・entries の差分対象フィールドは Diff による差分圧縮
     （最新エントリは平文、それ以前は Diff オブジェクト）
   ・PrivacySpec オプションで privacylevel をエントリに記録
   ============================================================ *)

(* ---- 内部ヘルパー: ヘッダーから差分圧縮フィールドを取得 ---- *)
(* 後方互換: diffFields 未設定の旧 DB には空リストを返す *)
iGetDiffFields[header_Association] :=
  Lookup[header, "diffFields", {}];

iGetDiffFields[nb_NotebookObject, tag_String] :=
  iGetDiffFields[Lookup[NBAccess`NBHistoryRawData[nb, tag], "header", <||>]];

(* エントリの差分フィールドがまだ平文（未圧縮）かを判定 *)
iIsPlainEntry[entry_Association, diffFields_List] :=
  AnyTrue[diffFields,
    Function[f, StringQ[Lookup[entry, f, Missing[]]]]];

(* prev エントリを next エントリとの差分で圧縮する *)
iCompressOneEntry[prev_Association, next_Association, diffFields_List] :=
  Fold[
    Function[{e, field},
      Module[{pv = Lookup[e, field, ""], nv = Lookup[next, field, ""]},
        If[StringQ[pv] && StringQ[nv],
          <|e, field -> Diff[nv, pv]|>,
          e]]],
    prev,
    diffFields];

(* 差分オブジェクトを nextPlain の平文で復元する *)
iDecompressOneEntry[entry_Association, nextPlain_Association, diffFields_List] :=
  Fold[
    Function[{e, field},
      Module[{sv = Lookup[e, field, ""], nv = Lookup[nextPlain, field, ""]},
        If[!StringQ[sv] && StringQ[nv],
          (* Diff オブジェクト → DiffApply で復元 *)
          <|e, field -> Quiet@Check[DiffApply[sv, nv], "(復元失敗)"]|>,
          e]]],
    entry,
    diffFields];

(* エントリリスト全体を復元 (最新=末尾 が平文、それ以前を順次復元) *)
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

(* エントリリスト全体を圧縮 (最新を平文のまま、それ以前を Diff 化) *)
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

(* ---- NBHistoryRawData: 圧縮状態のまま読み取り (キャッシュ付き) ----
   ClaudeQuery 1回で同じ履歴を7回以上読むため、キャッシュで FE 通信を削減。
   書き込み系関数は iHistoryCacheUpdate / iHistoryCacheInvalidate でキャッシュを同期する。 *)

$iNBHistoryCache = <||>;

iHistoryCacheKey[nb_NotebookObject, tag_String] :=
  {nb, tag};

iHistoryCacheInvalidate[nb_NotebookObject, tag_String] :=
  ($iNBHistoryCache = KeyDrop[$iNBHistoryCache, Key[{nb, tag}]]);

iHistoryCacheUpdate[nb_NotebookObject, tag_String, val_] :=
  ($iNBHistoryCache[{nb, tag}] = val);

(* 全キャッシュクリア（パッケージ再ロード・セッション切替時） *)
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

(* ---- NBHistoryCreate: DB 作成 (冪等) ---- *)
NBAccess`NBHistoryCreate[nb_NotebookObject, tag_String, diffFields_List] :=
  NBAccess`NBHistoryCreate[nb, tag, diffFields, <||>];

NBAccess`NBHistoryCreate[nb_NotebookObject, tag_String, diffFields_List,
    headerOverrides_Association] :=
  Module[{raw, existingHdr, hdr},
    raw = NBAccess`NBHistoryRawData[nb, tag];
    existingHdr = Lookup[raw, "header", <||>];
    (* diffFields 設定済みなら冪等: 既存ヘッダーを返す *)
    If[AssociationQ[existingHdr] && KeyExistsQ[existingHdr, "diffFields"],
      Return[existingHdr]];
    (* 新規作成 or 旧 DB に diffFields を追加 *)
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

(* ---- NBHistoryData: 復元済みデータ (Decompress->False で圧縮状態) ---- *)
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

(* ---- NBHistorySetData: 圧縮して書き込み ---- *)
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

(* ---- NBHistoryEntries: エントリリスト (Decompress->False で圧縮状態) ---- *)
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

(* ---- NBHistoryAppend: エントリ追加 (差分圧縮 + privacylevel) ---- *)
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

    (* privacylevel を付与 *)
    ps = OptionValue[PrivacySpec];
    If[ps === Automatic, ps = NBAccess`$NBPrivacySpec];
    newEntry = <|entry, "privacylevel" -> ps|>;

    (* 二つ前のエントリが未圧縮なら、直前のエントリとの差分で圧縮。
       直前エントリ (entries[[-1]]) は前回の updateLast で確定済み。
       ※ entries[[-1]] はまだ平文なのでこの段階で圧縮可能。 *)
    If[n >= 2 && iIsPlainEntry[entries[[-2]], diffFields],
      entries[[-2]] = iCompressOneEntry[entries[[-2]], entries[[-1]], diffFields]];

    entries = Append[entries, newEntry];
    With[{newData = <|data, "entries" -> entries|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryUpdateLast: 最終エントリの更新 ---- *)
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


(* ---- NBHistoryReplaceEntries: エントリリスト全体の置換 ---- *)
NBAccess`NBHistoryReplaceEntries[nb_NotebookObject, tag_String, entries_List] :=
  Module[{data},
    data = NBAccess`NBHistoryRawData[nb, tag];
    If[!AssociationQ[data], data = <|"header" -> <||>, "entries" -> {}|>];
    With[{newData = <|data, "entries" -> entries|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryUpdateHeader: ヘッダーの部分更新 ---- *)
NBAccess`NBHistoryUpdateHeader[nb_NotebookObject, tag_String, updates_Association] :=
  Module[{data, hdr},
    data = NBAccess`NBHistoryRawData[nb, tag];
    hdr = Lookup[data, "header", <||>];
    hdr = Merge[{hdr, updates}, Last];
    With[{newData = <|data, "header" -> hdr|>},
      NBAccess`NBSetTaggingRule[nb, tag, newData];
      iHistoryCacheUpdate[nb, tag, newData]]
  ];

(* ---- NBHistoryEntriesWithInherit: 親チェーンを辿った全履歴 ---- *)
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

(* ---- セッションアタッチメント API ---- *)

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


(* ============================================================
   履歴プライバシフィルター
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
      resp = "(機密変数の値を含むためこのステップの履歴は非表示)";
      blocked = True];

    If[!blocked && iHistoryFieldLeaksConfidential[code, confVars],
      code = "(機密変数を含むため非表示)";
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
      Quiet[SelectionMove[evalCell, After, Cell]],
      Quiet[SelectionMove[nb, After, Notebook]]];
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
    Quiet[SelectionMove[First[cells], All, Cell]];
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
      Quiet[SelectionMove[First[cells], After, Cell]]];
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

(* スロットの written フラグを False にリセット (NBEndJob での削除対象にする) *)
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
   分離API実装: claudecode が CellObject/Private に直接触らないための公開API
   ============================================================ *)

(* EvaluationCell を内部取得して Job を開始する *)
NBAccess`NBBeginJobAtEvalCell[nb_NotebookObject] :=
  Module[{evalCell},
    evalCell = Quiet[EvaluationCell[]];
    NBAccess`NBBeginJob[nb, evalCell]
  ];

(* テキストから代入変数名を抽出 (Private`iExtractAssignments の公開版) *)
NBAccess`NBExtractAssignments[text_String] :=
  iExtractAssignments[text];

(* 機密変数テーブル操作API *)
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

(* CellEpilog 管理 *)
NBAccess`NBInstallCellEpilog[nb_NotebookObject, key_String, expr_] :=
  Module[{current},
    current = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    If[FreeQ[current, key],
      Quiet[SetOptions[nb, CellEpilog :> expr]]]];

NBAccess`NBCellEpilogInstalledQ[nb_NotebookObject, key_String] :=
  Module[{epi},
    epi = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    !FreeQ[epi, key]];

(* セル評価ヘルパー *)
NBAccess`NBEvaluatePreviousCell[nb_NotebookObject] := (
  Quiet[SelectionMove[nb, Previous, Cell]];
  Quiet[SelectionEvaluate[nb]];
  Quiet[SelectionMove[nb, After, Cell]]);

(* Input テンプレート挿入 *)
NBAccess`NBInsertInputTemplate[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], All];
  SelectionMove[nb, All, CellContents]);

(* EvaluationCell の親ノートブック *)
NBAccess`NBParentNotebookOfCurrentCell[] :=
  Quiet @ Check[ParentNotebook[EvaluationCell[]], InputNotebook[]];


(* ============================================================
   分離API追加実装: セル書き込み・テンプレート・CellEpilog
   ============================================================ *)

(* 汎用セル書き込み *)
NBAccess`NBWriteCell[nb_NotebookObject, cellExpr_Cell, where_:After] :=
  Quiet[NotebookWrite[nb, cellExpr, where]];

(* 通知用 Print セル書き込み
   CellTags "claudecode-notice" を付与して NBScanDependentCells のマーキング対象外にする *)
NBAccess`NBWritePrintNotice[None, text_String, color_] :=
  CellPrint[Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}]];
NBAccess`NBWritePrintNotice[nb_NotebookObject, text_String, color_] :=
  NotebookWrite[nb, Cell[text, "Print", FontWeight -> Bold, FontColor -> color, FontSize -> 11,
    CellTags -> {"claudecode-notice"}], After];

(* Dynamic セル書き込み *)
NBAccess`NBWriteDynamicCell[nb_NotebookObject, dynBoxExpr_, tag_String:"", opts___] :=
  If[tag === "",
    NotebookWrite[nb, Cell[BoxData[dynBoxExpr], "Print", opts], After],
    NotebookWrite[nb, Cell[BoxData[dynBoxExpr], "Print", CellTags -> {tag}, opts], After]];

(* ExternalLanguage セル書き込み *)
NBAccess`NBWriteExternalLanguageCell[nb_NotebookObject, code_String,
    lang_String, autoEvaluate_:False] := (
  NotebookWrite[nb,
    Cell[code, "ExternalLanguage", CellEvaluationLanguage -> lang], After];
  If[TrueQ[autoEvaluate],
    Quiet[SelectionMove[nb, Previous, Cell]];
    Quiet[SelectionEvaluate[nb]];
    Quiet[SelectionMove[nb, After, Cell]]]);

(* Input セルを挿入して即座に評価 *)
NBAccess`NBInsertAndEvaluateInput[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  Quiet[SelectionEvaluate[nb]]);

(* Input セルを After に書き込み、Before CellContents に移動 *)
NBAccess`NBInsertInputAfter[nb_NotebookObject, boxes_] := (
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  SelectionMove[nb, Before, CellContents]);

(* カーソル後に Input セルを挿入し、カーソル配置 + 条件付き評価 *)
NBAccess`NBWriteInputCellAndMaybeEvaluate[nb_NotebookObject, boxes_,
    autoEvaluate_:False] := (
  Quiet[SelectionMove[nb, After, Cell]];
  NotebookWrite[nb, Cell[BoxData[boxes], "Input"], After];
  Quiet[SelectionMove[nb, Previous, Cell]];
  Quiet[SelectionMove[nb, Before, CellContents]];
  SetSelectedNotebook[nb];
  If[TrueQ[autoEvaluate], Quiet[SelectionEvaluate[nb]]]);

(* EvaluationCell 直後に不可視アンカーセルを書き込む *)
NBAccess`NBWriteAnchorAfterEvalCell[nb_NotebookObject, tag_String] :=
  Module[{evalCell},
    evalCell = Quiet[EvaluationCell[]];
    If[Head[evalCell] === CellObject,
      Quiet[SelectionMove[evalCell, After, Cell]],
      Quiet[SelectionMove[nb, After, Notebook]]];
    NotebookWrite[nb,
      Cell["", "Text", CellTags -> {tag}, CellOpen -> False], After]];

(* 機密追跡用 CellEpilog インストール (専用API)
   epilogExpr: CellEpilog に設定する式
   checkSymbol: FreeQ チェック用のマーカーシンボル (例: ClaudeCode`Private`iConfidentialCellEpilog) *)
NBAccess`NBInstallConfidentialEpilog[nb_NotebookObject, epilogExpr_, checkSymbol_] :=
  Module[{current},
    current = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    If[FreeQ[current, checkSymbol],
      Quiet[SetOptions[nb, CellEpilog :> epilogExpr]]]];

NBAccess`NBConfidentialEpilogInstalledQ[nb_NotebookObject, checkSymbol_] :=
  Module[{epi},
    epi = Quiet[AbsoluteCurrentValue[nb, CellEpilog]];
    !FreeQ[epi, checkSymbol]];


(* .nb ファイルを開いてテキストセルを挿入する (テンプレート初期化用) *)
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
   フォールバックモデル / プロバイダーアクセスレベル API
   ============================================================ *)

(* フォールバックモデルリスト管理 *)
NBAccess`NBSetFallbackModels[models_List] :=
  ($iFallbackModels = models);

NBAccess`NBGetFallbackModels[] :=
  If[ListQ[$iFallbackModels], $iFallbackModels, {}];

(* プロバイダー別最大アクセスレベル管理 *)
NBAccess`NBSetProviderMaxAccessLevel[provider_String, level_?NumericQ] :=
  ($iProviderMaxAccessLevel[ToLowerCase[provider]] = Clip[level, {0., 1.}]);

NBAccess`NBGetProviderMaxAccessLevel[provider_String] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5];

(* プロバイダーがアクセスレベルに対応可能か判定 *)
NBAccess`NBProviderCanAccess[provider_String, accessLevel_?NumericQ] :=
  Lookup[$iProviderMaxAccessLevel, ToLowerCase[provider], 0.5] >= accessLevel;

(* 指定アクセスレベルで利用可能なフォールバックモデルのみ返す *)
NBAccess`NBGetAvailableFallbackModels[requestedLevel_?NumericQ] :=
  Select[$iFallbackModels,
    Function[entry,
      Lookup[$iProviderMaxAccessLevel, ToLowerCase[entry[[1]]], 0.5] >= requestedLevel
    ]
  ];


End[];
EndPackage[];
