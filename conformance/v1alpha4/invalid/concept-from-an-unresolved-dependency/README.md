# v1alpha4 / invalid / concept-from-an-unresolved-dependency

**Regla:** [`02-property.md` §7](../../../../spec/v1alpha4/02-property.md#7) · **Codigo:** `OOS2001` · **Nivel:** L0

---

El gemelo de `concept-from-another-package`, con el paquete `gdpr` retirado del arbol.
`ontology.config.yaml` sigue declarando la dependencia y `ontology.lock` sigue fijandola.

**No basta.** `is: gdpr.personalEmail` no resuelve, y el paquete no compila.

> Declarar una dependencia no conjura lo que publica. La resolucion es **por presencia**, no
> por declaracion.

Y esa direccion es la correcta: de los dos errores posibles, este es el reversible. Aceptar
un `is` a un concepto que nadie ha visto por el hecho de que alguien escribio una linea en un
fichero de configuracion seria heredar un tipo y una clasificacion **imaginarios** — y toda
la maquinaria de flujo y de gobierno correria encima de ellos.

## Por que el mensaje importa aqui mas que en otros sitios

El diagnostico dice donde mirar:

> *un concepto es un documento `Concept`, propio o importado. Si lo publica una dependencia,
> comprueba que este en `ontology.config.yaml` y fijada en el lock*

En un `is` que no resuelve hay dos causas muy distintas —una errata, o una dependencia que no
esta materializada— y la segunda no se arregla mirando el fichero donde salta el error. Un
codigo compartido con un mensaje que no distingue las dos habria mandado a quien lo lee al
sitio equivocado.
