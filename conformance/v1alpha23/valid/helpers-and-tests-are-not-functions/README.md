# v1alpha23 / valid / helpers-and-tests-are-not-functions

**Regla:** [`01-la-funcion-de-typescript.md` §3](../../../../spec/v1alpha23/01-la-funcion-de-typescript.md#3) · **Nivel:** L0

---

Solo `repeat.ts` es una función. `unir.ts` no exporta nada por defecto: es un módulo de ayuda. `repeat.test.ts` y `globales.d.ts` nunca son funciones, aunque exporten por defecto. Y `lib/formato.ts` exporta por defecto una función, pero no está en un directorio `functions`.
