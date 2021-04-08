IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'BAGUVIX')) 
BEGIN
    EXEC ('CREATE SCHEMA [BAGUVIX] AUTHORIZATION [dbo]')
END
GO

BEGIN TRANSACTION

CREATE TABLE BAGUVIX.TIPO_MOTOR (
	CODIGO DECIMAL(18,0) PRIMARY KEY
)

CREATE TABLE BAGUVIX.TIPO_AUTO (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	DESCRIPCION NVARCHAR(255)
)

CREATE TABLE BAGUVIX.TIPO_TRANSMISION (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	DESCRIPCION NVARCHAR(255)
)

CREATE TABLE BAGUVIX.TIPO_CAJA (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	DESCRIPCION NVARCHAR(255)
)

CREATE TABLE BAGUVIX.SUCURSAL (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	MAIL NVARCHAR(255),
	DIRECCION NVARCHAR(255),
	CIUDAD NVARCHAR(255),
	TELEFONO DECIMAL(18,0)
)

CREATE TABLE BAGUVIX.CLIENTE (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	DNI DECIMAL(18,0),
	APELLIDO NVARCHAR(255),
	NOMBRE NVARCHAR(255),
	DIRECCION NVARCHAR(255),
	FECHA_NACIMIENTO DATETIME2(3),
	MAIL NVARCHAR(255)
)


CREATE TABLE BAGUVIX.MODELO (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	NOMBRE NVARCHAR(255),
	POTENCIA DECIMAL(18,0),
	TIPO DECIMAL(18,0) REFERENCES BAGUVIX.TIPO_AUTO(CODIGO),
	TRANSMISION DECIMAL(18,0) REFERENCES BAGUVIX.TIPO_TRANSMISION(CODIGO),
	CAJA DECIMAL(18,0) REFERENCES BAGUVIX.TIPO_CAJA(CODIGO),
	MOTOR DECIMAL(18,0) REFERENCES BAGUVIX.TIPO_MOTOR(CODIGO)
)

CREATE TABLE BAGUVIX.FABRICANTE (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	NOMBRE NVARCHAR(255) UNIQUE
)

CREATE TABLE BAGUVIX.AUTO (
	PATENTE NVARCHAR(50) PRIMARY KEY,
	MOTOR NVARCHAR(50),
	CHASIS NVARCHAR(50),
	FECHA_ALTA DATETIME2(3),
	CANTIDAD_KILOMETROS DECIMAL(18,0),
	MODELO DECIMAL(18,0) REFERENCES BAGUVIX.MODELO(CODIGO),
	FABRICANTE DECIMAL(18,0) REFERENCES BAGUVIX.FABRICANTE(CODIGO)
)

CREATE TABLE BAGUVIX.AUTOPARTE (
	CODIGO DECIMAL(18,0) PRIMARY KEY,
	DESCRIPCION NVARCHAR(255),
	MODELO DECIMAL(18,0) REFERENCES BAGUVIX.MODELO(CODIGO),
	FABRICANTE DECIMAL(18,0) REFERENCES BAGUVIX.FABRICANTE(CODIGO)
)

CREATE TABLE BAGUVIX.TRANSACCION (
	NUMERO DECIMAL(18,0) PRIMARY KEY,
	SUCURSAL DECIMAL(18,0) REFERENCES BAGUVIX.SUCURSAL(CODIGO),
	FECHA DATE,
	CLIENTE DECIMAL(18,0) REFERENCES BAGUVIX.CLIENTE(CODIGO),
	TIPO_TRANSACCION VARCHAR(50)
)

CREATE TABLE BAGUVIX.TRANSACCION_AUTOMOVIL (
	TRANSACCION DECIMAL(18,0) PRIMARY KEY REFERENCES BAGUVIX.TRANSACCION(NUMERO),
	PRECIO NUMERIC(19, 4),
	AUTO NVARCHAR(50) REFERENCES BAGUVIX.AUTO(PATENTE)
)

CREATE TABLE BAGUVIX.TRANSACCION_AUTOPARTE (
	TRANSACCION DECIMAL(18,0) REFERENCES BAGUVIX.TRANSACCION(NUMERO),
	AUTOPARTE DECIMAL(18,0) REFERENCES BAGUVIX.AUTOPARTE(CODIGO),
	CANTIDAD DECIMAL(18,0),
	PRECIO NUMERIC(18,2),
	PRIMARY KEY(TRANSACCION, AUTOPARTE)
)
GO

CREATE PROCEDURE BAGUVIX.LLENAR_TABLAS
AS
BEGIN
INSERT INTO BAGUVIX.TIPO_MOTOR(CODIGO)
	SELECT TIPO_MOTOR_CODIGO
FROM gd_esquema.Maestra WHERE TIPO_MOTOR_CODIGO IS NOT NULL GROUP BY TIPO_MOTOR_CODIGO;

INSERT INTO BAGUVIX.TIPO_AUTO(CODIGO, DESCRIPCION) 
	SELECT TIPO_AUTO_CODIGO,
	TIPO_AUTO_DESC 
FROM gd_esquema.Maestra WHERE TIPO_AUTO_CODIGO IS NOT NULL GROUP BY TIPO_AUTO_CODIGO, TIPO_AUTO_DESC;

INSERT INTO BAGUVIX.TIPO_CAJA(CODIGO, DESCRIPCION) 
	SELECT TIPO_CAJA_CODIGO,
	TIPO_CAJA_DESC 
FROM gd_esquema.Maestra WHERE TIPO_CAJA_CODIGO IS NOT NULL GROUP BY TIPO_CAJA_CODIGO, TIPO_CAJA_DESC;

INSERT INTO BAGUVIX.TIPO_TRANSMISION(CODIGO, DESCRIPCION) 
	SELECT TIPO_TRANSMISION_CODIGO,
	TIPO_TRANSMISION_DESC 
FROM gd_esquema.Maestra WHERE TIPO_TRANSMISION_CODIGO IS NOT NULL GROUP BY TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC;

INSERT INTO BAGUVIX.MODELO(CODIGO, NOMBRE, POTENCIA, TIPO, TRANSMISION, CAJA, MOTOR) 
	SELECT 
	MODELO_CODIGO,
	MODELO_NOMBRE, 
	MODELO_POTENCIA,
	TIPO_AUTO_CODIGO,
	TIPO_TRANSMISION_CODIGO,
	TIPO_CAJA_CODIGO,
	TIPO_MOTOR_CODIGO
FROM gd_esquema.Maestra 
WHERE MODELO_CODIGO IS NOT NULL 
AND TIPO_TRANSMISION_CODIGO IS NOT NULL
GROUP BY MODELO_CODIGO, MODELO_NOMBRE, MODELO_POTENCIA, TIPO_AUTO_CODIGO, TIPO_TRANSMISION_CODIGO, TIPO_CAJA_CODIGO, TIPO_MOTOR_CODIGO;

INSERT INTO BAGUVIX.SUCURSAL (
	CODIGO,
	MAIL,
	DIRECCION,
	CIUDAD,
	TELEFONO
)
SELECT ROW_NUMBER() OVER(ORDER BY SUCURSAL_MAIL), SUCURSAL_MAIL, SUCURSAL_DIRECCION, SUCURSAL_CIUDAD, SUCURSAL_TELEFONO
FROM gd_esquema.Maestra
WHERE SUCURSAL_MAIL IS NOT NULL
GROUP BY SUCURSAL_MAIL, SUCURSAL_DIRECCION, SUCURSAL_CIUDAD, SUCURSAL_TELEFONO;

INSERT INTO BAGUVIX.CLIENTE (
	CODIGO,
	DNI,
	APELLIDO,
	NOMBRE,
	DIRECCION,
	FECHA_NACIMIENTO,
	MAIL
)
SELECT ROW_NUMBER() OVER(ORDER BY CLIENTE_DNI), CLIENTE_DNI, CLIENTE_APELLIDO, CLIENTE_NOMBRE, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL
FROM gd_esquema.Maestra
WHERE CLIENTE_DNI IS NOT NULL
GROUP BY CLIENTE_DNI, CLIENTE_APELLIDO, CLIENTE_NOMBRE, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL;

INSERT INTO BAGUVIX.CLIENTE (
	CODIGO,
	DNI,
	APELLIDO,
	NOMBRE,
	DIRECCION,
	FECHA_NACIMIENTO,
	MAIL
)
SELECT ROW_NUMBER() OVER(ORDER BY FAC_CLIENTE_DNI) + (SELECT MAX(CODIGO) FROM BAGUVIX.CLIENTE), FAC_CLIENTE_DNI, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_NOMBRE, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_FECHA_NAC, FAC_CLIENTE_MAIL
FROM gd_esquema.Maestra
WHERE FAC_CLIENTE_DNI IS NOT NULL 
GROUP BY FAC_CLIENTE_DNI, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_NOMBRE, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_FECHA_NAC, FAC_CLIENTE_MAIL;

INSERT INTO BAGUVIX.FABRICANTE (
	CODIGO,
	NOMBRE
)
SELECT 
ROW_NUMBER() OVER(ORDER BY FABRICANTE_NOMBRE),
FABRICANTE_NOMBRE
FROM gd_esquema.Maestra
WHERE FABRICANTE_NOMBRE IS NOT NULL
GROUP BY FABRICANTE_NOMBRE

INSERT INTO BAGUVIX.AUTOPARTE (
	CODIGO,
	DESCRIPCION,
	FABRICANTE,
	MODELO
)
SELECT m.AUTO_PARTE_CODIGO, m.AUTO_PARTE_DESCRIPCION, f.CODIGO, m.MODELO_CODIGO 
FROM gd_esquema.Maestra m
LEFT JOIN BAGUVIX.FABRICANTE f ON m.FABRICANTE_NOMBRE = f.NOMBRE
WHERE m.AUTO_PARTE_CODIGO IS NOT NULL
GROUP BY m.AUTO_PARTE_CODIGO, m.AUTO_PARTE_DESCRIPCION, f.CODIGO, m.MODELO_CODIGO;

INSERT INTO BAGUVIX.AUTO (
	PATENTE,
	MOTOR,
	CHASIS,
	FECHA_ALTA,
	CANTIDAD_KILOMETROS,
	MODELO,
	FABRICANTE
)
SELECT m.AUTO_PATENTE, m.AUTO_NRO_MOTOR, m.AUTO_NRO_CHASIS, m.AUTO_FECHA_ALTA, m.AUTO_CANT_KMS, m.MODELO_CODIGO, f.CODIGO
FROM gd_esquema.Maestra m
LEFT JOIN BAGUVIX.FABRICANTE f ON m.FABRICANTE_NOMBRE = f.NOMBRE
WHERE m.AUTO_PATENTE IS NOT NULL
GROUP BY m.AUTO_PATENTE, m.AUTO_NRO_MOTOR, m.AUTO_NRO_CHASIS, m.AUTO_FECHA_ALTA, m.AUTO_CANT_KMS, m.MODELO_CODIGO, f.CODIGO;

INSERT INTO BAGUVIX.TRANSACCION (
	NUMERO,
	SUCURSAL,
	FECHA,
	CLIENTE,
	TIPO_TRANSACCION
)
select m.COMPRA_NRO, s.CODIGO, m.COMPRA_FECHA, c.CODIGO, 'COMPRA'
FROM gd_esquema.Maestra m
join BAGUVIX.SUCURSAL s ON s.MAIL = m.SUCURSAL_MAIL
join BAGUVIX.CLIENTE c ON c.DNI = m.CLIENTE_DNI AND c.APELLIDO = m.CLIENTE_APELLIDO AND c.NOMBRE = m.CLIENTE_NOMBRE
where m.COMPRA_NRO IS NOT NULL
group by m.COMPRA_NRO, s.CODIGO, m.COMPRA_FECHA, c.CODIGO;

INSERT INTO BAGUVIX.TRANSACCION (
	NUMERO,
	SUCURSAL,
	FECHA,
	CLIENTE,
	TIPO_TRANSACCION
)
select m.FACTURA_NRO, s.CODIGO, m.FACTURA_FECHA, c.CODIGO, 'VENTA'
FROM gd_esquema.Maestra m
join BAGUVIX.SUCURSAL s ON s.MAIL = m.FAC_SUCURSAL_MAIL
join BAGUVIX.CLIENTE c ON c.DNI = m.FAC_CLIENTE_DNI AND c.APELLIDO = m.FAC_CLIENTE_APELLIDO AND c.NOMBRE = m.FAC_CLIENTE_NOMBRE
where m.FACTURA_NRO IS NOT NULL
group by m.FACTURA_NRO, s.CODIGO, m.FACTURA_FECHA, c.CODIGO;

INSERT INTO BAGUVIX.TRANSACCION_AUTOMOVIL (
	TRANSACCION,
	PRECIO,
	AUTO
)
SELECT m.COMPRA_NRO, m.COMPRA_PRECIO, m.AUTO_PATENTE
FROM gd_esquema.Maestra m
WHERE m.COMPRA_NRO IS NOT NULL AND M.AUTO_PATENTE IS NOT NULL
GROUP BY m.COMPRA_NRO, m.COMPRA_PRECIO, m.AUTO_PATENTE;

INSERT INTO BAGUVIX.TRANSACCION_AUTOMOVIL (
	TRANSACCION,
	PRECIO,
	AUTO
)
SELECT m.FACTURA_NRO, m.PRECIO_FACTURADO, m.AUTO_PATENTE
FROM gd_esquema.Maestra m
WHERE m.FACTURA_NRO IS NOT NULL AND M.AUTO_PATENTE IS NOT NULL
GROUP BY m.FACTURA_NRO, m.PRECIO_FACTURADO, m.AUTO_PATENTE;

INSERT INTO BAGUVIX.TRANSACCION_AUTOPARTE(
	TRANSACCION,
	PRECIO,
	CANTIDAD,
	AUTOPARTE
)
SELECT m.COMPRA_NRO, m.COMPRA_PRECIO, SUM(m.COMPRA_CANT), m.AUTO_PARTE_CODIGO
FROM gd_esquema.Maestra m
WHERE m.COMPRA_NRO IS NOT NULL AND m.COMPRA_CANT IS NOT NULL AND M.AUTO_PARTE_CODIGO IS NOT NULL
GROUP BY m.COMPRA_NRO, m.COMPRA_PRECIO, m.AUTO_PARTE_CODIGO;

INSERT INTO BAGUVIX.TRANSACCION_AUTOPARTE(
	TRANSACCION,
	PRECIO,
	CANTIDAD,
	AUTOPARTE
)
SELECT m.FACTURA_NRO, m.PRECIO_FACTURADO, SUM(m.CANT_FACTURADA), m.AUTO_PARTE_CODIGO
FROM gd_esquema.Maestra m
WHERE m.FACTURA_NRO IS NOT NULL AND m.CANT_FACTURADA IS NOT NULL AND M.AUTO_PARTE_CODIGO IS NOT NULL
GROUP BY m.FACTURA_NRO, m.PRECIO_FACTURADO, m.AUTO_PARTE_CODIGO;
END;
GO

EXEC BAGUVIX.LLENAR_TABLAS;
GO

COMMIT