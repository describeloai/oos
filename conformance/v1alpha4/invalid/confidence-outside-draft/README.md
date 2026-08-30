# v1alpha4 / invalid / confidence-outside-draft

**Regla:** [`01-significado.md` §4.2.1](../../../../spec/v1alpha4/01-significado.md#421) · **Codigo:** `OOS9003` · **Nivel:** L0

---

> Un documento que no esta en `DRAFT` **no puede contener una sola conjetura.**

Es la regla leida al reves, y asi es como hace trabajo: **la revision humana deja de ser una
buena practica y pasa a ser una condicion de compilacion.** No hay forma de promover un
documento arrastrando un mapeo que nadie miro.

Y vale igual para una herramienta ajena que para la propia. Una importacion desde un
inductor de terceros que traiga mapeos sin revisar **entra como `DRAFT` o no entra** — que
es exactamente lo que un molde tiene que conseguir: no dice lo que la herramienta debe
hacer, dice lo que tiene que ser cierto, y entonces la herramienta no tiene eleccion.

La diferencia con aprobar elemento a elemento en una interfaz: alli la aprobacion es un
acto que ocurrio y hay que creerse. Aqui es **un commit, con autor y diff, y un digest que
cambia**.
