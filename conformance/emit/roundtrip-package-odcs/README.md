# emit / roundtrip-package-odcs

**Regla:** [`01-package.md` §4](../../../spec/v1alpha1/01-package.md) · **Afirmación:** `OOS → ODCS → OOS` es la identidad · **Formato:** ODCS v3.1.0

---

Un `Package` que ejercita las cinco secciones del perfil —Fundamentals, Team, Roles,
Support, SLA— más la extensión `dependencies`.

## Por qué se afirma la ida y vuelta y no los bytes de ODCS

El requisito normativo no es *"el ODCS emitido tiene estos bytes"* sino **"la ida y vuelta
es sin pérdida"**. Afirmar bytes exigiría fijar un serializador YAML concreto, y estaríamos
comprobando eso en lugar de la emisión.

Y hay una ventaja práctica: **el resultado esperado es comparable en OOS**, que es el
formato que quien revisa el caso ya domina. Nadie tiene que saberse ODCS de memoria para
verificar que este caso es correcto — basta comparar la entrada consigo misma.

## Lo que atrapa

Las traducciones asimétricas, que es donde se pierde información:

- `owner: team:people-platform` se emite como `team.name` y debe volver como handle
- `sla.breakingChangePolicy` viaja como `slaProperty` y debe reconocerse al volver
- `dependencies` viaja bajo `customProperties` como `x-oos-dependencies`
- `id`, ausente en la entrada, se deriva por UUIDv5 al emitir y **no debe reaparecer
  declarado** al volver
