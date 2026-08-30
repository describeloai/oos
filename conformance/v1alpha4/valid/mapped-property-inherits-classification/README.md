# v1alpha4 / valid / mapped-property-inherits-classification

**Regla:** [`01-significado.md` §4.2](../../../../spec/v1alpha4/01-significado.md#42) · **Nivel:** L0

---

**El caso que decide si toda esta version es real o decorativa.**

`crm.Customer.email` no declara `type`, no declara `labels` y no aparece en ningun
`Ruleset` por nombre. Lo unico que dice es **que es**:

```yaml
email: { is: gdpr.personalEmail }
```

De ahi tiene que salir todo lo demas. El concepto la clasifica `high`, el reticulo exige
gobierno a partir de `high`, y el objetivo por predicado —que no sabe nada de conceptos—
la selecciona **porque la etiqueta heredada es indistinguible de una escrita**.

Esa indistinguibilidad es el diseno entero. `is` no anadio un plano nuevo de analisis: se
enchufo como **tercera fuente de herencia** en la propagacion que ya existia, al lado de la
que baja de la entidad y de la que sube del `datasource`. Si hubiera hecho falta un plano
nuevo, la cobertura habria visto una etiqueta y el flujo otra.
