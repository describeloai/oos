# v1alpha25 / valid / a-java-class-with-two-transforms

**Regla:** [`01-transform.md` §5.5](../../../../spec/v1alpha25/01-transform.md#5) · **Nivel:** L0

---

`import ore.*;` hace de `@Transform` la anotación de ORE, y `@ore.Transform` lo es siempre. `inputs` con un solo valor va sin llaves, como Java lo admite; `Pedidos.CLIENTES` es la constante nombrada por su clase. Lo que hay en el comentario y en la cadena no es una anotación, y el método sin anotar no es un transform: el fichero da dos documentos, sin descripción (no hay Javadoc).
