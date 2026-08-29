# invalid / undeclared-datasource

**Regla:** [`03-binding.md` §2.1](../../../spec/v1alpha1/03-binding.md) · **Código:** `OOS2004` · **Nivel:** L0

---

El binding pide `hr_warehouse`; el manifiesto declara `hr_db`.

Tiene código propio en vez de caer en la referencia genérica porque **un datasource no
declarado rompe dos cosas a la vez**: no hay `connectionEnv` del que sacar la credencial, y
no hay `labels` de los que heredar. Lo segundo es lo grave — sin ellas, todo lo enlazado a
esa fuente quedaría sin la residencia ni el suelo de sensibilidad que le correspondían, y
el análisis de flujo daría un resultado optimista sobre un paquete que ni siquiera puede
conectarse.
