Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports CLI.AccesoDatos
Imports GEN.Infraestructura

Namespace CLI.FlujoTrabajo
    Public Class CLI_FlujoTrabajo
        Implements ICLI_Servicio

        Private ReadOnly _da As ICLI_AccesoDatos

        Public Sub New()
            _da = New CLI_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of CLI_EntidadBase) Implements ICLI_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As CLI_EntidadBase) As Boolean Implements ICLI_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
