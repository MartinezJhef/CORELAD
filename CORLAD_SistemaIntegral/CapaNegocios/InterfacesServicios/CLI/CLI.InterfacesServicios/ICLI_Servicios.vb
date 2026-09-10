Imports System
Imports System.Collections.Generic
Imports CLI.Entidades

Namespace CLI.InterfacesServicios
    Public Interface ICLI_AccesoDatos
        Function ListarTodos() As List(Of CLI_EntidadBase)
        Function ObtenerPorID(id As Integer) As CLI_EntidadBase
        Function Guardar(entidad As CLI_EntidadBase) As Boolean
        Function Eliminar(id As Integer) As Boolean
    End Interface

    Public Interface ICLI_Servicio
        Function Consultar() As List(Of CLI_EntidadBase)
        Function Registrar(entidad As CLI_EntidadBase) As Boolean
    End Interface
End Namespace
