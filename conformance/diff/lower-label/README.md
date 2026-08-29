# diff / lower-label

**Regla:** [`91-versioning.md` §4](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5011`

---

`baseSalary` baja de `critical` a `low`.

**Nadie recibe un error. Ningún consumidor se rompe. Ningún cuadro de mando deja de
funcionar.** Simplemente más gente ve los salarios, y más conductos los admiten.

Es la asimetría que no existe en el versionado de software convencional. En una librería,
añadir capacidad es seguro y quitarla rompe. Aquí hay **dos direcciones opuestas y ambas
rompen**:

```
◀── restringir ─────────────────── relajar ──▶
rompe al CONSUMIDOR                rompe la GOBERNANZA
(deja de poder leer)               (concede acceso en silencio)
```

Un versionado que solo mirase al consumidor clasificaría esto como **compatible** y lo
dejaría pasar como un parche. Por eso los cambios del eje `POLICY` son rompedores **aunque
amplíen capacidades**, y exigen la revisión de los propietarios declarados.

Es el cambio más peligroso que este sistema puede sufrir, y el único que no produce
síntomas.
