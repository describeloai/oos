# 01 · La geometría

**Estado:** normativo. Parte de OOS v1alpha32.

Dos tipos nuevos para columnas de `Table` y `Dataset` y para propiedades de entidad. Existen porque la
geometría **tiene forma y tiene sistema de referencia**, y sin tipo acaba como texto: un EWKB en
hexadecimal, un GeoJSON en una cadena o `Opaque` (00 §1).

## 1. `Geometry<subtipo, crs>`

```yaml
columns:
  ubicacion:
    type: "Geometry<Point>"                 # un punto en OGC:CRS84 (longitud, latitud)
  parcela:
    type: "Geometry<Polygon, EPSG:25830>"   # un polígono en ETRS89 / UTM 30N, como lo da el origen
  trazado:
    type: "Geometry<Any, EPSG:3857>"        # cualquier geometría en Web Mercator
  zona:
    type: "Geometry"                        # cualquier geometría en OGC:CRS84
```

- **Geometría plana**: las aristas entre vértices son rectas en el plano del CRS (la interpolación
  `planar` de Parquet e Iceberg).
- **El subtipo** es uno de `Any`, `Point`, `LineString`, `Polygon`, `MultiPoint`, `MultiLineString`,
  `MultiPolygon` y `GeometryCollection`. `Any` admite cualquiera. Puede llevar dimensiones: `Point Z`,
  `Point M`, `Point ZM` (y lo mismo con los demás), como en WKT.
- **El CRS** se escribe como código de autoridad, `AUTORIDAD:CÓDIGO`: `EPSG:25830`, `EPSG:4326`,
  `OGC:CRS84`. **Se guarda el del origen**: el documento no obliga a reproyectar, y quien lee sabe en
  qué está cada valor.
- **Por defecto**, el subtipo es `Any` y el CRS es `OGC:CRS84` (WGS 84 con los ejes longitud/latitud,
  el de GeoJSON, GeoParquet e Iceberg).
- **La forma canónica omite lo que vale por defecto**:
  - `Geometry<Any, OGC:CRS84>` se escribe `Geometry`;
  - `Geometry<Point, OGC:CRS84>`, `Geometry<Point>`;
  - un CRS distinto obliga a escribir el subtipo: `Geometry<Any, EPSG:3857>`.

  `parse_type(t.to_string()) == t` se cumple también aquí.
- **`EPSG:4326` y `OGC:CRS84` son el mismo datum con distinto orden de ejes en la definición de la
  autoridad.** En OOS el valor va **siempre** en orden x/y (§3), así que los dos describen los mismos
  valores. Se conserva el que diga el origen, y la forma canónica no los funde.

## 2. `Geography<subtipo>`

```yaml
columns:
  ruta_aerea:
    type: "Geography<LineString>"
```

- **Sobre el elipsoide**: las aristas son geodésicas (la interpolación `spherical` de Parquet e
  Iceberg). Es lo que hace falta a escala continental o global (rutas aéreas y marítimas), donde una
  recta en el plano no es el camino más corto.
- **El CRS es siempre `OGC:CRS84`**, y no se escribe. `Geography<Point, EPSG:4326>` es `OOS3008`.
- **Los subtipos** son los de §1. La forma canónica de `Geography<Any>` es `Geography`.

## 3. El valor

- **WKB** (ISO, *Well-Known Binary*), con los ejes siempre en orden **x/y**: longitud/latitud en un CRS
  geográfico, este/norte en uno proyectado, sea cual sea el orden que defina la autoridad. Es la regla
  de GeoParquet, GeoArrow e Iceberg.
- **Nulo y vacío son distintos**. Nulo es «no hay valor», con el contrato de nulos de siempre. Una
  geometría vacía (`POINT EMPTY`, `POLYGON EMPTY`) es un valor: «se sabe, y no ocupa espacio».
- **El subtipo se cumple al escribir**: un `Polygon` en una columna `Geometry<Point>` **no se escribe**.
  Lo rechaza quien escribe, con la columna, la fila y los dos tipos (como un `Vector<n>` de otra
  longitud, v1alpha17 01 §2). Un `Point` en `Geometry<Any>` sí se escribe.
- **En `Geography`**, la longitud va de −180 a 180 y la latitud de −90 a 90. Fuera de rango no se
  escribe.
- **La validez geométrica no es del tipo** (00 §3).

## 4. Cómo se guarda y cómo se lee

| en | `Geometry<s, crs>` | `Geography<s>` |
|---|---|---|
| **Arrow** (GeoArrow) | `Binary` con la extensión `geoarrow.wkb` y el CRS en sus metadatos | ídem, con `"edges": "spherical"` |
| **Parquet** | `BYTE_ARRAY` con el tipo lógico `GEOMETRY(crs)` **y** la clave GeoParquet `geo` del fichero (columna, `encoding: WKB`, tipos de geometría, CRS en PROJJSON y `bbox`) | `GEOGRAPHY(crs, spherical)` **y** la clave `geo` con `edges: spherical` |
| **Iceberg** | `geometry(crs)` en v3. Hasta que la implementación lo tenga, `binary` y el tipo en el contrato (§4.1) | `geography(crs, spherical)` en v3, o `binary` (§4.1) |
| **DuckDB** | `GEOMETRY` (el CRS, en el contrato) | `GEOMETRY` (la esfera, en el contrato) |
| **PostGIS** | `geometry(Subtipo, SRID)` | `geography(Subtipo, 4326)` |
| **BigQuery** | — (no tiene geometría plana) | `GEOGRAPHY` |
| **Snowflake** | `GEOMETRY` (con SRID) | `GEOGRAPHY` |

- **El tipo lógico y la clave GeoParquet van los dos**:
  - el tipo lógico da las estadísticas espaciales por grupo de filas y es el estándar de Parquet;
  - la clave `geo` es lo que leen GeoPandas, los lectores anteriores al tipo lógico y GDAL (medido en
    ORE 0066 T5: GeoPandas rechaza un fichero sin ella).
- **El CRS se escribe siempre explícito, en los dos**, también cuando es el de por defecto (medido en
  T5: un CRS implícito se pierde por el camino).

### 4.1 Mientras el lago no tiene el tipo

Una implementación cuyo formato de tabla todavía no tiene el tipo (Iceberg v2, o v3 sin `geometry`):
- guarda la columna como **binario**, con los ficheros de datos escritos como dice la fila de Parquet
  de §4;
- **el tipo de la columna sigue siendo el del documento**: el contrato lo conserva (en Iceberg, en las
  propiedades de la tabla);
- cuando el formato traiga el tipo, la columna pasa a él **sin reescribir los datos**, porque los
  bytes ya son WKB.

## 5. El ensanche y las reglas

| de | a | |
|---|---|---|
| `Geometry<Point>` | `Geometry<MultiPoint>`, `Geometry<GeometryCollection>`, `Geometry<Any>` (mismo CRS) | **ensancha**: todo valor anterior sigue valiendo |
| `Geometry<Any, A>` | `Geometry<Any, B>` | **no ensancha**: cambiar el CRS cambia los valores (es reproyectar) |
| `Geometry<s>` | `Geography<s>` y al revés | **no ensancha**: cambia lo que significa una arista |
| cualquiera | `Opaque` | como siempre: retira el gobierno (v1alpha1 02 §3.4) |

| | código | |
|---|---|---|
| `Geometry<…>` o `Geography<…>` en v1alpha31 o antes | `OOS3001` | tipos que no existían |
| un subtipo que no es de §1, una dimensión que no es `Z`, `M` ni `ZM`, un CRS que no es `AUTORIDAD:CÓDIGO`, más de dos argumentos, o un CRS en `Geography` | `OOS3008` | |
| una escritura no canónica (`Geometry<Any, OGC:CRS84>`, `Geometry< Point >`) | — | se acepta y se canoniza; el digest del paquete usa la canónica |

**Dónde valen.**
- Como tipo de columna de `Table` y `Dataset`, y de propiedad de entidad.
- Como campo de un `Struct<…>`.
- Como elemento de un `list<…>`: `list<Geometry<Point>>` son las posiciones de una trayectoria.

`OOS3008` es **un tipo geo mal formado**. `OOS3001` sigue siendo un tipo que no existe.
