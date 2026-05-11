# Skill: close-task

Cierra una tarea: ejecuta los comandos de verificación del `goal.md`, captura la evidencia, documenta qué cambió respecto al plan y declara el objetivo conseguido.

**Principio:**
- El cierre lo manda el `goal.md`, no el plan. Si los tests pasan, la tarea está terminada — independientemente de cómo llegaste.
- La evidencia es la prueba. Sin captura ejecutable, el cierre no es válido.

## Cuándo usar este skill

- El usuario dice "cierra la tarea", "marca como hecho", "terminamos", `/close-task`, etc.
- El trabajo está hecho y hay que demostrar que el objetivo se ha conseguido.

## Flujo

Ejecuta las fases en orden. No declares el cierre hasta haber capturado evidencia real.

---

### Fase 1: Localizar la tarea

1. Pregunta (o infiere del contexto):
   > ¿Cuál es la ruta del directorio de la tarea? (p.ej. `tasks/nombre-tarea/`)
   >
   > Si hay una sola tarea en `tasks/`, úsala directamente sin preguntar.

2. Lee `goal.md` de esa carpeta. Extrae:
   - **Objetivo**: la descripción de qué hay que conseguir.
   - **Comandos de verificación**: el bloque con comandos y salida esperada.
   - **Estado inicial** (si lo hay): las métricas de partida.

3. Si `goal.md` no existe o no tiene comandos de verificación concretos, para y avisa:
   > `goal.md` no contiene criterios ejecutables. No puedo cerrar la tarea sin ellos.
   > Define primero los comandos de verificación en `goal.md`.

---

### Fase 2: Ejecutar verificación

1. Ejecuta cada comando de verificación del `goal.md`. Captura stdout y stderr completos.

2. Para cada comando, evalúa si el resultado cumple el criterio de éxito definido en `goal.md`.

3. Si **todos pasan** → continúa a Fase 3.

4. Si **alguno falla** → informa el resultado y pregunta:
   > El comando `<cmd>` no ha pasado:
   > ```
   > <output>
   > ```
   > ¿Quieres continuar el cierre igualmente (documentando el fallo) o prefieres arreglarlo primero?

---

### Fase 3: Capturar evidencia

La evidencia tiene que ser reproducible. En orden de preferencia:
- **Playwright trace o screenshot** — para flujos de UI: `playwright test --reporter=html`, captura de pantalla del estado final.
- **Dump** — para estado de datos: export JSON/CSV/SQL del estado que demuestra el resultado.
- **Diff de archivos** — para cambios en código o configuración: `git diff`, output de spec runner.
- **Output de comando** — solo si es la única opción (tests unitarios, checks de arquitectura, lint).

Los logs de servidor o de aplicación no cuentan como evidencia — son efímeros y no demuestran el estado final del sistema.

1. Obtén la fecha actual del sistema.

2. Crea el archivo `evidence/close-YYYY-MM-DD.md` con este formato:

```markdown
# Cierre de tarea — YYYY-MM-DD

## Objetivo conseguido

<objetivo copiado del goal.md>

## Verificación

### <nombre del comando 1>
```
<comando exacto ejecutado>
```
**Resultado:**
```
<output capturado>
```
**Estado:** ✓ PASS / ✗ FAIL

### <nombre del comando 2>
...

## Veredicto

PASS: N   FAIL: M   TOTAL: T

<si todo pasa>
✓ Objetivo conseguido. Todos los criterios de verificación han pasado.

<si hay fallos>
⚠ Cierre parcial. N de T criterios han pasado. Ver fallos arriba.

## Delta respecto al plan

<se rellena en Fase 4>
```

---

### Fase 4: Documentar el delta

Pregunta al usuario:

> El objetivo está conseguido. Antes de cerrar, ¿qué cambió respecto al plan original?
>
> - ¿Hubo tareas que no se hicieron? ¿Por qué?
> - ¿Aparecieron tareas imprevistas?
> - ¿El enfoque técnico fue distinto al planeado?
> - Si no hubo cambios relevantes, escribe "plan seguido sin desviaciones".

Espera la respuesta. Añade el delta al archivo `evidence/close-YYYY-MM-DD.md` bajo `## Delta respecto al plan`.

---

### Fase 5: Marcar como terminada

1. Añade al final de `tasks.md` (o créalo si no existe):

```markdown
---
## Cierre

**Fecha:** YYYY-MM-DD
**Estado:** ✓ DONE
**Evidencia:** evidence/close-YYYY-MM-DD.md
**Veredicto:** PASS: N / TOTAL: T
```

2. Si el proyecto usa GitFlow (existe rama `feature/<nombre>`):
   - Informa al usuario:
     > La rama `feature/<nombre>` está lista para merge a `develop`.
     > Cuando quieras, ejecuta:
     > ```bash
     > git -C <proyecto> merge --no-ff feature/<nombre> -m "feat(<nombre>): objetivo conseguido"
     > ```

3. Muestra el resumen final:

```
✓ TAREA CERRADA
───────────────────────────────────────
Objetivo:   <objetivo del goal.md>
Verificación: PASS: N / TOTAL: T
Evidencia:  evidence/close-YYYY-MM-DD.md
Delta:      <una línea del delta o "sin desviaciones">
───────────────────────────────────────
```

## Reglas

- **La evidencia tiene que ser reproducible**: Playwright traces, dumps o diffs. Los logs no cuentan.
- **Sin evidencia ejecutable no hay cierre válido**: si los tests no se han podido correr, documenta el motivo y marca como cierre-manual.
- **El veredicto lo da goal.md, no el plan**: el plan puede haber cambiado completamente — lo que importa es si los comandos del goal.md pasan.
- **No modificar goal.md**: es el contrato inmutable. Si los criterios estaban mal definidos, es aprendizaje para la próxima tarea.
- **Capturar output real**: no generes output simulado. Si un comando falla por entorno, documenta el error real.
