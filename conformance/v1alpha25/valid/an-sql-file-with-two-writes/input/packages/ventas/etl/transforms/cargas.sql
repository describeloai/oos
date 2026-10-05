-- lo que no escribe no es un transform
SELECT count(*) FROM ventas.pedidos;

CREATE OR REPLACE DATASET ventas.por_cliente AS
SELECT cliente_id, sum(importe) AS total FROM ventas.pedidos GROUP BY cliente_id;

INSERT INTO ventas.historico
SELECT p.pedido_id, c.pais FROM ventas.clientes c JOIN ventas.pedidos p USING (cliente_id);
