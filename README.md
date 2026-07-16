# 📚 Trabajo Práctico 1: Migración y Consultas Avanzadas en SQL Server

## 🏫 Información Institucional
* **Institución:** Instituto Superior Nuestra Señora de Luján del Buen Viaje
* **Materia:** Seminario de Actualización - 2026
* **Docente:** Jorge Insfran
* **Fecha de Entrega:** 16/07/2026
* **Integrantes:** Franco Amendolara

---

## 🎯 1. Objetivos del Trabajo Práctico
* Comprender las diferencias estructurales y operativas entre los motores relacionales MySQL y Microsoft SQL Server (T-SQL).
* Desarrollar habilidades de migración de datos, transformando de manera estricta tipos de datos, restricciones e integridad referencial.
* Resolver problemas de negocio mediante consultas SQL relacionales avanzadas sin recurrir al uso de bucles imperativos o cursores.

---

## 🛠️ 2. Matriz de Cambios y Justificación Técnica (MySQL a T-SQL)

Durante el diseño del script DDL se realizaron adaptaciones clave para garantizar la compatibilidad nativa con Microsoft SQL Server:

| Elemento / Tipo en MySQL | Modificación en SQL Server (T-SQL) | Justificación de Ingeniería de Datos |
| :--- | :--- | :--- |
| **Idioma General** (`customer`, `film`, etc.) | Traducción estricta al español (e.g., `cliente`, `pelicula`). | Cumplimiento de los requerimientos pedagógicos y estandarización del negocio. |
| **Cláusula `AUTO_INCREMENT`** | Atributo `IDENTITY(1,1)`. | Propiedad nativa de SQL Server para autogenerar secuencias numéricas correlativas en PKs. |
| **Delimitadores** (\`backticks\`) | Corchetes angulares `[objeto]`. | Estándar de sintaxis en T-SQL para encapsular identificadores y evitar conflictos con palabras reservadas. |
| **Texto Largo** (`TEXT`) | `VARCHAR(MAX)`. | El tipo `TEXT` está obsoleto (*deprecated*) en SQL Server. `VARCHAR(MAX)` administra cadenas dinámicas de hasta 2 GB con mayor rendimiento. |
| **Datos Binarios** (`BLOB`) | `VARBINARY(MAX)`. | Almacenamiento optimizado para flujos multimedia, utilizado en la foto de la tabla `empleado`. |
| **Variables Lógicas** (`BOOLEAN / TINYINT(1)`) | Tipo de dato lógico `BIT`. | SQL Server no posee un tipo booleano puro; `BIT` procesa valores lógicos mediante bits numéricos `0` (Falso) o `1` (Verdadero). |
| **Listas de Selección** (`ENUM`) | `VARCHAR` con restricción `CHECK`. | Al carecer del tipo `ENUM`, se aplicaron restricciones de control (`CHECK`) para blindar la integridad del campo `clasificacion` ('G', 'PG', 'R', etc.). |
| **Funciones de Fecha** (`NOW()`) | Función escalar `GETDATE()`. | Sincronización directa con el huso horario y reloj del servidor de base de datos. |

---

## 🧠 3. Resolución de Conflictos Estructurales Complejos

### A. Dependencia Cíclica (Tienda vs. Empleado)
* **Conflicto:** La tabla `tienda` requiere conocer el ID del empleado gerente (`id_gerente`), mientras que la tabla `empleado` requiere la clave de la `tienda_id` donde ejerce funciones. Ninguna de las dos tablas se podía crear primero de manera lineal debido a la restricción de clave foránea cruzada.
* **Solución:** Se construyó la tabla `tienda` omitiendo inicialmente la FK del gerente. Posteriormente se declaró la estructura de `empleado` referenciando a la tienda. Al final del bloque, se aplicó un comando estructural `ALTER TABLE [tienda] ADD CONSTRAINT...` inyectando la restricción de integridad referencial cíclica una vez que ambos objetos ya existían en el catálogo.

### B. Actualización de Auditoría (`ON UPDATE CURRENT_TIMESTAMP`)
* **Conflicto:** En MySQL, el motor modifica las marcas de tiempo automáticamente mediante propiedades de columna. SQL Server no permite este comportamiento de manera declarativa directa.
* **Solución:** Se programaron disparadores específicos del tipo `AFTER UPDATE` (Triggers) en las tablas de mayor concurrencia (`actor`, `pelicula`, `cliente`, `alquiler`). Los triggers capturan cualquier modificación física en las filas y alteran la columna `ultima_actualizacion` consumiendo los datos temporales del sistema desde la tabla interna `inserted`.

---

## 🔍 4. Bitácora de Errores de Compilación Solucionados (Trazabilidad)

Durante las pruebas de despliegue en *SQL Server Management Studio (SSMS)*, se identificaron y mitigaron las siguientes excepciones técnicas en consola:

1. **Excepción de Bloque Múltiple (`CREATE FUNCTION/TRIGGER must be the only statement in the batch`)**:
   * *Causa:* SQL Server impide la declaración de subprogramas u objetos programables (como funciones de inventario o triggers de actualización) si se envían en el mismo lote secuencial de código que la creación de tablas.
   * *Solución:* Se aislaron por completo los bloques agregando terminadores de lote **`GO`** de manera individual, reiniciando el analizador sintáctico del motor antes de cada objeto.
2. **Error sintáctico de ámbito (`is not a recognized CURSOR option` / `Must declare the scalar variable`)**:
   * *Causa:* El uso erróneo de signos de punto y coma (`;`) inmediatamente después del tipo en la instrucción `DECLARE` forzaba al compilador a interpretar que se abría un cursor, interrumpiendo la lectura de las variables escalares siguientes (`@v_alquilado`, `@v_devuelto`).
   * *Solución:* Se estandarizó la sintaxis eliminando los delimitadores incorrectos y prefijando de forma unificada las variables con el caracter `@`.

---
