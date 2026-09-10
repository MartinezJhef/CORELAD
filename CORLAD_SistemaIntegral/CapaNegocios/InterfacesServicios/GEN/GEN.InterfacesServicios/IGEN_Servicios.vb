Imports System
Imports System.Collections.Generic
Imports GEN.Entidades

Namespace GEN.InterfacesServicios
    Public Interface IGEN_AccesoDatos
        Function ListarTodos() As List(Of GEN_EntidadBase)
        Function ObtenerPorID(id As Integer) As GEN_EntidadBase
        Function Guardar(entidad As GEN_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IGEN_Servicio
        Function Consultar() As List(Of GEN_EntidadBase)
        Function Registrar(entidad As GEN_EntidadBase) As Boolean
    End Interface
End Namespace
