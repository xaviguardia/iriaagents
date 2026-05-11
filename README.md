# iriaagents

Framework de tareas para agentes de código. Su función principal es forzar la definición del **objetivo verificable** antes de ejecutar cualquier trabajo, y servir de base adaptable para cada proyecto.

## Principio central

```
Objetivo + tests que lo demuestran  →  inmutable (el contrato)
Plan + tareas                        →  mutable   (la orientación)
```

El plan puede cambiar. Las tareas pueden reordenarse, añadirse o eliminarse. Lo que no cambia es la respuesta a: **¿qué comandos ejecutamos al final para demostrar que lo conseguimos?**

El skill `/new-task` no te da una estructura rígida — te da la conversación que fuerza ese anclaje antes de escribir una sola línea de código.

---

## Instalación

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

Escribe `~/.claude/iriaagents_path` (para localizar templates sin paths hardcodeados) y crea symlinks en `~/.claude/commands/`. Desde ese momento `/new-task` está disponible en Claude Code en cualquier proyecto.

```bash
./install.sh --list       # qué skills están instalados
./install.sh --force      # actualizar tras git pull
./install.sh --uninstall  # limpieza completa
```

---

## Para qué tipo de tareas funciona

Tras aplicar esta técnica en más de 40 proyectos reales, los arquetipos donde más valor aporta son:

### 1. Corrección sistemática de divergencias

Un sistema conocido produce resultados incorrectos en N casos documentados. El objetivo es llevar esos N casos a cero con evidencia por caso.

**Tests típicos:**
```bash
node run-spec.js specs/caso-001.prg   # salida esperada: "OK"
grep -r "FIXED" report/divergences/  # todos tienen estado final
```

**Proyectos:** corrección de 40 divergencias VFP9→JS (strings, fechas, arrays, OOP, macros, errores, DBF); fixes en intérpretes PL/I, COBOL, CICS.

---

### 2. Conformance testing — especificación como contrato

Construir una suite de specs que capture el comportamiento exacto de un sistema de referencia y verificar que la implementación alternativa lo replica.

**Tests típicos:**
```bash
bash run-suite.sh
# PASS: 53   FAIL: 0   TOTAL: 53
```

**Proyectos:** 53 specs de lifecycle VFP9 Form/Control/DataEnvironment; suite de conformance del corpus VFP9 (1606 programas); golden master pipeline WinGest8 (102h, 5 tracks); equivalencia COBOL→Rust en nuhost.

---

### 3. Migración de sistemas legados

Convertir un sistema existente (VB6, VFP9, COBOL, PL/I, JCL) a un stack moderno preservando el comportamiento observable. El test es la equivalencia de salidas, no la similitud del código.

**Tests típicos:**
```bash
diff <(run-legacy input.dat) <(run-modern input.dat)   # sin diferencias
./e2e-suite.sh                                          # N/N specs en verde
```

**Proyectos:** VFP9→Java (newwingest, abina con 24 specs E2E); VB6→Java+React (ekoN ERP); COBOL/PL/I→Rust con event-sourcing (nuhost); pipeline Iria (F1-F8) para modernización de mainframe.

---

### 4. Construcción de infraestructura de interpretación

Implementar un intérprete, transpiler o runtime para un lenguaje existente. El contrato es la cobertura del lenguaje medida en specs que pasan.

**Tests típicos:**
```bash
node interpreter/run-spec.js corpus/programa.prg   # sin runtime errors
./coverage.sh                                       # N% tokens cubiertos
```

**Proyectos:** intérprete VFP9 JS (corpus completo, lifecycle, OOP, SQL, DBF); intérprete PL/I (100% ECMA-50); intérprete CICS+TCP gateway contra Hercules/MVS real; pipeline JCL.

---

### 5. Nuevas funcionalidades en sistemas en producción

Añadir capacidades a un sistema existente donde el criterio de éxito es un comportamiento nuevo demostrable, no "que el PR pase CI".

**Tests típicos:**
```bash
./health.sh --symbols STRTRAN        # nueva flag funciona
curl -s /api/nuevo-endpoint | jq .   # respuesta correcta
playwright test e2e/nuevo-flujo.spec # flujo de usuario completo
```

**Proyectos:** flags `--symbols`/`--tokens` en conformance tooling; dark mode en frontend VFP; dashboard de observabilidad (token tracking, burndown, LLM proxy); TMS Obsly Verba (editor, MT, memoria de traducción); SDUI visual editor Trazz.

---

## Cómo funciona

`/new-task` conduce una conversación de 7 preguntas. La más importante es la tercera:

> **¿Cómo se verifica que el trabajo está terminado?**  
> Dame los comandos exactos que demostrarán que lo lograste.

Si la respuesta es vaga, el skill sigue preguntando hasta tener comandos concretos. Sin verificación ejecutable no se avanza.

Con las respuestas genera un directorio `tasks/<nombre>/` adaptado al proyecto:

```
tasks/mi-tarea/
├── goal.md          ← objetivo + criterio de éxito ejecutable  ← NO TOCAR
├── plan.md          ← diseño inicial                           ← vivo, evoluciona
├── tasks.md         ← tabla de tareas atómicas                 ← vivo, evoluciona
├── coding-rules.md  ← restricciones del proyecto
├── AGENT.md         ← instrucciones para el agente
├── PROMPT.md        ← prompt de arranque de sesión
├── task01-slug.md   ← descripción de cada tarea
├── evidence/        ← outputs capturados (diffs, trazas, logs)
├── scripts/         ← scripts reutilizables
└── run-claude.sh    ← arranca la sesión
```

**`goal.md` es el único archivo que no debe modificarse una vez acordado.** El resto evoluciona con el trabajo.

Si el proyecto usa GitFlow (rama `develop`), el skill crea la rama `feature/<nombre>` y un worktree separado automáticamente.

---

## Ejemplos de cómo el plan cambia pero el objetivo no

### Lifecycle VFP9 — 0 → 53/53 specs

**Objetivo y tests (no cambiaron):**
```bash
bash tasks/language-proof-lifecycle/scripts/run-lifecycle-suite.sh
# PASS: 53   FAIL: 0   TOTAL: 53
```

**Lo que no estaba en el plan inicial y emergió al ejecutar:**
- `traceEvent` no era callable desde VFP — globalEnv JS no se consultaba
- Los métodos VFP perdían frente a funciones nativas en `_callMethod`
- `DataEnvironment.Destroy` tenía que dispararse *después* del `Unload`, no antes
- Runtime `AddObject`: `THIS.Name` incorrecto dentro de `Init` — el nombre se asignaba después de ejecutarlo
- `trace-base.prg` se eliminaba en el preprocesador en vez de inyectarse inline

El plan se reescribió cinco veces. El objetivo y los tests: ni una coma.

---

### Wave-1 bugfix — 40 divergencias cerradas

**Objetivo y tests (no cambiaron):**
```bash
node interpreter/run-spec.js specs/Bxx-nombre.prg
grep -r "FIXED\|TRIAGED" report/divergences/
```

**Lo que cambió durante la ejecución:**
Las tareas se agruparon por bucket (strings, fechas, arrays, OOP, macros, errores, DBF) pero el orden de ejecución real fue distinto — algunas dependencias solo se veían al ejecutar. B25 se movió a wave-2 porque dependía del parser. El plan lo absorbió; el objetivo no.

---

## Adaptar al proyecto

El directorio generado es una base, no una jaula:

- Reescribir `plan.md` cuando la solución real es distinta a la propuesta
- Añadir o eliminar `taskNN-*.md` durante la ejecución
- Guardar en `evidence/` los outputs que demuestran el avance
- **No tocar `goal.md`** — si el objetivo cambia, es una tarea nueva

---

## Añadir nuevos skills

```bash
# Crea el skill en el repo
vim commands/mi-skill.md

# Instala el symlink
./install.sh --force

# Disponible en Claude Code como /mi-skill
```

---

## Requisitos

- Claude Code CLI
- Git (para worktrees y actualizaciones)
