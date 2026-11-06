-- Muestra las ventas de un periodo con el cliente, el vendedor, el modelo, el
-- precio y la comision. Usa fn_ventas_vendedor con CROSS APPLY, una vez por cada
-- vendedor, en lugar de repetir los JOIN de ventas, clientes, vehiculos, modelos
-- y marcas.
DECLARE @desde DATE = '2025-01-01';
DECLARE @hasta DATE = CAST(GETDATE() AS DATE);

SELECT f.id_venta, f.fecha,
       f.cliente,
       e.nombre_completo AS vendedor,
       f.marca, f.modelo,
       dbo.fn_formatear_monto(f.precio) AS precio_venta,
       dbo.fn_formatear_monto(f.comision) AS comision
FROM empleados e
CROSS APPLY dbo.fn_ventas_vendedor(e.id, @desde, @hasta) f
WHERE e.tipo = 'vendedor'
ORDER BY f.fecha DESC, f.id_venta DESC;


-- Calcula la cantidad de ventas y el total vendido por sucursal.
SELECT s.nombre AS sucursal,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM ventas v
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN sucursales s ON s.id = vh.id_sucursal
GROUP BY s.id, s.nombre
ORDER BY SUM(v.precio) DESC;


-- Muestra los vendedores con al menos dos ventas y su facturacion.
SELECT e.nombre_completo AS vendedor,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM empleados e
JOIN ventas v ON v.id_vendedor = e.id
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
HAVING COUNT(v.id) >= 2
ORDER BY SUM(v.precio) DESC;


-- Obtiene el mayor y el menor precio de lista de los modelos.
SELECT dbo.fn_formatear_monto(MAX(precio)) AS precio_maximo,
       dbo.fn_formatear_monto(MIN(precio)) AS precio_minimo
FROM modelos;


-- Resume las ventas por medio de pago.
SELECT medio_pago,
       COUNT(*) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(precio)) AS total_vendido
FROM ventas
GROUP BY medio_pago
ORDER BY COUNT(*) DESC, medio_pago;



-- Subconsultas

-- Lista los modelos cuyo precio de lista supera el promedio. El promedio lo
-- calcula la subconsulta.
SELECT ma.nombre AS marca, mo.modelo,
       dbo.fn_formatear_monto(mo.precio) AS precio_lista
FROM modelos mo
JOIN marcas ma ON ma.id = mo.id_marca
WHERE mo.precio > (
       SELECT AVG(CAST(precio AS DECIMAL(19,2)))
       FROM modelos
)
ORDER BY mo.precio DESC;


-- Busca los clientes con mas de una venta registrada.
SELECT c.id, c.nombre_completo, c.email
FROM clientes c
WHERE c.id IN (
       SELECT v.id_cliente
       FROM ventas v
       GROUP BY v.id_cliente
       HAVING COUNT(*) > 1
)
ORDER BY c.nombre_completo;


-- Muestra los vendedores que vendieron mas que el promedio de ventas por
-- vendedor. La subconsulta calcula ese promedio.
SELECT e.nombre_completo AS vendedor,
       COUNT(v.id) AS cantidad_ventas
FROM empleados e
JOIN ventas v ON v.id_vendedor = e.id
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
HAVING COUNT(v.id) > (
       SELECT AVG(CAST(x.cantidad AS DECIMAL(10,2)))
       FROM (
              SELECT COUNT(*) AS cantidad
              FROM ventas
              GROUP BY id_vendedor
       ) x
)
ORDER BY cantidad_ventas DESC;


-- Verifica si falta el registro RUNA de algun vehiculo vendido.
SELECT v.id AS id_venta, v.fecha,
       c.nombre_completo AS cliente,
       vh.chasis, vh.patente
FROM ventas v
JOIN clientes c ON c.id = v.id_cliente
JOIN vehiculos vh ON vh.id = v.id_vehiculo
WHERE NOT EXISTS (
       SELECT 1
       FROM registro_runa r
       WHERE r.id_vehiculo = v.id_vehiculo
)
ORDER BY v.fecha, v.id;


-- Muestra las ventas de un período con cliente, vendedor y vehículo.
DECLARE @desde DATE = '2025-01-01';
DECLARE @hasta DATE = CAST(GETDATE() AS DATE);

SELECT v.id AS id_venta, v.fecha,
       c.nombre_completo AS cliente,
       e.nombre_completo AS vendedor,
       ma.nombre AS marca, mo.modelo,
       dbo.fn_formatear_monto(v.precio) AS precio_venta,
       v.medio_pago
FROM ventas v
JOIN clientes c ON c.id = v.id_cliente
JOIN empleados e ON e.id = v.id_vendedor
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN modelos mo ON mo.id = vh.id_modelo
JOIN marcas ma ON ma.id = mo.id_marca
WHERE v.fecha BETWEEN @desde AND @hasta
ORDER BY v.fecha DESC, v.id DESC;


-- Calcula la cantidad de ventas y el total vendido por sucursal.
SELECT s.nombre AS sucursal,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM ventas v
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN sucursales s ON s.id = vh.id_sucursal
GROUP BY s.id, s.nombre
ORDER BY SUM(v.precio) DESC;


-- Muestra vendedores con al menos dos ventas y su facturación.
SELECT e.nombre_completo AS vendedor,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM empleados e
JOIN ventas v ON v.id_vendedor = e.id
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
HAVING COUNT(v.id) >= 2
ORDER BY SUM(v.precio) DESC;


-- Obtiene el mayor y el menor precio de lista de los modelos.
SELECT dbo.fn_formatear_monto(MAX(precio)) AS precio_maximo,
       dbo.fn_formatear_monto(MIN(precio)) AS precio_minimo
FROM modelos;


-- Resume las ventas por medio de pago.
SELECT medio_pago,
       COUNT(*) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(precio)) AS total_vendido
FROM ventas
GROUP BY medio_pago
ORDER BY COUNT(*) DESC, medio_pago;



-- Subconsultas

-- Calcula el precio promedio para filtrar los modelos más caros.
SELECT ma.nombre AS marca, mo.modelo,
       dbo.fn_formatear_monto(mo.precio) AS precio_lista
FROM modelos mo
JOIN marcas ma ON ma.id = mo.id_marca
WHERE mo.precio > (
    SELECT AVG(CAST(precio AS DECIMAL(19,2)))
    FROM modelos
)
ORDER BY mo.precio DESC;

-- Busca clientes con más de una venta registrada.
SELECT c.id, c.nombre_completo, c.email
FROM clientes c
WHERE c.id IN (
    SELECT v.id_cliente
    FROM ventas v
    GROUP BY v.id_cliente
    HAVING COUNT(*) > 1
)
ORDER BY c.nombre_completo;


-- Calculan el promedio de ventas por vendedor para compararlo con cada uno.
SELECT e.nombre_completo AS vendedor,
       COUNT(v.id) AS cantidad_ventas
FROM empleados e
JOIN ventas v ON v.id_vendedor = e.id
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
HAVING COUNT(v.id) > (
    SELECT AVG(CAST(x.cantidad AS DECIMAL(10,2)))
    FROM (
        SELECT COUNT(*) AS cantidad
        FROM ventas
        GROUP BY id_vendedor
    ) x
)
ORDER BY cantidad_ventas DESC;


-- Verifica si falta el registro RUNA del vehículo vendido.
SELECT v.id AS id_venta, v.fecha,
       c.nombre_completo AS cliente,
       vh.chasis, vh.patente
FROM ventas v
JOIN clientes c ON c.id = v.id_cliente
JOIN vehiculos vh ON vh.id = v.id_vehiculo
WHERE NOT EXISTS (
    SELECT 1
    FROM registro_runa r
    WHERE r.id_vehiculo = v.id_vehiculo
)
ORDER BY v.fecha, v.id;