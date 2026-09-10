Imports System
Imports System.Collections.Generic

Namespace CLI.Entidades
    ''' <summary>
    ''' Entidad Empresarial que representa el expediente administrativo de colegiatura del postulante.
    ''' Mapea a la tabla [Colegiatura].[ExpedienteColegiatura].
    ''' </summary>
    Public Class ExpedienteColegiaturaBE
        Public Property ExpedienteColegiaturaID As Integer
        Public Property EntidadID As Integer
        Public Property NumeroExpediente As String ' char(14), formato: COL-YYYY-XXXXX
        Public Property FechaPresentacion As DateTime = DateTime.Now
        Public Property EstadoRevision As String = "EN_REVISION" ' EN_REVISION, OBSERVADO, APROBADO, RECHAZADO
        Public Property ValidadoSunedu As Boolean = False
        Public Property ValidadoReniec As Boolean = False
        Public Property AprobadoConsejo As Boolean = False
        Public Property NumeroResolucionIncorporacion As String
        Public Property FechaJuramentacion As Date?
        Public Property Observaciones As String
        Public Property ModifiedDate As DateTime = DateTime.Now

        ' Propiedades de navegación / composición
        Public Property Postulante As PostulanteBE
        Public Property Titulo As TituloProfesionalBE
        Public Property DocumentosAdjuntos As New List(Of DocumentoExpedienteBE)
    End Class
End Namespace
