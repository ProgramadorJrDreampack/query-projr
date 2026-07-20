SELECT 
    W."WddCode",
    W."Status"     AS "EstadoSolicitud",
    W."CreateDate" AS "Fecha",
    W."CreateTime" AS "Hora",
    W."ObjType",
    W."DocEntry"
FROM OWDD W
WHERE W."DocEntry" = 66285
  AND W."ObjType"  = '17'
ORDER BY W."WddCode";