-- Laboratorio 10 PL/SQL Triggers
-- Jose David Ruano Burbano  8982982

-- 1
CREATE OR REPLACE TRIGGER tr_evitar_compra_carrito_vacio
BEFORE INSERT ON COMPRA
FOR EACH ROW
DECLARE
    v_conteo_productos NUMBER;
BEGIN
    -- Contar la cantidad de productos en el carrito del usuario que intenta comprar
    SELECT COUNT(*)
    INTO v_conteo_productos
    FROM CARRITO_COMPRAS
    WHERE cod_usuario = :NEW.cod_usuario;

    -- Si no hay productos en el carrito, evitar la compra
    IF v_conteo_productos = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede crear la compra. El carrito de compras está vacío.');
    END IF;
END;
/


SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name = 'TR_EVITAR_COMPRA_CARRITO_VACIO'; -- Ajusta el nombre si es diferente
-- Pruebas
-- Caso 1, no tiene productos en el carrito
SELECT u.cod_usuario
FROM USUARIO u
WHERE NOT EXISTS (SELECT 1
                  FROM CARRITO_COMPRAS cc
                  WHERE cc.cod_usuario = u.cod_usuario);

INSERT INTO COMPRA (cod_usuario, nro_compra, fecha) 
VALUES (6, 1, SYSDATE);

-- Caso 2, tiene al menos un producto
SELECT DISTINCT cod_usuario
FROM CARRITO_COMPRAS;
SELECT * FROM COMPRA WHERE cod_usuario = 1;
SELECT cod_ciudad FROM ciudad;

INSERT INTO COMPRA (cod_usuario, nro_compra, fecha, ciudad_entrega)
VALUES (1, 7, SYSDATE, 101);

-- 2
CREATE OR REPLACE TRIGGER tr_validar_fecha_carrito
BEFORE INSERT ON COMPRA
FOR EACH ROW
DECLARE
    v_conteo_productos NUMBER;
    v_fecha_limite DATE;
    v_productos_viejos NUMBER := 0;
    CURSOR cur_carrito IS
        SELECT fecha_ingreso
        FROM CARRITO_COMPRAS
        WHERE cod_usuario = :NEW.cod_usuario;
    r_carrito cur_carrito%ROWTYPE;
BEGIN
    -- Verificar si el carrito está vacío
    SELECT COUNT(*)
    INTO v_conteo_productos
    FROM CARRITO_COMPRAS
    WHERE cod_usuario = :NEW.cod_usuario;

    IF v_conteo_productos = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede crear la compra. El carrito de compras está vacío.');
    ELSE
        --  Si el carrito no está vacío, verificar la fecha de ingreso de los productos
        v_fecha_limite := ADD_MONTHS(:NEW.fecha, -6);

        OPEN cur_carrito;
        LOOP
            FETCH cur_carrito INTO r_carrito;
            EXIT WHEN cur_carrito%NOTFOUND;

            IF r_carrito.fecha_ingreso < v_fecha_limite THEN
                v_productos_viejos := v_productos_viejos + 1;
            END IF;
        END LOOP;
        CLOSE cur_carrito;

        -- Si hay productos con fecha de ingreso anterior a seis meses, evitar la compra
        IF v_productos_viejos > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No se puede crear la compra. El carrito contiene productos ingresados hace más de seis meses.');
        END IF;
    END IF;
END;
/

-- Pruebas
-- Caso 1: Carrito no vacío y todos los productos tienen una fecha_ingreso reciente (dentro de los últimos seis meses).

-- Insertamos en usuario dos para que nos sirva como ejemplo de este caso 
INSERT INTO CARRITO_COMPRAS (cod_usuario, cod_producto, cantidad, fecha_ingreso)
VALUES (2, 104, 1, SYSDATE);
COMMIT;

INSERT INTO COMPRA (cod_usuario, nro_compra, fecha, ciudad_entrega)
VALUES (2, 11, SYSDATE,104);
COMMIT;

SELECT * FROM carrito_compras WHERE cod_usuario = 2;
SELECT * FROM compra WHERE cod_usuario = 2;

-- Caso 2: Carrito contiene al menos un producto con una fecha_ingreso de hace más de seis meses.
SELECT * FROM carrito_compras WHERE cod_usuario = 1;
INSERT INTO COMPRA (cod_usuario, nro_compra, fecha, ciudad_entrega) 
VALUES (1, 8, SYSDATE, 103);


-- Caso 3: El carrito del usuario está vacío.
SELECT * FROM carrito_compras WHERE cod_usuario = 6;
SELECT * FROM compra WHERE cod_usuario = 6;
INSERT INTO COMPRA (cod_usuario, nro_compra, fecha, ciudad_entrega)
VALUES (6, 7, SYSDATE, 105);

-- 3
CREATE OR REPLACE TRIGGER tr_actualizar_precio_compra
BEFORE INSERT ON PROD_COMPRA
FOR EACH ROW
DECLARE
    v_precio_actual PRODUCTO.precio%TYPE;
BEGIN
    -- Obtener el precio actual del producto desde la tabla PRODUCTO
    SELECT precio
    INTO v_precio_actual
    FROM PRODUCTO
    WHERE id_producto = :NEW.cod_producto;

    -- Comparar el precio actual con el precio que se va a insertar
    IF :NEW.precio_unitario <> v_precio_actual THEN
        -- Si los precios son diferentes, actualizar el precio unitario al valor actual
        :NEW.precio_unitario := v_precio_actual;
        DBMS_OUTPUT.PUT_LINE('¡Advertencia! El precio del producto ' || :NEW.cod_producto || ' en la compra ha sido actualizado a: ' || v_precio_actual);
    END IF;
END;
/

-- Pruebas 
SELECT * FROM PRODUCTO;
INSERT INTO PRODUCTO (id_producto, descripcion, precio, cod_categoria, largo, alto, ancho, cantidad_inv)
VALUES (301, 'Producto de prueba', 50000, 1, 10, 5, 8, 100);

-- Prueba 1: Insertar en PROD_COMPRA con el precio actual.
INSERT INTO PROD_COMPRA (cod_usuario, nro_compra, cod_producto, precio_unitario, cantidad)
VALUES (2, 10, 105, 50000, 1);

--  Modificar el precio del producto en PRODUCTO
UPDATE PRODUCTO
SET precio = 55000
WHERE id_producto = 105;
COMMIT;
-- Activacion advertencia trigger
INSERT INTO PROD_COMPRA (cod_usuario, nro_compra, cod_producto, precio_unitario, cantidad)
VALUES (2, 10, 105, 50000, 1);

-- 4
CREATE TABLE Bonificaciones (
    codUsuario NUMBER(5) NOT NULL,
    fechaBonificacion DATE NOT NULL,
    valorBono NUMBER(10, 2) NOT NULL CHECK (valorBono > 0),
    estado VARCHAR2(10) NOT NULL CHECK (estado IN ('Vigente', 'Usado')),
    PRIMARY KEY (codUsuario, fechaBonificacion),
    FOREIGN KEY (codUsuario) REFERENCES usuario(cod_usuario)
);
COMMIT;

-- 5
CREATE OR REPLACE TRIGGER tr_generar_bono_primera_compra
AFTER INSERT ON COMPRA
FOR EACH ROW
DECLARE
    v_conteo_compras NUMBER;
    v_total_compra NUMBER(10, 2) := 0;
    v_valor_bono NUMBER(10, 2);
BEGIN
    -- Contar el número total de compras realizadas por el cliente
    SELECT COUNT(*)
    INTO v_conteo_compras
    FROM COMPRA
    WHERE cod_usuario = :NEW.cod_usuario;

    -- Si es la primera compra del cliente (solo una compra registrada)
    IF v_conteo_compras = 1 THEN
        -- Calcular el valor total de la compra
        SELECT SUM(pc.precio_unitario * pc.cantidad)
        INTO v_total_compra
        FROM PROD_COMPRA pc
        WHERE pc.cod_usuario = :NEW.cod_usuario
          AND pc.nro_compra = :NEW.nro_compra;

        -- Calcular el valor del bono (15% del total de la compra)
        v_valor_bono := v_total_compra * 0.15;

        -- Insertar el bono en la tabla Bonificaciones
        INSERT INTO Bonificaciones (codUsuario, fechaBonificacion, valorBono, estado)
        VALUES (:NEW.cod_usuario, SYSDATE, v_valor_bono, 'Vigente');

        DBMS_OUTPUT.PUT_LINE('¡Bono generado para el usuario ' || :NEW.cod_usuario || ' por su primera compra! Valor del bono: ' || v_valor_bono);
    END IF;
END;
/
-- 6
CREATE OR REPLACE TRIGGER tr_carrito_fecha_ingreso
BEFORE INSERT ON CARRITO_COMPRAS
FOR EACH ROW
BEGIN
    :NEW.fecha_ingreso := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER tr_compra_fecha
BEFORE INSERT ON COMPRA
FOR EACH ROW
BEGIN
    :NEW.fecha := SYSDATE;
END;
/

-- Pruebas
-- Insertando sin especificar fecha_ingreso
INSERT INTO CARRITO_COMPRAS (cod_usuario, cod_producto, cantidad)
VALUES (2, 106, 1);

-- Verificando la fecha_ingreso
SELECT cod_usuario, cod_producto, fecha_ingreso
FROM CARRITO_COMPRAS
WHERE cod_usuario = 2 AND cod_producto = 106;

-- Insertando una fecha antigua (debería ser reemplazada por SYSDATE)
INSERT INTO CARRITO_COMPRAS (cod_usuario, cod_producto, cantidad, fecha_ingreso)
VALUES (2, 146, 1, DATE '2024-01-01');

-- Verificando la fecha_ingreso
SELECT cod_usuario, cod_producto, fecha_ingreso
FROM CARRITO_COMPRAS
WHERE cod_usuario = 2 AND cod_producto = 146;