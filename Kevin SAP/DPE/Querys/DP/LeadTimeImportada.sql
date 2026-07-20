WITH FLUJO1 AS (
--inicio flujo 1
SELECT 
        T0."DocNum"                     AS "PR No",
        T0."DocDate"                    AS "PR Date",
        T0."ReqDate"                    AS "Required Date",
        T3."DocNum"                     AS "PO No",
        T3."DocDate"                    AS "PO Date",
        T3."DocDueDate"                 AS "PO DeliveryDate",
        'Importada'                     AS "TipoCompra",
        (SELECT A0."Name" FROM "@SYP_MOTCOM" A0 
         WHERE A0."Code" = T0."U_SYP_MTVCOMP") AS "MotivoDeCompra",
        T3."CardCode"                   AS "VendorCode",
        T3."CardName"                   AS "VendorName",
CASE 
 WHEN T3."DocType" = 'I' THEN 'Articulo'
 WHEN T3."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
        T1."ItemCode", 
        T1."Dscription", 
        T1."Price",
        T2."Quantity",
        CASE 
            WHEN T3."DocStatus" = 'C' THEN 'Closed' 
            WHEN T3."DocStatus" = 'O' THEN 'Open' 
            ELSE T3."DocStatus" 
        END                             AS "Status PO",
        T5."DocNum"                     AS "A/P Reserve No",
        T5."DocDate"                    AS "A/P Reserve Invoice Date",
        T7."DocNum"                     AS "Goods Receipt No",
        T7."DocDate"                    AS "Goods Receipt Date",
T6."Quantity" AS "Goods Receipt Quantity",
(   SELECT 
    COUNT(DISTINCT T4sub."DocEntry")    FROM PDN1 T4sub    WHERE T4sub."BaseEntry" = T4."DocEntry"      
AND T4sub."BaseLine"  = T4."LineNum" 
AND T4sub."BaseType"  = 18
) AS "CantEntradas",
        T9."DocNum"                     AS "Landed Cost No",
        T9."DocDueDate"                 AS "Landed Cost Date"
    FROM OPRQ T0  
    INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" 
                       AND T1."LineNum"   = T2."BaseLine"
    INNER JOIN OPOR T3 ON T2."DocEntry"   = T3."DocEntry" AND T3."CANCELED" <> 'Y'
LEFT JOIN (  
  SELECT "BaseEntry", "BaseLine", MAX("DocEntry") AS "DocEntry"   
  FROM PCH1   
WHERE "BaseType" = 22 
GROUP BY "BaseEntry", "BaseLine" 
 ) T4_KEY ON T2."DocEntry" = T4_KEY."BaseEntry" 
  AND T2."LineNum"  = T4_KEY."BaseLine"  
LEFT JOIN PCH1 T4 ON T4_KEY."DocEntry" = T4."DocEntry" AND T4_KEY."BaseLine" = T4."BaseLine" AND T4."BaseType"     = 22 
LEFT JOIN OPCH T5 ON T4."DocEntry"  = T5."DocEntry"     AND T5."CANCELED"   <> 'Y'
LEFT JOIN PDN1 T6 ON T4."DocEntry"    = T6."BaseEntry" 
                      AND T4."LineNum"    = T6."BaseLine"
                     AND T6."BaseType" = 18
    LEFT JOIN OPDN T7 ON T6."DocEntry"    = T7."DocEntry" 
                      AND T7."CANCELED"  <> 'Y'

    LEFT JOIN IPF1 T8 ON T6."DocEntry"    = T8."BaseEntry"
                        AND T6."ItemCode" =  T8."ItemCode"
                      --AND T6."LineNum"    = T8."LineNum"
    LEFT JOIN OIPF T9 ON T8."DocEntry"    = T9."DocEntry"
    WHERE 
        T0."CANCELED"            = 'N' 
        AND T3."U_SYP_TIPCOMPRA" = '02' 
        AND YEAR(T0."DocDate")   >= 2024
--fin flujo 1

    /*SELECT 
        T0."DocNum"                     AS "PR No",
        T0."DocDate"                    AS "PR Date",
        T0."ReqDate"                    AS "Required Date",
        T3."DocNum"                     AS "PO No",
        T3."DocDate"                    AS "PO Date",
        T3."DocDueDate"                 AS "PO DeliveryDate",
        'Importada'                     AS "TipoCompra",
        (SELECT A0."Name" FROM "@SYP_MOTCOM" A0 
         WHERE A0."Code" = T0."U_SYP_MTVCOMP") AS "MotivoDeCompra",
        T3."CardCode"                   AS "VendorCode",
        T3."CardName"                   AS "VendorName",
CASE 
 WHEN T3."DocType" = 'I' THEN 'Articulo'
 WHEN T3."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
        T1."ItemCode", 
        T1."Dscription", 
        T1."Price",
        T2."Quantity",
        CASE 
            WHEN T3."DocStatus" = 'C' THEN 'Closed' 
            WHEN T3."DocStatus" = 'O' THEN 'Open' 
            ELSE T3."DocStatus" 
        END                             AS "Status PO",
        T5."DocNum"                     AS "A/P Reserve No",
        T5."DocDate"                    AS "A/P Reserve Invoice Date",
        T7."DocNum"                     AS "Goods Receipt No",
        T7."DocDate"                    AS "Goods Receipt Date",
T6."Quantity" AS "Goods Receipt Quantity",
(   SELECT COUNT(DISTINCT T4sub."DocEntry")    FROM PDN1 T4sub    WHERE T4sub."BaseEntry" = T4."DocEntry"      AND T4sub."BaseLine"  = T4."LineNum"      AND T4sub."BaseType"  = 22) AS "CantEntradas",
        T9."DocNum"                     AS "Landed Cost No",
        T9."DocDueDate"                 AS "Landed Cost Date"
    FROM OPRQ T0  
    INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" 
                       AND T1."LineNum"   = T2."BaseLine"
    INNER JOIN OPOR T3 ON T2."DocEntry"   = T3."DocEntry"
LEFT JOIN (  SELECT "BaseEntry", "BaseLine", MAX("DocEntry") AS "DocEntry"   
FROM PCH1   GROUP BY "BaseEntry", "BaseLine"  ) T4_KEY ON T2."DocEntry" = T4_KEY."BaseEntry" 
  AND T2."LineNum"  = T4_KEY."BaseLine"  
LEFT JOIN PCH1 T4 ON T4_KEY."DocEntry" = T4."DocEntry" AND T4_KEY."BaseLine" = T4."BaseLine"
LEFT JOIN OPCH T5 ON T4."DocEntry"  = T5."DocEntry"     AND T5."CANCELED"   <> 'Y'

    LEFT JOIN PDN1 T6 ON T4."DocEntry"    = T6."BaseEntry" 
                      AND T4."LineNum"    = T6."BaseLine"
                      --AND T6."BaseType" = 18
    LEFT JOIN OPDN T7 ON T6."DocEntry"    = T7."DocEntry" 
                      AND T7."CANCELED"  <> 'Y'
    LEFT JOIN IPF1 T8 ON T6."DocEntry"    = T8."BaseEntry" 
                      AND T6."LineNum"    = T8."LineNum"
    LEFT JOIN OIPF T9 ON T8."DocEntry"    = T9."DocEntry"
    WHERE 
        T0."CANCELED"            = 'N' 
        AND T3."U_SYP_TIPCOMPRA" = '02' 
        AND YEAR(T0."DocDate")   >= 2024
        --AND T3."DocNum" IN ('26000136','26000138')*/
),

FLUJO2 AS (
    SELECT 
        NULL                            AS "PR No",
        NULL                            AS "PR Date",
        NULL                            AS "Required Date",
        A0."DocNum"                     AS "PO No",
        A0."DocDate"                    AS "PO Date",
        A0."DocDueDate"                 AS "PO DeliveryDate",
        'Importada'                     AS "TipoCompra",
        (SELECT B0."Name" FROM "@SYP_MOTCOM" B0 
         WHERE B0."Code" = A0."U_SYP_MTVCOMP") AS "MotivoDeCompra",
        A0."CardCode"                   AS "VendorCode",
        A0."CardName"                   AS "VendorName",
CASE 
 WHEN A0."DocType" = 'I' THEN 'Articulo'
 WHEN A0."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
        A1."ItemCode", 
        A1."Dscription", 
        A1."Price",
        A1."Quantity",
        CASE 
            WHEN A0."DocStatus" = 'C' THEN 'Closed' 
            WHEN A0."DocStatus" = 'O' THEN 'Open' 
            ELSE A0."DocStatus" 
        END                             AS "Status PO",
        A5."DocNum"                     AS "A/P Reserve No",
        A5."DocDate"                    AS "A/P Reserve Invoice Date",
        A7."DocNum"                     AS "Goods Receipt No",
        A7."DocDate"                    AS "Goods Receipt Date",
A6."Quantity" AS "Goods Receipt Quantity",
(   SELECT COUNT(DISTINCT T4sub."DocEntry")    FROM PDN1 T4sub    WHERE T4sub."BaseEntry" = A4."DocEntry"      AND T4sub."BaseLine"  = A4."LineNum"      AND T4sub."BaseType"  = 18) AS "CantEntradas",
        A9."DocNum"                     AS "Landed Cost No",
        A9."DocDueDate"                 AS "Landed Cost Date"
    FROM OPOR A0                            
    INNER JOIN POR1 A1 ON A0."DocEntry"  = A1."DocEntry"
   LEFT JOIN (  
SELECT "BaseEntry", "BaseLine", MAX("DocEntry") AS "DocEntry"   
FROM PCH1   
WHERE "BaseType" = 22 
GROUP BY "BaseEntry", "BaseLine"  ) T4_KEY ON A1."DocEntry" = T4_KEY."BaseEntry" 
  AND A1."LineNum"  = T4_KEY."BaseLine"  
LEFT JOIN PCH1 A4 ON T4_KEY."DocEntry" = A4."DocEntry" AND T4_KEY."BaseLine" = A4."BaseLine"
LEFT JOIN OPCH A5 ON A4."DocEntry"  = A5."DocEntry"     AND A5."CANCELED"   <> 'Y'
    LEFT JOIN PDN1 A6 ON A4."DocEntry"   = A6."BaseEntry" 
                      AND A4."LineNum"   = A6."BaseLine"
                      AND A6."BaseType" = 18
    LEFT JOIN OPDN A7 ON A6."DocEntry"   = A7."DocEntry" 
                      AND A7."CANCELED" <> 'Y'
    LEFT JOIN IPF1 A8 ON A6."DocEntry"   = A8."BaseEntry" 
                     -- AND A6."LineNum"   = A8."LineNum"
AND A6."ItemCode"   = A8."ItemCode"
    LEFT JOIN OIPF A9 ON A8."DocEntry"   = A9."DocEntry"
    WHERE 
        A0."CANCELED"            = 'N' 
        AND A0."U_SYP_TIPCOMPRA" = '02'
        AND YEAR(A0."DocDate")   >= 2024
        --AND A0."DocNum" IN ('26000136','26000138')
        -- Sin PR link directo Y sin PR hermana por item+vendor+fecha
        AND NOT EXISTS (
            SELECT 1 
            FROM PRQ1 P 
            INNER JOIN OPRQ PRQ ON P."DocEntry"  = PRQ."DocEntry"
            WHERE P."TrgetEntry" = A0."DocEntry"
              AND P."LineNum"    = A1."BaseLine"
              AND PRQ."CANCELED" = 'N'
        )
        AND NOT EXISTS (
            SELECT 1 FROM PRQ1 P3
            INNER JOIN OPRQ PRQ3 ON P3."DocEntry"   = PRQ3."DocEntry"
            INNER JOIN OPOR PO3  ON P3."TrgetEntry" = PO3."DocEntry"
            WHERE P3."ItemCode"   = A1."ItemCode"
              AND PO3."CardCode"  = A0."CardCode"
              AND PO3."DocDate"   = A0."DocDate"
              AND PRQ3."CANCELED" = 'N'
        )
),

FLUJO3 AS (
    SELECT 
        PR_REF."DocNum"                 AS "PR No",
        PR_REF."DocDate"                AS "PR Date",
        PR_REF."ReqDate"                AS "Required Date",
        A0."DocNum"                     AS "PO No",
        A0."DocDate"                    AS "PO Date",
        A0."DocDueDate"                 AS "PO DeliveryDate",
        'Importada'                     AS "TipoCompra",
        (SELECT B0."Name" FROM "@SYP_MOTCOM" B0 
         WHERE B0."Code" = A0."U_SYP_MTVCOMP") AS "MotivoDeCompra",
        A0."CardCode"                   AS "VendorCode",
        A0."CardName"                   AS "VendorName",
CASE 
 WHEN A0."DocType" = 'I' THEN 'Articulo'
 WHEN A0."DocType" = 'S' THEN 'Servicio'
END AS "Clase",
        A1."ItemCode", 
        A1."Dscription", 
        A1."Price",
        A1."Quantity",
        CASE 
            WHEN A0."DocStatus" = 'C' THEN 'Closed' 
            WHEN A0."DocStatus" = 'O' THEN 'Open' 
            ELSE A0."DocStatus" 
        END                             AS "Status PO",
        A5."DocNum"                     AS "A/P Reserve No",
        A5."DocDate"                    AS "A/P Reserve Invoice Date",
        A7."DocNum"                     AS "Goods Receipt No",
        A7."DocDate"                    AS "Goods Receipt Date",
A6."Quantity" AS "Goods Receipt Quantity",
(   SELECT COUNT(DISTINCT T4sub."DocEntry")    FROM PDN1 T4sub    WHERE T4sub."BaseEntry" = A4."DocEntry"      AND T4sub."BaseLine"  = A4."LineNum"      AND T4sub."BaseType"  = 18) AS "CantEntradas",
        A9."DocNum"                     AS "Landed Cost No",
        A9."DocDueDate"                 AS "Landed Cost Date"
    FROM OPOR A0                            
    INNER JOIN POR1 A1 ON A0."DocEntry"  = A1."DocEntry"
    -- Buscar PR hermana: mismo item, mismo vendor, misma fecha de PO
    INNER JOIN PRQ1 P_LINE  ON P_LINE."ItemCode"    = A1."ItemCode"
    INNER JOIN OPRQ PR_REF  ON P_LINE."DocEntry"    = PR_REF."DocEntry"
                            AND PR_REF."CANCELED"   = 'N'
    INNER JOIN OPOR PO_HER  ON P_LINE."TrgetEntry"  = PO_HER."DocEntry"
                            AND PO_HER."CardCode"   = A0."CardCode"
                            AND PO_HER."DocDate"    = A0."DocDate"
    -- Cadena documental
  LEFT JOIN (  
SELECT "BaseEntry", "BaseLine", MAX("DocEntry") AS "DocEntry"   
FROM PCH1   
WHERE "BaseType" = 22 
GROUP BY "BaseEntry", "BaseLine"  ) T4_KEY ON A1."DocEntry" = T4_KEY."BaseEntry" 
  AND A1."LineNum"  = T4_KEY."BaseLine"  
LEFT JOIN PCH1 A4 ON T4_KEY."DocEntry" = A4."DocEntry" AND T4_KEY."BaseLine" = A4."BaseLine" AND A4."BaseType"     = 22
LEFT JOIN OPCH A5 ON A4."DocEntry"  = A5."DocEntry"     AND A5."CANCELED"   <> 'Y'
    LEFT JOIN PDN1 A6 ON A4."DocEntry"   = A6."BaseEntry" 
                      AND A4."LineNum"   = A6."BaseLine"
                     AND A6."BaseType" = 18 
    LEFT JOIN OPDN A7 ON A6."DocEntry"   = A7."DocEntry" 
                      AND A7."CANCELED" <> 'Y'
    LEFT JOIN IPF1 A8 ON A6."DocEntry"   = A8."BaseEntry" 
                      --AND A6."LineNum"   = A8."LineNum"
AND A6."ItemCode"   = A8."ItemCode"
    LEFT JOIN OIPF A9 ON A8."DocEntry"   = A9."DocEntry"
    WHERE 
        A0."CANCELED"            = 'N' 
        AND A0."U_SYP_TIPCOMPRA" = '02'
        AND YEAR(A0."DocDate")   >= 2024
        --AND A0."DocNum" IN ('26000136','26000138')
        -- Solo líneas sin PR link directo
        AND NOT EXISTS (
            SELECT 1 FROM PRQ1 P2
            INNER JOIN OPRQ PRQ2 ON P2."DocEntry"  = PRQ2."DocEntry"
            WHERE P2."TrgetEntry" = A0."DocEntry"
              AND P2."LineNum"    = A1."BaseLine"
              AND PRQ2."CANCELED" = 'N'
        )
        -- Pero que SÍ tengan PR hermana
        AND EXISTS (
            SELECT 1 FROM PRQ1 P3
            INNER JOIN OPRQ PRQ3 ON P3."DocEntry"   = PRQ3."DocEntry"
            INNER JOIN OPOR PO3  ON P3."TrgetEntry" = PO3."DocEntry"
            WHERE P3."ItemCode"   = A1."ItemCode"
              AND PO3."CardCode"  = A0."CardCode"
              AND PO3."DocDate"   = A0."DocDate"
              AND PRQ3."CANCELED" = 'N'
        )
)

SELECT * FROM FLUJO1
UNION ALL
SELECT * FROM FLUJO2
UNION ALL
SELECT * FROM FLUJO3
ORDER BY "PO No", "ItemCode"
