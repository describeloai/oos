# diff / harden-conduit-clearance

**Regla:** [`91-versioning.md` §5.1](../../../spec/v1alpha1/91-versioning.md) · **Nivel:** L0

---

El hermano invertido de [`raise-conduit-clearance`](../raise-conduit-clearance). El mismo
paquete, y el conducto va al revés: de `critical` a `low`.

| | Dirección | Eje | Código |
|---|---|---|---|
| `raise-conduit-clearance` | relajar | `POLICY` | `OOS5012` |
| **este** | **restringir** | **`CONSUMER`** | **`OOS5026`** |

## Por qué faltaba, y por qué no era una carencia del registro

`91-versioning` §4 enuncia la ley general dos secciones antes de la tabla:

> ```
> ◀── restringir ──────────────────── relajar ──▶
> rompe al CONSUMIDOR                 rompe la GOBERNANZA
> ```

Y §5.4 listaba *«endurecer un conducto»* entre los cambios **compatibles**. **La tabla
contradecía a la ley que el mismo documento acababa de enunciar**, y no se notó porque
mientras ningún conducto tuvo consumidor, endurecerlo solo restringía materialización,
exportación y log — operaciones internas, sin nadie al otro lado.

`contextSurface` era el único conducto sin consumidor, y la lista de compatibles se escribió
cuando eso era cierto. La cuarta superficie de emisión se lo dio.

## Un solo síntoma, dos causas

Hay dos caminos para que una propiedad deje de ser legible por un conducto, y el registro
emite **un código por síntoma, no por causa**:

```
elevar la etiqueta de la propiedad   →  OOS5009
rebajar el techo del conducto        →  OOS5026
```

Que sean dos códigos y no uno es porque **el sujeto es distinto**: uno habla de una propiedad
y el otro de un conducto, y un diagnóstico que no puede nombrar lo que cambió no sirve para
arreglarlo. Lo que comparten —y esto sí es del síntoma— es el **eje** y el **veredicto**.

## Y por qué se puede añadir sin miedo

Ningún caso de la suite endurecía un conducto: el único que tocaba uno era su hermano, y
relajaba. **El código nace sin poder romper nada**, que es la situación más cómoda posible
para un registro que promete que un código publicado no se reutiliza jamás.
