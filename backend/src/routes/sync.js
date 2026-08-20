const express = require('express');
const { body, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const syncController = require('../controllers/syncController');

const router = express.Router();

// All sync routes require authentication
router.use(authenticate);

// POST /api/sync/push — Push offline changes
router.post('/push',
  [
    body('items').optional().isArray().withMessage('items must be an array'),
    body('items.*.entity_type').optional().isString().withMessage('entity_type is required'),
    body('items.*.entity_id').optional().isUUID().withMessage('entity_id must be a valid UUID'),
    body('items.*.operation').optional().isIn(['create', 'update', 'delete']).withMessage('operation must be create, update, or delete'),
    body('items.*.payload').optional().isObject().withMessage('payload must be a JSON object'),
    body('items.*.client_id').optional().isUUID().withMessage('client_id must be a valid UUID'),
    // Support single-item push as well
    body('entity_type').optional().isString(),
    body('entity_id').optional().isUUID(),
    body('operation').optional().isIn(['create', 'update', 'delete']),
    body('payload').optional().isObject(),
    body('client_id').optional().isUUID()
  ],
  validate,
  syncController.push
);

// GET /api/sync/pull — Pull pending items
router.get('/pull',
  [query('client_id').optional().isUUID().withMessage('client_id must be a valid UUID')],
  validate,
  syncController.pull
);

// POST /api/sync/acknowledge — Acknowledge processed items
router.post('/acknowledge',
  [body('ids').isArray({ min: 1 }).withMessage('ids must be a non-empty array')],
  validate,
  syncController.acknowledge
);

// GET /api/sync/status — Sync queue status
router.get('/status',
  [query('client_id').optional().isUUID()],
  validate,
  syncController.status
);

module.exports = router;
