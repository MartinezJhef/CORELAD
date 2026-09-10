Imports System
Imports System.Collections.Generic
Imports PRE.Entidades

Namespace PRE.InterfacesServicios
    Public Interface IPRE_AccesoDatos
        Function ListarTodos() As List(Of PRE_EntidadBase)
        Function ObtenerPorID(id As Integer) As PRE_EntidadBase
        Function Guardar(entidad As PRE_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IPRE_Servicio
        Function Consultar() As List(Of PRE_EntidadBase)
        Function Registrar(entidad As PRE_EntidadBase) As Boolean
    End Interface
End Namespace
