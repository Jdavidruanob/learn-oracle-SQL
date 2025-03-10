OPTIONS (SKIP=1)
LOAD DATA
    INFILE 'categorias.csv' "str '\r\n'"
    APPEND INTO TABLE categoria
    FIELDS TERMINATED BY ','
    TRAILING NULLCOLS
( cod_categoria, 
  nombre CHAR(15) )