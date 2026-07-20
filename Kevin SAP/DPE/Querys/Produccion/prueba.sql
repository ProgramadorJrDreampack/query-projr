SELECT 
    T2."DocNum" AS "OV",
    T2."SlpCode" AS "Empleado de ventas",
    T4."firstName" || ' ' || T4."lastName" AS "Empleado de Ventas",
    T1."ItemCode", 
    T3."Dscription",
    T1."Quantity",
    T3."Price" AS "Precio por unidad",
    T3."TaxCode" AS "Indicador de Impuestos",
    T3."GTotal" AS "Total ML",
     -- Dimensiones del cartón
    T6."SLength1" AS "Longitud Cartón",
    T6."SWidth1"  AS "Ancho Cartón",
    T6."SHeight1" AS "Altura Cartón",
    T6."SVolume"  AS "Volumen Cartón"
    T0."DocNum" AS "Entrega",
    T0."NumAtCard", 
    T0."DocDate",
    T0."CardName", 
    T0."U_DPE_NUM_VIAJE",
    T0."U_DPE_EMP_TRANS", 
    T0."U_DPE_PERS_FIRM",
    T0."U_DPE_LATITUD", 
    T0."U_DPE_LONGITUD",
    T0."U_DPE_OBSERVACIONES",
    T0."U_DPE_FECHA_COMENTARIO",
    T0."U_DPE_OBSER_ADIC",
    T0."U_DPE_FECHA_CREACION",
    T0."U_DPE_HORA_CREACION",
    T0."U_DPE_EST_GUIA",
    T0."U_DPE_COSTO_VIAJE",
    T0."U_DPE_TIPO_TRANSPORTE"

FROM ODLN T0
INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN ORDR T2 ON T1."BaseEntry" = T2."DocEntry"
INNER JOIN RDR1 T3 ON T2."DocEntry" = T3."DocEntry" 
                   AND T1."BaseLine" = T3."LineNum"
INNER JOIN OHEM T4 ON T2."OwnerCode" = T4."empID"
LEFT JOIN (
    SELECT 
        T0."ItemCode"   AS "SKU_PADRE",
        T0."ART1_ID"    AS "COD_CARTON",
        T0."ROUND_TYPE"
    FROM "SBO_FIGURETTI_PROD"."BEAS_STL" T0
    INNER JOIN "SBO_FIGURETTI_PROD"."OITM" T1 ON T0."ART1_ID" = T1."ItemCode"
    WHERE T1."validFor" = 'Y' 
      AND T1."U_SYP_SUBGRUPO2" = 'CARTON'
) T5 ON T1."ItemCode" = T5."SKU_PADRE"
-- Join al maestro para traer las dimensiones del cartón
LEFT JOIN OITM T6 ON T5."COD_CARTON" = T6."ItemCode"
WHERE T0."U_DPE_NUM_VIAJE" IS NOT NULL
ORDER BY T0."U_DPE_NUM_VIAJE" DESC