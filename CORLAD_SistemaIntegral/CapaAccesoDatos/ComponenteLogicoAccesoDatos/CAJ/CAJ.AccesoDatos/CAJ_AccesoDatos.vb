Imports System
Imports System.Collections.Generic
Imports CAJ.Entidades
Imports CAJ.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CAJ.AccesoDatos
    Public Class CAJ_AccesoDatos
        Implements ICAJ_AccesoDatos

        Public Function ListarTodos() As List(Of CAJ_EntidadBase) Implements ICAJ_AccesoDatos.ListarTodos
            Return New List(Of CAJ_EntidadBase)()
        End Function

        Public Function ObtenerPorID(id As Integer) As CAJ_EntidadBase Implements ICAJ_AccesoDatos.ObtenerPorID
            Return New CAJ_EntidadBase() With {.ID = id, .Descripcion = "MÃ³dulo CAJ"}
        End Function

        Public Function Guardar(entidad As CAJ_EntidadBase) As Boolean Implements ICAJ_AccesoDatos.Guardar
            Return True
        End Function

        Public Function Eliminar(id As Integer) As Boolean Implements ICAJ_AccesoDatos.Eliminar
            Return True
        End Function
    End Class
End Namespace
