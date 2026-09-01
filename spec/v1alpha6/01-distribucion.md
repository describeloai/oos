# v1alpha6 · Distribución — el `.oob` y de dónde viene

**Normativo para esta versión.** Fija **qué es** un paquete publicable, **qué se verifica** de
él y **qué contrato** cumple el programa que lo trae. No fija dónde vive: eso es §4, y es
justamente lo que no se fija.

---

## 1. Qué es un `.oob`

> **La forma canónica de un paquete, escrita en un fichero.**

No es un archivo comprimido, y esa es la decisión de la versión
([`00-scope`](00-scope.md) §6). Un `tar.gz` lleva marcas de tiempo, orden de entradas y nivel
de compresión: el mismo paquete produciría bytes distintos y el digest dejaría de ser función
del contenido. La forma canónica ya resuelve eso desde v1alpha1, y su digest ya está definido.

Un `.oob` es **un documento JSON en JCS** (RFC 8785), con esta forma:

```json
{
  "documents": {
    "Property:gdpr.personalEmail": { "apiVersion": "oos.dev/v1alpha4", "kind": "Property", … },
    "Lattice:gdpr.sensitivity":    { … }
  },
  "oobVersion": 1,
  "oos": "oos.dev/v1alpha4",
  "package": "oos.dev/regulatory/gdpr",
  "version": "0.1.0"
}
```

**Normativo.**

- `oobVersion` **DEBE** valer `1`. Es la versión **del sobre**, no la de OOS: un `.oob` puede
  cambiar de forma sin que cambie ninguna gramática, y al revés.
- `package` y `version` **DEBEN** estar, y son la identidad que el fichero **declara**. Un
  fichero renombrado es un fichero que miente, así que la identidad va dentro.
- `oos` **DEBE** ser la mayor `apiVersion` que use alguno de sus documentos. Se **deriva**, no
  se declara: es lo que permite a un consumidor rechazar un paquete del futuro sin abrirlo
  entero.
- `documents` **DEBE** contener la forma canónica de cada documento del paquete, indexada por
  su identidad —`<Kind>:<nombre cualificado>`— exactamente como la produce
  [`90-canonical-form`](../v1alpha1/90-canonical-form.md).
- El fichero **DEBE** serializarse en JCS. Dos productores conformes escriben **los mismos
  bytes**.

### 1.1 · Qué NO va dentro, y las tres son la misma razón

| No va | Por qué |
|---|---|
| `OntologyConfig` | es del **workspace**, no del paquete. Lleva las fuentes físicas y las dependencias de quien compila, y publicarlas sería publicar la infraestructura de otro |
| `ontology.lock` | es de quien consume. El lock de un publicador no gobierna al que importa |
| los artefactos generados (`.cedarschema`) | se derivan de lo que sí va dentro. Publicarlos sería publicar dos veces lo mismo, y uno de los dos envejece |

Y **el digest tampoco va dentro**. No por evitar la autorreferencia —se puede computar sobre
`documents` y guardarlo al lado— sino por algo peor: *un número que un lector no debe creerse
acaba creído.* Lo que se verifica es contra **el lock del que consume**, nunca contra lo que el
fichero dice de sí mismo.

---

## 2. El digest, que ya estaba

El digest de un `.oob` **es el digest del paquete**, tal y como lo define
[`digest`](../v1alpha1/90-canonical-form.md) §5.2: sobre las identidades y los digests de los
documentos, **nunca sobre las rutas**.

De ahí sale la propiedad que hace que esta versión no rompa nada de lo anterior:

> **El contenedor no cambia la identidad.** El mismo paquete vendorizado como un árbol de
> ficheros y publicado como `.oob` tiene el mismo digest.

Un lock que se resolvió contra el árbol sigue siendo válido el día que ese paquete se publique,
y un consumidor puede pasar de una forma a la otra sin que nada se mueva. Si el digest hubiera
sido el del fichero, cambiar de contenedor habría sido indistinguible de cambiar de paquete.

**Normativo.** Un consumidor **DEBE** computar el digest de lo que recibe y compararlo con la
entrada de su lock. Si no coinciden, **DEBE** parar. **NO DEBE** aceptar el digest que el
origen declare, venga en el fichero, en una cabecera o en un índice.

Y **DEBE** volver a compararlo cada vez que compila, no solo al traerlo: un paquete que ya
está en el árbol se puede editar, y el momento en que se obtuvo no es el momento en que se
usa. El síntoma —*lo que usas no es lo que declaraste*— es el de `OOS2013`, y no hace falta
un código nuevo: el lock y lo que hay dicen cosas distintas sobre el mismo artefacto.

---

## 3. Inmutabilidad

Una versión publicada **NO DEBE** cambiar nunca. No es una recomendación de higiene: si
cambiara, su digest cambiaría, y **todos los locks que la nombran se romperían a la vez** — que
es exactamente el comportamiento correcto y la razón de que no haga falta prohibirlo con nada
más que aritmética.

Retirar una versión —que un registro deje de servirla— es legítimo y es otra cosa: rompe a
quien no la tenga, no a quien ya la verificó.

---

## 4. De dónde viene: el contrato, no el sitio

**OOS no fija cómo una coordenada se convierte en una URL**, y no por falta de opinión: un
compilador que resolviera nombres en la red dejaría de ser una función del árbol de ficheros,
que es la invariante III. Traer un paquete **se delega**, igual que se delega leer una fuente
([`03-binding`](../v1alpha1/03-binding.md)), y lo que esta sección fija es el contrato con el
programa que lo hace.

**Normativo.**

- El programa se llama **`ore-fetch`** y se busca en el `PATH`. Un motor conforme **PUEDE**
  usar otro nombre; lo que **DEBE** conservar es que sea *un programa del usuario, que el
  usuario ya autenticó*.
- La petición viaja por **stdin**, nunca por la línea de órdenes: `argv` lo lee cualquier
  proceso de la máquina, y una coordenada privada dice de qué depende una organización.

  ```json
  { "package": "oos.dev/regulatory/gdpr", "range": "^0.1" }
  ```

- La respuesta es **el `.oob` por stdout**, y nada más. Un programa que no pueda traerlo
  **DEBE** salir con código distinto de cero y explicar por qué en **stderr**.
- El motor **DEBE** mostrar ese stderr **literal**. Es lo único accionable que existe: «no
  estás autenticado» y «esa versión fue retirada» se arreglan solos en cuanto se leen, y
  resumirlos convierte un problema de cinco minutos en una tarde.
- El motor **DEBE** comprobar que el `.oob` que recibe **dice el paquete que se pidió** y una
  versión **dentro del rango**, y **NO DEBE** escribir en disco lo que no lo cumpla. Que el
  obtenedor ya lo haya mirado no cuenta: lo que hace que su origen no tenga que ser de
  confianza es precisamente que quien pide **no se crea nada**.
- Un obtenedor **PUEDE** ignorar el rango y devolver lo que tenga. No es dejadez: es la
  consecuencia de lo anterior — si la comprobación de verdad está del lado del que pide, un
  obtenedor esmerado solo conseguiría que pareciera redundante.

### 4.1 · Y por eso el registro no es de confianza

Ninguna de las reglas de arriba pide que el origen sea honesto. Un registro que sirviera otro
paquete produce otro digest y la compilación se para; uno que sirviera una versión
**modificada** de la que pediste, igual. Lo único que puede hacer es **no servirte**.

Es la misma figura que el lector de una fuente: *la credencial nunca entra en el espacio de
direcciones del compilador*, y aquí *la confianza nunca entra en la decisión de qué se
compila*.

### 4.2 · La primera vez, y quién decide

Un lock vacío no tiene contra qué verificar. La primera resolución **anota lo que obtuvo**, y
ese acto **es** la decisión de confianza — no la toma el motor: la toma quien revisa el
`ontology.lock` en un pull request, que es donde este proyecto pone todas las demás.

Es idéntico a un `package-lock.json` y por lo mismo. La diferencia está en qué se acepta al
aceptarlo: aquí, **la definición de qué es un dato personal**.

---

## 5. Cuándo publicar falla

Un paquete **NO DEBE** empaquetarse si:

- **no valida.** Publicar algo que no compila reparte un problema en vez de un paquete.
- **no declara `name` y `version`.** Sin identidad no hay coordenada, y sin coordenada nadie
  puede importarlo — es lo que `01-package` §2.1 ya exige para poder ser referenciado.
- **contiene un `Binding`** cuyo `datasourceRef` no está en el paquete. Un binding dice dónde
  está el dato **de quien publica**, y viaja hacia un consumidor que no tiene esa fuente. No es
  un error de forma: es publicar la infraestructura de otro.

---

## 6. Listo — tres peldaños

No son fases: son propiedades independientes, cada una medible sin las otras.

### 6.1 · Peldaño 1 · **es determinista**

> El mismo paquete produce el mismo `.oob`, **byte a byte**, y su digest es el mismo que el del
> paquete sin empaquetar.

Es `G1` sobre el artefacto que se distribuye, y la segunda mitad es la que importa: si el
digest cambiara al empaquetar, **el contenedor sería parte de la identidad** y cambiar de
contenedor sería indistinguible de cambiar de paquete.

### 6.2 · Peldaño 2 · **es verificable sin extraerlo**

> Un consumidor decide si un `.oob` es el que pidió **leyéndolo**, sin escribir nada en disco.

Un formato que hubiera que descomprimir para saberlo obliga a materializar algo que todavía no
has verificado, que es la peor forma de tratar un fichero que acaba de llegar de la red.

### 6.3 · Peldaño 3 · **el registro es prescindible**

> Dos consumidores que obtienen el mismo paquete de **orígenes distintos** compilan el mismo
> bundle.

Es lo que convierte «portable» (`G5`) en algo que también vale para las dependencias, y lo que
hace que adoptar esto no sea adoptar a un proveedor. Se mide con dos orígenes y un solo lock.

---

## 7. El horizonte

**Firmas.** ~~Un digest dice *qué* es; una firma diría *quién* lo publicó.~~ Está en
[`02-firma`](02-firma.md), y salió justo donde este párrafo decía que iría: una clave junto al
digest en el lock. No tocó nada de aquí.

**Espejos y caché compartida.** Se siguen de §4.1 sin añadir nada: si el origen no importa,
cualquiera puede servir lo mismo. Es la propiedad que un formato de identidad por contenido
regala y que uno por URL no puede tener.

**Y dónde se queda lo traído es del motor, no de aquí.** La implementación de referencia lo
**vendoriza en el árbol** en vez de guardarlo en una caché, y la diferencia se nota en un
clon recién hecho: con caché hace falta el obtenedor otra vez, y con el árbol no hace falta
nadie. Un artefacto que se compromete a Git se revisa en un pull request como todo lo demás —
que es donde este proyecto pone las decisiones de confianza.

**Publicar desde CI.** Empaquetar es puro y el digest es reproducible, así que un tercero puede
recomputar el `.oob` desde el commit y comprobar que el registro sirve lo que ese commit dice.
Es la construcción reproducible aplicada a la distribución, y no exige nada que no esté ya.
