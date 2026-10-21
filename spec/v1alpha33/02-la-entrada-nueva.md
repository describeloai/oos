# 02 · La entrada nueva — construido con una versión vieja de lo que lee

**Estado:** borrador. Parte de OOS v1alpha33. Añade un motivo al vocabulario cerrado de
[`v1alpha30/01-la-salud`](../v1alpha30/01-la-salud.md) §6.

---

## 1. El hueco

v1alpha30 §2.2 hace que lo derivado sea honesto sobre **de cuándo** son sus datos: lo escrito por un
transform tiene como `dataAsOf` el más viejo de lo que leyó, **tal como lo leyó**. Lo que no dice es que
una entrada **ya tiene algo más nuevo**. Un dataset enriquecido con los municipios de enero sigue
`healthy` cuando llegan los de marzo, aunque reconstruirlo daría otra cosa.

Es lo que distingue un enriquecimiento gobernado ([`01-enrich`](01-enrich.md)) de una tabla escrita una
vez: el resultado sabe que su capa ha cambiado.

## 2. El motivo

| `code` | Estado | Cuándo |
|---|---|---|
| `input-refreshed` | `warning` | Una entrada tiene hoy un `dataAsOf` posterior al que tenía cuando se construyó lo que se sirve; lleva `asset` |

- **`since`** es el `dataAsOf` de la entrada hoy: desde entonces hay algo más nuevo.
- **`asset`** es la entrada, por su nombre cualificado, como en `upstream-degraded`.
- Se juzga **sólo con las dos horas conocidas**: la de la entrada al construir (lo que quien escribe
  guarda con la escritura, v1alpha30 §2.2) y la de hoy. Si falta alguna, no se dice nada.
- Vale para **todo transform**, no sólo para `runtime: enrich`, y para todo árbol: es una obligación de
  quien sirve, sin puerta de versión (v1alpha30 §8).
- **No baja por el linaje.** Quien lee de algo en `warning` no lo hereda (v1alpha30 §2.2: sólo baja
  `degraded`). Lo que lea de ello y se construya después tendrá su propio `input-refreshed` si le toca.

## 3. Lo que no es

- **No es `behind-source`.** Aquel compara una copia con su origen fuera del lago; este compara un
  activo escrito con una entrada que el propio catálogo ya tiene más nueva.
- **No es reconstruir.** Decir que hay algo más nuevo no lo construye: cuándo se construye sigue siendo de
  la programación, no del documento (v1alpha25 §2).
