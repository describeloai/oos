# 01 · La colección escrita deriva

**Estado:** borrador. Parte de OOS v1alpha19.
**Cambia:** `MediaCollection` (v1alpha16 `02`).

---

## 1. Naturaleza

> **Una `MediaCollection` escrita dice lo que el código leyó para escribirla.**

Es la regla del dataset escrito (v1alpha12 `01` §1, §5) aplicada a los ficheros. Una función que
lee contratos y deja sus páginas como imágenes, o que lee grabaciones y deja sus trozos, escribe
una colección: lo que ésta **lleva puesto** —su clasificación— depende de lo que se leyó, y eso
tiene que estar donde se gobierna, que es el documento.

## 2. La forma

```yaml
apiVersion: oos.dev/v1alpha19
kind: MediaCollection
metadata: { name: paginas, namespace: legal, schema: archivo }
spec:
  owner: team:legal
  media: image
  formats: [png]
  derivedFrom: [legal.archivo.contratos, legal.registro]   # lo que el código leyó para escribirla
```

| clave | forma | |
|---|---|---|
| `derivedFrom` | **escrita** (sin `from`), opcional | lista de nombres cualificados (`<paquete>.<nombre>` o `<paquete>.<schema>.<nombre>`) de **vistas, datasets o colecciones**: lo que el código leyó para escribirla. Cada nombre resuelve (`OOS2018`); no se nombra a sí misma (`OOS2019`) |

- **Quién la escribe**: la herramienta, al confirmar cada transacción de la colección, de la
  procedencia del trabajo —los `inputs` del transform, o lo que la sesión leyó—, como el
  `derivedFrom` de un dataset escrito. Una persona puede corregirla; la siguiente transacción la
  vuelve a escribir.
- **Sin `derivedFrom`**, la colección escrita dice no haber leído nada: lleva sólo sus etiquetas.
- **En una mantenida no existe**: su linaje es `from` (`OOS1004`).
- Lo demás de la forma es el de v1alpha16 `02` §4, sin cambios.

## 3. Gobierno

- **Lo que lleva.** Una colección escrita con `derivedFrom` lleva el *join* de las etiquetas de
  todo lo que nombra: de una vista o un dataset, las de **todos** sus campos (el código no declara
  de qué columna salió cada fichero, igual que no lo declara para una columna, v1alpha12 `01` §5);
  de una colección, las suyas (v1alpha16 `02` §6, y las que a su vez herede).
- **Puede elevar, no rebajar.** Sus `metadata.labels` se suman a lo derivado; una etiqueta por
  debajo de lo derivado en el mismo retículo es `OOS4012`, como en una mantenida respecto de su
  origen.
- **Lo que deriva de ella la lleva**, por las vías de v1alpha17: una vista sobre su listado
  (`04` §3), una tabla anclada a ella (`03` §5) y un dataset escrito que la nombra en su
  `derivedFrom` (§4).
- **No cruza `materialization.payload`**: una escrita no copia de un origen (v1alpha16 `02` §6).

## 4. Para todas las versiones desde v1alpha16: un dataset que deriva de una colección

El `derivedFrom` de un `Dataset` escrito puede nombrar una `MediaCollection`. v1alpha16 `02` §6 lo
daba por hecho («hereda sus etiquetas por `derivedFrom`») y la tabla de v1alpha12 `01` §2 sólo
nombraba vistas y datasets: un nombre de `derivedFrom` resuelve a una **vista, un dataset o una
colección**, y si no, `OOS2018`. El dataset lleva, en cada columna, las etiquetas de la colección.

## 5. Las reglas

| | código | |
|---|---|---|
| `derivedFrom` en una colección mantenida (con `from`) | `OOS1004` | su linaje es `from` |
| `derivedFrom` vacía o con repetidos | `OOS1004` | |
| un nombre de `derivedFrom` que no resuelve a una vista, un dataset o una colección | `OOS2018` | |
| la colección se nombra a sí misma | `OOS2019` | |
| una etiqueta por debajo de lo derivado | `OOS4012` | se eleva, no se rebaja |
| `derivedFrom` en una `MediaCollection` de v1alpha16, v1alpha17 o v1alpha18 | `OOS1005` | es una clave de v1alpha19 |

## 6. Lo que la gramática no decide

- **En qué transacción** se leyó cada entrada: va en el puntero de la colección, con su
  procedencia (§3 de `00-scope`).
- **Cómo** escribe ítems el código (transacciones, subida, idempotencia por digest): contrato de
  ejecución.
