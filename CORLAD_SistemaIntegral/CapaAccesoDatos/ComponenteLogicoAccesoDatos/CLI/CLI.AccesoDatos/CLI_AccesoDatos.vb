Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CLI.AccesoDatos
    Public Class CLI_AccesoDatos
        Implements ICLI_AccesoDatos

        Public Function ListarTodos() As List(Of CLI_EntidadBase) Implements ICLI_AccesoDatos.ListarTodos
            Return New List(Of CLI_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As CLI_EntidadBase Implements ICLI_AccesoDatos.ObtenerPorID
            Return New CLI_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo CLI"}
        End Function

        Public Function Guardar(entidad As CLI_EntidadBase) As Boolean Implements ICLI_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements ICLI_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
