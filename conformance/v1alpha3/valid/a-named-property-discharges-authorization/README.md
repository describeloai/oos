# `a-named-property-discharges-authorization`

`Property in [Label, <Entidad>]` son **dos** proyecciones, y una politica puede
apuntar a una propiedad por cualquiera de las dos: por su clasificacion
—`resource in Label::"gdpr.sensitivity:high"`— o **por su nombre**
—`resource == Property::"hr.Employee.taxId"`—.

La cobertura leia solo la primera. Medido sobre la ontologia de referencia, eso
producia esto:

```
error[OOS8001]: `hr.Employee.nationalId` exige `authorization` y no lo tiene
```

…con el `forbid` mas contundente del fichero apuntandole por su nombre. Un
paquete que gobierne **enumerando** no compilaba, y el mensaje le decia que le
faltaba lo que tenia.

Y el defecto tenia una causa concreta: la comprobacion que rompe la compilacion
y la funcion que se expone para el diff eran **dos computaciones distintas** de
la misma cosa — teniendo esta ultima escrito, desde v1alpha3, que *«dos
definiciones de "esta propiedad esta gobernada" serian dos semanticas»*.

El aviso estaba en el sitio correcto, mirando a la funcion equivocada.
