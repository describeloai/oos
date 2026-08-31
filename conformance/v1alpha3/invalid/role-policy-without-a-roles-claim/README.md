# `role-policy-without-a-roles-claim`

Una pertenencia a rol **no es un atributo**. Un atributo se **compara**
—`principal.departmentId == ...`— y una pertenencia se **recorre**
—`principal in Role::"analyst"`, y `in` en Cedar es alcanzabilidad transitiva—.
Son una **arista de padre** en el almacen de entidades, no un escalar, asi que no
caben en `claims`: las declara `subject.roles`.

Sin ella, el principal no pertenece a nada y la politica **no casa nunca**. Esta
medido, no deducido: la misma peticion devuelve `Allow` con el rol y `Deny` sin
el.

Y deniega **en silencio**, que es la forma de fallo de siempre — una politica que
no gobierna tiene exactamente el mismo aspecto que una que gobierna.

## Por que solo aplica con un principal de entidad

Sin ninguna entidad `principal: true`, el unico principal expresable es `Role`, y
entonces **la pertenencia es la identidad**: `Role::"analyst" in Role::"analyst"`
es cierto por reflexividad. Ese es el RBAC degenerado que v1alpha1 siempre
admitio, y ahi no falta nada.

La reclamacion hace falta justo cuando el sujeto deja de ser el rol.
