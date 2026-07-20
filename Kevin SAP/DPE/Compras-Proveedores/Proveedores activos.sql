SELECT     
    T0."CardCode",
    T0."LicTradNum"       AS "RFC",    
    T0."CardName"         AS "Nombre del cliente",    
    T0."E_Mail"           AS "Correo_Electronico", 
    T0."Phone1",
    T0."Cellular",
    G."GroupName"         AS "Grupo",                      -- ← Nombre del grupo
    T0."Balance"          AS "Saldo_Cuenta",              
    T1."BankCode"         AS "Codigo_Banco",    
    T2."BankName"         AS "Nombre_Banco",   
    T1."Account"          AS "Cuenta_CLAVE",    
    T1."AcctName"         AS "Nombre_Cuenta_Bancaria",   
    A1."Address", 
    T0."BillToDef",
    A1."Street",
    T1."Country"          AS "Pais",
(SELECT MAX(J1."RefDate") FROM JDT1 J1 WHERE J1."ShortName" = T0."CardCode") AS "Date",
 T0."U_SYP_REGIMEN_APP"
FROM     OCRD T0
INNER JOIN CRD1 A1 
    ON T0."CardCode" = A1."CardCode" 
    AND A1."AdresType" = 'B' 
    AND A1."Address" = T0."BillToDef"
LEFT JOIN OCRB T1 
    ON T0."CardCode" = T1."CardCode" 
    AND T0."DflAccount" = T1."Account" 
    AND (T0."BankCode" = T1."BankCode" OR T0."BankCode" = '-1')
LEFT JOIN ODSC T2 
    ON T1."BankCode" = T2."BankCode"
LEFT JOIN OCRG G
    ON T0."GroupCode" = G."GroupCode"                     -- ← Unión con grupos
WHERE 
    T0."CardType" = 'S' 
    AND T0."validFor" = 'Y' --ANd T0."CardCode" = 'P0915006258001'