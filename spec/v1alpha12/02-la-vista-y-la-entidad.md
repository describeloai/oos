# 02 · La vista y la entidad sobre un dataset

**Estado:** borrador. Parte de OOS v1alpha12.
**Sustituye a** nada: [`v1alpha8/02-view`](../v1alpha8/02-view.md) y
[`v1alpha7/01-view` §5](../v1alpha7/01-view.md) (`backedBy`) siguen valiendo enteros para lo
que dicen.
Aquí sólo está **lo que cambia** para que una vista y una entidad compongan sobre un dataset, y
la clave que se retira.

---

## 1. `View.from` admite `{ dataset }`

```yaml
apiVersion: oos.dev/v1alpha12
kind: View
metadata: { name: brasil, namespace: olist }
spec:
  owner: team:olist
  from: { dataset: olist.customers }   # antes: { view: customers }, que era la copia
  fields: { id: id, ciudad: city }
  where: { state: SP }
```

`from` sigue siendo **exactamente una** de sus formas, y ahora son tres: `{ table }`,
`{ view }`, `{ dataset }`. Las tres resuelven con la misma regla (N1, `OOS2018`, `OOS2019`).
Con `{ dataset }`, cada valor de `fields` y cada clave de `where` y `groupBy` **DEBE** ser un
nombre que el dataset expone ([`01-dataset` §6](01-dataset.md)) — `OOS2018`.

**La raíz de lectura** de una vista sobre un dataset es ese dataset: es de donde salen las
filas, y siempre se deja leer. Por eso `OOS2020` (una raíz con `reads: none` exige copia) se
satisface con un dataset en la cadena, como se satisfacía con una vista `materialized`.

## 2. `Entity.backedBy` resuelve a una vista **o a un dataset**

```yaml
kind: Entity
metadata: { name: Customer, namespace: olist }
spec:
  backedBy: customers                  # una View o un Dataset de este espacio de nombres
  primaryKey: id
  …
```

La forma no cambia —sigue siendo una referencia—; cambia **a qué puede resolver**. Las reglas
se leen sobre lo que el respaldo expone: **DEBE** exponer la `primaryKey` y los `via` de las
relaciones (`OOS2011`), y un campo por cada propiedad que no declare `derivedFrom` (`OOS2022`).
Las etiquetas de las propiedades bajan por el plan del dataset como bajaban por el de la vista
(`OOS4002`).

Y `OOS2025` —una vista escrita por una función tiene que ser copia— se lee así: **la entidad
que una `Function` toca en `effects` DEBE estar respaldada por un dataset**, directamente o por
una vista cuya raíz de lectura sea un dataset. Una vista virtual sobre una tabla no tiene dónde
sostener una edición.

## 3. `View.materialized` y `View.freshness` se retiran

> Una `View` de v1alpha12 **NO DEBE** declarar `materialized` ni `freshness`. Es `OOS1005`, y
> el mensaje dice el remedio: *un `Dataset` con `from: { view: <ésta> }`*, que es donde van
> las dos.

Lo que `materialized` decía —«esta pregunta, además, se guarda, en el lago»— lo dice ahora un
documento propio, que es lo que el registro lista. Y `freshness` se va con ella porque era
suya: una vista virtual lee en el momento y no tiene retraso que tolerar; la frescura es una
decisión sobre **la copia**, y la copia es el dataset. La vista queda con **lo que es suyo**:
quién responde, de qué sale, qué sale y cómo se llama, qué filas son suyas, y —si es un
agregado— por qué se agrupa.

**«La copia más cercana bajando por la cadena»** (`02-view` §3), que el enlazado, el flujo y el
ejecutor comparten, pasa a ser **«el primer dataset bajando por la cadena»**. Es la misma
operación con otro predicado, y sigue siendo una.

## 4. Lo que no cambia

Todo lo demás de la vista (`fields` en forma breve, `where` cerrado, `groupBy`/`having`,
`oos.maturity` como única etiqueta, `moved`/`reserved`, `OOS2032`–`OOS2034`) y de la entidad
(propiedades, relaciones, `nature`, `derivedFrom`) es el de v1alpha8, sin una coma.
