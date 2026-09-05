# v1alpha8 / diff / a-view-repointed-to-another-object

**Regla:** [`91-versioning.md` §5.3](../../../../spec/v1alpha1/91-versioning.md#53--rompedor-en-index) ·
**Código:** `OOS5019` · **Nivel:** L0

---

La **tabla** pasa de `public.employees` a `public.workers`. Ninguna vista se toca, y las dos cambian
de raíz.

```json
{ "subject": "hr.empleados", "from": "erp·public.employees", "to": "erp·public.workers" }
{ "subject": "hr.iberia",    "from": "erp·public.employees", "to": "erp·public.workers" }
```

## El sujeto devuelto, y por qué la raíz va resuelta

`OOS5019` —*«cambiar el binding físico de una propiedad indexada»*— es de v1alpha1. Lo que cambia es
de quién se predica: del binding a **la raíz de la cadena, resuelta**.

Resolverla es lo que hace que este caso exista con una sola línea tocada **en la tabla**. Comparar
lo que la vista declara diría que no cambió nada: su `from` sigue diciendo `erp.employees`. Para
quien consume, en cambio, es el mismo hecho que si la vista hubiera repuntado — y es el hecho que
importa: **el artefacto materializado hay que reconstruirlo.**
