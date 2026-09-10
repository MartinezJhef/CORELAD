Imports System
Imports System.Collections.Generic
Imports ADM.Entidades
Imports ADM.InterfacesServicios
Imports Helper.AccesoDatos

Namespace ADM.AccesoDatos
    Public Class ADM_AccesoDatos
        Implements IADM_AccesoDatos

        Public Function ListarTodos() As List(Of ADM_EntidadBase) Implements IADM_AccesoDatos.ListarTodos
            Return New List(Of ADM_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As ADM_EntidadBase Implements IADM_AccesoDatos.ObtenerPorID
            Return New ADM_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo ADM"}
        End Function

        Public Function Guardar(entidad As ADM_EntidadBase) As Boolean Implements IADM_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IADM_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
