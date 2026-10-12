# v1alpha29 · Las familias de medios

**Normativo.** Amplía [`v1alpha16/01-object-table`](../v1alpha16/01-object-table.md) §4 y
[`v1alpha16/02-media-collection`](../v1alpha16/02-media-collection.md) §4 y §7 para los documentos
con `apiVersion: oos.dev/v1alpha29`.

## 1. El vocabulario

`media` sigue siendo **cerrado**, por lo mismo que en v1alpha16: lo que se puede hacer con un objeto
depende de qué es, y quien lo lea tiene que poder razonar sobre ello. Son quince palabras:

| `media` | qué es | extensiones que lo proponen | lo que lo confirma en los bytes |
|---|---|---|---|
| `document` | texto paginado | pdf, doc, docx, ppt, pptx, odt, odp, rtf, txt, md, html, htm, epub, xps, pages, key | `%PDF`; los de Office y ODF son zips: decide la extensión |
| `image` | una imagen | png, jpg, jpeg, gif, tif, tiff, webp, bmp, heic, heif, avif, svg, ico, jp2, dng, cr2, nef, arw | PNG, JPEG, GIF, RIFF/WEBP, `ftyp` avif/heic, `<svg` |
| `audio` | sonido | wav, mp3, flac, ogg, oga, opus, m4a, aac, aiff, aif, wma, sph | ID3, `fLaC`, `OggS`, RIFF/WAVE, FORM/AIFF |
| `video` | vídeo | mp4, m4v, mov, avi, mkv, webm, mpg, mpeg, ts, m2ts, wmv, flv, 3gp | `ftyp`, RIFF/AVI, EBML, MPEG-TS |
| `spreadsheet` | una hoja con celdas, no filas declaradas | xlsx, xlsm, xlsb, xls, ods, numbers | OOXML/ODF por la extensión; OLE2 |
| `email` | un mensaje con adjuntos | eml, msg, mbox | `From `, `Received:`; OLE2 |
| `structured` | datos con forma: un documento por fichero | json, xml, yaml, yml, toml | `<?xml`; un `{` o `[` que analiza |
| `text` | texto que no se pagina | log, sha256, sha1, md5, ini, conf, cfg, y código: py, js, ts, java, scala, kt, rs, go, c, h, cpp, cs, rb, php, sh, ps1, sql, r, ipynb | UTF-8 sin bytes de control en la muestra |
| `geospatial` | geometría y mapas | geojson, kml, kmz, gpx, gml, gpkg, shp, shx, dbf, prj, cpg, las, laz | `<kml`, `<gpx`, SQLite (gpkg), shp `0000270A`, `LASF` |
| `model3d` | piezas y escenas 3D, CAD | stl, obj, ply, glb, gltf, fbx, 3ds, dwg, dxf, step, stp, iges, igs, usdz | `glTF`, `solid`, `ply`, `AC10` (dwg), `ISO-10303-21` |
| `medical` | imagen y señal clínica | dcm, dicom, nii, hl7, edf | `DICM` en el byte 128, `n+1` en el 344 (NIfTI), `MSH|` (HL7) |
| `scientific` | arrays y cubos de datos | h5, hdf5, he5, nc, nc4, netcdf, npy, npz, fits, fit, mat | `\x89HDF`, `CDF\x01`/`\x02`, `\x93NUMPY`, `SIMPLE  =` |
| `design` | ficheros fuente de diseño | psd, ai, eps, indd, sketch, fig, xd | `8BPS`, `%!PS-Adobe` |
| `archive` | un contenedor de otros ficheros | zip, tar, gz, tgz, bz2, xz, zst, 7z, rar | PK, gzip, `7z`, `Rar!`, `ustar` en el 257 |
| `binary` | todavía no se sabe | lo que nada de lo anterior reconoce | — |

Y una más que sólo existe en una colección: **`multimodal`** (§3).

**Normativo.**

- **El tipo es el de los bytes** (v1alpha16 `01` §4.1): la extensión propone y los bytes deciden.
  La tabla es la de la extensión; una implementación **DEBERÍA** confirmar con la firma.
- **Una extensión es de una sola familia.** Las fronteras:
  - `dcm` es `medical`, no `image`: un DICOM lleva paciente, estudio y serie, no sólo píxeles.
  - `txt` y `md` son `document`; `text` es lo que no se pagina —registros, código, sumas de control—.
  - `json` es `structured`: un documento por fichero. `jsonl`, `csv` y `parquet` son **filas**: una
    `Table` con `format` (v1alpha16 `03`), no un medio.
  - Un GeoTIFF es `image`: distinguirlo exige leer las etiquetas TIFF, y una imagen lo es.
  - `obj` y `stl` son `model3d`; las nubes de puntos LiDAR (`las`, `laz`), `geospatial`.
- Un `ObjectTable` es de **una** familia, o `binary`. `multimodal` en un `ObjectTable` es
  `OOS1004`: un objeto es de una cosa; un conjunto puede mezclarlas.

## 2. Un `archive` es una colección

Una colección de `archive` **guarda los contenedores tal cual**: los `.zip` de una entrega, los
`.gz` de un conjunto público, una copia de seguridad. Sus ítems son los ficheros comprimidos, con
su huella y su historia, como cualquier otro.

**Normativo.** `media: archive` en una `MediaCollection` de v1alpha29 es legal. Lo que v1alpha16
`01` §4.3 dice sigue en pie: **abrirlo no es catalogarlo**. Lo que hay dentro de un contenedor es
otro conjunto de objetos, y llega por una transformación que lo escribe.

## 3. La colección `multimodal`

La colección de lo que no es de una sola familia: una carpeta de entregas con PDF, fotos y hojas;
un manifiesto y sus sumas de control; lo que el catálogo no reconoce (`binary`) y alguien quiere
guardar.

```yaml
apiVersion: oos.dev/v1alpha29
kind: MediaCollection
metadata: { name: manifiestos, namespace: lago, schema: archivo }
spec:
  owner: team:data
  media: multimodal               # cualquier familia; `formats`, opcional
  from: { objectTable: mnist.processedmanifest.processedmanifest }
```

**Normativo.**

- `media: multimodal` sólo en una `MediaCollection` de v1alpha29.
- **`formats` es opcional** en ella. Sin `formats` entra cualquier fichero; con `formats`, sólo
  esos, sin repetidos, y **no hay primario**.
- **Sale de un `ObjectTable` de cualquier `media`**, `binary` incluido: `OOS2040` no se aplica a una
  `multimodal`.
- **Lo que se hace con un ítem depende de la familia del ítem**, no de la colección: su preview, lo
  que el código puede abrir. Un ítem de `multimodal` sin familia reconocida se cuenta, se versiona,
  se gobierna y se baja.

## 4. `binary` sigue sin ser colección

Lo que no se sabe qué es no se guarda en una colección **de su tipo**, porque no tiene tipo:
`media: binary` en una colección sigue siendo `OOS1004`. Guardarlo es posible, y se dice:
`multimodal`.

## 5. Las reglas

| | código | antes (v1alpha16) | v1alpha29 |
|---|---|---|---|
| `media` de un `ObjectTable` fuera del vocabulario | `OOS1004` | 8 palabras | las 15 de §1 |
| `media: multimodal` en un `ObjectTable` | `OOS1004` | — | sí |
| `media: archive` en una colección | `OOS1004` | sí | **no**: es legal (§2) |
| `media: binary` en una colección | `OOS1004` | sí | sí (§4) |
| una colección `multimodal` sin `formats` | `OOS1004` | — | **no**: es legal (§3) |
| una colección de otro `media` que su `ObjectTable` | `OOS2040` | sí | sí, salvo `multimodal` |
| una familia nueva en un documento anterior a v1alpha29 | `OOS1004` | — | sí: la puerta es del documento |

## 6. Conformidad

| caso | espera | |
|---|---|---|
| `valid/an-archive-collection` | acepta | una colección mantenida de `.gz`, de un `ObjectTable` de `archive` |
| `valid/a-multimodal-collection-from-binary` | acepta | una `multimodal` sin `formats`, de un `ObjectTable` `binary` |
| `valid/a-geospatial-collection` | acepta | un `ObjectTable` y una colección `geospatial` |
| `invalid/an-object-table-cannot-be-multimodal` | `OOS1004` | `multimodal` es de un conjunto, no de un objeto |
| `invalid/binary-is-still-not-a-collection` | `OOS1004` | §4 |
| `invalid/a-new-family-before-v1alpha29` | `OOS1004` | `geospatial` en un `ObjectTable` de v1alpha16 |
| `invalid/a-family-collection-from-another-family` | `OOS2040` | una colección `image` de un `ObjectTable` `geospatial` |
