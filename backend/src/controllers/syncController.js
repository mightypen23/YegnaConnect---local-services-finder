const asyncHandler = require('../middleware/asyncHandler');
const syncService = require('../services/syncService');

/**
 * POST /api/sync/push
 * Push offline changes to the sync queue.
 */
const push = asyncHandler(async (req, res) => {
  const items = req.body.items || [req.body];
  const created = await syncService.enqueue(items);

  // Auto-process the batch
  const result = await syncService.processBatch(items.length);

  res.status(201).json({
    data: { queued: created.length, ...result }
  });
});

/**
 * GET /api/sync/pull
 * Pull pending/failed sync items for the current client.
 */
const pull = asyncHandler(async (req, res) => {
  const clientId = req.query.client_id || req.user.id;
  const items = await syncService.getPendingItems(clientId);
  res.json({ data: items });
});

/**
 * POST /api/sync/acknowledge
 * Acknowledge that completed sync items have been processed by the client.
 */
const acknowledge = asyncHandler(async (req, res) => {
  const { ids } = req.body;

  if (!ids || !Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: 'ids array is required' });
  }

  const result = await syncService.acknowledge(ids);
  res.json({ data: result });
});

/**
 * GET /api/sync/status
 * Get sync queue status summary.
 */
const status = asyncHandler(async (req, res) => {
  const clientId = req.query.client_id || null;
  const result = await syncService.getStatus(clientId);
  res.json({ data: result });
});

module.exports = {
  push,
  pull,
  acknowledge,
  status
};
