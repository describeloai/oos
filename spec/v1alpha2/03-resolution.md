# `Resolution` — el efecto sobre la identidad

**Estado:** borrador. `spec/v1alpha1/` sigue mandando.
Aplica el régimen de [`01-efectos`](01-efectos.md).

---

## 1. Naturaleza

De los tres efectos de v1alpha2, este es el peligroso.

Una derivación cambia el contenido y una `Function` cambia el mundo; los dos son reversibles
y los dos dejan rastro. `Resolution` decide que **dos registros son la misma cosa**, y eso no
es un cambio sobre la ontología: es un cambio sobre a qué se refieren todos los demás.

> **Fusionar dos entidades fusiona sus etiquetas.**

Un `Customer` de Salesforce clasificado `eu_only` y uno del ERP clasificado `global` no
producen algo intermedio: producen una entidad `eu_only`, porque `join = max` y la
restricción no se diluye. Eso ya lo computa v1alpha1 sin una regla nueva — y es lo único
de este documento que era gratis.

El resto no lo es, porque la resolución de identidad es **el problema más difícil de los
datos empresariales** y en casi todas partes vive dentro de una tubería, sin revisión y sin
nombre. Aquí es un documento en un pull request.

---

## 2. Las dos estrategias no son dos grados de lo mismo

Es la distinción que estructura el documento entero, y no es de precisión: es de **qué se
lee**.

| | Qué lee | Qué es |
|---|---|---|
| `deterministic` | **solo la clave** — un NIF, un DUNS | un `join`. No toca un valor de negocio |
| `probabilistic` | **valores reales, a escala** — nombres, direcciones | un flujo de datos etiquetados hacia un emparejador |

La segunda fila cae entera de v1alpha1 sin añadir nada: comparar nombres y direcciones es
hacer fluir esos nombres y direcciones hacia algo que los lee. **Un emparejador
probabilístico es un conducto**, y como tal exige autorización declarada.

El borrador de `docs/vision/` lo escribía como `requires.materialization: cache`, que se lee
como una opción de rendimiento. No lo es: **es la declaración del conducto**, y por eso se
renombra a `conduit`.

Y la clase es `materialization`, del vocabulario cerrado que ya existe — no una clase nueva.
Un emparejador que compara nombres a escala **tiene que sostener esos nombres para
compararlos**, así que es una materialización en el sentido literal. Que encaje sin ampliar
el vocabulario es la señal de que el conducto estaba bien definido desde v1alpha1.

```yaml
strategies:
  - id: tax-id-exact
    type: deterministic
    match:
      - { salesforce_crm: "Account.VAT_Number__c", postgres_erp: "erp.customer.tax_id" }
    normalize: [trim, upper, strip_non_alphanumeric]

  - id: fuzzy-name-address
    type: probabilistic
    conduit: materialization.matching   # ← no es rendimiento: es el conducto
    threshold: "0.92"
    weights:
      - { property: legalName,     method: jaro_winkler,            weight: "0.45" }
      - { property: postalAddress, method: normalized_levenshtein,  weight: "0.35" }
```

**Normativo.** Una estrategia `probabilistic` **DEBE** declarar `conduit`, y ese conducto
**DEBE** tener autorización declarada que alcance la etiqueta de **cada propiedad que
pondera** (`OOS7009`). Sin ella, la regla de flujo falla con `OOS4002` como con cualquier
otro conducto — no hace falta un código nuevo para el caso normal.

---

## 3. Una coincidencia probable no produce un hecho

Aquí está lo que este documento aporta al régimen, y sale de aplicarle el eje de integridad
a algo a lo que nadie se lo aplica.

Una estrategia probabilística **infiere**. Por bien calibrada que esté, produce una
conclusión, no una observación. Y la integridad de una conclusión no puede superar a la de
una inferencia:

> Una entidad resuelta por una estrategia `probabilistic` **NO DEBE** declarar integridad en
> el **nivel máximo** de un retículo, sea cual sea su `threshold`.

El techo es «no el máximo» y no un nivel con nombre, y eso es deliberado: obligaría a que
todo retículo de integridad declarase cuál de sus niveles significa «inferido», que es
vocabulario nuevo para decir algo que la posición ya dice. **Sea lo que sea la cima de tu
retículo, una conjetura no es eso.**

**`threshold: "0.99"` sigue sin ser un hecho.** Es la misma frase que `meet` dice en el otro
sitio —un cómputo no es más fiable que su entrada menos fiable— aplicada a la propia
operación en lugar de a sus datos: aquí lo menos fiable es *el método*.

La consecuencia práctica es la que interesa: una `Function` que escriba sobre una entidad
resuelta probabilísticamente **hereda ese techo**, y si su destino exige más, falla con
`OOS7001` señalando la resolución. Aprobar un pedido a un proveedor que *probablemente* es
el que crees no es una operación con una integridad distinta de esa probabilidad, y ahora
el compilador lo dice.

Elevar ese techo exige un endoso —`endorsements`, el mismo mecanismo de `02-function` §6—,
que es la única forma declarada de decir *me hago responsable de esta fusión*. Y en
resolución de identidad ese endoso tiene nombre propio en la práctica: alguien mira los dos
registros y decide.

---

## 4. Lo que **no** es un campo

Tercera vez que aparece el patrón, y ya no es casualidad:

> Un valor constante no es un campo.

El borrador declaraba `confidence: "1.0"` en las estrategias deterministas. **Determinista
significa 1.0** — si el NIF coincide, coincide. Declararlo es un campo derivable, luego no
declarable (**P2**), y además abre la puerta a `confidence: "0.8"` en una estrategia
determinista, que no significa nada.

**Y escribir el esquema lo llevó más lejos: `confidence` no existe en ninguna estrategia.**

La primera redacción le dio código propio —`OOS7010`— para el caso determinista. Al escribir
el esquema quedó claro que el campo tampoco significa nada en el probabilístico: lo que se
quería decir con él —*cuánta confianza merece lo que produce esta estrategia*— es
exactamente lo que dice el eje de integridad en §3, y **dos formas de decir lo mismo acaban
con dos semánticas**. Es el hallazgo del endosante otra vez, en pequeño.

Así que `confidence` desaparece del vocabulario y el error es estructural: `OOS1005`, clave
desconocida, igual que `labels` en una `Function`. `OOS7010` queda **retirado**.

Lo que sí significa algo en una `probabilistic` es `threshold`, y significa otra cosa: el
corte por debajo del cual no se fusiona.

---

## 5. El orden es semántico

Las estrategias **se evalúan en orden y la primera que casa gana**, así que `strategies` es
una **secuencia**, no un conjunto: N4 preserva su orden y no lo ordena.

No es un detalle de implementación. Poner `fuzzy-name-address` antes que `tax-id-exact`
cambia qué registros se fusionan, y una forma canónica que reordenara la lista produciría el
mismo digest para dos ontologías que resuelven identidades distintas — exactamente el fallo
silencioso que N4 existe para impedir.

---

## 6. La ambigüedad no se resuelve sola

Cuando dos candidatos superan el umbral, hay tres salidas y solo una es aceptable:

| | |
|---|---|
| fusionar el mejor | **no** — es una decisión tomada por un desempate |
| no fusionar ninguno | pierde la resolución en silencio |
| **marcar para revisión** | la ambigüedad es información, y sube a quien decide |

```yaml
onAmbiguity: FLAG_FOR_REVIEW
```

Es el único valor admitido, y por tanto —§4— **no es un campo**: es el comportamiento. Se
documenta aquí y no se declara.

Lo que sí se declara es qué hacer con lo marcado, y eso es un endoso: `humanApproval` sobre
la fusión concreta. Es el mismo mecanismo de `02-function` §6, y que sea el mismo importa —
un régimen con dos formas de decir *«que lo mire una persona»* acaba con dos semánticas.

---

## 7. Errores

| Código | Condición |
|---|---|
| `OOS7009` | estrategia `probabilistic` sin `conduit` declarado |
| `OOS7011` | integridad declarada por encima del techo que la estrategia puede producir |

**`OOS7010` está retirado** (§4). Existía para `confidence` en una estrategia determinista;
al desaparecer el campo del vocabulario, el fallo es una clave desconocida y ya tiene código.
Un código semántico para algo que el esquema resuelve estructuralmente es peso muerto — y
retirarlo antes de implementarlo es más barato que después.

Y los que **no** hacen falta, que es lo que dice que el régimen compone: una propiedad
ponderada cuya etiqueta supera la autorización del conducto es `OOS4002`; una que referencia
algo inexistente es `OOS2005`; la fusión de etiquetas por `join` no necesita comprobarse
porque **es** lo que el compilador ya computa.

`OOS7011` es el único código propio de este documento, y no es casualidad que sea el que
habla de integridad: es lo único que la resolución de identidad añade al régimen que no
estuviera ya.

---

## 8. Aplazado

- **Resolución transitiva.** Si A resuelve con B y B con C, ¿resuelve A con C? La respuesta
  correcta depende de si las estrategias son transitivas —el NIF sí, la similitud de nombres
  **no**— y meterlo aquí exigiría un modelo de clausura que no está escrito. Hoy la
  resolución es por pares.
- **Deshacer una fusión.** Es la operación que más falta hará en producción y la que peor
  encaja: deshacer no es un efecto sobre la identidad, es un efecto sobre la *historia* de
  la identidad, y eso es temporalidad. Va con `Test` y con lo temporal, después de L2.
