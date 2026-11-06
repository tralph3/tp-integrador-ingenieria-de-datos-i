-- Seguridad: usuarios, roles, permisos y enmascarado de datos sensibles.
-- Se ejecuta despues de crear las tablas, vistas, funciones y procedimientos,
-- porque los permisos hacen referencia a esos objetos.

-- Usuarios (uno por rol). Se crean sin login para que el script no necesite
-- permisos de servidor; se prueban con EXECUTE AS USER.
IF DATABASE_PRINCIPAL_ID('usr_vendedor') IS NULL CREATE USER usr_vendedor WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID('usr_contador') IS NULL CREATE USER usr_contador WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID('usr_gerente') IS NULL CREATE USER usr_gerente WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID('usr_marketing') IS NULL CREATE USER usr_marketing WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID('usr_admin') IS NULL CREATE USER usr_admin WITHOUT LOGIN;

-- Roles
IF DATABASE_PRINCIPAL_ID('rol_vendedor') IS NULL CREATE ROLE rol_vendedor;
IF DATABASE_PRINCIPAL_ID('rol_contador') IS NULL CREATE ROLE rol_contador;
IF DATABASE_PRINCIPAL_ID('rol_gerente') IS NULL CREATE ROLE rol_gerente;
IF DATABASE_PRINCIPAL_ID('rol_marketing') IS NULL CREATE ROLE rol_marketing;
IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL CREATE ROLE rol_administrador;

ALTER ROLE rol_vendedor ADD MEMBER usr_vendedor;
ALTER ROLE rol_contador ADD MEMBER usr_contador;
ALTER ROLE rol_gerente ADD MEMBER usr_gerente;
ALTER ROLE rol_marketing ADD MEMBER usr_marketing;
ALTER ROLE rol_administrador ADD MEMBER usr_admin;
ALTER ROLE db_owner ADD MEMBER rol_administrador;

-- Permisos: vendedor
GRANT SELECT ON vw_stock_disponible TO rol_vendedor;
GRANT SELECT ON vw_catalogo_modelos TO rol_vendedor;
GRANT SELECT ON clientes (id, nombre_completo, dni, email, telefono) TO rol_vendedor;
GRANT EXECUTE ON sp_registrar_cliente TO rol_vendedor;
GRANT EXECUTE ON sp_registrar_venta TO rol_vendedor;
GRANT EXECUTE ON sp_generar_cuotas TO rol_vendedor;
GRANT EXECUTE ON fn_formatear_monto TO rol_vendedor;

-- Permisos: contador
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

-- Permisos: gerente
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

-- Permisos: marketing
GRANT SELECT ON vw_catalogo_modelos TO rol_marketing;

-- Restricciones
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_vendedor;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_marketing;
DENY INSERT, DELETE ON SCHEMA::dbo TO rol_contador;
DENY UPDATE, DELETE ON SCHEMA::dbo TO rol_gerente;

-- Enmascarado de datos sensibles de clientes (lo ve completo quien tiene UNMASK)
ALTER TABLE clientes ALTER COLUMN dni ADD MASKED WITH (FUNCTION = 'partial(0, "xxxx", 3)');
ALTER TABLE clientes ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE clientes ALTER COLUMN telefono ADD MASKED WITH (FUNCTION = 'partial(0, "xx-xxxx-", 4)');
