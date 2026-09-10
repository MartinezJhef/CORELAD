Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' DTO con información de expedientes aprobados listos para formalización de matrícula regional (CU-COL-03).
    ''' </summary>
    Public Class ExpedienteAprobadoDTO
        Public Property ExpedienteColegiaturaID As Integer
        Public Property NumeroExpediente As String
        Public Property EntidadID As Integer
        Public Property DniPostulante As String
        Public Property NombreCompleto As String
        Public Property Universidad As String
        Public Property TituloProfesional As String
        Public Property CodigoRegistroSunedu As String
        Public Property FechaAprobacion As DateTime
        Public Property EstadoRevision As String
        Public Property ValidadoSunedu As Boolean
        Public Property FotoUrl As String
        Public Property Email As String
        Public Property Telefono As String
    End Class
End Namespace
