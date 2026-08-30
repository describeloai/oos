# v1alpha3 / canonical / n4-assertions-are-a-set

**Regla:** [`90-canonical-form.md` §N4](../../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** mismas formas canónicas · **Nivel:** L0

---

Las mismas dos aserciones, en dos ordenes. **Convergen**, porque `assertions` es un
conjunto: todas se sostienen y no hay nada que desempatar.

No convergian. `CONJUNTOS` —la lista de N4— **no habia crecido desde v1alpha1**, asi que
todo campo lista anadido despues quedo sin clasificar y se trataba como secuencia. Dos
`Ruleset` que decian exactamente lo mismo producian dos digests, y eso es **G1 rota** en el
plano nuevo: *el mismo commit produce el mismo digest*.

Y la especificacion afirmaba lo contrario —`02-ruleset` §3 dice «`assertions` es un
**conjunto**: N4 lo ordena»—, asi que no era un hueco: era una divergencia entre lo escrito y
lo hecho.

Contrastese con `Resolution.strategies`, que **no** se ordena y no debe ordenarse: alli la
primera que casa gana, y reordenarla cambiaria que registros se fusionan. **La misma regla
trata los dos casos distinto porque los dos casos son distintos.**
