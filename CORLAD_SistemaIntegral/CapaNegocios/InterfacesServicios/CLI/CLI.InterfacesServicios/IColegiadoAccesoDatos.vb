Imports System
Imports System.Collections.Generic
Imports CLI.Entidades

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de persistencia y acceso a datos para el Padrón de Colegiados y Matrículas Regionales (CU-COL-03).
    ''' </summary>
    Public Interface IColegiadoAccesoDatos
        Function ListarExpedientesAprobados() As List(Of ExpedienteAprobadoDTO)
        Function ObtenerUltimoCorrelativoMatricula() As Integer
        Function ExisteMatriculaRegional(matriculaRegional As String) As Boolean
        Function ObtenerColegiadoPorId(colegiadoId As Integer) As ColegiadoBE
        Function ObtenerColegiadoPorExpedienteId(expedienteId As Integer) As ColegiadoBE
        Function RegistrarColegiado(colegiado As ColegiadoBE, expedienteId As Integer, numeroResolucion As String, fechaJuramentacion As Date, registradoPor As String) As Integer
        Function ObtenerDatosCarnet(colegiadoId As Integer) As CarnetColegiadoDTO
        Function ObtenerDatosCarnetPorExpediente(expedienteId As Integer) As CarnetColegiadoDTO
    End Interface
End Namespace
