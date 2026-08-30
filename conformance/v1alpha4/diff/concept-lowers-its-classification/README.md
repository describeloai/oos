# v1alpha4 / diff / concept-lowers-its-classification

**Regla:** [`00-scope.md` §8](../../../../spec/v1alpha4/00-scope.md#8) · **Codigo:** `OOS5011` · **Nivel:** L0

---

`acme.personalEmail` decia `high`. En la version siguiente dice `low`.

Nadie mas cambia. **Y todas las propiedades que lo mapean —en paquetes que no se han
tocado— bajan de clasificacion, con lo que eso arrastra:** dejan de exigir gobierno, dejan de
ser seleccionadas por un objetivo `atLeast`, y pasan por conductos que antes las rechazaban.

## Por que este caso es el que mas importa de la fase

Es exactamente lo que `OOS4012` impide **dentro** de un paquete: una propiedad no puede
rebajar la clasificacion que hereda. Entre dos versiones de un concepto publicado, **no lo
veia nadie** — el diff clasificaba esto como `patch`.

La asimetria entre las dos situaciones no tenia ninguna justificacion. Es la misma
rebaja, hecha desde el otro lado de la frontera del paquete, y ahi es **peor**: dentro de un
paquete quien rebaja al menos tiene el fichero delante.

## Y no trajo codigo nuevo

`OOS5011` es *«etiqueta de una propiedad rebajada»*, de v1alpha1, sin tocar. Un concepto
declara `type`, `labels` y `enum` — exactamente lo que declara una propiedad—, asi que sus
cambios **son** los cambios de una propiedad y pasan por la misma funcion.

Eso no es un ahorro de implementacion: es la tesis de `01-significado` §3 comprobandose sola.
