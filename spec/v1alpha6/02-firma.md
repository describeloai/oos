# v1alpha6 · La firma de un paquete

> **Normativo.** Extiende [`01-distribucion`](01-distribucion.md). Un digest dice **qué** es un
> paquete; esto es lo que hace que también se pueda saber **de quién**.

---

## 1. Qué añade una firma que un digest no puede dar

`01-distribucion` §2 establece que el consumidor **DEBE** computar el digest de lo que recibe y
compararlo con su lock. Eso hace que el origen no tenga que ser de confianza — y no hace nada
sobre una pregunta distinta:

> *«El paquete que mi lock fija, ¿lo publicó quien yo creo?»*

Un digest no la contesta y no puede: **un digest correcto lo produce cualquiera que tenga los
bytes**, incluido quien los sustituyó antes de que nadie los fijara. El digest protege de un
cambio *después* de aceptar; la firma es lo único que dice algo sobre el momento de aceptar.

---

## 2. Qué se firma

Se firma el **enunciado**: la coordenada y el digest, en la forma canónica de
[`90-canonical-form`](../v1alpha1/90-canonical-form.md).

```json
{"digest":"sha256:…","package":"oos.dev/regulatory/gdpr","version":"0.2.0"}
```

**Normativo.** Un productor **DEBE** firmar exactamente esos bytes: las tres claves, en ese
orden —el de JCS— y ninguna más.

Las dos alternativas evidentes están descartadas, y por lo mismo que decidió el formato:

| | Por qué no |
|---|---|
| firmar **el fichero** | ataría la firma al contenedor, y `01-distribucion` §2 dice que el contenedor no cambia la identidad. La misma firma tendría que valer para el árbol y para el `.oob`, y no valdría |
| firmar **el digest a secas** | sería una afirmación sin sujeto —*«estos bytes existen»*— replicable sobre cualquier coordenada |

Con los tres campos, una firma dice lo mismo que dice una entrada del lock. Es la propiedad que
hace que se pueda creer: firmar `gdpr 0.2.0` no firma `gdpr 0.3.0` aunque el digest coincida.

---

## 3. Dónde vive cada mitad

**Normativo.** Un motor conforme **DEBE** poder verificar una firma. **NO DEBE** necesitar una
clave privada para nada.

| | Dónde | Por qué |
|---|---|---|
| **verificar** | dentro del motor | es aritmética sobre bytes que ya están en el árbol. No es red, no es reloj, no es una credencial |
| **firmar** | fuera, delegado | exige una clave privada |

Es la misma frontera que `01-package` traza para un secreto de conexión y que
[`01-distribucion` §4](01-distribucion.md) traza para traer un paquete: **lo que necesita una
credencial vive fuera del compilador.** No es higiene, es lo que permite que el binario que
compila se ejecute en el CI de un tercero o en la máquina de quien audita sin que nadie tenga
que preguntarse a qué tiene acceso. Un compilador que pudiera firmar sería un compilador al que
hay que confiarle algo.

La asimetría es el punto: verificar no necesita nada que no esté ya, así que **una firma que no
case se puede rechazar sin haber confiado en nadie**.

---

## 4. La forma

### 4.1 · En el `.oob`

Un sobre **PUEDE** llevar `signatures`. Es opcional: un paquete sin firmar es válido.

```json
{ "oobVersion": 1, "package": "…", "version": "…", "oos": "…",
  "documents": { … },
  "signatures": [
    { "algorithm": "ed25519", "keyId": "oos.dev", "signature": "<128 hex>" }
  ] }
```

`signatures` **NO DEBE** entrar en el cómputo del digest. Se sigue de que el digest sea sobre
las identidades y los digests de los **documentos** (`90-canonical-form` §5.2), y tiene una
consecuencia que conviene decir en voz alta: **firmar no cambia la identidad.** Un lock
resuelto contra el paquete sin firmar sigue valiendo el día que alguien lo firme.

`algorithm` es `ed25519`. Se escribe aunque hoy solo haya uno: el día que haya un segundo, lo
que no puede pasar es que las firmas viejas no digan cuál son.

### 4.2 · En el manifiesto de quien consume

```yaml
trustedKeys:
  - id: oos.dev
    algorithm: ed25519
    publicKey: "<64 hex>"
```

**Normativo.** La clave pública **DEBE** venir de quien consume. Un motor **NO DEBE** verificar
una firma con una clave que viaje dentro del paquete que firma: cerraría el círculo entero —
quien sustituye el paquete sustituye la clave, firma con la suya, y todo verifica.

### 4.3 · En el lock

```yaml
  - name: oos.dev/regulatory/gdpr
    version: 0.1.0
    digest: sha256:…
    signedBy: [oos.dev]
```

**Normativo.** `signedBy` **DEBE** contener solo firmantes **verificados** al resolver. Un lock
que anotara lo que el paquete dice de sí mismo convertiría un rumor en un hecho por el mero
acto de escribirlo, y el lock es el documento del que todo lo demás tira.

---

## 5. Qué comprueba un consumidor

**Normativo.** Al cargar un paquete importado, un motor conforme:

1. **DEBE** verificar cada firma cuyo `keyId` esté en `trustedKeys`, contra el enunciado
   construido con el digest **recomputado del árbol** —nunca con uno que venga escrito—. Si no
   verifica, **DEBE** parar, con el mismo trato que un digest que no case.
2. **DEBE** parar si el lock afirma un firmante y el paquete del árbol no trae una firma válida
   de esa clave.
3. **NO DEBE** rechazar una firma cuyo `keyId` no conoce: no hay con qué comprobarla, y
   rechazar por no poder mirar convertiría la firma de un tercero en un fallo de quien no lo
   conoce.
4. **NO DEBE** exigir que un paquete esté firmado.

La segunda es la que hace que la primera no se pueda esquivar. Sin ella, borrar el campo
`signatures` sería la forma barata de saltarse la comprobación — y una comprobación evitable no
es una comprobación. El ancla no es una declaración nueva sino **el lock**, que ya existe y ya
se revisa en un pull request.

Y las dos juntas explican por qué la 4 no es una laxitud: quien no firma no gana nada, porque
lo que protege es haber firmado **una vez** y que el lock lo recuerde.

### Diagnóstico

| Código | Condición |
|---|---|
| `OOS2016` | la firma de un paquete importado no verifica, o falta la que el lock afirma |

Un solo código y dos condiciones, por la misma razón que `OOS5009` cubre varias causas: **el
síntoma observable es uno** —lo que hay no es lo que se aceptó— y quien lo lee necesita saber
eso antes que cuál de las dos formas tomó.

---

## 6. Listo — dos peldaños

### 6.1 · Peldaño 1 · **firmar no cambia la identidad**

> El mismo paquete, firmado y sin firmar, digiere igual.

Es el peldaño 1 de `01-distribucion` §6.1 aplicado a lo que se le añade encima. Si fallara,
firmar sería indistinguible de cambiar el paquete y ningún lock sobreviviría a que su
dependencia empezara a firmarse.

### 6.2 · Peldaño 2 · **una firma que estaba no se puede quitar**

> Un consumidor cuyo lock afirma un firmante **no compila** con un paquete del que se ha
> quitado la firma.

Es el que convierte la firma en una garantía en vez de en un adorno. Se mide quitando el campo,
no manipulándolo.

---

## 7. El horizonte

**El log de transparencia.** ~~Una firma dice de quién; un log append-only dice *que esa clave
nunca dijo dos cosas distintas*.~~ Está en [`03-transparencia`](03-transparencia.md), y salió
donde este párrafo decía: una capa encima del mismo enunciado, sin tocar nada de aquí. La hoja
del log es este enunciado **y su firma**.

**Rotación y revocación de claves.** Hoy `trustedKeys` es una lista y cambiarla es un pull
request, que ya es un mecanismo de revocación — lento, revisado y sin infraestructura. Lo que
falta para uno mejor es el log: sin él, una revocación es otra afirmación que hay que creerse.

**Varias firmas sobre el mismo paquete.** La forma ya lo admite —`signatures` es una lista— y
el motor ya verifica cada una por separado. Lo que no está decidido es qué significaría exigir
*dos de tres*, y eso es una política de quien consume, no un formato.
