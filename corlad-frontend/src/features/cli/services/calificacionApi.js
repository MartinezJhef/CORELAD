import apiClient from '../../../services/apiClient';

/**
 * Servicio API para la Calificación de Expedientes y Verificación SUNEDU (CU-COL-02).
 * Conecta directamente a los endpoints REST del backend CORLAD.API en VB.NET.
 */
export const calificacionApi = {
  /**
   * Obtiene la lista de expedientes pendientes de calificación técnica para la Secretaría Regional.
   * @param {string} rol Rol del usuario autenticado (default: 'ROL-SEC')
   * @returns {Promise<Object>} ApiResponse con lista de ExpedientePendienteDTO
   */
  obtenerPendientes: async (rol = 'ROL-SEC') => {
    return await apiClient.get('/api/cli/calificacion/pendientes', {
      params: { rol },
    });
  },

  /**
   * Obtiene el legajo detallado de un expediente para auditoría documental.
   * @param {number} expedienteId ID del expediente de colegiatura
   * @param {string} rol Rol del usuario autenticado
   * @returns {Promise<Object>} ApiResponse con ExpedienteDetalleAuditoriaDTO
   */
  obtenerDetalle: async (expedienteId, rol = 'ROL-SEC') => {
    return await apiClient.get(`/api/cli/calificacion/detalle/${expedienteId}`, {
      params: { rol },
    });
  },

  /**
   * Consulta el título profesional ante el Registro Nacional de Grados y Títulos de SUNEDU.
   * @param {Object} payload { dni, codigoRegistroSunedu }
   * @returns {Promise<Object>} ApiResponse con ValidacionSuneduResponseDTO
   */
  verificarSunedu: async ({ dni, codigoRegistroSunedu }) => {
    return await apiClient.post('/api/cli/calificacion/verificar-sunedu', {
      dni,
      codigoRegistroSunedu,
    });
  },

  /**
   * Procesa el dictamen de calificación técnica (APROBADO, OBSERVADO o RECHAZADO).
   * @param {Object} payload CalificarExpedienteFormRequest
   * @param {string} rol Rol del auditor (default: 'ROL-SEC')
   * @param {string} usuarioAuditor Nombre/código del auditor
   * @returns {Promise<Object>} ApiResponse con boolean
   */
  dictaminarExpediente: async (payload, rol = 'ROL-SEC', usuarioAuditor = 'SECRETARIA_REGIONAL') => {
    return await apiClient.post('/api/cli/calificacion/dictaminar', payload, {
      headers: {
        'X-Usuario-Rol': rol,
        'X-Usuario-Auditor': usuarioAuditor,
      },
    });
  },
};

export default calificacionApi;
