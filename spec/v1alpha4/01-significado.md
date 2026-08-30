# El régimen de significado

**Estado:** borrador. Gobierna los documentos que declaran su `apiVersion`, y es **alpha**:
sin garantías de compatibilidad.

El núcleo de v1alpha4. Todo lo demás de esta versión se deriva de lo que aquí se decide.

---

## 1. La tercera altura de una pregunta que ya contestamos

v1alpha2 escribió `Resolution` para decidir que **dos registros son la misma cosa**, y lo
llamó *el efecto sobre la identidad*. Era una de tres, y nadie lo vio:

| Declara que son la misma cosa | Nivel | |
|---|---|---|
| `Resolution` | dos **registros** | ✅ v1alpha2 |
| `Property` | dos **propiedades** | **falta** |
| `Interface` | dos **entidades** | **falta** |

> **v1alpha1 gobierna lo que se puede saber. v1alpha2, lo que se puede causar. v1alpha3, qué
> debe sostenerse. v1alpha4 gobierna qué es la misma cosa.**

Y no es una simetría bonita: es la fila que faltaba debajo de todo lo demás. La regla de
flujo compara etiquetas, la de gobierno exige que estén cubiertas — y **ninguna de las dos
comprueba que la clasificación sea consistente**, porque hasta ahora no había forma de decir
que dos propiedades son la misma.

> v1alpha3 gobierna **lo que alguien acertó a etiquetar**.

Esa frase es el motivo de esta versión.

---

## 2. El movimiento es el de `Binding`, en la otra dirección

Aquí está lo que hace que la pieza que falta sea casi gratis, y es el mismo hallazgo que en
las dos versiones anteriores: **ya existe, aplicada a otro nivel.**

```yaml
kind: Binding
spec:
  properties:
    employeeId: "Worker_Reference.ID"     # el nombre es mío, la columna es suya
```

Un `Binding` **declara una identidad a través de una frontera**: esta propiedad del modelo
*es* esa columna física. Nadie lo llama una segunda superficie de autoría, y nadie lo
confunde con la entidad — porque no duplica nada: **relaciona**.

| | Mapea una propiedad | Del modelo | A |
|---|---|---|---|
| `Binding` | ✓ | ✓ | **la fuente física** |
| `Property` | ✓ | ✓ | **el concepto** |

Es el mismo movimiento en la otra dirección: hacia abajo, dónde vive el dato; hacia arriba,
qué significa. Y la herencia también existe ya, con su dirección decidida: `02-entity` §4.1
dice que una propiedad **PUEDE** elevar la etiqueta que hereda y **NO DEBE** rebajarla
(`OOS4012`). Esa regla sube un nivel **sin cambiar una letra**.

**Lo único nuevo de esta versión es el nivel al que se aplica lo que ya está.**

---

## 3. Las tres piezas

### 3.1 · El concepto

Un `Property` no dice dónde vive un dato ni cómo se llama. Dice **qué es**.

```yaml
apiVersion: oos.dev/v1alpha4
kind: Property
metadata: { name: personalEmail, namespace: gdpr }
spec:
  type: String
  labels: { gdpr.sensitivity: high }
  description: >
    La dirección de correo de una persona física.
```

Tiene `namespace` y por tanto **dueño**, versión y digest: se publica, se importa y se fija
en el lock como cualquier otro documento. Un paquete regulatorio puede traer sesenta
conceptos con su clasificación ya decidida, y eso convierte *«GDPR como dependencia»* en algo
que además **clasifica**, no solo exige.

**Normativo.**

- `type` y `labels` los declara el concepto. Es lo único que declara.
- Un `Property` **NO DEBE** declarar `derivedFrom`, `expression` ni `examples`: eso es de la
  propiedad concreta, no del concepto. Un correo personal significa lo mismo se calcule como
  se calcule.

### 3.2 · El mapeo

La entidad conserva su nombre y declara qué concepto es:

```yaml
kind: Entity
metadata: { name: Customer, namespace: crm }
spec:
  properties:
    email:
      is: gdpr.personalEmail        # el nombre es mío, el significado es suyo
```

**Y aquí está el guardarraíl que esta especificación ya pagó caro por no tener.**

> Una propiedad **declara localmente o referencia un concepto, nunca las dos cosas.**

Una propiedad con `is` **NO DEBE** declarar `type` ni `labels`: los hereda. Declarar lo
heredado es exactamente `OOS4008` —*una propiedad derivada no declara su etiqueta, se
computa*— un nivel más arriba, y por el mismo motivo: **dos sitios donde decir lo mismo
acaban con dos semánticas.** Es la lección de `quality` inline, aplicada antes de cometer el
error en vez de después.

Lo que sí **PUEDE** hacer es **elevar** la clasificación —el correo de un menor puede ser
`critical` donde el concepto dice `high`— y **NO DEBE** rebajarla. `OOS4012`, sin cambios.

Y el nombre no importa: `Customer.email`, `Supplier.contactEmail` y `Employee.workEmail`
pueden ser el mismo concepto sin renombrarse. **Eso es lo que hace modelable un patrimonio
sucio**: no se limpia para gobernar, se mapea.

### 3.3 · La forma

Un `Interface` nombra un conjunto de entidades **por su forma**, y la forma se expresa en
conceptos, no en nombres:

```yaml
apiVersion: oos.dev/v1alpha4
kind: Interface
metadata: { name: Party, namespace: acme }
spec:
  requires:
    - gdpr.personalEmail
    - acme.legalName
```

```yaml
kind: Entity
metadata: { name: Customer, namespace: crm }
spec:
  implements: [acme.Party]
```

Que se exija **el concepto y no el nombre** es toda la diferencia. Quince casi-duplicados
salidos de quince sistemas distintos pueden implementar `Party` conservando cada uno su
vocabulario, y el gobierno apunta a `Party`. **Modelar sin esto obliga a limpiar antes de
gobernar, que es el orden imposible.**

Y da el tercer eje de objetivo que le faltaba a un `Ruleset`:

| Objetivo | Nombra un conjunto por |
|---|---|
| `atLeast` | **clasificación** |
| `named` | **identidad** |
| `implements` | **forma** |

No son tres formas de decir lo mismo: son tres criterios distintos. Y la monotonía se
comporta igual — si `Customer implements Party`, una regla sobre `Party` lo alcanza.

---

## 4. `nature` se disuelve

`Entity.nature` admite `entity` y `event`, y `OOS2010` dice: *«`nature: entity` sin
`primaryKey`, o `event` sin `timeKey`»*.

Eso **ya es una interfaz**: un nombre, una forma, y miembros obligatorios. Con un vocabulario
cerrado de dos.

Así que v1alpha4 no le añade nada a `Entity` en este punto — **le quita un caso especial**:

| | v1alpha1 | v1alpha4 |
|---|---|---|
| `entity` · `event` | vocabulario cerrado en el esquema | **dos interfaces incorporadas** |
| `OOS2010` | regla propia para dos formas | el caso general: *no satisface lo que declara implementar* |

Un mecanismo sustituyendo a un par grabado a fuego, y **el registro de errores encoge en vez
de crecer**. Es el resultado que P7 existe para producir.

---

## 5. La regla

Cada versión aporta una, y esta es la cuarta:

| | Regla | Dice |
|---|---|---|
| **v1alpha1** | `L ⊑ C` | nada **fluye** por encima de su autorización |
| **v1alpha2** | `I(f) ⊒ I(destino)` | nada **escribe** por encima de su integridad |
| **v1alpha3** | `L(x) ⊒ n ⟹ ∃r` | nada clasificado queda **sin gobernar** |
| **v1alpha4** | `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c` | **una forma declarada se satisface** |

Y es decidible al compilar por lo de siempre: los dos lados se computan del paquete, sin
tocar un dato.

### 5.1 · Lo que hace útil a la regla, y lo que la limita

Una entidad que **declara** implementar y no cumple es un fallo visible: está escrito en el
documento y una revisión lo encuentra.

Lo que **no** es visible —y es el modo de fallo real de un patrimonio sucio— es una columna
que **es** un `personalEmail` y que nadie mapeó. Eso el compilador no puede detectarlo, y no
por falta de esfuerzo: detectarlo exigiría adivinar significado desde un nombre, y esta
especificación ya decidió que **un análisis sólido no depende de parsear cadenas**
(`02-entity`, sobre `derivedFrom`).

Así que la regla hace lo mismo que `OOS8001`: **convierte en error lo que alguien declaró que
importaba.** Si `Customer implements Party`, faltar un concepto de `Party` rompe la
compilación. Si nadie declaró nada, nadie exige nada.

> **El compilador comprueba que las formas declaradas se cumplan. Que se declararan las
> formas correctas lo responde un dueño.**

Tercera vez que la frontera cae en el mismo sitio, y ya no es casualidad: **lo declarado es
decidible, lo omitido no lo es nunca.**

---

## 6. La familia `OOS9xxx`

| Código | Condición |
|---|---|
| `OOS9001` | una entidad declara implementar una interfaz y no la satisface |
| `OOS9002` | una propiedad con `is` redeclara lo que hereda —`type` o `labels`— |

Y los que **no** hacen falta, que es lo informativo:

| Condición | Código | De dónde sale |
|---|---|---|
| una propiedad rebaja la clasificación de su concepto | `OOS4012` | v1alpha1, **sin cambios** |
| `is` o `requires` apuntan a algo inexistente | `OOS2001` | reservado en v1alpha1 |
| tipo fuera del conjunto en un concepto | `OOS3001` | v1alpha1 |
| `nature` incoherente con su forma | `OOS9001` | **absorbe `OOS2010`** |

**Dos códigos nuevos y uno retirado.** Este registro se moverá al escribir los esquemas y los
casos —pasó las tres veces anteriores— y la dirección esperable es que encoja.

---

## 7. El ecosistema

| | Qué aporta | Por qué no se inventa |
|---|---|---|
| **`Binding`** de v1alpha1 | **el patrón del mapeo** | ya está: el modelo conserva el nombre, el mapeo declara la identidad |
| **`OOS4012`** | la dirección de la herencia | se puede elevar, no rebajar. Sube un nivel sin cambiar |
| **el retículo** | la clasificación que el concepto declara | sin cambios |
| **`Ruleset`** de v1alpha3 | el consumidor: gana un tercer eje de objetivo | `implements` junto a `atLeast` y `named` |

**Y `Ossie` no aporta nada aquí, que es lo que hay que decir en voz alta.** El estándar con el
que componemos modela *datasets, métricas, dimensiones, relaciones y contextos* — vocabulario
de capa semántica, de BI. **No tiene interfaces ni propiedades compartidas.** Así que esto no
es adoptar: es **inventar**, y **P7** exige pagarlo:

> Sin el concepto compartido, la clasificación sobre la que descansa todo v1alpha3 es
> arbitraria, y `discover` escribe cuatro mil conjeturas independientes en vez de cuatro mil
> mapeos sobre un vocabulario decidido.

De **Foundry** se adopta una cosa y se rechaza otra, y conviene separarlas. Se adopta **el
mapeo** —el concepto posee el significado, la entidad el nombre—, que es la parte que resuelve
el problema de las dos superficies. **No** se adopta que una interfaz cargue con acciones:
allí una interfaz lleva propiedades, enlaces y *actions*, y aquí una acción es una `Function`.
Que una `Function` pueda apuntar a una interfaz es una pregunta de v1alpha2, y va en §6 del
alcance como decisión abierta — no se resuelve metiéndola aquí.

---

## 8. Lo que este régimen no promete

- **Que se hayan declarado las formas correctas.** §5.1. Es la misma frontera que
  cobertura/adecuación, por tercera vez.
- **Descubrir sameness no declarada.** Dos propiedades que son el mismo concepto y no lo
  dicen son indistinguibles de dos que no lo son. Adivinarlo desde el nombre sería basar la
  solidez en parsear cadenas, y eso está decidido que no.
- **Que el concepto esté bien clasificado.** Que `gdpr.personalEmail` sea `high` es una
  afirmación de quien publica el paquete. El compilador comprueba que se respete, no que sea
  verdad — la misma honestidad que `01-efectos` §7 sobre la integridad de una fuente externa.
- **Limpiar los datos.** Un mapeo dice que dos cosas significan lo mismo. No las hace iguales,
  no las fusiona y no las normaliza. Fusionar registros es `Resolution` y es otra fila de la
  tabla de §1.
