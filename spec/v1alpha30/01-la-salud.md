# OOS v1alpha30 · 01 — La salud de un activo

**De cuándo es lo que se sirve, si es lo que dice ser, y qué se le dice a quien lee.**

Estado: borrador, alpha. Obligaciones de **ejecución**: las cumple quien sirve los datos, no el
compilador. Las palabras **DEBE**, **NO DEBE**, **DEBERÍA** y **PUEDE** tienen el sentido de RFC
2119.

---

## 1. De cuándo es lo que se sirve

Un activo **materializado** es una copia que se refresca: un `Dataset` mantenido (v1alpha12) o una
`MediaCollection` mantenida (v1alpha16). Su frescura se mide con **tres horas y una posición**, y
todo número de frescura dice de cuál sale:

| | Qué es | |
|---|---|---|
| **`dataAsOf`** | **Los datos**: el instante en que se leyó el origen para la versión que se sirve. Se toma **antes** de leer, y es la cota más fiel de hasta cuándo es cierta la copia | **DEBE** guardarse con cada versión publicada |
| **`checkedAt`** | **La comprobación**: la última vez que se vio, con una medida, que el origen no había cambiado desde `dataAsOf` | Si hay con qué medirlo |
| **`sourceChangedAt`** | **El cambio del origen**: cuándo se supo que el origen cambió después de `dataAsOf` | Si hay con qué medirlo |
| **la posición** | Hasta dónde llega la copia en el orden del origen: el testigo de v1alpha8, o la marca de agua de v1alpha1 [`05`](../v1alpha1/05-ejecutor.md) §7 | Es un orden, **no** una hora. Sirve para retomar una lectura. **No** dice por sí sola si el activo cambió (v1alpha30 [`00`](00-scope.md) §1) |

**La hora de publicar no es una de ellas.** Cuándo se escribió la copia, o cuándo se hizo commit
de su puntero, no dice de cuándo son los datos.

De esas horas salen dos magnitudes distintas:

- **El retraso** es `ahora − dataAsOf`. Se puede calcular siempre.
- **La edad** es `ahora −` el primer cambio del origen que la copia no tiene. Vale **0 si el origen
  no cambió**. Se conoce sólo con una comprobación, y no pasa del retraso: un activo leído hace seis
  horas, cuyo origen no ha cambiado desde entonces, tiene edad 0.

**La promesa de frescura** es `freshness` (v1alpha12 [`01-dataset`](../v1alpha12/01-dataset.md)):
la edad que se tolera. Se cumple si **la edad conocida** es como mucho `freshness`, o, a falta de
comprobación, si lo es **el retraso**, porque la edad nunca lo supera.

Un activo que se lee **en vivo** (una `Table` de una base foránea, v1alpha27) se lee del origen
al consultar. Su `dataAsOf` es el momento de la lectura, y su retraso, 0.

## 2. Los cuatro estados

Todo activo que se sirve tiene **un estado**:

| Estado | Significa | Cuándo, como mínimo |
|---|---|---|
| **`healthy`** | Lo que se sirve está dentro de lo que se espera, **y hay una medida que lo respalda** | Con promesa: se cumple (§1). Sin promesa: el último refresco se publicó y el origen no ha cambiado desde `dataAsOf`, comprobado |
| **`warning`** | Se sirve, pero algo no está como se espera, **sin romper una promesa** | El origen cambió después de `dataAsOf` y no hay promesa que lo cubra. Una guarda o una promesa de severidad aviso no se cumplen |
| **`degraded`** | Se sirve algo que **no es lo que se promete**, o no puede seguir a su origen | Se pasó de `freshness`. El último refresco **falló** o **se retuvo**, y se sirve lo último bueno (§4). El esquema del origen ya no es el declarado. Una entrada de la que depende está `degraded` (§2.2) |
| **`unknown`** | **No se sabe.** No hay medida que respalde ninguno de los otros tres | Sin promesa y sin comprobación: copiado, pero sin saber si el origen ha cambiado después. Nunca refrescado. Un activo cuyo estado no se pudo calcular |

### 2.1 · El peor gana

El estado de un activo es **el peor de sus motivos**, en este orden: `degraded`, `warning`,
`unknown`, `healthy`. Un activo `healthy` no tiene motivos; cualquier otro estado tiene **al menos
uno** (§6).

`unknown` **está por encima** de `healthy`. Lo que no se sabe no es sano.

### 2.2 · Baja por el linaje

La frescura de lo derivado es la de su camino más viejo. Si un activo lee de otro, `dataAsOf` de lo
derivado **no puede ser posterior** al `dataAsOf` más antiguo de lo que leyó, aunque lo derivado se
calculara después. Y si una entrada está `degraded`, lo derivado **DEBE** estar al menos en
`warning`, con el motivo `upstream-degraded` y el nombre de esa entrada. Está `degraded` si su propia
promesa ya no se cumple.

### 2.3 · Relación con lo anterior

- El **estado degradado** de v1alpha1 [`03-binding`](../v1alpha1/03-binding.md) §3.2 y la condición
  de consulta del mismo nombre de [`05-ejecutor`](../v1alpha1/05-ejecutor.md) §9 son
  **`degraded`**.
- `freshnessSLA` (v1alpha1) y `freshness` (v1alpha12) son **la promesa de frescura** de §1.

## 3. Lo que se le debe a quien lee

Quien sirve un activo materializado o en vivo:

1. **DEBE** dar el estado y el bloque de salud (§6) **con cada lectura**, por el mismo canal que
   el dato: la respuesta de una consulta, el resultado de una función, la vista previa, lo que
   recibe un agente. Un estado que sólo se ve en otra pantalla no llega a quien lo necesita.
2. **NO DEBE** dar como `healthy` una frescura que **ninguna medida respalda**. Sin promesa y sin
   comprobación, el estado es `unknown`. **NO DEBE** decir «al día» de un activo por el mero hecho
   de no haberlo refrescado.
3. **NO DEBE** contar `unknown` como `healthy`, tampoco al sumar: el estado de un schema, de una base
   o de un catálogo cuenta lo desconocido aparte.
4. **DEBE** enseñar como hora de un activo su **`dataAsOf`**. **NO DEBE** presentar la hora de
   publicar como la de los datos.
5. **NO DEBE** dejar de servir la versión vigente porque un refresco **falló** o **se retuvo**
   (§4). **DEBE** servirla con su estado, `degraded`, y el motivo.
6. **PUEDE** fallar en lugar de servir si quien lee lo pide: un modo estricto, o una frescura
   máxima propia de esa lectura. Si quien lee no lo pide, se sirve con aviso.
7. **DEBE** decir **por qué** falla una lectura en vivo, distinguiendo al menos:
   - el objeto no existe en el origen;
   - el objeto existe pero **su esquema no es el declarado** (`source-schema-changed`, con las
     columnas);
   - el origen no contesta;
   - la credencial no vale.

   Un esquema que cambió **NO DEBE** comunicarse como un objeto que no existe.

## 4. La versión vigente y la última buena

Un refresco **escribe**, **se comprueba** y, sólo entonces, **se publica**: la versión vigente pasa a
ser la nueva. Si falla al escribir, o lo que escribió no pasa una guarda o una promesa que retiene,
**no se publica**. Entonces:

- **la versión vigente sigue siendo la última buena**, con su `dataAsOf` de entonces;
- el intento queda registrado, con su hora, su resultado (`failed` o `held`) y su motivo;
- el activo está `degraded` mientras dure (§2), y se sirve (§3.5).

Una implementación **PUEDE** ofrecer publicar lo retenido por decisión expresa de quien responde del
activo (v1alpha21: su `owner`). Esa decisión queda registrada.

**Guardas de base.** Sin que nadie las prometa, una implementación **DEBERÍA** retener un refresco que:

- deja **sin filas** un activo que las tenía;
- pierde una **columna declarada**.

Y **DEBERÍA** avisar (`warning`), sin retener, de una caída brusca de filas o de una subida brusca
de nulos.

## 5. Las tres capas

Lo que una implementación sabe de un activo se ordena por **lo que cuesta saberlo**:

| Capa | Qué | Cuesta | |
|---|---|---|---|
| **0 · la verdad** | Lo que se sabe **al refrescar**: `dataAsOf`, la versión vigente y la última buena, el resultado de cada intento, el esquema del origen comparado con el declarado, las filas y los nulos de lo escrito, las guardas, y la promesa de frescura juzgada con el reloj | Nada que no cueste ya el refresco | **Obligatoria. NO DEBE poder apagarse** |
| **1 · vigilancia** | Lo que se sabe **entre refrescos**: si el origen cambió (`checkedAt`, `sourceChangedAt`), si contesta, si la credencial vale, y el esquema de lo que se lee en vivo, antes de que nadie lo lea | Toca el origen de quien lo posee | **Opcional**. Se enciende por ámbito: una base o un schema |
| **2 · perfilado** | Métricas por columna con su historia, y comprobaciones que son consultas | Lee los datos | **Opcional**. Se enciende por activo |

Las capas 1 y 2 **vienen apagadas**. Una implementación que las ofrezca **DEBE** decir, en el
bloque de salud, cuáles están encendidas para ese activo (§6, `layers`). Que algo no se vigile es
un dato, no un silencio.

**Sin la capa 1, los cuatro estados siguen valiendo.** Lo que cambia es cuánto se sabe:

- una copia sin promesa ni comprobación es `unknown`, con su `dataAsOf`;
- con la capa 1, puede ser `healthy`, porque se comprobó que el origen no cambió, o `warning`,
  porque se sabe que cambió.

## 6. El bloque de salud

Es lo que acompaña a cada lectura (§3.1) y lo que da quien pregunta por un activo. Su forma
normativa es [`health.schema.json`](../../schemas/v1alpha30/health.schema.json):

```json
{
  "state": "degraded",
  "dataAsOf": "2026-10-13T13:37:02Z",
  "checkedAt": null,
  "sourceChangedAt": null,
  "freshness": { "promise": "PT1H", "lagSeconds": 7260, "ageSeconds": null },
  "servingLastGood": true,
  "lastRefresh": { "at": "2026-10-13T13:44:51Z", "outcome": "failed" },
  "reasons": [
    { "code": "refresh-failed", "since": "2026-10-13T13:44:51Z",
      "message": "the source has no column `cliente`" },
    { "code": "source-schema-changed", "since": "2026-10-13T13:44:51Z",
      "columns": { "removed": ["cliente"], "added": ["cliente_x"] } }
  ],
  "layers": { "monitoring": false, "profiling": false }
}
```

Los **motivos** forman un vocabulario cerrado. Cada uno empuja el estado, como mínimo, a:

| `code` | Estado | Cuándo |
|---|---|---|
| `freshness-exceeded` | `degraded` | La edad conocida, o el retraso, pasa de la promesa |
| `refresh-failed` | `degraded` | El último intento falló y se sirve lo último bueno |
| `refresh-held` | `degraded` | El último intento se retuvo (§4) y se sirve lo último bueno |
| `source-schema-changed` | `degraded` | El esquema del origen ya no es el declarado; lleva `columns` |
| `source-unreachable` | `degraded` | El origen no contesta, o su credencial no vale |
| `upstream-degraded` | `warning` | Una entrada está `degraded` (§2.2); lleva `asset` |
| `behind-source` | `warning` | El origen cambió después de `dataAsOf`, sin promesa que lo cubra |
| `guard-warning` | `warning` | Una guarda de aviso (§4); lleva `guard` |
| `unverified` | `unknown` | No hay medida que respalde la frescura |
| `never-refreshed` | `unknown` | No hay versión vigente |

Una implementación **PUEDE** añadir motivos propios con el prefijo `x-`, y **NO DEBE** usarlos para
algo que uno de estos ya nombra. Un motivo propio no puede dejar `healthy` un activo que tiene un
motivo de los de arriba.

## 7. Conformidad

Ninguna regla de esta versión cambia lo que compila: no hay casos nuevos en la suite de documentos.
Las obligaciones de §3 a §5 se comprueban **ejecutando**: escenarios que cambian el origen entre
refrescos y miran lo que se sirve. La plataforma que implementa OOS mantiene esos escenarios (ORE
0063, la vara), y son el borrador de una suite de ejecución.

## 8. Sin puerta de versión

Estas obligaciones son de quien sirve, y valen **para todo árbol**, declare la `apiVersion` que
declare. Un documento de v1alpha12 con `freshness` se juzga como dice §1.
