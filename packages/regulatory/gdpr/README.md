# `oos.dev/regulatory/gdpr`

**El vocabulario del RGPD como paquete.** Quince conceptos, una escala, cero entidades.

`0.1.0` · `status: draft` · Apache-2.0 · **no es asesoramiento jurídico**

---

## Qué resuelve

Etiquetar a mano `gdpr.sensitivity: high` en cuatro mil columnas tiene dos problemas y el
segundo es el grave: cuesta, y **depende de que alguien acierte**. Un correo personal
clasificado `low` por descuido se escapa de su obligación regulatoria y el paquete compila.

Aquí la obligación va pegada a **qué es** el dato:

```yaml
correo: { is: gdpr.personalEmail }
```

Esa línea trae tres cosas sin escribir ninguna — el tipo, la clasificación y la clase de
regla que exige— y quien la escribe **no ha tenido que juzgar cuánto pesa un correo**.

### Medido, de punta a punta

Contra la implementación de referencia, sobre un consumidor mínimo con `contextSurface`
a `medium`:

| | Qué pasa |
|---|---|
| se mapea `correo` a `gdpr.personalEmail` | **el paquete deja de compilar**: `OOS8001`, el retículo importado exige un `constraint` para `high` |
| se escribe el `Ruleset` que faltaba | compila |
| se emite `--format graphql` | **`correo` no está en el SDL.** Excede el techo del conducto, y lo que no cabe en el contrato no lo puede pedir un agente |

Nadie escribió una etiqueta en una entidad. *Cumplimiento como dependencia*, y la frase deja
de ser una promesa.

---

## Qué hay dentro

**La escala.** `gdpr.sensitivity` —`none ⊑ low ⊑ medium ⊑ high ⊑ critical`— vive aquí porque
la autoridad sobre el orden no es de quien modela. Si cada repositorio declarase la suya,
`high` querría decir una cosa distinta en cada uno y una etiqueta importada no significaría
nada. Trae su `requiresGovernance` por nivel: `high` exige `constraint`, `critical` exige
además `authorization`.

**Los conceptos**, en tres grupos que no son estéticos —cada uno responde a una parte
distinta del reglamento:

| | Conceptos | Nivel |
|---|---|:---:|
| **identifica directamente** | `fullName` · `personalEmail` · `phoneNumber` · `postalAddress` | `high` |
| **personal, no público** | `dateOfBirth` · `ipAddress` | `medium` |
| **identificador de un estado** | `nationalId` | `critical` |
| **categorías especiales del art. 9** | `racialOrEthnicOrigin` · `politicalOpinion` · `religiousOrPhilosophicalBelief` · `tradeUnionMembership` · `geneticData` · `biometricIdentifier` · `healthCondition` · `sexLifeOrOrientation` | `critical` |

Los nueve de los dos últimos grupos declaran además `requiresGovernance: [authorization]`, y
esa duplicidad aparente es el punto de `02-property` §3.3: **la regulación no clasifica por
nivel, clasifica por categoría.** Si la exigencia solo colgara del retículo, bastaría con que
alguien bajara la clasificación para descargarla. Colgando del concepto, mapearlo basta — y
las exigencias se componen con unión, así que un retículo local más laxo no afloja nada.

Las ocho categorías especiales están **completas**, y eso no contradice el aviso contra la
inflación de §6.2: no es un concepto por columna repetida, es la enumeración cerrada que hace
el propio artículo 9.1. Transcribir una lista que ya existe no infla un vocabulario; lo ancla.

---

## Qué se dejó fuera, y por qué

Esta lista importa tanto como la otra. Un vocabulario crece por sus admisiones y **se estropea
por las que no debió hacer**.

| No está | Por qué |
|---|---|
| **el salario** | es dato personal y el RGPD no lo singulariza. Que sea `critical` es una decisión de una empresa, no del reglamento — y meterla aquí colaría el criterio de alguien en un paquete al que otros delegan autoridad |
| **el sexo o el género** | **no** son categoría especial del artículo 9. Confundirlos con la orientación sexual clasifica `critical` media base de datos, y una escala que marca todo como crítico es una escala que nadie respeta |
| **`countryCode`, `currencyCode`, `languageTag`** | son de `oos.dev/types/iso`. Un paquete regulatorio publica lo que la regulación gobierna, no tipos — y versionarlos juntos haría que una revisión del reglamento moviera el código de una moneda |
| **la base de licitud, el plazo de conservación, la evaluación de impacto** | dependen del tratamiento concreto, no del dato. No son ciertas *en todas partes*, así que no caben en un concepto (§1.1) |
| **`required`, `unique`, `temporal`** | dependen de la tabla. `personalEmail` es obligatorio en `Customer` y opcional en `Lead`, y sigue siendo el mismo concepto |

---

## Cómo se consume

```yaml
# ontology.config.yaml
dependencies:
  - { package: oos.dev/regulatory/gdpr, version: "^0.1" }
```

Se copia como un miembro más del workspace y se resuelve:

```
$ ore lock
  ✓ ontology.lock
  · oos.dev/regulatory/gdpr 0.1.0 · packages/gdpr · sha256:d47f6ee8ccb7
```

y después, en cada propiedad que **sea** uno de estos conceptos:

```yaml
properties:
  correo:  { is: gdpr.personalEmail }
  nacido:  { is: gdpr.dateOfBirth }
```

Lo que se hereda es un **suelo**: `05` de `02-property` fija que quien importa puede exigir
**más** y nunca menos. Un correo de un menor puede declararse `critical` sobre el `high` del
concepto —`OOS4012` existe para eso— y no hay forma de bajarlo.

### `0.1.0`, y no `2.1`

El ejemplo `examples/acme-retail` declara `oos.dev/regulatory/gdpr@^2.1` y su lock lo resuelve
en `2.1.4` contra `registry.oos.dev`. Eso es **ilustración**: el registro no existe y esos
digests están inventados. Este paquete arranca en `0.1.0` porque nada depende de él todavía y
`91-versioning` reserva `0.x` para lo que aún no promete nada. Publicar un `2.1.0` para
cuadrar con un lock de mentira habría sugerido que el lock es de verdad.

---

## Lo que falta, y lo que ya no

**El resolutor ya existe para la mitad que se puede usar hoy.** `ore lock` resuelve una
dependencia **contra el árbol**: si el paquete está vendorizado como miembro del workspace, lo
encuentra por su nombre —que es su coordenada—, comprueba el rango, computa su digest y
escribe la entrada. Lo que no hace es **traer** nada: `ore` no sabe hablar por la red, y el día
que exista un registro eso se delegará como se delega leer una fuente.

**Y vendorizarlo tampoco funcionaba**, que era el otro lado. Arreglarlo salió de medir con
este paquete:

```
$ ore validate .            # el vocabulario copiado dentro de un consumidor
error[OOS9004]: el concepto `gdpr.biometricIdentifier` no lo referencia nada del paquete
error[OOS9004]: el concepto `gdpr.fullName` no lo referencia nada del paquete
... trece más
```

Y la ayuda del diagnóstico recomendaba *«publícalo en un paquete SIN ENTIDADES»*, que es
exactamente lo que ya se había hecho. La excepción de `02-property` §6.1 es de un **paquete**
sin entidades y se estaba evaluando sobre el **workspace**, que no es lo mismo: un workspace
tiene miembros. Corregido —`conformance/v1alpha4/valid/vocabulary-member-has-no-entities`— el
mismo árbol da:

```
$ ore validate .
ok · sin errores
```

Y este paquete sigue validando solo, que es la otra mitad de la propiedad:

```
$ ore validate packages/regulatory/gdpr
ok · sin errores
```
