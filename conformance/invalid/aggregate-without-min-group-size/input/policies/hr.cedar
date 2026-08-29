// `aggregate` sin minGroupSize: no desclasifica nada.
// El agregado de un grupo de UNA persona es esa persona.
@id("workforce-analytics")
@obligation("aggregate")
permit (
    principal,
    action == Action::"aggregate",
    resource in Label::"gdpr.sensitivity:critical"
);
