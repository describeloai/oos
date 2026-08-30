# v1alpha3 / invalid / mask-does-not-lower

**Regla:** [`02-ruleset.md` §4](../../../../spec/v1alpha3/02-ruleset.md#4) · **Código:** `OOS8003` · **Nivel:** L0

---

El objetivo selecciona `high` y por encima; la mascara declara producir `high`.

**Un desclasificador que no baja no es una salvaguarda: es teatro con coste de computo.** Y
lo que hace este caso posible es que la mascara **declare** su nivel de salida: la
comprobacion es local —compara dos niveles declarados— y no hace falta recorrer una sola
propiedad, porque ninguna puede estar por debajo del suelo que la selecciono.

Esto es lo que ningun catalogo puede comprobar. Una mascara de Unity Catalog o de Snowflake
es una funcion opaca evaluada en tiempo de consulta: nadie sabe que clasificacion sale por el
otro lado, y por tanto nadie puede decir si lo que sale puede ir a donde va.

La otra causa que este codigo tuvo en el borrador —declarar `to` sobre un `redact`— **ya no
es suya**: redactar hace desaparecer el valor, luego su salida es siempre el infimo del
reticulo, y al escribir el esquema quedo claro que eso es estructural. Es `OOS1005`, y es la
misma leccion de `OOS7010`.
