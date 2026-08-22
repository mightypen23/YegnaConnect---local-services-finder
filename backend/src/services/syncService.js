const { SyncQueue, ServiceRequest, Review } = require('../models');
const { sequelize } = require('../config/database');
const { Op } = require('sequelize');

const MAX_RETRIES = 5;

/**
 * Entity handlers map entity_type to the model + processing logic.
 * Add new entity types here as the app grows.
 */
const ENTITY_HANDLERS = {
  service_request: {
    model: ServiceRequest,
    processCreate: async (payload, t) => ServiceRequest.create(payload, { transaction: t }),
    processUpdate: async (entityId, payload, t) => {
      const entity = await ServiceRequest.findByPk(entityId, { transaction: t });
      if (!entity) throw new Error(`ServiceRequest ${entityId} not found`);
      return entity.update(payload, { transaction: t });
    },
    processDelete: async (entityId, t) => {
      const entity = await ServiceRequest.findByPk(entityId, { transaction: t });
      if (!entity) throw new Error(`ServiceRequest ${entityId} not found`);
      return entity.destroy({ transaction: t });
    }
  },
  review: {
    model: Review,
    processCreate: async (payload, t) => Review.create(payload, { transaction: t }),
    processUpdate: async (entityId, payload, t) => {
      const entity = await Review.findByPk(entityId, { transaction: t });
      if (!entity) throw new Error(`Review ${entityId} not found`);
      return entity.update(payload, { transaction: t });
    },
    processDelete: async (entityId, t) => {
      const entity = await Review.findByPk(entityId, { transaction: t });
      if (!entity) throw new Error(`Review ${entityId} not found`);
      return entity.destroy({ transaction: t });
    }
  }
};

/**
 * Enqueue one or more offline changes for later processing.
 */
async function enqueue(data) {
  const items = Array.isArray(data) ? data : [data];

  const created = await SyncQueue.bulkCreate(
    items.map((item) => ({
      entity_type: item.entity_type,
      entity_id: item.entity_id,
      operation: item.operation,
      payload: item.payload,
      client_id: item.client_id,
      status: 'pending',
      retry_count: 0
    }))
  );

  return created;
}

/**
 * Process a batch of pending sync items.
 * Each item is processed in its own transaction; failures are recorded.
 */
async function processBatch(batchSize = 10) {
  const items = await SyncQueue.findAll({
    where: { status: 'pending' },
    order: [['created_at', 'ASC']],
    limit: batchSize
  });

  const results = { processed: 0, failed: 0, skipped: 0 };

  for (const item of items) {
    const handler = ENTITY_HANDLERS[item.entity_type];

    if (!handler) {
      await item.update({
        status: 'failed',
        error_message: `Unknown entity type: ${item.entity_type}`
      });
      results.failed++;
      continue;
    }

    try {
      await sequelize.transaction(async (t) => {
        await item.update({ status: 'processing' }, { transaction: t });

        switch (item.operation) {
          case 'create':
            await handler.processCreate(item.payload, t);
            break;
          case 'update':
            await handler.processUpdate(item.entity_id, item.payload, t);
            break;
          case 'delete':
            await handler.processDelete(item.entity_id, t);
            break;
          default:
            throw new Error(`Unknown operation: ${item.operation}`);
        }

        await item.update({ status: 'completed' }, { transaction: t });
      });
      results.processed++;
    } catch (error) {
      await item.update({
        status: 'failed',
        error_message: error.message,
        retry_count: item.retry_count + 1
      });
      results.failed++;
    }
  }

  return results;
}

/**
 * Get pending sync items for a specific client.
 */
async function getPendingItems(clientId) {
  return SyncQueue.findAll({
    where: {
      client_id: clientId,
      status: { [Op.in]: ['pending', 'failed'] }
    },
    order: [['created_at', 'ASC']]
  });
}

/**
 * Retry failed items that haven't exceeded the retry limit.
 */
async function retryFailed(maxRetries = MAX_RETRIES) {
  const [count] = await SyncQueue.update(
    { status: 'pending' },
    {
      where: {
        status: 'failed',
        retry_count: { [Op.lt]: maxRetries }
      }
    }
  );

  return { retriedCount: count };
}

/**
 * Get sync status summary for a client.
 */
async function getStatus(clientId) {
  const where = clientId ? { client_id: clientId } : {};

  const results = await SyncQueue.findAll({
    attributes: [
      'status',
      [sequelize.fn('COUNT', sequelize.col('id')), 'count']
    ],
    where,
    group: ['status'],
    raw: true
  });

  const status = { pending: 0, processing: 0, completed: 0, failed: 0 };
  results.forEach((r) => { status[r.status] = parseInt(r.count, 10); });

  return status;
}

/**
 * Client acknowledges that it has processed the completed sync items.
 * Removes them from the queue.
 */
async function acknowledge(ids) {
  const deleted = await SyncQueue.destroy({
    where: {
      id: { [Op.in]: ids },
      status: 'completed'
    }
  });

  return { acknowledged: deleted };
}

module.exports = {
  enqueue,
  processBatch,
  getPendingItems,
  retryFailed,
  getStatus,
  acknowledge
};
