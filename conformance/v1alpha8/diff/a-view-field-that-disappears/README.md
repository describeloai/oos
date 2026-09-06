# v1alpha8 / diff / a-view-field-that-disappears

**Regla:** [`91-versioning.md` §5.1](../../../../spec/v1alpha1/91-versioning.md#51--rompedor-en-consumer) ·
**Código:** `OOS5001` · **Nivel:** L0

---

`hr.empleados` dejaba de exponer `borrado` y nadie se enteraba. Ahora:

```json
{ "code": "OOS5001", "axis": "CONSUMER", "subject": "hr.empleados.borrado" }
```

## Es el mismo código, un piso más abajo

`OOS5001` es *«eliminar una propiedad sin `moved` ni `reserved`»*, y un campo de vista es lo mismo
para quien lo nombra. **Y por eso esta regla no se pudo escribir en el peldaño anterior**: sin
`moved` en la vista, la regla no tenía válvula y todo renombrado de campo habría sido rompedor para
siempre.

Con `moved` puesto, la salida existe:

```yaml
spec:
  moved:
    - { from: borrado, to: eliminado, since: 2.0.0 }
```

y entonces `diff` calla, porque el nombre no desapareció: se movió, y hay dónde leerlo.

## Lo que NO dice

Que el campo se pueda quitar sin más. Un `moved` lo declara **movido**, no borrado; para retirarlo
de verdad está `reserved`, que además impide que el nombre vuelva con otro significado —`OOS2006`.
