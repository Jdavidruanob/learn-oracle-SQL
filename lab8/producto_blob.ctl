OPTIONS (SKIP=1)
LOAD DATA
    INFILE 'productos_img.csv' "str '\r\n'"
    APPEND INTO TABLE producto
    FIELDS TERMINATED BY ';'
    TRAILING NULLCOLS
(
  id_Producto        INTEGER EXTERNAL,
  descripcion        CHAR(100),
  imagen             LOBFILE(img) TERMINATED BY EOF,
  img                FILLER CHAR(255),
  largo              DECIMAL EXTERNAL,
  alto               DECIMAL EXTERNAL,
  ancho              DECIMAL EXTERNAL,
  cantidad_inv       INTEGER EXTERNAL,
  precio             DECIMAL EXTERNAL,
  cod_categoria      CHAR(50)
)
