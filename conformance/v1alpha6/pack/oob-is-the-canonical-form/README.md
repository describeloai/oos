# v1alpha6 / pack / oob-is-the-canonical-form

**Regla:** [`01-distribucion.md` §1](../../../../spec/v1alpha6/01-distribucion.md#1-qué-es-un-oob) · **Nivel:** L0

---

> **Un `.oob` es la forma canónica escrita en un fichero.**

La respuesta evidente era un `tar.gz` con los `.yaml` dentro, y se cae con `G1`: un archivo
lleva marcas de tiempo, orden de entradas, permisos y nivel de compresión, así que **el mismo
paquete produce bytes distintos** y el digest deja de ser función del contenido. Habría hecho
falta inventar un «formato de archivo determinista». La forma canónica ya es una serialización
determinista de un paquete, y su digest ya está definido desde v1alpha1.

## Lo que el caso fija

| | |
|---|---|
| `oobVersion` | la versión **del sobre**. Puede cambiar sin que cambie ninguna gramática, y al revés |
| `package` · `version` | la identidad **dentro** del fichero: uno renombrado es uno que miente |
| `oos` | la mayor `apiVersion` de sus documentos, **derivada**. Aquí la pone el `Property` (v1alpha4), no el `Package` (v1alpha1) |
| `documents` | indexados por **identidad**, nunca por ruta |

Y tres ausencias, que son la mitad del formato:

**No va el `OntologyConfig`.** Es del workspace de quien publica y lleva sus fuentes físicas.
El caso lo hace visible con `INTERNO_URL`: el nombre de la variable de una fuente interna no
tiene por qué viajar a los consumidores.

**No va el digest.** Se *podría* —sobre `documents`, sin autorreferencia— y no va porque **un
número que un lector no debe creerse acaba creído**. Lo que se verifica es contra el lock de
quien consume.

Y no lleva saltos de línea ni espacios, porque JCS no los lleva: un `.oob` no se lee a mano,
se computa. Eso no se afirma aquí —un `contains` sobre un salto de línea dice más del lector
de aserciones que del artefacto— sino donde ya estaba: en la forma canónica.

## La propiedad que no cabe en un `contains`

El digest de este `.oob` es **el mismo** que el del paquete sin empaquetar, porque se computa
sobre las identidades de los documentos y nunca sobre las rutas (`digest` §5.2). Eso es el
[peldaño 1](../../../../spec/v1alpha6/01-distribucion.md#61--peldaño-1--es-determinista) y no
se puede afirmar con una subcadena: se comprueba comparando dos cómputos, y lo hace el motor.

Si el digest hubiera sido el del fichero, **cambiar de contenedor sería indistinguible de
cambiar de paquete** — y un lock resuelto contra un árbol dejaría de valer el día que ese
mismo paquete se publicara.
