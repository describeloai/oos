# diff / remove-entity

**Regla:** [`91-versioning.md` §5.1 y §6](../../../spec/v1alpha1/91-versioning.md) · **Ejes:** `CONSUMER` + `PACKAGE` · **Códigos:** `OOS5007`, `OOS5022`

---

`hr.Contractor` desaparece. El paquete declara
`sla.breakingChangePolicy.noticePeriod: 90d`.

Dos códigos, una sola causa, y son cosas distintas:

| Código | Qué dice |
|---|---|
| `OOS5007` | **es** un cambio rompedor |
| `OOS5022` | y llega **sin el aviso que este paquete prometió** |

La segunda es la que convierte el SLA de documentación en obligación. `noticePeriod` es el
**único campo del SLA que se tipa** —todo lo demás viaja como `slaProperty` genérica sin
interpretar— precisamente porque es el único que el compilador hace cumplir.

La salida correcta es marcar la entidad `DEPRECATED` con fecha, dejar pasar la ventana y
retirarla después. Entonces `OOS5007` sigue apareciendo, `OOS5022` no, y el consumidor ha
tenido tres meses para reaccionar.
