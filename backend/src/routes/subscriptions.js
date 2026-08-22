const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate, requireRole } = require('../middleware/auth');
const subscriptionController = require('../controllers/subscriptionController');

const router = express.Router();

// All subscription routes require authentication + provider role
router.use(authenticate);
router.use(requireRole('provider', 'admin'));

// POST /api/subscriptions — Subscribe to a plan
router.post('/',
  [body('plan_id').isUUID().withMessage('Valid plan_id is required')],
  validate,
  subscriptionController.subscribe
);

// GET /api/subscriptions/active — Current active subscription
router.get('/active', subscriptionController.getActive);

// GET /api/subscriptions/history — Subscription history
router.get('/history',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  subscriptionController.getHistory
);

// PATCH /api/subscriptions/:id/cancel — Cancel subscription
router.patch('/:id/cancel',
  [param('id').isUUID().withMessage('Valid subscription ID is required')],
  validate,
  subscriptionController.cancel
);

module.exports = router;
