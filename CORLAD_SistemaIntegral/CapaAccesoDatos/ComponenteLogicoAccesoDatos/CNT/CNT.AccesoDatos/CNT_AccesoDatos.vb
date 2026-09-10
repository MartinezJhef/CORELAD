Imports System
Imports System.Collections.Generic
Imports CNT.Entidades
Imports CNT.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CNT.AccesoDatos
    Public Class CNT_AccesoDatos
        Implements ICNT_AccesoDatos

        Public Function ListarTodos() As List(Of CNT_EntidadBase) Implements ICNT_AccesoDatos.ListarTodos
            Return New List(Of CNT_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As CNT_EntidadBase Implements ICNT_AccesoDatos.ObtenerPorID
            Return New CNT_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo CNT"}
        End Function

        Public Function Guardar(entidad As CNT_EntidadBase) As Boolean Implements ICNT_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements ICNT_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
