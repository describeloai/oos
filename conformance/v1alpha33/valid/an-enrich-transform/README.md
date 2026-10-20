# v1alpha33 / valid / an-enrich-transform

**Regla:** [`01-enrich.md` §6](../../../../spec/v1alpha33/01-enrich.md#6) · **Espera:** `accept` · **Nivel:** L0

---

Un documento del `.enrich.yaml` es un `Transform` con `runtime: enrich` y `entrypoint: <ruta>.enrich.yaml:1`; sus entradas, el objetivo y luego las capas sin repetir. Todo en `EPSG:25830`, que mide en metros.
