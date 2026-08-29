@id("workforce-analytics")
@obligation("aggregate:minGroupSize=8")
permit (
    principal,
    action == Action::"aggregate",
    resource in Label::"gdpr.sensitivity:critical"
) when { context.purpose == "workforce_analytics" };
