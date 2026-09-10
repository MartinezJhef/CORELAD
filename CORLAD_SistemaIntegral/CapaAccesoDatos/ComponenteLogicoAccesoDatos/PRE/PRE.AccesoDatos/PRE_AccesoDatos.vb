Imports System
Imports System.Collections.Generic
Imports PRE.Entidades
Imports PRE.InterfacesServicios
Imports Helper.AccesoDatos

Namespace PRE.AccesoDatos
    Public Class PRE_AccesoDatos
        Implements IPRE_AccesoDatos

        Public Function ListarTodos() As List(Of PRE_EntidadBase) Implements IPRE_AccesoDatos.ListarTodos
            Return New List(Of PRE_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As PRE_EntidadBase Implements IPRE_AccesoDatos.ObtenerPorID
            Return New PRE_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo PRE"}
        End Function

        Public Function Guardar(entidad As PRE_EntidadBase) As Boolean Implements IPRE_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IPRE_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
