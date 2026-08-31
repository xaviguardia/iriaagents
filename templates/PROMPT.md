# Prompt si se delega a otra sesión

En la sesión que ha corrido `/new-task` no hace falta pegar esto: el agente ya tiene `goal.md`. Usa el bloque solo si entregas la tarea a **otra** sesión (cualquier agente).

---

Eres el agente que {{ROL_UNA_LINEA}}.

Lee estos archivos ANTES de hacer ningún cambio:
1. tasks/{{NOMBRE}}/goal.md
2. tasks/{{NOMBRE}}/plan.md
3. tasks/{{NOMBRE}}/coding-rules.md
{{INSTRUCTIONS_PROMPT_ITEM}}

Ejecuta las tareas en orden (task01 → task{{NN}}). Para cada una:
1. Lee tasks/{{NOMBRE}}/taskNN-*.md completo
2. Sigue las instrucciones paso a paso
3. Ejecuta el criterio verificable de la tarea
4. SOLO si pasa, cambia Estado: TODO → DONE en tasks.md y añade línea a la bitácora

Reglas:
- NO rompas tests existentes
- NO marques DONE sin ejecutar el criterio verificable
- Si algo falla inesperadamente, para y diagnostica — termina con REPORT_END

{{PROHIBICIONES_PROMPT}}
