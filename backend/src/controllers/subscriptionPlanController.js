const { body, param, validationResult } = require('express-validator');
const {
  listActivePlans,
  listPlans,
  createPlan,
  updatePlan,
  PlanError
} = require('../services/subscriptionPlanService');

function asyncHandler(fn) {
  return (req, res, next) => {
    fn(req, res, next).catch((err) => {
      if (err instanceof PlanError) {
        return res.status(err.status).json({ error: err.message });
      }
      return next(err);
    });
  };
}

function requireValid(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ error: errors.array()[0].msg });
    return false;
  }
  return true;
}

function sanitizePlan(plan) {
  const p = plan.toJSON ? plan.toJSON() : plan;
  return {
    id: p.id,
    name: p.name,
    description: p.description,
    credits: p.credits,
    price: p.price == null ? null : Number(p.price),
    currency: p.currency,
    duration_days: p.duration_days,
    is_active: p.is_active,
    created_at: p.created_at,
    updated_at: p.updated_at
  };
}

const createValidators = [
  body('name')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Plan name must be between 1 and 100 characters'),
  body('description')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be at most 500 characters'),
  body('credits')
    .isInt({ min: 1 })
    .withMessage('Credits must be a positive integer'),
  body('price')
    .isFloat({ min: 0 })
    .withMessage('Price must be a non-negative number'),
  body('currency')
    .optional()
    .trim()
    .isLength({ min: 3, max: 3 })
    .isUppercase()
    .withMessage('Currency must be a 3-letter ISO code'),
  body('duration_days')
    .isInt({ min: 1 })
    .withMessage('Duration must be a positive integer number of days'),
  body('is_active')
    .optional()
    .isBoolean()
    .withMessage('is_active must be a boolean')
];

const updateValidators = [
  param('id').isUUID().withMessage('Invalid plan id'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Plan name must be between 1 and 100 characters'),
  body('description')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be at most 500 characters'),
  body('credits')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Credits must be a positive integer'),
  body('price')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Price must be a non-negative number'),
  body('currency')
    .optional()
    .trim()
    .isLength({ min: 3, max: 3 })
    .isUppercase()
    .withMessage('Currency must be a 3-letter ISO code'),
  body('duration_days')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Duration must be a positive integer number of days'),
  body('is_active')
    .optional()
    .isBoolean()
    .withMessage('is_active must be a boolean')
];

const listPublic = asyncHandler(async (req, res) => {
  const plans = await listActivePlans();
  res.json({ plans: plans.map(sanitizePlan) });
});

const listAdmin = asyncHandler(async (req, res) => {
  const plans = await listPlans();
  res.json({ plans: plans.map(sanitizePlan) });
});

const create = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const plan = await createPlan({
    name: req.body.name,
    description: req.body.description,
    credits: req.body.credits,
    price: req.body.price,
    currency: req.body.currency,
    duration_days: req.body.duration_days,
    is_active: req.body.is_active
  });
  res.status(201).json({ plan: sanitizePlan(plan) });
});

const update = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const plan = await updatePlan(req.params.id, {
    name: req.body.name,
    description: req.body.description,
    credits: req.body.credits,
    price: req.body.price,
    currency: req.body.currency,
    duration_days: req.body.duration_days,
    is_active: req.body.is_active
  });
  res.json({ plan: sanitizePlan(plan) });
});

module.exports = {
  createValidators,
  updateValidators,
  sanitizePlan,
  listPublic,
  listAdmin,
  create,
  update
};