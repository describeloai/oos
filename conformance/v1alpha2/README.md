# Suite de conformidad — v1alpha2

**Borrador.** Certifica el régimen de efectos de
[`spec/v1alpha2/`](../../spec/v1alpha2/), que **no es normativo todavía**.

---

## Por qué vive en su propio árbol

La suite de v1alpha1 tiene 73 casos y están los 73 en verde. Ese número significa algo
preciso —*una implementación de referencia pasa la especificación completa*— y mezclar aquí
casos de un borrador lo destruiría de la peor manera posible: no dando un número falso,
sino **dando un número que ya no se sabe qué mide**.

Un marcador que baja porque la especificación creció no informa de nada. Así que los dos
árboles se cuentan por separado, y `73/73` seguirá queriendo decir lo mismo el día que este
directorio tenga cincuenta casos.

## Qué afirma

Un caso por código de la familia `OOS7xxx`, más el `accept` que impide que la suite
distinga mal:

| Caso | Código | Qué certifica |
|---|---|---|
| `valid/function-attested-writes` | — | una función atestada escribe lo que alcanza |
| `invalid/propagated-integrity-below-target` | `OOS7001` | la integridad **computada** cae bajo el destino |
| `invalid/function-below-target-integrity` | `OOS7002` | sin endosos, la integridad es el mínimo |
| `invalid/conditional-endorsement-does-not-close` | `OOS7002` | un endoso condicional no cierra una carencia |
| `invalid/integrity-label-not-in-lattice` | `OOS7003` | nivel que el retículo no declara |
| `invalid/unknown-endorser` | `OOS7004` | endosante fuera del vocabulario cerrado |
| `invalid/target-without-integrity` | `OOS7005` | destino sin integridad declarada |
| `invalid/effect-on-derived-property` | `OOS7006` | efecto sobre una propiedad `derivedFrom` |
| `invalid/lattice-join-contradicts-axis` | `OOS7007` | `join` contradiciendo el `axis` |
| `invalid/effects-across-two-datasources` | `OOS7008` | efectos sobre dos fuentes físicas |

`OOS7002` tiene dos casos porque tiene dos causas que se confunden con facilidad: **no
tener endoso** y **tener uno que no cuenta**. Una implementación puede acertar la primera y
fallar la segunda, y el caso que las separa es el que hace normativa la distinción.

## El caso que hay que leer primero

[`propagated-integrity-below-target`](invalid/propagated-integrity-below-target/) es el
`OOS4001` de este eje, y por tanto el que justifica que exista un compilador.

La función **está atestada** y su destino exige `reviewed`. Aun así falla, porque lee un
`supplierScore` que viene de un tercero y es `untrusted`. La atestación dice que el
**código** es de fiar; no dice nada de la **entrada**. Un promedio no limpia un dato sucio.

Nadie escribió `untrusted` ni en la función ni en `status`: lo computó el compilador
propagando `meet` por lo que la función lee. Un linter no lo encuentra y un revisor tampoco,
porque la etiqueta está a dos saltos del sitio donde falla.

## Anatomía

Idéntica a la de v1alpha1 (`../README.md` §5): `case.yaml` con `rule`, `level` y `expects`;
`input/` con el paquete; `expected-error.json` cuando el caso rechaza; y un `README.md` que
explica **por qué la regla existe**, no qué hace el caso.

El campo `path` de un error esperado es informativo. **El `code` es normativo.**
