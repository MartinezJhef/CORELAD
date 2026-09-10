Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' DTO optimizado para la bandeja de expedientes pendientes de calificación técnica.
    ''' </summary>
    Public Class ExpedientePendienteDTO
        Public Property ExpedienteId As Integer
        Public Property NumeroExpediente As String
        Public Property DniPostulante As String
        Public Property NombrePostulante As String
        Public Property Universidad As String
        Public Property TituloProfesional As String
        Public Property CodigoRegistroSunedu As String
        Public Property FechaPresentacion As Date
        Public Property EstadoRevision As String
        Public Property ValidadoSunedu As Boolean
        Public Property TotalDocumentos As Integer
    End Class

    ''' <summary>
    ''' DTO de detalle con requisitos adjuntos para auditoría visual de la Secretaria Regional.
    ''' </summary>
    Public Class ExpedienteDetalleAuditoriaDTO
        Public Property ExpedienteId As Integer
        Public Property NumeroExpediente As String
        Public Property DniPostulante As String
        Public Property NombrePostulante As String
        Public Property CorreoElectronico As String
        Public Property Telefono As String
        Public Property Direccion As String
        Public Property Universidad As String
        Public Property DenominacionTitulo As String
        Public Property NumeroResolucionTitulo As String
        Public Property FechaExpedicionTitulo As Date
        Public Property CodigoRegistroSunedu As String
        Public Property FechaPresentacion As Date
        Public Property EstadoRevision As String
        Public Property ValidadoSunedu As Boolean
        Public Property Documentos As New List(Of DocumentoExpedienteBE)()
    End Class
End Namespace
