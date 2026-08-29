# diff / raise-conduit-clearance

**Regla:** [`91-versioning.md` §5.2](../../../spec/v1alpha1/91-versioning.md) · **Eje:** `POLICY` · **Código:** `OOS5012`

---

`materialization.index` pasa de admitir `low` a admitir `critical`. **Ni una entidad
cambia.**

Es el cambio de una línea con mayor radio de acción de todo el sistema: de golpe, cualquier
binding del repositorio puede materializar cualquier cosa. Todos los `OOS4001` y `OOS4002`
que protegían el paquete dejan de dispararse a la vez, y el diff de código son tres
palabras.

Por eso `conduits.yaml` es el fichero que `CODEOWNERS` reserva al equipo de seguridad, y por
eso este cambio es rompedor en el eje `POLICY` **aunque no rompa a nadie**.
