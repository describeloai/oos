@id("analyst-reads-tax")
@oosScope("eu.nif#own-department")
permit (
    principal in Role::"analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:high"
);
