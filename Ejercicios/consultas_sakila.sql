USE sakila;
-- 1. 

SELECT TOP 10
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS NombreCompleto,
    COUNT(DISTINCT a.id_alquiler) AS CantidadPeliculasAlquiladas,
    SUM(p.monto) AS TotalPagado
FROM cliente c
INNER JOIN alquiler a
    ON c.id_cliente = a.id_cliente
INNER JOIN pago p
    ON a.id_alquiler = p.id_alquiler
GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellido
ORDER BY TotalPagado DESC;
GO



-- 2. 


SELECT
    t.id_tienda,
    c.nombre AS Categoria,
    SUM(p.monto) AS Ingresos
FROM pago p
INNER JOIN alquiler a
    ON p.id_alquiler = a.id_alquiler
INNER JOIN inventario i
    ON a.id_inventario = i.id_inventario
INNER JOIN pelicula pe
    ON i.id_pelicula = pe.id_pelicula
INNER JOIN pelicula_categoria pc
    ON pe.id_pelicula = pc.id_pelicula
INNER JOIN categoria c
    ON pc.id_categoria = c.id_categoria
INNER JOIN tienda t
    ON i.id_tienda = t.id_tienda
GROUP BY
    t.id_tienda,
    c.nombre
ORDER BY
    t.id_tienda,
    Ingresos DESC;
GO


-- 3. 


SELECT
    pe.titulo,
    'Tienda ' + CAST(t.id_tienda AS VARCHAR(5)) AS Tienda,
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS Cliente,
    a.fecha_alquiler
FROM alquiler a
INNER JOIN inventario i
    ON a.id_inventario = i.id_inventario
INNER JOIN pelicula pe
    ON i.id_pelicula = pe.id_pelicula
INNER JOIN tienda t
    ON i.id_tienda = t.id_tienda
INNER JOIN cliente c
    ON a.id_cliente = c.id_cliente
WHERE a.fecha_devolucion IS NULL
AND a.fecha_alquiler <= DATEADD(DAY,-15,GETDATE())
ORDER BY
    a.fecha_alquiler;
GO



-- 4. 


SELECT
    a.id_actor,
    a.nombre + ' ' + a.apellido AS Actor,
    COUNT(DISTINCT pc.id_categoria) AS CantidadCategorias
FROM actor a
INNER JOIN pelicula_actor pa
    ON a.id_actor = pa.id_actor
INNER JOIN pelicula_categoria pc
    ON pa.id_pelicula = pc.id_pelicula
GROUP BY
    a.id_actor,
    a.nombre,
    a.apellido
HAVING COUNT(DISTINCT pc.id_categoria) >= 5
ORDER BY
    CantidadCategorias DESC,
    Actor;
GO



-- 5.

SELECT
    p.id_pelicula,
    p.titulo,
    COUNT(a.id_alquiler) AS CantidadAlquileres,
    CASE
        WHEN COUNT(a.id_alquiler) > 30 THEN 'Alta Demanda'
        WHEN COUNT(a.id_alquiler) BETWEEN 10 AND 30 THEN 'Demanda Media'
        ELSE 'Baja Demanda / Sin Alquileres'
    END AS Clasificacion
FROM pelicula p
LEFT JOIN inventario i
    ON p.id_pelicula = i.id_pelicula
LEFT JOIN alquiler a
    ON i.id_inventario = a.id_inventario
GROUP BY
    p.id_pelicula,
    p.titulo
ORDER BY
    CantidadAlquileres DESC;
GO