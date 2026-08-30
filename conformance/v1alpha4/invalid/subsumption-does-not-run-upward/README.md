# v1alpha4 / invalid / subsumption-does-not-run-upward

**Regla:** [`03-interface.md` §4.2](../../../../spec/v1alpha4/03-interface.md#42) · **Codigo:** `OOS8002` · **Nivel:** L0

---

El gemelo del anterior, con la flecha girada. `crm.Contact` implementa `acme.Party` —la forma
**laxa**— y la regla apunta a `acme.Employee` —la **exigente**—.

```
Employee.requires ⊄ Party.requires        (falta `acme.employeeId`)
```

Luego `Party ⋢ Employee`, la seleccion es vacia y sale `OOS8002`.

**La inclusion de conjuntos no es simetrica, y ese es todo el contenido del caso.** Un
mecanismo de subsuncion que corriera en las dos direcciones daria por gobernado lo que nadie
gobierna, que es el sentido inseguro del error — el mismo que ya hubo que corregir en la
cobertura por orden de reticulo.

Y el codigo es el correcto: la interfaz **existe**, asi que no es `OOS2001`. Lo que pasa es
que no casa con ninguna entidad, y eso es una errata o un modelo que cambio. Distinguir los
dos fallos es la razon de que toda interfaz declarada figure en el indice de formas aunque
nadie la implemente.
