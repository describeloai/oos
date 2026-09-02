# v1alpha8 / invalid / append-changes-back-a-mutable-entity

**Regla:** [`02-view.md` §5.2](../../../../spec/v1alpha8/02-view.md#52) · **Código:** `OOS2021` · **Nivel:** L0

---

**El otro que vale dinero, y el peor modo de fallo de todo el motor: el que no produce ningun
sintoma.**

`app.clicks` solo sabe de altas. `clics` la copia. `Perfil` es `nature: entity` — una cosa que
cambia y sigue siendo la misma. Mantener su estado presente exige poder **quitar** lo que dejo de
ser cierto, y un `append` no puede.

Lo que se obtiene copiando un `append` no es el estado presente: es el historico de lo que llego,
con las filas viejas dentro. La vista se materializa, la consulta responde, los numeros salen —
y son los de antes. Nadie ve nada.

Foundry documenta esta limitacion como una nota. Convertirla en un codigo es la diferencia entre
un compilador y un manual.

El gemelo `valid/append-changes-back-an-event` es la mitad que **si** compila: un hecho ocurrido
no se retira.
