# 02 · El ancla

**Estado:** normativo. Parte de OOS v1alpha17.

`Anchor` es el tipo de **la parte de un medio** a la que se refiere un resultado: una página, una
región, un intervalo de tiempo, un rango de texto. Es el *selector* de W3C Web Annotation, tipado.
El ítem al que pertenece no va dentro: va en su columna `Media<c>`, al lado
([03](03-la-tabla-anclada.md)).

## 1. Por qué un tipo, y no una convención

Cada herramienta ancla a su manera (ORE 0049, anexo): Docling con `bbox` por página;
Unstructured con un polígono antihorario desde arriba a la izquierda; marker con uno horario;
WhisperX con segundos por palabra; COCO con píxeles absolutos. Sin un tipo, dos tablas que dicen
«página 3, arriba a la izquierda» no se pueden unir. Con él, **se normaliza al escribir** y se
compara al leer.

## 2. La forma

Un `Anchor` es un struct con un discriminante, `kind`, y los campos de su clase; los que no son
de su clase van nulos:

| `kind` | campos | equivale a |
|---|---|---|
| `item` | — | el medio entero |
| `page` | `page` | RFC 8118 `#page=` |
| `region` | `page` (nulo en una imagen), `bbox`, `polygon`, `space` | Media Fragments `#xywh=`, COCO `bbox`, Docling `prov` |
| `interval` | `t_start`, `t_end` | Media Fragments `#t=`, WebVTT, segmentos de Whisper |
| `frame` | `t_start`, `frame` | un fotograma de un vídeo |
| `text` | `char_start`, `char_end`, `text_of` | W3C `TextPositionSelector` |
| `bytes` | `offset`, `length` | RFC 9110 `Range`, Parquet `FILE.offset/size` |

| campo | tipo | regla |
|---|---|---|
| `page` | `Integer` | desde 1, como RFC 8118 |
| `bbox` | `Struct<x: Float, y: Float, w: Float, h: Float>` | esquina superior izquierda, ancho y alto, en `space` |
| `polygon` | `list<Struct<x: Float, y: Float>>` | **horario** desde el vértice superior izquierdo; opcional si basta la caja |
| `space` | `Struct<unit: String, width: Float, height: Float>` | `unit` ∈ `px`, `pt`, `norm`; `width` y `height`, las del lienzo en esa unidad |
| `t_start`, `t_end` | `Float` | segundos desde el inicio, `t_start ≤ t_end` |
| `frame` | `Integer` | índice desde 0 |
| `char_start`, `char_end` | `Integer` | medio abierto `[start, end)` sobre `text_of` |
| `text_of` | `String` | el `anchor_id` del ancla cuyo texto se mide |
| `offset`, `length` | `Integer` | bytes |

## 3. Las normas de escritura

- **El origen es arriba a la izquierda**, `y` crece hacia abajo, y el polígono es horario. Quien
  escribe convierte lo que su herramienta le da; la gramática no admite «como venga».
- **`space` es obligatorio en una `region`**: una caja sin su lienzo no se puede dibujar ni
  comparar. `norm` es `[0, 1]` en los dos ejes; `pt` es la unidad de PDF (1/72 pulgada).
- **Una región de un PDF lleva su `page`**; de una imagen, no.
- **Un `text` apunta a otro ancla** (`text_of`), no a un texto suelto: el texto de un rango es el
  de la fila que lo tiene.

## 4. Lo que un ancla no es

- No es una URL: la forma de URL (`#page=3&xywh=…`, `#t=12.3,14.1`) se **deriva** de ella para
  quien la necesite (un visor, un navegador), y nunca se guarda en su lugar.
- No lleva el ítem: el ítem es la columna `Media<c>` de la fila.
- No lleva confianza ni etiqueta: eso es la carga del resultado, no dónde está.

## 5. Las reglas

| | código | |
|---|---|---|
| `Anchor` en v1alpha16 o antes | `OOS3001` | |
| `Anchor` como campo de un `Struct` | `OOS3007` | un ancla es una columna o un elemento de `list<Anchor>` |

Lo demás —un `kind` desconocido, una `region` sin `space`, `t_start > t_end`— es un **valor**, no
un tipo: lo rechaza quien escribe, con la fila y el motivo, y no la gramática.
