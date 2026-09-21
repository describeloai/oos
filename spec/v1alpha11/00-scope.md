# OOS v1alpha11 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué un modelo entrenado es un documento distinto del modelo servido |
| [`01-trained-model`](01-trained-model.md) | el modelo entrenado: naturaleza, la forma, las reglas, y lo que la gramática no decide |

Esta versión **añade un `kind`** —`TrainedModel`— y nada más. No añade códigos de error: lo
que rechaza lo rechaza con los de siempre —`OOS1004` la forma, `OOS1005` una clave que no es
de aquí, `OOS2005` una referencia que no resuelve, `OOS2009` un dueño que no lo es—.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| versión | verbo | la regla |
|---|---|---|
| v1alpha7 | **preguntar** | la vista es la pregunta y compone |
| v1alpha8 | **apuntar** | lo físico se registra una vez, con dos caras |
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| v1alpha10 | **actuar** | lo que una función toca se lee en su documento, en los dos sentidos |
| **v1alpha11** | **publicar** | **lo que el código produce y no es una tabla entra en el árbol como un documento que nombra sus bytes por digest y de qué salió** |

Lo que esta versión afirma: el trabajo de una sesión de código tiene **dos salidas con
nombre**, y las dos son assets del mismo registro. Una es un dataset —una tabla con historia,
y para ésa el árbol ya tiene documento: la `Table` de v1alpha8 y el puntero que la nombra—.
La otra es **un modelo entrenado**: unos ficheros en el bucket que un framework carga, con una
versión, y que salieron de unas vistas. Para ésa no había documento, y sin documento no hay
asset: no se lista, no se gobierna, no tiene dueño ni linaje.

## 2. Por qué otro `kind`, y no el `Model` de v1alpha9

Porque son **dos cosas distintas que se usan de dos maneras distintas**, y un documento que
sirviera para las dos tendría dos formas bajo un nombre:

| | `Model` (v1alpha9) | `TrainedModel` (v1alpha11) |
|---|---|---|
| qué es | un **perfil certificado** que alguien sirve: máquina × modelo, con números medidos | unos **pesos** que alguien entrenó: ficheros en el bucket, con digest |
| dónde vive | en `modelos/`, en la raíz; **sin namespace**: vocabulario del árbol | en un **paquete** (`packages/<ns>/models/`); con namespace: es del dominio que lo entrenó |
| quién lo escribe | quien certifica el perfil (`POST /modelos` contra la lista) | la sesión que lo entrenó, al publicarlo |
| de qué sale | de nadie: es un servicio | de **vistas del árbol** (`trainedFrom`): tiene linaje |
| cómo se usa | una `Function` con `runtime: model` lo nombra como `modelo/<n>` | lo carga el código de un transform, o una `Function` que lo sirva (fuera de esta versión) |

Lo que el `Model` de v1alpha9 dice de sí —*«no lleva runtime, ni recursos, ni pesos: todo
eso es del perfil»*— es exactamente lo que un modelo entrenado **sí** lleva. Estirar un
documento hasta que diga lo contrario de lo que dice es el defecto que esta gramática existe
para no cometer (**P7**).

## 3. Por qué un documento y no un puntero

El dataset de un `write()` tiene documento (`Table`) y puntero (el estado vigente); un modelo
entrenado necesita las dos cosas también, pero la primera no existía. El puntero —qué versión
está publicada, dónde están sus bytes— es del que registra, no de la gramática; lo que la
gramática fija es **lo que un modelo entrenado tiene que decir de sí para ser un asset**: quién
responde por él, con qué se carga, qué versión es, dónde están sus bytes y cuál es su digest,
y de qué vistas salió. Con eso el catálogo lo lista, la gobernanza baja por `trainedFrom` como
baja por `from` en una vista, y un cambio de versión es un commit con quién.

## 4. Qué entra

- `kind: TrainedModel` — [`01-trained-model`](01-trained-model.md).

## 5. Qué no entra, y por qué

- **Cómo se sirve.** Una `Function` que cargue un `TrainedModel` y conteste por fila es la
  pieza de baja latencia, y se decide cuando se mida. Hasta entonces, lo que lo usa es código.
- **El formato de los artefactos.** `artifacts` es un prefijo del lago y `digest` el de su
  manifiesto; qué ficheros hay debajo lo sabe el framework, no la gramática.
- **Métricas.** Un modelo entrenado tiene números (una pérdida, un MAE); no van aquí porque no
  hay vocabulario que los haga comparables entre frameworks, y un campo libre acaba adquiriendo
  un significado que nadie escribió. `metadata.description` es texto, y para eso está.
- **El código que lo entrenó como documento.** Un transform es código más lo que produce; el
  código vive en el repositorio, en un commit, y el puntero del asset lo nombra. No es un kind.

## 6. Compatibilidad

Ningún documento de v1alpha1 a v1alpha10 cambia de resultado. `kind: TrainedModel` en una
versión anterior es `OOS1003`.
