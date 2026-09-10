Imports System
Imports System.Collections.Generic
Imports System.Text.RegularExpressions

Namespace CLI.Entidades
    ''' <summary>
    ''' Resultado estructurado de validación para FormRequests.
    ''' </summary>
    Public Class FormValidationResult
        Public Property EsValido As Boolean = True
        Public Property Errores As New List(Of FormValidationError)()

        Public ReadOnly Property PrimerMensajeError As String
            Get
                Return If(Errores.Count > 0, Errores(0).Mensaje, String.Empty)
            End Get
        End Property

        Public Sub AgregarError(campo As String, mensaje As String)
            EsValido = False
            Errores.Add(New FormValidationError With {.Campo = campo, .Mensaje = mensaje})
        End Sub
    End Class

    Public Class FormValidationError
        Public Property Campo As String
        Public Property Mensaje As String
    End Class

    ''' <summary>
    ''' FormRequest de Entrada con validación estricta y autorización para el registro de Preinscripción de Colegiatura.
    ''' </summary>
    Public Class RegistrarPreinscripcionFormRequest
        Public Property Dni As String
        Public Property ApellidoPaterno As String
        Public Property ApellidoMaterno As String
        Public Property Nombres As String
        Public Property Sexo As String = "M"
        Public Property EstadoCivil As String = "S"
        Public Property FechaNacimiento As Date
        Public Property Departamento As String = "JUNIN"
        Public Property Provincia As String = "HUANCAYO"
        Public Property Distrito As String = "HUANCAYO"
        Public Property DireccionDetalle As String
        Public Property Referencia As String
        Public Property CorreoElectronico As String
        Public Property Telefono As String
        Public Property UniversidadOrigen As String
        Public Property FechaExpedicionTitulo As Date
        Public Property CodigoRegistroSunedu As String
        Public Property DeclaracionJuradaAceptada As Boolean = False
        Public Property ArchivosAdjuntos As New List(Of DocumentoExpedienteBE)()

        ''' <summary>
        ''' Valida si la solicitud está autorizada para procesarse.
        ''' Al ser un trámite de preinscripción público, se autoriza si acepta la declaración jurada y no tiene bloqueos.
        ''' </summary>
        Public Function Authorize(Optional rolUsuario As String = Nothing) As Boolean
            ' El trámite de colegiatura es un canal abierto para licenciados postulantes
            ' Requiere aceptación expresa de la declaración jurada de veracidad institucional
            Return DeclaracionJuradaAceptada
        End Function

        ''' <summary>
        ''' Sanitiza y valida exhaustivamente todos los campos del formulario conforme a las reglas RN-COL-01 y RN-COL-02.
        ''' </summary>
        Public Function Validar() As FormValidationResult
            Dim resultado As New FormValidationResult()

            ' 1. Sanitización de entradas
            Dni = If(Dni, String.Empty).Trim()
            ApellidoPaterno = If(ApellidoPaterno, String.Empty).Trim().ToUpperInvariant()
            ApellidoMaterno = If(ApellidoMaterno, String.Empty).Trim().ToUpperInvariant()
            Nombres = If(Nombres, String.Empty).Trim().ToUpperInvariant()
            CorreoElectronico = If(CorreoElectronico, String.Empty).Trim().ToLowerInvariant()
            Telefono = If(Telefono, String.Empty).Trim()
            UniversidadOrigen = If(UniversidadOrigen, String.Empty).Trim().ToUpperInvariant()
            CodigoRegistroSunedu = If(CodigoRegistroSunedu, String.Empty).Trim().ToUpperInvariant()
            DireccionDetalle = If(DireccionDetalle, String.Empty).Trim()

            ' 2. Validación de DNI (Exactamente 8 dígitos numéricos)
            If String.IsNullOrWhiteSpace(Dni) Then
                resultado.AgregarError("Dni", "El Documento Nacional de Identidad (DNI) es obligatorio.")
            ElseIf Not Regex.IsMatch(Dni, "^\d{8}$") Then
                resultado.AgregarError("Dni", "El DNI debe contener exactamente 8 dígitos numéricos.")
            End If

            ' 3. Validación de Nombres y Apellidos
            If String.IsNullOrWhiteSpace(ApellidoPaterno) Then
                resultado.AgregarError("ApellidoPaterno", "El apellido paterno es obligatorio.")
            End If
            If String.IsNullOrWhiteSpace(ApellidoMaterno) Then
                resultado.AgregarError("ApellidoMaterno", "El apellido materno es obligatorio.")
            End If
            If String.IsNullOrWhiteSpace(Nombres) Then
                resultado.AgregarError("Nombres", "Los nombres completos son obligatorios.")
            End If

            ' 4. Validación de Correo Electrónico (Formato RFC)
            If String.IsNullOrWhiteSpace(CorreoElectronico) Then
                resultado.AgregarError("CorreoElectronico", "El correo electrónico es obligatorio para remitir credenciales y notificaciones.")
            ElseIf Not Regex.IsMatch(CorreoElectronico, "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$") Then
                resultado.AgregarError("CorreoElectronico", "El formato del correo electrónico no es válido.")
            End If

            ' 5. Validación de Teléfono (9 dígitos peruanos)
            If Not String.IsNullOrWhiteSpace(Telefono) AndAlso Not Regex.IsMatch(Telefono, "^\d{9}$") Then
                resultado.AgregarError("Telefono", "El teléfono celular debe contener 9 dígitos numéricos.")
            End If

            ' 6. Validación de Datos Universitarios
            If String.IsNullOrWhiteSpace(UniversidadOrigen) Then
                resultado.AgregarError("UniversidadOrigen", "La universidad de egreso es obligatoria.")
            End If
            If FechaExpedicionTitulo = Date.MinValue OrElse FechaExpedicionTitulo > Date.Today Then
                resultado.AgregarError("FechaExpedicionTitulo", "La fecha de expedición del título profesional debe ser una fecha válida anterior a hoy.")
            End If

            ' 7. Validación de Declaración Jurada
            If Not DeclaracionJuradaAceptada Then
                resultado.AgregarError("DeclaracionJuradaAceptada", "Debe aceptar la Declaración Jurada de veracidad de la información y requisitos presentados.")
            End If

            ' 8. Validación de Requisitos Documentarios (RN-COL-01 y RN-COL-02)
            Const MaxBytesPermitidos As Long = 5 * 1024 * 1024 ' 5 MB máximo por archivo
            Dim tiposRequeridos As New HashSet(Of String)(StringComparer.OrdinalIgnoreCase) From {
                "DNI", "TITULO", "ANTECEDENTES", "FOTO", "VOUCHER"
            }

            If ArchivosAdjuntos Is Nothing OrElse ArchivosAdjuntos.Count = 0 Then
                resultado.AgregarError("ArchivosAdjuntos", "Debe adjuntar los 5 requisitos obligatorios para formalizar el expediente de colegiatura.")
            Else
                Dim tiposPresentados As New HashSet(Of String)(StringComparer.OrdinalIgnoreCase)
                For Each doc In ArchivosAdjuntos
                    tiposPresentados.Add(doc.TipoDocumentoRequisito)

                    ' Validación de tamaño
                    If doc.TamanoBytes > MaxBytesPermitidos Then
                        resultado.AgregarError("ArchivosAdjuntos", $"El archivo '{doc.NombreArchivo}' excede el límite máximo institucional de 5 MB.")
                    End If

                    ' Validación de extensión
                    Dim ext As String = If(doc.Extension, String.Empty).Trim().ToLowerInvariant()
                    If ext <> ".pdf" AndAlso ext <> ".jpg" AndAlso ext <> ".jpeg" AndAlso ext <> ".png" Then
                        resultado.AgregarError("ArchivosAdjuntos", $"El archivo '{doc.NombreArchivo}' tiene un formato no permitido. Solo se admite PDF, JPG o PNG.")
                    End If
                Next

                For Each tipoReq In tiposRequeridos
                    If Not tiposPresentados.Contains(tipoReq) Then
                        resultado.AgregarError("ArchivosAdjuntos", $"Falta adjuntar el documento obligatorio correspondiente a: {tipoReq}.")
                    End If
                Next
            End If

            Return resultado
        End Function
    End Class
End Namespace
