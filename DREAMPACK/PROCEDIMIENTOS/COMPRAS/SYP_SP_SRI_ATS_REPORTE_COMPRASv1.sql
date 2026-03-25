CREATE PROCEDURE "SYP_SP_SRI_ATS_REPORTE_COMPRAS"(
    IN FECHA_INI DATETIME,
    IN FECHA_FIN DATETIME,
    OUT TMP SYP_TEMP_COMPRAS
) READS SQL DATA WITH RESULT VIEW SYP_SP_SRI_ATS_REPORTE_COMPRAS_VIEW AS BEGIN TMP =
SELECT
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T1."LineNum",
    T1."U_SYP_CODIDTRD" AS "SUST. TRIB",
    T6."U_SYP_CODCOM" AS "TIP. IDENTF",
    T5."LicTradNum" AS "IDENTIFICACION",
    T."CardName" AS "RAZON SOCIAL",
    T5."U_SYP_TCONTRIB" AS "TIP CONTRIB",
    T5."U_SYP_PARTREL" AS "PART. RELC",
    T5."U_SYP_TIPPROV" as "TIP SUJETO",
    T."U_SYP_MDTD" AS "TIP. DOC",
    "U_SYP_SERIESUC" AS "ESTB. DOC",
    "U_SYP_MDSD" AS "PTO. EMI. DOC",
    RIGHT(
        LPAD('0', 9) || CAST("U_SYP_MDCD" AS VARCHAR(9)),
        9
    ) AS "SEC. DOC",
    CASE
        WHEN IFNULL((RTRIM(LTRIM("U_SYP_NROAUTO"))), '') = '' THEN MAP(
            T."U_SYP_MDTD",
            '03',
(
                MAP(
                    (TRIM("U_SYP_NROAUTO_LC")),
                    '',
                    'SINAUTORIZACION',
                    TRIM("U_SYP_NROAUTO_LC")
                )
            ),
            '41',
(
                MAP(
                    (TRIM("U_SYP_NROAUTO_LC")),
                    '',
                    'SINAUTORIZACION',
                    TRIM("U_SYP_NROAUTO_LC")
                )
            ),
            'SINAUTORIZACION'
        )
        ELSE RTRIM(LTRIM("U_SYP_NROAUTO"))
    END AS "AUTORIZACION",
    CAST(T."TaxDate" AS TIMESTAMP) "FCH EMIS.",
    CAST(T."DocDate" AS TIMESTAMP) "FCH REGIS.",
    CAST(
        IFNULL(
            (
                SELECT
                    "U_SYP_FECHAS"
                FROM
                    (
                        SELECT
                            C1."U_SYP_FECHAS",
                            ROW_NUMBER() OVER(
                                ORDER BY
                                    (
                                        SELECT
                                            1
                                        from
                                            dummy
                                    )
                            ) AS ROWNUM
                        FROM
                            "@SYP_CCODAUT" C1
                        WHERE
                            C1."U_SYP_NROID" = T."CardCode"
                            AND C1."U_SYP_TIPDOC" = T."U_SYP_MDTD"
                            AND C1."U_SYP_SERIESUC" = T."U_SYP_SERIESUC"
                            AND C1."U_SYP_SERIEVTA" = T."U_SYP_MDSD"
                            AND T."TaxDate" >= C1."U_SYP_FECINI"
                            AND T."U_SYP_NROAUTO" = C1."U_SYP_NROAUT"
                    ) A
                where
                    a.rownum = 1
            ),
            T."TaxDate"
        ) AS TIMESTAMP
    ) AS "FCH VENCI",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImponible%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE %0",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE GRAV 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE GRAV 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE GRAV 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE GRAV 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE GRAV 15%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseNoGraIva%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE NO OBJETO",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpExe%' THEN T2."BaseSum"
        ELSE 0.00
    END "BASE EXCENTA IVA",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN T2."TaxSum"
        ELSE 0.00
    END "MONTO IVA 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN T2."TaxSum"
        ELSE 0.00
    END "MONTO IVA 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN T2."TaxSum"
        ELSE 0.00
    END "MONTO IVA 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN T2."TaxSum"
        ELSE 0.00
    END "MONTO IVA 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN T2."TaxSum"
        ELSE 0.00
    END "MONTO IVA 15%",
    CAST(
        CASE
            WHEN (
                SELECT
                    SUM(C5."LineTotal")
                FROM
                    "PCH1" C5
                WHERE
                    T."DocEntry" = C5."DocEntry"
                    AND C5."U_SYP_APLICA_ICE" = 'SI'
            ) > 0
            AND T1."U_SYP_APLICA_ICE" = 'SI' THEN (T1."LineTotal" * IFNULL(T."U_SYP_ICE", 0)) / (
                SELECT
                    SUM(C5."LineTotal")
                FROM
                    "PCH1" C5
                WHERE
                    T."DocEntry" = C5."DocEntry"
                    AND C5."U_SYP_APLICA_ICE" = 'SI'
            )
            ELSE 0
        END AS DECIMAL(24, 6)
    ) AS "MONTO ICE",
    IFNULL(
        (
            SELECT
                B1."U_SYP_CODSRI"
            FROM
                "PCH5" C5
                LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
            WHERE
                T."DocEntry" = C5."AbsEntry"
                AND T1."U_SYP_RET_IVA" = C5."WTCode"
                AND C5."BaseType" = 'V'
        ),
        ''
    ) AS "COD RET IVA",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 10
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 10%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 20
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 20%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 30
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 30%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 50
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 50%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 70
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 70%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 100
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 100%",
    CAST(T2."BaseSum" AS DECIMAL(24, 6)) AS "BASE IMP",
    (
        SELECT
            B1."U_SYP_CODSRI"
        FROM
            "PCH5" C5
            LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
        WHERE
            T."DocEntry" = C5."AbsEntry"
            AND T1."U_SYP_CODIGO_RET" = C5."WTCode"
            AND C5."BaseType" = 'N'
    ) AS "COD RET FUENTE",
(
        SELECT
            C5."Rate"
        FROM
            "PCH5" C5
        WHERE
            T."DocEntry" = C5."AbsEntry"
            AND T1."U_SYP_CODIGO_RET" = "WTCode"
    ) AS "% RET FUENTE",
    CAST(
        T2."BaseSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_CODIGO_RET" = "WTCode"
                    AND C5."BaseType" = 'N'
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "VALOR RETENIDO",
    T."U_SYP_TIPOPAGO" "TIPO DE PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE T."U_SYP_PAISP"
    END "PAIS DE PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE ''
    END "PARAISO FISCAL",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE IFNULL(T.U_SYP_ADTPAGO, 'NO')
    END "ADOBLE TRIB EN PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE IFNULL(T.U_SYP_PESRET, 'NO')
    END "SUJE. RET",
    T7."Remark" "TIPO DE PROVISION",
    CASE
        WHEN T1."BaseType" = '20' THEN 'Entr. Mercancias'
        ELSE CASE
            WHEN T1."BaseType" = '22' THEN 'Pedido '
            ELSE ''
        END
    END AS "ORIGEN",
    CASE
        WHEN T1."ObjType" = '18' THEN 'Fact. Proveedores'
        ELSE ''
    END AS "DOCUMENTO SAP",
    T."DocNum" "NRO. SAP",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE CAST(IFNULL(T."DocDate", '') AS TIMESTAMP)
    END "FCH. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE "U_SYP_SUCCERT"
    END AS "ESTB. RET.",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE "U_SYP_SERTRET"
    END AS "PTO. EMIS. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE RIGHT(
            LPAD('0', 9) || CAST(U_SYP_CORCERT AS VARCHAR(9)),
            9
        )
    END AS "SEC. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE (
            CASE
                WHEN IFNULL((RTRIM(LTRIM(T.U_SYP_NROAUTOC))), '') = '' THEN 'SINAUTORIZACION'
                ELSE RTRIM(LTRIM(T.U_SYP_NROAUTOC))
            END
        )
    END AS "AUT. RET.",
    (
        SELECT
            "U_NAME"
        FROM
            "OUSR"
        WHERE
            "USERID" = T."UserSign"
    ) AS "USUARIO",
    CASE
        WHEN T5."U_SYP_TCONTRIB" IN ('08', '09') THEN 'SI'
        ELSE 'NO'
    END AS "RISE",
    IFNULL(SUBSTR(T."U_SYP_FORMAP", 0, 40), '') "FORMA PAGO 1",
    IFNULL(SUBSTR(T."U_SYP_FORMAPAGO2", 0, 40), '') "FORMA PAGO 2",
    CASE
        WHEN T1."BaseType" = '20' THEN T8."AcctCode"
        ELSE T1."AcctCode"
    END AS "CTA CONTABLE",
    'A' "TIPO OPERAC",
    IFNULL("U_SYP_COMPS_IVA", '') "COMPENS. IVA",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_MDTO"
        ELSE NULL
    END "DOC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_SERIESUCO"
        ELSE NULL
    END "ESTB MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_MDSO"
        ELSE NULL
    END "PTO MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN RIGHT(
            LPAD('0', 9) || CAST(T."U_SYP_MDCO" AS VARCHAR(9)),
            9
        )
        ELSE NULL
    END AS "SEC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T.U_SYP_NROAUTOO
        ELSE NULL
    END "AUTO MODIFICADO",
    T."U_SYP_FACREEMBOLSO" "COD SAP REEMB",
    CASE
        WHEN IFNULL(T.U_SYP_TIPOREGI, 'NA') = 'NA' THEN NULL
        ELSE T."U_SYP_TIPOREGI"
    END "TIPO REG",
    CASE
        WHEN T."U_SYP_TIPOREGI" = '01' THEN T."U_SYP_PAISPAGOGEN"
        ELSE NULL
    END "PAIS PAG GEN",
    CASE
        WHEN T."U_SYP_TIPOREGI" IN ('02', '03') THEN IFNULL(T."U_SYP_PAISPAG_PARFIS", '000')
        ELSE NULL
    END "PAIS PAG PAR FIS",
    T."U_SYP_DENOPAGO" "DENO PAGO",
    '' "FECHA PAGO DIV",
    NULL "IMP RENTA SOC",
    NULL "ANO UTIL DIV",
    NULL "NUM CAJAS BANANO",
    NULL "PRECIO CAJAS BANANO",
    CASE
        WHEN (
            SELECT
                DISTINCT COUNT(B1."U_SYP_CODSRI")
            FROM
                "PCH5" C5
                LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
            WHERE
                T."DocEntry" = C5."AbsEntry"
                AND C5."BaseType" = 'N'
        ) > 0 THEN 'SI'
        ELSE 'NO'
    END AS "APLICA RET FTE"
From
    OPCH T
    INNER JOIN "PCH1" T1 ON T."DocEntry" = T1."DocEntry"
    INNER JOIN "PCH4" T2 ON T."DocEntry" = T2."DocEntry"
    And T1."LineNum" = T2."LineNum"
    LEFT JOIN "@SYP_IVA_FE_ATS" T4 ON T4."Code" = T2."StaCode"
    INNER JOIN "OCRD" T5 ON T."CardCode" = T5."CardCode"
    LEFT JOIN "@SYP_TIPIDENT" T6 ON T5."U_SYP_BPTD" = T6."Code"
    INNER JOIN "NNM1" T7 ON T."Series" = T7."Series"
    LEFT JOIN "PDN1" T8 ON T8."DocEntry" = T1."BaseEntry"
    AND T8."LineNum" = T1."BaseLine"
    AND T8."ObjType" = T1."BaseType"
    INNER JOIN "@SYP_TPODOC" T9 ON T9."Code" = T."U_SYP_MDTD"
    AND IFNULL(T9."U_SYP_DIN", 'N') = 'N'
    AND IFNULL(T9."U_SYP_ESTADO", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGCOM", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGINT", 'N') = 'N'
Where
    T."CANCELED" = 'N'
    AND T."U_SYP_STATUS" IN ('V')
    AND T2."RelateType" NOT IN (11, 3)
    AND T."DocDate" BETWEEN :FECHA_INI
    AND :FECHA_FIN
UNION
ALL
SELECT
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T1."LineNum",
    T1."U_SYP_CODIDTRD" AS "SUST. TRIB",
    T6."U_SYP_CODCOM" AS "TIP. IDENTF",
    T5."LicTradNum" AS "IDENTIFICACION",
    T."CardName" AS "RAZON SOCIAL",
    T5."U_SYP_TCONTRIB" AS "TIP CONTRIB",
    T5."U_SYP_PARTREL" AS "PART. RELC",
    T5."U_SYP_TIPPROV" as "TIP SUJETO",
    T."U_SYP_MDTD" AS "TIP. DOC",
    "U_SYP_SERIESUC" AS "ESTB. DOC",
    "U_SYP_MDSD" AS "PTO. EMI. DOC",
    RIGHT(
        LPAD('0', 9) || CAST("U_SYP_MDCD" AS VARCHAR(9)),
        9
    ) AS "SEC. DOC",
    CASE
        WHEN IFNULL((RTRIM(LTRIM("U_SYP_NROAUTO"))), '') = '' THEN 'SINAUTORIZACION'
        ELSE RTRIM(LTRIM("U_SYP_NROAUTO"))
    END AS "AUTORIZACION",
    CAST(T."TaxDate" AS TIMESTAMP) "FCH EMIS.",
    CAST(T."DocDate" AS TIMESTAMP) "FCH REGIS.",
    CAST(
        IFNULL(
            (
                SELECT
                    "U_SYP_FECHAS"
                FROM
                    (
                        SELECT
                            C1."U_SYP_FECHAS",
                            ROW_NUMBER() OVER(
                                ORDER BY
                                    (
                                        SELECT
                                            1
                                        from
                                            dummy
                                    )
                            ) AS ROWNUM
                        FROM
                            "@SYP_CCODAUT" C1
                        WHERE
                            C1."U_SYP_NROID" = T."CardCode"
                            AND C1."U_SYP_TIPDOC" = T."U_SYP_MDTD"
                            AND C1."U_SYP_SERIESUC" = T."U_SYP_SERIESUC"
                            AND C1."U_SYP_SERIEVTA" = T."U_SYP_MDSD"
                            AND T."TaxDate" >= C1."U_SYP_FECINI"
                            AND T."U_SYP_NROAUTO" = C1."U_SYP_NROAUT"
                    ) A
                where
                    a.rownum = 1
            ),
            T."TaxDate"
        ) AS TIMESTAMP
    ) AS "FCH VENCI",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImponible%' THEN T2."BaseSum"
        ELSE 0
    END "BASE %0",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN T2."BaseSum"
        ELSE 0
    END "BASE GRAV 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN T2."BaseSum"
        ELSE 0
    END "BASE GRAV 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN T2."BaseSum"
        ELSE 0
    END "BASE GRAV 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN T2."BaseSum"
        ELSE 0
    END "BASE GRAV 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN T2."BaseSum"
        ELSE 0
    END "BASE GRAV 15%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseNoGraIva%' THEN T2."BaseSum"
        ELSE 0
    END "BASE NO OBJETO",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpExe%' THEN T2."BaseSum"
        ELSE 0
    END "BASE EXCENTA IVA",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN T2."TaxSum"
        ELSE 0
    END "MONTO IVA 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN T2."TaxSum"
        ELSE 0
    END "MONTO IVA 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN T2."TaxSum"
        ELSE 0
    END "MONTO IVA 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN T2."TaxSum"
        ELSE 0
    END "MONTO IVA 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN T2."TaxSum"
        ELSE 0
    END "MONTO IVA 15%",
    CAST(0 AS DECIMAL(24, 6)) AS "MONTO ICE",
    IFNULL(
        (
            SELECT
                B1."U_SYP_CODSRI"
            FROM
                "PCH5" C5
                LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
            WHERE
                T."DocEntry" = C5."AbsEntry"
                AND T1."U_SYP_RET_IVA" = C5."WTCode"
                AND C5."BaseType" = 'V'
        ),
        ''
    ) AS "COD RET IVA",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 10
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 10%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 20
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 20%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 30
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 30%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 50
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 50%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 70
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 70%",
    CAST(
        T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 100
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 100%",
    CAST(T2."BaseSum" AS DECIMAL(24, 6)) AS "BASE IMP",
    (
        SELECT
            B1."U_SYP_CODSRI"
        FROM
            "PCH5" C5
            LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
        WHERE
            T."DocEntry" = C5."AbsEntry"
            AND T1."U_SYP_CODIGO_RET" = C5."WTCode"
            AND C5."BaseType" = 'N'
    ) AS "COD RET FUENTE",
    (
        SELECT
            C5."Rate"
        FROM
            "PCH5" C5
        WHERE
            T."DocEntry" = C5."AbsEntry"
            AND T1."U_SYP_CODIGO_RET" = "WTCode"
    ) AS "% RET FUENTE",
    CAST(
        T2."BaseSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "PCH5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_CODIGO_RET" = "WTCode"
                    AND C5."BaseType" = 'N'
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "VALOR RETENIDO",
    T."U_SYP_TIPOPAGO" "TIPO DE PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE T."U_SYP_PAISP"
    END "PAIS DE PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE ''
    END "PARAISO FISCAL",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE IFNULL(T.U_SYP_ADTPAGO, 'NO')
    END "ADOBLE TRIB EN PAGO",
    CASE
        WHEN T."U_SYP_TIPOPAGO" = '01' THEN 'NA'
        ELSE IFNULL(T.U_SYP_PESRET, 'NO')
    END "SUJE. RET",
    T7."Remark" "TIPO DE PROVISION",
    CASE
        WHEN T1."BaseType" = '20' THEN 'Entr. Mercancias'
        ELSE CASE
            WHEN T1."BaseType" = '22' THEN 'Pedido '
            ELSE ''
        END
    END AS "ORIGEN",
    CASE
        WHEN T1."ObjType" = '18' THEN 'Fact. Proveedores'
        ELSE ''
    END AS "DOCUMENTO SAP",
    T."DocNum" "NRO. SAP",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE CAST(IFNULL(T."DocDate", '') AS TIMESTAMP)
    END "FCH. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE "U_SYP_SUCCERT"
    END AS "ESTB. RET.",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE "U_SYP_SERTRET"
    END AS "PTO. EMIS. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE RIGHT(
            LPAD('0', 9) || CAST("U_SYP_CORCERT" AS VARCHAR(9)),
            9
        )
    END AS "SEC. RET",
    CASE
        WHEN T."U_SYP_MDTD" = '41'
        OR "U_SYP_TPDOCCERT" != '07' THEN NULL
        ELSE (
            CASE
                WHEN IFNULL((RTRIM(LTRIM(T."U_SYP_NROAUTOC"))), '') = '' THEN 'SINAUTORIZACION'
                ELSE RTRIM(LTRIM(T."U_SYP_NROAUTOC"))
            END
        )
    END AS "AUT. RET.",
    (
        SELECT
            "U_NAME"
        FROM
            "OUSR"
        WHERE
            "USERID" = T."UserSign"
    ) AS "USUARIO",
    CASE
        WHEN T5."U_SYP_TCONTRIB" = '08' THEN 'SI'
        ELSE 'NO'
    END AS "RISE",
    IFNULL(SUBSTR(T."U_SYP_FORMAP", 0, 40), '') "FORMA PAGO 1",
    IFNULL(SUBSTR(T."U_SYP_FORMAPAGO2", 0, 40), '') "FORMA PAGO 2",
    CASE
        WHEN T1."BaseType" = '20' THEN 'NA'
        ELSE 'NA'
    END AS "CTA CONTABLE",
    'A' "TIPO OPERAC",
    IFNULL("U_SYP_COMPS_IVA", '') "COMPENS. IVA",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T.U_SYP_MDTO
        ELSE NULL
    END "DOC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_SERIESUCO"
        ELSE NULL
    END "ESTB MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_MDSO"
        ELSE NULL
    END "PTO MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN RIGHT(
            LPAD('0', 9) || CAST(T.U_SYP_MDCO AS VARCHAR(9)),
            9
        )
        ELSE NULL
    END AS "SEC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '05' THEN T."U_SYP_NROAUTOO"
        ELSE NULL
    END "AUTO MODIFICADO",
    T."U_SYP_FACREEMBOLSO" "COD SAP REEMB",
    CASE
        WHEN IFNULL(T."U_SYP_TIPOREGI", 'NA') = 'NA' THEN NULL
        ELSE T."U_SYP_TIPOREGI"
    END "TIPO REG",
    CASE
        WHEN T."U_SYP_TIPOREGI" = '01' THEN T."U_SYP_PAISPAGOGEN"
        ELSE NULL
    END "PAIS PAG GEN",
    CASE
        WHEN T."U_SYP_TIPOREGI" IN ('02', '03') THEN IFNULL(T."U_SYP_PAISPAG_PARFIS", '000')
        ELSE NULL
    END "PAIS PAG PAR FIS",
    T."U_SYP_DENOPAGO" "DENO PAGO",
    '' "FECHA PAGO DIV",
    NULL "IMP RENTA SOC",
    NULL "ANO UTIL DIV",
    NULL "NUM CAJAS BANANO",
    NULL "PRECIO CAJAS BANANO",
    CASE
        WHEN (
            SELECT
                DISTINCT COUNT(B1."U_SYP_CODSRI")
            FROM
                "PCH5" C5
                LEFT JOIN "OWHT" B1 ON B1."WTCode" = C5."WTCode"
            WHERE
                T."DocEntry" = C5."AbsEntry"
                AND C5."BaseType" = 'N'
        ) > 0 THEN 'SI'
        ELSE 'NO'
    END AS "APLICA RET FTE"
From
    OPCH T
    INNER JOIN PCH3 T1 ON T."DocEntry" = T1."DocEntry"
    INNER JOIN "PCH4" T2 ON T."DocEntry" = T2."DocEntry"
    And T1."LineNum" = T2."LineNum"
    LEFT JOIN "@SYP_IVA_FE_ATS" T4 ON T4."Code" = T2."StaCode"
    INNER JOIN "OCRD" T5 ON T."CardCode" = T5."CardCode"
    LEFT JOIN "@SYP_TIPIDENT" T6 ON T5."U_SYP_BPTD" = T6."Code"
    INNER JOIN "NNM1" T7 ON T."Series" = T7."Series"
    INNER JOIN "@SYP_TPODOC" T9 ON T9."Code" = T."U_SYP_MDTD"
    AND IFNULL(T9."U_SYP_DIN", 'N') = 'N'
    AND IFNULL(T9."U_SYP_ESTADO", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGCOM", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGINT", 'N') = 'N'
Where
    T."CANCELED" = 'N'
    AND T."U_SYP_STATUS" IN ('V')
    AND T2."RelateType" NOT IN (11, 1)
    AND T1."WTLiable" = 'Y'
    AND T."DocDate" BETWEEN :FECHA_INI
    AND :FECHA_FIN
UNION
ALL
SELECT
    T."DocEntry",
    T7."SeriesName",
    T."DocNum",
    T."NumAtCard",
    T1."LineNum",
    T1."U_SYP_CODIDTRD" AS "SUST. TRIB",
    T6."U_SYP_CODCOM" AS "TIP. IDENTF",
    T5."LicTradNum" AS "IDENTIFICACION",
    T."CardName" AS "RAZON SOCIAL",
    T5."U_SYP_TCONTRIB" AS "TIP CONTRIB",
    T5."U_SYP_PARTREL" AS "PART. RELC",
    T5."U_SYP_TIPPROV" as "TIP SUJETO",
    T."U_SYP_MDTD" AS "TIP. DOC",
    "U_SYP_SERIESUC" AS "ESTB. DOC",
    U_SYP_MDSD AS "PTO. EMI. DOC",
    RIGHT(
        LPAD('0', 9) || CAST("U_SYP_MDCD" AS VARCHAR(9)),
        9
    ) AS "SE. DOC",
    CASE
        WHEN IFNULL((RTRIM(LTRIM("U_SYP_NROAUTO"))), '') = '' THEN 'SINAUTORIZACION'
        ELSE RTRIM(LTRIM("U_SYP_NROAUTO"))
    END AS "AUTORIZACION",
    CAST(T."TaxDate" AS TIMESTAMP) "FCH EMIS.",
    CAST(T."DocDate" AS TIMESTAMP) "FCH REGIS.",
    CAST(
        IFNULL(
            (
                SELECT
                    "U_SYP_FECHAS"
                FROM
                    (
                        SELECT
                            C1."U_SYP_FECHAS",
                            ROW_NUMBER() OVER(
                                ORDER BY
                                    (
                                        SELECT
                                            1
                                        from
                                            dummy
                                    )
                            ) AS ROWNUM
                        FROM
                            "@SYP_CCODAUT" C1
                        WHERE
                            C1."U_SYP_NROID" = T."CardCode"
                            AND C1."U_SYP_TIPDOC" = T."U_SYP_MDTD"
                            AND C1."U_SYP_SERIESUC" = T."U_SYP_SERIESUC"
                            AND C1."U_SYP_SERIEVTA" = T."U_SYP_MDSD"
                            AND T."TaxDate" >= C1."U_SYP_FECINI"
                            AND T."U_SYP_NROAUTO" = C1."U_SYP_NROAUT"
                    ) A
                where
                    a.rownum = 1
            ),
            T."TaxDate"
        ) AS TIMESTAMP
    ) AS "FCH VENCI",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImponible%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE %0",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE GRAV 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE GRAV 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE GRAV 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE GRAV 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE GRAV 15%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseNoGraIva%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE NO OBJETO",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpExe%' THEN -1 * T2."BaseSum"
        ELSE 0
    END "BASE EXCENTA IVA",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav5%' THEN -1 * T2."TaxSum"
        ELSE 0
    END "MONTO IVA 5%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav8%' THEN -1 * T2."TaxSum"
        ELSE 0
    END "MONTO IVA 8%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav12%' THEN -1 * T2."TaxSum"
        ELSE 0
    END "MONTO IVA 12%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav14%' THEN -1 * T2."TaxSum"
        ELSE 0
    END "MONTO IVA 14%",
    CASE
        WHEN T4."U_SYP_COLATS" LIKE '%baseImpGrav15%' THEN -1 * T2."TaxSum"
        ELSE 0
    END "MONTO IVA 15%",
    CAST(
        CASE
            WHEN (
                SELECT
                    SUM(C5."LineTotal")
                FROM
                    "RPC1" C5
                WHERE
                    T."DocEntry" = C5."DocEntry"
                    AND C5."U_SYP_APLICA_ICE" = 'SI'
            ) > 0
            AND T1."U_SYP_APLICA_ICE" = 'SI' THEN -1 * (T1."LineTotal" * IFNULL(T."U_SYP_ICE", 0)) / (
                SELECT
                    SUM(C5."LineTotal")
                FROM
                    RPC1 C5
                WHERE
                    T."DocEntry" = C5."DocEntry"
                    AND C5."U_SYP_APLICA_ICE" = 'SI'
            )
            ELSE 0
        END AS DECIMAL(24, 6)
    ) as "MONTO ICE",
    'N/A' "COD RET IVA",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 10
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 10%",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 20
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 20%",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 30
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 30%",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 50
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 50%",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 70
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 70%",
    CAST(
        -1 * T2."TaxSum" * IFNULL(
            (
                SELECT
                    C5."Rate"
                FROM
                    "RPC5" C5
                WHERE
                    T."DocEntry" = C5."AbsEntry"
                    AND T1."U_SYP_RET_IVA" = "WTCode"
                    AND C5."BaseType" = 'V'
                    AND C5."Rate" = 100
            ),
            0.00
        ) / 100 AS DECIMAL(24, 6)
    ) AS "RET 100%",
    CAST(-1 * T2."BaseSum" AS DECIMAL(24, 6)) AS "BASE IMP",
    '' AS "COD RET FUENTE",
    0.00 AS "% RET FUENTE",
    CAST(0 AS DECIMAL(24, 6)) AS "VALOR RETENIDO",
    '01' AS "TIPO DE PAGO",
    'NA' AS "PAIS DE PAGO",
    'NA' AS "PARAISO FISCAL",
    'NA' AS "ADOBLE TRIB EN PAGO",
    'NA' AS "SUJE. RET",
    T7."Remark" AS "TIPO DE PROVISION",
    CASE
        WHEN T1."BaseType" = '20' THEN 'Entr. Mercancias'
        ELSE CASE
            WHEN T1."BaseType" = '22' THEN 'Pedido '
            ELSE ''
        END
    END AS "ORIGEN",
    CASE
        WHEN T1."ObjType" = '18' THEN 'Fact. Proveedores'
        ELSE ''
    END AS "DOCUMENTO SAP",
    T."DocNum" AS "NRO. SAP",
    '' "FCH. RET",
    NULL AS "ESTB. RET.",
    NULL AS "PTO. EMIS. RET",
    NULL AS "SEC. RET",
    NULL AS "AUT. RET.",
    (
        SELECT
            "U_NAME"
        FROM
            OUSR
        WHERE
            "USERID" = T."UserSign"
    ) AS "USUARIO",
    CASE
        WHEN T5."U_SYP_TCONTRIB" = '08' THEN 'SI'
        ELSE 'NO'
    END AS "RISE",
    IFNULL(SUBSTR(T."U_SYP_FORMAP", 0, 40), '') AS "FORMA PAGO 1",
    IFNULL(SUBSTR(T."U_SYP_FORMAPAGO2", 0, 40), '') AS "FORMA PAGO 2",
    CASE
        WHEN T1."BaseType" = '20' THEN T8."AcctCode"
        ELSE T1."AcctCode"
    END AS "CTA CONTABLE",
    'S' "TIPO OPERAC",
    IFNULL(U_SYP_COMPS_IVA, '') "COMPENS. IVA",
    CASE
        WHEN T."U_SYP_MDTD" = '04' THEN T."U_SYP_MDTO"
        ELSE NULL
    END "DOC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '04' THEN T."U_SYP_SERIESUCO"
        ELSE NULL
    END "ESTB MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '04' THEN T."U_SYP_MDSO"
        ELSE NULL
    END "PTO MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '04' THEN RIGHT(
            LPAD('0', 9) || CAST(T."U_SYP_MDCO" AS VARCHAR(9)),
            9
        )
        ELSE NULL
    END AS "SEC MODIFICADO",
    CASE
        WHEN T."U_SYP_MDTD" = '04' THEN T."U_SYP_NROAUTOO"
        ELSE NULL
    END "AUTO MODIFICADO",
    NULL "COD SAP REEMB",
    T."U_SYP_TIPOREGI" AS "TIPO REG",
    NULL AS "PAIS PAG GEN",
    NULL AS "PAIS PAG PAR FIS",
    T."U_SYP_DENOPAGO" "DENO PAGO",
    '' "FECHA PAGO DIV",
    NULL "IMP RENTA SOC",
    NULL "ANO UTIL DIV",
    NULL "NUM CAJAS BANANO",
    NULL "PRECIO CAJAS BANANO",
    'NO' AS "APLICA RET FTE"
From
    "ORPC" T
    INNER JOIN "RPC1" T1 ON T."DocEntry" = T1."DocEntry"
    INNER JOIN "RPC4" T2 ON T."DocEntry" = T2."DocEntry"
    And T1."LineNum" = T2."LineNum"
    LEFT JOIN "@SYP_IVA_FE_ATS" T4 ON T4."Code" = T2."StaCode"
    INNER JOIN "OCRD" T5 ON T."CardCode" = T5."CardCode"
    LEFT JOIN "@SYP_TIPIDENT" T6 ON T5."U_SYP_BPTD" = T6."Code"
    INNER JOIN "NNM1" T7 ON T."Series" = T7."Series"
    LEFT JOIN "PDN1" T8 ON T8."DocEntry" = T1."BaseEntry"
    AND T8."LineNum" = T1."BaseLine"
    AND T8."ObjType" = T1."BaseType"
    INNER JOIN "@SYP_TPODOC" T9 ON T9."Code" = T."U_SYP_MDTD"
    AND IFNULL(T9."U_SYP_DIN", 'N') = 'N'
    AND IFNULL(T9."U_SYP_ESTADO", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGCOM", 'N') = 'Y'
    AND IFNULL(T9."U_SYP_REGINT", 'N') = 'N'
Where
    T."CANCELED" = 'N'
    AND T."U_SYP_STATUS" IN ('V')
    AND T2."RelateType" NOT IN (11)
    AND T."DocDate" BETWEEN :FECHA_INI
    AND :FECHA_FIN;

END