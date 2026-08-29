# invalid / circular-dependency

**Regla:** [`01-package.md` §3.1](../../../spec/v1alpha1/01-package.md) · **Código:** `OOS2002` · **Nivel:** L0

---

`acme/alpha` depende de `acme/beta`, que depende de `acme/alpha`.

Importar es **transferir autoridad**, y un ciclo significa que dos paquetes se delegan la
decisión el uno al otro sin que nadie la tome. No es solo un problema de resolución: es una
cadena de autoridad sin origen.

## El ciclo vive en el lock, y tiene que ser así

La primera versión de este caso declaraba el ciclo **en un comentario**: el manifiesto
pedía `acme/alpha`, el paquete pedía `acme/beta`, y una línea de prosa afirmaba que uno
dependía del otro. **Ninguna implementación podía detectarlo**, porque el grafo transitivo
no estaba en ninguna parte legible.

Se corrigió al implementar la fase de enlazado: el caso incluye ahora un `ontology.lock`
donde `acme/beta` declara su dependencia de `acme/alpha`. Ahí el ciclo es un hecho del
documento y no una afirmación del README.

Es también la razón de que `ontology.lock` reconstruya el grafo completo con las
dependencias de cada paquete ya resueltas: **sin él, la detección de ciclos exigiría red**,
y la compilación dejaría de ser hermética.
