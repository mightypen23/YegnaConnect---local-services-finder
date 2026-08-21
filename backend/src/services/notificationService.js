const notificationRepository = require('../repositories/NotificationRepository');

async function getNotifications(userId, { page = 1, limit = 20 } = {}) {
  return notificationRepository.findByUser(userId, { page, limit });
}

async function getUnreadCount(userId) {
  return notificationRepository.countUnread(userId);
}

async function markAllRead(userId) {
  await notificationRepository.markAllRead(userId);
}

async function markRead(id, userId) {
  return notificationRepository.markRead(id, userId);
}

async function createNotification({ userId, title, message, type, referenceId = null, referenceType = null }) {
  return notificationRepository.create({
    user_id: userId,
    title,
    message,
    type,
    reference_id: referenceId,
    reference_type: referenceType
  });
}

module.exports = {
  getNotifications,
  getUnreadCount,
  markAllRead,
  markRead,
  createNotification
};
