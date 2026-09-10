Imports System
Imports System.Collections.Generic
Imports ADM.Entidades
Imports ADM.InterfacesServicios
Imports ADM.AccesoDatos
Imports GEN.Infraestructura

Namespace ADM.FlujoTrabajo
    Public Class ADM_FlujoTrabajo
        Implements IADM_Servicio

        Private ReadOnly _da As IADM_AccesoDatos

        Public Sub New()
            _da = New ADM_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of ADM_EntidadBase) Implements IADM_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As ADM_EntidadBase) As Boolean Implements IADM_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
