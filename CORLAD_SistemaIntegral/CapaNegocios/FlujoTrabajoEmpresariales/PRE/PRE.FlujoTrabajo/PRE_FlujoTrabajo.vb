Imports System
Imports System.Collections.Generic
Imports PRE.Entidades
Imports PRE.InterfacesServicios
Imports PRE.AccesoDatos
Imports GEN.Infraestructura

Namespace PRE.FlujoTrabajo
    Public Class PRE_FlujoTrabajo
        Implements IPRE_Servicio

        Private ReadOnly _da As IPRE_AccesoDatos

        Public Sub New()
            _da = New PRE_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of PRE_EntidadBase) Implements IPRE_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As PRE_EntidadBase) As Boolean Implements IPRE_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
