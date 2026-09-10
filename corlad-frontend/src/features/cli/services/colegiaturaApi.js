import apiClient from '../../../services/apiClient';

export const colegiaturaApi = {
  /**
   * Registra la solicitud de pre-inscripción y carga de documentos
   * @param {Object} payload 
   * @returns {Promise<Object>} ApiResponse con ExpedienteResponseDTO
   */
  registrarPreinscripcion: async (payload) => {
    return await apiClient.post('/api/cli/colegiatura/preinscripcion', payload);
  },

  /**
   * Consulta el estado de un expediente por su número institucional (ej. COL-2026-00001)
   * @param {string} numeroExpediente 
   * @returns {Promise<Object>} ApiResponse con ExpedienteResponseDTO
   */
  consultarSeguimiento: async (numeroExpediente) => {
    return await apiClient.get('/api/cli/colegiatura/seguimiento', {
      params: { numeroExpediente },
    });
  },
};

export default colegiaturaApi;
