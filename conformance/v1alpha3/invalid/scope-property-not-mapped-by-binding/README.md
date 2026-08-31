# `scope-property-not-mapped-by-binding`

El mismo codigo que un `requiredFilters` sin mapear, y **no es reutilizacion oportunista**:
es el mismo defecto. Un requisito de la **fuente** y un requisito de la **politica** dejan
al motor en el mismo estado — sin con que construir el filtro.

Lo que cambia es la consecuencia. `05-ejecutor` §3 obliga a **rechazar el plan** antes que
servirlo sin recorte, asi que un binding asi deja la entidad inconsultable para toda
politica que nombre ese ambito. Compila, y no se puede consultar nunca.
