# v1alpha11 / valid / a-trained-model-with-its-lineage

**Regla:** [`01-trained-model.md` 3](../../../../spec/v1alpha11/01-trained-model.md#3) · **Nivel:** L0

---

`ventas.prevision` es la versión 3 de un modelo de sklearn cuyos ficheros están bajo `models/ventas_prevision/v3` del lago, con el digest de su manifiesto, y salió de `ventas.pedidos`. Tiene dueño y está en el paquete que lo entrenó: es un asset del registro como la tabla que `write()` deja, y el catálogo lo lista y la gobernanza baja por `trainedFrom` como baja por `from` en una vista.
