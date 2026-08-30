# v1alpha4 / emit / mapped-property-roundtrip

**Regla:** [`00-scope.md` §8](../../../../spec/v1alpha4/00-scope.md#8) · **Nivel:** L0

---

El gemelo de `mapped-property-emits-what-it-means`, y el que explica por que aquel emite
`x-oos-is`.

```
email: { is: acme.personalEmail }
  → ODCS   { "x-oos-is": "...", "x-oos-type": "String", "x-oos-labels": {...} }
  → OOS    email: { is: acme.personalEmail }
```

## Lo que se juega aqui

Sin `x-oos-is`, la vuelta traeria **el tipo heredado escrito a mano**:

```yaml
email: { type: String, labels: { gdpr.sensitivity: high } }
```

Eso valida, compila y **miente el dia que el concepto cambie**. Seria importar una copia
—que es exactamente el fallo que `OOS4008` y el guardarrail de `is` existen para impedir— por
la puerta de atras de un formato ajeno.

Asi que enriquecer la emision obliga a poder deshacerla. **Una traduccion que no se puede
invertir no es una traduccion: es una perdida.**

## Y por eso el importador borra lo que fundio

Al reconocer `is`, el importador retira `type`, `labels`, `enum` y `description`: no son
suyos, son del concepto. Si el contrato viene de fuera y trae los dos —un `x-oos-is` y un
tipo que no coincide— gana `is`, por lo mismo que el guardarrail prohibe declarar las dos
cosas: **el que sabe que es el dato es el concepto**.
