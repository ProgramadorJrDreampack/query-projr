SELECT 
    T0."AcctCode"                              AS "Cuenta Contable",
    T0."AcctName"                              AS "Nombre Cuenta",
    T0."ActType"                               AS "Tipo de Cuenta",
    T1."ProfitCode"                            AS "Centro de Costo",
    SUM(T1."Debit") - SUM(T1."Credit")        AS "Saldo Final"
FROM 
    OACT T0
INNER JOIN 
    JDT1 T1 ON T0."AcctCode" = T1."Account"
WHERE 
    T1."ProfitCode" IS NOT NULL
    AND T1."ProfitCode" != ''
GROUP BY 
    T0."AcctCode",
    T0."AcctName",
    T0."ActType",
    T1."ProfitCode"
ORDER BY 
    T0."AcctCode",
    T1."ProfitCode"