import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '15s', target: 50 },  // Rampa a 50 evaluadores concurrentes
    { duration: '30s', target: 200 }, // Carga sostenida de 200 solicitudes simultáneas
    { duration: '15s', target: 0 },   // Rampa descendente
  ],
  thresholds: {
    // Percentil 95 debe responder en menos de 200 ms (criterio normativo institucional)
    http_req_duration: ['p(95)<200'],
    // Tasa de fallos menor al 0.5%
    http_req_failed: ['rate<0.005'],
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:5000';

export default function () {
  const headers = {
    'Content-Type': 'application/json',
    'X-Usuario-Rol': 'ROL-SEC',
    'X-Usuario-Auditor': 'SECRETARIA_REGIONAL',
  };

  // 1. Simular consulta de bandeja de expedientes pendientes
  const resBandeja = http.get(`${BASE_URL}/api/cli/calificacion/pendientes?rol=ROL-SEC`, { headers });
  check(resBandeja, {
    'Bandeja: Status 200': (r) => r.status === 200,
    'Bandeja: P95 latencia < 200ms': (r) => r.timings.duration < 200,
  });

  // 2. Simular consulta de legajo documental para auditoría
  const resDetalle = http.get(`${BASE_URL}/api/cli/calificacion/detalle/1?rol=ROL-SEC`, { headers });
  check(resDetalle, {
    'Detalle: Status 200 o 404': (r) => r.status === 200 || r.status === 404,
  });

  // 3. Simular contrastación en tiempo real con SUNEDU vía PIDE
  const payloadSunedu = JSON.stringify({
    dni: '72345678',
    codigoRegistroSunedu: 'SUN-2024-UNCP-001',
  });

  const resSunedu = http.post(`${BASE_URL}/api/cli/calificacion/verificar-sunedu`, payloadSunedu, { headers });
  check(resSunedu, {
    'SUNEDU: Status 200': (r) => r.status === 200,
    'SUNEDU: Respuesta contiene validación': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.exito === true;
      } catch (e) {
        return false;
      }
    },
  });

  sleep(1);
}
