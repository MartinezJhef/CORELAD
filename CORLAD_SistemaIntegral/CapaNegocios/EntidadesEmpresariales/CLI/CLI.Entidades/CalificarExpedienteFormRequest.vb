Imports System
Imports System.Collections.Generic

Namespace CLI.Entidades
    ''' <summary>
    ''' FormRequest de Entrada con validación y autorización RBAC para emitir Dictamen Técnico sobre un expediente de colegiatura.
    ''' </summary>
    Public Class CalificarExpedienteFormRequest
        Public Property ExpedienteId As Integer
        Public Property NumeroExpediente As String
        Public Property Dictamen As String ' "APROBADO", "OBSERVADO", "RECHAZADO"
        Public Property MotivoObservacion As String
        Public Property ValidadoSunedu As Boolean
        Public Property CodigoRegistroSunedu As String
        Public Property ObservacionesDocumentos As New List(Of DocumentoObservacionDTO)()

        ''' <summary>
        ''' Control de Acceso RBAC: Solo roles administrativos autorizados pueden calificar expedientes.
        ''' </summary>
        Public Function Authorize(rolUsuario As String) As Boolean
            If String.IsNullOrWhiteSpace(rolUsuario) Then Return False
            Dim rolUpper = rolUsuario.Trim().ToUpperInvariant()

            ' Roles autorizados: Secretaria Regional, Gerente Regional, Decano Regional o Administrador
            Return rolUpper = "ROL-SEC" OrElse rolUpper = "ROL-GER" OrElse rolUpper = "ROL-DEC" OrElse rolUpper = "ADMIN"
        End Function

        ''' <summary>
        ''' Validación estricta de las reglas de calificación técnica según el ERS (RN-COL-02).
        ''' </summary>
        Public Function Validar() As FormValidationResult
            Dim resultado As New FormValidationResult()

            ' Sanitización
            NumeroExpediente = If(NumeroExpediente, String.Empty).Trim().ToUpperInvariant()
            Dictamen = If(Dictamen, String.Empty).Trim().ToUpperInvariant()
            MotivoObservacion = If(MotivoObservacion, String.Empty).Trim()
            CodigoRegistroSunedu = If(CodigoRegistroSunedu, String.Empty).Trim().ToUpperInvariant()

            ' 1. Validar Expediente
            If ExpedienteId <= 0 Then
                resultado.AgregarError("ExpedienteId", "El identificador del expediente es inválido.")
            End If

            ' 2. Validar Dictamen
            If String.IsNullOrWhiteSpace(Dictamen) Then
                resultado.AgregarError("Dictamen", "El dictamen de calificación es obligatorio.")
            ElseIf Dictamen <> "APROBADO" AndAlso Dictamen <> "OBSERVADO" AndAlso Dictamen <> "RECHAZADO" Then
                resultado.AgregarError("Dictamen", "El dictamen debe ser 'APROBADO', 'OBSERVADO' o 'RECHAZADO'.")
            End If

            ' 3. Regla RN-COL-02: Para dictamen APROBADO, el título debe haber sido validado positivamente con SUNEDU
            If Dictamen = "APROBADO" AndAlso Not ValidadoSunedu Then
                resultado.AgregarError("ValidadoSunedu", "No procede la aprobación del expediente sin la verificación positiva del título en SUNEDU (Ley 31060).")
            End If

            ' 4. Si el dictamen es OBSERVADO o RECHAZADO, el motivo es obligatorio
            If (Dictamen = "OBSERVADO" OrElse Dictamen = "RECHAZADO") AndAlso String.IsNullOrWhiteSpace(MotivoObservacion) Then
                resultado.AgregarError("MotivoObservacion", "Debe consignar el motivo detallado de la observación o rechazo para notificar al postulante.")
            End If

            Return resultado
        End Function
    End Class

    ''' <summary>
    ''' Detalle de observación para un requisito específico.
    ''' </summary>
    Public Class DocumentoObservacionDTO
        Public Property DocumentoId As Integer
        Public Property CodigoTipoDocumento As String
        Public Property EsConforme As Boolean = True
        Public Property Observacion As String
    End Class
End Namespace
