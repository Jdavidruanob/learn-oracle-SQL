--Primera parte
SELECT ora_database_name FROM dual;
SELECT user FROM dual;
SELECT current_date FROM dual;
SELECT * FROM v$version;
SELECT * FROM ALL_USERS;
SELECT * FROM USER_USERS;

SELECT owner, table_name, tablespace_name, num_rows, blocks FROM ALL_TABLES;
SELECT * FROM USER_ROLE_PRIVS;

CREATE TABLE pais (
    codPais NUMBER(3) PRIMARY KEY,
    nombrePais VARCHAR2(15) NOT NULL
);

GRANT INSERT, UPDATE, DELETE, SELECT ON pais TO DATABASE19;
INSERT INTO DATABASE19.pais VALUES (169, "Colombia" );
COMMIT;
SELECT * FROM DATABASE19.Pais;
SELECT * FROM Pais;

--Segunda Parte

CREATE TABLE pais (
    cod_pais NUMBER(3) PRIMARY KEY,
    nombre_pais VARCHAR2(15) NOT NULL
);

CREATE TABLE ciudad (
    cod_ciudad NUMBER(3) PRIMARY KEY,
    nombre_ciudad VARCHAR2(15) NOT NULL,
    cod_pais NUMBER(3),
    FOREIGN KEY (cod_pais) REFERENCES pais(cod_pais)
);

CREATE TABLE usuario (
    cod_usuario NUMBER(5) PRIMARY KEY,
    nombre_usuario VARCHAR2(15) UNIQUE NOT NULL,
    nombres VARCHAR2(15),
    apellidos VARCHAR2(15),
    correo VARCHAR2(15) NOT NULL,
    contrasena VARCHAR2(8) NOT NULL,
    direccion VARCHAR2(15),
    ciudad NUMBER(3),
    FOREIGN KEY (ciudad) REFERENCES ciudad(cod_ciudad)
);

CREATE TABLE categoria (
    cod_categoria NUMBER(2) PRIMARY KEY,
    nombre VARCHAR2(15) NOT NULL
);

CREATE TABLE producto (
    id_producto NUMBER(5) PRIMARY KEY,
    descripcion VARCHAR2(50),
    imagen BLOB,
    largo NUMBER(2) CHECK (largo BETWEEN 1 AND 100),
    alto NUMBER(2) CHECK (alto BETWEEN 1 AND 100),
    ancho NUMBER(2) CHECK (ancho BETWEEN 1 AND 100),
    cantidad_inv NUMBER CHECK (cantidad_inv > 0),
    precio NUMBER(8,2) CHECK (precio > 1000),
    cod_categoria NUMBER(2),
    FOREIGN KEY (cod_categoria) REFERENCES categoria(cod_categoria)
);

CREATE TABLE tema (
    cod_tema NUMBER(2) PRIMARY KEY,
    nombre VARCHAR2(15) NOT NULL
);

CREATE TABLE tema_producto (
    cod_tema NUMBER(2),
    cod_producto NUMBER(5),
    PRIMARY KEY (cod_tema, cod_producto),
    FOREIGN KEY (cod_tema) REFERENCES tema(cod_tema),
    FOREIGN KEY (cod_producto) REFERENCES producto(id_producto)
);

CREATE TABLE compra (
    cod_usuario NUMBER(5),
    nro_compra NUMBER(5),
    fecha DATE NOT NULL,
    dir_entrega VARCHAR2(15),
    ciudad_entrega NUMBER(3),
    PRIMARY KEY (cod_usuario, nro_compra),
    FOREIGN KEY (cod_usuario) REFERENCES usuario(cod_usuario),
    FOREIGN KEY (ciudad_entrega) REFERENCES ciudad(cod_ciudad)
);

CREATE TABLE carrito_compras (
    cod_usuario NUMBER(5),
    cod_producto NUMBER(5),
    cantidad NUMBER(3) DEFAULT 1,
    fecha_ingreso DATE DEFAULT SYSDATE,
    PRIMARY KEY (cod_usuario, cod_producto),
    FOREIGN KEY (cod_usuario) REFERENCES usuario(cod_usuario),
    FOREIGN KEY (cod_producto) REFERENCES producto(id_producto)
);

CREATE TABLE eliminados (
    cod_usuario NUMBER(5),
    cod_producto NUMBER(5),
    fecha_hora TIMESTAMP,
    cantidad NUMBER(3) DEFAULT 0,
    PRIMARY KEY (cod_usuario, cod_producto, fecha_hora),
    FOREIGN KEY (cod_usuario) REFERENCES usuario(cod_usuario),
    FOREIGN KEY (cod_producto) REFERENCES producto(id_producto)
);

CREATE TABLE prod_compra (
    cod_usuario NUMBER(5),
    nro_compra NUMBER(5),
    cod_producto NUMBER(5),
    precio_unitario NUMBER(8,2) NOT NULL,
    cantidad NUMBER(3) DEFAULT 1,
    PRIMARY KEY (cod_usuario, nro_compra, cod_producto),
    FOREIGN KEY (cod_usuario, nro_compra) REFERENCES compra(cod_usuario, nro_compra),
    FOREIGN KEY (cod_producto) REFERENCES producto(id_producto)
);
