# v1alpha3 / invalid / sql-assertion-across-datasources

**Regla:** [`02-ruleset.md` §3](../../../../spec/v1alpha3/02-ruleset.md#3) · **Código:** `OOS8005` · **Nivel:** L0

---

El objetivo casa con `Customer.taxId` —en PostgreSQL— y con `Order.billingRef` —en
Salesforce—. La asercion es `type: sql`.

`OOS8005` es **`OOS7008` con el signo cambiado**, y que aparezca sin buscarlo es la senal de
que la particion de `01-gobierno` §4 no era una analogia. Alli una transaccion no cruza dos
fuentes; aqui una regla atada a un dialecto tampoco.

La limitacion se hereda de ODCS y no es nuestra: **una regla `sql` no es portable entre
fuentes**. Conviene decirlo en vez de fingir que si. La misma regla escrita como `library`
—`nullValues mustBe 0`— no tiene el problema, porque no tiene dialecto.
