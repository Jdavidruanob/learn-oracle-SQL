-- 1
SELECT *
FROM DATABASE34.CLIENTE
WHERE DIRECCIONRESIDENCIA IS NULL;

-- 2
SELECT 
    MIN(C.PRECIOALQUILER) AS PRECIO_MINIMO, 
    MAX(C.PRECIOALQUILER) AS PRECIO_MAXIMO
FROM DATABASE34.CARRO C
INNER JOIN DATABASE34.SUCURSAL S USING (CODSUCURSAL)
WHERE S.NOMBRE = 'DriveAway Sur';

-- 3
SELECT 
    EXTRACT(YEAR FROM F.FECHAALQUILER) AS ANIO,
    EXTRACT(MONTH FROM F.FECHAALQUILER) AS MES,
    SUM(F.VALORAVANCE + F.VALORDIASADICIONALES + F.CARGOGASOLINA + F.VALOROTROSCARGOS) AS TOTAL_PAGADO
FROM DATABASE34.FACTURA F
JOIN DATABASE34.CLIENTE C ON F.CLIENTE = C.ID
WHERE C.NOMBRE = 'Bryar Marks'
GROUP BY EXTRACT(YEAR FROM F.FECHAALQUILER), EXTRACT(MONTH FROM F.FECHAALQUILER)
ORDER BY ANIO, MES;


-- 4
SELECT S.nombre, COUNT(A.placa) AS total_alquileres
FROM DATABASE34.SUCURSAL S
LEFT JOIN DATABASE34.CARRO C ON S.codSucursal = C.codSucursal
LEFT JOIN DATABASE34.ALQUILER A ON C.placa = A.placa
WHERE EXTRACT(YEAR FROM A.fechaAlquiler) IN (2023, 2024)
GROUP BY S.nombre;

-- 5
SELECT EXTRACT(MONTH FROM fechaAlquiler) AS mes
FROM DATABASE34.ALQUILER
GROUP BY EXTRACT(MONTH FROM fechaAlquiler)
HAVING SUM(diasAlquilados) > 120;

-- 6
SELECT C.id, C.nombre, F.nroFactura, F.fechaAlquiler, F.VALORAVANCE, 
       F.VALORDIASADICIONALES, F.VALOROTROSCARGOS, M.nombre AS marca, 
       R.modelo, R.color
FROM DATABASE34.CLIENTE C
LEFT JOIN DATABASE34.FACTURA F ON C.id = F.cliente
LEFT JOIN DATABASE34.ALQUILER A ON F.placa = A.placa AND F.fechaAlquiler = A.fechaAlquiler
LEFT JOIN DATABASE34.CARRO R ON A.placa = R.placa
LEFT JOIN DATABASE34.MARCA M ON R.marca = M.codMarca;

-- 7
SELECT C.nombre AS cliente, S.nombre AS sucursal, 
       SUM(F.VALORAVANCE + NVL(F.VALORDIASADICIONALES, 0) + NVL(F.VALOROTROSCARGOS, 0)) AS total_pagado
FROM DATABASE34.FACTURA F
INNER JOIN DATABASE34.CLIENTE C ON F.CLIENTE = C.ID
INNER JOIN DATABASE34.CARRO R ON F.PLACA = R.PLACA
INNER JOIN DATABASE34.SUCURSAL S ON R.CODSUCURSAL = S.CODSUCURSAL
GROUP BY C.nombre, S.nombre
HAVING SUM(F.VALORAVANCE + NVL(F.VALORDIASADICIONALES, 0) + NVL(F.VALOROTROSCARGOS, 0)) > 200000;


