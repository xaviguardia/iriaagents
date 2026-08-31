# iriaagents

[🇬🇧 English below](#english)

---

> La receta es centrarse en el objetivo.

20+ proyectos entregados en 2026 con la misma técnica: define qué hay que conseguir y cómo demostrar que está terminado — antes de escribir una sola línea de código. Todo lo demás — el plan, los pasos, las decisiones técnicas — se adapta mientras ejecutas.

**[→ Leer el manual](https://xaviguardia.github.io/iriaagents)**

---

## La idea

![Principio: inmutable vs mutable](docs/principle.svg)

Antes de escribir código, responde dos preguntas:

1. **¿Qué hay que conseguir?**
2. **¿Cómo sabremos que está terminado?** — el comando exacto con la salida esperada.

Esas dos respuestas son el contrato. No cambian.

Todo lo demás — cómo llegar, qué tecnología usar, en qué orden — evoluciona con lo que aprendes mientras ejecutas. Si la respuesta a la segunda pregunta es vaga, aún no hay un objetivo real.

---

## Instalación

![Instalación en 3 pasos](docs/install.svg)

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

Crea symlinks en `~/.claude/commands/`. A partir de ahí `/new-task`, `/close-task` y `/coach` están disponibles en Claude Code, Grok y cualquier agente que cargue esa carpeta.

```bash
./install.sh --list       # skills instalados
./install.sh --force      # actualizar tras git pull
./install.sh --uninstall  # desinstalar
```

---

## Cómo funciona `/new-task`

![Flujo de /new-task](docs/flow.svg)

Una conversación de 6 preguntas. Las dos que más importan:

- **¿Qué hay que conseguir?**
- **¿Cómo se demuestra que está terminado?**

El skill no avanza si la segunda respuesta es vaga. Una vez acordado, genera `tasks/<nombre>/`. No genera script de lanzamiento: ejecuta quien está en el chat. Si el proyecto usa GitFlow crea la rama `feature/<nombre>` y el worktree automáticamente.

---

## `/coach` — feedback de uso de IA

Requiere [`obsly-ai`](https://ai.obsly.io) instalado (`pipx install obsly-ai`).

Ejecuta `iria-monitor coach`, lee el resultado y traduce la señal más débil en una acción concreta de iriaagents: qué `goal.md` corregir, cuándo usar `/close-task`, o por qué las sesiones se van de madre.

Un problema. Una acción.

---

## Dónde lo hemos usado

20+ proyectos entregados en 2026. Cinco patrones que se repiten:

![5 arquetipos de tarea](docs/archetypes.svg)

### Corregir N casos fallidos

Tienes una lista de casos incorrectos. El objetivo es llevarlos a cero.

```bash
node run-spec.js specs/B21.prg   # → PASS
grep "FIXED" report/divergences/ # → todos cerrados
```

40 bugs VFP9→JS cerrados. Fixes en intérpretes PL/I, COBOL y CICS.

---

### Verificar que dos sistemas se comportan igual

Construyes una suite de tests contra el sistema de referencia. La nueva implementación tiene que pasar la misma suite.

```bash
bash run-suite.sh
# PASS: 53   FAIL: 0
```

53 escenarios de ciclo de vida VFP9. Pipeline golden master WinGest8. Equivalencia COBOL→Rust.

---

### Migrar un sistema legacy a tecnología moderna

El código cambia completamente. El comportamiento no. El test es comparar salidas, no leer código.

```bash
diff <(run-legacy input.dat) <(run-modern input.dat)  # sin diferencias
./e2e-suite.sh                                         # todo verde
```

VFP9→Java, VB6→React, COBOL/PL1→Rust, mainframe→cloud.

---

### Construir un intérprete o runtime

Implementas soporte para un lenguaje. La cobertura se mide en programas que ejecutan correctamente.

```bash
./coverage.sh   # 1606/1606 programas  100%
```

Intérprete JS de VFP9, intérprete PL/I (ECMA-50), gateway CICS+TCP, pipeline JCL.

---

### Añadir nueva funcionalidad

El sistema existe y funciona. Añades algo. El test prueba el nuevo comportamiento, no la estructura del código.

```bash
./health.sh --symbols STRTRAN        # nueva opción funciona
playwright test e2e/new-flow.spec    # flujo completo verde
```

Flags de filtrado en tooling de conformidad. Modo oscuro. Dashboard de tokens. Editor de traducciones. Editor visual SDUI.

---

## El plan cambia. El objetivo no.

**VFP9 Lifecycle — de 0 a 53/53 PASS**
El plan inicial era corregir el orden de tres eventos. Durante la ejecución aparecieron ocho problemas nuevos. El plan se reescribió cinco veces. Los tests: ni una coma cambió.

**40 bugs cerrados**
Las tareas estaban agrupadas por tipo. El orden de ejecución real fue completamente distinto — las dependencias solo se ven cuando ejecutas. El plan lo absorbió. El objetivo nunca se tocó.

**Flags `--symbols` y `--tokens`**
La tarea era solo `--symbols`. Al implementarlo, apareció la necesidad obvia de `--tokens`. Se añadió sobre la marcha. El objetivo creció. Los tests crecieron con él.

---

## Cuando la arquitectura importa

Una vez que tienes los tests, la pregunta cambia. Ya no es "¿cómo construimos esto?" — es "¿puede este sistema siquiera hacer esto?"

A veces parte del plan es una pregunta previa: ¿se puede hacer aquí? Un spike de una tarde que responde sí o no. Si sí, los tests ya están escritos — la arquitectura se adapta a las restricciones del sistema. Si no, el objetivo cambia antes de invertir semanas.

Los tests no dicen cómo implementar. Dicen qué tiene que ocurrir. Eso deja margen para adaptar la arquitectura a restricciones reales sin tocar el contrato.

### Las restricciones se convierten en reglas

Cuando la arquitectura, el glosario o las dependencias importan, el objetivo no es "verificarlo una vez" — es **hacer las filtraciones imposibles**. La restricción se codifica como una regla ejecutable que corre en cada cambio.

El resultado siempre es el mismo: cero violaciones. Si alguien introduce una filtración, la verificación falla antes de llegar a la revisión.

**newwingest** — migración VFP9/VB6 → Java + React + Python. Un único comando de validación:

```bash
./scripts/verify.sh
# frontend: lint + build + unit tests
# backend: Checkstyle + PMD + tests
# iria: ruff + unit tests
# === All checks passed ===
```

Tres capas. Un comando. Si alguno falla, sin merge.

**Arquitectura hexagonal como test** — ArchUnit verifica que ningún controlador toca el dominio, que los puertos son interfaces y que la aplicación nunca bypasea un puerto para acceder directamente a un repositorio. 20+ reglas por módulo, dentro del build normal:

```bash
./mvnw verify
# HexagonalArchitectureTest: pedcli, albcli, prepro, cartera... ✓
# aplicacion_no_accede_repositorios_directamente ✓
# controllers_should_not_access_domain ✓
```

No es un diagrama. Si alguien introduce un bypass, el build falla.

**i18n como regla** — sin strings hardcodeados en rutas protegidas. La regla corre en CI:

```bash
./scripts/check_frontend_i18n_debt.sh
# 0 violations in guarded paths
```

No se revisa en code review. Se detecta automáticamente.

**Glosario como código** — los términos del dominio viven en Apicurio Registry y se exportan como un Maven JAR. El build del backend depende del JAR. Si el glosario no está cargado y exportado, el build falla:

```bash
./scripts/ci-export-glossary.sh   # carga el glosario → exporta JAR
./mvnw verify                     # usa el JAR; falla si no existe
```

El vocabulario del dominio tiene la misma trazabilidad que el código.

---

## La evidencia debe ser reproducible

Los logs no cuentan. La evidencia tiene que ser verificable a posteriori:

- **Traza Playwright o captura de pantalla** — para flujos de UI
- **Dump** — export JSON/CSV/SQL del estado final
- **Diff de archivos** — `git diff`, salida del spec runner
- **Salida de comando** — solo si es la única opción (tests unitarios, verificaciones de arquitectura, lint)

Los logs de servidor son efímeros y no demuestran el estado final del sistema.

---

## Adaptar al proyecto

| Archivo | Regla |
|---------|-------|
| `goal.md` | No tocar. Si el objetivo cambia, es una tarea nueva. |
| `plan.md` | Reescribir cuando la solución real se desvía. |
| `tasks.md` | Añadir, eliminar, reordenar según avanza el trabajo. |
| `evidence/` | Trazas Playwright, dumps y diffs — no logs. |

---

## Añadir un nuevo skill

```bash
vim commands/mi-skill.md
./install.sh --force
# disponible como /mi-skill
```

---

## Requisitos

- Un agente que cargue `~/.claude/commands/` ([Claude Code](https://claude.ai/code), Grok, …)
- Git

---

---

<a name="english"></a>
# iriaagents — English

> The recipe is to focus on the objective.

20+ projects shipped in 2026 using the same technique: define what you need to achieve and how to prove it's done — before writing a single line of code. Everything else — the plan, the steps, the technical decisions — adapts as you execute.

**[→ Read the manual](https://xaviguardia.github.io/iriaagents)**

---

## The idea

Before writing code, answer two questions:

1. **What needs to be achieved?**
2. **How will we know it's done?** — the exact command with the expected output.

Those two answers are the contract. They don't change.

Everything else — how to get there, which technology to use, in what order — evolves with what you learn while executing. If the answer to the second question is vague, there's no real objective yet.

---

## Installation

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

Creates symlinks in `~/.claude/commands/`. From that point `/new-task`, `/close-task` and `/coach` are available in Claude Code, Grok, and any agent that loads that folder.

```bash
./install.sh --list       # installed skills
./install.sh --force      # update after git pull
./install.sh --uninstall  # uninstall
```

---

## How `/new-task` works

A conversation of 6 questions. The two that matter most:

- **What needs to be achieved?**
- **How do we prove it's done?**

The skill won't advance if the second answer is vague. Once agreed, it generates `tasks/<name>/`. No launch script: whoever is in the chat runs the work. If the project uses GitFlow it creates the `feature/<name>` branch and worktree automatically.

---

## `/coach` — AI usage feedback

Requires [`obsly-ai`](https://ai.obsly.io) installed (`pipx install obsly-ai`).

Runs `iria-monitor coach`, reads the output and translates the weakest signal into a single iriaagents action: which `goal.md` to fix, when to use `/close-task`, or why sessions are going off-track.

One problem. One action.

---

## Where we've used it

20+ projects shipped in 2026. Five patterns that repeat:

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
# available as /my-skill
```

---

## Requirements

- An agent that loads `~/.claude/commands/` ([Claude Code](https://claude.ai/code), Grok, …)
- Git
