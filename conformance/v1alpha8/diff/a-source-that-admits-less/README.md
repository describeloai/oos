# v1alpha8 / diff / a-source-that-admits-less

**Regla:** [`91-versioning.md` §5.3](../../../../spec/v1alpha1/91-versioning.md#53--rompedor-en-index) ·
**Código:** `OOS5031` · **Nivel:** L0

---

`fullScan` pasa de `cheap` a `expensive`. **Ninguna consulta se rompe**: lo que cambia es que el
plan cuesta más, o que un predicado deja de bajar.

```json
{ "subject": "hr.empleados", "from": "eq,in·fullScan:cheap", "to": "eq,in·fullScan:expensive" }
{ "subject": "hr.iberia",    "from": "eq,in·fullScan:cheap", "to": "eq,in·fullScan:expensive" }
```

**Las dos vistas de la cadena**, porque a las dos les pasa: el efecto se compara resuelto hasta la
raíz, como todo lo demás del sustrato.

## Por qué informa y no bloquea

Quien publica **no aflojó esto porque quisiera**: lo aflojó porque el origen cambió. `91-versioning`
§5.3 ya lo dice del eje `INDEX` — *«NO DEBEN bloquear el merge por sí solos, pero una implementación
DEBE señalar que el índice requiere reconstrucción»*. Cobrarle un `major` sería cobrarle el clima.

## Y por qué no es el mismo código que `OOS5032`

Por el **remedio**, que es el criterio de `OOS2024`/`OOS2025`: esto se arregla **replanificando**
—empujar menos, o materializar para dejar de depender—. Lo otro no tiene plan que valga.
