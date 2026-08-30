# v1alpha3 / emit / quality-from-ruleset

**Regla:** [`04-expression.md` §3.4](../../../../spec/v1alpha2/04-expression.md) · **Afirmación:** estructura · **Nivel:** L0

---

El paquete de [`target-by-name`](../../valid/target-by-name/) exportado a ODCS. La asercion
del `Ruleset` sale **colgando de la propiedad**, que es donde ODCS la espera y donde Soda,
Great Expectations y dbt saben leerla:

```json
{ "name": "taxId",
  "quality": [
    { "id": "sin-nulos", "metric": "nullValues", "mustBe": 0,
      "x-oos-ruleset": "eu.nif" } ] }
```

Es la posicion que Ossie ocupa para la entidad, aplicada a la regla: **objetivo de emision,
no anfitrion.** Se emite ahi; no se escribe ahi. Escribirla colgando de la propiedad seria
una segunda superficie de autoria sin dueno propio, y por eso `quality` no esta en el
esquema de `Entity`.

Y `x-oos-ruleset` es lo que hace auditable el contrato: dice **quien exige** cada regla. Un
contrato que enumera obligaciones sin decir de donde vienen no se puede revisar — hay que
creerselo.

La seleccion no se recomputa aqui: la da `governance`, la misma que decide `OOS8001`. Dos
selecciones serian dos semanticas, y la que gobierna al compilar tiene que ser la que se
emite.
