# 02 · View — la vista, adelgazada

**Estado:** borrador. Parte de OOS v1alpha8.
**Sustituye a** [`v1alpha7/01-view`](../v1alpha7/01-view.md), que sigue describiendo los
documentos v1alpha7 y sigue siendo válido para ellos.

---

## 1. Qué cambia, y qué no

Lo que [`v1alpha7/01-view`](../v1alpha7/01-view.md) dice de la **naturaleza** de una vista sigue
valiendo entero: no lleva significado, no decide quién ve, no es un motor, compone, y su copia
lleva lo que llevan sus campos. Nada de eso se repite aquí.

Lo que cambia es **dónde vive lo físico**:

| | v1alpha7 | v1alpha8 |
|---|---|---|
| `from` | `{datasource, object}` o `{view}` | **`{table}`** o `{view}` |
| `capabilities` | en la vista | **fuera**: es `reads` de la tabla |
| `version` | en la vista | **fuera**: es `changes.witness` de la tabla |
| `fields` | forma breve o `{column, physicalType}` | **solo la breve**: `physicalType` era lo único que la expandida añadía, y ahora lo dice la columna de la tabla |
| `owner`, `where`, `materialized`, `freshness` | en la vista | igual |

La vista queda con **lo que es suyo**: quién responde, qué sale y cómo se llama, qué filas son
suyas, si se copia y dónde, y cuánto retraso se tolera. Todo lo demás era del objeto.

---

## 2. Forma

```yaml
apiVersion: oos.dev/v1alpha8
kind: View
metadata:
  name: empleados
  namespace: hr
spec:
  owner: team:rrhh
  from: { table: erp.employees }     # o { view: … }
  freshness: 15m
  fields:
    employeeId: employee_id          # cada valor DEBE ser una columna de la tabla
    nationalId: national_id
    pais: country
  where:
    deleted: "false"                 # cada clave DEBE ser una columna de la tabla
```

Una vista **sobre otra**, igual que antes:

```yaml
kind: View
metadata: { name: iberia, namespace: hr }
spec:
  owner: team:rrhh
  from: { view: empleados }
  fields:
    id: employeeId
    dni: nationalId
  where:
    pais: [ES, PT]
  materialized:
    datasource: lago
    table: "cache.hr_iberia"
```

Una vista **sobre un stream** — una tabla con `reads: none`. Sin `materialized` no compila:

```yaml
kind: View
metadata: { name: pedidos, namespace: ventas }
spec:
  owner: team:ventas
  from: { table: bus.orders }
  fields: { id: order_id, cliente: customer_id, total: total }
  materialized: { datasource: lago, table: "cache.pedidos" }
  freshness: 1m
```

---

## 3. La raíz, y la raíz de lectura

Son dos, y la diferencia es el asunto de `OOS2020`.

**La raíz** de una vista es a dónde se llega bajando por `from` hasta que deja de haber `view`:
siempre una **tabla**. De ella salen el `datasource` —para heredar etiquetas, `v1alpha7/01-view`
§5.1—, el objeto, y ahora también las **columnas reales** contra las que se comprueba `fields`.

**La raíz de lectura** es la vista `materialized` más cercana bajando por la cadena, o la tabla
si no hay ninguna. Es de donde salen de verdad las filas cuando alguien consulta.

Una vista virtual sobre una vista materializada sobre un stream **sí** compila: su raíz es una
tabla que no se deja leer, pero su **raíz de lectura** es la copia, y la copia se lee.

Esa operación —bajar la cadena— es **una**, y la usan el enlazado para comprobar que resuelve,
el flujo para heredar la ubicación, y el ejecutor para leer. Si fueran tres copias, divergirían
en el eslabón que ninguna prueba ejerce.

---

## 4. Restricciones

Las de [`v1alpha7/01-view` §4](../v1alpha7/01-view.md#4-restricciones) siguen, con `from.table`
donde decía `from.datasource`:

- `from` es **exactamente una** de dos formas: `{table}` o `{view}`. Una sola fuente, porque el
  vocabulario no tiene junta.
- `from.table` **DEBE** resolver a una tabla del paquete o de una dependencia — `OOS2018`.
- `from.view` y `backedBy` **DEBEN** resolver a una vista — `OOS2018`. Los dos admiten la forma
  corta en el mismo espacio de nombres y se normalizan al nombre cualificado.
- Con `from: {table}`, **cada valor de `fields` y cada clave de `where` DEBE ser una columna de
  `columns` de esa tabla** — `OOS2018`. Es lo que v1alpha7 no podía comprobar.
- Con `from: {view}`, cada valor de `fields` y cada clave de `where` **DEBE** ser un campo que la
  de abajo expone — `OOS2018`, sin cambios.
- `materialized.datasource` **DEBE** estar declarado en el manifiesto raíz — `OOS2004`.
- La cadena **NO DEBE** volver sobre sí misma — `OOS2019`.
- La vista que respalda una entidad **DEBE** exponer su `primaryKey` y los `via` de sus
  relaciones — `OOS2011`.
- Y **DEBE** exponer un campo por cada propiedad de esa entidad que no declare `derivedFrom` —
  `OOS2022`, §5.3.
- La vista **NO** admite `labels`. Estructural: `OOS1005`.

Y cambian dos:

- desaparece la de `version.witness: field`, que ahora es de la tabla;
- `fields` pierde la forma expandida. Cada valor es **una cadena**: el nombre en la fuente. La
  expandida existía para llevar `physicalType`, y el tipo físico es del objeto — lo dice
  `columns`. Un documento v1alpha7 con la forma expandida migra tirando el tipo a la tabla, que
  es donde ya debía estar.

---

## 5. Las reglas nuevas

Tres. Las dos primeras eran, hasta aquí, prosa en la documentación de quien las sufrió; la
tercera no existía porque hasta aquí no hacía falta. Las tres son compilación.

### 5.1 · `OOS2020` — lo que no se puede leer se debe materializar

> Una vista cuya **raíz de lectura** es una tabla con `reads: none` **DEBE** llevar
> `materialized`.

Una tabla con `reads: none` no responde consultas: solo emite cambios. Una vista virtual sobre
ella promete algo que nadie puede servir — y lo promete **en tiempo de compilación**, para
fallar en tiempo de consulta.

Databricks lo descubre cuando `readStream` no existe sobre una *foreign table*. Aquí no compila.

La regla mira la **raíz de lectura**, no la raíz: si un eslabón intermedio ya materializó, hay
de dónde leer, y la vista de arriba puede ser virtual sin mentir.

### 5.2 · `OOS2021` — sin retractación no se mantiene lo mutable

> Una vista `materialized` cuya raíz tiene `changes.mode: append` **NO PUEDE** respaldar una
> entidad con `nature: entity`.

Una entidad es una cosa que **cambia y sigue siendo la misma**: se corrige, se actualiza, se da
de baja. Mantener su estado presente exige poder **quitar** lo que dejó de ser cierto, y un
flujo que solo sabe anexar no puede. Lo que se obtiene copiando un `append` no es el estado
presente: es el histórico de lo que llegó, con las filas viejas dentro.

Un `nature: event` **sí** se respalda de un `append`, y es su forma natural: un hecho ocurrido
no se retira, y por eso solo hace falta anexar.

Foundry documenta esta misma limitación —el soporte incremental está limitado a cambios de solo
anexado— como una nota en su documentación. **Es el peor modo de fallo de todo el motor**: no
produce ningún síntoma. La vista se materializa, la consulta responde, los números salen, y son
los de antes. Convertirlo en un código es la diferencia entre un compilador y un manual.

### 5.3 · `OOS2022` — una propiedad sin campo no tiene de dónde salir

> Cada propiedad de una entidad **DEBE** ser un campo de la vista que la respalda, salvo que
> declare `derivedFrom`.

Esta regla es **la otra cara de una exclusión**, y solo se entiende junto a ella.

`03-binding` §2.1 admitía que *«una entidad PUEDE tener varios bindings; cada uno cubre un
subconjunto de sus propiedades»*. Con eso, una cobertura parcial no solo era legal: era **el
mecanismo**. Preguntar *«¿de dónde sale esta propiedad?»* no tenía respuesta local, porque la
respuesta podía estar en otro documento.

[`00-scope` §6](00-scope.md#6-lo-que-no-entra) retira esa posibilidad: una entidad sale de **una**
vista. Y en cuanto no hay otro documento donde mirar, la pregunta vuelve a tener respuesta local
— y una propiedad sin campo pasa de *«la cubre otro»* a *«no la cubre nadie»*.

Sin esta regla, la migración que esta versión pide produciría exactamente el fallo que este
proyecto persigue: se escribe una vista con la mitad de los campos, la entidad sigue declarando
el doble, **compila en verde**, y las propiedades huérfanas responden vacío para siempre.

**`derivedFrom` es la excepción, y es la única.** Una propiedad derivada declara de qué otras
propiedades sale, y eso *es* su origen: pedirle además una columna sería exigirle que esté
calculada en la fuente. Es justo lo que la migración de `Binding.properties.<x>.expression` deja
de poder hacer ([`00-scope` §5.3](00-scope.md#53)), así que negarle el hueco sería cerrar la
única salida que le queda.

### 5.4 · Lo que las tres tienen en común

Las dos primeras son la regla de la versión leída al revés:

> `Table = I(changes)` — sin `I` no hay lectura, y sin `-1` no hay `I` de una cosa que cambia.

Y las dos son comprobables **solo** desde que la tabla declara sus dos caras. Ese es el precio
que paga esta versión, y lo que compra.

La tercera no sale del álgebra: sale de haber **quitado** algo. Las reglas que aparecen al retirar
una pieza son las que más fácil se olvidan, porque no las pide nadie — las pide la ausencia.

---

## 6. La copia, sin cambios

`materialized` instancia el conducto `materialization.payload`, y lleva lo que llevan sus campos:
lo que el datasource raíz etiqueta, y lo que **cualquier entidad cuya cadena pase por esta
vista** declaró sobre ellos. Es
[`v1alpha7/01-view` §5.2](../v1alpha7/01-view.md#52--la-copia-lleva-lo-que-llevan-sus-campos)
entero, y sigue siendo `OOS4001`, `OOS4002` y `OOS4011`.

Que no cambie es la afirmación: la tabla movió el puntero de sitio, no la regla de flujo.
