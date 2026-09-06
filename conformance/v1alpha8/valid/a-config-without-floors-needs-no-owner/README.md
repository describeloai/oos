# valid / a-config-without-floors-needs-no-owner

**Regla:** [`04-flow.md` §3.3](../../../spec/v1alpha1/04-flow.md) · **Debe:** aceptar · **Nivel:** L0

---

Ningun `datasource` declara `labels`, asi que la configuracion no fija ningun minimo y no
hace falta que nadie responda de el.

Sin este caso, la regla se leeria como *«toda configuracion debe declarar dueno»*, que es
un peaje y no una salvaguarda. El sujeto de la regla no es el documento: es **la decision
de clasificar**, y donde no la hay, la regla no tiene a quien mirar.
