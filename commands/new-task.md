# Skill: new-task

Agente conversacional que recoge los requisitos de una tarea y genera el directorio `tasks/<nombre>/` completo listo para ejecutar con Claude Code o Codex.

**Cómo encontrar los templates (portable, sin paths hardcodeados):**
1. Lee `~/.claude/iriaagents_path` con la herramienta Read → contiene la ruta absoluta del repo iriaagents en esta máquina.
2. Los templates están en `<esa-ruta>/templates/`. Lee todos los `.md` y `.sh` de ese directorio antes de generar archivos.

## Cuándo usar este skill

- El usuario dice "nueva tarea", "crea una tarea", "scaffoldea una tarea", `/new-task`, etc.
- El usuario quiere preparar contexto estructurado para delegar trabajo a un agente

## Flujo

Ejecuta las fases en orden. **No generes archivos hasta tener todas las respuestas.** Haz UNA pregunta a la vez y espera respuesta antes de continuar.

---

### Fase 1: Recopilación (7 preguntas secuenciales)

**P1 — Qué construir**
> ¿Qué quieres construir? Describe el problema: qué está mal o qué falta, y qué debe quedar distinto al terminar.

**P2 — Estado actual**
> ¿Cuál es el estado actual? Dame métricas concretas si las hay (ej: "593/817 tests pasan", "VSAM OPEN falla con RESP=19"). Si no hay métricas, describe qué funciona y qué no.

**P3 — Verificación**
> ¿Cómo se verifica que el trabajo está terminado? Dame los comandos exactos que el agente ejecutará para demostrar que lo logró (tests, greps, scripts de smoke). Si la respuesta es vaga ("que funcione"), sigue preguntando hasta tener comandos concretos.

**P4 — Proyecto y rama**
> ¿En qué proyecto se crea la carpeta `tasks/`? Dame la ruta absoluta o el nombre del repo.
>
> Tras recibir la respuesta, comprueba si el proyecto usa GitFlow:
> - Si existe la rama `develop` (local o remota): informa al usuario y pregunta el nombre de la rama feature que se creará (`feature/<nombre-tarea>`). El trabajo se hará en un worktree separado.
> - Si no existe `develop`: continúa sin rama feature (flujo clásico).

**P5 — Entorno**
> ¿Hay un entorno especial que el agente debe conocer? (stack Docker, FTP, variables de entorno, comandos para arrancar el sistema). Si no, escribe "ninguno" — omitiré el archivo `INSTRUCTIONS.md`.

**P6 — Reglas de codificación**
> ¿Hay reglas de codificación o restricciones para este trabajo? (lenguaje, framework de tests, naming, prohibiciones explícitas). Si no, escribe "ninguna".

**P7 — Runner**
> ¿Qué runner usará el agente: **Claude Code**, **Codex**, o **ambos**?

---

### Fase 2: Propuesta

Con las respuestas recogidas:

1. **Nombre del directorio**: propón un nombre en kebab-case (ej: `vsam-open-fix`, `java-coverage`). Pregunta si está bien.

2. **Descomposición en tareas**: propón una tabla de tareas atómicas:
   | # | Nombre | Qué hace | Depende de |
   |---|--------|----------|------------|

   Cada tarea debe ser ejecutable en una sesión y tener criterio de DONE verificable con comandos. Pregunta si añaden, quitan o ajustan tareas antes de continuar.

---

### Fase 3: Generación

Una vez confirmada la propuesta:

1. Lee `~/.claude/iriaagents_path` para obtener la ruta del repo iriaagents.
2. Lee todos los templates de `<iriaagents>/templates/` (`.md` y `.sh`).
3. Sustituye todos los `{{PLACEHOLDER}}` con la información del usuario. **Sin placeholders sin resolver.**

4. **Si el proyecto usa GitFlow** (tiene rama `develop`):
   - Crea un worktree: `git -C <proyecto> worktree add ../<proyecto>-<nombre-tarea> -b feature/<nombre-tarea> develop`
   - Genera todos los archivos dentro del worktree (`../<proyecto>-<nombre-tarea>/tasks/<nombre>/`)
   - Informa al usuario de la ruta del worktree y la rama creada.

5. **Si no usa GitFlow**: genera los archivos directamente en `<proyecto>/tasks/<nombre>/`.

6. Archivos a crear:

   **Siempre:**
   - `goal.md` — basado en `templates/goal.md`
   - `plan.md` — basado en `templates/plan.md`
   - `tasks.md` — basado en `templates/tasks.md`
   - `coding-rules.md` — basado en `templates/coding-rules.md`
   - `AGENT.md` — basado en `templates/AGENT.md`
   - `PROMPT.md` — basado en `templates/PROMPT.md`
   - `task01-<slug>.md` ... `taskNN-<slug>.md` — uno por tarea, basado en `templates/task-ejemplo.md`
   - `evidence/.gitkeep`
   - `scripts/.gitkeep`

   **Solo si hay entorno especial (P5 ≠ "ninguno"):**
   - `INSTRUCTIONS.md` — basado en `templates/INSTRUCTIONS.md`

   **Según runner elegido (P7):**
   - `run-claude.sh` — si Claude Code o ambos
   - `run-codex.sh` — si Codex o ambos
   - `chmod +x` en todos los `.sh`

7. En los scripts `.sh`:
   - Si el proyecto tiene git: `cd "$(git rev-parse --show-toplevel)"` como `{{CD_TOPLEVEL}}`
   - Si no tiene git: `cd "<ruta absoluta>"` como `{{CD_TOPLEVEL}}`

8. Al terminar, confirma:
   - Rama y worktree creados (si GitFlow)
   - Archivos generados con ruta completa
   - Siguiente paso: `cd ../<proyecto>-<nombre-tarea> && ./tasks/<nombre>/run-claude.sh`

## Reglas de generación

- **Sin placeholders sin resolver**: todos los `{{...}}` deben estar rellenos
- **Criterios siempre ejecutables**: si el usuario da un criterio vago, tradúcelo a comandos concretos
- **No inventar detalles técnicos**: si no sabes la ruta exacta de un archivo, márcala con `# VERIFICAR`
- **tasks.md refleja exactamente las tareas generadas**: una fila por cada taskNN
- **Los timestamps usan la fecha de hoy**: obtenerla con la herramienta de fecha del sistema
