Imports System
Imports Xunit
Imports CLI.Entidades
Imports CLI.FlujoTrabajo
Imports CLI.InterfacesServicios
Imports GEN.Infraestructura

Namespace CORLAD.Tests
    Public Class CalificacionExpedienteUnitTests

        ''' <summary>
        ''' Dimensión 8: Seguridad - FormRequest Authorize() restringe acceso a usuarios no autorizados
        ''' </summary>
        <Fact>
        Public Sub Authorize_RolPostulante_RetornaAccesoDenegado()
            Dim request As New CalificarExpedienteFormRequest()
            Dim autorizado = request.Authorize("ROL-POSTULANTE")
            Assert.False(autorizado)
        End Sub

        ''' <summary>
        ''' Dimensión 8: Seguridad - FormRequest Authorize() permite acceso a roles con privilegio evaluador
        ''' </summary>
        <Theory>
        <InlineData("ROL-SEC")>
        <InlineData("ROL-GER")>
        <InlineData("ROL-DEC")>
        <InlineData("ADMIN")>
        Public Sub Authorize_RolesAutorizados_RetornaAccesoPermitido(rol As String)
            Dim request As New CalificarExpedienteFormRequest()
            Dim autorizado = request.Authorize(rol)
            Assert.True(autorizado)
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - ExpedienteId inválido genera error de validación
        ''' </summary>
        <Fact>
        Public Sub Validar_ExpedienteIdInvalido_RetornaErrorValidacion()
            Dim request As New CalificarExpedienteFormRequest With {
                .ExpedienteId = 0,
                .Dictamen = "APROBADO",
                .ValidadoSunedu = True,
                .CodigoRegistroSunedu = "SUN-2024-001"
            }

            Dim resultado = request.Validar()

            Assert.False(resultado.EsValido)
            Assert.Contains(resultado.Errores, Function(e) e.Campo = "ExpedienteId")
        End Sub

        ''' <summary>
        ''' Dimensión 7: Validación - Dictamen no permitido genera error de validación
        ''' </summary>
        <Fact>
        Public Sub Validar_DictamenInvalido_RetornaErrorValidacion()
            Dim request As New CalificarExpedienteFormRequest With {
                .ExpedienteId = 15,
                .Dictamen = "DENEGADO_SIN_DICTAMEN",
                .ValidadoSunedu = True
            }

            Dim resultado = request.Validar()

            Assert.False(resultado.EsValido)
            Assert.Contains(resultado.Errores, Function(e) e.Campo = "Dictamen")
        End Sub

        ''' <summary>
        ''' Dimensión 4: Regla de Negocio RN-COL-02 - Expediente OBSERVADO requiere motivo u observación obligatoria
        ''' </summary>
        <Fact>
        Public Sub Validar_ObservadoSinMotivo_RetornaErrorReglaNegocio()
            Dim request As New CalificarExpedienteFormRequest With {
                .ExpedienteId = 15,
                .Dictamen = "OBSERVADO",
                .MotivoObservacion = "" ' Vacío intencionalmente
            }

            Dim resultado = request.Validar()

            Assert.False(resultado.EsValido)
            Assert.Contains(resultado.Errores, Function(e) e.Campo = "MotivoObservacion")
        End Sub

        ''' <summary>
        ''' Dimensión 4: Regla de Negocio RN-COL-02 - Expediente APROBADO requiere validación previa de SUNEDU
        ''' </summary>
        <Fact>
        Public Sub Validar_AprobadoSinSunedu_RetornaErrorReglaNegocio()
            Dim request As New CalificarExpedienteFormRequest With {
                .ExpedienteId = 15,
                .Dictamen = "APROBADO",
                .ValidadoSunedu = False ' No validado
            }

            Dim resultado = request.Validar()

            Assert.False(resultado.EsValido)
            Assert.Contains(resultado.Errores, Function(e) e.Campo = "ValidadoSunedu")
        End Sub

        ''' <summary>
        ''' Dimensión 4: Regla de Negocio RN-COL-02 - Expediente APROBADO con SUNEDU validado y código es exitoso
        ''' </summary>
        <Fact>
        Public Sub Validar_AprobadoConSuneduValido_RetornaExito()
            Dim request As New CalificarExpedienteFormRequest With {
                .ExpedienteId = 15,
                .Dictamen = "APROBADO",
                .ValidadoSunedu = True,
                .CodigoRegistroSunedu = "SUN-2024-9988"
            }

            Dim resultado = request.Validar()

            Assert.True(resultado.EsValido)
            Assert.Empty(resultado.Errores)
        End Sub

        ''' <summary>
        ''' Dimensión 8: Seguridad - Flujo de Trabajo bloquea llamadas con rol no autorizado con HTTP 403
        ''' </summary>
        <Fact>
        Public Sub FlujoTrabajo_RolNoAutorizado_Retorna403Forbidden()
            Dim servicio As New CalificacionColegiaturaFlujoTrabajo()
            Dim respuesta = servicio.ObtenerBandejaPendientes("ROL-EXTERNO")

            Assert.False(respuesta.Exito)
            Assert.Equal(403, respuesta.CodigoEstado)
        End Sub

        ''' <summary>
        ''' Dimensión 3: Funcional - Servicio de validación SUNEDU retorna registro válido para postulante con título
        ''' </summary>
        <Fact>
        Public Sub ValidarTituloEnSunedu_DniValido_RetornaRegistroExitoso()
            Dim servicio As New CalificacionColegiaturaFlujoTrabajo()
            Dim respuesta = servicio.ValidarTituloEnSunedu("72345678", "SUN-2024-UNCP-001")

            Assert.True(respuesta.Exito)
            Assert.NotNull(respuesta.Datos)
            Assert.True(respuesta.Datos.EsValido)
            Assert.Equal("LICENCIADO EN ADMINISTRACION", respuesta.Datos.GradoTitulo)
        End Sub
    End Class
End Namespace
