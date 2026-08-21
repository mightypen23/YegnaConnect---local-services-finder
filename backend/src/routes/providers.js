const express = require('express');
const router = express.Router();

const {
  createProviderValidators,
  getProviderValidators,
  updateValidators,
  locationValidators,
  create,
  getPublicOne,
  list,
  getMe,
  update,
  setLocationHandler
} = require('../controllers/providerController');
const { authenticate } = require('../middleware/auth');
const { getTransactions: creditsHistory } = require('../controllers/creditController');
const { getActive: subscriptionStatus } = require('../controllers/subscriptionController');

router.post('/', authenticate, createProviderValidators, create);
router.get('/', list);
router.get('/me', authenticate, getMe);
router.get('/me/credits', authenticate, creditsHistory);
router.get('/me/subscription', authenticate, subscriptionStatus);
router.get('/:id', getProviderValidators, getPublicOne);
router.put('/:id', authenticate, updateValidators, update);
router.put('/:id/location', authenticate, locationValidators, setLocationHandler);

module.exports = router;
