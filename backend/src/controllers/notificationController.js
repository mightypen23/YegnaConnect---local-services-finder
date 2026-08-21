const asyncHandler = require('../middleware/asyncHandler');
const notificationService = require('../services/notificationService');

const getNotifications = asyncHandler(async (req, res) => {
  const { page, limit } = req.query;
  const result = await notificationService.getNotifications(req.user.id, {
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

const getUnreadCount = asyncHandler(async (req, res) => {
  const count = await notificationService.getUnreadCount(req.user.id);
  res.json({ count });
});

const markAllRead = asyncHandler(async (req, res) => {
  await notificationService.markAllRead(req.user.id);
  res.json({ success: true });
});

const markRead = asyncHandler(async (req, res) => {
  const notification = await notificationService.markRead(req.params.id, req.user.id);
  if (!notification) {
    const err = new Error('Notification not found');
    err.status = 404;
    throw err;
  }
  res.json({ data: notification });
});

module.exports = {
  getNotifications,
  getUnreadCount,
  markAllRead,
  markRead
};
