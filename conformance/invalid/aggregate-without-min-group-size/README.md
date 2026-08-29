# invalid / aggregate-without-min-group-size

**Regla:** [`04-flow.md` §5](../../../spec/v1alpha1/04-flow.md) · **Código:** `OOS4007` · **Nivel:** L0

---

`aggregate` es el desclasificador que hace utilizable a un agente sobre datos críticos: el
salario medio de un departamento de cincuenta personas no identifica a ninguna.

**El de un departamento de una persona sí.**

Sin `minGroupSize` la anotación no desclasifica nada, y aceptarla sería peor que
rechazarla: el paquete compilaría, el agente recibiría respuestas, y todo el mundo creería
que hay una garantía de k-anonimato donde solo hay una palabra.

Es el caso que convierte el k-anonimato de convención en **propiedad demostrable en
compilación** — que es la diferencia entre decir que se protege la privacidad y poder
probarlo sin ejecutar nada.
