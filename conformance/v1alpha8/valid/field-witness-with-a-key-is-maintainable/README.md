# v1alpha8 / valid / field-witness-with-a-key-is-maintainable

**Regla:** [`02-view.md` §5.4](../../../../spec/v1alpha8/02-view.md#54) · **Nivel:** L0

---

**El gemelo positivo de
[`invalid/append-and-field-cannot-be-maintained`](../../invalid/append-and-field-cannot-be-maintained/),
y difieren en la pareja y nada mas.**

La misma tabla, la misma copia, el mismo testigo por columna. Alli `mode: append`; aqui
`mode: upsert` con `key`. Y compila.

## Por que este si

El problema de fechar por columna es que **una columna puede tener empates**, asi que el borde del
refresco es ambiguo: pedir `> T` pierde y pedir `>= T` re-entrega. Con clave, la segunda opcion
deja de ser un problema — **la re-entrega es idempotente**, la clave absorbe las repetidas, y la
copia converge.

Por eso `OOS2023` mira la **pareja** y no el testigo. Sin este caso, el codigo se leeria como si
prohibiera `witness: field`, que es justo lo que no dice: fechar por una columna es legitimo,
frecuente, y a veces lo unico que el origen sabe ofrecer.

## Lo que este caso fija ademas

Que la **marca** del registro sale de `changes.witness` de la tabla y trae **que columna** ordena
el avance. Es la unica forma valida que queda de ver un `Marca::Campo` en la suite.

## Y declara `retention`

Porque este caso va de **mantenerse**, y cuanto guarda el origen su changelog es
la otra mitad de esa pregunta: la clave dice que la re-entrega no duele, y la
retencion dice cuanto se puede tardar en volver. Es ademas el unico caso valido
de la suite que la declara, asi que es el que ejerce esa linea.
