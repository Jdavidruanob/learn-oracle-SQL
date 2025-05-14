-- Part 1
SELECT id_producto, nombre, descripcion, imagen
FROM producto;
SELECT id_producto, descripcion, imagen FROM Producto WHERE id_producto >= 156;

-- Part 2
-- 1
select p.id_cod_producto as codigo,
       p.descripcion as descripcion,
       'Carrito' as tipo
  from cod_producto p
  join carrito_compras c
on p.id_cod_producto = c.cod_cod_producto
union
select p.id_cod_producto as codigo,
       p.descripcion as descripcion,
       'Eliminado' as tipo
  from cod_producto p
  join eliminados e
on p.id_cod_producto = e.cod_cod_producto;

-- 2
select u.cod_cod_usuario as codigo,
       u.nombres as nombre
  from cod_usuario u
  join compra c
on u.cod_cod_usuario = c.cod_cod_usuario
 where extract(year from c.fecha) = 2023
   and extract(month from c.fecha) = 08
except
select u.cod_cod_usuario,
       u.nombres
  from cod_usuario u
  join compra c
on u.cod_cod_usuario = c.cod_cod_usuario
 where extract(year from c.fecha) = 2024
   and extract(month from c.fecha) = 10;

-- 3
-- Ciudades con compras > 10.000 en 2023
select cd.cod_ciudad as codigociudad,
       cd.nombre_ciudad as nombre_ciudad
  from ciudad cd
  join compra c
on cd.cod_ciudad = c.ciudad_entrega
  join prod_compra pc
on c.cod_usuario = pc.cod_usuario
   and c.nro_compra = pc.nro_compra
 where extract(year from c.fecha) = 2023
 group by cd.cod_ciudad,
          cd.nombre_ciudad
having sum(pc.precio_unitario * pc.cantidad) > 10000
intersect
select cd.cod_ciudad,
       cd.nombre_ciudad
  from ciudad cd
  join compra c
on cd.cod_ciudad = c.ciudad_entrega
  join prod_compra pc
on c.cod_usuario = pc.cod_usuario
   and c.nro_compra = pc.nro_compra
 where extract(year from c.fecha) = 2024
 group by cd.cod_ciudad,
          cd.nombre_ciudad
having sum(pc.precio_unitario * pc.cantidad) < 7000;

-- 4

WITH gabriela_eliminations AS (
  SELECT e.cod_producto
    FROM eliminados e
    JOIN usuario u
      ON e.cod_usuario = u.cod_usuario
    WHERE u.nombres = 'Gabriela'
        AND u.apellidos = 'Ramos'
     AND EXTRACT(YEAR FROM e.fecha_hora) = 2024
),
clients_eliminations AS (
  SELECT DISTINCT e.cod_usuario AS cod_usuario
    FROM eliminados e
   WHERE e.cod_producto IN (
     SELECT cod_producto
       FROM gabriela_eliminations
   )
     AND EXTRACT(YEAR FROM e.fecha_hora) = 2024
)
SELECT u.nombres AS nombre,
       u.apellidos AS apellido
  FROM usuario u
  JOIN clients_eliminations ce
    ON u.cod_usuario = ce.cod_usuario
 WHERE NOT (u.nombres = 'Gabriela'
    AND u.apellidos = 'Ramos');

-- 5
WITH purchases_ly AS (
  
  SELECT c.cod_usuario,
         SUM(pc.cantidad) AS total_cantidad
  FROM   compra c
  JOIN   prod_compra pc
    ON c.cod_usuario   = pc.cod_usuario
   AND c.nro_compra = pc.nro_compra
  WHERE  c.fecha >= ADD_MONTHS(TRUNC(SYSDATE), -12)
  GROUP  BY c.cod_usuario
),
average_quantity AS (
  
  SELECT AVG(total_cantidad) AS avgCantidad
  FROM   purchases_ly
)
SELECT u.nombres AS Nombre,
       u.apellidos     AS Apellidos,
       u.direccion     AS Direccion,
       cd.nombre_ciudad AS Ciudad
FROM   usuario u
JOIN   purchases_ly p 
  ON u.cod_usuario = p.cod_usuario
JOIN   average_quantity a 
  ON 1 = 1            
JOIN   ciudad cd
  ON u.ciudad = cd.cod_ciudad
WHERE  p.total_cantidad > a.avgCantidad;
