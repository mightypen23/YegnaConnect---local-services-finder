require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');
const { Notification, ServiceProvider, User } = require('../models');

(async () => {
  try {
    await sequelize.authenticate();
    console.log('Connected to DB');

    const providers = await ServiceProvider.findAll({
      where: { user_id: sequelize.literal('user_id IS NOT NULL') },
      limit: 1
    });
    if (!providers.length) {
      console.log('No provider rows found');
      return;
    }
    const sp = providers[0];
    console.log('ServiceProvider id:', sp.id, '| user_id:', sp.user_id);

    const user = await User.findByPk(sp.user_id);
    console.log('Provider User:', user ? `${user.full_name} (${user.role})` : 'NOT FOUND!');

    // Mimic notificationService.createNotification exactly
    try {
      const n = await Notification.create({
        user_id: sp.user_id,
        title: 'New Service Request',
        message: `'Test Customer' requested your service`,
        type: 'new_request',
        reference_id: null,
        reference_type: 'ServiceRequest'
      });
      console.log('Notification created OK:', n.id);

      // Read it back the way GET /notifications does
      const found = await Notification.findAll({ where: { user_id: sp.user_id }, limit: 5 });
      console.log('Notifications visible for this user:', found.length);

      // Cleanup
      await n.destroy();
      console.log('Test notification cleaned up');
    } catch (e) {
      console.log('NOTIFICATION CREATE FAILED:', e.message);
      if (e.parent) console.log('SQL FAIL:', e.parent.message);
    }
  } catch (e) {
    console.error('ERR', e.message);
  } finally {
    await sequelize.close();
  }
})();
