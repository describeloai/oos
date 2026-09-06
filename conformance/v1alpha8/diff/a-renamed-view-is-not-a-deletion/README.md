# v1alpha8 / diff / a-renamed-view-is-not-a-deletion

**Regla:** [`91-versioning.md` §5.3](../../../../spec/v1alpha1/91-versioning.md#53--rompedor-en-index) ·
**Nivel:** L0

---

`hr.iberia` pasa a llamarse `hr.iberica`, y el manifiesto lo dice:

```yaml
# packages/…/package.yaml
spec:
  owner: team:data
  moved:
    - { from: hr.iberia, to: hr.iberica, since: 1.1.0 }
```

```json
{ "changes": [], "requiredBump": "patch" }
```

## Lo que este caso afirma

**Que renombrar deja de leerse como borrar.** Sin la línea del manifiesto, esto mismo sale como
`OOS5007` —*«`hr.iberia` desapareció»*— y lo que aparece con el nombre nuevo **no se reporta**,
porque añadir es compatible: nadie relaciona los dos hechos, y el consumidor se queda buscando un
documento que sí existe con otro nombre.

## Por qué el anuncio vive en el manifiesto

Por una sola regla, y es la misma que pone `moved` en la entidad para sus propiedades y en la vista
para sus campos:

> ### Lo dice el que sobrevive. Si no sobrevive nadie, lo dice el paquete.

Un `moved` de documento **sí** tendría superviviente —`hr.iberica` podría decir cómo se llamaba,
que es la forma de los `aliases` de Avro—. **`reserved` no**: un nombre retirado para siempre no
deja documento donde vivir, y los dos son un mecanismo. Ver
[`01-package` §3.4](../../../../spec/v1alpha1/01-package.md).

## Lo que NO dice

Que el compilador comprueba el `moved`. No comprueba que `from` haya dejado de existir ni que `to`
exista — **es exactamente el rigor que la entidad ya tenía**, y subirlo aquí habría cambiado su
regla de paso.
