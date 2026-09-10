Imports System
Imports System.Security.Cryptography
Imports System.Text

Namespace GEN.Infraestructura
    Public Class CryptoHelper
        Public Shared Function CalcularSHA256(texto As String) As String
            If String.IsNullOrEmpty(texto) Then Return String.Empty
            Using sha256 As SHA256 = SHA256.Create()
                Dim bytes As Byte() = Encoding.UTF8.GetBytes(texto)
                Dim hash As Byte() = sha256.ComputeHash(bytes)
                Dim sb As New StringBuilder()
                For Each b As Byte In hash
                    sb.Append(b.ToString("x2"))
                Next
                Return sb.ToString()
            End Using
        End Function
    End Class

    Public Class ApiResponse(Of T)
        Public Property Exito As Boolean
        Public Property Mensaje As String
        Public Property Datos As T
        Public Property CodigoEstado As Integer

        Public Sub New()
            Exito = True
            CodigoEstado = 200
        End Sub
    End Class
End Namespace
