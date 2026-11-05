GO -- iniciar nuevo lote

-- fn_saldo_pendiente: monto que todavia debe el cliente de una venta, es decir
-- la suma de las cuotas sin fecha de pago. Si la venta no tiene cuotas (no es a
-- credito) o ya estan todas pagas, devuelve 0.
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
GO


-- fn_service_vigente: indica si una fecha cae dentro del plazo de service de
-- una venta, contado desde la fecha de venta durante meses_service meses.
-- Devuelve 1 si esta vigente, 0 si no, y NULL si la venta no existe.
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
GO


-- fn_comision: comision que le corresponde al vendedor por una venta, el 2% del
-- precio. Los montos estan en centavos, por eso se multiplica antes de dividir.
CREATE OR ALTER FUNCTION fn_comision (@precio BIGINT)
RETURNS BIGINT
AS
BEGIN
       RETURN @precio * 2 / 100;
END;
GO


-- fn_formatear_monto: pasa un monto en centavos a texto legible, por ejemplo
-- 6500000000 queda '$ 65.000.000,00'.
CREATE OR ALTER FUNCTION fn_formatear_monto (@centavos BIGINT)
RETURNS VARCHAR(40)
AS
BEGIN
       RETURN '$ ' + FORMAT(@centavos / 100, 'N0', 'es-AR')
              + ',' + RIGHT('0' + CAST(@centavos % 100 AS VARCHAR(2)), 2);
END;
GO


-- fn_ventas_vendedor: ventas de un vendedor entre dos fechas, con el cliente, el
-- modelo vendido, el precio y la comision generada.
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
GO
