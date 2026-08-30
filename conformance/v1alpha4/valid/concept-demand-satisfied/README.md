# v1alpha4 / valid / concept-demand-satisfied

**Regla:** [`02-property.md` §3.3](../../../../spec/v1alpha4/02-property.md#33) · **Nivel:** L0

---

El gemelo de `invalid/concept-demands-governance`, con la politica puesta.

Importa por lo que **no** hizo falta cambiar: la politica es una politica de Cedar normal,
apunta a una etiqueta como cualquier otra, y descarga la exigencia por la via de siempre. El
tercer origen cambia **quien pide**, no **como se paga**.

## La direccion, que es lo que lo hace seguro

Un concepto solo puede exigir **mas**. Sin `requiresGovernance` no exige nada; con el, anade.
**No hay forma de descargar una obligacion desde aqui** — y esa asimetria es la que impide
que importar vocabulario laxo afloje una exigencia local.

Si un concepto pudiera decir *«a mi no me hace falta autorizacion»*, importar el paquete
equivocado seria la manera de escaparse de la clasificacion propia. Es el mismo razonamiento
que hizo que la composicion entre reticulos fuera **conjuncion y no disyuncion**.
