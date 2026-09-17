# 02 · Action — lo que un actor puede causar, sin código

**Estado:** borrador. Un `kind` nuevo. Aplica [`01-efectos`](../v1alpha2/01-efectos.md) con
una diferencia que se dice en §4: una acción no tiene código que atestar.

---

## 1. Naturaleza

> **Una `Action` es la invocación como documento: qué parámetros pide, sobre qué filas, con
> qué criterios, qué causa, y quién puede. Sin código.**

Es el equivalente de un *action type*: lo que una persona o un agente hace **desde una
aplicación** sobre la ontología. Y es un kind aparte de `Function` por una razón que no es de
forma:

| | `Function` | `Action` |
|---|---|---|
| qué es | lógica como código | una declaración |
| quién la escribe | quien programa | quien opera |
| integridad | se computa de los endosos del **código** (`attested`) | no hay código: la cierra **quien la aplica** (`humanApproval`) o la función que llama |
| dónde vive el valor que escribe | lo computa el módulo | viene de los parámetros o está fijo |

Lo más frecuente en una ontología operacional no es una función: es «pon `status` a
`DELIVERED` y `deliveredAt` a lo que me pasan», y hoy eso exigía compilar un módulo para no
computar nada. Una acción es ese documento, y no necesita runtime.

## 2. Anatomía

Una acción tiene **exactamente una** de dos formas: **declara** lo que causa (`sets`), o
**llama** a una función (`call`).

```yaml
apiVersion: oos.dev/v1alpha10
kind: Action
metadata:
  name: marcarEntregado
  namespace: supply
  description: Lo que hace el transportista al entregar.
spec:
  over: supply.envios                    # sobre una fila de esta vista
  input:
    deliveredAt: { type: Timestamp, required: true }
    nota:        { type: String }
  preconditions:
    - id: en-transito
      expr: 'target.status == "IN_TRANSIT"'
      message: "Solo se entrega lo que está en tránsito"
  sets:
    - writes: supply.Shipment.status
      to: DELIVERED
    - writes: supply.Shipment.deliveredAt
      from: input.deliveredAt
  endorsements:
    - endorser: humanApproval
  authorization: supply.Deliver
```

```yaml
apiVersion: oos.dev/v1alpha10
kind: Action
metadata: { name: cerrarEnvio, namespace: supply }
spec:
  over: supply.envios
  input:
    deliveredAt: { type: Timestamp, required: true }
  call: supply.cerrarEnvio               # la función que lo hace
  authorization: supply.CloseShipment
```

- `over` es la vista cuyas filas son la unidad, como en la función. `target` en las
  precondiciones es la fila.
- `input` son los parámetros que la aplicación pide, con el sistema de tipos de `02-entity`.
- `preconditions` son los criterios de envío: se evalúan antes, y una acción cuya
  precondición falla **no se ofrece**, que es lo que hace usable la superficie en una pantalla.
- `sets` es la superficie de efecto de una acción declarativa. Cada entrada es un efecto de
  v1alpha2 —`writes`, `from`, `to`— y el valor viene de `to` (fijo) o de `from: input.<x>`
  (un parámetro). No hay tercera fuente: una acción no computa.
- `call` nombra una `Function`. Los `input` de la acción son los de la función, y la
  superficie de efecto es la de la función.
- `endorsements` y `authorization`, como en la función.

## 3. Lo que una acción **no** es

- **No es un flujo.** Una acción causa lo que declara y termina. Encadenar acciones es de quien
  las invoca; la ontología no tiene pasos.
- **No es una notificación, ni un webhook.** Que algo ocurra fuera al aplicarla es de quien
  aplica, y no entra en el documento: un efecto que no aterriza en la copia no es un efecto de
  la ontología.
- **No es una función sin runtime.** Una función tiene lógica; una acción tiene una tabla de
  valores. Si hace falta computar, es una función y la acción la llama.

## 4. La integridad de una acción

Una acción declarativa **no tiene código que atestar**: `attested` no significa nada sobre una
tabla de valores, y es `OOS1004`. Lo que cierra la carencia es **quien la aplica**: un
`humanApproval` incondicional, y el nivel que el endosante declare cubrir. Sin endoso, una
acción es ⊥ y solo puede escribir lo que no exige integridad (`OOS7002`, como una función sin
firmar).

Una acción con `call` **hereda** la integridad de la función que llama, y puede añadir la suya:
una función atestada que además exige una firma humana al invocarse desde esta acción.

Y el arrastre (`OOS7001`) es el de la función: lo que la acción lee por `over` arrastra sobre
lo que escribe.

## 5. Las reglas

| | código | |
|---|---|---|
| sin `sets` y sin `call`, o con los dos | `OOS1004` | exactamente una forma |
| `sets` con un valor que no es `to` fijo ni `from: input.<x>` | `OOS1004` | una acción no computa |
| `from: input.<x>` con un `x` que `input` no declara | `OOS1004` | |
| `attested` en una acción declarativa | `OOS1004` | no hay código que atestar |
| `call` que no resuelve a una `Function` | `OOS2001` | |
| `input` de la acción que no cubre el de la función que llama | `OOS1004` | el contrato es el de la función |
| `over` que no resuelve a una `View`; precondición sobre un campo que no expone | `OOS7014` | |
| `writes` de `sets` que no resuelve | `OOS2005` | |
| destino sin integridad · derivada · no alcanza · efecto sobre vista sin copia | `OOS7005` · `OOS7006` · `OOS7002` · `OOS2025` | los de siempre |
| `metadata.labels` | `OOS1005` | |
| `kind: Action` en v1alpha9 o antes | `OOS1003` | es un documento de v1alpha10 |

## 6. Lo que se deriva, y por eso no se declara

**Qué acciones aplican a una fila.** Es la lista de acciones cuyo `over` es una vista de la que
la fila sale, filtrada por sus precondiciones. No hay campo que lo diga: se deriva del árbol, y
una pantalla lo pinta sin que nadie mantenga una lista.

**Quién la nombra.** Un `Ruleset` puede llamar a una acción por `duties[].call`, igual que a
una función; retirarla es `OOS2001` desde quien la llama.

## 7. Lo que la gramática no decide

- **Desde qué aplicación.** Que una acción se ofrezca en Forge, en un panel operacional o a un
  agente es de la superficie que la expone, y Cedar decide el principal. El documento dice qué
  se puede causar; no dónde está el botón.
- **La idempotencia de una acción.** `idempotency` es de la función. Una acción declarativa
  repetida escribe lo mismo dos veces, y si eso importa es una función.
