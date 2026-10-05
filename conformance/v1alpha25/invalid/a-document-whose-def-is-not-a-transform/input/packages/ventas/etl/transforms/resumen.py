from ore import transform, over, write

PEDIDOS = "ventas.pedidos"


def resumen():
    """El total por país."""
    return write("ventas.resumen", over(PEDIDOS))
