# v1alpha8 / valid / a-package-exports-what-others-may-use

**Regla:** [`01-package.md` §3.2](../../../../spec/v1alpha1/01-package.md#32--exports--lo-público-y-llega-con-v1alpha8) ·
**Nivel:** L0

---

**El trío con [`invalid/a-reference-across-packages-needs-an-export`](../../invalid/a-reference-across-packages-needs-an-export/)
y [`invalid/exports-names-what-the-package-does-not-have`](../../invalid/exports-names-what-the-package-does-not-have/),
y los tres son el mismo árbol.** Aquí la lista está y nombra lo correcto; allí falta; allí sobra un
nombre.

## El árbol

```text
ontology.config.yaml
conduits.yaml              ┐ de la raíz: no son de ningún miembro y
lattices/sensitivity.yaml  ┘ gobiernan a los dos. Viajan con cada `.oob`
packages/infra/            la tabla y las dos vistas
packages/rrhh/             la entidad, con `backedBy: iberia`
```

`hr.Employee` vive en `rrhh` y se respalda de `hr.iberia`, que vive en `infra`. **La referencia
cruza la frontera del paquete**, y por eso hace falta que `infra` lo diga:

```yaml
# packages/infra/package.yaml
spec: { owner: team:data, exports: [hr.iberia] }
```

## Lo que este caso afirma, y no es solo que compile

**Que lo que se exporta es `hr.iberia` y no `hr.empleados`.** Las dos son vistas de `infra`, y la
cadena pasa por las dos —`iberia` se apoya en `empleados`—, pero **desde fuera solo se nombra una**.
Exportar la de arriba no obliga a exportar el peldaño sobre el que se apoya: el consumidor no lo
nombra, así que no se acopla a él, así que puede cambiar.

Es la diferencia entre visibilidad y membresía dicha en un árbol: el paquete **contiene** dos
vistas y **expone** una.

## Lo que NO dice

Que los documentos de la raíz haya que exportarlos. El retículo y la política de conductos no son
de ningún miembro y gobiernan a todos; pedirles permiso sería pedírselo a nadie.
