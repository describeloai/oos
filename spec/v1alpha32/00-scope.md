# OOS v1alpha32 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-geometria`](01-la-geometria.md) | **los tipos geo**: `Geometry<…>` y `Geography<…>`, su CRS, su valor y cómo se guardan |

Esta versión **añade dos tipos**, `Geometry<…>` y `Geography<…>`, y **un código**: `OOS3008`.

---

## 1. Lo medido

El vertical de la plataforma que implementa OOS es la inteligencia geoespacial y geotemporal (ORE 0066).
Medido allí el 2026-10-16 (ORE 0066 §8, T1–T8):

- **La geometría no tiene tipo.** Una columna `geometry` de PostGIS llega como texto (su EWKB en
  hexadecimal), y un `GEOGRAPHY` de BigQuery, como `Opaque`. Quien la lee no sabe que es una geometría,
  ni en qué sistema de coordenadas está.
- **El ecosistema ya lo tiene.**
  - Parquet define los tipos lógicos `GEOMETRY` y `GEOGRAPHY`, con estadísticas espaciales por grupo
    de filas.
  - Iceberg v3 tiene `geometry` y `geography` (Snowflake los da en GA desde 2026-05-07, y AWS S3
    Tables también).
  - GeoParquet y GeoArrow fijan la codificación (WKB) y el CRS.
  - DuckDB, PostGIS, BigQuery y Snowflake tienen sus tipos.

  Sin un tipo en el documento, nada de eso se puede declarar ni comprobar.
- **Foundry lo resuelve con texto**: `geopoint` es `"lat,lon"` y `geoshape` es un GeoJSON en una
  cadena. Lo que da forma a un dato no puede ser una cadena (es el mismo defecto que v1alpha17 corrigió
  para los resultados con forma).

## 2. Lo que entra

1. **`Geometry<subtipo, crs>`**: geometría plana, con su CRS ([`01`](01-la-geometria.md) §1).
2. **`Geography<subtipo>`**: geometría sobre el elipsoide, siempre en `OGC:CRS84`, con aristas
   esféricas (§2).
3. **El valor es WKB**, con los ejes siempre en orden x/y (longitud/latitud o este/norte); nulo y vacío
   son cosas distintas (§3).
4. **La correspondencia** con Arrow (GeoArrow), Parquet (el tipo lógico **y** la clave GeoParquet),
   Iceberg v3, DuckDB, PostGIS, BigQuery y Snowflake (§4).
5. **El ensanche y las reglas**, con `OOS3008` para un tipo geo mal formado (§5).

## 3. Lo que no entra (todavía)

- **Funciones** espaciales: las da el motor que calcula (OGC Simple Features, `ST_*`); el documento no
  las nombra.
- **Ráster, nubes de puntos y cubos** como tipos de activo (ORE 0067, después de G3).
- **Un tipo de celda** (H3, S2, quadbin): por ahora una celda es un `Integer`, y su resolución va en la
  descripción.
- **La validez** de una geometría (anillos cerrados, sin autointersecciones) como regla del tipo: un
  valor inválido se guarda como llega, y la validez será una promesa (v1alpha31) cuando se pida.
