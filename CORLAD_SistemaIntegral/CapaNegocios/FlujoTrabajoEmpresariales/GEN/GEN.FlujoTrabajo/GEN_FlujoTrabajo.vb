Imports System
Imports System.Collections.Generic
Imports GEN.Entidades
Imports GEN.InterfacesServicios
Imports GEN.AccesoDatos
Imports GEN.Infraestructura

Namespace GEN.FlujoTrabajo
    Public Class GEN_FlujoTrabajo
        Implements IGEN_Servicio

        Private ReadOnly _da As IGEN_AccesoDatos

        Public Sub New()
            _da = New GEN_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of GEN_EntidadBase) Implements IGEN_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As GEN_EntidadBase) As Boolean Implements IGEN_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
