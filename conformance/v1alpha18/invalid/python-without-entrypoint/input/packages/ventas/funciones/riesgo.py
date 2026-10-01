def riesgo(cliente, umbral, moneda="EUR"):
    return {"nivel": "alto" if umbral > 100 else "bajo"}
