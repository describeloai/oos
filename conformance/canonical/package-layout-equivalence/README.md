# canonical / package-layout-equivalence

**Regla:** [`90-canonical-form.md` §5.2](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

El mismo paquete en las dos disposiciones admitidas: `a/` plana —el caso degenerado de un
único paquete implícito— y `b/` bajo `packages/hr/`.

Convergen **porque las rutas que entran en el digest son relativas al paquete**, no al
repositorio: `entities/Employee.yaml` en ambos casos.

## Lo que este caso valida

Es una consecuencia de §5.2 que estaba implícita y nadie había comprobado. Y es la que
hace practicable lo que `03` promete:

> Un repositorio puede migrar de la forma plana a la multi-paquete **sin cambiar ninguna
> definición, solo moviendo ficheros.**

Si el digest incluyera la ruta desde la raíz del repositorio, esa migración —que no cambia
un solo significado— produciría un artefacto distinto, invalidaría todas las firmas y
obligaría a redesplegar. Crecer de un dominio a diez dejaría de ser gratis.
