# `request-policy-without-issuer`

`05-ejecutor` §6.1 exige que los atributos del principal lleguen **firmados** y que se
**verifiquen**. Sin emisor declarado no hay contra que verificarlos, asi que la exigencia
no seria comprobable — y una exigencia que no se puede comprobar tiene exactamente el
mismo aspecto que una que se cumple.

Es forma, no semantica: cabe entero en el esquema, luego `OOS1004`.
