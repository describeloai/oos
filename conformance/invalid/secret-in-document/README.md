# invalid / secret-in-document

**Regla:** [`03-binding.md` §2.1](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2012` · **Nivel:** L0

---

Alguien pegó la cadena de conexión entera donde iba el nombre de la tabla. Es el error real
que comete la gente, no uno inventado para el caso.

Importa porque un repositorio ontológico **está pensado para ser publicable**: se revisa en
un pull request, se publica en un registry, se comparte con un auditor. Toda la promesa de
que no contiene secretos se apoya en que la herramienta lo compruebe, no en que el humano
se acuerde.

## Es una heurística, y hay que decirlo

`OOS2012` detecta patrones de cadena de conexión —`esquema://usuario:clave@host`— en
cualquier valor de texto. Eso es **determinista**, que es lo que exige el invariante III, y
**no es completo**: no puede demostrar que un documento no contiene secretos.

Prometer detección exhaustiva sería mentir. Lo que se promete es atrapar el descuido común,
que es donde ocurren casi todas las filtraciones de este tipo.
