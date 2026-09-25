# OOS v1alpha15 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — el modelo tiene sitio: vive en un paquete y un schema, como lo que lee y lo que escribe |

Esta versión **cambia un `kind`** —`Model`—: deja de ser vocabulario del árbol, sin
`namespace`, y pasa a ser **contenido gobernado**, con `metadata.namespace` y
`metadata.schema`. No añade códigos: usa los de v1alpha13 (`OOS2030`, `OOS2035`, `OOS2036`,
`OOS2037`) y `OOS2005`. Los demás `kind` no cambian.

---

## 1. La tesis

| versión | verbo | la regla |
|---|---|---|
| v1alpha9 | **razonar** | un modelo que se usa es un documento del árbol, y nombra un perfil medido |
| v1alpha13 | **ordenar** | lo que se tiene se ordena en schemas, y el schema es parte del nombre |
| v1alpha14 | **escribir** | una vista se escribe en SQL; lo que se gobierna de ella se deriva de lo escrito |
| **v1alpha15** | **situar** | **un modelo que se usa es algo que se tiene: vive en un paquete y un schema, y tiene dueño** |

v1alpha9 (`01-model` §2) dejó el modelo **sin `namespace`**: se direccionaba por su nombre desde
cualquier paquete y vivía en `modelos/`, en la raíz, como vocabulario del árbol. Era lo mínimo
para que una función pudiera nombrarlo, y se midió que no basta:

- **El catálogo no lo ve.** Un catálogo de assets se ordena base → schema → ítem (v1alpha13
  §1); un documento fuera de todo paquete no tiene dónde pintarse. En ORE, el índice lo daba con
  `paquete: null` y la consola lo descartaba: el único activo del inquilino que no aparecía.
- **No tiene dueño.** Un modelo desplegado **cuesta** —una máquina encendida mientras sirve— y
  lo usa quien lo nombra. El dueño, el acceso y el coste son del paquete en todo lo demás; en el
  modelo no eran de nadie.
- **Y no es vocabulario.** `gdpr.sensitivity` tiene que significar lo mismo en `hr` y en `crm`,
  y por eso es compartido. Un modelo no: dos equipos pueden desplegar cada uno el suyo con el
  mismo nombre —su `chat`, su `extractor`— y son dos cosas.

## 2. La forma

```yaml
apiVersion: oos.dev/v1alpha15
kind: Model
metadata:
  name: extractor                  # único en su schema
  namespace: ventas                # el paquete, como todo contenido gobernado (OOS2030)
  schema: espana                   # opcional: sin él, `default` (v1alpha13 §3)
  description: …                   # opcional
spec:
  profile: g1/llama-3.1-8b         # lo de v1alpha9, sin cambios
  tier: shared
  task: chat
```

- `metadata.namespace` es **obligatoria**: nombra el paquete donde vive el documento
  (`OOS2030`).
- `metadata.schema` es la de v1alpha13 §3: un schema declarado del paquete, o `default`
  (`OOS2037`), y el documento vive en su carpeta, a cualquier profundidad (`OOS2036`). La
  carpeta `modelos/` es la costumbre, como `views/`: ordena y no nombra.
- `metadata.name` **no lleva puntos** (minúsculas, dígitos, `-` y `_`): el punto separa las
  partes de la referencia (§3). v1alpha9 los admitía porque el nombre era una sola parte.
- `spec` no cambia: todo lo de `01-model` (v1alpha9) §3 vale entero.
- Su identidad es `Model:<paquete>.<schema>.<nombre>`. **Es único por schema**: dos `extractor`
  en `ventas.espana` son `OOS2035`; uno en `ventas.espana` y otro en `ventas.francia`, dos
  modelos.

## 3. La referencia desde una función

`Function.model` sigue siendo `modelo/<referencia>`, y la referencia se lee por su número de
partes, como cualquier referencia a contenido gobernado (v1alpha13 §5):

| partes | se lee | ejemplo, desde una función de `ventas.espana` |
|---|---|---|
| **una** | el mismo paquete y el mismo schema; si ahí no hay, un `Model` de la raíz (§4) | `modelo/extractor` → `ventas.espana.extractor` |
| **dos** | `<paquete>.<nombre>` en el schema `default` | `modelo/ia.chat` → `ia.default.chat` |
| **tres** | el nombre completo | `modelo/ia.nlp.chat` |

Una que no resuelve es `OOS2005`, con el nombre al que se expandió.

## 4. Los modelos de antes

Un `Model` de v1alpha9 a v1alpha14 **no cambia**: sigue sin `namespace`, sigue en `modelos/` en
la raíz, y una referencia de una parte que no encuentra uno en su schema lo encuentra ahí. Lo
que esta versión cambia es dónde se escribe el siguiente. Moverlo a un paquete es reescribirlo
en esta versión —con su `namespace`— y en su carpeta, en el mismo acto.

`namespace` o `schema` en un `Model` de una versión anterior es `OOS1005`.

## 5. Las reglas

| código | la regla | desde |
|---|---|---|
| `OOS2030` | un `Model` de v1alpha15 dentro de un paquete declara ese paquete en `namespace` | v1alpha15 |
| `OOS2036` · `OOS2037` | su schema, como el de todo contenido gobernado | v1alpha15 |
| `OOS2035` | dos `Model` con el mismo nombre en el mismo schema | v1alpha15 |
| `OOS2005` | `Function.model` que no resuelve, leída por partes (§3) | como siempre |
| `OOS1005` | `namespace` o `schema` en un `Model` anterior | v1alpha15 |

## 6. Lo que la gramática no decide

- **Quién puede desplegar en un schema, ni quién paga la máquina**: del plano de control, que
  ahora tiene a quién preguntárselo (el dueño del paquete o del schema).
- **Que el perfil exista y esté medido**: lo de v1alpha9 §6, sin cambios.
- **Quién puede llamar al modelo desde fuera del árbol** —con una clave de la celda, por la
  puerta del gateway—: el sitio del documento gobierna quién lo nombra desde el árbol, no quién
  lo alcanza desde fuera.
