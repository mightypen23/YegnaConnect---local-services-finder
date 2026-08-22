const express = require('express');
const { body, param } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate, requireRole } = require('../middleware/auth');
const subscriptionPlanController = require('../controllers/subscriptionPlanController');

const router = express.Router();

// GET /api/plans — List all active plans (public)
router.get('/', subscriptionPlanController.getAll);

// GET /api/plans/:id — Single plan detail (public)
router.get('/:id',
  [param('id').isUUID().withMessage('Valid plan ID is required')],
  validate,
  subscriptionPlanController.getById
);

// POST /api/plans — Create plan (admin only)
router.post('/',
  authenticate,
  requireRole('admin'),
  [
    body('name').notEmpty().withMessage('Plan name is required'),
    body('price').isDecimal({ decimal_digits: '0,2' }).withMessage('Price must be a valid decimal'),
    body('credits').isInt({ min: 0 }).withMessage('Credits must be a non-negative integer'),
    body('duration_days').isInt({ min: 1 }).withMessage('Duration must be at least 1 day'),
    body('features').optional().isObject().withMessage('Features must be a JSON object'),
    body('is_active').optional().isBoolean()
  ],
  validate,
  subscriptionPlanController.create
);

// PUT /api/plans/:id — Update plan (admin only)
router.put('/:id',
  authenticate,
  requireRole('admin'),
  [
    param('id').isUUID().withMessage('Valid plan ID is required'),
    body('name').optional().notEmpty(),
    body('price').optional().isDecimal({ decimal_digits: '0,2' }),
    body('credits').optional().isInt({ min: 0 }),
    body('duration_days').optional().isInt({ min: 1 }),
    body('features').optional().isObject(),
    body('is_active').optional().isBoolean()
  ],
  validate,
  subscriptionPlanController.update
);

// DELETE /api/plans/:id — Deactivate plan (admin only)
router.delete('/:id',
  authenticate,
  requireRole('admin'),
  [param('id').isUUID().withMessage('Valid plan ID is required')],
  validate,
  subscriptionPlanController.deactivate
);

module.exports = router;
