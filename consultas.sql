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


-- Calcula la comision total de cada vendedor en el periodo. Reutiliza
-- fn_ventas_vendedor, que ya trae la comision de cada venta.
SELECT e.nombre_completo AS vendedor,
       COUNT(f.id_venta) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(f.comision)) AS comision_total
FROM empleados e
CROSS APPLY dbo.fn_ventas_vendedor(e.id, @desde, @hasta) f
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
ORDER BY SUM(f.comision) DESC;


-- Lista las ventas a credito que todavia tienen saldo por pagar, de mayor a menor.
SELECT v.id AS id_venta,
       c.nombre_completo AS cliente,
       mo.modelo,
       dbo.fn_formatear_monto(v.precio) AS precio_venta,
       dbo.fn_formatear_monto(dbo.fn_saldo_pendiente(v.id)) AS saldo_pendiente
FROM ventas v
JOIN clientes c ON c.id = v.id_cliente
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN modelos mo ON mo.id = vh.id_modelo
WHERE v.medio_pago = 'credito'
  AND dbo.fn_saldo_pendiente(v.id) > 0
ORDER BY dbo.fn_saldo_pendiente(v.id) DESC;


-- Muestra los clientes que todavia tienen service gratuito vigente y hasta
-- cuando pueden usarlo.
SELECT v.id AS id_venta,
       c.nombre_completo AS cliente,
       vh.patente, mo.modelo,
       DATEADD(MONTH, v.meses_service, v.fecha) AS service_hasta
FROM ventas v
JOIN clientes c ON c.id = v.id_cliente
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN modelos mo ON mo.id = vh.id_modelo
WHERE dbo.fn_service_vigente(v.id, CAST(GETDATE() AS DATE)) = 1
ORDER BY service_hasta;


-- Cuenta los vehiculos disponibles y el valor de lista del stock por sucursal y
-- marca, a partir de vw_stock_disponible.
SELECT sucursal, marca,
       COUNT(*) AS unidades,
       dbo.fn_formatear_monto(SUM(precio_lista)) AS valor_stock
FROM vw_stock_disponible
GROUP BY sucursal, marca
ORDER BY sucursal, COUNT(*) DESC;


-- Obtiene el mayor y el menor precio de lista de cada marca, a partir de
-- vw_catalogo_modelos.
SELECT marca,
       COUNT(*) AS cantidad_modelos,
       dbo.fn_formatear_monto(MAX(precio_lista)) AS precio_maximo,
       dbo.fn_formatear_monto(MIN(precio_lista)) AS precio_minimo
FROM vw_catalogo_modelos
GROUP BY marca
ORDER BY marca;



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


-- Busca los modelos que nunca se vendieron. La subconsulta devuelve los modelos
-- de los vehiculos que figuran en alguna venta.
SELECT ma.nombre AS marca, mo.modelo,
       dbo.fn_formatear_monto(mo.precio) AS precio_lista
FROM modelos mo
JOIN marcas ma ON ma.id = mo.id_marca
WHERE mo.id NOT IN (
       SELECT vh.id_modelo
       FROM ventas v
       JOIN vehiculos vh ON vh.id = v.id_vehiculo
)
ORDER BY ma.nombre, mo.modelo;
