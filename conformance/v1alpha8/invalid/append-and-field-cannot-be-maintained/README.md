# v1alpha8 / invalid / append-and-field-cannot-be-maintained

**Regla:** [`02-view.md` §5.4](../../../../spec/v1alpha8/02-view.md#54) · **Codigo:** `OOS2023` ·
**Nivel:** L0

---

**El gemelo de [`valid/append-changes-back-an-event`](../../valid/append-changes-back-an-event/),
y difieren en UN campo.**

La misma tabla, la misma copia, la misma entidad `nature: event`. Alli el testigo es `log`; aqui
es `field`. Nada mas. Que los dos casos se distingan en una linea es el punto: **la regla es sobre
la pareja `(mode, witness)`**, no sobre ninguno de los dos por separado, y un lector que los ponga
uno al lado del otro lo ve sin leer prosa.

## Por que este no compila

`witness: field` fecha por una columna, y **una columna puede tener empates**. Refrescar la copia
es pedir *«lo que hay despues de `T`»*, y con empates en `T` no hay forma buena de escribirlo:

- `ocurrio_en > T` **pierde** las filas que comparten `T` y llegaron despues, para siempre;
- `ocurrio_en >= T` **re-entrega** el borde en cada refresco, y `mode: append` no trae clave con
  la que quitarlo.

`snapshot` y `log` no tienen el problema: nombran una posicion de confirmacion, que es un orden
total. Y `upsert` o `retract` tampoco, aunque fechen por columna: hay clave, asi que la
re-entrega es idempotente.

Queda una sola combinacion sin salida, y es esta.

## Lo que NO dice

Que la tabla sea ilegal. Un registro de eventos fechado por una columna de tiempo es legitimo,
frecuente, y a veces lo unico que el origen sabe ofrecer — quitale `materialized` a la vista y el
paquete compila. **Lo que no se puede es mantener una copia suya.**
