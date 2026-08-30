@id("clinician-reads-condition")
permit (
    principal in Role::"clinician",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:low"
);
