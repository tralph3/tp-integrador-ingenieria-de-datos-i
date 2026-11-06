-- sp_aumentar_precios_marca: aumenta en un porcentaje el precio de lista de
-- todos los modelos de una marca. El cursor llama a sp_actualizar_precio_modelo
-- una vez por modelo, asi se reutilizan sus validaciones y su registro de errores.
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
GO

-- sp_liquidar_comisiones: liquida las comisiones pendientes con la fecha de hoy.
-- Cada comision va en su propia transaccion: si una se rechaza, se guarda el
-- error en log_errores y el cursor sigue con la siguiente.
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
GO
