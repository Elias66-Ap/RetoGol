CREATE DATABASE RETOGOL;
USE RETOGOL;

CREATE TABLE DEPARTAMENTO (
  id VARCHAR(2) NOT NULL PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL
);

CREATE TABLE PROVINCIA (
  id VARCHAR(4) NOT NULL PRIMARY KEY,
  nombre VARCHAR(45) NOT NULL,
  id_departamento VARCHAR(2) NOT NULL,
  FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO(id)
);

CREATE TABLE DISTRITO (
  id VARCHAR(6) NOT NULL PRIMARY KEY,
  nombre VARCHAR(45) DEFAULT NULL,
  id_provincia VARCHAR(4) NOT NULL,
  id_departamento VARCHAR(2) NOT NULL,
  FOREIGN KEY (id_provincia) REFERENCES PROVINCIA(id),
  FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO(id)
);

CREATE TABLE USUARIO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    TELEFONO VARCHAR(20) NOT NULL UNIQUE,
    ESTATURA VARCHAR(5) NOT NULL,
    PESO VARCHAR(5) NOT NULL,
    PASSWORDD VARCHAR(255) NOT NULL, 
    ID_DEPARTAMENTO VARCHAR(9) NOT NULL,
    ID_PROVINCIA VARCHAR(9) NOT NULL,
    ID_DISTRITO VARCHAR(9) NOT NULL,
    ESTADO CHAR(1) DEFAULT '1',
    FOREIGN KEY (ID_DEPARTAMENTO) REFERENCES DEPARTAMENTO(ID),
    FOREIGN KEY (ID_PROVINCIA) REFERENCES PROVINCIA(ID),
    FOREIGN KEY (ID_DISTRITO) REFERENCES DISTRITO(ID)
);

CREATE TABLE EQUIPO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_USUARIO INT NOT NULL, 
    NOMBRE VARCHAR(300) NOT NULL,
    ESCUDO VARCHAR(300),
    APODO VARCHAR(100),
    CANTIDAD INT NOT NULL,
    CALIFICACION INT NOT NULL,
    ID_DEPARTAMENTO VARCHAR(9) NOT NULL,
    ID_PROVINCIA VARCHAR(9) NOT NULL,
    ID_DISTRITO VARCHAR(9) NOT NULL,
    ESTADO CHAR(1) DEFAULT '1',
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(ID),
    FOREIGN KEY (ID_DEPARTAMENTO) REFERENCES DEPARTAMENTO(ID),
    FOREIGN KEY (ID_PROVINCIA) REFERENCES PROVINCIA(ID),
    FOREIGN KEY (ID_DISTRITO) REFERENCES DISTRITO(ID)
);

CREATE TABLE RETO(
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_USUARIO INT NOT NULL, 
    NOMBRE VARCHAR(100) NOT NULL,
    CANTIDAD VARCHAR(5) NOT NULL,
    LUGAR VARCHAR(100) NOT NULL,
    FECHA_HORA DATETIME NOT NULL,
    ID_DEPARTAMENTO VARCHAR(9) NOT NULL,
    ID_PROVINCIA VARCHAR(9) NOT NULL,
    ID_DISTRITO VARCHAR(9) NOT NULL,
    NUMERO_CONTACTO VARCHAR(20) NOT NULL, 
    ESTADO CHAR(1) DEFAULT '1',
    FECHA_CREACION DATETIME NOT NULL,
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIO(ID),
    FOREIGN KEY (ID_DEPARTAMENTO) REFERENCES DEPARTAMENTO(ID),
    FOREIGN KEY (ID_PROVINCIA) REFERENCES PROVINCIA(ID),
    FOREIGN KEY (ID_DISTRITO) REFERENCES DISTRITO(ID)
);

--Funciones:

DELIMITER $$

CREATE PROCEDURE RegistrarUsuario (
    IN p_nombre VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_estatura VARCHAR(5),
    IN p_peso VARCHAR(5),
    IN p_passwordd VARCHAR(255),
    IN p_id_departamento VARCHAR(2),
    IN p_id_provincia VARCHAR(4),
    IN p_id_distrito VARCHAR(6)
)
BEGIN
    -- Verificar si ya existe el teléfono
    IF EXISTS (SELECT 1 FROM USUARIO WHERE TELEFONO = p_telefono) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El número de teléfono ya está registrado.';
    ELSE
        INSERT INTO USUARIO (
            NOMBRE, TELEFONO, ESTATURA, PESO, PASSWORDD, 
            ID_DEPARTAMENTO, ID_PROVINCIA, ID_DISTRITO
        ) VALUES (
            p_nombre, p_telefono, p_estatura, p_peso, p_passwordd, 
            p_id_departamento, p_id_provincia, p_id_distrito
        );
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE LoginUsuario (
    IN p_telefono VARCHAR(20),
    IN p_passwordd VARCHAR(255)
)
BEGIN
    DECLARE v_id INT;

    SELECT ID 
    INTO v_id
    FROM USUARIO
    WHERE TELEFONO = p_telefono 
      AND PASSWORDD = p_passwordd
      AND ESTADO = '1'
    LIMIT 1;

    IF v_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Credenciales inválidas o usuario inactivo.';
    ELSE
        SELECT * FROM USUARIO WHERE ID = v_id;
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE CrearEquipo (
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(300),
    IN p_escudo VARCHAR(300),
    IN p_apodo VARCHAR(100),
    IN p_cantidad INT,
    IN p_calificacion INT,
    IN p_id_departamento VARCHAR(2),
    IN p_id_provincia VARCHAR(4),
    IN p_id_distrito VARCHAR(6)
)
BEGIN
    INSERT INTO EQUIPO (
        ID_USUARIO, NOMBRE, ESCUDO, APODO, CANTIDAD, CALIFICACION, 
        ID_DEPARTAMENTO, ID_PROVINCIA, ID_DISTRITO
    ) VALUES (
        p_id_usuario, p_nombre, p_escudo, p_apodo, p_cantidad, p_calificacion,
        p_id_departamento, p_id_provincia, p_id_distrito
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ListarEquiposPorUsuario (
    IN p_id_usuario INT
)
BEGIN
    SELECT * 
    FROM EQUIPO
    WHERE ID_USUARIO = p_id_usuario
      AND ESTADO = '1';
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE EditarEquipo (
    IN p_id INT,
    IN p_nombre VARCHAR(300),
    IN p_escudo VARCHAR(300),
    IN p_apodo VARCHAR(100),
    IN p_cantidad INT,
    IN p_calificacion INT
)
BEGIN
    UPDATE EQUIPO
    SET NOMBRE = p_nombre,
        ESCUDO = p_escudo,
        APODO = p_apodo,
        CANTIDAD = p_cantidad,
        CALIFICACION = p_calificacion
    WHERE ID = p_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE EliminarEquipo (
    IN p_id INT
)
BEGIN
    UPDATE EQUIPO
    SET ESTADO = '0'
    WHERE ID = p_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE CrearReto (
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(100),
    IN p_cantidad VARCHAR(5),
    IN p_lugar VARCHAR(100),
    IN p_fecha_hora DATETIME,
    IN p_id_departamento VARCHAR(2),
    IN p_id_provincia VARCHAR(4),
    IN p_id_distrito VARCHAR(6),
    IN p_numero_contacto VARCHAR(20)
)
BEGIN
    INSERT INTO RETO (
        ID_USUARIO, NOMBRE, CANTIDAD, LUGAR, FECHA_HORA, 
        ID_DEPARTAMENTO, ID_PROVINCIA, ID_DISTRITO, NUMERO_CONTACTO, 
        FECHA_CREACION
    ) VALUES (
        p_id_usuario, p_nombre, p_cantidad, p_lugar, p_fecha_hora,
        p_id_departamento, p_id_provincia, p_id_distrito, p_numero_contacto,
        NOW()
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ListarRetosPorUbicacion (
    IN p_id_departamento VARCHAR(2),
    IN p_id_provincia VARCHAR(4),
    IN p_id_distrito VARCHAR(6)
)
BEGIN
    SELECT R.*, U.NOMBRE AS USUARIO, U.TELEFONO 
    FROM RETO R
    INNER JOIN USUARIO U ON U.ID = R.ID_USUARIO
    WHERE R.ID_DEPARTAMENTO = p_id_departamento
      AND R.ID_PROVINCIA = p_id_provincia
      AND R.ID_DISTRITO = p_id_distrito
      AND R.ESTADO = '1';
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE EliminarReto (
    IN p_id INT
)
BEGIN
    UPDATE RETO
    SET ESTADO = '0'
    WHERE ID = p_id;
END $$

DELIMITER ;




