# v1alpha8 / invalid / property-without-a-field

**Regla:** [`02-view.md` §5.3](../../../../spec/v1alpha8/02-view.md#53) · **Código:** `OOS2022` · **Nivel:** L0

---

**La otra cara de haber retirado la federación.**

`Employee` declara `alias` y `empleados` no lo expone. Con bindings esto era legal, y no por
descuido: [`v1alpha1/03-binding` §2.1](../../../../spec/v1alpha1/03-binding.md) decía que una
entidad *«PUEDE tener varios bindings; cada uno cubre un subconjunto de sus propiedades»*. La
cobertura parcial **era el mecanismo**, y preguntar de dónde sale una propiedad no tenía respuesta
local.

Una entidad de v1alpha8 sale de **una** vista. En cuanto no hay otro documento donde mirar, una
propiedad sin campo pasa de *«la cubre otro»* a *«no la cubre nadie»*.

Sin este código, la migración que esta versión pide produce el fallo que este proyecto persigue:
se escribe la vista con la mitad de los campos, la entidad sigue declarando el doble, **compila en
verde**, y las propiedades huérfanas responden vacío para siempre.

Y la regla es **solo de v1alpha8**: un documento anterior declaró su versión, y aquella sí admitía
la cobertura parcial. `conformance/v1alpha7/valid/entity-backed-by-view` es quien vigila esa
puerta — si se quitara, aquel caso se pondría rojo.
