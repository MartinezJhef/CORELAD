Imports System
Imports System.Collections.Generic
Imports ADM.Entidades

Namespace ADM.InterfacesServicios
    Public Interface IADM_AccesoDatos
        Function ListarTodos() As List(Of ADM_EntidadBase)
        Function ObtenerPorID(id As Integer) As ADM_EntidadBase
        Function Guardar(entidad As ADM_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IADM_Servicio
        Function Consultar() As List(Of ADM_EntidadBase)
        Function Registrar(entidad As ADM_EntidadBase) As Boolean
    End Interface
End Namespace
