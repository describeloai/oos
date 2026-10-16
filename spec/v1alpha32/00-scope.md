# OOS v1alpha32 — alcance

**Estado:** borrador de alcance, **alpha**: sin garantías de compatibilidad. La gramática es **del
documento** que declara v1alpha32.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-geometria`](01-la-geometria.md) | **los tipos geo**: `Geometry<…>` y `Geography<…>`, su CRS, su valor, cómo se guardan, cómo viajan y cómo se emiten |

Esta versión **añade dos tipos**, `Geometry<…>` y `Geography<…>`, y **un código**: `OOS3008`.

---

## 1. Lo medido

El vertical de la plataforma que implementa OOS es la inteligencia geoespacial y geotemporal (ORE 0066).
Medido allí el 2026-10-16, con un banco de datos geo propio y su vara (ORE 0067 G0):

- **La geometría no tiene tipo, y cada origen la entrega a su manera.** PostGIS da su EWKB en
  hexadecimal y la inducción solo sabe decir `physicalType: geometry(MultiPolygon,25830)`, sin `type`.
  BigQuery da `GEOGRAPHY` como WKT y la inducción lo deja en `Opaque`. Un GeoParquet llega como
  `binary`. Un par latitud/longitud, como dos `Float`. **De 16 columnas geo del banco, 0 salen tipadas.**
- **Declararla no se puede**: `Geometry<MultiPolygon, EPSG:25830>` en una `Table` es `OOS3001`.
- **El ecosistema ya lo tiene.**
  - Parquet define los tipos lógicos `GEOMETRY` y `GEOGRAPHY`, con estadísticas espaciales por grupo
    de filas.
  - Iceberg v3 tiene `geometry` y `geography` (Snowflake los da en GA desde 2026-05-07; las
    implementaciones abiertas los están terminando: ni pyiceberg 0.12 ni Iceberg Java 1.11 escriben
    todavía datos `geometry`).
  - GeoParquet y GeoArrow fijan la codificación (WKB, ejes x/y) y el CRS.
  - DuckDB, PostGIS, BigQuery, Snowflake, SQL Server y Oracle tienen sus tipos.

  Sin un tipo en el documento, nada de eso se puede declarar ni comprobar.
- **Foundry lo resuelve con texto**: `geopoint` es `"lat,lon"` y `geoshape` es un GeoJSON en una
  cadena. Lo que da forma a un dato no puede ser una cadena: es el mismo defecto que v1alpha17 corrigió
  para los resultados con forma.

## 2. Lo que entra

1. **`Geometry<subtipo, crs>`**: geometría plana, con su CRS, que se guarda **fiel al origen**
   ([`01`](01-la-geometria.md) §1).
2. **`Geography<subtipo>`**: geometría sobre el elipsoide, siempre en `OGC:CRS84`, con aristas
   geodésicas (§2).
3. **El valor es WKB** ISO con los ejes siempre en orden x/y; nulo y vacío son cosas distintas; el
   subtipo se cumple al escribir (§3).
4. **La correspondencia**: con Arrow (GeoArrow), Parquet (el tipo lógico **y** la clave GeoParquet),
   Iceberg v3, DuckDB y los orígenes (PostGIS, BigQuery, Snowflake, SQL Server, Oracle), y qué hace
   quien guarda mientras su formato de tabla no tiene el tipo (§4).
5. **Cómo viaja en texto** (WKB en hexadecimal) **y cómo se emite** en GraphQL (GeoJSON, en WGS 84)
   (§5).
6. **El ensanche, dónde vale y los errores**, con `OOS3008` para un tipo geo mal formado (§6).

## 3. Lo que no entra (todavía)

- **Funciones** espaciales: las da el motor que calcula (OGC Simple Features, `ST_*`); el documento no
  las nombra.
- **Un CRS sin código de autoridad** (un PROJJSON propio en el tipo): el tipo nombra el CRS por su
  código. PROJJSON es como se **escribe** en Parquet (§4), no como se declara.
- **Ráster, nubes de puntos, cubos y objetos en movimiento** como tipos o activos propios (ORE 0067,
  después de G3).
- **Un tipo de celda** (H3, S2, quadbin): por ahora una celda es un `Integer`, y su resolución va en la
  descripción.
- **La validez** de una geometría (anillos cerrados, sin autointersecciones) como regla del tipo: un
  valor inválido se guarda como llega, y la validez será una promesa (v1alpha31) cuando se pida.
- **Reproyectar al guardar**: el documento no obliga a ninguna transformación de coordenadas.

## 4. Lo que se acepta a cambio

- **Subir la versión del documento para declarar una columna geo.** La puerta es del documento, como
  en v1alpha17 y v1alpha29: una `Table` de v1alpha8 sigue igual hasta que alguien escriba un tipo geo.
- **Un formato de tabla sin el tipo** (Iceberg v2, o v3 en una implementación que aún no lo tiene)
  guarda la columna como binario y el tipo en el contrato (§4.1). Lo que cambia al pasar al tipo del
  formato es el esquema de la tabla, no los bytes del valor.
