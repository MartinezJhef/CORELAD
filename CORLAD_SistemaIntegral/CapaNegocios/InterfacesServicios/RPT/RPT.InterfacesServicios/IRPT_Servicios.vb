Imports System
Imports System.Collections.Generic
Imports RPT.Entidades

Namespace RPT.InterfacesServicios
    Public Interface IRPT_AccesoDatos
        Function ListarTodos() As List(Of RPT_EntidadBase)
        Function ObtenerPorID(id As Integer) As RPT_EntidadBase
        Function Guardar(entidad As RPT_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IRPT_Servicio
        Function Consultar() As List(Of RPT_EntidadBase)
        Function Registrar(entidad As RPT_EntidadBase) As Boolean
    End Interface
End Namespace
