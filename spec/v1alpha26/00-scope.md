# OOS v1alpha26 — alcance

**Estado:** borrador de alcance. Gobierna los documentos que declaran su `apiVersion`, y es
**alpha**: sin garantías de compatibilidad.

| | |
|---|---|
| `00-scope` | **este documento** — qué entra, qué no, y por qué |
| [`01-la-funcion-propia`](01-la-funcion-propia.md) | la `Function` **fuera de los paquetes**: su espacio propio (`functions.<nombre>`), **su versión** (`metadata.version`) y **la huella de lo que corre** (`spec.codeDigest`) |

Esta versión **cambia un `kind`** —`Function`— y **añade un código**: `OOS2048` (un paquete no se
puede llamar `functions`). Lo demás que puede fallar ya tiene código: dos funciones con el mismo
nombre son `OOS2035`, el fichero que no está es `OOS2042`, la huella que no es la del código es
`OOS2013`, y la versión que no llega al salto es `OOS5021`, ahora **por función**, y la que vive fuera de `functions/` es `OOS2036`. Los demás `kind`
no cambian.

---

## 1. La tesis

| versión | la función |
|---|---|
| v1alpha1 | un documento **del paquete**: `<paquete>.<nombre>`; su versión, la del paquete |
| v1alpha18 / v1alpha23 | **de código**: el documento se deriva de un `def` o de un `export default` |
| **v1alpha26** | **un activo propio**: no es de ningún paquete, se llama `functions.<nombre>`, **tiene su versión** y dice **qué código corre** |

Dos hechos, medidos en la plataforma que implementa OOS (ORE 0056, 2026-10-04/05), la mueven:

- **Una función no es un dato de una base.** El producto la enseña en su propia sección, sin base ni
  schema, y quien la llama no tiene por qué saber en qué paquete se escribió. Llamarla
  `<paquete>.<nombre>` hacía aparecer como base de datos el sitio donde vive el código.
- **La versión del paquete no versionaba nada.** Ningún commit la comprobaba: un paquete con ocho
  funciones nacidas y cambiadas seguía en `0.1.0`. Y el documento no cambia cuando cambia el cuerpo
  —sólo la firma—, así que una derivación anclada no sabía que el código era otro y no recalculaba.

## 2. Qué entra

- **Dónde vive** (`01` §2): `functions/<nombre>.yaml` en la raíz del espacio de trabajo, fuera de
  todo paquete; sin `namespace` ni `schema`.
- **Cómo se llama** (`01` §3): `functions.<nombre>`, único en el espacio de trabajo. `functions` deja
  de poder ser el nombre de un paquete (`OOS2048`).
- **Su `entrypoint`** (`01` §4): la ruta desde la raíz del espacio de trabajo.
- **Su versión** (`01` §5): `metadata.version`, semver, **calculada** con las reglas de v1alpha18 `01`
  §7 contra la versión anterior de esa función; nadie la escribe.
- **La huella de lo que corre** (`01` §6): `spec.codeDigest`, derivada del fichero y de su entorno.
- **Convivencia** (`01` §7): la forma de antes —en un paquete, con `namespace`— sigue valiendo en las
  versiones de antes.

## 3. Qué no entra

- **Fijar una versión al llamar** (`functions.f@1`): quien llama usa la que hay. Entra cuando se pida.
- **Lo que una función importa de otros ficheros** en la huella: hoy corre un fichero (v1alpha18 §3,
  v1alpha23 §2). Entra con la importación entre ficheros.
- **Versiones de los demás `kind`**: los datos tienen su propia versión de contenido (el snapshot);
  su contrato versionado es otra decisión.
