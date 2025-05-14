--------------------------------------------------------------------------------
-- BLOQUE ANÓNIMO (Ejemplo básico)
--------------------------------------------------------------------------------
DECLARE
    ccCliente NUMBER(10) := 256;
    descuento NUMBER(10,2);
BEGIN
    SELECT SUM(precio*cantidad) * 0.1 INTO descuento
    FROM   compra
    WHERE cc = ccCliente
    AND    fecha BETWEEN '01/07/2020' AND '30/09/2020';

    INSERT INTO descuentos VALUES (ccCliente, descuento);
END;
/

--------------------------------------------------------------------------------
-- PROCEDIMIENTO ALMACENADO (Bloque Nombrado)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE dctoP(ccCliente NUMBER)
AS
    Descuento NUMBER(10);
BEGIN
    SELECT SUM(precio*cantidad) * 0.1 INTO descuento
    FROM   compra
    WHERE cc = ccCliente
    AND fecha BETWEEN '01/07/2020' AND '30/09/2020';

    IF descuento IS NOT NULL THEN
        INSERT INTO descuentos VALUES (ccCliente, descuento);
    END IF;
END;
/

-- Ejecución del procedimiento
BEGIN
    dctoP(256);
END;
/

--------------------------------------------------------------------------------
-- FUNCIÓN ALMACENADA (Bloque Nombrado)
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dctoF(ccCliente NUMBER)
RETURN NUMBER
AS
    Descuento NUMBER(10,2);
BEGIN
    SELECT SUM(precio*cantidad) * 0.1 INTO descuento
    FROM   compra
    WHERE cc = ccCliente
    AND fecha BETWEEN '01/07/2020' AND '30/09/2020';

    RETURN descuento;
END;
/

-- Ejemplos de uso de la función
SELECT dctoF(256) FROM DUAL;

SELECT  usuario.*, dctoF(256) FROM usuario WHERE codusuario = 1;

DECLARE
    dcto number(5,1);
BEGIN
    dcto := dctoF(256);
    -- ... aquí iría más código que usa la variable dcto
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(dctoF(256));
END;
/

--------------------------------------------------------------------------------
-- CURSORES IMPLÍCITOS (Usando FOR en un procedimiento)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE clientes
AS
BEGIN
    FOR pers IN ( SELECT nombre, direccion
                  FROM cliente
                  WHERE codCiud = 7601 )
    LOOP
        DBMS_OUTPUT.PUT_LINE
            (pers.nombre||' '||pers.direccion);
    END LOOP;
END;
/

--------------------------------------------------------------------------------
-- CURSORES IMPLÍCITOS (Usando FOR en una función con %ROWTYPE)
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION clientesCorreo
RETURN VARCHAR AS
    rCl cliente%ROWTYPE;
    correos VARCHAR(500) := '';
BEGIN
    FOR rCl IN  (SELECT cliente.*
                  FROM cliente NATURAL JOIN ciudad
                  WHERE ciudad.nombre = 'Cali'
                  ORDER BY cliente.nombre )
    LOOP
            correos := correos || rCl.email || ' ; ' ;
    END LOOP;
    RETURN correos;
END;
/

--------------------------------------------------------------------------------
-- MANEJO DE EXCEPCIONES (Excepción del sistema nombrada: ZERO_DIVIDE)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pLiquidez
AS
    liquidez NUMBER(10,2);
BEGIN
    SELECT activosCtes / pasivosCtes INTO liquidez
    FROM Balance;
    INSERT INTO resumen VALUES ('Liquidez', liquidez);
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        INSERT INTO resumen VALUES ('Liquidez', NULL);
END;
/

--------------------------------------------------------------------------------
-- MANEJO DE EXCEPCIONES (Excepción nombrada definida por el usuario)
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER insEmpleado
BEFORE INSERT OR UPDATE ON EMPLEADO FOR EACH ROW
DECLARE
    invalidEmail  EXCEPTION;
BEGIN
    IF INSTR(:NEW.email, '@') = 0 THEN
        RAISE invalidEmail;
    END IF;
EXCEPTION
    WHEN invalidEmail THEN
        RAISE_APPLICATION_ERROR (-20000, 'Dirección de correo con formato incorrecto');
END;
/

--------------------------------------------------------------------------------
-- MANEJO DE EXCEPCIONES (Excepción del sistema no nombrada capturada con OTHERS)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pLiquidez
AS
    liquidez NUMBER(2);
BEGIN
    SELECT activosCtes / pasivosCtes INTO liquidez
    FROM Balance;
    INSERT INTO resumen VALUES ('Liquidez', liquidez);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000, 'Error en el calculo');
END;
/

--------------------------------------------------------------------------------
-- MANEJO DE EXCEPCIONES (Nombrar una excepción del sistema no nombrada)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pLiquidez
AS
    Number_over EXCEPTION;
    PRAGMA EXCEPTION_INIT (Number_over, -6502);
    liquidez NUMBER(2);
BEGIN
    SELECT activosCtes / pasivosCtes INTO liquidez
    FROM Balance;
    INSERT INTO resumen VALUES ('Liquidez', liquidez);
EXCEPTION
    WHEN Number_over THEN
        dbms_output.put_line('Error: Valor supera el máximo permitido');
END;
/