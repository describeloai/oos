from ore import transform


@transform(inputs=["ventas.b"], output="ventas.a")
def a():
    ...


@transform(inputs=["ventas.a"], output="ventas.b")
def b():
    ...
