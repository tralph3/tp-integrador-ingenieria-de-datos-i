GO -- iniciar nuevo lote

-- sp_log_error: guarda en log_errores el error del CATCH que la llama.
CREATE OR ALTER PROCEDURE sp_log_error
       @procedimiento VARCHAR(100)
AS
BEGIN
       SET NOCOUNT ON;
       INSERT INTO log_errores (procedimiento, numero_error, mensaje)
       VALUES (@procedimiento, ERROR_NUMBER(), LEFT(ERROR_MESSAGE(), 2048));
END;
GO


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
              IF @estado != 'disponible'
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
GO