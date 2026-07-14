const { getFirebaseProjectId } = require('../src/config/firebase');
const { listDocuments } = require('./firestore-rest');

async function main() {
  const projectId = getFirebaseProjectId();

  if (!projectId) {
    throw new Error('Missing FIREBASE_PROJECT_ID or project_id in service account.');
  }

  const services = await listDocuments('services');
  const categories = await listDocuments('serviceCategories');
  const appointments = await listDocuments('appointments');

  console.log(`Firebase project: ${projectId}`);
  console.log(`serviceCategories found: ${categories.length}`);
  console.log(`services found: ${services.length}`);
  console.log(`appointments found: ${appointments.length}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.stack || error.message);
    process.exit(1);
  });
