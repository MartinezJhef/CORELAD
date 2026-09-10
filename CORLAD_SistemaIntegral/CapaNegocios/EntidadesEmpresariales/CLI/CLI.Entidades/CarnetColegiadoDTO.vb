Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' DTO que representa la credencial oficial (Carnet de Colegiado) del CORLAD Junín con firma digital y código QR.
    ''' </summary>
    Public Class CarnetColegiadoDTO
        Public Property ColegiadoID As Integer
        Public Property ExpedienteColegiaturaID As Integer
        Public Property MatriculaRegional As String
        Public Property MatriculaNacional As String
        Public Property Dni As String
        Public Property Nombres As String
        Public Property ApellidoPaterno As String
        Public Property ApellidoMaterno As String
        Public Property NombreCompleto As String
        Public Property TituloProfesional As String
        Public Property Universidad As String
        Public Property FechaIncorporacion As Date
        Public Property FechaEmision As Date
        Public Property FechaCaducidad As Date
        Public Property NumeroResolucion As String
        Public Property CondicionColegiado As String
        Public Property EstadoHabilidad As String
        Public Property FotoUrl As String
        Public Property CodigoQRUrl As String
        Public Property HashSeguridad As String
        Public Property DecanoRegional As String = "Lic. Adm. Decano Regional CORLAD Junín"
        Public Property SecretariaRegional As String = "Lic. Adm. Secretaria Regional CORLAD Junín"
    End Class
End Namespace
