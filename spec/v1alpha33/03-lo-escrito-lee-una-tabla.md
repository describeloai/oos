# 03 · Lo escrito lee una tabla — `derivedFrom` nombra también una `Table`

**Estado:** borrador. Parte de OOS v1alpha33. Amplía
[`v1alpha12/01-dataset`](../v1alpha12/01-dataset.md) §5 y
[`v1alpha19/01-la-coleccion-escrita-deriva`](../v1alpha19/01-la-coleccion-escrita-deriva.md) §5.

---

## 1. El hueco

`derivedFrom` dice lo que el código leyó para escribir un `Dataset` o una `MediaCollection` escritos, y
es **por donde les baja la clasificación** (v1alpha12 §5). Admite una vista, un dataset o una colección,
y nada más: un nombre de otra clase es `OOS2018`.

Pero el código lee también **una `Table`**: una tabla de un origen, en vivo, o la que una foreign
database expone. Un `Transform` ya puede declararla en sus `inputs` (v1alpha25 `01` §6), y lo que
escribe hereda lo que lleva cada columna de la tabla. Lo escrito **desde una sesión**, sin `Transform`,
no tiene dónde decirlo: la implementación lo calla, y lo escrito deja de llevar la etiqueta de la
tabla que leyó.

Lo escrito desde una sesión no es la excepción: es el grueso de lo que se escribe.

## 2. La regla

- **`derivedFrom` de un `Dataset` o de una `MediaCollection` escritos admite una `Table`**, además de
  una vista, un dataset o una colección. Un nombre que no es ninguna de las cuatro sigue siendo
  `OOS2018`; el propio activo, `OOS2019`.
- **Lo que hereda:** cada campo de lo escrito lleva el join de lo que llevan **todas** las columnas de
  la tabla —las `labels` de su `datasource` y las de cada columna—, como con un `Transform` que la
  declara (v1alpha25 `01` §6) y como con una vista o un dataset leídos (v1alpha12 §5): el código no dice
  qué columna salió de cuál.
- **Sin puerta de versión.** Es una obligación de quien escribe y de quien clasifica, para todo
  documento desde v1alpha12 (como v1alpha19 `01` §4 hizo con las colecciones): un árbol que ya
  compilaba sigue compilando, y lo que antes se callaba ahora se puede decir.

## 3. Lo que no es

- **No es `from`.** Un dataset con `from: { table: … }` es una copia mantenida de la tabla; uno con
  `derivedFrom: [la tabla]` es lo que un código escribió después de leerla.
- **No es el linaje por columna.** `derivedFrom` sigue siendo de tabla entera: sobra más de lo que
  falta, que es la dirección segura para una etiqueta.
