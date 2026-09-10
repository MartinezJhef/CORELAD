Imports System
Imports System.Collections.Generic
Imports CAJ.Entidades
Imports CAJ.InterfacesServicios
Imports CAJ.AccesoDatos
Imports GEN.Infraestructura

Namespace CAJ.FlujoTrabajo
    Public Class CAJ_FlujoTrabajo
        Implements ICAJ_Servicio

        Private ReadOnly _da As ICAJ_AccesoDatos

        Public Sub New()
            _da = New CAJ_AccesoDatos()
        End Sub

        Public Function Consultar() As List(Of CAJ_EntidadBase) Implements ICAJ_Servicio.Consultar
            Return _da.ListarTodos()
        End Function

        Public Function Registrar(entidad As CAJ_EntidadBase) As Boolean Implements ICAJ_Servicio.Registrar
            If entidad Is Nothing Then Throw New ArgumentNullException(NameOf(entidad))
            Return _da.Guardar(entidad)
        End Function
    End Class
End Namespace
