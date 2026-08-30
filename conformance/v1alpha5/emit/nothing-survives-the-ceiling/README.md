# v1alpha5 / emit / nothing-survives-the-ceiling

**Regla:** [`01-emision-graphql.md` §5](../../../../spec/v1alpha5/01-emision-graphql.md#5-cuándo-la-emisión-falla) · **Nivel:** L0

---

El mismo `Diagnosis` del caso anterior, solo. El techo de `contextSurface` es `low` y todas
sus propiedades están en `critical`: **no queda un solo campo, luego no queda un solo tipo.**

La emisión falla, y conviene decir por qué **no** es un error de gobierno: es que
**un SDL sin tipos y sin raíz de consulta no es un documento válido de GraphQL.** El filtro
hizo su trabajo correctamente; lo que no existe es el destino.

## Por qué falla en vez de emitir un esquema vacío

Emitir un fichero que ningún motor puede cargar no es servir menos: es **entregar algo roto
con aspecto de artefacto**. Un fallo explícito dice lo que hay que oír —*este paquete no tiene
nada que servir por este conducto*— y esa frase es accionable: o se sube el techo, o se acepta
que ese paquete no se sirve.

## Sin código de error propio

Como `ossie-requires-binding`. Una emisión imposible es una **expectativa**, no un
diagnóstico sobre el documento: el paquete es perfectamente válido y compila. Lo que no puede
es viajar por este conducto.
