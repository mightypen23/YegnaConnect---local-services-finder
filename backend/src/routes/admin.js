const express = require('express');
const router = express.Router();

const { authenticate, requireAdmin } = require('../middleware/auth');
const {
  listProviderValidators,
  verificationValidators,
  creditsValidators,
  subscriptionValidators,
  badgeListValidators,
  badgeDecisionValidators,
  list,
  setVerification,
  grantCreditsHandler,
  createSubscriptionHandler,
  listBadgesHandler,
  decideBadgeHandler,
  planList,
  planCreate,
  planUpdate
} = require('../controllers/adminController');
const {
  createValidators: planCreateValidators,
  updateValidators: planUpdateValidators
} = require('../controllers/subscriptionPlanController');

router.use(authenticate, requireAdmin);

router.get('/providers', listProviderValidators, list);
router.put('/providers/:providerId/verification', verificationValidators, setVerification);
router.post('/providers/:providerId/credits', creditsValidators, grantCreditsHandler);

router.post('/subscriptions', subscriptionValidators, createSubscriptionHandler);

router.get('/badges', badgeListValidators, listBadgesHandler);
router.put('/badges/:badgeId/decision', badgeDecisionValidators, decideBadgeHandler);

router.get('/plans', planList);
router.post('/plans', planCreateValidators, planCreate);
router.put('/plans/:id', planUpdateValidators, planUpdate);

module.exports = router;