-- Laboratorio 10 PL/SQL Records & explicit cursors
-- Jose David Ruano Burbano  8982982

-- 1

CREATE OR REPLACE TYPE t_venta_record AS OBJECT (
    tema VARCHAR2(15),
    producto VARCHAR2(50),
    fecha DATE,
    cantidad NUMBER,
    precio_total NUMBER
);

CREATE OR REPLACE TYPE t_ventas_table AS TABLE OF t_venta_record;


CREATE OR REPLACE FUNCTION obtener_ventas_por_anio (p_anio IN NUMBER)
RETURN t_ventas_table
AS
    v_resultado t_ventas_table;
BEGIN
    SELECT t_venta_record(
               t.nombre,
               p.descripcion,
               c.fecha,
               pc.cantidad,
               pc.cantidad * pc.precio_unitario
           )
    BULK COLLECT INTO v_resultado
    FROM prod_compra pc
    JOIN compra c ON pc.cod_usuario = c.cod_usuario AND pc.nro_compra = c.nro_compra
    JOIN producto p ON pc.cod_producto = p.id_producto
    JOIN tema_producto tp ON p.id_producto = tp.cod_producto
    JOIN tema t ON tp.cod_tema = t.cod_tema
    WHERE EXTRACT(YEAR FROM c.fecha) = p_anio;

    RETURN v_resultado;
END;

-- Prueba
SELECT * FROM TABLE(obtener_ventas_por_anio(2024));

-- 2
SELECT
    v.tema,
    TO_CHAR(v.fecha, 'YYYY-MM') AS mes_anio,
    SUM(v.precio_total) AS valor_total_ventas
FROM
    TABLE(obtener_ventas_por_anio(2024)) v -- Reemplaza 2024 con el año deseado
GROUP BY
    v.tema,
    TO_CHAR(v.fecha, 'YYYY-MM')
ORDER BY
    v.tema,
    mes_anio;

-- 3
CREATE OR REPLACE TYPE t_producto_vendido_record AS OBJECT (
    id_producto NUMBER(5),
    descripcion VARCHAR2(50),
    cantidad_vendida NUMBER
);
/
CREATE OR REPLACE TYPE t_productos_vendidos_table AS TABLE OF t_producto_vendido_record;
/

CREATE OR REPLACE FUNCTION obtener_productos_fibonacci (p_categoria_nombre IN VARCHAR2)
RETURN t_productos_vendidos_table
AS
    v_resultado t_productos_vendidos_table;
    v_fib1 NUMBER := 0;
    v_fib2 NUMBER := 1;
    v_fib_actual NUMBER := 0;
    v_posicion NUMBER := 0;
    v_rec_producto t_producto_vendido_record;
CURSOR cur_productos_vendidos IS
    SELECT
        p.id_producto,
        p.descripcion,
        SUM(pc.cantidad) AS total_vendido
    FROM
        producto p
    JOIN
        categoria c ON p.cod_categoria = c.cod_categoria
    LEFT JOIN
        prod_compra pc ON p.id_producto = pc.cod_producto
    WHERE
        c.nombre = p_categoria_nombre
    GROUP BY
        p.id_producto, p.descripcion
    ORDER BY
        SUM(pc.cantidad) DESC;
BEGIN
    v_resultado := t_productos_vendidos_table();
    OPEN cur_productos_vendidos;
    LOOP
        FETCH cur_productos_vendidos INTO v_rec_producto.id_producto, v_rec_producto.descripcion, v_rec_producto.cantidad_vendida;
        EXIT WHEN cur_productos_vendidos%NOTFOUND;
        v_posicion := v_posicion + 1;

        -- Generar la secuencia de Fibonacci
        IF v_posicion = 1 THEN
            v_fib_actual := 1;
        ELSE
            v_fib_actual := v_fib1 + v_fib2;
            v_fib1 := v_fib2;
            v_fib2 := v_fib_actual;
        END IF;

        -- Verificar si la posición actual está en la secuencia de Fibonacci
        IF v_posicion = v_fib_actual THEN
            v_resultado.EXTEND;
            v_resultado(v_resultado.COUNT).id_producto := v_rec_producto.id_producto;
            v_resultado(v_resultado.COUNT).descripcion := v_rec_producto.descripcion;
            v_resultado(v_resultado.COUNT).cantidad_vendida := v_rec_producto.cantidad_vendida;
        END IF;
    END LOOP;
    CLOSE cur_productos_vendidos;
    RETURN v_resultado;
END;
/

SELECT * FROM TABLE(obtener_productos_fibonacci('Ropa y Moda'));

-- 4
CREATE OR REPLACE PROCEDURE actualizar_nivel_usuarios
AS
    CURSOR cur_usuarios_ventas IS
        SELECT
            u.cod_usuario,
            u.nivel,
            SUM(pc.cantidad * pc.precio_unitario) AS total_compras
        FROM
            usuario u
        JOIN
            compra c ON u.cod_usuario = c.cod_usuario
        JOIN
            prod_compra pc ON c.cod_usuario = pc.cod_usuario AND c.nro_compra = pc.nro_compra
        WHERE
            c.fecha >= ADD_MONTHS(SYSDATE, -12) -- Compras del último año
        GROUP BY
            u.cod_usuario, u.nivel
        ORDER BY
            SUM(pc.cantidad * pc.precio_unitario) DESC
        FOR UPDATE OF u.nivel; -- Especificamos que vamos a actualizar la columna 'nivel' de la tabla 'usuario'

    v_usuario_venta cur_usuarios_ventas%ROWTYPE;
    v_contador NUMBER := 0;
BEGIN
    OPEN cur_usuarios_ventas;
    LOOP
        FETCH cur_usuarios_ventas INTO v_usuario_venta.cod_usuario, v_usuario_venta.nivel, v_usuario_venta.total_compras;
        EXIT WHEN cur_usuarios_ventas%NOTFOUND;
        v_contador := v_contador + 1;

        IF v_contador <= 2 THEN
            UPDATE usuario
            SET nivel = v_usuario_venta.nivel + 5
            WHERE CURRENT OF cur_usuarios_ventas;
        ELSIF v_contador <= 5 THEN 
            UPDATE usuario
            SET nivel = v_usuario_venta.nivel + 3
            WHERE CURRENT OF cur_usuarios_ventas;
        ELSIF v_contador <= 9 THEN 
            UPDATE usuario
            SET nivel = v_usuario_venta.nivel + 2
            WHERE CURRENT OF cur_usuarios_ventas;
        ELSE
            EXIT; 
        END IF;
    END LOOP;
    CLOSE cur_usuarios_ventas;
    COMMIT; 
END;
/
EXEC actualizar_nivel_usuarios;