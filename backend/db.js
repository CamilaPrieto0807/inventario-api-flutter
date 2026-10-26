const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './inventario.sqlite',
  logging: false,
});

const Producto = sequelize.define('Producto', {
  nombre:      { type: DataTypes.STRING, allowNull: false },
  codigo:      { type: DataTypes.STRING, allowNull: false, unique: true },
  descripcion: { type: DataTypes.TEXT },
  precio:      { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  cantidad:    { type: DataTypes.INTEGER, allowNull: false },
  categoria:   { type: DataTypes.STRING, allowNull: false },
});

module.exports = { sequelize, Producto };