# 01 · Model — el modelo

**Estado:** borrador. Parte de OOS v1alpha9.
**Anfitrión:** ninguno. Es gramática propia. El vocabulario de `task` es el de las tres
superficies que un modelo servido ofrece (`chat`, `embed`, `rerank`); el de `tier`, las dos
formas de servirlo y cobrarlo.

---

## 1. Naturaleza

> **Un modelo es un documento del árbol que nombra un perfil certificado —máquina × modelo,
> con sus números medidos— y un tier. No lleva un runtime, no lleva recursos, no lleva pesos:
> lleva el nombre de algo que alguien midió y el digest de lo que ese algo sirve.**

Es **un operador dentro del grafo**. Sus salidas —una extracción, un embedding, una
clasificación— son escrituras, y el árbol ya dijo dónde aterriza una escritura: en la
ontología, por la vista, como cualquier efecto de una función. Lo que Databricks Serving (un
endpoint junto a una tabla) y Vertex (un catálogo de APIs ajenas) no tienen, aquí sale de que
el modelo está en el mismo árbol que lo que lee y lo que escribe.

## 2. Qué **no** es

- **No es una configuración.** Ni `runtime`, ni `resources`, ni `weights.repo`: todo eso es
  del perfil, y el perfil lo certifica quien lo mide. Una clave de ésas es `OOS1005`.
- **No lleva significado ni se endosa a sí mismo.** No admite `labels`. Lo que produce llega
  al retículo por los endosos de la función que lo invoca; sin ellos es el mínimo, y
  `OOS7002` lo cobra sobre la función.
- **No es una conexión.** Un modelo propietario por API, con clave del cliente y datos que
  salen, no es un `Model`: es otra cosa, con su excepción de salida explícita, y no está aquí.
- **No tiene `namespace`.** Se direcciona por su nombre desde cualquier paquete
  (`modelo/<nombre>`) y vive en `modelos/` en la raíz, como una función en `functions/`.

## 3. La forma

```yaml
apiVersion: oos.dev/v1alpha9
kind: Model
metadata:
  name: qwen3-235b                 # lo que una Function nombra: modelo/qwen3-235b
  description: …                   # opcional
spec:
  profile: g4/qwen3-235b-fp8       # <máquina>/<modelo>: un perfil certificado, con sus números
  digest: sha256:…                 # opcional hasta que el perfil publique el suyo; lo que corre es esto, o no corre
  tier: shared                     # shared · dedicated
  task: chat                       # chat · embed · rerank
```

| clave | | |
|---|---|---|
| `profile` | **obligatoria** | `<máquina>/<modelo>`: minúsculas, dígitos, `-` y `.`, y exactamente una barra. Que exista en la lista de certificación **no lo comprueba la gramática**: lo comprueba quien escribe el documento (§6) |
| `digest` | opcional | `sha256:<64 hex>`. Los pesos que el perfil sirve, tal como los publica quien los certifica |
| `tier` | **obligatoria** | `shared`: un pod por modelo, se cobra por token · `dedicated`: una máquina para esta celda, precio fijo |
| `task` | **obligatoria** | lo que una función puede pedirle |

## 4. La función que lo invoca

`Function` gana un segundo `runtime`. Con `runtime: model`:

```yaml
apiVersion: oos.dev/v1alpha9
kind: Function
metadata: { name: segmentar, namespace: ventas }
spec:
  runtime: model
  model: modelo/v2-lite            # un nodo del árbol, no una URL ni un id de proveedor
  prompt: "Clasifica la actividad en un segmento de una palabra…"
  effects:
    - writes: ventas.Cliente.segmento
```

- `model` es **obligatoria** con `runtime: model` y **prohibida** con cualquier otro;
  `entrypoint` es de `wasm` y con `runtime: model` sobra. `prompt` sólo con un modelo.
- `model` tiene que resolver a un `Model` del árbol: si no, `OOS2005`, como cualquier
  referencia que no resuelve.
- Todo lo demás de `02-function` (v1alpha2) vale entero: los `effects` son la superficie,
  la propuesta se coteja contra ellos, los endosos deciden la integridad. **Una función con
  un modelo detrás sigue sin aplicar: propone.**

## 5. Las reglas

| | código | |
|---|---|---|
| un modelo sin `profile`, sin `tier` o sin `task` | `OOS1004` | la forma mínima |
| `profile` que no es `<máquina>/<modelo>` | `OOS1004` | |
| `digest` que no es `sha256:<64 hex>` | `OOS1004` | |
| `tier` o `task` fuera del vocabulario | `OOS1004` | una palabra fuera no exige nada en silencio |
| una clave que no es de aquí (`runtime`, `resources`, `weights`…) | `OOS1005` | es del perfil |
| `kind: Model` en v1alpha8 o antes | `OOS1003` | es un documento de v1alpha9 |
| `runtime: model` sin `model`, o con `entrypoint` | `OOS1004` | |
| `model` o `prompt` con otro `runtime` | `OOS1004` | |
| `model` que no resuelve a un `Model` | `OOS2005` | |
| la función escribe una propiedad que exige más integridad de la que alcanza | `OOS7002` | de v1alpha2, y aquí es donde más se ve |

## 6. Lo que la gramática no decide

**Que el perfil exista y esté medido.** Eso es un hecho del sustrato y lo coteja quien
escribe el documento en el árbol —en ORE, `POST /modelos`— contra la lista de certificación
que le dejan, con `422` y el motivo. La gramática admite un `profile` bien formado que nadie
midió, y es a propósito: un árbol tiene que poder leerse sin la lista, y un documento no
caduca porque una lista cambie.
