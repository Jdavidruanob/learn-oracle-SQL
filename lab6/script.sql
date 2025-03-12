-- Laboratorio 6 script

--1
-- Cambie la direccion y la ciudad del usuario Pedro Ramos por 'Av. Sur # 3 -21' y 103 respectivamente.
UPDATE USUARIO
SET direccion =  'Av. Sur # 3 -21', CIUDAD = 103
WHERE NOMBRES = 'Pedro' and apellidos = 'Ramos';

-- view change
SELECT *
FROM usuario 
WHERE nombres = 'Pedro' AND apellidos = 'Ramos';

-- 2
-- Actualice las compras del 15 de diciembre del 2024,
-- cambie dirEntrega y ciudadEntrega por la dirección y 
-- ciudad del usuario que realizó la compra.

DESC COMPRA;
SELECT *
FROM COMPRA
WHERE TRUNC(FECHA) = DATE '2024-12-15' ;

DESC USUARIO;
SELECT *
FROM USUARIO
WHERE COD_USUARIO = 12;

UPDATE (
    SELECT U.DIRECCION, U.CIUDAD, C.DIR_ENTREGA,
    C.CIUDAD_ENTREGA, C.FECHA
    FROM COMPRA C 
    JOIN USUARIO U ON (C.COD_USUARIO = U.COD_USUARIO)
    WHERE TRUNC(C.FECHA) = DATE '2024-12-15'
) CU
SET CU.DIR_ENTREGA = CU.DIRECCION,
    CU.CIUDAD_ENTREGA = CU.CIUDAD;

COMMIT;
-- 3
-- Borre del carrito de compras del usuario Camila Garcia el producto Auriculares con orejas de gato
-- cambiar 
DESC CARRITO_COMPRAS;
DELETE FROM CARRIT_COMPRAS
WHERE COD_USUARIO = (
    SELECT COD_USUARIO
    FROM USUARIO
    WHERE NOMBRES = 'Camila' AND APELLIDOS = 'Garcia'
)
AND COD_PRODUCTO = (
    SELECT COD
    FROM PRODUCTO
    WHERE NOMBRE = 'Auriculares con orejas de gato'
);

