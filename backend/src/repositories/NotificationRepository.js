const BaseRepository = require('./BaseRepository');
const { Notification } = require('../models');

class NotificationRepository extends BaseRepository {
  constructor() {
    super(Notification);
  }

  async findByUser(userId, { page = 1, limit = 20 } = {}) {
    return this.paginate(
      { user_id: userId },
      { order: [['created_at', 'DESC']] },
      page,
      limit
    );
  }

  async countUnread(userId) {
    return this.model.count({ where: { user_id: userId, is_read: false } });
  }

  async markAllRead(userId) {
    return this.model.update(
      { is_read: true },
      { where: { user_id: userId, is_read: false } }
    );
  }

  async markRead(id, userId) {
    const instance = await this.model.findOne({ where: { id, user_id: userId } });
    if (!instance) return null;
    return instance.update({ is_read: true });
  }
}

module.exports = new NotificationRepository();
