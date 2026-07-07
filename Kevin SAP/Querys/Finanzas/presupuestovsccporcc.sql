SELECT * FROM (

    SELECT
        'PRESUPUESTO'        AS "Tipo",
        CAB."U_TM_PC"        AS "Anio",
        LIN."U_TM_AR"        AS "AreaResponsable",
        LIN."U_TM_NOMBCC"    AS "NombreCC",
        LIN."U_TM_CC"        AS "CentroCosto",
        LIN."U_TM_CTAC"      AS "Cuenta",
        LIN."U_TM_NOMCTAC"   AS "NombreCuenta",
        LIN."U_TM_RUBRO"     AS "Rubro",
        LIN."U_TM_ENE"  AS "ENE", LIN."U_TM_FEB" AS "FEB", LIN."U_TM_MAR" AS "MAR",
        LIN."U_TM_ABR"  AS "ABR", LIN."U_TM_MAY" AS "MAY", LIN."U_TM_JUN" AS "JUN",
        LIN."U_TM_JUL"  AS "JUL", LIN."U_TM_AGO" AS "AGO", LIN."U_TM_SEP" AS "SEP",
        LIN."U_TM_OCT"  AS "OCT", LIN."U_TM_NOV" AS "NOV", LIN."U_TM_DIC" AS "DIC"
    FROM "@TM_PRECC_LIN" LIN
    INNER JOIN "@TM_PRECC_CAB" CAB ON CAB."Code" = LIN."Code"
    WHERE CAB."U_TM_PC" = TO_NVARCHAR([%0])

    UNION ALL

    SELECT
        'REAL'                 AS "Tipo",
        TO_NVARCHAR([%0])      AS "Anio",
        NULL                   AS "AreaResponsable",
        NULL                   AS "NombreCC",
        T1."OcrCode4"          AS "CentroCosto",
        T0."AcctCode"          AS "Cuenta",
        T0."AcctName"          AS "NombreCuenta",
        NULL                   AS "Rubro",
        SUM(CASE WHEN MONTH(T1."RefDate") =  1 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "ENE",
        SUM(CASE WHEN MONTH(T1."RefDate") =  2 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "FEB",
        SUM(CASE WHEN MONTH(T1."RefDate") =  3 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "MAR",
        SUM(CASE WHEN MONTH(T1."RefDate") =  4 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "ABR",
        SUM(CASE WHEN MONTH(T1."RefDate") =  5 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "MAY",
        SUM(CASE WHEN MONTH(T1."RefDate") =  6 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "JUN",
        SUM(CASE WHEN MONTH(T1."RefDate") =  7 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "JUL",
        SUM(CASE WHEN MONTH(T1."RefDate") =  8 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "AGO",
        SUM(CASE WHEN MONTH(T1."RefDate") =  9 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "SEP",
        SUM(CASE WHEN MONTH(T1."RefDate") = 10 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "OCT",
        SUM(CASE WHEN MONTH(T1."RefDate") = 11 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "NOV",
        SUM(CASE WHEN MONTH(T1."RefDate") = 12 THEN T1."Debit" - T1."Credit" ELSE 0 END) AS "DIC"
    FROM OACT T0
    INNER JOIN JDT1 T1 ON T0."AcctCode" = T1."Account"
    WHERE YEAR(T1."RefDate") = [%0]
      AND T1."OcrCode4" IS NOT NULL AND T1."OcrCode4" <> ''
     AND LEFT(T0."AcctCode", 2) IN ('50', '60', '70')
    GROUP BY T1."OcrCode4", T0."AcctCode", T0."AcctName", YEAR(T1."RefDate")

)
ORDER BY "Cuenta",  "CentroCosto",
    CASE "Tipo" WHEN 'PRESUPUESTO' THEN 1 ELSE 2 END