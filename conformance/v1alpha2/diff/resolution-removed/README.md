# v1alpha2 / diff / resolution-removed

**Regla:** [`91-versioning.md` §4.1](../../../../spec/v1alpha1/91-versioning.md#41) · **Codigo:** `OOS5007` · **Nivel:** L0

---

`crm.dedup` desaparece. Los registros que se fundian dejan de fundirse: **un cliente pasa a
ser dos**, y todo lo que contaba clientes cuenta otra cosa.

`OOS5007` es *«entidad o relacion eliminada»*, de v1alpha1, y se reutiliza por el sintoma: algo
con nombre propio, del que otros dependen, ha dejado de existir. Que sea una entidad, una
relacion, un concepto o una resolucion cambia **quien lo sufre**, no que lo sufra.

Notese la simetria con el caso hermano: bajar el umbral funde **de mas** y retirarla funde
**de menos**. Las dos direcciones rompen, y por eso ninguna puede ser un `patch`.
