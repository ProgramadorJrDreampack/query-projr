SELECT 
'FAC' AS "Tipo",
T0."DocEntry", T0."DocNum", T0."U_SYP_ORDEN_COMPRA",T0."DocDate", T0."CardName", T0."NumAtCard", T1."ItemCode",T2."U_SYP_CODE_SKU" AS "SKU CLIENTE", T1."Dscription" AS "Descripcion", T1."AcctCode" AS "Cuenta Contable",
T1."Quantity" AS "CANTIDAD", T1."PriceBefDi"  As "Precio Unitario", T1."StockPrice" AS "Costo", T1."UomCode" AS "UoM",
T1."Quantity" * COALESCE(T14."BaseQty", 1) AS "Cantidad en Unidades",
CASE WHEN T0."CANCELED" = 'N' THEN T1."TotalSumSy" ELSE T1."TotalSumSy" * -1 END AS "Total Ingreso USD", 
CASE WHEN T0."CANCELED" = 'N' THEN T1."LineTotal" ELSE  T1."LineTotal" * -1 END As "Total Ingreso MXN", 
T1."Currency", (T1."Quantity" * T1."StockPrice") AS "Total Costo MXN", T1."TaxCode"  AS "IVA", T1."GTotalSC" AS "Total Bruto", T3."SlpName" AS "Vendedor",
T2."U_SYP_PESOBRUTO" AS "PESO BRUTO", T1."NoInvtryMv" As "No Mueve Inventario", T1."InvQty" AS "Cant Conv", (T1."InvQty" * T2."U_SYP_PESOBRUTO") AS "KG",
((T1."InvQty" * T2."U_SYP_PESOBRUTO") / 1000) AS "Ton", (((T1."InvQty" * T2."U_SYP_PESOBRUTO") / 1000) * T1."PriceBefDi") AS "D/T", T4."Name" AS "SG1", T5."Name" AS "SG2", T6."Name" AS "SG3", T7."Name" AS "SG4"
, CASE WHEN T2."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
WHEN T2."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
WHEN T2."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
WHEN T2."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
WHEN T2."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
WHEN T2."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
WHEN T2."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
WHEN T2."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
WHEN T2."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
WHEN T2."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
WHEN T2."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
WHEN T2."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
WHEN T2."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
ELSE T2."U_FIGU_SUBGRUPO5" END AS "SG5", 
CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
ELSE T0."CANCELED" END AS "Cancelado", 
D1."CityS", 
  T0."CardCode",
(T1."Quantity" * T1."StockPrice") / (SELECT A0."Rate" FROM ORTT A0 WHERE A0."Currency" = 'USD' AND A0."RateDate" = T0."DocDate") AS "Total Costo USD",
T12."U_LAB_FSC_DECLA",
N8."Comments"
FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN INV12 D1 ON T0."DocEntry" = D1."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
LEFT JOIN UGP1 T14  ON T14."UgpEntry" = T2."UgpEntry"    
AND T14."UomEntry" = T1."UomEntry"
INNER JOIN OSLP T3 ON T0."SlpCode" = T3."SlpCode" 
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO1" T4 ON T2."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO2" T5 ON T2."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO3" T6 ON T2."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO4" T7 ON T2."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN OBTN T12 ON T1."ItemCode" = T12."ItemCode" AND T1."BaseLine" = T12."SysNumber"
-- Salto 2: Factura → Entrega (heredamos el BaseType de la factura origen)
LEFT JOIN DLN1 N11 ON T1."BaseType" = 15 
                  AND T1."BaseEntry" = N11."DocEntry" 
                  AND T1."ItemCode" = N11."ItemCode"
LEFT JOIN ODLN N10 ON N11."DocEntry" = N10."DocEntry"

-- Salto 3: Entrega → Orden
LEFT JOIN RDR1 N9 ON N11."BaseType" = 17 
                 AND N11."BaseEntry" = N9."DocEntry" 
                 AND N11."ItemCode" = N9."ItemCode"
LEFT JOIN ORDR N8 ON N9."DocEntry" = N8."DocEntry"

WHERE T0."DocDate"  BETWEEN [%0] AND [%1] 
--AND T0."CANCELED" <> 'Y' 
--AND T1."ItemCode" = '07EBF10690004' 


UNION ALL

SELECT 'NC' AS "Tipo", T0."DocEntry", T0."DocNum", T0."U_LAB_ORDCOM", T0."DocDate", T0."CardName", T0."NumAtCard", T1."ItemCode",T3."U_SYP_CODE_SKU" AS "SKU CLIENTE", T1."Dscription", T1."AcctCode"  AS "Cuenta Contable", 
(T1."Quantity" * -1) AS "CANTIDAD", T1."PriceBefDi" As "Precio Unitario", T1."StockPrice", T1."UomCode"  AS "UoM", 
T1."Quantity" * COALESCE(T14."BaseQty", 1) AS "Cantidad en Unidades",
(T1."TotalSumSy" * -1) AS "Total Ingreso USD", T1."LineTotal" * -1 As "Total Ingreso MXN", T1."Currency", (T1."Quantity" * T1."StockPrice") * -1 AS "Total Costo MXN", T1."TaxCode" AS "IVA", (T1."GTotalSC" * -1) AS "Total Bruto", T2."SlpName" AS "Vendedor",
T3."U_SYP_PESOBRUTO" AS "PESO BRUTO", T1."NoInvtryMv" AS "No Mueve Inventario", 
CASE WHEN T1."NoInvtryMv" = 'N' THEN (T1."InvQty" * -1) 
WHEN T1."NoInvtryMv" = 'Y' THEN '0' END AS "Cant Conv", 
CASE WHEN T1."NoInvtryMv" = 'N' THEN ((T1."InvQty" * T3."U_SYP_PESOBRUTO") * -1) 
WHEN T1."NoInvtryMv" = 'Y' THEN '0' END AS "KG",
CASE WHEN T1."NoInvtryMv" = 'N' THEN (((T1."InvQty" * T3."U_SYP_PESOBRUTO") / 1000) * -1) 
WHEN T1."NoInvtryMv" = 'Y' THEN '0' END AS "Ton", (((T1."InvQty" * T3."U_SYP_PESOBRUTO") / 1000) * T1."PriceBefDi") AS "D/T", T4."Name" AS "SG1", T5."Name" AS "SG2", T6."Name" AS "SG3", T7."Name" AS "SG4"
, CASE WHEN T3."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
WHEN T3."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
WHEN T3."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
WHEN T3."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
WHEN T3."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
WHEN T3."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
WHEN T3."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
WHEN T3."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
WHEN T3."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
WHEN T3."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
WHEN T3."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
WHEN T3."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
WHEN T3."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
ELSE T3."U_FIGU_SUBGRUPO5" END AS "SG5",
CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
ELSE T0."CANCELED" END AS "Cancelado",
D1."CityS", 
  T0."CardCode",
(T1."Quantity" * T1."StockPrice") / (SELECT A0."Rate" FROM ORTT A0 WHERE A0."Currency" = 'USD' AND A0."RateDate" = T0."DocDate") AS "Total Costo USD",
T12."U_LAB_FSC_DECLA",
N8."Comments"
FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RIN12 D1 ON T0."DocEntry" = D1."DocEntry"
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
LEFT JOIN OITM T3 ON T1."ItemCode" = T3."ItemCode"
LEFT JOIN UGP1 T14  ON T14."UgpEntry" = T3."UgpEntry"    
AND T14."UomEntry" = T1."UomEntry"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO1" T4 ON T3."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO2" T5 ON T3."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO3" T6 ON T3."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "B1H_EPM_PROD"."@SYP_SUBGRUPO4" T7 ON T3."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN OBTN T12 ON T1."ItemCode" = T12."ItemCode" AND T1."BaseLine" = T12."SysNumber"
 -- Salto 1: NC → Factura (BaseType 13 = Factura)
LEFT JOIN INV1 N1 ON T1."BaseType" = 13 
                 AND T1."BaseEntry" = N1."DocEntry" 
                 AND T1."BaseLine" = N1."LineNum"
LEFT JOIN OINV N0 ON N1."DocEntry" = N0."DocEntry"

-- Salto 2: Factura → Entrega (heredamos el BaseType de la factura origen)
LEFT JOIN DLN1 N11 ON N1."BaseType" = 15 
                  AND N1."BaseEntry" = N11."DocEntry" 
                  AND N1."ItemCode" = N11."ItemCode"
LEFT JOIN ODLN N10 ON N11."DocEntry" = N10."DocEntry"

-- Salto 3: Entrega → Orden
LEFT JOIN RDR1 N9 ON N11."BaseType" = 17 
                 AND N11."BaseEntry" = N9."DocEntry" 
                 AND N11."ItemCode" = N9."ItemCode"
LEFT JOIN ORDR N8 ON N9."DocEntry" = N8."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1] 
--AND T0."CANCELED" <> 'Y' 
--AND T1."ItemCode" = '07EBF10690004'

ORDER BY "Tipo",T0."DocEntry"