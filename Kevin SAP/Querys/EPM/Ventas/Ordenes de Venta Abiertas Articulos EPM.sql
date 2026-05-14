SELECT 
T5."DocNum" AS "Numero Doc Oferta de Venta",
T0."DocNum",T0."NumAtCard" ,T0."DocDate", T0."DocDueDate", T0."CardCode", T0."CardName", T1."ItemCode", T1."Dscription",T1."Quantity"*T1."NumPerMsr" AS "Cantidad", T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
T1."U_SYP_FEMBARCA",
T1."UomCode2" AS "Unidad", T1."Price"/T1."NumPerMsr", T1."TaxCode",T2."CityS",T2."StreetS",T0."Comments",T4."SlpName", T1."WhsCode" 
FROM ORDR
T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode"=T4."SlpCode"  
LEFT JOIN OQUT T5 ON CAST(T1."BaseRef" AS VARCHAR) = CAST(T5."DocNum" AS VARCHAR) AND T1."BaseType" = '23'
WHERE T1."LineStatus" = 'O' --AND T1."WhsCode" IN ('10PTE','10FPTE','10EPTE')