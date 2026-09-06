# valid / a-traversal-copies-only-the-key-and-the-link

**Regla:** [`04-flow.md` §4.2](../../../spec/v1alpha1/04-flow.md) · **Debe:** aceptar · **Nivel:** L0

---

`hr.Employee` tiene `nationalId` etiquetada `gdpr.sensitivity: high`, y
`materialization.topology` solo autoriza hasta `low`. **Compila igualmente.**

Y esa es toda la tesis del indice de topologia: recorrer `manager` copia dos columnas
—`employeeId`, la clave, y `managerId`, el enlace—, no la entidad. Que la entidad
contenga campos que no pueden salir del origen no impide atravesarla, porque no salen.

**Una suite que solo probara lo que se rechaza no demostraria nada.** Este caso es el que
impide leer el sello como *«una entidad con datos sensibles no se atraviesa»*, que es
justo lo contrario de lo que dice.

Es el gemelo v1alpha8 de [`valid/index-below-clearance`](../../valid/index-below-clearance),
que afirmaba lo mismo cuando el sujeto era un `Binding` con su eje declarado. Aqui no hay
nada declarado: la copia se **deriva** de `relations` con `via`, porque lo derivable no se
declara (P2), y aun asi se sella.
