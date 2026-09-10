Imports Xunit
Imports CLI.Entidades
Imports GEN.Infraestructura

Public Class PreinscripcionUnitTests

    ''' <summary>
    ''' Dimensión 7: Pruebas de Validación - DNI con longitud diferente a 8 dígitos numéricos
    ''' </summary>
    <Fact>
    Public Sub Validar_DniInvalido_RetornaErrorValidacion()
        ' Arrange
        Dim request As New RegistrarPreinscripcionFormRequest With {
            .Dni = "12345", ' Solo 5 dígitos
            .Nombres = "Jheferson David",
            .ApellidoPaterno = "Martinez",
            .ApellidoMaterno = "Castro",
            .CorreoElectronico = "postulante@corladjunin.org.pe",
            .Telefono = "987654321",
            .DireccionDetalle = "Av. Giraldez 230",
            .UniversidadOrigen = "UNCP",
            .FechaExpedicionTitulo = New Date(2024, 2, 15),
            .CodigoRegistroSunedu = "SUN-2024-1122",
            .DeclaracionJuradaAceptada = True
        }

        ' Act
        Dim resultado = request.Validar()

        ' Assert
        Assert.False(resultado.EsValido)
        Assert.Contains(resultado.Errores, Function(e) e.Campo = "Dni")
    End Sub

    ''' <summary>
    ''' Dimensión 7: Pruebas de Validación - Correo electrónico con formato inválido
    ''' </summary>
    <Fact>
    Public Sub Validar_CorreoInvalido_RetornaErrorValidacion()
        ' Arrange
        Dim request As New RegistrarPreinscripcionFormRequest With {
            .Dni = "72345678",
            .Nombres = "Jheferson David",
            .ApellidoPaterno = "Martinez",
            .ApellidoMaterno = "Castro",
            .CorreoElectronico = "correo_sin_arroba_ni_dominio",
            .Telefono = "987654321",
            .DireccionDetalle = "Av. Ferrocarril 1024",
            .UniversidadOrigen = "UNCP",
            .FechaExpedicionTitulo = New Date(2024, 2, 15),
            .CodigoRegistroSunedu = "SUN-2024-1122",
            .DeclaracionJuradaAceptada = True
        }

        ' Act
        Dim resultado = request.Validar()

        ' Assert
        Assert.False(resultado.EsValido)
        Assert.Contains(resultado.Errores, Function(e) e.Campo = "CorreoElectronico")
    End Sub

    ''' <summary>
    ''' Dimensión 3: Pruebas Funcionales - Lista incompleta de requisitos obligatorios
    ''' </summary>
    <Fact>
    Public Sub Validar_FaltaDocumentoObligatorio_RetornaErrorValidacion()
        ' Arrange (Solo 2 de 5 requisitos)
        Dim request As New RegistrarPreinscripcionFormRequest With {
            .Dni = "72345678",
            .Nombres = "Jheferson David",
            .ApellidoPaterno = "Martinez",
            .ApellidoMaterno = "Castro",
            .CorreoElectronico = "postulante@corladjunin.org.pe",
            .Telefono = "987654321",
            .DireccionDetalle = "Av. Ferrocarril 1024",
            .UniversidadOrigen = "UNCP",
            .FechaExpedicionTitulo = New Date(2024, 2, 15),
            .CodigoRegistroSunedu = "SUN-2024-1122",
            .DeclaracionJuradaAceptada = True,
            .ArchivosAdjuntos = New List(Of DocumentoExpedienteBE) From {
                New DocumentoExpedienteBE With {
                    .TipoDocumentoRequisito = "DNI",
                    .NombreArchivo = "DNI.pdf",
                    .Extension = ".pdf",
                    .TamanoBytes = 1024,
                    .ContenidoBase64 = "JVBERi0xLjQK..."
                },
                New DocumentoExpedienteBE With {
                    .TipoDocumentoRequisito = "TITULO",
                    .NombreArchivo = "Titulo.pdf",
                    .Extension = ".pdf",
                    .TamanoBytes = 2048,
                    .ContenidoBase64 = "JVBERi0xLjQK..."
                }
            }
        }

        ' Act
        Dim resultado = request.Validar()

        ' Assert
        Assert.False(resultado.EsValido)
        Assert.Contains(resultado.Errores, Function(e) e.Campo = "ArchivosAdjuntos")
    End Sub

    ''' <summary>
    ''' Dimensión 8: Pruebas de Seguridad - Formato peligroso o no permitido (.exe)
    ''' </summary>
    <Fact>
    Public Sub Validar_ExtensionPeligrosa_RetornaErrorValidacion()
        ' Arrange
        Dim request As New RegistrarPreinscripcionFormRequest With {
            .Dni = "72345678",
            .Nombres = "Jheferson David",
            .ApellidoPaterno = "Martinez",
            .ApellidoMaterno = "Castro",
            .CorreoElectronico = "postulante@corladjunin.org.pe",
            .Telefono = "987654321",
            .DireccionDetalle = "Av. Ferrocarril 1024",
            .UniversidadOrigen = "UNCP",
            .FechaExpedicionTitulo = New Date(2024, 2, 15),
            .CodigoRegistroSunedu = "SUN-2024-1122",
            .DeclaracionJuradaAceptada = True,
            .ArchivosAdjuntos = New List(Of DocumentoExpedienteBE) From {
                New DocumentoExpedienteBE With {
                    .TipoDocumentoRequisito = "DNI",
                    .NombreArchivo = "script_peligroso.exe",
                    .Extension = ".exe",
                    .TamanoBytes = 1024,
                    .ContenidoBase64 = "TVqQAAMAAAAE..."
                }
            }
        }

        ' Act
        Dim resultado = request.Validar()

        ' Assert
        Assert.False(resultado.EsValido)
        Assert.Contains(resultado.Errores, Function(e) e.Campo = "ArchivosAdjuntos" AndAlso e.Mensaje.Contains("no permitido"))
    End Sub

    ''' <summary>
    ''' Dimensión 1: Pruebas Unitarias - Cálculo de Hash criptográfico SHA-256 (64 caracteres hexadecimales)
    ''' </summary>
    <Fact>
    Public Sub CryptoHelper_CalcularSHA256_RetornaHash64CaracteresExactos()
        ' Arrange
        Dim textoPrueba = "DOCUMENTO_OFICIAL_CORLAD_JUNIN_2026"

        ' Act
        Dim hashCalculado = CryptoHelper.CalcularSHA256(textoPrueba)

        ' Assert
        Assert.NotNull(hashCalculado)
        Assert.Equal(64, hashCalculado.Length)
        Assert.Matches("^[0-9a-f]{64}$", hashCalculado)
    End Sub

    ''' <summary>
    ''' Dimensión 12: Pruebas de API REST - ApiResponse(Of T) respeta el esquema normativo
    ''' </summary>
    <Fact>
    Public Sub ApiResponse_CrearExitoso_MantieneContratoOficial()
        ' Arrange & Act
        Dim respuesta As New ApiResponse(Of String) With {
            .Exito = True,
            .CodigoEstado = 201,
            .Datos = "COL-2026-00001",
            .Mensaje = "Expediente generado exitosamente"
        }

        ' Assert
        Assert.True(respuesta.Exito)
        Assert.Equal(201, respuesta.CodigoEstado)
        Assert.Equal("COL-2026-00001", respuesta.Datos)
        Assert.Equal("Expediente generado exitosamente", respuesta.Mensaje)
    End Sub

    ''' <summary>
    ''' Dimensión 4: Pruebas de Aceptación BDD - Expediente con todos los datos válidos pasa sin errores
    ''' </summary>
    <Fact>
    Public Sub Validar_ExpedienteCompletoYValido_PasaSatisfactoriamente()
        ' Arrange
        Dim request As New RegistrarPreinscripcionFormRequest With {
            .Dni = "72345678",
            .Nombres = "Jheferson David",
            .ApellidoPaterno = "Martinez",
            .ApellidoMaterno = "Castro",
            .CorreoElectronico = "postulante@corladjunin.org.pe",
            .Telefono = "987654321",
            .DireccionDetalle = "Av. Ferrocarril 1024, El Tambo",
            .UniversidadOrigen = "UNCP",
            .FechaExpedicionTitulo = New Date(2024, 2, 15),
            .CodigoRegistroSunedu = "SUN-2024-1122",
            .DeclaracionJuradaAceptada = True,
            .ArchivosAdjuntos = New List(Of DocumentoExpedienteBE) From {
                New DocumentoExpedienteBE With {.TipoDocumentoRequisito = "DNI", .NombreArchivo = "DNI.pdf", .Extension = ".pdf", .TamanoBytes = 102400, .ContenidoBase64 = "AAA="},
                New DocumentoExpedienteBE With {.TipoDocumentoRequisito = "TITULO", .NombreArchivo = "Titulo.pdf", .Extension = ".pdf", .TamanoBytes = 204800, .ContenidoBase64 = "BBB="},
                New DocumentoExpedienteBE With {.TipoDocumentoRequisito = "ANTECEDENTES", .NombreArchivo = "Antecedentes.pdf", .Extension = ".pdf", .TamanoBytes = 153600, .ContenidoBase64 = "CCC="},
                New DocumentoExpedienteBE With {.TipoDocumentoRequisito = "FOTO", .NombreArchivo = "Foto.jpg", .Extension = ".jpg", .TamanoBytes = 51200, .ContenidoBase64 = "DDD="},
                New DocumentoExpedienteBE With {.TipoDocumentoRequisito = "VOUCHER", .NombreArchivo = "Voucher.pdf", .Extension = ".pdf", .TamanoBytes = 81920, .ContenidoBase64 = "EEE="}
            }
        }

        ' Act
        Dim resultado = request.Validar()

        ' Assert
        Assert.True(resultado.EsValido)
        Assert.Empty(resultado.Errores)
    End Sub

End Class
