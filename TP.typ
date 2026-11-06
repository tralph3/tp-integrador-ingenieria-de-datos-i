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
       patente VARCHAR(20),
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
       CONSTRAINT uq_ventas_id_vehiculo UNIQUE (id_vehiculo),
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
       fecha_pago DATE,
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
       fecha_liquidacion DATE,
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
Las consultas responden preguntas del día a día de la concesionaria: cuánto vendió cada sucursal y cada vendedor, qué clientes todavía deben cuotas, a quiénes les queda service gratuito y qué stock hay disponible. Cuando una función o una vista ya resuelve parte del problema, se usa en lugar de repetir la lógica, y los montos se muestran en pesos con `fn_formatear_monto`. Entre todas aparecen `WHERE`, `ORDER BY`, `JOIN`, `GROUP BY`, `HAVING`, `MAX`, `MIN` y consultas sobre varias tablas.

== Ventas del período
Lista las ventas de un período con el cliente, el vendedor, el modelo, el precio y la comisión de cada una. En vez de repetir los `JOIN` entre `ventas`, `clientes`, `vehiculos`, `modelos` y `marcas`, llama a `fn_ventas_vendedor` una vez por vendedor con `CROSS APPLY`. Las fechas del período están en dos variables, y el resultado sale de la venta más reciente a la más antigua.

```sql
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
```

== Ventas por sucursal
Cuenta las ventas y suma lo vendido en cada sucursal, de mayor a menor facturación. Cruza `ventas`, `vehiculos` y `sucursales`, y agrupa con `GROUP BY`. La sucursal que se toma es la del vehículo vendido.

```sql
SELECT s.nombre AS sucursal,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM ventas v
JOIN vehiculos vh ON vh.id = v.id_vehiculo
JOIN sucursales s ON s.id = vh.id_sucursal
GROUP BY s.id, s.nombre
ORDER BY SUM(v.precio) DESC;
```

== Vendedores con al menos dos ventas
Muestra cuántas ventas hizo cada vendedor y cuánto facturó, solo para quienes tienen dos o más. Ese filtro va en un `HAVING` porque depende del resultado de `COUNT`, no de cada fila. El `WHERE` deja afuera a los empleados que no son vendedores.

```sql
SELECT e.nombre_completo AS vendedor,
       COUNT(v.id) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(v.precio)) AS total_vendido
FROM empleados e
JOIN ventas v ON v.id_vendedor = e.id
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
HAVING COUNT(v.id) >= 2
ORDER BY SUM(v.precio) DESC;
```

== Precio mayor y menor
Obtiene el precio de lista más alto y el más bajo de todos los modelos con `MAX` y `MIN`.

```sql
SELECT dbo.fn_formatear_monto(MAX(precio)) AS precio_maximo,
       dbo.fn_formatear_monto(MIN(precio)) AS precio_minimo
FROM modelos;
```

== Ventas por medio de pago
Agrupa las ventas por medio de pago, con la cantidad y el total de cada uno, empezando por el más usado.

```sql
SELECT medio_pago,
       COUNT(*) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(precio)) AS total_vendido
FROM ventas
GROUP BY medio_pago
ORDER BY COUNT(*) DESC, medio_pago;
```

== Comisión por vendedor
Suma la comisión de cada vendedor en el período. Reutiliza `fn_ventas_vendedor`, que ya trae la comisión de cada venta, y las variables de la primera consulta.

```sql
SELECT e.nombre_completo AS vendedor,
       COUNT(f.id_venta) AS cantidad_ventas,
       dbo.fn_formatear_monto(SUM(f.comision)) AS comision_total
FROM empleados e
CROSS APPLY dbo.fn_ventas_vendedor(e.id, @desde, @hasta) f
WHERE e.tipo = 'vendedor'
GROUP BY e.id, e.nombre_completo
ORDER BY SUM(f.comision) DESC;
```

== Ventas a crédito con saldo
Muestra las ventas a crédito que todavía tienen cuotas sin pagar, con el precio de la venta y lo que falta, ordenadas por saldo. El saldo sale de `fn_saldo_pendiente`, que se usa en el `SELECT`, en el `WHERE` y en el `ORDER BY`.

```sql
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
```

== Service gratuito vigente
Muestra las ventas cuyo service gratuito sigue vigente hoy y hasta qué fecha se puede usar. La vigencia la decide `fn_service_vigente`, y la fecha límite se calcula sumando `meses_service` a la fecha de venta.

```sql
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
```

== Stock por sucursal y marca
Cuenta los vehículos disponibles y suma su valor de lista por sucursal y marca. Parte de `vw_stock_disponible`, que ya resuelve el cruce con modelos, marcas, sucursales y entregas, así que acá solo falta agrupar.

```sql
SELECT sucursal, marca,
       COUNT(*) AS unidades,
       dbo.fn_formatear_monto(SUM(precio_lista)) AS valor_stock
FROM vw_stock_disponible
GROUP BY sucursal, marca
ORDER BY sucursal, COUNT(*) DESC;
```

== Precios por marca
Calcula el precio de lista mayor y menor de cada marca y cuántos modelos tiene. Usa `vw_catalogo_modelos`, que ya une modelos con marcas.

```sql
SELECT marca,
       COUNT(*) AS cantidad_modelos,
       dbo.fn_formatear_monto(MAX(precio_lista)) AS precio_maximo,
       dbo.fn_formatear_monto(MIN(precio_lista)) AS precio_minimo
FROM vw_catalogo_modelos
GROUP BY marca
ORDER BY marca;
```

= Subconsultas
Estas consultas dependen del resultado de otra: comparan contra un promedio que se calcula en el momento o filtran según lo que existe, o no, en otra tabla. En cada una se explica qué información se obtiene, qué función cumple la subconsulta y por qué es adecuada.

== Modelos más caros que el promedio
Obtiene los modelos cuyo precio de lista supera el promedio de todos. La subconsulta calcula ese promedio y la consulta externa lo usa como umbral en el `WHERE`. Es adecuada porque el promedio cambia cuando se actualizan los precios, y así no hay que escribir un valor fijo.

```sql
SELECT ma.nombre AS marca, mo.modelo,
       dbo.fn_formatear_monto(mo.precio) AS precio_lista
FROM modelos mo
JOIN marcas ma ON ma.id = mo.id_marca
WHERE mo.precio > (
       SELECT AVG(CAST(precio AS DECIMAL(19,2)))
       FROM modelos
)
ORDER BY mo.precio DESC;
```

== Clientes con más de una venta
Busca los clientes que compraron más de una vez. La subconsulta agrupa `ventas` por cliente y devuelve los que aparecen más de una vez, y la consulta externa trae sus datos con `IN`. Así la externa no necesita agrupar y muestra cada cliente una sola vez.

```sql
SELECT c.id, c.nombre_completo, c.email
FROM clientes c
WHERE c.id IN (
       SELECT v.id_cliente
       FROM ventas v
       GROUP BY v.id_cliente
       HAVING COUNT(*) > 1
)
ORDER BY c.nombre_completo;
```

== Vendedores sobre el promedio
Muestra los vendedores que vendieron más que el promedio de ventas por vendedor. La subconsulta interna cuenta las ventas de cada vendedor y la de afuera promedia esos conteos, que se compara con el de cada uno en el `HAVING`. Hace falta anidarlas porque SQL Server no permite aplicar `AVG` directamente sobre un `COUNT`.

```sql
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
```

== Ventas sin registro RUNA
Detecta las ventas cuyo vehículo todavía no tiene registro en el RUNA. `NOT EXISTS` busca en `registro_runa` el vehículo de cada venta y deja pasar solo las que no lo encuentran. Es adecuada porque solo importa saber si existe un registro, no traer sus datos, y `NOT EXISTS` no se confunde con valores nulos.

```sql
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
```

== Modelos nunca vendidos
Lista los modelos de los que no se vendió ningún vehículo. La subconsulta devuelve los modelos de los vehículos que figuran en alguna venta, y la consulta externa se queda con los que no están en ese conjunto usando `NOT IN`. Es útil para ver qué modelos no se mueven.

```sql
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
```

= Vistas
Las vistas son consultas almacenadas que funcionan como tablas virtuales: no guardan datos propios, sino que muestran el resultado actualizado de un SELECT sobre una o más tablas. Se utilizan para consultar de forma simple información que requeriría varios JOIN y para exponer solo los datos necesarios. Son de solo lectura; las operaciones que modifican datos o validan reglas de negocio se resuelven con procedimientos almacenados y triggers.

== vw_stock_disponible
*Objetivo*

Mostrar los vehículos que actualmente están disponibles para la venta, junto con su ubicación y su precio de lista.

*Información presentada*

Sucursal donde se encuentra el vehículo, marca, modelo, color, chasis, precio de lista, fecha de ingreso (entrega) y proveedor.

*Tablas involucradas*

vehiculos, modelos, marcas, sucursales, entregas y proveedores.

*Motivo de utilización*

El vendedor necesita conocer qué vehículos puede ofrecer sin tener que armar cada vez un JOIN de seis tablas. La vista deja visibles únicamente los vehículos con estado disponible (los vendidos, reservados o en service no aparecen) y puede filtrarse desde afuera por sucursal, marca o modelo. Es una consulta de solo lectura que no requiere parámetros ni lógica de negocio, por lo que una vista resulta más adecuada que un procedimiento almacenado.

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
*Objetivo*

Ofrecer el listado de modelos que comercializa la concesionaria con su marca y su precio de lista actual.

*Información presentada*

Marca, país de origen de la marca, modelo, fecha de lanzamiento y precio de lista.

*Tablas involucradas*

modelos y marcas.

*Motivo de utilización*

Es la información que se le muestra al cliente o al área de marketing. La vista expone solo datos comerciales y evita que quien la consulta deba conocer la estructura interna de las tablas (identificadores y claves foráneas). Si el precio de un modelo cambia, la vista lo refleja automáticamente.

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
*Objetivo*

Listar las cuotas de las ventas a crédito que todavía no fueron pagadas, indicando cuáles están vencidas y cuántos días de atraso tienen.

*Información presentada*

Datos de contacto del cliente, vehículo vendido (marca, modelo y patente), número de cuota, monto, fecha de vencimiento, estado (vencida o a vencer) y días de atraso.

*Tablas involucradas*

cuotas, ventas, clientes, vehiculos, modelos y marcas.

*Motivo de utilización*

El área de cobranzas necesita identificar quién tiene deuda y desde cuándo, sin recorrer las cuotas una por una. La vista selecciona las cuotas con fecha de pago nula y calcula el atraso con la fecha actual, por lo que siempre se encuentra actualizada. Se utiliza solo para consultar: si fuera necesario notificar a los clientes o aplicar recargos, esa lógica correspondería a un procedimiento almacenado.

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
*Objetivo*

Mostrar los service programados a partir de la fecha actual, con el cliente, el vehículo, el taller y la situación de cobertura gratuita.

*Información presentada*

Fecha del service, taller y su dirección, cliente y datos de contacto, vehículo (marca, modelo y patente), fecha de venta, meses de service contratados, fecha de fin de cobertura y estado de la cobertura (vigente o vencida) a la fecha del service.

*Tablas involucradas*

service, talleres, ventas, clientes, vehiculos, modelos y marcas.

*Motivo de utilización*

El área de postventa necesita conocer los turnos próximos para avisar al cliente y coordinar con el taller. Como el service gratuito depende de los meses de service pactados en cada venta, la vista calcula la fecha de fin de cobertura e indica qué service quedan a cargo de la concesionaria y cuáles no. Se trata de una consulta sobre datos existentes, por lo que no requiere un procedimiento almacenado.

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
Registra la venta de un vehículo, que es el proceso central de la concesionaria. Recibe el cliente, el vendedor, el vehículo, la plataforma, el precio en centavos, el medio de pago, la patente con la que sale el auto y, si se quiere, los meses de service (por defecto 6) y la fecha de la venta (por defecto hoy). Devuelve el id de la venta en `@id_venta`.

Consulta al cliente, al vendedor y al vehículo, y modifica dos tablas: inserta la venta y pasa el vehículo a `vendido` con su patente. Las dos cosas van en una transacción, porque no puede quedar una sin la otra. El vehículo se lee con `UPDLOCK` para que dos ventas simultáneas no tomen el mismo auto.

Valida a mano solo lo que una constraint no puede expresar: que haya patente (error 51001), que el cliente tenga 18 años (51002), que el vendedor esté activo y sea de tipo vendedor (51003) y que el vehículo esté disponible (51004). El precio, el medio de pago y la existencia de los registros ya los controlan los `CHECK` y las claves foráneas de `ventas`. La comisión la genera un trigger sobre `ventas`.

```sql
CREATE OR ALTER PROCEDURE sp_registrar_venta
       @id_cliente INT,
       @id_vendedor INT,
       @id_vehiculo INT,
       @id_plataforma INT,
       @precio BIGINT,
       @medio_pago VARCHAR(30),
       @patente VARCHAR(20),
       @meses_service INT = 6,
       @fecha DATE = NULL,
       @id_venta INT OUTPUT
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
              SET @fecha = ISNULL(@fecha, CAST(GETDATE() AS DATE));

              IF @patente IS NULL
                     THROW 51001, 'Se debe indicar la patente con la que se vende el vehiculo.', 1;

              DECLARE @nacimiento DATE;
              SELECT @nacimiento = fecha_nacimiento FROM clientes WHERE id = @id_cliente;
              IF DATEADD(YEAR, 18, @nacimiento) > @fecha
                     THROW 51002, 'El cliente debe ser mayor de 18 anios.', 1;

              IF NOT EXISTS (SELECT 1 FROM empleados WHERE id = @id_vendedor AND tipo = 'vendedor' AND estado = 'activo')
                     THROW 51003, 'El vendedor no existe o no esta activo.', 1;

              BEGIN TRANSACTION;

              DECLARE @estado VARCHAR(20);
              SELECT @estado = estado FROM vehiculos WITH (UPDLOCK) WHERE id = @id_vehiculo;
              IF @estado != 'disponible'
                     THROW 51004, 'El vehiculo no esta disponible para la venta.', 1;

              INSERT INTO ventas (id_cliente, id_vendedor, id_vehiculo, id_plataforma, fecha, precio, medio_pago, meses_service)
              VALUES (@id_cliente, @id_vendedor, @id_vehiculo, @id_plataforma, @fecha, @precio, @medio_pago, @meses_service);
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
EXEC sp_registrar_venta @id_cliente = 1, @id_vendedor = 1, @id_vehiculo = 10,
     @id_plataforma = 1, @precio = 6400000000, @medio_pago = 'efectivo',
     @patente = 'AE204LP', @id_venta = @id_venta OUTPUT;
```

== `sp_generar_cuotas`
Reparte el precio de una venta a crédito en cuotas mensuales. Recibe el id de la venta y la cantidad de cuotas, que tiene que estar entre 1 y 120. Lee el precio y la fecha de la venta, y genera los números de cuota con una consulta recursiva, sin cursor. El primer vencimiento cae un mes después de la venta.

La división del precio es entera y descarta el resto, así que la última cuota absorbe la diferencia para que todas sumen exactamente el precio. Las inserciones van en una transacción: o se crean todas las cuotas o ninguna.

Que la venta exista, que sea a crédito y que no tenga cuotas ya cargadas lo controlan la clave foránea, el trigger de cuotas y el `UNIQUE (id_venta, nro_cuota)`. Acá solo se valida el rango de la cantidad (error 51101).

```sql
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
CREATE OR ALTER PROCEDURE sp_actualizar_precio_modelo
       @id_modelo INT,
       @precio_nuevo BIGINT
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
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
Implementamos los siguientes triggers para aplicar automáticamente reglas que una constraint no puede expresar, casi siempre porque hay que mirar otra tabla, y para generar datos derivados que no queremos depender de que alguien cargue a mano. Los que validan deshacen la operación con `ROLLBACK` y lanzan un error con `THROW`, y cada uno tiene su propio número de error.

== `trg_cuotas_solo_credito`
Se dispara con un `INSERT` o `UPDATE` sobre `cuotas`. Si la venta de alguna de las cuotas tiene un medio de pago distinto de crédito, deshace la operación y lanza el error 50001. Implementa la regla de que solo las ventas a crédito tienen cuotas. Hace falta un trigger porque la condición depende de `ventas`, y un `CHECK` no puede mirar otra tabla.

```sql
CREATE TRIGGER trg_cuotas_solo_credito
ON cuotas
AFTER INSERT, UPDATE
AS
BEGIN
       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN ventas v ON v.id = i.id_venta
              WHERE v.medio_pago != 'credito'
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50001, 'Solo las ventas a credito pueden tener cuotas.', 1;
       END
END;
```

== `trg_ventas_validar`
Se dispara con un `INSERT` sobre `ventas` y controla tres reglas. El cliente tiene que ser mayor de 18 años a la fecha de la venta (error 50002), el vendedor tiene que ser un empleado activo de tipo vendedor (50003) y el vehículo tiene que estar disponible (50004). Si alguna falla, deshace la venta. Si todas se cumplen, pasa el vehículo a `vendido`.

Las tres reglas cruzan `ventas` con `clientes`, `empleados` y `vehiculos`, por eso van en un trigger. Cambiar el estado en el mismo lugar evita que un vehículo vendido siga figurando como disponible, sin importar por dónde se cargue la venta. Este trigger tiene prioridad sobre los demás de `ventas` con `sp_settriggerorder`, así una venta inválida no genera comisión.

```sql
CREATE OR ALTER TRIGGER trg_ventas_validar
ON ventas
AFTER INSERT
AS
BEGIN
       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN clientes c ON c.id = i.id_cliente
              WHERE DATEADD(YEAR, 18, c.fecha_nacimiento) > i.fecha
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50002, 'El cliente debe ser mayor de 18 anios.', 1;
       END

       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN empleados e ON e.id = i.id_vendedor
              WHERE e.tipo != 'vendedor' OR e.estado != 'activo'
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50003, 'Solo un empleado activo de tipo vendedor puede registrar ventas.', 1;
       END

       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN vehiculos v ON v.id = i.id_vehiculo
              WHERE v.estado != 'disponible'
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50004, 'El vehiculo no esta disponible para la venta.', 1;
       END

       UPDATE v
       SET v.estado = 'vendido'
       FROM vehiculos v
       JOIN inserted i ON i.id_vehiculo = v.id;
END;

-- Tiene que correr antes que los otros triggers de ventas: si la venta es
-- invalida, ninguno de los demas debe llegar a ejecutarse.
EXEC sp_settriggerorder @triggername = 'trg_ventas_validar', @order = 'First', @stmttype = 'INSERT';
```

== `trg_ventas_comision`
Se dispara con un `INSERT` sobre `ventas`, sin condición: por cada venta nueva inserta en `comisiones` el 2% del precio (calculado con `fn_comision`), pendiente de liquidar. Implementa la regla de que cada venta genera una comisión para el vendedor. Se justifica porque así ninguna venta puede quedar sin comisión, aunque se cargue sin pasar por el procedimiento de venta.

```sql
CREATE OR ALTER TRIGGER trg_ventas_comision
ON ventas
AFTER INSERT
AS
BEGIN
       INSERT INTO comisiones (id_venta, monto)
       SELECT i.id, dbo.fn_comision(i.precio)
       FROM inserted i;
END;
```

== `trg_modelos_historial_precios`
Se dispara con un `UPDATE` sobre `modelos`, y solo actúa si cambió el precio. En ese caso inserta en `historial_precios` el precio anterior y el nuevo, y el usuario y la fecha se completan solos. Implementa la regla de que todo cambio del precio de lista queda registrado. Las ventas guardan el precio al que se vendió, pero sin este trigger no se sabría cuándo ni quién modificó el precio de lista.

```sql
CREATE OR ALTER TRIGGER trg_modelos_historial_precios
ON modelos
AFTER UPDATE
AS
BEGIN
       IF UPDATE(precio)
       BEGIN
              INSERT INTO historial_precios (id_modelo, precio_anterior, precio_nuevo)
              SELECT d.id, d.precio, i.precio
              FROM inserted i
              JOIN deleted d ON d.id = i.id
              WHERE d.precio != i.precio;
       END
END;
```

== `trg_service_vigencia`
Se dispara con un `INSERT` o `UPDATE` sobre `service`. Si `fn_service_vigente` indica que la fecha del service no está dentro del plazo (anterior a la venta o posterior a la fecha de venta más los `meses_service` pactados), deshace la operación y lanza el error 50006. Implementa la regla de que el service gratuito solo se puede usar dentro del plazo de vigencia. Como el plazo es distinto en cada venta, hay que consultar `ventas`, y por eso no alcanza con un `CHECK`.

```sql
CREATE OR ALTER TRIGGER trg_service_vigencia
ON service
AFTER INSERT, UPDATE
AS
BEGIN
       IF EXISTS (
              SELECT 1
              FROM inserted i
              WHERE dbo.fn_service_vigente(i.id_venta, i.fecha) = 0
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50006, 'La fecha del service esta fuera del plazo de vigencia.', 1;
       END
END;
```

== `trg_registro_runa_cliente`
Se dispara con un `INSERT` o `UPDATE` sobre `registro_runa`. Rechaza el registro si el vehículo no tiene una venta (error 50007) o si el cliente no es el comprador de esa venta (50008). Implementa la regla de que el vehículo se registra en el RUNA a nombre del cliente que lo compró. Se justifica porque registrarlo a nombre de otra persona sería un error de datos con consecuencias legales, y verificarlo requiere cruzar con `ventas`.

```sql
CREATE OR ALTER TRIGGER trg_registro_runa_cliente
ON registro_runa
AFTER INSERT, UPDATE
AS
BEGIN
       IF EXISTS (
              SELECT 1
              FROM inserted i
              LEFT JOIN ventas v ON v.id_vehiculo = i.id_vehiculo
              WHERE v.id IS NULL
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50007, 'No se puede registrar en el RUNA un vehiculo que no fue vendido.', 1;
       END

       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN ventas v ON v.id_vehiculo = i.id_vehiculo
              WHERE v.id_cliente != i.id_cliente
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50008, 'El cliente del registro RUNA debe ser el comprador del vehiculo.', 1;
       END
END;
```

= Cursores
Un cursor permite recorrer el resultado de una consulta fila por fila y ejecutar una operación sobre cada una. Como es más lento que una operación por conjuntos, en este trabajo se utiliza solo cuando cada fila requiere un tratamiento individual que una única sentencia no puede dar. Todos se declaran `LOCAL`, `STATIC` y `READ_ONLY`: el conjunto queda fijo al abrir el cursor, y se libera solo al terminar el procedimiento que lo contiene.

== sp_aumentar_precios_marca
*Problema que se desea resolver:* Aplicar un aumento porcentual al precio de lista de todos los modelos de una marca, por ejemplo cuando el proveedor actualiza sus precios.

*Motivo por el cual se utiliza un cursor:* Cada modelo debe pasar por sp_actualizar_precio_modelo, que valida que el modelo exista y que el precio cambie, y registra los errores. Un UPDATE masivo sobre modelos se saltearía esas validaciones, y un procedimiento no puede aplicarse a un conjunto de filas: hay que invocarlo una vez por fila. Además, el cursor permite que, si un modelo falla, el error quede registrado y se continúe con los demás.

*Registros procesados:* Los modelos de la marca indicada (tabla modelos, filtrada por id_marca), tomados al abrir el cursor y ordenados por id.

*Operación realizada sobre cada registro:* Se calcula el precio nuevo como el precio actual más el porcentaje indicado, redondeado al entero más cercano, y se ejecuta sp_actualizar_precio_modelo con ese valor. Si el procedimiento falla, se cuenta como fallido y se continúa con el siguiente. Al finalizar se informa la cantidad de modelos actualizados y fallidos.

```sql
CREATE OR ALTER PROCEDURE sp_aumentar_precios_marca
       @id_marca INT,
       @porcentaje DECIMAL(5,2)
AS
BEGIN
       SET NOCOUNT ON;
       BEGIN TRY
              IF @porcentaje IS NULL OR @porcentaje <= 0
                     THROW 51301, 'El porcentaje de aumento debe ser mayor a 0.', 1;

              IF NOT EXISTS (SELECT 1 FROM marcas WHERE id = @id_marca)
                     THROW 51302, 'La marca no existe.', 1;

              DECLARE @id_modelo INT, @precio_actual BIGINT, @precio_nuevo BIGINT;
              DECLARE @actualizados INT = 0, @fallidos INT = 0;

              DECLARE c_modelos CURSOR LOCAL STATIC READ_ONLY FOR
                     SELECT id, precio FROM modelos WHERE id_marca = @id_marca ORDER BY id;

              OPEN c_modelos;
              FETCH NEXT FROM c_modelos INTO @id_modelo, @precio_actual;

              WHILE @@FETCH_STATUS = 0
              BEGIN
                     SET @precio_nuevo = CAST(ROUND(@precio_actual * (1 + @porcentaje / 100.0), 0) AS BIGINT);

                     BEGIN TRY
                            EXEC sp_actualizar_precio_modelo @id_modelo, @precio_nuevo;
                            SET @actualizados += 1;
                     END TRY
                     BEGIN CATCH
                            SET @fallidos += 1;
                     END CATCH

                     FETCH NEXT FROM c_modelos INTO @id_modelo, @precio_actual;
              END;

              CLOSE c_modelos;
              DEALLOCATE c_modelos;

              SELECT @actualizados AS modelos_actualizados, @fallidos AS modelos_fallidos;
       END TRY
       BEGIN CATCH
              IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
              EXEC sp_log_error 'sp_aumentar_precios_marca';
              THROW;
       END CATCH
END;
```

*Ejemplo*
```sql
EXEC sp_aumentar_precios_marca @id_marca = 1, @porcentaje = 5;
```

== sp_liquidar_comisiones
*Problema que se desea resolver:* Liquidar las comisiones de venta que están pendientes (con fecha de liquidación nula), registrando la fecha de liquidación, sin que una comisión que todavía no corresponde pagar impida liquidar las demás.

*Motivo por el cual se utiliza un cursor:* Cada comisión se evalúa por separado: si la venta fue a crédito, solo corresponde liquidarla cuando el cliente terminó de pagar todas las cuotas, y se verifica además que otro proceso no la haya liquidado mientras se recorría el conjunto. Cada liquidación se ejecuta en su propia transacción y, cuando una se rechaza, el motivo queda guardado en log_errores con el número de comisión y se sigue con la siguiente. Un único UPDATE no puede aislar el error de cada fila, y el registro de errores del sistema (sp_log_error) se apoya en el CATCH, que actúa sobre una fila por vez.

*Registros procesados:* Las comisiones con fecha_liquidacion nula, junto con el medio de pago de la venta asociada (tablas comisiones y ventas), ordenadas por id.

*Operación realizada sobre cada registro:* Se bloquea la comisión y se verifica que siga pendiente; si la venta es a crédito, se verifica que tenga cuotas y que `fn_saldo_pendiente` sea cero. Si se cumple, se asigna la fecha actual a fecha_liquidacion y se confirma la transacción. Si no, se deshace, se registra el error y se cuenta la comisión como rechazada. Al finalizar se informa cuántas comisiones se liquidaron y cuántas se rechazaron.

```sql
CREATE OR ALTER PROCEDURE sp_liquidar_comisiones
AS
BEGIN
       SET NOCOUNT ON;
       SET CURSOR_CLOSE_ON_COMMIT OFF;
       BEGIN TRY
              DECLARE @id_comision INT, @id_venta INT, @medio_pago VARCHAR(30);
              DECLARE @ya_liquidada DATE, @msg NVARCHAR(200);
              DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
              DECLARE @liquidadas INT = 0, @rechazadas INT = 0;

              DECLARE c_comisiones CURSOR LOCAL STATIC READ_ONLY FOR
                     SELECT co.id, co.id_venta, ve.medio_pago
                     FROM comisiones co
                            INNER JOIN ventas ve ON ve.id = co.id_venta
                     WHERE co.fecha_liquidacion IS NULL
                     ORDER BY co.id;

              OPEN c_comisiones;
              FETCH NEXT FROM c_comisiones INTO @id_comision, @id_venta, @medio_pago;

              WHILE @@FETCH_STATUS = 0
              BEGIN
                     BEGIN TRY
                            BEGIN TRANSACTION;

                            SELECT @ya_liquidada = fecha_liquidacion
                            FROM comisiones WITH (UPDLOCK) WHERE id = @id_comision;
                            IF @ya_liquidada IS NOT NULL
                            BEGIN
                                   SET @msg = CONCAT('Comision ', @id_comision, ': ya fue liquidada.');
                                   THROW 51401, @msg, 1;
                            END;

                            IF @medio_pago = 'credito'
                               AND (NOT EXISTS (SELECT 1 FROM cuotas WHERE id_venta = @id_venta)
                                    OR dbo.fn_saldo_pendiente(@id_venta) > 0)
                            BEGIN
                                   SET @msg = CONCAT('Comision ', @id_comision, ': la venta a credito tiene cuotas sin pagar.');
                                   THROW 51402, @msg, 1;
                            END;

                            UPDATE comisiones SET fecha_liquidacion = @fecha WHERE id = @id_comision;

                            COMMIT TRANSACTION;
                            SET @liquidadas += 1;
                     END TRY
                     BEGIN CATCH
                            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                            EXEC sp_log_error 'sp_liquidar_comisiones';
                            SET @rechazadas += 1;
                     END CATCH

                     FETCH NEXT FROM c_comisiones INTO @id_comision, @id_venta, @medio_pago;
              END;

              CLOSE c_comisiones;
              DEALLOCATE c_comisiones;

              SELECT @liquidadas AS comisiones_liquidadas, @rechazadas AS comisiones_rechazadas;
       END TRY
       BEGIN CATCH
              IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
              EXEC sp_log_error 'sp_liquidar_comisiones';
              THROW;
       END CATCH
END;
```

*Ejemplo*
```sql
EXEC sp_liquidar_comisiones;
```

= Funciones
Las funciones reúnen en un solo lugar cálculos que varios objetos de la base necesitan. Las escalares se llaman con el esquema, por ejemplo `dbo.fn_comision(...)`, y los montos van siempre en centavos.

== `fn_saldo_pendiente`
Devuelve cuánto le falta pagar al cliente de una venta. Recibe el id de la venta (`INT`) y devuelve un `BIGINT` con la suma de las cuotas que todavía no tienen `fecha_pago`. Si la venta no tiene cuotas (porque no fue a crédito) o ya están todas pagas, devuelve 0. Eso significa que no distingue una venta sin cuotas de una saldada, y por eso `sp_liquidar_comisiones`, que la usa para decidir si liquida una comisión, comprueba aparte que las cuotas existan.

```sql
CREATE OR ALTER FUNCTION fn_saldo_pendiente (@id_venta INT)
RETURNS BIGINT
AS
BEGIN
       RETURN (
              SELECT ISNULL(SUM(monto), 0)
              FROM cuotas
              WHERE id_venta = @id_venta
                AND fecha_pago IS NULL
       );
END;
```

*Ejemplo*
```sql
SELECT dbo.fn_saldo_pendiente(4) AS saldo;
```

== `fn_service_vigente`
Indica si una fecha cae dentro del plazo de service de una venta. Recibe el id de la venta (`INT`) y la fecha a evaluar (`DATE`), y devuelve un `BIT`: 1 si la fecha está entre la fecha de venta y esa fecha más los `meses_service` pactados, 0 si no, y `NULL` si la venta no existe. Esta regla antes estaba escrita dentro de `trg_service_vigencia`, que ahora la consulta acá. También sirve para saber si un cliente todavía tiene service vigente.

```sql
CREATE OR ALTER FUNCTION fn_service_vigente (@id_venta INT, @fecha DATE)
RETURNS BIT
AS
BEGIN
       RETURN (
              SELECT CASE WHEN @fecha BETWEEN v.fecha AND DATEADD(MONTH, v.meses_service, v.fecha)
                          THEN 1 ELSE 0 END
              FROM ventas v
              WHERE v.id = @id_venta
       );
END;
```

*Ejemplo*
```sql
SELECT dbo.fn_service_vigente(1, GETDATE()) AS vigente;
```

== `fn_comision`
Calcula la comisión de una venta, el 2% del precio. Recibe el precio en centavos (`BIGINT`) y devuelve otro `BIGINT`. La cuenta es `precio * 2 / 100`, con la multiplicación primero porque `2 / 100` es una división entera y da 0, y la comisión saldría siempre nula. Al truncar solo se pierde la fracción de centavo. La usa `trg_ventas_comision`, así que si cambia el porcentaje alcanza con modificar esta función.

```sql
CREATE OR ALTER FUNCTION fn_comision (@precio BIGINT)
RETURNS BIGINT
AS
BEGIN
       RETURN @precio * 2 / 100;
END;
```

*Ejemplo*
```sql
SELECT dbo.fn_comision(6500000000) AS comision;
```

== `fn_formatear_monto`
Pasa un monto en centavos a un texto visible para los reportes, separando los miles con puntos y los decimales con una coma. Recibe los centavos (`BIGINT`) y devuelve un `VARCHAR(40)`. Por ejemplo, 6500000000 queda como `$ 65.000.000,00`. Asume montos positivos, que es lo que permiten los `CHECK` de las tablas.

```sql
CREATE OR ALTER FUNCTION fn_formatear_monto (@centavos BIGINT)
RETURNS VARCHAR(40)
AS
BEGIN
       RETURN '$ ' + FORMAT(@centavos / 100, 'N0', 'es-AR')
              + ',' + RIGHT('0' + CAST(@centavos % 100 AS VARCHAR(2)), 2);
END;
```

*Ejemplo*
```sql
SELECT dbo.fn_formatear_monto(6500000000) AS monto;
```

== `fn_ventas_vendedor`
Devuelve las ventas de un vendedor en un período. Recibe el id del vendedor (`INT`) y las fechas desde y hasta (`DATE`), y devuelve una tabla con los datos de cada venta: cliente, modelo, precio y comisión. Para armarla cruza `ventas` con `clientes`, `vehiculos`, `modelos` y `marcas`, y une `comisiones` con `LEFT JOIN` para que una venta sin comisión no desaparezca. Es una función de tabla en línea: tiene un solo `SELECT` y se usa en el `FROM`, casi como una vista con parámetros.

```sql
CREATE OR ALTER FUNCTION fn_ventas_vendedor (@id_vendedor INT, @desde DATE, @hasta DATE)
RETURNS TABLE
AS
RETURN (
       SELECT v.id AS id_venta,
              v.fecha,
              c.nombre_completo AS cliente,
              ma.nombre AS marca,
              mo.modelo,
              v.precio,
              co.monto AS comision
       FROM ventas v
       JOIN clientes c ON c.id = v.id_cliente
       JOIN vehiculos ve ON ve.id = v.id_vehiculo
       JOIN modelos mo ON mo.id = ve.id_modelo
       JOIN marcas ma ON ma.id = mo.id_marca
       LEFT JOIN comisiones co ON co.id_venta = v.id
       WHERE v.id_vendedor = @id_vendedor
         AND v.fecha BETWEEN @desde AND @hasta
);
```

*Ejemplo*
```sql
SELECT * FROM dbo.fn_ventas_vendedor(1, '2025-01-01', '2025-12-31');
```

= Manejo de errores
Casi todo lo frena la propia estructura de las tablas. Los triggers cubren lo que depende de otras tablas, y los procedimientos lo que queda. Si algo se rechaza, no queda ninguna operación a medio hacer.

Los datos inválidos y las violaciones de restricciones los frenan los `CHECK`, las claves foráneas, los `UNIQUE` y los `NOT NULL`. Un precio negativo o un DNI repetido hacen fallar el `INSERT` con el número de error que le asigna SQL Server, y por eso los procedimientos no repiten esas validaciones. Cuando la operación viene de un procedimiento, el `CATCH` captura ese error y lo guarda en `log_errores`.

Las reglas que necesitan mirar otra tabla las resuelven los triggers, que deshacen la operación con `ROLLBACK` y lanzan un error propio con `THROW` (50001 a 50008). Acá entran las operaciones no permitidas, como registrar un service fuera de plazo o poner en el RUNA a alguien que no compró el vehículo.

Los procedimientos se ocupan del resto. Revisan los parámetros, como una cantidad de cuotas fuera de rango o un porcentaje de aumento menor o igual a cero, y que existan el modelo o la marca que se van a modificar (un `UPDATE` sobre un id inexistente no falla, y ninguna clave foránea lo impide). También rechazan las operaciones no permitidas que no encajan en un trigger, como liquidar la comisión de una venta cuyo cliente todavía debe cuotas. Menor de edad, vendedor activo y vehículo disponible se controlan en los dos lugares: el procedimiento falla primero y con un mensaje más claro, y el trigger sigue protegiendo cuando alguien inserta en `ventas` directamente.

#{
  set text(size: 9pt)
  set par(justify: false)
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Código*][*Origen*][*Situación*],
    [50001], [`trg_cuotas_solo_credito`], [Cuotas en una venta que no es a crédito.],
    [50002], [`trg_ventas_validar`], [Cliente menor de 18 años.],
    [50003], [`trg_ventas_validar`], [Empleado que no es vendedor o no está activo.],
    [50004], [`trg_ventas_validar`], [Vehículo no disponible.],
    [50006], [`trg_service_vigencia`], [Service fuera del plazo de vigencia.],
    [50007], [`trg_registro_runa_cliente`], [Registro RUNA de un vehículo sin venta.],
    [50008], [`trg_registro_runa_cliente`], [Cliente del RUNA distinto del comprador.],
    [51001], [`sp_registrar_venta`], [Patente no indicada.],
    [51002], [`sp_registrar_venta`], [Cliente menor de 18 años.],
    [51003], [`sp_registrar_venta`], [Vendedor inexistente, inactivo o de otro tipo.],
    [51004], [`sp_registrar_venta`], [Vehículo no disponible.],
    [51101], [`sp_generar_cuotas`], [Cantidad de cuotas fuera de 1 a 120.],
    [51201], [`sp_actualizar_precio_modelo`], [Modelo inexistente.],
    [51202], [`sp_actualizar_precio_modelo`], [Precio nuevo igual al actual.],
    [51301], [`sp_aumentar_precios_marca`], [Porcentaje de aumento menor o igual a 0.],
    [51302], [`sp_aumentar_precios_marca`], [Marca inexistente.],
    [51401], [`sp_liquidar_comisiones`], [Comisión ya liquidada.],
    [51402], [`sp_liquidar_comisiones`], [Venta a crédito con cuotas sin pagar.],
  )
}

Cada procedimiento que modifica datos abre una transacción y la confirma al final. Si algo falla, el `CATCH` hace `ROLLBACK` solo si todavía hay una transacción abierta (`@@TRANCOUNT > 0`), porque un trigger puede haberla deshecho antes. Después llama a `sp_log_error` y relanza el error con `THROW` para que lo vea quien llamó. Ese orden importa: si el registro se hiciera antes, el `ROLLBACK` lo borraría. `sp_registrar_venta` además bloquea la fila del vehículo con `UPDLOCK` hasta confirmar, así que dos ventas simultáneas del mismo vehículo no pasan las dos. En los cursores cada fila va en su propio `TRY`: el error de una se registra y el recorrido sigue.

`log_errores` guarda la fecha, el usuario de SQL Server, el procedimiento, el número de error y el mensaje. Los errores de un trigger quedan registrados solo si la operación vino de un procedimiento; si se inserta directo en la tabla, el error le llega al cliente y no se guarda. Para que la tabla tenga contenido, los datos de prueba incluyen seis llamadas que fallan a propósito, por ejemplo vender un vehículo que ya se vendió o cambiar el precio de un modelo que no existe.

*Ejemplo*
```sql
SELECT fecha, usuario, procedimiento, numero_error, mensaje
FROM log_errores
ORDER BY id;
```

= Seguridad de la base de datos
Cada tipo de empleado que usa la base tiene un rol, y los usuarios no reciben permisos sueltos: los heredan del rol al que pertenecen. Casi nadie toca las tablas directamente. Se consulta a través de vistas y se opera a través de procedimientos, y eso funciona porque todos los objetos pertenecen al esquema `dbo`. Cuando un procedimiento usa una tabla del mismo dueño, SQL Server no revisa los permisos de quien lo ejecuta sobre esa tabla (encadenamiento de propiedad). Por eso un vendedor puede registrar una venta con `sp_registrar_venta` sin tener permiso de `INSERT` sobre `ventas`.

== Usuarios
Hay cinco usuarios, uno por rol: `usr_vendedor`, `usr_contador`, `usr_gerente`, `usr_marketing` y `usr_admin`. Son usuarios de ejemplo. En una puesta en marcha habría uno por persona, que se agregaría al rol correspondiente con `ALTER ROLE`. Los empleados de tipo `limpieza` no tienen usuario porque no usan la base.

#{
  set text(size: 9pt)
  set par(justify: false)
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Usuario*][*Rol*][*Lo usa*],
    [`usr_vendedor`], [`rol_vendedor`], [Empleados de tipo vendedor.],
    [`usr_contador`], [`rol_contador`], [Empleados de tipo contador.],
    [`usr_gerente`], [`rol_gerente`], [Empleados de tipo gerente.],
    [`usr_marketing`], [`rol_marketing`], [Empleados de tipo marketing.],
    [`usr_admin`], [`rol_administrador`], [Quien mantiene la base.],
  )
}

Cada usuario tiene su propio login de SQL Server, con política de contraseñas y vencimiento activados. La contraseña inicial es temporal y el motor obliga a cambiarla en el primer ingreso. Tener un login por usuario también sirve para saber quién hizo cada cosa: las columnas `usuario` de `log_errores` y `historial_precios` toman el valor de `SUSER_SNAME()`.

```sql
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_vendedor')
       CREATE LOGIN usr_vendedor
       WITH PASSWORD = 'Cambiar1#Alfa26' MUST_CHANGE,
            CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_contador')
       CREATE LOGIN usr_contador
       WITH PASSWORD = 'Cambiar2#Beta26' MUST_CHANGE,
            CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_gerente')
       CREATE LOGIN usr_gerente
       WITH PASSWORD = 'Cambiar3#Gama26' MUST_CHANGE,
            CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_marketing')
       CREATE LOGIN usr_marketing
       WITH PASSWORD = 'Cambiar4#Delta26' MUST_CHANGE,
            CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usr_admin')
       CREATE LOGIN usr_admin
       WITH PASSWORD = 'Cambiar5#Sigma26' MUST_CHANGE,
            CHECK_EXPIRATION = ON, CHECK_POLICY = ON;

IF DATABASE_PRINCIPAL_ID('usr_vendedor') IS NULL
       CREATE USER usr_vendedor FOR LOGIN usr_vendedor;

IF DATABASE_PRINCIPAL_ID('usr_contador') IS NULL
       CREATE USER usr_contador FOR LOGIN usr_contador;

IF DATABASE_PRINCIPAL_ID('usr_gerente') IS NULL
       CREATE USER usr_gerente FOR LOGIN usr_gerente;

IF DATABASE_PRINCIPAL_ID('usr_marketing') IS NULL
       CREATE USER usr_marketing FOR LOGIN usr_marketing;

IF DATABASE_PRINCIPAL_ID('usr_admin') IS NULL
       CREATE USER usr_admin FOR LOGIN usr_admin;
```

== Roles
Se crearon cinco roles. `rol_vendedor` atiende al cliente y cierra la venta. `rol_contador` se ocupa de los cobros y las comisiones. `rol_gerente` supervisa el negocio y carga lo que llega a las sucursales. `rol_marketing` solo necesita conocer el catálogo de modelos. `rol_administrador` mantiene la base: es miembro de `db_owner`, así que puede todo, y no se usa para el trabajo diario.

```sql
IF DATABASE_PRINCIPAL_ID('rol_vendedor') IS NULL
       CREATE ROLE rol_vendedor;

IF DATABASE_PRINCIPAL_ID('rol_contador') IS NULL
       CREATE ROLE rol_contador;

IF DATABASE_PRINCIPAL_ID('rol_gerente') IS NULL
       CREATE ROLE rol_gerente;

IF DATABASE_PRINCIPAL_ID('rol_marketing') IS NULL
       CREATE ROLE rol_marketing;

IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL
       CREATE ROLE rol_administrador;

ALTER ROLE rol_vendedor ADD MEMBER usr_vendedor;
ALTER ROLE rol_contador ADD MEMBER usr_contador;
ALTER ROLE rol_gerente ADD MEMBER usr_gerente;
ALTER ROLE rol_marketing ADD MEMBER usr_marketing;
ALTER ROLE rol_administrador ADD MEMBER usr_admin;
ALTER ROLE db_owner ADD MEMBER rol_administrador;
```

== Permisos
Los permisos se dan con `GRANT` a los roles, nunca a los usuarios, y lo que no se otorga queda prohibido. La tabla muestra lo que recibe cada rol, salvo el administrador, que lo tiene todo por `db_owner`.

#{
  set text(size: 9pt)
  set par(justify: false)
  table(
    columns: (auto, 1fr, 1.1fr),
    stroke: 0.5pt + luma(150),
    inset: 5pt,
    table.header[*Rol*][*Consulta*][*Ejecuta*],
    [`rol_vendedor`], [`vw_stock_disponible`, `vw_catalogo_modelos` y las columnas `id`, `nombre_completo`, `dni`, `email` y `telefono` de `clientes`], [`sp_registrar_cliente`, `sp_registrar_venta`, `sp_generar_cuotas` y `fn_formatear_monto`],
    [`rol_contador`], [`vw_cuotas_pendientes`, `fn_ventas_vendedor`, `cuotas`, `comisiones`, `ventas` y `empleados`], [`sp_liquidar_comisiones`, `fn_saldo_pendiente`, `fn_comision` y `fn_formatear_monto`],
    [`rol_gerente`], [Todo el esquema `dbo`], [`sp_actualizar_precio_modelo`, `sp_aumentar_precios_marca` y las cuatro funciones escalares],
    [`rol_marketing`], [`vw_catalogo_modelos`], [Nada],
  )
}

Hay dos permisos de escritura directa. El contador puede actualizar solo la columna `fecha_pago` de `cuotas`, que es como registra un cobro, sin poder tocar montos ni vencimientos. El gerente puede hacer `INSERT` en `entregas`, `vehiculos`, `service` y `registro_runa`, tablas que no tienen procedimiento y que ya se protegen con sus constraints y con los triggers `trg_service_vigencia` y `trg_registro_runa_cliente`.

El vendedor no recibe la columna `fecha_nacimiento` de `clientes`. No la necesita, porque la edad la valida `sp_registrar_venta` por dentro.

```sql
GRANT SELECT ON vw_stock_disponible TO rol_vendedor;
GRANT SELECT ON vw_catalogo_modelos TO rol_vendedor;
GRANT SELECT ON clientes (id, nombre_completo, dni, email, telefono) TO rol_vendedor;
GRANT EXECUTE ON sp_registrar_cliente TO rol_vendedor;
GRANT EXECUTE ON sp_registrar_venta TO rol_vendedor;
GRANT EXECUTE ON sp_generar_cuotas TO rol_vendedor;
GRANT EXECUTE ON fn_formatear_monto TO rol_vendedor;

GRANT SELECT ON vw_cuotas_pendientes TO rol_contador;
GRANT SELECT ON fn_ventas_vendedor TO rol_contador;
GRANT SELECT ON cuotas TO rol_contador;
GRANT SELECT ON comisiones TO rol_contador;
GRANT SELECT ON ventas TO rol_contador;
GRANT SELECT ON empleados TO rol_contador;
GRANT UPDATE ON cuotas (fecha_pago) TO rol_contador;
GRANT EXECUTE ON sp_liquidar_comisiones TO rol_contador;
GRANT EXECUTE ON fn_saldo_pendiente TO rol_contador;
GRANT EXECUTE ON fn_comision TO rol_contador;
GRANT EXECUTE ON fn_formatear_monto TO rol_contador;
GRANT UNMASK TO rol_contador;

GRANT SELECT ON SCHEMA::dbo TO rol_gerente;
GRANT EXECUTE ON sp_actualizar_precio_modelo TO rol_gerente;
GRANT EXECUTE ON sp_aumentar_precios_marca TO rol_gerente;
GRANT EXECUTE ON fn_saldo_pendiente TO rol_gerente;
GRANT EXECUTE ON fn_service_vigente TO rol_gerente;
GRANT EXECUTE ON fn_comision TO rol_gerente;
GRANT EXECUTE ON fn_formatear_monto TO rol_gerente;
GRANT INSERT ON entregas TO rol_gerente;
GRANT INSERT ON vehiculos TO rol_gerente;
GRANT INSERT ON service TO rol_gerente;
GRANT INSERT ON registro_runa TO rol_gerente;
GRANT UNMASK TO rol_gerente;

GRANT SELECT ON vw_catalogo_modelos TO rol_marketing;
```

== Acceso a la información
El vendedor ve el stock disponible, el catálogo y los datos de contacto de los clientes, enmascarados. No ve ventas, comisiones ni sueldos. El contador ve las cuotas, las ventas, las comisiones y los sueldos, y los datos de contacto completos de los clientes con cuotas pendientes, que necesita para cobrar. No ve el stock ni el historial de precios. El gerente ve toda la base, incluidos `log_errores` e `historial_precios`. Marketing ve solo marca, origen, modelo, fecha de lanzamiento y precio de lista, sin ningún dato de clientes ni de ventas. El administrador ve todo.

== Operaciones permitidas
El vendedor da de alta clientes, registra ventas y genera las cuotas de las ventas a crédito. El contador marca cuotas como pagas y liquida comisiones. El gerente cambia precios, de un modelo o de toda una marca, y carga entregas, vehículos, services y registros del RUNA. Marketing no modifica nada. El resto lo hace el administrador: el alta y la baja de empleados, el mantenimiento de marcas, modelos, proveedores, talleres, sucursales y plataformas, y los cambios de estado de un vehículo que no son una venta, como una reserva o el ingreso a service, porque no tienen procedimiento.

== Restricciones de acceso
Ningún rol puede borrar datos, salvo el administrador. Para que eso no dependa solo de que nunca se otorgue, los roles tienen un `DENY` explícito sobre el esquema `dbo` para las operaciones que no les corresponden. Los procedimientos y los triggers siguen escribiendo en las tablas por el encadenamiento de propiedad, que no revisa esos permisos.

```sql
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_vendedor;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_marketing;
DENY INSERT, DELETE ON SCHEMA::dbo TO rol_contador;
DENY UPDATE, DELETE ON SCHEMA::dbo TO rol_gerente;
```

`log_errores` e `historial_precios` solo los escriben `sp_log_error` y el trigger de `modelos`. Ningún rol tiene permiso para insertar ahí, así que nadie puede falsear ni borrar el registro de errores o de cambios de precio. Por la misma razón `sp_log_error` no se otorga a nadie: si un rol pudiera ejecutarla, podría llenar `log_errores` con errores inventados.

`fn_ventas_vendedor` recibe cualquier id de vendedor y devuelve sus ventas, los clientes y las comisiones. Por eso la usan solo el contador y el gerente. Si la tuviera el vendedor, podría mirar las ventas de sus compañeros.

Un `SELECT *` sobre `clientes` falla para el vendedor porque incluye `fecha_nacimiento`. Tiene que pedir las columnas que sí tiene.

== Protección de información sensible
Los datos sensibles son los personales de los clientes (`dni`, `email`, `telefono` y `fecha_nacimiento`) y el `sueldo` de los empleados.

El sueldo lo ven solo el contador, el gerente y el administrador, porque ningún otro rol tiene `SELECT` sobre `empleados`. La fecha de nacimiento no se otorga al vendedor. El DNI, el email y el teléfono sí los necesita para ubicar al cliente, pero no completos, así que se enmascaran con Dynamic Data Masking. Quien no tiene el permiso `UNMASK` ve el DNI con sus últimos tres dígitos, el email con su primera letra y el teléfono con sus últimos cuatro dígitos. El contador y el gerente tienen `UNMASK`: el contador lo necesita para contactar a quienes tienen cuotas vencidas, y el gerente ve toda la base.

```sql
ALTER TABLE clientes ALTER COLUMN dni ADD MASKED WITH (FUNCTION = 'partial(0, "xxxx", 3)');
ALTER TABLE clientes ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE clientes ALTER COLUMN telefono ADD MASKED WITH (FUNCTION = 'partial(0, "xx-xxxx-", 4)');
```

El enmascarado no es un control fuerte. Un usuario puede ir probando valores en un `WHERE` y deducir el dato completo. Por eso se usa junto con los permisos por columna y no en lugar de ellos.

*Ejemplo*
```sql
EXECUTE AS USER = 'usr_marketing';
SELECT * FROM vw_catalogo_modelos;
SELECT * FROM clientes;
REVERT;

EXECUTE AS USER = 'usr_vendedor';
SELECT id, nombre_completo, dni, email, telefono FROM clientes;
REVERT;
```

Marketing puede leer el catálogo, pero su consulta sobre `clientes` falla con el error 229 (permiso denegado). El vendedor recibe el DNI, el email y el teléfono enmascarados.

= Centralización de la lógica en la capa de datos
_Placeholder._

= Conclusiones
_Placeholder._
