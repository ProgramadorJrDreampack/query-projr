SELECT
  T0."DocNum"                                          AS "N° Documento",
  T1."ItemCode"                                        AS "Número Artículo",
  T1."Dscription"                                      AS "Descripción",
  T1."Quantity"                                        AS "Cantidad",
  T1."Price"                                           AS "Precio Unitario",
  T1."LineTotal"                                       AS "Total Línea",
  COUNT(*) OVER(PARTITION BY T0."DocNum")              AS "Total Artículos",
  SUM(T1."LineTotal") OVER(PARTITION BY T0."DocNum")   AS "Total General"
 FROM OPDN T0  
INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T0."DocNum" = '25001514'
