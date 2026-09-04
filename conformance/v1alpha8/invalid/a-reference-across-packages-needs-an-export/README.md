# v1alpha8 / invalid / a-reference-across-packages-needs-an-export

**Regla:** [`01-package.md` §3.2](../../../../spec/v1alpha1/01-package.md#32--exports--lo-público-y-llega-con-v1alpha8) ·
**Código:** `OOS2028` · **Nivel:** L0

---

**El gemelo de [`valid/a-package-exports-what-others-may-use`](../../valid/a-package-exports-what-others-may-use/),
y difieren en una línea:** allí `infra` declara `exports: [hr.iberia]`; aquí no declara nada.

## Por qué esto no compila

```text
error[OOS2028]: `backedBy: hr.iberia` cruza a `infra`, que no lo exporta
```

**`exports` ausente no significa «todo»: significa nada.** Es P4 — la misma regla con la que un
conducto no listado no autoriza y `reads` ausente es una negativa. Java exporta nada sin `exports`;
Rust es privado por defecto; dbt es `protected`.

## Y por qué NO es `OOS2018`

Porque `hr.iberia` **existe**. Antes de este código, un árbol así compilaba y el problema no
aparecía hasta empaquetar el miembro por separado, donde `OOS2018` decía *«la vista no existe»* —
y existía, en el paquete de al lado. **Un diagnóstico que nombra lo que no es manda a mirar el
fichero equivocado.**

El remedio también es otro, y es lo que separa los dos códigos: `OOS2018` se arregla escribiendo la
vista que falta; este se arregla **en el manifiesto del otro paquete**, o dejando de nombrarla.

## Lo que NO dice

Que un árbol de un solo miembro tenga que declarar nada. La regla solo mira cuando los dos extremos
pertenecen a un miembro y los miembros difieren — que en el corpus son cuatro árboles de casi
trescientos.

Ni se aplica a documentos anteriores a v1alpha8: se escribieron cuando un paquete no tenía
superficie pública, y aplicárselo cambiaría lo que significa algo ya escrito. Es la misma puerta que
`OOS2022`.
