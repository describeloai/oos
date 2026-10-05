# 01 · La función propia — fuera de los paquetes, con su versión

**Estado:** borrador. Cambia **dónde vive**, **cómo se llama** y **cómo se versiona** una `Function`.
Lo que no se dice aquí es lo de antes: el contrato (v1alpha1 `01-function`), la derivación del
código (v1alpha18 `01`, v1alpha20 `01`, v1alpha23 `01`) y el dueño (v1alpha21 `01`).

---

## 1. Por qué fuera del paquete

Un paquete es una base: agrupa datos bajo un nombre (v1alpha13 `01`). Una función no es un dato: es
una operación que se llama por su nombre desde SQL, desde código o desde un pipeline. Hasta aquí su
nombre era el de su paquete —`ventas.quoteOrder`— y su versión la de su paquete; las dos cosas
ataban a un contenedor algo que no lo necesita, y la segunda no se cumplía.

## 2. Dónde vive

```yaml
# functions/quoteOrder.yaml, en la raíz del espacio de trabajo
apiVersion: oos.dev/v1alpha26
kind: Function
metadata:
  name: quoteOrder
  version: 1.3.0
  description: El total de un pedido, con su descuento.
spec:
  owner: user:ana
  runtime: node
  entrypoint: packages/ventas/facturacion/functions/quoteOrder.ts
  codeDigest: sha256:9f2c…e41a
  reads: [ventas.default.pedidos]
  input:
    orderId: { type: String, required: true }
    discount: { type: 'Decimal<5, 2>' }
  output: { type: 'Money<EUR, 2>' }
  limits: { timeout: 30s }
```

- El documento está en `functions/<nombre>.yaml`, en la **raíz del espacio de trabajo**, fuera de
  todo paquete. El fichero se llama como `metadata.name`. En otro sitio —dentro de un paquete— es
  `OOS2036`: la identidad no sale de la ruta, pero la ruta tiene que estar de acuerdo.
- `metadata` **no lleva** `namespace` ni `schema`: llevarlos es `OOS1004`.
- `spec.owner` es **obligatorio** (v1alpha21 `01`): fuera de un paquete no hay de quién heredarlo.

## 3. El nombre

- `metadata.name` es un identificador (`[A-Za-z][A-Za-z0-9_]*`) y es **único en el espacio de
  trabajo**, sin distinguir mayúsculas —en SQL son el mismo—: dos `Function` con el mismo nombre son
  `OOS2035`.
- Se llama **`functions.<nombre>`**: en SQL (`functions.quoteOrder(o.id)`), en una referencia de otro
  documento y en un SDK. El `docId` (v1alpha13 `01` §6) es `Function:functions.<nombre>`.
- **`functions` no es el nombre de un paquete** (`OOS2048`): si lo fuera, `functions.x` sería a la vez
  una función y un dato de una base.

## 4. `entrypoint`

La ruta del fichero **desde la raíz del espacio de trabajo**, con `/`, sin `..` ni `/` inicial; con
`runtime: python`, seguida de `:<def>` (v1alpha18 §3); con `runtime: node`, el `.ts` (v1alpha23 §2).
El fichero que no está es `OOS2042`.

## 5. La versión

`metadata.version` es **obligatoria** y es semver. **Nadie la escribe:** la escribe quien deriva el
documento, comparando la función con **su versión anterior** —la del documento de esa función en la
rama principal— por las reglas de v1alpha18 `01` §7:

| lo que cambió | el salto |
|---|---|
| un cambio de `CONSUMER` rompedor (`OOS5001`, `OOS5002`, `OOS5003`, `OOS5010`), o un endoso, un quórum o una precondición (`OOS5011`, `OOS5016`, `OOS5025`) | **mayor** |
| un parámetro opcional, un campo de `output`, `reads`, `models` | **menor** |
| sólo `codeDigest`, `entrypoint`, `limits` o la descripción | **parche** |
| nada | la misma |

- Una función **nueva** nace en `0.1.0`.
- La versión que no llega al salto que exigen los cambios es `OOS5021`, con la función como sujeto.
- **Las ramas no numeran por su cuenta:** la versión se calcula siempre contra la de la rama
  principal. Dos ramas que cambian la misma función cambian el mismo fichero, y la fusión lo dice.

## 6. `codeDigest`

La huella de **lo que corre**: `sha256:` y el hash, en hexadecimal, de, en este orden,

1. los bytes del fichero del `entrypoint`;
2. los del manifiesto de entorno más cercano subiendo desde ese fichero —`pyproject.toml` con
   `runtime: python`, `package.json` con `runtime: node`—, si lo hay;
3. los de su fichero de bloqueo al lado (`uv.lock`, `poetry.lock`, `package-lock.json`), si lo hay;

cada uno precedido por su ruta desde la raíz y un `\n`. Es **derivada**: la que no es la del código
es `OOS2013`, como la firma. Un cambio del cuerpo, de una dependencia o de su resolución es otra
huella y, por §5, un parche.

Quien ejecuta una función en una derivación anclada (una tabla calculada ítem a ítem) **debe**
incluir `codeDigest` en la versión de lo que calcula: otro código con la misma firma es otro
resultado.

## 7. Convivencia con la forma de antes

- Un documento de una versión anterior a v1alpha26 sigue siendo **una función del paquete**, con su
  `namespace`, su nombre `<paquete>.<nombre>` y sin versión propia. No cambia de forma canónica ni de
  digest.
- Un espacio de trabajo puede tener las dos formas. Si una función propia y una del paquete
  comparten `metadata.name`, son dos cosas (`functions.f` y `ventas.f`).
- Migrar es mover el documento a `functions/`, quitar `namespace` y `schema`, rehacer `entrypoint`
  desde la raíz, poner `version` —la del paquete que la contenía— y derivar `codeDigest`.

## 8. Las reglas

| código | cuándo |
|---|---|
| `OOS1004` | una `Function` de v1alpha26 con `metadata.namespace` o `metadata.schema`, o sin `metadata.version`, `spec.owner` o `spec.codeDigest` |
| `OOS2013` | `codeDigest` no es la huella del código |
| `OOS2035` | dos `Function` de v1alpha26 con el mismo `metadata.name`, sin distinguir mayúsculas |
| `OOS2036` | una `Function` de v1alpha26 fuera de `functions/` de la raíz |
| `OOS2042` | el `entrypoint` no está |
| **`OOS2048`** | un `Package` llamado `functions` |
| `OOS5021` | `metadata.version` no llega al salto que exigen los cambios de esa función |

## 9. Lo que la gramática no decide

- **Cuándo se calcula la versión**: una implementación lo hace al guardar en una rama; otra, en la
  fusión. Lo que la gramática fija es contra qué (la rama principal) y con qué reglas.
- **Quién puede llamar a una función**: el control de acceso es de la plataforma.
