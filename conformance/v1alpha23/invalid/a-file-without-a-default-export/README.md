# v1alpha23 / invalid / a-file-without-a-default-export

**Regla:** [`01-la-funcion-de-typescript.md` §2](../../../../spec/v1alpha23/01-la-funcion-de-typescript.md#2) · **Espera:** `OOS2042` · **Nivel:** L0

---

Con `node`, lo que el `entrypoint` nombra es la exportación por defecto. `export function repeat` es un módulo que ofrece `repeat`, y el fichero no tiene `export default function`.
