from ore import function


@function
def repetir(texto: str) -> str:
    plantilla = t"hola {texto}"
    return str(plantilla)
