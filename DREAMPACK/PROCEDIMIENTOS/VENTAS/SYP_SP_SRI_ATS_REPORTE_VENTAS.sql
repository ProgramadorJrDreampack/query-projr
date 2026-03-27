CREATE PROCEDURE "SYP_SP_SRI_ATS_REPORTE_VENTAS"(
  IN FECHA_INI DATETIME,
  IN FECHA_FIN DATETIME,
  OUT TMP SYP_TEMP_VENTAS
)
READS SQL DATA WITH RESULT VIEW SYP_SP_SRI_ATS_REPORTE_VENTAS_VIEW 
AS
BEGIN
TMP = SELECT
 CASE
   WHEN COALESCE(T."U_SYP_EXPORTACION", 'NO') = 'SI' THEN '01'
   WHEN COALESCE(T."U_SYP_FACREEMBOLSO", 0) != 0 THEN '41'
   ELSE ifnull(T."U_SYP_MDTD", '')
 END AS "COD DOC",
 (SELECT
   "U_SYP_TDDD"
 FROM "@SYP_TPODOC" C1
 WHERE C1."Code" = (SELECT
   CASE
     WHEN COALESCE(T."U_SYP_EXPORTACION", 'NO') = 'SI' THEN '01'
     WHEN COALESCE(T."U_SYP_FACREEMBOLSO", 0) != 0 THEN '41'
     ELSE ifnull(T."U_SYP_MDTD", '')
   END FROM DUMMY)) AS "DESCRIP DOC",
 CASE
   WHEN COALESCE(T."U_SYP_EXPORTACION", 'NO') = 'SI' THEN T5."U_SYP_CODEXP"
   ELSE T5."U_SYP_CODVTA"
 END AS "TIP. IDENTF",
 T2."LicTradNum" AS "IDENTIFICACION",
 T2."CardName" AS "RAZON SOCIAL",
 CASE
   WHEN (CASE
       WHEN COALESCE(T."U_SYP_EXPORTACION", 'NO') = 'SI' THEN T5."U_SYP_CODEXP"
       ELSE T5."U_SYP_CODVTA"
     END) = '07' THEN NULL
   ELSE T2."U_SYP_PARTREL"
 END AS "PARTE REL",
 T2."U_SYP_TIPPROV" AS "TIP SUJETO",
 'V' AS "TIP. ANEXO",
 'A' AS "TIP. OPERAC",
 CASE
   WHEN ifnull(T4B."U_SYP_NDFE", '') = 'Y' THEN 'E'
   ELSE 'F'
 END AS "EMISION",
 T."U_SYP_SERIESUC" AS "COD ESTAB",
 T."U_SYP_MDSD" AS "PTO VTA",
 T."U_SYP_MDCD" AS "SECUENC.",
 ifnull(T."U_SYP_NROAUTO", '') AS "NRO AUTORIZACION",
 CAST(T."DocDate" AS date) AS "FCHA EMISI.",
 ifnull(CAST(T."U_SYP_FECHAUTOR" AS date), '') AS "FCHA AUTORIZACION",
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" IN ('baseImpExe', 'baseImponible'))), 0) AS "BASE %0",
 CAST((
 CASE
   WHEN COALESCE(T."U_SYP_FACREEMBOLSO", 0) != 0 THEN ifnull((SELECT
       SUM(ifnull(C2."U_SYP_TARIVADIF", 0))
     FROM "@SYP_REEMBOLSOS" C1
     INNER JOIN "@SYP_REEMBOLSOS_DET" C2
       ON C1."DocEntry" = C2."DocEntry"
       AND C1."DocEntry" = T."U_SYP_FACREEMBOLSO"), 0)
   ELSE 0
 END) AS DECIMAL(19,2) ) AS "BASE DIF%0 REEMB",
 
 
 
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav5%')), 0) AS "BASE %5",
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav8%')), 0) AS "BASE %8",
 
 
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "BASE %12",
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "BASE %14",
 
 
   ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav15%')), 0) AS "BASE %15",
 
 
 ifnull((SELECT
   CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" = 'baseNoGraIva')), 0) AS "BASE NO OBJ",
 1 AS "NO. COMPROBANTES",
 
  ifnull((SELECT
   CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav5%')), 0) AS "MONTO IVA 5",
  ifnull((SELECT
   CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav8%')), 0) AS "MONTO IVA 8",
 
 
 ifnull((SELECT
   CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "MONTO IVA 12",
 
 ifnull((SELECT
   CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "MONTO IVA 14",
 
 
  ifnull((SELECT
   CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
 FROM "INV4" AS X
 INNER JOIN "INV1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav15%')), 0) AS "MONTO IVA 15",
 
 
 ifnull(T."U_SYP_ICE", 0) AS "MONTO ICE",
 T."DocTotal" AS "TOTAL VENTA",
 ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'IVA'
   AND P2."U_SYP_PORCN_RET" IS NOT NULL
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0) AS "RET. IVA",
 ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'FTE'
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0) AS "RET. FUENTE",
 (T."DocTotal"
 - ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'IVA'
   AND P2."U_SYP_PORCN_RET" IS NOT NULL
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0)
 - ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'FTE'
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0)
 ) AS "VENTAS RETENCIONES",
 ifnull(T."U_SYP_CASILLA104", '') AS "CASILLA 104",
 
 
 ifnull((SELECT
   MAX(C."DIAS")
 FROM (SELECT
   (ifnull("InstMonth", IFNULL(B1."ExtraMonth",0)) * 30) + ifnull("InstDays", IFNULL("ExtraDays",0)) "DIAS"
 FROM "OCTG" B1
 LEFT JOIN "CTG1" B2
   ON B1."GroupNum" = B2."CTGCode"
 WHERE B1."GroupNum" = T."GroupNum") C), 0) "DIAS CREDT",
 
 
 CASE
   WHEN ifnull(T."U_SYP_FORMAP", '') = '' THEN CASE
       WHEN ifnull(T2."U_SYP_FPAGO", '') = '' THEN '00'
       ELSE T2."U_SYP_FPAGO"
     END
   ELSE T."U_SYP_FORMAP"
 END "FORMA PAGO1",
 T."U_SYP_FORMAPAGO2" "FORMA PAGO2",
 '' "TIPO COMPENSA",
 0 "MONTO COMPENSA",
 COALESCE(T."U_SYP_EXPORTACION", 'NO') "EXPORTACION",
 ifnull(T."U_SYP_EX_PAIS", NULL) "PAIS EFEC EXPRT",
 '' "PAGO REG FISCAL",
 T."U_SYP_EXPORTACIONDE" "EXPORTACION DE",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_DISTADUANERO", '')
   ELSE NULL
 END AS "DIST ADUANERO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_ANIOREF", '')
   ELSE NULL
 END AS "ANIO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REGIMEN", '')
   ELSE NULL
 END AS "REGIMEN",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REFRENDO_CORR", '')
   ELSE NULL
 END AS "CORRELATIVO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_TRANSPREF", '')
   ELSE NULL
 END AS "DOC TRANSP",
 CAST(ifnull(T."U_SYP_MDFE", T."DocDate") AS datetime) "FCH EMBARQUE",
 COALESCE(T."U_SYP_VALORFOB", 0) "VALOR FOB",
 T."DocTotal" "VALOR FOB COMPROBANTE",
 T."U_SYP_TIPOREGI" AS "TIPO REG",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '01' THEN T."U_SYP_PAISPAGOGEN"
   ELSE 'NA'
 END AS "PAIS PAG GEN",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '02' THEN ifnull(T."U_SYP_PAISPAG_PARFIS", '000')
   ELSE NULL
 END AS "PAIS PAG PAR FIS",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '03' THEN ifnull(T."U_SYP_DENOPAGO", '')
   ELSE NULL
 END AS "DENO PAGO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_TIP_INGEXT", '')
   ELSE NULL
 END AS "TIPO INGRESO EXT",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_INGEXT_GRVOTRP", '')
   ELSE NULL
 END AS "ING EXT GRAV OTRO PAIS",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN (CASE
       WHEN T."U_SYP_IMP_OTRPAIS" > 0 THEN T."U_SYP_IMP_OTRPAIS"
       ELSE NULL
     END)
   ELSE NULL
 END AS "IMP OTRO PAIS"
FROM "OINV" T
INNER JOIN "OCRD" T2
 ON (T."CardCode" = T2."CardCode")
LEFT JOIN "OCTG" T3
 ON T."GroupNum" = T3."GroupNum"
INNER JOIN "@SYP_TPODOC" T4
 ON T4."Code" = T."U_SYP_MDTD"
 AND ifnull(T4."U_SYP_DIN", 'N') = 'N'
 AND ifnull(T4."U_SYP_ESTADO", 'N') = 'Y'
 AND (ifnull(T4."U_SYP_REGVEN", 'N') = 'Y'
 OR ifnull(T4."U_SYP_REGEXP", 'N') = 'Y')
 AND ifnull(T4."U_SYP_REGINT", 'N') = 'N'
INNER JOIN "@SYP_NUMDOC" T4B
 ON T4B."Code" = T4."Code"
 AND ifnull(T4B."U_SYP_NDAI", 'N') = 'Y'
 AND T4B."U_SYP_NDCE" = T."U_SYP_SERIESUC"
 AND T4B."U_SYP_NDSD" = T."U_SYP_MDSD"
LEFT JOIN "@SYP_TIPIDENT" T5
 ON T2."U_SYP_BPTD" = T5."Code"
WHERE T."CANCELED" = 'N'
AND T."U_SYP_STATUS" = 'V'
AND T."DocDate" BETWEEN :FECHA_INI AND :FECHA_FIN


--=======================================================
UNION
--=======================================================


SELECT
 ifnull(T."U_SYP_MDTD", '') AS "COD DOC",
 (SELECT
   "U_SYP_TDDD"
 FROM "@SYP_TPODOC" C1
 WHERE C1."Code" = T."U_SYP_MDTD")
 AS "DESCRIP DOC",
 case when  T5."U_SYP_CODVTA"= '06' then '21' else T5."U_SYP_CODVTA" end 
   AS "TIP. IDENTF",
 T2."LicTradNum" AS "IDENTIFICACION",
 T2."CardName" AS "RAZON SOCIAL",
 CASE
   WHEN (CASE
       WHEN COALESCE(T."U_SYP_EXPORTACION", 'NO') = 'SI' THEN T5."U_SYP_CODEXP"
       ELSE T5."U_SYP_CODVTA"
     END) = '07' THEN NULL
   ELSE T2."U_SYP_PARTREL"
 END AS "PARTE REL",
 T2."U_SYP_TIPPROV" AS "TIP SUJETO",
 'V' AS "TIP. ANEXO",
 'S' AS "TIP. OPERAC",
 CASE
   WHEN ifnull(T4B."U_SYP_NDFE", '') = 'Y' THEN 'E'
   ELSE 'F'
 END "EMISION",
 T."U_SYP_SERIESUC" AS "COD ESTAB",
 T."U_SYP_MDSD" AS "PTO VTA",
 T."U_SYP_MDCD" AS "SECUENC.",
 ifnull(T."U_SYP_NROAUTO", '') AS "NRO AUTORIZACION",
 T."DocDate" AS "FCHA EMISI.",
 ifnull(T."U_SYP_FECHAUTOR", '') AS "FCHA AUTORIZACION",
 ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" IN ('baseImpExe', 'baseImponible'))), 0) AS "BASE %0",
 CAST( '0.00' AS decimal(19, 2))  AS "BASE DIF%0 REEMB",
 
  ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav5%')), 0) AS "BASE %5",
  ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav8%')), 0) AS "BASE %8",
 
 ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "BASE %12",
 ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "BASE %14",
 
 
  ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav15%')), 0) AS "BASE %15",
 
 
 ifnull((SELECT
   CAST(SUM("BaseSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseNoGraIva%')), 0) AS "BASE NO OBJ",
 1 AS "NO. COMPROBANTES",
 
 
  ifnull((SELECT
   CAST(SUM("TaxSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav5%')), 0) AS "MONTO IVA 5",
  ifnull((SELECT
   CAST(SUM("TaxSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav8%')), 0) AS "MONTO IVA 8",
 
 
 ifnull((SELECT
   CAST(SUM("TaxSum") * -1 AS decimal(19, 2)) AS "Expr1"
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "MONTO IVA 12",
 ifnull((SELECT
   CAST(SUM("TaxSum") * -1 AS decimal(19, 2)) AS Expr1
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "MONTO IVA 14",
 
 ifnull((SELECT
   CAST(SUM("TaxSum") * -1 AS decimal(19, 2)) AS Expr1
 FROM "RIN4" AS X
 INNER JOIN "RIN1" X1
   ON (X."DocEntry" = X1."DocEntry"
   AND X."LineNum" = X1."LineNum")
 WHERE X."DocEntry" = T."DocEntry"
 AND "StaCode" IN (SELECT
   "Code"
 FROM "@SYP_IVA_FE_ATS"
 WHERE "U_SYP_COLATS" LIKE '%baseImpGrav15%')), 0) AS "MONTO IVA 15",
 
 
 ifnull(T."U_SYP_ICE", 0) AS "MONTO ICE",
 T."DocTotal" * -1 AS "TOTAL VENTA",
 0 AS "RET. IVA",
 0 AS "RET. FUENTE",
 (T."DocTotal" - T."PaidToDate") * -1 AS "VENTAS RETENCIONES",
 ifnull(T."U_SYP_CASILLA104", '') AS "CASILLA 104",
 
 
 ifnull((SELECT
   MAX(C."DIAS")
 FROM (SELECT
   (ifnull("InstMonth", IFNULL(B1."ExtraMonth",0)) * 30) + ifnull("InstDays", IFNULL("ExtraDays",0)) "DIAS"
 FROM "OCTG" B1
 LEFT JOIN "CTG1" B2
   ON B1."GroupNum" = B2."CTGCode"
 WHERE B1."GroupNum" = T."GroupNum") C), 0) "DIAS CREDT",
 
 
 
 T."U_SYP_FORMAP" "FORMA PAGO1",
 T."U_SYP_FORMAPAGO2" "FORMA PAGO2",
 '' "TIPO COMPENSA",
 0 "MONTO COMPENSA",
 COALESCE(T."U_SYP_EXPORTACION", 'NO') "EXPORTACION",
 ifnull(T."U_SYP_EX_PAIS", NULL) "PAIS EFEC EXPRT",
 '' "PAGO REG FISCAL",
 T."U_SYP_EXPORTACIONDE" "EXPORTACION DE",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_DISTADUANERO", '')
   ELSE NULL
 END "DIST ADUANERO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_ANIOREF", '')
   ELSE NULL
 END "ANIO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REGIMEN", '')
   ELSE NULL
 END "REGIMEN",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REFRENDO_CORR", '')
   ELSE NULL
 END "CORRELATIVO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_TRANSPREF", '')
   ELSE NULL
 END "DOC TRANSP",
 CAST(ifnull(T."U_SYP_MDFE", T."DocDate") AS date) "FCH EMBARQUE",
 COALESCE(T."U_SYP_VALORFOB", 0) "VALOR FOB",
 T."DocTotal" "VALOR FOB COMPROBANTE",
 T."U_SYP_TIPOREGI" AS "TIPO REG",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '01' THEN T."U_SYP_PAISPAGOGEN"
   ELSE 'NA'
 END AS "PAIS PAG GEN",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '02' THEN ifnull(T."U_SYP_PAISPAG_PARFIS", '000')
   ELSE NULL
 END AS "PAIS PAG PAR FIS",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '03' THEN ifnull(T."U_SYP_DENOPAGO", '')
   ELSE NULL
 END AS "DENO PAGO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_TIP_INGEXT", '')
   ELSE NULL
 END AS "TIPO INGRESO EXT",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_INGEXT_GRVOTRP", '')
   ELSE NULL
 END AS "ING EXT GRAV OTRO PAIS",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN (CASE
       WHEN T."U_SYP_IMP_OTRPAIS" > 0 THEN T."U_SYP_IMP_OTRPAIS"
       ELSE NULL
     END)
   ELSE NULL
 END AS "IMP OTRO PAIS"
FROM "ORIN" T
INNER JOIN "OCRD" T2
 ON (T."CardCode" = T2."CardCode")
LEFT JOIN "OCTG" T3
 ON T."GroupNum" = T3."GroupNum"
INNER JOIN "@SYP_TPODOC" T4
 ON T4."Code" = T."U_SYP_MDTD"
 AND ifnull(T4."U_SYP_DIN", 'N') = 'N'
 AND ifnull(T4."U_SYP_ESTADO", 'N') = 'Y'
 AND (ifnull(T4."U_SYP_REGVEN", 'N') = 'Y'
 OR ifnull(T4."U_SYP_REGEXP", 'N') = 'Y')
 AND ifnull(T4."U_SYP_REGINT", 'N') = 'N'
INNER JOIN "@SYP_NUMDOC" T4B
 ON T4B."Code" = T4."Code"
 AND ifnull(T4B."U_SYP_NDAI", 'N') = 'Y'
 AND T4B."U_SYP_NDCE" = T."U_SYP_SERIESUC"
 AND T4B."U_SYP_NDSD" = T."U_SYP_MDSD"
LEFT JOIN "@SYP_TIPIDENT" T5
 ON T2."U_SYP_BPTD" = T5."Code"
WHERE T."CANCELED" = 'N'
AND T."U_SYP_STATUS" = 'V'
AND T."DocDate" BETWEEN :FECHA_INI AND :FECHA_FIN


--=======================================================
UNION
-- RETENCIONES DE FACTURAS VINCULADAS AL PERIODO ANTERIOR
--=======================================================

SELECT DISTINCT
 ifnull(T."U_SYP_MDTD", '') AS "COD DOC",
 (SELECT
   "U_SYP_TDDD"
 FROM "@SYP_TPODOC" C1
 WHERE C1."Code" = T."U_SYP_MDTD")
 AS "DESCRIP DOC",
 T5."U_SYP_CODVTA" AS "TIP. IDENTF",
 T2."LicTradNum" AS "IDENTIFICACION",
 T2."CardName" AS "RAZON SOCIAL",
 CASE
   WHEN T5."U_SYP_CODVTA" = '07' THEN NULL
   ELSE T2."U_SYP_PARTREL"
 END AS "PARTE REL",
 T2."U_SYP_TIPPROV" AS "TIP SUJETO",
 'V' AS "TIP. ANEXO",
 'A' AS "TIP. OPERAC",
 CASE
   WHEN ifnull(T4B."U_SYP_NDFE", '') = 'Y' THEN 'E'
   ELSE 'F'
 END "EMISION",
 T."U_SYP_SERIESUC" AS "COD ESTAB",
 T."U_SYP_MDSD" AS "PTO VTA",
 T."U_SYP_MDCD" AS "SECUENC.",
 ifnull(T."U_SYP_NROAUTO", '') AS "NRO AUTORIZACION",
 CAST(T."DocDate" AS date) AS "FCHA EMISI.",
 ifnull(CAST(T."U_SYP_FECHAUTOR" AS date), '') AS "FCHA AUTORIZACION",
 0 AS "BASE %0",
 CAST ('0.00' AS DECIMAL(19,2)) AS "BASE DIF%0 REEMB",
 0 AS "BASE %5",
 0 AS "BASE %8",
 0 AS "BASE %12",
 0 AS "BASE %14",
 0 AS "BASE %15",
 0 AS "BASE NO OBJ",
 0 AS "NO. COMPROBANTES",
 0 AS "MONTO IVA 5",
 0 AS "MONTO IVA 8",
 0 AS "MONTO IVA 12",
 0 AS "MONTO IVA 14",
 0 AS "MONTO IVA 15",
 0 AS "MONTO ICE",
 0 AS "TOTAL VENTA",
 ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'IVA'
   AND P2."U_SYP_PORCN_RET" IS NOT NULL
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0) AS "RET. IVA",
 ifnull((SELECT
   SUM(P1."SumApplied")
 FROM "ORCT" P0
 INNER JOIN "RCT2" P1
   ON (P0."DocEntry" = P1."DocNum")
 INNER JOIN "@SYP_TOPER" P2
   ON (P0."U_SYP_TIPOOPERACION" = P2."Code"
   AND P2."U_SYP_BASERET" = 'FTE'
   AND P2."U_SYP_ISRET" = 'Y')
 WHERE P1."DocEntry" = T."DocEntry"
 AND P0."Canceled" = 'N'), 0) AS "RET. FUENTE",
 0 "VENTAS RETENCIONES",
 ifnull(T."U_SYP_CASILLA104", '') AS "CASILLA 104",
 T3."ExtraDays" "DIAS CREDT",
 CASE
   WHEN ifnull(T."U_SYP_FORMAP", '') = '' THEN CASE
       WHEN ifnull(T2."U_SYP_FPAGO", '') = '' THEN '00'
       ELSE T2."U_SYP_FPAGO"
     END
   ELSE T."U_SYP_FORMAP"
 END "FORMA PAGO1",
 T."U_SYP_FORMAPAGO2" "FORMA PAGO2",
 '' "TIPO COMPENSA",
 0 "MONTO COMPENSA",
 COALESCE(T."U_SYP_EXPORTACION", 'NO') "EXPORTACION",
 ifnull(T."U_SYP_EX_PAIS", NULL) "PAIS EFEC EXPRT",
 '' "PAGO REG FISCAL",
 T."U_SYP_EXPORTACIONDE" "EXPORTACION DE",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_DISTADUANERO", '')
   ELSE NULL
 END AS "DIST ADUANERO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_ANIOREF", '')
   ELSE NULL
 END AS "ANIO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REGIMEN", '')
   ELSE NULL
 END AS "REGIMEN",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_REFRENDO_CORR", '')
   ELSE NULL
 END AS "CORRELATIVO REF",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '01' THEN ifnull(T."U_SYP_TRANSPREF", '')
   ELSE NULL
 END AS "DOC TRANSP",
 CAST(ifnull(T."U_SYP_MDFE", T."DocDate") AS date) "FCH EMBARQUE",
 0 "VALOR FOB",
 0 "VALOR FOB COMPROBANTE",
 T."U_SYP_TIPOREGI" AS "TIPO REG",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '01' THEN T."U_SYP_PAISPAGOGEN"
   ELSE 'NA'
 END AS "PAIS PAG GEN",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '02' THEN ifnull(T."U_SYP_PAISPAG_PARFIS", '000')
   ELSE NULL
 END AS "PAIS PAG PAR FIS",
 CASE
   WHEN T."U_SYP_TIPOREGI" = '03' THEN ifnull(T."U_SYP_DENOPAGO", '')
   ELSE NULL
 END AS "DENO PAGO",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_TIP_INGEXT", '')
   ELSE NULL
 END AS "TIPO INGRESO EXT",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN ifnull(T."U_SYP_INGEXT_GRVOTRP", '')
   ELSE NULL
 END AS "ING EXT GRAV OTRO PAIS",
 CASE
   WHEN T."U_SYP_EXPORTACIONDE" = '03' THEN (CASE
       WHEN T."U_SYP_IMP_OTRPAIS" > 0 THEN T."U_SYP_IMP_OTRPAIS"
       ELSE NULL
     END)
   ELSE NULL
 END AS "IMP OTRO PAIS"
FROM "ORCT" P0
INNER JOIN "RCT2" P1
 ON P0."DocEntry" = P1."DocNum"
INNER JOIN "OINV" T
 ON P1."DocEntry" = T."DocEntry"
INNER JOIN "OCRD" T2
 ON T."CardCode" = T2."CardCode"
LEFT JOIN "OCTG" T3
 ON T."GroupNum" = T3."GroupNum"
INNER JOIN "@SYP_TPODOC" T4
 ON T4."Code" = T."U_SYP_MDTD"
 AND ifnull(T4."U_SYP_DIN", 'N') = 'N'
 AND ifnull(T4."U_SYP_ESTADO", 'N') = 'Y'
 AND (ifnull(T4."U_SYP_REGVEN", 'N') = 'Y'
 OR ifnull(T4."U_SYP_REGEXP", 'N') = 'Y')
 AND ifnull(T4."U_SYP_REGINT", 'N') = 'N'
INNER JOIN "@SYP_NUMDOC" T4B
 ON T4B."Code" = T4."Code"
 AND ifnull(T4B."U_SYP_NDAI", 'N') = 'Y'
 AND T4B."U_SYP_NDCE" = T."U_SYP_SERIESUC"
 AND T4B."U_SYP_NDSD" = T."U_SYP_MDSD"
LEFT JOIN "@SYP_TIPIDENT" T5
 ON T2."U_SYP_BPTD" = T5."Code"
WHERE T."CANCELED" = 'N'
AND T."U_SYP_STATUS" = 'V'
AND P0."U_SYP_FECHARET" BETWEEN :FECHA_INI AND :FECHA_FIN
AND T."DocDate" < :FECHA_INI

UNION


SELECT DISTINCT
'18' as "COD DOC"
,'Deposito Tarjeta Credito' as "DESCRIP DOC"
,T5."U_SYP_CODVTA" AS "TIP. IDENTF"
,T2."LicTradNum" as "IDENTIFICACION"
,T2."CardName" as "RAZON SOCIAL"
,CASE WHEN T5."U_SYP_CODVTA" = '07'
THEN NULL
ELSE T2."U_SYP_PARTREL"
END AS  "PARTE REL"
,T2."U_SYP_TIPPROV" as "TIP SUJETO"
,'V' as "TIP. ANEXO"
,'A' as "TIP. OPERAC"
,T0."U_SYP_TIPO_EMIS" as "EMISION"
,T0."U_SYP_SERIESUC" as "COD ESTAB"
,T0."U_SYP_MDSD" as "PTO VTA"
,T0."U_SYP_MDCD" as "SECUENC."
,IFNULL(T0."U_SYP_NROAUTO",'') as "NRO AUTORIZACION"
,T0."DeposDate" as "FCHA EMISI."
,T0."U_SYP_FECHAUTOR" as "FCHA AUTORIZACION"
,0 AS "BASE %0"
,0 AS "BASE DIF%0 REEMB"
,0 AS "BASE %5"
,0 AS "BASE %8"
,0 AS "BASE %12"
,0 AS "BASE %14"
,0 AS "BASE %15"
,0 AS "BASE NO OBJ"
,0 as "NO. COMPROBANTES"
,0 AS "MONTO IVA 5"
,0 AS "MONTO IVA 8"
,0 AS "MONTO IVA 12"
,0 AS "MONTO IVA 14"
,0 AS "MONTO IVA 15"
,0 as "MONTO ICE"
,0 as "TOTAL VENTA"
,IFNULL(T0."Comission",0) as "RET. IVA"
,IFNULL(T0."VatTotal",0) as "RET. FUENTE"
,0 "VENTAS RETENCIONES"
,'' as "CASILLA 104"
,0 AS "DIAS CREDT"
, '19' AS  "FORMA PAGO1"  
, '' AS "FORMA PAGO2"
, '' AS "TIPO COMPENSA"
, 0 "MONTO COMPENSA"
, 'NO' AS "EXPORTACION"
, '' AS "PAIS EFEC EXPRT"
, '' AS "PAGO REG FISCAL"
, '' AS "EXPORTACION DE"
            , '' AS "DIST ADUANERO"
            , '' AS "ANIO REF"
            , '' AS "REGIMEN"
            , '' AS "CORRELATIVO REF"
            , '' AS "DOC TRANSP"
, '' AS  "FCH EMBARQUE"
, 0 "VALOR FOB"
, 0 "VALOR FOB COMPROBANTE"
            , '' AS "TIPO REG"
            , 'NA' AS "PAIS PAG GEN"
            , '' AS "PAIS PAG PAR FIS"
            , '' AS "DENO PAGO"
            , '' AS "TIPO INGRESO EXT"
            , '' AS "ING EXT GRAV OTRO PAIS"
            , 0 AS "IMP OTRO PAIS"  
FROM "ODPS" T0  
INNER JOIN "OCRD" T2 on T0."U_SYP_IDSN" = T2."CardCode"
   LEFT JOIN "@SYP_TIPIDENT" T5 ON T2."U_SYP_BPTD" = T5."Code"
  WHERE T0."DeposType" ='V'
    AND T0."Canceled" = 'N'
    AND T0."CnclDps" = -1
AND T0."DeposDate" BETWEEN :FECHA_INI AND :FECHA_FIN ;


END;
