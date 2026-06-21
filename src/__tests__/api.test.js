const test = require('node:test');
const assert = require('node:assert/strict');

const { createApp } = require('../app');
const { pool, initSchema } = require('../db');

let server;
let baseUrl;

test.before(async () => {
  await initSchema();
  await pool.query('DELETE FROM tasks');

  const app = createApp();
  await new Promise((resolve) => {
    server = app.listen(0, () => {
      const { port } = server.address();
      baseUrl = `http://127.0.0.1:${port}`;
      resolve();
    });
  });
});

test.after(async () => {
  await new Promise((resolve) => server.close(resolve));
  await pool.end();
});

test('GET /health returns ok', async () => {
  const res = await fetch(`${baseUrl}/health`);
  assert.equal(res.status, 200);
  assert.deepEqual(await res.json(), { status: 'ok' });
});

test('POST /tasks creates a task', async () => {
  const res = await fetch(`${baseUrl}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: 'write tests' }),
  });
  assert.equal(res.status, 201);
  const body = await res.json();
  assert.equal(body.title, 'write tests');
  assert.equal(body.done, false);
  assert.ok(Number.isInteger(body.id));
});

test('POST /tasks rejects missing title', async () => {
  const res = await fetch(`${baseUrl}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
  assert.equal(res.status, 400);
});

test('GET /tasks lists tasks', async () => {
  const res = await fetch(`${baseUrl}/tasks`);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.ok(Array.isArray(body));
  assert.ok(body.length >= 1);
});

test('PUT /tasks/:id marks done', async () => {
  const created = await (
    await fetch(`${baseUrl}/tasks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'temp' }),
    })
  ).json();

  const res = await fetch(`${baseUrl}/tasks/${created.id}`, { method: 'PUT' });
  assert.equal(res.status, 200);
  assert.equal((await res.json()).done, true);
});

test('DELETE /tasks/:id removes a task', async () => {
  const created = await (
    await fetch(`${baseUrl}/tasks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'doomed' }),
    })
  ).json();

  const res = await fetch(`${baseUrl}/tasks/${created.id}`, { method: 'DELETE' });
  assert.equal(res.status, 204);

  const lookup = await fetch(`${baseUrl}/tasks/${created.id}`, { method: 'PUT' });
  assert.equal(lookup.status, 404);
});
