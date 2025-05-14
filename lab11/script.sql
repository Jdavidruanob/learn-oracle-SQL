-- Jose David Ruano Burbano
-- Gestion y Modelacion de Bases de Datos

-- 1
/* CREATE OR REPLACE TYPE r_venta AS OBJECT (
    tema VARCHAR2(200),
    producto VARCHAR2(50),
    fecha DATE,
    cantidad NUMBER,
    precio_total NUMBER
); */
/* CREATE OR REPLACE TYPE t_ventas_tabla AS TABLE OF r_venta; */

CREATE OR REPLACE FUNCTION obtener_ventas_por_anio (p_anio IN NUMBER)
RETURN t_ventas_tabla
AS
    v_resultado t_ventas_tabla;
BEGIN
    SELECT
        r_venta(
            t.NOMBRE,
            p.DESCRIPCION,
            c.FECHA,
            pc.CANTIDAD,
            pc.PRECIO_UNITARIO * pc.CANTIDAD
        )
    BULK COLLECT INTO v_resultado
    FROM PROD_COMPRA pc
    JOIN COMPRA c ON pc.NRO_COMPRA = c.NRO_COMPRA
    JOIN PRODUCTO p ON pc.COD_PRODUCTO = p.ID_PRODUCTO
    JOIN TEMA_PRODUCTO tp ON p.ID_PRODUCTO = tp.COD_PRODUCTO
    JOIN TEMA t USING (COD_TEMA)
    WHERE EXTRACT(YEAR FROM c.FECHA) = p_anio;

    RETURN v_resultado;
END;
