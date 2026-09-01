# `packages/` — vocabulario publicable

**Ontologías que no modelan nada: publican los conceptos con los que otros modelan.**

Un paquete de aquí no describe el patrimonio de nadie. Declara `kind: Property` —qué es un
dato, cuánto pesa y qué clase de regla exige— para que una ontología pueda **acogerse** a
ellos en vez de volver a decidirlos. Es lo que `02-property` §7 llama publicar vocabulario,
y lo que convierte *«GDPR como dependencia»* en algo literal.

```
packages/regulatory/gdpr/   los conceptos que el RGPD nombra, y la escala con la que pesan
packages/types/iso/         los codigos de un registro internacional, sin clasificar nada
```

Los dos publican `kind: Property` y **no traen lo mismo**: uno dice cuánto pesa un dato y qué
gobierno exige; el otro, qué es y qué forma tiene. Es la misma distinción que separa a un
regulador de un registro, y decide en cuál va cada concepto.

La ruta espeja la coordenada con la que se importa —`oos.dev/regulatory/gdpr`— y esa es toda
la convención que hay aquí. **No decide** la pregunta que `spec/v1alpha4/00-scope` deja
abierta: qué relaciona la identidad de un `Package` local con la coordenada de una
dependencia. Mientras eso no esté decidido, `metadata.name` es el nombre corto y la
coordenada vive solo en `dependencies`.

## Qué lo distingue de `examples/`

| | Qué es | Para qué se lee |
|---|---|---|
| `examples/` | ontologías de referencia | **enseñan a modelar** — se leen y se copian |
| `packages/` | vocabulario | **se consume** — se importa y no se copia |

Los dos validan con cero diagnósticos y no es la misma propiedad. Un ejemplo que no valida
enseña mal; un vocabulario que no valida **rompe a todo el que lo importe**, y a distancia:
el fallo aparece en el repositorio de otro.

## La regla de admisión

> **Entra lo que es cierto en todas partes.**

Es la línea de [`02-property`](../spec/v1alpha4/02-property.md) §1.1 —*el concepto declara lo
que es cierto de él en todas partes; la propiedad declara lo que es cierto de esa columna*—
aplicada un piso más arriba, al paquete entero:

- **Solo entra lo que su autoridad gobierna.** Un paquete regulatorio publica lo que el
  reglamento nombra. Si la respuesta a *«¿quién decide si esto es correcto?»* es *«nosotros»*,
  no es un concepto publicable: es del que modela.
- **Un paquete, una autoridad.** Los tipos ISO no van en el paquete del RGPD aunque hagan
  falta a la vez. Mezclarlos obligaría a versionarlos juntos, y una revisión del reglamento
  no debería mover el código de una moneda.
- **Sinónimos siempre.** `aiContext.synonyms` es *«exactamente el ancla contra la que un
  inductor propone»* (§2). Un concepto sin sinónimos existe y no lo va a encontrar nadie.

## Cómo se consume hoy

**Copiándolo en el árbol**, como un miembro más del workspace. Funciona: un miembro sin
entidades es un vocabulario, y los conceptos que nadie habla en ese workspace no están
muertos — están para que los importe otro. Lo fija
`conformance/v1alpha4/valid/vocabulary-member-has-no-entities`.

Lo que todavía **no** hay es resolutor: `dependencies` se declara y se comprueba contra el
lock, pero nadie lo resuelve. `ore lock` no existe y no puede vivir dentro de un compilador
que no habla por la red — se delegará, como se delegan los lectores de fuente.
