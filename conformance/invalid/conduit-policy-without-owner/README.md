# `conduit-policy-without-owner`

`ConduitPolicy` era **el cuarto documento que gobierna y el unico sin `owner`**.
Y no porque no lo tuviera: en la practica el dueño esta escrito en un comentario
o en CODEOWNERS —la ontologia de referencia lo llevaba asi—, y **ninguna de las
dos cosas viaja en el bundle**. Lo que va a una auditoria es el bundle.

> Elevar la autorizacion de un conducto es LA decision de seguridad de este
> modelo. Un techo del que nadie responde es el hueco.

Y tiene una segunda consecuencia, que es la que lo hace valioso: **da dueño a las
politicas de Cedar**, la unica superficie de gobierno que no lo tenia. Quien
eleva la autorizacion de un conducto y quien escribe un `permit` toman la misma
clase de decision —*quien ve que*— y son la misma persona.

Es forma, no semantica: cabe entero en el esquema, luego `OOS1004`.
