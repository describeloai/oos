# invalid / binding-leaves-a-relation-without-columns

**Regla:** [`03-binding.md` §2.1](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2011` · **Nivel:** L0

---

El binding mapea `idFactura` y nada más. `ventas.Factura` declara una relación sostenida por
`[idCliente, codPais]`, y ninguna de las dos tiene columna física.

El esquema del binding **ya lo decía** —*«las relaciones no se mapean: unen propiedades, y el
enlace físico sale de mapear la propiedad `via`»*— y nadie lo comprobaba. Salió sondeando si
el vocabulario aguantaba las claves de fuentes distintas: este documento validaba limpio.

Es la figura de siempre. Una relación sin columna física tiene exactamente el mismo aspecto
que una enlazable: se declara igual, se emite igual al SDL, y solo falla cuando alguien
intenta recorrerla — es decir, en L2, lejos del documento que la causó.
