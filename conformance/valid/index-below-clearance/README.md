# valid / index-below-clearance

**Regla:** [`04-flow.md` §2](../../../spec/v1alpha1/04-flow.md) · **Debe:** aceptar · **Nivel:** L0

---

`materialization.topology` autoriza hasta `medium`. Lo que se materializa es la topología —la
clave primaria y la propiedad `via` de la relación—, y `departmentId` está etiquetada
`low`. `low ⊑ medium`, así que compila.

**Una suite que solo probara lo que se rechaza no demostraría nada.** Un compilador que
rechazase todo pasaría los nueve casos `invalid/` de esta tanda y sería completamente
inútil. Este caso es el que impide esa lectura.

Es además el ejemplo de la tesis de materialización: se copian **las aristas**, no la carga
útil, y por eso la operación es legítima aunque la entidad contenga campos críticos que no
se copian.

## Sobre el digest

Este caso **no declara `expected.digest` todavía.** Un digest fabricado a mano sería peor
que ninguno: su valor no está en haberlo derivado sino en que dos implementaciones
independientes coincidan. Se añadirá como línea base cuando exista la primera
implementación conforme, y su función a partir de ahí será detectar regresiones.
