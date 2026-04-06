SELECT T0."DocEntry" as "N° Interno SAP", T0."U_ESY_PROVEEDOR" as "Proveedor",
T0."U_ESY_DESCPROVE" as "Nombre Proveedor", T0."U_ESY_TDOCUMENTO" as "Tipo Documento",
T0."U_ESY_ARTICULO_P" as "Artículo SAP", T0."U_ESY_DESCARTI" as "Descripción Artículo SAP",
T0."U_ESY_CUENTAC" as "Cuenta de Servicios", T0."U_ESY_RETEIVA" as "Retención Iva",
T0."U_ESY_RETEFUENTE" as "Retención Fuente", T0."U_ESY_DIMENSION1" as "Ubicación", 
T0."U_ESY_DIMENSION2" as "Cliente", T0."U_ESY_DIMENSION3" as "Área",
T0."U_ESY_DIMENSION4" as "Centro de Costo", T0."U_ESY_MONTO_MAXIMO" as "Monto Máximo"
FROM "SBO_FIGURETTI_PRO"."@ESY_VINCPROV"  T0