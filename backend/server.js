require('dotenv').config({ path: require('node:path').join(__dirname, '.env') });

const express = require('express');
const cors = require('cors');
const { Op } = require('sequelize');
const { sequelize, Producto } = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

function validar(body) {
  const errores = {};
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { body: 'El cuerpo debe ser un objeto JSON' };
  }
  if (!body.nombre || !String(body.nombre).trim()) errores.nombre = 'El nombre es obligatorio';
  if (!body.codigo || !String(body.codigo).trim()) errores.codigo = 'El código es obligatorio';
  if (!body.categoria || !String(body.categoria).trim()) errores.categoria = 'La categoría es obligatoria';
  if (body.precio === undefined || body.precio === null || body.precio === '' ||
      !Number.isFinite(Number(body.precio)) || Number(body.precio) < 0)
    errores.precio = 'El precio debe ser un número mayor o igual a 0';
  if (body.cantidad === undefined || body.cantidad === null || body.cantidad === '' ||
      !Number.isInteger(Number(body.cantidad)) || Number(body.cantidad) < 0)
    errores.cantidad = 'La cantidad debe ser un entero mayor o igual a 0';
  return errores;
}

function datosLimpios(b) {
  return {
    nombre: String(b.nombre).trim(),
    codigo: String(b.codigo).trim(),
    descripcion: b.descripcion ? String(b.descripcion).trim() : null,
    precio: Number(b.precio),
    cantidad: Number(b.cantidad),
    categoria: String(b.categoria).trim(),
  };
}

const error422 = (res, errors) =>
  res.status(422).json({ message: 'Datos inválidos', errors });

function idValido(id) {
  const parsed = Number(id);
  return /^\d+$/.test(id) && Number.isSafeInteger(parsed) && parsed > 0;
}

function responderError(res, error) {
  console.error(error);
  if (error.name === 'SequelizeUniqueConstraintError') {
    return error422(res, { codigo: 'El código ya existe' });
  }
  return res.status(500).json({ message: 'Error interno del servidor' });
}

// GET todos
app.get('/api/productos', async (req, res) => {
  try {
    const productos = await Producto.findAll({ order: [['id', 'DESC']] });
    res.status(200).json(productos);
  } catch (e) {
    responderError(res, e);
  }
});

// GET uno
app.get('/api/productos/:id', async (req, res) => {
  if (!idValido(req.params.id)) return res.status(422).json({ message: 'El id debe ser un entero positivo' });
  try {
    const p = await Producto.findByPk(req.params.id);
    if (!p) return res.status(404).json({ message: 'Producto no encontrado' });
    res.status(200).json(p);
  } catch (e) {
    responderError(res, e);
  }
});

// POST
app.post('/api/productos', async (req, res) => {
  try {
    const errores = validar(req.body);
    if (Object.keys(errores).length) return error422(res, errores);

    const datos = datosLimpios(req.body);
    const existe = await Producto.findOne({ where: { codigo: datos.codigo } });
    if (existe) return error422(res, { codigo: 'El código ya existe' });

    const nuevo = await Producto.create(datos);
    res.status(201).json(nuevo);
  } catch (e) {
    responderError(res, e);
  }
});

// PUT
app.put('/api/productos/:id', async (req, res) => {
  if (!idValido(req.params.id)) return res.status(422).json({ message: 'El id debe ser un entero positivo' });
  try {
    const p = await Producto.findByPk(req.params.id);
    if (!p) return res.status(404).json({ message: 'Producto no encontrado' });

    const errores = validar(req.body);
    if (Object.keys(errores).length) return error422(res, errores);

    const datos = datosLimpios(req.body);
    const duplicado = await Producto.findOne({
      where: { codigo: datos.codigo, id: { [Op.ne]: p.id } },
    });
    if (duplicado) return error422(res, { codigo: 'El código ya existe' });

    await p.update(datos);
    res.status(200).json(p);
  } catch (e) {
    responderError(res, e);
  }
});

// DELETE
app.delete('/api/productos/:id', async (req, res) => {
  if (!idValido(req.params.id)) return res.status(422).json({ message: 'El id debe ser un entero positivo' });
  try {
    const p = await Producto.findByPk(req.params.id);
    if (!p) return res.status(404).json({ message: 'Producto no encontrado' });
    await p.destroy();
    res.status(200).json({ message: 'Producto eliminado correctamente' });
  } catch (e) {
    responderError(res, e);
  }
});

app.use((req, res) => res.status(404).json({ message: 'Ruta no encontrada' }));

app.use((error, req, res, next) => {
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({ message: 'El cuerpo de la solicitud no contiene JSON válido' });
  }
  responderError(res, error);
});

const PORT = process.env.PORT || 3000;

async function iniciarServidor() {
  await sequelize.sync();
  if ((await Producto.count()) === 0) {
    await Producto.bulkCreate([
      { nombre: 'Arroz 500g', codigo: 'P001', descripcion: 'Arroz blanco', precio: 2500, cantidad: 100, categoria: 'Granos' },
      { nombre: 'Aceite 1L', codigo: 'P002', descripcion: 'Aceite vegetal', precio: 12000, cantidad: 40, categoria: 'Aceites' },
      { nombre: 'Leche 1L', codigo: 'P003', descripcion: 'Leche entera', precio: 4200, cantidad: 60, categoria: 'Lácteos' },
      { nombre: 'Huevos x30', codigo: 'P004', descripcion: 'Cubeta AA', precio: 18000, cantidad: 25, categoria: 'Huevos' },
      { nombre: 'Panela', codigo: 'P005', descripcion: 'Panela redonda', precio: 3500, cantidad: 50, categoria: 'Endulzantes' },
      { nombre: 'Café 250g', codigo: 'P006', descripcion: 'Café molido', precio: 9500, cantidad: 35, categoria: 'Bebidas' },
      { nombre: 'Jabón', codigo: 'P007', descripcion: 'Jabón de barra', precio: 2000, cantidad: 80, categoria: 'Aseo' },
      { nombre: 'Atún lata', codigo: 'P008', descripcion: 'Atún en agua', precio: 5200, cantidad: 70, categoria: 'Enlatados' },
      { nombre: 'Pasta 500g', codigo: 'P009', descripcion: 'Espagueti', precio: 3000, cantidad: 90, categoria: 'Pastas' },
      { nombre: 'Gaseosa 1.5L', codigo: 'P010', descripcion: 'Bebida gaseosa', precio: 6500, cantidad: 45, categoria: 'Bebidas' },
    ]);
  }
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`API en http://localhost:${server.address().port}`);
  });
  return server;
}

if (require.main === module) {
  iniciarServidor().catch((error) => {
    console.error('No fue posible iniciar la API:', error);
    process.exitCode = 1;
  });
}

module.exports = { app, iniciarServidor };