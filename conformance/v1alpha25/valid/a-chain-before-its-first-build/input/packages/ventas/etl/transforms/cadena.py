from ore import transform


@transform(inputs=["ventas.pedidos"], output="ventas.limpios")
def limpios():
    ...


@transform(inputs=["ventas.limpios"], output="ventas.totales")
def totales():
    ...
