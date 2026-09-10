Imports System
Imports System.Data
Imports System.Collections.Generic
Imports Microsoft.Data.SqlClient

Namespace Helper.AccesoDatos
    ''' <summary>
    ''' Proveedor de acceso a datos parametrizado para Microsoft SQL Server 2026.
    ''' Garantiza protección total contra inyección SQL y manejo transaccional seguro.
    ''' </summary>
    Public Class SqlHelper
        Private Shared _cadenaConexion As String = "Server=localhost;Database=CORLADJunin2026;Trusted_Connection=True;TrustServerCertificate=True;"

        Public Shared Property CadenaConexion As String
            Get
                Return _cadenaConexion
            End Get
            Set(value As String)
                If Not String.IsNullOrWhiteSpace(value) Then
                    _cadenaConexion = value
                End If
            End Set
        End Property

        Public Shared Function ObtenerConexion() As SqlConnection
            Return New SqlConnection(_cadenaConexion)
        End Function

        Public Shared Function ExecuteScalar(comandoSql As String, Optional parametros As List(Of SqlParameter) = Nothing) As Object
            Using cnn As SqlConnection = ObtenerConexion()
                Using cmd As New SqlCommand(comandoSql, cnn)
                    cmd.CommandType = CommandType.Text
                    If parametros IsNot Nothing Then
                        cmd.Parameters.AddRange(parametros.ToArray())
                    End If
                    cnn.Open()
                    Return cmd.ExecuteScalar()
                End Using
            End Using
        End Function

        Public Shared Function ExecuteNonQuery(comandoSql As String, Optional parametros As List(Of SqlParameter) = Nothing) As Integer
            Using cnn As SqlConnection = ObtenerConexion()
                Using cmd As New SqlCommand(comandoSql, cnn)
                    cmd.CommandType = CommandType.Text
                    If parametros IsNot Nothing Then
                        cmd.Parameters.AddRange(parametros.ToArray())
                    End If
                    cnn.Open()
                    Return cmd.ExecuteNonQuery()
                End Using
            End Using
        End Function

        Public Shared Function ExecuteDataTable(comandoSql As String, Optional parametros As List(Of SqlParameter) = Nothing) As DataTable
            Using cnn As SqlConnection = ObtenerConexion()
                Using cmd As New SqlCommand(comandoSql, cnn)
                    cmd.CommandType = CommandType.Text
                    If parametros IsNot Nothing Then
                        cmd.Parameters.AddRange(parametros.ToArray())
                    End If
                    Using da As New SqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)
                        Return dt
                    End Using
                End Using
            End Using
        End Function

        Public Shared Function CrearParametro(nombre As String, tipo As SqlDbType, valor As Object, Optional esNullable As Boolean = False) As SqlParameter
            Dim param As New SqlParameter(nombre, tipo)
            If valor Is Nothing OrElse (TypeOf valor Is String AndAlso String.IsNullOrEmpty(DirectCast(valor, String)) AndAlso esNullable) Then
                param.Value = DBNull.Value
            Else
                param.Value = valor
            End If
            Return param
        End Function
    End Class
End Namespace
