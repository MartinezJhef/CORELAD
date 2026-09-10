Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports GEN.Infraestructura

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de servicio y flujo de trabajo para la Asignación de Matrícula Regional y Emisión de Carnet (CU-COL-03).
    ''' </summary>
    Public Interface IColegiadoServicio
        Function ObtenerExpedientesAprobados(rol As String) As ApiResponse(Of List(Of ExpedienteAprobadoDTO))
        Function ObtenerSiguienteMatriculaSugerida(rol As String) As ApiResponse(Of String)
        Function AsignarMatricula(request As AsignarMatriculaFormRequest, rol As String, usuarioOperador As String) As ApiResponse(Of CarnetColegiadoDTO)
        Function ObtenerCarnet(colegiadoId As Integer, rol As String) As ApiResponse(Of CarnetColegiadoDTO)
        Function ObtenerCarnetPorExpediente(expedienteId As Integer, rol As String) As ApiResponse(Of CarnetColegiadoDTO)
    End Interface
End Namespace
