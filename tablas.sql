CREATE TABLE clientes (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre_completo VARCHAR(255) NOT NULL,
       dni VARCHAR(20) NOT NULL,
       fecha_nacimiento DATE NOT NULL,
       email VARCHAR(50) NOT NULL,
       telefono VARCHAR(30),
       CONSTRAINT uq_clientes_dni UNIQUE (dni),
       CONSTRAINT chk_clientes_fecha_nacimiento CHECK (fecha_nacimiento < NOW())
);

CREATE TABLE sucursales (
       id INT IDENTITY(1,1) PRIMARY KEY,
       direccion VARCHAR(255) NOT NULL
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
       CONSTRAINT chk_empleados_estado CHECK (tipo IN ('activo', 'licencia', 'baja')),
       CONSTRAINT chk_empleados_tipo CHECK (tipo IN ('vendedor', 'limpieza', 'contador', 'gerente', 'marketing')),
       CONSTRAINT chk_empleados_sueldo CHECK (sueldo > 0),
       CONSTRAINT uq_empleados_dni UNIQUE (dni)
);

CREATE TABLE marcas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(255) NOT NULL,
       origen VARCHAR(50),
       fecha_fundacion DATE
);

CREATE TABLE autos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       modelo VARCHAR(255) NOT NULL,
       fecha_lanzamiento DATE NOT NULL,
       id_marca INT NOT NULL,
       precio BIGINT NOT NULL,
       FOREIGN KEY (id_marca) REFERENCES marcas(id),
       CONSTRAINT uq_autos_modelo_marca UNIQUE (modelo, id_marca)
);

CREATE TABLE ventas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_cliente INT NOT NULL,
       id_vendedor INT NOT NULL,
       id_auto INT NOT NULL,
       fecha DATE NOT NULL,
       precio BIGINT NOT NULL,
       medio_pago VARCHAR(30) NOT NULL,
       meses_service INT DEFAULT 6,
       FOREIGN KEY (id_cliente) REFERENCES clientes(id),
       FOREIGN KEY (id_vendedor) REFERENCES empleados(id),
       FOREIGN KEY (id_auto) REFERENCES autos(id),
       CONSTRAINT chk_ventas_medio_pag CHECK (medio_pago IN ('efectivo', 'transferencia', 'debito', 'credito'))
);

CREATE TABLE stock (
       id_sucursal INT NOT NULL,
       id_auto INT NOT NULL,
       cantidad INT NOT NULL DEFAULT 0,
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_auto) REFERENCES autos(id),
       CONSTRAINT pk_stock PRIMARY KEY (id_sucursal, id_auto),
       CONSTRAINT chk_stock_cantidad CHECK (cantidad >= 0)
);

CREATE TABLE proveedores (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       telefono VARCHAR(20) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       cuit VARCHAR(20) NOT NULL
);

CREATE TABLE proveedores_entregas (
       id_proveedor INT NOT NULL,
       id_auto INT NOT NULL,
       id_sucursal INT NOT NULL,
       FOREIGN KEY (id_proveedor) REFERENCES proveedores(id),
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_auto) REFERENCES autos(id)
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
       FOREIGN KEY (id_venta) REFERENCES ventas(id),
       FOREIGN KEY (id_taller) REFERENCES talleres(id)
);
