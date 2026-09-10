Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports CLI.FlujoTrabajo
Imports GEN.Infraestructura

Namespace CORLAD.API
    ''' <summary>
    ''' Controlador REST Web API para la Calificación de Expedientes y Validación SUNEDU (CU-COL-02).
    ''' Expone endpoints normalizados para consumo de la aplicación SPA en React.
    ''' </summary>
    Public Class CalificacionColegiaturaController
        Private ReadOnly _servicio As ICalificacionColegiaturaServicio

        Public Sub New()
            _servicio = New CalificacionColegiaturaFlujoTrabajo()
        End Sub

        Public Sub New(servicio As ICalificacionColegiaturaServicio)
            _servicio = servicio
        End Sub

        ''' <summary>
        ''' Endpoint: GET /api/cli/calificacion/pendientes?rol=ROL-SEC
        ''' Obtiene la lista de expedientes pendientes de calificación técnica para la Secretaria Regional.
        ''' </summary>
        Public Function ObtenerPendientes(Optional rol As String = "ROL-SEC") As ApiResponse(Of List(Of ExpedientePendienteDTO))
            Return _servicio.ObtenerBandejaPendientes(rol)
        End Function

        ''' <summary>
        ''' Endpoint: GET /api/cli/calificacion/detalle/{expedienteId}?rol=ROL-SEC
        ''' Obtiene el legajo detallado de un expediente para auditoría documental.
        ''' </summary>
        Public Function ObtenerDetalle(expedienteId As Integer, Optional rol As String = "ROL-SEC") As ApiResponse(Of ExpedienteDetalleAuditoriaDTO)
            Return _servicio.ObtenerDetalleExpediente(expedienteId, rol)
        End Function

        ''' <summary>
        ''' Endpoint: POST /api/cli/calificacion/verificar-sunedu
        ''' Consulta el título profesional ante el Registro Nacional de Grados y Títulos de SUNEDU.
        ''' </summary>
        Public Function VerificarSunedu(request As ConsultarSuneduRequest) As ApiResponse(Of ValidacionSuneduResponseDTO)
            If request Is Nothing OrElse String.IsNullOrWhiteSpace(request.Dni) Then
                Return New ApiResponse(Of ValidacionSuneduResponseDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "Debe proporcionar el DNI del postulante para la consulta en SUNEDU."
                }
            End If

            Return _servicio.ValidarTituloEnSunedu(request.Dni, request.CodigoRegistroSunedu)
        End Function

        ''' <summary>
        ''' Endpoint: POST /api/cli/calificacion/dictaminar
        ''' Procesa el dictamen de calificación técnica (APROBADO, OBSERVADO o RECHAZADO).
        ''' </summary>
        Public Function DictaminarExpediente(request As CalificarExpedienteFormRequest, Optional rol As String = "ROL-SEC", Optional usuarioAuditor As String = "SECRETARIA_REGIONAL") As ApiResponse(Of Boolean)
            If request Is Nothing Then
                Return New ApiResponse(Of Boolean) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "La solicitud de calificación no puede ser nula."
                }
            End If

            Return _servicio.ProcesarDictamen(request, rol, usuarioAuditor)
        End Function
    End Class
End Namespace
