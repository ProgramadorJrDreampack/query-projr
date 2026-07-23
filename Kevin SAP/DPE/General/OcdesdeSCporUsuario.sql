SELECT
T0."DocNum"        AS "OC_Num",
T0."DocDate"       AS "OC_Fecha",
T0."CardCode"      AS "Proveedor",
T0."CardName"      AS "Proveedor_Nombre",
T3."U_NAME"        AS "Liberado_Por",
T0."DocTotal"      AS "OC_Total",
S."Solicitud_Num",
S."Creada_Por",
S."Solicitud_Fecha"
FROM OPOR T0 
INNER JOIN OUSR T3 ON T0."UserSign" = T3."USERID" 
LEFT JOIN (SELECT	P."DocEntry", MIN(R."DocNum")  AS "Solicitud_Num",
                                MIN(R."DocDate") AS "Solicitud_Fecha",
                                MIN(R."ReqName") AS "Creada_Por"
		FROM POR1 P 
INNER JOIN OPRQ R ON R."DocEntry" = P."BaseEntry"	
WHERE P."BaseType" = 1470000113
GROUP BY P."DocEntry") S ON S."DocEntry" = T0."DocEntry"
WHERE T0."DocStatus" = 'O' 
and T0."CANCELED" = 'N'
and T0."U_SYP_TIPCOMPRA" = '01'