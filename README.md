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

## Ejemplos reales

### Lifecycle VFP9 — de 0 a 53/53 specs en verde

**Objetivo acordado:**
> El intérprete JS replica el ordering exacto de eventos Form/Control/DataEnvironment de VFP9 real en los 53 escenarios documentados.

**Tests que lo anclan:**
```bash
bash tasks/language-proof-lifecycle/scripts/run-lifecycle-suite.sh
# PASS: 53   FAIL: 0   TOTAL: 53
```

**Cómo evolucionó el trabajo:**
El plan inicial era "arreglar el orden Load→Init→Activate". Al ejecutar los tests emergieron 8 capas adicionales que no estaban en el plan original:
- `traceEvent` no era callable desde VFP (globalEnv no se consultaba)
- Los métodos VFP perdían frente a funciones nativas en `_callMethod`
- `DataEnvironment.Destroy` debía dispararse *después* del `Unload` del form, no antes
- Runtime `AddObject`: `THIS.Name` era incorrecto dentro de `Init` porque el nombre se asignaba después de ejecutarlo
- `trace-base.prg` se eliminaba en el preprocesador en vez de inyectarse

El objetivo no cambió. Los tests tampoco. El plan se reescribió cinco veces.

---

### Wave-1 bugfix — 40 divergencias VFP9→JS cerradas

**Objetivo acordado:**
> Las divergencias B01-B40 documentadas en `report/divergences/` quedan marcadas FIXED o TRIAGED con evidencia ejecutable.

**Tests que lo anclan:**
```bash
node interpreter/run-spec.js specs/Bxx-nombre.prg   # cada spec produce la salida esperada
grep -r "FIXED\|TRIAGED" report/divergences/        # todas tienen estado final
```

**Cómo evolucionó el trabajo:**
Las tareas se agruparon por bucket (strings, fechas, arrays, OOP, macros, errores, DBF) pero el orden real de ejecución fue distinto al planeado — algunas dependencias entre fixes solo se veían al ejecutar. B25 se movió a wave-2 porque dependía del parser, no del intérprete. El plan lo absorbió; el objetivo y los tests no se tocaron.

---

### Conformance tooling — filtrado por símbolo y token

**Objetivo acordado:**
> El runner de conformance permite aislar subconjuntos del corpus por símbolo VFP o por volumen de tokens.

**Tests que lo anclan:**
```bash
./health.sh --symbols STRTRAN        # solo specs que usan STRTRAN
./health.sh --tokens 50              # specs con más de 50 tokens
./health.sh --symbols SET,USE,CLOSE  # intersección de símbolos
```

**Cómo evolucionó el trabajo:**
La task inicial era "añadir `--symbols`". Al implementarlo apareció la necesidad natural de `--tokens` para detectar specs demasiado densas. Se añadió como subtarea no planificada. El objetivo original se cumplió y se amplió; los tests de verificación crecieron con él.

---

## Adaptar al proyecto

El directorio `tasks/<nombre>/` es una base, no una jaula. Lo normal es:

- Reescribir `plan.md` cuando la solución real es distinta a la propuesta
- Añadir o eliminar `taskNN-*.md` durante la ejecución
- Guardar en `evidence/` los outputs clave que demuestran el avance
- **No tocar `goal.md`** — si el objetivo cambia, es una nueva tarea

---

## Añadir nuevos skills

```bash
# Crea el skill
echo "# Skill: mi-skill\n..." > commands/mi-skill.md

# Instala
./install.sh --force

# Disponible en Claude Code como /mi-skill
```

---

## Requisitos

- Claude Code CLI
- Git (para worktrees y actualizaciones)
- `~/.claude/commands/` (gestionado por Claude Code)
