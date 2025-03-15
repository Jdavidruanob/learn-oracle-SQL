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
DESC CARRITO_COMPRAS;
DESC USUARIO;
DESC PRODUCTO;

DELETE FROM CARRITO_COMPRAS
WHERE COD_USUARIO IN (
    SELECT COD_USUARIO
    FROM USUARIO
    WHERE NOMBRES = 'Camila' AND APELLIDOS = 'Garcia'
)
AND COD_PRODUCTO IN (
    SELECT ID_PRODUCTO
    FROM PRODUCTO
    WHERE DESCRIPCION = 'Auriculares con orejas de gato'
);

-- 4
ALTER TABLE producto
RENAME COLUMN categoria TO cod_categoria;

-- 5
-- a) 
ALTER TABLE compra
MODIFY ciudad_entrega NUMBER(3) NOT NULL;

-- b) 
ALTER TABLE producto
MODIFY cantidad_inv DEFAULT 0;

-- c) 
ALTER TABLE prod_compra
ADD CONSTRAINT chk_cantidad CHECK (cantidad > 0);

-- 6
ALTER TABLE producto
ADD peso NUMBER(3) DEFAULT 1 CHECK (peso > 0);

COMMIT;

-- 7. 

-- Agregar el nuevo campo id_compra como IDENTITY
ALTER TABLE compra
ADD id_compra NUMBER(5) GENERATED ALWAYS AS IDENTITY;

--  Crear una tabla temporal para mantener la relación entre la vieja y nueva PK
CREATE TABLE temp_compra AS
SELECT id_compra, cod_usuario, nro_compra
FROM compra;

-- Actualizar prod_compra para agregar el nuevo campo
ALTER TABLE prod_compra
ADD id_compra NUMBER(5);

--  Actualizar los valores en prod_compra
UPDATE prod_compra pc
SET pc.id_compra = (
    SELECT tc.id_compra 
    FROM temp_compra tc 
    WHERE tc.cod_usuario = pc.cod_usuario 
    AND tc.nro_compra = pc.nro_compra
);

-- Eliminar las restricciones existentes
ALTER TABLE prod_compra
DROP CONSTRAINT FK_PROD_COMPRA_COMPRA;

ALTER TABLE prod_compra
DROP PRIMARY KEY;

ALTER TABLE compra
DROP PRIMARY KEY;

--  Crear las nuevas claves primarias
ALTER TABLE compra
ADD CONSTRAINT PK_COMPRA PRIMARY KEY (id_compra);

ALTER TABLE prod_compra
ADD CONSTRAINT PK_PROD_COMPRA PRIMARY KEY (id_compra, cod_producto);

-- Crear la nueva clave foránea
ALTER TABLE prod_compra
ADD CONSTRAINT FK_PROD_COMPRA_COMPRA 
FOREIGN KEY (id_compra) REFERENCES compra(id_compra);

-- Eliminar las columnas antiguas de prod_compra que ya no se necesitan
ALTER TABLE prod_compra
DROP COLUMN cod_usuario;

ALTER TABLE prod_compra
DROP COLUMN nro_compra;

-- Verificar la integridad de los datos
SELECT COUNT(*) FROM compra;
SELECT COUNT(*) FROM prod_compra;





