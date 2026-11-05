SET QUOTED_IDENTIFIER ON;

-- Las comisiones, el historial de precios y el log de errores los
-- generan los triggers y los procedimientos.
-- Varias fechas se calculan con GETDATE() (por ejemplo "hace 130 dias") en
-- vez de escribirlas fijas. Asi siempre hay cuotas vencidas y service que
-- todavia no ocurrieron, sin importar cuando se ejecute el script.

-- sucursales
INSERT INTO sucursales (nombre, direccion, telefono) VALUES
('Sucursal Palermo',    'Av. Santa Fe 3500, CABA',  '11-4879-1183'),
('Sucursal Belgrano',   'Av. Cabildo 2200, CABA',   '11-4777-9923'),
('Sucursal Avellaneda', 'Av. Mitre 850, Avellaneda', '11-3995-7719');


-- clientes
INSERT INTO clientes (nombre_completo, dni, fecha_nacimiento, email, telefono) VALUES
('Martin Gomez',     '30481926', '1990-04-12', 'martin.gomez@mail.com',     '11-6142-7730'),
('Lucia Fernandez',  '35927413', '1994-09-23', 'lucia.fernandez@mail.com',  '11-5391-2084'),
('Carlos Rodriguez', '28660357', '1985-01-30', 'carlos.rodriguez@mail.com', NULL),
('Valentina Suarez', '39205841', '1996-08-03', 'valentina.suarez@mail.com',  '11-4521-8860'),
('Tomas Acosta',     '33874120', '1988-11-19', 'tomas.acosta@mail.com',      '11-6073-2419'),
('Camila Ortiz',     '42316755', '2001-02-27', 'camila.ortiz@mail.com',      '11-5288-6402'),
('Ramiro Diaz',      '24590173', '1979-06-08', 'ramiro.diaz@mail.com',       NULL),
-- menor de edad: sirve para probar que no puede comprar
('Joaquin Molina',   '51740298', DATEADD(YEAR, -16, GETDATE()), 'joaquin.molina@mail.com', '11-3947-5516');


-- empleados - 1, 2 y 4 son vendedores activos, el 5 es vendedor de licencia.
INSERT INTO empleados (nombre_completo, dni, id_sucursal, tipo, estado, fecha_ingreso, sueldo) VALUES
('Juan Perez',    '27394618', 1, 'vendedor', 'activo', '2020-03-15', 1200000),
('Sofia Ramirez', '32805271', 2, 'vendedor', 'activo', '2021-07-01', 1150000),
('Diego Torres',  '29148803', 3, 'gerente',  'activo', '2018-11-20', 2000000),
('Marcos Benitez', '33706284', 3, 'vendedor', 'activo',   '2022-02-14', 1180000),
('Paula Castro',   '31452907', 1, 'vendedor', 'licencia', '2019-09-02', 1250000),
('Ana Lopez',      '30918365', 2, 'contador', 'activo',   '2021-04-26', 1400000);


-- marcas
INSERT INTO marcas (nombre, origen, fecha_fundacion) VALUES
('Nissan', 'Japon',          '1933-12-26'),
('Ford',   'Estados Unidos', '1903-06-16'),
('Toyota', 'Japon',          '1937-08-28'),
('Volkswagen', 'Alemania',   '1937-05-28');


-- modelos
INSERT INTO modelos (modelo, fecha_lanzamiento, id_marca, precio) VALUES
('Frontier', '2023-03-01', 1, 6500000000),
('Maverick', '2022-05-10', 2, 5500000000),
('Corolla',  '2023-01-15', 3, 4200000000),
('Versa',    '2024-02-01', 1, 3800000000),
('Ranger',   '2023-08-15', 2, 7200000000),
('Hilux',    '2023-06-01', 3, 7800000000),
('Yaris',    '2024-01-10', 3, 3300000000),
('Amarok',   '2023-10-01', 4, 7600000000);


-- proveedores
INSERT INTO proveedores (nombre, telefono, direccion, cuit) VALUES
('Nissan Argentina S.A.', '11-4318-5602', 'Av. del Libertador 2000, CABA', '30-70824519-3'),
('Ford Argentina S.C.A.', '11-4752-9941', 'Ruta 9 km 50, Pacheco',         '30-50317864-8'),
('Toyota Argentina S.A.', '11-4896-1273', 'Calle Justa Lima 1420, Zarate', '30-68105927-4'),
('Volkswagen Argentina S.A.', '11-4691-3375', 'Av. General Paz 11200, CABA',  '30-59238146-1');


-- entregas
INSERT INTO entregas (fecha, id_proveedor, id_sucursal) VALUES
('2025-01-20', 1, 1),
('2025-02-15', 2, 2),
('2025-03-10', 3, 3),
(DATEADD(DAY, -300, GETDATE()), 4, 1),
(DATEADD(DAY, -220, GETDATE()), 3, 2),
(DATEADD(DAY, -160, GETDATE()), 1, 3),
(DATEADD(DAY, -150, GETDATE()), 2, 1);


-- vehiculos - no se indican ni la patente (se asigna al vender) ni el estado,
-- asi que todos entran como 'disponible'. Los 8 primeros se venden mas abajo con
-- sp_registrar_venta. Los ultimos 7 siguen en stock.
INSERT INTO vehiculos (chasis, id_modelo, id_sucursal, id_entrega, color) VALUES
('9BFZZZ54ZPB482917', 1, 1, 1, 'Gris'),
('9BFZZZ54ZPB139654', 2, 2, 2, 'Blanco'),
('9BFZZZ54ZPB807326', 3, 3, 3, 'Negro'),
('8AJFZ29G4PB316075', 6, 2, 5, 'Blanco'),
('9BRBL5JE4RB641208', 7, 2, 5, 'Rojo'),
('94DCC4C16RB208734', 4, 3, 6, 'Plata'),
('8AFAR22N3PB755901', 5, 1, 7, 'Negro'),
('8AWDB45Z7PB094382', 8, 1, 4, 'Azul'),
('94DCC4C19RB512640', 1, 3, 6, 'Blanco'),
('9BRBL5JE1RB873415', 3, 2, 5, 'Gris'),
('8AFAR22N8RB360927', 2, 1, 7, 'Rojo'),
('8AJFZ29G6RB947120', 6, 2, 5, 'Negro'),
('8AWDB45Z2RB185563', 8, 1, 4, 'Gris'),
('94DCC4C13RB426809', 4, 3, 6, 'Azul');

INSERT INTO vehiculos (chasis, id_modelo, id_sucursal, id_entrega, color, estado) VALUES
('8AFAR22N1RB772236', 5, 1, 7, 'Blanco', 'reservado');


-- plataformas
INSERT INTO plataformas (nombre) VALUES
('Presencial'),
('Sitio web'),
('WhatsApp');


-- ventas - se registran con sp_registrar_venta, que valida la venta, marca el
-- vehiculo como vendido y le asigna la patente. La comision la genera el trigger.
-- Casi todas llevan una fecha propia para que haya ventas de distintos momentos.
DECLARE @id_venta INT, @fecha_venta DATE; -- EXEC no acepta funciones como valor de un parametro

EXEC sp_registrar_venta @id_cliente = 1, @id_vendedor = 1, @id_vehiculo = 1, @id_plataforma = 1,
     @precio = 6400000000, @medio_pago = 'transferencia', @patente = 'AG482KT', @meses_service = 12, @fecha = '2025-02-10', @id_venta = @id_venta OUTPUT;

EXEC sp_registrar_venta @id_cliente = 2, @id_vendedor = 2, @id_vehiculo = 2, @id_plataforma = 2,
     @precio = 5500000000, @medio_pago = 'credito', @patente = 'AF917MR', @meses_service = 6, @fecha = '2025-03-18', @id_venta = @id_venta OUTPUT;

EXEC sp_registrar_venta @id_cliente = 3, @id_vendedor = 1, @id_vehiculo = 3, @id_plataforma = 3,
     @precio = 4100000000, @medio_pago = 'efectivo', @patente = 'AH265BX', @meses_service = 6, @fecha = '2025-04-05', @id_venta = @id_venta OUTPUT;

SET @fecha_venta = DATEADD(DAY, -130, GETDATE());
EXEC sp_registrar_venta @id_cliente = 4, @id_vendedor = 4, @id_vehiculo = 4, @id_plataforma = 2,
     @precio = 7700000000, @medio_pago = 'credito', @patente = 'AD316RW', @meses_service = 12, @fecha = @fecha_venta, @id_venta = @id_venta OUTPUT;

SET @fecha_venta = DATEADD(DAY, -45, GETDATE());
EXEC sp_registrar_venta @id_cliente = 5, @id_vendedor = 1, @id_vehiculo = 5, @id_plataforma = 3,
     @precio = 3250000000, @medio_pago = 'credito', @patente = 'AE641QL', @meses_service = 6, @fecha = @fecha_venta, @id_venta = @id_venta OUTPUT;

SET @fecha_venta = DATEADD(DAY, -60, GETDATE());
EXEC sp_registrar_venta @id_cliente = 6, @id_vendedor = 4, @id_vehiculo = 6, @id_plataforma = 1,
     @precio = 3750000000, @medio_pago = 'efectivo', @patente = 'AF208NT', @meses_service = 6, @fecha = @fecha_venta, @id_venta = @id_venta OUTPUT;

SET @fecha_venta = DATEADD(DAY, -90, GETDATE());
EXEC sp_registrar_venta @id_cliente = 2, @id_vendedor = 2, @id_vehiculo = 7, @id_plataforma = 1,
     @precio = 7100000000, @medio_pago = 'debito', @patente = 'AG755PD', @meses_service = 12, @fecha = @fecha_venta, @id_venta = @id_venta OUTPUT;

SET @fecha_venta = DATEADD(DAY, -20, GETDATE());
EXEC sp_registrar_venta @id_cliente = 7, @id_vendedor = 1, @id_vehiculo = 8, @id_plataforma = 2,
     @precio = 7500000000, @medio_pago = 'transferencia', @patente = 'AH094SM', @meses_service = 12, @fecha = @fecha_venta, @id_venta = @id_venta OUTPUT;

-- una venta de hoy (sin indicar la fecha)
EXEC sp_registrar_venta @id_cliente = 3, @id_vendedor = 2, @id_vehiculo = 9, @id_plataforma = 1,
     @precio = 6600000000, @medio_pago = 'efectivo', @patente = 'AH512JV', @id_venta = @id_venta OUTPUT;


-- talleres
INSERT INTO talleres (nombre, direccion) VALUES
('Taller Central', 'Av. San Martin 1200, CABA'),
('Taller Lanus',   'Calle 25 de Mayo 450, Lanus'),
('Taller Oeste',   'Av. Rivadavia 7800, CABA');


-- service
INSERT INTO service (id_venta, id_taller, fecha) VALUES
(1, 1, '2025-08-10'),
(2, 2, '2025-09-15'),
(3, 3, '2025-10-01'),
(4, 1, DATEADD(DAY,  30, GETDATE())),
(6, 2, DATEADD(DAY,  10, GETDATE())),
(7, 3, DATEADD(DAY, -10, GETDATE())),
(8, 1, DATEADD(DAY,  60, GETDATE()));


-- registro_runa -> El cliente debe coincidir con el de la venta de ese vehiculo.
INSERT INTO registro_runa (id_vehiculo, id_cliente, fecha, nro_tramite) VALUES
(1, 1, '2025-02-15', 'RUNA-2025-0417'),
(2, 2, '2025-03-25', 'RUNA-2025-0583'),
(3, 3, '2025-04-12', 'RUNA-2025-0731'),
(4, 4, DATEADD(DAY, -120, GETDATE()), 'RUNA-2026-0149'),
(6, 6, DATEADD(DAY,  -50, GETDATE()), 'RUNA-2026-0267'),
(7, 2, DATEADD(DAY,  -80, GETDATE()), 'RUNA-2026-0352');


-- cuotas - las genera el procedimiento para las ventas a credito (2, 4 y 5).
EXEC sp_generar_cuotas @id_venta = 2, @cantidad = 3;
EXEC sp_generar_cuotas @id_venta = 4, @cantidad = 6;
EXEC sp_generar_cuotas @id_venta = 5, @cantidad = 3;

-- pagos: la venta 2 las pago todas, la 4 pago 3 (la cuarta esta vencida y las
-- otras dos por vencer) y la 5 no pago ninguna (la primera ya vencio).
UPDATE cuotas SET fecha_pago = vencimiento WHERE id_venta = 2;
UPDATE cuotas SET fecha_pago = vencimiento WHERE id_venta = 4 AND nro_cuota <= 3;

-- la comision de la venta 1 ya se liquido, las demas quedan pendientes
UPDATE comisiones SET fecha_liquidacion = '2025-03-05' WHERE id_venta = 1;


-- historial_precios - lo llena el trigger de modelos al cambiar precios.
EXEC sp_actualizar_precio_modelo @id_modelo = 1, @precio_nuevo = 6700000000;
EXEC sp_actualizar_precio_modelo @id_modelo = 3, @precio_nuevo = 4300000000;
EXEC sp_actualizar_precio_modelo @id_modelo = 6, @precio_nuevo = 7900000000;
EXEC sp_actualizar_precio_modelo @id_modelo = 2, @precio_nuevo = 5600000000;


-- log_errores - llamadas que fallan a proposito. Cada procedimiento guarda el
-- error y lo vuelve a lanzar, por eso van dentro de un TRY que solo imprime el mensaje.

-- vehiculo ya vendido (51004)
BEGIN TRY
       EXEC sp_registrar_venta @id_cliente = 2, @id_vendedor = 2, @id_vehiculo = 1,
            @id_plataforma = 2, @precio = 6400000000, @medio_pago = 'transferencia',
            @patente = 'AB111CD', @id_venta = @id_venta OUTPUT;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;

-- cliente menor de edad (51002)
BEGIN TRY
       EXEC sp_registrar_venta @id_cliente = 8, @id_vendedor = 1, @id_vehiculo = 10,
            @id_plataforma = 1, @precio = 4300000000, @medio_pago = 'efectivo',
            @patente = 'AB222EF', @id_venta = @id_venta OUTPUT;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;

-- vendedor de licencia (51003)
BEGIN TRY
       EXEC sp_registrar_venta @id_cliente = 4, @id_vendedor = 5, @id_vehiculo = 10,
            @id_plataforma = 1, @precio = 4300000000, @medio_pago = 'efectivo',
            @patente = 'AB333GH', @id_venta = @id_venta OUTPUT;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;

-- modelo inexistente (51201)
BEGIN TRY
       EXEC sp_actualizar_precio_modelo @id_modelo = 99, @precio_nuevo = 5000000000;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;

-- precio igual al actual (51202)
BEGIN TRY
       EXEC sp_actualizar_precio_modelo @id_modelo = 1, @precio_nuevo = 6700000000;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;

-- cantidad de cuotas invalida (51101)
BEGIN TRY
       EXEC sp_generar_cuotas @id_venta = 4, @cantidad = 0;
END TRY
BEGIN CATCH
       PRINT ERROR_MESSAGE();
END CATCH;
