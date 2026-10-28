import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import spawn from 'cross-spawn';
import { createApp } from '../src/app.js';

let server, base;
before(async () => {
  server = createApp().listen(0, '127.0.0.1');
  await once(server, 'listening');
  base = `http://127.0.0.1:${server.address().port}`;
});
after(() => new Promise(resolve => server.close(resolve)));

for (const [path, expected] of [
  ['/', { message: 'Pipeline DevSecOps' }],
  ['/health', { status: 'ok' }],
  ['/runtime', { node: process.version }],
]) {
  test(`GET ${path}`, async () => {
    const res = await fetch(base + path);
    assert.equal(res.status, 200);
    assert.equal(res.headers.get('x-content-type-options'), 'nosniff');
    assert.deepEqual(await res.json(), expected);
  });
}
test('rota inexistente retorna 404', async () => {
  const res = await fetch(base + '/inexistente');
  assert.equal(res.status, 404);
  assert.deepEqual(await res.json(), { error: 'Rota não encontrada' });
});
test('POST retorna 405 e informa GET', async () => {
  const res = await fetch(base, { method: 'POST' });
  assert.equal(res.status, 405);
  assert.equal(res.headers.get('allow'), 'GET');
});
test('falha ao obter runtime retorna 503', async t => {
  t.mock.method(spawn, 'sync', () => ({ status: 1 }));
  const res = await fetch(base + '/runtime');
  assert.equal(res.status, 503);
  assert.deepEqual(await res.json(), { error: 'Runtime indisponível' });
});
