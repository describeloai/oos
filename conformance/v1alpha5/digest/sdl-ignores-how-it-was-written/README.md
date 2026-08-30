# v1alpha5 / digest / sdl-ignores-how-it-was-written

**Regla:** [`01-emision-graphql.md` §6.3](../../../../spec/v1alpha5/01-emision-graphql.md#63--peldaño-3--es-identificable) · **Nivel:** L0

---

El mismo paquete, escrito de dos maneras. Emite **el mismo SDL, byte a byte**.

| | `a` | `b` |
|---|---|---|
| orden de `properties` | `customerId, externalId, country, email` | al revés |
| orden de `uniqueKeys` | `[[email], [externalId]]` | `[[externalId], [email]]` |

Es el **peldaño 3**: `G1` aplicado a la emisión. Sin él, el contrato que un consumidor recibe
depende de en qué orden tecleó alguien un fichero — y entonces *«este esquema salió del bundle
`sha256:…`»* deja de ser comprobable.

## Lo que este caso obliga sin decirlo

Que la emisión **pase por la forma canónica**. Las dos diferencias de arriba ya están
resueltas allí: `90-canonical-form` §N4 ordena los conjuntos y `properties` es un mapa, no una
secuencia. Un emisor que leyera el YAML crudo y escribiera en el orden de aparición fallaría
este caso — y sería un emisor perfectamente razonable, que es justo por lo que hace falta el
caso.

## Y por qué no basta con «emitir dos veces lo mismo»

Comparar dos ejecuciones sobre **el mismo fichero** solo descarta que el emisor use un mapa
sin orden o un reloj. No descarta lo que de verdad rompe `G1`: que **dos autores** describan
la misma ontología y obtengan contratos distintos. Este caso compara dos escrituras, no dos
ejecuciones.
