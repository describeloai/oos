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
// ---------------------------------------------------------------------------

// Un analista de RRHH lee compensación de su propio departamento, enmascarada,
// y solo para las finalidades declaradas. `context.purpose` es limitación de
// finalidad del RGPD expresada como ABAC estándar de Cedar.
@id("hr-analyst-reads-masked-comp")
@obligation("mask:LAST4")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
)
when {
    context.purpose in ["compensation_review", "regulatory_reporting"] &&
    resource.owner.department == principal.department
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


// El manager de la cadena jerárquica ve la compensación sin enmascarar.
// `in` recorre la autorreferencia hr.Employee.manager, que el compilador
// proyecta a la jerarquía de entidades de Cedar: ReBAC sin añadir un
// segundo sistema.
@id("manager-reads-own-chain")
permit (
    principal in Role::"people_manager",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
)
when {
    context.purpose == "compensation_review" &&
    resource.owner in principal.directReports
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


// Un agente autónomo nunca lee compensación sin finalidad declarada.
// Sin este forbid, un agente sin `purpose` caería en la política de agregados
// y obtendría datos que nadie le autorizó explícitamente.
@id("forbid-agent-without-purpose")
forbid (
    principal in Role::"ai_agent",
    action,
    resource in Label::"gdpr.sensitivity:critical"
)
unless {
    context has purpose
};
