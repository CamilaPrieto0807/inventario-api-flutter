const { Sequelize, DataTypes } = require('sequelize');
const path = require('node:path');

const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: path.resolve(process.env.DB_STORAGE || path.join(__dirname, 'inventario.sqlite')),
  logging: false,
});

const Producto = sequelize.define('Producto', {
  nombre:      { type: DataTypes.STRING, allowNull: false },
  codigo:      { type: DataTypes.STRING, allowNull: false, unique: true },
  descripcion: { type: DataTypes.TEXT },
  precio:      { type: DataTypes.DECIMAL(10, 2), allowNull: false, validate: { min: 0 } },
  cantidad:    { type: DataTypes.INTEGER, allowNull: false, validate: { min: 0 } },
  categoria:   { type: DataTypes.STRING, allowNull: false },
});

module.exports = { sequelize, Producto };