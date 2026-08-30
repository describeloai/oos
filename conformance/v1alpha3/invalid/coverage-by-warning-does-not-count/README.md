# v1alpha3 / invalid / coverage-by-warning-does-not-count

**Regla:** [`02-ruleset.md` §6](../../../../spec/v1alpha3/02-ruleset.md#6) · **Código:** `OOS8001` · **Nivel:** L0

---

Hay un `Ruleset`, apunta bien, y el objetivo **no esta vacio**: casa con `taxId`. Aun asi
falla, y este es el caso que hace normativa la regla de §6.

```yaml
severity: warning
```

Un aviso es, por definicion, *«lo vimos y no paramos nada»*. Si contara para la cobertura,
`OOS8001` se satisfaria con una regla que no para nada y **la cobertura pasaria a medir que
alguien escribio un fichero**.

No es un caso academico: es el modo de fallo mas probable de todo v1alpha3, porque es el que
aparece en cuanto alguien tiene prisa por poner verde una compilacion. Un unico caracter
—`warning` en vez de `error`— convierte el gobierno en decorado, y sin este caso la
implementacion mas natural lo aceptaria.

Lo mismo vale, por el otro motivo de la regla, para `type: text` y `type: custom`: se
transportan sin interpretar, luego el compilador no sabe que afirman.
