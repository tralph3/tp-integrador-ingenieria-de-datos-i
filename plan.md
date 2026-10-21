# Problematica
- Contexto del sistema
   La concesionaria fulanito actualmente maneja sus ventas por
   WhatsApp, y no tiene un registro centralizado. Mantiene una libreta
   con el stock de sus productos y no tiene un vistazo general del
   estado de sus operaciones.

- Objetivo de la base de datos
  La base de datos debe consolidar toda la informacion para ser
  facilmente procesada y agilizar el desarrollo de informes.

- Actores involucrados
  Empleados, clientes, sucursales, plataformas.

- Informacion que se necesita almacenar
  Stock actual, registro de ventas, estado de empleados, proveedores.

- Reglas de negocio
  - Al realizar una venta, el cliente debe ser mayor de 18 anios.
  - Todas las ventas deben estar registradas a un vendedor.
  - El vehiculo debe registrarse al nombre del cliente en el RUNA.

- Procesos principales
  - Venta
  - Ingesta de stock por proveedores
  - Service de auto al poco tiempo de la venta.

- Restricciones
  - Solo los vendedores pueden realizar ventas.
  - No se pueden realizar ventas de un vehiculo que la sucursal no
    tenga en stock.
  - No se puede realizar service gratuito al expirar el tiempo de
    gracia.

- Relaciones existentes entre los distintos elementos del dominio



# Tablas

- Autos
  - Marca
  - Precio

- Sucursales

- Clientes

- Proveedores

- Marcas

- Empleados

- Ventas
  - Plataforma

- Stock
