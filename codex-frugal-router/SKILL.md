---
name: codex-frugal-router
description: Route everyday Codex work from Luna Max to Terra Max or Sol only when task difficulty requires it. Use when minimizing token and model quota usage matters; avoid for user-requested multi-model review or large-project orchestration where parallel deliverables are the primary goal.
---

# Codex Quality-First Frugal Router

以「最低足夠能力」完成工作：預設讓 Luna Max 接收任務，只有證據顯示任務超出該層級時才升級。品質底線不因節省額度而降低；用工具產生的可重現證據取代重複模型審查。

## 核心路由

| 任務 | 唯一主責模型 |
|---|---|
| 讀檔、搜尋、盤點、統計、摘要、執行明確指令 | `gpt-5.6-luna`, `max` |
| 一般程式修改、常規除錯、測試補強、多檔案但局部的工程工作 | `gpt-5.6-terra`, `max` |
| 複雜分析、架構／資料模型、跨模組取捨、安全或高風險決策 | `gpt-5.6-sol`, `medium` |

日常任務應從 Luna Max 開始。若目前主線程已是 Luna Max，直接評估並處理；若不是，不要為了形式再啟動 Luna，直接套用相同門檻，避免額外一次模型呼叫。不要固定 Sol-first。

## 執行方式

1. 先判斷使用者要的是讀取／分析，還是實際修改。若只需 Luna 能可靠完成的工作，直接完成，不建立子代理。
2. 若必須升級，讀取 [路由與升級規則](references/routing.md)，只啟動一個所需層級的代理。使用 `fork_turns: "none"`，只交付必要背景與檔案範圍。
3. Luna 已取得的事實要放入精簡 handoff，後續模型沿用，不重新掃描整個專案。格式見 [精簡交接](references/handoff.md)。
4. 預設單代理到底。只有至少兩個互不依賴、寫入範圍不重疊、且平行處理明顯省時時才分工；不要為展示模型分層而啟動多個代理。
5. 以最便宜的可靠 oracle 驗證：優先使用 `rg`、diff、現有測試、編譯器、型別檢查、lint、Node/Python 指令或結構化資料檢查。
6. 工具驗證通過且風險中低時直接交付。不要讓另一模型從頭複查同一成果；只有缺乏可靠 oracle 或涉及架構、安全、資料遺失、公開介面時才做 Sol 的針對性判斷。

## 額度護欄

- 每個成果最多升級一次：Luna → Terra 或 Luna → Sol；Terra 只有發現 T3 風險時才交給 Sol。
- 不把完整對話、完整檔案樹、冗長日誌或已知無關檔案傳給代理。
- 不輪詢代理；等待其完成或需要協助的事件。回報只保留結論、變更、驗證與未解風險。
- 能由當前模型安全完成時不委派；委派的背景成本若接近工作本身，當前模型直接完成。
- 模型不可用時，先完成安全且可驗證的部分，再說明未完成範圍；不要靜默改用更弱模型處理高風險決策。

## 可選量測模式

正常日常工作不呼叫統計 MCP，因為量測本身也有少量工具與上下文成本。只有使用者明確要求「量測、benchmark、A/B 比較、確認是否省額度」時，才依 [量測規則](references/measurement.md) 使用共用的 `project-orchestrator-stats` MCP。

量測模式必須在任何委派前取得開始快照，`record_plan` 固定填入 `workflow_label: "frugal-router"`，完成驗證後再取得結束快照並呼叫 `finish_run`。只有宿主提供整個 run 的精確 usage 時才填 `token_usage`；不得估算 token。統計失敗不阻斷主要工作。

## 完成條件

交付前確認使用者要求已滿足、修改未越界、驗證與風險相稱，並簡短列出已完成內容、驗證結果與任何剩餘風險。不要回報內部逐步推理或為路由本身寫長篇說明。
