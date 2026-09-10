Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' Entidad Empresarial que representa un archivo probatorio adjunto al expediente de colegiatura.
    ''' Mapea a la tabla [Tramite].[DocumentoAdjunto].
    ''' </summary>
    Public Class DocumentoExpedienteBE
        Public Property DocumentoAdjuntoID As Long
        Public Property ExpedienteID As Integer
        Public Property TipoDocumentoRequisito As String ' DNI, TITULO, ANTECEDENTES, FOTO, VOUCHER
        Public Property NombreArchivo As String ' nvarchar(200)
        Public Property Extension As String ' nvarchar(10)
        Public Property RutaAlmacenamiento As String ' nvarchar(400)
        Public Property HashSHA256 As String ' char(64)
        Public Property TamanoBytes As Long
        Public Property TipoMime As String = "application/pdf"
        Public Property ContenidoBase64 As String
        Public Property FechaCarga As DateTime = DateTime.Now
    End Class
End Namespace
