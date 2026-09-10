Imports System
Imports System.Collections.Generic
Imports ADM.FlujoTrabajo
Imports CLI.FlujoTrabajo
Imports MLA.FlujoTrabajo

Namespace CORLAD.API
    ''' <summary>
    ''' Controlador de Servicios REST para la comunicacion con el Frontend en React
    ''' </summary>
    Public Class CorladApiController
        Public Function ObtenerEstadoServicio() As String
            Return "CORLAD JunÃ­n Web API REST v1.0 - Conectado con React y Backend VB.NET"
        End Function
    End Class
End Namespace
