# Codex Frugal Router

一套以品質為底線、以額度節省為目標的 Codex 模型路由 demo。

它讓日常 task 從 **GPT-5.6 Luna Max** 開始，只有在工作難度、影響範圍或風險超過門檻時，才升級到 **Terra Max** 或 **Sol Medium**。流程不固定 Sol-first、不做重複模型審查，並優先用測試、編譯器、型別檢查與 Node/Python 指令驗證成果。

> 專案狀態：可公開展示的 MVP／完整概念 demo。路由、升級、精簡 handoff、工具驗證與 A/B 統計流程均已實作；它不是帳務或計費系統，能否取得單次 task 的精確 token 仍取決於 Codex 宿主提供的資料。

## 為什麼做這個專案

多模型工作流常用最強模型先規劃，再啟動多個模型實作與審查。這能提高大型專案的控制力，卻可能讓讀檔、搜尋、統計或小修改也承擔不必要的模型成本。

本專案採用相反方向：

1. 從最低足夠能力開始。
2. 只有出現明確證據才升級一次。
3. 已有可靠工具 oracle 時，不再請另一個模型重做審查。
4. 量測模式與日常模式分離，避免統計本身抵銷小任務的節省。

## 路由策略

| 等級 | 模型設定 | 適合工作 |
|---|---|---|
| T1 | Luna Max | 讀檔、搜尋、統計、摘要、執行既有檢查 |
| T2 | Terra Max | 一般修改、常規除錯、測試與局部多檔案工程 |
| T3 | Sol Medium | 架構、資料模型、跨模組取捨、安全與高風險決策 |

```text
使用者任務
    ↓
Luna Max 判斷難度
    ├─ T1：直接完成 ──────────────┐
    ├─ T2：精簡交接給 Terra Max ─┤
    └─ T3：精簡交接給 Sol Medium ┤
                                  ↓
                    測試／編譯器／指令驗證
                                  ↓
                              完整交付
```

若目前 task 不是 Luna Max，skill 不會為了形式額外啟動一次 Luna；它會直接套用相同門檻，避免新增一輪模型呼叫。

## 主要功能

- Luna-first 的三級難度路由。
- 每個成果原則上最多升級一次。
- 約 150 字的精簡模型 handoff，避免重傳完整對話與檔案樹。
- 以 deterministic tools 取代例行性的第二模型複查。
- 一般模式不呼叫統計 MCP。
- 可選 A/B 量測模式，分開比較精確 token、一般 Codex 額度、Luna base-model 額度與品質指標。
- 統計資料只保存白名單化欄位，不保存 prompt、原始碼、diff、帳號 ID 或秘密。

## 專案結構

```text
AI Agent品質優先但客家系統/
├─ README.md
├─ install.ps1
└─ codex-frugal-router/
   ├─ SKILL.md
   ├─ agents/
   │  └─ openai.yaml
   └─ references/
      ├─ routing.md
      ├─ handoff.md
      └─ measurement.md
```

完整的 A/B 量測 demo 會共用 `AI Agent大型專案自動分工與完整交付系統` 裡的 `project-orchestrator-stats` MCP。核心路由 skill 可獨立安裝；統計元件是可選功能。

## 系統需求

- Windows 10/11
- Codex Desktop 或 Codex CLI
- Windows PowerShell 5.1 或 PowerShell 7+
- Node.js（只有啟用統計 MCP 時需要）

## 安裝

### 只安裝核心路由

```powershell
cd "C:\path\to\AI Agent品質優先但客家系統"
.\install.ps1 -SkipMcp
```

### 安裝路由與統計 MCP

若大型編排專案位於同一層，安裝器會自動找到它：

```text
side project/
├─ AI Agent品質優先但客家系統/
└─ AI Agent大型專案自動分工與完整交付系統/
```

```powershell
.\install.ps1 -ReplaceMcp
```

也可以明確指定統計專案：

```powershell
.\install.ps1 `
  -StatsProjectRoot "C:\path\to\AI Agent大型專案自動分工與完整交付系統" `
  -ReplaceMcp
```

安裝後重新啟動 Codex 或建立新 task。Skill 無法替目前 task 切換主線程模型；若要真正 Luna-first，請建立 task 時選擇 Luna Max。

## 快速 Demo

### 1. T1：唯讀統計

```text
$codex-frugal-router

只讀取目前專案，統計有多少個 .md、.py、.js 檔案，
列出數量最多的五個資料夾。不要修改任何檔案。
最後說明實際使用的模型與是否有委派。
```

預期：由 Luna Max 單獨處理，使用搜尋或 shell 統計，不啟動其他模型。

### 2. T2：一般修改

```text
$codex-frugal-router

建立一個臨時 router-test 資料夾，新增 sum.js 與 Node 測試，
實作 sum(a, b)，並執行 node --test 驗證。
最後說明實際使用的模型與驗證結果。
```

預期：依修改範圍交給 Terra Max，並用 `node --test` 驗證；不啟動重複審查。

### 3. T3：架構分析

```text
$codex-frugal-router

分析目前 MCP server。評估如果要拆分儲存層、統計層與 protocol 層，
應採用什麼架構，並分析資料相容性、遷移與安全風險。
只分析，不修改檔案。
```

預期：交由 Sol Medium 處理複雜架構與風險判斷。

## 如何驗證是否真的省額度

不要只比較一次。準備一組固定 benchmark，確保兩個工作流使用相同題目、初始檔案、完成條件與測試。兩組使用相同 `comparison_label`、`project_label`，但 workflow 分別為 `large-orchestrator` 與 `frugal-router`。

大型編排基準組：

```text
$codex-project-orchestrator

以量測模式完成這個任務。
comparison_label 使用 router-ab-v1，project_label 使用 benchmark-01。
```

省額度候選組：

```text
$codex-frugal-router

以量測模式完成完全相同的任務。
comparison_label 使用 router-ab-v1，project_label 使用 benchmark-01。
```

每組至少累積 5 個 run，再要求比較：

```text
比較 router-ab-v1 的 large-orchestrator 與 frugal-router，
說明 token／額度差異、成功率、修正率與品質護欄是否通過。
```

### 判讀原則

- 有完整 run usage 時，優先比較平均 `exact_total_tokens`。
- 沒有精確 token 時，只能將額度窗口視為帳號共享趨勢。
- 一般 Codex 與 Luna base-model 是不同 bucket，不能把百分比直接相加。
- 候選組成功率不得低於基準組，修正率不得高於基準組。
- 其他 task 同時執行可能污染帳號共享的額度差值。

完整欄位與隱私規則請見 [measurement.md](codex-frugal-router/references/measurement.md)。

## 測試狀態

統計 MCP 測試涵蓋 protocol、tool schema、路由紀錄、reset 處理、精確 token 驗證、A/B 比較、品質護欄、舊 JSONL 相容性與敏感欄位過濾。

目前已驗證 14 項 Node 測試全部通過，並通過 Windows PowerShell 5.1 安裝測試。

## 隱私與安全

統計元件不應保存完整 prompt、模型回覆、原始碼、diff、工具日誌、帳號識別資料、API key、密碼、cookie 或原始 usage payload。量測失敗不應阻斷主要工作，也不應為了補統計而重跑模型。

## 已知限制

- Codex skill 不能自行切換目前 task 的主線程模型。
- Codex Desktop 若未暴露完整 run usage，就無法得到精確 task token。
- 額度窗口是帳號共享觀察值，容易受到其他 task 影響。
- 統計 MCP 目前由同層的大型編排 demo 共用，尚未打包成獨立發行套件。
- 路由結果仍取決於需求描述、可用模型與宿主能力。

## 放到 GitHub

建議 repository 名稱：`codex-frugal-router`。

### 方法 A：使用 GitHub CLI

先在此資料夾開啟 PowerShell：

```powershell
git init -b main
git add .
git commit -m "Initial release: Codex frugal router demo"
gh auth login
gh repo create codex-frugal-router --public --source . --remote origin --push
```

### 方法 B：使用 GitHub 網站

1. 登入 GitHub，按右上角 `+` → `New repository`。
2. Repository name 填 `codex-frugal-router`，選擇 `Public`。
3. 不要勾選自動建立 README、`.gitignore` 或 License，避免第一次 push 衝突。
4. 建立後，在本資料夾執行：

```powershell
git init -b main
git add .
git commit -m "Initial release: Codex frugal router demo"
git remote add origin https://github.com/<你的帳號>/codex-frugal-router.git
git push -u origin main
```

上傳前建議執行 `git status` 與 `git diff --cached`，確認沒有本機 `.codex` 設定、usage JSONL、API key、私人路徑截圖或暫存資料。

## 後續方向

- 將統計 MCP 打包為本 repository 的獨立可安裝元件。
- 建立固定 benchmark fixture 與可重複執行的報表。
- 加入跨平台 Bash 安裝腳本。
- 在宿主提供精確 usage 時，自動輸出 Markdown／CSV 比較結果。

## License

目前尚未加入開源 License。若要讓別人合法重用、修改與散布，建議上傳前選擇 MIT License；若只想公開展示而不授權重用，可先維持無 License。
