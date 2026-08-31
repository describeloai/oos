# `ruleset-governs-every-workspace-member`

`eu.nif` vive en `rulesets/` de la raiz. `ventas.Cliente.email` esta clasificada `high`, y
`gdpr.sensitivity` exige `constraint` en ese nivel. **`ventas` no importa nada.**

Y aun asi queda cubierta, porque **la unidad de evaluacion es el workspace**: el manifiesto
raiz declara `workspace: { members }` y eso es lo que se compila.

Es lo que permite gobernar sin pedir permiso a cada paquete — la separacion de funciones que
un equipo de cumplimiento necesita— y su limite esta en el mismo sitio: **un `Ruleset`
alcanza exactamente lo que la compilacion puede ver.** Dentro del workspace, todo; fuera,
nada, porque la compilacion es hermetica y un alcance que dependiera de un registro central
dejaria de ser una funcion del arbol de ficheros.

Este caso existe porque el comportamiento era real y no estaba escrito: se descubrio
quitando el unico `Ruleset` de la ontologia de referencia y viendo romperse una propiedad de
un paquete que no lo importaba.
