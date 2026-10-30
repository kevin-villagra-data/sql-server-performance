# Estándar de performance y estilo T-SQL

Guía que documenté para el desarrollo de consultas del área, pensada para tablas de hechos de **cientos de millones de filas**. Versión pública, sin nombres de tablas internas.

## 1. Índices y filtros

- Unir por columnas indexadas (PK, FK o índices conocidos). Si no hay certeza de que exista el índice, decirlo y proponerlo.
- **Nunca aplicar funciones sobre la columna** de un filtro o de un JOIN (`CONVERT`, `YEAR`, `DATEDIFF`...). Reescribir como rango: `FECHA >= @DESDE AND FECHA < @HASTA`. → [ejemplo 01](ejemplos/01_filtro_sargable)
- Aplicar los filtros más selectivos **lo antes posible**, dentro de CTEs previas, y no sobre el resultado ya unido.
- En tablas muy grandes, materializar primero en una CTE el conjunto chico de IDs objetivo y recién después tocar la tabla grande. **Nunca unir tabla grande contra tabla grande sin pre-filtrar.** → [ejemplo 02](ejemplos/02_prefiltrado_en_cte)

## 2. Subconsultas y APPLY

- Evitar subconsultas correlacionadas. Reescribir como JOIN, `EXISTS`/`NOT EXISTS` o CTE.
- Toda subconsulta necesaria va como **CTE con nombre descriptivo** (`ORDENES_VALIDAS`, `ULTIMO_ESTADO_POR_OT`), nunca `T1`, `TEMP` o `A`. La consulta tiene que poder leerse de arriba hacia abajo.
- Evitar `CROSS APPLY` / `OUTER APPLY` salvo con funciones inline. Para "último/primer registro por grupo", usar `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`. → [ejemplo 03](ejemplos/03_ultimo_estado_por_ot)

## 3. Lógica repetida

Si una regla de negocio se repite (un `CASE` de clasificación, un cálculo de período), encapsularla con esta prioridad:

1. **Inline table-valued function (iTVF):** se expande en la consulta como una vista. → [ejemplo 04](ejemplos/04_itvf_en_lugar_de_escalar)
2. **Vista:** si no necesita parámetros.
3. **Función escalar:** solo si no hay alternativa. Se ejecuta fila por fila e impide el paralelismo.

## 4. Otras reglas

- Nada de `SELECT *`: columnas explícitas.
- `EXISTS` en lugar de `IN (subconsulta)` cuando se pueda.
- **`DISTINCT` no es un parche** para duplicados de un JOIN mal planteado: investigar la causa. → [ejemplo 05](ejemplos/05_exists_en_lugar_de_distinct)
- Consultas que se repiten con distintos valores: **parametrizadas** (`DECLARE @...`).
- `WITH (NOLOCK)` solo en lecturas de reporting sobre tablas de hechos (`*_facts`), que se cargan por lotes en ventanas conocidas. Ahí se acepta el riesgo de lectura sucia a cambio de no bloquear ni ser bloqueado por las cargas. En cualquier otra tabla, o si el dato tiene que ser exacto al instante, no se usa.

## 5. Estilo

- Alias pegado al campo, sin espacios de relleno: `E.ESTADO AS ESTADO_OT`.
- Una columna por línea en consultas largas; JOINs alineados.
- Columnas calculadas o ambiguas con alias descriptivo en mayúsculas y prefijo según el tipo:

| Prefijo | Significa | Ejemplo |
|---|---|---|
| `Q_` | cantidad | `Q_OT_CERRADAS` |
| `FLAG_` | booleano 0/1 | `FLAG_FUERA_DE_SLA` |
| `PCT_` | porcentaje | `PCT_OCUPACION_AGENDA` |

- **Sin comentarios dentro del código.** La consulta se autodocumenta con nombres de CTE, columnas y alias. La explicación va afuera (en este repo, en el README de cada ejemplo).

## 6. Cómo se explica una consulta

- Qué hace **cada CTE y por qué existe**, no la sintaxis. Mal: "esta CTE hace un SELECT con JOIN". Bien: "`OT_PERIODO` deja solo las OT del mes para no arrastrar toda la tabla de eventos al JOIN".
- La decisión técnica cuando se aparta de lo obvio: por qué `ROW_NUMBER` y no `APPLY`, por qué `EXISTS` y no `IN`.
- Los supuestos a validar: índices, cardinalidad, columnas que pueden venir con nulos o duplicados.
- Si la consulta transforma datos, una tabla con casos de entrada y salida.
