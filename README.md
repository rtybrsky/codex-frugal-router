# Codex Frugal Router

English | [繁體中文](README.zh-TW.md)

A quality-gated model routing skill for Codex that handles routine work with lower-cost model tiers and escalates only when task complexity or risk requires it.

Codex Frugal Router uses Luna Max for routine inspection and deterministic checks, Terra Max for non-trivial engineering work, and Sol Medium for architecture or high-risk decisions. Instead of repeated model reviews, it prefers verification evidence from tests, compilers, type checkers, linters, and executable checks.

> [!NOTE]
> **Status: Experimental.** The routing and escalation workflow is implemented and usable. Exact per-task token measurement depends on usage data exposed by the Codex host.

## Quick Start

### Requirements

- Windows 10 or 11
- Codex Desktop or Codex CLI
- Windows PowerShell 5.1 or PowerShell 7+

### Installation

```powershell
git clone https://github.com/rtybrsky/codex-frugal-router.git
cd codex-frugal-router
.\install.ps1 -SkipMcp
```

Restart Codex or start a new task after installation. For a true Luna-first workflow, select Luna Max when creating the task; a skill cannot change the main model of an existing task.

### Usage

```text
$codex-frugal-router

Inspect the current project and count all .md, .py, and .js files.
Do not modify any files. Report the model used and whether work was delegated.
```

Additional T1, T2, and T3 prompts are available in [Usage Examples](docs/examples.md).

## Features

- Routes work to the lowest model tier that can complete it reliably.
- Escalates a deliverable at most once under normal operation.
- Uses compact handoffs instead of forwarding full conversations or file trees.
- Prefers automated checks over routine second-model review.
- Keeps measurement disabled during normal tasks to avoid fixed tracking overhead.
- Supports optional workflow comparison with privacy-filtered usage observations.

## Routing Strategy

| Tier | Model | Typical work |
|---|---|---|
| T1 | Luna Max | File inspection, search, summaries, statistics, and existing checks |
| T2 | Terra Max | Implementation, debugging, tests, and localized multi-file changes |
| T3 | Sol Medium | Architecture, data models, security, migration, and cross-module decisions |

```text
Task
 ├─ T1 → Luna Max  ────────┐
 ├─ T2 → Terra Max ────────┤→ automated verification → delivery
 └─ T3 → Sol Medium ───────┘
```

If the current task is not already running on Luna Max, the skill applies the same thresholds without launching Luna solely for classification. This avoids adding a model call for routing overhead.

## How It Works

1. Classify the task using ambiguity, impact, reasoning depth, failure cost, and verification difficulty.
2. Complete T1 work directly or delegate once to the required T2/T3 tier.
3. Pass only the goal, verified facts, file scope, constraints, completion criteria, and checks.
4. Validate the result with the cheapest reliable automated evidence available.
5. Request targeted Sol judgment only when deterministic verification is unavailable or risk justifies it.

Detailed operating rules are maintained in:

- [Routing and escalation](codex-frugal-router/references/routing.md)
- [Compact handoff format](codex-frugal-router/references/handoff.md)
- [Measurement rules](codex-frugal-router/references/measurement.md)

## Optional Statistics MCP

Normal tasks do not call a statistics service. Optional A/B measurement uses the `project-orchestrator-stats` MCP server from [Codex Project Orchestrator](https://github.com/rtybrsky/codex-project-orchestrator).

Place both repositories in the same parent directory and run:

```powershell
.\install.ps1 -ReplaceMcp
```

Alternatively, provide its location explicitly:

```powershell
.\install.ps1 `
  -StatsProjectRoot "C:\path\to\codex-project-orchestrator" `
  -ReplaceMcp
```

See [Benchmarking and Measurement](docs/benchmarking.md) for experiment design, attribution limits, and interpretation guidance.

## Project Structure

```text
codex-frugal-router/
├─ README.md
├─ README.zh-TW.md
├─ LICENSE
├─ install.ps1
├─ tests/
│  └─ install-smoke.ps1
├─ docs/
│  ├─ examples.md
│  └─ benchmarking.md
└─ codex-frugal-router/
   ├─ SKILL.md
   ├─ agents/
   │  └─ openai.yaml
   └─ references/
      ├─ routing.md
      ├─ handoff.md
      └─ measurement.md
```

## Development and Testing

Run the standalone installation smoke test with Windows PowerShell:

```powershell
.\tests\install-smoke.ps1
```

The test parses `install.ps1`, performs an isolated core-skill installation, and verifies that the installed `SKILL.md` matches the source. Tests for the optional statistics MCP are maintained in the companion orchestrator repository.

## Privacy

Measurement metadata is restricted to allow-listed routing labels, outcomes, usage windows, and exact token totals only when supplied by the host. It must not include prompts, model responses, source code, diffs, account identifiers, credentials, or raw host payloads.

## Limitations

- A skill cannot change the main model of an existing Codex task.
- Exact task-level token counts are unavailable when the host does not expose complete run usage.
- Account quota windows may be affected by other concurrent tasks.
- The optional statistics MCP is distributed through the companion orchestrator repository.
- Routing behavior depends on available models, host capabilities, and the clarity of the task request.

## License

This project is licensed under the [MIT License](LICENSE).
