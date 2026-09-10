Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' Entidad de Negocio que mapea la tabla [Colegiatura].[Colegiado].
    ''' Representa a un profesional formalmente incorporado al Colegio Regional de Licenciados en Administración.
    ''' </summary>
    Public Class ColegiadoBE
        Public Property ColegiadoID As Integer
        Public Property EntidadID As Integer
        Public Property MatriculaRegional As String
        Public Property MatriculaNacional As String
        Public Property FechaIncorporacion As Date
        Public Property CondicionColegiado As String = "ORDINARIO"
        Public Property EstadoHabilidadActual As String = "HABIL"
        Public Property CantidadCuotasPendientes As Short = 0
        Public Property UltimoPeriodoPagado As String
        Public Property ModifiedDate As DateTime = DateTime.Now
    End Class
End Namespace
