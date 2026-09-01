# Una firma que se quita no compila

`02-firma` §5 exige dos cosas, y **esta es la que hace que la otra no se pueda esquivar.**

La primera —una firma que no verifica para el build— se salta borrando el campo: sin firma no
hay nada que verificar, y un paquete sin firmar es legal. Con eso, la comprobacion seria
evitable por quien tuviera algo que ganar evitandola, que es lo mismo que no tenerla.

El ancla no es una declaracion nueva sino **el lock**, que ya existe y ya se revisa en un pull
request. Si dice `signedBy: [oos.dev]`, el arbol tiene que seguir trayendo esa firma.

## Lo que se mide

El `.oob` vendorizado **no lleva `signatures`** y su digest es exactamente el que el lock fija,
asi que `OOS2013` no salta: por contenido, el paquete es el correcto. Lo unico que ha cambiado
es que ya no se sabe de quien es — y eso es precisamente lo que `OOS2016` existe para decir.

Se mide **quitando** el campo y no manipulandolo, porque manipularlo tambien lo cazaria la
primera comprobacion. Un caso que confundiera las dos no probaria esta.
