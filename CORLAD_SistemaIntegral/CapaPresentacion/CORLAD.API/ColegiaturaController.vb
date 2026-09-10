Imports System
Imports CLI.Entidades
Imports CLI.FlujoTrabajo
Imports GEN.Infraestructura

Namespace CORLAD.API
    ''' <summary>
    ''' Controlador REST Web API para el Módulo de Colegiatura, Padrón y Habilitación (CLI).
    ''' Expone endpoints normalizados para consumo de la aplicación SPA en React.
    ''' </summary>
    Public Class ColegiaturaController
        Private ReadOnly _servicioColegiatura As ExpedienteColegiaturaFlujoTrabajo

        Public Sub New()
            _servicioColegiatura = New ExpedienteColegiaturaFlujoTrabajo()
        End Sub

        Public Sub New(servicio As ExpedienteColegiaturaFlujoTrabajo)
            _servicioColegiatura = servicio
        End Sub

        ''' <summary>
        ''' Endpoint: POST /api/cli/colegiatura/preinscripcion
        ''' Registra la pre-inscripción y expediente digital de colegiatura.
        ''' </summary>
        Public Function RegistrarPreinscripcion(solicitud As RegistrarPreinscripcionFormRequest) As ApiResponse(Of ExpedienteResponseDTO)
            If solicitud Is Nothing Then
                Return New ApiResponse(Of ExpedienteResponseDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "El cuerpo de la solicitud no puede estar vacío."
                }
            End If

            Return _servicioColegiatura.RegistrarPreinscripcion(solicitud)
        End Function

        ''' <summary>
        ''' Endpoint: GET /api/cli/colegiatura/seguimiento?numeroExpediente=COL-2026-00001&dni=12345678
        ''' Consulta el estado del expediente y trazabilidad en Mesa de Partes.
        ''' </summary>
        Public Function ConsultarSeguimiento(numeroExpediente As String, Optional dni As String = Nothing) As ApiResponse(Of ExpedienteResponseDTO)
            Return _servicioColegiatura.ConsultarEstadoExpediente(numeroExpediente, dni)
        End Function
    End Class
End Namespace
