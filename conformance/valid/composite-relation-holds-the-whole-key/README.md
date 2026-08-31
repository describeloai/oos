# valid / composite-relation-holds-the-whole-key

**Regla:** [`02-entity.md` §6](../../../spec/v1alpha1/02-entity.md) · **Nivel:** L0

---

`Cliente` tiene identidad compuesta —`[id, codPais]`— y `Factura` enlaza contra ella con las
dos propiedades que sostienen el enlace.

Este caso existe porque antes **no se podía escribir**. `via` era un identificador único, así
que una entidad podía declarar una identidad compuesta y ninguna otra podía enlazar contra
ella: el vocabulario admitía el blanco y prohibía la flecha. Un lector contra un PostgreSQL
real encontró la foránea `facturas(id_cliente, cod_pais) → clientes(id, cod_pais)` y no tuvo
dónde ponerla.

**El lado del padre no aparece por ninguna parte, y es deliberado.** `ventas.Cliente` ya
publica su `primaryKey`; escribirla aquí sería declarar lo derivable (P2). R2RML nombra los
dos lados porque no conoce la clave del padre — aquí se conoce.
