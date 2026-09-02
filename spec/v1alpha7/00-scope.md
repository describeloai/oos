# OOS v1alpha7 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué la vista absorbe al binding |
| [`01-view`](01-view.md) | la vista: naturaleza, forma, la cadena, y **qué significa que esto esté listo** (§9) |

Esta versión **añade un `kind`** —`View`—, un campo a otro —`Entity.backedBy`—, dos esquemas y
dos códigos de error. Es la primera desde v1alpha4 que añade gramática, y lo que añade no es
una pieza más al lado de las que había: **sustituye a una**. El `Binding` sigue existiendo
mientras dure la migración, y este alcance dice cómo termina.

---

## 1. La tesis

Cada versión gobierna un verbo, y aporta **una** regla:

| | Gobierna | Regla |
|---|---|---|
| **v1alpha1** | lo que se puede **saber** | `L ⊑ C` |
| **v1alpha2** | lo que se puede **causar** | `I(f) ⊒ I(destino)` |
| **v1alpha3** | qué debe **sostenerse** | `L(x) ⊒ n ⟹ ∃r` |
| **v1alpha4** | **qué es la misma cosa** | `E implements I ⟹ ∀c ∈ I . ∃p ∈ E . is(p) = c` |
| **v1alpha5** | lo que se puede **pedir** | `S = { p : L(p) ⊑ C(contextSurface) }` |
| **v1alpha6** | **de quién es lo que usas** | `usar(P) ⟹ digest(P) ∈ lock` |
| **v1alpha7** | **de dónde sale lo que sabes** | `L(E.p) ⊒ L(raíz(V, p))` |

La regla se lee: **la clasificación de una propiedad es al menos la del origen físico en el
que termina la cadena de vistas que la trae.** Y con ella, su consecuencia sobre la copia:
`materialized(V) ⟹ ∀f ∈ V . L(f) ⊑ C(materialization.payload)`.

Ninguna de las dos es nueva. v1alpha1 ya decía que una propiedad enlazada hereda las
etiquetas de su datasource, y que una copia instancia un conducto. Lo que cambia es **a través
de qué**: antes de un binding, que era un salto; ahora de una cadena, que puede tener los
eslabones que haga falta. La regla tiene que atravesarla entera o no vale.

---

## 2. Por qué el binding no bastaba

El `Binding` decía dónde vive una entidad. Decía **una** cosa a la vez, y por eso tenía cuatro
límites que no eran defectos de escritura sino de forma:

| Con binding | Por qué duele |
|---|---|
| lo físico **nombra** a lo semántico (`targetEntity`) | una fuente no se puede exponer hasta que alguien haya modelado una entidad sobre ella. El flujo real es el inverso: *descubrir, elegir qué exponer y con qué frescura, modelar después* |
| un binding sale de **una tabla** | un pipeline —limpiar, recortar, renombrar, copiar— no cabe: cada paso necesitaría un binding, y ningún binding puede salir de otro |
| **dos entidades sobre la misma tabla** son dos bindings | que repiten el mapeo, y el día que la tabla cambie, uno se actualiza y otro no |
| la copia (`materialization`) cuelga de la entidad | una caché es una decisión de **enrutamiento**, y estaba en un documento de **modelado** |

Los cuatro tienen la misma raíz: el binding **es un salto**, y lo que hace falta es **una
cadena**. Es lo que el sector llama *view* —Foundry, Cognite Data Fusion, Snowflake, dbt, todos
con la misma forma: una tabla virtual con nombre, definida sobre otras, materializable—, y no
tiene sentido inventar un nombre para lo que todo el mundo llama igual.

---

## 3. Lo que hay que añadir, y lo que se retira

| | |
|---|---|
| **se crea** | `kind: View` · `Entity.backedBy` · `schemas/v1alpha7/` · `OOS2018` y `OOS2019` · `conformance/v1alpha7/` |
| **se reutiliza** | `OOS2004` para `from.datasource` · `OOS2011` para la clave que la vista no expone · `OOS4001`, `OOS4002` y `OOS4011` para la vista materializada, por `materialization.payload` |
| **no se toca** | el retículo, el conducto, el concepto, `is`, la interfaz, la forma canónica, el digest, la firma, el log, `ore diff` |
| **se retira, al final** | `kind: Binding` — §5 |

Que los códigos de flujo se **reutilicen** en vez de duplicarse no es economía: es la prueba
de que la vista no cambia la regla, cambia el camino. Un `OOS4002` sobre una vista
materializada significa exactamente lo que significaba sobre un binding con `payload`.

---

## 4. La decisión de forma que decide todo lo demás

> **La entidad nombra a la vista. No al revés.**

Con la flecha de v1alpha1 lo físico tenía que conocer lo semántico. Invertida:

- una vista **existe antes** de que nadie modele nada;
- **varias entidades** se respaldan de la misma vista sin duplicarla;
- lo físico **no sabe de significado**, que es §2 de `01-view` hecho estructura.

Es la dirección de Cognite —un container no sabe de vistas, una vista no sabe de data
models— y la de cualquier almacén: una tabla no sabe qué modelo la lee.

Y arrastra una segunda decisión, más pequeña y más discutible: **las propiedades de la entidad
se llaman como los campos de su vista**. No hay un mapeo propiedad→campo en `backedBy`. Podría
haberlo, y sería el `properties` del binding otra vez. Se decide que **el renombre es de la
vista** —para eso existe `fields`— y que la entidad, que es semántica, no mapea nada físico.
Si una entidad quiere otro nombre, pone una vista encima; cuesta un documento y deja el
renombre donde se puede leer.

---

## 5. Cómo termina: la migración

`Binding` y `View` conviven, y es **el único momento del proyecto en que dos documentos dicen
lo mismo**. Está acotado y tiene fin:

1. **Coexistencia.** Una entidad puede tener bindings, `backedBy`, o los dos. Los chequeos de
   flujo, gobierno y enlazado ven las dos vías y las tratan igual — `datasources_de` en la
   implementación de referencia es una función y no dos.
2. **El descubrimiento propone vistas.** `discover` deja de emitir bindings: emite vistas
   primero —qué expones, de dónde, con qué testigo y con qué frescura— y entidades con
   `backedBy` después. Es el flujo de quien vende esto.
3. **El binding se retira.** Con nada que lo emita y todo lo que hacía absorbido, `kind:
   Binding` sale del vocabulario. `03-binding` pasa a histórico, sus casos de conformidad se
   traducen a vistas, y `OOS2014` —dos bindings del mismo objeto— pasa a decir *dos vistas*.

Esta versión cierra el peldaño 1 y deja escrito el 2 y el 3. **Si la coexistencia se queda,
hemos fallado**: sería tener dos formas de decir dónde está el dato, y el día que discrepen
ninguna dirá cuál manda.

---

## 6. Lo que **no** entra

**Quién ve qué.** Las *restricted views* de Foundry fusionan proyección y seguridad en un
objeto, y el precio está documentado: una vista restringida no puede ser entrada de un
transform — gobernar corta la cadena. Aquí la seguridad sigue siendo el `ConduitPolicy` y las
políticas Cedar. Una vista dice qué existe; el conducto dice quién puede. Por eso una vista
gobernada sigue siendo componible.

**Significado.** `is`, los conceptos, los retículos y las interfaces no se mueven. La vista es
física, y no admite `labels`.

**Un motor de cómputo.** La transformación se declara y la ejecuta quien tenga el cómputo. El
vocabulario de esta versión es **seleccionar, renombrar y recortar por partición** — lo que el
binding ya sabía hacer, mudado. Unir, agregar y deduplicar son del IR del motor de vistas y
llegarán cuando se decida su precio; una vista no puede hoy tener dos fuentes porque no tendría
forma de decir cómo se combinan.

**Formato de tabla o de fichero.** Iceberg y Parquet ya existen.
