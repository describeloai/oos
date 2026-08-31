# 90 · Forma canónica y digest

**Estado:** normativo. Parte de OOS v1alpha1.

---

## 1. Por qué existe este documento

Toda garantía del sistema depende de una sola propiedad: **dos paquetes semánticamente
idénticos deben producir bytes idénticos.**

Sin ella no hay digest reproducible, no hay diff semántico, no hay `ore diff --breaking`,
no hay firma verificable y no hay promoción del mismo artefacto entre entornos. Es la
pieza más aburrida de la especificación y la que sostiene todas las demás.

---

## 2. Cadena de transformación

```
autoría (YAML | TypeScript | ore discover)
   │
   ├─ 1. Análisis sintáctico → árbol de documentos
   ├─ 2. Normalización semántica       ← definida en §3
   ├─ 3. Serialización canónica JCS    ← definida en §4
   └─ 4. Digest                        ← definido en §5
```

Los pasos 2 a 4 **DEBEN** ser puros: sin red, sin credenciales, sin reloj, sin
aleatoriedad, sin variables de entorno. Una implementación que introduzca cualquiera de
esas entradas **NO ES CONFORME**.

---

## 3. Normalización semántica

Se aplica **antes** de serializar. Cada regla es normativa.

### N1 · Cualificación de nombres

Toda referencia **DEBE** expandirse a su nombre completamente cualificado.

```yaml
targetEntity: Employee        →  targetEntity: hr.Employee
```

### N2 · Materialización de valores por defecto

Todo valor por defecto definido por el esquema **DEBE** escribirse explícitamente. La
forma canónica no contiene valores implícitos.

```yaml
materialization: {}           →  materialization: { mode: passthrough }
```

### N3 · Ausencia, nunca nulo

Un campo sin valor **DEBE** omitirse. `null` **NO DEBE** aparecer en la forma canónica
salvo cuando `null` sea un valor semánticamente distinto de la ausencia, en cuyo caso el
esquema del campo **DEBE** documentarlo.

### N4 · Conjuntos ordenados, secuencias preservadas

Cada campo de tipo lista **DEBE** declarar en su esquema si es un **conjunto** o una
**secuencia**.

- **Conjunto** — el orden no es semántico. **DEBE** ordenarse ascendentemente por su
  forma canónica serializada. Los duplicados **DEBEN** rechazarse (`OOS2003`).
  Ejemplos: `derivedFrom`, `reserved`, `uniqueKeys`, `dependencies`, `targets`.
- **Secuencia** — el orden es semántico. **DEBE** preservarse.
  Ejemplos: `levels`, `primaryKey`, `via`, `enum`, `strategies`.

> Sin esta distinción, dos autores que escriben las mismas etiquetas en distinto orden
> producen digests distintos, y el diff semántico se llena de ruido.

**Los ejemplos de arriba se corrigieron midiendo, y conviene decir qué eran antes:**
`classification`, `reviewers` y `action` —tres de los cuatro ejemplos de conjunto— **no son
campos de OOS**, y `moved` figuraba como secuencia siendo un conjunto. Uno de esos ejemplos
llegó a la implementación de referencia como una entrada de su lista de conjuntos y estuvo
clasificando un campo inexistente desde v1alpha1.

> **Un ejemplo en prosa acaba en código.** Si es falso, el código hereda la falsedad y nada
> lo comprueba, porque un ejemplo no tiene esquema ni caso.

### N4.1 · La exigencia, y por qué no se cumplía

La primera frase de este apartado es normativa y **no se cumplía en ninguna parte**: ni los
esquemas publicados declaran si una lista es conjunto o secuencia, ni la implementación de
referencia tenía forma de saberlo. Su lista se mantenía a mano, y por eso `G1` se rompió
**cuatro veces**, una por versión, incluida esta:

| Roto en | Campos | Descubierto |
|---|---|---|
| v1alpha2 | `effects`, `endorsements`, `preconditions`, `sources`, `weights` | comparando dos digests |
| v1alpha3 | `targets`, `assertions`, `masks`, `duties`, `named` | comparando dos digests |
| v1alpha3 | las naturalezas de `requiresGovernance` | al añadir el mismo campo un nivel más arriba |
| **v1alpha1** | `derivedFrom`, `reserved`, `uniqueKeys`, `support`, `moved`… | al preguntarse si todo estaba realmente en verde |

Ninguna se descubrió leyendo. Las cuatro, comparando dos digests a mano.

> **Una lista que hay que acordarse de actualizar es una lista de la que nadie se acuerda.**

Una implementación conforme **DEBE** poder demostrar que clasifica todo campo lista de los
esquemas que dice soportar. Cómo lo demuestre es suyo; que un campo sin clasificar sea
indistinguible de uno bien clasificado es lo que hay que hacer imposible — es la misma ley
que `OOS8002`.

**Y la obligación es de cada versión, no solo de esta.** v1alpha2 y v1alpha3 añadieron nueve
campos de tipo lista —`effects`, `endorsements`, `preconditions`, `sources`, `weights`,
`targets`, `assertions`, `masks`, `duties`— y **ninguno declaró su naturaleza**, así que la
implementación de referencia los trataba a todos como secuencias. Reordenar los endosos de
una función o las aserciones de un `Ruleset` producía otro digest: **G1 rota en silencio, por
no aplicar una regla que ya existía.** Se dice aquí porque la regla estaba bien y lo que
falló fue obedecerla.

### N5 · Normalización Unicode

Todo texto **DEBE** normalizarse a **NFC**.

### N6 · Identificadores

Los nombres de entidad, propiedad, paquete y etiqueta **DEBEN** casar con
`^[a-zA-Z][a-zA-Z0-9_]*$` y **DEBEN** compararse de forma sensible a mayúsculas. Los
nombres cualificados usan `.` como separador.

### N7 · Comentarios y formato

Se descartan. No forman parte del significado y **NO DEBEN** afectar al digest.

### N8 · Lo derivado no se serializa

Los campos computados —linaje, clasificación propagada, grafo de consumidores— **NO
DEBEN** aparecer en la forma canónica del **paquete fuente**. Son salida del compilador y
viven en el bundle, no en el repositorio. Ver principio P2.

---

## 4. Serialización canónica

La forma canónica es **JSON**, conforme a
[RFC 8785 · JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785).

Esto fija, sin margen de interpretación:

- Codificación **UTF-8**, sin BOM.
- Sin espacio en blanco insignificante.
- Claves de objeto ordenadas lexicográficamente por sus **unidades de código UTF-16**.
- Números serializados según el algoritmo de ECMAScript `Number::toString`.
- Escapes de cadena mínimos y deterministas.

YAML es una **superficie de autoría**, nunca la forma canónica. Su modelo de datos es
ambiguo —`no` como booleano, resolución de tipos implícita, anclas y alias— y ninguna de
esas ambigüedades **DEBE** sobrevivir a la normalización.

> **Regla operativa:** se autora en YAML, se compara en JSON canónico, se firma sobre
> JSON canónico. Nadie edita JSON canónico a mano.

### 4.1 · Números

Un valor numérico **con parte fraccionaria DEBE representarse como cadena** en la forma
canónica, y por tanto **DEBE escribirse entrecomillado en el origen**. Un decimal sin
comillas es un error de conformidad (`OOS6003`).

```yaml
value: "68400.50"      # correcto
value: 68400.50        # OOS6003
```

```json
{"amount": "1234.50", "currency": "EUR", "precision": 2}
```

Los enteros no están afectados: son exactos y no tienen dígitos que perder.

**La regla es deliberadamente uniforme, y no dice «cuando se pierda precisión».** Una
formulación permisiva —«solo si el valor es inexacto en binario»— sería peor por dos
razones:

1. Obligaría a cada implementación a coincidir *exactamente* en qué decimales pierden
   precisión, que es justo la divergencia que esta sección existe para impedir.
2. Dejaría pasar `68400.50`, cuyo valor **sí** es exacto en binario y cuyo cero final se
   pierde igual — y con él la escala que `Money<EUR, 2>` declara.

El problema de fondo no es el valor, es que **un decimal escrito sin comillas no tiene
forma canónica**: lo que sobreviva depende del parser de quien lo lea. RFC 8785 fija cómo
se serializa el resultado, pero no puede devolver los dígitos que el parseo ya perdió.

El arreglo es una comilla.

---

## 5. Digest

### 5.1 · Digest de documento

```
docDigest = SHA-256( bytes_canónicos_JCS(documento) )
```

### 5.2 · Digest de paquete

El digest del paquete es un hash sobre la lista **ordenada** de sus documentos,
identificados por su **identidad de documento** — el par `kind` + nombre cualificado— y
**nunca por su ruta en el sistema de ficheros**:

```
docId     = kind || ":" || nombre_cualificado        p. ej. "Entity:hr.Employee"
entradas  = [ (docId, docDigest) por cada documento del paquete ]
ordenadas = ordenar entradas por docId, byte a byte
pkgDigest = SHA-256( concatenación de ( docId || 0x00 || docDigest ) )
```

**El nombre del fichero es incidental**, igual que los comentarios y la indentación (§N7).
La identidad de un documento vive **dentro** de él, no en dónde alguien decidió guardarlo:
renombrar `Employee.yaml` a `emp.yaml`, o mover un paquete de la forma plana a
`packages/hr/`, **no cambia el artefacto** y por tanto no debe invalidar su firma ni obligar
a redesplegar.

Esta construcción conserva además la propiedad que motivaba la versión anterior —**al
comparar dos paquetes se sabe exactamente qué documentos cambiaron sin volver a leerlos**—
y la mejora: saberlo por identidad sobrevive a que alguien reorganice las carpetas, y saberlo
por ruta no.

### 5.3 · Un fichero es un **flujo**, no un documento

Se sigue de lo anterior y conviene no dejarlo deducido. En YAML, un fichero es un *stream* y
un *stream* contiene cero o más *documentos*, separados por `---`. La unidad de OOS y la
unidad de YAML son la misma, y OOS no la inventó: la heredó, junto con la convención
`apiVersion`/`kind`/`metadata` de Kubernetes, donde varios documentos por fichero es el
idioma habitual.

Un motor conforme **DEBE** leer **todos** los documentos de un fichero.

No es una comodidad: es lo que hace cierta la frase de arriba. Si el nombre del fichero es
incidental, **partir un fichero en dos o juntar dos en uno no puede cambiar el artefacto** —
y un motor que lee el primero y descarta el resto convierte una decisión de organización en
un cambio de contenido, sin decirlo.

Y no abre ningún riesgo nuevo: el único que tendría juntar documentos —que dos acaben con la
misma identidad— ya lo cierra `OOS2003`, que se aplica al paquete y no al fichero.

> Descartar en silencio no es una tercera opción. Un motor que no quisiera admitir varios
> documentos tendría que **decirlo**; leer uno y callar los demás es pérdida de datos con un
> «ok» encima.

**Una excepción, y es la que confirma la regla:** `ontology.lock` se localiza **por su
nombre**, porque es un artefacto generado y no lleva `kind`. La regla precisa es que la
identidad de un *documento de la ontología* vive dentro de él.

Dos documentos con la misma identidad en un mismo paquete **DEBEN** rechazarse
(`OOS2003`).

### 5.3 · Digest del bundle

```
bundleDigest = SHA-256( pkgDigest || versión_OOS || digest_del_lock )
```

La versión de OOS entra en el digest porque **el mismo fuente compilado bajo una
especificación distinta no es el mismo artefacto**. El lock entra porque las dependencias
resueltas forman parte del significado.

### 5.4 · Representación

Los digests se representan como `sha256:<64 dígitos hexadecimales en minúscula>`,
siguiendo la convención de OCI.

---

## 6. Lo que esto habilita

| Propiedad | Depende de |
|---|---|
| Mismo commit → mismo digest, siempre | pureza (§2) + N1–N8 + JCS |
| Diff semántico sin ruido de formato | N4 + N7 + JCS |
| Promoción del mismo artefacto entre entornos | §5.3 |
| Firma verificable por terceros | §5 + bytes deterministas |
| Invalidación incremental de caché | §5.2 |

---

## 7. Casos de conformidad

Toda regla de este documento **DEBE** tener al menos un caso en
`/conformance/canonical/`. Una regla sin caso de conformidad no es normativa: es una
intención.
