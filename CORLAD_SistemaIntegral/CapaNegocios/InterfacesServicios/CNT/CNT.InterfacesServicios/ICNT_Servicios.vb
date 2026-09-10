Imports System
Imports System.Collections.Generic
Imports CNT.Entidades

Namespace CNT.InterfacesServicios
    Public Interface ICNT_AccesoDatos
        Function ListarTodos() As List(Of CNT_EntidadBase)
        Function ObtenerPorID(id As Integer) As CNT_EntidadBase
        Function Guardar(entidad As CNT_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface ICNT_Servicio
        Function Consultar() As List(Of CNT_EntidadBase)
        Function Registrar(entidad As CNT_EntidadBase) As Boolean
    End Interface
End Namespace
