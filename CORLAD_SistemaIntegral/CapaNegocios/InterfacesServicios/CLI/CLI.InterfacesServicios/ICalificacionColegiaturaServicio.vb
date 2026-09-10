Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports GEN.Infraestructura

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de lógica de negocio para la calificación técnica de expedientes y validación con SUNEDU.
    ''' </summary>
    Public Interface ICalificacionColegiaturaServicio
        ''' <summary>
        ''' Obtiene la bandeja de expedientes pendientes para la Secretaria Regional con validación de roles.
        ''' </summary>
        Function ObtenerBandejaPendientes(rolUsuario As String) As ApiResponse(Of List(Of ExpedientePendienteDTO))

        ''' <summary>
        ''' Obtiene el detalle completo del legajo y los 5 requisitos para auditoría.
        ''' </summary>
        Function ObtenerDetalleExpediente(expedienteId As Integer, rolUsuario As String) As ApiResponse(Of ExpedienteDetalleAuditoriaDTO)

        ''' <summary>
        ''' Consulta el Registro Nacional de Grados y Títulos de SUNEDU para verificar autenticidad.
        ''' </summary>
        Function ValidarTituloEnSunedu(dni As String, codigoSunedu As String) As ApiResponse(Of ValidacionSuneduResponseDTO)

        ''' <summary>
        ''' Procesa el dictamen final (APROBADO, OBSERVADO o RECHAZADO) con reglas de negocio y auditoría.
        ''' </summary>
        Function ProcesarDictamen(request As CalificarExpedienteFormRequest, rolUsuario As String, usuarioAuditor As String) As ApiResponse(Of Boolean)
    End Interface
End Namespace
