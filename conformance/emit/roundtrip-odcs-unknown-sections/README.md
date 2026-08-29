# emit / roundtrip-odcs-unknown-sections

**Regla:** [`01-package.md` §4.3](../../../spec/v1alpha1/01-package.md) · **Afirmación:** `ODCS → OOS → ODCS` es la identidad · **Formato:** ODCS v3.1.0

---

La dirección contraria: un contrato ODCS **nativo** entra, se convierte en paquete OOS y
vuelve a salir. Debe salir idéntico.

Lleva a propósito dos campos que el perfil **no interpreta**:

| Campo | Por qué está aquí |
|---|---|
| `price` | el precio de un producto de datos no es asunto de un artefacto de gobernanza |
| `contractCreatedTs` | **OOS nunca lo escribe** —el invariante III prohíbe el reloj— pero si viene, se conserva |

Es la prueba de la **superficie de transporte**: lo que OOS no valida ni entiende viaja
literalmente, sin interpretarse y sin perderse.

Sin esa garantía, adoptar OOS obligaría a abandonar información que el contrato original ya
tenía, y ningún equipo con contratos en producción lo haría. **La ida y vuelta sin pérdida
no es elegancia: es la condición para poder entrar sin tirar nada.**
