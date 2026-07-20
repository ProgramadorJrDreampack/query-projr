SELECT 
    T0."ItemCode",
    T0."ItemName",
    CASE WHEN T0."QryGroup7" = 'Y' THEN 'SI'
         ELSE 'No' 
    END AS "Paletizado"
FROM OITM T0 
WHERE  T0."ItemCode" LIKE '07%' AND T0."validFor" = 'Y'