const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { after, before, test } = require('node:test');

const databaseDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'inventario-api-'));
process.env.DB_STORAGE = path.join(databaseDirectory, 'test.sqlite');
process.env.PORT = '0';

const { iniciarServidor } = require('../server');
const { sequelize } = require('../db');

let server;
let baseUrl;

before(async () => {
  server = await iniciarServidor();
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}/api/productos`;
});

after(async () => {
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  await sequelize.close();
  fs.rmSync(databaseDirectory, { recursive: true, force: true });
});

test('performs persistent product CRUD and returns validation errors', async () => {
  const seeded = await fetch(baseUrl);
  assert.equal((await seeded.json()).length, 10);

  const invalid = await fetch(baseUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ nombre: 'Incompleto' }),
  });
  assert.equal(invalid.status, 422);

  const payload = {
    nombre: 'Producto de prueba',
    codigo: 'TEST-001',
    descripcion: 'Registro de integración',
    precio: 1250.5,
    cantidad: 4,
    categoria: 'Pruebas',
  };
  const createdResponse = await fetch(baseUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  assert.equal(createdResponse.status, 201);
  const created = await createdResponse.json();

  const duplicate = await fetch(baseUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  assert.equal(duplicate.status, 422);

  const listed = await fetch(baseUrl);
  assert.equal(listed.status, 200);
  assert.equal((await listed.json()).some((product) => product.codigo === payload.codigo), true);

  const updatedResponse = await fetch(`${baseUrl}/${created.id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...payload, nombre: 'Producto actualizado', cantidad: 9 }),
  });
  assert.equal(updatedResponse.status, 200);
  assert.equal((await updatedResponse.json()).nombre, 'Producto actualizado');

  await new Promise((resolve, reject) =>
    server.close((error) => error ? reject(error) : resolve()),
  );
  server = await iniciarServidor();
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}/api/productos`;

  const detail = await fetch(`${baseUrl}/${created.id}`);
  assert.equal((await detail.json()).cantidad, 9);

  const deleted = await fetch(`${baseUrl}/${created.id}`, { method: 'DELETE' });
  assert.equal(deleted.status, 200);
  assert.equal((await fetch(`${baseUrl}/${created.id}`)).status, 404);
});
