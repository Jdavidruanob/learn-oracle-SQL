# Errores en la carga de datos con SQL*Loader

Durante la carga de datos en la tabla **PROD_COMPRA** mediante **SQL*Loader**, se encontraron algunos errores que impidieron que ciertos registros fueran insertados correctamente.

En total, se intentaron cargar **1383 registros**, de los cuales **1360** se insertaron con éxito. Sin embargo, **23 registros** fueron rechazados debido a errores en los datos.

## Principales errores detectados:

1. **Error de formato en los datos**  
   - El primer registro fue rechazado porque el campo **COD_USUARIO** contenía un valor de texto (`'usuario'`) en lugar de un número.

2. **Duplicidad de datos**  
   - Los otros **22 registros** fueron rechazados porque ya existía un registro con la misma combinación de **COD_USUARIO, NRO_COMPRA y COD_PRODUCTO** en la base de datos.  
   - Esto violó la **restricción de unicidad** definida en la tabla.

## Recomendaciones para corregir los errores:

- **Revisar el archivo de datos** para asegurarse de que los valores sean del tipo correcto.  
- **Verificar la base de datos** y los datos que se están cargando para evitar registros duplicados.  
- Si los registros duplicados son válidos, **considerar modificar la estructura de la tabla** o el método de carga de datos para permitir su inserción si es necesario.  
