const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Subscription = sequelize.define('Subscription', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  plan_id: {
    type: DataTypes.UUID,
    allowNull: true
  },
  plan_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  credits: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 0
    }
  },
  amount_paid: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  currency: {
    type: DataTypes.STRING(3),
    defaultValue: 'ETB'
  },
  starts_at: {
    type: DataTypes.DATE,
    allowNull: false
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('active', 'expired', 'cancelled'),
    defaultValue: 'active'
  }
}, {
  tableName: 'subscriptions',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  validate: {
    expiresAfterStarts() {
      if (this.expires_at && this.starts_at && this.expires_at <= this.starts_at) {
        throw new Error('expires_at must be after starts_at');
      }
    }
  },
  indexes: [
    {
      fields: ['provider_id']
    },
    {
      fields: ['status']
    },
    {
      fields: ['expires_at']
    }
  ]
});

module.exports = Subscription;