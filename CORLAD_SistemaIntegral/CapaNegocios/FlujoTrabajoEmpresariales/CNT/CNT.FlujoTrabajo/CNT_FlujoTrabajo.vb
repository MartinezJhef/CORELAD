Imports System
Imports System.Collections.Generic
Imports CNT.Entidades
Imports CNT.InterfacesServicios
Imports CNT.AccesoDatos
Imports GEN.Infraestructura

Namespace CNT.FlujoTrabajo
    Public Class CNT_FlujoTrabajo
        Implements ICNT_Servicio

        Private ReadOnly _da As ICNT_AccesoDatos

        Public Sub New()
            _da = New CNT_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of CNT_EntidadBase) Implements ICNT_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As CNT_EntidadBase) As Boolean Implements ICNT_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
