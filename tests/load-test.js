import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    load_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 50 },
        { duration: '30s', target: 50 },
        { duration: '5s', target: 0 },
      ],
      gracefulRampDown: '5s',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.05'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function loadTest() {
  const response = http.get(`${BASE_URL}/api/v1/heavy-process`);

  check(response, {
    'status es 200': (r) => r.status === 200,
    'latencia entre 400-600ms (ideal)': (r) => r.timings.duration >= 400 && r.timings.duration <= 600,
    'latencia bajo umbral 2000ms': (r) => r.timings.duration < 2000,
  });

  sleep(0.1);
}
