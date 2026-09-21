# Usage Examples

These examples exercise each routing tier. Actual delegation depends on the active model, available models, task context, and host capabilities.

## T1: Read-only inventory

```text
$codex-frugal-router

Inspect the current project and count all .md, .py, and .js files.
List the five directories containing the most matching files.
Do not modify any files. Report the model used and whether work was delegated.
```

Expected behavior: Luna Max handles the task directly and uses filesystem or shell evidence.

## T2: Localized implementation

```text
$codex-frugal-router

Create a temporary router-test directory with sum.js and a Node test.
Implement sum(a, b), run node --test, and report the model and result.
```

Expected behavior: Terra Max handles the implementation and verifies it with `node --test`, without a duplicate model review.

## T3: Architecture analysis

```text
$codex-frugal-router

Analyze the current MCP server and propose boundaries for its storage,
statistics, and protocol layers. Address compatibility, migration, and
security risks. Analyze only; do not modify files.
```

Expected behavior: Sol Medium handles the architecture and risk analysis.
