# diff / raise-label

**Regla:** [`91-versioning.md` §4.1](../../../spec/v1alpha1/91-versioning.md) · **Código:** `OOS5009`

---

**Este es el caso que demuestra que los ejes no son academicismo.** El mismo cambio —subir
`baseSalary` de `high` a `critical`— recibe dos veredictos **opuestos**:

| Eje | Veredicto | Por qué |
|---|---|---|
| `POLICY` | **compatible** | la gobernanza se endurece. Nadie ve más de lo que veía |
| `CONSUMER` | **rompedor** | quien leía el valor ahora lo recibe enmascarado, o no lo recibe |

Sin ejes separados habría que elegir uno de los dos y **mentir en el otro**. Un versionado
que solo mirase a la gobernanza marcaría esto como parche y rompería un cuadro de mando en
producción; uno que solo mirase al consumidor desincentivaría endurecer la clasificación,
que es exactamente lo que se quiere fomentar.

Y obsérvese el par: [`lower-label`](../lower-label/) es el mismo cambio en sentido
contrario, y sus dos veredictos también se invierten.
