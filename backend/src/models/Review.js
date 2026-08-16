const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Review = sequelize.define('Review', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  customer_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  request_id: {
    type: DataTypes.UUID,
    allowNull: true
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'reviews',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['provider_id']
    },
    {
      fields: ['customer_id']
    },
    {
      unique: true,
      fields: ['provider_id', 'customer_id', 'request_id']
    }
  ]
});

module.exports = Review;