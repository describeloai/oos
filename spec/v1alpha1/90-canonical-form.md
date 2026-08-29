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
  Ejemplos: `classification`, `reviewers`, `action`, `capabilities.datasources`.
- **Secuencia** — el orden es semántico. **DEBE** preservarse.
  Ejemplos: `enum`, `moved`, obligaciones encadenadas.

> Sin esta distinción, dos autores que escriben las mismas etiquetas en distinto orden
> producen digests distintos, y el diff semántico se llena de ruido.

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

Un valor numérico con precisión decimal significativa —importes monetarios, umbrales—
**DEBE** representarse como **cadena** en la forma canónica, no como número JSON, para
evitar la pérdida de precisión del punto flotante binario.

```json
{"amount": "1234.50", "currency": "EUR", "precision": 2}
```

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
