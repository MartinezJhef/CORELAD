Imports System
Imports System.Collections.Generic
Imports CLI.Entidades

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de persistencia y consultas SQL para la calificación técnica de expedientes de colegiatura.
    ''' </summary>
    Public Interface ICalificacionColegiaturaAccesoDatos
        ''' <summary>
        ''' Obtiene la lista de expedientes en estado 'EN_REVISION' o 'ENVIADO' para la bandeja de Mesa de Partes.
        ''' </summary>
        Function ListarExpedientesPendientes() As List(Of ExpedientePendienteDTO)

        ''' <summary>
        ''' Obtiene el expediente completo con sus requisitos documentarios para la auditoría técnica.
        ''' </summary>
        Function ObtenerDetalleExpediente(expedienteId As Integer) As ExpedienteDetalleAuditoriaDTO

        ''' <summary>
        ''' Actualiza el estado y dictamen del expediente de forma parametrizada.
        ''' </summary>
        Function ActualizarDictamenExpediente(expedienteId As Integer, nuevoEstado As String, validadoSunedu As Boolean, observaciones As String, usuarioAuditor As String) As Boolean

        ''' <summary>
        ''' Registra la verificación del título universitario en SUNEDU.
        ''' </summary>
        Function ActualizarVerificacionTituloSunedu(expedienteId As Integer, codigoSunedu As String, verificado As Boolean, fechaVerificacion As Date) As Boolean
    End Interface
End Namespace
