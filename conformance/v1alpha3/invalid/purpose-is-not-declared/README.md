# `purpose-is-not-declared`

`OOS4005` se habia **retirado** razonando que *«la comprobacion corresponde al validador
de Cedar»*. Se midio, y **Cedar no puede hacerla**: `context.purpose` es un `String`, y un
validador comprueba el **tipo**, no el **valor**.

`context.purpose == "compenstaion_review"` tipa perfectamente. Y no casa con nada.

> **Una politica con una finalidad mal escrita no falla: deja de casar, y el dato queda
> sin gobernar en silencio.**

Un codigo retirado por una razon que resulta falsa se reabre. Lo que no se puede es darle
otro significado, y no se le da: significa exactamente lo que significaba.
