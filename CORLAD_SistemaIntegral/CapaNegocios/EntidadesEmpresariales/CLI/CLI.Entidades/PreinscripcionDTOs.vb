Imports System
Imports System.Collections.Generic

Namespace CLI.Entidades
    ''' <summary>
    ''' DTO de respuesta para el trámite de preinscripción de colegiatura consumido por el frontend en React.
    ''' </summary>
    Public Class ExpedienteResponseDTO
        Public Property ExpedienteID As Integer
        Public Property NumeroExpediente As String
        Public Property PostulanteDni As String
        Public Property PostulanteNombreCompleto As String
        Public Property FechaPresentacion As String
        Public Property EstadoRevision As String
        Public Property CodigoSeguimiento As String
        Public Property DocumentosRegistrados As Integer
        Public Property MensajeRespuesta As String
        Public Property DocumentosAdjuntos As New List(Of DocumentoAdjuntoDTO)
    End Class

    Public Class DocumentoAdjuntoDTO
        Public Property TipoDocumento As String
        Public Property NombreArchivo As String
        Public Property TamanoBytes As Long
        Public Property HashSHA256 As String
    End Class
End Namespace
