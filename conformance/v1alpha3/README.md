# Suite de conformidad — v1alpha3

**Borrador.** Certifica el régimen de gobierno de
[`spec/v1alpha3/`](../../spec/v1alpha3/), que **no es normativo todavía**.

---

## Por qué vive en su propio árbol

Por lo mismo que el de v1alpha2, y ahora con más razón. La suite de v1alpha1 tiene 73 casos
y están los 73 en verde; ese número significa algo preciso —*una implementación de referencia
pasa la especificación completa*— y mezclar aquí casos de un borrador lo destruiría de la
peor manera posible: no dando un número falso, sino **dando un número que ya no se sabe qué
mide**.

Tres árboles, tres marcadores. `73/73` seguirá queriendo decir lo mismo el día que este
directorio tenga cincuenta casos.

## Qué afirma

| Caso | Código | Qué certifica |
|---|---|---|
| `valid/covered-by-assertion` | — | una aserción legible que puede fallar **cubre** |
| `valid/covered-by-mask` | — | una máscara también, y cierra el hueco de materialización |
| `invalid/uncovered-classified-property` | `OOS8001` | lo clasificado sin nadie que lo cubra |
| `invalid/coverage-by-warning-does-not-count` | `OOS8001` | un aviso **no** descarga la obligación de gobernar |
| `invalid/empty-target` | `OOS8002` | objetivo que no casa con nada |
| `invalid/mask-does-not-lower` | `OOS8003` | desclasificador que no baja |
| `invalid/duty-without-function` | `OOS2001` | deber que nombra una `Function` inexistente |
| `invalid/sql-assertion-across-datasources` | `OOS8005` | regla atada a un dialecto sobre dos fuentes |
| `invalid/target-on-integrity-lattice` | `OOS8006` | gobierno sobre el eje cuya monotonía corre al revés |
| `valid/target-by-name` | — | el **caso enumerado**, dentro de un `Ruleset` y con dueño |

**Diez casos.** `OOS8004` no aparece porque **está retirado**: existía para el deber sin
función, y `OOS2001` lleva reservado desde v1alpha1 para *«tipos de referencia nuevos»* que
`Function`, `Resolution` y `Test` iban a introducir. Activar una reserva es mejor que inflar
una familia.

## Los dos casos que hay que leer primero

[`uncovered-classified-property`](invalid/uncovered-classified-property/) es el **`OOS4001` de
este plano**, y por tanto el que justifica que exista un compilador para el gobierno.
`OOS4001` existe porque nadie ve una etiqueta a dos saltos; este existe porque el defecto **no
está escrito en ninguna parte**. No hay una línea mal puesta que señalar: hay una línea que
nadie escribió. Un `grep` no lo encuentra y una revisión de código tampoco, porque no hay
diff donde mirarlo.

[`coverage-by-warning-does-not-count`](invalid/coverage-by-warning-does-not-count/) es el que
protege al primero de volverse decorativo. Hay un `Ruleset`, apunta bien, y el objetivo no
está vacío — y aun así falla, porque `severity: warning` significa *«lo vimos y no paramos
nada»*. Sin este caso, la implementación más natural aceptaría el paquete y **la cobertura
pasaría a medir que alguien escribió un fichero**.

Un solo carácter separa los dos.

## Lo que los casos no pueden probar todavía

`OOS8001` demuestra que **existe** una regla, no que sea **la adecuada**: una política que
permite todo cubre igual que una que no permite nada. Los casos de aquí cierran los tres
huecos baratos —lo ilegible, lo que no puede fallar, lo que no puede fallar al compilar— y no
el caro. Tipar la cobertura por naturaleza está anotado en
[`02-ruleset`](../../spec/v1alpha3/02-ruleset.md) §9, no improvisado.

## Anatomía

Idéntica a la de v1alpha1 (`../README.md` §5): `case.yaml` con `rule`, `level` y `expects`;
`input/` con el paquete; `expected-error.json` cuando el caso rechaza; y un `README.md` que
explica **por qué la regla existe**, no qué hace el caso.

El campo `path` de un error esperado es informativo. **El `code` es normativo.**

Dos detalles de construcción que se repiten y conviene ver: varios casos declaran su retículo
**sin** `requiresGovernance` a propósito, porque con él `OOS8001` saltaría antes y el caso no
probaría lo que dice probar; y ninguno declara materialización ni conductos, para que la
familia `OOS4xxx` no se cruce con lo que se está midiendo.
