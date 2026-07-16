# Trabajo Práctico 1 - Seminario de Actualización

Migración de la base de datos **Sakila** desde **MySQL** a **Microsoft SQL Server**, adaptación del esquema al español y resolución de consultas avanzadas en T-SQL.

## Integrantes

- Franco Amendolara
- (Agregar nombres de los demás integrantes)

## Objetivo

El objetivo de este trabajo fue adaptar la base de datos **Sakila**, originalmente desarrollada para MySQL, para que funcione correctamente en **SQL Server**. Además de realizar la migración del esquema y los datos, se resolvieron distintas consultas utilizando características propias de T-SQL.

## Contenido del repositorio

```
📂 TrabajoPracticoSeminario
│
├── sakila_sql_server.sql      # Script de creación de la base de datos
├── consultas_sakila.sql       # Resolución de las consultas solicitadas
├── README.md                  # Documentación del proyecto
└── (Otros archivos utilizados durante el desarrollo)
```

## Tecnologías utilizadas

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Git y GitHub

## Trabajo realizado

### 1. Migración del esquema

Se adaptó el script original de MySQL para que pudiera ejecutarse en SQL Server.

Entre los cambios realizados se encuentran:

- Conversión de tipos de datos.
- Reemplazo de `AUTO_INCREMENT` por `IDENTITY`.
- Sustitución de funciones propias de MySQL por sus equivalentes en SQL Server.
- Adaptación de claves foráneas y restricciones.
- Cambio de delimitadores y sintaxis.
- Traducción de tablas y columnas al español.

### 2. Carga de datos

Se migraron los datos de la base original respetando las relaciones entre tablas y verificando que la información quedara correctamente cargada.

### 3. Consultas desarrolladas

Se resolvieron las consultas propuestas en el trabajo práctico:

- Top 10 clientes con mayor gasto.
- Ingresos por categoría y tienda.
- Inventario no devuelto.
- Actores que participaron en al menos cinco categorías.
- Clasificación de películas según su demanda.

Las consultas fueron desarrolladas utilizando:

- JOIN
- GROUP BY
- HAVING
- Subconsultas
- Funciones de agregación
- CASE
- ORDER BY

## Dificultades encontradas

Durante la migración aparecieron algunas diferencias importantes entre MySQL y SQL Server, principalmente relacionadas con:

- Tipos de datos incompatibles.
- Sintaxis de creación de tablas.
- Restricciones de claves foráneas.
- Funciones de fecha.
- Manejo de columnas autoincrementales.

Cada uno de estos puntos fue adaptado para mantener el funcionamiento esperado de la base de datos.

## Conclusiones

Este trabajo permitió comprender las diferencias entre distintos sistemas gestores de bases de datos y la importancia de adaptar correctamente un modelo antes de migrarlo.

Además, sirvió para reforzar el uso de consultas avanzadas en SQL Server, aplicando distintos conceptos de SQL para resolver problemas de negocio de manera eficiente.

## Cómo ejecutar el proyecto

1. Abrir SQL Server Management Studio.
2. Ejecutar el archivo `sakila_sql_server.sql`.
3. Importar o ejecutar los datos correspondientes.
4. Ejecutar `consultas_sakila.sql` para probar las consultas desarrolladas.

## Repositorio

Repositorio del proyecto:

**https://github.com/Franconext/TrabajoPracticoSeminario**