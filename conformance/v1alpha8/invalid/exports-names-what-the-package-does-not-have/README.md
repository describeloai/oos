# v1alpha8 / invalid / exports-names-what-the-package-does-not-have

**Regla:** [`01-package.md` §3.2](../../../../spec/v1alpha1/01-package.md#32--exports--lo-público-y-llega-con-v1alpha8) ·
**Código:** `OOS2027` · **Nivel:** L0

---

El mismo árbol que sus dos gemelos, y aquí la lista **sobra por un nombre**:

```yaml
spec: { owner: team:data, exports: [hr.iberia, hr.no_existe] }
```

`hr.iberia` está y se exporta bien —por eso este caso no dispara también `OOS2028`, y esa es la
razón de que la lista lleve las dos: **un caso, un defecto**—. `hr.no_existe` no está en ninguna
parte.

## Por qué es un error y no un aviso

Exportar lo que no se tiene **es una promesa que nadie puede cumplir**. Un consumidor lee la lista
para saber sobre qué puede construir; un nombre que no resuelve le ofrece un apoyo que no existe, y
lo descubre al escribir la referencia.

## Por qué es un código distinto de `OOS2028`

Por el criterio de `OOS2024`/`OOS2025`: **los remedios son distintos.** Este se arregla en la
**lista** —sobra un nombre, o falta el documento—; el otro, en la **referencia** o en el manifiesto
ajeno. Un solo código mandaría a mirar el fichero equivocado la mitad de las veces.

Y hay un tercer caso que el diagnóstico distingue sin necesitar un código propio: si el nombre
existe pero es **de otro paquete**, la ayuda lo dice — un paquete solo puede exportar lo suyo, y lo
de una dependencia lo exporta ella.
