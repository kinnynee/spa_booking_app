# Spa Booking Backend

Monolithic Node.js backend for a mobile Spa Booking App. The project follows a layered
architecture: routes -> controllers -> services -> repositories -> models/database.

## Stack

- Express.js API server
- PostgreSQL with Knex migrations
- Redis cache
- JWT authentication and role based authorization
- Zod validation
- Helmet, CORS, rate limit, HPP, centralized errors, and Winston logging
- ESLint, Prettier, lint-staged, Husky-ready pre-commit hook
- Docker and Docker Compose
- Firebase Admin SDK with Firestore seed scripts

## Quick start

```bash
cp .env.example .env
pnpm install
pnpm db:migrate
pnpm db:seed
pnpm dev
```

Health endpoint:

```bash
GET http://localhost:3000/api/v1/health
```

## Main folders

```text
src/
  common/        Shared errors, middleware, logger, cache, events, utilities
  config/        Environment, database, redis, static path singletons
  database/      Knex migrations and seeds
  modules/       Domain modules: auth, users, profiles, services, bookings
  pipeline/      Rule based data pipeline with Strategy pattern and DLQ
  routes/        API route composition
  app.js         Express application
  server.js      HTTP server bootstrap
static/          Public static assets served by Express
```

## Security baseline

- Input validation is centralized with Zod schemas.
- SQL injection risk is reduced by using Knex parameterized queries.
- Passwords are hashed with bcryptjs.
- JWT access tokens are verified by authentication middleware.
- RBAC authorization is available through `authorize(...)`.
- CORS, Helmet, HPP, request size limits, and rate limits are enabled globally.
- Auth endpoints use a stricter rate limit.
- Errors and request logs are centralized through Winston and Morgan.

## Docker

```bash
cp .env.example .env
docker compose up --build
```

Then run migrations inside the API container:

```bash
docker compose exec api pnpm db:migrate
docker compose exec api pnpm db:seed
```

## Firebase Firestore

The service account key is stored locally in `.secrets/firebase-service-account.json` and is ignored
by Git. Do not commit it.

```bash
pnpm firebase:create-db
pnpm firebase:seed
pnpm firebase:check
```

`firebase:seed` creates sample `serviceCategories`, `services`, `users`, and `appointments`
documents in the `bookingspabe` Firestore project. To create a real Firebase Auth admin account,
set `FIREBASE_SEED_ADMIN_EMAIL` and `FIREBASE_SEED_ADMIN_PASSWORD` in `.env` before seeding.

## Firebase Storage service images

Service images are stored in Firebase Storage, while PostgreSQL keeps the public download URL in `spa_services.image_url`. The Flutter app already renders that field with `Image.network`.

1. Enable Firebase Storage in the Firebase Console.
2. Put the service account JSON at `.secrets/firebase-service-account.json`.
3. Set `FIREBASE_STORAGE_BUCKET` in `.env` using the exact bucket name from Firebase Console > Storage.
4. Keep local source images in `../assets/images`, or override the folder with `SERVICE_IMAGE_ASSET_DIR`.
5. Upload images and update PostgreSQL:

```bash
pnpm run firebase:upload-service-images
```

The script uploads the mapped files to `service-images/` in Firebase Storage and updates services by slug. The package command uses Node `--use-system-ca` so Windows can validate Firebase TLS certificates through the system certificate store. Restart or refresh the Flutter app after it finishes so the catalog reloads the new `imageUrl` values.
