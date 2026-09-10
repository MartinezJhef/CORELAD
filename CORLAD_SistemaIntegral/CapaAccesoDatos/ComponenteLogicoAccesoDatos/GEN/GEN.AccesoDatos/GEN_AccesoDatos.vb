Imports System
Imports System.Collections.Generic
Imports GEN.Entidades
Imports GEN.InterfacesServicios
Imports Helper.AccesoDatos

Namespace GEN.AccesoDatos
    Public Class GEN_AccesoDatos
        Implements IGEN_AccesoDatos

        Public Function ListarTodos() As List(Of GEN_EntidadBase) Implements IGEN_AccesoDatos.ListarTodos
            Return New List(Of GEN_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As GEN_EntidadBase Implements IGEN_AccesoDatos.ObtenerPorID
            Return New GEN_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo GEN"}
        End Function

        Public Function Guardar(entidad As GEN_EntidadBase) As Boolean Implements IGEN_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IGEN_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
