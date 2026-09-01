# v1alpha6 · El registro

> **Normativo.** Cierra [`01-distribucion`](01-distribucion.md). Va el último a propósito, y esa
> es la mitad interesante de este documento.

---

## 1. Por qué va el último

Un registro de paquetes suele ser lo primero que se construye, y acaba siendo la pieza de la
que todo lo demás depende: quien lo opera decide qué existe, qué es cada cosa y quién puede
publicar.

Aquí llega al final, y para entonces **ya no le queda casi nada que decidir**:

| | Se lo quitó | Qué le quedaba |
|---|---|---|
| **integridad** | `01-distribucion` §2 | *«esto es lo que pediste»* |
| **procedencia** | `02-firma` | *«esto lo publicó quien crees»* |
| **historia** | `03-transparencia` | *«y no le han dicho otra cosa a otro»* |

Lo que queda es **servir ficheros**. Y eso es exactamente la propiedad que se quiere conservar:
un registro del que se pueda prescindir es un registro que no ata a nadie. La orden con la que
se hace un espejo completo es `rsync`.

> **Normativo.** Un registro **NO DEBE** ser necesario para compilar. Un consumidor con su árbol
> vendorizado y su lock **DEBE** poder compilar sin alcanzar ningún origen.

---

## 2. La forma: dos directorios

**Normativo.** Un registro es un árbol de ficheros estáticos con esta disposición:

```text
<raíz>/
  index/oos.dev/regulatory/gdpr.json
  blobs/sha256/<64 hex>
```

Sin base de datos en el camino crítico y sin nada que ejecutar: **cualquier servidor de
ficheros estáticos es un registro conforme.** Es lo que hace que un espejo sea una copia y no
un despliegue.

### 2.1 · El índice

`index/<paquete>.json`, con el nombre del paquete **como ruta**: la coordenada ya tiene la forma
de una, así que no hace falta inventar un escapado.

```json
{ "package": "oos.dev/regulatory/gdpr",
  "versions": [
    { "version": "0.1.0", "digest": "sha256:d47f…", "blob": "a91c…", "size": 11362 }
  ] }
```

### 2.2 · Los blobs

`blobs/sha256/<hash>`, donde el hash es el **SHA-256 de los bytes del fichero**.

**Y no es el digest del paquete, que es otra cosa.** La distinción importa lo suficiente para
decirla en voz alta:

| | Identifica | Cambia cuando |
|---|---|---|
| `digest` | **el paquete** | cambia un documento |
| `blob` | **el fichero** | cambia cualquier byte, incluida una firma |

Si el blob se nombrara por el digest del paquete, dos `.oob` del mismo paquete —uno firmado y
otro no, o firmados por claves distintas— colisionarían: mismo nombre, bytes distintos. Y eso
es una consecuencia directa de que **el contenedor no cambie la identidad** (§2 de
`01-distribucion`), que es una propiedad que se quiere y no un defecto que corregir.

Así que el almacén direcciona **bytes** y el índice direcciona **significado**. Son dos
preguntas y llevan dos nombres.

---

## 3. Qué comprueba quien replica

**Normativo.** Un registro es verificable **sin hablar con nadie**. Quien tenga una copia
**DEBE** poder comprobar, por sí solo:

1. el SHA-256 de cada blob es su nombre;
2. cada versión del índice apunta a un blob que existe;
3. ese blob analiza como `.oob`, dice ese paquete y esa versión, y **el digest de su paquete es
   el que el índice declara**.

Las tres son aritmética sobre ficheros. Un registro que las pase no está diciendo la verdad
porque nosotros lo digamos: está diciendo algo que cualquiera acaba de recomprobar.

Y lo que un registro **NO** puede afirmar con esto: que un paquete sea de quien dice —eso es
`02-firma`— ni que su historia sea única —eso es `03-transparencia`—. Un registro conforme
puede servir un paquete sin firmar, y quien lo consuma se enterará por su lock.

---

## 4. Publicar

**Normativo.** Publicar es **escribir dos ficheros**: el blob y la entrada del índice.

Un registro **NO DEBE** reescribir un blob que ya existe con otros bytes —el nombre es su
hash, así que no podría— y **NO DEBE** cambiar el `digest` de una versión ya publicada. Lo que
sustituye a corregir una versión es **publicar otra**.

Lo que este documento **no** define, y no por falta de tiempo:

- **Cuentas y permisos.** Son de quien opera un registro concreto y no de la forma. Definirlas
  aquí ataría el formato a un modelo de identidad que `02-firma` no necesita: quien verifica una
  firma no pregunta quién tenía permiso de escritura.
- **Búsqueda.** Buscar, navegar y *«quién depende de esto»* son útiles y **desechables**: si se
  cae el buscador, los builds siguen. Un registro cuyo índice puede tumbar una compilación ha
  dejado de ser un registro.
- **Retirar una versión.** Retirar rompe a quien no la tenga y no a quien ya la verificó, y eso
  es correcto. Lo que sustituye a una retirada es **una versión nueva y un aviso**, no borrar el
  pasado — que es además lo que `03-transparencia` hace comprobable.

---

## 5. Listo — el peldaño 3

`01-distribucion` §6.3 lo dejó escrito y aquí es donde se cobra:

> **Dos consumidores que obtienen el mismo paquete de orígenes distintos compilan el mismo
> bundle.**

**Y «orígenes distintos» no significa dos copias del mismo directorio.** Eso solo mediría que
`cp` funciona. La medida que vale enfrenta dos caminos que no comparten un solo byte de
transporte:

| | Origen |
|---|---|
| **A** | el registro: un blob servido, direccionado por contenido |
| **B** | **el código fuente**: `ore pack` sobre el árbol del que salió |

Si los dos dan el mismo digest y el mismo bundle, entonces el registro no está aportando
identidad — está aportando **conveniencia**, que es todo lo que debe aportar. Es la
construcción reproducible aplicada a la distribución, y no exige nada que no esté ya:
empaquetar es puro y el digest es función del contenido.

Es también lo que convierte a un tercero en auditor sin pedirle permiso a nadie: puede
recomputar el `.oob` desde el commit y comprobar que el registro sirve lo que ese commit dice.

---

## 6. El horizonte

**Espejos y caché compartida.** Se siguen de §2 sin añadir nada: si el origen no importa,
cualquiera puede servir lo mismo. Es lo que un formato direccionado por contenido regala y uno
direccionado por URL no puede tener.

**Un índice de índices.** Un registro sabe de sus paquetes y no de los de otro. Federar es
concatenar índices, y la pregunta que falta no es técnica: es qué pasa cuando dos registros
dicen cosas distintas de la misma coordenada. La respuesta ya está escrita en otro sitio —
`03-transparencia`— y aplicarla aquí es trabajo, no invención.

**Publicar desde CI.** Empaquetar es puro, así que un tercero puede recomputar el `.oob` desde
el commit y comprobar que el registro sirve lo que ese commit dice. §5 lo mide entre dos
orígenes; hacerlo en cada publicación es la misma medida, automatizada.
