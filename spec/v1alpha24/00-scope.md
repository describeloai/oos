# OOS v1alpha24 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-leer-el-origen`](01-leer-el-origen.md) | **leer un origen sin copiarlo**: el conducto `federation.read`, lo que se empuja (lo que la tabla admite y lo que el conector sabe), y lo que la tabla declara de su coste aplicado al leer |

Esta versión **no añade claves**: `reads` ya dice desde v1alpha8 qué operadores admite el origen
(`predicatePushdown`), si se puede recorrer entero (`fullScan`), qué filtros exige
(`requiredFilters`), cuántas filas da por petición (`maxRowsPerRequest`) y si junta
(`joinPushdown`). Hasta hoy eso se **declaraba**; desde esta versión **se aplica** cuando alguien
lee la tabla donde está. Añade **una clase de conducto** —`federation`— y **dos códigos**: `OOS2044` y `OOS2045`.

---

## 1. La tesis

Una `Table` es un puntero a un objeto de un origen, y una vista sobre ella es la vista de una base
*foreign* que **se lee donde está** ([`v1alpha14/01` §3](../v1alpha14/01-la-vista-es-sql.md)). La
gramática lo admitía; lo que faltaba es decir **con qué permiso** y **con qué cuidado**:

| | hasta v1alpha23 | desde v1alpha24 |
|---|---|---|
| quién autoriza leer el origen sin copiarlo | nadie lo decía | el conducto `federation.read` |
| `fullScan`, `requiredFilters` | declarados | **aplicados al leer** |
| qué viaja al origen | lo que cada implementación quisiera | lo que admiten **la tabla y el conector**, los dos |

Leer el origen en vivo es lo que hace un *foreign catalog*: Lakehouse Federation, Athena Federated
Query, Trino. Lo pidió la plataforma que implementa OOS (ORE 0053, «ORE Federation Engine»,
2026-10-04), con una cifra que lo decide: una tabla que se declara `fullScan: expensive`, de dos
millones de filas, se leyó entera tres veces seguidas y **nada lo impidió**.

## 2. Qué entra

- **El conducto `federation.read`** (`01` §2): lo que sale de un origen leído en vivo. Sin
  autorización es `⊥` y la lectura no se hace (`OOS4011`); lo que lleva una etiqueta por encima de
  lo autorizado, tampoco (`OOS4002`, `OOS4001`).
- **Lo que se empuja es una intersección** (`01` §3): lo que la tabla admite (`reads`, la política
  de quien la declara) y lo que el conector sabe expresar. Lo demás lo hace el motor sobre lo que
  llega.
- **El coste declarado se aplica** (`01` §4): `fullScan: forbidden` no se recorre (`OOS2044`); un
  filtro de `requiredFilters` que no llega al origen no se lee (`OOS2045`); una tabla `expensive`
  se lee **con un presupuesto** de lectura que la corta si lo supera. `maxRowsPerRequest` parte la
  lectura.
- **Una vista sobre una `Table` de esta versión** compila sólo con `federation.read` autorizado
  (`01` §5).

## 3. Qué no entra

- **Escribir en el origen.** Leer en vivo es leer: lo que se escribe va a una copia, como siempre.
- **Cambiar lo que ya compila.** Una vista de v1alpha24 o anterior sobre una `Table` sigue
  compilando; leerla en vivo pide el conducto igual, al leer (`01` §5).
- **Cómo se ejecuta.** Dónde corre el conector, cómo se cachea, qué tope de filas pone una
  plataforma o cuántas lecturas a la vez admite un origen son de quien implementa; aquí se dice qué
  significa leer el origen y cuándo **NO DEBE** hacerse.
- **Juntar dos orígenes en el origen.** `joinPushdown` sigue siendo una declaración; qué junta se
  empuja y a cuál de los dos es una decisión de un motor.
