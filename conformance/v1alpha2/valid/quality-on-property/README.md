# v1alpha2 / valid / quality-on-property

**Regla:** [`04-campos.md` §3](../../../../spec/v1alpha2/04-campos.md#3) · **Código:** `—` · **Nivel:** L0

---

```yaml
spec:
  quality:                                  # sobre la entidad entera
    - { id: al-menos-una-fila, metric: rowCount, mustBeGreaterThan: 0 }
  properties:
    baseSalary:
      quality:                              # sobre esta propiedad
        - { id: sin-nulos, metric: nullValues, mustBe: 0 }
```

El cuerpo es `quality` de ODCS v3.1 y no se inventa nada: se adopta la biblioteca de
metricas, los operadores y las dimensiones.

Lo que este caso fija es **el caso enumerado**, que es la mitad que faltaba de la frase:

> Una regla sobre **una** propiedad se escribe donde esta la propiedad. Una regla sobre
> **una clase** de propiedades se escribe donde esta la clase.

La segunda mitad es un `Ruleset` de v1alpha3. No compiten: comparten el cuerpo y difieren en
como se nombra el dominio —escrito aqui, computado alli—, y el guardarrail que impide el
solape es que un `Ruleset` **no admite objetivos por enumeracion**.

`schedule` y `scheduler` de ODCS no se perfilan: ningun planificador. Un documento declara
que debe sostenerse; cuando se comprueba es del motor que lo ejecute.
