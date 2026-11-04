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
GO

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
GO
