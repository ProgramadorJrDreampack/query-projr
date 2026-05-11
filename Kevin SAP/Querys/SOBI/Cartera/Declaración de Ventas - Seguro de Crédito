SELECT 
  T1."Country"                                 AS "País",
    T1."CardName"                                AS "Nombre Cliente",
 T0."CardCode"                                  AS "Código Cliente",
T1."LicTradNum" AS "RUC",
NULL AS "Curstomer References",

T1."Currency" AS "Moneda",
  
    SUM(T0."DocTotal")                             AS "Total Factura",
 YEAR(T0."TaxDate")                             AS "Año",
    MONTH(T0."TaxDate")                            AS "Mes",
    TO_VARCHAR(T0."TaxDate", 'YYYY-MM')            AS "Periodo",
    COUNT(*)                                       AS "Cantidad Facturas"

FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE T0."CANCELED" NOT IN ('Y', 'C')
AND  T1."QryGroup6" = 'Y'
  AND T0."TaxDate" BETWEEN '[%0]' AND '[%1]'
GROUP BY 
    T0."CardCode",
T1."LicTradNum",
    T1."Country" ,
    T1."CardName",
T1."Currency",
    YEAR(T0."TaxDate"),
    MONTH(T0."TaxDate"),
    TO_VARCHAR(T0."TaxDate", 'YYYY-MM')
ORDER BY 
    T0."CardCode",
    YEAR(T0."TaxDate"),
    MONTH(T0."TaxDate");