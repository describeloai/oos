CREATE OR REPLACE DATASET ventas.resumen AS
SELECT cliente_id, sum(importe) AS total FROM ventas.pedidos GROUP BY cliente_id
