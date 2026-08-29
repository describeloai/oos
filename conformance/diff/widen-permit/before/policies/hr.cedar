@id("manager-reads-own-chain")
@obligation("mask:LAST4")
permit (
    principal in Role::"people_manager",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:critical"
) when {
    context.purpose == "compensation_review" &&
    resource.owner in principal.directReports
};
