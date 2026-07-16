SELECT T1."DocEntry", T0."BaseType", T0."BaseNum", T0."ItemCode", T0."BatchNum" AS "LOTE", T2."U_beas_belnrid" AS "ORDEN", T3."KNDNAME" AS "CLIENTE", T0."ItemName", T0."WhsCode", 
--T0."Quantity", 
T2."Quantity",T0."InDate"
FROM "SBO_FIGURETTI_PROD"."OIBT" T0
INNER JOIN "SBO_FIGURETTI_PROD"."OIGN" T1 ON T0."BaseNum" = T1."DocNum"
INNER JOIN "SBO_FIGURETTI_PROD"."IGN1" T2 ON T1."DocEntry" = T2."DocEntry"
INNER JOIN "SBO_FIGURETTI_PROD"."BEAS_FTHAUPT" T3 ON T2."U_beas_belnrid" = T3."BELNR_ID"
WHERE 
--T0."Quantity" <> '0' 
T2."Quantity"  <> '0' 
AND (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%') 
AND T0."WhsCode" LIKE '04%' AND
T0."InDate" BETWEEN [%0] AND [%1]
 --AND T0."BatchNum" = '35716102508211905'
ORDER BY T2."U_beas_belnrid"