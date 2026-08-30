# v1alpha3 / invalid / empty-target

**Regla:** [`02-ruleset.md` §2](../../../../spec/v1alpha3/02-ruleset.md#2) · **Código:** `OOS8002` · **Nivel:** L0

---

El objetivo pide `high` o por encima y la unica propiedad clasificada es `medium`. El
conjunto seleccionado esta vacio.

Casi nunca significa *«no hay nada asi»*. Significa que alguien escribio mal un nivel, o que
el reticulo cambio y la regla se quedo apuntando a un nombre que ya no existe. **Y una regla
que no gobierna nada tiene exactamente el mismo aspecto que una que funciona**: es el unico
fallo de este documento que no produce ningun sintoma.

Kubernetes tomo la decision contraria —*«un selector de etiquetas vacio casa con todos los
objetos»*—, que es una de sus trampas conocidas. Aqui no hay forma de escribir *«todo»*, y es
a proposito: una regla que gobierna el modelo entero no es gobierno, es una opinion.

El reticulo **no** declara `requiresGovernance`, a proposito: si lo hiciera, `OOS8001`
saltaria antes y el caso no probaria lo que dice probar.
