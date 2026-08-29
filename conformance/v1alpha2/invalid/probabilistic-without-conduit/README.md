# v1alpha2 / invalid / probabilistic-without-conduit

**Regla:** [`03-resolution.md` §2](../../../../spec/v1alpha2/03-resolution.md#2) · **Código:** `OOS7009` · **Nivel:** L0

---

La estrategia pondera `legalName`, que esta clasificada `gdpr.sensitivity: medium`.

Comparar nombres a escala **no es una operacion de rendimiento**: es hacer fluir esos
nombres hacia un emparejador que tiene que sostenerlos para compararlos. Eso es un conducto
en el sentido literal de v1alpha1, y un conducto sin autorizacion declarada no se autoriza
solo.

El borrador lo escribia como `requires.materialization: cache` y se leia como una opcion de
cache. Renombrarlo a `conduit` es la mitad del arreglo; exigirlo es la otra.
