--FLUJO 1
SELECT 
T0."DocNum" AS "PR No",
T0."DocDate" AS "PR Date",
T0."ReqDate" AS "Required Date",
T3."DocNum" AS "PO No",
T3."DocDate"AS "PO Date",
T3."DocDueDate" AS "PO DeliveryDate",
CASE 
 WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'Local'
 WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'Importada'
END AS "TipoCompra",
(SELECT A0."Name" FROM "SBO_FIGURETTI_PROD"."@SYP_MOTCOM" A0 WHERE A0."Code" = T0."U_SYP_MTVCOMP" ) AS "MotivoDeCompra",
--T2."LineVendor" AS "VendorCode",
COALESCE(T2."LineVendor",T3."CardCode") AS "VendorCode",
--T1."FreeTxt" AS "VendorName",
T3."CardName"  AS "VendorName",
CASE 
 WHEN T0."DocType" = 'I' THEN 'Articulo'
 WHEN T0."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
T1."ItemCode", 
T1."Dscription", 
T1."Price",
T1."Quantity",
CASE 
 WHEN T3."DocStatus" = 'C' OR T0."DocStatus" = 'C' THEN 'Closed'
 WHEN T3."DocStatus" = 'O' OR T0."DocStatus" = 'O' THEN 'Open'
 ELSE T3."DocStatus"
END AS "Status PO",
T7."DocNum" AS "A/P Reserve No",
T7."DocDate" AS "A/P Reserve Invoice Date",
T5."DocNum" AS "Goods Receipt No",
T5."DocDate" AS "Goods Receipt Date",
T4."Quantity" AS "Goods Receipt Quantity",
(   SELECT COUNT(DISTINCT T4sub."DocEntry")    FROM PDN1 T4sub    WHERE T4sub."BaseEntry" = T2."DocEntry"      AND T4sub."BaseLine"  = T2."LineNum"      AND T4sub."BaseType"  = 22) AS "CantEntradas",
T0."U_SYP_TIPCOMPRA" 

FROM OPRQ T0  --Solicitud de compra
INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry" --Linea Solicitud de Compra
LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine" --Linea Pedido
LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry" --Pedido

LEFT JOIN PDN1 T4 ON T2."DocEntry" = T4."BaseEntry" 
           AND T2."LineNum" = T4."BaseLine"            --T4."LineNum"
           AND T4."BaseType" = 22   --Linea Entrada de mercancias
LEFT JOIN OPDN T5 ON T4."DocEntry" = T5."DocEntry"
LEFT JOIN PCH1 T6 ON T4."DocEntry" = T6."BaseEntry" AND T4."LineNum" = T6."BaseLine"  AND T6."BaseType" = 20  --Linea Factura de proveedores
LEFT JOIN OPCH T7 ON T6."DocEntry" = T7."DocEntry"  AND T7."CANCELED" = 'N'

WHERE 

T0."CANCELED" = 'N' AND
T0."U_SYP_TIPCOMPRA" = '01' 
AND YEAR(T0."DocDate") >= '2024'

UNION ALL


SELECT 
    NULL AS "PR No", NULL AS "PR Date", NULL AS "Required Date",
    T0."DocNum" AS "PO No", T0."DocDate" AS "PO Date", T0."DocDueDate" AS "PO DeliveryDate",
    CASE WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'Local' ELSE 'Importada' END AS "TipoCompra",
    (SELECT A0."Name" FROM "@SYP_MOTCOM" A0 WHERE A0."Code" = T0."U_SYP_MTVCOMP") AS "MotivoDeCompra",
    T1."LineVendor" AS "VendorCode", T0."CardName" AS "VendorName",
    CASE 
 WHEN T0."DocType" = 'I' THEN 'Articulo'
 WHEN T0."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
    T1."ItemCode", T1."Dscription", T1."Price", T1."Quantity",
    CASE WHEN T0."DocStatus" = 'C' THEN 'Closed' WHEN T0."DocStatus" = 'O' THEN 'Open' ELSE NULL END AS "Status PO",
    T6."DocNum" AS "A/P Reserve No", T6."DocDate" AS "A/P Reserve Invoice Date",
    T4."DocNum" AS "Goods Receipt No", T4."DocDate" AS "Goods Receipt Date",
    T3."Quantity" AS "Goods Receipt Quantity",
    (   SELECT COUNT(DISTINCT T4sub."DocEntry")        FROM PDN1 T4sub        WHERE T4sub."BaseEntry" = T1."DocEntry"  AND T4sub."BaseLine"  = T1."LineNum"  AND T4sub."BaseType"  = 22    ) AS "CantEntradas",
     T0."U_SYP_TIPCOMPRA"

FROM OPOR T0  
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
--LEFT JOIN OCRD T2 ON T1."LineVendor" = T2."CardCode"  -- Nombre proveedor
LEFT JOIN PDN1 T3 ON T1."DocEntry" = T3."BaseEntry" AND T1."LineNum" = T3."BaseLine"
LEFT JOIN OPDN T4 ON T3."DocEntry" = T4."DocEntry"
LEFT JOIN PCH1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T3."LineNum" = T5."BaseLine"
LEFT JOIN OPCH T6 ON T5."DocEntry" = T6."DocEntry" AND T6."CANCELED" = 'N'
WHERE 
  T0."CANCELED" = 'N' 