# Skill: coach

Lee las métricas de uso de IA con `iria-monitor coach` y las traduce a un consejo concreto con vocabulario iriaagents.

## Cuándo usar este skill

- El usuario dice "coach", "dame un consejo", "cómo lo estoy haciendo", "revisa mis métricas", `/coach`, etc.

## Flujo

### Fase 1: Generar snapshot

1. Crea un directorio temporal:
   ```bash
   COACH_DIR=$(mktemp -d /tmp/iriacoach-XXXX)
   ```

2. Ejecuta el coach:
   ```bash
   iria-monitor coach --output-dir "$COACH_DIR"
   ```
   Si `iria-monitor` no está en PATH, informa:
   > `iria-monitor` no encontrado. Instala con: `pipx install obsly-ai`

3. Lee `$COACH_DIR/coach.json`. Si no existe (el LLM falló o no hay Claude CLI), reintenta con `--no-llm` y trabaja solo con `trends.json`.

### Fase 2: Mapear a señales iriaagents

Con los datos de `coach.json` y `trends.json`, identifica la señal más débil según esta tabla:

| Dato del coach | Señal iriaagents | Causa raíz habitual |
|---|---|---|
| `shipped_results` vacío | Nada cerrado con `/close-task` | Se trabaja sin contrato ejecutable en `goal.md` |
| `biggest_waste_pattern` menciona sesiones sin cierre | Sesiones off-track | Objetivo no definido antes de promtear |
| `dora_observations.lead_time` no medible | Sin ciclo de entrega | No hay `/close-task` que marque "done" |
| `improvement_advice` menciona ambigüedad de scope | Goal.md vago | Criterio de verificación descriptivo, no ejecutable |
| `dora_observations.wellbeing` menciona horas extremas | Sesiones paralelas o nocturnas | Demasiadas tareas abiertas en paralelo |
| `recent_shift` muestra scatter → focus → scatter | Foco inconsistente | Tareas sin goal.md anclan peor el trabajo |

Elige **una sola señal** — la más crítica. No hagas una lista de problemas.

### Fase 3: Presentar el consejo

Estructura fija, sin adornos:

```
HEADLINE
<copia literal de coach.json › headline>

LO QUE VEO
<una frase del biggest_waste_pattern o main_focus, reescrita en vocabulario iriaagents>

ACCIÓN ESTA SEMANA
<una sola acción concreta — basada en concrete_suggestion pero usando el vocabulario:
 goal.md / /new-task / /close-task / criterio ejecutable / evidencia>

LO QUE FUNCIONA
<good_pattern de coach.json, sin modificar>
```

Nada más. Sin listas de mejoras, sin el JSON raw, sin explicaciones del coach.

## Reglas

- **Un problema, una acción.** Si hay varios problemas, elige el más impactante.
- **Vocabulario iriaagents siempre:** `goal.md`, `/new-task`, `/close-task`, criterio ejecutable, evidencia. No uses jerga genérica de productividad.
- **No expliques el coach.** El usuario ya sabe qué es `iria-monitor`. Ve directo al consejo.
- **Si `coach.json` no tiene `headline`** (modo `--no-llm`): genera el headline tú leyendo `trends.json` — mira la ratio off_track/total y el order_score de los últimos 7 días.
