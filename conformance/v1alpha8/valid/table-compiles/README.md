# v1alpha8 / valid / table-compiles

**Regla:** [`01-table.md` §5](../../../../spec/v1alpha8/01-table.md#5) · **Nivel:** L0

---

La forma minima de esta version, y la afirmacion de que **la tabla se sostiene sola**: es el
puntero a un objeto que existe, y existe lo consulte alguien o no. Un catalogo foraneo recien
creado es exactamente esto y nada mas.

`reads` es `capabilities` mudado; `changes` es lo que v1alpha7 decia a medias con
`version.witness` — aquel decia que **fecha** el cambio y no decia que **llega**.

Y `columns`, que es lo unico nuevo de verdad: hasta aqui ningun documento decia que columnas
tenia `public.employees`, y por eso `OOS2018` sobre una vista de fuente no era comprobable.

Cada columna lleva `type` —el escalar de OOS que el conector tradujo— junto a `physicalType`,
la cita del origen. `address` no lleva `type`: el conector no supo traducir `address_t`, lo cita,
y la columna es texto para quien la lea hasta que alguien decida. Los dos casos son validos y
son distintos, y por eso estan los dos.
