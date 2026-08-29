# canonical / n8-computed-fields-absent

**Regla:** [`90-canonical-form.md` §N8](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** ausencia

---

Único caso de esta tanda que afirma **ausencia** en lugar de convergencia, y por eso su
fichero esperado lista qué **no** debe aparecer.

Al compilar este paquete, el compilador computa que `totalCompensation` es `critical`,
construye su linaje y sabe qué consumidores dependen de `baseSalary`. **Nada de eso entra
en la forma canónica del paquete fuente.**

## Por qué la distinción importa

| | Contiene lo computado |
|---|---|
| Forma canónica del **paquete fuente** | **no** |
| **Bundle** compilado | sí — para eso se compila |

Si lo computado entrase en la forma canónica del fuente, cambiaría el digest del
repositorio cada vez que cambiase una regla de propagación **sin que nadie hubiera tocado
una línea**. Y peor: alguien podría editarlo a mano, y volveríamos a una etiqueta que un
humano puede desincronizar del código — el modo de fallo que P2 existe para eliminar.

Es el mismo razonamiento que hace de `OOS4008` un error: **lo derivable no se declara, y
tampoco se serializa donde se declara.**
