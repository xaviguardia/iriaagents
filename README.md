# iriaagents

Kit de skills para Claude Code. Un comando (`/new-task`) que recoge requisitos en conversación y genera el scaffolding completo de una tarea lista para ejecutar con Claude Code o Codex.

GitFlow-aware: si tu proyecto tiene rama `develop`, crea la rama `feature/` y el worktree automáticamente.

---

## Instalación

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

Eso hace tres cosas:
- Escribe `~/.claude/iriaagents_path` con la ruta del repo (para que los skills encuentren los templates sin paths hardcodeados)
- Crea symlinks en `~/.claude/commands/` → los skills quedan disponibles en Claude Code
- Puedes actualizar con `git pull && ./install.sh --force`

### Comandos útiles

```bash
./install.sh --list       # lista los skills y si están instalados
./install.sh --force      # sobreescribe si ya existen
./install.sh --copy       # copia en vez de symlinkear (para máquinas sin acceso al repo)
./install.sh --uninstall  # elimina symlinks y ~/.claude/iriaagents_path
```

---

## Uso

Escribe `/new-task` en Claude Code. El skill te hace 7 preguntas y genera:

```
tasks/mi-tarea/
├── goal.md          ← qué se construye y criterio de éxito ejecutable
├── plan.md          ← diseño de la solución
├── tasks.md         ← tabla de tareas atómicas
├── coding-rules.md  ← restricciones de codificación
├── AGENT.md         ← instrucciones para el agente
├── PROMPT.md        ← prompt inicial de la sesión
├── task01-slug.md   ← una por tarea atómica
├── evidence/        ← outputs capturados (diffs, traces, logs)
├── scripts/         ← scripts reutilizables
└── run-claude.sh    ← arranca la sesión de Claude Code
```

Si el proyecto usa GitFlow (tiene rama `develop`), también:
- Crea `feature/<nombre-tarea>` off `develop`
- Genera los archivos en un worktree separado (`../<proyecto>-<nombre-tarea>/`)

---

## Ejemplos reales

### 1 — Lifecycle VFP9: 0 → 53/53 specs en verde

**Proyecto:** `vfp9interpreter` + `vfp-conformance`  
**Objetivo:** verificar que el intérprete JS replica el ordering exacto de eventos Form/Control/DataEnvironment de VFP9 real.

**Estado inicial:** 0 specs pasando. No había infraestructura de trazas ni suite de comparación.

**Lo que generó el skill:**
- 53 specs `.prg` con trazas doradas capturadas en VFP9 real
- 53 `assert.json` (reglas de subsecuencia ordenada R0-R7)
- `compare-trace.py` y `run-lifecycle-suite.sh`
- Tasks atómicas: infra → specs baseline → specs de controles → specs DE/Cursor → fixes de intérprete

**Criterio de éxito ejecutado:**
```bash
bash tasks/language-proof-lifecycle/scripts/run-lifecycle-suite.sh
# PASS: 53   FAIL: 0   TOTAL: 53
```

**Fixes en el intérprete que emergieron de las specs:**
- `_callMethod`: métodos VFP tienen prioridad sobre funciones nativas JS
- `Form.Release` async: DataEnvironment Destroy después de form Unload (orden VFP9)
- `_addObjectPendingName`: `THIS.Name` correcto dentro de `Init` en runtime `AddObject`
- `traceEvent` callable desde VFP mediante globalEnv JS functions
- `SetFocus` con LostFocus/GotFocus chain; two-form handoff

---

### 2 — Wave-1 bugfix: 40 divergencias VFP9 → JS cerradas

**Proyecto:** `vfp9interpreter`  
**Objetivo:** cerrar las divergencias B01-B40 entre el intérprete JS y VFP9 documentadas en `vfp-conformance/report/divergences/`.

**Estado inicial:** 40 divergencias abiertas, sin priorización ni criterios de cierre.

**Lo que generó el skill:**
- Tasks separadas por bucket (strings, fechas, arrays, OOP, macros, errores, DBF)
- Criterios de verificación por spec: `node interpreter/run-spec.js specs/Bxx.prg`
- Tracking de estado: FIXED / TRIAGED / WAVE-2

**Resultado:**
```
B08, B21-B33: FIXED (wave-1)
B34-B40: FIXED (wave-1 closure)
B25: TRIAGED → wave-2 (depende de parser)
```

---

### 3 — Conformance tooling: flags `--symbols` y `--tokens`

**Proyecto:** `vfp-conformance`  
**Objetivo:** añadir flags de filtrado al tooling de conformance para poder aislar tokens VFP específicos en los reportes.

**Estado inicial:** el runner no tenía filtrado; los reportes cubrían todo el corpus sin forma de hacer zoom.

**Lo que generó el skill:**
- Task única con criterio: `./health.sh --symbols SET,USE` produce output filtrado
- Spec de 5 tokens: `#INCLUDE`, `#INSERT`, `#NAME`, `?|??`, `???`

**Verificación:**
```bash
./health.sh --symbols STRTRAN    # solo specs con STRTRAN
./health.sh --tokens 50          # specs con > 50 tokens
```

---

## Estructura del repo

```
iriaagents/
├── commands/
│   └── new-task.md     ← el skill (symlinkeado en ~/.claude/commands/)
├── templates/
│   ├── goal.md
│   ├── plan.md
│   ├── tasks.md
│   ├── coding-rules.md
│   ├── AGENT.md
│   ├── PROMPT.md
│   ├── INSTRUCTIONS.md
│   ├── task-ejemplo.md
│   ├── run-claude.sh
│   └── run-codex.sh
└── install.sh
```

---

## Añadir nuevos skills

1. Crea `commands/mi-skill.md` con las instrucciones para Claude
2. `./install.sh --force` para instalar el symlink
3. Disponible como `/mi-skill` en Claude Code

---

## Requisitos

- Claude Code CLI instalado
- `~/.claude/commands/` accesible (Claude Code lo gestiona automáticamente)
- Git (para actualizaciones y la funcionalidad de worktrees en `/new-task`)
