@id("analyst-reads-pii")
permit (
    principal in Role::"analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:high"
);
