Imports System
Imports System.Collections.Generic
Imports GRH.Entidades
Imports GRH.InterfacesServicios
Imports Helper.AccesoDatos

Namespace GRH.AccesoDatos
    Public Class GRH_AccesoDatos
        Implements IGRH_AccesoDatos

        Public Function ListarTodos() As List(Of GRH_EntidadBase) Implements IGRH_AccesoDatos.ListarTodos
            Return New List(Of GRH_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As GRH_EntidadBase Implements IGRH_AccesoDatos.ObtenerPorID
            Return New GRH_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo GRH"}
        End Function

        Public Function Guardar(entidad As GRH_EntidadBase) As Boolean Implements IGRH_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements IGRH_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
