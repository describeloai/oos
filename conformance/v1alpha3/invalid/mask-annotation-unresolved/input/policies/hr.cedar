@id("analyst-reads-tax")
@oosMask("eu.nif#no-existe")
permit (
    principal in Role::"analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:high"
);
