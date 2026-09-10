Imports System
Imports System.Collections.Generic
Imports GRH.Entidades

Namespace GRH.InterfacesServicios
    Public Interface IGRH_AccesoDatos
        Function ListarTodos() As List(Of GRH_EntidadBase)
        Function ObtenerPorID(id As Integer) As GRH_EntidadBase
        Function Guardar(entidad As GRH_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IGRH_Servicio
        Function Consultar() As List(Of GRH_EntidadBase)
        Function Registrar(entidad As GRH_EntidadBase) As Boolean
    End Interface
End Namespace
