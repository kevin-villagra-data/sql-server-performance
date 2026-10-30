# 05 · `EXISTS` en lugar de `DISTINCT` para tapar duplicados

**Pregunta de negocio:** ¿qué OT creadas desde el 1/10 fueron reprogramadas al menos una vez?

**Problema (`antes.sql`):** el JOIN contra la tabla de eventos devuelve **una fila por cada reprogramación**. Una OT reprogramada 3 veces aparece 3 veces, y el `DISTINCT` se agrega al final para "arreglarlo". Funciona, pero:

- SQL Server primero arma todas las filas duplicadas y después las ordena o hashea para quitarlas;
- el `DISTINCT` esconde la causa: si mañana alguien agrega una columna de la tabla de eventos al SELECT, los duplicados vuelven y nadie entiende por qué.

**Solución (`despues.sql`):** la pregunta es "¿existe al menos un evento?", y eso es exactamente `EXISTS`. SQL Server hace un *semi join*: para cada OT, frena en el primer evento que cumple y no genera filas extra. No hace falta `DISTINCT` porque nunca hubo duplicados.

| ID_OT | Reprogramaciones | Filas con JOIN | Filas con EXISTS |
|---|---|---|---|
| 1001 | 0 | 0 | 0 |
| 1002 | 1 | 1 | 1 |
| 1003 | 3 | 3 → `DISTINCT` → 1 | 1 |

**Regla general:** si aparece un `DISTINCT` para corregir duplicados de un JOIN, revisar primero si el JOIN es el correcto.
