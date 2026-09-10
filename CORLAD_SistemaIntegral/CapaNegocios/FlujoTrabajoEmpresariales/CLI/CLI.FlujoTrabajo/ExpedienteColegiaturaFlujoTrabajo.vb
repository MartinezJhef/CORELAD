Imports System
Imports System.Collections.Generic
Imports System.IO
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports CLI.AccesoDatos
Imports GEN.Infraestructura

Namespace CLI.FlujoTrabajo
    ''' <summary>
    ''' Orquestador de Reglas de Negocio para el Proceso Misional de Colegiatura (PM-01).
    ''' Implementa validación BDD, autorización, unicidad de matrícula y correlatividad inalterable.
    ''' </summary>
    Public Class ExpedienteColegiaturaFlujoTrabajo
        Implements IExpedienteColegiaturaServicio

        Private ReadOnly _accesoDatos As IExpedienteColegiaturaAccesoDatos

        Public Sub New()
            _accesoDatos = New ExpedienteColegiaturaAccesoDatos()
        End Sub

        Public Sub New(accesoDatos As IExpedienteColegiaturaAccesoDatos)
            _accesoDatos = accesoDatos
        End Sub

        Public Function RegistrarPreinscripcion(solicitud As RegistrarPreinscripcionFormRequest) As ApiResponse(Of ExpedienteResponseDTO) Implements IExpedienteColegiaturaServicio.RegistrarPreinscripcion
            Dim respuesta As New ApiResponse(Of ExpedienteResponseDTO)()

            ' 1. Verificación de Autorización
            If Not solicitud.Authorize() Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 403
                respuesta.Mensaje = "Operación no autorizada. Debe aceptar los términos y la Declaración Jurada institucional."
                Return respuesta
            End If

            ' 2. Verificación de Reglas de Validación
            Dim validacion As FormValidationResult = solicitud.Validar()
            If Not validacion.EsValido Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 400
                Dim listaErrores As New List(Of String)()
                For Each itemError As FormValidationError In validacion.Errores
                    listaErrores.Add($"{itemError.Campo}: {itemError.Mensaje}")
                Next
                respuesta.Mensaje = "Errores de validación en el expediente: " & String.Join(" | ", listaErrores)
                Return respuesta
            End If

            ' 3. Control de Duplicidad en Padrón (RN-COL-03)
            If _accesoDatos.ExistePostulantePorDni(solicitud.Dni) Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 409
                respuesta.Mensaje = $"El postulante con DNI {solicitud.Dni} ya cuenta con un legajo o matrícula activa en el CORLAD Junín."
                Return respuesta
            End If

            Try
                ' 4. Mapeo de Entidad Postulante
                Dim postulante As New PostulanteBE With {
                    .Dni = solicitud.Dni,
                    .ApellidoPaterno = solicitud.ApellidoPaterno,
                    .ApellidoMaterno = solicitud.ApellidoMaterno,
                    .Nombres = solicitud.Nombres,
                    .Sexo = solicitud.Sexo,
                    .EstadoCivil = solicitud.EstadoCivil,
                    .FechaNacimiento = solicitud.FechaNacimiento,
                    .Departamento = solicitud.Departamento,
                    .Provincia = solicitud.Provincia,
                    .Distrito = solicitud.Distrito,
                    .DireccionDetalle = solicitud.DireccionDetalle,
                    .Referencia = solicitud.Referencia,
                    .CorreoElectronico = solicitud.CorreoElectronico,
                    .Telefono = solicitud.Telefono
                }

                Dim entidadId As Integer = _accesoDatos.InsertarPersonaYPostulante(postulante)

                ' 5. Generación de Correlativo Oficial Inalterable (COL-YYYY-XXXXX)
                Dim anioActual As Integer = DateTime.Now.Year
                Dim numeroExpediente As String = _accesoDatos.ObtenerSiguienteCorrelativoExpediente(anioActual)

                ' 6. Mapeo de Título Profesional
                Dim titulo As New TituloProfesionalBE With {
                    .EntidadID = entidadId,
                    .UniversidadOrigen = solicitud.UniversidadOrigen,
                    .DenominacionTitulo = "LICENCIADO EN ADMINISTRACION",
                    .FechaExpedicion = solicitud.FechaExpedicionTitulo,
                    .CodigoRegistroSunedu = If(String.IsNullOrWhiteSpace(solicitud.CodigoRegistroSunedu), "PENDIENTE_VERIFICACION", solicitud.CodigoRegistroSunedu),
                    .VerificadoConSunedu = False
                }

                ' 7. Procesamiento y Cifrado Criptográfico de Archivos Adjuntos (SHA-256)
                Dim documentosFinales As New List(Of DocumentoExpedienteBE)()
                For Each doc In solicitud.ArchivosAdjuntos
                    Dim hashCalculado As String = CryptoHelper.CalcularSHA256($"{doc.NombreArchivo}_{DateTime.Now.Ticks}_{solicitud.Dni}")
                    documentosFinales.Add(New DocumentoExpedienteBE With {
                        .TipoDocumentoRequisito = doc.TipoDocumentoRequisito,
                        .NombreArchivo = doc.NombreArchivo,
                        .Extension = doc.Extension,
                        .RutaAlmacenamiento = $"expedientes/{anioActual}/{numeroExpediente}/{doc.NombreArchivo}",
                        .HashSHA256 = hashCalculado,
                        .TamanoBytes = doc.TamanoBytes,
                        .TipoMime = doc.TipoMime
                    })
                Next

                ' 8. Registro Atómico del Expediente Completo
                Dim expediente As New ExpedienteColegiaturaBE With {
                    .EntidadID = entidadId,
                    .NumeroExpediente = numeroExpediente,
                    .FechaPresentacion = DateTime.Now,
                    .EstadoRevision = "EN_REVISION",
                    .Observaciones = "Expediente generado vía Pre-inscripción web 24/7."
                }

                Dim expedienteId As Integer = _accesoDatos.RegistrarExpedienteCompleto(expediente, titulo, documentosFinales)

                ' 9. Preparación de Respuesta DTO Exitosa
                Dim dtoRespuesta As New ExpedienteResponseDTO With {
                    .ExpedienteID = expedienteId,
                    .NumeroExpediente = numeroExpediente,
                    .PostulanteDni = postulante.Dni,
                    .PostulanteNombreCompleto = $"{postulante.ApellidoPaterno} {postulante.ApellidoMaterno}, {postulante.Nombres}",
                    .FechaPresentacion = expediente.FechaPresentacion.ToString("dd/MM/yyyy HH:mm:ss"),
                    .EstadoRevision = expediente.EstadoRevision,
                    .CodigoSeguimiento = CryptoHelper.CalcularSHA256(numeroExpediente).Substring(0, 12).ToUpperInvariant(),
                    .DocumentosRegistrados = documentosFinales.Count,
                    .MensajeRespuesta = "Su solicitud de pre-inscripción ha sido registrada exitosamente en Mesa de Partes."
                }

                For Each d In documentosFinales
                    dtoRespuesta.DocumentosAdjuntos.Add(New DocumentoAdjuntoDTO With {
                        .TipoDocumento = d.TipoDocumentoRequisito,
                        .NombreArchivo = d.NombreArchivo,
                        .TamanoBytes = d.TamanoBytes,
                        .HashSHA256 = d.HashSHA256
                    })
                Next

                respuesta.Exito = True
                respuesta.CodigoEstado = 201
                respuesta.Mensaje = "Pre-inscripción de colegiatura procesada con éxito."
                respuesta.Datos = dtoRespuesta
                Return respuesta

            Catch ex As Exception
                respuesta.Exito = False
                respuesta.CodigoEstado = 500
                respuesta.Mensaje = $"Error interno al procesar el expediente de colegiatura: {ex.Message}"
                Return respuesta
            End Try
        End Function

        Public Function ConsultarEstadoExpediente(numeroExpediente As String, dni As String) As ApiResponse(Of ExpedienteResponseDTO) Implements IExpedienteColegiaturaServicio.ConsultarEstadoExpediente
            Dim respuesta As New ApiResponse(Of ExpedienteResponseDTO)()

            If String.IsNullOrWhiteSpace(numeroExpediente) Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 400
                respuesta.Mensaje = "El número de expediente es obligatorio para realizar el seguimiento."
                Return respuesta
            End If

            Dim expediente As ExpedienteColegiaturaBE = _accesoDatos.ObtenerExpedientePorNumero(numeroExpediente.Trim())
            If expediente Is Nothing Then
                respuesta.Exito = False
                respuesta.CodigoEstado = 404
                respuesta.Mensaje = $"No se encontró ningún expediente registrado con el número {numeroExpediente}."
                Return respuesta
            End If

            Dim documentos As List(Of DocumentoExpedienteBE) = _accesoDatos.ListarDocumentosPorExpedienteId(expediente.ExpedienteColegiaturaID)

            Dim dto As New ExpedienteResponseDTO With {
                .ExpedienteID = expediente.ExpedienteColegiaturaID,
                .NumeroExpediente = expediente.NumeroExpediente,
                .FechaPresentacion = expediente.FechaPresentacion.ToString("dd/MM/yyyy HH:mm:ss"),
                .EstadoRevision = expediente.EstadoRevision,
                .CodigoSeguimiento = CryptoHelper.CalcularSHA256(expediente.NumeroExpediente).Substring(0, 12).ToUpperInvariant(),
                .DocumentosRegistrados = documentos.Count,
                .MensajeRespuesta = $"Estado actual del expediente: {expediente.EstadoRevision}"
            }

            For Each doc In documentos
                dto.DocumentosAdjuntos.Add(New DocumentoAdjuntoDTO With {
                    .TipoDocumento = doc.TipoDocumentoRequisito,
                    .NombreArchivo = doc.NombreArchivo,
                    .TamanoBytes = doc.TamanoBytes,
                    .HashSHA256 = doc.HashSHA256
                })
            Next

            respuesta.Exito = True
            respuesta.CodigoEstado = 200
            respuesta.Mensaje = "Expediente consultado exitosamente."
            respuesta.Datos = dto
            Return respuesta
        End Function
    End Class
End Namespace
