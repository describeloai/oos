# 05 · Ejecutor — el nivel L2

**Estado:** normativo. Parte de OOS v1alpha1.
**Gobierna:** qué **DEBE** hacer una implementación L2 cuando el dato se mueve de verdad.

---

## 1. Naturaleza

[`04-flow`](04-flow.md) fija **la regla**. Este documento fija **qué pasa cuando la
información se pone en movimiento**, que es lo único que L0 y L1 no podían comprobar: L0 es
hermético y L1 sirve un artefacto ya compilado. En cuanto hay una fuente viva y un principal
que pregunta, aparecen tres cosas que ningún documento anterior podía nombrar — un plan, una
credencial y una respuesta que puede llegar tarde.

Y una diferencia de fondo que conviene fijar antes que nada:

> **L0 y L1 fallan al compilar. L2 falla al responder.**

Por eso este documento casi no añade códigos de error. Un rechazo en tiempo de consulta no es
un defecto de un documento: es una **condición nombrada** que la implementación **DEBE**
comunicar. Los códigos `OOSxxxx` siguen siendo del artefacto.

### 1.1 · Los dos planos

| Plano | Qué sirve | Dónde vive | Latencia |
|---|---|---|---|
| **Contexto** | entidades, relaciones, tipos, políticas, linaje | el artefacto compilado | µs–ms |
| **Datos** | filas y valores | el origen | la de la fuente |

**L2 es el plano de datos, y solo él.** Servir el plano de contexto es L1 y no exige nada de
este documento.

---

## 2. La ley: el ejecutor no compensa

Una lectura amplificada **es un conducto**. Cuando el motor consume el flujo completo de una
fuente, reserva memoria, deserializa, filtra y emite diez filas, esas diez filas no son lo
que ha pasado por él: han pasado todas. Y el coste real no está en la red ni en el disco —
está en que el ejecutor **asume trabajo de cómputo y transferencia que pertenece a la capa de
almacenamiento**.

> **LEY DEL EJECUTOR.** Una implementación L2 **NO DEBE** compensar lo que la fuente no sabe
> hacer. O empuja la operación al origen, o la rechaza. **NO DEBE** traer filas para
> filtrarlas, ordenarlas o agregarlas localmente salvo que el binding lo autorice (§5).

Esto parece caro y no lo es, por una razón que ya estaba decidida en otro sitio:

> **El índice convierte escaneos en búsquedas por clave.** La travesía del grafo ocurre en
> local sobre las aristas materializadas, así que **cuando el motor abre una conexión ya sabe
> exactamente qué claves pide.** Por eso puede permitirse no compensar: casi nunca lo
> necesita.

Un motor que compensa está resolviendo, con una máquina que no es la suya y sin el índice que
la fuente sí tiene, un problema que la fuente resolvía mejor. La ley no es purismo: es
negarse a ser un almacén de datos mediocre además de un motor de ontologías.

---

## 3. El plan tiene cuatro fases, y ese orden es normativo

```
① AUTORIZAR   Cedar sobre el principal → poda el plan
② TRAVESÍA    el índice, en local → un conjunto de CLAVES
③ CARGA ÚTIL  una petición por (fuente, entidad), POR CLAVE
④ ENSAMBLAR   sobre flujos ya reducidos
```

El orden **DEBE** ser ese, y no es una preferencia de implementación: **autorizar primero es
lo que impide que la fase ③ pida algo que el principal no puede ver.** Un motor que
autorizase al final habría abierto ya la conexión, y el dato habría salido del origen para
ser descartado después — que es la lectura amplificada de §2 con otro nombre.

De ahí sale la consecuencia más útil de todo el documento:

> **La forma más fuerte de aplicar una máscara es no pedir la columna.**

Una máscara `redact` **NO DEBE** aplicarse como post-proceso: la propiedad **DEBE**
desaparecer de la proyección enviada al origen. Redactar después es haber traído el valor.

Y la otra mitad, que es el eje de las filas. Cedar gobierna **propiedades**; *«compensación
de mi departamento»* es un recorte de filas, y lo declara un **ámbito**
([`v1alpha3/02-ruleset`](../v1alpha3/02-ruleset.md) §4.2) que la política nombra.

**Normativo.** Un ámbito que alcanza a una política que autoriza **DEBE** convertirse en un
**predicado de la petición de la fase ③**, con el valor tomado del atributo del principal que
llegó con la petición. **NO DEBE** aplicarse localmente sobre filas ya traídas.

> **Un ámbito que no se puede empujar al origen rechaza el plan.**

Servir sin el recorte devolvería filas que nadie autorizó. Aplicarlo después las habría
traído igual —y entonces el ámbito habría dejado de ser una salvaguarda para ser un adorno
con coste de cómputo—. Es la ley de §2 otra vez, en el único sitio donde incumplirla no es
caro sino inseguro.

---

## 4. Los dos momentos de aplicación

La política se aplica **dos veces, en dos sitios, contra dos cosas distintas**, y confundirlos
es el error que este apartado existe para impedir.

| | **Emisión** | **Consulta** |
|---|---|---|
| Cuándo | al compilar | por petición |
| Contra qué | el techo del **paquete** | el **principal** que pregunta |
| Qué aplica | los cuatro pasos de la emisión | Cedar y sus máscaras anotadas |
| ¿Consulta quién pregunta? | **no** — por eso es pura | sí |
| Máscaras | **sin sujeto**: al construir el índice | **con sujeto**: por petición |

Y la regla que se deriva:

> **El contrato ya pasó por el conducto. El ejecutor sirve lo que el contrato contiene, y
> nunca más de eso.**

**Normativo.** Una implementación L2 **NO DEBE** volver a filtrar por clasificación ni por
madurez. Esa decisión ya la tomó la emisión, contra `contextSurface`, y **dos puntos de
aplicación se aplican en el más débil de los dos**. Lo que L2 aplica —y solo él— es lo que
depende de quién pregunta.

El corolario vale para cada herramienta que se añada: **toda respuesta se deriva del contrato
emitido, no del paquete.** Una que leyera el paquete podría contar lo que el conducto quitó, y
lo haría sin que nadie lo notase, porque el fallo no tiene aspecto de fallo.

---

## 5. `fullScan` es una autorización, no una descripción

`03-binding` §3.3 presentaba `capabilities` como una descripción de lo que el origen sabe
hacer. Con la ley de §2, `fullScan` deja de describir y pasa a **autorizar**:

| Valor | Qué significa para el planificador |
|---|---|
| `forbidden` | **la negativa.** Un plan que necesite recorrido completo se rechaza |
| `expensive` | **un permiso con coste declarado.** El planificador lo evita, y si no hay alternativa lo ejecuta |
| `cheap` | permiso sin reservas |

La diferencia con «compensar» es **quién decide**. El motor nunca decide traer una tabla
entera: lo decide **el dueño del binding, en código revisable, dentro de un pull request**. Es
la misma figura que gobierna todo lo demás en OOS — la decisión existe, y existe escrita.

### 5.1 · Sin `capabilities`, un binding sirve exactamente una operación

`capabilities` es opcional, y la pregunta que nadie había contestado es qué asume el
planificador cuando falta. La respuesta sale de P4, denegación por defecto, y **no hay que
inventarla**:

> Sin `capabilities` declaradas, un binding sirve **la búsqueda por clave, y nada más.**

No es una limitación arbitraria: es **lo único que se deduce** de que el binding declare un
objeto y cubra la `primaryKey` de su entidad. Cualquier otra operación —un predicado, un
join, una agregación— es una afirmación sobre el origen que nadie ha hecho, y el compilador
no las sondea (`03-binding` §3.3: *las capacidades **DEBEN** declararse, no sondearse*).

Que el caso por defecto sea justo la fase ③ del plan no es casualidad: **el camino principal
funciona sin declarar nada, y las capacidades solo desbloquean lo demás.**

### 5.2 · Las capacidades de lo materializado son las del formato

`capabilities` describe **el origen**. Cuando un binding declara `payload`, el motor tiene un
segundo sitio de donde leer, y ese sitio **no tiene las capacidades del origen: tiene las del
formato en que se materializó**.

**Normativo.** Una implementación L2 **PUEDE** planificar contra lo materializado usando las
capacidades del formato en que lo guarda, y **NO DEBE** exigir que se declaren: son derivables
de una decisión que ya tomó el motor (P2). Lo que **DEBE** es no atribuirlas al origen —
`capabilities` sigue describiendo la fuente, y si lo materializado desaparece, el plan que
dependía de ellas vuelve a ser irrealizable.

Eso es lo que convierte una caché en algo más que velocidad, y está dicho en
[`03-binding`](03-binding.md) §3.1.4: **habilita consultas que la ley de §2 rechazaría contra
el origen.** Y su reverso es la razón de que retirar un eje sea un cambio observable y no una
optimización que se quita sin más.

### 5.3 · Un filtro exigido que nadie mapea hace inconsultable el binding

`requiredFilters` nombra propiedades sin las que el origen no acepta una consulta. Si alguna
no está en el mapeo del binding, **el motor no tiene con qué construir el filtro** y la fuente
nunca podrá consultarse. Es un documento que compila y no sirve para nada, así que falla al
compilar: `OOS2015`.

El mismo código cubre el otro origen del mismo defecto: la `property` de un **ámbito**
(`v1alpha3/02-ruleset` §4.2) que algún binding de esa entidad no mapea. Un requisito de la
fuente y un requisito de la política producen aquí el mismo estado —no hay con qué construir
el filtro—, y **son el mismo defecto**, no dos parecidos.

---

## 6. Credenciales

Un L2 está en el camino del dato por necesidad: si el dato no pasa por él, no puede aplicar la
política, y §4 se convierte en una convención que el consumidor puede olvidar. **Pero estar en
el camino no obliga a ser una caja fuerte de secretos largos**, y este apartado fija la
postura.

### 6.1 · Los atributos del principal no se leen: llegan

**Normativo.** Los atributos que la política evalúa sobre el principal **DEBEN** llegar con la
petición, firmados por la capa de identidad. Una implementación L2 **NO DEBE** resolverlos
contra un binding, y **DEBE** rechazar una petición que no los traiga.

> **Lo que decide el acceso no puede estar sujeto al acceso que decide.**

**Normativo.** Una petición que no satisface el esquema —sin los atributos del principal, sin
`purpose`— **DEBE** rechazarse **antes** de ①. No es una denegación de política: es una
petición que no existe.

Y conviene decir la consecuencia, porque muerde a quien escribe políticas: **una política
escrita para vigilar una petición inválida no vigila nada.** El esquema ya la rechazó, y la
política queda con el aspecto de estar protegiendo algo — un `forbid` contra un agente sin
finalidad declarada es exactamente ese caso el día que la finalidad pasa a ser obligatoria.

La jerarquía es el otro caso, y se resuelve sin leer datos tampoco: `resource in principal`
—la cadena de mando— se responde con el **índice de topología**, que es donde ya viven las
aristas y que se gobernó al construirse. Ninguna de las dos cosas que Cedar necesita para
autorizar exige una lectura gobernada en el camino de autorización, y eso no es casualidad:
es lo que hace que el orden de las fases de §3 se pueda cumplir.

### 6.2 · Credenciales de la fuente

**Normativo.** Una implementación L2 **DEBE** preferir, en este orden, la primera forma que la
fuente admita:

| | Forma | Qué ve la fuente |
|---|---|---|
| 1 | **identidad delegada** — intercambio de token en nombre del principal | **al principal final** |
| 2 | **identidad de carga** — la del proceso, sin secreto en reposo | al motor |
| 3 | **referencia a secreto** — resuelta al conectar, nunca almacenada | al motor |
| 4 | **secreto estático** | al motor |

La primera no es solo más segura: **hace que el control de acceso por filas del origen y la
política del motor sean dos aplicaciones sobre la misma identidad**, y el motor deja de ser el
único muro.

**Normativo.** El proceso que **refresca** lo materializado y el que **responde** consultas
**DEBEN** poder usar identidades distintas. El primero necesita lectura amplia y programada; el
segundo, lectura por clave y por petición. Obligarlos a compartir credencial da al segundo un
permiso que no usa.

**Normativo.** L2 es **solo lectura**. Escribir es L3 y exige una `Function`
([`v1alpha2/02-function`](../v1alpha2/02-function.md)). Una implementación L2 **NO DEBE**
abrir una conexión con permiso de escritura.

> Y conviene decir el argumento completo, porque suele leerse al revés: **la superficie de
> credenciales baja, no sube.** Sin un motor, cada agente, cada aplicación y cada cuaderno
> lleva su propia cadena de conexión a cada fuente, con acceso a tabla completa. Un L2 las
> colapsa a una por fuente y entrega **un contrato en vez de una cadena de conexión**. No se
> añade un almacén de credenciales: se colapsa uno que ya existía y era peor.

---

## 7. Frescura: la marca de agua

`03-binding` §3.2 ya obliga a declarar el estado degradado al superar `freshnessSLA`. Faltaba
**con qué se mide**, y sin eso la promesa de auditoría —*«¿qué sabía el agente el martes a las
14:32?»*— no tiene segundo eje.

```yaml
materialization:
  topology:
    refresh: { every: 15m, strategy: table_version }
    freshnessSLA: 30m
  payload:
    properties: [legalName]
    refresh: { every: 1h, strategy: poll }
    watermark: updated_at      # cuando el formato no versiona
```

**Normativo.**

- Con `strategy: table_version`, la marca de agua **es la versión nativa del formato** —el
  identificador de instantánea de Iceberg, la versión de Delta— y `watermark` **NO DEBE**
  declararse: sería declarar lo derivable (P2).
- Con `cdc` o `poll`, `watermark` **DEBE** declarar la propiedad que ordena el avance. Sin
  ella el refresco no sabe desde dónde continuar y solo puede recargar entero.
- Toda respuesta de un L2 **DEBE** poder acompañarse del digest del bundle y de la marca de
  agua de lo materializado que haya intervenido. Son los dos ejes: **qué significaba** y
  **hasta cuándo era cierto**.
- Si alguna política que intervino en ① **es función del tiempo** —Cedar tiene una extensión
  `datetime`, y una política puede decir *«antes del 1 de enero»*—, la respuesta **DEBE**
  poder acompañarse además del **instante contra el que se autorizó**. Sin él, *«la misma
  pregunta devolvió cosas distintas»* no se distingue de un fallo: tiene el mismo aspecto.

### 7.1 · Refrescar no es reconstruir

Una máscara **sin sujeto** se aplica *al construir el índice*
([`v1alpha3/02-ruleset`](../v1alpha3/02-ruleset.md) §4), así que **queda horneada en lo
materializado**. Cambiarla no se propaga refrescando: el refresco trae filas nuevas y deja
intactas las viejas, que siguen enmascaradas con la regla anterior.

**Normativo.** Cuando cambia una máscara sin sujeto que alcanza a lo materializado, una
implementación **DEBE reconstruirlo**, no refrescarlo. **NO DEBE** servir de lo materializado
valores enmascarados con una regla que ya no está vigente.

Es la clase de fallo que no tiene aspecto de fallo: se refresca, todo sale verde, y lo
materializado sigue sirviendo lo que la máscara nueva prohibiría. Y distingue las dos figuras
de una vez:

> **Refrescar responde a que el dato cambió. Reconstruir responde a que la REGLA cambió.**

---

## 8. Lo que este documento NO decide, y es deliberado

OOS define el artefacto; **cómo se ejecuta es del motor.** Un segundo motor conforme puede
tomar decisiones opuestas a las de la implementación de referencia sin dejar de ser conforme,
y por eso lo siguiente **no** está aquí:

| | Por qué no |
|---|---|
| Qué motor de consulta usar | detalle de implementación; la ley de §2 lo constriñe lo suficiente |
| **Cómo se almacena lo materializado** | la topología quiere lecturas por clave y la caché escaneo columnar. **Son dos problemas distintos y meterlos en el mismo almacén es una decisión que se paga después** — pero es del motor, no del formato |
| De dónde salen los atributos del principal | abierto. Cedar necesita un almacén de entidades; que ese almacén sea la propia ontología es coherente y **todavía no está cerrado** |
| El protocolo de transporte | MCP, GraphQL y el nativo son superficies, no niveles |

---

## 9. Errores

| Código | Condición |
|---|---|
| `OOS2015` | `requiredFilters` nombra una propiedad que el binding no mapea |

Y las condiciones de tiempo de consulta, que **no** son códigos de documento y que una
implementación **DEBE** comunicar como tales:

| Condición | Cuándo |
|---|---|
| **petición inválida** | la petición no satisface el esquema: sin los atributos del principal, sin `purpose`. Se rechaza **antes** de ① |
| **plan rechazado** | el plan exige una operación que las capacidades no autorizan, o un ámbito que no se puede empujar (§2, §3, §5) |
| **estado degradado** | se superó `freshnessSLA` sin refresco (§7) |
| **no autorizado** | la política del principal poda el plan hasta dejarlo vacío (§3 ①) |
| **reconstrucción pendiente** | cambió una máscara sin sujeto y lo materializado aún lleva la anterior (§7.1) |
