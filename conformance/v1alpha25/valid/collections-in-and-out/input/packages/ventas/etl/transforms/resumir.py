import ore
from ore import transform

CONTRATOS = "ventas.contratos"


@transform(inputs=[ore.collection(CONTRATOS)], output=ore.collection("ventas.resumenes"))
def resumir():
    ...
