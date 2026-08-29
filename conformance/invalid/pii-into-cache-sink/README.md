# invalid / pii-into-cache-sink

**Regla:** [`03-binding.md` §3.1](../../../spec/v1alpha1/03-binding.md) — el modo de
materialización instancia un conducto, y la regla de flujo de
[`04-flow.md` §2](../../../spec/v1alpha1/04-flow.md) aplica sin excepciones.
**Código esperado:** `OOS4002` · **Nivel:** L0

---

## Por qué existe

Es el caso fundacional de la familia `OOS4xxx` y la demostración mínima de la tesis del
proyecto: **la violación de gobernanza es un error de compilación, no una alerta en tiempo
de ejecución.**

Se comprueba herméticamente. Sin red, sin credenciales, sin haber leído un solo dato — y
aun así el sistema sabe que este paquete filtraría PII a una caché.

## Qué debe ocurrir

`hr.Employee.email` está etiquetada `gdpr.sensitivity: high`. El binding declara
`mode: cache`, que instancia el conducto `materialization.cache`, cuya autorización es
`gdpr.sensitivity: low`.

```
hr.Employee.email  ──binding──▶  materialization.cache

  etiqueta del origen      : high
  autorización del conducto: low        →  high ⋢ low
```

Una implementación conforme **DEBE** rechazar el paquete con `OOS4002` y **NO DEBE**
producir bundle.

## Sobre el tamaño de la entrada

Seis ficheros para un caso «mínimo» parecen muchos, y no lo son: **la comprobación de flujo
es intrínsecamente cruzada.** Hace falta el retículo que define el orden, la política que
autoriza el conducto, la entidad que porta la etiqueta y el binding que instancia el
conducto — más el manifiesto y el paquete para que aquello sea un paquete.

Que el caso más pequeño posible necesite cuatro documentos relacionados es, en sí mismo,
la razón por la que este error no lo puede detectar un JSON Schema.

## Variantes que faltan

| Caso | Qué añade | Código |
|---|---|---|
| `pii-derived-into-cache-sink` | la etiqueta **se propaga** desde una derivada en vez de estar declarada. **Es el que demuestra el análisis de flujo**; este solo demuestra la comprobación directa | `OOS4001` |
| `pii-into-cache-with-mask` | el mismo flujo, legal porque atraviesa un desclasificador autorizado | *válido* |
| `label-not-in-lattice` | etiqueta que no pertenece a ningún retículo declarado ni importado | `OOS4003` |
| `conduit-without-clearance` | modo de materialización cuyo conducto no tiene autorización — denegación por defecto | `OOS4011` |

Las cuatro son necesarias: la primera porque es la que respalda la afirmación central, y la
segunda porque **una suite que solo prueba lo que se rechaza no demuestra que lo legítimo
pase.**
