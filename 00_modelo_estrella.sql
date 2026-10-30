CREATE TABLE dbo.dsc_zona_geografica (
    ID_ZONA       INT          NOT NULL CONSTRAINT pk_dsc_zona_geografica PRIMARY KEY,
    REGION        VARCHAR(30)  NOT NULL,
    PROVINCIA     VARCHAR(40)  NOT NULL,
    LOCALIDAD     VARCHAR(60)  NOT NULL
);

CREATE TABLE dbo.dsc_tecnologia_red (
    ID_RED        TINYINT      NOT NULL CONSTRAINT pk_dsc_tecnologia_red PRIMARY KEY,
    RED           VARCHAR(10)  NOT NULL
);

CREATE TABLE dbo.dsc_tipo_trabajo (
    ID_TIPO_TRABAJO        SMALLINT     NOT NULL CONSTRAINT pk_dsc_tipo_trabajo PRIMARY KEY,
    TIPO_TRABAJO           VARCHAR(40)  NOT NULL,
    CLASIFICACION_TRABAJO  VARCHAR(30)  NOT NULL
);

CREATE TABLE dbo.ordenes_trabajo_facts (
    ID_OT            BIGINT        NOT NULL CONSTRAINT pk_ordenes_trabajo_facts PRIMARY KEY,
    ID_CLIENTE       BIGINT        NOT NULL,
    ID_ZONA          INT           NOT NULL CONSTRAINT fk_ot_zona REFERENCES dbo.dsc_zona_geografica (ID_ZONA),
    ID_RED           TINYINT       NOT NULL CONSTRAINT fk_ot_red REFERENCES dbo.dsc_tecnologia_red (ID_RED),
    ID_TIPO_TRABAJO  SMALLINT      NOT NULL CONSTRAINT fk_ot_tipo REFERENCES dbo.dsc_tipo_trabajo (ID_TIPO_TRABAJO),
    FECHA_CREACION   DATETIME2(0)  NOT NULL,
    FECHA_CIERRE     DATETIME2(0)  NULL,
    ESTADO           VARCHAR(20)   NOT NULL
);

CREATE NONCLUSTERED INDEX ix_ot_fecha_cierre
    ON dbo.ordenes_trabajo_facts (FECHA_CIERRE)
    INCLUDE (ID_ZONA, ID_RED, ID_TIPO_TRABAJO, FECHA_CREACION, ESTADO);

CREATE NONCLUSTERED INDEX ix_ot_fecha_creacion
    ON dbo.ordenes_trabajo_facts (FECHA_CREACION)
    INCLUDE (ID_ZONA, ESTADO);

CREATE TABLE dbo.estados_ot_facts (
    ID_EVENTO     BIGINT        NOT NULL CONSTRAINT pk_estados_ot_facts PRIMARY KEY,
    ID_OT         BIGINT        NOT NULL,
    ESTADO        VARCHAR(20)   NOT NULL,
    FECHA_ESTADO  DATETIME2(0)  NOT NULL
);

CREATE NONCLUSTERED INDEX ix_estados_ot_fecha
    ON dbo.estados_ot_facts (ID_OT, FECHA_ESTADO)
    INCLUDE (ESTADO);

CREATE TABLE dbo.capacidad_agenda_facts (
    ID_CAPACIDAD    BIGINT       NOT NULL CONSTRAINT pk_capacidad_agenda_facts PRIMARY KEY,
    FECHA           DATE         NOT NULL,
    ID_ZONA         INT          NOT NULL,
    FRANJA          VARCHAR(5)   NOT NULL,
    CUPOS_TOTALES   SMALLINT     NOT NULL,
    CUPOS_OCUPADOS  SMALLINT     NOT NULL
);

CREATE NONCLUSTERED INDEX ix_capacidad_fecha_zona
    ON dbo.capacidad_agenda_facts (FECHA, ID_ZONA)
    INCLUDE (CUPOS_TOTALES, CUPOS_OCUPADOS);
