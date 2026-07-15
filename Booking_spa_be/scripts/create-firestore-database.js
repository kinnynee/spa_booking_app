const { GoogleAuth } = require('google-auth-library');

const config = require('../src/config/env');
const { getFirebaseProjectId } = require('../src/config/firebase');

const DATABASE_ID = '(default)';

function getKeyFilename() {
  return config.firebase.serviceAccountPath || undefined;
}

async function waitForOperation(client, operationName) {
  const url = `https://firestore.googleapis.com/v1/${operationName}`;

  for (let attempt = 0; attempt < 30; attempt += 1) {
    const response = await client.request({ url });

    if (response.data.done) {
      return response.data;
    }

    await new Promise((resolve) => setTimeout(resolve, 2000));
  }

  throw new Error(`Timed out waiting for Firestore operation: ${operationName}`);
}

async function main() {
  const projectId = getFirebaseProjectId();

  if (!projectId) {
    throw new Error('Missing FIREBASE_PROJECT_ID or project_id in service account.');
  }

  const auth = new GoogleAuth({
    keyFilename: getKeyFilename(),
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });
  const client = await auth.getClient();
  const databaseName = `projects/${projectId}/databases/${DATABASE_ID}`;
  const getUrl = `https://firestore.googleapis.com/v1/${databaseName}`;

  try {
    await client.request({ url: getUrl });
    console.log(`Firestore database already exists: ${databaseName}`);
    return;
  } catch (error) {
    if (error.response?.status !== 404) {
      throw error;
    }
  }

  const createUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases?databaseId=${encodeURIComponent(
    DATABASE_ID,
  )}`;
  const response = await client.request({
    url: createUrl,
    method: 'POST',
    data: {
      locationId: config.firebase.firestoreLocation,
      type: 'FIRESTORE_NATIVE',
    },
  });

  const operation = await waitForOperation(client, response.data.name);

  if (operation.error) {
    throw new Error(operation.error.message);
  }

  console.log(`Firestore database created: ${databaseName}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.stack || error.message);
    process.exit(1);
  });
