# v1alpha4 / invalid / concept-demands-governance

**Regla:** [`02-property.md` §3.3](../../../../spec/v1alpha4/02-property.md#33) · **Codigo:** `OOS8001` · **Nivel:** L0

---

**Este caso aisla el tercer origen de exigencia**, y para que lo aisle de verdad el reticulo
de este paquete **no declara `requiresGovernance` en absoluto**. Ninguna clasificacion exige
nada aqui. La propiedad esta en `low`, el nivel mas bajo que se usa en toda la suite.

Y no compila, porque el concepto lo exige:

```yaml
kind: Property
metadata: { name: healthCondition, namespace: gdpr }
spec:
  labels: { gdpr.sensitivity: low }
  requiresGovernance: [authorization]
```

## Por que el nivel no basta

El articulo 9 del RGPD enumera **categorias** —salud, biometria, convicciones— y sus
obligaciones se activan en cuanto el dato cae en una de ellas, **con independencia de lo
sensible que sea en ese contexto concreto**. No hay umbral que evaluar: la obligacion va
pegada a *que es* el dato, no a *cuanto* pesa.

Un `requiresGovernance` que solo colgara del reticulo obligaria a traducir *«esto es un dato
de salud»* a *«esto es `high`»*, **y esa traduccion es de alguien**. Que sea de alguien es el
hueco entero de esta version:

> v1alpha3 gobierna **lo que alguien acerto a etiquetar**.

Aqui alguien lo etiqueto `low` —mal, o por descuido, o porque en su sistema no parecia grave—
y la obligacion se sostiene igual. **Mapearlo basta.**

## Y no trae codigo propio

Falla con `OOS8001`, el mismo que existia desde v1alpha3, con el mismo mensaje y el mismo
diagnostico. Un origen nuevo de exigencia y **cero codigos nuevos** es la senal de que la
pieza encajo donde debia: la exigencia se compone por union con la de los reticulos, y la
union es asociativa, conmutativa e idempotente — **el orden de los origenes no puede cambiar
el resultado**.
