# Suite de conformidad

## 1. Naturaleza

> **La suite es la definición operativa de «conforme».**
> El texto normativo **describe**. La suite **decide**.

De ahí la regla de precedencia que ya está en el README raíz: donde `spec/` y la suite
discrepen, **manda la suite** y el defecto está en el texto.

No es un banco de pruebas de ORE. **ORE es un cliente de la suite como cualquier otro**, y
la ejecuta por su CLI pública, sin acceso privilegiado a sus estructuras internas. Es lo
único que impide que la especificación acabe teniendo la forma de su implementación de
referencia.

Sirve a tres destinatarios, y el primero es el que justifica que exista:

| Para quién | Qué le da |
|---|---|
| **Quien escribe una segunda implementación** | saber si lo ha hecho bien. Sin la suite, «conforme» es una opinión |
| **Quien escribe la especificación** | precisión forzada: **una regla ambigua no se puede convertir en un caso** |
| **Quien usa OOS** | la garantía G5 —portabilidad— deja de ser una promesa y pasa a ser comprobable |

---

## 2. Qué puede decidir, y qué no

La suite es **hermética**: ficheros de entrada, ficheros esperados, sin red y sin datos. Eso
determina exactamente su alcance.

| Nivel | ¿Certificable por la suite? |
|---|---|
| **L0 · Validador** | **sí, por completo.** Analizar, normalizar, validar, comprobar el flujo y emitir digest son operaciones puras |
| **L1 · Servidor de contexto** | **parcialmente.** Servir el plano de contexto es determinista dado un bundle, pero exige un proceso vivo |
| **L2 · Ejecutor** · **L3 · Actor** | **no.** Exigen fuentes de datos reales. Ninguna suite de ficheros puede certificarlos |

> **La conformidad solo es decidible en L0** — y L0 es precisamente el nivel que carga las
> garantías **G2** (la gobernanza se demuestra al compilar) y **G4** (verificable sin
> acceso a datos).

No es una limitación incómoda: es la misma propiedad que hace valioso a L0. Lo que se puede
comprobar sin datos es lo que se puede certificar sin confianza.

---

## 3. En una especificación de gobernanza, los casos negativos son el producto

Que un paquete válido se normalice bien importa. Que **`OOS4001` se dispare cuando debe**
importa más: el valor de OOS no está en lo que acepta, sino en **lo que se niega a
compilar**.

Por eso `invalid/` es la parte densa de la suite, y por eso el registro de códigos de
[`99-errors.md`](../spec/v1alpha1/99-errors.md) funciona como su índice: **cada código
publicado exige al menos un caso.**

---

## 4. Las cuatro operaciones

```
conformance/
├── valid/      <caso>/  input/                        → acepta
├── invalid/    <caso>/  input/  + expected-error.json → rechaza con este código
├── diff/       <caso>/  before/ + after/  + expected.diff.json
├── canonical/  <caso>/  a/ + b/           → convergen | NO convergen
│               <caso>/  input/ + expected.absent.json
└── emit/       <caso>/  input/ + expected.*
```

| Directorio | Qué afirma | Entradas |
|---|---|---|
| `valid/` | acepta | 1 |
| `invalid/` | **rechaza con el código exacto** | 1 |
| `diff/` | clasificación por eje: `CONSUMER`, `POLICY`, `INDEX`, `PACKAGE` | **2** |
| `canonical/` | dos entradas **convergen** —o deliberadamente **no** convergen— | **2** |
| `emit/` | ida y vuelta sin pérdida | 1 |

`diff/` es el que certifica `ore diff --breaking`. Sin él, la afirmación de que el carácter
rompedor de un cambio *se computa* en lugar de *afirmarse* no está respaldada por nada.

### 4.1 · Lo que no se puede escribir a mano se afirma como propiedad

`canonical/`, `digest/` y `emit/` tienen un problema que `invalid/` y `diff/` no tienen:
**su resultado esperado no es revisable por un humano.** Nadie audita 400 bytes de JSON
canónico minificado, nadie calcula un SHA-256, y afirmar bytes exactos de ODCS exigiría
dominar ODCS.

Aplicarles la forma «entrada → valor esperado» produciría exactamente lo que §6 prohíbe:
valores fabricados que nadie comprueba. Así que cambian de forma:

| | En lugar de… | Se afirma… |
|---|---|---|
| `canonical/` | *entrada → estos bytes* | **dos entradas convergen** (o no) |
| `digest/` | *entrada → este hash* | **relaciones**: mismo/distinto digest |
| `emit/` | *entrada → este ODCS* | **la ida y vuelta es la identidad** |

Todas son verificables leyendo las entradas y la regla. Ninguna obliga a inventar un valor.

Un `canonical/` **PUEDE** además afirmar ausencia —qué campos no deben aparecer— cuando la
regla trate de lo que se omite.

Y hay una consecuencia útil: **una regla puede ser normativa sin tener código de error.**
La normalización Unicode y la pureza de la compilación no las viola ningún documento; se
verifican como afirmaciones positivas y por eso `OOS6001` y `OOS6002` están retirados como
códigos pero siguen siendo obligatorios.

> La mecánica interna de RFC 8785 —ordenación de claves, serialización numérica— **no se
> reproduce aquí**: es un estándar externo con sus propios vectores de conformidad. Estos
> casos comprueban **nuestra** normalización (N1–N8), no la suya.

---

## 5. Anatomía de un caso

Autocontenido, y **mínimo**: cada caso ejercita **una** regla. Un caso que puede fallar por
tres motivos no sirve para diagnosticar nada.

```
invalid/pii-into-cache-sink/
├── case.yaml         qué regla ejercita, a qué nivel, qué código espera
├── README.md         por qué existe este caso
├── input/            el paquete, tal como lo escribiría un humano
└── expected-error.json
```

```yaml
# case.yaml
rule: spec/v1alpha1/04-flow.md#2      # la regla normativa exacta
level: L0
expects: OOS4002
```

El `case.yaml` es lo que hace **medible la cobertura** (§7). El índice de casos no se
mantiene a mano: **se deriva escaneando el árbol**, porque lo derivable no se declara (P2).

---

## 6. La regla de integridad

El peligro es evidente: si el resultado esperado se genera con nuestro compilador, la suite
deja de comprobar la especificación y pasa a comprobar que el compilador es consistente
consigo mismo.

La regla practicable, que es más honesta que «tecléalo a mano»:

> **El resultado esperado debe ser verificado por un humano contra el texto normativo, y el
> caso debe ser lo bastante pequeño para que esa verificación signifique algo.**

Se puede generar un candidato. **No se puede aceptar sin revisarlo.** Y un caso demasiado
grande para revisarse de un vistazo es un caso mal cortado, no una excusa.

Hay una distinción práctica que conviene tener presente:

| | Naturaleza | De dónde sale su valor |
|---|---|---|
| Códigos de error · forma canónica | **afirmaciones** | verificables a ojo contra la regla |
| Digests | **líneas base** | de que una segunda implementación produzca el mismo |

Nadie calcula un SHA-256 a mano, y no hace falta: su valor no está en haberlo derivado sino
en que dos implementaciones independientes coincidan.

---

## 7. Cobertura

Se deriva mecánicamente y se puede medir:

> **Cada **DEBE** y **NO DEBE** del texto normativo, y cada código de error publicado,
> exige al menos un caso.**
>
> Una regla sin caso de conformidad no es normativa: **es una intención.**

Eso convierte la completitud en un número —*N reglas, M cubiertas*— y no en una opinión
sobre si la suite «parece suficiente».

---

## 8. El ejecutor no es normativo

La suite define **la disposición de directorios y la semántica de los ficheros**. Cada
implementación escribe su propio ejecutor.

Enviar uno como normativo privilegiaría el lenguaje en que esté escrito, que es exactamente
lo contrario de lo que la suite existe para conseguir. Habrá un ejecutor de referencia por
comodidad, marcado como **no normativo**.

Contrato mínimo:

```
Para cada caso en valid/:
    canonicalizar(input) DEBE ser idéntico byte a byte a expected.canonical.json
    digest(input)        DEBE ser idéntico a expected.digest

Para cada caso en invalid/:
    canonicalizar(input) DEBE fallar con expected-error.json.code
    NO DEBE fallar antes con un código distinto

Para cada caso en diff/:
    diff(before, after)  DEBE producir la misma clasificación por eje

Para cada caso en emit/:
    emit(input, formato) DEBE ser equivalente al esperado según las reglas de ese formato
```

El campo `path` de un error esperado es informativo; **el `code` es normativo**. Una
implementación **DEBERÍA** señalar la ubicación correcta, pero solo el código decide la
conformidad.

`emit/` compara **por equivalencia en el formato de destino**, no byte a byte: ODCS y Ossie
son YAML y no tienen forma canónica definida, así que exigir bytes idénticos comprobaría el
serializador y no la emisión.

---

## 9. Precedentes

- **JSON Schema Test Suite** — la estructura caso / entrada / esperado, agnóstica de
  lenguaje, con ejecutores por implementación.
- **CommonMark** — los ejemplos viven **dentro** del documento normativo y la suite se
  extrae de él, de modo que texto y pruebas no pueden divergir. **Objetivo declarado para
  v1beta1.**
- **WebAssembly spec tests** — una implementación de referencia que corre la suite en
  igualdad de condiciones con las demás.
