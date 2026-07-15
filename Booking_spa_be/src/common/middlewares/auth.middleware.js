const { AppError } = require('../errors/app-error');
const { verifyAccessToken } = require('../utils/token');
const userRepository = require('../../modules/users/user.repository');

async function authenticate(req, _res, next) {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith('Bearer ')) {
      throw new AppError('Authentication token is required.', 401, 'AUTH_REQUIRED');
    }

    const token = header.slice('Bearer '.length);
    const decoded = verifyAccessToken(token);
    const user = await userRepository.findById(decoded.sub);

    if (!user || !user.is_active) {
      throw new AppError('User is not allowed to access this resource.', 401, 'AUTH_INVALID');
    }

    req.user = user;
    return next();
  } catch (error) {
    if (error instanceof AppError) {
      return next(error);
    }

    return next(new AppError('Invalid or expired authentication token.', 401, 'AUTH_INVALID'));
  }
}

function authorize(...allowedRoles) {
  return (req, _res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication token is required.', 401, 'AUTH_REQUIRED'));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(new AppError('You do not have permission for this action.', 403, 'FORBIDDEN'));
    }

    return next();
  };
}

module.exports = {
  authenticate,
  authorize,
};
