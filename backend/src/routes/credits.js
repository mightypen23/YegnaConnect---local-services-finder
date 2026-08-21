const express = require('express');
const { query, body } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate, requireRole } = require('../middleware/auth');
const creditController = require('../controllers/creditController');

const router = express.Router();

// All credit routes require authentication + provider role
router.use(authenticate);
router.use(requireRole('provider', 'admin'));

// GET /api/credits/balance — Current credit balance
router.get('/balance', creditController.getBalance);

// GET /api/credits/transactions — Transaction history
router.get('/transactions',
  [
    query('type').optional().isIn(['credit', 'debit']).withMessage('Type must be "credit" or "debit"'),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  creditController.getTransactions
);

// GET /api/credits/summary — Credit balance summary
router.get('/summary', creditController.getSummary);

// POST /api/credits/purchase — Buy credit top-up packages (50 birr = 100 credits)
router.post('/purchase',
  [body('packages').optional().isInt({ min: 1 }).withMessage('packages must be a positive integer')],
  validate,
  creditController.purchaseCredits
);

module.exports = router;
