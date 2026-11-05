SET QUOTED_IDENTIFIER ON;
GO -- iniciar nuevo lote

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
GO


-- trg_ventas_validar: reglas que debe cumplir una venta y cambio de estado del
-- vehiculo. El cliente debe ser mayor de 18 a la fecha de la venta, el vendedor
-- debe ser un empleado activo de tipo vendedor y el vehiculo debe estar
-- disponible. Si todo es valido, el vehiculo pasa a 'vendido'.
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
GO

-- Tiene que correr antes que los otros triggers de ventas: si la venta es
-- invalida, ninguno de los demas debe llegar a ejecutarse.
EXEC sp_settriggerorder @triggername = 'trg_ventas_validar', @order = 'First', @stmttype = 'INSERT';
GO


-- trg_ventas_comision: genera la comision de cada venta nueva, equivalente al
-- 2% del precio de venta.
CREATE OR ALTER TRIGGER trg_ventas_comision
ON ventas
AFTER INSERT
AS
BEGIN
       INSERT INTO comisiones (id_venta, monto)
       SELECT i.id, i.precio * (2 / 100)
       FROM inserted i;
END;
GO


-- trg_modelos_historial_precios: guarda en historial_precios cada cambio del
-- precio de lista de un modelo, con el precio anterior y el nuevo.
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
GO


-- trg_service_vigencia: el service gratuito solo se puede registrar dentro de
-- los meses de service pactados en la venta, contados desde la fecha de venta.
CREATE OR ALTER TRIGGER trg_service_vigencia
ON service
AFTER INSERT, UPDATE
AS
BEGIN
       IF EXISTS (
              SELECT 1
              FROM inserted i
              JOIN ventas v ON v.id = i.id_venta
              WHERE i.fecha < v.fecha
                 OR i.fecha > DATEADD(MONTH, v.meses_service, v.fecha)
       )
       BEGIN
              ROLLBACK TRANSACTION;
              THROW 50006, 'La fecha del service esta fuera del plazo de vigencia.', 1;
       END
END;
GO


-- trg_registro_runa_cliente: el vehiculo se registra en el RUNA a nombre de
-- quien lo compro, por lo que tiene que existir una venta del vehiculo y el
-- cliente del registro debe coincidir con el de esa venta.
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
GO
