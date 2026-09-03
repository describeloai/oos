# `datasourceRef` en un efecto, bajo v1alpha8

Hasta v1alpha7 un efecto declaraba **dos** cosas: `writes`, la propiedad que toca, y
`datasourceRef`, la fuente donde cae. En v1alpha8 la segunda sobra, porque el camino ya existe:

```text
entidad  →  backedBy  →  vista  →  raíz  →  tabla  →  datasource
```

Declararla sería un segundo sitio que puede discrepar del primero. `writes` **se queda tal cual**:
nombrar la propiedad es correcto, porque es el idioma de la ontología y la ontología no debe saber
en qué columna cae.

Se rechaza con `OOS1005` —clave desconocida—, y el mensaje dice que se borre. Bajo
`oos.dev/v1alpha2` el mismo campo sigue siendo obligatorio: un documento no caduca por haber sido
escrito antes. Es el trato que recibió `kind: Binding`, por la misma razón.
