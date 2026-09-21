# Codex Frugal Router

[English](README.md) | 繁體中文

Codex Frugal Router 是一套具品質門檻的模型路由 skill。它讓例行工作使用成本較低的模型層級，只有在任務複雜度或風險需要時才升級。

系統以 Luna Max 處理例行盤點與確定性檢查、Terra Max 處理非平凡工程工作，並由 Sol Medium 處理架構與高風險決策。它優先採用測試、編譯器、型別檢查、lint 與可執行檢查提供驗證證據，而不是例行啟動另一個模型重做審查。

> [!NOTE]
> **狀態：Experimental。** 路由與升級流程已實作並可使用；能否取得單一 task 的精確 token，取決於 Codex 宿主是否提供完整 usage 資料。

## 快速開始

### 系統需求

- Windows 10 或 11
- Codex Desktop 或 Codex CLI
- Windows PowerShell 5.1 或 PowerShell 7+

### 安裝

```powershell
git clone https://github.com/rtybrsky/codex-frugal-router.git
cd codex-frugal-router
.\install.ps1 -SkipMcp
```

安裝後重新啟動 Codex 或建立新 task。若要真正採用 Luna-first，請在建立 task 時選擇 Luna Max；skill 無法改變既有 task 的主線程模型。

### 使用方式

```text
$codex-frugal-router

只讀取目前專案，統計所有 .md、.py、.js 檔案。
不要修改檔案，最後說明實際使用的模型與是否有委派。
```

更多 T1、T2、T3 範例請見 [Usage Examples](docs/examples.md)。

## 主要功能

- 將工作交給能可靠完成它的最低模型層級。
- 一般情況下，每個成果最多升級一次。
- 使用精簡 handoff，避免傳送完整對話或檔案樹。
- 以自動化檢查取代例行性的第二模型審查。
- 日常工作不啟用量測，避免固定統計成本。
- 支援經過隱私過濾的可選工作流比較。

## 路由策略

| 等級 | 模型 | 適合工作 |
|---|---|---|
| T1 | Luna Max | 讀檔、搜尋、摘要、統計與既有檢查 |
| T2 | Terra Max | 實作、除錯、測試與局部多檔案修改 |
| T3 | Sol Medium | 架構、資料模型、安全、遷移與跨模組決策 |

如果目前 task 並非 Luna Max，skill 會直接套用相同門檻，不會只為了分類而額外啟動 Luna。

## 運作方式

1. 依歧義、影響範圍、推理深度、失敗代價與驗證難度分類任務。
2. 直接完成 T1，或將成果委派一次給需要的 T2／T3 層級。
3. 只交接目標、已驗證事實、檔案範圍、限制、完成條件與檢查方式。
4. 使用成本最低且可靠的自動化證據驗證成果。
5. 只有無法確定性驗證或風險足夠高時，才要求 Sol 做針對性判斷。

詳細規則位於：

- [路由與升級](codex-frugal-router/references/routing.md)
- [精簡交接格式](codex-frugal-router/references/handoff.md)
- [量測規則](codex-frugal-router/references/measurement.md)

## 可選統計 MCP

一般工作不呼叫統計服務。A/B 量測使用 [Codex Project Orchestrator](https://github.com/rtybrsky/codex-project-orchestrator) 提供的 `project-orchestrator-stats` MCP。

將兩個 repository 放在同一層後執行：

```powershell
.\install.ps1 -ReplaceMcp
```

或明確指定位置：

```powershell
.\install.ps1 `
  -StatsProjectRoot "C:\path\to\codex-project-orchestrator" `
  -ReplaceMcp
```

實驗設計與歸因限制請見 [Benchmarking and Measurement](docs/benchmarking.md)。

## 開發與測試

```powershell
.\tests\install-smoke.ps1
```

這項測試會解析 `install.ps1`、執行隔離的核心 skill 安裝，並確認安裝後的 `SKILL.md` 與來源相同。可選統計 MCP 的測試位於搭配使用的 orchestrator repository。

## 隱私

量測資料僅限白名單化的路由標籤、結果、額度窗口，以及宿主提供時的精確 token。不得保存 prompt、模型回覆、原始碼、diff、帳號識別資料、憑證或原始宿主 payload。

## 限制

- Skill 無法改變既有 Codex task 的主線程模型。
- 宿主未提供完整 run usage 時，無法取得精確 task token。
- 帳號額度窗口可能受到其他同時執行的 task 影響。
- 可選統計 MCP 由搭配使用的 orchestrator repository 發布。
- 路由行為取決於可用模型、宿主能力與需求清晰度。

## License

本專案採用 [MIT License](LICENSE)。
