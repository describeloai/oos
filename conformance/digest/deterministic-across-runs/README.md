# digest / deterministic-across-runs

**Regla:** [`90-canonical-form.md` §2](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** `stable`

---

Un único paquete. El ejecutor lo compila varias veces y **todos los digests deben
coincidir**.

Es la verificación de la **pureza de la compilación** —invariante III— que dejó de tener
código de error: `OOS6001` se retiró al comprobar que ningún documento puede contener un
reloj. La regla no desapareció; cambió de forma.

Lo que atrapa es un compilador que introduzca un reloj, un número aleatorio, el orden de
iteración de un mapa hash o una variable de entorno en el artefacto. **Ninguno de esos
fallos produce un error: producen un digest distinto cada martes**, y quien lo descubre lo
hace cuando una firma deja de validar en producción.

Un ejecutor **DEBERÍA** además compilar en dos directorios de trabajo distintos, para
atrapar rutas absolutas filtradas al artefacto.
