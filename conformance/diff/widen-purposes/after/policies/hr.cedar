@id("hr-analyst-reads-comp")
@obligation("mask:LAST4")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
) when { ["compensation_review", "workforce_analytics", "recruiting"].contains(context.purpose) };
