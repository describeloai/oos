// ---------------------------------------------------------------------------
// Políticas de compensación · paquete hr
//
// Cedar es la forma canónica. OOS no define un lenguaje de autorización:
// aporta el vocabulario cerrado de desclasificadores que una anotación
// @obligation puede invocar, y el mapeo determinista del paquete a un
// esquema Cedar (generado en policies/acme.cedarschema).
//
// Las entidades Label:: y Property:: las genera el compilador desde las
// etiquetas del paquete. Nadie las escribe a mano.
//
// Y una frontera que conviene tener delante al leer lo de abajo:
//
//   Cedar gobierna PROPIEDADES. Qué filas ve cada quien es otro eje, y lo
//   declara un ÁMBITO en el Ruleset, que la política nombra con @oosScope.
//
// El recurso se posiciona por PERTENENCIA —`resource in Label::"…"`— y no
// tiene atributos, a propósito: describirlo con atributos obligaría al motor
// a leer el recurso para autorizarlo.
// ---------------------------------------------------------------------------

// Un analista de RRHH lee compensación de su propio departamento, enmascarada,
// y solo para las finalidades declaradas. `context.purpose` es limitación de
// finalidad del RGPD expresada como ABAC estándar de Cedar.
//
// «De su propio departamento» NO cabe en el `when`: sería un predicado sobre
// la fila, y evaluarlo exigiría haberla leído. Se declara como ámbito y el
// ejecutor lo empuja al origen como filtro (`05-ejecutor` §3).
@id("hr-analyst-reads-masked-comp")
@obligation("mask:LAST4")
@oosScope("eu.gdpr-minimization#own-department")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
)
when {
    // `.contains(...)`, no `context.purpose in [...]`: `in` es el operador de
    // JERARQUIA de entidades, y `purpose` es un `String`. La forma con `in` no
    // tipa —lo dijo el validador de Cedar, no una lectura— y llevaba viviendo
    // en este fichero y en un caso de conformidad desde que se escribieron.
    ["compensation_review", "regulatory_reporting"].contains(context.purpose)
};


// Cualquiera puede consultar agregados de compensación, siempre que el grupo
// tenga ocho personas o más.
//
// `aggregate` es un desclasificador: un agregado de >=8 sujetos no identifica
// a ninguno, luego su etiqueta es genuinamente menor y el flujo hacia la
// superficie de contexto pasa a ser legal. Es la razón formal por la que el
// k-anonimato funciona, comprobable en compilación y no por convención.
//
// Esta es la política que hace utilizable a un agente sobre datos sensibles.
@id("workforce-analytics-aggregate-only")
@obligation("aggregate:minGroupSize=8")
permit (
    principal,
    action == Action::"aggregate",
    resource in Label::"gdpr.sensitivity:critical"
)
when {
    context.purpose == "workforce_analytics"
};


// El manager ve sin enmascarar la compensación de quien le reporta.
//
// El ámbito recorta por igualdad —`managerId == principal.employeeId`—, que es
// UN SALTO: lo que un filtro sabe hacer. La cadena de mando entera no es un
// filtro sino una travesía, y la responde el índice de topología en la fase ②,
// no esta política (`05-ejecutor` §6.1).
@id("manager-reads-direct-reports")
@oosScope("eu.gdpr-minimization#direct-reports")
permit (
    principal in Role::"people_manager",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
)
when {
    context.purpose == "compensation_review"
};


// Los identificadores nacionales no salen. De ningún modo y para nadie.
// Un `forbid` de Cedar gana siempre sobre cualquier `permit`, así que ninguna
// política futura puede aflojar esto por descuido.
@id("forbid-national-id-egress")
forbid (
    principal,
    action in [Action::"export", Action::"aggregate"],
    resource == Property::"hr.Employee.nationalId"
);


// ---------------------------------------------------------------------------
// Aquí vivía `forbid-agent-without-purpose`, que prohibía leer sin `purpose`.
//
// Está borrado porque el validador de Cedar lo declaró IMPOSIBLE: `purpose` es
// obligatorio en el esquema desde que el contexto se cerró, así que una
// petición sin finalidad no llega a ser una petición — se rechaza antes de
// autorizar (`05-ejecutor` §6.1). El `forbid` no protegía de nada, y tenía
// exactamente el aspecto de uno que sí.
//
// Se deja escrito en lugar de borrado en silencio: quien vaya a añadir una
// política contra una petición inválida merece saber que el esquema ya la
// rechazó antes.
// ---------------------------------------------------------------------------
