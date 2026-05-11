# Skill: new-task

Agente conversacional que ancla el objetivo de una tarea con tests ejecutables y genera el scaffolding adaptable para ejecutarla con Claude Code o Codex.

**Principio que guía todas las decisiones:**
- `goal.md` (objetivo + verificación) es el contrato inmutable. No se toca una vez acordado.
- `plan.md` y las tareas son orientación mutable — se espera que cambien durante la ejecución.
- Sin criterio de verificación ejecutable no existe objetivo válido.

**Cómo encontrar los templates (portable, sin paths hardcodeados):**
1. Lee `~/.claude/iriaagents_path` → contiene la ruta absoluta del repo iriaagents en esta máquina.
2. Los templates están en `<esa-ruta>/templates/`. Lee todos los `.md` y `.sh` antes de generar archivos.

## Cuándo usar este skill

- El usuario dice "nueva tarea", "crea una tarea", "scaffoldea una tarea", `/new-task`, etc.
- El usuario quiere preparar contexto estructurado para delegar trabajo a un agente

## Flujo

Ejecuta las fases en orden. **No generes archivos hasta tener todas las respuestas.** Haz UNA pregunta a la vez y espera respuesta antes de continuar.

---

### Fase 1: Recopilación (7 preguntas secuenciales)

**P1 — Qué construir**
> ¿Qué quieres construir o corregir? Describe el problema: qué está mal o qué falta, y qué debe quedar distinto al terminar.

**P2 — Estado actual**
> ¿Cuál es el estado actual? Dame métricas concretas si las hay (ej: "0/53 specs pasan", "B21-B40 sin cerrar"). Si no hay métricas, describe qué funciona y qué no.

**P3 — Verificación** ← la más importante
> ¿Cómo se demuestra que el trabajo está terminado? Dame los comandos exactos que ejecutaremos al final para probar que el objetivo se ha conseguido.
>
> Si la respuesta es vaga ("que funcione", "que mejore"), no avances. Sigue preguntando hasta tener:
> - Comandos concretos y ejecutables
> - Salida esperada o criterio de éxito para cada comando
>
> Estos comandos se convierten en el criterio de éxito de `goal.md` y **no cambian durante la tarea**.

**P4 — Proyecto y rama**
> ¿En qué proyecto se crea la carpeta `tasks/`? Dame la ruta absoluta o el nombre del repo.
>
> Tras recibir la respuesta, comprueba si el proyecto usa GitFlow:
> - Si existe la rama `develop` (local o remota): informa al usuario y pregunta el nombre de la rama feature (`feature/<nombre-tarea>`). El trabajo irá en un worktree separado.
> - Si no existe `develop`: continúa sin rama feature.

**P5 — Entorno**
> ¿Hay un entorno especial que el agente debe conocer? (Docker, FTP, variables de entorno, comandos para arrancar el sistema). Si no, escribe "ninguno" — omitiré `INSTRUCTIONS.md`.

**P6 — Reglas de codificación**
> ¿Hay reglas de codificación o restricciones? (lenguaje, framework de tests, naming, prohibiciones). Si no, escribe "ninguna".

**P7 — Runner**
> ¿Qué runner usará el agente: **Claude Code**, **Codex**, o **ambos**?

---

### Fase 2: Propuesta

Con las respuestas recogidas:

1. **Nombre del directorio**: propón un nombre en kebab-case. Pregunta si está bien.

2. **Elementos clave del objetivo**: lista los aspectos del sistema que los tests de verificación cubren. Esto es lo que el agente debe tener claro antes de tocar código.

3. **Descomposición en tareas**: propón una tabla orientativa de tareas atómicas:
   | # | Nombre | Qué hace | Depende de |
   |---|--------|----------|------------|

   Deja claro que esta tabla es orientación — se espera que cambie durante la ejecución. Lo que no cambia es la verificación del paso anterior.

   Pregunta si añaden, quitan o ajustan tareas antes de continuar.

---

### Fase 3: Generación

Una vez confirmada la propuesta:

1. Lee `~/.claude/iriaagents_path` para obtener la ruta del repo iriaagents.
2. Lee todos los templates de `<iriaagents>/templates/`.
3. Sustituye todos los `{{PLACEHOLDER}}`. **Sin placeholders sin resolver.**

4. **Si el proyecto usa GitFlow** (tiene rama `develop`):
   - `git -C <proyecto> worktree add ../<proyecto>-<nombre-tarea> -b feature/<nombre-tarea> develop`
   - Genera los archivos en el worktree (`../<proyecto>-<nombre-tarea>/tasks/<nombre>/`)

5. **Si no usa GitFlow**: genera en `<proyecto>/tasks/<nombre>/`.

6. Archivos a crear:

   **Siempre:**
   - `goal.md` ← objetivo + verificación ejecutable. Marcar explícitamente: "Este archivo no se modifica durante la ejecución."
   - `plan.md` ← diseño inicial. Marcar: "Documento vivo — se espera que evolucione."
   - `tasks.md` ← tabla de tareas. Marcar: "Documento vivo — añade, elimina o reordena según avance el trabajo."
   - `coding-rules.md`
   - `AGENT.md`
   - `PROMPT.md`
   - `task01-<slug>.md` ... `taskNN-<slug>.md`
   - `evidence/.gitkeep`
   - `scripts/.gitkeep`

   **Solo si P5 ≠ "ninguno":**
   - `INSTRUCTIONS.md`

   **Según runner (P7):**
   - `run-claude.sh` y/o `run-codex.sh` — con `chmod +x`

7. En los `.sh`: `cd "$(git rev-parse --show-toplevel)"` si el proyecto tiene git, o ruta absoluta si no.

8. Al terminar, informa:
   - Rama y worktree creados (si GitFlow)
   - Archivos generados con ruta completa
   - Recuerda al usuario: "El único archivo que no debe modificarse es `goal.md`. El resto evoluciona con el trabajo."
   - Siguiente paso: `cd ../<proyecto>-<nombre-tarea> && ./tasks/<nombre>/run-claude.sh`

## Reglas de generación

- **Sin verificación ejecutable, no hay tarea válida**: si P3 queda vaga, no generes nada — sigue preguntando.
- **Sin placeholders sin resolver**: todos los `{{...}}` deben estar rellenos.
- **Criterios siempre como comandos**: si el usuario da un criterio descriptivo, tradúcelo a comandos concretos con salida esperada.
- **tasks.md refleja exactamente las tareas generadas**: una fila por taskNN.
- **Los timestamps usan la fecha de hoy**: obtenerla con la herramienta de fecha del sistema.
- **No inventar detalles técnicos**: rutas desconocidas → `# VERIFICAR`.
