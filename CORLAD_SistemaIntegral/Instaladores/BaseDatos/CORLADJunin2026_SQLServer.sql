-- =============================================================================
-- BASE DE DATOS: CORLADJunin2026
-- MOTOR: Microsoft SQL Server 2019 / 2022 / Express / Azure SQL Database
-- DIALECTO: Transact-SQL (T-SQL)
-- TESIS: IMPLEMENTACION DE UN SISTEMA WEB BASADO EN MACHINE LEARNING
--        PARA MEJORAR LA CALIDAD DE SERVICIO EN EL CORLAD JUNIN, 2026
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. CREACION Y CONFIGURACION DE LA BASE DE DATOS
-- -----------------------------------------------------------------------------
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'CORLADJunin2026')
BEGIN
    CREATE DATABASE [CORLADJunin2026]
    COLLATE Modern_Spanish_CI_AS;
END;
GO

ALTER DATABASE [CORLADJunin2026] SET ANSI_NULL_DEFAULT OFF;
ALTER DATABASE [CORLADJunin2026] SET ANSI_NULLS ON;
ALTER DATABASE [CORLADJunin2026] SET ANSI_PADDING ON;
ALTER DATABASE [CORLADJunin2026] SET ANSI_WARNINGS ON;
ALTER DATABASE [CORLADJunin2026] SET ARITHABORT ON;
ALTER DATABASE [CORLADJunin2026] SET AUTO_CLOSE OFF;
ALTER DATABASE [CORLADJunin2026] SET AUTO_SHRINK OFF;
ALTER DATABASE [CORLADJunin2026] SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE [CORLADJunin2026] SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE [CORLADJunin2026] SET RECOVERY FULL;
GO

USE [CORLADJunin2026];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- A. CREACION DE ESQUEMAS INSTITUCIONALES
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Academico') EXEC sys.sp_executesql N'CREATE SCHEMA [Academico]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Calidad') EXEC sys.sp_executesql N'CREATE SCHEMA [Calidad]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Colegiatura') EXEC sys.sp_executesql N'CREATE SCHEMA [Colegiatura]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Finanzas') EXEC sys.sp_executesql N'CREATE SCHEMA [Finanzas]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'MachineLearning') EXEC sys.sp_executesql N'CREATE SCHEMA [MachineLearning]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Persona') EXEC sys.sp_executesql N'CREATE SCHEMA [Persona]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reniec') EXEC sys.sp_executesql N'CREATE SCHEMA [Reniec]';
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Tramite') EXEC sys.sp_executesql N'CREATE SCHEMA [Tramite]';
GO

-- -----------------------------------------------------------------------------
-- B. TIPOS DE DATOS DEFINIDOS POR EL USUARIO (UDT)
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'Dni' AND is_user_defined = 1)
    CREATE TYPE [dbo].[Dni] FROM char(8) NOT NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'Ruc' AND is_user_defined = 1)
    CREATE TYPE [dbo].[Ruc] FROM char(11) NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'Flag' AND is_user_defined = 1)
    CREATE TYPE [dbo].[Flag] FROM bit NOT NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'Name' AND is_user_defined = 1)
    CREATE TYPE [dbo].[Name] FROM nvarchar(50) NOT NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'NumeroExpediente' AND is_user_defined = 1)
    CREATE TYPE [dbo].[NumeroExpediente] FROM char(14) NOT NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'HashSHA256' AND is_user_defined = 1)
    CREATE TYPE [dbo].[HashSHA256] FROM char(64) NULL;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = N'MoneySol' AND is_user_defined = 1)
    CREATE TYPE [dbo].[MoneySol] FROM decimal(12,2) NOT NULL;
GO

-- -----------------------------------------------------------------------------
-- C. CREACION DE TABLAS Y COLUMNAS
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[CORLADBuildVersion] (
    [SystemInformationID] tinyint IDENTITY(1,1) NOT NULL,
    [DatabaseVersion] nvarchar(25) NOT NULL,
    [VersionDate] datetime NOT NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_dbo_CORLADBuildVersion_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_CORLADBuildVersion_SystemInformationID] PRIMARY KEY CLUSTERED ([SystemInformationID] ASC)
);
GO

CREATE TABLE [dbo].[DatabaseLog] (
    [DatabaseLogID] int IDENTITY(1,1) NOT NULL,
    [PostTime] datetime NOT NULL,
    [DatabaseUser] sysname NOT NULL,
    [Event] sysname NOT NULL,
    [Schema] sysname NULL,
    [Object] sysname NULL,
    [TSQL] nvarchar(MAX) NOT NULL,
    [XmlEvent] xml NOT NULL,
    CONSTRAINT [PK_DatabaseLog_DatabaseLogID] PRIMARY KEY NONCLUSTERED ([DatabaseLogID] ASC)
);
GO

CREATE TABLE [dbo].[ErrorLog] (
    [ErrorLogID] int IDENTITY(1,1) NOT NULL,
    [ErrorTime] datetime NOT NULL CONSTRAINT [DF_dbo_ErrorLog_ErrorTime] DEFAULT (getdate()),
    [UserName] sysname NOT NULL,
    [ErrorNumber] int NOT NULL,
    [ErrorSeverity] int NULL,
    [ErrorState] int NULL,
    [ErrorProcedure] nvarchar(126) NULL,
    [ErrorLine] int NULL,
    [ErrorMessage] nvarchar(4000) NOT NULL,
    CONSTRAINT [PK_ErrorLog_ErrorLogID] PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
);
GO

CREATE TABLE [Persona].[Entidad] (
    [EntidadID] int IDENTITY(1,1) NOT NULL,
    [TipoEntidad] nvarchar(20) NOT NULL CONSTRAINT [DF_Persona_Entidad_TipoEntidad] DEFAULT ('PERSONA_NATURAL'),
    [FechaRegistro] datetime NOT NULL CONSTRAINT [DF_Persona_Entidad_FechaRegistro] DEFAULT (getdate()),
    [Activo] [Flag] NOT NULL CONSTRAINT [DF_Persona_Entidad_Activo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Entidad_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Entidad_EntidadID] PRIMARY KEY CLUSTERED ([EntidadID] ASC)
);
GO

CREATE TABLE [Persona].[Persona] (
    [EntidadID] int NOT NULL,
    [Dni] [Dni] NOT NULL,
    [ApellidoPaterno] [Name] NOT NULL,
    [ApellidoMaterno] [Name] NOT NULL,
    [Nombres] nvarchar(100) NOT NULL,
    [Sexo] char(1) NOT NULL,
    [EstadoCivil] char(1) NOT NULL CONSTRAINT [DF_Persona_Persona_EstadoCivil] DEFAULT ('S'),
    [FechaNacimiento] date NOT NULL,
    [EsColegiado] [Flag] NOT NULL CONSTRAINT [DF_Persona_Persona_EsColegiado] DEFAULT ((0)),
    [EsPostulante] [Flag] NOT NULL CONSTRAINT [DF_Persona_Persona_EsPostulante] DEFAULT ((0)),
    [EsEmpleado] [Flag] NOT NULL CONSTRAINT [DF_Persona_Persona_EsEmpleado] DEFAULT ((0)),
    [rowguid] uniqueidentifier NOT NULL CONSTRAINT [DF_Persona_Persona_rowguid] DEFAULT (newid()),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Persona_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Persona_EntidadID] PRIMARY KEY CLUSTERED ([EntidadID] ASC)
);
GO

CREATE TABLE [Persona].[Direccion] (
    [DireccionID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [TipoDireccion] nvarchar(30) NOT NULL CONSTRAINT [DF_Persona_Direccion_TipoDireccion] DEFAULT ('DOMICILIO'),
    [Departamento] nvarchar(50) NOT NULL CONSTRAINT [DF_Persona_Direccion_Departamento] DEFAULT ('JUNIN'),
    [Provincia] nvarchar(50) NOT NULL CONSTRAINT [DF_Persona_Direccion_Provincia] DEFAULT ('HUANCAYO'),
    [Distrito] nvarchar(50) NOT NULL CONSTRAINT [DF_Persona_Direccion_Distrito] DEFAULT ('HUANCAYO'),
    [DireccionDetalle] nvarchar(250) NOT NULL,
    [Referencia] nvarchar(200) NULL,
    [EsPrincipal] [Flag] NOT NULL CONSTRAINT [DF_Persona_Direccion_EsPrincipal] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Direccion_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Direccion_DireccionID] PRIMARY KEY CLUSTERED ([DireccionID] ASC)
);
GO

CREATE TABLE [Persona].[Contacto] (
    [ContactoID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [TipoContacto] nvarchar(20) NOT NULL,
    [ValorContacto] nvarchar(100) NOT NULL,
    [EsPrincipal] [Flag] NOT NULL CONSTRAINT [DF_Persona_Contacto_EsPrincipal] DEFAULT ((1)),
    [Verificado] [Flag] NOT NULL CONSTRAINT [DF_Persona_Contacto_Verificado] DEFAULT ((0)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Contacto_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Contacto_ContactoID] PRIMARY KEY CLUSTERED ([ContactoID] ASC)
);
GO

CREATE TABLE [Persona].[Usuario] (
    [UsuarioID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [Login] nvarchar(50) NOT NULL,
    [PasswordHash] nvarchar(256) NOT NULL,
    [PasswordSalt] nvarchar(100) NOT NULL,
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Persona_Usuario_EsActivo] DEFAULT ((1)),
    [IntentosFallidos] smallint NOT NULL CONSTRAINT [DF_Persona_Usuario_IntentosFallidos] DEFAULT ((0)),
    [BloqueadoHasta] datetime NULL,
    [Requiere2FA] [Flag] NOT NULL CONSTRAINT [DF_Persona_Usuario_Requiere2FA] DEFAULT ((0)),
    [Secret2FA] nvarchar(100) NULL,
    [UltimoAcceso] datetime NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Usuario_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Usuario_UsuarioID] PRIMARY KEY CLUSTERED ([UsuarioID] ASC)
);
GO

CREATE TABLE [Persona].[Rol] (
    [RolID] smallint IDENTITY(1,1) NOT NULL,
    [CodigoRol] nvarchar(20) NOT NULL,
    [NombreRol] nvarchar(50) NOT NULL,
    [Descripcion] nvarchar(250) NOT NULL,
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Persona_Rol_EsActivo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Persona_Rol_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Rol_RolID] PRIMARY KEY CLUSTERED ([RolID] ASC)
);
GO

CREATE TABLE [Persona].[UsuarioRol] (
    [UsuarioID] int NOT NULL,
    [RolID] smallint NOT NULL,
    [FechaAsignacion] datetime NOT NULL CONSTRAINT [DF_Persona_UsuarioRol_FechaAsignacion] DEFAULT (getdate()),
    [AsignadoPor] sysname NOT NULL CONSTRAINT [DF_Persona_UsuarioRol_AsignadoPor] DEFAULT (suser_sname()),
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Persona_UsuarioRol_EsActivo] DEFAULT ((1)),
    CONSTRAINT [PK_UsuarioRol_UsuarioID_RolID] PRIMARY KEY CLUSTERED ([UsuarioID] ASC, [RolID] ASC)
);
GO

CREATE TABLE [Persona].[AuditoriaSesion] (
    [SesionID] bigint IDENTITY(1,1) NOT NULL,
    [UsuarioID] int NULL,
    [FechaInicio] datetime NOT NULL CONSTRAINT [DF_Persona_AuditoriaSesion_FechaInicio] DEFAULT (getdate()),
    [FechaFin] datetime NULL,
    [DireccionIP] nvarchar(45) NOT NULL,
    [Dispositivo] nvarchar(200) NULL,
    [Exitoso] [Flag] NOT NULL,
    [MotivoFallo] nvarchar(150) NULL,
    CONSTRAINT [PK_AuditoriaSesion_SesionID] PRIMARY KEY CLUSTERED ([SesionID] ASC)
);
GO

CREATE TABLE [Reniec].[ParametroConfiguracion] (
    [ParametroID] int IDENTITY(1,1) NOT NULL,
    [Clave] nvarchar(50) NOT NULL,
    [Valor] nvarchar(500) NOT NULL,
    [Descripcion] nvarchar(250) NOT NULL,
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Reniec_ParametroConfiguracion_EsActivo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Reniec_ParametroConfiguracion_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ParametroConfiguracion_ParametroID] PRIMARY KEY CLUSTERED ([ParametroID] ASC)
);
GO

CREATE TABLE [Reniec].[PersonaIdentidadCache] (
    [Dni] [Dni] NOT NULL,
    [DigitoVerificador] char(1) NOT NULL,
    [ApellidoPaterno] nvarchar(50) NOT NULL,
    [ApellidoMaterno] nvarchar(50) NOT NULL,
    [Nombres] nvarchar(100) NOT NULL,
    [EstadoCivil] nvarchar(20) NOT NULL CONSTRAINT [DF_Reniec_PersonaIdentidadCache_EstadoCivil] DEFAULT ('SOLTERO'),
    [RestriccionFallecido] [Flag] NOT NULL CONSTRAINT [DF_Reniec_PersonaIdentidadCache_RestriccionFallecido] DEFAULT ((0)),
    [FotoBinaria] varbinary(MAX) NULL,
    [FotoBase64] nvarchar(MAX) NULL,
    [FechaConsulta] datetime NOT NULL CONSTRAINT [DF_Reniec_PersonaIdentidadCache_FechaConsulta] DEFAULT (getdate()),
    [FechaExpiracionCache] datetime NOT NULL,
    [HashRespuesta] nvarchar(64) NOT NULL,
    CONSTRAINT [PK_PersonaIdentidadCache_Dni] PRIMARY KEY CLUSTERED ([Dni] ASC)
);
GO

CREATE TABLE [Reniec].[ConsultaDniLog] (
    [ConsultaLogID] bigint IDENTITY(1,1) NOT NULL,
    [DniConsultado] [Dni] NOT NULL,
    [UsuarioID] int NULL,
    [FechaConsulta] datetime NOT NULL CONSTRAINT [DF_Reniec_ConsultaDniLog_FechaConsulta] DEFAULT (getdate()),
    [CodigoRespuestaHttp] smallint NOT NULL,
    [EstadoConsulta] nvarchar(30) NOT NULL,
    [MensajeRespuesta] nvarchar(500) NULL,
    [TiempoRespuestaMs] int NOT NULL,
    [DireccionIP] nvarchar(45) NOT NULL,
    [TokenHash] nvarchar(64) NOT NULL,
    [ModuloOrigen] nvarchar(50) NOT NULL CONSTRAINT [DF_Reniec_ConsultaDniLog_ModuloOrigen] DEFAULT ('MESA_PARTES'),
    CONSTRAINT [PK_ConsultaDniLog_ConsultaLogID] PRIMARY KEY CLUSTERED ([ConsultaLogID] ASC)
);
GO

CREATE TABLE [Colegiatura].[Colegiado] (
    [ColegiadoID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [MatriculaRegional] nvarchar(20) NOT NULL,
    [MatriculaNacional] nvarchar(20) NULL,
    [FechaIncorporacion] date NOT NULL,
    [CondicionColegiado] nvarchar(30) NOT NULL CONSTRAINT [DF_Colegiatura_Colegiado_CondicionColegiado] DEFAULT ('ORDINARIO'),
    [EstadoHabilidadActual] nvarchar(30) NOT NULL CONSTRAINT [DF_Colegiatura_Colegiado_EstadoHabilidadActual] DEFAULT ('HABIL'),
    [CantidadCuotasPendientes] smallint NOT NULL CONSTRAINT [DF_Colegiatura_Colegiado_CantidadCuotasPendientes] DEFAULT ((0)),
    [UltimoPeriodoPagado] char(7) NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Colegiatura_Colegiado_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_Colegiado_ColegiadoID] PRIMARY KEY CLUSTERED ([ColegiadoID] ASC)
);
GO

CREATE TABLE [Colegiatura].[ExpedienteColegiatura] (
    [ExpedienteColegiaturaID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [NumeroExpediente] [NumeroExpediente] NOT NULL,
    [FechaPresentacion] datetime NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_FechaPresentacion] DEFAULT (getdate()),
    [EstadoRevision] nvarchar(30) NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_EstadoRevision] DEFAULT ('EN_REVISION'),
    [ValidadoSunedu] [Flag] NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_ValidadoSunedu] DEFAULT ((0)),
    [ValidadoReniec] [Flag] NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_ValidadoReniec] DEFAULT ((0)),
    [AprobadoConsejo] [Flag] NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_AprobadoConsejo] DEFAULT ((0)),
    [NumeroResolucionIncorporacion] nvarchar(50) NULL,
    [FechaJuramentacion] date NULL,
    [Observaciones] nvarchar(MAX) NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Colegiatura_ExpedienteColegiatura_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ExpedienteColegiatura_ExpedienteColegiaturaID] PRIMARY KEY CLUSTERED ([ExpedienteColegiaturaID] ASC)
);
GO

CREATE TABLE [Colegiatura].[TituloProfesional] (
    [TituloID] int IDENTITY(1,1) NOT NULL,
    [EntidadID] int NOT NULL,
    [UniversidadOrigen] nvarchar(150) NOT NULL,
    [DenominacionTitulo] nvarchar(150) NOT NULL CONSTRAINT [DF_Colegiatura_TituloProfesional_DenominacionTitulo] DEFAULT ('LICENCIADO EN ADMINISTRACION'),
    [FechaExpedicion] date NOT NULL,
    [NumeroResolucionSunedu] nvarchar(50) NULL,
    [CodigoRegistroSunedu] nvarchar(50) NOT NULL,
    [VerificadoConSunedu] [Flag] NOT NULL CONSTRAINT [DF_Colegiatura_TituloProfesional_VerificadoConSunedu] DEFAULT ((0)),
    [FechaVerificacion] datetime NULL,
    [DocumentoTituloUrl] nvarchar(300) NULL,
    CONSTRAINT [PK_TituloProfesional_TituloID] PRIMARY KEY CLUSTERED ([TituloID] ASC)
);
GO

CREATE TABLE [Colegiatura].[EstadoHabilidadHistorial] (
    [HistorialHabilidadID] bigint IDENTITY(1,1) NOT NULL,
    [ColegiadoID] int NOT NULL,
    [EstadoHabilidad] nvarchar(30) NOT NULL,
    [MotivoCambio] nvarchar(250) NOT NULL,
    [FechaVigenciaDesde] datetime NOT NULL CONSTRAINT [DF_Colegiatura_EstadoHabilidadHistorial_FechaVigenciaDesde] DEFAULT (getdate()),
    [FechaVigenciaHasta] datetime NULL,
    [RegistradoPor] sysname NOT NULL CONSTRAINT [DF_Colegiatura_EstadoHabilidadHistorial_RegistradoPor] DEFAULT (suser_sname()),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Colegiatura_EstadoHabilidadHistorial_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_EstadoHabilidadHistorial_HistorialHabilidadID] PRIMARY KEY CLUSTERED ([HistorialHabilidadID] ASC)
);
GO

CREATE TABLE [Tramite].[AreaOrganica] (
    [AreaOrganicaID] smallint IDENTITY(1,1) NOT NULL,
    [CodigoArea] nvarchar(10) NOT NULL,
    [NombreArea] nvarchar(100) NOT NULL,
    [ResponsableEntidadID] int NULL,
    [NivelJerarquico] tinyint NOT NULL CONSTRAINT [DF_Tramite_AreaOrganica_NivelJerarquico] DEFAULT ((1)),
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Tramite_AreaOrganica_EsActivo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Tramite_AreaOrganica_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_AreaOrganica_AreaOrganicaID] PRIMARY KEY CLUSTERED ([AreaOrganicaID] ASC)
);
GO

CREATE TABLE [Tramite].[TipoDocumento] (
    [TipoDocumentoID] smallint IDENTITY(1,1) NOT NULL,
    [CodigoTipo] nvarchar(20) NOT NULL,
    [NombreTipo] nvarchar(100) NOT NULL,
    [Descripcion] nvarchar(250) NOT NULL,
    [EsRevisionExhaustiva] [Flag] NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_EsRevisionExhaustiva] DEFAULT ((0)),
    [PlazoMaximoLegalDias] smallint NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_PlazoMaximoLegalDias] DEFAULT ((30)),
    [PlazoSlaEstimadoDias] smallint NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_PlazoSlaEstimadoDias] DEFAULT ((5)),
    [CostoTramite] [MoneySol] NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_CostoTramite] DEFAULT ((0.00)),
    [RequiereReniec] [Flag] NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_RequiereReniec] DEFAULT ((1)),
    [RequiereSunedu] [Flag] NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_RequiereSunedu] DEFAULT ((0)),
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_EsActivo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Tramite_TipoDocumento_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_TipoDocumento_TipoDocumentoID] PRIMARY KEY CLUSTERED ([TipoDocumentoID] ASC)
);
GO

CREATE TABLE [Tramite].[ExpedienteDocumento] (
    [ExpedienteID] int IDENTITY(1,1) NOT NULL,
    [NumeroExpediente] [NumeroExpediente] NOT NULL,
    [TipoDocumentoID] smallint NOT NULL,
    [RemitenteEntidadID] int NOT NULL,
    [DniSolicitante] [Dni] NOT NULL,
    [NombresSolicitante] nvarchar(150) NOT NULL,
    [Asunto] nvarchar(300) NOT NULL,
    [NumeroFolios] smallint NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_NumeroFolios] DEFAULT ((1)),
    [CanalIngreso] nvarchar(20) NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_CanalIngreso] DEFAULT ('VIRTUAL'),
    [Prioridad] nvarchar(20) NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_Prioridad] DEFAULT ('NORMAL'),
    [EstadoExpediente] nvarchar(30) NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_EstadoExpediente] DEFAULT ('REGISTRADO'),
    [AreaActualID] smallint NOT NULL,
    [FechaIngreso] datetime NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_FechaIngreso] DEFAULT (getdate()),
    [FechaCierre] datetime NULL,
    [EsExhaustivo] [Flag] NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_EsExhaustivo] DEFAULT ((0)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Tramite_ExpedienteDocumento_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ExpedienteDocumento_ExpedienteID] PRIMARY KEY CLUSTERED ([ExpedienteID] ASC)
);
GO

CREATE TABLE [Tramite].[DerivacionPaso] (
    [DerivacionPasoID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [PasoNumero] smallint NOT NULL CONSTRAINT [DF_Tramite_DerivacionPaso_PasoNumero] DEFAULT ((1)),
    [AreaOrigenID] smallint NOT NULL,
    [AreaDestinoID] smallint NOT NULL,
    [FuncionarioAsignadoID] int NULL,
    [FechaEnvio] datetime NOT NULL CONSTRAINT [DF_Tramite_DerivacionPaso_FechaEnvio] DEFAULT (getdate()),
    [FechaRecepcion] datetime NULL,
    [FechaAtencion] datetime NULL,
    [ProveidoInstruccion] nvarchar(500) NOT NULL,
    [EstadoPaso] nvarchar(30) NOT NULL CONSTRAINT [DF_Tramite_DerivacionPaso_EstadoPaso] DEFAULT ('EN_TRANSITO'),
    [DuracionMinutos] int NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Tramite_DerivacionPaso_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_DerivacionPaso_DerivacionPasoID] PRIMARY KEY CLUSTERED ([DerivacionPasoID] ASC)
);
GO

CREATE TABLE [Tramite].[DocumentoAdjunto] (
    [DocumentoAdjuntoID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [NombreArchivo] nvarchar(200) NOT NULL,
    [Extension] nvarchar(10) NOT NULL,
    [RutaAlmacenamiento] nvarchar(400) NOT NULL,
    [HashSHA256] [HashSHA256] NOT NULL,
    [TamanoBytes] bigint NOT NULL,
    [TipoMime] nvarchar(50) NOT NULL CONSTRAINT [DF_Tramite_DocumentoAdjunto_TipoMime] DEFAULT ('application/pdf'),
    [FechaCarga] datetime NOT NULL CONSTRAINT [DF_Tramite_DocumentoAdjunto_FechaCarga] DEFAULT (getdate()),
    CONSTRAINT [PK_DocumentoAdjunto_DocumentoAdjuntoID] PRIMARY KEY CLUSTERED ([DocumentoAdjuntoID] ASC)
);
GO

CREATE TABLE [Tramite].[ConstanciaHabilidad] (
    [ConstanciaHabilidadID] int IDENTITY(1,1) NOT NULL,
    [ColegiadoID] int NOT NULL,
    [ExpedienteID] int NULL,
    [CodigoVerificacionQR] nvarchar(100) NOT NULL,
    [NumeroConstancia] nvarchar(30) NOT NULL,
    [FechaEmision] datetime NOT NULL CONSTRAINT [DF_Tramite_ConstanciaHabilidad_FechaEmision] DEFAULT (getdate()),
    [FechaCaducidad] date NOT NULL,
    [HashFirmaDigital] nvarchar(128) NOT NULL,
    [EsValida] [Flag] NOT NULL CONSTRAINT [DF_Tramite_ConstanciaHabilidad_EsValida] DEFAULT ((1)),
    [DescargadoPorEntidadID] int NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Tramite_ConstanciaHabilidad_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ConstanciaHabilidad_ConstanciaHabilidadID] PRIMARY KEY CLUSTERED ([ConstanciaHabilidadID] ASC)
);
GO

CREATE TABLE [MachineLearning].[ModeloPredictivo] (
    [ModeloID] smallint IDENTITY(1,1) NOT NULL,
    [NombreModelo] nvarchar(100) NOT NULL,
    [VersionModelo] nvarchar(20) NOT NULL,
    [TipoAlgoritmo] nvarchar(50) NOT NULL,
    [TipoTarea] nvarchar(30) NOT NULL CONSTRAINT [DF_MachineLearning_ModeloPredictivo_TipoTarea] DEFAULT ('REGRESION'),
    [HiperparametrosJson] nvarchar(MAX) NOT NULL,
    [MetricaR2] decimal(6,4) NULL,
    [MetricaMAE] decimal(8,4) NULL,
    [MetricaRMSE] decimal(8,4) NULL,
    [Exactitud] decimal(6,4) NULL,
    [FechaEntrenamiento] datetime NOT NULL CONSTRAINT [DF_MachineLearning_ModeloPredictivo_FechaEntrenamiento] DEFAULT (getdate()),
    [EsModeloActivo] [Flag] NOT NULL CONSTRAINT [DF_MachineLearning_ModeloPredictivo_EsModeloActivo] DEFAULT ((0)),
    [NotasModelo] nvarchar(500) NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_MachineLearning_ModeloPredictivo_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ModeloPredictivo_ModeloID] PRIMARY KEY CLUSTERED ([ModeloID] ASC)
);
GO

CREATE TABLE [MachineLearning].[MetricaRendimiento] (
    [MetricaID] int IDENTITY(1,1) NOT NULL,
    [ModeloID] smallint NOT NULL,
    [FechaEvaluacion] datetime NOT NULL CONSTRAINT [DF_MachineLearning_MetricaRendimiento_FechaEvaluacion] DEFAULT (getdate()),
    [TipoDataset] nvarchar(20) NOT NULL CONSTRAINT [DF_MachineLearning_MetricaRendimiento_TipoDataset] DEFAULT ('TEST'),
    [MuestrasEvaluadas] int NOT NULL,
    [MAE] decimal(8,4) NOT NULL,
    [RMSE] decimal(8,4) NOT NULL,
    [R2] decimal(6,4) NOT NULL,
    [F1Score] decimal(6,4) NULL,
    [Observaciones] nvarchar(250) NULL,
    CONSTRAINT [PK_MetricaRendimiento_MetricaID] PRIMARY KEY CLUSTERED ([MetricaID] ASC)
);
GO

CREATE TABLE [MachineLearning].[DatasetHistoricoTramite] (
    [RegistroHistoricoID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [TipoDocumentoID] smallint NOT NULL,
    [EsRevisionExhaustiva] [Flag] NOT NULL,
    [NumeroFolios] smallint NOT NULL,
    [AreaFinalID] smallint NOT NULL,
    [CargaLaboralColaEnIngreso] int NOT NULL,
    [CantidadRequisitosCumplidos] smallint NOT NULL,
    [MesIngreso] tinyint NOT NULL,
    [DiaSemana] tinyint NOT NULL,
    [HoraIngreso] tinyint NOT NULL,
    [RequiereValidacionExterna] [Flag] NOT NULL,
    [TuvoObservacionesPrevias] [Flag] NOT NULL,
    [DiasRealesAtencion] decimal(6,2) NOT NULL,
    [HorasRealesAtencion] decimal(8,2) NOT NULL,
    [CumplioSLA] [Flag] NOT NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_MachineLearning_DatasetHistoricoTramite_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_DatasetHistoricoTramite_RegistroHistoricoID] PRIMARY KEY CLUSTERED ([RegistroHistoricoID] ASC)
);
GO

CREATE TABLE [MachineLearning].[PrediccionEntregaDocumento] (
    [PrediccionID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [ModeloID] smallint NOT NULL,
    [DiasEstimadosEntrega] decimal(6,2) NOT NULL,
    [HorasEstimadasEntrega] decimal(8,2) NOT NULL,
    [FechaEstimadaEntrega] datetime NOT NULL,
    [IntervaloConfianzaMin] datetime NOT NULL,
    [IntervaloConfianzaMax] datetime NOT NULL,
    [ProbabilidadRetraso] decimal(5,4) NOT NULL CONSTRAINT [DF_MachineLearning_PrediccionEntregaDocumento_ProbabilidadRetraso] DEFAULT ((0.0000)),
    [NivelRiesgoRetraso] nvarchar(20) NOT NULL CONSTRAINT [DF_MachineLearning_PrediccionEntregaDocumento_NivelRiesgoRetraso] DEFAULT ('BAJO'),
    [FechaPrediccion] datetime NOT NULL CONSTRAINT [DF_MachineLearning_PrediccionEntregaDocumento_FechaPrediccion] DEFAULT (getdate()),
    [FechaRealEntrega] datetime NULL,
    [ErrorAbsolutoDias] decimal(6,2) NULL,
    [EsPrediccionAcertada] [Flag] NULL,
    [FeedbackCalidadPrediccion] nvarchar(250) NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_MachineLearning_PrediccionEntregaDocumento_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_PrediccionEntregaDocumento_PrediccionID] PRIMARY KEY CLUSTERED ([PrediccionID] ASC)
);
GO

CREATE TABLE [MachineLearning].[AlertaCuelloBotella] (
    [AlertaID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [PrediccionID] bigint NULL,
    [AreaOrganicaID] smallint NOT NULL,
    [NivelSeveridad] nvarchar(20) NOT NULL CONSTRAINT [DF_MachineLearning_AlertaCuelloBotella_NivelSeveridad] DEFAULT ('MEDIO'),
    [MensajeAlerta] nvarchar(300) NOT NULL,
    [FechaGeneracion] datetime NOT NULL CONSTRAINT [DF_MachineLearning_AlertaCuelloBotella_FechaGeneracion] DEFAULT (getdate()),
    [AtendidoPorUsuarioID] int NULL,
    [FechaResolucion] datetime NULL,
    [EstadoAlerta] nvarchar(20) NOT NULL CONSTRAINT [DF_MachineLearning_AlertaCuelloBotella_EstadoAlerta] DEFAULT ('PENDIENTE'),
    CONSTRAINT [PK_AlertaCuelloBotella_AlertaID] PRIMARY KEY CLUSTERED ([AlertaID] ASC)
);
GO

CREATE TABLE [Calidad].[EncuestaServqual] (
    [EncuestaID] bigint IDENTITY(1,1) NOT NULL,
    [ExpedienteID] int NOT NULL,
    [EntidadEvaluadorID] int NULL,
    [FechaRespuesta] datetime NOT NULL CONSTRAINT [DF_Calidad_EncuestaServqual_FechaRespuesta] DEFAULT (getdate()),
    [P1_Fiabilidad] tinyint NOT NULL,
    [P2_CapacidadRespuesta] tinyint NOT NULL,
    [P3_Seguridad] tinyint NOT NULL,
    [P4_Empatia] tinyint NOT NULL,
    [P5_ElementosTangibles] tinyint NOT NULL,
    [PuntuacionGlobal] decimal(4,2) NOT NULL,
    [TiempoEntregaPercibido] nvarchar(30) NOT NULL CONSTRAINT [DF_Calidad_EncuestaServqual_TiempoEntregaPercibido] DEFAULT ('ADECUADO'),
    [Comentarios] nvarchar(500) NULL,
    CONSTRAINT [PK_EncuestaServqual_EncuestaID] PRIMARY KEY CLUSTERED ([EncuestaID] ASC)
);
GO

CREATE TABLE [Calidad].[LibroReclamacion] (
    [ReclamoID] int IDENTITY(1,1) NOT NULL,
    [NumeroHojaReclamo] nvarchar(20) NOT NULL,
    [EntidadReclamanteID] int NOT NULL,
    [ExpedienteRelacionadoID] int NULL,
    [TipoIncidencia] nvarchar(20) NOT NULL CONSTRAINT [DF_Calidad_LibroReclamacion_TipoIncidencia] DEFAULT ('RECLAMO'),
    [DetalleReclamo] nvarchar(MAX) NOT NULL,
    [PedidoConcreto] nvarchar(500) NOT NULL,
    [FechaRegistro] datetime NOT NULL CONSTRAINT [DF_Calidad_LibroReclamacion_FechaRegistro] DEFAULT (getdate()),
    [FechaLimiteRespuesta] date NOT NULL,
    [RespuestaInstitucional] nvarchar(MAX) NULL,
    [FechaRespuesta] datetime NULL,
    [EstadoReclamo] nvarchar(20) NOT NULL CONSTRAINT [DF_Calidad_LibroReclamacion_EstadoReclamo] DEFAULT ('PENDIENTE'),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Calidad_LibroReclamacion_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_LibroReclamacion_ReclamoID] PRIMARY KEY CLUSTERED ([ReclamoID] ASC)
);
GO

CREATE TABLE [Calidad].[IndicadorCalidadSLA] (
    [IndicadorID] int IDENTITY(1,1) NOT NULL,
    [TipoDocumentoID] smallint NOT NULL,
    [PeriodoAnioMes] char(7) NOT NULL,
    [TotalTramitesAtendidos] int NOT NULL,
    [TotalCumplieronSla] int NOT NULL,
    [PorcentajeCumplimientoSla] decimal(5,2) NOT NULL,
    [PromedioDiasAtencion] decimal(6,2) NOT NULL,
    [PromedioServqual] decimal(4,2) NOT NULL,
    [ErrorPromedioMLDias] decimal(6,2) NOT NULL,
    [FechaCalculo] datetime NOT NULL CONSTRAINT [DF_Calidad_IndicadorCalidadSLA_FechaCalculo] DEFAULT (getdate()),
    CONSTRAINT [PK_IndicadorCalidadSLA_IndicadorID] PRIMARY KEY CLUSTERED ([IndicadorID] ASC)
);
GO

CREATE TABLE [Academico].[EventoCapacitacion] (
    [EventoID] int IDENTITY(1,1) NOT NULL,
    [CodigoEvento] nvarchar(20) NOT NULL,
    [TituloEvento] nvarchar(200) NOT NULL,
    [TipoEvento] nvarchar(50) NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_TipoEvento] DEFAULT ('CURSO'),
    [HorasAcademicas] smallint NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_HorasAcademicas] DEFAULT ((40)),
    [CreditosAcademicos] decimal(4,2) NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_CreditosAcademicos] DEFAULT ((2.00)),
    [FechaInicio] date NOT NULL,
    [FechaFin] date NOT NULL,
    [CostoGeneral] [MoneySol] NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_CostoGeneral] DEFAULT ((0.00)),
    [CostoColegiado] [MoneySol] NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_CostoColegiado] DEFAULT ((0.00)),
    [EstadoEvento] nvarchar(30) NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_EstadoEvento] DEFAULT ('PLANIFICADO'),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Academico_EventoCapacitacion_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_EventoCapacitacion_EventoID] PRIMARY KEY CLUSTERED ([EventoID] ASC)
);
GO

CREATE TABLE [Academico].[InscripcionParticipante] (
    [InscripcionID] bigint IDENTITY(1,1) NOT NULL,
    [EventoID] int NOT NULL,
    [EntidadID] int NOT NULL,
    [FechaInscripcion] datetime NOT NULL CONSTRAINT [DF_Academico_InscripcionParticipante_FechaInscripcion] DEFAULT (getdate()),
    [ComprobantePagoID] bigint NULL,
    [NotaFinal] decimal(4,2) NULL,
    [PorcentajeAsistencia] decimal(5,2) NULL,
    [EstadoAprobacion] nvarchar(30) NOT NULL CONSTRAINT [DF_Academico_InscripcionParticipante_EstadoAprobacion] DEFAULT ('MATRICULADO'),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Academico_InscripcionParticipante_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_InscripcionParticipante_InscripcionID] PRIMARY KEY CLUSTERED ([InscripcionID] ASC)
);
GO

CREATE TABLE [Academico].[CertificadoAcademico] (
    [CertificadoID] bigint IDENTITY(1,1) NOT NULL,
    [InscripcionID] bigint NOT NULL,
    [CodigoCertificado] nvarchar(30) NOT NULL,
    [TipoCertificado] nvarchar(30) NOT NULL CONSTRAINT [DF_Academico_CertificadoAcademico_TipoCertificado] DEFAULT ('APROBACION'),
    [HashQr] nvarchar(128) NOT NULL,
    [FechaEmision] datetime NOT NULL CONSTRAINT [DF_Academico_CertificadoAcademico_FechaEmision] DEFAULT (getdate()),
    [UrlVerificacionPublica] nvarchar(300) NOT NULL,
    [EsRevocado] [Flag] NOT NULL CONSTRAINT [DF_Academico_CertificadoAcademico_EsRevocado] DEFAULT ((0)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Academico_CertificadoAcademico_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_CertificadoAcademico_CertificadoID] PRIMARY KEY CLUSTERED ([CertificadoID] ASC)
);
GO

CREATE TABLE [Finanzas].[ConceptoPago] (
    [ConceptoID] smallint IDENTITY(1,1) NOT NULL,
    [CodigoConcepto] nvarchar(20) NOT NULL,
    [Descripcion] nvarchar(150) NOT NULL,
    [MontoBase] [MoneySol] NOT NULL CONSTRAINT [DF_Finanzas_ConceptoPago_MontoBase] DEFAULT ((0.00)),
    [AplicaMora] [Flag] NOT NULL CONSTRAINT [DF_Finanzas_ConceptoPago_AplicaMora] DEFAULT ((0)),
    [PorcentajeMora] decimal(5,2) NOT NULL CONSTRAINT [DF_Finanzas_ConceptoPago_PorcentajeMora] DEFAULT ((0.00)),
    [EsActivo] [Flag] NOT NULL CONSTRAINT [DF_Finanzas_ConceptoPago_EsActivo] DEFAULT ((1)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Finanzas_ConceptoPago_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ConceptoPago_ConceptoID] PRIMARY KEY CLUSTERED ([ConceptoID] ASC)
);
GO

CREATE TABLE [Finanzas].[CuotaMensualColegiado] (
    [CuotaID] bigint IDENTITY(1,1) NOT NULL,
    [ColegiadoID] int NOT NULL,
    [PeriodoAnioMes] char(7) NOT NULL,
    [Monto] [MoneySol] NOT NULL CONSTRAINT [DF_Finanzas_CuotaMensualColegiado_Monto] DEFAULT ((20.00)),
    [MontoMora] [MoneySol] NOT NULL CONSTRAINT [DF_Finanzas_CuotaMensualColegiado_MontoMora] DEFAULT ((0.00)),
    [FechaVencimiento] date NOT NULL,
    [EstadoCuota] nvarchar(20) NOT NULL CONSTRAINT [DF_Finanzas_CuotaMensualColegiado_EstadoCuota] DEFAULT ('PENDIENTE'),
    [ComprobantePagoID] bigint NULL,
    [FechaPago] datetime NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Finanzas_CuotaMensualColegiado_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_CuotaMensualColegiado_CuotaID] PRIMARY KEY CLUSTERED ([CuotaID] ASC)
);
GO

CREATE TABLE [Finanzas].[ComprobantePago] (
    [ComprobantePagoID] bigint IDENTITY(1,1) NOT NULL,
    [EntidadClienteID] int NOT NULL,
    [TipoComprobante] nvarchar(20) NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_TipoComprobante] DEFAULT ('BOLETA'),
    [Serie] nvarchar(10) NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_Serie] DEFAULT ('B001'),
    [Correlativo] int NOT NULL,
    [FechaEmision] datetime NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_FechaEmision] DEFAULT (getdate()),
    [SubTotal] [MoneySol] NOT NULL,
    [Igv] [MoneySol] NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_Igv] DEFAULT ((0.00)),
    [Total] [MoneySol] NOT NULL,
    [MetodoPago] nvarchar(30) NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_MetodoPago] DEFAULT ('EFECTIVO'),
    [NumeroOperacionBancaria] nvarchar(50) NULL,
    [HashSunat] nvarchar(128) NULL,
    [EstadoSunat] nvarchar(30) NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_EstadoSunat] DEFAULT ('ACEPTADO'),
    [UsuarioCajeroID] int NOT NULL,
    [Conciliado] [Flag] NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_Conciliado] DEFAULT ((0)),
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Finanzas_ComprobantePago_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ComprobantePago_ComprobantePagoID] PRIMARY KEY CLUSTERED ([ComprobantePagoID] ASC)
);
GO

CREATE TABLE [Finanzas].[ComprobanteDetalle] (
    [ComprobanteDetalleID] bigint IDENTITY(1,1) NOT NULL,
    [ComprobantePagoID] bigint NOT NULL,
    [ConceptoID] smallint NOT NULL,
    [DescripcionConcepto] nvarchar(150) NOT NULL,
    [Cantidad] smallint NOT NULL CONSTRAINT [DF_Finanzas_ComprobanteDetalle_Cantidad] DEFAULT ((1)),
    [PrecioUnitario] [MoneySol] NOT NULL,
    [SubTotal] [MoneySol] NOT NULL,
    CONSTRAINT [PK_ComprobanteDetalle_ComprobanteDetalleID] PRIMARY KEY CLUSTERED ([ComprobanteDetalleID] ASC)
);
GO

CREATE TABLE [Finanzas].[ConciliacionBancaria] (
    [ConciliacionID] int IDENTITY(1,1) NOT NULL,
    [FechaRecaudacion] date NOT NULL,
    [FechaDeposito] datetime NOT NULL,
    [BancoCuenta] nvarchar(100) NOT NULL CONSTRAINT [DF_Finanzas_ConciliacionBancaria_BancoCuenta] DEFAULT ('BANCO DE LA NACION - CTA CTE CORLAD'),
    [NumeroOperacion] nvarchar(50) NOT NULL,
    [MontoCajaFisica] [MoneySol] NOT NULL,
    [MontoDepositado] [MoneySol] NOT NULL,
    [Diferencia] [MoneySol] NOT NULL CONSTRAINT [DF_Finanzas_ConciliacionBancaria_Diferencia] DEFAULT ((0.00)),
    [HorasTranscurridas] smallint NOT NULL,
    [CumplePlazo48h] [Flag] NOT NULL CONSTRAINT [DF_Finanzas_ConciliacionBancaria_CumplePlazo48h] DEFAULT ((1)),
    [UsuarioResponsableID] int NOT NULL,
    [Observaciones] nvarchar(300) NULL,
    [ModifiedDate] datetime NOT NULL CONSTRAINT [DF_Finanzas_ConciliacionBancaria_ModifiedDate] DEFAULT (getdate()),
    CONSTRAINT [PK_ConciliacionBancaria_ConciliacionID] PRIMARY KEY CLUSTERED ([ConciliacionID] ASC)
);
GO

-- -----------------------------------------------------------------------------
-- D. CREACION DE RESTRICCIONES CHECK
-- -----------------------------------------------------------------------------
ALTER TABLE [Persona].[Entidad] WITH CHECK ADD CONSTRAINT [CK_Entidad_TipoEntidad] CHECK (([TipoEntidad]='PERSONA_NATURAL' OR [TipoEntidad]='PERSONA_JURIDICA'));
ALTER TABLE [Persona].[Entidad] CHECK CONSTRAINT [CK_Entidad_TipoEntidad];
ALTER TABLE [Persona].[Persona] WITH CHECK ADD CONSTRAINT [CK_Persona_Dni] CHECK ((len([Dni])=(8) AND NOT [Dni] like '%[^0-9]%'));
ALTER TABLE [Persona].[Persona] CHECK CONSTRAINT [CK_Persona_Dni];
ALTER TABLE [Persona].[Persona] WITH CHECK ADD CONSTRAINT [CK_Persona_Sexo] CHECK ((upper([Sexo])='M' OR upper([Sexo])='F'));
ALTER TABLE [Persona].[Persona] CHECK CONSTRAINT [CK_Persona_Sexo];
ALTER TABLE [Persona].[Persona] WITH CHECK ADD CONSTRAINT [CK_Persona_EstadoCivil] CHECK ((upper([EstadoCivil])='S' OR upper([EstadoCivil])='C' OR upper([EstadoCivil])='V' OR upper([EstadoCivil])='D'));
ALTER TABLE [Persona].[Persona] CHECK CONSTRAINT [CK_Persona_EstadoCivil];
ALTER TABLE [Persona].[Persona] WITH CHECK ADD CONSTRAINT [CK_Persona_FechaNacimiento] CHECK (([FechaNacimiento]>='1920-01-01' AND [FechaNacimiento]<=dateadd(year,(-17),getdate())));
ALTER TABLE [Persona].[Persona] CHECK CONSTRAINT [CK_Persona_FechaNacimiento];
ALTER TABLE [Persona].[Contacto] WITH CHECK ADD CONSTRAINT [CK_Contacto_TipoContacto] CHECK (([TipoContacto]='CELULAR' OR [TipoContacto]='TELEFONO_FIJO' OR [TipoContacto]='EMAIL_PERSONAL' OR [TipoContacto]='EMAIL_INSTITUCIONAL'));
ALTER TABLE [Persona].[Contacto] CHECK CONSTRAINT [CK_Contacto_TipoContacto];
ALTER TABLE [Persona].[Usuario] WITH CHECK ADD CONSTRAINT [CK_Usuario_IntentosFallidos] CHECK (([IntentosFallidos]>=(0) AND [IntentosFallidos]<=(10)));
ALTER TABLE [Persona].[Usuario] CHECK CONSTRAINT [CK_Usuario_IntentosFallidos];
ALTER TABLE [Reniec].[PersonaIdentidadCache] WITH CHECK ADD CONSTRAINT [CK_PersonaIdentidadCache_Dni] CHECK ((len([Dni])=(8) AND NOT [Dni] like '%[^0-9]%'));
ALTER TABLE [Reniec].[PersonaIdentidadCache] CHECK CONSTRAINT [CK_PersonaIdentidadCache_Dni];
ALTER TABLE [Reniec].[ConsultaDniLog] WITH CHECK ADD CONSTRAINT [CK_ConsultaDniLog_TiempoRespuestaMs] CHECK (([TiempoRespuestaMs]>=(0)));
ALTER TABLE [Reniec].[ConsultaDniLog] CHECK CONSTRAINT [CK_ConsultaDniLog_TiempoRespuestaMs];
ALTER TABLE [Colegiatura].[Colegiado] WITH CHECK ADD CONSTRAINT [CK_Colegiado_Condicion] CHECK (([CondicionColegiado]='ORDINARIO' OR [CondicionColegiado]='VITALICIO' OR [CondicionColegiado]='FALLECIDO' OR [CondicionColegiado]='TRASLADADO'));
ALTER TABLE [Colegiatura].[Colegiado] CHECK CONSTRAINT [CK_Colegiado_Condicion];
ALTER TABLE [Colegiatura].[Colegiado] WITH CHECK ADD CONSTRAINT [CK_Colegiado_EstadoHabilidad] CHECK (([EstadoHabilidadActual]='HABIL' OR [EstadoHabilidadActual]='INHABILITADO_DEUDA' OR [EstadoHabilidadActual]='INHABILITADO_SANCION'));
ALTER TABLE [Colegiatura].[Colegiado] CHECK CONSTRAINT [CK_Colegiado_EstadoHabilidad];
ALTER TABLE [Colegiatura].[Colegiado] WITH CHECK ADD CONSTRAINT [CK_Colegiado_CuotasPendientes] CHECK (([CantidadCuotasPendientes]>=(0)));
ALTER TABLE [Colegiatura].[Colegiado] CHECK CONSTRAINT [CK_Colegiado_CuotasPendientes];
ALTER TABLE [Colegiatura].[ExpedienteColegiatura] WITH CHECK ADD CONSTRAINT [CK_ExpedienteColegiatura_Estado] CHECK (([EstadoRevision]='REGISTRADO' OR [EstadoRevision]='EN_REVISION' OR [EstadoRevision]='OBSERVADO' OR [EstadoRevision]='APROBADO_CONSEJO' OR [EstadoRevision]='ELEVADO_LIMA' OR [EstadoRevision]='LISTO_JURAMENTACION' OR [EstadoRevision]='CONCLUIDO'));
ALTER TABLE [Colegiatura].[ExpedienteColegiatura] CHECK CONSTRAINT [CK_ExpedienteColegiatura_Estado];
ALTER TABLE [Colegiatura].[EstadoHabilidadHistorial] WITH CHECK ADD CONSTRAINT [CK_EstadoHabilidadHistorial_Estado] CHECK (([EstadoHabilidad]='HABIL' OR [EstadoHabilidad]='INHABILITADO_DEUDA' OR [EstadoHabilidad]='INHABILITADO_SANCION'));
ALTER TABLE [Colegiatura].[EstadoHabilidadHistorial] CHECK CONSTRAINT [CK_EstadoHabilidadHistorial_Estado];
ALTER TABLE [Tramite].[TipoDocumento] WITH CHECK ADD CONSTRAINT [CK_TipoDocumento_CostoTramite] CHECK (([CostoTramite]>=(0.00)));
ALTER TABLE [Tramite].[TipoDocumento] CHECK CONSTRAINT [CK_TipoDocumento_CostoTramite];
ALTER TABLE [Tramite].[TipoDocumento] WITH CHECK ADD CONSTRAINT [CK_TipoDocumento_Plazos] CHECK (([PlazoSlaEstimadoDias]>=(0) AND [PlazoMaximoLegalDias]>=[PlazoSlaEstimadoDias]));
ALTER TABLE [Tramite].[TipoDocumento] CHECK CONSTRAINT [CK_TipoDocumento_Plazos];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [CK_ExpedienteDocumento_Folios] CHECK (([NumeroFolios]>=(1)));
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [CK_ExpedienteDocumento_Folios];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [CK_ExpedienteDocumento_Canal] CHECK (([CanalIngreso]='VIRTUAL' OR [CanalIngreso]='PRESENCIAL'));
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [CK_ExpedienteDocumento_Canal];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [CK_ExpedienteDocumento_Prioridad] CHECK (([Prioridad]='BAJA' OR [Prioridad]='NORMAL' OR [Prioridad]='ALTA' OR [Prioridad]='URGENTE'));
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [CK_ExpedienteDocumento_Prioridad];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [CK_ExpedienteDocumento_Estado] CHECK (([EstadoExpediente]='REGISTRADO' OR [EstadoExpediente]='DERIVADO' OR [EstadoExpediente]='EN_EVALUACION' OR [EstadoExpediente]='OBSERVADO' OR [EstadoExpediente]='ATENDIDO' OR [EstadoExpediente]='ARCHIVADO'));
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [CK_ExpedienteDocumento_Estado];
ALTER TABLE [Tramite].[DerivacionPaso] WITH CHECK ADD CONSTRAINT [CK_DerivacionPaso_Estado] CHECK (([EstadoPaso]='EN_TRANSITO' OR [EstadoPaso]='RECIBIDO' OR [EstadoPaso]='ATENDIDO' OR [EstadoPaso]='DEVUELTO'));
ALTER TABLE [Tramite].[DerivacionPaso] CHECK CONSTRAINT [CK_DerivacionPaso_Estado];
ALTER TABLE [Tramite].[DocumentoAdjunto] WITH CHECK ADD CONSTRAINT [CK_DocumentoAdjunto_Tamano] CHECK (([TamanoBytes]>(0)));
ALTER TABLE [Tramite].[DocumentoAdjunto] CHECK CONSTRAINT [CK_DocumentoAdjunto_Tamano];
ALTER TABLE [Tramite].[ConstanciaHabilidad] WITH CHECK ADD CONSTRAINT [CK_ConstanciaHabilidad_Fechas] CHECK (([FechaCaducidad]>=cast([FechaEmision] as date)));
ALTER TABLE [Tramite].[ConstanciaHabilidad] CHECK CONSTRAINT [CK_ConstanciaHabilidad_Fechas];
ALTER TABLE [MachineLearning].[ModeloPredictivo] WITH CHECK ADD CONSTRAINT [CK_ModeloPredictivo_Tarea] CHECK (([TipoTarea]='REGRESION' OR [TipoTarea]='CLASIFICACION'));
ALTER TABLE [MachineLearning].[ModeloPredictivo] CHECK CONSTRAINT [CK_ModeloPredictivo_Tarea];
ALTER TABLE [MachineLearning].[MetricaRendimiento] WITH CHECK ADD CONSTRAINT [CK_MetricaRendimiento_Muestras] CHECK (([MuestrasEvaluadas]>(0)));
ALTER TABLE [MachineLearning].[MetricaRendimiento] CHECK CONSTRAINT [CK_MetricaRendimiento_Muestras];
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] WITH CHECK ADD CONSTRAINT [CK_DatasetHistoricoTramite_Mes] CHECK (([MesIngreso]>=(1) AND [MesIngreso]<=(12)));
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] CHECK CONSTRAINT [CK_DatasetHistoricoTramite_Mes];
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] WITH CHECK ADD CONSTRAINT [CK_DatasetHistoricoTramite_DiaSemana] CHECK (([DiaSemana]>=(1) AND [DiaSemana]<=(7)));
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] CHECK CONSTRAINT [CK_DatasetHistoricoTramite_DiaSemana];
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] WITH CHECK ADD CONSTRAINT [CK_DatasetHistoricoTramite_HorasReales] CHECK (([HorasRealesAtencion]>=(0.00)));
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] CHECK CONSTRAINT [CK_DatasetHistoricoTramite_HorasReales];
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] WITH CHECK ADD CONSTRAINT [CK_PrediccionEntregaDocumento_Probabilidad] CHECK (([ProbabilidadRetraso]>=(0.0000) AND [ProbabilidadRetraso]<=(1.0000)));
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] CHECK CONSTRAINT [CK_PrediccionEntregaDocumento_Probabilidad];
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] WITH CHECK ADD CONSTRAINT [CK_PrediccionEntregaDocumento_Riesgo] CHECK (([NivelRiesgoRetraso]='BAJO' OR [NivelRiesgoRetraso]='MEDIO' OR [NivelRiesgoRetraso]='ALTO' OR [NivelRiesgoRetraso]='CRITICO'));
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] CHECK CONSTRAINT [CK_PrediccionEntregaDocumento_Riesgo];
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] WITH CHECK ADD CONSTRAINT [CK_PrediccionEntregaDocumento_DiasEstimados] CHECK (([DiasEstimadosEntrega]>=(0.00)));
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] CHECK CONSTRAINT [CK_PrediccionEntregaDocumento_DiasEstimados];
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] WITH CHECK ADD CONSTRAINT [CK_AlertaCuelloBotella_Severidad] CHECK (([NivelSeveridad]='BAJA' OR [NivelSeveridad]='MEDIA' OR [NivelSeveridad]='ALTA' OR [NivelSeveridad]='CRITICA'));
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] CHECK CONSTRAINT [CK_AlertaCuelloBotella_Severidad];
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] WITH CHECK ADD CONSTRAINT [CK_AlertaCuelloBotella_Estado] CHECK (([EstadoAlerta]='PENDIENTE' OR [EstadoAlerta]='EN_ATENCION' OR [EstadoAlerta]='RESUELTA' OR [EstadoAlerta]='DESCARTADA'));
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] CHECK CONSTRAINT [CK_AlertaCuelloBotella_Estado];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_P1] CHECK (([P1_Fiabilidad]>=(1) AND [P1_Fiabilidad]<=(5)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_P1];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_P2] CHECK (([P2_CapacidadRespuesta]>=(1) AND [P2_CapacidadRespuesta]<=(5)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_P2];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_P3] CHECK (([P3_Seguridad]>=(1) AND [P3_Seguridad]<=(5)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_P3];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_P4] CHECK (([P4_Empatia]>=(1) AND [P4_Empatia]<=(5)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_P4];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_P5] CHECK (([P5_ElementosTangibles]>=(1) AND [P5_ElementosTangibles]<=(5)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_P5];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [CK_EncuestaServqual_Global] CHECK (([PuntuacionGlobal]>=(1.00) AND [PuntuacionGlobal]<=(5.00)));
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [CK_EncuestaServqual_Global];
ALTER TABLE [Calidad].[LibroReclamacion] WITH CHECK ADD CONSTRAINT [CK_LibroReclamacion_Tipo] CHECK (([TipoIncidencia]='QUEJA' OR [TipoIncidencia]='RECLAMO'));
ALTER TABLE [Calidad].[LibroReclamacion] CHECK CONSTRAINT [CK_LibroReclamacion_Tipo];
ALTER TABLE [Calidad].[LibroReclamacion] WITH CHECK ADD CONSTRAINT [CK_LibroReclamacion_Estado] CHECK (([EstadoReclamo]='PENDIENTE' OR [EstadoReclamo]='EN_INVESTIGACION' OR [EstadoReclamo]='RESUELTO' OR [EstadoReclamo]='CERRADO'));
ALTER TABLE [Calidad].[LibroReclamacion] CHECK CONSTRAINT [CK_LibroReclamacion_Estado];
ALTER TABLE [Calidad].[IndicadorCalidadSLA] WITH CHECK ADD CONSTRAINT [CK_IndicadorCalidadSLA_Porcentaje] CHECK (([PorcentajeCumplimientoSla]>=(0.00) AND [PorcentajeCumplimientoSla]<=(100.00)));
ALTER TABLE [Calidad].[IndicadorCalidadSLA] CHECK CONSTRAINT [CK_IndicadorCalidadSLA_Porcentaje];
ALTER TABLE [Academico].[EventoCapacitacion] WITH CHECK ADD CONSTRAINT [CK_EventoCapacitacion_Horas] CHECK (([HorasAcademicas]>(0)));
ALTER TABLE [Academico].[EventoCapacitacion] CHECK CONSTRAINT [CK_EventoCapacitacion_Horas];
ALTER TABLE [Academico].[EventoCapacitacion] WITH CHECK ADD CONSTRAINT [CK_EventoCapacitacion_Fechas] CHECK (([FechaFin]>=[FechaInicio]));
ALTER TABLE [Academico].[EventoCapacitacion] CHECK CONSTRAINT [CK_EventoCapacitacion_Fechas];
ALTER TABLE [Academico].[InscripcionParticipante] WITH CHECK ADD CONSTRAINT [CK_InscripcionParticipante_Nota] CHECK (([NotaFinal]>=(0.00) AND [NotaFinal]<=(20.00) OR [NotaFinal] IS NULL));
ALTER TABLE [Academico].[InscripcionParticipante] CHECK CONSTRAINT [CK_InscripcionParticipante_Nota];
ALTER TABLE [Academico].[InscripcionParticipante] WITH CHECK ADD CONSTRAINT [CK_InscripcionParticipante_Asistencia] CHECK (([PorcentajeAsistencia]>=(0.00) AND [PorcentajeAsistencia]<=(100.00) OR [PorcentajeAsistencia] IS NULL));
ALTER TABLE [Academico].[InscripcionParticipante] CHECK CONSTRAINT [CK_InscripcionParticipante_Asistencia];
ALTER TABLE [Academico].[CertificadoAcademico] WITH CHECK ADD CONSTRAINT [CK_CertificadoAcademico_Tipo] CHECK (([TipoCertificado]='APROBACION' OR [TipoCertificado]='ASISTENCIA'));
ALTER TABLE [Academico].[CertificadoAcademico] CHECK CONSTRAINT [CK_CertificadoAcademico_Tipo];
ALTER TABLE [Finanzas].[ConceptoPago] WITH CHECK ADD CONSTRAINT [CK_ConceptoPago_MontoBase] CHECK (([MontoBase]>=(0.00)));
ALTER TABLE [Finanzas].[ConceptoPago] CHECK CONSTRAINT [CK_ConceptoPago_MontoBase];
ALTER TABLE [Finanzas].[CuotaMensualColegiado] WITH CHECK ADD CONSTRAINT [CK_CuotaMensualColegiado_Estado] CHECK (([EstadoCuota]='PENDIENTE' OR [EstadoCuota]='PAGADA' OR [EstadoCuota]='FRACCIONADA' OR [EstadoCuota]='EXONERADA'));
ALTER TABLE [Finanzas].[CuotaMensualColegiado] CHECK CONSTRAINT [CK_CuotaMensualColegiado_Estado];
ALTER TABLE [Finanzas].[ComprobantePago] WITH CHECK ADD CONSTRAINT [CK_ComprobantePago_Total] CHECK (([Total]>=[SubTotal]));
ALTER TABLE [Finanzas].[ComprobantePago] CHECK CONSTRAINT [CK_ComprobantePago_Total];
ALTER TABLE [Finanzas].[ComprobantePago] WITH CHECK ADD CONSTRAINT [CK_ComprobantePago_Tipo] CHECK (([TipoComprobante]='BOLETA' OR [TipoComprobante]='FACTURA' OR [TipoComprobante]='RECIBO_INGRESO'));
ALTER TABLE [Finanzas].[ComprobantePago] CHECK CONSTRAINT [CK_ComprobantePago_Tipo];
ALTER TABLE [Finanzas].[ComprobanteDetalle] WITH CHECK ADD CONSTRAINT [CK_ComprobanteDetalle_Cantidad] CHECK (([Cantidad]>(0)));
ALTER TABLE [Finanzas].[ComprobanteDetalle] CHECK CONSTRAINT [CK_ComprobanteDetalle_Cantidad];
ALTER TABLE [Finanzas].[ComprobanteDetalle] WITH CHECK ADD CONSTRAINT [CK_ComprobanteDetalle_SubTotal] CHECK (([SubTotal]>=(0.00)));
ALTER TABLE [Finanzas].[ComprobanteDetalle] CHECK CONSTRAINT [CK_ComprobanteDetalle_SubTotal];
ALTER TABLE [Finanzas].[ConciliacionBancaria] WITH CHECK ADD CONSTRAINT [CK_ConciliacionBancaria_Horas] CHECK (([HorasTranscurridas]>=(0)));
ALTER TABLE [Finanzas].[ConciliacionBancaria] CHECK CONSTRAINT [CK_ConciliacionBancaria_Horas];
GO

-- -----------------------------------------------------------------------------
-- E. CREACION DE LLAVES FORANEAS (FOREIGN KEYS)
-- -----------------------------------------------------------------------------
ALTER TABLE [Persona].[Persona] WITH CHECK ADD CONSTRAINT [FK_Persona_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Persona].[Persona] CHECK CONSTRAINT [FK_Persona_Entidad_EntidadID];
ALTER TABLE [Persona].[Direccion] WITH CHECK ADD CONSTRAINT [FK_Direccion_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
    ON DELETE CASCADE
;
ALTER TABLE [Persona].[Direccion] CHECK CONSTRAINT [FK_Direccion_Entidad_EntidadID];
ALTER TABLE [Persona].[Contacto] WITH CHECK ADD CONSTRAINT [FK_Contacto_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
    ON DELETE CASCADE
;
ALTER TABLE [Persona].[Contacto] CHECK CONSTRAINT [FK_Contacto_Entidad_EntidadID];
ALTER TABLE [Persona].[Usuario] WITH CHECK ADD CONSTRAINT [FK_Usuario_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Persona].[Usuario] CHECK CONSTRAINT [FK_Usuario_Entidad_EntidadID];
ALTER TABLE [Persona].[UsuarioRol] WITH CHECK ADD CONSTRAINT [FK_UsuarioRol_Usuario_UsuarioID] FOREIGN KEY ([UsuarioID])
    REFERENCES [Persona].[Usuario] ([UsuarioID])
    ON DELETE CASCADE
;
ALTER TABLE [Persona].[UsuarioRol] CHECK CONSTRAINT [FK_UsuarioRol_Usuario_UsuarioID];
ALTER TABLE [Persona].[UsuarioRol] WITH CHECK ADD CONSTRAINT [FK_UsuarioRol_Rol_RolID] FOREIGN KEY ([RolID])
    REFERENCES [Persona].[Rol] ([RolID])
;
ALTER TABLE [Persona].[UsuarioRol] CHECK CONSTRAINT [FK_UsuarioRol_Rol_RolID];
ALTER TABLE [Persona].[AuditoriaSesion] WITH CHECK ADD CONSTRAINT [FK_AuditoriaSesion_Usuario_UsuarioID] FOREIGN KEY ([UsuarioID])
    REFERENCES [Persona].[Usuario] ([UsuarioID])
;
ALTER TABLE [Persona].[AuditoriaSesion] CHECK CONSTRAINT [FK_AuditoriaSesion_Usuario_UsuarioID];
ALTER TABLE [Reniec].[ConsultaDniLog] WITH CHECK ADD CONSTRAINT [FK_ConsultaDniLog_Usuario_UsuarioID] FOREIGN KEY ([UsuarioID])
    REFERENCES [Persona].[Usuario] ([UsuarioID])
;
ALTER TABLE [Reniec].[ConsultaDniLog] CHECK CONSTRAINT [FK_ConsultaDniLog_Usuario_UsuarioID];
ALTER TABLE [Colegiatura].[Colegiado] WITH CHECK ADD CONSTRAINT [FK_Colegiado_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Colegiatura].[Colegiado] CHECK CONSTRAINT [FK_Colegiado_Entidad_EntidadID];
ALTER TABLE [Colegiatura].[ExpedienteColegiatura] WITH CHECK ADD CONSTRAINT [FK_ExpedienteColegiatura_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Colegiatura].[ExpedienteColegiatura] CHECK CONSTRAINT [FK_ExpedienteColegiatura_Entidad_EntidadID];
ALTER TABLE [Colegiatura].[TituloProfesional] WITH CHECK ADD CONSTRAINT [FK_TituloProfesional_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Colegiatura].[TituloProfesional] CHECK CONSTRAINT [FK_TituloProfesional_Entidad_EntidadID];
ALTER TABLE [Colegiatura].[EstadoHabilidadHistorial] WITH CHECK ADD CONSTRAINT [FK_EstadoHabilidadHistorial_Colegiado_ColegiadoID] FOREIGN KEY ([ColegiadoID])
    REFERENCES [Colegiatura].[Colegiado] ([ColegiadoID])
    ON DELETE CASCADE
;
ALTER TABLE [Colegiatura].[EstadoHabilidadHistorial] CHECK CONSTRAINT [FK_EstadoHabilidadHistorial_Colegiado_ColegiadoID];
ALTER TABLE [Tramite].[AreaOrganica] WITH CHECK ADD CONSTRAINT [FK_AreaOrganica_Entidad_ResponsableEntidadID] FOREIGN KEY ([ResponsableEntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Tramite].[AreaOrganica] CHECK CONSTRAINT [FK_AreaOrganica_Entidad_ResponsableEntidadID];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [FK_ExpedienteDocumento_TipoDocumento_TipoDocumentoID] FOREIGN KEY ([TipoDocumentoID])
    REFERENCES [Tramite].[TipoDocumento] ([TipoDocumentoID])
;
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [FK_ExpedienteDocumento_TipoDocumento_TipoDocumentoID];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [FK_ExpedienteDocumento_Entidad_RemitenteEntidadID] FOREIGN KEY ([RemitenteEntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [FK_ExpedienteDocumento_Entidad_RemitenteEntidadID];
ALTER TABLE [Tramite].[ExpedienteDocumento] WITH CHECK ADD CONSTRAINT [FK_ExpedienteDocumento_AreaOrganica_AreaActualID] FOREIGN KEY ([AreaActualID])
    REFERENCES [Tramite].[AreaOrganica] ([AreaOrganicaID])
;
ALTER TABLE [Tramite].[ExpedienteDocumento] CHECK CONSTRAINT [FK_ExpedienteDocumento_AreaOrganica_AreaActualID];
ALTER TABLE [Tramite].[DerivacionPaso] WITH CHECK ADD CONSTRAINT [FK_DerivacionPaso_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
    ON DELETE CASCADE
;
ALTER TABLE [Tramite].[DerivacionPaso] CHECK CONSTRAINT [FK_DerivacionPaso_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [Tramite].[DerivacionPaso] WITH CHECK ADD CONSTRAINT [FK_DerivacionPaso_AreaOrganica_AreaOrigenID] FOREIGN KEY ([AreaOrigenID])
    REFERENCES [Tramite].[AreaOrganica] ([AreaOrganicaID])
;
ALTER TABLE [Tramite].[DerivacionPaso] CHECK CONSTRAINT [FK_DerivacionPaso_AreaOrganica_AreaOrigenID];
ALTER TABLE [Tramite].[DerivacionPaso] WITH CHECK ADD CONSTRAINT [FK_DerivacionPaso_AreaOrganica_AreaDestinoID] FOREIGN KEY ([AreaDestinoID])
    REFERENCES [Tramite].[AreaOrganica] ([AreaOrganicaID])
;
ALTER TABLE [Tramite].[DerivacionPaso] CHECK CONSTRAINT [FK_DerivacionPaso_AreaOrganica_AreaDestinoID];
ALTER TABLE [Tramite].[DerivacionPaso] WITH CHECK ADD CONSTRAINT [FK_DerivacionPaso_Entidad_FuncionarioAsignadoID] FOREIGN KEY ([FuncionarioAsignadoID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Tramite].[DerivacionPaso] CHECK CONSTRAINT [FK_DerivacionPaso_Entidad_FuncionarioAsignadoID];
ALTER TABLE [Tramite].[DocumentoAdjunto] WITH CHECK ADD CONSTRAINT [FK_DocumentoAdjunto_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
    ON DELETE CASCADE
;
ALTER TABLE [Tramite].[DocumentoAdjunto] CHECK CONSTRAINT [FK_DocumentoAdjunto_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [Tramite].[ConstanciaHabilidad] WITH CHECK ADD CONSTRAINT [FK_ConstanciaHabilidad_Colegiado_ColegiadoID] FOREIGN KEY ([ColegiadoID])
    REFERENCES [Colegiatura].[Colegiado] ([ColegiadoID])
;
ALTER TABLE [Tramite].[ConstanciaHabilidad] CHECK CONSTRAINT [FK_ConstanciaHabilidad_Colegiado_ColegiadoID];
ALTER TABLE [Tramite].[ConstanciaHabilidad] WITH CHECK ADD CONSTRAINT [FK_ConstanciaHabilidad_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
;
ALTER TABLE [Tramite].[ConstanciaHabilidad] CHECK CONSTRAINT [FK_ConstanciaHabilidad_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [MachineLearning].[MetricaRendimiento] WITH CHECK ADD CONSTRAINT [FK_MetricaRendimiento_ModeloPredictivo_ModeloID] FOREIGN KEY ([ModeloID])
    REFERENCES [MachineLearning].[ModeloPredictivo] ([ModeloID])
    ON DELETE CASCADE
;
ALTER TABLE [MachineLearning].[MetricaRendimiento] CHECK CONSTRAINT [FK_MetricaRendimiento_ModeloPredictivo_ModeloID];
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] WITH CHECK ADD CONSTRAINT [FK_DatasetHistoricoTramite_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
;
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] CHECK CONSTRAINT [FK_DatasetHistoricoTramite_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] WITH CHECK ADD CONSTRAINT [FK_DatasetHistoricoTramite_TipoDocumento_TipoDocumentoID] FOREIGN KEY ([TipoDocumentoID])
    REFERENCES [Tramite].[TipoDocumento] ([TipoDocumentoID])
;
ALTER TABLE [MachineLearning].[DatasetHistoricoTramite] CHECK CONSTRAINT [FK_DatasetHistoricoTramite_TipoDocumento_TipoDocumentoID];
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] WITH CHECK ADD CONSTRAINT [FK_PrediccionEntregaDocumento_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
    ON DELETE CASCADE
;
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] CHECK CONSTRAINT [FK_PrediccionEntregaDocumento_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] WITH CHECK ADD CONSTRAINT [FK_PrediccionEntregaDocumento_ModeloPredictivo_ModeloID] FOREIGN KEY ([ModeloID])
    REFERENCES [MachineLearning].[ModeloPredictivo] ([ModeloID])
;
ALTER TABLE [MachineLearning].[PrediccionEntregaDocumento] CHECK CONSTRAINT [FK_PrediccionEntregaDocumento_ModeloPredictivo_ModeloID];
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] WITH CHECK ADD CONSTRAINT [FK_AlertaCuelloBotella_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
    ON DELETE CASCADE
;
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] CHECK CONSTRAINT [FK_AlertaCuelloBotella_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] WITH CHECK ADD CONSTRAINT [FK_AlertaCuelloBotella_PrediccionEntregaDocumento_PrediccionID] FOREIGN KEY ([PrediccionID])
    REFERENCES [MachineLearning].[PrediccionEntregaDocumento] ([PrediccionID])
;
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] CHECK CONSTRAINT [FK_AlertaCuelloBotella_PrediccionEntregaDocumento_PrediccionID];
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] WITH CHECK ADD CONSTRAINT [FK_AlertaCuelloBotella_AreaOrganica_AreaOrganicaID] FOREIGN KEY ([AreaOrganicaID])
    REFERENCES [Tramite].[AreaOrganica] ([AreaOrganicaID])
;
ALTER TABLE [MachineLearning].[AlertaCuelloBotella] CHECK CONSTRAINT [FK_AlertaCuelloBotella_AreaOrganica_AreaOrganicaID];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [FK_EncuestaServqual_ExpedienteDocumento_ExpedienteID] FOREIGN KEY ([ExpedienteID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
    ON DELETE CASCADE
;
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [FK_EncuestaServqual_ExpedienteDocumento_ExpedienteID];
ALTER TABLE [Calidad].[EncuestaServqual] WITH CHECK ADD CONSTRAINT [FK_EncuestaServqual_Entidad_EntidadEvaluadorID] FOREIGN KEY ([EntidadEvaluadorID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Calidad].[EncuestaServqual] CHECK CONSTRAINT [FK_EncuestaServqual_Entidad_EntidadEvaluadorID];
ALTER TABLE [Calidad].[LibroReclamacion] WITH CHECK ADD CONSTRAINT [FK_LibroReclamacion_Entidad_EntidadReclamanteID] FOREIGN KEY ([EntidadReclamanteID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Calidad].[LibroReclamacion] CHECK CONSTRAINT [FK_LibroReclamacion_Entidad_EntidadReclamanteID];
ALTER TABLE [Calidad].[LibroReclamacion] WITH CHECK ADD CONSTRAINT [FK_LibroReclamacion_ExpedienteDocumento_ExpedienteRelacionadoID] FOREIGN KEY ([ExpedienteRelacionadoID])
    REFERENCES [Tramite].[ExpedienteDocumento] ([ExpedienteID])
;
ALTER TABLE [Calidad].[LibroReclamacion] CHECK CONSTRAINT [FK_LibroReclamacion_ExpedienteDocumento_ExpedienteRelacionadoID];
ALTER TABLE [Calidad].[IndicadorCalidadSLA] WITH CHECK ADD CONSTRAINT [FK_IndicadorCalidadSLA_TipoDocumento_TipoDocumentoID] FOREIGN KEY ([TipoDocumentoID])
    REFERENCES [Tramite].[TipoDocumento] ([TipoDocumentoID])
;
ALTER TABLE [Calidad].[IndicadorCalidadSLA] CHECK CONSTRAINT [FK_IndicadorCalidadSLA_TipoDocumento_TipoDocumentoID];
ALTER TABLE [Academico].[InscripcionParticipante] WITH CHECK ADD CONSTRAINT [FK_InscripcionParticipante_EventoCapacitacion_EventoID] FOREIGN KEY ([EventoID])
    REFERENCES [Academico].[EventoCapacitacion] ([EventoID])
    ON DELETE CASCADE
;
ALTER TABLE [Academico].[InscripcionParticipante] CHECK CONSTRAINT [FK_InscripcionParticipante_EventoCapacitacion_EventoID];
ALTER TABLE [Academico].[InscripcionParticipante] WITH CHECK ADD CONSTRAINT [FK_InscripcionParticipante_Entidad_EntidadID] FOREIGN KEY ([EntidadID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Academico].[InscripcionParticipante] CHECK CONSTRAINT [FK_InscripcionParticipante_Entidad_EntidadID];
ALTER TABLE [Academico].[CertificadoAcademico] WITH CHECK ADD CONSTRAINT [FK_CertificadoAcademico_InscripcionParticipante_InscripcionID] FOREIGN KEY ([InscripcionID])
    REFERENCES [Academico].[InscripcionParticipante] ([InscripcionID])
    ON DELETE CASCADE
;
ALTER TABLE [Academico].[CertificadoAcademico] CHECK CONSTRAINT [FK_CertificadoAcademico_InscripcionParticipante_InscripcionID];
ALTER TABLE [Finanzas].[CuotaMensualColegiado] WITH CHECK ADD CONSTRAINT [FK_CuotaMensualColegiado_Colegiado_ColegiadoID] FOREIGN KEY ([ColegiadoID])
    REFERENCES [Colegiatura].[Colegiado] ([ColegiadoID])
    ON DELETE CASCADE
;
ALTER TABLE [Finanzas].[CuotaMensualColegiado] CHECK CONSTRAINT [FK_CuotaMensualColegiado_Colegiado_ColegiadoID];
ALTER TABLE [Finanzas].[ComprobantePago] WITH CHECK ADD CONSTRAINT [FK_ComprobantePago_Entidad_EntidadClienteID] FOREIGN KEY ([EntidadClienteID])
    REFERENCES [Persona].[Entidad] ([EntidadID])
;
ALTER TABLE [Finanzas].[ComprobantePago] CHECK CONSTRAINT [FK_ComprobantePago_Entidad_EntidadClienteID];
ALTER TABLE [Finanzas].[ComprobantePago] WITH CHECK ADD CONSTRAINT [FK_ComprobantePago_Usuario_UsuarioCajeroID] FOREIGN KEY ([UsuarioCajeroID])
    REFERENCES [Persona].[Usuario] ([UsuarioID])
;
ALTER TABLE [Finanzas].[ComprobantePago] CHECK CONSTRAINT [FK_ComprobantePago_Usuario_UsuarioCajeroID];
ALTER TABLE [Finanzas].[ComprobanteDetalle] WITH CHECK ADD CONSTRAINT [FK_ComprobanteDetalle_ComprobantePago_ComprobantePagoID] FOREIGN KEY ([ComprobantePagoID])
    REFERENCES [Finanzas].[ComprobantePago] ([ComprobantePagoID])
    ON DELETE CASCADE
;
ALTER TABLE [Finanzas].[ComprobanteDetalle] CHECK CONSTRAINT [FK_ComprobanteDetalle_ComprobantePago_ComprobantePagoID];
ALTER TABLE [Finanzas].[ComprobanteDetalle] WITH CHECK ADD CONSTRAINT [FK_ComprobanteDetalle_ConceptoPago_ConceptoID] FOREIGN KEY ([ConceptoID])
    REFERENCES [Finanzas].[ConceptoPago] ([ConceptoID])
;
ALTER TABLE [Finanzas].[ComprobanteDetalle] CHECK CONSTRAINT [FK_ComprobanteDetalle_ConceptoPago_ConceptoID];
ALTER TABLE [Finanzas].[ConciliacionBancaria] WITH CHECK ADD CONSTRAINT [FK_ConciliacionBancaria_Usuario_UsuarioResponsableID] FOREIGN KEY ([UsuarioResponsableID])
    REFERENCES [Persona].[Usuario] ([UsuarioID])
;
ALTER TABLE [Finanzas].[ConciliacionBancaria] CHECK CONSTRAINT [FK_ConciliacionBancaria_Usuario_UsuarioResponsableID];
GO

-- -----------------------------------------------------------------------------
-- F. CREACION DE INDICES OPTIMIZADOS (INDEXES)
-- -----------------------------------------------------------------------------
CREATE UNIQUE NONCLUSTERED INDEX [IX_Persona_Dni] ON [Persona].[Persona] ([Dni] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_Usuario_Login] ON [Persona].[Usuario] ([Login] ASC);
CREATE NONCLUSTERED INDEX [IX_Persona_Nombres] ON [Persona].[Persona] ([ApellidoPaterno] ASC, [ApellidoMaterno] ASC, [Nombres] ASC);
CREATE NONCLUSTERED INDEX [IX_ConsultaDniLog_Dni_Fecha] ON [Reniec].[ConsultaDniLog] ([DniConsultado] ASC, [FechaConsulta] DESC);
CREATE NONCLUSTERED INDEX [IX_PersonaIdentidadCache_Expiracion] ON [Reniec].[PersonaIdentidadCache] ([FechaExpiracionCache] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_Colegiado_MatriculaRegional] ON [Colegiatura].[Colegiado] ([MatriculaRegional] ASC);
CREATE NONCLUSTERED INDEX [IX_Colegiado_EstadoHabilidad] ON [Colegiatura].[Colegiado] ([EstadoHabilidadActual] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_ExpedienteDocumento_NumeroExpediente] ON [Tramite].[ExpedienteDocumento] ([NumeroExpediente] ASC);
CREATE NONCLUSTERED INDEX [IX_ExpedienteDocumento_Dni] ON [Tramite].[ExpedienteDocumento] ([DniSolicitante] ASC);
CREATE NONCLUSTERED INDEX [IX_ExpedienteDocumento_Estado_Area] ON [Tramite].[ExpedienteDocumento] ([EstadoExpediente] ASC, [AreaActualID] ASC);
CREATE NONCLUSTERED INDEX [IX_DerivacionPaso_Expediente] ON [Tramite].[DerivacionPaso] ([ExpedienteID] ASC, [PasoNumero] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_ConstanciaHabilidad_QR] ON [Tramite].[ConstanciaHabilidad] ([CodigoVerificacionQR] ASC);
CREATE NONCLUSTERED INDEX [IX_PrediccionEntregaDocumento_Expediente] ON [MachineLearning].[PrediccionEntregaDocumento] ([ExpedienteID] ASC);
CREATE NONCLUSTERED INDEX [IX_PrediccionEntregaDocumento_Riesgo] ON [MachineLearning].[PrediccionEntregaDocumento] ([NivelRiesgoRetraso] ASC, [FechaEstimadaEntrega] ASC);
CREATE NONCLUSTERED INDEX [IX_AlertaCuelloBotella_Estado] ON [MachineLearning].[AlertaCuelloBotella] ([EstadoAlerta] ASC, [NivelSeveridad] ASC);
CREATE NONCLUSTERED INDEX [IX_EncuestaServqual_Expediente] ON [Calidad].[EncuestaServqual] ([ExpedienteID] ASC);
CREATE NONCLUSTERED INDEX [IX_CuotaMensualColegiado_Estado] ON [Finanzas].[CuotaMensualColegiado] ([ColegiadoID] ASC, [EstadoCuota] ASC);
CREATE NONCLUSTERED INDEX [IX_ComprobantePago_Fecha] ON [Finanzas].[ComprobantePago] ([FechaEmision] DESC, [EstadoSunat] ASC);
GO

-- -----------------------------------------------------------------------------
-- G. DDL TRIGGER DE AUDITORIA A NIVEL DE BASE DE DATOS (ESTILO ADVENTUREWORKS)
-- -----------------------------------------------------------------------------
CREATE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EventData xml = EVENTDATA();

    INSERT INTO [dbo].[DatabaseLog] (
        [PostTime],
        [DatabaseUser],
        [Event],
        [Schema],
        [Object],
        [TSQL],
        [XmlEvent]
    )
    VALUES (
        GETDATE(),
        CONVERT(sysname, CURRENT_USER),
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname'),
        @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'),
        @EventData
    );
END;
GO
ENABLE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE;
GO

-- -----------------------------------------------------------------------------
-- H. CREACION DE FUNCIONES DE USUARIO
-- -----------------------------------------------------------------------------
CREATE FUNCTION [dbo].[ufnCalcularDiasHabiles](@FechaInicio datetime, @FechaFin datetime)
RETURNS int
AS
BEGIN
    IF @FechaInicio IS NULL OR @FechaFin IS NULL OR @FechaInicio > @FechaFin
        RETURN 0;

    DECLARE @DiasTotal int = DATEDIFF(day, @FechaInicio, @FechaFin);
    DECLARE @Semanas int = @DiasTotal / 7;
    DECLARE @DiasHabiles int = @Semanas * 5;
    DECLARE @DiaRestante int = @DiasTotal % 7;
    DECLARE @DiaSemanaInicio int = DATEPART(weekday, @FechaInicio);

    DECLARE @i int = 0;
    WHILE @i < @DiaRestante
    BEGIN
        DECLARE @DiaActual int = (@DiaSemanaInicio + @i) % 7;
        IF @DiaActual <> 1 AND @DiaActual <> 0 AND @DiaActual <> 7
            SET @DiasHabiles = @DiasHabiles + 1;
        SET @i = @i + 1;
    END;

    RETURN @DiasHabiles;
END;
GO

CREATE FUNCTION [dbo].[ufnObtenerEstadoExpedienteTexto](@EstadoExpediente nvarchar(30))
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @Resultado nvarchar(50);
    SET @Resultado = CASE @EstadoExpediente
        WHEN 'REGISTRADO' THEN 'Registrado en Mesa de Partes'
        WHEN 'DERIVADO' THEN 'Derivado a Despacho Competente'
        WHEN 'EN_EVALUACION' THEN 'En Evaluacion Tecnica / Colegiada'
        WHEN 'OBSERVADO' THEN 'Con Observaciones Notificadas'
        WHEN 'ATENDIDO' THEN 'Atendido / Documento Concluido'
        WHEN 'ARCHIVADO' THEN 'Archivado en Archivo Central'
        ELSE 'Estado Desconocido'
    END;
    RETURN @Resultado;
END;
GO

CREATE FUNCTION [dbo].[ufnDeterminarNivelRiesgoRetraso](
    @ProbabilidadRetraso decimal(5,4),
    @DiasTranscurridos decimal(6,2),
    @DiasEstimados decimal(6,2)
)
RETURNS nvarchar(20)
AS
BEGIN
    DECLARE @Nivel nvarchar(20);

    IF @DiasEstimados > 0 AND (@DiasTranscurridos / @DiasEstimados) >= 1.00
        SET @Nivel = 'CRITICO';
    ELSE IF @ProbabilidadRetraso >= 0.70 OR (@DiasEstimados > 0 AND (@DiasTranscurridos / @DiasEstimados) >= 0.80)
        SET @Nivel = 'ALTO';
    ELSE IF @ProbabilidadRetraso >= 0.40 OR (@DiasEstimados > 0 AND (@DiasTranscurridos / @DiasEstimados) >= 0.50)
        SET @Nivel = 'MEDIO';
    ELSE
        SET @Nivel = 'BAJO';

    RETURN @Nivel;
END;
GO

CREATE FUNCTION [Colegiatura].[ufnEsColegiadoHabil](@ColegiadoID int)
RETURNS [dbo].[Flag]
AS
BEGIN
    DECLARE @EsHabil [dbo].[Flag] = 0;
    DECLARE @CuotasPendientes smallint;
    DECLARE @EstadoActual nvarchar(30);

    SELECT 
        @CuotasPendientes = [CantidadCuotasPendientes],
        @EstadoActual = [EstadoHabilidadActual]
    FROM [Colegiatura].[Colegiado]
    WHERE [ColegiadoID] = @ColegiadoID;

    IF @EstadoActual = 'HABIL' AND @CuotasPendientes <= 2
        SET @EsHabil = 1;
    ELSE
        SET @EsHabil = 0;

    RETURN @EsHabil;
END;
GO

-- -----------------------------------------------------------------------------
-- I. CREACION DE VISTAS DEL SISTEMA
-- -----------------------------------------------------------------------------
CREATE VIEW [Tramite].[vSeguimientoExpedientesEnTiempoReal]
AS
SELECT 
    e.[ExpedienteID],
    e.[NumeroExpediente],
    td.[NombreTipo] AS [TipoDocumento],
    td.[EsRevisionExhaustiva],
    e.[DniSolicitante],
    e.[NombresSolicitante],
    e.[Asunto],
    e.[NumeroFolios],
    e.[CanalIngreso],
    e.[Prioridad],
    e.[EstadoExpediente],
    ao.[NombreArea] AS [AreaActual],
    e.[FechaIngreso],
    p.[DiasEstimadosEntrega],
    p.[FechaEstimadaEntrega],
    p.[ProbabilidadRetraso],
    p.[NivelRiesgoRetraso],
    [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], GETDATE()) AS [DiasHabilesTranscurridos],
    CASE 
        WHEN e.[FechaCierre] IS NOT NULL THEN 'CULMINADO'
        WHEN GETDATE() > p.[FechaEstimadaEntrega] THEN 'VENCIDO'
        WHEN p.[NivelRiesgoRetraso] = 'CRITICO' THEN 'RIESGO_CRITICO'
        WHEN p.[NivelRiesgoRetraso] = 'ALTO' THEN 'RIESGO_ALTO'
        ELSE 'EN_PLAZO'
    END AS [SemaforoOperativo]
FROM [Tramite].[ExpedienteDocumento] e
    INNER JOIN [Tramite].[TipoDocumento] td ON e.[TipoDocumentoID] = td.[TipoDocumentoID]
    INNER JOIN [Tramite].[AreaOrganica] ao ON e.[AreaActualID] = ao.[AreaOrganicaID]
    LEFT JOIN (
        SELECT pred.*
        FROM [MachineLearning].[PrediccionEntregaDocumento] pred
        INNER JOIN (
            SELECT [ExpedienteID], MAX([FechaPrediccion]) AS MaxFecha
            FROM [MachineLearning].[PrediccionEntregaDocumento]
            GROUP BY [ExpedienteID]
        ) ult ON pred.[ExpedienteID] = ult.[ExpedienteID] AND pred.[FechaPrediccion] = ult.MaxFecha
    ) p ON e.[ExpedienteID] = p.[ExpedienteID];
GO

CREATE VIEW [MachineLearning].[vPrediccionesVsTiemposReales]
AS
SELECT 
    e.[ExpedienteID],
    e.[NumeroExpediente],
    td.[NombreTipo] AS [TipoDocumento],
    td.[EsRevisionExhaustiva],
    m.[NombreModelo],
    m.[VersionModelo],
    p.[DiasEstimadosEntrega],
    p.[FechaEstimadaEntrega],
    p.[FechaRealEntrega],
    p.[ErrorAbsolutoDias],
    p.[EsPrediccionAcertada],
    p.[ProbabilidadRetraso],
    p.[NivelRiesgoRetraso],
    DATEDIFF(day, p.[FechaEstimadaEntrega], p.[FechaRealEntrega]) AS [DesviacionDiasCalendario],
    CASE 
        WHEN p.[ErrorAbsolutoDias] <= 1.00 THEN 'ALTA_PRECISION'
        WHEN p.[ErrorAbsolutoDias] <= 3.00 THEN 'PRECISION_ACEPTABLE'
        ELSE 'DESVIACION_SIGNIFICATIVA'
    END AS [CalidadEstimacion]
FROM [MachineLearning].[PrediccionEntregaDocumento] p
    INNER JOIN [Tramite].[ExpedienteDocumento] e ON p.[ExpedienteID] = e.[ExpedienteID]
    INNER JOIN [Tramite].[TipoDocumento] td ON e.[TipoDocumentoID] = td.[TipoDocumentoID]
    INNER JOIN [MachineLearning].[ModeloPredictivo] m ON p.[ModeloID] = m.[ModeloID]
WHERE p.[FechaRealEntrega] IS NOT NULL;
GO

CREATE VIEW [MachineLearning].[vDatasetEntrenamientoExtendido]
AS
SELECT 
    d.[RegistroHistoricoID],
    d.[ExpedienteID],
    d.[TipoDocumentoID],
    td.[CodigoTipo] AS [CodigoTipoDocumento],
    d.[EsRevisionExhaustiva],
    d.[NumeroFolios],
    d.[AreaFinalID],
    ao.[CodigoArea] AS [CodigoAreaFinal],
    d.[CargaLaboralColaEnIngreso],
    d.[CantidadRequisitosCumplidos],
    d.[MesIngreso],
    d.[DiaSemana],
    d.[HoraIngreso],
    d.[RequiereValidacionExterna],
    d.[TuvoObservacionesPrevias],
    d.[DiasRealesAtencion],
    d.[HorasRealesAtencion],
    d.[CumplioSLA],
    td.[PlazoSlaEstimadoDias]
FROM [MachineLearning].[DatasetHistoricoTramite] d
    INNER JOIN [Tramite].[TipoDocumento] td ON d.[TipoDocumentoID] = td.[TipoDocumentoID]
    INNER JOIN [Tramite].[AreaOrganica] ao ON d.[AreaFinalID] = ao.[AreaOrganicaID];
GO

CREATE VIEW [Colegiatura].[vPadronColegiadosHabilitados]
AS
SELECT 
    c.[ColegiadoID],
    c.[MatriculaRegional],
    c.[MatriculaNacional],
    p.[Dni],
    p.[ApellidoPaterno],
    p.[ApellidoMaterno],
    p.[Nombres],
    c.[CondicionColegiado],
    c.[EstadoHabilidadActual],
    c.[FechaIncorporacion],
    c.[CantidadCuotasPendientes],
    c.[UltimoPeriodoPagado],
    CASE 
        WHEN c.[EstadoHabilidadActual] = 'HABIL' THEN 1 
        ELSE 0 
    END AS [EsHabilParaEjercicioProfesional]
FROM [Colegiatura].[Colegiado] c
    INNER JOIN [Persona].[Persona] p ON c.[EntidadID] = p.[EntidadID]
WHERE c.[CondicionColegiado] IN ('ORDINARIO', 'VITALICIO');
GO

CREATE VIEW [Calidad].[vMetricasServqualCalidadServicio]
AS
SELECT 
    FORMAT(s.[FechaRespuesta], 'yyyy-MM') AS [PeriodoAnioMes],
    COUNT(s.[EncuestaID]) AS [TotalEncuestas],
    CAST(AVG(CAST(s.[P1_Fiabilidad] AS decimal(5,2))) AS decimal(4,2)) AS [Promedio_Fiabilidad],
    CAST(AVG(CAST(s.[P2_CapacidadRespuesta] AS decimal(5,2))) AS decimal(4,2)) AS [Promedio_CapacidadRespuesta],
    CAST(AVG(CAST(s.[P3_Seguridad] AS decimal(5,2))) AS decimal(4,2)) AS [Promedio_Seguridad],
    CAST(AVG(CAST(s.[P4_Empatia] AS decimal(5,2))) AS decimal(4,2)) AS [Promedio_Empatia],
    CAST(AVG(CAST(s.[P5_ElementosTangibles] AS decimal(5,2))) AS decimal(4,2)) AS [Promedio_ElementosTangibles],
    CAST(AVG(s.[PuntuacionGlobal]) AS decimal(4,2)) AS [IndiceServqualGlobal],
    CAST(AVG(ISNULL(p.[ErrorAbsolutoDias], 0.00)) AS decimal(6,2)) AS [ErrorPromedioEstimacionDias]
FROM [Calidad].[EncuestaServqual] s
    LEFT JOIN [MachineLearning].[PrediccionEntregaDocumento] p ON s.[ExpedienteID] = p.[ExpedienteID]
GROUP BY FORMAT(s.[FechaRespuesta], 'yyyy-MM');
GO

CREATE VIEW [Reniec].[vAuditoriaConsultasReniec]
AS
SELECT 
    FORMAT(l.[FechaConsulta], 'yyyy-MM-dd') AS [FechaConsultaDia],
    l.[ModuloOrigen],
    COUNT(l.[ConsultaLogID]) AS [TotalConsultas],
    SUM(CASE WHEN l.[CodigoRespuestaHttp] = 200 THEN 1 ELSE 0 END) AS [ConsultasExitosas],
    SUM(CASE WHEN l.[CodigoRespuestaHttp] <> 200 THEN 1 ELSE 0 END) AS [ConsultasFallidas],
    CAST(AVG(CAST(l.[TiempoRespuestaMs] AS decimal(10,2))) AS decimal(8,2)) AS [LatenciaPromedioMs],
    MIN(l.[TiempoRespuestaMs]) AS [LatenciaMinimaMs],
    MAX(l.[TiempoRespuestaMs]) AS [LatenciaMaximaMs]
FROM [Reniec].[ConsultaDniLog] l
GROUP BY FORMAT(l.[FechaConsulta], 'yyyy-MM-dd'), l.[ModuloOrigen];
GO

CREATE VIEW [Tramite].[vSlaCumplimientoPorTipoDocumento]
AS
SELECT 
    td.[TipoDocumentoID],
    td.[CodigoTipo],
    td.[NombreTipo],
    td.[EsRevisionExhaustiva],
    td.[PlazoSlaEstimadoDias],
    COUNT(e.[ExpedienteID]) AS [TotalExpedientesRegistrados],
    SUM(CASE WHEN e.[FechaCierre] IS NOT NULL THEN 1 ELSE 0 END) AS [TotalAtendidos],
    SUM(CASE WHEN e.[FechaCierre] IS NOT NULL AND [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], e.[FechaCierre]) <= td.[PlazoSlaEstimadoDias] THEN 1 ELSE 0 END) AS [AtendidosEnPlazoSLA],
    SUM(CASE WHEN e.[FechaCierre] IS NOT NULL AND [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], e.[FechaCierre]) > td.[PlazoSlaEstimadoDias] THEN 1 ELSE 0 END) AS [AtendidosConRetraso],
    CAST(
        CASE 
            WHEN SUM(CASE WHEN e.[FechaCierre] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN 0.00
            ELSE (CAST(SUM(CASE WHEN e.[FechaCierre] IS NOT NULL AND [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], e.[FechaCierre]) <= td.[PlazoSlaEstimadoDias] THEN 1 ELSE 0 END) AS decimal(10,2)) / 
                  CAST(SUM(CASE WHEN e.[FechaCierre] IS NOT NULL THEN 1 ELSE 0 END) AS decimal(10,2))) * 100.00
        END AS decimal(5,2)
    ) AS [PorcentajeCumplimientoSLA]
FROM [Tramite].[TipoDocumento] td
    LEFT JOIN [Tramite].[ExpedienteDocumento] e ON td.[TipoDocumentoID] = e.[TipoDocumentoID]
GROUP BY td.[TipoDocumentoID], td.[CodigoTipo], td.[NombreTipo], td.[EsRevisionExhaustiva], td.[PlazoSlaEstimadoDias];
GO

-- -----------------------------------------------------------------------------
-- J. CREACION DE PROCEDIMIENTOS ALMACENADOS (TRANSACCIONALES Y AUDITORIA)
-- -----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID int = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ErrorLogID = 0;

    BEGIN TRY
        IF ERROR_NUMBER() IS NULL
            RETURN;

        IF XACT_STATE() = -1
        BEGIN
            PRINT 'No se puede registrar el error porque la transaccion esta en estado no confirmable.';
            RETURN;
        END;

        INSERT INTO [dbo].[ErrorLog] (
            [UserName],
            [ErrorNumber],
            [ErrorSeverity],
            [ErrorState],
            [ErrorProcedure],
            [ErrorLine],
            [ErrorMessage]
        )
        VALUES (
            CONVERT(sysname, CURRENT_USER),
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
        );

        SET @ErrorLogID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        PRINT 'Fallo la ejecucion interna de dbo.uspLogError.';
        RETURN -1;
    END CATCH;
END;
GO

CREATE PROCEDURE [dbo].[uspPrintError]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severidad ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', Estado ' + CONVERT(varchar(5), ERROR_STATE()) +
          ', Procedimiento ' + ISNULL(ERROR_PROCEDURE(), '-') +
          ', Linea ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO

CREATE PROCEDURE [Reniec].[uspRegistrarConsultaReniec]
    @DniConsultado [dbo].[Dni],
    @UsuarioID int = NULL,
    @CodigoRespuestaHttp smallint,
    @EstadoConsulta nvarchar(30),
    @MensajeRespuesta nvarchar(500) = NULL,
    @TiempoRespuestaMs int,
    @DireccionIP nvarchar(45),
    @TokenHash nvarchar(64),
    @ModuloOrigen nvarchar(50) = 'MESA_PARTES',
    @ConsultaLogID bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [Reniec].[ConsultaDniLog] (
            [DniConsultado],
            [UsuarioID],
            [FechaConsulta],
            [CodigoRespuestaHttp],
            [EstadoConsulta],
            [MensajeRespuesta],
            [TiempoRespuestaMs],
            [DireccionIP],
            [TokenHash],
            [ModuloOrigen]
        )
        VALUES (
            @DniConsultado,
            @UsuarioID,
            GETDATE(),
            @CodigoRespuestaHttp,
            @EstadoConsulta,
            @MensajeRespuesta,
            @TiempoRespuestaMs,
            @DireccionIP,
            @TokenHash,
            @ModuloOrigen
        );

        SET @ConsultaLogID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [MachineLearning].[uspRegistrarPrediccionEntrega]
    @ExpedienteID int,
    @ModeloID smallint,
    @DiasEstimadosEntrega decimal(6,2),
    @HorasEstimadasEntrega decimal(8,2),
    @FechaEstimadaEntrega datetime,
    @IntervaloConfianzaMin datetime,
    @IntervaloConfianzaMax datetime,
    @ProbabilidadRetraso decimal(5,4),
    @NivelRiesgoRetraso nvarchar(20),
    @PrediccionID bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [MachineLearning].[PrediccionEntregaDocumento] (
            [ExpedienteID],
            [ModeloID],
            [DiasEstimadosEntrega],
            [HorasEstimadasEntrega],
            [FechaEstimadaEntrega],
            [IntervaloConfianzaMin],
            [IntervaloConfianzaMax],
            [ProbabilidadRetraso],
            [NivelRiesgoRetraso],
            [FechaPrediccion]
        )
        VALUES (
            @ExpedienteID,
            @ModeloID,
            @DiasEstimadosEntrega,
            @HorasEstimadasEntrega,
            @FechaEstimadaEntrega,
            @IntervaloConfianzaMin,
            @IntervaloConfianzaMax,
            @ProbabilidadRetraso,
            @NivelRiesgoRetraso,
            GETDATE()
        );

        SET @PrediccionID = SCOPE_IDENTITY();

        IF @NivelRiesgoRetraso IN ('ALTO', 'CRITICO')
        BEGIN
            DECLARE @AreaActualID smallint;
            SELECT @AreaActualID = [AreaActualID] FROM [Tramite].[ExpedienteDocumento] WHERE [ExpedienteID] = @ExpedienteID;

            INSERT INTO [MachineLearning].[AlertaCuelloBotella] (
                [ExpedienteID],
                [PrediccionID],
                [AreaOrganicaID],
                [NivelSeveridad],
                [MensajeAlerta],
                [FechaGeneracion],
                [EstadoAlerta]
            )
            VALUES (
                @ExpedienteID,
                @PrediccionID,
                @AreaActualID,
                @NivelRiesgoRetraso,
                'El modelo de Machine Learning proyecta un riesgo ' + @NivelRiesgoRetraso + ' de retraso (' + CAST((@ProbabilidadRetraso * 100) AS varchar(10)) + '%). Requiere monitoreo.',
                GETDATE(),
                'PENDIENTE'
            );
        END;
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [MachineLearning].[uspActualizarCierreTramiteYFeedback]
    @ExpedienteID int,
    @FechaRealEntrega datetime = NULL,
    @FeedbackCalidadPrediccion nvarchar(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @FechaRealEntrega IS NULL
            SET @FechaRealEntrega = GETDATE();

        UPDATE [Tramite].[ExpedienteDocumento]
        SET [EstadoExpediente] = 'ATENDIDO',
            [FechaCierre] = @FechaRealEntrega,
            [ModifiedDate] = GETDATE()
        WHERE [ExpedienteID] = @ExpedienteID;

        UPDATE [MachineLearning].[PrediccionEntregaDocumento]
        SET [FechaRealEntrega] = @FechaRealEntrega,
            [ErrorAbsolutoDias] = ABS(DATEDIFF(day, [FechaEstimadaEntrega], @FechaRealEntrega)),
            [EsPrediccionAcertada] = CASE WHEN ABS(DATEDIFF(day, [FechaEstimadaEntrega], @FechaRealEntrega)) <= 1 THEN 1 ELSE 0 END,
            [FeedbackCalidadPrediccion] = @FeedbackCalidadPrediccion,
            [ModifiedDate] = GETDATE()
        WHERE [ExpedienteID] = @ExpedienteID;

        IF NOT EXISTS (SELECT 1 FROM [MachineLearning].[DatasetHistoricoTramite] WHERE [ExpedienteID] = @ExpedienteID)
        BEGIN
            INSERT INTO [MachineLearning].[DatasetHistoricoTramite] (
                [ExpedienteID],
                [TipoDocumentoID],
                [EsRevisionExhaustiva],
                [NumeroFolios],
                [AreaFinalID],
                [CargaLaboralColaEnIngreso],
                [CantidadRequisitosCumplidos],
                [MesIngreso],
                [DiaSemana],
                [HoraIngreso],
                [RequiereValidacionExterna],
                [TuvoObservacionesPrevias],
                [DiasRealesAtencion],
                [HorasRealesAtencion],
                [CumplioSLA]
            )
            SELECT 
                e.[ExpedienteID],
                e.[TipoDocumentoID],
                td.[EsRevisionExhaustiva],
                e.[NumeroFolios],
                e.[AreaActualID],
                (SELECT COUNT(*) FROM [Tramite].[ExpedienteDocumento] WHERE [AreaActualID] = e.[AreaActualID] AND [EstadoExpediente] IN ('REGISTRADO', 'DERIVADO', 'EN_EVALUACION')),
                1,
                MONTH(e.[FechaIngreso]),
                DATEPART(weekday, e.[FechaIngreso]),
                DATEPART(hour, e.[FechaIngreso]),
                td.[RequiereSunedu],
                CASE WHEN EXISTS(SELECT 1 FROM [Tramite].[DerivacionPaso] WHERE [ExpedienteID] = e.[ExpedienteID] AND [EstadoPaso] = 'DEVUELTO') THEN 1 ELSE 0 END,
                [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], @FechaRealEntrega),
                CAST(DATEDIFF(minute, e.[FechaIngreso], @FechaRealEntrega) AS decimal(8,2)) / 60.00,
                CASE WHEN [dbo].[ufnCalcularDiasHabiles](e.[FechaIngreso], @FechaRealEntrega) <= td.[PlazoSlaEstimadoDias] THEN 1 ELSE 0 END
            FROM [Tramite].[ExpedienteDocumento] e
                INNER JOIN [Tramite].[TipoDocumento] td ON e.[TipoDocumentoID] = td.[TipoDocumentoID]
            WHERE e.[ExpedienteID] = @ExpedienteID;
        END;
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [Tramite].[uspRegistrarExpedienteMesaPartes]
    @TipoDocumentoID smallint,
    @RemitenteEntidadID int,
    @DniSolicitante [dbo].[Dni],
    @NombresSolicitante nvarchar(150),
    @Asunto nvarchar(300),
    @NumeroFolios smallint = 1,
    @CanalIngreso nvarchar(20) = 'VIRTUAL',
    @Prioridad nvarchar(20) = 'NORMAL',
    @AreaInicialID smallint,
    @ExpedienteID int OUTPUT,
    @NumeroExpediente [dbo].[NumeroExpediente] OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @AnioActual char(4) = CAST(YEAR(GETDATE()) AS char(4));
        DECLARE @Correlativo int;

        SELECT @Correlativo = ISNULL(MAX(CAST(RIGHT([NumeroExpediente], 5) AS int)), 0) + 1
        FROM [Tramite].[ExpedienteDocumento]
        WHERE [NumeroExpediente] LIKE 'EXP-' + @AnioActual + '-%';

        SET @NumeroExpediente = 'EXP-' + @AnioActual + '-' + RIGHT('00000' + CAST(@Correlativo AS varchar(5)), 5);

        DECLARE @EsExhaustivo [dbo].[Flag];
        SELECT @EsExhaustivo = [EsRevisionExhaustiva] FROM [Tramite].[TipoDocumento] WHERE [TipoDocumentoID] = @TipoDocumentoID;

        INSERT INTO [Tramite].[ExpedienteDocumento] (
            [NumeroExpediente],
            [TipoDocumentoID],
            [RemitenteEntidadID],
            [DniSolicitante],
            [NombresSolicitante],
            [Asunto],
            [NumeroFolios],
            [CanalIngreso],
            [Prioridad],
            [EstadoExpediente],
            [AreaActualID],
            [FechaIngreso],
            [EsExhaustivo]
        )
        VALUES (
            @NumeroExpediente,
            @TipoDocumentoID,
            @RemitenteEntidadID,
            @DniSolicitante,
            @NombresSolicitante,
            @Asunto,
            @NumeroFolios,
            @CanalIngreso,
            @Prioridad,
            'REGISTRADO',
            @AreaInicialID,
            GETDATE(),
            @EsExhaustivo
        );

        SET @ExpedienteID = SCOPE_IDENTITY();

        INSERT INTO [Tramite].[DerivacionPaso] (
            [ExpedienteID],
            [PasoNumero],
            [AreaOrigenID],
            [AreaDestinoID],
            [FechaEnvio],
            [FechaRecepcion],
            [ProveidoInstruccion],
            [EstadoPaso]
        )
        VALUES (
            @ExpedienteID,
            1,
            @AreaInicialID,
            @AreaInicialID,
            GETDATE(),
            GETDATE(),
            'Ingreso y recepcion oficial en Mesa de Partes.',
            'RECIBIDO'
        );
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [Colegiatura].[uspEvaluarHabilidadColegiado]
    @ColegiadoID int,
    @RegistradoPor sysname = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @RegistradoPor IS NULL
            SET @RegistradoPor = SUSER_SNAME();

        DECLARE @CuotasImpagas smallint;
        SELECT @CuotasImpagas = COUNT(*)
        FROM [Finanzas].[CuotaMensualColegiado]
        WHERE [ColegiadoID] = @ColegiadoID
          AND [EstadoCuota] = 'PENDIENTE'
          AND [FechaVencimiento] < CAST(GETDATE() AS date);

        DECLARE @EstadoPrevio nvarchar(30);
        SELECT @EstadoPrevio = [EstadoHabilidadActual] FROM [Colegiatura].[Colegiado] WHERE [ColegiadoID] = @ColegiadoID;

        DECLARE @NuevoEstado nvarchar(30);
        IF @CuotasImpagas <= 2
            SET @NuevoEstado = 'HABIL';
        ELSE
            SET @NuevoEstado = 'INHABILITADO_DEUDA';

        IF @EstadoPrevio <> @NuevoEstado
        BEGIN
            UPDATE [Colegiatura].[Colegiado]
            SET [EstadoHabilidadActual] = @NuevoEstado,
                [CantidadCuotasPendientes] = @CuotasImpagas,
                [ModifiedDate] = GETDATE()
            WHERE [ColegiadoID] = @ColegiadoID;

            UPDATE [Colegiatura].[EstadoHabilidadHistorial]
            SET [FechaVigenciaHasta] = GETDATE(),
                [ModifiedDate] = GETDATE()
            WHERE [ColegiadoID] = @ColegiadoID AND [FechaVigenciaHasta] IS NULL;

            INSERT INTO [Colegiatura].[EstadoHabilidadHistorial] (
                [ColegiadoID],
                [EstadoHabilidad],
                [MotivoCambio],
                [FechaVigenciaDesde],
                [RegistradoPor]
            )
            VALUES (
                @ColegiadoID,
                @NuevoEstado,
                CASE WHEN @NuevoEstado = 'HABIL' THEN 'Regularizacion de cuotas ordinarias.' ELSE 'Acumulacion de 3 o mas cuotas impagas.' END,
                GETDATE(),
                @RegistradoPor
            );
        END;
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE [Calidad].[uspRegistrarEncuestaServqual]
    @ExpedienteID int,
    @EntidadEvaluadorID int = NULL,
    @P1 tinyint,
    @P2 tinyint,
    @P3 tinyint,
    @P4 tinyint,
    @P5 tinyint,
    @TiempoEntregaPercibido nvarchar(30) = 'ADECUADO',
    @Comentarios nvarchar(500) = NULL,
    @EncuestaID bigint OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @PuntuacionGlobal decimal(4,2);
        SET @PuntuacionGlobal = (CAST(@P1 AS decimal(4,2)) + @P2 + @P3 + @P4 + @P5) / 5.00;

        INSERT INTO [Calidad].[EncuestaServqual] (
            [ExpedienteID],
            [EntidadEvaluadorID],
            [FechaRespuesta],
            [P1_Fiabilidad],
            [P2_CapacidadRespuesta],
            [P3_Seguridad],
            [P4_Empatia],
            [P5_ElementosTangibles],
            [PuntuacionGlobal],
            [TiempoEntregaPercibido],
            [Comentarios]
        )
        VALUES (
            @ExpedienteID,
            @EntidadEvaluadorID,
            GETDATE(),
            @P1,
            @P2,
            @P3,
            @P4,
            @P5,
            @PuntuacionGlobal,
            @TiempoEntregaPercibido,
            @Comentarios
        );

        SET @EncuestaID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        EXEC [dbo].[uspLogError];
        EXEC [dbo].[uspPrintError];
        THROW;
    END CATCH;
END;
GO

-- -----------------------------------------------------------------------------
-- K. EXTENDED PROPERTIES DE DOCUMENTACION EN SQL SERVER (SP_ADDEXTENDEDPROPERTY)
-- -----------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la version actual de la base de datos y la fecha del despliegue oficial.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'CORLADBuildVersion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico y clave primaria del registro de version.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'CORLADBuildVersion', @level2type=N'COLUMN', @level2name=N'SystemInformationID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de version de la base de datos en formato ''1.0.2026.09''.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'CORLADBuildVersion', @level2type=N'COLUMN', @level2name=N'DatabaseVersion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en que se genero la version del release.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'CORLADBuildVersion', @level2type=N'COLUMN', @level2name=N'VersionDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de la ultima actualizacion del registro.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'CORLADBuildVersion', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auditoria de todas las sentencias DDL ejecutadas en la base de datos capturadas por trigger.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el registro de auditoria DDL.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'DatabaseLogID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora exacta en que ocurrio el cambio DDL.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'PostTime';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de base de datos que ejecuto la sentencia DDL.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'DatabaseUser';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de evento DDL ejecutado (CREATE_TABLE, ALTER_TABLE, etc).', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'Event';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del esquema al que pertenece el objeto modificado.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'Schema';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del objeto modificado por la sentencia.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'Object';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sentencia Transact-SQL exacta que fue ejecutada.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'TSQL';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Datos en formato XML generados por el evento del trigger.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'DatabaseLog', @level2type=N'COLUMN', @level2name=N'XmlEvent';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registro de excepciones de T-SQL capturadas en el bloque CATCH de procedimientos almacenados.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el registro de errores.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorLogID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en que ocurrio el error de base de datos.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorTime';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que ejecuto el lote que genero el error.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'UserName';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de error devuelto por la funcion ERROR_NUMBER().', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorNumber';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nivel de severidad del error devuelto por ERROR_SEVERITY().', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorSeverity';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del error devuelto por ERROR_STATE().', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorState';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del procedimiento o trigger donde ocurrio la falla.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorProcedure';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de linea en el codigo donde se provoco la excepcion.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorLine';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Texto descriptivo del mensaje de error capturado.', @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'ErrorLog', @level2type=N'COLUMN', @level2name=N'ErrorMessage';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Supertipo relacional para cualquier participante en el ecosistema institucional (Personas y Organizaciones).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico maestro de la entidad.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de entidad: ''PERSONA_NATURAL'' o ''PERSONA_JURIDICA''.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad', @level2type=N'COLUMN', @level2name=N'TipoEntidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro inicial de la entidad en el sistema.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad', @level2type=N'COLUMN', @level2name=N'FechaRegistro';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = Inactivo, 1 = Activo en el sistema.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad', @level2type=N'COLUMN', @level2name=N'Activo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de ultima modificacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Entidad', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Subtipo para personas naturales: colegiados, postulantes, directivos, colaboradores y ciudadanos.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria y foranea hacia Persona.Entidad.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documento Nacional de Identidad oficial de 8 digitos numericos.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'Dni';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primer apellido de la persona natural.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'ApellidoPaterno';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segundo apellido de la persona natural.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'ApellidoMaterno';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombres de la persona natural.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'Nombres';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sexo segun RENIEC: ''M'' = Masculino, ''F'' = Femenino.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'Sexo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado civil: ''S''=Soltero, ''C''=Casado, ''V''=Viudo, ''D''=Divorciado.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'EstadoCivil';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de nacimiento de la persona.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'FechaNacimiento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Es miembro de la orden CORLAD Junin, 0 = No colegiado.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'EsColegiado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Tiene expediente activo de postulacion a colegiatura.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'EsPostulante';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Es personal administrativo o funcionario en planilla.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'EsEmpleado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador global unico para integraciones.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'rowguid';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de ultima modificacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Persona', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direcciones postales, residenciales y laborales de las entidades.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el registro de direccion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'DireccionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad a la que pertenece la direccion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo: ''DOMICILIO'', ''TRABAJO'', ''LEGAL_NOTIFICACION''.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'TipoDireccion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Region o departamento geografico.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'Departamento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Provincia politica.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'Provincia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distrito de residencia.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'Distrito';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Calle, avenida, numero, manzana, lote o urbanizacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'DireccionDetalle';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Punto de referencia geografico.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'Referencia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Direccion principal para notificaciones oficiales.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'EsPrincipal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion del registro.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Direccion', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Medios de contacto: telefonos celulares, fijos y correos electronicos.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el medio de contacto.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'ContactoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad titular del medio de contacto.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''CELULAR'', ''TELEFONO_FIJO'', ''EMAIL_PERSONAL'', ''EMAIL_INSTITUCIONAL''.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'TipoContacto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero telefonico o direccion de correo electronico.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'ValorContacto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Canal preferente de notificacion del sistema.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'EsPrincipal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Verificado mediante codigo OTP o token de activacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'Verificado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Contacto', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuentas de usuario para autenticacion en el sistema web y mesa de partes virtual.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del usuario del sistema.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'UsuarioID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad vinculada a la cuenta de usuario.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de usuario unico para inicio de sesion (DNI o alias).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'Login';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash criptografico de la contrasena (PBKDF2/SHA-256).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'PasswordHash';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sal criptografica para robustez del hash.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'PasswordSalt';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Cuenta habilitada, 0 = Cuenta bloqueada o suspendida.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contador de autenticaciones fallidas consecutivas.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'IntentosFallidos';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora hasta la cual la cuenta permanece bloqueada por seguridad.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'BloqueadoHasta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Requiere doble factor de autenticacion obligatorio.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'Requiere2FA';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave secreta base32 para TOTP (Google Authenticator).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'Secret2FA';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora del ultimo inicio de sesion exitoso.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'UltimoAcceso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Usuario', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Roles institucionales y perfiles de autorizacion para el control de acceso (RBAC).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del rol de usuario.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'RolID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo institucional unico: ''ROL-DEC'', ''ROL-GER'', ''ROL-SEC'', etc.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'CodigoRol';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre descriptivo del rol (Decano Regional, Administrador, etc).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'NombreRol';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de atribuciones y responsabilidades en el sistema.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'Descripcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Rol disponible para asignacion, 0 = Inactivo.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'Rol', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asignacion formal de roles de operacion a cada cuenta de usuario.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del usuario.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol', @level2type=N'COLUMN', @level2name=N'UsuarioID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del rol asignado.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol', @level2type=N'COLUMN', @level2name=N'RolID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se confirio el rol al usuario.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol', @level2type=N'COLUMN', @level2name=N'FechaAsignacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario del sistema que autorizo la asignacion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol', @level2type=N'COLUMN', @level2name=N'AsignadoPor';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Asignacion vigente, 0 = Revocada.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'UsuarioRol', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Trazabilidad forense de conexiones y autenticaciones de usuarios.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el registro de sesion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'SesionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario involucrado en el intento de acceso.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'UsuarioID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp exacto de la conexion.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'FechaInicio';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp del cierre de sesion o expiracion de token.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'FechaFin';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion IP de origen (IPv4 o IPv6).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'DireccionIP';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User-Agent del navegador web o cliente movil.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'Dispositivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Autenticacion correcta, 0 = Intento fallido.', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'Exitoso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Causa del rechazo (Contrasena incorrecta, Cuenta bloqueada, etc).', @level0type=N'SCHEMA', @level0name=N'Persona', @level1type=N'TABLE', @level1name=N'AuditoriaSesion', @level2type=N'COLUMN', @level2name=N'MotivoFallo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros tecnicos de conexion con el servicio web de RENIEC.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del parametro.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'ParametroID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la clave de configuracion (URL_ENDPOINT, TOKEN_VIGENCIA, etc).', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'Clave';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor asignado al parametro de configuracion.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'Valor';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Explicacion tecnica del proposito del parametro.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'Descripcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Parametro vigente para el consumo de la API.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ParametroConfiguracion', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cache local de respuestas validadas por RENIEC para ahorro de costos y reduccion de latencia.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documento Nacional de Identidad de 8 digitos.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'Dni';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Digito de control oficial emitido por RENIEC.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'DigitoVerificador';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primer apellido segun padron electoral.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'ApellidoPaterno';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segundo apellido segun padron electoral.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'ApellidoMaterno';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombres segun acta de nacimiento oficial.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'Nombres';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado civil registrado en RENIEC.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'EstadoCivil';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Titular fallecido, 0 = Ciudadano con vida.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'RestriccionFallecido';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fotografia digital oficial en formato binario.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'FotoBinaria';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fotografia codificada en Base64 para consumo web rapido.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'FotoBase64';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se consulto el servicio web de RENIEC.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'FechaConsulta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha limite de validez de la cache (TTL, ej. 90 dias).', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'FechaExpiracionCache';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash SHA-256 de la carga util (payload) recibida para no repudio.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'PersonaIdentidadCache', @level2type=N'COLUMN', @level2name=N'HashRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bitacora inmutable de auditoria de consultas consumidas a la API de RENIEC (Ley N 29733).', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para el registro de auditoria.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'ConsultaLogID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DNI sobre el cual se realizo la consulta de identidad.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'DniConsultado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operador del sistema que provoco la llamada al servicio.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'UsuarioID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp exacto en que se envio la peticion HTTP.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'FechaConsulta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de estado HTTP (200, 400, 401, 404, 500).', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'CodigoRespuestaHttp';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''EXITOSA'', ''NO_ENCONTRADO'', ''FALLO_CONEXION'', ''ERROR_AUTENTICACION''.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'EstadoConsulta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Resumen o glosa de la respuesta devuelta por RENIEC.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'MensajeRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo de latencia de red y procesamiento en milisegundos.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'TiempoRespuestaMs';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP publica/privada desde donde se origino la solicitud.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'DireccionIP';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash anonimizado del token Bearer utilizado.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'TokenHash';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modulo que invoco el servicio: ''MESA_PARTES'', ''COLEGIATURA'', ''PORTAL_WEB''.', @level0type=N'SCHEMA', @level0name=N'Reniec', @level1type=N'TABLE', @level1name=N'ConsultaDniLog', @level2type=N'COLUMN', @level2name=N'ModuloOrigen';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Padron maestro oficial de Licenciados en Administracion incorporados a la orden regional.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro del colegiado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'ColegiadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad vinculada al colegiado en el esquema Persona.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de matricula asignado en Junin (Ej: ''CORLAD-JUN-03421'').', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'MatriculaRegional';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de registro nacional expedido por CLAD Lima.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'MatriculaNacional';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha protocolar de juramentacion oficial como colegiado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'FechaIncorporacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''ORDINARIO'', ''VITALICIO'', ''FALLECIDO'', ''TRASLADADO''.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'CondicionColegiado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''HABIL'', ''INHABILITADO_DEUDA'', ''INHABILITADO_SANCION''.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'EstadoHabilidadActual';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de meses adeudados acumulados.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'CantidadCuotasPendientes';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ultimo mes cancelado en formato ''YYYY-MM'' (Ej: ''2026-08'').', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'UltimoPeriodoPagado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de ultima actualizacion.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'Colegiado', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Legajo de postulacion y tramite exhaustivo de incorporacion de nuevos titulados.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del tramite de colegiatura.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'ExpedienteColegiaturaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Postulante titular del expediente.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo unico del expediente (EXP-YYYY-XXXXX).', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'NumeroExpediente';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de admision del legajo en mesa de partes.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'FechaPresentacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''REGISTRADO'', ''EN_REVISION'', ''OBSERVADO'', ''APROBADO_CONSEJO'', ''ELEVADO_LIMA'', ''LISTO_JURAMENTACION'', ''CONCLUIDO''.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'EstadoRevision';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Titulo verificado positivamente ante el registro SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'ValidadoSunedu';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = DNI y nombres validados fehacientemente ante RENIEC.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'ValidadoReniec';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Aprobado formalmente por Acuerdo de Consejo Directivo Regional.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'AprobadoConsejo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de resolucion decanal de incorporacion (Ej: ''RD-045-2026-CORLAD-J'').', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'NumeroResolucionIncorporacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha programada de la ceremonia protocolar de juramento.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'FechaJuramentacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pliego de observaciones formuladas al legajo documentario.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'Observaciones';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'ExpedienteColegiatura', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Informacion academica del titulo profesional en administracion verificado con SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del titulo profesional.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'TituloID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Titular graduado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre oficial de la universidad que confirio el grado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'UniversidadOrigen';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Denominacion exacta del titulo profesional.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'DenominacionTitulo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de emision oficial del diploma de grado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'FechaExpedicion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Resolucion de aprobacion rectoral o resolucion SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'NumeroResolucionSunedu';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo unico alfanumerico en el Registro Nacional de Grados y Titulos.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'CodigoRegistroSunedu';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Verificado mediante interoperabilidad con API SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'VerificadoConSunedu';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp exacto de la confirmacion con el padron de SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'FechaVerificacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta fisica o URI del diploma escaneado en alta resolucion.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'TituloProfesional', @level2type=N'COLUMN', @level2name=N'DocumentoTituloUrl';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Historial inmutable de estados de habilitacion del profesional para fines deontologicos y publicos.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del evento de cambio de habilidad.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'HistorialHabilidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Colegiado evaluado.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'ColegiadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''HABIL'', ''INHABILITADO_DEUDA'', ''INHABILITADO_SANCION''.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'EstadoHabilidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Causa del cambio: ''PAGO_CUOTAS'', ''MORA_3_MESES'', ''SANCION_TRIBUNAL_HONOR''.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'MotivoCambio';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inicio de la vigencia de la condicion de habilidad.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'FechaVigenciaDesde';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fin de vigencia (NULL si continua en vigor).', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'FechaVigenciaHasta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario o proceso automatico que modifico la condicion.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'RegistradoPor';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Colegiatura', @level1type=N'TABLE', @level1name=N'EstadoHabilidadHistorial', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de organos de linea, direccion y apoyo receptores de expedientes.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del area organica.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'AreaOrganicaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo institucional (Ej: ''DEC'', ''GER'', ''SEC'', ''TES'', ''DAC'', ''LEG'', ''HON'').', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'CodigoArea';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre oficial: Decanatura, Gerencia Regional, Mesa de Partes, etc.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'NombreArea';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Funcionario o directivo titular a cargo del despacho.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'ResponsableEntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Directivo, 2 = Administrativo, 3 = Apoyo operativo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'NivelJerarquico';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Area operativa, 0 = Desactivada.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'AreaOrganica', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clasificador maestro de tramites, diferenciando atencion rapida vs revision exhaustiva.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del tipo de documento.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'TipoDocumentoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo abreviado: ''HABILIDAD_DIGITAL'', ''EXP_COLEGIATURA'', ''AUXILIO_MUTUO'', etc.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'CodigoTipo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre legible del procedimiento o documento oficial.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'NombreTipo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion detallada y requisitos normativos exigidos.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'Descripcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Requiere revision colegiada/comision/peritaje, 0 = Emision rapida.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'EsRevisionExhaustiva';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plazo legal perentorio segun Ley 27444 (dias habiles).', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'PlazoMaximoLegalDias';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acuerdo de nivel de servicio (SLA) institucional prometido.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'PlazoSlaEstimadoDias';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Derecho arancelario segun TUPA del CORLAD Junin.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'CostoTramite';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Exige validacion obligatoria con API RENIEC.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'RequiereReniec';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Exige validacion obligatoria con registro SUNEDU.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'RequiereSunedu';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Disponible para solicitud, 0 = Inactivo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'TipoDocumento', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cabecera principal de expedientes recibidos en mesa de partes fisica o virtual (SGD).', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria interna del expediente.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo visible unico en formato ''EXP-YYYY-XXXXX''.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'NumeroExpediente';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de tramite o procedimiento solicitado.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'TipoDocumentoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad que formula el requerimiento o tramite.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'RemitenteEntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DNI validado del presentante en ventanilla o web.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'DniSolicitante';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre completo consolidado segun consulta oficial.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'NombresSolicitante';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sumilla o resumen de la peticion formulada.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'Asunto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de hojas o folios fisicos/digitales que componen el legajo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'NumeroFolios';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''VIRTUAL'' (Mesa de partes 24/7) o ''PRESENCIAL'' (Ventanilla).', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'CanalIngreso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''BAJA'', ''NORMAL'', ''ALTA'', ''URGENTE''.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'Prioridad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''REGISTRADO'', ''DERIVADO'', ''EN_EVALUACION'', ''OBSERVADO'', ''ATENDIDO'', ''ARCHIVADO''.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'EstadoExpediente';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area organica que actualmente custodia y tramita el expediente.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'AreaActualID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de admision oficial en el sistema.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'FechaIngreso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de conclusion o entrega formal al usuario.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'FechaCierre';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera de sincronizacion con el modelo de complejidad de ML.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'EsExhaustivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ExpedienteDocumento', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Movimientos y proveidos internos entre despachos para la atencion del tramite.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del paso de derivacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'DerivacionPasoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente que se deriva.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Secuencia ordinal del movimiento (1, 2, 3...).', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'PasoNumero';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area que despacha el documento.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'AreaOrigenID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area receptora competente.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'AreaDestinoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Especialista o directivo encargado del analisis.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'FuncionarioAsignadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de salida del area emisora.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'FechaEnvio';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp en que el area destino acepta el pase.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'FechaRecepcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp en que el despacho culmina su intervencion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'FechaAtencion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Directiva u orden: ''Para informe legal'', ''Para ejecucion'', etc.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'ProveidoInstruccion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''EN_TRANSITO'', ''RECIBIDO'', ''ATENDIDO'', ''DEVUELTO''.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'EstadoPaso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo neto de permanencia en el area en minutos.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'DuracionMinutos';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DerivacionPaso', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Archivos digitales sustentatorios con calculo de hash SHA-256 para garantizar integridad.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del adjunto.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'DocumentoAdjuntoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente contenedor del archivo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre original del fichero subido por el usuario.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'NombreArchivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extension del archivo (pdf, jpg, png, zip).', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'Extension';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta fisica segura en el servidor de archivos.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'RutaAlmacenamiento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash SHA-256 de 64 caracteres hexadecimales del archivo binario.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'HashSHA256';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tamano del fichero expresado en bytes.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'TamanoBytes';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de contenido MIME de internet.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'TipoMime';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de subida del archivo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'DocumentoAdjunto', @level2type=N'COLUMN', @level2name=N'FechaCarga';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Certificados oficiales de habilitacion profesional generados digitalmente con codigo QR.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la constancia de habilidad.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'ConstanciaHabilidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Colegiado habilitado titular de la constancia.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'ColegiadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente asociado si fue solicitado por mesa de partes.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cadena criptografica unica impresa en el codigo QR.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'CodigoVerificacionQR';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correlativo oficial (Ej: ''CONST-HAB-2026-01294'').', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'NumeroConstancia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de generacion y sellado de tiempo.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'FechaEmision';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha limite de validez legal del documento.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'FechaCaducidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Firma digital X.509 aplicada con el certificado del Decano.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'HashFirmaDigital';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Documento vigente y legitimo, 0 = Revocada o adulterada.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'EsValida';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad que descargo el PDF desde el portal web.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'DescargadoPorEntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Tramite', @level1type=N'TABLE', @level1name=N'ConstanciaHabilidad', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de modelos de aprendizaje automatico supervisado entrenados y registrados (MLOps).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del modelo de ML.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'ModeloID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Denominacion: ''PredictorTiemposEntregaDocumentos_XGBoost'', etc.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'NombreModelo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version semantica del artefacto: ''v1.0.0'', ''v2.1.0''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'VersionModelo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''XGBoost_Regressor'', ''Random_Forest'', ''MLP_NeuralNetwork'', ''Gradient_Boosting''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'TipoAlgoritmo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''REGRESION'' (Tiempo en dias) o ''CLASIFICACION'' (Riesgo de retraso).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'TipoTarea';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cadena JSON con hiperparametros optimizados (n_estimators, max_depth, lr).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'HiperparametrosJson';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Coeficiente de determinacion R-cuadrado en conjunto de prueba.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'MetricaR2';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error absoluto medio (MAE) en dias obtenido en validacion.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'MetricaMAE';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Raiz del error cuadratico medio (RMSE) en dias.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'MetricaRMSE';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Porcentaje de predicciones dentro de la tolerancia de +/- 1 dia.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'Exactitud';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp en que finalizo el proceso de ajuste de parametros.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'FechaEntrenamiento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Modelo en produccion para inferencias en tiempo real.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'EsModeloActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Observaciones tecnicas del cientifico de datos.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'NotasModelo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'ModeloPredictivo', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Historial de evaluacion de desempeno y validacion cruzada del modelo predictivo.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro de evaluacion.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'MetricaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modelo de ML evaluado.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'ModeloID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de la sesion de benchmarking.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'FechaEvaluacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''TRAIN'', ''VALIDATION'', ''TEST'', ''PRODUCCION''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'TipoDataset';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de expedientes incluidos en el conjunto evaluado.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'MuestrasEvaluadas';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mean Absolute Error obtenido.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'MAE';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Root Mean Squared Error obtenido.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'RMSE';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'R-cuadrado alcanzado.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'R2';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'F1-Score para clasificacion de riesgo de retraso.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'F1Score';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comentarios sobre sobreajuste o estabilidad del modelo.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'MetricaRendimiento', @level2type=N'COLUMN', @level2name=N'Observaciones';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Conjunto consolidado de variables (features) y tiempos reales para reentrenamiento continuo (MLOps).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro historico de entrenamiento.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'RegistroHistoricoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente del cual se extrajeron las caracteristicas.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable categorica: Identificador de tipo de tramite.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'TipoDocumentoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable binaria: 1 = Requiere revision colegiada/comisiones.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'EsRevisionExhaustiva';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable numerica: Volumen documental a revisar.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'NumeroFolios';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable categorica: Ultima area que resolvio el tramite.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'AreaFinalID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable numerica: Numero de expedientes pendientes en el area en t=0.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'CargaLaboralColaEnIngreso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable numerica: Cantidad de recaudos adjuntos conformes.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'CantidadRequisitosCumplidos';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable estacional: Mes del ano (1 a 12).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'MesIngreso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable temporal: Dia de la semana (1 = Lunes a 7 = Domingo).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'DiaSemana';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable temporal: Hora militar de presentacion (8 a 18).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'HoraIngreso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable binaria: 1 si interopera con SUNEDU/CLAD Lima.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'RequiereValidacionExterna';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Variable binaria: 1 si el legajo sufrio observaciones.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'TuvoObservacionesPrevias';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Target (variable objetivo Y): Dias habiles netos de culminacion.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'DiasRealesAtencion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Target granular: Horas netas de atencion efectiva.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'HorasRealesAtencion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Atendido dentro del SLA institucional, 0 = Retrasado.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'CumplioSLA';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion del vector de entrenamiento.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'DatasetHistoricoTramite', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inferencias en tiempo real de fecha y plazo de entrega estimadas para cada expediente ingresado.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro de inferencia de ML.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'PrediccionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente evaluado por el modelo predictivo.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modelo de aprendizaje automatico que ejecuto la inferencia.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'ModeloID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plazo previsto en dias habiles devuelto por el regresor.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'DiasEstimadosEntrega';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plazo previsto expresado en horas habiles.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'HorasEstimadasEntrega';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora exacta proyectada de conclusion del tramite.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'FechaEstimadaEntrega';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Limite inferior del intervalo de confianza predictivo (95%).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'IntervaloConfianzaMin';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Limite superior del intervalo de confianza predictivo (95%).', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'IntervaloConfianzaMax';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Probabilidad (0.00 a 1.00) de que el tramite supere el SLA institucional.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'ProbabilidadRetraso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''BAJO'', ''MEDIO'', ''ALTO'', ''CRITICO''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'NivelRiesgoRetraso';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp exacto en que se calculo la inferencia.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'FechaPrediccion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp real cuando el tramite fue finalizado por el funcionario.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'FechaRealEntrega';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error de estimacion en dias: |FechaReal - FechaEstimada|.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'ErrorAbsolutoDias';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Cumplida dentro del intervalo de tolerancia (+/- 1 dia), 0 = Desviada.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'EsPrediccionAcertada';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notas de retroalimentacion para reajuste de hiperparametros.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'FeedbackCalidadPrediccion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'PrediccionEntregaDocumento', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Alertas operativas preventivas disparadas ante probabilidad inminente de incumplimiento de plazos.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la alerta preventiva.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'AlertaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente en condicion de riesgo de retraso.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inferencia que activo la alerta.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'PrediccionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Despacho donde se focaliza la demora.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'AreaOrganicaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''BAJA'', ''MEDIA'', ''ALTA'', ''CRITICA''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'NivelSeveridad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle explicativo de la advertencia generado por el motor de reglas.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'MensajeAlerta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de creacion de la alerta.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'FechaGeneracion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Funcionario o administrador que gestiono el destrabe.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'AtendidoPorUsuarioID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp en que se solvento la demora.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'FechaResolucion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''PENDIENTE'', ''EN_ATENCION'', ''RESUELTA'', ''DESCARTADA''.', @level0type=N'SCHEMA', @level0name=N'MachineLearning', @level1type=N'TABLE', @level1name=N'AlertaCuelloBotella', @level2type=N'COLUMN', @level2name=N'EstadoAlerta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Evaluacion de percepcion de calidad del servicio post-entrega basada en las 5 dimensiones SERVQUAL.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la encuesta SERVQUAL.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'EncuestaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expediente objeto de evaluacion por el usuario.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'ExpedienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario o colegiado que completo la evaluacion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'EntidadEvaluadorID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de registro de las calificaciones.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'FechaRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntuacion escala Likert (1 a 5): Cumplimiento de plazos prometidos.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'P1_Fiabilidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntuacion escala Likert (1 a 5): Rapidez y diligencia en la atencion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'P2_CapacidadRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntuacion escala Likert (1 a 5): Confianza en la firma digital y validacion RENIEC.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'P3_Seguridad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntuacion escala Likert (1 a 5): Informacion clara y comunicacion transparente de estados.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'P4_Empatia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntuacion escala Likert (1 a 5): Usabilidad del portal web y presentacion del documento.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'P5_ElementosTangibles';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Promedio aritmetico ponderado de las 5 dimensiones (1.00 a 5.00).', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'PuntuacionGlobal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''MUY_RAPIDO'', ''ADECUADO'', ''REGULAR'', ''EXCESIVO''.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'TiempoEntregaPercibido';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Opiniones o sugerencias directas del administrado.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'EncuestaServqual', @level2type=N'COLUMN', @level2name=N'Comentarios';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Libro de Reclamaciones virtual oficial de acuerdo al Decreto Supremo N 007-2020-PCM.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro de reclamacion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'ReclamoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correlativo normado: ''RECL-2026-00041''.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'NumeroHojaReclamo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ciudadano o colegiado denunciante.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'EntidadReclamanteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tramite documentario que motivo la queja (si aplica).', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'ExpedienteRelacionadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''QUEJA'' (Maltrato o mala atencion) o ''RECLAMO'' (Disconformidad con el servicio).', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'TipoIncidencia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hechos cronologicos fundamentados por el usuario.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'DetalleReclamo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pretension especifica solicitada por el reclamante.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'PedidoConcreto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de envio de la queja o reclamo.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'FechaRegistro';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha perentoria legal: Maximo 15 dias habiles segun ley.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'FechaLimiteRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Informe de descargo y resolucion de la Gerencia Regional.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'RespuestaInstitucional';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de notificacion oficial de respuesta.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'FechaRespuesta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''PENDIENTE'', ''EN_INVESTIGACION'', ''RESUELTO'', ''CERRADO''.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'EstadoReclamo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'LibroReclamacion', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monitoreo mensual de cumplimiento de acuerdos de nivel de servicio (SLA) y precision de ML.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del consolidado mensual.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'IndicadorID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de documento monitoreado.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'TipoDocumentoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo evaluado en formato ''YYYY-MM'' (Ej: ''2026-08'').', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'PeriodoAnioMes';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad total de expedientes concluidos en el mes.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'TotalTramitesAtendidos';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expedientes atendidos dentro del plazo pactado.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'TotalCumplieronSla';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tasa porcentual de efectividad: (Cumplieron / Total) * 100.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'PorcentajeCumplimientoSla';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Duracion media observada en dias habiles.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'PromedioDiasAtencion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Promedio mensual obtenido en encuestas de satisfaccion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'PromedioServqual';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Desviacion media absoluta observada entre la prediccion y la realidad.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'ErrorPromedioMLDias';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de ejecucion del proceso de consolidacion.', @level0type=N'SCHEMA', @level0name=N'Calidad', @level1type=N'TABLE', @level1name=N'IndicadorCalidadSLA', @level2type=N'COLUMN', @level2name=N'FechaCalculo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de diplomados, conferencias, cursos y talleres organizados por Asuntos Academicos.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del evento academico.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'EventoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo institucional (Ej: ''DIP-2026-ADM-01'').', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'CodigoEvento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre oficial de la actividad formativa.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'TituloEvento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''DIPLOMADO'', ''CONFERENCIA'', ''SEMINARIO'', ''TALLER'', ''CURSO''.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'TipoEvento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Carga lectiva de horas pedagogicas certificadas.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'HorasAcademicas';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor en creditaje universitario oficial.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'CreditosAcademicos';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de apertura del curso.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'FechaInicio';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de clausura de la actividad formativa.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'FechaFin';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifa para profesionales no agremiados y publico general.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'CostoGeneral';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifa con descuento preferencial para colegiados habiles.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'CostoColegiado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''PLANIFICADO'', ''INSCRIPCIONES_ABIERTAS'', ''EN_EJECUCION'', ''EVALUACION'', ''FINALIZADO''.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'EstadoEvento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'EventoCapacitacion', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Matricula de participantes a eventos academicos con control de notas y asistencias.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la matricula academica.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'InscripcionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Evento academico al que se matricula.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'EventoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Participante (colegiado o alumno externo).', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'EntidadID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de registro formal en el curso.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'FechaInscripcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comprobante de cancelacion de la matricula.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'ComprobantePagoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Calificacion final en escala vigesimal (0.00 a 20.00).', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'NotaFinal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tasa porcentual de participacion en sesiones de clase.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'PorcentajeAsistencia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''MATRICULADO'', ''APROBADO'', ''ASISTIO'', ''DESAPROBADO'', ''RETIRADO''.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'EstadoAprobacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'InscripcionParticipante', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Certificados digitales con valor oficial curricular provistos de QR y firma digital.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del certificado emitido.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'CertificadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inscripcion academica que amerito la certificacion.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'InscripcionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo correlativo visible (Ej: ''CERT-2026-DIP-00318'').', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'CodigoCertificado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''APROBACION'' (Nota >= 14.00 y Asistencia >= 80%) o ''ASISTENCIA''.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'TipoCertificado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hash criptografico unico representado en la imagen QR.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'HashQr';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de generacion digital del certificado.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'FechaEmision';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Enlace web institucional para validacion publica por empleadores.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'UrlVerificacionPublica';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Documento anulado por fraude o plagio, 0 = Vigente.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'EsRevocado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Academico', @level1type=N'TABLE', @level1name=N'CertificadoAcademico', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifario y catalogo de conceptos arancelarios recaudados por el CORLAD Junin.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del concepto de pago.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'ConceptoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo contable: ''CUOTA_MENSUAL'', ''DER_COLEGIATURA'', ''CONST_HABILIDAD'', etc.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'CodigoConcepto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Glosa explicativa del concepto tarifario.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'Descripcion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Importe nominal en Soles (PEN).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'MontoBase';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Genera recargo por mora al vencer el periodo.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'AplicaMora';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tasa de interes moratorio aplicable.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'PorcentajeMora';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Concepto vigente para facturacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'EsActivo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConceptoPago', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Control individual de aportes societarios mensuales para determinar el estado de habilidad.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del registro de cuota mensual.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'CuotaID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Colegiado adscrito a la obligacion estatutaria.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'ColegiadoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo en formato ''YYYY-MM'' (Ej: ''2026-09'').', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'PeriodoAnioMes';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto de la cuota ordinaria estatutaria.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'Monto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Recargo generado por pago fuera de fecha de vencimiento.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'MontoMora';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ultimo dia habil del mes correspondiente.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'FechaVencimiento';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''PENDIENTE'', ''PAGADA'', ''FRACCIONADA'', ''EXONERADA''.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'EstadoCuota';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comprobante de pago con el que se liquido la cuota.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'ComprobantePagoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de cancelacion de la obligacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'FechaPago';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'CuotaMensualColegiado', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cabecera de comprobantes de pago electronicos emitidos en caja POS o pasarela web (SUNAT).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria del comprobante de pago.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'ComprobantePagoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cliente pagador (agremiado o entidad externa).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'EntidadClienteID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''BOLETA'', ''FACTURA'', ''RECIBO_INGRESO''.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'TipoComprobante';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie autorizada por SUNAT (Ej: ''B001'', ''F001'').', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'Serie';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero correlativo secuencial del comprobante.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'Correlativo';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp de emision del documento fiscal.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'FechaEmision';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Base imponible de la transaccion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'SubTotal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Impuesto General a las Ventas (18%).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'Igv';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total cancelado en Soles.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'Total';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''EFECTIVO'', ''TRANSFERENCIA'', ''TARJETA_CREDITO'', ''BILLETERA_DIGITAL''.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'MetodoPago';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de operacion o constancia bancaria (para conciliacion).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'NumeroOperacionBancaria';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Firma digital del comprobante devuelta por el OSE/SUNAT.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'HashSunat';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''EMITIDO'', ''ACEPTADO'', ''RECHAZADO'', ''ANULADO''.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'EstadoSunat';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cajero operador responsable de la emision.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'UsuarioCajeroID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Fondo depositado y conciliado en banco < 48 horas.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'Conciliado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobantePago', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lineas de detalle de articulos y conceptos cobrados en el comprobante fiscal.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la linea de detalle.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'ComprobanteDetalleID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comprobante de pago padre.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'ComprobantePagoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concepto arancelario facturado.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'ConceptoID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Glosa descriptiva especifica impresa en el comprobante.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'DescripcionConcepto';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de unidades del bien o servicio cobrado.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'Cantidad';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Importe individual por unidad.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'PrecioUnitario';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total de la linea: Cantidad * PrecioUnitario.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ComprobanteDetalle', @level2type=N'COLUMN', @level2name=N'SubTotal';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Control y verificacion de depositos en cuentas bancarias dentro del plazo obligatorio de 48 horas.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria de la conciliacion bancaria.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'ConciliacionID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se percibieron los ingresos en caja fisica.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'FechaRecaudacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Timestamp del abono registrado en el extracto bancario.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'FechaDeposito';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad financiera y numero de cuenta receptora.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'BancoCuenta';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de operacion impreso en el voucher del banco.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'NumeroOperacion';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total efectivo recaudado segun arqueo de sistema.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'MontoCajaFisica';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total efectivamente acreditado por el banco.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'MontoDepositado';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Discrepancia entre caja y banco (MontoDepositado - MontoCajaFisica).', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'Diferencia';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo transcurrido entre el cierre de caja y el deposito bancario.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'HorasTranscurridas';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Depositado en <= 48 horas segun regla institucional, 0 = Infractor.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'CumplePlazo48h';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Encargado de Tesoreria que ejecuto la operacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'UsuarioResponsableID';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Justificaciones tecnicas ante retrasos bancarios.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'Observaciones';
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificacion.', @level0type=N'SCHEMA', @level0name=N'Finanzas', @level1type=N'TABLE', @level1name=N'ConciliacionBancaria', @level2type=N'COLUMN', @level2name=N'ModifiedDate';
GO

-- -----------------------------------------------------------------------------
-- L. INSERCION DE DATOS SEMILLA (CATALOGOS INICIALES)
-- -----------------------------------------------------------------------------
-- 1. Version de Base de Datos
INSERT INTO [dbo].[CORLADBuildVersion] ([DatabaseVersion], [VersionDate])
VALUES ('1.0.2026.09', GETDATE());

-- 2. Parametros de Configuracion de la API RENIEC
INSERT INTO [Reniec].[ParametroConfiguracion] ([Clave], [Valor], [Descripcion], [EsActivo])
VALUES 
('RENIEC_API_URL', 'https://api.reniec.gob.pe/v1/identidad/consultar', 'Endpoint seguro oficial del servicio web de RENIEC.', 1),
('RENIEC_API_TOKEN_TTL_MIN', '60', 'Tiempo de expiracion del token de autenticacion OAuth2.', 1),
('RENIEC_CACHE_TTL_DIAS', '90', 'Dias de permanencia de datos en PersonaIdentidadCache.', 1),
('RENIEC_TIMEOUT_MS', '5000', 'Tiempo maximo de espera antes de considerar caida la conexion.', 1),
('RENIEC_MODO_SIMULACION', '0', '0 = Produccion REST RENIEC, 1 = Modo Sandbox institucional.', 1);

-- 3. Roles Institucionales (RBAC)
INSERT INTO [Persona].[Rol] ([CodigoRol], [NombreRol], [Descripcion], [EsActivo])
VALUES 
('ROL-DEC', 'Decano Regional', 'Maxima direccion institucional, firma digital de diplomas y resoluciones.', 1),
('ROL-CDIR', 'Consejo Directivo', 'Organo colegiado de gobierno, aprobacion de acuerdos y auxilios mutuos.', 1),
('ROL-GER', 'Gerente Regional', 'Conduccion administrativa, control de calidad, compras y supervision.', 1),
('ROL-SEC', 'Secretaria / Mesa de Partes', 'Recepcion documentaria, emision de habilidad, foliado y archivo central.', 1),
('ROL-TES', 'Tesoreria y Cobranzas', 'Caja POS, emision de boletas/facturas y conciliacion bancaria < 48h.', 1),
('ROL-DAC', 'Director Academico', 'Gestion curricular de diplomados, actas de notas y certificados QR.', 1),
('ROL-DBS', 'Director de Bienestar', 'Evaluacion de fondo de prevision social y subsidios por auxilio mutuo.', 1),
('ROL-DIC', 'Director Cientifico', 'Asesoria de tesis, comite editorial y repositorio digital OAI-PMH.', 1),
('ROL-MKT', 'Marketing y Comercial', 'Portal web, gestion de redes, campanas de colegiatura y prensa.', 1),
('ROL-LEG', 'Asesor Legal', 'Dictamenes juridicos, visacion de convenios y defensa Ley 31060.', 1),
('ROL-CON', 'Contador General', 'Libros electronicos PLE/SIRE, balances tributarios y asientos contables.', 1),
('ROL-LOG', 'Encargado de Logistica', 'Control de almacen Kardex, pecosas y adquisiciones institucionales.', 1),
('ROL-TIC', 'Especialista TIC / Admin TI', 'Administracion de base de datos, seguridad, roles, backups y ML.', 1),
('ROL-HON', 'Tribunal de Honor', 'Procesos deontologicos, pliego de cargos y resoluciones de sancion.', 1),
('ROL-AGR', 'Colegiado Titular', 'Portal de autoservicio: Pagos, habilidad digital y seguimiento.', 1),
('ROL-POS', 'Postulante a Colegiatura', 'Pre-registro web y carga de expediente digital para admision.', 1),
('ROL-CIU', 'Ciudadano / Entidad Externa', 'Consulta publica de habilidad y tramites en Mesa de Partes Virtual.', 1);

-- 4. Areas Organicas Receptores
INSERT INTO [Tramite].[AreaOrganica] ([CodigoArea], [NombreArea], [NivelJerarquico], [EsActivo])
VALUES 
('DEC', 'Decanatura Regional', 1, 1),
('CDIR', 'Consejo Directivo Regional', 1, 1),
('GER', 'Gerencia / Administracion Regional', 2, 1),
('SEC', 'Secretaria Regional / Mesa de Partes', 2, 1),
('TES', 'Tesoreria y Cobranzas', 2, 1),
('DAC', 'Direccion de Asuntos Academicos', 2, 1),
('DBS', 'Direccion de Seguridad y Bienestar Social', 2, 1),
('DIC', 'Direccion de Informacion Cientifica y Tesis', 2, 1),
('LEG', 'Asesoria Legal y Defensa Profesional', 2, 1),
('HON', 'Tribunal de Honor Regional', 1, 1),
('LOG', 'Logistica y Abastecimiento', 3, 1),
('TIC', 'Tecnologias de Informacion y Comunicaciones', 3, 1);

-- 5. Tipos de Tramites (Rapidos vs Revision Exhaustiva)
INSERT INTO [Tramite].[TipoDocumento] (
    [CodigoTipo], [NombreTipo], [Descripcion], [EsRevisionExhaustiva],
    [PlazoMaximoLegalDias], [PlazoSlaEstimadoDias], [CostoTramite], [RequiereReniec], [RequiereSunedu], [EsActivo]
)
VALUES 
('CONST_HABILIDAD', 'Constancia de Habilidad Profesional Digital', 'Emision automatica con codigo QR sujeta a no adeudo <= 2 cuotas.', 0, 1, 1, 20.00, 1, 0, 1),
('CERT_CURSO', 'Certificado de Evento Academico / Diplomado', 'Certificado con valor curricular sujeto a aprobacion y asistencia.', 0, 3, 2, 30.00, 1, 0, 1),
('CONST_NO_SANCION', 'Constancia de No Registro de Sancion Etica', 'Certificacion expedida por el Tribunal de Honor de conducta intachable.', 0, 3, 2, 25.00, 1, 0, 1),
('DUPLICADO_CARNET', 'Duplicado de Carnet Oficial de Colegiado', 'Emision de credencial institucional por perdida o deterioro.', 0, 5, 3, 35.00, 1, 0, 1),
('EXP_COLEGIATURA', 'Expediente de Incorporacion y Colegiatura Profesional', 'Tramite exhaustivo: Verificacion SUNEDU, dictamen, Consejo, CLAD Lima y juramentacion.', 1, 30, 15, 650.00, 1, 1, 1),
('AUXILIO_MUTUO', 'Solicitud de Subsidio por Auxilio Mutuo (Fondo Prevision)', 'Revision medica/defuncion, carencia >= 6m, dictamen Bienestar y aprobacion Consejo.', 1, 30, 10, 0.00, 1, 0, 1),
('DENUNCIA_ETICA', 'Denuncia Deontologica ante el Tribunal de Honor', 'Instruccion etica, notificacion de cargos (10d), descargos, audiencia y resolucion.', 1, 45, 20, 0.00, 1, 0, 1),
('DICTAMEN_LEGAL', 'Solicitud de Intervencion Juridica por Intrusismo (Ley 31060)', 'Defensa gremial frente a plazas publicas que omitan colegiatura obligatoria.', 1, 30, 12, 0.00, 1, 0, 1),
('TRAMITE_GENERAL', 'Solicitud o Recurso Administrativo General (Ley 27444)', 'Cartas, peticiones y recursos de reconsideracion o apelacion.', 1, 30, 15, 0.00, 1, 0, 1);

-- 6. Conceptos Arancelarios de Cobranza
INSERT INTO [Finanzas].[ConceptoPago] ([CodigoConcepto], [Descripcion], [MontoBase], [AplicaMora], [PorcentajeMora], [EsActivo])
VALUES 
('CUOTA_MENSUAL', 'Cuota Societaria Mensual Ordinaria', 20.00, 1, 5.00, 1),
('DER_COLEGIATURA', 'Derecho de Incorporacion y Colegiatura Integral', 650.00, 0, 0.00, 1),
('CONST_HABILIDAD', 'Expedicion de Constancia de Habilidad Profesional', 20.00, 0, 0.00, 1),
('CERT_EVENTO', 'Derecho de Certificacion en Diplomado o Taller', 30.00, 0, 0.00, 1),
('DUPLICADO_CARNET', 'Duplicado de Carnet Institucional', 35.00, 0, 0.00, 1),
('ALQUILER_AUDITORIO', 'Alquiler de Auditorio Institucional por Hora', 120.00, 0, 0.00, 1);

-- 7. Modelo Inicial de Machine Learning Parametrizado
INSERT INTO [MachineLearning].[ModeloPredictivo] (
    [NombreModelo], [VersionModelo], [TipoAlgoritmo], [TipoTarea],
    [HiperparametrosJson], [MetricaR2], [MetricaMAE], [MetricaRMSE], [Exactitud], [FechaEntrenamiento], [EsModeloActivo], [NotasModelo]
)
VALUES (
    'PredictorTiemposEntregaDocumental_XGBoost',
    'v2.1.0',
    'XGBoost_Regressor',
    'REGRESION',
    '{"n_estimators": 250, "learning_rate": 0.05, "max_depth": 6, "subsample": 0.8, "colsample_bytree": 0.8, "objective": "reg:squarederror"}',
    0.8845,
    0.7420,
    1.1250,
    0.9120,
    GETDATE(),
    1,
    'Modelo entrenado sobre 3,450 expedientes historicos del CORLAD Junin. Pondera revision exhaustiva vs tramites rapidos con validacion RENIEC.'
);
GO