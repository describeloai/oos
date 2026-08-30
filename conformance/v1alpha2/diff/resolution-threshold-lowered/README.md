# v1alpha2 / diff / resolution-threshold-lowered

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md#41) · **Codigo:** `OOS5016` · **Nivel:** L0

---

`threshold: "0.95"` pasa a `"0.55"`. Se funden mas registros.

**Y eso no es un cambio de esquema: es un cambio de quien es quien.** Aguas abajo cambian los
recuentos, cambian los joins, y **un registro de cliente puede absorber los datos de otra
persona**. Antes de este caso, ese cambio viajaba como `requiredBump: patch`.

## Por que `OOS5016` y no un codigo nuevo

`OOS5016` existia para *«`minGroupSize` de `aggregate` reducido»*: un **parametro numerico de
seguridad que se afloja**, de modo que un desclasificador revela mas de lo que revelaba. El
umbral de una fusion es exactamente eso, y el proyecto **ya habia decidido** que aflojarlo es
rompedor — pero solo lo habia implementado del lado de Cedar.

Mismo riesgo con dos tratamientos segun en que documento estuviera escrito. Este caso cierra
esa asimetria sin inventar vocabulario.

## Y v1alpha2 ya sabia que esto era delicado

`03-resolution` escribio un regimen entero para ello: la estrategia probabilistica **es un
conducto**, y no alcanza la cima del reticulo de integridad sin un endoso. Se decidio que el
valor es peligroso, y se dejo invisible el cambiarlo.
