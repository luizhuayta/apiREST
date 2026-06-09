import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    stress_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '15s', target: 50 },
        { duration: '15s', target: 100 },
        { duration: '15s', target: 200 },
        { duration: '15s', target: 300 },
        { duration: '15s', target: 400 },
      ],
      gracefulRampDown: '10s',
    },
  },
  thresholds: {
    http_req_failed: [{ threshold: 'rate<0.05', abortOnFail: true, delayAbortEval: '10s' }],
    http_req_duration: ['p(95)<10000'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function stressTest() {
  const response = http.get(`${BASE_URL}/api/v1/heavy-process`, {
    timeout: '10s',
  });

  check(response, {
    'status es 200': (r) => r.status === 200,
    'sin timeout': (r) => r.status !== 0,
  });
}
