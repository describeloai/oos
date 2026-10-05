from ore import transform, over, write

PEDIDOS = "ventas.pedidos"
PEDIDOS = "ventas.clientes"


@transform(inputs=[PEDIDOS, "ventas.clientes"], output="ventas.resumen")
def resumen():
    """El total por país."""
    return write("ventas.resumen", over(PEDIDOS))
