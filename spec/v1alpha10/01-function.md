# 01 · Function — lógica encapsulada sobre la copia

**Estado:** borrador. Sustituye la naturaleza de [`v1alpha2/02-function`](../v1alpha2/02-function.md)
y conserva su régimen: los efectos son la superficie, los endosos deciden la integridad, y una
función no aplica: propone. Aplica [`01-efectos`](../v1alpha2/01-efectos.md).

---

## 1. Naturaleza

> **Una `Function` es un trozo de lógica como código, encapsulado, que lee o edita los hechos
> de la copia, y que es el puente por el que un modelo soberano infiere sobre un conjunto de
> ellos. Lo que lee y lo que causa se leen en su documento.**

Sigue siendo el único canal por el que la ontología puede causar algo (v1alpha2 §1): un
agente no recibe credenciales, recibe una superficie. Lo que cambia es que la superficie tiene
**dos sentidos**. Lo que una función puede leer es exactamente la unión de las vistas que
declara; lo que puede causar es exactamente la unión de los efectos que declara. Fuera de las
dos no hay canal, y por eso el sandbox no tiene red.

Tiene **tres caras**, y son una sola cosa con el mismo régimen:

| cara | lleva | devuelve | integridad |
|---|---|---|---|
| **leer** | `reads`, `output` | un valor | no escribe: no hay carencia que cerrar |
| **editar** | `reads`, `effects` | una propuesta | `I(f) ⊒ I(destino)`, computada de los endosos |
| **inferir** | `reads`, `model`, `effects` | una propuesta | la misma: lo que el modelo afirma vale lo que su endoso |

## 2. Sobre qué actúa: la copia

No hay objetos. Hay tablas, vistas y entidades, y una función actúa sobre **las filas de una
vista**:

- `over` nombra la vista cuyas filas son la unidad de trabajo. La función se aplica **una vez
  por fila**, y `target` en las precondiciones es esa fila, con el vocabulario de la vista. Sin
  `over`, la función se aplica una vez, sobre el conjunto entero de `reads`.
- `reads` nombra las vistas que la función puede leer además de `over`. Entra en el sandbox
  lo que esas preguntas exponen, con sus etiquetas: **el sandbox es un conducto** y la regla
  de flujo de `04-flow` decide, sin extensión, si puede (`OOS4001`, `OOS4002`).
- `effects` nombra las propiedades de entidad que la función puede afirmar. La entidad sale de
  una vista (`backedBy`), la vista de una tabla, y el hecho nuevo aterriza **en la copia de esa
  vista**, en la fila que `changes.key` identifica. El origen no se toca.

Y la copia es la copia: una database `standard` la tiene entera, una `foreign` es un espejo.
Un efecto sobre una vista sin copia sigue siendo `OOS2025`, y en esta versión se lee así: *la
database es foreign, y sobre un espejo no se escribe*.

## 3. Anatomía

```yaml
apiVersion: oos.dev/v1alpha10
kind: Function
metadata:
  name: cerrarEnvio
  namespace: supply
spec:
  runtime: wasm
  entrypoint: dist/cerrar_envio.wasm
  source: src/cerrar_envio.ts

  over: supply.envios                  # la unidad: una fila de esta vista
  reads: [supply.proveedores]          # lo demás que puede leer, con sus etiquetas

  input:
    deliveredAt: { type: Timestamp, required: true }
  output:
    dias: { type: Integer }

  preconditions:
    - id: en-transito
      expr: 'target.status == "IN_TRANSIT"'

  effects:
    - writes: supply.Shipment.status
      from: IN_TRANSIT
      to: DELIVERED
    - writes: supply.Shipment.deliveredAt

  endorsements:
    - endorser: humanApproval
  authorization: supply.CloseShipment
```

Y el puente, que es la misma función con otro runtime:

```yaml
apiVersion: oos.dev/v1alpha10
kind: Function
metadata: { name: clasificarRetraso, namespace: supply }
spec:
  runtime: model
  model: modelo/v2-lite
  over: supply.envios
  prompt: "Para cada envío, di la causa probable del retraso."
  effects:
    - writes: supply.Shipment.causaRetraso
  endorsements:
    - endorser: humanApproval
```

Lee la pregunta, la lleva al modelo soberano, y lo que vuelve es un hecho que vale
`inferred` o más según quién lo firme. Un embedding sobre un conjunto es lo mismo con
`task: embed` y `writes: supply.Shipment.vector`.

## 4. Lo que se conserva de v1alpha2, tal cual

- **Las precondiciones son del contrato**, CEL total y sin efectos, evaluadas antes de
  ejecutar. Leen `target.<campo>` de `over`.
- **Los efectos se declaran, no se descubren.** La función no escribe; el motor escribe en su
  nombre lo declarado. `from` y `to` acotan la transición.
- **Una función, una fuente** (`OOS7008`). **Lo derivado no se escribe** (`OOS7006`).
- **La integridad se computa** de los endosos: ninguno es ⊥; `attested` o `humanApproval`
  incondicional cierran la carencia; un `when` no la cierra (`OOS7002`); `quorum` cuenta
  juicios, no eleva.
- **`authorization`** es Cedar y decide en invocación. Este documento decide si la función
  puede existir; Cedar, si este principal puede invocarla ahora.
- **Una función no aplica: propone.** La propuesta se coteja contra `effects` y contra la
  clave de la entidad.

## 5. Lo que cambia, y por qué

### 5.1 · `effects` es opcional

Leer y devolver es legítimo. Una función sin `effects` no tiene carencia de integridad que
cerrar y no necesita endosos; sigue sujeta a la regla de flujo por lo que lee. Lo que **no** es
legítimo es una función sin `reads`, sin `over` y sin `effects`: no toca nada, y un documento
que no toca nada es `OOS1004`.

### 5.2 · `reads` y `over` son vistas, y el arrastre gana su sujeto

`OOS7001` —la integridad por propagación— arrastraba por lo que una precondición miraba,
porque era lo único declarado. Ahora arrastra por **todo lo que la función lee**: el `meet` de
la integridad de los campos de `over` y `reads` en el retículo del destino. La atestación dice
que el código es de fiar, no que la entrada lo sea, y ahora la entrada está entera a la vista.

### 5.3 · La lectura no declarada es un error, no una omisión

Una precondición que mira `target.x` cuando `x` no es campo de `over`, o un `reads` que no
resuelve a una vista, es `OOS7014`. Es el espejo de `OOS2005` en el otro sentido: lo que no
está en la superficie no existe para la función.

### 5.4 · `writes` que no resuelve es `OOS2005`

v1alpha2 §8 lo decía y el compilador de referencia no lo hacía: un efecto sobre una propiedad
o una entidad que no existe compilaba, y retirar la entidad con la función puesta también. Esta
versión lo fija con un caso de conformidad. No es una regla nueva: es la de siempre, aplicada.

## 6. Las reglas

| | código | |
|---|---|---|
| sin `reads`, sin `over` y sin `effects` | `OOS1004` | no toca nada |
| `runtime: model` sin `model`, o con `entrypoint`; `model` o `prompt` con otro runtime | `OOS1004` | de v1alpha9 |
| `reads`, `over` o `sets` en una versión anterior | `OOS1005` | son de v1alpha10 |
| `metadata.labels` | `OOS1005` | la integridad no se declara sobre uno mismo |
| `over` o un `reads` que no resuelve a una `View` | `OOS7014` | la superficie de lectura |
| una precondición que mira un campo que `over` no expone | `OOS7014` | |
| `writes` que no resuelve a una propiedad de una entidad | `OOS2005` | la de siempre, aplicada |
| `model` que no resuelve a un `Model` | `OOS2005` | de v1alpha9 |
| efecto sobre una vista sin copia | `OOS2025` | la database es foreign |
| la raíz de la vista escrita sin `changes.key` | `OOS2024` | sin clave no hay «esta fila» |
| lo que lee no cabe por el sandbox | `OOS4001` · `OOS4002` | `04-flow`, sin extensión |
| destino sin integridad · derivada · dos fuentes · endosante fuera · condicional que no cierra · no alcanza | `OOS7005` · `OOS7006` · `OOS7008` · `OOS7004` · `OOS7002` · `OOS7002` | de v1alpha2, tal cual |
| lo leído arrastra por debajo del destino con el código atestado | `OOS7001` | ahora sobre `over` y `reads` enteros |
| dos ficheros con la misma función | `OOS2035` | |

## 7. Lo que la gramática no decide

- **Cómo el código recibe las filas.** Que `over` y `reads` lleguen como tablas, como
  iteradores o como un contexto del modelo es del runtime. La gramática dice **qué** puede
  entrar; el runtime dice **cómo**.
- **Qué gana entre el refresco y un efecto.** Dos autores sobre la misma fila de la copia: el
  origen por `changes.mode` y la ontología por una propuesta aplicada. Se nombra en `00-scope`
  §5 y no se decide aquí.
- **Quién puede invocarla desde dónde.** Cedar decide el principal; **desde qué superficie**
  —una aplicación, una obligación de un `Ruleset`, un agente— lo declara una
  [`Action`](02-action.md), o no lo declara nadie y la función solo existe para quien la
  nombra.
