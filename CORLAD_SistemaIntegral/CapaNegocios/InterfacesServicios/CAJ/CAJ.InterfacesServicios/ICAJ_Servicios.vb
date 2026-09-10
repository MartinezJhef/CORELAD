Imports System
Imports System.Collections.Generic
Imports CAJ.Entidades

Namespace CAJ.InterfacesServicios
    Public Interface ICAJ_AccesoDatos
        Function ListarTodos() As List(Of CAJ_EntidadBase)
        Function ObtenerPorID(id As Integer) As CAJ_EntidadBase
        Function Guardar(entidad As CAJ_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface ICAJ_Servicio
        Function Consultar() As List(Of CAJ_EntidadBase)
        Function Registrar(entidad As CAJ_EntidadBase) As Boolean
    End Interface
End Namespace
