from ore import transform, sql, write


@transform(inputs=["ventas_vivo.ventas.clientes"], output="ventas_vivo.ventas.copia")
def copia():
    return write("ventas_vivo.ventas.copia", sql("select id, pais from ventas_vivo.ventas.clientes"))
