# v1alpha2 / valid / expression-declares-what-it-reads

**Regla:** [`04-campos.md` §2](../../../../spec/v1alpha2/04-campos.md#2) · **Código:** `—` · **Nivel:** L0

---

```yaml
totalComp:
  type: Integer
  derivedFrom: [hr.Employee.baseSalary, hr.Employee.bonus]
  expression: "baseSalary + bonus"
```

`expression` **no es un campo nuevo**. Existe en v1alpha1 como prosa documental que no se
interpreta; v1alpha2 le cambia el estatuto —pasa a CEL y a comprobarse— y no le cambia el
nombre. Un `expr` al lado habrian sido dos nombres para un concepto separados por tres
letras, que es el error del endosante otra vez.

Lo que este caso fija es que la comprobacion tiene **una direccion**: `derivedFrom` es
normativo —es lo que propaga las etiquetas— y la expresion se contrasta contra el, nunca al
reves. v1alpha1 ya dio el motivo y no se reabre: *«un analisis de contaminacion solido no
puede depender de parsear cadenas de expresion»*.

Y la propiedad derivada sigue sin declarar `labels`: se computan por `join` sobre lo que
`derivedFrom` declara (`OOS4008`).
