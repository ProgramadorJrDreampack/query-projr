 
 /********* Begin Procedure Script ************/ 
 BEGIN 
 	 var_out = 
 	 WITH
-- =========================
-- 07/04: precios de VENTA (compra = 0)
-- =========================
Stock10 AS (
    SELECT
        W."ItemCode",
        W."WhsCode",
        W."OnHand"
    FROM OITW W
    WHERE W."WhsCode" LIKE '10%'
      AND W."WhsCode" <> '100'
      AND W."OnHand" > 0
      AND W."Locked" = 'N'
      AND (
            W."ItemCode" LIKE '07%'
         OR W."ItemCode" LIKE '04%'
          )
),

Ventas_3M AS (
    SELECT
        L."ItemCode",

        ROUND(
            SUM(L."Price" * ABS(L."Quantity")) /
            NULLIF(SUM(ABS(L."Quantity")), 0),
            4
        ) AS "PrecioVenta_Pond_3M",

        ROUND(
            SUM(L."Price" * ABS(L."Quantity")) /
            NULLIF(
                SUM(
                    ABS(L."Quantity") *
                    CASE
                        WHEN UPPER(L."UomCode") IN ('UN', 'MANUAL') THEN 1
                        WHEN UPPER(L."UomCode") = 'PACK' THEN
                            COALESCE(NULLIF(ITM."U_SYP_UPPL", 0), NULLIF(L."NumPerMsr", 0), 1)
                        WHEN UPPER(L."UomCode") = 'CARTON' THEN
                            CASE
                                WHEN UPPER(ITM."InvntryUom") = 'PACK' THEN
                                    COALESCE(NULLIF(L."NumPerMsr", 0), 1)
                                    * COALESCE(NULLIF(ITM."U_SYP_UPPL", 0), 1)
                                ELSE
                                    COALESCE(NULLIF(L."NumPerMsr", 0), 1)
                            END
                        ELSE 1
                    END
                ),
                0
            ),
            4
        ) AS "PrecioPorUnidad_Pond_3M",

        MAX(H."DocDate")         AS "FechaUltFactura_3M",
        MAX(H."DocNum")          AS "DocNumUltFactura_3M",
        MAX(L."UomCode")         AS "UomUltFactura_3M",
        MAX(W."U_SYP_TIPOWSH")   AS "CodigoBodegaBase"
    FROM OINV H
    INNER JOIN INV1 L
        ON L."DocEntry" = H."DocEntry"
    INNER JOIN Stock10 S
        ON S."ItemCode" = L."ItemCode"
    INNER JOIN OITM ITM
        ON ITM."ItemCode" = L."ItemCode"
    INNER JOIN OWHS W
        ON W."WhsCode" = L."WhsCode"
    WHERE H."CANCELED" = 'N'
      AND H."CardCode" <> 'C0991440429001'
      AND L."Price" > 0
      AND L."Quantity" <> 0
      AND H."DocDate" >= ADD_MONTHS(CURRENT_DATE, -3)
    GROUP BY
        L."ItemCode"
),

UltimaFactura AS (
    SELECT
        X."ItemCode",
        ROUND(X."Price", 4)      AS "PrecioUltFactura",
        X."DocDate"              AS "FechaUltFactura",
        X."DocNum"               AS "DocNumUltFactura",
        X."UomCode"              AS "UomUltFactura",
        X."CodigoBodegaBase",

        ROUND(
            X."Price" /
            NULLIF(
                CASE
                    WHEN UPPER(X."UomCode") IN ('UN', 'MANUAL') THEN 1
                    WHEN UPPER(X."UomCode") = 'PACK' THEN
                        COALESCE(NULLIF(X."U_SYP_UPPL", 0), NULLIF(X."NumPerMsr", 0), 1)
                    WHEN UPPER(X."UomCode") = 'CARTON' THEN
                        CASE
                            WHEN UPPER(X."InvntryUom") = 'PACK' THEN
                                COALESCE(NULLIF(X."NumPerMsr", 0), 1)
                                * COALESCE(NULLIF(X."U_SYP_UPPL", 0), 1)
                            ELSE
                                COALESCE(NULLIF(X."NumPerMsr", 0), 1)
                        END
                    ELSE 1
                END,
                0
            ),
            4
        ) AS "PrecioPorUnidad_Ult"
    FROM (
        SELECT
            L."ItemCode",
            L."Price",
            H."DocDate",
            H."DocNum",
            L."UomCode",
            L."NumPerMsr",
            W."U_SYP_TIPOWSH" AS "CodigoBodegaBase",
            ITM."U_SYP_UPPL",
            ITM."InvntryUom",
            ROW_NUMBER() OVER (
                PARTITION BY L."ItemCode"
                ORDER BY H."DocDate" DESC, H."DocNum" DESC
            ) AS RN
        FROM OINV H
        INNER JOIN INV1 L
            ON L."DocEntry" = H."DocEntry"
        INNER JOIN OITM ITM
            ON ITM."ItemCode" = L."ItemCode"
        INNER JOIN OWHS W
            ON W."WhsCode" = L."WhsCode"
        WHERE H."CANCELED" = 'N'
          AND H."CardCode" <> 'C0991440429001'
          AND L."Price" > 0
          AND L."Quantity" <> 0
    ) X
    WHERE X.RN = 1
),

PrecioFinalVenta AS (
    SELECT
        I."ItemCode",
        I."ItemName",
        COALESCE(V."CodigoBodegaBase", U."CodigoBodegaBase") AS "CodigoBodegaBase",
        CASE
            WHEN V."ItemCode" IS NOT NULL THEN V."PrecioPorUnidad_Pond_3M"
            ELSE U."PrecioPorUnidad_Ult"
        END AS "PrecioVentaPorUnidad"
    FROM Stock10 S
    INNER JOIN OITM I
        ON I."ItemCode" = S."ItemCode"
    LEFT JOIN Ventas_3M V
        ON V."ItemCode" = S."ItemCode"
    LEFT JOIN UltimaFactura U
        ON U."ItemCode" = S."ItemCode"
    WHERE I."validFor" = 'Y'
      AND (
            (V."ItemCode" IS NOT NULL AND V."PrecioVenta_Pond_3M" > 0)
         OR (V."ItemCode" IS NULL AND U."PrecioUltFactura" > 0)
          )
),

-- =========================
-- 01/02: precios de COMPRA (venta = 0)
-- =========================
Receta AS (
    SELECT DISTINCT
        STL."ART1_ID" AS "ItemCode"
    FROM "SBO_FIGURETTI_PROD"."BEAS_STL" STL
    LEFT JOIN "SBO_FIGURETTI_PROD"."OITM" T2
        ON STL."ART1_ID" = T2."ItemCode"
    WHERE STL."ART1_ID" IS NOT NULL
      AND (
            STL."ART1_ID" LIKE '01%'
         OR STL."ART1_ID" LIKE '02%'
          )
      AND T2."validFor" = 'Y'
),

UltimaEntrada AS (
    SELECT
        X."ItemCode",
        X."Price"    AS "UltPrecioCompra",
        X."UomCode"  AS "UomEntrada",
        X."UomEntry" AS "UomEntryEntrada",
        X."DocDate"  AS "FechaUltEntrada",
        X."DocNum"   AS "DocNumUltEntrada",
        X."CardName" AS "Proveedor",
        X."CodigoBodegaBase",
        ROW_NUMBER() OVER (
            PARTITION BY X."ItemCode"
            ORDER BY X."DocDate" DESC, X."DocNum" DESC
        ) AS RN
    FROM (
        SELECT
            L."ItemCode",
            L."Price",
            L."UomCode",
            L."UomEntry",
            H."DocDate",
            H."DocNum",
            H."CardName",
            W."U_SYP_TIPOWSH" AS "CodigoBodegaBase"
        FROM OPDN H
        INNER JOIN PDN1 L
            ON L."DocEntry" = H."DocEntry"
        INNER JOIN OWHS W
            ON W."WhsCode" = L."WhsCode"
        WHERE H."CANCELED" = 'N'
          AND L."Quantity" <> 0
          AND L."Price" > 0
    ) X
),

FactorConv AS (
    SELECT
        R."ItemCode",
        CASE
            WHEN U1."AltQty" IS NULL OR U1."AltQty" = 0 THEN 1
            ELSE (U1."BaseQty" / U1."AltQty")
        END AS "FactorToInv"
    FROM Receta R
    INNER JOIN OITM ITM
        ON ITM."ItemCode" = R."ItemCode"
    LEFT JOIN UltimaEntrada U
        ON U."ItemCode" = R."ItemCode"
       AND U.RN = 1
    LEFT JOIN UGP1 U1
        ON U1."UgpEntry" = ITM."UgpEntry"
       AND U1."UomEntry" = U."UomEntryEntrada"
)

-- =========================
-- RESULTADO UNIFICADO
-- =========================
SELECT DISTINCT
    V."ItemCode"             AS "CodigoArticulo",
    V."ItemName"             AS "NombreArticulo",
    V."CodigoBodegaBase"     AS "CodigoBodega",
    V."PrecioVentaPorUnidad" AS "PrecioVenta",
    0.00                     AS "PrecioCompra",
    --V."InvntryUom"           AS "UnidadMedida"
    ITM."InvntryUom"         AS "UnidadMedida"
FROM PrecioFinalVenta V
INNER JOIN OITM ITM ON ITM."ItemCode" = V."ItemCode"

UNION ALL

SELECT DISTINCT
    R."ItemCode"             AS "CodigoArticulo",
    ITM."ItemName"             AS "NombreArticulo",
    LEFT(R."ItemCode", 2)    AS "CodigoBodega",
    0.00                     AS "PrecioVenta",
    ROUND(
        COALESCE(U."UltPrecioCompra", 0) /
        NULLIF(COALESCE(F."FactorToInv", 1), 0),
        4
    )                         AS "PrecioCompra",
     ITM."InvntryUom"         AS "UnidadMedida"
    --R."InvntryUom"            AS "UnidadMedida"
FROM Receta R
INNER JOIN OITM ITM ON ITM."ItemCode" = R."ItemCode"
LEFT JOIN UltimaEntrada U ON U."ItemCode" = R."ItemCode" AND U.RN = 1
LEFT JOIN FactorConv F ON F."ItemCode" = R."ItemCode"
WHERE U."UltPrecioCompra" > 0;
 	 
 	 
 	 
 	 
    
 	 
 	 

END /********* End Procedure Script ************/