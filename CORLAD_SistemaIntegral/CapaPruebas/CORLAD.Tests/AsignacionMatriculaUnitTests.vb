Imports System
Imports System.Collections.Generic
Imports Xunit
Imports CLI.Entidades
Imports CLI.FlujoTrabajo
Imports CLI.InterfacesServicios
Imports GEN.Infraestructura

Namespace CORLAD.Tests
    Public Class AsignacionMatriculaUnitTests

        ''' <summary>
        ''' Dimensión 8: Seguridad - FormRequest Authorize() deniega acceso a usuarios no autorizados (ej: ROL-POSTULANTE, ROL-AGR).
        ''' </summary>
        <Fact>
        Public Sub Authorize_RolNoAutorizado_RetornaAccesoDenegado()
            Dim request As New AsignarMatriculaFormRequest()
            Dim autorizado = request.Authorize("ROL-POSTULANTE")
            Assert.False(autorizado)
        End Sub

        ''' <summary>
        ''' Dimensión 8: Seguridad - FormRequest Authorize() autoriza a Decano y Secretaria Regional.
        ''' </summary>
        <Theory>
        <InlineData("ROL-DEC")>
        <InlineData("ROL-SEC")>
        <InlineData("ADMIN")>
        Public Sub Authorize_RolesDirectivos_RetornaAccesoPermitido(rol As String)
            Dim request As New AsignarMatriculaFormRequest()
            Dim autorizado = request.Authorize(rol)
            Assert.True(autorizado)
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - ExpedienteId menor o igual a cero genera error.
        ''' </summary>
        <Fact>
        Public Sub Validar_ExpedienteIdInvalido_RetornaErrorValidacion()
            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 0,
                .MatriculaRegional = "CORLAD-JUN-00128",
                .NumeroResolucionIncorporacion = "RES-DEC-045-2026-CORLAD-JUN"
            }

            Dim res = request.Validar()
            Assert.False(res.EsValido)
            Assert.Contains(res.Errores, Function(e) e.Campo = "ExpedienteColegiaturaID")
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - Matrícula regional vacía genera error.
        ''' </summary>
        <Fact>
        Public Sub Validar_MatriculaVacia_RetornaErrorValidacion()
            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 10,
                .MatriculaRegional = "   ",
                .NumeroResolucionIncorporacion = "RES-DEC-045-2026-CORLAD-JUN"
            }

            Dim res = request.Validar()
            Assert.False(res.EsValido)
            Assert.Contains(res.Errores, Function(e) e.Campo = "MatriculaRegional")
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - Resolución Decanal vacía genera error mandatorio.
        ''' </summary>
        <Fact>
        Public Sub Validar_ResolucionVacia_RetornaErrorValidacion()
            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 10,
                .MatriculaRegional = "CORLAD-JUN-00128",
                .NumeroResolucionIncorporacion = ""
            }

            Dim res = request.Validar()
            Assert.False(res.EsValido)
            Assert.Contains(res.Errores, Function(e) e.Campo = "NumeroResolucionIncorporacion")
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - FormRequest con todos los campos correctos es válido.
        ''' </summary>
        <Fact>
        Public Sub Validar_DatosCompletos_RetornaEsValidoTrue()
            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 10,
                .MatriculaRegional = "CORLAD-JUN-00128",
                .MatriculaNacional = "CLAD-24150",
                .NumeroResolucionIncorporacion = "RES-DEC-045-2026-CORLAD-JUN",
                .FechaJuramentacion = DateTime.Today,
                .CondicionColegiado = "ORDINARIO"
            }

            Dim res = request.Validar()
            Assert.True(res.EsValido)
            Assert.Empty(res.Errores)
        End Sub

        ''' <summary>
        ''' Dimensión 3: Funcional - Servicio retorna 403 si un rol no autorizado intenta obtener el siguiente correlativo.
        ''' </summary>
        <Fact>
        Public Sub ObtenerSiguienteMatricula_RolNoAutorizado_Retorna403()
            Dim servicio As New ColegiadoFlujoTrabajo()
            Dim respuesta = servicio.ObtenerSiguienteMatriculaSugerida("ROL-POSTULANTE")

            Assert.False(respuesta.Exito)
            Assert.Equal(403, respuesta.CodigoEstado)
        End Sub

        ''' <summary>
        ''' Dimensión 3: Funcional - Servicio calcula correlativo con formato oficial CORLAD-JUN-XXXXX.
        ''' </summary>
        <Fact>
        Public Sub ObtenerSiguienteMatricula_RolDecano_RetornaFormatoOficial()
            Dim servicio As New ColegiadoFlujoTrabajo()
            Dim respuesta = servicio.ObtenerSiguienteMatriculaSugerida("ROL-DEC")

            Assert.True(respuesta.Exito)
            Assert.Equal(200, respuesta.CodigoEstado)
            Assert.StartsWith("CORLAD-JUN-", respuesta.Datos)
        End Sub

        ''' <summary>
        ''' Dimensión 3 & 13: Reglas de Negocio - Intento de asignar matrícula existente retorna conflicto 409.
        ''' </summary>
        <Fact>
        Public Sub AsignarMatricula_MatriculaDuplicada_Retorna409()
            ' Mock de acceso a datos con matrícula existente
            Dim mockAcceso As New MockColegiadoAccesoDatos()
            mockAcceso.MatriculaDuplicadaConfigurada = "CORLAD-JUN-00125"

            Dim servicio As New ColegiadoFlujoTrabajo(mockAcceso)
            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 10,
                .MatriculaRegional = "CORLAD-JUN-00125",
                .NumeroResolucionIncorporacion = "RES-DEC-045-2026-CORLAD-JUN"
            }

            Dim respuesta = servicio.AsignarMatricula(request, "ROL-DEC", "DECANO_REGIONAL")

            Assert.False(respuesta.Exito)
            Assert.Equal(409, respuesta.CodigoEstado)
        End Sub

        ''' <summary>
        ''' Dimensión 3, 4 & 8: Camino Feliz - Formalización exitosa genera Carnet con Hash SHA-256 y URL QR.
        ''' </summary>
        <Fact>
        Public Sub AsignarMatricula_CaminoFeliz_Retorna201YGeneraCarnetConQrYHash()
            Dim mockAcceso As New MockColegiadoAccesoDatos()
            Dim servicio As New ColegiadoFlujoTrabajo(mockAcceso)

            Dim request As New AsignarMatriculaFormRequest With {
                .ExpedienteColegiaturaID = 10,
                .MatriculaRegional = "CORLAD-JUN-00128",
                .MatriculaNacional = "CLAD-24150",
                .NumeroResolucionIncorporacion = "RES-DEC-045-2026-CORLAD-JUN",
                .FechaJuramentacion = DateTime.Today,
                .CondicionColegiado = "ORDINARIO"
            }

            Dim respuesta = servicio.AsignarMatricula(request, "ROL-DEC", "DECANO_REGIONAL")

            Assert.True(respuesta.Exito)
            Assert.Equal(201, respuesta.CodigoEstado)
            Assert.NotNull(respuesta.Datos)
            Assert.Equal("CORLAD-JUN-00128", respuesta.Datos.MatriculaRegional)
            Assert.False(String.IsNullOrEmpty(respuesta.Datos.HashSeguridad))
            Assert.Equal(64, respuesta.Datos.HashSeguridad.Length)
            Assert.Contains("https://validador.corladjunin.org.pe", respuesta.Datos.CodigoQRUrl)
        End Sub

        ''' <summary>
        ''' Mock de acceso a datos para pruebas unitarias aisladas.
        ''' </summary>
        Private Class MockColegiadoAccesoDatos
            Implements IColegiadoAccesoDatos

            Public Property MatriculaDuplicadaConfigurada As String = ""

            Public Function ListarExpedientesAprobados() As List(Of ExpedienteAprobadoDTO) Implements IColegiadoAccesoDatos.ListarExpedientesAprobados
                Return New List(Of ExpedienteAprobadoDTO)()
            End Function

            Public Function ObtenerUltimoCorrelativoMatricula() As Integer Implements IColegiadoAccesoDatos.ObtenerUltimoCorrelativoMatricula
                Return 127
            End Function

            Public Function ExisteMatriculaRegional(matriculaRegional As String) As Boolean Implements IColegiadoAccesoDatos.ExisteMatriculaRegional
                Return Not String.IsNullOrEmpty(MatriculaDuplicadaConfigurada) AndAlso matriculaRegional.Equals(MatriculaDuplicadaConfigurada, StringComparison.OrdinalIgnoreCase)
            End Function

            Public Function ObtenerColegiadoPorId(colegiadoId As Integer) As ColegiadoBE Implements IColegiadoAccesoDatos.ObtenerColegiadoPorId
                Return New ColegiadoBE With {.ColegiadoID = colegiadoId, .MatriculaRegional = "CORLAD-JUN-00128"}
            End Function

            Public Function ObtenerColegiadoPorExpedienteId(expedienteId As Integer) As ColegiadoBE Implements IColegiadoAccesoDatos.ObtenerColegiadoPorExpedienteId
                Return New ColegiadoBE With {.ColegiadoID = 128, .MatriculaRegional = "CORLAD-JUN-00128"}
            End Function

            Public Function RegistrarColegiado(colegiado As ColegiadoBE, expedienteId As Integer, numeroResolucion As String, fechaJuramentacion As Date, registradoPor As String) As Integer Implements IColegiadoAccesoDatos.RegistrarColegiado
                Return 128
            End Function

            Public Function ObtenerDatosCarnet(colegiadoId As Integer) As CarnetColegiadoDTO Implements IColegiadoAccesoDatos.ObtenerDatosCarnet
                Return New CarnetColegiadoDTO With {
                    .ColegiadoID = colegiadoId,
                    .ExpedienteColegiaturaID = 10,
                    .MatriculaRegional = "CORLAD-JUN-00128",
                    .MatriculaNacional = "CLAD-24150",
                    .Dni = "45892134",
                    .NombreCompleto = "ROJAS CONDOR, JUAN CARLOS",
                    .NumeroResolucion = "RES-DEC-045-2026-CORLAD-JUN",
                    .FechaIncorporacion = DateTime.Today,
                    .CondicionColegiado = "ORDINARIO",
                    .EstadoHabilidad = "HABIL"
                }
            End Function

            Public Function ObtenerDatosCarnetPorExpediente(expedienteId As Integer) As CarnetColegiadoDTO Implements IColegiadoAccesoDatos.ObtenerDatosCarnetPorExpediente
                Return ObtenerDatosCarnet(128)
            End Function
        End Class

    End Class
End Namespace
