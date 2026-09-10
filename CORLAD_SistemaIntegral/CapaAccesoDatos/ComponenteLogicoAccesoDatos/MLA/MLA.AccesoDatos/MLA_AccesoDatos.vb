Imports System
Imports System.Collections.Generic
Imports MLA.Entidades
Imports MLA.InterfacesServicios
Imports Helper.AccesoDatos

Namespace MLA.AccesoDatos
    Public Class MLA_AccesoDatos
        Implements IMLA_AccesoDatos

        Public Function ListarTodos() As List(Of MLA_EntidadBase) Implements IMLA_AccesoDatos.ListarTodos
            Return New List(Of MLA_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As MLA_EntidadBase Implements IMLA_AccesoDatos.ObtenerPorID
            Return New MLA_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo MLA"}
        End Function

        Public Function Guardar(entidad As MLA_EntidadBase) As Boolean Implements IMLA_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IMLA_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
