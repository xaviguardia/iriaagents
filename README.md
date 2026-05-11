# iriaagents

> The recipe is to focus on the objective.

20+ projects shipped in 2026 using the same technique: define what you need to achieve and how to prove it's done — before writing a single line of code. Everything else — the plan, the steps, the technical decisions — adapts as you execute.

**[→ Read the manual](https://xaviguardia.github.io/iriaagents)**

---

## The idea

![Principle: immutable vs mutable](docs/principle.svg)

Before writing code, answer two questions:

1. **What needs to be achieved?**
2. **How will we know it's done?** — the exact command with the expected output.

Those two answers are the contract. They don't change.

Everything else — how to get there, which technology to use, in what order — evolves with what you learn while executing. If the answer to the second question is vague, there's no real objective yet.

---

## Installation

![Installation in 3 steps](docs/install.svg)

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

Creates symlinks in `~/.claude/commands/`. From that point `/new-task` is available in Claude Code.

```bash
./install.sh --list       # installed skills
./install.sh --force      # update after git pull
./install.sh --uninstall  # uninstall
```

---

## How `/new-task` works

![/new-task flow](docs/flow.svg)

A conversation of 7 questions. The two that matter most:

- **What needs to be achieved?**
- **How do we prove it's done?**

The skill won't advance if the second answer is vague. Once agreed, it generates `tasks/<name>/` with everything needed to start. If the project uses GitFlow it creates the `feature/<name>` branch and worktree automatically.

---

## Where we've used it

20+ projects shipped in 2026. Five patterns that repeat:

![5 task archetypes](docs/archetypes.svg)

### Fix N failing cases

You have a list of incorrect cases. The objective is to bring them to zero.

```bash
node run-spec.js specs/B21.prg   # → PASS
grep "FIXED" report/divergences/ # → all closed
```

40 VFP9→JS bugs closed. Fixes in PL/I, COBOL and CICS interpreters.

---

### Verify two systems behave identically

You build a test suite against the reference system. The new implementation has to pass the same suite.

```bash
bash run-suite.sh
# PASS: 53   FAIL: 0
```

53 VFP9 lifecycle scenarios. WinGest8 golden master pipeline. COBOL→Rust equivalence.

---

### Migrate a legacy system to modern technology

The code changes completely. The behaviour doesn't. The test is comparing outputs, not reading code.

```bash
diff <(run-legacy input.dat) <(run-modern input.dat)  # no differences
./e2e-suite.sh                                         # all green
```

VFP9→Java, VB6→React, COBOL/PL1→Rust, mainframe→cloud.

---

### Build an interpreter or runtime

You implement support for a language. Coverage is measured in programs that run correctly.

```bash
./coverage.sh   # 1606/1606 programs  100%
```

VFP9 JS interpreter, PL/I interpreter (ECMA-50), CICS+TCP gateway, JCL pipeline.

---

### Add new functionality

The system exists and works. You add something. The test proves the new behaviour, not the code structure.

```bash
./health.sh --symbols STRTRAN        # new option works
playwright test e2e/new-flow.spec    # full flow green
```

Filtering flags in conformance tooling. Dark mode. Token dashboard. Translation editor. SDUI visual editor.

---

## The plan changes. The objective doesn't.

**VFP9 Lifecycle — 0 to 53/53 PASS**
The initial plan was to fix the order of three events. While executing, eight previously unseen problems appeared. The plan was rewritten five times. The tests: not a comma changed.

**40 bugs closed**
The tasks were grouped by type. The actual execution order was completely different — dependencies only become visible when you run things. The plan absorbed it. The objective was never touched.

**`--symbols` and `--tokens` flags**
The task was only `--symbols`. While implementing it, the obvious need for `--tokens` appeared. It was added on the fly. The objective grew. The tests grew with it.

---

## When architecture matters

Once you have the tests, the question changes. It's no longer "how do we build this?" — it's "can this system even do this?"

Sometimes part of the plan is a prior question: can this be done here? A one-afternoon spike that answers yes or no. If yes, the tests are already written — the architecture adapts to the system's constraints. If no, the objective changes before investing weeks.

The tests don't say how to implement. They say what has to happen. That leaves room to bend the architecture to real constraints without touching the contract.

### Constraints become rules

When architecture, glossary or dependencies matter, the objective isn't to "verify it once" — it's to **make leaks impossible**. The constraint is encoded as an executable rule that runs on every change.

The result is always the same: zero violations. If someone introduces a leak, the check fails before reaching review.

**newwingest** — VFP9/VB6 → Java + React + Python migration. A single gate command:

```bash
./scripts/verify.sh
# frontend: lint + build + unit tests
# backend: Checkstyle + PMD + tests
# iria: ruff + unit tests
# === All checks passed ===
```

Three layers. One command. If any fails, no merge.

**Hexagonal architecture as a test** — ArchUnit verifies that no controller touches the domain, that ports are interfaces, and that the application never bypasses a port to hit a repository directly. 20+ rules per module, inside the normal build:

```bash
./mvnw verify
# HexagonalArchitectureTest: pedcli, albcli, prepro, cartera... ✓
# aplicacion_no_accede_repositorios_directamente ✓
# controllers_should_not_access_domain ✓
```

It's not a diagram. If someone introduces a bypass, the build fails.

**i18n as a rule** — no hardcoded strings in guarded paths. The rule runs in CI:

```bash
./scripts/check_frontend_i18n_debt.sh
# 0 violations in guarded paths
```

Not reviewed in code review. Detected automatically.

**Glossary as code** — domain terms live in Apicurio Registry and are exported as a Maven JAR. The backend build depends on the JAR. If the glossary isn't loaded and exported, the build fails:

```bash
./scripts/ci-export-glossary.sh   # load glossary → export JAR
./mvnw verify                     # uses the JAR; fails if missing
```

The domain vocabulary has the same traceability as code.

---

## Evidence must be reproducible

Logs don't count. Evidence has to be verifiable after the fact:

- **Playwright trace or screenshot** — for UI flows
- **Dump** — JSON/CSV/SQL export of the final state
- **File diff** — `git diff`, spec runner output
- **Command output** — only if it's the only option (unit tests, architecture checks, lint)

Server logs are ephemeral and don't prove the final state of the system.

---

## Adapting to your project

| File | Rule |
|------|------|
| `goal.md` | Don't touch. If the objective changes, it's a new task. |
| `plan.md` | Rewrite when the real solution diverges. |
| `tasks.md` | Add, remove, reorder as work progresses. |
| `evidence/` | Playwright traces, dumps and diffs — not logs. |

---

## Adding a new skill

```bash
vim commands/my-skill.md
./install.sh --force
# available as /my-skill in Claude Code
```

---

## Requirements

- [Claude Code](https://claude.ai/code)
- Git
