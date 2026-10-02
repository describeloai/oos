# OOS v1alpha21 · 01 — el dueño

**Normativo.** Las palabras DEBE, NO DEBE y PUEDE se interpretan como en RFC 2119.

## 1. Lo que cambia

`Entity`, `Function`, `ObjectTable` y `Model` ganan una clave en `spec`:

```yaml
apiVersion: oos.dev/v1alpha21
kind: Function
metadata: { name: riesgo, namespace: ventas }
spec:
  owner: user:ana
  runtime: python
  entrypoint: riesgo/funciones/riesgo.py:riesgo
  # …
```

Todo lo demás de los cuatro `kind` es lo de su última versión: `Entity` y `ObjectTable` de
v1alpha16, `Function` de v1alpha20, `Model` de v1alpha15.

## 2. La forma

`spec.owner` es **opcional**. Si está, DEBE ser un handle: `team:` o `user:`, una letra minúscula
y luego minúsculas, dígitos y `-` (`^(team|user):[a-z][a-z0-9-]*$`, como en `Package`). Si no lo es,
`OOS2009`, con el mismo mensaje que en los demás `kind`.

En un documento que declara una versión **anterior** a v1alpha21, `spec.owner` en estos cuatro
`kind` es una clave desconocida: `OOS1005`. La versión dice qué gramática se habla, y la de antes no
tenía esta palabra.

## 3. Lo que significa

`owner` dice **quién responde** del activo: a quién se pregunta por él, quién decide cambiarlo o
retirarlo. Es lo mismo que significa en `Package`, `Schema`, `View`, `Dataset`, `MediaCollection` y
`TrainedModel`, y por eso es la misma palabra.

- **NO DEBE** conceder ni negar acceso. Quién puede leer, escribir o invocar algo lo decide el
  gobierno del flujo y el plano de control; un `owner` que diera permisos sería una segunda
  superficie de autorización escrita en un fichero que cualquiera con commit puede editar.
- **No se hereda.** Un `owner` ausente no es «el del paquete» en ningún análisis de esta
  especificación: es que el documento no lo dice. Una herramienta PUEDE mostrar el del paquete como
  referencia, pero no escribirlo como si fuera el del activo.
- Una herramienta que crea el documento en nombre de alguien DEBERÍA escribir el `owner` de **quien
  lo crea**, y al reescribirlo DEBERÍA conservar el que tenía: editar no es transferir.

## 4. En una función de código

El documento de una función de código se **deriva** de su `@function` (v1alpha18 `01`), y `OOS2013`
dice cuándo el documento no es el que el código da. `owner` **no sale del código**: no es parte de la
firma.

- Una herramienta que regenera el documento DEBE conservar el `owner` que tuviera.
- `OOS2013` NO DEBE comparar `owner`: un documento derivado con `owner` es el que su código da si lo
  demás coincide.
- La versión del documento derivado sigue siendo la más baja que lo describe (v1alpha20 `01` §6):
  v1alpha18 o v1alpha20 sin `owner`, **v1alpha21 con él**.
