Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports CLI.FlujoTrabajo
Imports CLI.InterfacesServicios
Imports GEN.Infraestructura

Namespace CORLAD.API
    ''' <summary>
    ''' Controlador REST Web API para la Asignación de Matrícula Regional y Emisión de Carnet (CU-COL-03).
    ''' Expone endpoints normalizados para consumo de la aplicación SPA en React.
    ''' </summary>
    Public Class MatriculaColegiaturaController
        Private ReadOnly _servicio As IColegiadoServicio

        Public Sub New()
            _servicio = New ColegiadoFlujoTrabajo()
        End Sub

        Public Sub New(servicio As IColegiadoServicio)
            _servicio = servicio
        End Sub

        ''' <summary>
        ''' Endpoint: GET /api/cli/matricula/aprobados?rol=ROL-DEC
        ''' Obtiene la lista de expedientes aprobados pendientes de formalización de matrícula regional.
        ''' </summary>
        Public Function ObtenerExpedientesAprobados(Optional rol As String = "ROL-DEC") As ApiResponse(Of List(Of ExpedienteAprobadoDTO))
            Return _servicio.ObtenerExpedientesAprobados(rol)
        End Function

        ''' <summary>
        ''' Endpoint: GET /api/cli/matricula/siguiente-correlativo?rol=ROL-DEC
        ''' Obtiene el siguiente número correlativo sugerido de Matrícula Regional en formato oficial.
        ''' </summary>
        Public Function ObtenerSiguienteCorrelativo(Optional rol As String = "ROL-DEC") As ApiResponse(Of String)
            Return _servicio.ObtenerSiguienteMatriculaSugerida(rol)
        End Function

        ''' <summary>
        ''' Endpoint: POST /api/cli/matricula/asignar
        ''' Formaliza el alta en el padrón, asigna la matrícula regional y emite el carnet digital.
        ''' </summary>
        Public Function AsignarMatricula(request As AsignarMatriculaFormRequest, Optional rol As String = "ROL-DEC", Optional usuarioOperador As String = "DECANO_REGIONAL") As ApiResponse(Of CarnetColegiadoDTO)
            If request Is Nothing Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "El cuerpo de la solicitud no puede estar vacío."
                }
            End If

            Return _servicio.AsignarMatricula(request, rol, usuarioOperador)
        End Function

        ''' <summary>
        ''' Endpoint: GET /api/cli/matricula/carnet/{colegiadoId}?rol=ROL-DEC
        ''' Obtiene la credencial oficial (Carnet de Colegiado) por identificador de colegiado.
        ''' </summary>
        Public Function ObtenerCarnetPorId(colegiadoId As Integer, Optional rol As String = "ROL-DEC") As ApiResponse(Of CarnetColegiadoDTO)
            Return _servicio.ObtenerCarnet(colegiadoId, rol)
        End Function

        ''' <summary>
        ''' Endpoint: GET /api/cli/matricula/carnet/expediente/{expedienteId}?rol=ROL-DEC
        ''' Obtiene el carnet oficial generado para un expediente específico.
        ''' </summary>
        Public Function ObtenerCarnetPorExpediente(expedienteId As Integer, Optional rol As String = "ROL-DEC") As ApiResponse(Of CarnetColegiadoDTO)
            Return _servicio.ObtenerCarnetPorExpediente(expedienteId, rol)
        End Function
    End Class
End Namespace
