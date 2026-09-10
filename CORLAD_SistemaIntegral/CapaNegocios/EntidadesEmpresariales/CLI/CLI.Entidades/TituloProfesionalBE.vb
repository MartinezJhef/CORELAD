Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' Entidad Empresarial que representa el Título Profesional universitario emitido por la universidad de origen.
    ''' Mapea a la tabla [Colegiatura].[TituloProfesional].
    ''' </summary>
    Public Class TituloProfesionalBE
        Public Property TituloID As Integer
        Public Property EntidadID As Integer
        Public Property UniversidadOrigen As String ' nvarchar(150)
        Public Property DenominacionTitulo As String = "LICENCIADO EN ADMINISTRACION" ' nvarchar(150)
        Public Property FechaExpedicion As Date
        Public Property NumeroResolucionSunedu As String ' nvarchar(50)
        Public Property CodigoRegistroSunedu As String ' nvarchar(50)
        Public Property VerificadoConSunedu As Boolean = False
        Public Property FechaVerificacion As DateTime?
        Public Property DocumentoTituloUrl As String
    End Class
End Namespace
