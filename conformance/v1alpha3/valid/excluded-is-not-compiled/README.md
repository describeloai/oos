# v1alpha3 / valid / excluded-is-not-compiled

**Regla:** [`02-ruleset.md` §2.5.3](../../../../spec/v1alpha3/02-ruleset.md#253--y-por-eso-no-hay-scope-de-miembros) · **Nivel:** L0

---

> **Excluido del workspace es no compilado, luego no gobernado.**

Es el complemento exacto de [`ruleset-governs-every-workspace-member`](../ruleset-governs-every-workspace-member/README.md). Aquel fija hasta dónde llega un
`Ruleset` local —**a todos los miembros**, los importe o no—; este fija dónde deja de llegar,
y no es una excepción del `Ruleset`: es que ahí ya no hay nada compilado.

## El montaje

```
lattices/            critical exige [constraint, authorization]
rulesets/nif.yaml    targets: atLeast high   ·   aporta la ASERCIÓN, no la autorización
packages/ventas/     email: high             ·   cubierto
legacy/              nif:   critical         ·   NO cubierto — le falta `authorization`
workspace.exclude:   [legacy]
```

Compilado, `legacy.Contacto.nif` es `OOS8001`: el `Ruleset` de la raíz lo alcanza —apunta por
clasificación y `critical` está por encima de `high`— y solo aporta una de las dos clases que
`critical` exige. Excluido, el paquete **acepta**.

Quitar la línea `exclude` es todo lo que hace falta para verlo:

```
error[OOS8001]: `legacy.Contacto.nif` exige `authorization` y no lo tiene
```

## Por qué este caso importa más de lo que parece

§2.5.3 se apoya en esta frase para **descartar una funcionalidad**: un `Ruleset` local no
lleva un `scope` de miembros, y una de las dos razones es que *«la exclusión ya existe, y está
un piso más arriba»* — un concepto en vez de dos.

El campo estaba en la gramática desde v1alpha1, en la forma canónica desde `90-canonical-form`
§N-defaults, y **no lo leía nadie**: un directorio excluido compilaba igual. La alternativa
que la especificación descartó por innecesaria no estaba cubierta por lo que puso en su lugar,
y la única forma de enterarse era escribir un `exclude` y comprobar que no excluía.

> Un campo que se declara y nadie lee es peor que uno que no existe, porque promete algo. Y
> este prometía **que algo no se gobierna**, que es la dirección insegura.
