SET QUOTED_IDENTIFIER ON;

-- sucursales
INSERT INTO sucursales (nombre, direccion, telefono) VALUES
('Sucursal Palermo',    'Av. Santa Fe 3500, CABA',  '11-4777-1001'),
('Sucursal Belgrano',   'Av. Cabildo 2200, CABA',   '11-4777-1002'),
('Sucursal Avellaneda', 'Av. Mitre 850, Avellaneda', '11-4777-1003');


-- clientes
INSERT INTO clientes (nombre_completo, dni, fecha_nacimiento, email, telefono) VALUES
('Martin Gomez',     '30123456', '1990-04-12', 'martin.gomez@mail.com',     '11-5555-1001'),
('Lucia Fernandez',  '35234567', '1994-09-23', 'lucia.fernandez@mail.com',  '11-5555-1002'),
('Carlos Rodriguez', '28345678', '1985-01-30', 'carlos.rodriguez@mail.com', NULL);


-- empleados - 1 y 2 son vendedores.
INSERT INTO empleados (nombre_completo, dni, id_sucursal, tipo, estado, fecha_ingreso, sueldo) VALUES
('Juan Perez',    '27111222', 1, 'vendedor', 'activo', '2020-03-15', 1200000),
('Sofia Ramirez', '32333444', 2, 'vendedor', 'activo', '2021-07-01', 1150000),
('Diego Torres',  '29555666', 3, 'gerente',  'activo', '2018-11-20', 2000000);


-- marcas
INSERT INTO marcas (nombre, origen, fecha_fundacion) VALUES
('Nissan', 'Japon',          '1933-12-26'),
('Ford',   'Estados Unidos', '1903-06-16'),
('Toyota', 'Japon',          '1937-08-28');


-- autos 
INSERT INTO autos (modelo, fecha_lanzamiento, id_marca, precio) VALUES
('Frontier', '2023-03-01', 1, 45000000),
('Maverick', '2022-05-10', 2, 42000000),
('Corolla',  '2023-01-15', 3, 38000000);


-- proveedores
INSERT INTO proveedores (nombre, telefono, direccion, cuit) VALUES
('Nissan Argentina S.A.', '11-4000-1111', 'Av. del Libertador 2000, CABA', '30-11111111-1'),
('Ford Argentina S.C.A.', '11-4000-2222', 'Ruta 9 km 50, Pacheco',         '30-22222222-2'),
('Toyota Argentina S.A.', '11-4000-3333', 'Ruta 12 km 80, Zarate',         '30-33333333-3');


-- entregas
INSERT INTO entregas (fecha, id_proveedor, id_sucursal) VALUES
('2025-01-20', 1, 1),
('2025-02-15', 2, 2),
('2025-03-10', 3, 3);


-- vehiculos - los tres están vendidos porque cada uno se usa en una venta más abajo.
INSERT INTO vehiculos (chasis, patente, id_auto, id_sucursal, id_entrega, color, estado) VALUES
('9BFZZZ54ZPB000001', 'AG123AB', 1, 1, 1, 'Gris',   'vendido'),
('9BFZZZ54ZPB000002', 'AG456CD', 2, 2, 2, 'Blanco', 'vendido'),
('9BFZZZ54ZPB000003', 'AG789EF', 3, 3, 3, 'Negro',  'vendido');


-- plataformas
INSERT INTO plataformas (nombre) VALUES
('Presencial'),
('Sitio web'),
('WhatsApp');


-- ventas - un vehiculo solo puede venderse una vez (claramente).
INSERT INTO ventas (id_cliente, id_vendedor, id_vehiculo, id_plataforma, fecha, precio, medio_pago, meses_service) VALUES
(1, 1, 1, 1, '2025-02-10', 44000000, 'transferencia', 12),
(2, 2, 2, 2, '2025-03-18', 42000000, 'credito',        6),
(3, 1, 3, 3, '2025-04-05', 37500000, 'efectivo',       6);


-- talleres
INSERT INTO talleres (nombre, direccion) VALUES
('Taller Central', 'Av. San Martin 1200, CABA'),
('Taller Lanus',   'Calle 25 de Mayo 450, Lanus'),
('Taller Oeste',   'Av. Rivadavia 7800, CABA');


-- service Gratuito exige costo 0 y pago exige costo mayor a 0 (chk_service_costo_gratuito).
INSERT INTO service (id_venta, id_taller, fecha, tipo, costo) VALUES
(1, 1, '2025-08-10', 'gratuito',      0),
(2, 2, '2025-09-15', 'pago',      95000),
(3, 3, '2025-10-01', 'pago',     120000);


-- registro_runa -> El cliente debe coincidir con el de la venta de ese vehiculo.
INSERT INTO registro_runa (id_vehiculo, id_cliente, fecha, nro_tramite) VALUES
(1, 1, '2025-02-15', 'RUNA-2025-0001'),
(2, 2, '2025-03-25', 'RUNA-2025-0002'),
(3, 3, '2025-04-12', 'RUNA-2025-0003');


-- log_errores 
INSERT INTO log_errores (fecha, procedimiento, numero_error, mensaje) VALUES
('2025-05-02 10:15:00', 'sp_registrar_venta',    2627, 'Violacion de restriccion UNIQUE: el vehiculo ya fue vendido'),
('2025-06-11 16:40:00', 'sp_actualizar_precio',   547, 'Conflicto con la restriccion FOREIGN KEY: el auto no existe'),
('2025-07-23 09:05:00', 'sp_registrar_service',   547, 'Conflicto con la restriccion CHECK chk_service_costo_gratuito');


-- historial_precio
INSERT INTO historial_precios (id_auto, precio_anterior, precio_nuevo, fecha) VALUES
(1, 43000000, 45000000, '2024-12-01 09:00:00'),
(2, 40000000, 42000000, '2024-12-01 09:05:00'),
(3, 36000000, 38000000, '2024-12-01 09:10:00');


-- cuotas - la cuota 3 queda sin pagar.
INSERT INTO cuotas (id_venta, nro_cuota, monto, vencimiento, fecha_pago) VALUES
(2, 1, 14000000, '2025-04-18', '2025-04-17'),
(2, 2, 14000000, '2025-05-18', '2025-05-20'),
(2, 3, 14000000, '2025-06-18', NULL);


-- comisiones (una por venta, equivalente al 2% del precio de venta) - la comision de la venta 3 todavia no fue liquidada (fecha_liquidacion NULL).
INSERT INTO comisiones (id_venta, monto, fecha_liquidacion) VALUES
(1, 880000, '2025-03-05'),
(2, 840000, '2025-04-05'),
(3, 750000, NULL);