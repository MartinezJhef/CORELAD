Imports System

Namespace CLI.Entidades
    ''' <summary>
    ''' Entidad Empresarial que representa los datos civiles y de contacto del postulante a colegiatura.
    ''' Mapea a las tablas [Persona].[Persona], [Persona].[Direccion] y [Persona].[Contacto].
    ''' </summary>
    Public Class PostulanteBE
        Public Property EntidadID As Integer
        Public Property Dni As String ' char(8)
        Public Property ApellidoPaterno As String ' nvarchar(50)
        Public Property ApellidoMaterno As String ' nvarchar(50)
        Public Property Nombres As String ' nvarchar(100)
        Public Property Sexo As String ' char(1) - 'M' o 'F'
        Public Property EstadoCivil As String ' char(1) - 'S', 'C', 'V', 'D'
        Public Property FechaNacimiento As Date
        Public Property EsColegiado As Boolean = False
        Public Property EsPostulante As Boolean = True
        Public Property EsEmpleado As Boolean = False
        Public Property Departamento As String = "JUNIN"
        Public Property Provincia As String = "HUANCAYO"
        Public Property Distrito As String = "HUANCAYO"
        Public Property DireccionDetalle As String
        Public Property Referencia As String
        Public Property CorreoElectronico As String
        Public Property Telefono As String
        Public Property FechaRegistro As DateTime = DateTime.Now
    End Class
End Namespace
