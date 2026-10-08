-- 1 · vacía: lo que crea algo vacío no es un transform
create media collection if not exists ventas.borradores media document formats (pdf);

-- 2 · la colección que da su consulta: una fila por fichero
create or replace media collection ventas.solo_pdf media document formats (pdf) as
select c.path as name, c._item as data
from ventas.contratos as c
where c.content_type = 'application/pdf';
