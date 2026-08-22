const express = require('express');
const { param, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

const router = express.Router();

router.use(authenticate);

router.get('/',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 })
  ],
  validate,
  notificationController.getNotifications
);

router.get('/unread', notificationController.getUnreadCount);

router.patch('/read-all', notificationController.markAllRead);

router.patch('/:id/read',
  [param('id').isUUID().withMessage('Valid notification ID is required')],
  validate,
  notificationController.markRead
);

module.exports = router;
