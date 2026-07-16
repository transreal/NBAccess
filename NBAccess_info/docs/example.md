## 概要

NBAccess はノートブックアクセスユーティリティパッケージです。セルインデックスベースでノートブックの読み書きとプライバシーフィルタリングを提供し、クラウド LLM とローカル LLM の双方に安全にアクセスできるようにします。

```
Block[{$CharacterEncoding = "UTF-8"}, Get["NBAccess.wl"]]
```

または claudecode.wl 経由でロードするとエンコーディングを自動的に処理します。

## プライバシー仕様 (PrivacySpec)

NBAccess の多くの関数は `PrivacySpec` オプションでアクセス範囲を制御します。

```
PrivacySpec -> <|"AccessLevel" -> 0.5|>   (* クラウドLLM安全なデータのみ (デフォルト) *)
PrivacySpec -> <|"AccessLevel" -> 1.0|>   (* ローカルLLM環境などすべてのデータ *)
```

グローバルデフォルトは `$NBPrivacySpec` で保持されます。

```
$NBPrivacySpec
(* <|"AccessLevel" -> 0.5|> *)

$NBPrivacySpec = <|"AccessLevel" -> 1.0|>;  (* ローカルLLM環境から利用する場合 *)
```

関連するグローバル変数:

- `$NBConfidentialSymbols` — `<|"変数名" -> privacyLevel, ...|>` の形式の秘密変数テーブル。ClaudeCode パッケージが自動更新します。
- `$NBSendDataSchema` — 秘密依存データのスキーマ情報（型・サイズ・キー等）をクラウド LLM に送信するかを制御します。`True`（デフォルト）で送信、`False` で抑制します。非秘密 Output は常にスマート要約付きで送信されます。
- `$NBVerbose` — NBAccess 内部の詳細ログ出力を制御します。`True` で `Messages` に詳細ログを出力、`False`（デフォルト）で重大エラー以外を抑制します。
- `$NBAutoEvalProhibitedPatterns` — `NBEvaluatePreviousCell` で自動実行をブロックするパターン（`RegularExpression` または `StringExpression`）のリストです。セル内容がいずれかのパターンにマッチする場合、評価をスキップして警告を表示します。ClaudeCode パッケージがロード時にパターンを登録し、デフォルトは空リストです。

## セルユーティリティ API

セルインデックス（1始まりの整数）を基準にノートブックを操作する低レベル API 群です。

```
nb = EvaluationNotebook[];
NBCellCount[nb]                      (* ノートブックの全セル数 *)
NBCurrentCellIndex[nb]               (* EvaluationCell[] のセルインデックス。見つからなければ 0 *)
NBSelectedCellIndices[nb]            (* 選択中セルのインデックスリスト *)
NBCellIndicesByTag[nb, "MyTag"]      (* 指定 CellTags を持つセルのインデックスリスト *)
NBCellIndicesByStyle[nb, "Input"]    (* 指定 CellStyle のセルのインデックスリスト *)
NBCellIndicesByStyle[nb, {"Input", "Output"}]  (* 複数スタイルを指定可能 *)
NBDeleteCellsByTag[nb, "MyTag"]      (* 指定 CellTags を持つセルを全て削除 *)
NBMoveAfterCell[nb, 3]               (* セル3の後ろにカーソルを移動 *)
NBCellRead[nb, 3]                    (* NotebookRead で Cell 式を返す *)
NBCellReadInputText[nb, 3]           (* FrontEnd 経由で InputText 形式を取得。失敗時は NBCellExprToText にフォールバック *)
NBCellStyle[nb, 3]                   (* セルの CellStyle を返す *)
NBCellLabel[nb, 3]                   (* セルの CellLabel ("In[3]:=" 等)。ラベルなしは "" *)
NBCellSetOptions[nb, 3, ShowCellLabel -> False]
NBCellSetStyle[nb, 3, "Input"]       (* スタイルを変更。TaggingRules 等の属性は保持される *)
NBSelectCell[nb, 3]                  (* セルブラケットを選択状態にする *)
NBResolveCell[nb, 3]                 (* CellObject を返す。無効なインデックスは $Failed *)
NBCellGetTaggingRule[nb, 3, {"claudecode", "confidential"}]
NBCellRasterize[nb, 3, "C:\\out\\cell3.png"]
NBCellHasImage[NBCellRead[nb, 3]]    (* Cell式が RasterBox/GraphicsBox を含むか判定 *)
NBCellWriteText[nb, 3, "新しいテキスト"]   (* テキストを置換。スタイル・TaggingRules等は保持 *)
NBCellSetTaggingRule[nb, 3, {"documentation", "idea"}, "元のアイデア"]  (* NBCellGetTaggingRule の対となるセッター *)
```

`NBCellWriteCode[nb, cellIdx, code]` は既存セルに構文カラーリング付き BoxData を書き込みます。

```
NBCellWriteCode[nb, 3, "Plot[Sin[x], {x, 0, 2 Pi}]"]
```

## LLM 連携 API

```
$NBLLMQueryFunc[prompt, callback, nb, Model -> spec, Fallback -> True, Integrations -> {...}]
```

`$NBLLMQueryFunc` は非同期 LLM 呼び出し用コールバック関数です。ClaudeCode パッケージが自動的に `ClaudeQueryAsync` を登録します。`callback` は応答文字列を受け取る関数、`nb` は出力先の `NotebookObject` です。`Integrations` は LM Studio MCP 用（`lmstudio` モデル使用時のみ有効、`Automatic` なら無視）で、カーネルはブロックしません。

```
NBCellGetText[nb, 3]
```

`NBCellGetText` はセルからテキストを堅牢に取得します。FrontEnd InputText → NBCellToText → NBCellExprToText の順にフォールバックし、取得不可の場合は `""` を返します。

```
NBCellTransformWithLLM[nb, 3, promptFn, Print, Fallback -> True]
```

`NBCellTransformWithLLM` は非同期でセルを LLM 変換します。`promptFn` はセルテキストを受け取りプロンプト文字列を返す関数、`completionFn` は結果 Association を受け取るコールバックです（エラー時は `$Failed`）。カーネルはブロックしません。セルのプライバシーレベルに応じて適切な LLM を自動選択します。

オプション:

- `Fallback -> False`
- `InputText -> Automatic` — セルテキストの代わりに使用する入力テキスト。
- `Integrations -> Automatic` — LM Studio MCP サーバーリスト（`lmstudio` モデル時のみ）。

`completionFn` が受け取る Association: `<|"Response" -> text, "OriginalText" -> orig, "PrivacyLevel" -> pl|>`

## プライバシー API

```
NBCellPrivacyLevel[nb, 3]     (* 0.0(非秘密) 〜 1.0(秘密: Confidentialマーク or 秘密変数参照) *)
NBIsAccessible[nb, 3, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
NBFilterCellIndices[nb, Range[NBCellCount[nb]], PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

## テキスト抽出 API

```
NBCellExprToText[NBCellRead[nb, 3]]   (* Cell式からテキストを抽出 *)
NBCellToText[nb, 3]                   (* セルのテキスト内容を返す *)
NBGetCells[nb, PrivacySpec -> <|"AccessLevel" -> 0.5|>]   (* 全セルインデックスをフィルタして返す *)
NBGetContext[nb, 5, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
```

`NBGetContext` は指定セル番号以降から LLM プロンプト用コンテキスト文字列を構築します（デフォルト AccessLevel 0.5）。

## 書き込み API

```
NBWriteText[nb, "説明テキスト", "Text"]     (* style既定は "Text" *)
NBWriteCode[nb, "1 + 1"]                    (* 構文カラーリング付き Input セル *)
NBWriteSmartCode[nb, "Plot[x, {x,0,1}]"]    (* CellPrint[]パターンを自動検出してスマートに書き込む *)
NBWriteInputCellAndMaybeEvaluate[nb, boxes, True]
NBInsertTextCells["C:\\path\\to\\file.nb", "セクション名", "本文"]
```

`NBWriteInputCellAndMaybeEvaluate` は現在のカーソル位置の後ろに Input セルを挿入し、カーソルをセル先頭に移動します。`autoEvaluate` が `True` なら続けて `SelectionEvaluate` を実行します。

`NBInsertTextCells` は `.nb` ファイルを非表示で開き、末尾に Subsection セル（name）と Text セル（prompt）を挿入して保存・クローズします。

## ファイル型ノートブック操作 API

閉じた `.nb` ファイルを対象とした読み書き操作です。秘匿セルの有無にかかわらず必ずこの API を経由してください（claudecode.wl 等の上位層から `.nb` ファイルを直接 `NotebookOpen`/`NotebookGet` してはいけません）。

```
nb2 = NBFileOpen["C:\\path\\to\\file.nb"]     (* 非表示 (Visible->False) で開く。失敗時は $Failed *)
NBFileSave[nb2, "C:\\path\\to\\translated.nb"]  (* path が None なら上書き保存 *)
cells = NBFileReadCells[nb2, PrivacySpec -> <|"AccessLevel" -> 0.5|>]
(* {<|cellIdx, style, text, privacyLevel|>, ...} を返す。
   privacyLevel > PrivacySpec の秘匿セルはテキストが "[CONFIDENTIAL]" に置換される *)
cells = NBFileReadAllCells[nb2]     (* 秘匿セルも含む全セルをアクセスレベル別に分類して返す。ローカルモデル処理用 *)
NBFileWriteCell[nb2, 3, "This is a pen."]
NBFileWriteAllCells[nb2, <|2 -> "text", 3 -> "[CONFIDENTIAL]"|>]  (* Association/List で複数セル一括置換 *)
NBFileClose[nb2]
```

## ObjectSpec API

```
NBFileSpec["C:\\path\\file.nb"]
(* PrivacyLevel: <0.5=クラウドLLM可, >=0.5=ローカルのみ, {0.5,1.0}=混在(.nb) *)

NBFileSpecCacheClear[]   (* NBFileSpec の base/projection キャッシュをクリア *)

NBValueSpec[dataset, 1.0]

NBNormalizePath["C:\\path\\to\\file"]
(* <|"Kind", "RootId", "Parts", "SymbolicPath", "PhysicalPath", "ResolutionStatus", "MatchedBy"|> を返す。
   ResolutionStatus: "ResolvedOnThisPC" | "AliasOnly" | "Unrooted"。
   MatchedBy: "LocalRoot" | "Alias" | "None"。
   戻り値は同一性判定用の情報でありアクセス権限そのものではない。
   権限判定は必ず PhysicalPath を現PCで解決・実在確認した上で access mode と privacy を見ること。 *)

NBPrivacyLevelToRoutes[{0.5, 1.0}]   (* 0.5->{"cloud"}, 1.0->{"local"}, {0.5,1.0}->{"cloud","local"} *)

NBFileReadCellsInRange[nb2, 0.5, 0.5]  (* 公開セルのみ *)
NBFileReadCellsInRange[nb2, 0.9, 1.0]  (* 秘匿セルのみ *)

{pub, priv} = NBAccess`NBSplitNotebookCells["file.nb", 0.5]
(* PrivacyLevel <= threshold(public) と > threshold(private) に2分割 *)

NBAccess`NBMergeNotebookCells[src, dst, pubResults, privResults]
(* 2つの <|cellIdx->newText|> を元セル順にマージして outputPath に保存 *)
```

## セルマーク API

```
NBGetConfidentialTag[nb, 3]     (* TaggingRules から機密タグを返す: True/False/Missing[] *)
NBSetConfidentialTag[nb, 3, True]
NBMarkCellConfidential[nb, 3]          (* PrivacyLevel 1.0 に設定し赤背景マークを付ける *)
NBMarkCellConfidential[nb, 3, 0.8]     (* PrivacyLevel を任意の数値(0.0-1.0)に設定。>0.5で赤背景、<=0.5でマーク解除 *)
NBSetSnapshotPrivacyLevel[snapshotId, 1.0]
NBInsertArtifactCell[nb, "sv://artifact/<id>"]
NBMarkCellDependent[nb, 3]       (* 依存機密マーク（橙背景+LockIcon）を付ける *)
NBUnmarkCell[nb, 3]              (* 機密マーク（視覚・タグ）をすべて解除 *)
```

`NBMarkCellConfidential` と `NBSetSnapshotPrivacyLevel` は `Options: PrivacySpec -> Automatic` を持ち、`$NBApprovalHeads` に登録されているため実行時に承認ゲートが発火します。

`NBSetSnapshotPrivacyLevel` は SourceVault snapshot の PrivacyLevel を設定します。snapshot の PrivacyLevel は通常セル判定からの導出値ですが、人間が明示的に上書きしたい場合に使用します。SourceVault がロードされている必要があります。

`NBInsertArtifactCell` は SourceVault artifact URI（`sv://artifact/<id>` / `sv://hash/sha256/<hex>`）の内容を解決し、メディア種別に応じたセルとしてノートブックへ挿入します（Image は画像セル、Video/Binary はファイルリンク、Text は本文）。セルには artifact の PrivacyLevel が必ず焼き込まれ（TaggingRules `claudecode` `privacyLevel`/`confidential`）、level > 0.5 なら `$NBConfidentialCellOpts` の機密マーク（赤背景+警告 dingbat）付きで出力されます。内容解決は `SourceVault`SourceVaultResolveArtifactContent`（正規リーダー）に委譲し、SourceVault 未ロード時はエラーになります。

オプション:

- `"VideoCell" -> False`（`True` で `Video[file]` セル、既定はファイルリンク）
- `"MaxImageSize" -> 480`（表示上の最大幅 px、`None` で原寸）
- `"Materialize" -> Automatic`

戻り値: `<|Status, URI, MediaKind, PrivacyLevel, Marked|>`

## セル内容分析 API

```
NBCellUsesConfidentialSymbol[nb, 3]     (* セルが機密変数を参照しているか *)
NBCellExtractVarNames[nb, 3]            (* Set/SetDelayed のLHS変数名を抽出 *)
NBCellExtractAssignedNames[nb, 3]       (* Confidential[] 内の代入先変数名を抽出 *)
NBShouldExcludeFromPrompt[nb, 3]        (* プロンプトから除外すべきセルか *)
NBIsClaudeFunctionCell[nb, 3]           (* Claude関数呼び出しセルか *)
```

## 依存グラフ API

```
NBAccess`iCellToInputText[cell]     (* FrontEnd経由でセルのInputText形式を取得。失敗時は NBCellExprToText にフォールバック *)

NBBuildVarDependencies[nb]
(* ノートブックのInputセルを解析して変数依存関係グラフ <|"var" -> {"dep1",...}|> を返す。
   文字列リテラル内の識別子は除外される。 *)

NBBuildGlobalVarDependencies[]
(* Notebooks[] 全体のInputセルを走査して統合された変数依存関係グラフを返す。
   LLM呼び出し直前の精密チェックで使用する。通常のセル実行時は軽量版 NBBuildVarDependencies[nb] を使用すること。 *)

{updatedDeps, newLastLine} = NBUpdateGlobalVarDependencies[existingDeps, afterLine]
(* 既存の依存グラフに CellLabel In[x] (x > afterLine) のセルのみを追加走査してマージする。
   完全なグラフを毎回構築するコストを回避するインクリメンタル版。 *)

NBTransitiveDependents[deps, confVars]    (* confVarsに直接・間接依存する全変数名リスト *)
NBScanDependentCells[nb, confVarNames]
(* 依存グラフを使って機密変数に依存するセルに NBMarkCellDependent を適用し、新たにマークしたセル数を返す。
   Claude関数呼び出しセル (ClaudeQuery等) は除外される。 *)
NBScanDependentCells[nb, confVarNames, deps]   (* 事前計算済みの依存グラフdepsを使う（二重計算回避） *)

NBFilterHistoryEntry[entry, confVars]
(* 履歴エントリ内のresponse/instructionに現時点の機密変数名または値が含まれる場合にそのフィールドをブロックする。 *)

NBDependencyEdges[nb]
(* ノートブックの変数依存関係をエッジリストで返す: {DirectedEdge["dep", "var"], ...}
   "dep" -> "var" は「var が dep に依存する」を意味する。 *)
NBDependencyEdges[nb, confVars]   (* 機密変数confVarsに関連するエッジのみ返す *)

NBDebugDependencies[nb, confVars]
(* 依存グラフ・推移依存・セルテキストをPrintで表示するデバッグ関数。
   各Inputセルについて InputText取得結果・代入解析結果・依存判定結果を出力する。 *)

NBPlotDependencyGraph[]        (* 全ノートブック統合の依存グラフをプロット（デフォルト） *)
NBPlotDependencyGraph[nb]      (* 指定ノートブックの依存グラフをプロット *)
(* ノードは変数名・Out[n]で、直接秘密は赤、依存秘密は橙で着色。
   NB内エッジは濃い実線、クロスNBエッジは薄い破線で描画。 *)
NBPlotDependencyGraph[EvaluationNotebook[], "Scope" -> "Local"]

(* オプション:
     "Scope" -> "Global" (デフォルト) | "Local"
     PrivacySpec -> <|"AccessLevel" -> 1.0|> で表示範囲を制御。 *)
```

## 関数定義解析

```
NBGetFunctionGlobalDeps[nb]
(* ノートブック内の全関数定義を解析し、各関数が依存している大域変数のリストを返す。
   戻り値: <|"関数名" -> {"大域変数1", ...}, ...|>
   パターン変数とスコーピング局所変数 (Module/Block/With/Function) は除外される。 *)
```

## ノートブック TaggingRules API

```
NBGetTaggingRule[nb, "key"]
NBGetTaggingRule[nb, {"key1", "key2"}]     (* ネストしたパスを指定可能。存在しなければ Missing[] *)
NBSetTaggingRule[nb, "key", value]
NBSetTaggingRule[nb, {"key1", "key2"}, value]
NBDeleteTaggingRule[nb, "key"]
NBListTaggingRuleKeys[nb]                  (* 全キーを返す *)
NBListTaggingRuleKeys[nb, "prefix"]        (* prefixで始まるキーのみ返す *)

NBSetNotebookDefaultModel[nb, "anthropic", "claude-opus-4-8"]
(* ノートブックのデフォルトモデル (claudecode パレット設定 paletteProvider/paletteModelName) を書き換える。
   NBAccess以外がノートブック内部データを書き換えない原則に従い書き込みはNBAccessが行う。 *)

NBGetNotebookDefaultModel[nb]
(* ノートブックのデフォルトモデル {provider, modelName} を返す。未設定なら Missing["NotDeclared"]。 *)
```

## 汎用履歴データベース API

差分圧縮方式の履歴（会話ログ等）を TaggingRules に永続化する仕組みです。

```
NBHistoryCreate[nb, "myTag", {"fullPrompt", "response", "code"}]
(* 新しい履歴データベースを作成。diffFieldsは差分圧縮対象のフィールド名リスト。
   NBHistoryCreate[nb, tag, diffFields, headerOverrides] でヘッダーを上書き可能。
   既存DBに同じdiffFieldsがある場合は既存ヘッダーを返す(冪等)。 *)

NBHistoryAppend[nb, "myTag", <|"fullPrompt" -> "...", "response" -> "...", "code" -> "..."|>]
(* エントリを履歴に追加する。直前のエントリの fullPrompt/response/code を Diff で圧縮。
   オプション PrivacySpec -> ps で privacylevel をエントリに記録可能。 *)

NBHistoryData[nb, "myTag"]
(* TaggingRulesから履歴データを読み取り、差分圧縮されたエントリを復元して返す。
   オプション Decompress -> False で Diff オブジェクトのまま返す。
   戻り値: <|"header" -> <|...|>, "entries" -> {<|...|>, ...}|> *)

NBHistoryRawData[nb, "myTag"]      (* 差分圧縮を解除せずに履歴データを返す（内部用） *)

NBHistorySetData[nb, "myTag", <|"header" -> ..., "entries" -> {...}|>]
(* entries は差分圧縮されていない平文で渡すこと。自動的に圧縮される。 *)

NBHistoryEntries[nb, "myTag"]      (* 差分圧縮を復元した全エントリリストを返す。Decompress -> False も可 *)
NBHistoryUpdateLast[nb, "myTag", <|"response" -> "..."|>]   (* 最後のエントリを更新 *)
NBHistoryReadHeader[nb, "myTag"]
NBHistoryWriteHeader[nb, "myTag", header]

NBHistoryEntriesWithInherit[nb, "myTag"]
(* 親履歴を含む全エントリを返す。headerのparent/inherit/createdに従って親チェーンを辿る。
   オプション Decompress -> False も可。 *)

NBHistoryListTags[nb, "prefix"]    (* prefixで始まる履歴タグ一覧を返す *)
NBHistoryDelete[nb, "myTag"]
NBHistoryReplaceEntries[nb, "myTag", entries]   (* エントリリスト全体を置換。コンパクションやバッチ更新に使用 *)
NBHistoryUpdateHeader[nb, "myTag", <|"key" -> value|>]   (* 既存キーは上書き、新規キーは追加 *)
```

## セッションアタッチメント API

```
NBHistoryAddAttachment[nb, "myTag", "C:\\path\\file.png"]
(* セッションにファイルをアタッチする。ヘッダーの "attachments" リストにパスを追加（重複除去）。 *)
NBHistoryRemoveAttachment[nb, "myTag", "C:\\path\\file.png"]
NBHistoryGetAttachments[nb, "myTag"]
NBHistoryClearAttachments[nb, "myTag"]

NBHistoryClearAll[nb, "myTag", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
(* prefixで始まる全履歴を削除する。PrivacySpec -> <|"AccessLevel" -> 1.0|> が必須。
   セルレベルの機密・機密依存タグは削除しない。ノートブックを他者に渡す際の履歴情報除去用。 *)
```

## API キーアクセサ

```
NBGetAPIKey["anthropic", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
(* provider: "anthropic" | "openai" | "github"
   AccessLevel >= 1.0 が必須。呼び出し側で PrivacySpec -> <|"AccessLevel" -> 1.0|> を明示指定すること。
   SystemCredential へのアクセスを一元管理する。 *)

NBListProviderModels["anthropic"]
(* クラウドプロバイダ (anthropic / openai) の利用可能モデルIDリストを返す。
   APIキーは内部でSystemCredentialから読み、外部には出さない。
   返すのはモデル名リスト（秘匿性なし）だけなので、PrivacySpec / AccessLevel の指定は不要。
   戻り値: <|"Status" -> _, "Provider" -> _, "Models" -> {_String..}|> *)
```

## ローカル LLM サーバーの API キーアクセサ

```
NBGetLocalLLMAPIKey["lmstudio", "http://127.0.0.1:1234", PrivacySpec -> <|"AccessLevel" -> 1.0|>]
(* ローカルLLMサーバー (LM Studio等) のAPIキーをSystemCredentialから返す。照合は{provider, url}ペア。
   AccessLevel >= 1.0 が必須。
   解決優先度: (1)完全一致 (2)localhost⇔127.0.0.1置換版 (3){provider,"*"}ワイルドカード (4)フォールバック名 ToUpperCase[provider]<>"_API_KEY" *)

NBSetLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234", "LMSTUDIO_STUDY_KEY"]
(* {provider, url} -> credentialName のマッピングを登録する。SystemCredentialの実値自体は書き込まない（名前の紐付けのみ）。
   戻り値: {provider, normalizedUrl} -> credentialName の Rule *)

NBStoreLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234", "LMSTUDIO_STUDY_KEY", "sk-..."]
(* 上記マッピング登録に加えて SystemCredential[credentialName] = key も同時に設定する。初回セットアップ用。 *)

NBRemoveLocalLLMAPIKey["lmstudio", "http://192.168.1.10:1234"]
(* {provider, url}のエントリを削除する。SystemCredential本体は変更しない。 *)

NBLocalLLMAPIKeyMap[]
(* 現在登録されているローカルLLMサーバー→APIキー名マッピングをDatasetで返す。
   Configured列はSystemCredentialが実際に設定済みかどうかを示す。 *)

NBLocalLLMCredentialName["lmstudio", "http://127.0.0.1:1234"]
(* SystemCredential名のみを返す（値は取得しない）。AccessLevelチェックなし。登録確認用。 *)
```

## フォールバックモデル / プロバイダーアクセスレベル API

```
NBSetFallbackModels[{{"anthropic", "claude-opus-4-6"}, {"lmstudio", "gpt-oss-20b", "http://127.0.0.1:1234"}}]
(* models: {{"provider","model"}, {"provider","model","url"}, ...} *)

NBGetFallbackModels[]     (* フォールバックモデルリスト全体を返す *)

NBRegisterTrustedLocalServer[<|
  "MachineName" -> "phoenix", "Subnet" -> "192.168.2",
  "Provider" -> "lmstudio", "URL" -> "http://192.168.2.110:1234"
|>]
(* 信頼できるローカルLLMサーバを登録する。IP／サブネットはセキュリティ境界なのでNBAccessが管理する。
   モデル名（Qwenの枝番等）は含めない（それはSourceVaultがintent解決で扱う）。起動ファイルから呼んで信頼リストに追加する。 *)

NBResolveLocalServer[]
(* 現在のマシン環境 ($MachineNameと自IPのサブネット) を信頼リストと照合し、
   信頼できるローカルLLMサーバ <|"Provider" -> _, "URL" -> _, "Trusted" -> _, ...|> を返す。
   未知のサブネット(信頼リストに無い)では安全側に倒し、localhost (127.0.0.1) のローカルサーバのみを返す。
   リモートIPのLM Studioには信頼サブネット内でのみ接続する。モデル名は返さない (SourceVaultが解決)。 *)

NBTrustedLocalServers[]    (* 現在登録されている信頼ローカルサーバのリスト (Dataset) を返す *)

NBSyncClaudeModelVars[Verbose -> False]
(* SourceVaultにキャッシュされているモデルでClaudeCodeの $ClaudeModel / $ClaudeDocModel /
   $ClaudePrivateModel / $ClaudeFallbackModels を更新する。
   SourceVaultがintent割り当てマップ(SourceVaultModelIntentMap)を保持し、
   NBAccessがそれを読み取ってSourceVaultResolveでモデルIDに解決し、ローカルサーバのURLは
   NBResolveLocalServerで安全に解決して実変数へ代入する。モデル変数の代入はネットワーク情報
   ($ClaudePrivateModelのURL)を含むため、セキュリティ境界を管理するNBAccessに一元化する。
   SourceVault未ロードなら何もしない (claudecode単体の後方互換)。SourceVaultロード時に自動実行される。 *)

NBSetProviderMaxAccessLevel["anthropic", 0.5]
NBSetProviderMaxAccessLevel["lmstudio", 1.0]
(* プロバイダーの最大アクセスレベルを設定する。level: 0.0〜1.0。
   このレベルを超えるアクセスレベルのリクエストにはフォールバックしない。 *)

NBGetProviderMaxAccessLevel["anthropic"]    (* 未登録プロバイダーは0.5を返す *)

NBGetAvailableFallbackModels[0.8]
(* 指定アクセスレベルで利用可能なフォールバックモデルのリストを返す。
   プロバイダーのMaxAccessLevel >= accessLevelのモデルのみ含まれる。
   例: NBGetAvailableFallbackModels[0.8] → lmstudioのみ
       NBGetAvailableFallbackModels[0.5] → 全プロバイダー *)

NBProviderCanAccess["lmstudio", 1.0]
(* プロバイダーが指定アクセスレベルのデータにアクセス可能かを返す(True/False)。
   MaxAccessLevel >= accessLevelならTrue。 *)

NBModelCanHandleAccessLevel[{"anthropic", "claude-opus-4-8"}, 1.0]
(* モデル指定がそのアクセスレベルのデータを扱えるかを返す(True/False)。Privateノート(レベル1.0)で
   クラウドモデル(claudecode/anthropic/openai = 0.5)を拒否し、ローカルLLM(lmstudio = 1.0)のみを通すために使う。
   modelSpec: {provider, model} | {provider, model, url} | "model" | Automatic (未指定はTrue)。 *)

NBModelProviderName[{"anthropic", "claude-opus-4-8"}]   (* modelSpecからprovider文字列を取り出す *)

NBNotebookRequiredAccessLevel[nb]
(* ノートブックが要求するアクセスレベルを返す。
   Private宣言 (CloudPublishable -> False) なら1.0 (クラウド禁止)、それ以外は0.0。 *)
```

## アクセス可能ディレクトリ API

```
NBSetAccessibleDirs[nb, {"C:\\projects\\A", "C:\\projects\\B"}]
NBSetAccessibleDirs[{"C:\\projects\\A"}]     (* EvaluationNotebook[] に保存 *)

NBGetAccessibleDirs[nb]     (* 保存されたアクセス可能ディレクトリリストを返す *)
NBGetAccessibleDirs[]       (* EvaluationNotebook[] から取得 *)

NBResolvePathRef[pathRef]
(* PathRef (NBNormalizePathが返すAssociation、または{"$onWork", ...}形式のシンボリックパスリスト)を
   現PCの実パスへ解決する。現PCで解決でき実在すれば絶対パス文字列、解決できない
   (ルート未定義・別PCエイリアスのみ)ならMissing[...]を返す。
   SourceVaultがロード済みならiSVResolvePathを利用する。
   alias-only / root-missing なPathRefは実パスに解決されない。settings.jsonへのmaterializeには
   解決できたものだけを使う。 *)

NBSetAccessiblePathRefs[nb, refs]
(* AccessPathRefのリストをnotebookのTaggingRules (claudeAccessiblePathRefs) に保存する。
   NBSetAccessiblePathRefs[refs] はEvaluationNotebook[]に保存する。
   各AccessPathRefは <|"PathRef" -> _, "Mode" -> "List"|"Read"|"ReadWrite", "CloudSend" -> False|True|"Ask"|> のAssociation。
   claudeAccessiblePathRefsを正本(canonical)とし、旧claudeAccessibleDirsはreadフォールバックとしてのみ残す。
   PathRefは同一性であり、保存自体が権限を与えるものではない。 *)

NBGetAccessiblePathRefs[nb]
(* notebookに保存されたAccessPathRefのリストを返す。NBGetAccessiblePathRefs[]はEvaluationNotebook[]から取得。
   claudeAccessiblePathRefsが無い旧notebookでは、claudeAccessibleDirs(旧形式の絶対パスリスト)を
   AccessPathRefに変換して返す(readフォールバック)。
   戻り値はnotebookに永続化するcanonicalな参照リスト。実パスへの解決はNBResolvePathRef / NBGetAccessibleDirsで行う。 *)

NBNormalizeAccessPathRef["C:\\projects\\A"]
(* 旧形式の絶対パス文字列または部分的な指定を、完全なAccessPathRef Associationに正規化する。
   文字列が渡された場合はNBNormalizePathでPathRef化し、Mode -> "Read"、CloudSend -> "Ask"を既定とする。
   既にAccessPathRef Associationなら不足キーを既定で補う。NBSetAccessibleDirs互換ラッパが内部で使う。 *)
```

## カレンダーアクセス API (iCal/ICS)

所有者の iCal/ICS カレンダーを、`PrivacySpec` によるアクセスレベル制御のもとで読み取る API 群です。

```
NBCalendarEvents[from, to]
(* [from, to) と重なるイベント発生 (occurrence) を Start 順の Association リストで返す。
   RRULE (FREQ DAILY/WEEKLY/MONTHLY/YEARLY, INTERVAL, UNTIL, COUNT,
   BYDAY(序数付き 2MO 等)/BYMONTHDAY(負数含む), EXDATE, RECURRENCE-ID による
   上書き・キャンセル) を展開する。
   返すフィールドはアクセスレベル (PrivacySpec、既定 $NBPrivacySpec) に応じて変わる:
     >=0.5: Start/End/AllDay/Busy/Mandatory/Recurring/UIDDigest +
            R0b識別情報 (EventId/OriginalStart/SemanticDigest/ObservedRevision)
     >=0.7: 上記 + Summary/Categories/Status
     >=1.0: 上記 + Description/Location/UID (フルフィールド)
   0.5未満は Failure["NBCalendarAccessDenied"] を返す。
   R0b識別情報 (どのアクセスレベルでも返る不透明な値):
     "EventId": UID の HMAC鍵付き安定ID ($NBCalendarIdentityKeyRef、未鍵なら "unkeyed:<digest>")。
                同一の繰り返しイベントではoccurrence間で共通。
     "OriginalStart": occurrenceの本来のシリーズ位置 (上書き時はRECURRENCE-ID)。
     "SemanticDigest": Start/End/Status/Busy/AllDay等の意味的内容のダイジェスト (差し替え検出用)。
     "ObservedRevision": SEQUENCE/DTSTAMPのダイジェスト (観測用、DTSTAMPのみの変更では変化しない)。 *)

NBCalendarFreeBusy[from, to]
(* [from, to) 内のマージ済みビジーブロックを {<|"Start","End","Mandatory","Count"|>, ...} で返す。
   重なるビジーイベントは1ブロックに統合される。TRANSP:TRANSPARENT のイベントは除外。
   内容を含まない (メタデータのみ) ためAccessLevel 0.5から利用可能。
   NBCalendarEvents と同じソースオプションを取る。 *)

NBCalendarBusyQ[t]
(* 時刻 t がビジーブロック内にあれば True を返す (会議中判定)。
   "Detailed" -> True で <|"Busy", "Mandatory", "Block"|> を返す。
   ソースが利用不可の場合は Failure ではなく False を返す (通知ゲーティングは「ビジーでない」側に倒す)。
   NBCalendarEvents と同じソースオプションを取る。 *)

NBICSParseEvents[icsText]
(* 生の iCal/ICS テキストを解析し、イベント Association のリスト
   (UID/Summary/Description/Location/Status/Categories/Busy/Start/End/AllDay/RRule/ExDates/RecurrenceId)
   を返す。純粋なパーサーで credential・ネットワーク・アクセス制御は行わない。
   壊れた VEVENT ブロックはスキップされる。折り返し行・TEXT エスケープ・
   TZID/UTC/floating 各形式・VALUE=DATE (終日) 形式・DURATION に対応。 *)

NBICSEventOccurrences[event, from, to]
(* NBICSParseEvents で得た1イベントを [from, to) と重なる occurrence に展開する。
   RRULE/EXDATE の意味論は NBCalendarEvents と同じ。純粋関数。
   occurrenceのStart/Endと"Recurring" -> True|Falseを含むAssociationリストを返す。 *)
```

`NBCalendarEvents` のオプション: `PrivacySpec -> Automatic`、`"Source" -> Automatic`（`SystemCredential[$NBCalendarCredentialName]`、または明示的な `.ics` パス/URL）、`"ICSText" -> Missing["None"]`（生ICSテキストを直接渡すテスト用シーム。`Source` を無視）、`"MandatoryPatterns" -> Automatic`（`$NBCalendarMandatoryPatterns`）、`"MaxEvents" -> 500`、`"Refresh" -> False`（パースキャッシュを無視）、`"Wrap" -> False`（`True` で `<|"Events"->{...}, "ObservedAtUTC", "Count", "Truncated", "Completeness"(MaxEventsで打ち切られた場合は1未満), "IdentityKeyed"|>` を返す）。`NBCalendarFreeBusy`/`NBCalendarBusyQ` も同じソース関連オプション（`PrivacySpec`/`"Source"`/`"ICSText"`/`"MandatoryPatterns"`/`"Refresh"`）を取り、`NBCalendarBusyQ` はさらに `"Detailed" -> False` を持ちます。

グローバル変数:

- `$NBCalendarMandatoryPatterns` — 出席必須イベントとみなす文字列パターンの既定リスト（Summary/Categories/Description に大文字小文字を無視してマッチ）。既定 `{}`。導出される Mandatory フラグは全アクセスレベルで公開されます。
- `$NBCalendarCacheSeconds` — `NBCalendarEvents` が使うカレンダーソースのインメモリ・パースキャッシュ TTL（秒）。既定 300。
- `$NBCalendarCredentialName` — ICS カレンダーの所在（ファイルパスまたは URL）を保持する SystemCredential キー名。既定 `"ics-calendar"`。
- `$NBCalendarIdentityKeyRef` — 各イベントの不透明で安定な `"EventId"` を導出する HMAC 鍵を保持する SystemCredential キー名（署名鍵とは別管理）。既定 `Missing["None"]`（未設定時は `EventId` が `"unkeyed:<digest>"` 形式に縮退し、`"Wrap"->True` は `"IdentityKeyed"->False` を報告します）。鍵をローテーションすると埋め込まれた KeyId が変わるため、保存済み EventId マッピングの移行が必要になります。

## $onWork タスクメタデータ API

`$onWork` 配下の `.nb` ファイルからタスクメタデータのみを、評価を一切行わずに安全に読み取る API 群です（ノートブック本文・出力は読みません）。

```
NBOnWorkTaskSafeExtract[held]
(* HELD式 (HoldComplete[...] や Hold[...] でラップされたメタデータ Association、
   またはその先頭要素がそれであるリスト) から $onWork タスクメタデータを
   一切評価せずに抽出する。ホワイトリストされた文字列キー
   (Title/Status/Deadline/NextReview/EventDate/Keywords/Effort/Movable/DependsOn/TaskId/MailRecordId) の
   リテラル値 (String/Integer/Real/True/False/DateObject[{整数...},(粒度)]/Quantity[数,単位]/
   文字列リスト) のみが保持され、それ以外のキー・値は破棄される。
   副作用式・Notebook box・巨大な式・UpValueを持つシンボルは決して評価されない。
   実装にReleaseHoldを含まない (静的検査AC-033)。安全なAssociationを返す。
   Notebook box セルに加え、テキストコンテンツセル（メール由来ノートブック等）も
   非評価パース (ToExpression[..., InputForm, HoldComplete]) で扱えるようになった。 *)

NBOnWorkTasks[]
(* $onWork 配下の .nb ファイルを列挙し、NBOnWorkTaskSafeExtract 経由で読んだ
   メタデータのみをアクセスレベルに応じて射影したタスクレコードのリストを返す。
   各レコードは "Due" (Deadline、無ければNextReview；NextReviewがQuantityの場合は
   ModificationDate + オフセットとして解決、NotebookExtensionsと同じ挙動) と
   "State" (StatusからDone/Pass/Keep、無ければOpen) を導出する。
   アクセスレベル別フィールド:
     0.5: Due/DueKind/State/FileDigest/ModificationDate
     0.7: 上記 + Title/Keywords/TaskId/Effort/Movable/DependsOn
     1.0: 上記 + Path
   読み取り不可・安全パース失敗のファイルは "State"->"Unknown", "ParseFailed"->True の
   レコードになり、スキャン全体は中断しない。 *)
```

`NBOnWorkTasks` のオプション: `"Directory" -> Automatic`（`Global`$onWork`）、`"ModifiedWithinDays" -> Automatic`（既定は全件）、`"IncludeDone" -> False`（Status が Done/Pass のものを除外）、`PrivacySpec -> Automatic`、`"MaxFiles" -> 2000`、`"Files" -> Automatic`（テスト用シーム: `{<|"Path"->_, "Held"->HoldComplete[...], ("ModificationDate"->_)|>, ...}` でファイルシステムを迂回）。

## その他

```
NBMoveToEnd[nb]     (* ノートブックの末尾にカーソルを移動 *)
```

---

以上が現時点でのソースコードに定義されている公開シンボルです。今回のドキュメント更新時点での確認では、公開関数・オプションの追加/削除はありませんでした。唯一の変更点は `$onWork` タスクメタデータ抽出（`NBOnWorkTaskSafeExtract`/`NBOnWorkTasks`）の内部実装（Private コンテキスト）に対する堅牢性向上です: (1) 安全に抽出できるキーのホワイトリストに `"MailRecordId"` が追加され、メール由来のタスクレコードなどを想定した拡張が行われました。(2) Notebook box 形式のセルに加え、テキストコンテンツ形式のセル（メール由来ノートブック等）も `ToExpression[..., InputForm, HoldComplete]` による非評価パースで扱えるようになりました。これらはいずれも公開関数のシグネチャや `::usage` 文字列、オプション体系には影響しません。