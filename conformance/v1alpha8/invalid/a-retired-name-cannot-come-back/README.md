# v1alpha8 / invalid / a-retired-name-cannot-come-back

**Regla:** [`01-package.md` §3.4](../../../../spec/v1alpha1/01-package.md) ·
**Código:** `OOS2006` · **Nivel:** L0

---

El manifiesto retira un nombre de documento, y el paquete sigue teniendo una vista que lo lleva:

```yaml
spec:
  owner: team:data
  reserved:
    - { name: hr.iberia, reason: se fusiono en hr.empleados }
```

```text
error[OOS2006]: `hr.iberia` está reservado y no puede reutilizarse
```

## Por qué es un error

Es el campo `reserved` de Protobuf, al nivel del documento. Previene *«el fallo más silencioso y
más caro de una ontología viva: una consulta antigua que devuelve una cifra correcta para la
pregunta equivocada»* — y al nivel de documento es peor que al de miembro, porque lo que vuelve no
es un campo: es una pregunta entera con otro significado.

## Y por qué el manifiesto es el único sitio donde cabe

Un nombre retirado **no deja documento donde vivir**. Un `moved` sí tendría superviviente; un
`reserved`, por definición, no. Y los dos son un mecanismo — `ore diff` los une y `OOS5001` no
distingue de cuál vino un nombre—, así que partirlos en dos casas sería peor que cualquiera de las
dos.

## Lo que NO dice

Que reservar un nombre que nunca existió sea un error. No lo es, y es deliberado: reservar mira
hacia delante. Lo mismo vale en la entidad desde v1alpha1.
