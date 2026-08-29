# digest / lock-affects-bundle-digest

**Regla:** [`90-canonical-form.md` §5.3](../../../spec/v1alpha1/90-canonical-form.md) · **Afirmación:** digest de **bundle** distinto

---

**Idéntico código fuente.** Ni un carácter de diferencia en entidades, manifiesto ni
paquete. Lo único que cambia es que `ontology.lock` resuelve `gdpr` a `2.1.4` en `a/` y a
`2.1.5` en `b/`.

Los digests de **paquete** coinciden. Los de **bundle** no:

```
bundleDigest = SHA-256( pkgDigest || versión_OOS || digest_del_lock )
```

## Por qué el lock tiene que entrar

Porque **las dependencias resueltas forman parte del significado**. Importar `gdpr` es
transferir autoridad: la definición de qué es un dato personal no es tuya, y `2.1.5` puede
haber añadido un nivel al retículo o endurecido un conducto.

Si el lock no entrase en el digest, dos artefactos que gobiernan de forma distinta
compartirían identidad. Un auditor que preguntase *«¿qué reglas regían el martes?»* recibiría
un digest que no distingue entre las dos, y **la cadena de procedencia se rompería en el
único eslabón que la organización no controla**.

Es también lo que separa `pkgDigest` de `bundleDigest`, y la razón de que sean dos: el
primero identifica lo que escribiste; el segundo, lo que se ejecuta.
