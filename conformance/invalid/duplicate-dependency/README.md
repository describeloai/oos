# invalid / duplicate-dependency

**Regla:** [`90-canonical-form.md` §N4](../../../spec/v1alpha1/90-canonical-form.md) · **Código:** `OOS2003` · **Nivel:** L0

---

El mismo paquete declarado dos veces con rangos distintos.

Lo interesante es **por qué el esquema no basta**. `uniqueItems: true` compara elementos
**por valor**, y estos dos objetos son literalmente distintos:

```yaml
- { package: oos.dev/regulatory/gdpr, version: "^2.1" }
- { package: oos.dev/regulatory/gdpr, version: "^3.0" }
```

El duplicado es **por clave semántica** —el nombre del paquete—, y saber cuál es la clave de
un conjunto es conocimiento del dominio, no de la forma. Es la razón por la que `OOS2003`
existe además de `uniqueItems`, y no en su lugar.

Ordenar un conjunto en la forma canónica exige haber resuelto antes los duplicados: dos
elementos con la misma clave y distinto valor no tienen un orden determinista.
