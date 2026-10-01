import functools


def registrada(f):
    return f


@registrada
def riesgo(cliente: dict, *, umbral: float) -> dict:
    return {"nivel": "alto"}
