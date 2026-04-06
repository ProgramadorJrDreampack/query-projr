SELECT   t0."ItemCode",  t0."ItemName",  t1."ItmsGrpNam"
FROM OITM T0 
inner join oitb t1 on t0."ItmsGrpCod" = t1."ItmsGrpCod"
where t0."ItemCode" = '03FEL03080007';