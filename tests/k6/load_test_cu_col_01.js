import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '20s', target: 50 },  // Rampa inicial a 50 postulantes simultáneos
    { duration: '40s', target: 200 }, // Carga sostenida de 200 usuarios concurrentes
    { duration: '20s', target: 0 },   // Rampa descendente
  ],
  thresholds: {
    // 95% de las solicitudes deben completarse en menos de 200 ms (criterio normativo CORLAD)
    http_req_duration: ['p(95)<200'],
    // Tasa de fallos menor al 0.5%
    http_req_failed: ['rate<0.005'],
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:5000';

export default function () {
  // 1. Simular consulta de seguimiento de expediente
  const resSeguimiento = http.get(`${BASE_URL}/api/cli/colegiatura/seguimiento?numeroExpediente=COL-2026-00001`);
  check(resSeguimiento, {
    'Seguimiento: Status es 200 o 404 controlado': (r) => r.status === 200 || r.status === 404,
    'Seguimiento: P95 latencia < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1);
}
