SET QUOTED_IDENTIFIER ON;

-- sucursales
INSERT INTO sucursales (nombre, direccion, telefono) VALUES
('Sucursal Palermo',    'Av. Santa Fe 3500, CABA',  '11-4879-1183'),
('Sucursal Belgrano',   'Av. Cabildo 2200, CABA',   '11-4777-9923'),
('Sucursal Avellaneda', 'Av. Mitre 850, Avellaneda', '11-3995-7719');


-- clientes
INSERT INTO clientes (nombre_completo, dni, fecha_nacimiento, email, telefono) VALUES
('Martin Gomez',     '30481926', '1990-04-12', 'martin.gomez@mail.com',     '11-6142-7730'),
('Lucia Fernandez',  '35927413', '1994-09-23', 'lucia.fernandez@mail.com',  '11-5391-2084'),
('Carlos Rodriguez', '28660357', '1985-01-30', 'carlos.rodriguez@mail.com', NULL);


-- empleados - 1 y 2 son vendedores.
INSERT INTO empleados (nombre_completo, dni, id_sucursal, tipo, estado, fecha_ingreso, sueldo) VALUES
('Juan Perez',    '27394618', 1, 'vendedor', 'activo', '2020-03-15', 1200000),
('Sofia Ramirez', '32805271', 2, 'vendedor', 'activo', '2021-07-01', 1150000),
('Diego Torres',  '29148803', 3, 'gerente',  'activo', '2018-11-20', 2000000);


-- marcas
INSERT INTO marcas (nombre, origen, fecha_fundacion) VALUES
('Nissan', 'Japon',          '1933-12-26'),
('Ford',   'Estados Unidos', '1903-06-16'),
('Toyota', 'Japon',          '1937-08-28');


-- modelos
INSERT INTO modelos (modelo, fecha_lanzamiento, id_marca, precio) VALUES
('Frontier', '2023-03-01', 1, 6500000000),
('Maverick', '2022-05-10', 2, 5500000000),
('Corolla',  '2023-01-15', 3, 4200000000);


-- proveedores
INSERT INTO proveedores (nombre, telefono, direccion, cuit) VALUES
('Nissan Argentina S.A.', '11-4318-5602', 'Av. del Libertador 2000, CABA', '30-70824519-3'),
('Ford Argentina S.C.A.', '11-4752-9941', 'Ruta 9 km 50, Pacheco',         '30-50317864-8'),
('Toyota Argentina S.A.', '11-4896-1273', 'Calle Justa Lima 1420, Zarate', '30-68105927-4');


-- entregas
INSERT INTO entregas (fecha, id_proveedor, id_sucursal) VALUES
('2025-01-20', 1, 1),
('2025-02-15', 2, 2),
('2025-03-10', 3, 3);


-- vehiculos - los tres están vendidos porque cada uno se usa en una venta más abajo.
INSERT INTO vehiculos (chasis, patente, id_modelo, id_sucursal, id_entrega, color, estado) VALUES
('9BFZZZ54ZPB482917', 'AG482KT', 1, 1, 1, 'Gris',   'vendido'),
('9BFZZZ54ZPB139654', 'AF917MR', 2, 2, 2, 'Blanco', 'vendido'),
('9BFZZZ54ZPB807326', 'AH265BX', 3, 3, 3, 'Negro',  'vendido');


-- plataformas
INSERT INTO plataformas (nombre) VALUES
('Presencial'),
('Sitio web'),
('WhatsApp');


-- ventas - un vehiculo solo puede venderse una vez (claramente).
INSERT INTO ventas (id_cliente, id_vendedor, id_vehiculo, id_plataforma, fecha, precio, medio_pago, meses_service) VALUES
(1, 1, 1, 1, '2025-02-10', 6400000000, 'transferencia', 12),
(2, 2, 2, 2, '2025-03-18', 5500000000, 'credito',        6),
(3, 1, 3, 3, '2025-04-05', 4100000000, 'efectivo',       6);


-- talleres
INSERT INTO talleres (nombre, direccion) VALUES
('Taller Central', 'Av. San Martin 1200, CABA'),
('Taller Lanus',   'Calle 25 de Mayo 450, Lanus'),
('Taller Oeste',   'Av. Rivadavia 7800, CABA');


-- service
INSERT INTO service (id_venta, id_taller, fecha) VALUES
(1, 1, '2025-08-10'),
(2, 2, '2025-09-15'),
(3, 3, '2025-10-01');


-- registro_runa -> El cliente debe coincidir con el de la venta de ese vehiculo.
INSERT INTO registro_runa (id_vehiculo, id_cliente, fecha, nro_tramite) VALUES
(1, 1, '2025-02-15', 'RUNA-2025-0417'),
(2, 2, '2025-03-25', 'RUNA-2025-0583'),
(3, 3, '2025-04-12', 'RUNA-2025-0731');
