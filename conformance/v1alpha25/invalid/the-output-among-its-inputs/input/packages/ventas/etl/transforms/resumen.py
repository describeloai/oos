from ore import transform, over, write

PEDIDOS = "ventas.pedidos"


@transform(inputs=[PEDIDOS, "ventas.resumen"], output="ventas.resumen")
def resumen():
    """El total por país."""
    return write("ventas.resumen", over(PEDIDOS))
