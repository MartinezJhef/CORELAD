Imports System
Imports System.Collections.Generic
Imports CLI.Entidades

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de persistencia para expedientes de colegiatura en Capa de Acceso a Datos.
    ''' </summary>
    Public Interface IExpedienteColegiaturaAccesoDatos
        Function ExistePostulantePorDni(dni As String) As Boolean
        Function ObtenerSiguienteCorrelativoExpediente(anio As Integer) As String
        Function InsertarPersonaYPostulante(postulante As PostulanteBE) As Integer
        Function RegistrarExpedienteCompleto(expediente As ExpedienteColegiaturaBE, titulo As TituloProfesionalBE, documentos As List(Of DocumentoExpedienteBE)) As Integer
        Function ObtenerExpedientePorId(expedienteId As Integer) As ExpedienteColegiaturaBE
        Function ObtenerExpedientePorNumero(numeroExpediente As String) As ExpedienteColegiaturaBE
        Function ListarDocumentosPorExpedienteId(expedienteId As Integer) As List(Of DocumentoExpedienteBE)
    End Interface
End Namespace
