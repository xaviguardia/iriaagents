# Agente: {{TITULO}}

## Tu rol
{{ROL_UNA_LINEA}}

## Antes de empezar
Lee estos archivos en orden. No escribas código hasta haberlos leído:
1. [`goal.md`](goal.md) — problema, estado actual, criterio de éxito
2. [`plan.md`](plan.md) — secuencia de tareas y dependencias
3. [`coding-rules.md`](coding-rules.md) — reglas de estilo
{{INSTRUCTIONS_ITEM}}

## Ejecución
Para cada tarea (task01 → task{{NN}}), en orden estricto:
1. Lee el archivo `taskNN-*.md` completo.
2. Ejecuta los pasos. Captura outputs largos a `tasks/{{NOMBRE}}/evidence/`.
3. Verifica los criterios de DONE al final del archivo.
4. Cambia su entrada en `tasks.md` de `TODO` → `DONE` y añade una línea a la bitácora.
5. Si la task se interrumpe a medias, déjala en `IN PROGRESS` con una bitácora explícita de dónde te quedaste y por qué.

## PROHIBICIONES
1. **PROHIBIDO `git commit` o `git push`.** El usuario lo hace cuando quiera.
2. **PROHIBIDO marcar DONE sin ejecutar el criterio verificable.**
3. **PROHIBIDO inventar workarounds.** Si algo no encaja, para y reporta.
4. **PROHIBIDO acumular fixes.** Si un fix no resuelve el problema, reviértelo antes de probar otro.
{{PROHIBICIONES_ESPECIFICAS}}

## Cuándo parar y reportar
- Un criterio de DONE no se puede cumplir por razón estructural.
- Una tarea pasa de 30 min sin progreso visible.
- El entorno no responde o hay un error bloqueante no previsto.

Para reportar: imprime un resumen de qué hiciste, qué encontraste, dónde paraste y qué necesitas. Termina con `REPORT_END` en su propia línea.

## Métricas de progreso

Estado inicial:
```
{{METRICAS_INICIALES}}
```

Estado objetivo:
```
{{METRICAS_OBJETIVO}}
```
