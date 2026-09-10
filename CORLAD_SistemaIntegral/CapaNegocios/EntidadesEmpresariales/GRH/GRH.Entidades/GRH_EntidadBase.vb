Imports System

Namespace GRH.Entidades
    Public Class GRH_EntidadBase
        Public Property ID As Integer
        Public Property Codigo As String
        Public Property Descripcion As String
        Public Property Activo As Boolean = True
        Public Property FechaRegistro As DateTime = DateTime.Now
    End Class
End Namespace
