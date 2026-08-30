# v1alpha2 / invalid / expression-reads-undeclared

**Regla:** [`04-campos.md` §2](../../../../spec/v1alpha2/04-campos.md#2) · **Código:** `OOS4015` · **Nivel:** L0

---

```yaml
derivedFrom: [hr.Employee.baseSalary]     # falta `bonus`
expression: "baseSalary + bonus"
```

**Es el fallo de `OOS4001` con la etiqueta escrita en la linea de al lado.**

`derivedFrom` es lo que propaga: el compilador computa la etiqueta de `totalComp` por `join`
sobre lo que ahi se declara. Si la expresion lee `bonus` y `bonus` no esta en la lista, la
etiqueta de `bonus` **desaparece** y la propiedad derivada queda clasificada por debajo de lo
que le corresponde. A partir de ese punto fluye a sitios donde no deberia.

Lo que hace este caso distinto de `OOS4001` es que alli la etiqueta esta a dos saltos y no la
ve nadie; **aqui esta a un centimetro y tampoco la ve nadie**, porque hasta v1alpha2 los dos
campos no se hablaban. `expression` era prosa.

El analisis es deliberadamente conservador —no es un analizador de CEL— y solo puede
**apretar**: lo que se le escape produce un error de menos, jamas una etiqueta mas baja. Es
la unica direccion en la que fallar es aceptable.
