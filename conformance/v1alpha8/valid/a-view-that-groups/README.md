# v1alpha8 / valid / a-view-that-groups

**Regla:** [`02-view.md` §5.8](../../../../spec/v1alpha8/02-view.md) · **Nivel:** L0

---

`por_pais` es el primer documento conforme que **no esta en el fragmento invertible**. Hasta
v1alpha8 el vocabulario de `View` era, termino a termino, lo que PostgreSQL admite como vista
auto-actualizable; `groupBy` lo saca de ahi a proposito.

Lo que este caso afirma:

- `count()` no necesita columna, y el paréntesis lo distingue de un nombre;
- `pais` sale de `country`, que **esta** en `groupBy` — sin eso seria `OOS2032`;
- el agregado va con `groupBy` — sin eso seria `OOS2033`.

Y lo que se enciende al aceptarlo, aunque no lo compruebe este caso: el tipo de salida —`count()`
es `Integer`—, el linaje con su arista **INDIRECT** desde la clave de grupo, y el mantenimiento
incremental con un acumulador por grupo.
