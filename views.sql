SET QUOTED_IDENTIFIER ON;
GO
-- Stock disponible: detalle de los vehiculos que estan disponibles para la venta, con su marca, modelo y precio.
CREATE OR ALTER VIEW vw_stock_disponible AS
SELECT
    v.id AS id_vehiculo,
    s.nombre AS sucursal,
    ma.nombre AS marca,
    mo.modelo AS modelo,
    v.color AS color,
    v.chasis AS chasis,
    mo.precio AS precio_lista,
    e.fecha AS fecha_ingreso,
    p.nombre AS proveedor
FROM vehiculos v
    INNER JOIN modelos mo ON mo.id = v.id_modelo
    INNER JOIN marcas ma ON ma.id = mo.id_marca
    INNER JOIN sucursales s ON s.id = v.id_sucursal
    INNER JOIN entregas e ON e.id = v.id_entrega
    INNER JOIN proveedores p ON p.id = e.id_proveedor
WHERE v.estado = 'disponible';
GO

-- Ventas registradas: detalle de las ventas registradas, con el estado de cada una.
CREATE OR ALTER VIEW vw_catalogo_modelos AS
SELECT
    ma.nombre AS marca,
    ma.origen AS origen,
    mo.modelo AS modelo,
    mo.fecha_lanzamiento AS fecha_lanzamiento,
    mo.precio AS precio_lista
FROM modelos mo
    INNER JOIN marcas ma ON ma.id = mo.id_marca;
GO

-- Cuotas pendientes: detalle de las cuotas que no han sido pagadas, con el estado de cada una.
CREATE OR ALTER VIEW vw_cuotas_pendientes AS
SELECT
    cu.id AS id_cuota,
    ve.id AS id_venta,
    c.nombre_completo AS cliente,
    c.telefono AS telefono,
    c.email AS email,
    ma.nombre AS marca,
    mo.modelo AS modelo,
    vh.patente AS patente,
    cu.nro_cuota AS nro_cuota,
    cu.monto AS monto,
    cu.vencimiento AS vencimiento,
    CASE
        WHEN cu.vencimiento < CAST(GETDATE() AS DATE) THEN 'vencida'
        ELSE 'a vencer'
    END AS estado,
    CASE
        WHEN cu.vencimiento < CAST(GETDATE() AS DATE)
            THEN DATEDIFF(DAY, cu.vencimiento, CAST(GETDATE() AS DATE))
        ELSE 0
    END AS dias_atraso
FROM cuotas cu
    INNER JOIN ventas ve ON ve.id = cu.id_venta
    INNER JOIN clientes c ON c.id = ve.id_cliente
    INNER JOIN vehiculos vh ON vh.id = ve.id_vehiculo
    INNER JOIN modelos mo ON mo.id = vh.id_modelo
    INNER JOIN marcas ma ON ma.id = mo.id_marca
WHERE cu.fecha_pago IS NULL;
GO

-- Service programados: detalle de los service que estan programados, con el estado de cada uno.
CREATE OR ALTER VIEW vw_service_programados AS
SELECT
    sv.id AS id_service,
    sv.fecha AS fecha_service,
    t.nombre AS taller,
    t.direccion AS direccion_taller,
    c.nombre_completo AS cliente,
    c.telefono AS telefono,
    c.email AS email,
    ma.nombre AS marca,
    mo.modelo AS modelo,
    vh.patente AS patente,
    ve.fecha AS fecha_venta,
    ve.meses_service AS meses_service,
    DATEADD(MONTH, ve.meses_service, ve.fecha) AS fin_cobertura,
    CASE
        WHEN sv.fecha <= DATEADD(MONTH, ve.meses_service, ve.fecha) THEN 'vigente'
        ELSE 'vencida'
    END AS cobertura
FROM service sv
    INNER JOIN talleres t ON t.id = sv.id_taller
    INNER JOIN ventas ve ON ve.id = sv.id_venta
    INNER JOIN clientes c ON c.id = ve.id_cliente
    INNER JOIN vehiculos vh ON vh.id = ve.id_vehiculo
    INNER JOIN modelos mo ON mo.id = vh.id_modelo
    INNER JOIN marcas ma ON ma.id = mo.id_marca
WHERE sv.fecha >= CAST(GETDATE() AS DATE);
GO
