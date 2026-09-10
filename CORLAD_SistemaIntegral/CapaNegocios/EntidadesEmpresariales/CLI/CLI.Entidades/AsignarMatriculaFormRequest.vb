Imports System
Imports System.Collections.Generic

Namespace CLI.Entidades
    ''' <summary>
    ''' FormRequest de Entrada con validación y autorización RBAC para formalizar la matrícula regional y expedir el carnet (CU-COL-03).
    ''' </summary>
    Public Class AsignarMatriculaFormRequest
        Public Property ExpedienteColegiaturaID As Integer
        Public Property MatriculaRegional As String
        Public Property MatriculaNacional As String
        Public Property NumeroResolucionIncorporacion As String
        Public Property FechaJuramentacion As Date = DateTime.Today
        Public Property CondicionColegiado As String = "ORDINARIO"
        Public Property Observaciones As String

        ''' <summary>
        ''' Control de Acceso RBAC: Solo roles ejecutivos y directivos pueden formalizar matriculación de colegiados.
        ''' </summary>
        Public Function Authorize(rolUsuario As String) As Boolean
            If String.IsNullOrWhiteSpace(rolUsuario) Then Return False
            Dim rolUpper = rolUsuario.Trim().ToUpperInvariant()

            ' Roles autorizados: Decano Regional (ROL-DEC), Secretaria Regional (ROL-SEC), Administrador (ADMIN)
            Return rolUpper = "ROL-DEC" OrElse rolUpper = "ROL-SEC" OrElse rolUpper = "ADMIN"
        End Function

        ''' <summary>
        ''' Valida rigurosamente los campos del formulario según las reglas institucionales (RN-COL-03).
        ''' </summary>
        Public Function Validar() As FormValidationResult
            Dim resultado As New FormValidationResult()

            ' Sanitización
            MatriculaRegional = If(MatriculaRegional, String.Empty).Trim().ToUpperInvariant()
            MatriculaNacional = If(MatriculaNacional, String.Empty).Trim().ToUpperInvariant()
            NumeroResolucionIncorporacion = If(NumeroResolucionIncorporacion, String.Empty).Trim().ToUpperInvariant()
            CondicionColegiado = If(CondicionColegiado, "ORDINARIO").Trim().ToUpperInvariant()
            Observaciones = If(Observaciones, String.Empty).Trim()

            ' 1. Validar Expediente
            If ExpedienteColegiaturaID <= 0 Then
                resultado.AgregarError("ExpedienteColegiaturaID", "El identificador del expediente es inválido o no fue especificado.")
            End If

            ' 2. Validar Matrícula Regional
            If String.IsNullOrWhiteSpace(MatriculaRegional) Then
                resultado.AgregarError("MatriculaRegional", "El número de Matrícula Regional es obligatorio.")
            ElseIf MatriculaRegional.Length < 3 OrElse MatriculaRegional.Length > 20 Then
                resultado.AgregarError("MatriculaRegional", "El formato de Matrícula Regional debe tener entre 3 y 20 caracteres.")
            End If

            ' 3. Validar Resolución Decanal
            If String.IsNullOrWhiteSpace(NumeroResolucionIncorporacion) Then
                resultado.AgregarError("NumeroResolucionIncorporacion", "El número de Resolución Decanal de Incorporación es mandatorio.")
            ElseIf NumeroResolucionIncorporacion.Length < 5 OrElse NumeroResolucionIncorporacion.Length > 50 Then
                resultado.AgregarError("NumeroResolucionIncorporacion", "La resolución debe tener una longitud de entre 5 y 50 caracteres (ej. RES-DEC-045-2026-CORLAD-JUN).")
            End If

            ' 4. Validar Fecha de Juramentación
            If FechaJuramentacion = Date.MinValue Then
                resultado.AgregarError("FechaJuramentacion", "La fecha de juramentación protocolar es obligatoria.")
            ElseIf FechaJuramentacion > DateTime.Today.AddYears(1) Then
                resultado.AgregarError("FechaJuramentacion", "La fecha de juramentación no puede exceder más de 1 año al futuro.")
            End If

            ' 5. Validar Condición de Colegiado
            If CondicionColegiado <> "ORDINARIO" AndAlso CondicionColegiado <> "VITALICIO" AndAlso CondicionColegiado <> "HONORARIO" Then
                resultado.AgregarError("CondicionColegiado", "La condición debe ser 'ORDINARIO', 'VITALICIO' o 'HONORARIO'.")
            End If

            Return resultado
        End Function
    End Class
End Namespace
