# v1alpha2 / invalid / sql-quality-in-entity

**Regla:** [`04-campos.md` §3](../../../../spec/v1alpha2/04-campos.md#3) · **Código:** `OOS1004` · **Nivel:** L0

---

Una entidad admite `library`, `text` y `custom`. **No admite `sql`.**

La particion es **por plano**, no por gusto:

| | Donde | Por que |
|---|---|---|
| `library` — `nullValues mustBe 0` | `Entity` | afirma algo sobre el **significado**. Sin dialecto |
| `sql` | `Binding` | esta atada a un dialecto, y el dialecto solo se conoce donde se declara la fuente |

Y por eso el error es **estructural**: `sql` es un valor fuera del conjunto que el esquema de
la entidad admite, luego `OOS1004`, sin codigo propio.

Lo que se hereda al usar `sql` es una limitacion de ODCS y conviene decirlo en vez de fingir
que no esta: **una regla `sql` no es portable entre fuentes.** La misma comprobacion escrita
como `library` no tiene el problema, porque no tiene dialecto.
