# canonical / n1-name-qualification

**Regla:** [`90-canonical-form.md` §N1](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** convergen

---

`targetEntity: Employee` y `targetEntity: hr.Employee` designan lo mismo desde dentro del
paquete `hr`. La forma canónica expande siempre al nombre completamente cualificado.

Sin esta regla, dos repositorios semánticamente idénticos tendrían digests distintos por una
comodidad de escritura — y con ellos se caería **G1**, la identidad determinista.

Es también la razón por la que la expansión ocurre **antes** de serializar y no durante: el
significado se resuelve primero, los bytes después.
