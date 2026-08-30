@id("hr-analyst-reads-personal")
permit (
    principal in Role::"hr_analyst",
    action == Action::"read",
    resource in Label::"gdpr.sensitivity:high"
);
