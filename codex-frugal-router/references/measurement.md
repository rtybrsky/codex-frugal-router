# 省額度路由量測規則

只有使用者明確要求量測或比較時啟用。一般任務維持零統計呼叫，避免為了省額度而增加固定成本。

## 執行順序

1. 在任何模型委派與實質工作之前讀取一次宿主 `get_usage_limits`，白名單化為 `start_usage`。
2. 呼叫 `record_plan`。即使不委派也記一個代表整體工作的 task，並填入：
   - `comparison_label`：同一輪 A/B 實驗共用名稱，例如 `router-ab-v1`。
   - `project_label`：基準組和候選組共用的專案或題組名稱。
   - `workflow_label`：固定為 `frugal-router`。
   - task tier：實際承擔成果的層級；不要把未使用的模型寫入 plan。
3. 完成工作並用測試、編譯器或其他確定性 oracle 驗證後，呼叫 `record_task_result`。
4. 最終回覆前立刻再次讀取 `get_usage_limits`，白名單化為 `end_usage`，再呼叫 `finish_run`。
5. 基準與候選各至少累積 5 個相似 run 後，呼叫 `compare_workflows`。大型編排基準使用 `workflow_label: "large-orchestrator"`，省額度候選使用 `workflow_label: "frugal-router"`。

MCP 或 usage 讀取失敗時省略該筆資料並照常完成工作，不要重跑模型。

## Usage 白名單

從 `get_usage_limits.rateLimitsByLimitId` 取得：

- 一般 Codex bucket 的 `primary`、`secondary` 對應頂層同名窗口。
- `base_model_inference` bucket 的 `primary`、`secondary` 對應 `base_model.primary`、`base_model.secondary`。這通常可觀察 Luna 額度，但仍是帳號共享窗口。

每個窗口只傳下列三個數字，且三者齊全才傳送：

```json
{
  "used_percent": 12.5,
  "window_duration_mins": 300,
  "resets_at": 1800000000
}
```

若宿主只有舊版 `rateLimits`，可用它作為一般 Codex bucket。若另有日級 account usage，才可傳 `daily_tokens`。不得保存 limit ID、account ID、reset-credit ID、原始 payload、prompt、原始碼、diff、秘密或工具日誌。

## 精確 token

若宿主或 Responses API 明確提供「整個本次 run」的 usage，`finish_run.token_usage` 可傳：

```json
{
  "source": "responses_api",
  "input_tokens": 1000,
  "cached_input_tokens": 200,
  "output_tokens": 300,
  "reasoning_tokens": 100,
  "total_tokens": 1300
}
```

`source` 也可為 `host`。所有值必須是非負整數，cached 不得大於 input、reasoning 不得大於 output，且 total 必須等於 input 加 output。若無法取得完整 run 的精確值，就完全省略 `token_usage`，不得用字數、檔案大小、額度百分比或模型價格反推。

## A/B 判讀

基準組與候選組應使用相同題目、相同初始檔案、相同完成條件與相同驗證。避免兩組同時執行，否則帳號共享窗口容易互相污染。

`compare_workflows` 優先比較平均 `exact total tokens`；其次只把一般 Codex與 `base_model` 的窗口變化分開呈現，不能把不同 bucket 的百分比直接相加。只有候選組成功率不低於基準組時，`quality_guardrail_passed` 才會通過。額度窗口與 daily tokens 都是帳號共享觀察值，精確歸因不可用時只能稱為趨勢，不能宣稱已證明單一 task 省下多少 token。

建議呼叫方式：

```text
$codex-frugal-router 以量測模式完成這個任務；comparison_label 使用 router-ab-v1，project_label 使用同一題組名稱。
```
