import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '15s', target: 50 },  // Rampa a 50 usuarios directivos concurrentes
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
    'X-Usuario-Rol': 'ROL-DEC',
    'X-Usuario-Operador': 'DECANO_REGIONAL',
  };

  // 1. Simular consulta de bandeja de expedientes aprobados listos para matrícula
  const resAprobados = http.get(`${BASE_URL}/api/cli/matricula/aprobados?rol=ROL-DEC`, { headers });
  check(resAprobados, {
    'Aprobados: Status 200': (r) => r.status === 200,
    'Aprobados: P95 latencia < 200ms': (r) => r.timings.duration < 200,
  });

  // 2. Simular consulta de siguiente correlativo de matrícula
  const resCorrelativo = http.get(`${BASE_URL}/api/cli/matricula/siguiente-correlativo?rol=ROL-DEC`, { headers });
  check(resCorrelativo, {
    'Correlativo: Status 200': (r) => r.status === 200,
    'Correlativo: Respuesta válida': (r) => {
      try {
        const b = JSON.parse(r.body);
        return b.exito === true && b.datos.startsWith('CORLAD-JUN-');
      } catch (e) {
        return false;
      }
    },
  });

  // 3. Simular consulta de Carnet Oficial Digital
  const resCarnet = http.get(`${BASE_URL}/api/cli/matricula/carnet/1?rol=ROL-DEC`, { headers });
  check(resCarnet, {
    'Carnet: Status 200 o 404': (r) => r.status === 200 || r.status === 404,
  });

  sleep(1);
}
