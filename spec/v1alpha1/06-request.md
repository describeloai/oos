# 06 · `RequestPolicy` — la frontera que faltaba

**Estado:** normativo. Parte de OOS v1alpha1.
**Gobierna:** qué entra con una petición, y quién responde de que sea cierto.

---

## 1. Por qué existe

OOS declara sus fronteras. Todas menos una:

| Frontera | Dónde se declara | Qué dice |
|---|---|---|
| **Entrada de datos** | `datasources` en el manifiesto raíz | de dónde vienen, qué etiqueta heredan, de qué variable sale el secreto |
| **Salida** | [`ConduitPolicy`](04-flow.md) | por dónde salen y hasta qué clasificación |
| **Entrada de identidad** | **nada** | — |

Y la que faltaba es **la única entrada que decide** en lugar de ser gobernada.

> **OOS describió el dato y describió la regla. Nunca describió la petición.**

No es un olvido: **L0 y L1 no tienen peticiones.** La frontera no faltaba — no existía
hasta que [`05-ejecutor`](05-ejecutor.md) puso un principal delante de un dato.

### 1.1 · Las tres cosas que se caían por el hueco, y son la misma

**① La forma del sujeto se tomaba prestada de un recurso.** Sin sitio donde declarar qué
es un principal, `principal: true` ([`02-entity`](02-entity.md) §2.2) la cogía de lo único
que tenía forma cerca: **una entidad de recurso**. El conjunto de atributos del sujeto
pasaba a ser el conjunto de columnas de una tabla gobernada, así que el DNI de un empleado
entraba en el esquema de autorización como atributo **obligatorio** del que pregunta.

> Un atributo del principal es lo que **decide** el acceso. Que ahí entre un dato que el
> acceso protege es exactamente al revés.

Y es la misma ley de `05-ejecutor` §6.1 —*«lo que decide el acceso no puede estar sujeto al
acceso que decide»*— aplicada en la dirección que nadie vigilaba: estaba escrita contra
**leer** los atributos desde un binding, y no contra **derivar su forma** de un dato
gobernado.

**② El emisor de confianza.** `05-ejecutor` §6.1 exige que los atributos lleguen *firmados
por la capa de identidad* y que se verifiquen. **Contra quién** no se declaraba en ninguna
parte, así que la exigencia no era comprobable.

**③ El vocabulario de finalidades.** [`99-errors`](99-errors.md) retiró `OOS4005` —*«política
que referencia una finalidad no declarada»*— razonando que *«la comprobación corresponde al
validador de Cedar»*. **Se midió, y no puede hacerla**: `context.purpose` es un `String`, y
un validador comprueba el **tipo**, no el **valor**. `context.purpose == "compenstaion_review"`
tipa perfectamente y no casa con nada. `OOS4005` se reabre en este documento, que es donde
por fin tiene contra qué comprobar.

Las tres son la misma frontera: **lo que llega con la petición y se cree sin leerlo de
ningún dato.**

---

## 2. La forma

```yaml
apiVersion: oos.dev/v1alpha1
kind: RequestPolicy
metadata: { name: acme-default }
spec:
  owner: team:platform-identity

  issuer:
    url: https://id.acme.example
    audience: ore

  subject:
    entity: hr.Employee          # el TIPO del principal
    claim: employee_id           # la reclamación que lo identifica
    roles: groups                # la que trae sus pertenencias a rol

  claims:
    departmentId: { type: String, from: department_id }
    employeeId:   { type: String, from: employee_id }

  purposes:
    - compensation_review
    - regulatory_reporting
    - workforce_analytics
```

**Normativo.**

- Un paquete **PUEDE** declarar como mucho **un** `RequestPolicy`. Dos serían dos fronteras
  de confianza sin nada que dijera cuál manda.
- `owner` **DEBE** declararse. Es otro equipo: quien opera la identidad no es quien modela
  el dominio ni quien escribe las políticas — la misma razón que hace de
  [`Ruleset`](../v1alpha3/02-ruleset.md) un documento aparte.
- `issuer.url` e `issuer.audience` **DEBEN** declararse. Una implementación L2 **DEBE**
  rechazar una petición cuyo emisor o cuya audiencia no casen.
- `subject.entity` **DEBE** resolver a una entidad `principal: true`; si no, `OOS2005`.
- `subject.roles` **PUEDE** declararse, y nombra la reclamación que trae las pertenencias a
  rol. Sin ella, **un principal no pertenece a ningún rol** y toda política escrita como
  `principal in Role::"…"` deniega — P4, y medido: es exactamente lo que Cedar contesta.
- Si alguna política menciona un `Role::"…"` y **no** se declara `subject.roles`, esa
  política **no puede casar nunca**: `OOS2005`.
- Cada clave de `claims` **DEBE** ser un identificador, y `from` **DEBE** declarar el nombre
  externo de la reclamación cuando difiera.
- `purposes` es un **conjunto no vacío** de identificadores. N4 lo ordena.
- Todos los campos son **cerrados**: una reclamación que no esté en `claims` **NO DEBE**
  llegar al evaluador aunque venga firmada. Es P4 en la entrada — lo que no se declara, no
  se cree.

### 2.0 · Una pertenencia no es un atributo

`claims` declara **atributos**: escalares con tipo. Una pertenencia a rol **no es un
atributo** — es una **arista de padre** en el almacén de entidades, y por eso necesita su
propio campo en lugar de caber en `claims`.

La distinción no es de implementación: es la misma asimetría de
[`02-entity`](02-entity.md) §2.2.1 vista desde el otro lado. Un atributo se **compara**
(`principal.departmentId == …`); una pertenencia se **recorre** (`principal in Role::"…"`,
y `in` en Cedar es alcanzabilidad transitiva). Meter una en el sitio de la otra produce una
política que no casa nunca.

> **Sin `roles` declarado, el único principal expresable es el que no pertenece a nada** —
> y eso convierte en muertas todas las políticas por rol, en silencio.

Por eso no basta con que el campo exista: si una política menciona un `Role::"…"` y nadie
declaró de dónde vienen los roles, es `OOS2005`. La regla de siempre, en el sitio nuevo.

### 2.1 · `claims` sustituye a las propiedades, no las selecciona

**Normativo.** Los atributos del principal que una política puede evaluar son **los de
`claims`, y solo esos**. La proyección a esquema Cedar ([`00-overview`](00-overview.md) §4.1)
**NO DEBE** derivarlos de las propiedades de la entidad.

Es la mitad que cierra ①, y la diferencia no es de tamaño sino de **procedencia**:

| | `hr.Employee.departmentId` | `claims.departmentId` |
|---|---|---|
| Quién lo afirma | la fuente, vía binding | **la capa de identidad, firmado** |
| Cuándo | al leer la fila | **con la petición** |
| Está gobernado por | el retículo y los conductos | nada: **es lo que gobierna** |

Se llaman igual y **no son lo mismo**, y pueden discrepar. Que hasta ahora fueran la misma
declaración es precisamente el defecto.

`principal: true` conserva su otro sentido, que sí es de la entidad: **qué tipo es el
sujeto**, que es lo que da nombre a su UID y permite que la jerarquía del principal
—`principal in Employee::"…"`— tenga tipo. Identidad del sujeto y afirmaciones sobre el
sujeto son dos cosas, y ahora viven en dos sitios.

### 2.2 · Se declara y también se deriva, cada mitad por su razón

Lo tentador era derivar los atributos de las políticas que los usan: da divulgación mínima,
no envejece y es **P2**. No basta, por el mismo argumento que obliga a declarar los niveles
de un retículo:

> **La derivación no detecta una errata, porque la errata pasa a ser la declaración.**

Un `principal.deptId` mal escrito se convertiría en un atributo nuevo, y una finalidad mal
escrita en una finalidad válida. Así que:

- **Se declara la frontera** —quién firma, qué afirma, qué finalidades existen— para que una
  errata falle.
- **Se deriva qué se emite** al esquema: una implementación **PUEDE** proyectar solo las
  reclamaciones que alguna política o algún ámbito referencian.

La primera mitad hace que una errata sea un error. La segunda, que el DNI no viaje en cada
petición. Ninguna sustituye a la otra.

---

## 3. Lo que se toma prestado, y de dónde

Esto no se inventa aquí: es el patrón con el que la industria declara una frontera de
confianza, y conviene decir de dónde sale cada pieza.

| Pieza | De dónde | Qué hace allí |
|---|---|---|
| `issuer.url` | `bound_issuer` de Vault | contra qué se compara el `iss` del token |
| `issuer.audience` | `bound_audiences` de Vault, `aud` de los *ID tokens* de GitLab | el token se acuña **para** un destinatario concreto, y el resto lo rechaza |
| `subject.claim` | `user_claim` de Vault | qué reclamación identifica al sujeto |
| `subject.roles` | `groups_claim` de Vault | qué reclamación trae las pertenencias |
| `claims[].from` | `claim_mappings` de Vault | renombra la reclamación externa a un nombre interno |
| `owner` separado | los *security policy projects* de GitLab | separación de funciones: quien está sujeto a la regla no puede editarla |

La lección de fondo es de Vault y es la que fija el diseño:

> **La frontera de confianza la declara quien confía, no quien emite.** El emisor no puede
> decidir qué se le cree.

Y la de GitLab confirma algo que OOS ya había decidido por su cuenta para `Ruleset`: un
proyecto de políticas de seguridad vive **separado** del proyecto al que gobierna
precisamente para que el equipo gobernado no pueda desactivarlo. Que dos diseños
independientes lleguen a la misma forma es la mejor señal de que la forma es la correcta.

Lo que **no** se toma es `bound_claims` —fijar valores concretos por rol—: eso es
autorización, y aquí la hace Cedar. Este documento declara **qué se cree**; qué se permite
con ello es otra pregunta y tiene su propio lenguaje.

---

## 4. Errores

| Código | Condición |
|---|---|
| `OOS4005` | una política referencia una finalidad que `purposes` no declara |
| `OOS2005` | `subject.entity` no resuelve, o un ámbito compara contra una reclamación inexistente |
| `OOS1004` | `RequestPolicy` sin `owner`, sin `issuer`, sin `subject` o sin `purposes` |

**`OOS4005` se reabre.** Se retiró delegando en el validador de Cedar una comprobación que
Cedar no puede hacer, y el defecto que deja pasar es el de siempre:

> **Una política con una finalidad mal escrita no falla: deja de casar, y el dato queda sin
> gobernar en silencio.**

Un código retirado por una razón que resultó falsa se vuelve a abrir. No es una excepción al
criterio de no inflar familias —**P7**—: es que el criterio se aplicó sobre una premisa
equivocada.

---

## 5. Lo que este documento NO hace

| | Por qué no |
|---|---|
| Emitir tokens | OOS declara qué se cree, no acuña identidades. Eso es del proveedor |
| Fijar valores por rol (`bound_claims`) | es autorización, y la hace Cedar |
| Declarar cómo se rotan las claves | es operación del emisor, y OIDC ya la tiene resuelta |
| Un retículo de finalidades | las finalidades no están ordenadas: ninguna es *más* que otra. Un conjunto, no un retículo |
