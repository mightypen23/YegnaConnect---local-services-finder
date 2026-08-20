const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const requestController = require('../controllers/requestController');

const router = express.Router();

// All request routes require authentication
router.use(authenticate);

// POST /api/requests — Create a service request
router.post('/',
  [
    body('category_id').isUUID().withMessage('Valid category_id is required'),
    body('description').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Latitude must be a decimal'),
    body('longitude').optional().isDecimal().withMessage('Longitude must be a decimal'),
    body('provider_id').optional().isUUID().withMessage('provider_id must be a valid UUID'),
    body('client_id').optional().isUUID().withMessage('client_id must be a valid UUID')
  ],
  validate,
  requestController.create
);

// GET /api/requests/me — Customer's own requests
router.get('/me',
  [
    query('status').optional().isIn(['pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'failed']),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  requestController.getMyRequests
);

// GET /api/requests/provider — Provider's incoming requests
router.get('/provider',
  [
    query('status').optional().isIn(['pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'failed']),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  requestController.getProviderRequests
);

// GET /api/requests/:id — Single request detail
router.get('/:id',
  [param('id').isUUID().withMessage('Valid request ID is required')],
  validate,
  requestController.getById
);

// PATCH /api/requests/:id/accept — Provider accepts
router.patch('/:id/accept',
  [param('id').isUUID().withMessage('Valid request ID is required')],
  validate,
  requestController.accept
);

// PATCH /api/requests/:id/complete — Provider completes
router.patch('/:id/complete',
  [param('id').isUUID().withMessage('Valid request ID is required')],
  validate,
  requestController.complete
);

// PATCH /api/requests/:id/cancel — Cancel request
router.patch('/:id/cancel',
  [
    param('id').isUUID().withMessage('Valid request ID is required'),
    body('reason').optional().isString()
  ],
  validate,
  requestController.cancel
);

module.exports = router;
