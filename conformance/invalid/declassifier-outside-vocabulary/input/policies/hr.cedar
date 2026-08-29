// `obfuscate` no pertenece al vocabulario cerrado de desclasificadores.
// El conjunto es: mask · tokenize · redact · aggregate · promote
@id("hr-analyst-reads-comp")
@obligation("obfuscate:LIGHT")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
);
