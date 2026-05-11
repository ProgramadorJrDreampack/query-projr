SELECT DISTINCT 
    T0."CardCode", 
    T0."CardName",
    T1."Address2", 
    T1."Street"
FROM OCRD T0  
INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode" 
WHERE T1."Address" = 'DIR_ENTREGA' 
  AND T0."frozenFor" = 'N'  -- N = Activo, Y = Congelado/Inactivo
ORDER BY T0."CardCode"