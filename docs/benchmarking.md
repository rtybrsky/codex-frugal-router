# Benchmarking and Measurement

Measurement is optional and disabled during normal tasks. It requires the `project-orchestrator-stats` MCP server from [Codex Project Orchestrator](https://github.com/rtybrsky/codex-project-orchestrator).

## Experiment Design

Run the baseline and candidate workflows with the same:

- task prompt and initial files;
- completion criteria;
- automated checks;
- `comparison_label` and `project_label`.

Use `large-orchestrator` as the baseline `workflow_label` and `frugal-router` as the candidate label. Avoid running other Codex tasks during quota-window measurement, and collect at least five comparable runs per workflow before interpreting a trend.

## Example

Baseline:

```text
$codex-project-orchestrator

Complete this task in measurement mode.
Use comparison_label router-ab-v1 and project_label benchmark-01.
```

Candidate:

```text
$codex-frugal-router

Complete the same task in measurement mode.
Use comparison_label router-ab-v1 and project_label benchmark-01.
```

After collecting both groups:

```text
Compare large-orchestrator and frugal-router for router-ab-v1.
Report token or quota differences, success rate, correction rate,
and whether the quality guardrail passed.
```

## Interpretation

- Prefer average `exact_total_tokens` when the host supplies complete run usage.
- Treat quota-window deltas as account-wide observations, not task attribution.
- Keep general Codex and Luna base-model quota buckets separate; their percentages are not additive.
- Require candidate success rate to be no lower than baseline and correction rate to be no higher.
- Concurrent tasks, resets, and window changes can make quota comparisons unavailable or unreliable.

The detailed field contract and privacy allow-list are defined in [the skill measurement reference](../codex-frugal-router/references/measurement.md).
