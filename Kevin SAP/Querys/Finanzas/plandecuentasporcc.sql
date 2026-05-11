SELECT T0."AcctCode" AS "Cuenta",
 T0."AcctName" AS "Nombre Cuenta",
  T0."Dim1Relvnt" AS "Aplica Línea Negocio",
   T0."Dim2Relvnt" AS "Aplica Cliente",
    T0."Dim3Relvnt" AS "Aplica Área", 
    T0."Dim4Relvnt" AS "Aplica Centro Costo",
     SUM(T1."Debit") AS "Total Débitos",
      SUM(T1."Credit") AS "Total Créditos",
       SUM(T1."Debit") - SUM(T1."Credit") AS "Saldo" 
       FROM OACT T0 INNER JOIN JDT1 T1 ON T0."AcctCode" = T1."Account" 
       INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" 
       WHERE T2."RefDate" BETWEEN '[%0]' AND '[%1]'
        GROUP BY T0."AcctCode", T0."AcctName", T0."Dim1Relvnt", T0."Dim2Relvnt", T0."Dim3Relvnt", T0."Dim4Relvnt" 
        ORDER BY T0."AcctCode"


VALIDAR CON HENRY
SELECT T0."AcctCode",T0."AcctName",  T0."Dim1Relvnt" AS "PorLineaDeNegocio", T0."Dim2Relvnt" AS "Cliente", T0."Dim3Relvnt" AS "Area", T0."Dim4Relvnt" AS "CentroCost", T0."CurrTotal" FROM OACT T0