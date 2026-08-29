# diff / reduce-min-group-size

**Regla:** [`91-versioning.md` §5.2](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5016`

---

`minGroupSize` baja de `8` a `2`. Un carácter en el diff.

El salario medio de un grupo de dos personas, si conoces el tuyo, **es el salario de la
otra**. El desclasificador sigue ahí, la política sigue ahí, el agente sigue recibiendo
"agregados" — y la garantía de k-anonimato ha desaparecido.

Es el mejor argumento a favor de haber tipado `minGroupSize` en lugar de dejarlo dentro de
una cadena de obligación libre. Un umbral que el compilador entiende es un umbral que
`ore diff` puede comparar; uno enterrado en texto habría pasado como edición cosmética.
