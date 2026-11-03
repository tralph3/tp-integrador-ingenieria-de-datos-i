#set document(title: "TP Integrador - Base de Datos", author: "Grupo 14")
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
  number-align: center,
)
#set text(lang: "es", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#show heading.where(level: 1): it => {
  v(1em)
  it
  v(0.4em)
}
#show raw.where(block: true): it => block(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
  it,
)

// ---------------------------------------------------------------- Carátula
#page(numbering: none)[
  #align(center)[
    #v(1fr)
    #text(size: 14pt)[Universidad Argentina de la Empresa (UADE)] \
    #text(size: 12pt)[Ingeniería de Datos 1 · 2do Cuatrimestre 2026]

    #v(2cm)
    #text(size: 24pt, weight: "bold")[Trabajo Práctico Integrador] \
    #v(0.3cm)
    #text(size: 16pt)[Base de Datos: Concesionaria de Automóviles]

    #v(2cm)
    #line(length: 60%)
    #v(0.5cm)

    *Docentes* \
    Lic. Gustavo E. Escandell \
    Ing. Melinda Selles

    #v(1cm)
    *Grupo:* Nº 14

    #v(1fr)
    Fecha de entrega: 5 de noviembre de 2026
  ]
]

// ------------------------------------------------------------- Integrantes
#page(numbering: none)[
  #heading(numbering: none)[Integrantes]

  #table(
    columns: (1fr, auto, 1.5fr),
    align: (left, center, left),
    stroke: 0.5pt + luma(150),
    inset: 7pt,
    table.header[*Nombre y apellido*][*Legajo*][*Rama de Git*],
    [Tomás Ralph], [1248335], [`ralph`],
    [Augusto Lecour], [1216511], [`lecour`],
  )

  #v(1em)
  *Repositorio:* `https://github.com/tralph3/tp-integrador-ingenieria-de-datos-i`
]

// ------------------------------------------------------------------ Índice
#page(numbering: none)[
  #outline(title: "Índice", indent: auto, depth: 2)
]

#counter(page).update(1)

// --------------------------------------------------------------- Contenido
= Descripción del sistema
Descripción general de la concesionaria y del problema que resuelve la base
de datos. _Placeholder._

= Universo del Discurso
== Contexto del sistema
_Placeholder._
== Objetivo de la base de datos
_Placeholder._
== Actores involucrados
_Placeholder._
== Procesos principales
_Placeholder._

= Reglas de negocio
+ Al realizar una venta, el cliente debe ser mayor de 18 años.
+ Todas las ventas deben estar registradas a un vendedor.
+ El vehículo debe registrarse a nombre del cliente en el RUNA.

= Diagrama Entidad-Relación
#figure(
  rect(width: 100%, height: 6cm, stroke: (dash: "dashed"))[
    #align(center + horizon)[_Insertar imagen del DER_]
  ],
  caption: [Diagrama Entidad-Relación.],
)

= Proceso de normalización
== Dependencias funcionales y claves candidatas
_Placeholder._
== Formas normales (1FN a 3FN)
_Placeholder._

= Modelo de tablas
== Clientes
Almacena todos los clientes del negocio.

```sql
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
```

== Sucursales
Almacena todas las sucursales de la empresa.

```sql
CREATE TABLE sucursales (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       telefono VARCHAR(30) NOT NULL,
       CONSTRAINT uq_sucursales_nombre UNIQUE (nombre)
);
```

== Empleados
Registra todos los empleados de la empresa, indicando su rol y su salario.

```sql
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
```

== Marcas
Almacena las distintas marcas de los autos.

```sql
CREATE TABLE marcas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       origen VARCHAR(50),
       fecha_fundacion DATE,
       CONSTRAINT uq_marcas_nombre UNIQUE (nombre)
);
```

== Autos
Almacena los distintos modelos de autos disponibles junto con su precio de lista.

```sql
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
```

== Proveedores
Almacena los distintos proveedores de autos y sus datos de contacto.

```sql
CREATE TABLE proveedores (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       telefono VARCHAR(20) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       cuit VARCHAR(20) NOT NULL,
       CONSTRAINT uq_proveedores_cuit UNIQUE (cuit)
);
```

== Entregas
Registra las entregas de los proveedores. La tabla vehiculos luego referencia esta tabla, indicando a qué entrega pertenecen.

```sql
CREATE TABLE entregas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       id_proveedor INT NOT NULL,
       id_sucursal INT NOT NULL,
       FOREIGN KEY (id_proveedor) REFERENCES proveedores(id),
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id)
);
```

== Vehículos
Registra los vehículos que la empresa posee. A diferencia de autos, estos no son los modelos, sino vehículos particulares, con una ubicación y patente específicas.

```sql
CREATE TABLE vehiculos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       chasis VARCHAR(20) NOT NULL,
       patente VARCHAR(20), -- se asigna al vender
       id_auto INT NOT NULL,
       id_sucursal INT NOT NULL,
       id_entrega INT NOT NULL,
       color VARCHAR(20) NOT NULL,
       estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
       CONSTRAINT uq_vehiculos_chasis UNIQUE (chasis),
       CONSTRAINT chk_vehiculos_estado CHECK (estado IN ('disponible', 'reservado', 'vendido', 'en_service')),
       FOREIGN KEY (id_auto) REFERENCES autos(id),
       FOREIGN KEY (id_sucursal) REFERENCES sucursales(id),
       FOREIGN KEY (id_entrega) REFERENCES entregas(id)
);

CREATE UNIQUE INDEX uq_vehiculos_patente ON vehiculos(patente) WHERE patente IS NOT NULL;
```

== Plataformas
Registra los canales por los cuales se concretan las ventas (por ejemplo WhatsApp, sitio web o presencial).

```sql
CREATE TABLE plataformas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       CONSTRAINT uq_plataformas_nombre UNIQUE (nombre)
);
```

== Ventas
Registra las ventas realizadas por la empresa, indicando el vendedor, el vehículo, el cliente, y el canal de venta (plataforma). La sucursal donde se realizó se obtiene a través del vehículo.

```sql
CREATE TABLE ventas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_cliente INT NOT NULL,
       id_vendedor INT NOT NULL,
       id_vehiculo INT NOT NULL,
       id_plataforma INT NOT NULL,
       fecha DATE NOT NULL DEFAULT GETDATE(),
       precio BIGINT NOT NULL,
       medio_pago VARCHAR(30) NOT NULL,
       meses_service INT NOT NULL DEFAULT 6,
       FOREIGN KEY (id_cliente) REFERENCES clientes(id),
       FOREIGN KEY (id_vendedor) REFERENCES empleados(id),
       FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id),
       FOREIGN KEY (id_plataforma) REFERENCES plataformas(id),
       CONSTRAINT uq_ventas_id_vehiculo UNIQUE (id_vehiculo), -- no se puede vender el mismo auto mas de una vez
       CONSTRAINT chk_ventas_precio CHECK (precio > 0),
       CONSTRAINT chk_ventas_meses_service CHECK (meses_service >= 0),
       CONSTRAINT chk_ventas_medio_pag CHECK (medio_pago IN ('efectivo', 'transferencia', 'debito', 'credito')),
       CONSTRAINT chk_ventas_fecha CHECK (fecha <= GETDATE())
);
```

== Talleres
Registra los talleres donde la empresa puede tercerizar el servicio de service para los vehículos.

```sql
CREATE TABLE talleres (
       id INT IDENTITY(1,1) PRIMARY KEY,
       nombre VARCHAR(50) NOT NULL,
       direccion VARCHAR(255) NOT NULL,
       CONSTRAINT uq_talleres_nombre UNIQUE (nombre)
);
```

== Service
Registra un service para un vehículo (atado a una venta específica).

```sql
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
```

== Registro RUNA
Almacena el número de trámite en el registro RUNA para cada vehículo vendido.

```sql
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
```

== Log Errores
Registra los errores capturados por procedimientos y triggers.

```sql
CREATE TABLE log_errores (
       id INT IDENTITY(1,1) PRIMARY KEY,
       fecha DATETIME NOT NULL DEFAULT GETDATE(),
       usuario VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
       procedimiento VARCHAR(100),
       numero_error INT NOT NULL,
       mensaje VARCHAR(2048) NOT NULL
);
```

== Historial de Precios
Registra los cambios en los precios de lista de los autos.

```sql
CREATE TABLE historial_precios (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_auto INT NOT NULL,
       precio_anterior BIGINT NOT NULL,
       precio_nuevo BIGINT NOT NULL,
       fecha DATETIME NOT NULL DEFAULT GETDATE(),
       usuario VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
       CONSTRAINT chk_historial_precios_anterior CHECK (precio_anterior > 0),
       CONSTRAINT chk_historial_precios_nuevo CHECK (precio_nuevo > 0),
       FOREIGN KEY (id_auto) REFERENCES autos(id)
);
```

== Cuotas
Registra las cuotas de las ventas con `medio_pago = 'credito'`.

```sql
CREATE TABLE cuotas (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_venta INT NOT NULL,
       nro_cuota INT NOT NULL,
       monto BIGINT NOT NULL,
       vencimiento DATE NOT NULL,
       fecha_pago DATE, -- NULL hasta que se paga
       CONSTRAINT uq_cuotas_id_venta_nro_cuota UNIQUE (id_venta, nro_cuota),
       CONSTRAINT chk_cuotas_nro_cuota CHECK (nro_cuota > 0),
       CONSTRAINT chk_cuotas_monto CHECK (monto > 0),
       FOREIGN KEY (id_venta) REFERENCES ventas(id)
);
```

== Comisiones
Registra las comisiones que cobran los vendedores al efectuar una venta.

```sql
CREATE TABLE comisiones (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_venta INT NOT NULL,
       monto BIGINT NOT NULL,
       fecha_liquidacion DATE, -- NULL hasta que se liquida
       CONSTRAINT uq_comisiones_id_venta UNIQUE (id_venta),
       CONSTRAINT chk_comisiones_monto CHECK (monto >= 0),
       FOREIGN KEY (id_venta) REFERENCES ventas(id)
);
```

= Diccionario de datos
#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt + luma(150),
  inset: 6pt,
  table.header[*Tabla*][*Campo*][*Tipo*][*Descripción*],
  [`clientes`], [`id`], [`INT`], [Identificador del cliente.],
  [`clientes`], [`dni`], [`VARCHAR(20)`], [Documento, único.],
)

= Consultas SQL
_Placeholder._

= Subconsultas
_Placeholder: qué información se obtiene, qué función cumple la subconsulta y por qué es adecuada._

= Vistas
_Placeholder: objetivo, información presentada, tablas involucradas y motivo._

= Stored Procedures
_Placeholder._

= Triggers
_Placeholder: evento, tabla, condición, acción y regla de negocio._

= Cursores
_Placeholder: problema, motivo, registros procesados y operación por registro._

= Funciones
_Placeholder: objetivo, parámetros, tipo de retorno, lógica y ejemplo._

= Manejo de errores
_Placeholder._

= Seguridad de la base de datos
_Placeholder: usuarios, roles, permisos y protección de información sensible._

= Centralización de la lógica en la capa de datos
_Placeholder._

= Conclusiones
_Placeholder._
