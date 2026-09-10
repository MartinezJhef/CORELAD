Imports System
Imports System.Collections.Generic
Imports MLA.Entidades

Namespace MLA.InterfacesServicios
    Public Interface IMLA_AccesoDatos
        Function ListarTodos() As List(Of MLA_EntidadBase)
        Function ObtenerPorID(id As Integer) As MLA_EntidadBase
        Function Guardar(entidad As MLA_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface IMLA_Servicio
        Function Consultar() As List(Of MLA_EntidadBase)
        Function Registrar(entidad As MLA_EntidadBase) As Boolean
    End Interface
End Namespace
