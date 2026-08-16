const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ProviderCategory = sequelize.define('ProviderCategory', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  category_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  skill_level: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'expert'),
    defaultValue: 'intermediate'
  }
}, {
  tableName: 'provider_categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      unique: true,
      fields: ['provider_id', 'category_id']
    }
  ]
});

module.exports = ProviderCategory;