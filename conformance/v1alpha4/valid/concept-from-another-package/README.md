# v1alpha4 / valid / concept-from-another-package

**Regla:** [`02-property.md` §7](../../../../spec/v1alpha4/02-property.md#7) · **Nivel:** L0

---

`gdpr.personalEmail` lo publica un paquete. `crm.Customer` lo mapea desde otro. Y **las tres
cosas cruzan la frontera**:

| | Qué aporta el paquete importado |
|---|---|
| `type` | `String`, sin que `crm` lo escriba |
| `labels` | `gdpr.sensitivity: high` — el suelo de clasificacion |
| `requiresGovernance` | `[authorization]` — **y por eso `crm` necesita una politica de Cedar para compilar** |

Esa ultima fila es lo que convierte *«GDPR como dependencia»* de metafora en hecho. `crm` no
declara que su correo sea sensible ni que necesite autorizacion: **lo hereda del vocabulario
que importa**, y si no pone la politica no compila.

## Lo que este caso certifica

Que un concepto **se comporta igual viniendo de otro paquete**. No hace falta ningun
mecanismo nuevo —un `Concept` tiene `namespace`, version y digest como cualquier documento—
y precisamente por eso habia que probarlo: lo que no tiene caso no se sabe si funciona.

## Y lo que NO certifica

**Que la dependencia este declarada no se comprueba.** Se midio: dos paquetes en el arbol con
un `is` que los cruza y **sin una sola linea de `dependencies`** validan igual. Y no es de
v1alpha4 — lo mismo pasa con una etiqueta de un reticulo ajeno, que es vocabulario de
v1alpha1.

La causa es que un paquete cargado es **una bolsa plana de documentos**: ORE no sabe a que
`package.yaml` pertenece cada fichero, asi que no puede saber si una referencia cruza una
frontera. Esta escrito en [`00-scope`](../../../../spec/v1alpha4/00-scope.md) §8.6 con la
pregunta de especificacion que abre, porque decidirlo es del modelo de empaquetado y no de
esta version.

Este caso trae `ontology.config.yaml` con la dependencia y un `ontology.lock` que la fija
**porque asi es como se escribe**, no porque el compilador lo exija todavia.
