# Un log con dos historias no compila

Una firma dice **de quien** es un paquete. No dice si esa clave le ha dicho lo mismo a todo el
mundo, y ninguna comprobacion local puede decirlo: el defecto no esta en lo que tienes, esta en
no poder ver lo que le ensenaron a otro.

Un log de transparencia cierra eso — y **solo si se comprueba que no ha reescrito nada**.

## Por que este caso es asi

El log tiene dos listas de dos entradas que **contienen las dos la del paquete**, con un vecino
distinto. Entonces:

- las dos cabezas estan firmadas por la clave buena del log;
- la prueba de inclusion del paquete **cuadra en las dos**, cada una contra su propia raiz.

Es la forma minima en que un log puede bifurcar sin que se note por inclusion. Con una sola
entrada no valdria: el arbol que la contiene es uno y su raiz tambien, asi que una bifurcacion
de tamano 1 la cazaria la inclusion — y el caso no probaria lo que dice probar.

## Lo que lo delata

`ontology.lock` anoto una cabeza: `treeSize: 2` con una raiz. El paquete trae otra raiz para el
mismo tamano. **Dos raices del mismo tamano son dos historias**, y no hay forma de que las dos
sean ciertas.

Que dos cabezas de tamanos DISTINTOS sean consistentes es otra comprobacion y vive en `ore
lock`, que puede pedirle la prueba al log. Aqui no se toca nada de fuera: compilar es hermetico,
y por eso lo unico que se puede ver sin salir es la contradiccion directa.
