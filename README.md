# iriaagents

> Framework de tareas para agentes de código.  
> Una conversación de 7 preguntas que fuerza la definición del **objetivo verificable** antes de ejecutar cualquier trabajo.

---

## El principio que lo gobierna todo

![Principio: inmutable vs mutable](docs/principle.svg)

El plan puede cambiar. Las tareas pueden reordenarse, añadirse o eliminarse.  
Lo que **no cambia** es la respuesta a:

> *¿Qué comandos ejecutamos al final para demostrar que lo conseguimos?*

`goal.md` es el único archivo que no se toca una vez acordado. El resto evoluciona con lo que aprendes al ejecutar.

---

## Instalación

![Instalación en 3 pasos](docs/install.svg)

```bash
git clone https://github.com/xaviguardia/iriaagents
cd iriaagents
./install.sh
```

`install.sh` escribe `~/.claude/iriaagents_path` (para que los skills encuentren los templates sin paths hardcodeados) y crea symlinks en `~/.claude/commands/`. Desde ese momento `/new-task` está disponible en cualquier proyecto.

```bash
./install.sh --list       # qué skills están instalados
./install.sh --force      # actualizar tras git pull
./install.sh --uninstall  # limpieza completa
```

---

## Cómo funciona `/new-task`

![Flujo de /new-task](docs/flow.svg)

El skill conduce una conversación de 7 preguntas. **La tercera es la más importante** — y no avanza si la respuesta es vaga:

> *¿Cómo se verifica que el trabajo está terminado?*  
> *Dame los comandos exactos con la salida esperada.*

Con las respuestas genera `tasks/<nombre>/` adaptado al proyecto. Si el repo usa GitFlow (rama `develop`), crea la rama `feature/<nombre>` y el worktree separado automáticamente.

---

## Para qué tipo de tareas

Tras aplicarlo en más de 40 proyectos reales, estos son los 5 arquetipos donde más valor aporta:

![5 arquetipos de tarea](docs/archetypes.svg)

### 1 · Corrección sistemática de divergencias

Un sistema produce resultados incorrectos en N casos documentados. El objetivo es llevarlos a cero, con evidencia por caso.

```bash
node run-spec.js specs/B21-strtran.prg   # → OK
grep -r "FIXED" report/divergences/      # → todos tienen estado final
```

**Proyectos reales:** 40 divergencias VFP9→JS (strings, fechas, arrays, OOP, macros, DBF); fixes en intérpretes PL/I, COBOL, CICS.

---

### 2 · Conformance testing

Construir una suite que capture el comportamiento exacto de un sistema de referencia y verificar que la implementación alternativa lo replica.

```bash
bash run-lifecycle-suite.sh
# PASS: 53   FAIL: 0   TOTAL: 53
```

**Proyectos reales:** 53 specs lifecycle VFP9 Form/Control/DataEnvironment; corpus VFP9 1606 programas; golden master pipeline WinGest8 (102h, 5 tracks); equivalencia COBOL→Rust.

---

### 3 · Migración de sistemas legados

Convertir VB6, VFP9, COBOL, PL/I o JCL a stack moderno preservando el comportamiento observable. El test no es la similitud del código — es la equivalencia de salidas.

```bash
diff <(run-legacy input.dat) <(run-modern input.dat)   # sin diferencias
./e2e-suite.sh                                          # N/N en verde
```

**Proyectos reales:** VFP9→Java (newwingest); VB6→Java+React (abina, 24 specs E2E); COBOL/PL1→Rust con event-sourcing (nuhost); pipeline Iria F1-F8 para mainframe.

---

### 4 · Infraestructura de interpretación

Implementar un intérprete, transpiler o runtime para un lenguaje existente. La cobertura se mide en specs que pasan, no en líneas de código.

```bash
node interpreter/run-spec.js corpus/programa.prg   # sin runtime errors
./coverage.sh                                       # N% tokens cubiertos
```

**Proyectos reales:** intérprete VFP9 JS (corpus completo, lifecycle, OOP, SQL, DBF); intérprete PL/I (100% ECMA-50); gateway CICS+TCP contra Hercules/MVS real; pipeline JCL.

---

### 5 · Nuevas funcionalidades en producción

Añadir capacidades a un sistema existente. El criterio es el comportamiento nuevo demostrable, no que el PR pase CI.

```bash
./health.sh --symbols STRTRAN        # nueva flag funciona
playwright test e2e/nuevo-flujo.spec # flujo de usuario completo
curl -s /api/nuevo | jq .status      # "ok"
```

**Proyectos reales:** flags `--symbols`/`--tokens` en conformance tooling; dark mode VFP frontend; dashboard Obsly (token tracking, burndown, LLM proxy); TMS Obsly Verba (editor, MT, memoria); SDUI visual editor Trazz.

---

## El plan cambia. El objetivo no.

Tres ejemplos de cómo evolucionó el trabajo una vez definido el contrato:

**Lifecycle VFP9 (0 → 53/53 PASS)**  
El plan inicial era "arreglar el orden Load→Init→Activate". Al ejecutar emergieron 8 capas adicionales no planificadas: `traceEvent` no era callable desde VFP, los métodos VFP perdían frente a funciones nativas, `DataEnvironment.Destroy` tenía que dispararse *después* del `Unload`... El plan se reescribió cinco veces. Los tests: ni una coma.

**Wave-1 bugfix (40 divergencias cerradas)**  
Las tareas se agruparon por bucket (strings, fechas, OOP...) pero el orden de ejecución fue distinto al planeado — las dependencias solo se veían al ejecutar. B25 se movió a wave-2 porque dependía del parser. El plan lo absorbió; el objetivo no.

**Conformance tooling (flags `--symbols`/`--tokens`)**  
La tarea inicial era solo `--symbols`. Al implementarlo apareció la necesidad natural de `--tokens`. Se añadió como subtarea no planificada. El objetivo creció; los tests de verificación crecieron con él.

---

## Adaptar al proyecto

El directorio generado es una base, no una jaula:

| Archivo | Qué hacer |
|---------|-----------|
| `goal.md` | **No tocar.** Si el objetivo cambia, es una tarea nueva. |
| `plan.md` | Reescribir cuando la solución real difiere de la propuesta. |
| `tasks.md` | Añadir, eliminar o reordenar según avanza el trabajo. |
| `evidence/` | Guardar outputs clave: diffs, trazas, logs, capturas. |
| `taskNN-*.md` | Añadir los que emerjan; borrar los que no apliquen. |

---

## Añadir nuevos skills

```bash
# 1. Crea el skill en el repo
vim commands/mi-skill.md

# 2. Instala el symlink
./install.sh --force

# 3. Disponible en Claude Code
/mi-skill
```

---

## Requisitos

- [Claude Code](https://claude.ai/code) CLI instalado
- Git (para worktrees y actualizaciones)
