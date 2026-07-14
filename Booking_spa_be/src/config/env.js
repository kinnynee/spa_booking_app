const dotenv = require('dotenv');
const { z } = require('zod');

dotenv.config();

const emptyToUndefined = (value) => (value === '' ? undefined : value);

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  API_PREFIX: z.string().default('/api/v1'),
  APP_NAME: z.string().default('Spa Booking API'),
  CORS_ORIGIN: z.string().default('*'),
  JSON_BODY_LIMIT: z.string().default('1mb'),
  DATABASE_URL: z
    .string()
    .url()
    .default('postgres://spa_user:spa_password@localhost:5432/spa_booking'),
  DB_POOL_MIN: z.coerce.number().int().nonnegative().default(2),
  DB_POOL_MAX: z.coerce.number().int().positive().default(10),
  REDIS_URL: z.string().url().default('redis://localhost:6379'),
  CACHE_TTL_SECONDS: z.coerce.number().int().positive().default(300),
  JWT_ACCESS_SECRET: z.string().min(32).default('dev_access_secret_change_me_32_chars'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_SECRET: z.string().min(32).default('dev_refresh_secret_change_me_32_chars'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),
  PASSWORD_SALT_ROUNDS: z.coerce.number().int().min(10).max(14).default(12),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(15 * 60 * 1000),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(100),
  AUTH_RATE_LIMIT_MAX: z.coerce.number().int().positive().default(10),
  LOG_LEVEL: z.string().default('info'),
  FIREBASE_PROJECT_ID: z.preprocess(emptyToUndefined, z.string().optional()),
  GOOGLE_OAUTH_CLIENT_ID: z.preprocess(emptyToUndefined, z.string().optional()),
  FIREBASE_SERVICE_ACCOUNT_PATH: z.preprocess(emptyToUndefined, z.string().optional()),
  FIREBASE_CLIENT_EMAIL: z.preprocess(emptyToUndefined, z.string().email().optional()),
  FIREBASE_PRIVATE_KEY: z.preprocess(emptyToUndefined, z.string().optional()),
  FIREBASE_STORAGE_BUCKET: z.preprocess(emptyToUndefined, z.string().optional()),
  FIREBASE_USE_EMULATOR: z.preprocess((value) => value === true || value === 'true', z.boolean()),
  FIRESTORE_EMULATOR_HOST: z.string().default('127.0.0.1:8080'),
  FIREBASE_AUTH_EMULATOR_HOST: z.string().default('127.0.0.1:9099'),
  FIRESTORE_LOCATION: z.string().default('asia-southeast1'),
  FIREBASE_SEED_ADMIN_EMAIL: z.preprocess(emptyToUndefined, z.string().email().optional()),
  FIREBASE_SEED_ADMIN_PASSWORD: z.preprocess(emptyToUndefined, z.string().min(8).optional()),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const details = parsed.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`);
  throw new Error(`Invalid environment configuration: ${details.join('; ')}`);
}

const env = parsed.data;

if (
  env.NODE_ENV === 'production' &&
  (env.JWT_ACCESS_SECRET.startsWith('dev_') || env.JWT_REFRESH_SECRET.startsWith('dev_'))
) {
  throw new Error('Production JWT secrets must be changed from development defaults.');
}

module.exports = {
  env: env.NODE_ENV,
  app: {
    name: env.APP_NAME,
    port: env.PORT,
    apiPrefix: env.API_PREFIX,
    jsonBodyLimit: env.JSON_BODY_LIMIT,
  },
  cors: {
    origin:
      env.CORS_ORIGIN === '*'
        ? '*'
        : env.CORS_ORIGIN.split(',')
            .map((origin) => origin.trim())
            .filter(Boolean),
  },
  database: {
    url: env.DATABASE_URL,
    poolMin: env.DB_POOL_MIN,
    poolMax: env.DB_POOL_MAX,
  },
  redis: {
    url: env.REDIS_URL,
    defaultTtlSeconds: env.CACHE_TTL_SECONDS,
  },
  jwt: {
    accessSecret: env.JWT_ACCESS_SECRET,
    accessExpiresIn: env.JWT_ACCESS_EXPIRES_IN,
    refreshSecret: env.JWT_REFRESH_SECRET,
    refreshExpiresIn: env.JWT_REFRESH_EXPIRES_IN,
  },
  password: {
    saltRounds: env.PASSWORD_SALT_ROUNDS,
  },
  security: {
    rateLimitWindowMs: env.RATE_LIMIT_WINDOW_MS,
    rateLimitMax: env.RATE_LIMIT_MAX,
    authRateLimitMax: env.AUTH_RATE_LIMIT_MAX,
  },
  logging: {
    level: env.LOG_LEVEL,
  },
  google: {
    oauthClientId: env.GOOGLE_OAUTH_CLIENT_ID,
  },
  firebase: {
    projectId: env.FIREBASE_PROJECT_ID,
    serviceAccountPath: env.FIREBASE_SERVICE_ACCOUNT_PATH,
    clientEmail: env.FIREBASE_CLIENT_EMAIL,
    privateKey: env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    storageBucket: env.FIREBASE_STORAGE_BUCKET,
    useEmulator: env.FIREBASE_USE_EMULATOR,
    firestoreEmulatorHost: env.FIRESTORE_EMULATOR_HOST,
    authEmulatorHost: env.FIREBASE_AUTH_EMULATOR_HOST,
    firestoreLocation: env.FIRESTORE_LOCATION,
    seedAdminEmail: env.FIREBASE_SEED_ADMIN_EMAIL,
    seedAdminPassword: env.FIREBASE_SEED_ADMIN_PASSWORD,
  },
};
