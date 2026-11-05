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

    #v(2cm)
    *Integrantes*

    #table(
        columns: (1fr, 1.5fr, auto),
        align: (left, center, left),
        stroke: 0pt,
        inset: 7pt,
        table.header[*Nombre y apellido*][*Legajo*][*Rama de Git*],
        [Tomás Ralph], [1248335], [`ralph`],
        [Augusto Lecour], [1216511], [`lecour`],
    )

    #v(1em)
    *Repositorio:* `https://github.com/tralph3/tp-integrador-ingenieria-de-datos-i`

    #v(1fr)
    Fecha de entrega: 5 de noviembre de 2026
  ]
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
Una dependencia funcional `A → B` indica que, conociendo el valor de `A`, hay un único valor de `B` posible. Una clave candidata es un conjunto mínimo de atributos que determina a todos los demás de la tabla. De todas las claves candidatas se elige una como clave primaria, y las restantes se declaran con `UNIQUE`.

== Dependencias funcionales y claves candidatas
Para cada tabla listamos las claves candidatas y las dependencias. Las claves salen de los `PRIMARY KEY` y `UNIQUE` del esquema. En ninguna tabla hay una dependencia que parta de una columna que no sea clave.

#{
  set text(size: 9pt)
  set par(justify: false)
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Tabla*][*Claves candidatas*][*Dependencias funcionales*],
    [`clientes`], [`id`, `dni`, `email`],
      [`id → nombre_completo, dni, fecha_nacimiento, email, telefono` \ `dni → id` \ `email → id`],
    [`sucursales`], [`id`, `nombre`],
      [`id → nombre, direccion, telefono` \ `nombre → id`],
    [`empleados`], [`id`, `dni`],
      [`id → nombre_completo, dni, id_sucursal, tipo, estado, fecha_ingreso, sueldo` \ `dni → id`],
    [`marcas`], [`id`, `nombre`],
      [`id → nombre, origen, fecha_fundacion` \ `nombre → id`],
    [`modelos`], [`id`, `(modelo, id_marca)`],
      [`id → modelo, fecha_lanzamiento, id_marca, precio` \ `(modelo, id_marca) → id`],
    [`proveedores`], [`id`, `cuit`],
      [`id → nombre, telefono, direccion, cuit` \ `cuit → id`],
    [`entregas`], [`id`],
      [`id → fecha, id_proveedor, id_sucursal`],
    [`vehiculos`], [`id`, `chasis`, `patente`],
      [`id → chasis, patente, id_modelo, id_sucursal, id_entrega, color, estado` \ `chasis → id` \ `patente → id`],
    [`plataformas`], [`id`, `nombre`],
      [`id → nombre` \ `nombre → id`],
    [`ventas`], [`id`, `id_vehiculo`],
      [`id → id_cliente, id_vendedor, id_vehiculo, id_plataforma, fecha, precio, medio_pago, meses_service` \ `id_vehiculo → id`],
    [`talleres`], [`id`, `nombre`],
      [`id → nombre, direccion` \ `nombre → id`],
    [`service`], [`id`],
      [`id → id_venta, id_taller, fecha`],
    [`registro_runa`], [`id`, `id_vehiculo`, `nro_tramite`],
      [`id → id_vehiculo, id_cliente, fecha, nro_tramite` \ `id_vehiculo → id` \ `nro_tramite → id`],
    [`log_errores`], [`id`],
      [`id → fecha, usuario, procedimiento, numero_error, mensaje`],
    [`historial_precios`], [`id`],
      [`id → id_modelo, precio_anterior, precio_nuevo, fecha, usuario`],
    [`cuotas`], [`id`, `(id_venta, nro_cuota)`],
      [`id → id_venta, nro_cuota, monto, vencimiento, fecha_pago` \ `(id_venta, nro_cuota) → id`],
    [`comisiones`], [`id`, `id_venta`],
      [`id → id_venta, monto, fecha_liquidacion` \ `id_venta → id`],
  )
}

La patente de `vehiculos` solo es clave candidata cuando está cargada, porque puede ser nula (se controla con un índice único filtrado).

Hay además dependencias que cruzan tablas, y por ellas separamos: `id_vehiculo → id_modelo → id_marca → origen`, `id_empleado → id_sucursal → direccion` e `id_venta → id_cliente → dni`.

== Formas normales (1FN a 3FN)
Para mostrar el proceso arrancamos de una sola relación sin normalizar, que sería como hoy anota la concesionaria las ventas (libreta y WhatsApp): todo junto en una fila.

```
VENTA(id_venta, fecha, cliente_dni, cliente_nombre, cliente_email,
      vendedor_dni, vendedor_nombre, vendedor_tipo,
      sucursal_nombre, sucursal_direccion,
      chasis, patente, color, modelo, marca, marca_origen, precio_lista,
      precio_venta, medio_pago, plataforma,
      {cuotas: nro_cuota, monto, vencimiento, fecha_pago},
      {services: fecha, taller, taller_direccion})
```

=== Primera forma normal (1FN)
Una relación está en 1FN si todos los atributos son atómicos y no hay grupos repetidos. Acá una venta puede tener varias cuotas y varios services, y todos están metidos dentro de la misma fila, así que no cumple.

Lo resolvemos sacando cada grupo repetido a su propia relación, que apunta a la venta. De ahí salen `cuotas` y `service`:

```
VENTA(id_venta, fecha, cliente_dni, ..., plataforma)
CUOTA(id_venta, nro_cuota, monto, vencimiento, fecha_pago)
SERVICE(id_service, id_venta, fecha, taller, taller_direccion)
```

=== Segunda forma normal (2FN)
Una relación está en 2FN si cumple 1FN y ninguna columna no clave depende de solo una parte de una clave compuesta.

- `CUOTA` tiene clave compuesta `(id_venta, nro_cuota)`. `monto`, `vencimiento` y `fecha_pago` dependen de la clave entera, porque cada cuota de cada venta tiene sus propios valores. El nombre del cliente dependería solo de `id_venta`, o sea una dependencia parcial, así que no se guarda acá y se llega a él desde la venta.
- En `modelos` la clave candidata `(modelo, id_marca)` determina `fecha_lanzamiento` y `precio`, y los dos dependen de la clave completa: el precio es de ese modelo de esa marca.
- Las demás tablas tienen clave primaria simple (`id`), así que no puede haber dependencias parciales.

=== Tercera forma normal (3FN)
Una relación está en 3FN si cumple 2FN y ninguna columna no clave depende de otra columna que tampoco es clave (dependencia transitiva). De acá salen casi todas las separaciones de tablas:

#{
  set text(size: 9pt)
  set par(justify: false)
  table(
    columns: (1.4fr, 1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Dependencia transitiva detectada*][*Solución*],
    [`id_venta → cliente_dni → cliente_nombre, cliente_email`], [Tabla `clientes`.],
    [`id_venta → vendedor_dni → vendedor_nombre, vendedor_tipo`], [Tabla `empleados`.],
    [`vendedor_dni → sucursal_nombre → sucursal_direccion`], [Tabla `sucursales`, referenciada desde `empleados`.],
    [`id_venta → chasis → patente, color, modelo`], [Tabla `vehiculos`, que representa la unidad física.],
    [`chasis → modelo → precio_lista`], [Tabla `modelos`, que representa el modelo.],
    [`modelo → marca → marca_origen`], [Tabla `marcas`.],
    [`id_venta → plataforma`], [Tabla `plataformas`, para evitar repetir y escribir mal el nombre del canal.],
    [`id_service → taller → taller_direccion`], [Tabla `talleres`.],
  )
}

Para evitar más redundancia tomamos estas decisiones:

- No hay tabla `stock`. La cantidad de autos disponibles por sucursal y modelo se calcula contando los vehículos en estado `disponible`. Guardada aparte tendría que mantenerse sincronizada con `vehiculos` y podrían contradecirse.
- `ventas` no tiene `id_sucursal`. La sucursal ya la determina el vehículo vendido (`id_vehiculo → id_sucursal`), así que en la venta sería una dependencia transitiva.
- `comisiones` no tiene `id_vendedor`. El vendedor se obtiene desde la venta (`id_venta → id_vendedor`).
- `entregas` es solo la cabecera. La cantidad entregada se saca contando los vehículos que apuntan a ella con `id_entrega`.
- `ventas.precio` y `modelos.precio` no son el mismo dato. El de `ventas` es lo que se acordó en esa venta y no cambia si después se actualiza el precio de lista.

Después de estas separaciones, lo único que determina a otras columnas en cada tabla son las claves candidatas (ver la tabla de arriba). Por eso el modelo está en 3FN y también en BCNF.

=== Las dos sucursales de `vehiculos`
`vehiculos` tiene una columna `id_sucursal` y `entregas` otra, pero cada una guarda algo distinto. La de `entregas` es el destino: la sucursal a la que el proveedor llevó la mercadería, y no cambia. La de `vehiculos` es la ubicación actual del auto, que puede cambiar si lo movemos a otra sucursal.

Por eso `id_entrega → id_sucursal` no se cumple en `vehiculos`. Dos autos de la misma entrega pueden estar hoy en sucursales distintas, así que no hay dependencia transitiva y la tabla sigue en 3FN. El stock por sucursal se calcula con la ubicación actual, es decir, con `vehiculos.id_sucursal`.

=== Anomalías evitadas
Separar en tablas evita las tres anomalías típicas.

- Inserción: en la relación inicial no se podría cargar una marca, un modelo, un proveedor o un cliente sin que haya una venta que lo incluya. Con las tablas separadas se cargan por su cuenta.
- Modificación: si el origen de una marca, la dirección de una sucursal o el teléfono de un cliente estuvieran repetidos en cada venta, habría que cambiarlos en muchas filas, y si se olvida una quedan datos contradictorios. Ahora cada dato está en un solo lugar.
- Eliminación: si los datos del cliente estuvieran dentro de la venta, borrar su única venta borraría también al cliente. Con `clientes` aparte eso no pasa.

=== Formas normales superiores
Cada tabla representa una sola entidad o relación y no mezcla datos multivaluados independientes, así que no hay dependencias multivaluadas no triviales y se cumple 4FN. Tampoco hay dependencias de reunión que obliguen a descomponer más, así que se cumple 5FN.

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

== Modelos
Almacena los distintos modelos de autos disponibles junto con su precio de lista.

```sql
CREATE TABLE modelos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       modelo VARCHAR(255) NOT NULL,
       fecha_lanzamiento DATE NOT NULL,
       id_marca INT NOT NULL,
       precio BIGINT NOT NULL,
       FOREIGN KEY (id_marca) REFERENCES marcas(id),
       CONSTRAINT uq_modelos_modelo_marca UNIQUE (modelo, id_marca),
       CONSTRAINT chk_modelos_precio CHECK (precio > 0)
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
Registra las entregas de los proveedores. La tabla #link(<tabla-vehiculos>)[#text(fill: blue)[`vehiculos`]] luego referencia esta tabla, indicando a qué entrega pertenecen.

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

== Vehículos <tabla-vehiculos>
Registra los vehículos que la empresa posee. A diferencia de `modelos`, estos no son modelos genéricos, sino vehículos particulares, con una ubicación y patente específicas.

```sql
CREATE TABLE vehiculos (
       id INT IDENTITY(1,1) PRIMARY KEY,
       chasis VARCHAR(20) NOT NULL,
       patente VARCHAR(20), -- se asigna al vender
       id_modelo INT NOT NULL,
       id_sucursal INT NOT NULL,
       id_entrega INT NOT NULL,
       color VARCHAR(20) NOT NULL,
       estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
       CONSTRAINT uq_vehiculos_chasis UNIQUE (chasis),
       CONSTRAINT chk_vehiculos_estado CHECK (estado IN ('disponible', 'reservado', 'vendido', 'en_service')),
       FOREIGN KEY (id_modelo) REFERENCES modelos(id),
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

== Log de Errores
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
Registra los cambios en los precios de lista de los modelos.

```sql
CREATE TABLE historial_precios (
       id INT IDENTITY(1,1) PRIMARY KEY,
       id_modelo INT NOT NULL,
       precio_anterior BIGINT NOT NULL,
       precio_nuevo BIGINT NOT NULL,
       fecha DATETIME NOT NULL DEFAULT GETDATE(),
       usuario VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
       CONSTRAINT chk_historial_precios_anterior CHECK (precio_anterior > 0),
       CONSTRAINT chk_historial_precios_nuevo CHECK (precio_nuevo > 0),
       FOREIGN KEY (id_modelo) REFERENCES modelos(id)
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
#let dic(..filas) = {
  set text(size: 9pt)
  table(
    columns: (auto, auto, auto, 1.3fr, 1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Campo*][*Tipo*][*Nulo*][*Restricciones*][*Descripción*],
    ..filas.pos().map(f => (raw(f.at(0)), raw(f.at(1)), f.at(2), f.at(3), emph(f.at(4)))).flatten(),
  )
}

== Clientes
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre_completo", "VARCHAR(255)", "No", "—", "Nombre completo del cliente."),
  ("dni", "VARCHAR(20)", "No", "UNIQUE", "DNI del cliente."),
  ("fecha_nacimiento", "DATE", "No", "CHECK: <= fecha actual", "Fecha de nacimiento del cliente."),
  ("email", "VARCHAR(50)", "No", "UNIQUE", "Correo electrónico del cliente."),
  ("telefono", "VARCHAR(30)", "Sí", "—", "Teléfono del cliente."),
)

== Sucursales
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre", "VARCHAR(50)", "No", "UNIQUE", "Nombre de la sucursal."),
  ("direccion", "VARCHAR(255)", "No", "—", "Dirección de la sucursal."),
  ("telefono", "VARCHAR(30)", "No", "—", "Teléfono de la sucursal."),
)

== Empleados
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre_completo", "VARCHAR(255)", "No", "—", "Nombre completo del empleado."),
  ("dni", "VARCHAR(20)", "No", "UNIQUE", "DNI del empleado."),
  ("id_sucursal", "INT", "No", "FK → sucursales(id)", "Identificador de la sucursal donde el empleado trabaja."),
  ("tipo", "VARCHAR(20)", "No", "CHECK: vendedor, limpieza, contador, gerente, marketing", "Tipo de empleado (su posición)."),
  ("estado", "VARCHAR(20)", "No", "CHECK: activo, licencia, baja", "Estado del empleado."),
  ("fecha_ingreso", "DATE", "No", "—", "Fecha de ingreso del empleado."),
  ("sueldo", "BIGINT", "No", "CHECK: > 0", "Sueldo mensual del empleado."),
)

== Marcas
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre", "VARCHAR(50)", "No", "UNIQUE", "Nombre de la marca."),
  ("origen", "VARCHAR(50)", "Sí", "—", "País de origen de la marca."),
  ("fecha_fundacion", "DATE", "Sí", "—", "Fecha de fundación de la marca."),
)

== Modelos
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("modelo", "VARCHAR(255)", "No", "UNIQUE junto con id_marca", "Modelo del auto."),
  ("fecha_lanzamiento", "DATE", "No", "—", "Fecha de lanzamiento del auto."),
  ("id_marca", "INT", "No", "FK → marcas(id)", "Identificador de la marca del auto."),
  ("precio", "BIGINT", "No", "CHECK: > 0", "Precio de lista del auto."),
)

== Proveedores
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre", "VARCHAR(50)", "No", "—", "Nombre del proveedor."),
  ("telefono", "VARCHAR(20)", "No", "—", "Teléfono del proveedor."),
  ("direccion", "VARCHAR(255)", "No", "—", "Dirección del proveedor."),
  ("cuit", "VARCHAR(20)", "No", "UNIQUE", "CUIT del proveedor."),
)

== Entregas
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("fecha", "DATE", "No", "DEFAULT: fecha actual", "Fecha de la entrega."),
  ("id_proveedor", "INT", "No", "FK → proveedores(id)", "Identificador del proveedor que realizó la entrega."),
  ("id_sucursal", "INT", "No", "FK → sucursales(id)", "Identificador de la sucursal donde se realizó la entrega."),
)

== Vehículos
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("chasis", "VARCHAR(20)", "No", "UNIQUE", "Número de chasis del vehículo."),
  ("patente", "VARCHAR(20)", "Sí", "Índice único filtrado (solo valores no nulos)", "Patente del vehículo, que se asigna al registrarlo luego de su venta."),
  ("id_modelo", "INT", "No", "FK → modelos(id)", "Identificador del modelo del vehículo."),
  ("id_sucursal", "INT", "No", "FK → sucursales(id)", "Identificador de la sucursal donde el vehículo reside actualmente."),
  ("id_entrega", "INT", "No", "FK → entregas(id)", "Identificador de la entrega en la que llegó el vehículo a la sucursal."),
  ("color", "VARCHAR(20)", "No", "—", "Color del vehículo."),
  ("estado", "VARCHAR(20)", "No", "DEFAULT: 'disponible'. CHECK: disponible, reservado, vendido, en_service", "Estado del vehículo."),
)

== Plataformas
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre", "VARCHAR(50)", "No", "UNIQUE", "Nombre de la plataforma."),
)

== Ventas
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_cliente", "INT", "No", "FK → clientes(id)", "Identificador del cliente que realizó la compra."),
  ("id_vendedor", "INT", "No", "FK → empleados(id)", "Identificador del vendedor que realizó la venta."),
  ("id_vehiculo", "INT", "No", "FK → vehiculos(id). UNIQUE", "Identificador del vehículo vendido."),
  ("id_plataforma", "INT", "No", "FK → plataformas(id)", "Identificador de la plataforma por la cual se concretó la venta."),
  ("fecha", "DATE", "No", "DEFAULT: fecha actual. CHECK: <= fecha actual", "Fecha de la venta."),
  ("precio", "BIGINT", "No", "CHECK: > 0", "Precio acordado de la venta."),
  ("medio_pago", "VARCHAR(30)", "No", "CHECK: efectivo, transferencia, debito, credito", "Medio de pago de la venta."),
  ("meses_service", "INT", "No", "DEFAULT: 6. CHECK: >= 0", "Cantidad de meses desde la fecha de la venta en los que se puede solicitar un service gratuito al vehículo."),
)

== Talleres
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("nombre", "VARCHAR(50)", "No", "UNIQUE", "Nombre del taller."),
  ("direccion", "VARCHAR(255)", "No", "—", "Dirección del taller."),
)

== Service
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_venta", "INT", "No", "FK → ventas(id)", "Identificador de la venta cuyo vehículo recibe el service."),
  ("id_taller", "INT", "No", "FK → talleres(id)", "Identificador del taller donde se realiza el service."),
  ("fecha", "DATE", "No", "—", "Fecha del service."),
)

== Registro RUNA
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_vehiculo", "INT", "No", "FK → vehiculos(id). UNIQUE", "Identificador del vehículo registrado."),
  ("id_cliente", "INT", "No", "FK → clientes(id)", "Identificador del cliente que compró el vehículo."),
  ("fecha", "DATE", "No", "DEFAULT: fecha actual", "Fecha en la que se registró el vehículo."),
  ("nro_tramite", "VARCHAR(20)", "No", "UNIQUE", "Número de trámite del registro."),
)

== Log de Errores
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("fecha", "DATETIME", "No", "DEFAULT: fecha y hora actual", "Fecha y hora en que se registró el error."),
  ("usuario", "VARCHAR(128)", "No", "DEFAULT: SUSER_SNAME()", "Usuario que ejecutó la operación que produjo el error."),
  ("procedimiento", "VARCHAR(100)", "Sí", "—", "Procedimiento donde se produjo el error."),
  ("numero_error", "INT", "No", "—", "Número del error."),
  ("mensaje", "VARCHAR(2048)", "No", "—", "Mensaje descriptivo del error."),
)

== Historial de Precios
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_modelo", "INT", "No", "FK → modelos(id)", "Identificador del modelo cuyo precio de lista se actualizó."),
  ("precio_anterior", "BIGINT", "No", "CHECK: > 0", "Precio previo a la modificación."),
  ("precio_nuevo", "BIGINT", "No", "CHECK: > 0", "Precio luego de la modificación."),
  ("fecha", "DATETIME", "No", "DEFAULT: fecha y hora actual", "Fecha de la modificación."),
  ("usuario", "VARCHAR(128)", "No", "DEFAULT: SUSER_SNAME()", "Usuario que realizó la modificación."),
)

== Cuotas
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_venta", "INT", "No", "FK → ventas(id). UNIQUE junto con nro_cuota", "Identificador de la venta que será pagada en cuotas."),
  ("nro_cuota", "INT", "No", "CHECK: > 0", "Número de cuota de la venta."),
  ("monto", "BIGINT", "No", "CHECK: > 0", "Monto de la cuota."),
  ("vencimiento", "DATE", "No", "—", "Fecha de vencimiento de la cuota."),
  ("fecha_pago", "DATE", "Sí", "—", "Fecha de pago de la cuota."),
)

== Comisiones
#dic(
  ("id", "INT", "No", "PK, IDENTITY", "Identificador."),
  ("id_venta", "INT", "No", "FK → ventas(id). UNIQUE", "Identificador de la venta."),
  ("monto", "BIGINT", "No", "CHECK: >= 0", "Monto de la comisión."),
  ("fecha_liquidacion", "DATE", "Sí", "—", "Fecha en que se efectúa la liquidación de la comisión."),
)

= Consultas SQL
_Placeholder._

= Subconsultas
_Placeholder: qué información se obtiene, qué función cumple la subconsulta y por qué es adecuada._

= Vistas
Las vistas son consultas almacenadas que funcionan como tablas virtuales: no guardan datos propios, sino que muestran el resultado actualizado de un SELECT sobre una o más tablas. Se utilizan para consultar de forma simple información que requeriría varios JOIN y para exponer solo los datos necesarios. Son de solo lectura; las operaciones que modifican datos o validan reglas de negocio se resuelven con procedimientos almacenados y triggers.

== vw_stock_disponible
*Objetivo:* Mostrar los vehículos que actualmente están disponibles para la venta, junto con su ubicación y su precio de lista.

*Información presentada:* Sucursal donde se encuentra el vehículo, marca, modelo, color, chasis, precio de lista, fecha de ingreso (entrega) y proveedor.

*Tablas involucradas:* vehiculos, modelos, marcas, sucursales, entregas y proveedores.

*Motivo de utilización:* El vendedor necesita conocer qué vehículos puede ofrecer sin tener que armar cada vez un JOIN de seis tablas. La vista deja visibles únicamente los vehículos con estado disponible (los vendidos, reservados o en service no aparecen) y puede filtrarse desde afuera por sucursal, marca o modelo. Es una consulta de solo lectura que no requiere parámetros ni lógica de negocio, por lo que una vista resulta más adecuada que un procedimiento almacenado.

```sql
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
```

== vw_catalogo_modelos
*Objetivo:* Ofrecer el listado de modelos que comercializa la concesionaria con su marca y su precio de lista actual.

*Información presentada:* Marca, país de origen de la marca, modelo, fecha de lanzamiento y precio de lista.

*Tablas involucradas:* modelos y marcas.

*Motivo de utilización:* Es la información que se le muestra al cliente o al área de marketing. La vista expone solo datos comerciales y evita que quien la consulta deba conocer la estructura interna de las tablas (identificadores y claves foráneas). Si el precio de un modelo cambia, la vista lo refleja automáticamente.

```sql
CREATE OR ALTER VIEW vw_catalogo_modelos AS
SELECT
       ma.nombre AS marca,
       ma.origen AS origen,
       mo.modelo AS modelo,
       mo.fecha_lanzamiento AS fecha_lanzamiento,
       mo.precio AS precio_lista
FROM modelos mo
       INNER JOIN marcas ma ON ma.id = mo.id_marca;
```

== vw_cuotas_pendientes
*Objetivo:* Listar las cuotas de las ventas a crédito que todavía no fueron pagadas, indicando cuáles están vencidas y cuántos días de atraso tienen.

*Información presentada:* Datos de contacto del cliente, vehículo vendido (marca, modelo y patente), número de cuota, monto, fecha de vencimiento, estado (vencida o a vencer) y días de atraso.

*Tablas involucradas:* cuotas, ventas, clientes, vehiculos, modelos y marcas.

*Motivo de utilización:* El área de cobranzas necesita identificar quién tiene deuda y desde cuándo, sin recorrer las cuotas una por una. La vista selecciona las cuotas con fecha de pago nula y calcula el atraso con la fecha actual, por lo que siempre se encuentra actualizada. Se utiliza solo para consultar: si fuera necesario notificar a los clientes o aplicar recargos, esa lógica correspondería a un procedimiento almacenado.

```sql
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
```

== vw_service_programados
*Objetivo:* Mostrar los service programados a partir de la fecha actual, con el cliente, el vehículo, el taller y la situación de cobertura gratuita.

*Información presentada:* Fecha del service, taller y su dirección, cliente y datos de contacto, vehículo (marca, modelo y patente), fecha de venta, meses de service contratados, fecha de fin de cobertura y estado de la cobertura (vigente o vencida) a la fecha del service.

*Tablas involucradas:* service, talleres, ventas, clientes, vehiculos, modelos y marcas.

*Motivo de utilización:* El área de postventa necesita conocer los turnos próximos para avisar al cliente y coordinar con el taller. Como el service gratuito depende de los meses de service pactados en cada venta, la vista calcula la fecha de fin de cobertura e indica qué service quedan a cargo de la concesionaria y cuáles no. Se trata de una consulta sobre datos existentes, por lo que no requiere un procedimiento almacenado.

```sql
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
```


= Stored Procedures
Se implementaron los siguientes procedimientos para cubrir los procesos principales de la concesionaria. Todos los de negocio siguen el mismo esquema de errores: el `CATCH` deshace lo que haya quedado abierto, guarda el error con `sp_log_error` y lo vuelve a lanzar con `THROW` para que lo vea quien llamó. El registro va después del `ROLLBACK`, porque si va antes el `ROLLBACK` lo borra.

Para no repetir ese `INSERT` en cada `CATCH` hay un procedimiento auxiliar, `sp_log_error`. Recibe el nombre del procedimiento, y el número y el mensaje los toma de `ERROR_NUMBER()` y `ERROR_MESSAGE()`.

```sql
-- sp_log_error: guarda en log_errores el error del CATCH que la llama.
CREATE OR ALTER PROCEDURE sp_log_error
       @procedimiento VARCHAR(100)
AS
BEGIN
       SET NOCOUNT ON;
       INSERT INTO log_errores (procedimiento, numero_error, mensaje)
       VALUES (@procedimiento, ERROR_NUMBER(), LEFT(ERROR_MESSAGE(), 2048));
END;
```

== `sp_registrar_venta`
Registra la venta de un vehículo, que es el proceso central de la concesionaria. Recibe el cliente, el vendedor, el vehículo, la plataforma, el precio en centavos, el medio de pago, la patente con la que sale el auto y, si se quiere, los meses de service (por defecto 6). Devuelve el id de la venta en `@id_venta`.

Consulta al cliente, al vendedor y al vehículo, y modifica dos tablas: inserta la venta y pasa el vehículo a `vendido` con su patente. Las dos cosas van en una transacción, porque no puede quedar una sin la otra. El vehículo se lee con `UPDLOCK` para que dos ventas simultáneas no tomen el mismo auto.

Valida a mano solo lo que una constraint no puede expresar: que haya patente (error 51001), que el cliente tenga 18 años (51002), que el vendedor esté activo y sea de tipo vendedor (51003) y que el vehículo esté disponible (51004). El precio, el medio de pago y la existencia de los registros ya los controlan los `CHECK` y las claves foráneas de `ventas`. La comisión la genera un trigger sobre `ventas`.

```sql
-- sp_registrar_venta: registra la venta y marca el vehiculo como vendido.
-- La comision la genera el trigger de ventas. Si es a credito, las cuotas
-- se generan despues con sp_generar_cuotas.
CREATE OR ALTER PROCEDURE sp_registrar_venta
       @id_cliente INT,
       @id_vendedor INT,
       @id_vehiculo INT,
       @id_plataforma INT,
       @precio BIGINT,
       @medio_pago VARCHAR(30),
       @patente VARCHAR(20),
       @meses_service INT = 6,
       @id_venta INT OUTPUT
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
              IF @patente IS NULL
                     THROW 51001, 'Se debe indicar la patente con la que se vende el vehiculo.', 1;

              DECLARE @nacimiento DATE;
              SELECT @nacimiento = fecha_nacimiento FROM clientes WHERE id = @id_cliente;
              IF DATEADD(YEAR, 18, @nacimiento) > CAST(GETDATE() AS DATE)
                     THROW 51002, 'El cliente debe ser mayor de 18 anios.', 1;

              IF NOT EXISTS (SELECT 1 FROM empleados WHERE id = @id_vendedor AND tipo = 'vendedor' AND estado = 'activo')
                     THROW 51003, 'El vendedor no existe o no esta activo.', 1;

              BEGIN TRANSACTION;

              DECLARE @estado VARCHAR(20);
              SELECT @estado = estado FROM vehiculos WITH (UPDLOCK) WHERE id = @id_vehiculo;
              IF @estado <> 'disponible'
                     THROW 51004, 'El vehiculo no esta disponible para la venta.', 1;

              INSERT INTO ventas (id_cliente, id_vendedor, id_vehiculo, id_plataforma, precio, medio_pago, meses_service)
              VALUES (@id_cliente, @id_vendedor, @id_vehiculo, @id_plataforma, @precio, @medio_pago, @meses_service);
              SET @id_venta = SCOPE_IDENTITY();

              UPDATE vehiculos
              SET estado = 'vendido', patente = @patente
              WHERE id = @id_vehiculo;

              COMMIT TRANSACTION;
       END TRY
       BEGIN CATCH
              IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
              EXEC sp_log_error 'sp_registrar_venta';
              THROW;
       END CATCH
END;
```

*Ejemplo*
```sql
DECLARE @id_venta INT;
EXEC sp_registrar_venta @id_cliente = 1, @id_vendedor = 1, @id_vehiculo = 4,
     @id_plataforma = 1, @precio = 6400000000, @medio_pago = 'efectivo',
     @patente = 'AE204LP', @id_venta = @id_venta OUTPUT;
```

== `sp_generar_cuotas`
Reparte el precio de una venta a crédito en cuotas mensuales. Recibe el id de la venta y la cantidad de cuotas, que tiene que estar entre 1 y 120. Lee el precio y la fecha de la venta, y genera los números de cuota con una consulta recursiva, sin cursor. El primer vencimiento cae un mes después de la venta.

La división del precio es entera y descarta el resto, así que la última cuota absorbe la diferencia para que todas sumen exactamente el precio. Las inserciones van en una transacción: o se crean todas las cuotas o ninguna.

Que la venta exista, que sea a crédito y que no tenga cuotas ya cargadas lo controlan la clave foránea, el trigger de cuotas y el `UNIQUE (id_venta, nro_cuota)`. Acá solo se valida el rango de la cantidad (error 51101).

```sql
-- sp_generar_cuotas: reparte el precio de una venta a credito en cuotas
-- mensuales iguales. La ultima cuota absorbe el resto de la division.
CREATE OR ALTER PROCEDURE sp_generar_cuotas
       @id_venta INT,
       @cantidad INT
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
              IF @cantidad IS NULL OR @cantidad < 1 OR @cantidad > 120
                     THROW 51101, 'La cantidad de cuotas debe estar entre 1 y 120.', 1;

              DECLARE @precio BIGINT, @fecha DATE;
              SELECT @precio = precio, @fecha = fecha
              FROM ventas WHERE id = @id_venta;

              DECLARE @monto BIGINT = @precio / @cantidad;

              BEGIN TRANSACTION;

              WITH n AS (
                     SELECT 1 AS nro
                     UNION ALL
                     SELECT nro + 1 FROM n WHERE nro < @cantidad
              )
              INSERT INTO cuotas (id_venta, nro_cuota, monto, vencimiento)
              SELECT @id_venta,
                     nro,
                     CASE WHEN nro = @cantidad THEN @precio - @monto * (@cantidad - 1) ELSE @monto END,
                     DATEADD(MONTH, nro, @fecha)
              FROM n
              OPTION (MAXRECURSION 120);

              COMMIT TRANSACTION;
       END TRY
       BEGIN CATCH
              IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
              EXEC sp_log_error 'sp_generar_cuotas';
              THROW;
       END CATCH
END;
```

*Ejemplo*
```sql
EXEC sp_generar_cuotas @id_venta = 2, @cantidad = 3;
```

== `sp_actualizar_precio_modelo`
Cambia el precio de lista de un modelo. Recibe el id del modelo y el precio nuevo en centavos. Consulta el precio actual y actualiza `modelos`. El cambio queda guardado en `historial_precios` por un trigger sobre `modelos`, así que el procedimiento no escribe ahí.

Valida que el modelo exista (error 51201), porque un `UPDATE` sobre un id que no existe no falla y nadie se enteraría, y que el precio nuevo sea distinto del actual (51202), para no llenar el historial con cambios que no cambian nada. Que el precio sea mayor a 0 lo controla el `CHECK` de `modelos`.

```sql
-- sp_actualizar_precio_modelo: cambia el precio de lista de un modelo.
CREATE OR ALTER PROCEDURE sp_actualizar_precio_modelo
       @id_modelo INT,
       @precio_nuevo BIGINT
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
              -- Un UPDATE sobre un id inexistente no falla, por eso se controla aca.
              DECLARE @precio_actual BIGINT;
              SELECT @precio_actual = precio FROM modelos WHERE id = @id_modelo;
              IF @precio_actual IS NULL
                     THROW 51201, 'El modelo no existe.', 1;
              IF @precio_actual = @precio_nuevo
                     THROW 51202, 'El precio nuevo es igual al actual.', 1;

              UPDATE modelos SET precio = @precio_nuevo WHERE id = @id_modelo;
       END TRY
       BEGIN CATCH
              IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
              EXEC sp_log_error 'sp_actualizar_precio_modelo';
              THROW;
       END CATCH
END;
```

*Ejemplo*
```sql
EXEC sp_actualizar_precio_modelo @id_modelo = 1, @precio_nuevo = 6800000000;
```

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
