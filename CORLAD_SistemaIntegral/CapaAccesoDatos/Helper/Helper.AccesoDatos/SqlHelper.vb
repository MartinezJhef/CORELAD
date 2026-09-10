Imports System
Imports System.Data
Imports System.Data.Common

Namespace Helper.AccesoDatos
    Public Class SqlHelper
        Public Shared Property CadenaConexion As String = "Server=localhost;Database=CORLADJunin2026;Trusted_Connection=True;TrustServerCertificate=True;"

        Public Shared Function ObtenerEstadoConexion() As String
            Return "SqlHelper CORLAD JunÃ­n inicializado correctamente."
        End Function
    End Class
End Namespace
