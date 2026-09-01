# v1alpha6 · El log de transparencia

> **Normativo.** Extiende [`02-firma`](02-firma.md). Una firma dice **de quién** es un paquete;
> esto es lo que impide que esa clave diga cosas distintas a dos personas **en privado**.

---

## 1. El agujero que deja una firma

`02-firma` §5 hace que un `.oob` cuya firma no case no se use. Eso cierra la sustitución por un
tercero y deja abierta otra cosa:

> **Quien tiene la clave puede firmar dos `gdpr 0.2.0` distintos.** Uno para el auditor y otro
> para ti. Las dos firmas verifican.

Ninguna comprobación local los distingue, y no por falta de rigor: **el defecto no está en lo
que tienes.** Está en no poder ver lo que le enseñaron a otro.

La respuesta es la que ya dieron la base de sumas de Go y Sigstore: **todo lo que se firma se
publica en una lista que solo crece, y cualquiera puede comprobar que su copia es un prefijo de
la tuya.** No impide firmar algo malo; garantiza que no se pueda hacer sin dejarlo por escrito.

Y es lo que hace demostrable la pregunta que el sector regulado hace de verdad: *«¿qué decía la
definición de dato personal el 14 de marzo?»*.

---

## 2. La forma del árbol

**Normativo.** El árbol es el de [RFC 6962](https://www.rfc-editor.org/rfc/rfc6962) §2.1:

```text
hoja(d)   = SHA-256(0x00 ‖ d)
nodo(a,b) = SHA-256(0x01 ‖ a ‖ b)
```

Los prefijos separan los dos dominios y **no son decorativos**: sin ellos, la hoja cuyo
contenido es la concatenación de dos hashes tendría el mismo hash que el nodo que los une, y
una hoja podría hacerse pasar por un subárbol.

Se adopta RFC 6962 y no un árbol propio por una razón concreta: es lo que permite que un log
existente sirva a este formato y que un tercero verifique con las herramientas que ya tiene.
Un árbol propio habría sido el mismo cómputo con menos gente que lo sabe leer.

### La hoja

**Normativo.** Lo que se anota es el **enunciado firmado y quién lo firmó**, en forma canónica:

```json
{"keyId":"oos.dev","signature":"<128 hex>","statement":"{\"digest\":\"sha256:…\",…}"}
```

El enunciado es **el mismo** de `02-firma` §2, no una segunda forma de decir lo mismo. Lo que
hay que poder demostrar más tarde no es *«este paquete existió»* sino *«esta clave dijo esto»*,
y por eso la firma entra en la hoja.

### La cabeza firmada

**Normativo.** Un log **DEBE** firmar cada cabeza que publique:

```json
{"logId":"oos.dev/log","root":"<64 hex>","treeSize":42}
```

Sin esto lo demás no significa nada: una prueba de inclusión demuestra que una hoja está en un
árbol **con esa raíz**, y no dice de dónde salió la raíz. Cualquiera construye un árbol con la
hoja que quiera, calcula su raíz y presenta una prueba impecable de algo que ningún log ha
visto.

El `logId` va dentro por lo mismo que la coordenada va en el enunciado de una firma: para que
la cabeza de un log no valga como cabeza de otro.

---

## 3. Dos pruebas, y hacen falta las dos

| | Qué demuestra | Sin ella |
|---|---|---|
| **inclusión** | esta versión está en el log, en esta posición | el log podría no haberla visto nunca |
| **consistencia** | el log de hoy **extiende** el de ayer | el log podría haber reescrito el pasado |

Con solo la primera, un log puede enseñarle a cada uno un árbol distinto y **todas las pruebas
de inclusión cuadran**, cada una contra su propia raíz. Se llama bifurcación, y es exactamente
el ataque contra el que existe la segunda.

### Dónde vive cada una

**Normativo.** Un motor conforme **DEBE** poder verificar las dos, y **NO DEBE** necesitar red
para verificar la inclusión.

| | Dónde | Por qué |
|---|---|---|
| **verificar** | dentro del motor | es SHA-256 sobre hashes que ya están en el árbol |
| **servir el log** | fuera, delegado | es estado, disco y —en cuanto sea de verdad— red |

Es la misma frontera de `02-firma` §3 y de `01-distribucion` §4.

Y hay un reparto más, que no es de capas sino **de momento**:

- La **inclusión** viaja dentro del `.oob`, porque quien publica sabe en qué árbol entró.
- La **consistencia** no puede viajar dentro: **quien publica no sabe qué cabeza viste tú la
  última vez.** Se pide, como se pide un paquete.

De ahí se sigue que verificar la inclusión sea hermético y avanzar la cabeza no lo sea. Un
consumidor compila sin preguntarle nada a nadie; **cambiar de cabeza** es otra cosa, y es la
única que necesita hablar con el log.

---

## 4. La forma

### 4.1 · En el `.oob`

Un sobre firmado **PUEDE** llevar `transparency`. `signatures` es requisito: una entrada sin
firma dejaría constancia de que un paquete existió, que no es lo que un log demuestra.

```json
"transparency": [
  { "logId": "oos.dev/log", "keyId": "oos.dev",
    "index": 41, "treeSize": 42,
    "root": "<64 hex>", "rootSignature": "<128 hex>",
    "inclusion": ["<64 hex>", "…"] }
]
```

`inclusion` es una **secuencia**: cada hash sube un nivel del árbol, así que reordenarla da otra
raíz. `transparency` **NO DEBE** entrar en el digest, por lo mismo que `signatures`: anotar no
cambia la identidad.

### 4.2 · En el manifiesto de quien consume

```yaml
trustedLogs:
  - id: oos.dev/log
    algorithm: ed25519
    publicKey: "<64 hex>"
```

La clave del log **DEBE** venir de quien consume, y es distinta de la del paquete: son **dos
autoridades**. Quien publica afirma *«esto es mío»*; el log afirma *«esto lo he visto y esta es
toda mi lista»*.

### 4.3 · En el lock

```yaml
  - name: oos.dev/regulatory/gdpr
    logged: [oos.dev/log]

logs:
  - id: oos.dev/log
    treeSize: 42
    root: <64 hex>
```

`logs` cuelga de la raíz y no de un paquete porque **no es de ningún paquete**: es la última
cabeza que este árbol dio por buena, y es el ancla contra la bifurcación.

---

## 5. Qué comprueba un consumidor

**Normativo.** Al cargar un paquete importado, un motor conforme:

1. **DEBE** verificar la cabeza contra la clave del log **antes** que la prueba de inclusión.
2. **DEBE** verificar la inclusión de la hoja construida con el **digest recomputado** y la
   firma que el paquete trae — nunca con nada que venga escrito.
3. **DEBE** parar si el lock fijó otra raíz para ese mismo `treeSize`.
4. **DEBE** parar si el lock afirma un log y el paquete no lo demuestra.
5. **NO DEBE** rechazar una prueba de un log que no conoce, ni exigir que un paquete esté
   anotado.

Y al **avanzar** la cabeza que el lock fija, un motor:

6. **DEBE** obtener y verificar una prueba de consistencia entre la cabeza vieja y la nueva,
   sea cual sea de las dos la mayor. Sin ella la garantía sería *«el log dijo esto»*, que es
   lo que dice cualquier firma.

### Diagnóstico

| Código | Condición |
|---|---|
| `OOS2017` | la prueba de transparencia de un paquete importado no verifica, o falta la que el lock afirma |

Un solo código, por el mismo criterio que `OOS2016`: **el síntoma observable es uno** —lo que
hay no es lo que se aceptó— y quien lo lee necesita saber eso antes que cuál de las formas tomó.

---

## 6. Listo — dos peldaños

### 6.1 · Peldaño 1 · **un tercero verifica sin preguntarnos nada**

> Quien replique el log comprueba la inclusión de una versión con SHA-256 y la clave pública
> del log, sin hablar con quien la publicó ni con quien la sirve.

Es lo que hace que el log sea una garantía y no un servicio. Se mide replicando la lista y
recomputando.

### 6.2 · Peldaño 2 · **una historia distinta no cuela**

> Un log que enseñe otra raíz para un tamaño que ya se vio, o que no pueda demostrar que el
> árbol de ahora extiende al de entonces, **no compila**.

Es el peldaño que separa un log de transparencia de una lista firmada. Se mide con dos
historias que comparten prefijo: las pruebas de inclusión de las dos cuadran, y solo la
consistencia lo ve.

---

## 7. El horizonte

**Testigos.** Un consumidor solo ve la parte del log que le enseñan. Que varios se intercambien
cabezas —o que terceros las publiquen— es lo que convierte *«a mí no me ha mentido»* en *«no ha
mentido»*. No toca nada de aquí: una cabeza firmada ya es un objeto que se puede pasar.

**Anotar sin publicar el paquete.** Hoy se anota al empaquetar. Anotar una retirada, una
rotación de clave o un aviso es la misma forma con otra hoja, y lo que falta no es formato: es
decidir qué significan.

**Un log de logs.** Es la respuesta ortodoxa a *«¿y quién vigila al log?»* y es prematura
mientras no haya dos. Lo que ya vale hoy sin ella: `trustedLogs` es una lista, y nada impide
exigir dos.
