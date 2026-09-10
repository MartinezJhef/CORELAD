Imports System
Imports System.Collections.Generic
Imports CLI.AccesoDatos
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports GEN.Infraestructura

Namespace CLI.FlujoTrabajo
    ''' <summary>
    ''' Orquestador de la lógica de negocio para la Asignación de Matrícula Regional y Emisión de Carnet Oficial (CU-COL-03).
    ''' </summary>
    Public Class ColegiadoFlujoTrabajo
        Implements IColegiadoServicio

        Private ReadOnly _accesoDatos As IColegiadoAccesoDatos

        Public Sub New()
            _accesoDatos = New ColegiadoAccesoDatos()
        End Sub

        Public Sub New(accesoDatos As IColegiadoAccesoDatos)
            _accesoDatos = accesoDatos
        End Sub

        Public Function ObtenerExpedientesAprobados(rol As String) As ApiResponse(Of List(Of ExpedienteAprobadoDTO)) Implements IColegiadoServicio.ObtenerExpedientesAprobados
            ' 1. Verificación de Autorización RBAC
            If Not EsRolAutorizado(rol) Then
                Return New ApiResponse(Of List(Of ExpedienteAprobadoDTO)) With {
                    .Exito = False,
                    .CodigoEstado = 403,
                    .Mensaje = "Acceso denegado. Únicamente el Decano Regional o la Secretaria Regional tienen acceso a la bandeja de matriculación.",
                    .Datos = New List(Of ExpedienteAprobadoDTO)()
                }
            End If

            Try
                Dim lista = _accesoDatos.ListarExpedientesAprobados()
                Return New ApiResponse(Of List(Of ExpedienteAprobadoDTO)) With {
                    .Exito = True,
                    .CodigoEstado = 200,
                    .Mensaje = $"Se encontraron {lista.Count} expedientes aprobados listos para asignación de matrícula.",
                    .Datos = lista
                }
            Catch ex As Exception
                Return New ApiResponse(Of List(Of ExpedienteAprobadoDTO)) With {
                    .Exito = False,
                    .CodigoEstado = 500,
                    .Mensaje = "Ocurrió un error al recuperar los expedientes aprobados: " & ex.Message,
                    .Datos = New List(Of ExpedienteAprobadoDTO)()
                }
            End Try
        End Function

        Public Function ObtenerSiguienteMatriculaSugerida(rol As String) As ApiResponse(Of String) Implements IColegiadoServicio.ObtenerSiguienteMatriculaSugerida
            If Not EsRolAutorizado(rol) Then
                Return New ApiResponse(Of String) With {
                    .Exito = False,
                    .CodigoEstado = 403,
                    .Mensaje = "Acceso denegado para consultar correlativos oficiales."
                }
            End If

            Try
                Dim ultimoCorrelativo = _accesoDatos.ObtenerUltimoCorrelativoMatricula()
                Dim siguiente = ultimoCorrelativo + 1
                Dim matriculaSugerida = $"CORLAD-JUN-{siguiente:D5}"

                Return New ApiResponse(Of String) With {
                    .Exito = True,
                    .CodigoEstado = 200,
                    .Mensaje = "Correlativo de matrícula regional calculado exitosamente.",
                    .Datos = matriculaSugerida
                }
            Catch ex As Exception
                Return New ApiResponse(Of String) With {
                    .Exito = False,
                    .CodigoEstado = 500,
                    .Mensaje = "Error al calcular el correlativo de matrícula: " & ex.Message
                }
            End Try
        End Function

        Public Function AsignarMatricula(request As AsignarMatriculaFormRequest, rol As String, usuarioOperador As String) As ApiResponse(Of CarnetColegiadoDTO) Implements IColegiadoServicio.AsignarMatricula
            If request Is Nothing Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "La solicitud de asignación de matrícula no puede ser nula."
                }
            End If

            ' 1. Autorización RBAC
            If Not request.Authorize(rol) Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 403,
                    .Mensaje = "Acceso denegado. Se requiere rol autorizado (Decano Regional ROL-DEC o Secretaria Regional ROL-SEC)."
                }
            End If

            ' 2. Validación de Entrada
            Dim validacion = request.Validar()
            If Not validacion.EsValido Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = validacion.PrimerMensajeError
                }
            End If

            ' 3. Regla de Negocio: Verificar que la matrícula regional no esté duplicada
            If _accesoDatos.ExisteMatriculaRegional(request.MatriculaRegional) Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 409,
                    .Mensaje = $"La matrícula regional '{request.MatriculaRegional}' ya se encuentra registrada en el Padrón Regional."
                }
            End If

            Try
                ' 4. Instanciar Entidad Colegiado
                Dim colegiado As New ColegiadoBE With {
                    .MatriculaRegional = request.MatriculaRegional,
                    .MatriculaNacional = request.MatriculaNacional,
                    .FechaIncorporacion = request.FechaJuramentacion,
                    .CondicionColegiado = request.CondicionColegiado,
                    .EstadoHabilidadActual = "HABIL",
                    .CantidadCuotasPendientes = 0,
                    .UltimoPeriodoPagado = DateTime.Today.ToString("yyyy-MM")
                }

                Dim usuarioAudit = If(String.IsNullOrWhiteSpace(usuarioOperador), "DECANO_REGIONAL", usuarioOperador.Trim())

                ' 5. Persistir Transacción ACID
                Dim nuevoId = _accesoDatos.RegistrarColegiado(colegiado, request.ExpedienteColegiaturaID, request.NumeroResolucionIncorporacion, request.FechaJuramentacion, usuarioAudit)

                If nuevoId <= 0 Then
                    Return New ApiResponse(Of CarnetColegiadoDTO) With {
                        .Exito = False,
                        .CodigoEstado = 500,
                        .Mensaje = "No fue posible persistir el alta en el Padrón Regional de Colegiados."
                    }
                End If

                ' 6. Obtener y compilar Carnet Oficial
                Dim carnet = _accesoDatos.ObtenerDatosCarnet(nuevoId)
                If carnet Is Nothing Then
                    carnet = _accesoDatos.ObtenerDatosCarnetPorExpediente(request.ExpedienteColegiaturaID)
                End If

                If carnet IsNot Nothing Then
                    EnriquecerCarnetCriptografico(carnet)
                End If

                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = True,
                    .CodigoEstado = 201,
                    .Mensaje = $"¡Incorporación formal exitosa! Se ha emitido la matrícula '{request.MatriculaRegional}' y generado el Carnet Institucional Oficial.",
                    .Datos = carnet
                }

            Catch ex As Exception
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 500,
                    .Mensaje = "Ocurrió un fallo en el servidor al formalizar la matrícula: " & ex.Message
                }
            End Try
        End Function

        Public Function ObtenerCarnet(colegiadoId As Integer, rol As String) As ApiResponse(Of CarnetColegiadoDTO) Implements IColegiadoServicio.ObtenerCarnet
            If Not EsRolAutorizado(rol) Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 403,
                    .Mensaje = "Acceso denegado para consultar la credencial oficial."
                }
            End If

            If colegiadoId <= 0 Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "Identificador de colegiado inválido."
                }
            End If

            Try
                Dim carnet = _accesoDatos.ObtenerDatosCarnet(colegiadoId)
                If carnet Is Nothing Then
                    Return New ApiResponse(Of CarnetColegiadoDTO) With {
                        .Exito = False,
                        .CodigoEstado = 404,
                        .Mensaje = "No se encontró el carnet solicitado para el colegiado indicado."
                    }
                End If

                EnriquecerCarnetCriptografico(carnet)

                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = True,
                    .CodigoEstado = 200,
                    .Mensaje = "Carnet oficial recuperado correctamente.",
                    .Datos = carnet
                }
            Catch ex As Exception
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 500,
                    .Mensaje = "Error al recuperar el carnet: " & ex.Message
                }
            End Try
        End Function

        Public Function ObtenerCarnetPorExpediente(expedienteId As Integer, rol As String) As ApiResponse(Of CarnetColegiadoDTO) Implements IColegiadoServicio.ObtenerCarnetPorExpediente
            If Not EsRolAutorizado(rol) Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 403,
                    .Mensaje = "Acceso denegado para consultar el carnet de colegiatura."
                }
            End If

            If expedienteId <= 0 Then
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 400,
                    .Mensaje = "Identificador de expediente inválido."
                }
            End If

            Try
                Dim carnet = _accesoDatos.ObtenerDatosCarnetPorExpediente(expedienteId)
                If carnet Is Nothing Then
                    Return New ApiResponse(Of CarnetColegiadoDTO) With {
                        .Exito = False,
                        .CodigoEstado = 404,
                        .Mensaje = "El expediente aún no cuenta con matrícula asignada ni carnet emitido."
                    }
                End If

                EnriquecerCarnetCriptografico(carnet)

                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = True,
                    .CodigoEstado = 200,
                    .Mensaje = "Carnet oficial recuperado correctamente.",
                    .Datos = carnet
                }
            Catch ex As Exception
                Return New ApiResponse(Of CarnetColegiadoDTO) With {
                    .Exito = False,
                    .CodigoEstado = 500,
                    .Mensaje = "Error al recuperar el carnet del expediente: " & ex.Message
                }
            End Try
        End Function

        ''' <summary>
        ''' Calcula el hash criptográfico SHA-256 inmutable y la URL dinámica de validación QR institucional.
        ''' </summary>
        Private Shared Sub EnriquecerCarnetCriptografico(carnet As CarnetColegiadoDTO)
            If carnet Is Nothing Then Return

            ' Semilla de hash: MatriculaRegional + DNI + NumeroResolucion + FechaIncorporacion
            Dim tramaSeguridad = $"{carnet.MatriculaRegional}|{carnet.Dni}|{carnet.NumeroResolucion}|{carnet.FechaIncorporacion:yyyyMMdd}"
            carnet.HashSeguridad = CryptoHelper.CalcularSHA256(tramaSeguridad)

            ' Token corto para URL QR
            Dim tokenQr = If(carnet.HashSeguridad.Length >= 16, carnet.HashSeguridad.Substring(0, 16), "0123456789abcdef")
            carnet.CodigoQRUrl = $"https://validador.corladjunin.org.pe/colegiado/verificar?mat={Uri.EscapeDataString(carnet.MatriculaRegional)}&dni={carnet.Dni}&hash={tokenQr}"
        End Sub

        Private Shared Function EsRolAutorizado(rol As String) As Boolean
            If String.IsNullOrWhiteSpace(rol) Then Return False
            Dim rolUpper = rol.Trim().ToUpperInvariant()
            Return rolUpper = "ROL-DEC" OrElse rolUpper = "ROL-SEC" OrElse rolUpper = "ROL-GER" OrElse rolUpper = "ADMIN"
        End Function
    End Class
End Namespace
