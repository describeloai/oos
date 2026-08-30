# v1alpha3 / diff / assertion-removed-from-a-surviving-ruleset

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md#41) · **Codigo:** `OOS5007` · **Nivel:** L0

---

El `Ruleset` tenia dos aserciones y se queda con una. **La cobertura no cambia**: el hermano
que sobrevive es de la misma naturaleza, asi que `OOS8001` sigue satisfecho y `OOS5023` no
tiene nada que decir.

## El contraste con `weaken-coverage`

Ese caso retira el `Ruleset` **entero** y espera `OOS5023` — su desaparicion se reporta **por
su efecto**, no por si misma, y esa decision se respeta: retirar el documento completo no
emite `OOS5007`, porque serian dos codigos para un cambio en el mismo eje.

Lo que faltaba es mas fino, y es este caso: **una pieza que desaparece de dentro de una regla
que se queda.** Es el hueco exacto que dejaba la vigilancia por efecto — y el mismo motivo por
el que existen `OOS8002` y `OOS9004`:

> Lo que ha dejado de gobernar tiene el mismo aspecto que lo que gobierna.
