Imports System
Imports System.Collections.Generic
Imports RPT.Entidades
Imports RPT.InterfacesServicios
Imports Helper.AccesoDatos

Namespace RPT.AccesoDatos
    Public Class RPT_AccesoDatos
        Implements IRPT_AccesoDatos

        Public Function ListarTodos() As List(Of RPT_EntidadBase) Implements IRPT_AccesoDatos.ListarTodos
            Return New List(Of RPT_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As RPT_EntidadBase Implements IRPT_AccesoDatos.ObtenerPorID
            Return New RPT_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo RPT"}
        End Function

        Public Function Guardar(entidad As RPT_EntidadBase) As Boolean Implements IRPT_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IRPT_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
