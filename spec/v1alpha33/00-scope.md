# OOS v1alpha33 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha33.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-enrich`](01-enrich.md) | **el enriquecimiento**: `runtime: enrich` del `Transform` y su fuente, `.enrich.yaml` |
| [`02-la-entrada-nueva`](02-la-entrada-nueva.md) | **un motivo de salud**: `input-refreshed`, construido con una versión vieja de lo que lee |
| [`03-lo-escrito-lee-una-tabla`](03-lo-escrito-lee-una-tabla.md) | **`derivedFrom` nombra una `Table`**: lo escrito desde una sesión dice que leyó una tabla, y hereda lo que lleva |

Esta versión **añade un runtime** al `Transform`, `enrich`, **un fichero de código**, `.enrich.yaml`,
**dos códigos**, `OOS2054` y `OOS3009`, y **un motivo de salud**, `input-refreshed`.

---

## 1. Lo medido

El vertical de la plataforma que implementa OOS es la inteligencia geoespacial (ORE 0066). La
operación que más se pide en él es **enriquecer**: añadir a cada fila de un dataset lo que dicen
otras capas según dónde está (en qué municipio cae un cliente, cuántos competidores tiene a 500 m,
cuánta población vive alrededor). Investigado el 2026-10-20 (ORE 0068 C4):

- **Las plataformas geo lo venden como producto**, con su propio vocabulario: CARTO (`ENRICH_POINTS`,
  `ENRICH_POLYGONS`, `ENRICH_GRID`), Esri (Enrich Layer, GeoEnrichment). Los almacenes de datos
  (BigQuery, Databricks, Snowflake) no tienen verbo: se escribe el *join* y la agregación a mano.
- **Lo que decide si el número es correcto es cómo se reparte cada variable**: una población se
  reparte por la fracción de área (extensiva), una renta media se pondera (intensiva). CARTO y Esri lo
  guardan como metadato de la variable. Escrito a mano en SQL, nadie lo comprueba.
- **Nadie gobierna el resultado**: de qué capa y versión sale cada columna, qué etiquetas hereda, si
  ha quedado viejo. Un `Transform` de OOS ya da el linaje y la etiqueta (v1alpha25 §7); un `.sql` a
  mano, no el reparto.

## 2. Lo que entra

1. **`runtime: enrich`** en el `Transform` ([`01`](01-enrich.md) §1): un transform **declarativo**, cuyo
   código no es un programa sino una declaración que la implementación traduce al motor que calcula.
2. **El fichero `.enrich.yaml`** (§2): el objetivo, las capas, la relación de cada una y lo que se
   toma, con su método de reparto.
3. **El grano** (§3): una fila de salida por cada fila del objetivo, siempre.
4. **Lo que se comprueba sin ejecutar** (§4): que las columnas existen, un solo CRS y metros sólo
   en un CRS que mide en metros, y el esquema de la salida.
5. **Las reglas** (§6), con `OOS2054` y `OOS3009`.
6. **La entrada nueva** ([`02`](02-la-entrada-nueva.md)): lo construido sabe que una entrada ya tiene algo más
   nuevo (`input-refreshed`), para todo transform.
7. **Lo escrito lee una tabla** ([`03`](03-lo-escrito-lee-una-tabla.md)): `derivedFrom` admite una `Table`,
   sin puerta de versión.

## 3. Lo que no entra (todavía)

- **La estadística zonal de ráster**: no hay tipo ráster.
- **El reparto dasimétrico** (por una variable auxiliar en vez de por el área) y el suavizado.
- **Áreas de estudio por red** (isócronas): necesitan una red de calles.
- **Enriquecer a una fecha** (los límites de entonces): v1 lee la versión vigente de cada capa.
- **El método por defecto como metadato de la columna** de la capa: v1 lo declara cada `take`.
- **El esferoide**: medir en metros sobre un CRS geográfico.

## 4. Lo que se acepta a cambio

- **Subir la versión del documento para usar `enrich`.** La puerta es del documento: un `Transform`
  de v1alpha25 sigue igual; uno con `runtime: enrich` es de v1alpha33.
- **Reproyectar antes de enriquecer.** Medir en metros exige un CRS que mide en metros; un dataset en
  `EPSG:4326` se reproyecta en una vista antes. Es explícito, como manda v1alpha32.
