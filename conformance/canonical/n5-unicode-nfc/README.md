# canonical / n5-unicode-nfc

**Regla:** [`90-canonical-form.md` §N5](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

Las dos variantes contienen la **misma** descripción —*«Persona con relación laboral en la
compañía»*— con distinta composición Unicode: en `a/` las tildes y la eñe son caracteres
precompuestos (NFC), en `b/` son letra base más diacrítico combinante (NFD).

Los ficheros difieren en bytes. La forma canónica no.

## Por qué este caso es necesario

Es la regla que **perdió su código de error**. `OOS6002` se retiró al comprobar que la
normalización NFC no falla sobre UTF-8 válido: no hay documento que la viole.

Pero la regla sigue siendo normativa, y sin ella un macOS y un Linux podrían producir
digests distintos para el mismo texto — los sistemas de ficheros de Apple normalizan a NFD
y casi todo lo demás a NFC. **Un `git clone` en el portátil equivocado rompería G1.**

Es el ejemplo más claro del principio de esta tanda: *no toda regla normativa se verifica
rechazando algo.* Esta se verifica con un par que converge.
