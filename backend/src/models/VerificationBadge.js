const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const VerificationBadge = sequelize.define('VerificationBadge', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  badge_type: {
    type: DataTypes.ENUM('identity_verified', 'certified_skill', 'assessed_skill', 'trusted_provider'),
    allowNull: false
  },
  evidence: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  evidence_url: {
    type: DataTypes.STRING,
    allowNull: true
  },
  verified_by: {
    type: DataTypes.UUID,
    allowNull: true
  },
  verified_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending', 'under_review', 'approved', 'rejected'),
    defaultValue: 'pending'
  },
  rejection_reason: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  tableName: 'verification_badges',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['provider_id']
    },
    {
      fields: ['status']
    },
    {
      fields: ['provider_id', 'badge_type']
    }
  ]
});

module.exports = VerificationBadge;