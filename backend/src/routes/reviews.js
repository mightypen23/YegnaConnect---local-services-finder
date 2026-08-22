const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const reviewController = require('../controllers/reviewController');

const router = express.Router();

// POST /api/reviews — Submit a review (auth required)
router.post('/',
  authenticate,
  [
    body('provider_id').isUUID().withMessage('Valid provider_id is required'),
    body('request_id').optional().isUUID().withMessage('request_id must be a valid UUID'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
    body('comment').optional().isString()
  ],
  validate,
  reviewController.create
);

// GET /api/reviews/provider/:providerId — List reviews (public)
router.get('/provider/:providerId',
  [
    param('providerId').isUUID().withMessage('Valid provider ID is required'),
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  reviewController.getForProvider
);

// GET /api/reviews/provider/:providerId/stats — Rating stats (public)
router.get('/provider/:providerId/stats',
  [param('providerId').isUUID().withMessage('Valid provider ID is required')],
  validate,
  reviewController.getProviderStats
);

// GET /api/reviews/request/:requestId — Review for a request (public)
router.get('/request/:requestId',
  [param('requestId').isUUID().withMessage('Valid request ID is required')],
  validate,
  reviewController.getByRequest
);

module.exports = router;
