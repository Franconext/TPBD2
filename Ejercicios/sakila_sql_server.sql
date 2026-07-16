IF DB_ID('sakila') IS NOT NULL
BEGIN
    ALTER DATABASE sakila SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE sakila;
END
GO

CREATE DATABASE sakila9;
GO
USE sakila;
GO

CREATE TABLE actor (
    id_actor            INT           IDENTITY(1,1) NOT NULL,
    nombre              VARCHAR(45)   NOT NULL,
    apellido            VARCHAR(45)   NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_actor PRIMARY KEY (id_actor)
);
GO
CREATE INDEX idx_actor_apellido ON actor(apellido);
CREATE INDEX IX_actor_apellido ON actor(apellido);
GO

CREATE TABLE pais (
    id_pais             SMALLINT      IDENTITY(1,1) NOT NULL,
    pais                VARCHAR(50)   NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_pais PRIMARY KEY (id_pais)
);
GO

CREATE TABLE ciudad (
    id_ciudad           INT           IDENTITY(1,1) NOT NULL,
    ciudad              VARCHAR(50)   NOT NULL,
    id_pais             SMALLINT      NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais)
        REFERENCES pais (id_pais) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_pais ON ciudad(id_pais);
CREATE INDEX IX_ciudad_pais_id ON ciudad(id_pais);
GO

CREATE TABLE direccion (
    id_direccion        INT             IDENTITY(1,1) NOT NULL,
    direccion           VARCHAR(50)     NOT NULL,
    direccion2          VARCHAR(50)     NULL,
    distrito            VARCHAR(20)     NOT NULL,
    id_ciudad           INT             NOT NULL,
    codigo_postal       VARCHAR(10)     NULL,
    telefono            VARCHAR(20)     NOT NULL,
    ubicacion           GEOMETRY        NULL,
    fecha_modificacion  DATETIME2       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_direccion PRIMARY KEY (id_direccion),
    CONSTRAINT fk_direccion_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_ciudad ON direccion(id_ciudad);
GO

CREATE TABLE categoria (
    id_categoria        TINYINT       IDENTITY(1,1) NOT NULL,
    nombre              VARCHAR(25)   NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_categoria PRIMARY KEY (id_categoria)
);
GO

CREATE TABLE idioma (
    id_idioma           TINYINT       IDENTITY(1,1) NOT NULL,
    nombre              CHAR(20)      NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_idioma PRIMARY KEY (id_idioma)
);
GO

CREATE TABLE tienda (
    id_tienda             TINYINT     IDENTITY(1,1) NOT NULL,
    id_gerente_empleado   SMALLINT    NOT NULL,
    id_direccion          INT         NOT NULL,
    fecha_modificacion    DATETIME2   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_tienda PRIMARY KEY (id_tienda),
    CONSTRAINT idx_gerente_unico UNIQUE (id_gerente_empleado),
    CONSTRAINT fk_tienda_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_direccion_tienda ON tienda(id_direccion);
CREATE INDEX IX_tienda_direccion_id ON tienda (id_direccion);
GO

CREATE TABLE empleado (
    id_empleado         SMALLINT        IDENTITY(1,1) NOT NULL,
    nombre              VARCHAR(45)     NOT NULL,
    apellido            VARCHAR(45)     NOT NULL,
    id_direccion        INT             NOT NULL,
    foto                VARBINARY(MAX)  NULL,
    email               VARCHAR(50)     NULL,
    id_tienda           TINYINT         NOT NULL,
    activo              BIT             NOT NULL DEFAULT 1,
    usuario             VARCHAR(16)     NOT NULL,
    contrasenia         VARCHAR(40)     COLLATE Latin1_General_BIN2 NULL,
    fecha_modificacion  DATETIME2       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT fk_empleado_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_empleado_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_tienda_empleado ON empleado(id_tienda);
CREATE INDEX idx_fk_id_direccion_empleado ON empleado(id_direccion);
CREATE INDEX IX_empleado_tienda_id ON empleado (id_tienda);
CREATE INDEX IX_empleado_direccion_id ON empleado (id_direccion);
GO

ALTER TABLE tienda
    ADD CONSTRAINT fk_tienda_gerente FOREIGN KEY (id_gerente_empleado)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

CREATE TABLE cliente (
    id_cliente          INT           IDENTITY(1,1) NOT NULL,
    id_tienda           TINYINT       NOT NULL,
    nombre              VARCHAR(45)   NOT NULL,
    apellido            VARCHAR(45)   NOT NULL,
    email               VARCHAR(50)   NULL,
    id_direccion        INT           NOT NULL,
    activo              BIT           NOT NULL DEFAULT 1,
    fecha_alta          DATETIME2     NOT NULL DEFAULT GETDATE(),
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_cliente_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_tienda_cliente ON cliente(id_tienda);
CREATE INDEX idx_fk_id_direccion_cliente ON cliente(id_direccion);
CREATE INDEX idx_apellido_cliente ON cliente(apellido);
CREATE INDEX IX_cliente_tienda_id ON cliente(id_tienda);
CREATE INDEX IX_cliente_direccion_id ON cliente(id_direccion);
CREATE INDEX IX_cliente_apellido ON cliente(apellido);
CREATE INDEX idx_cliente_email ON cliente(email);
GO

CREATE TABLE pelicula (
    id_pelicula                 INT           IDENTITY(1,1) NOT NULL,
    titulo                      VARCHAR(128)  NOT NULL,
    descripcion                 VARCHAR(MAX)  NULL,
    anio_lanzamiento            SMALLINT      NULL,
    id_idioma                   TINYINT       NOT NULL,
    id_idioma_original          TINYINT       NULL,
    duracion_alquiler           TINYINT       NOT NULL DEFAULT 3,
    tarifa_alquiler             DECIMAL(4,2)  NOT NULL DEFAULT 4.99,
    duracion                    SMALLINT      NULL,
    costo_reposicion            DECIMAL(5,2)  NOT NULL DEFAULT 19.99,
    clasificacion               VARCHAR(10)   NULL DEFAULT 'G'
        CONSTRAINT CK_pelicula_clasificacion CHECK (clasificacion IN ('G','PG','PG-13','R','NC-17')),
    caracteristicas_especiales  VARCHAR(100)  NULL,
    fecha_modificacion          DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_pelicula PRIMARY KEY (id_pelicula),
    CONSTRAINT fk_pelicula_idioma FOREIGN KEY (id_idioma)
        REFERENCES idioma (id_idioma) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_idioma_original FOREIGN KEY (id_idioma_original)
        REFERENCES idioma (id_idioma) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_titulo ON pelicula(titulo);
CREATE INDEX idx_fk_id_idioma ON pelicula(id_idioma);
CREATE INDEX idx_fk_id_idioma_original ON pelicula(id_idioma_original);
CREATE INDEX IX_pelicula_titulo ON pelicula(titulo);
CREATE INDEX IX_pelicula_idioma_id ON pelicula(id_idioma);
CREATE INDEX IX_pelicula_idioma_original_id ON pelicula(id_idioma_original);
GO

CREATE TABLE pelicula_actor (
    id_actor            INT         NOT NULL,
    id_pelicula         INT         NOT NULL,
    fecha_modificacion  DATETIME2   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_pelicula_actor PRIMARY KEY (id_actor, id_pelicula),
    CONSTRAINT fk_pelicula_actor_actor FOREIGN KEY (id_actor)
        REFERENCES actor (id_actor) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_actor_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_pelicula_pa ON pelicula_actor(id_pelicula);
CREATE INDEX IX_pelicula_actor_pelicula_id ON pelicula_actor(id_pelicula);
GO

CREATE TABLE pelicula_categoria (
    id_pelicula         INT         NOT NULL,
    id_categoria        TINYINT     NOT NULL,
    fecha_modificacion  DATETIME2   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_pelicula_categoria PRIMARY KEY (id_pelicula, id_categoria),
    CONSTRAINT fk_pelicula_categoria_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pelicula_categoria_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE pelicula_texto (
    id_pelicula   INT            NOT NULL,
    titulo        VARCHAR(255)   NOT NULL,
    descripcion   VARCHAR(MAX)   NULL,
    CONSTRAINT PK_pelicula_texto PRIMARY KEY (id_pelicula)
);
GO
CREATE INDEX idx_titulo_descripcion ON pelicula_texto(titulo);
GO

CREATE TABLE inventario (
    id_inventario       INT           IDENTITY(1,1) NOT NULL,
    id_pelicula         INT           NOT NULL,
    id_tienda           TINYINT       NOT NULL,
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_inventario PRIMARY KEY (id_inventario),
    CONSTRAINT fk_inventario_pelicula FOREIGN KEY (id_pelicula)
        REFERENCES pelicula (id_pelicula) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_inventario_tienda FOREIGN KEY (id_tienda)
        REFERENCES tienda (id_tienda) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_pelicula_inv ON inventario(id_pelicula);
CREATE INDEX idx_id_tienda_id_pelicula ON inventario(id_tienda, id_pelicula);
CREATE INDEX IX_inventario_pelicula_id ON inventario(id_pelicula);
CREATE INDEX IX_inventario_tienda_id_pelicula_id ON inventario(id_tienda, id_pelicula);
GO

CREATE TABLE alquiler (
    id_alquiler         INT         IDENTITY(1,1) NOT NULL,
    fecha_alquiler      DATETIME2   NOT NULL DEFAULT GETDATE(),
    id_inventario       INT         NOT NULL,
    id_cliente          INT         NOT NULL,
    fecha_devolucion    DATETIME2   NULL,
    id_empleado         SMALLINT    NOT NULL,
    fecha_modificacion  DATETIME2   NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_alquiler PRIMARY KEY (id_alquiler),
    CONSTRAINT idx_alquiler_unico UNIQUE (fecha_alquiler, id_inventario, id_cliente),
    CONSTRAINT fk_alquiler_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_alquiler_inventario FOREIGN KEY (id_inventario)
        REFERENCES inventario (id_inventario) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_alquiler_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_inventario_alq ON alquiler(id_inventario);
CREATE INDEX idx_fk_id_cliente_alq ON alquiler(id_cliente);
CREATE INDEX idx_fk_id_empleado_alq ON alquiler(id_empleado);
CREATE INDEX IX_alquiler_inventario_id ON alquiler (id_inventario);
CREATE INDEX IX_alquiler_cliente_id ON alquiler (id_cliente);
CREATE INDEX IX_alquiler_empleado_id ON alquiler (id_empleado);
CREATE INDEX idx_alquiler_fecha_alquiler ON alquiler(fecha_alquiler);
CREATE INDEX idx_alquiler_fecha_devolucion ON alquiler(fecha_devolucion);
GO

CREATE TABLE pago (
    id_pago             INT           IDENTITY(1,1) NOT NULL,
    id_cliente          INT           NOT NULL,
    id_empleado         SMALLINT      NOT NULL,
    id_alquiler         INT           NULL,
    monto               DECIMAL(5,2)  NOT NULL,
    fecha_pago          DATETIME2     NOT NULL DEFAULT GETDATE(),
    fecha_modificacion  DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_alquiler FOREIGN KEY (id_alquiler)
        REFERENCES alquiler (id_alquiler) ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_pago_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO
CREATE INDEX idx_fk_id_empleado_pago ON pago(id_empleado);
CREATE INDEX idx_fk_id_cliente_pago ON pago(id_cliente);
CREATE INDEX IX_pago_empleado_id ON pago (id_empleado);
CREATE INDEX IX_pago_cliente_id ON pago (id_cliente);
CREATE INDEX idx_pago_fecha_pago ON pago(fecha_pago);
GO

/* ============================================================================
   TRIGGERS
   ============================================================================ */

CREATE TRIGGER trg_ins_pelicula ON pelicula
AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO pelicula_texto (id_pelicula, titulo, descripcion)
    SELECT id_pelicula, titulo, descripcion 
    FROM inserted;
END;
GO

CREATE TRIGGER trg_upd_pelicula ON pelicula
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE pt
    SET titulo = i.titulo,
        descripcion = i.descripcion
    FROM pelicula_texto pt
    INNER JOIN inserted i 
        ON pt.id_pelicula = i.id_pelicula;
END;
GO

CREATE TRIGGER trg_del_pelicula ON pelicula
AFTER DELETE AS
BEGIN
    SET NOCOUNT ON;
    DELETE pt
    FROM pelicula_texto pt
    INNER JOIN deleted d 
        ON pt.id_pelicula = d.id_pelicula;
END;
GO

CREATE TRIGGER dbo.trg_actor_fecha_modificacion
ON dbo.actor
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.actor AS t 
    INNER JOIN inserted AS i 
        ON t.id_actor = i.id_actor;
END;
GO

CREATE TRIGGER dbo.trg_pais_fecha_modificacion
ON dbo.pais
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.pais AS t 
    INNER JOIN inserted AS i 
        ON t.id_pais = i.id_pais;
END;
GO

CREATE TRIGGER dbo.trg_ciudad_fecha_modificacion
ON dbo.ciudad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.ciudad AS t 
    INNER JOIN inserted AS i 
        ON t.id_ciudad = i.id_ciudad;
END;
GO

CREATE TRIGGER dbo.trg_direccion_fecha_modificacion
ON dbo.direccion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.direccion AS t 
    INNER JOIN inserted AS i 
        ON t.id_direccion = i.id_direccion;
END;
GO

CREATE TRIGGER dbo.trg_categoria_fecha_modificacion
ON dbo.categoria
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.categoria AS t 
    INNER JOIN inserted AS i 
        ON t.id_categoria = i.id_categoria;
END;
GO

CREATE TRIGGER dbo.trg_idioma_fecha_modificacion
ON dbo.idioma
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.idioma AS t 
    INNER JOIN inserted AS i 
        ON t.id_idioma = i.id_idioma;
END;
GO

CREATE TRIGGER dbo.trg_tienda_fecha_modificacion
ON dbo.tienda
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.tienda AS t 
    INNER JOIN inserted AS i 
        ON t.id_tienda = i.id_tienda;
END;
GO

CREATE TRIGGER dbo.trg_empleado_fecha_modificacion
ON dbo.empleado
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.empleado AS t 
    INNER JOIN inserted AS i 
        ON t.id_empleado = i.id_empleado;
END;
GO

CREATE TRIGGER dbo.trg_cliente_fecha_modificacion
ON dbo.cliente
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.cliente AS t 
    INNER JOIN inserted AS i 
        ON t.id_cliente = i.id_cliente;
END;
GO

CREATE TRIGGER dbo.trg_pelicula_fecha_modificacion
ON dbo.pelicula
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.pelicula AS t 
    INNER JOIN inserted AS i 
        ON t.id_pelicula = i.id_pelicula;
END;
GO

CREATE TRIGGER dbo.trg_pelicula_actor_fecha_modificacion
ON dbo.pelicula_actor
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.pelicula_actor AS t 
    INNER JOIN inserted AS i 
        ON t.id_actor = i.id_actor 
        AND t.id_pelicula = i.id_pelicula;
END;
GO

CREATE TRIGGER dbo.trg_pelicula_categoria_fecha_modificacion
ON dbo.pelicula_categoria
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.pelicula_categoria AS t 
    INNER JOIN inserted AS i 
        ON t.id_pelicula = i.id_pelicula 
        AND t.id_categoria = i.id_categoria;
END;
GO

CREATE TRIGGER dbo.trg_inventario_fecha_modificacion
ON dbo.inventario
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.inventario AS t 
    INNER JOIN inserted AS i 
        ON t.id_inventario = i.id_inventario;
END;
GO

CREATE TRIGGER dbo.trg_alquiler_fecha_modificacion
ON dbo.alquiler
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.alquiler AS t 
    INNER JOIN inserted AS i 
        ON t.id_alquiler = i.id_alquiler;
END;
GO

CREATE TRIGGER dbo.trg_pago_fecha_modificacion
ON dbo.pago
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_modificacion) RETURN;
    UPDATE t 
    SET fecha_modificacion = GETDATE() 
    FROM dbo.pago AS t 
    INNER JOIN inserted AS i 
        ON t.id_pago = i.id_pago;
END;
GO

/* ============================================================================
   VISTAS
   ============================================================================ */

CREATE VIEW lista_clientes AS
SELECT
    cl.id_cliente                                 AS id,
    CONCAT(cl.nombre, ' ', cl.apellido)          AS nombre_completo,
    d.direccion                                  AS direccion,
    d.codigo_postal                               AS [codigo postal],
    d.telefono                                   AS telefono,
    c.ciudad                                      AS ciudad,
    p.pais                                        AS pais,
    CASE WHEN cl.activo = 1 THEN 'activo' ELSE '' END AS notas,
    cl.id_tienda                                  AS id_tienda
FROM cliente AS cl
INNER JOIN direccion AS d 
    ON cl.id_direccion = d.id_direccion
INNER JOIN ciudad AS c 
    ON d.id_ciudad = c.id_ciudad
INNER JOIN pais AS p 
    ON c.id_pais = p.id_pais;
GO

CREATE VIEW lista_peliculas AS
SELECT
    pe.id_pelicula                                            AS id_pelicula,
    pe.titulo                                                 AS titulo,
    pe.descripcion                                            AS descripcion,
    cat.nombre                                                AS categoria,
    pe.tarifa_alquiler                                        AS precio,
    pe.duracion                                               AS duracion,
    pe.clasificacion                                          AS clasificacion,
    STRING_AGG(CONCAT(a.nombre, ' ', a.apellido), ', ') WITHIN GROUP (ORDER BY a.apellido) AS actors
FROM pelicula pe
LEFT JOIN pelicula_categoria pc 
    ON pc.id_pelicula = pe.id_pelicula
LEFT JOIN categoria cat 
    ON cat.id_categoria = pc.id_categoria
LEFT JOIN pelicula_actor pa 
    ON pe.id_pelicula = pa.id_pelicula
LEFT JOIN actor a 
    ON pa.id_actor = a.id_actor
GROUP BY 
    pe.id_pelicula, 
    pe.titulo, 
    pe.descripcion, 
    cat.nombre,
    pe.tarifa_alquiler, 
    pe.duracion, 
    pe.clasificacion;
GO

CREATE VIEW lista_peliculas_detallada AS
SELECT
    pe.id_pelicula      AS id_pelicula,
    pe.titulo           AS titulo,
    pe.descripcion      AS descripcion,
    cat.nombre          AS categoria,
    pe.tarifa_alquiler  AS precio,
    pe.duracion         AS duracion,
    pe.clasificacion    AS clasificacion,
    STRING_AGG(
        CONCAT(
            UPPER(LEFT(a.nombre, 1)), LOWER(SUBSTRING(a.nombre, 2, LEN(a.nombre))),
            ' ',
            UPPER(LEFT(a.apellido, 1)), LOWER(SUBSTRING(a.apellido, 2, LEN(a.apellido)))
        ), ', ') WITHIN GROUP (ORDER BY a.apellido) AS actors
FROM pelicula pe
LEFT JOIN pelicula_categoria pc 
    ON pc.id_pelicula = pe.id_pelicula
LEFT JOIN categoria cat 
    ON cat.id_categoria = pc.id_categoria
LEFT JOIN pelicula_actor pa 
    ON pe.id_pelicula = pa.id_pelicula
LEFT JOIN actor a 
    ON pa.id_actor = a.id_actor
GROUP BY 
    pe.id_pelicula, 
    pe.titulo, 
    pe.descripcion, 
    cat.nombre,
    pe.tarifa_alquiler, 
    pe.duracion, 
    pe.clasificacion;
GO

CREATE VIEW lista_empleados AS
SELECT
    e.id_empleado                             AS id,
    CONCAT(e.nombre, ' ', e.apellido)         AS nombre_completo,
    d.direccion                               AS direccion,
    d.codigo_postal                            AS [codigo postal],
    d.telefono                                 AS telefono,
    c.ciudad                                   AS ciudad,
    p.pais                                     AS pais,
    e.id_tienda                                AS id_tienda
FROM empleado AS e
INNER JOIN direccion AS d 
    ON e.id_direccion = d.id_direccion
INNER JOIN ciudad AS c 
    ON d.id_ciudad = c.id_ciudad
INNER JOIN pais AS p 
    ON c.id_pais = p.id_pais;
GO

CREATE VIEW ventas_por_tienda AS
SELECT
    CONCAT(c.ciudad, ',', p.pais)              AS tienda,
    CONCAT(g.nombre, ' ', g.apellido)          AS gerente,
    SUM(pg.monto)                              AS ventas_totales
FROM pago AS pg
INNER JOIN alquiler AS al 
    ON pg.id_alquiler = al.id_alquiler
INNER JOIN inventario AS inv 
    ON al.id_inventario = inv.id_inventario
INNER JOIN tienda AS t 
    ON inv.id_tienda = t.id_tienda
INNER JOIN direccion AS d 
    ON t.id_direccion = d.id_direccion
INNER JOIN ciudad AS c 
    ON d.id_ciudad = c.id_ciudad
INNER JOIN pais AS p 
    ON c.id_pais = p.id_pais
INNER JOIN empleado AS g 
    ON t.id_gerente_empleado = g.id_empleado
GROUP BY 
    t.id_tienda, 
    c.ciudad, 
    p.pais, 
    g.nombre, 
    g.apellido;
GO

CREATE VIEW ventas_por_categoria AS
SELECT
    cat.nombre        AS categoria,
    SUM(pg.monto)     AS ventas_totales
FROM pago AS pg
INNER JOIN alquiler AS al 
    ON pg.id_alquiler = al.id_alquiler
INNER JOIN inventario AS inv 
    ON al.id_inventario = inv.id_inventario
INNER JOIN pelicula AS pe 
    ON inv.id_pelicula = pe.id_pelicula
INNER JOIN pelicula_categoria AS pc 
    ON pe.id_pelicula = pc.id_pelicula
INNER JOIN categoria AS cat 
    ON pc.id_categoria = cat.id_categoria
GROUP BY 
    cat.nombre;
GO

CREATE VIEW info_actor AS
WITH actor_categoria AS (
    SELECT DISTINCT
        a.id_actor, 
        a.nombre, 
        a.apellido,
        cat.id_categoria, 
        cat.nombre AS nombre_categoria
    FROM actor a
    LEFT JOIN pelicula_actor pa 
        ON a.id_actor = pa.id_actor
    LEFT JOIN pelicula_categoria pc 
        ON pa.id_pelicula = pc.id_pelicula
    LEFT JOIN categoria cat 
        ON pc.id_categoria = cat.id_categoria
),
categoria_peliculas AS (
    SELECT
        ac.id_actor, 
        ac.id_categoria, 
        ac.nombre_categoria,
        (
            SELECT STRING_AGG(pe.titulo, ', ') WITHIN GROUP (ORDER BY pe.titulo)
            FROM pelicula pe
            INNER JOIN pelicula_categoria pc2 
                ON pe.id_pelicula = pc2.id_pelicula
            INNER JOIN pelicula_actor pa2 
                ON pe.id_pelicula = pa2.id_pelicula
            WHERE pc2.id_categoria = ac.id_categoria
              AND pa2.id_actor = ac.id_actor
        ) AS peliculas
    FROM actor_categoria ac
    WHERE ac.id_categoria IS NOT NULL
)
SELECT
    a.id_actor,
    a.nombre,
    a.apellido,
    STRING_AGG(CONCAT(cp.nombre_categoria, ': ', cp.peliculas), '; ') WITHIN GROUP (ORDER BY cp.nombre_categoria) AS info_peliculas
FROM actor a
LEFT JOIN categoria_peliculas cp 
    ON a.id_actor = cp.id_actor
GROUP BY 
    a.id_actor, 
    a.nombre, 
    a.apellido;
GO

CREATE VIEW dbo.clientes_activos AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    c.email,
    c.id_tienda,
    d.direccion,
    ci.ciudad,
    p.pais,
    c.fecha_alta,
    c.fecha_modificacion
FROM dbo.cliente AS c
INNER JOIN dbo.direccion AS d 
    ON c.id_direccion = d.id_direccion
INNER JOIN dbo.ciudad AS ci 
    ON d.id_ciudad = ci.id_ciudad
INNER JOIN dbo.pais AS p 
    ON ci.id_pais = p.id_pais
WHERE c.activo = 1;
GO

CREATE VIEW dbo.alquileres_pendientes AS
SELECT
    a.id_alquiler,
    a.fecha_alquiler,
    DATEDIFF(DAY, a.fecha_alquiler, GETDATE()) AS dias_transcurridos,
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    p.id_pelicula,
    p.titulo,
    i.id_inventario,
    i.id_tienda,
    CONCAT('Tienda ', i.id_tienda) AS tienda,
    a.id_empleado
FROM dbo.alquiler AS a
INNER JOIN dbo.cliente AS c 
    ON a.id_cliente = c.id_cliente
INNER JOIN dbo.inventario AS i 
    ON a.id_inventario = i.id_inventario
INNER JOIN dbo.pelicula AS p 
    ON i.id_pelicula = p.id_pelicula
WHERE a.fecha_devolucion IS NULL;
GO

CREATE VIEW dbo.resumen_peliculas AS
SELECT
    p.id_pelicula,
    p.titulo,
    p.clasificacion,
    p.tarifa_alquiler,
    COUNT(DISTINCT i.id_inventario) AS cantidad_copias,
    COUNT(DISTINCT a.id_alquiler) AS cantidad_alquileres,
    ISNULL(SUM(pg.monto), 0) AS total_recaudado
FROM dbo.pelicula AS p
LEFT JOIN dbo.inventario AS i 
    ON p.id_pelicula = i.id_pelicula
LEFT JOIN dbo.alquiler AS a 
    ON i.id_inventario = a.id_inventario
LEFT JOIN dbo.pago AS pg 
    ON a.id_alquiler = pg.id_alquiler
GROUP BY 
    p.id_pelicula, 
    p.titulo, 
    p.clasificacion, 
    p.tarifa_alquiler;
GO

CREATE VIEW dbo.rendimiento_empleados AS
SELECT
    e.id_empleado,
    CONCAT(e.nombre, ' ', e.apellido) AS empleado,
    e.id_tienda,
    COUNT(DISTINCT a.id_alquiler) AS alquileres_procesados,
    ISNULL(SUM(p.monto), 0) AS ingresos_gestionados
FROM dbo.empleado AS e
LEFT JOIN dbo.alquiler AS a 
    ON e.id_empleado = a.id_empleado
LEFT JOIN dbo.pago AS p 
    ON a.id_alquiler = p.id_alquiler
GROUP BY 
    e.id_empleado, 
    e.nombre, 
    e.apellido, 
    e.id_tienda;
GO

/* ============================================================================
   FUNCIONES
   ============================================================================ */

CREATE FUNCTION dbo.obtener_saldo_cliente
(
    @p_id_cliente INT,
    @p_fecha_efectiva DATETIME2
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @v_costos_alquiler DECIMAL(5,2);
    DECLARE @v_recargos_mora INT;
    DECLARE @v_pagos DECIMAL(5,2);

    SELECT @v_costos_alquiler = ISNULL(SUM(pe.tarifa_alquiler), 0)
    FROM pelicula pe
    INNER JOIN inventario inv 
        ON pe.id_pelicula = inv.id_pelicula
    INNER JOIN alquiler al 
        ON inv.id_inventario = al.id_inventario
    WHERE al.fecha_alquiler <= @p_fecha_efectiva 
      AND al.id_cliente = @p_id_cliente;

    SELECT @v_recargos_mora = ISNULL(SUM(
        CASE WHEN DATEDIFF(DAY, al.fecha_alquiler, al.fecha_devolucion) > pe.duracion_alquiler
             THEN DATEDIFF(DAY, al.fecha_alquiler, al.fecha_devolucion) - pe.duracion_alquiler
             ELSE 0 END), 0)
    FROM alquiler al
    INNER JOIN inventario inv 
        ON al.id_inventario = inv.id_inventario
    INNER JOIN pelicula pe 
        ON inv.id_pelicula = pe.id_pelicula
    WHERE al.fecha_alquiler <= @p_fecha_efectiva 
      AND al.id_cliente = @p_id_cliente;

    SELECT @v_pagos = ISNULL(SUM(monto), 0) 
    FROM pago 
    WHERE fecha_pago <= @p_fecha_efectiva 
      AND id_cliente = @p_id_cliente;

    RETURN @v_costos_alquiler + @v_recargos_mora - @v_pagos;
END;
GO

CREATE FUNCTION dbo.inventario_en_poder_de_cliente
(
    @p_id_inventario INT
)
RETURNS INT
AS
BEGIN
    DECLARE @v_id_cliente INT;
    SELECT @v_id_cliente = id_cliente 
    FROM alquiler 
    WHERE fecha_devolucion IS NULL 
      AND id_inventario = @p_id_inventario;
    RETURN @v_id_cliente;
END;
GO

CREATE FUNCTION dbo.inventario_en_stock
(
    @p_id_inventario INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @v_alquileres INT;
    DECLARE @v_prestados INT;

    SELECT @v_alquileres = COUNT(id_alquiler) 
    FROM alquiler 
    WHERE id_inventario = @p_id_inventario;
    IF @v_alquileres = 0 RETURN 1;

    SELECT @v_prestados = COUNT(al.id_alquiler) 
    FROM inventario inv 
    LEFT JOIN alquiler al 
        ON inv.id_inventario = al.id_inventario 
    WHERE inv.id_inventario = @p_id_inventario 
      AND al.fecha_devolucion IS NULL;
    IF @v_prestados > 0 RETURN 0;

    RETURN 1;
END;
GO

CREATE FUNCTION cliente_que_posee_inventario
(
    @id_inventario INT
)
RETURNS INT
AS
BEGIN
    DECLARE @id_cliente INT;
    SELECT @id_cliente = a.id_cliente 
    FROM alquiler AS a 
    WHERE a.fecha_devolucion IS NULL 
      AND a.id_inventario = @id_inventario;
    RETURN @id_cliente;
END;
GO

CREATE FUNCTION esta_en_stock_inventario
(
    @id_inventario INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @cantidad_alquileres INT;
    DECLARE @cantidad_prestados INT;
    DECLARE @resultado BIT;

    SELECT @cantidad_alquileres = COUNT(id_alquiler) 
    FROM alquiler 
    WHERE id_inventario = @id_inventario;
    IF @cantidad_alquileres = 0 RETURN 1;

    SELECT @cantidad_prestados = COUNT(a.id_alquiler) 
    FROM inventario AS i 
    LEFT JOIN alquiler AS a 
        ON i.id_inventario = a.id_inventario 
    WHERE i.id_inventario = @id_inventario 
      AND a.fecha_devolucion IS NULL;
    
    IF @cantidad_prestados > 0 SET @resultado = 0;
    ELSE SET @resultado = 1;

    RETURN @resultado;
END;
GO

CREATE FUNCTION dbo.obtener_nombre_cliente
(
    @id_cliente INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @nombre_completo VARCHAR(100);
    SELECT @nombre_completo = CONCAT(nombre, ' ', apellido) 
    FROM dbo.cliente 
    WHERE id_cliente = @id_cliente;
    RETURN @nombre_completo;
END;
GO

CREATE FUNCTION dbo.obtener_stock_pelicula
(
    @id_pelicula INT
)
RETURNS INT
AS
BEGIN
    DECLARE @stock_disponible INT;
    SELECT @stock_disponible = COUNT(id_inventario) 
    FROM dbo.inventario AS i 
    WHERE i.id_pelicula = @id_pelicula 
      AND dbo.inventario_en_stock(i.id_inventario) = 1;
    RETURN ISNULL(@stock_disponible, 0);
END;
GO

CREATE FUNCTION dbo.total_recaudado_pelicula
(
    @id_pelicula INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);
    SELECT @total = ISNULL(SUM(p.monto), 0) 
    FROM dbo.pago AS p 
    INNER JOIN dbo.alquiler AS a 
        ON p.id_alquiler = a.id_alquiler 
    INNER JOIN dbo.inventario AS i 
        ON a.id_inventario = i.id_inventario 
    WHERE i.id_pelicula = @id_pelicula;
    RETURN ISNULL(@total, 0);
END;
GO

/* ============================================================================
   PROCEDIMIENTOS ALMACENADOS
   ============================================================================ */

CREATE PROCEDURE dbo.pelicula_en_stock
    @p_id_pelicula INT,
    @p_id_tienda INT,
    @p_cantidad_peliculas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_inventario 
    FROM inventario 
    WHERE id_pelicula = @p_id_pelicula 
      AND id_tienda = @p_id_tienda 
      AND dbo.inventario_en_stock(id_inventario) = 1;

    SELECT @p_cantidad_peliculas = COUNT(id_inventario) 
    FROM inventario 
    WHERE id_pelicula = @p_id_pelicula 
      AND id_tienda = @p_id_tienda 
      AND dbo.inventario_en_stock(id_inventario) = 1;
END;
GO

CREATE PROCEDURE dbo.pelicula_sin_stock
    @p_id_pelicula INT,
    @p_id_tienda INT,
    @p_cantidad_peliculas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_inventario 
    FROM inventario 
    WHERE id_pelicula = @p_id_pelicula 
      AND id_tienda = @p_id_tienda 
      AND dbo.inventario_en_stock(id_inventario) = 0;

    SELECT @p_cantidad_peliculas = COUNT(id_inventario) 
    FROM inventario 
    WHERE id_pelicula = @p_id_pelicula 
      AND id_tienda = @p_id_tienda 
      AND dbo.inventario_en_stock(id_inventario) = 0;
END;
GO

CREATE PROCEDURE dbo.informe_recompensas
    @compras_minimas_mensuales TINYINT,
    @monto_minimo_comprado DECIMAL(10,2),
    @cantidad_premiados INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @inicio_mes_anterior DATE;
    DECLARE @fin_mes_anterior DATE;

    IF @compras_minimas_mensuales = 0 BEGIN SELECT 'El parámetro de compras mínimas mensuales debe ser > 0' AS mensaje; RETURN; END
    IF @monto_minimo_comprado = 0.00 BEGIN SELECT 'El parámetro de monto mínimo comprado debe ser > $0.00' AS mensaje; RETURN; END

    SET @inicio_mes_anterior = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1);
    SET @fin_mes_anterior = EOMONTH(@inicio_mes_anterior);

    CREATE TABLE #tmp_cliente (id_cliente INT NOT NULL PRIMARY KEY);

    INSERT INTO #tmp_cliente (id_cliente)
    SELECT pg.id_cliente 
    FROM pago AS pg 
    WHERE CAST(pg.fecha_pago AS DATE) BETWEEN @inicio_mes_anterior AND @fin_mes_anterior 
    GROUP BY pg.id_cliente 
    HAVING SUM(pg.monto) > @monto_minimo_comprado 
       AND COUNT(pg.id_cliente) > @compras_minimas_mensuales;

    SELECT @cantidad_premiados = COUNT(id_cliente) 
    FROM #tmp_cliente;

    SELECT 
        c.id_cliente, 
        c.id_tienda, 
        c.nombre, 
        c.apellido, 
        c.email, 
        c.id_direccion, 
        c.activo, 
        c.fecha_alta, 
        c.fecha_modificacion 
    FROM #tmp_cliente AS t 
    INNER JOIN cliente AS c 
        ON t.id_cliente = c.id_cliente;

    DROP TABLE #tmp_cliente;
END;
GO

CREATE PROCEDURE reporte_recompensas
(
    @min_compras_mensuales INT,
    @min_monto_compras DECIMAL(10,2),
    @cantidad_clientes INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @inicio_mes_anterior DATE;
    DECLARE @fin_mes_anterior DATE;

    IF @min_compras_mensuales = 0 BEGIN SELECT 'El mínimo de compras mensuales debe ser mayor a 0' AS mensaje; RETURN; END;
    IF @min_monto_compras = 0.00 BEGIN SELECT 'El monto mínimo mensual debe ser mayor a $0.00' AS mensaje; RETURN; END;

    SET @inicio_mes_anterior = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1);
    SET @fin_mes_anterior = EOMONTH(@inicio_mes_anterior);

    CREATE TABLE #clientes_recompensa (id_cliente INT NOT NULL PRIMARY KEY);

    INSERT INTO #clientes_recompensa (id_cliente)
    SELECT p.id_cliente 
    FROM pago AS p 
    WHERE CAST(p.fecha_pago AS DATE) BETWEEN @inicio_mes_anterior AND @fin_mes_anterior 
    GROUP BY p.id_cliente 
    HAVING SUM(p.monto) > @min_monto_compras 
       AND COUNT(p.id_cliente) > @min_compras_mensuales;

    SELECT @cantidad_clientes = COUNT(id_cliente) 
    FROM #clientes_recompensa;

    SELECT 
        c.id_cliente, 
        c.id_tienda, 
        c.nombre, 
        c.apellido, 
        c.email, 
        c.id_direccion, 
        c.activo, 
        c.fecha_alta, 
        c.fecha_modificacion 
    FROM #clientes_recompensa AS cr 
    INNER JOIN cliente AS c 
        ON cr.id_cliente = c.id_cliente;

    DROP TABLE #clientes_recompensa;
END;
GO

CREATE PROCEDURE peliculass_en_stock
(
    @pelicula_id INT,
    @tienda_id INT,
    @cantidad_peliculas INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.id_inventario 
    FROM inventario AS i 
    WHERE i.id_pelicula = @pelicula_id 
      AND i.id_tienda = @tienda_id 
      AND dbo.esta_en_stock_inventario(i.id_inventario) = 1;

    SELECT @cantidad_peliculas = COUNT(id_inventario) 
    FROM inventario AS i 
    WHERE i.id_pelicula = @pelicula_id 
      AND i.id_tienda = @tienda_id 
      AND dbo.esta_en_stock_inventario(i.id_inventario) = 1;
END;
GO

CREATE PROCEDURE peliculas_no_en_stock
(
    @pelicula_id INT,
    @tienda_id INT,
    @cantidad_peliculas INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.id_inventario 
    FROM inventario AS i 
    WHERE i.id_pelicula = @pelicula_id 
      AND i.id_tienda = @tienda_id 
      AND dbo.esta_en_stock_inventario(i.id_inventario) = 0;

    SELECT @cantidad_peliculas = COUNT(id_inventario) 
    FROM inventario AS i 
    WHERE i.id_pelicula = @pelicula_id 
      AND i.id_tienda = @tienda_id 
      AND dbo.esta_en_stock_inventario(i.id_inventario) = 0;
END;
GO

CREATE PROCEDURE dbo.buscar_peliculas_por_categoria
    @id_categoria TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        p.id_pelicula, 
        p.titulo, 
        p.descripcion, 
        p.clasificacion, 
        p.tarifa_alquiler, 
        p.duracion 
    FROM dbo.pelicula AS p 
    INNER JOIN dbo.pelicula_categoria AS pc 
        ON p.id_pelicula = pc.id_pelicula 
    WHERE pc.id_categoria = @id_categoria 
    ORDER BY p.titulo;
END;
GO

CREATE PROCEDURE dbo.listar_alquileres_cliente
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        a.id_alquiler, 
        p.id_pelicula, 
        p.titulo, 
        a.fecha_alquiler, 
        a.fecha_devolucion, 
        CASE WHEN a.fecha_devolucion IS NULL THEN 'Pendiente' ELSE 'Devuelto' END AS estado, 
        ISNULL(pg.monto, 0) AS monto_pagado 
    FROM dbo.alquiler AS a 
    INNER JOIN dbo.inventario AS i 
        ON a.id_inventario = i.id_inventario 
    INNER JOIN dbo.pelicula AS p 
        ON i.id_pelicula = p.id_pelicula 
    LEFT JOIN dbo.pago AS pg 
        ON a.id_alquiler = pg.id_alquiler 
    WHERE a.id_cliente = @id_cliente 
    ORDER BY a.fecha_alquiler DESC;
END;
GO

CREATE PROCEDURE dbo.registrar_devolucion
    @id_alquiler INT,
    @fecha_devolucion DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.alquiler 
        WHERE id_alquiler = @id_alquiler
    ) 
    BEGIN 
        ;THROW 50001, 'El alquiler indicado no existe.', 1; 
    END;
    
    IF EXISTS (
        SELECT 1 
        FROM dbo.alquiler 
        WHERE id_alquiler = @id_alquiler 
          AND fecha_devolucion IS NOT NULL
    ) 
    BEGIN 
        ;THROW 50002, 'El alquiler ya posee una devolución registrada.', 1; 
    END;

    UPDATE dbo.alquiler 
    SET fecha_devolucion = ISNULL(@fecha_devolucion, GETDATE()) 
    WHERE id_alquiler = @id_alquiler;

    SELECT 
        id_alquiler, 
        fecha_alquiler, 
        fecha_devolucion, 
        id_cliente, 
        id_inventario 
    FROM dbo.alquiler 
    WHERE id_alquiler = @id_alquiler;
END;
GO

CREATE PROCEDURE dbo.registrar_alquiler
    @id_inventario INT,
    @id_cliente INT,
    @id_empleado SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.inventario 
        WHERE id_inventario = @id_inventario
    ) 
    BEGIN 
        ;THROW 50003, 'El inventario indicado no existe.', 1; 
    END;
    
    IF dbo.inventario_en_stock(@id_inventario) = 0 
    BEGIN 
        ;THROW 50004, 'La película seleccionada no está disponible.', 1; 
    END;
    
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.cliente 
        WHERE id_cliente = @id_cliente 
          AND activo = 1
    ) 
    BEGIN 
        ;THROW 50005, 'El cliente no existe o se encuentra inactivo.', 1; 
    END;

    INSERT INTO dbo.alquiler (fecha_alquiler, id_inventario, id_cliente, fecha_devolucion, id_empleado) 
    VALUES (GETDATE(), @id_inventario, @id_cliente, NULL, @id_empleado);
    
    SELECT SCOPE_IDENTITY() AS id_alquiler_generado;
END;
GO

