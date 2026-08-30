# v1alpha4 / valid / shape-target-reaches-the-subsumed

**Regla:** [`03-interface.md` §4.2](../../../../spec/v1alpha4/03-interface.md#42) · **Nivel:** L0

---

`crm.Staff` declara `implements: [acme.Employee]`. **No nombra `acme.Party` en ninguna
linea.** Y el `Ruleset` que apunta a `implements: [acme.Party]` la alcanza.

```
Party.requires    = {personalEmail, legalName}
Employee.requires = {personalEmail, legalName, employeeId}

Party.requires ⊆ Employee.requires   ⟹   Employee ⊑ Party
```

No hay campo `extends` en ningun sitio, y no lo hay **porque sobraria**: la relacion se
computa de los dos documentos. Declararla seria un segundo sitio donde decir lo que
`requires` ya dice, con la posibilidad de contradecirlo — **P2**.

## Que este caso discrimina

Sin la clausura por subsuncion, el objetivo sobre `Party` **no casaria con nada** y el
paquete fallaria con `OOS8002`. Que este en `valid` es la prueba de que la relacion se
calcula, no de que se ignore.

Y la direccion es la correcta: si una regla se aplica a una forma, aplicarla tambien a una
forma **mas exigente** es lo que tiene que pasar. Una regla que dejara de aplicarse cuando la
entidad tiene *mas* de lo que se pide seria un defecto — es la monotonia de `atLeast`, un
nivel por encima.

## Lo que la disciplina ya habia contestado

En OWL, una clase con condiciones **necesarias y suficientes** es una *clase definida*, y un
razonador **computa** su lugar en la jerarquia; la jerarquia asertada se reserva para las
clases *primitivas*, cuya pertenencia no se puede calcular. Un `Interface` es una clase
definida por construccion: `requires` es exactamente una condicion necesaria y suficiente de
la forma.

Go llego a lo mismo desde el otro extremo de la informatica: sin palabra clave, por inclusion
de conjuntos de metodos.
