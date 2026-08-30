# v1alpha4 / invalid / unknown-governance-nature

**Regla:** [`02-property.md` §3.3](../../../../spec/v1alpha4/02-property.md#33) · **Codigo:** `OOS1004` · **Nivel:** L0

---

`autorization`, con una `h` de menos. El vocabulario cerrado es `constraint`,
`authorization`, `obligation` y `transformation`.

**Este caso destapa un agujero que ya tenia v1alpha3.** El calculo de cobertura filtra las
naturalezas contra la lista cerrada, asi que una que no reconoce **se descarta**: el paquete
compilaba y la exigencia no exigia nada. Nadie lo validaba — ni en un concepto, que es nuevo,
ni en un reticulo, que lleva desde v1alpha3.

Es `OOS8002` un piso mas arriba, por cuarta vez en esta especificacion:

> Una exigencia que no exige nada tiene **exactamente el mismo aspecto** que una que si.

Se arreglo en los dos sitios a la vez, y anadir el campo nuevo es lo que obligo a mirar el
viejo. Si solo se hubiera validado el nuevo, el de v1alpha3 habria quedado peor **por
comparacion con algo escrito el mismo dia**.
