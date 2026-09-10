Imports System
Imports System.Collections.Generic
Imports MLA.Entidades
Imports MLA.InterfacesServicios
Imports MLA.AccesoDatos
Imports GEN.Infraestructura

Namespace MLA.FlujoTrabajo
    Public Class MLA_FlujoTrabajo
        Implements IMLA_Servicio

        Private ReadOnly _da As IMLA_AccesoDatos

        Public Sub New()
            _da = New MLA_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of MLA_EntidadBase) Implements IMLA_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As MLA_EntidadBase) As Boolean Implements IMLA_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
