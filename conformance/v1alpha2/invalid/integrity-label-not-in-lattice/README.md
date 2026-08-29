# v1alpha2 / invalid / integrity-label-not-in-lattice

**Regla:** [`01-efectos.md` §3.1](../../../../spec/v1alpha2/01-efectos.md#3.1) · **Código:** `OOS7003` · **Nivel:** L0

---

`certified` no es un nivel de `acme.assurance`. El reticulo declara
`untrusted, inferred, reviewed, attested` y nada mas.

Es `OOS4003` en el otro eje, y falla por la misma razon: el esquema comprueba que la clave
sea un nombre cualificado y el valor un identificador, y ahi se acaba lo que puede saber.
Que ese nivel exista en ese reticulo es una relacion entre documentos.

Y aqui importa mas que en confidencialidad: comparar contra un nivel inexistente en un
reticulo de integridad no produce un error de comparacion, produce **una comparacion que
nadie sabe como resolver**, y cualquier resolucion por defecto concede o deniega en
silencio.
