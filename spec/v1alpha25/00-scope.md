# OOS v1alpha25 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-transform`](01-transform.md) | el `kind` `Transform`: el productor de un dataset escrito, **derivado** del código —un `@transform` de Python, una sentencia SQL que escribe o un `@Transform` de Java— y cotejado con él |

Esta versión **añade un `kind`** —`Transform`— y **dos códigos**: `OOS2046` (la salida no es algo
que el código escriba) y `OOS2047` (dos productores para una salida). Amplía `OOS2013`, `OOS2042` y
`OOS2043` a los transforms, y `OOS2018` y `OOS2019` a sus entradas y su grafo. Los demás `kind` no
cambian.

---

## 1. La tesis

| versión | el código es la fuente |
|---|---|
| v1alpha18 | una **función** de Python: su documento se deriva de la firma |
| v1alpha23 | una función de TypeScript, por la misma regla |
| **v1alpha25** | **un transform**: el documento de quien escribe un dataset se deriva de lo que el código declara leer y escribir |

v1alpha12 dejó dicho que un `Dataset` escrito *«no es el trabajo que lo escribió. El código vive en
un commit; el puntero lo nombra»*. El árbol sabía qué datos había y, por `derivedFrom`, qué leyó la
última escritura; no sabía **qué código los produce** hasta que ese código corría. Esta versión le
da documento, y con él se sabe al compilar lo que antes sólo se observaba.

Tres decisiones dan forma a la versión:

- **La identidad es la salida.** Un productor por salida, así que el transform se nombra por lo que
  escribe. No es un activo de catálogo: lo visible es el dataset.
- **El modo no es del transform.** Lo que una salida admite (`append`, `upsert`) lo declara su
  `Dataset`; cada escritura dice el suyo.
- **La salida puede estar por nacer.** Un transform nuevo apunta a un dataset que no existe aún, y
  sus columnas no se saben sin ejecutar: el árbol lo admite, y la primera escritura lo registra.

## 2. Qué entra

- El `kind` `Transform` (`01` §1–§4).
- La derivación desde Python (`@transform`, argumentos literales o constantes del módulo), desde SQL
  (las sentencias que escriben) y desde Java (`@Transform`, literales o constantes `static final` de
  la clase; añadida el 2026-10-08) (`01` §5).
- La resolución: entradas, salida escrita o por nacer, un productor, sin ciclos (`01` §6).
- La etiqueta que baja por el transform antes de ejecutar (`01` §7).

## 3. Qué no entra

- **TypeScript.** Su declaración de hoy es una llamada dentro de código que se ejecuta; entra cuando
  se pueda leer sin ejecutar. Java entró así: su `@Transform` es una anotación (`01` §5.5).
- **Varias salidas.** Un transform, una salida; si llegan, como `outputs`.
- **Cuándo construir** —una programación, un disparador—: es un objeto aparte que nombra transforms.
- **Builds, incremental, expectativas de datos**: son de la implementación o de otra versión (las
  expectativas, de un `Ruleset`, v1alpha3).
