# v1alpha8 / valid / derived-property-needs-no-field

**Regla:** [`02-view.md` §5.3](../../../../spec/v1alpha8/02-view.md#53) · **Nivel:** L0

---

La única excepción de `OOS2022`, y es la que impide que la regla se coma algo
legítimo.

`totalCompensation` no tiene campo en `empleados`, y no le hace falta: `derivedFrom` declara de
qué propiedades sale, y **eso es su origen**. Exigirle además una columna sería exigir que esté
calculada en la fuente — justo lo que `Binding.properties.<x>.expression` hacía y lo que esta
versión ya no puede expresar ([`00-scope` §5.3](../../../../spec/v1alpha8/00-scope.md#53)).

Los dos casos hacen falta. Una regla probada solo por el lado que falla es media regla: sin este,
cerrar el hueco de la cobertura parcial habría prohibido de paso toda propiedad derivada, y nadie
se habría enterado hasta migrar un modelo que las use.
