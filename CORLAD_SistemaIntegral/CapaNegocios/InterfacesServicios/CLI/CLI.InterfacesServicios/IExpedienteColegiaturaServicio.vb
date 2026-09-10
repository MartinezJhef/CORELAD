Imports System
Imports CLI.Entidades
Imports GEN.Infraestructura

Namespace CLI.InterfacesServicios
    ''' <summary>
    ''' Contrato de lógica de negocio y orquestación del flujo de colegiatura.
    ''' </summary>
    Public Interface IExpedienteColegiaturaServicio
        Function RegistrarPreinscripcion(solicitud As RegistrarPreinscripcionFormRequest) As ApiResponse(Of ExpedienteResponseDTO)
        Function ConsultarEstadoExpediente(numeroExpediente As String, dni As String) As ApiResponse(Of ExpedienteResponseDTO)
    End Interface
End Namespace
