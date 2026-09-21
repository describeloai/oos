# v1alpha12 / invalid / a-view-that-still-says-materialized

**Regla:** [`02-la-vista-y-la-entidad.md` 3](../../../../spec/v1alpha12/02-la-vista-y-la-entidad.md#3) · **Nivel:** L0

---

`View.materialized` se retira como se retiró `Binding`: en v1alpha12 es una clave que no es de aquí (`OOS1005`), y el mensaje dice el remedio —un `Dataset` con `from: { view: hr.iberia }`—. La misma vista en v1alpha8 sigue compilando: nada anterior cambia.
