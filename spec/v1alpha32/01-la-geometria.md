# 01 · La geometría

**Estado:** normativo. Parte de OOS v1alpha32.

Dos tipos para columnas de `Table`, `Dataset` y `View`, y para propiedades de entidad. Existen porque la
geometría **tiene forma y tiene sistema de referencia**, y sin tipo acaba como texto: un EWKB en
hexadecimal, un WKT, un GeoJSON en una cadena o `Opaque` ([`00`](00-scope.md) §1).

## 1. `Geometry<subtipo, crs>`

```yaml
columns:
  ubicacion:
    type: "Geometry<Point>"                 # un punto en OGC:CRS84 (longitud, latitud)
  parcela:
    type: "Geometry<MultiPolygon, EPSG:25830>"   # en ETRS89 / UTM 30N, como lo da el origen
    physicalType: "geometry(MultiPolygon,25830)"
  trazado:
    type: "Geometry<Any, EPSG:3857>"        # cualquier geometría en Web Mercator
  zona:
    type: "Geometry"                        # cualquier geometría en OGC:CRS84
  cota:
    type: "Geometry<Point Z, EPSG:4258>"    # con altura
```

- **Geometría plana**: las aristas entre vértices son rectas en el plano del CRS (la interpolación
  `planar` de Parquet e Iceberg).
- **El subtipo** es uno de `Any`, `Point`, `LineString`, `Polygon`, `MultiPoint`, `MultiLineString`,
  `MultiPolygon` y `GeometryCollection` (los de OGC Simple Features). `Any` admite cualquiera. Puede
  llevar dimensiones, como en WKT: `Point Z`, `Point M`, `Point ZM`, y lo mismo con los demás salvo
  `Any`.
- **El CRS** se escribe como código de autoridad, `AUTORIDAD:CÓDIGO`: `EPSG:25830`, `EPSG:4326`,
  `OGC:CRS84`. La autoridad va en mayúsculas y letras; el código, letras y cifras.
- **Se guarda el CRS del origen.** El documento no obliga a reproyectar: quien lee sabe en qué está
  cada valor, y quien sirve decide a qué lo transforma.
- **Por defecto**, el subtipo es `Any` y el CRS es `OGC:CRS84` (WGS 84 con los ejes longitud/latitud,
  el de GeoJSON, GeoParquet e Iceberg).
- **La forma canónica omite lo que vale por defecto**:
  - `Geometry<Any, OGC:CRS84>` se escribe `Geometry`;
  - `Geometry<Point, OGC:CRS84>`, `Geometry<Point>`;
  - un CRS distinto obliga a escribir el subtipo: `Geometry<Any, EPSG:3857>`.

  Entre los argumentos va una coma y un espacio, y nada más. Leer la forma canónica y volverla a
  escribir da la misma cadena.
- **`EPSG:4326` y `OGC:CRS84` son el mismo datum** con distinto orden de ejes en la definición de la
  autoridad. En OOS el valor va **siempre** en orden x/y (§3), así que los dos describen los mismos
  valores. Se conserva el que diga el origen, y la forma canónica no los funde.

## 2. `Geography<subtipo>`

```yaml
columns:
  ruta_aerea:
    type: "Geography<LineString>"
  lugar:
    type: "Geography<Point>"
    physicalType: "geography(Point,4326)"
```

- **Sobre el elipsoide**: las aristas son geodésicas (la interpolación `spherical` de Parquet e
  Iceberg). Es lo que hace falta a escala continental o global (rutas aéreas y marítimas), donde una
  recta en el plano no es el camino más corto.
- **El CRS es siempre `OGC:CRS84`**, y no se escribe. `Geography<Point, EPSG:4326>` es `OOS3008`.
- **Los subtipos y las dimensiones** son los de §1. La forma canónica de `Geography<Any>` es
  `Geography`.

## 3. El valor

- **WKB** (ISO, *Well-Known Binary*), con los ejes siempre en orden **x/y**: longitud/latitud en un CRS
  geográfico, este/norte en uno proyectado, sea cual sea el orden que defina la autoridad. Es la regla
  de GeoParquet, GeoArrow e Iceberg.
- **El SRID no va en el valor.** El CRS es del tipo de la columna. Un EWKB (el WKB de PostGIS con el
  SRID dentro) se acepta al leer si su SRID casa con el CRS de la columna, y se guarda como WKB ISO.
- **Nulo y vacío son distintos.** Nulo es «no hay valor», con el contrato de nulos de siempre. Una
  geometría vacía (`POINT EMPTY`, `POLYGON EMPTY`) es un valor: «se sabe, y no ocupa espacio». En WKB,
  un `POINT EMPTY` son coordenadas NaN.
- **El subtipo se cumple al escribir**: un `Polygon` en una columna `Geometry<Point>` **no se escribe**.
  Lo rechaza quien escribe, con la columna, la fila y los dos tipos (como un `Vector<n>` de otra
  longitud, v1alpha17 01 §2). Un `Point` en `Geometry<Any>` sí se escribe. Las dimensiones también se
  cumplen: un `Point Z` no es un `Point`.
- **En `Geography`**, la longitud va de −180 a 180 y la latitud de −90 a 90. Fuera de rango no se
  escribe.
- **La validez geométrica no es del tipo** ([`00`](00-scope.md) §3).

## 4. Cómo se guarda, y cómo llega de cada origen

| en | `Geometry<s, crs>` | `Geography<s>` |
|---|---|---|
| **Arrow** (GeoArrow) | `Binary` con la extensión `geoarrow.wkb` y el CRS en sus metadatos (`{"crs": …}`) | ídem, con `"edges": "spherical"` |
| **Parquet** | `BYTE_ARRAY` con el tipo lógico `GEOMETRY(crs)` **y** la clave GeoParquet `geo` del fichero (columna, `encoding: WKB`, tipos de geometría, CRS en PROJJSON y `bbox`) | `GEOGRAPHY(crs, spherical)` **y** la clave `geo` con `edges: spherical` |
| **Iceberg** | `geometry(crs)` en v3. Mientras el formato o la implementación no lo tengan, §4.1 | `geography(crs, spherical)` en v3, o §4.1 |
| **DuckDB** | `GEOMETRY` (el CRS, en el contrato) | `GEOMETRY` (la esfera, en el contrato) |
| **PostGIS** | `geometry(Subtipo, SRID)`; sin restricción, `geometry` es `Geometry<Any, …>` con el SRID de sus valores | `geography(Subtipo, 4326)` |
| **BigQuery** | — (no tiene geometría plana) | `GEOGRAPHY` (siempre `Geography<Any>`) |
| **Snowflake** | `GEOMETRY` (con su SRID) | `GEOGRAPHY` |
| **SQL Server** | `geometry` (el SRID va en cada valor) | `geography` |
| **Oracle** | `SDO_GEOMETRY` con su SRID | `SDO_GEOMETRY` con un SRID geodésico |
| **GeoParquet** (fichero de un origen) | la columna que declara su clave `geo`, con su CRS (sin CRS es `OGC:CRS84`) | ídem con `edges: spherical` |

- **`physicalType` cita el del origen**, tal cual (`geometry(MultiPolygon,25830)`, `GEOGRAPHY`): es lo
  que dice el origen, no lo que decide el documento.
- **El tipo lógico y la clave GeoParquet van los dos**:
  - el tipo lógico da las estadísticas espaciales por grupo de filas y es el estándar de Parquet;
  - la clave `geo` es lo que leen GeoPandas, los lectores anteriores al tipo lógico y GDAL (medido en
    ORE 0066 T5: GeoPandas rechaza un fichero sin ella).
- **El CRS se escribe siempre explícito, en los dos**, también cuando es el de por defecto (medido en
  ORE 0066 T5: un CRS implícito se pierde por el camino).

### 4.1 Mientras el formato de tabla no tiene el tipo

Quien guarda en un formato de tabla que todavía no tiene el tipo (Iceberg v2, o v3 en una
implementación sin `geometry`):
- guarda la columna como **binario**, con los ficheros de datos escritos como dice la fila de Parquet de
  §4;
- **el tipo de la columna sigue siendo el del documento**: el contrato lo conserva (en Iceberg, en las
  propiedades de la tabla), y quien lee la columna la recibe con su tipo;
- cuando el formato traiga el tipo, pasar a él cambia **el esquema de la tabla**, no los bytes del
  valor, que ya son WKB. Cómo se hace ese paso (reescribir solo los metadatos o la tabla) es de la
  implementación, y no cambia lo que lee el consumidor.

## 5. Cómo viaja en texto y cómo se emite

- **En texto** (una fila JSON, un caso de prueba, una muestra): el valor es su **WKB en hexadecimal**,
  en una cadena. Sin pérdida y sin ambigüedad de ejes. **Nunca WKT ni GeoJSON**: el WKT redondea según
  quien lo escribe, y el GeoJSON solo existe en WGS 84.
- **En la emisión GraphQL** (v1alpha5 01): una columna o propiedad geo es el escalar **`GeoJSON`**, con
  el valor como objeto *Geometry* de RFC 7946, **en WGS 84** (reproyectado desde el CRS de la columna).
  Es la única salida en texto legible, y es para servir a una aplicación, no para mover datos: quien
  necesita el valor exacto lo pide en Arrow.

## 6. El ensanche, dónde vale y los errores

| de | a | |
|---|---|---|
| `Geometry<Point>` | `Geometry<MultiPoint>`, `Geometry<GeometryCollection>`, `Geometry<Any>` (mismo CRS) | **ensancha**: todo valor anterior sigue valiendo |
| `Geometry<Any, A>` | `Geometry<Any, B>` | **no ensancha**: cambiar el CRS cambia los valores (es reproyectar) |
| `Geometry<s>` | `Geography<s>` y al revés | **no ensancha**: cambia lo que significa una arista |
| `Geometry<Point>` | `Geometry<Point Z>` y al revés | **no ensancha**: cambia lo que es cada valor |
| cualquiera | `Opaque` | como siempre: retira el gobierno (v1alpha1 02 §3.4) |

**Dónde valen.**
- Como tipo de columna de `Table`, `Dataset` y `View`, y de propiedad de entidad.
- Como campo de un `Struct<…>`.
- Como elemento de un `list<…>`: `list<Geometry<Point>>` son las posiciones de una trayectoria.
- **No como clave** (`primaryKey`, `key`): dos geometrías iguales en el plano pueden tener WKB distinto
  (el orden de los anillos, el punto de inicio). La identidad de un lugar es su identificador.

| | código | |
|---|---|---|
| `Geometry<…>` o `Geography<…>` en un documento de v1alpha31 o antes | `OOS3001` | tipos que no existían |
| un subtipo que no es de §1, una dimensión que no es `Z`, `M` ni `ZM` (o una dimensión en `Any`), un CRS que no es `AUTORIDAD:CÓDIGO`, argumentos vacíos o más de dos, o un CRS en `Geography` | `OOS3008` | un tipo geo mal formado |
| una columna geo en `primaryKey` o en `key` | `OOS3008` | |
| una escritura no canónica (`Geometry<Any, OGC:CRS84>`, `Geometry< Point >`) | — | se acepta y se canoniza; el digest del paquete usa la canónica |
