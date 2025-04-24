-- 1. 
SELECT p.id_producto, p.descripcion
FROM producto p
WHERE NOT EXISTS (
  SELECT e.cod_producto
  FROM eliminados e
  WHERE e.cod_producto = p.id_producto
);

-- 2.
SELECT u.cod_usuario, u.nombres, u.apellidos
FROM usuario u
JOIN compra c ON u.cod_usuario = c.cod_usuario
WHERE c.fecha = (
  SELECT MIN(fecha)
  FROM compra
);

-- 3. 
SELECT id_producto, descripcion
FROM producto
WHERE precio > (
  SELECT precio
  FROM producto
  WHERE descripcion = 'Taza de Doctor Who'
)
AND precio < (
  SELECT precio
  FROM producto
  WHERE descripcion = 'Alfombra de Star Wars'
);

-- 4. 
SELECT p.id_producto, p.descripcion
FROM producto p
JOIN prod_compra pc ON p.id_producto = pc.cod_producto
JOIN compra c ON pc.cod_usuario = c.cod_usuario AND pc.nro_compra = c.nro_compra
WHERE EXTRACT(YEAR FROM c.fecha) = 2024
GROUP BY p.id_producto, p.descripcion
HAVING SUM(pc.cantidad) = (
  SELECT MAX(total_cant)
  FROM (
    SELECT SUM(pc2.cantidad) AS total_cant
    FROM prod_compra pc2
    JOIN compra c2 ON pc2.cod_usuario = c2.cod_usuario AND pc2.nro_compra = c2.nro_compra
    WHERE EXTRACT(YEAR FROM c2.fecha) = 2024
    GROUP BY pc2.cod_producto
  ) sub
);

-- 5. 
SELECT c.nombre_ciudad, total_compras 
FROM ciudad c
JOIN (
    SELECT ciudad_entrega, SUM(pc.cantidad * pc.precio_unitario) AS total_compras
    FROM compra co
    JOIN prod_compra pc ON co.nro_compra = pc.nro_compra
    WHERE EXTRACT(YEAR FROM co.fecha) = 2023
    GROUP BY ciudad_entrega
) compras ON c.cod_ciudad = compras.ciudad_entrega;

-- 6. 
SELECT u.cod_usuario, u.nombres, u.apellidos 
FROM usuario u 
JOIN compra c ON u.cod_usuario = c.cod_usuario
JOIN prod_compra pc ON c.nro_compra = pc.nro_compra
GROUP BY u.cod_usuario, u.nombres, u.apellidos
HAVING SUM(pc.cantidad * pc.precio_unitario) > (
    SELECT AVG(total_compras)
    FROM (
        SELECT SUM(pc.cantidad * pc.precio_unitario) AS total_compras
        FROM compra co
        JOIN prod_compra pc ON co.nro_compra = pc.nro_compra
        WHERE EXTRACT(YEAR FROM co.fecha) = 2024
        GROUP BY co.cod_usuario
    )
);

-- 7.
SELECT u.cod_usuario, u.nombres, u.apellidos, compras.fecha, compras.total
FROM usuario u
JOIN (
    SELECT c.cod_usuario, c.fecha, SUM(pc.cantidad * pc.precio_unitario) AS total
    FROM compra c
    JOIN prod_compra pc ON c.nro_compra = pc.nro_compra
    WHERE (c.cod_usuario, c.fecha) IN (
        SELECT cod_usuario, MAX(fecha)
        FROM compra
        GROUP BY cod_usuario
    )
    GROUP BY c.cod_usuario, c.fecha
) compras ON u.cod_usuario = compras.cod_usuario;


