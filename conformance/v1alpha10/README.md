# Suite de conformidad — v1alpha10

**Borrador.** Certifica la funcion de [`spec/v1alpha10/`](../../spec/v1alpha10/) —logica
encapsulada que lee, edita o infiere sobre la copia, con su superficie en los dos sentidos— y
el kind nuevo, `Action`. El alcance sigue **abierto** y **no es normativo**.

---

## Por que vive en su propio arbol

Por lo mismo que los demas borradores: un marcador significa *una implementacion de referencia
pasa esto*, y mezclar casos de un borrador con los de v1alpha1 daria un numero que ya no se sabe
que mide. **Los arboles anteriores no se tocan**: la afirmacion que esta version tiene que
sostener es que no cambia un solo resultado de v1alpha1 a v1alpha9.

## Que cubre

Cinco casos que aceptan y diez que rechazan. Se agrupan en cuatro cosas que afirmar:

| | Casos |
|---|---|
| **la superficie tiene dos sentidos, y los dos se declaran** | `a-read-only-function` · `a-function-reads-a-field-over-does-not-expose` · `a-read-that-is-not-a-view` · `a-function-that-touches-nothing` |
| **lo que causa resuelve, en todas las versiones** | `a-function-that-edits-what-it-declares` · `an-effect-on-a-property-that-does-not-exist` · `an-effect-on-an-entity-that-is-not-there` |
| **la accion es la invocacion sin codigo, con exactamente una forma** | `a-declarative-action` · `an-action-that-calls-a-function` · `an-attested-action-without-code` · `an-action-with-both-forms` · `an-action-that-calls-no-function` |
| **el puente con el modelo es la misma funcion; y nada anterior cambia** | `an-inference-over-a-view` · `reads-in-v1alpha9` · `an-action-in-v1alpha9` |

## Los codigos

Uno nuevo: `OOS7014`, la funcion lee lo que no declara. Los demas son de siempre: `OOS1003`
(version), `OOS1004` (forma), `OOS1005` (clave que no es de aqui), `OOS2001` (una funcion que
no esta) y `OOS2005` (una referencia que no resuelve) — este ultimo es el que v1alpha2 §8
decia y el compilador de referencia no hacia sobre `writes`.

## De donde sale

De la medida de ORE `medida-forge-function.py` (2026-09-17): sobre `acme-retail` una funcion
no podia entrar sola (siete escrituras de seis kinds, cuatro sobre donde vive la copia), la
copia habia pasado a decidirse por database y no por vista, y lo que una funcion leia no se
declaraba. Y de comparar con lo que un *action type* hace en una ontologia de objetos, dicho
sobre una ontologia de preguntas: una funcion no recibe objetos, recibe las filas de una vista.
