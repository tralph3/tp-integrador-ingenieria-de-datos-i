CREATE TABLE clientes (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre_completo VARCHAR(255) NOT NULL,
       dni VARCHAR(20) NOT NULL,
       fecha_nacimiento DATE NOT NULL,
       email VARCHAR(50) NOT NULL,
       telefono VARCHAR(30),
       CONSTRAINT uq_clientes_dni UNIQUE (dni),
       CONSTRAINT uq_clientes_email UNIQUE (email),
       CONSTRAINT chk_clientes_fecha_nacimiento CHECK (fecha_nacimiento <= GETDATE())
);

CREATE TABLE sucursales (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       telefono VARCHAR(30) NOT NULL,
       CONSTRAINT uq_sucursales_nombre UNIQUE (nombre)
);

CREATE TABLE empleados (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre_completo VARCHAR(255) NOT NULL,
       dni VARCHAR(20) NOT NULL,
       id_sucursal INT NOT NULL,
       tipo VARCHAR(20) NOT NULL,
       estado VARCHAR(20) NOT NULL,
       fecha_ingreso DATE NOT NULL,
       sueldo BIGINT NOT NULL,
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       CONSTRAINT chk_empleados_estado CHECK (estado IN ('activo', 'licencia', 'baja')),
       CONSTRAINT chk_empleados_tipo CHECK (tipo IN ('vendedor', 'limpieza', 'contador', 'gerente', 'marketing')),
       CONSTRAINT chk_empleados_sueldo CHECK (sueldo > 0),
       CONSTRAINT uq_empleados_dni UNIQUE (dni)
);

CREATE TABLE marcas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(255) NOT NULL,
       origen VARCHAR(50),
       fecha_fundacion DATE,
       CONSTRAINT uq_marcas_nombre UNIQUE (nombre)
);

CREATE TABLE autos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       modelo VARCHAR(255) NOT NULL,
       fecha_lanzamiento DATE NOT NULL,
       id_marca INT NOT NULL,
       precio BIGINT NOT NULL,
       FOREIGN KEY (id_marca) REFERENCES marcas(id),
       CONSTRAINT uq_autos_modelo_marca UNIQUE (modelo, id_marca),
       CONSTRAINT chk_autos_precio CHECK (precio > 0)
);

CREATE TABLE proveedores (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       telefono VARCHAR(20) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       cuit VARCHAR(20) NOT NULL UNIQUE,
       CONSTRAINT uq_proveedores_cuit UNIQUE (cuit)
);

CREATE TABLE proveedores_entregas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       cantidad INT NOT NULL,
       id_proveedor INT NOT NULL,
       id_auto INT NOT NULL,
       id_sucursal INT NOT NULL,
       CONSTRAINT chk_proveedores_entregas_cantidad CHECK (cantidad > 0),
       FOREIGN KEY (id_proveedor) REFERENCES proveedores(id),
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_auto) REFERENCES autos(id)
);

CREATE TABLE vehiculos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       chasis VARCHAR(20) NOT NULL,
       patente VARCHAR(20), -- se asigna al vender
       id_auto INT NOT NULL,
       id_sucursal INT NOT NULL,
       id_entrega INT NOT NULL,
       color VARCHAR(20) NOT NULL,
       estado VARCHAR(20) NOT NULL,
       CONSTRAINT uq_vehiculos_chasis UNIQUE (chasis),
       CONSTRAINT uq_vehiculos_patente UNIQUE (patente),
       CONSTRAINT chk_vehiculos_estado CHECK (estado IN ('disponible', 'reservado', 'vendido', 'en_service')),
       FOREIGN KEY (id_auto) REFERENCES autos(id),
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_entrega) REFERENCES proveedores_entregas(id)
);

CREATE TABLE ventas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_sucursal INT NOT NULL,
       id_cliente INT NOT NULL,
       id_vendedor INT NOT NULL,
       id_vehiculo INT NOT NULL,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       precio BIGINT NOT NULL,
       medio_pago VARCHAR(30) NOT NULL,
       meses_service INT NOT NULL DEFAULT 6,
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_cliente) REFERENCES clientes(id),
       FOREIGN KEY (id_vendedor) REFERENCES empleados(id),
       FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id),
       CONSTRAINT uq_ventas_id_vehiculo UNIQUE (id_vehiculo), -- no se puede vender el mismo auto mas de una vez
       CONSTRAINT chk_ventas_precio CHECK (precio > 0),
       CONSTRAINT chk_ventas_meses_service CHECK (meses_service >= 0),
       CONSTRAINT chk_ventas_medio_pag CHECK (medio_pago IN ('efectivo', 'transferencia', 'debito', 'credito')),
       CONSTRAINT chk_ventas_fecha CHECK (fecha <= GETDATE())
);

CREATE TABLE talleres (
       id INT IDENTITY(1,1) PRIMARY KEY,
       direccion VARCHAR(255) NOT NULL
);

CREATE TABLE service (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_venta INT NOT NULL,
       id_taller INT NOT NULL,
       fecha DATE NOT NULL,
       tipo VARCHAR(20) NOT NULL DEFAULT 'pago',
       costo BIGINT NOT NULL DEFAULT 0,
       CONSTRAINT chk_service_costo CHECK (costo >= 0),
       CONSTRAINT chk_service_costo_gratuito CHECK ((costo > 0 AND tipo = 'pago') OR (costo = 0 AND tipo = 'gratuito')),
       CONSTRAINT chk_service_tipo CHECK (tipo IN ('pago', 'gratuito')),
       FOREIGN KEY (id_venta) REFERENCES ventas(id),
       FOREIGN KEY (id_taller) REFERENCES talleres(id)
);

CREATE TABLE registro_runa (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_vehiculo INT NOT NULL,
       id_cliente INT NOT NULL,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       nro_tramite VARCHAR(20) NOT NULL,
       CONSTRAINT uq_registro_runa_id_vehiculo UNIQUE (id_vehiculo),
       CONSTRAINT uq_registro_runa_nro_tramite UNIQUE (nro_tramite),
       FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id),
       FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE TABLE plataformas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       CONSTRAINT uq_plataformas_nombre UNIQUE (nombre)
);

CREATE TABLE log_errores (
       id INT IDENTITY(1,1) PRIMARY KEY,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       usuario VARCHAR(50) NOT NULL,
       procedimiento VARCHAR(100) NOT NULL,
       numero_error INT NOT NULL,
       mensaje TEXT NOT NULL
);
