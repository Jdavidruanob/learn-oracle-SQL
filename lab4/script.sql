-- 1. Identificar tablas con las que se puede hacer NATURAL JOIN
-- Las tablas que pueden realizar NATURAL JOIN deben compartir nombres de columnas y tener una relación lógica.
-- Basado en el modelo, se pueden hacer NATURAL JOIN entre:
--    - `usuario` y `compra` (por usuario)
--    - `usuario` y `carritoCompras` (por usuario)
--    - `producto` y `carritoCompras` (por producto)
--    - `producto` y `eliminados` (por producto)
--    - `temaProducto` y `producto` (por idProducto)
--    - `temaProducto` y `tema` (por codTema)
--    - `ciudad` y `usuario` (por ciudad)
--    - `pais` y `ciudad` (por codPais)

-- 2. Productos eliminados de carritos en 2025 con detalles
SELECT e.producto, p.descripcion, t.nombre AS nombreTema, c.nombre AS nombreCategoria,
       u.nombres, u.apellidos, u.nombreUsuario
FROM DATABASE35.eliminados e
JOIN DATABASE35.producto p ON e.producto = p.idProducto
JOIN DATABASE35.temaProducto tp ON p.idProducto = tp.codProducto
JOIN DATABASE35.tema t ON tp.codTema = t.codTema
JOIN DATABASE35.categoria c ON p.categoria = c.codCategoria
JOIN DATABASE35.usuario u ON e.usuario = u.codUsuario
WHERE EXTRACT(YEAR FROM e.fecha) = 2025;

-- 3. Usuarios con productos en su carrito (incluyendo los que no tienen productos)
SELECT u.codUsuario, u.nombreUsuario, u.nombres, u.apellidos,
       c.producto, p.descripcion, p.precio
FROM DATABASE35.usuario u
LEFT JOIN DATABASE35.carritoCompras c ON u.codUsuario = c.usuario
LEFT JOIN DATABASE35.producto p ON c.producto = p.idProducto;

-- 4. Usuarios con su ciudad y país (incluyendo todos los usuarios y ciudades)
SELECT u.nombres, u.apellidos, u.direccion, c.nombreCiudad, p.nombrePais
FROM DATABASE35.usuario u
FULL OUTER JOIN DATABASE35.ciudad c ON u.ciudad = c.codCiudad
LEFT JOIN DATABASE35.pais p ON c.codPais = p.codPais;

-- 5. Valor total de las compras por ciudad
SELECT c.nombreCiudad, SUM(pc.precioUnitario * pc.cantidad) AS valorTotalCompras
FROM DATABASE35.compra co
JOIN DATABASE35.usuario u ON co.usuario = u.codUsuario
JOIN DATABASE35.ciudad c ON u.ciudad = c.codCiudad
JOIN DATABASE35.prodCompra pc ON co.nroCompra = pc.nroCompra
GROUP BY c.nombreCiudad;

-- 6. Precio promedio de los productos por tema
SELECT t.nombre, AVG(p.precio) AS precioPromedio
FROM DATABASE35.temaProducto tp
JOIN DATABASE35.tema t ON tp.codTema = t.codTema
JOIN DATABASE35.producto p ON tp.codProducto = p.idProducto
GROUP BY t.nombre;

-- 7. Máximo valor de productos vendidos en cada categoría por año
SELECT EXTRACT(YEAR FROM co.fecha) AS anio, c.nombre AS categoria,
       MAX(pc.precioUnitario) AS maxValor
FROM DATABASE35.compra co
JOIN DATABASE35.prodCompra pc ON co.nroCompra = pc.nroCompra
JOIN DATABASE35.producto p ON pc.producto = p.idProducto
JOIN DATABASE35.categoria c ON p.categoria = c.codCategoria
GROUP BY anio, c.nombre;

-- 8. Productos eliminados más de 7 veces
SELECT e.producto, p.descripcion
FROM DATABASE35.eliminados e
JOIN DATABASE35.producto p ON e.producto = p.idProducto
GROUP BY e.producto, p.descripcion;

-- 9. Usuarios que en algún año compraron más de $10,000 en total
SELECT u.nombres, u.apellidos
FROM DATABASE35.usuario u
JOIN DATABASE35.compra co ON u.codUsuario = co.usuario
JOIN DATABASE35.prodCompra pc ON co.nroCompra = pc.nroCompra
GROUP BY u.codUsuario, u.nombres, u.apellidos
HAVING SUM(pc.precioUnitario * pc.cantidad) > 10000;
