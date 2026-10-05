from ore import transform, over, write

BASE = "ventas"
PEDIDOS = BASE + ".pedidos"


@transform(inputs=[PEDIDOS, "ventas.clientes"], output="ventas.resumen")
def resumen():
    """El total por país."""
    return write("ventas.resumen", over(PEDIDOS))
