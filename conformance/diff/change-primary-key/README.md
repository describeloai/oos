# diff / change-primary-key

**Regla:** [`91-versioning.md` §5.1 y §5.3](../../../spec/v1alpha1/91-versioning.md) · **Ejes:** `CONSUMER` + `INDEX` · **Códigos:** `OOS5006`, `OOS5018`

---

**Un solo cambio, dos ejes.** Es el caso que enseña para qué sirve evaluar por separado.

| Eje | Veredicto | Consecuencia |
|---|---|---|
| `CONSUMER` | **rompedor** | toda referencia guardada a un `employeeId` deja de resolver |
| `INDEX` | **invalidado** | el índice de topología está construido sobre la clave anterior |

Y las dos consecuencias son de naturaleza distinta: la primera **bloquea el merge**; la
segunda no, pero obliga a señalar que el índice requiere reconstrucción antes de que el
runtime sirva nada.

Un modelo de un solo eje habría tenido que elegir entre bloquear de más o avisar de menos.
