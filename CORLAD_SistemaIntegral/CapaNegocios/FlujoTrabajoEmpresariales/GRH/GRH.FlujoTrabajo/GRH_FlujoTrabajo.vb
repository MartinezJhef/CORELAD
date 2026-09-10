Imports System
Imports System.Collections.Generic
Imports GRH.Entidades
Imports GRH.InterfacesServicios
Imports GRH.AccesoDatos
Imports GEN.Infraestructura

Namespace GRH.FlujoTrabajo
    Public Class GRH_FlujoTrabajo
        Implements IGRH_Servicio

        Private ReadOnly _da As IGRH_AccesoDatos

        Public Sub New()
            _da = New GRH_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of GRH_EntidadBase) Implements IGRH_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As GRH_EntidadBase) As Boolean Implements IGRH_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
