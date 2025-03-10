-- 1. Liste el nombre de las ciudades y el código del país donde están.
SELECT nombre_ciudad, cod_pais
FROM ciudad;

-- 2. Seleccione todos los datos del usuario Pedro Ramos.
SELECT * 
FROM usuario 
WHERE nombres = 'Pedro' AND apellidos = 'Ramos';

-- 3. Liste de cada producto el id, la descripción y el volumen que ocupan.
SELECT id_producto, descripcion, (largo * alto * ancho) AS volumen
FROM producto;

-- 4. Liste el mes y año de las compras.
SELECT DISTINCT EXTRACT(MONTH FROM fecha) AS mes, EXTRACT(YEAR FROM fecha) AS año
FROM compra;

-- 5. Liste los usuarios que tienen un correo que no tiene la arroba (@).
SELECT * 
FROM usuario 
WHERE correo NOT LIKE '%@%';

-- 6. Seleccione el promedio del precio de los productos.
SELECT AVG(precio) AS precio_promedio
FROM producto;

-- 7. Seleccione el valor total de los productos que ha comprado el usuario con código 21.
SELECT SUM(precio_unitario * cantidad) AS valor_total
FROM prod_compra
WHERE cod_usuario = 21;

-- 8. Liste los datos del carrito de compras del usuario Daniela Fernandez.
SELECT * 
FROM carrito_compras 
WHERE cod_usuario IN (
    SELECT cod_usuario 
    FROM usuario 
    WHERE nombres = 'Daniela' AND apellidos = 'Fernandez'
);


-- 9. De las compras de enero del 2024, liste el id y descripción del producto, su precio, el nombre del tema, y el nombre de la categoría a la que pertenece el producto.
SELECT 
    P.id_producto, 
    P.descripcion, 
    P.precio, 
    T.nombre AS nombre_tema, 
    C.nombre AS nombre_categoria
FROM prod_compra PC
JOIN producto P ON PC.cod_producto = P.id_producto  
JOIN tema_producto TP ON P.id_producto = TP.cod_producto
JOIN tema T ON TP.cod_tema = T.cod_tema
JOIN categoria C ON P.cod_categoria = C.cod_categoria  -- Cambio "P.categoria" -> "P.cod_categoria"
WHERE PC.nro_compra IN (
    SELECT nro_compra 
    FROM compra 
    WHERE EXTRACT(YEAR FROM fecha) = 2024 
    AND EXTRACT(MONTH FROM fecha) = 1
);


-- 10. Liste el código y nombre de los usuarios que han recibido productos en una ciudad distinta a la ciudad donde viven.
SELECT DISTINCT U.cod_usuario, U.nombre_usuario
FROM usuario U
JOIN compra C ON U.cod_usuario = C.cod_usuario
JOIN ciudad CU_USUARIO ON U.ciudad = CU_USUARIO.cod_ciudad
JOIN ciudad CU_COMPRA ON C.dir_entrega = CU_COMPRA.nombre_ciudad -- Comparar nombre con nombre
WHERE CU_USUARIO.nombre_ciudad <> CU_COMPRA.nombre_ciudad;



