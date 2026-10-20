# 01 · Enrich — el transform que enriquece por dónde está

**Estado:** borrador. Parte de OOS v1alpha33. Añade un runtime al `Transform` de
[`v1alpha25/01-transform`](../v1alpha25/01-transform.md), con la misma regla: el código es la fuente,
el documento se deriva leyéndolo y se coteja con él.

---

## 1. Naturaleza

> **Un `Transform` con `runtime: enrich` añade a cada fila de un dataset —el objetivo— lo que dicen
> otras capas según dónde está, sin cambiar cuántas filas tiene. Su código es una declaración: qué
> capas, con qué relación, qué se toma y cómo se reparte.**

Es un transform como cualquier otro (v1alpha25): una salida, un productor, sus entradas y la
etiqueta que baja por él (§7 de v1alpha25). Lo que cambia es el código. No es un programa que se
ejecuta: es una declaración que **la implementación traduce** al motor que calcula. Por eso se puede
comprobar más que en un `.sql` escrito a mano (§4).

**No es un *join*.** Un *join* puede multiplicar filas; un enriquecimiento devuelve **una fila por
cada fila del objetivo** (§3). Lo que no cabe en esa forma (una fila por cada par) es un transform
`sql`.

## 2. El fichero `.enrich.yaml`

El código vive en un fichero `<ruta>.enrich.yaml` del paquete, como un `.sql`. Es una secuencia de
documentos YAML separados por `---`; **cada documento es un transform**. Su `entrypoint` es
`<ruta>.enrich.yaml:<n>`, donde `n` es el número del documento, empezando por 1.

```yaml
# packages/ventas/etl/clientes.enrich.yaml
description: Cada cliente, con su municipio y lo que tiene alrededor.
output: ventas.clientes_enriquecidos
target: { dataset: ventas.clientes, geometry: ubicacion }
layers:
  - dataset: ref.municipios
    relation: within
    take:
      - { as: municipio, column: nombre }
  - dataset: ref.secciones
    relation: intersects
    around: 500
    take:
      - { as: poblacion_500m, column: poblacion, method: extensive }
      - { as: renta_500m, column: renta_media, method: intensive }
  - dataset: ventas.competidores
    relation: intersects
    around: 500
    take:
      - { as: competidores_500m, count: true }
  - dataset: ventas.competidores
    relation: { nearest: 1, maxDistance: 5000 }
    take:
      - { as: competidor_cercano, column: nombre }
      - { as: dist_competidor, distance: true }
```

| clave | | qué |
|---|---|---|
| `output` | obligatoria | lo que escribe: un nombre del árbol |
| `description` | opcional | una línea; pasa a ser la `description` del documento derivado |
| `target.dataset` | obligatoria | el objetivo: lo que se lee para enriquecer |
| `target.geometry` | opcional | su columna geo; si falta, la única que tenga (§4) |
| `layers` | obligatoria, no vacía | las capas, en orden |
| `layers[].dataset` | obligatoria | la capa |
| `layers[].geometry` | opcional | su columna geo, como en `target` |
| `layers[].relation` | obligatoria | `within`, `intersects`, `contains`, o `{ nearest: k, maxDistance: m }` |
| `layers[].around` | opcional | metros: el objetivo pasa a ser el área a esa distancia (no vale con `nearest`) |
| `layers[].take` | obligatoria, no vacía | lo que se toma |
| `take[].as` | obligatoria | el nombre de la columna en la salida |
| `take[].column` · `count: true` · `distance: true` | exactamente una | qué se toma |
| `take[].method` | opcional, sólo con `column` | cómo se reparte (§3); por defecto, `value` |

**La relación** es la que hay entre el objetivo y cada rasgo de la capa:
- `within`: el objetivo está dentro del rasgo;
- `intersects`: se tocan o se solapan;
- `contains`: el objetivo contiene el rasgo;
- `nearest`: los `k` rasgos más cercanos a menos de `maxDistance` metros. Los dos son obligatorios:
  `k` es un entero ≥ 1 y `maxDistance` es > 0.

«A menos de 500 m» se escribe `intersects` con `around: 500`.

El documento **no se deriva** (`OOS2043`) si:
- tiene una clave que no es de aquí o le falta una;
- un valor no tiene su forma;
- dos `take` del fichero tienen el mismo `as`;
- hay `distance` sin `nearest`, o `around` con `nearest`.

## 3. El grano y lo que se toma

**Una fila de salida por cada fila del objetivo, todas.** La salida lleva las columnas del objetivo
tal cual, y una más por cada `take`, en el orden del fichero. Si una fila no coincide con ningún
rasgo de una capa, sus columnas de esa capa van a nulo, salvo `count`, que va a 0.

| `method` | qué da | dónde vale |
|---|---|---|
| `value` | el valor del rasgo. Con varias coincidencias, el del rasgo de **más solape** (área o longitud) y, si empatan, el de menor valor. Con `nearest`, el del más cercano | cualquier columna |
| `sum` · `avg` · `min` · `max` | sobre los rasgos que coinciden, sin ponderar | números |
| `extensive` | Σ valor × área(objetivo ∩ rasgo) / área(rasgo): reparte según la fracción del rasgo que cae dentro, así que conserva los totales | números; una capa poligonal y un objetivo con área |
| `intensive` | Σ valor × área(∩) / Σ área(∩): la media ponderada por el área | lo mismo |
| `majority` | el valor con más área de intersección; si no hay área, el que tiene más rasgos. Si empatan, el menor | cualquier columna |

`count: true` cuenta los rasgos que coinciden. `distance: true` da la distancia en metros al rasgo
más cercano, y sólo vale con `nearest`.

**Un objetivo con área** es uno poligonal o uno con `around`. **Una capa poligonal** es la que tiene
una columna `Geometry<Polygon, …>` o `Geometry<MultiPolygon, …>`.

## 4. Lo que se comprueba sin ejecutar

Sobre cada transform que es el que su código da (v1alpha25 §5.4):

1. **Las entradas**, que son el objetivo y las capas, resuelven igual que las de cualquier transform
   (v1alpha25 §6, `OOS2018`).
2. **Las columnas.** Las que se nombran en `geometry` y `column` están en su dataset, y la de
   `geometry` es geo (`Geometry<…>` o `Geography<…>`). Si no hay `geometry`, el dataset tiene
   **exactamente una** columna geo. Un `as` no puede repetir el nombre de una columna del objetivo.
   Si algo de esto falla, `OOS2054`.
3. **Un solo CRS.** El objetivo y todas sus capas comparten el mismo (una `Geography` cuenta como
   `OGC:CRS84`). Si no, `OOS3009`: hay que reproyectar antes, en una vista.
4. **Metros, sólo en un CRS que mide en metros.** `around`, `maxDistance`, `distance`, `extensive` e
   `intensive` sobre un CRS geográfico dan `OOS3009`. Son geográficos toda `Geography`, `OGC:CRS84`,
   `EPSG:4326`, `EPSG:4258`, `EPSG:4269` y cualquier otro que la implementación sepa geográfico.
5. **El método casa con la columna.** Da `OOS3009`:
   - `sum`, `avg`, `extensive` o `intensive` sobre una columna que no es un número (`Integer`,
     `Float`, `Decimal…`);
   - `extensive` o `intensive` sin una capa poligonal o sin un objetivo con área.

Lo que depende de las columnas de un dataset **sólo se comprueba si se conocen**. La salida de otro
transform que aún no se ha construido no tiene columnas hasta su primer build, y mientras tanto no
hay nada que comprobar.

## 5. El esquema de la salida

Se conoce sin ejecutar: las columnas del objetivo y, por cada `take`:

| se toma | tipo |
|---|---|
| `count: true` | `Integer` |
| `distance: true` | `Float` |
| `extensive`, `intensive`, `avg` | `Float` |
| `value`, `majority`, `min`, `max` | el de la columna de la capa |
| `sum` | el de la columna de la capa si es `Integer`; si no, `Float` |

## 6. El documento derivado

```yaml
# derivado por ore desde etl/clientes.enrich.yaml:1 · se edita el código, no este fichero
apiVersion: oos.dev/v1alpha33
kind: Transform
metadata:
  name: ventas__clientes_enriquecidos
  namespace: ventas
  description: Cada cliente, con su municipio y lo que tiene alrededor.
spec:
  runtime: enrich
  entrypoint: etl/clientes.enrich.yaml:1
  inputs: [ventas.clientes, ref.municipios, ref.secciones, ventas.competidores]
  output: ventas.clientes_enriquecidos
```

`inputs` lleva el objetivo y después las capas, en su orden y sin repetir. Lo demás sigue v1alpha25
§5.3.

## 7. Las reglas

| | código |
|---|---|
| `runtime: enrich` en un documento de v1alpha32 o anterior; un `entrypoint` sin la forma `<ruta>.enrich.yaml:<n>` | `OOS1004` |
| el fichero no está, o no tiene el documento `n` | `OOS2042` |
| el fichero no es YAML, o un documento no tiene la forma de §2 | `OOS2043` |
| el documento no es el que da el código; un documento del fichero que no tiene el suyo | `OOS2013` |
| una entrada que no resuelve | `OOS2018` |
| una columna que no está; una `geometry` que no es geo, o que falta y no es única; un `as` que repite una columna del objetivo | `OOS2054` |
| dos CRS; metros en un CRS geográfico; un método que no casa | `OOS3009` |

## 8. Lo que la gramática no decide

**Cómo se calcula.** El SQL que se genera, el motor, el índice y la estrategia de *join* son de la
implementación. El resultado tiene que ser el de §3.

**El área y la distancia** se miden en el CRS del objetivo, en sus unidades, y §4 obliga a que esas
unidades sean metros.

**Qué versión de cada capa se lee.** La vigente al construir. La procedencia del build la anota.
