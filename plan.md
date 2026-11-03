
### Contexto del sistema
   La concesionaria "LeCar", situada en Vicente López. Posee un alto volúmen de clientes, entre consultas, visitas presenciales, tasaciones y demás. Actualmente maneja sus ventas por WhatsApp, y no tiene un registro centralizado. Mantiene una planilla y un archivo .xls
   con el stock de sus productos y no tiene un vistazo general del estado de sus operaciones.


### Objetivo de la base de datos
  La base de datos debe consolidar toda la informacion para ser
  facilmente procesada y agilizar el desarrollo de informes, reportes de ventas y stock y validez de service para vehículos.


### Actores involucrados
  Empleados, clientes, sucursales, talleres, proveedores, autos.


### Informacion que se necesita almacenar
  Stock actual, registro de ventas, estado de empleados, proveedores, talleres disponibles para service, estado de service, vehículos disponibles en sucursal (stock).


### Reglas de negocio
  - Al realizar una venta, el cliente debe ser mayor de 18 anios.
  - Todas las ventas deben estar registradas a un vendedor.
  - El vehiculo debe registrarse al nombre del cliente en el RUNA.
  - Al momento de realizar el service al auto, la fecha debe estar dentro del plazo de vigencia.


### Procesos principales
  - Venta.
  - Entrega de vehículos (stock) de proveedores.
  - Determinación de rango de validez de service vehicular.
  - Validez de service vehicular.


### Restricciones
  - El sistema no permitirá que personas que no sean vendedores registren ventas.
  - El sistema no permitirá realizar ventas de un vehiculo que la sucursal no tenga disponible.
  - El sistema no realizará transferencias bancarias.
  - El sistema no almacenará cuentas bancarias ni credenciales bancarias de clientes.
  - El sistema no gestionará la distribución de vehículos por parte de los proveedores.
  - El sistema no gestionará la contratación ni renovación de pólizas de seguros.
  - El sistema no gestionará la logística de entrega de los vehículos.
  

### Relaciones existentes entre los distintos elementos del dominio



# Tablas

Clientes
- id
- nombre_completo
- dni

Sucursales
- id
- direccion

Empleados
- id
- nombre_completo
- dni
- id_sucursal
- tipo

Marcas
- id
- nombre
- origen
- fecha_fundacion

Autos
- id
- modelo
- fecha_lanzamiento
- id_marca
- precio

Ventas
- id
- id_cliente
- id_vendedor
- id_auto
- fecha
- precio
- medio_pago
- meses_service

Stock
- id_sucursal
- id_auto
- cantidad

Proveedores
- id
- nombre
- telefono
- direccion
- cuit

Proveedores_entregas
- id_proveedor
- id_auto
- id_sucursal

Talleres
- id
- direccion

Service
- id
- id_venta
- id_taller
- fecha
