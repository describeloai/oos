// `higth` no existe: el retículo declara `high`.
@id("proteger-lo-sensible")
permit(principal, action == Action::"read", resource)
when { resource in Label::"gdpr.sensitivity:higth" };
