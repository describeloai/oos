# v1alpha3 / valid / target-by-name

**Regla:** [`02-ruleset.md` §2](../../../../spec/v1alpha3/02-ruleset.md) · **Código:** `—` · **Nivel:** L0

---

```yaml
targets:
  - named: [hr.Employee.taxId]
```

El **caso enumerado**, y vive aqui —no colgando de la propiedad— por una razon que no es de
gusto: un `Ruleset` tiene `owner`, version y digest propios. El equipo que clasifica un dato
no puede descargarse a si mismo la exigencia que le impuso un paquete de cumplimiento
importado.

> Lo que la propiedad **es** va en la propiedad. Lo que alguien **exige** de ella va donde
> esta quien lo exige.

La primera redaccion **prohibia** este objetivo —*«dos formas de escribir lo mismo acaban con
dos semanticas»*— y con ello obligaba a que el caso enumerado viviera inline. La prohibicion
era autodestructiva: movia el problema y producia las dos formas que queria evitar.

Lo que la desmonta llego despues:

> **`OOS8001` vuelve segura la enumeracion.**

Enumerar se pudre porque una propiedad nueva se escapa **en silencio**. Con la regla de
cobertura, una propiedad clasificada que ningun objetivo alcanza rompe la compilacion. Era el
silencio, no la enumeracion, lo que hacia dano — y el silencio ya no es posible.

Este caso lo demuestra en las dos direcciones a la vez: el objetivo por nombre **selecciona**
y **cuenta** para la cobertura, porque `gdpr.sensitivity` declara `requiresGovernance: high` y
el paquete compila.
