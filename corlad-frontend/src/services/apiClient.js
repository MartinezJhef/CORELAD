import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  timeout: 30000,
});

// Interceptor para inyectar token JWT si existe en sesión
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('corlad_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para normalizar respuestas de ApiResponse(Of T)
apiClient.interceptors.response.use(
  (response) => {
    // Si la respuesta envuelve con ApiResponse de VB.NET
    return response.data;
  },
  (error) => {
    const errorResponse = error.response?.data || {
      exito: false,
      mensaje: error.message || 'Error de conexión con el servidor del CORLAD Junín',
      codigoEstado: error.response?.status || 500,
      erroresValidacion: [],
    };
    return Promise.reject(errorResponse);
  }
);

export default apiClient;
