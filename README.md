# 📊 Trabajo Práctico: Migración y Consultas Avanzadas en SQL Server
## *Caso de Estudio: Base de Datos Sakila*

---

### 🏛️ Datos Institucionales
*   **Institución:** Instituto Superior Nuestra Señora de Luján del Buen Viaje
*   **Materia:** Seminario de Actualización
*   **Docente:** Jorge Insfran
*   **Alumno:** Franco
*   **Fecha de Entrega:** 16/07/2026

---

## 1. 🎯 Introducción y Objetivos
El presente proyecto documenta el proceso estratégico de análisis, corrección y optimización del script DDL para migrar la base de datos de muestra **Sakila** desde su especificación original en MySQL hacia Microsoft SQL Server. 

El objetivo central del trabajo consiste en:
*   Garantizar la consistencia relacional del esquema traducido íntegramente al español.
*   Resolver de raíz los conflictos de referencias y recursividad en la actualización automatizada de metadatos.
*   Asegurar el cumplimiento estricto de las buenas prácticas de diseño DDL y la eficiencia del motor relacional exigidas por la cátedra.

---

## 2. 🛠️ Desafíos Técnicos Resueltos en la Migración (DDL)

### 2.1. Resolución de Referencias Circulares y Orden de Compilación
Uno de los principales inconvenientes identificados en las primeras etapas de ordenamiento del script fue la relación de dependencia mutua entre las entidades `tienda` y `empleado`.

*   **El Problema:** La tabla `tienda` requiere una clave foránea que referencie al empleado que actúa como gerente (`id_gerente_empleado`), mientras que la tabla `empleado` requiere conocer la tienda física a la que pertenece (`id_tienda`). Si ambas restricciones se declaran de manera interna dentro de los bloques `CREATE TABLE`, la compilación falla linealmente debido a la inexistencia temporal de la tabla relacionada.
*   **La Solución:** Se estructuró la creación secuencial de las tablas de forma aislada. La clave foránea que cierra el bucle referencial (`fk_tienda_gerente`) se extrajo del cuerpo de `CREATE TABLE tienda` y se aplicó de manera externa mediante una sentencia `ALTER TABLE tienda ADD CONSTRAINT...` una vez que ambas entidades se encontraban físicamente creadas y persistidas en el catálogo de SQL Server.

### 2.2. Mitigación de la Recursividad en Triggers de Modificación
A diferencia de MySQL, que de manera nativa provee la directiva `ON UPDATE CURRENT_TIMESTAMP`, SQL Server exige la implementación de disparadores de tipo `AFTER UPDATE` para actualizar campos de auditoría temporal (`fecha_modificacion`).

*   **El Problema:** Un trigger `AFTER UPDATE` estándar que ejecuta una instrucción `UPDATE` sobre la misma tabla que lo invocó provoca que el motor dispare el trigger nuevamente. Esto genera una ejecución recursiva en bucle infinito que es abortada por el planificador de SQL Server al alcanzar el límite máximo de anidamiento (`Msg 217`).
*   **La Solución:** Se reescribieron los 15 triggers de auditoría incorporando la cláusula de control condicional nativa de T-SQL:
    ```sql
    IF UPDATE(fecha_modificacion) RETURN;
    ```
    Esta condición evalúa si la columna de auditoría ya fue modificada en el lote de ejecución actual. Si es verdadero, interrumpe el flujo de manera inmediata (`RETURN`), garantizando la actualización del metadato en un único paso y anulando cualquier riesgo de recursión.

### 2.3. Emulación de Disparadores Temporales y Valores por Defecto
El esquema original de Sakila implementa triggers de tipo `BEFORE INSERT` (`customer_create_date`, `rental_date`, `payment_date`) para inyectar marcas de tiempo en el momento exacto de la inserción de registros[cite: 1, 2]. 

Debido a que SQL Server no cuenta con el evento `BEFORE`[cite: 2], se optó por la estrategia estándar de migración óptima: definir restricciones `DEFAULT GETDATE()` directamente en las especificaciones de las columnas (`fecha_alta` en `cliente`, `fecha_alquiler` en `alquiler` y `fecha_pago` en `pago`)[cite: 2]. Esto simplifica significativamente el catálogo de objetos de la base de datos y reduce la sobrecarga de procesamiento en la capa de datos[cite: 2].

### 2.4. Tratamiento del Paquete Full-Text Search e Integración Espacial
*   **Full-Text Search:** Se mantuvo la declaración lógica del catálogo `FTC_pelicula_texto` y su respectivo `FULLTEXT INDEX` sobre la tabla `pelicula_texto`. Es importante destacar que si el entorno local de SQL Server carece de la dependencia de sistema `mssql-server-fts`[cite: 2], el motor arrojará la advertencia descriptiva `Msg 7609`. Dicha advertencia responde a una limitación de la instalación local del entorno de pruebas y no a un error de diseño de la sentencia SQL, manteniendo intacta la validez académica del modelo para entornos productivos complejos[cite: 2].
*   **Datos Espaciales:** La columna `ubicacion` dentro de la tabla `direccion` se migró utilizando el tipo de datos nativo **`GEOMETRY`**, preservando las capacidades de indexación y consulta espacial del modelo Sakila original de manera nativa en SQL Server.

---

## 3. 🚀 Optimización de Código y Buenas Prácticas (Eliminación de `SELECT *`)

En estricto cumplimiento con los criterios de evaluación relacionales y de rendimiento, se realizó una de las mejores prácticas sobre el script: **erradicar por completo el uso de comodines de selección masiva (`*`)**[cite: 2]. 

El uso de `SELECT *` introduce penalizaciones debido al tráfico de red redundante y el escaneo innecesario de páginas de datos, afectando especialmente a tablas con columnas pesadas como `foto` en la entidad `empleado` (definida como `VARBINARY(MAX)`).

Las consultas internas de los procedimientos almacenados, incluyendo `dbo.informe_recompensas` y `reporte_recompensas`, fueron modificadas para proyectar de manera explícita cada uno de los atributos requeridos (`id_cliente`, `nombre`, `apellido`, `email`, etc.). Asimismo, se reemplazaron las funciones agregadas genéricas `COUNT(*)` por el conteo referenciado a las claves primarias estables de las tablas, utilizando sintaxis limpia como `COUNT(id_cliente)` o `COUNT(id_inventario)`.

---

## 4. IA
**¿Qué tipos de datos me recomendás usar en SQL Server en lugar de los de MySQL?**

## Respuesta

Al migrar una base de datos desde **MySQL** a **Microsoft SQL Server**, es importante revisar los tipos de datos utilizados, ya que algunos no existen o tienen un funcionamiento diferente. A continuación se muestran las conversiones más recomendadas.

| MySQL | SQL Server | Observación |
|--------|------------|-------------|
| `TINYINT` | `TINYINT` o `SMALLINT` | Dependiendo del rango de valores que se necesite almacenar. |
| `SMALLINT` | `SMALLINT` | Equivalente directo. |
| `INT` | `INT` | Equivalente directo. |
| `BIGINT` | `BIGINT` | Equivalente directo. |
| `VARCHAR(n)` | `VARCHAR(n)` | Se mantiene sin cambios. |
| `TEXT` | `VARCHAR(MAX)` | `TEXT` está obsoleto en SQL Server. |
| `CHAR(n)` | `CHAR(n)` | Equivalente directo. |
| `BLOB` | `VARBINARY(MAX)` | Recomendado para almacenar datos binarios. |
| `DATETIME` / `TIMESTAMP` | `DATETIME2` | Ofrece mayor precisión y es el tipo recomendado por Microsoft. |
| `ENUM` | `VARCHAR` + `CHECK` | SQL Server no soporta el tipo `ENUM`. |
| `SET` | `VARCHAR` o una tabla relacionada | No existe un equivalente directo. |
| `AUTO_INCREMENT` | `IDENTITY(1,1)` | Permite generar valores autoincrementales. |
| `BOOLEAN` | `BIT` | SQL Server utiliza el tipo `BIT` para valores booleanos. |

## Otras adaptaciones recomendadas

Además del cambio de tipos de datos, durante una migración también es conveniente realizar las siguientes modificaciones:

- Reemplazar `AUTO_INCREMENT` por `IDENTITY(1,1)`.
- Sustituir `NOW()` por `GETDATE()`.
- Reemplazar `IFNULL()` por `ISNULL()`.
- Cambiar `LIMIT` por `TOP` o `OFFSET ... FETCH`.
- Sustituir las comillas invertidas (`` ` ``) por corchetes (`[]`) cuando sea necesario.
- Revisar las reglas de `ON DELETE` y `ON UPDATE`, ya que SQL Server es más restrictivo con las eliminaciones y actualizaciones en cascada.


---

## 5. 📸 Capturas de Pantalla y Evidencias de Ejecución

Las capturas de pantalla que evidencian la correcta ejecución del proceso de migración, la creación de la base de datos y la posterior carga de los datos se encuentran organizadas en la carpeta **`Capturasdepantalla`** dentro de este repositorio.

En dicha carpeta se incluyen las siguientes evidencias visuales del proceso:
*   **Evidencias de Estructura (DDL):** Las primeras cuatro capturas de pantalla muestran la ejecución secuencial del script y la confirmación de la creación exitosa de las tablas principales en SQL Server.
*   **Evidencia de Carga de Datos (DML):** La última captura de pantalla certifica el proceso de inserción de datos (inserts)[cite: 1], mostrando el panel con el conteo de filas afectadas y confirmando que los registros se subieron de manera íntegra.

---

## 6. 🏁 Conclusiones
La migración exitosa del modelo Sakila a SQL Server demuestra que la adaptabilidad de un esquema relacional no solo requiere el mapeo directo de tipos de datos, sino también la comprensión de cómo cada motor gestiona la integridad referencial, el orden de compilación y los eventos de los triggers. 
