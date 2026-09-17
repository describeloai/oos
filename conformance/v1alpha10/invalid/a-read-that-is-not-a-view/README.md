# v1alpha10 / invalid / a-read-that-is-not-a-view

**Regla:** [`01-function.md` 5.3](../../../../spec/v1alpha10/01-function.md#53) · **Nivel:** L0

---

La superficie de lectura son vistas: lo que entra en el sandbox es lo que una pregunta expone, con sus etiquetas. Una funcion no lee tablas ni entidades; lee preguntas. `ventas.Cliente` esta bien formado y no es ninguna vista.
