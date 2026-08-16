const { DataTypes, QueryTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CreditTransaction = sequelize.define('CreditTransaction', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  amount: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM('credit', 'debit'),
    allowNull: false
  },
  reason: {
    type: DataTypes.STRING,
    allowNull: true
  },
  reference_id: {
    type: DataTypes.UUID,
    allowNull: true
  },
  reference_type: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'credit_transactions',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      fields: ['provider_id']
    },
    {
      fields: ['type']
    }
  ]
});

async function refreshProviderBalance(providerId, options = {}) {
  if (!providerId) return;
  const ServiceProvider = sequelize.models.ServiceProvider;
  if (!ServiceProvider) return;
  const [result] = await sequelize.query(
    `SELECT COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE -amount END), 0) AS balance
     FROM credit_transactions WHERE provider_id = :providerId`,
    {
      type: QueryTypes.SELECT,
      transaction: options.transaction,
      replacements: { providerId }
    }
  );
  await ServiceProvider.update(
    { credit_balance: Number(result.balance) },
    { where: { id: providerId }, transaction: options.transaction }
  );
}

CreditTransaction.addHook('afterCreate', (instance, options) => refreshProviderBalance(instance.provider_id, options));
CreditTransaction.addHook('afterUpdate', (instance, options) => refreshProviderBalance(instance.provider_id, options));
CreditTransaction.addHook('afterDestroy', (instance, options) => refreshProviderBalance(instance.provider_id, options));
CreditTransaction.addHook('afterBulkCreate', (instances, options) => {
  const providerIds = [...new Set(instances.map(i => i.provider_id).filter(Boolean))];
  return Promise.all(providerIds.map(id => refreshProviderBalance(id, options)));
});

module.exports = CreditTransaction;