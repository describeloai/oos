# 01 · View — la vista

**Estado:** borrador. Parte de OOS v1alpha7.
**Anfitrión:** ninguno. Es gramática propia, como `Entity`: la vista es la forma en que
Foundry, Cognite, Snowflake y dbt dicen la misma cosa, y esa forma no es de ninguno de ellos.

---

## 1. Naturaleza

Una `View` dice **qué existe físicamente y cómo se llama**: de dónde sale —una fuente
declarada, u **otra vista**—, qué campos expone, qué filas son suyas, qué sabe hacer el origen
y, si se copia, dónde.

Absorbe al `Binding` entero. Todo lo que el binding decía lo dice la vista, y dice dos cosas
más que el binding no podía: **de qué otra vista sale**, y **quién responde de ella**.

De las cinco caras que el sector le cuelga a la palabra *vista* —referencia, proyección,
semántica, frescura, seguridad— **la vista se queda cuatro**. La quinta se queda donde estaba.

---

## 2. Qué **no** es

- **No lleva significado.** No admite `labels`, ni `is`, ni conceptos. Eso está en la entidad.
  Si la vista supiera qué significa una columna habría dos sitios diciéndolo, y el día que
  discrepen ninguno diría cuál manda. Su incumplimiento es `OOS1005`: el campo no existe.
- **No decide quién ve qué.** El `ConduitPolicy` y las políticas Cedar siguen decidiendo. Es lo
  que deja que una vista gobernada sea entrada de otra.
- **No es un motor.** Declara la transformación; la ejecuta quien tenga el cómputo, empujada al
  origen o delegada.

---

## 3. Forma

```yaml
apiVersion: oos.dev/v1alpha7
kind: View
metadata:
  name: empleados
  namespace: hr
spec:
  owner: team:rrhh

  # De dónde. Una fuente declarada y un objeto suyo, u OTRA VISTA.
  from:
    datasource: hr_workday
    object: "Worker"

  # El testigo. Obligatorio; `none` es legal y tiene precio.
  version:
    witness: none

  # Cuánto retraso se tolera respecto al origen.
  freshness: 15m

  # Qué sale y cómo se llama. La clave es el nombre EN ESTA VISTA.
  fields:
    employeeId: "Worker_Reference.ID"
    nationalId:
      column: "Personal_Data.National_ID"
      physicalType: "varchar(16)"
    pais: "Location.Country"

  # Qué filas son suyas. Gramática cerrada: igualdad, pertenencia, ausencia.
  where:
    "Worker_Status": Active

  # Qué sabe hacer el origen. Sin cambios respecto al binding.
  capabilities:
    predicatePushdown: [eq, in]
    fullScan: forbidden
    requiredFilters: [employeeId]
```

Una vista **sobre otra**:

```yaml
kind: View
metadata: { name: iberia, namespace: hr }
spec:
  owner: team:rrhh
  from: { view: empleados }     # forma corta: mismo espacio de nombres
  version: { witness: none }
  fields:
    id: employeeId              # renombra un campo de `empleados`
    dni: nationalId
  where:
    pais: [ES, PT]              # `pais` es un campo de `empleados`
  materialized:
    datasource: lago
    table: "cache.hr_iberia"
```

Y la entidad, que **nombra a su vista**:

```yaml
kind: Entity
metadata: { name: Employee, namespace: hr }
spec:
  nature: entity
  primaryKey: [id]
  backedBy: iberia
  properties:
    id:  { type: String }
    dni: { type: String, labels: { gdpr.sensitivity: high } }
```

### 3.1 · Lo que muda del binding, campo a campo

| `Binding` | `View` | Qué cambia |
|---|---|---|
| `datasourceRef` + `source` | `from.datasource` + `from.object` | nada; o `from.view` |
| `properties` | `fields` | el sujeto: la clave es el nombre **en la vista** |
| `selector` | `where` | nada; las claves pueden ser campos de la vista de abajo |
| `capabilities` | `capabilities` | nada |
| `materialization.payload` | `materialized` + `freshness` | partido en dónde y cuánto; **un** conducto |
| `materialization.topology` | — | se deriva: el índice es una vista de aristas, y no se declara (P2) |
| `targetEntity` | `Entity.backedBy` | **la flecha al revés** |
| — | `owner` | la vista tiene dueño |
| — | `version.witness` | el testigo, explícito |

---

## 4. Restricciones

- `from` es **exactamente una** de dos formas. Una fuente y no una lista: el vocabulario no
  tiene junta, y una vista con dos fuentes no tendría forma de decir cómo se combinan.
- `from.datasource` y `materialized.datasource` **DEBEN** estar declarados en el manifiesto
  raíz — `OOS2004`, el mismo que `datasourceRef`, porque es el mismo defecto.
- `from.view` y `backedBy` **DEBEN** resolver a una vista del paquete o de una dependencia —
  `OOS2018`. Admiten la forma corta en el mismo espacio de nombres (N1) y se normalizan al
  nombre cualificado.
- En una vista sobre otra, **cada valor de `fields` y cada clave de `where` DEBE ser un campo
  que la de abajo expone** — `OOS2018`. Lo que la de abajo no expone no existe para la de
  arriba.
- La cadena **NO DEBE** volver sobre sí misma — `OOS2019`. Una vista se define por lo que tiene
  debajo; una que se tiene a sí misma debajo no se define, y ninguna de la cadena tiene raíz.
- Con `version.witness: field`, `version.field` **DEBE** estar en `fields` — `OOS2018`.
- La vista que respalda una entidad **DEBE** exponer su `primaryKey` y los `via` de sus
  relaciones — `OOS2011`, lo que necesita columna, dicho de la vista.
- La vista **NO** admite `labels`. Estructural: `OOS1005`.

---

## 5. La cadena

Una vista sobre otra **compone**: sus campos renombran campos de la de abajo, y sus filtros
recortan sobre las filas que la de abajo ya recortó. Seguir `from.view` hasta que deje de
haberlo da **la raíz** de la cadena: a qué fuente y objeto se llega, con qué columna física se
pide cada campo de arriba, y con qué filtros, ya en columnas físicas.

Esa operación es **una** y la usan tres cosas: el enlazado para comprobar que resuelve, el
flujo para heredar la ubicación, y el ejecutor para leer. Si fueran tres copias, divergirían
en el eslabón que ninguna prueba ejerce.

### 5.1 · La herencia atraviesa la cadena

Una entidad respaldada por una vista hereda las etiquetas **del datasource raíz**, no de la
vista —que no tiene— ni del primer eslabón. De ahí es de donde salen los bytes, y la ubicación
física es un hecho del mundo que se computa (P2). Con tres eslabones y una fuente `eu_only`, la
entidad es `eu_only` sin que nadie lo escriba en ninguno de los cuatro documentos.

### 5.2 · La copia lleva lo que llevan sus campos

Una vista con `materialized` **copia datos**, y una copia instancia un conducto:
`materialization.payload`, el del eje `payload` del binding. Lo que fluye es **cada campo**, y
lo que lleva puesto cada campo se sabe por dos vías:

- el datasource raíz, que etiqueta todo lo que sale de él;
- **cada entidad cuya cadena pasa por esta vista**: la entidad etiqueta sus propiedades, las
  propiedades se llaman como los campos de *su* vista, y los renombres de la cadena bajan esos
  nombres hasta la vista que se copia.

La segunda vía es la que vale dinero. Una entidad puede declarar `dni: high` sobre una vista
de tres eslabones, y **la de abajo, que es la que se materializa, no lo sabe** — no puede
saberlo, porque no lleva significado. Sin esta regla se copiaría en claro un dato que la
entidad clasificó, y compilaría. Con ella, `OOS4002` en la vista de abajo, señalando el campo
y de dónde le viene la etiqueta.

Es el *label seal* del motor de vistas visto desde la especificación: **la clasificación de
una materialización se hereda, no se recalcula** sobre la tabla copiada.

---

## 6. El testigo

`version.witness` dice **qué prueba qué versión de los datos se leyó**:

| | Qué es | Ejemplos |
|---|---|---|
| `none` | nada. Legal, y tiene precio: sin testigo no hay marca, y sin marca lo materializado no puede decir hasta cuándo era cierto | un CSV, una API sin versión |
| `snapshot` | la versión nativa de un formato de tabla | `snapshot-id` de Iceberg, la versión de Delta |
| `log` | una posición en un flujo de cambios | LSN, SCN, offset |
| `field` | un campo de la propia vista que ordena el avance | `updatedAt` |

Todos son **ordinales**. El motor los compara; no los interpreta ni los convierte. Quien
adapte un almacén mapea su testigo a un ordinal, y esa conversión es suya.

---

## 7. `where`: la gramática cerrada, y por qué sigue cerrada

Igualdad, pertenencia y ausencia. Ni rango, ni negación, ni expresión. Es la del `selector`
del binding y por la misma razón: **un predicado no filtra, lee.** Qué filas aparecen es
observable, así que un `WHERE salario > 100000` no emite el salario y lo revela. Igualdad y
pertenencia expresan una **partición**: cada fila cae en una clase, y lo único que revelan es
pertenencia — justo lo que la vista ya afirma en voz alta.

Una vista sobre otra hereda las filas que la de abajo ya recortó. La conjunción es implícita.

---

## 8. El vocabulario, y lo que **no** está en él

Esta versión sabe **seleccionar, renombrar y recortar por partición**. Es exactamente lo que
el binding sabía, mudado a un documento que puede salir de otro.

No sabe unir, agregar, deduplicar ni limitar. No es que falten: es que cada una tiene un
precio en la regla de flujo —una junta trae dos raíces, un agregado puede desclasificar, un
límite impide empujar predicados— y **el precio se decide antes de admitir la operación**, no
después. El IR del motor de vistas ya las tiene con sus reglas; cuándo entran en la gramática
de OOS es una decisión de una versión posterior, y se tomará con casos.

Lo que no quepa en el vocabulario **no entra como expresión libre**. Entra, cuando entre, como
opaca declarada: dice qué lee, qué tipo produce y si es determinista, y cuesta la garantía de
análisis. Es la misma figura que `effects:` en una función.

---

## 9. Listo · tres peldaños

Esta versión está lista para v1 cuando:

1. **la cadena compila y se niega** — una vista sobre vistas resuelve, un ciclo falla, y una
   etiqueta puesta en una entidad **impide materializar** la vista de abajo que la copiaría
   fuera de su conducto. Es lo que certifica [`conformance/v1alpha7/`](../../conformance/v1alpha7/README.md);
2. **el descubrimiento propone vistas** — `discover` emite vistas y entidades con `backedBy`,
   y ningún binding;
3. **el binding se retira** — `kind: Binding` sale del vocabulario, `03-binding` pasa a
   histórico y sus casos se traducen.

El primero está hecho. Los otros dos son la migración de [`00-scope`](00-scope.md) §5, y
mientras no lleguen esta versión es un borrador **con dos formas de decir dónde está el dato**,
que es la situación que existe para terminar.
