import apiClient from '../../../services/apiClient';

/**
 * Servicio API para la Asignación de Matrícula Regional y Emisión de Carnet Oficial (CU-COL-03).
 * Conecta directamente a los endpoints REST del backend CORLAD.API en VB.NET.
 */
export const matriculaApi = {
  /**
   * Obtiene la lista de expedientes aprobados pendientes de asignación de matrícula.
   * @param {string} rol Rol del usuario autenticado (default: 'ROL-DEC')
   * @returns {Promise<Object>} ApiResponse con lista de ExpedienteAprobadoDTO
   */
  obtenerAprobados: async (rol = 'ROL-DEC') => {
    return await apiClient.get('/api/cli/matricula/aprobados', {
      params: { rol },
    });
  },

  /**
   * Obtiene el siguiente correlativo oficial sugerido (CORLAD-JUN-XXXXX).
   * @param {string} rol Rol del usuario autenticado (default: 'ROL-DEC')
   * @returns {Promise<Object>} ApiResponse con string del correlativo
   */
  obtenerSiguienteCorrelativo: async (rol = 'ROL-DEC') => {
    return await apiClient.get('/api/cli/matricula/siguiente-correlativo', {
      params: { rol },
    });
  },

  /**
   * Formaliza el alta en el padrón regional, asigna la matrícula y genera el carnet digital.
   * @param {Object} payload AsignarMatriculaFormRequest
   * @param {string} rol Rol del usuario (default: 'ROL-DEC')
   * @param {string} usuarioOperador Usuario que ejecuta el alta
   * @returns {Promise<Object>} ApiResponse con CarnetColegiadoDTO
   */
  asignarMatricula: async (payload, rol = 'ROL-DEC', usuarioOperador = 'DECANO_REGIONAL') => {
    return await apiClient.post('/api/cli/matricula/asignar', payload, {
      params: { rol, usuarioOperador },
    });
  },

  /**
   * Obtiene los datos del carnet digital oficial por ColegiadoID.
   * @param {number} colegiadoId ID del colegiado
   * @param {string} rol Rol del usuario (default: 'ROL-DEC')
   * @returns {Promise<Object>} ApiResponse con CarnetColegiadoDTO
   */
  obtenerCarnetPorId: async (colegiadoId, rol = 'ROL-DEC') => {
    return await apiClient.get(`/api/cli/matricula/carnet/${colegiadoId}`, {
      params: { rol },
    });
  },

  /**
   * Obtiene los datos del carnet digital oficial por ExpedienteColegiaturaID.
   * @param {number} expedienteId ID del expediente
   * @param {string} rol Rol del usuario (default: 'ROL-DEC')
   * @returns {Promise<Object>} ApiResponse con CarnetColegiadoDTO
   */
  obtenerCarnetPorExpediente: async (expedienteId, rol = 'ROL-DEC') => {
    return await apiClient.get(`/api/cli/matricula/carnet/expediente/${expedienteId}`, {
      params: { rol },
    });
  },
};

export default matriculaApi;
