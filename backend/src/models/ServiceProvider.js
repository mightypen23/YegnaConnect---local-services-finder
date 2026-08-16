const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ServiceProvider = sequelize.define('ServiceProvider', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    unique: true
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  credit_balance: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  trust_score: {
    type: DataTypes.DECIMAL(3, 2),
    defaultValue: 0.00,
    validate: {
      min: 0,
      max: 5
    }
  },
  verification_status: {
    type: DataTypes.ENUM('pending', 'verified', 'rejected'),
    defaultValue: 'pending'
  },
  availability_status: {
    type: DataTypes.ENUM('available', 'busy', 'offline'),
    defaultValue: 'available'
  },
  subscription_status: {
    type: DataTypes.ENUM('inactive', 'active', 'expired'),
    defaultValue: 'inactive'
  }
}, {
  tableName: 'service_providers',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['verification_status']
    },
    {
      fields: ['subscription_status']
    }
  ]
});

module.exports = ServiceProvider;