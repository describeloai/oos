# v1alpha14 / invalid / reads-by-a-function

**Regla:** [`01-la-vista-es-sql` 3](../../../../spec/v1alpha14/01-la-vista-es-sql.md#3) · **Nivel:** L0 · **Espera:** `OOS2038`

---

Se lee por nombre, nunca por función: `read_parquet` lee bytes que el árbol no nombra, sin linaje ni conducto.
