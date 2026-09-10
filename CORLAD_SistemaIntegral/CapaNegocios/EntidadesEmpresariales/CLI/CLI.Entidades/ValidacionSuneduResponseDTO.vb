Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' DTO con el resultado de la contrastación en el Registro Nacional de Grados y Títulos de SUNEDU.
    ''' </summary>
    Public Class ValidacionSuneduResponseDTO
        Public Property Dni As String
        Public Property NombresCompletos As String
        Public Property Universidad As String
        Public Property GradoTitulo As String
        Public Property CodigoRegistro As String
        Public Property FechaEmision As Date
        Public Property EsValido As Boolean
        Public Property MensajeRespuesta As String
        Public Property FechaConsulta As Date = DateTime.Now
    End Class

    ''' <summary>
    ''' Solicitud para consulta de título ante SUNEDU.
    ''' </summary>
    Public Class ConsultarSuneduRequest
        Public Property Dni As String
        Public Property CodigoRegistroSunedu As String
    End Class
End Namespace
