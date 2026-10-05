from ore import transform


@transform(inputs=["ventas.pedidos"], output="ventas.clientes")
def pisar():
    ...
