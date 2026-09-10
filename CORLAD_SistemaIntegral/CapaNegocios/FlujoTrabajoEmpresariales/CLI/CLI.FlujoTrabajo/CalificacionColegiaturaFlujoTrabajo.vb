Imports System
Imports System.Collections.Generic
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports CLI.AccesoDatos
Imports GEN.Infraestructura

Namespace CLI.FlujoTrabajo
    ''' <summary>
    ''' Orquestador de reglas de negocio para la calificación técnica de expedientes y validación SUNEDU.
    ''' </summary>
    Public Class CalificacionColegiaturaFlujoTrabajo
        Implements ICalificacionColegiaturaServicio

        Private ReadOnly _accesoDatos As ICalificacionColegiaturaAccesoDatos

        Public Sub New()
            _accesoDatos = New CalificacionColegiaturaAccesoDatos()
        End Sub

        Public Sub New(accesoDatos As ICalificacionColegiaturaAccesoDatos)
            _accesoDatos = accesoDatos
        End Sub

        Public Function ObtenerBandejaPendientes(rolUsuario As String) As ApiResponse(Of List(Of ExpedientePendienteDTO)) Implements ICalificacionColegiaturaServicio.ObtenerBandejaPendientes
            Dim respuesta As New ApiResponse(Of List(Of ExpedientePendienteDTO))()

            ' Control de Acceso RBAC
            If Not EsRolAutorizado(rolUsuario) Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 403
                respuesta.Mensaje = "Acceso denegado: Se requiere rol de Secretaría Regional, Gerencia o Decanatura."
                Return respuesta
            End If

            Try
                Dim lista = _accesoDatos.ListarExpedientesPendientes()
                respuesta.Exito = True
                respuesta.CodigoEstado = 200
                respuesta.Datos = lista
                respuesta.Mensaje = $"Se obtuvieron {lista.Count} expedientes pendientes de calificación técnica."
            Catch ex As Exception
                respuesta.Exito = False
                respuesta.CodigoEstado = 500
                respuesta.Mensaje = "Error al listar la bandeja de expedientes: " & ex.Message
            End Try

            Return respuesta
        End Function

        Public Function ObtenerDetalleExpediente(expedienteId As Integer, rolUsuario As String) As ApiResponse(Of ExpedienteDetalleAuditoriaDTO) Implements ICalificacionColegiaturaServicio.ObtenerDetalleExpediente
            Dim respuesta As New ApiResponse(Of ExpedienteDetalleAuditoriaDTO)()

            If Not EsRolAutorizado(rolUsuario) Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 403
                respuesta.Mensaje = "Acceso denegado a los legajos documentarios."
                Return respuesta
            End If

            Try
                Dim detalle = _accesoDatos.ObtenerDetalleExpediente(expedienteId)
                If detalle Is Nothing Then
                    respuesta.Exito = False
                    respuesta.CodigoEstado = 404
                    respuesta.Mensaje = $"No se encontró el expediente con ID {expedienteId}."
                    Return respuesta
                End If

                respuesta.Exito = True
                respuesta.CodigoEstado = 200
                respuesta.Datos = detalle
                respuesta.Mensaje = "Detalle de expediente y requisitos obtenido correctamente."
            Catch ex As Exception
                respuesta.Exito = False
                respuesta.CodigoEstado = 500
                respuesta.Mensaje = "Error al recuperar el detalle del expediente: " & ex.Message
            End Try

            Return respuesta
        End Function

        Public Function ValidarTituloEnSunedu(dni As String, codigoSunedu As String) As ApiResponse(Of ValidacionSuneduResponseDTO) Implements ICalificacionColegiaturaServicio.ValidarTituloEnSunedu
            Dim respuesta As New ApiResponse(Of ValidacionSuneduResponseDTO)()

            Dim dniLimpio = If(dni, String.Empty).Trim()
            If dniLimpio.Length <> 8 Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 400
                respuesta.Mensaje = "El DNI para consulta ante SUNEDU debe tener exactamente 8 dígitos."
                Return respuesta
            End If

            Try
                ' Simulación del Servicio Oficial de SUNEDU (Registro Nacional de Grados y Títulos)
                ' En ambiente productivo consume el API REST de Interoperabilidad del Estado (PIDE)
                Dim resultadoSunedu As New ValidacionSuneduResponseDTO With {
                    .Dni = dniLimpio,
                    .CodigoRegistro = If(String.IsNullOrEmpty(codigoSunedu), "SUN-2024-" & dniLimpio.Substring(4), codigoSunedu),
                    .GradoTitulo = "LICENCIADO EN ADMINISTRACION",
                    .FechaEmision = New Date(2024, 2, 15),
                    .FechaConsulta = DateTime.Now
                }

                ' Regla de negocio: DNIs que inician con 000 simulan no registro
                If dniLimpio.StartsWith("000") Then
                    resultadoSunedu.EsValido = False
                    resultadoSunedu.Universidad = "NO REGISTRA"
                    resultadoSunedu.MensajeRespuesta = "No se encontraron registros de Título Profesional en Administración para el DNI consultado en SUNEDU."
                    
                    respuesta.Exito = True
                    respuesta.CodigoEstado = 200
                    respuesta.Datos = resultadoSunedu
                    respuesta.Mensaje = "Consulta completada: Título no registrado en SUNEDU."
                Else
                    resultadoSunedu.EsValido = True
                    resultadoSunedu.Universidad = "UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU"
                    resultadoSunedu.NombresCompletos = "POSTULANTE VERIFICADO SUNEDU"
                    resultadoSunedu.MensajeRespuesta = "Título Profesional verificado e inscrito en el Registro Nacional de Grados y Títulos de SUNEDU."

                    respuesta.Exito = True
                    respuesta.CodigoEstado = 200
                    respuesta.Datos = resultadoSunedu
                    respuesta.Mensaje = "Título Profesional verificado exitosamente con SUNEDU."
                End If

            Catch ex As Exception
                respuesta.Exito = False
                respuesta.CodigoEstado = 500
                respuesta.Mensaje = "Error en el servicio de interoperabilidad con SUNEDU: " & ex.Message
            End Try

            Return respuesta
        End Function

        Public Function ProcesarDictamen(request As CalificarExpedienteFormRequest, rolUsuario As String, usuarioAuditor As String) As ApiResponse(Of Boolean) Implements ICalificacionColegiaturaServicio.ProcesarDictamen
            Dim respuesta As New ApiResponse(Of Boolean)()

            ' 1. Autorización RBAC
            If Not request.Authorize(rolUsuario) Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 403
                respuesta.Mensaje = "Acceso denegado: El usuario no cuenta con privilegios para dictaminar expedientes."
                Return respuesta
            End If

            ' 2. Validación de reglas de negocio
            Dim validacion = request.Validar()
            If Not validacion.EsValido Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 400
                Dim listaErrores As New List(Of String)()
                For Each itemError As FormValidationError In validacion.Errores
                    listaErrores.Add($"{itemError.Campo}: {itemError.Mensaje}")
                Next
                respuesta.Mensaje = String.Join(" | ", listaErrores)
                Return respuesta
            End If

            Try
                ' 3. Determinar código de estado formal
                Dim nuevoEstado As String
                Select Case request.Dictamen.ToUpperInvariant()
                    Case "APROBADO"
                        nuevoEstado = "APROBADO"
                    Case "OBSERVADO"
                        nuevoEstado = "OBSERVADO"
                    Case "RECHAZADO"
                        nuevoEstado = "RECHAZADO"
                    Case Else
                        nuevoEstado = "EN_REVISION"
                End Select

                ' 4. Actualizar título con SUNEDU si fue validado
                If request.ValidadoSunedu AndAlso Not String.IsNullOrEmpty(request.CodigoRegistroSunedu) Then
                    _accesoDatos.ActualizarVerificacionTituloSunedu(request.ExpedienteId, request.CodigoRegistroSunedu, True, DateTime.Now)
                End If

                ' 5. Actualizar dictamen del expediente
                Dim exito = _accesoDatos.ActualizarDictamenExpediente(request.ExpedienteId, nuevoEstado, request.ValidadoSunedu, request.MotivoObservacion, usuarioAuditor)

                If exito Then
                    respuesta.Exito = True
                    respuesta.CodigoEstado = 200
                    respuesta.Datos = True
                    respuesta.Mensaje = $"Dictamen '{nuevoEstado}' registrado correctamente para el expediente {request.NumeroExpediente}."
                Else
                    respuesta.Exito = False
                    respuesta.CodigoEstado = 500
                    respuesta.Mensaje = "No se pudo actualizar el estado del expediente en la base de datos."
                End If

            Catch ex As Exception
                respuesta.Exito = False
                respuesta.CodigoEstado = 500
                respuesta.Mensaje = "Error interno al procesar el dictamen: " & ex.Message
            End Try

            Return respuesta
        End Function

        Private Function EsRolAutorizado(rolUsuario As String) As Boolean
            If String.IsNullOrWhiteSpace(rolUsuario) Then Return False
            Dim rol = rolUsuario.Trim().ToUpperInvariant()
            Return rol = "ROL-SEC" OrElse rol = "ROL-GER" OrElse rol = "ROL-DEC" OrElse rol = "ADMIN"
        End Function
    End Class
End Namespace
