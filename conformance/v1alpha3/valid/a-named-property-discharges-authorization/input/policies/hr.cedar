// Ni una etiqueta: la propiedad, por su nombre. Es la otra mitad de la
// proyeccion, y gobierna igual — un `forbid` sobre una propiedad concreta es la
// forma mas contundente de gobernarla.
@id("forbid-tax-id-egress")
forbid (
    principal,
    action in [Action::"export", Action::"aggregate"],
    resource == Property::"hr.Employee.taxId"
);
