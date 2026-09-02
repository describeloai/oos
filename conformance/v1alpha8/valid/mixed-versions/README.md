# v1alpha8 / valid / mixed-versions

**Regla:** [`00-scope.md` §5.3](../../../../spec/v1alpha8/00-scope.md#53) · **Nivel:** L0

---

**Lo que hace que el retiro del binding no tenga un dia en que todo se rompe.**

`hr.Department` sigue enlazada por un `Binding` que declara `apiVersion: oos.dev/v1alpha1`, y
v1alpha1 es normativo: sigue diciendo lo que decia, asi que sigue compilando. Al lado,
`hr.Employee` ya esta respaldada por una vista sobre una tabla v1alpha8.

Los dos caminos convergen donde ya convergian —en la operacion que resuelve de donde sale un
dato—, que es **una y no dos**. Se migra documento a documento.

Si este caso fallara, la migracion seria un salto, y un salto sobre un arbol grande no se da.
