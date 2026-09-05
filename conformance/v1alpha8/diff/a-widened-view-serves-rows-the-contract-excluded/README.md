# v1alpha8 / diff / a-widened-view-serves-rows-the-contract-excluded

**Regla:** [`91-versioning.md` §5.2](../../../../spec/v1alpha1/91-versioning.md#52--rompedor-en-policy--la-direccion-invertida) ·
**Código:** `OOS5029` · **Nivel:** L0

---

El espejo de [`a-narrowed-view-serves-fewer-rows`](../a-narrowed-view-serves-fewer-rows/):

```yaml
# before                      # after
where: { pais: [ES, PT] }     where: { pais: [ES, PT, FR] }
```

## El veredicto, y es la razón de que sean dos códigos

```
CONSUMER  compatible     nadie deja de recibir nada
POLICY    ROMPEDOR       salen filas que el contrato excluía
```

**Nadie recibe un error.** Simplemente empiezan a servirse francesas por una vista que decía ser
ibérica — y si esa vista está materializada, la copia las contiene. Es *«conceder más en
silencio»*, que [§4](../../../../spec/v1alpha1/91-versioning.md#4-las-dos-direcciones-de-la-ruptura)
llama **el cambio más peligroso que existe en este sistema**.

## Una comparación, dos códigos, dos públicos

Es la tercera vez que el registro toma esta forma —`OOS5009`/`OOS5011` para una etiqueta,
`OOS5012`/`OOS5026` para un conducto— y las tres por lo mismo: **cada dirección le duele a otro**.
El par no existe porque haya dos direcciones observables; existe porque el público cambia con la
dirección.

Un recorte **incomparable** —`false` por `true`, o dos conjuntos que se cruzan— emite **los dos**, y
no hace falta un tercer código: pierde filas y gana filas a la vez.
