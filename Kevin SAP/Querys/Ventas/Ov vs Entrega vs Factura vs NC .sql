SELECT DISTINCT

    -- Orden de Venta
    T_OV."DocNum"     AS "OV_NumDoc",
    T_OV."DocDate"    AS "OV_FechaCont",
    R_OV."ItemCode"   AS "OV_Item",
    R_OV."Quantity"   AS "OV_Cant",

    -- Entrega (puede ser NULL si la factura se hizo directo desde OV)
    T_ENT."DocNum"    AS "Ent_NumDoc",
    T_ENT."DocDate"   AS "Ent_FechaCont",
    R_ENT."ItemCode"  AS "Ent_Item",
    R_ENT."Quantity"  AS "Ent_Cant",

    -- Factura
    T_FAC."DocNum"    AS "Fac_NumDoc",
    T_FAC."DocDate"   AS "Fac_FechaCont",
    T_FAC."DocType"   AS "Fac_DocType",      -- 'I' = Item, 'S' = Servicio
    R_FAC."ItemType"  AS "Fac_ItemType",     -- tipo a nivel de línea
    R_FAC."ItemCode"  AS "Fac_Item",
    R_FAC."Quantity"  AS "Fac_Cant",

    -- Solicitud de Devolución
    T_SDV."DocNum"    AS "SDV_NumDoc",
    T_SDV."DocDate"   AS "SDV_FechaCont",
    R_SDV."ItemCode"  AS "SDV_Item",
    R_SDV."Quantity"  AS "SDV_Cant",


    -- Nota de Crédito
    T_NC."DocNum"     AS "NC_NumDoc",
    T_NC."DocDate"    AS "NC_FechaCont",
    R_NC."ItemCode"   AS "NC_Item",
    R_NC."Quantity"   AS "NC_Cant"

FROM ORIN T_NC
INNER JOIN RIN1 R_NC
    ON T_NC."DocEntry" = R_NC."DocEntry"


-- NC/Dev -> Solicitud Devolución
LEFT JOIN ORRR T_SDV
    ON ( R_NC."BaseType"  = 234000031 AND R_NC."BaseEntry"  = T_SDV."DocEntry" )
LEFT JOIN RRR1 R_SDV
    ON T_SDV."DocEntry" = R_SDV."DocEntry"
   AND ( R_NC."BaseType"  = 234000031 AND R_NC."ItemCode"  = R_SDV."ItemCode" )
       

-- ============================================================
-- Factura — INNER JOIN para que solo aparezcan con factura
-- ============================================================
INNER JOIN OINV T_FAC
    ON ( R_NC."BaseType"  = 13 AND R_NC."BaseEntry"  = T_FAC."DocEntry" )
    OR ( R_SDV."BaseType" = 13 AND R_SDV."BaseEntry" = T_FAC."DocEntry" )
INNER JOIN INV1 R_FAC
    ON T_FAC."DocEntry" = R_FAC."DocEntry"
   AND (
        ( R_NC."BaseType"  = 13 AND R_NC."ItemCode"  = R_FAC."ItemCode" )
     OR ( R_SDV."BaseType" = 13 AND R_SDV."ItemCode" = R_FAC."ItemCode" )
       )

-- ============================================================
-- Entrega — LEFT porque puede no existir
-- ============================================================
LEFT JOIN ODLN T_ENT
    ON R_FAC."BaseType"  = 15
   AND R_FAC."BaseEntry" = T_ENT."DocEntry"
LEFT JOIN DLN1 R_ENT
    ON T_ENT."DocEntry"  = R_ENT."DocEntry"
   AND R_FAC."ItemCode"  = R_ENT."ItemCode"

-- ============================================================
-- Orden de Venta — INNER JOIN + dos caminos posibles:
--   Camino A: Factura -> Entrega -> OV  (flujo normal)
--   Camino B: Factura -> OV directa     (sin entrega)
-- ============================================================
INNER JOIN ORDR T_OV
    ON ( R_ENT."BaseType"  = 17 AND R_ENT."BaseEntry" = T_OV."DocEntry" )
    OR ( R_FAC."BaseType"  = 17 AND R_FAC."BaseEntry" = T_OV."DocEntry" )
INNER JOIN RDR1 R_OV
    ON T_OV."DocEntry" = R_OV."DocEntry"
   AND (
        ( R_ENT."BaseType" = 17 AND R_ENT."ItemCode" = R_OV."ItemCode" )
     OR ( R_FAC."BaseType" = 17 AND R_FAC."ItemCode" = R_OV."ItemCode" )
       )

ORDER BY "OV_FechaCont" DESC;

cd "c:\Users\user\Documents\proyectos_dreampack\planificacion-biotime" && git update-index --skip-worktree marcaciones_api/settings.py && git status