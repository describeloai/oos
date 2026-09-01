# Suite de conformidad — v1alpha6

**Borrador.** Certifica la distribución de [`spec/v1alpha6/`](../../spec/v1alpha6/), cuyo
alcance sigue **abierto** y que **no es normativo**.

---

## Por qué vive en su propio árbol

Por lo mismo que los demás borradores. Un marcador significa algo preciso —*una implementación
de referencia pasa esto*— y mezclar casos de un borrador con los de v1alpha1 no daría un número
falso: daría **un número que ya no se sabe qué mide**.

## La familia `pack/`, que es nueva

Es la primera versión que añade una familia de casos, y la separación importa:

| | Qué produce |
|---|---|
| `emit/` | un **formato ajeno** — ODCS, Cedar, GraphQL |
| `pack/` | **nuestro artefacto** — el paquete publicable |

La mecánica es la misma —producir algo y afirmar su forma— y por eso el corredor las trata
igual. Lo que no es igual es la pregunta: `emit/` comprueba que traducimos bien a la casa de
otro, y `pack/` comprueba **qué se lleva y qué se queda** cuando lo que viaja es nuestro.

## Lo que esta suite cubre, y lo que se comprueba en otro sitio

De los [tres peldaños](../../spec/v1alpha6/01-distribucion.md#6-listo--tres-peldaños), aquí
solo puede vivir uno entero, y conviene decir dónde vive cada uno:

| Peldaño | Dónde se comprueba |
|---|---|
| **es determinista** | la **forma** del sobre, aquí. Su otra mitad —que el digest del `.oob` sea el del paquete sin empaquetar— **no cabe en una subcadena**: se comprueba comparando dos cómputos |
| **es verificable sin extraerlo** | en el motor: un `.oob` con una clasificación rebajada a mano se detecta **leyéndolo**, sin escribir nada |
| **el registro es prescindible** | en el motor: se trae un paquete, se **vacía el origen**, y el árbol sigue compilando |

Los dos últimos necesitan **ejecutar** un obtenedor y borrar un directorio, y eso no es una
entrada de caso: es una prueba de integración. Un caso que fingiera obtener algo comprobaría
el fingimiento.

> Una suite que cubre lo que puede y **dice dónde está el resto** es una suite. Una que se
> completa con casos que no miden nada es un número.
