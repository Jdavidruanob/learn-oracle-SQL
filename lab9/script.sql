-- Laboratorio 9    Jose David Ruano Burbano    8982982
-- 1
CREATE OR REPLACE PROCEDURE imprimir_compras_ciudad (p_nombre_ciudad IN VARCHAR2)
AS
    CURSOR cur_compras IS
        SELECT
            u.NOMBRES || ' ' || u.APELLIDOS AS nombre_usuario,
            c.FECHA AS fecha_compra,
            p.DESCRIPCION AS descripcion_producto,
            dc.CANTIDAD AS cantidad_producto
        FROM COMPRA c
        JOIN USUARIO u ON c.COD_USUARIO = u.COD_USUARIO
        JOIN CIUDAD ci ON c.CIUDAD_ENTREGA = ci.COD_CIUDAD
        JOIN PROD_COMPRA dc ON c.NRO_COMPRA = dc.NRO_COMPRA
        JOIN PRODUCTO P ON dc.COD_PRODUCTO = p.ID_PRODUCTO
        WHERE ci.NOMBRE_CIUDAD = p_nombre_ciudad;
BEGIN
    DBMS_OUTPUT.ENABLE; 
    FOR compra_rec IN cur_compras LOOP
        DBMS_OUTPUT.PUT_LINE(
            compra_rec.nombre_usuario || ' – ' ||
            TO_CHAR(compra_rec.fecha_compra, 'YYYY-MM-DD') || ' – ' ||
            compra_rec.descripcion_producto || ' - ' ||
            compra_rec.cantidad_producto
        );
    END LOOP;
END;


-- 2
CREATE OR REPLACE PROCEDURE actualizar_precio_categoria (
    p_porcentaje_incremento IN NUMBER,
    p_nombre_categoria IN VARCHAR2
)
AS
    ex_precio_fuera_rango EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_precio_fuera_rango, -01438); -- Error ORA-01438: value larger than specified precision allows for this column

    CURSOR cur_productos_categoria IS
        SELECT
            p.ID_PRODUCTO,
            p.PRECIO
        FROM
            PRODUCTO p
        JOIN
            CATEGORIA cat ON p.COD_CATEGORIA = cat.COD_CATEGORIA
        WHERE
            cat.NOMBRE = p_nombre_categoria;
BEGIN
    FOR prod_rec IN cur_productos_categoria LOOP
        DECLARE
            v_nuevo_precio PRODUCTO.PRECIO%TYPE;
        BEGIN
            v_nuevo_precio := prod_rec.PRECIO * (1 + (p_porcentaje_incremento / 100));
            -- La restricción CHECK (precio > 1000) se maneja implícitamente por la base de datos
            -- Intentaremos la actualización y capturaremos la excepción si el valor no es válido para NUMBER(8,2)

            UPDATE PRODUCTO
            SET PRECIO = v_nuevo_precio
            WHERE ID_PRODUCTO = prod_rec.ID_PRODUCTO;

        EXCEPTION
            WHEN ex_precio_fuera_rango THEN
                DBMS_OUTPUT.PUT_LINE('Error: El nuevo precio (' || v_nuevo_precio || ') excede el rango permitido para el atributo PRECIO (NUMBER(8,2)) para el producto con ID: ' || prod_rec.ID_PRODUCTO);
                ROLLBACK;
                CONTINUE; -- Continúa con el siguiente producto
        END;
    END LOOP;
    COMMIT;
END;

-- 3

CREATE OR REPLACE FUNCTION registrar_compra (
    p_cod_usuario IN USUARIO.COD_USUARIO%TYPE,
    p_direccion_entrega IN COMPRA.DIR_ENTREGA%TYPE DEFAULT NULL,
    p_cod_ciudad_entrega IN COMPRA.CIUDAD_ENTREGA%TYPE DEFAULT NULL
)
RETURN NUMBER
AS
    v_total_compra NUMBER := 0;
    v_direccion_usuario USUARIO.DIRECCION%TYPE;
    v_cod_ciudad_usuario USUARIO.CIUDAD%TYPE;
    v_nro_compra COMPRA.NRO_COMPRA%TYPE;
    ex_usuario_no_existe EXCEPTION;

    CURSOR cur_carrito IS
        SELECT
            cc.COD_PRODUCTO,
            cc.CANTIDAD,
            p.PRECIO
        FROM
            CARRITO_COMPRAS cc
        JOIN
            PRODUCTO p ON cc.COD_PRODUCTO = p.ID_PRODUCTO
        WHERE
            cc.COD_USUARIO = p_cod_usuario;
BEGIN
    -- Verificar si el usuario existe
    SELECT DIRECCION, CIUDAD
    INTO v_direccion_usuario, v_cod_ciudad_usuario
    FROM USUARIO
    WHERE COD_USUARIO = p_cod_usuario;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE ex_usuario_no_existe;
END;

    -- Determinar la dirección y ciudad de entrega
    DECLARE
        v_dir_entrega COMPRA.DIR_ENTREGA%TYPE;
        v_ciudad_entrega COMPRA.CIUDAD_ENTREGA%TYPE;
    BEGIN
        IF p_direccion_entrega IS NOT NULL THEN
            v_dir_entrega := p_direccion_entrega;
        ELSE
            v_dir_entrega := v_direccion_usuario;
        END IF;

        IF p_cod_ciudad_entrega IS NOT NULL THEN
            v_ciudad_entrega := p_cod_ciudad_entrega;
        ELSE
            v_ciudad_entrega := v_cod_ciudad_usuario;
        END IF;

        -- Insertar la nueva compra
        INSERT INTO COMPRA (COD_USUARIO, FECHA, DIR_ENTREGA, CIUDAD_ENTREGA)
        VALUES (p_cod_usuario, SYSDATE, v_dir_entrega, v_ciudad_entrega)
        RETURNING NRO_COMPRA INTO v_nro_compra;

        -- Procesar los productos del carrito
        FOR item IN cur_carrito LOOP
            INSERT INTO PROD_COMPRA (NRO_COMPRA, COD_USUARIO, COD_PRODUCTO, PRECIO_UNITARIO, CANTIDAD)
            VALUES (v_nro_compra, p_cod_usuario, item.COD_PRODUCTO, item.PRECIO, item.CANTIDAD);
            v_total_compra := v_total_compra + (item.PRECIO * item.CANTIDAD);
            -- Eliminar el producto del carrito después de la compra (opcional)
            DELETE FROM CARRITO_COMPRAS
            WHERE COD_USUARIO = p_cod_usuario AND COD_PRODUCTO = item.COD_PRODUCTO;
        END LOOP;

        COMMIT;
        RETURN v_total_compra;
    END;
EXCEPTION
    WHEN ex_usuario_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El usuario con código ' || p_cod_usuario || ' no existe.');
        RETURN NULL;
END;

-- 4
ALTER TABLE USUARIO
ADD (NIVEL NUMBER(1) DEFAULT 1);
COMMIT;

--5
CREATE OR REPLACE PROCEDURE actualizar_nivel_clientes
AS
BEGIN
    FOR usuario_rec IN (
        SELECT u.COD_USUARIO
        FROM USUARIO u
        WHERE EXISTS (
            SELECT 1
            FROM (
                SELECT
                    c.COD_USUARIO,
                    TRUNC(c.FECHA, 'MM') AS mes_compra,
                    SUM(pc.PRECIO_UNITARIO * pc.CANTIDAD) AS total_mes
                FROM
                    COMPRA c
                JOIN
                    PROD_COMPRA pc ON c.NRO_COMPRA = pc.NRO_COMPRA
                WHERE
                    c.COD_USUARIO = u.COD_USUARIO
                GROUP BY
                    c.COD_USUARIO,
                    TRUNC(c.FECHA, 'MM')
                HAVING
                    SUM(pc.PRECIO_UNITARIO * pc.CANTIDAD) > 6000
            ) m1
            JOIN (
                SELECT
                    c.COD_USUARIO,
                    TRUNC(c.FECHA, 'MM') AS mes_compra,
                    SUM(pc.PRECIO_UNITARIO * pc.CANTIDAD) AS total_mes
                FROM
                    COMPRA c
                JOIN
                    PROD_COMPRA pc ON c.NRO_COMPRA = pc.NRO_COMPRA
                WHERE
                    c.COD_USUARIO = u.COD_USUARIO
                GROUP BY
                    c.COD_USUARIO,
                    TRUNC(c.FECHA, 'MM')
                HAVING
                    SUM(pc.PRECIO_UNITARIO * pc.CANTIDAD) > 6000
            ) m2 ON m1.COD_USUARIO = m2.COD_USUARIO
                  AND m1.mes_compra = ADD_MONTHS(m2.mes_compra, -1)
        )
    ) LOOP
        UPDATE USUARIO
        SET NIVEL = NIVEL + 1
        WHERE COD_USUARIO = usuario_rec.COD_USUARIO;
    END LOOP;
    COMMIT;
END;

