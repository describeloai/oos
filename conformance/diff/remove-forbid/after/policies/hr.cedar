@id("hr-analyst-reads-comp")
@obligation("mask:LAST4")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
) when { context.purpose == "compensation_review" };
