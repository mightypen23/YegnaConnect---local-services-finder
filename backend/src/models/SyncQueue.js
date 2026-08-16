const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const SyncQueue = sequelize.define('SyncQueue', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  entity_type: {
    type: DataTypes.STRING,
    allowNull: false
  },
  entity_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  operation: {
    type: DataTypes.ENUM('create', 'update', 'delete'),
    allowNull: false
  },
  payload: {
    type: DataTypes.JSONB,
    allowNull: false
  },
  retry_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM('pending', 'processing', 'completed', 'failed'),
    defaultValue: 'pending'
  },
  error_message: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  client_id: {
    type: DataTypes.UUID,
    allowNull: false
  }
}, {
  tableName: 'sync_queue',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['status']
    },
    {
      fields: ['entity_type', 'entity_id']
    }
  ]
});

module.exports = SyncQueue;