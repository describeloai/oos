# v1alpha8 / invalid / binding-in-v1alpha8

**Regla:** [`00-scope.md` §5.3](../../../../spec/v1alpha8/00-scope.md#53) · **Código:** `OOS1003` · **Nivel:** L0

---

`kind: Binding` **se retira de la gramatica** a partir de v1alpha8. No se borra: un documento que
declare `apiVersion: oos.dev/v1alpha1` y sea un binding sigue compilando —lo mide
`valid/mixed-versions`— porque v1alpha1 es normativo y sigue diciendo lo que decia.

Lo que no cabe es declarar la version nueva y usar la forma vieja: en v1alpha8 lo que este
documento quiere decir son **una `Table` y una `View`**, y decirlo en dos documentos es lo que
permite que dos vistas compartan un objeto sin repetir su contrato.

Este caso y `valid/mixed-versions` son las dos mitades de la misma decision, y hacen falta las
dos: uno solo diria la mitad.
