# OOS v1alpha6 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué la distribución es lo último |
| [`01-distribucion`](01-distribucion.md) | el formato `.oob`, el protocolo de obtención y **qué significa que esto esté listo** (§6) |

Esta versión **no añade ningún `kind`**, ningún esquema y ningún código de error — como
v1alpha5, y por el mismo motivo: lo que añade no es gramática. Añade **un artefacto** y **un
contrato con un programa ajeno**.

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

La regla se lee: **nada entra en una compilación sin que su digest esté escrito en el lock.**
Y de ahí sale la frase que decide el diseño entero:

> **El registro no es de confianza.**

No hace falta que lo sea. Un paquete se identifica por **lo que contiene**, no por de dónde
vino, así que un registro que sirviera otra cosa produciría un digest distinto y la
compilación se pararía. Lo que un registro puede hacer es **no servirte**; lo que no puede
hacer es servirte algo distinto sin que se note.

Es `G4` mirado desde el otro lado. Donde v1alpha1 dice *«un auditor valida tu gobernanza sin
acceso a un solo dato»*, esta versión dice **lo mismo sobre tus dependencias**: un auditor
comprueba de qué te acogiste leyendo un fichero de tu repositorio, sin preguntarle a nadie.

---

## 2. El hueco, que lleva nombrado desde v1alpha2

[`v1alpha2/00-scope`](../v1alpha2/00-scope.md) §4 lo dejó escrito y sin cerrar:

> *«Hoy `ontology.lock` existe, `dependencies` existe, `OOS2013` comprueba que estén
> sincronizados, y **nada puede traer un paquete**. […] Alcance mínimo: un protocolo de
> registro, el formato del paquete publicable (`.oob`), y el resolutor.»*

De los tres, **el resolutor ya no falta entero**: resolver contra un paquete que está en el
árbol no necesita ni registro ni formato, y es el caso que se usa hoy —un vocabulario se
consume vendorizándolo—. Lo que queda son los otros dos, y son los que convierten *«GDPR como
dependencia»* de una figura en algo literal.

### 2.1 · Por qué importa más que un gestor de paquetes

Un gestor de paquetes reparte código. Aquí lo que se reparte es **autoridad**: `01-package`
§3.1 lo dice —*«declarar `gdpr@^2.1` es afirmar que la definición de qué es un dato personal
no es tuya»*—. Eso cambia qué hay que garantizar:

| Un gestor de paquetes normal | Aquí |
|---|---|
| que el código sea el que pediste | que **la clasificación** sea la que pediste |
| un fallo es un build roto | un fallo es **un dato sensible sin gobernar**, en verde |

Y hay una consecuencia que no tiene un gestor normal: `requiresGovernance` viaja con el
concepto (`02-property` §3.3), así que **importar puede hacer que tu paquete deje de
compilar** — y eso es lo correcto. Un paquete regulatorio que no pudiera romperte el build no
estaría gobernando nada.

---

## 3. Anfitrión u objetivo: aquí no aplica, y conviene decirlo

Las versiones anteriores decidían si un formato ajeno era **anfitrión** —se perfila— u
**objetivo de emisión** —se emite—. `.oob` no es ninguna de las dos cosas: no hay un formato
ajeno del que hablar. Es **nuestro artefacto**, como `ontology.lock` y como el bundle.

Y por eso la pregunta de diseño no es *«¿cómo lo perfilamos?»* sino la que decide todo lo
demás: **¿qué tiene que ser cierto de un fichero para que su digest signifique algo?**

---

## 4. Lo que hay que añadir es un documento y un comando

| | |
|---|---|
| **se crea** | `spec/v1alpha6/` · `conformance/v1alpha6/pack/` |
| **no se toca** | los ocho documentos de v1alpha1 · **ningún esquema** · la forma canónica · el registro de errores · el cómputo del digest |

Que **no haga falta ni un código nuevo ni un cambio en el digest** no es economía: es la
señal de que el formato estaba ya decidido y nadie lo había escrito. §1 de
[`01-distribucion`](01-distribucion.md) lo dice entero — **un `.oob` es la forma canónica**, y
la forma canónica lleva normativa desde v1alpha1.

---

## 5. Lo que **no** entra

**El registro como servicio.** Un índice, una API de publicación, cuentas, retirada de
versiones. Es un producto, no una especificación — y esta versión existe precisamente para
que ese producto **no tenga que ser de confianza**, con lo cual tampoco tiene que ser el
nuestro.

**Cómo una coordenada se convierte en una URL.** Se delega, y la razón es la misma por la que
se delega leer una fuente: un compilador que resolviera nombres en la red dejaría de ser una
función del árbol de ficheros. `01-distribucion` §4 fija el contrato con el programa que lo
hace —qué recibe, qué devuelve y qué se verifica— y **no fija dónde vive lo que trae**.

**Firmas criptográficas.** Un digest dice que el contenido es el que el lock nombra; una firma
diría **quién** lo publicó. Es una capa más y es separable: exige un modelo de identidad y una
distribución de claves que esta versión no tiene, y no bloquea nada de lo de arriba. El lock
ya hace revisable la decisión de confianza — la entrada la añade alguien y la aprueba un pull
request.

**Compresión.** Un `.oob` es texto y se comprime en tránsito como cualquier otro; comprimirlo
*dentro* del formato metería una decisión —qué algoritmo, qué nivel— en un artefacto cuya
propiedad principal es que dos productores conformes escriban los mismos bytes.

---

## 6. La decisión que este alcance cierra, y que no era obvia

> **Un `.oob` NO es un archivo comprimido.**

Era la respuesta evidente —un `tar.gz` con los `.yaml` dentro— y se cae con `G1`. Un archivo
lleva marcas de tiempo, orden de entradas, permisos y nivel de compresión: **el mismo paquete
produce bytes distintos**, y el digest deja de ser función del contenido. Habría hecho falta
un «formato de archivo determinista», que es un problema resuelto por nadie de forma
convincente y que aquí no hay que resolver.

La alternativa cabe en una frase: la forma canónica **ya es** una serialización determinista
de un paquete, y su digest **ya está** definido. Un `.oob` es eso escrito en un fichero.

Con dos consecuencias que valen la pena por sí solas:

- **El contenedor no cambia la identidad.** El mismo paquete vendorizado como árbol y
  publicado como `.oob` tiene **el mismo digest**, porque el digest es de los documentos y
  nunca de las rutas (`digest` §5.2). Un lock resuelto contra el árbol sigue valiendo cuando
  ese paquete se publique.
- **No hace falta extraerlo para verificarlo.** Se lee, se computa y se compara. Un formato
  que hubiera que descomprimir para saber si es el que pediste obliga a escribir en disco algo
  que aún no has verificado.
