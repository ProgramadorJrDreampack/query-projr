SELECT
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T6."U_SYP_CODCOM"        AS "TIP. IDENTF",
    T5."LicTradNum"           AS "IDENTIFICACION",
    T."CardName"              AS "RAZON SOCIAL",
    T5."U_SYP_TCONTRIB"      AS "TIP CONTRIB",
    T5."U_SYP_PARTREL"       AS "PART. RELC",
    T5."U_SYP_TIPPROV"       AS "TIP SUJETO",
    T."U_SYP_MDTD"           AS "TIP. DOC",
    T."U_SYP_SERIESUC"       AS "ESTB. DOC",
    T."U_SYP_MDSD"           AS "PTO. EMI. DOC",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImponible%'  THEN T2."BaseSum" ELSE 0 END) AS "BASE %0",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%'   THEN T2."BaseSum" ELSE 0 END) AS "BASE GRAV 5%",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%'  THEN T2."BaseSum" ELSE 0 END) AS "BASE GRAV 15%",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseNoGraIva%'   THEN T2."BaseSum" ELSE 0 END) AS "BASE NO OBJETO",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpExe%'     THEN T2."BaseSum" ELSE 0 END) AS "BASE EXCENTA IVA",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%'   THEN T2."TaxSum"  ELSE 0 END) AS "MONTO IVA 5%",
    (SELECT "U_NAME" FROM "OUSR" WHERE "USERID" = T."UserSign") AS "USUARIO"

FROM OPCH T
INNER JOIN "PCH1" T1 ON T."DocEntry" = T1."DocEntry"
INNER JOIN "PCH4" T2 ON T."DocEntry" = T2."DocEntry" AND T1."LineNum" = T2."LineNum"
LEFT  JOIN "@SYP_IVA_FE_ATS" T4 ON T4."Code" = T2."StaCode"
INNER JOIN "OCRD" T5 ON T."CardCode" = T5."CardCode"
LEFT  JOIN "@SYP_TIPIDENT" T6 ON T5."U_SYP_BPTD" = T6."Code"
INNER JOIN "NNM1" T7 ON T."Series" = T7."Series"
LEFT  JOIN "PDN1" T8 ON T8."DocEntry" = T1."BaseEntry"
    AND T8."LineNum" = T1."BaseLine"
    AND T8."ObjType" = T1."BaseType"
INNER JOIN "@SYP_TPODOC" T9 ON T9."Code" = T."U_SYP_MDTD"
    AND IFNULL(T9."U_SYP_DIN",    'N') = 'N'
    AND IFNULL(T9."U_SYP_ESTADO", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGCOM", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGINT", 'N') = 'N'
WHERE T."CANCELED" = 'N'
    AND T."U_SYP_STATUS" IN ('V')
    AND T2."RelateType" NOT IN (11, 3)
    AND T."DocDate" BETWEEN [%0] AND [%1]

GROUP BY
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T6."U_SYP_CODCOM",
    T5."LicTradNum",
    T."CardName",
    T5."U_SYP_TCONTRIB",
    T5."U_SYP_PARTREL",
    T5."U_SYP_TIPPROV",
    T."U_SYP_MDTD",
    T."U_SYP_SERIESUC",
    T."U_SYP_MDSD",
    T."UserSign"

UNION ALL

SELECT
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T6."U_SYP_CODCOM"        AS "TIP. IDENTF",
    T5."LicTradNum"           AS "IDENTIFICACION",
    T."CardName"              AS "RAZON SOCIAL",
    T5."U_SYP_TCONTRIB"      AS "TIP CONTRIB",
    T5."U_SYP_PARTREL"       AS "PART. RELC",
    T5."U_SYP_TIPPROV"       AS "TIP SUJETO",
    T."U_SYP_MDTD"           AS "TIP. DOC",
    T."U_SYP_SERIESUC"       AS "ESTB. DOC",
    T."U_SYP_MDSD"           AS "PTO. EMI. DOC",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImponible%'  THEN T2."BaseSum" ELSE 0 END) AS "BASE %0",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%'   THEN T2."BaseSum" ELSE 0 END) AS "BASE GRAV 5%",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%'  THEN T2."BaseSum" ELSE 0 END) AS "BASE GRAV 15%",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseNoGraIva%'   THEN T2."BaseSum" ELSE 0 END) AS "BASE NO OBJETO",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpExe%'     THEN T2."BaseSum" ELSE 0 END) AS "BASE EXCENTA IVA",
    SUM(CASE WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%'   THEN T2."TaxSum"  ELSE 0 END) AS "MONTO IVA 5%",
    (SELECT "U_NAME" FROM "OUSR" WHERE "USERID" = T."UserSign") AS "USUARIO"

FROM OPCH T
INNER JOIN PCH3 T1 ON T."DocEntry" = T1."DocEntry"
INNER JOIN "PCH4" T2 ON T."DocEntry" = T2."DocEntry" AND T1."LineNum" = T2."LineNum"
LEFT  JOIN "@SYP_IVA_FE_ATS" T4 ON T4."Code" = T2."StaCode"
INNER JOIN "OCRD" T5 ON T."CardCode" = T5."CardCode"
LEFT  JOIN "@SYP_TIPIDENT" T6 ON T5."U_SYP_BPTD" = T6."Code"
INNER JOIN "NNM1" T7 ON T."Series" = T7."Series"
INNER JOIN "@SYP_TPODOC" T9 ON T9."Code" = T."U_SYP_MDTD"
    AND IFNULL(T9."U_SYP_DIN",    'N') = 'N'
    AND IFNULL(T9."U_SYP_ESTADO", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGCOM", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGINT", 'N') = 'N'
WHERE T."CANCELED" = 'N'
    AND T."U_SYP_STATUS" IN ('V')
    AND T2."RelateType" NOT IN (11, 1)
    AND T1."WTLiable" = 'Y'
    AND T."DocDate" BETWEEN [%0] AND [%1]

GROUP BY
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T6."U_SYP_CODCOM",
    T5."LicTradNum",
    T."CardName",
    T5."U_SYP_TCONTRIB",
    T5."U_SYP_PARTREL",
    T5."U_SYP_TIPPROV",
    T."U_SYP_MDTD",
    T."U_SYP_SERIESUC",
    T."U_SYP_MDSD",
    T."UserSign";