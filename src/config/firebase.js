const fs = require('fs');
const path = require('path');

const admin = require('firebase-admin');
const { applicationDefault, cert, getApp, getApps, initializeApp } = require('firebase-admin/app');
const { getAuth: getAdminAuth } = require('firebase-admin/auth');
const {
  getFirestore: getAdminFirestore,
  initializeFirestore,
} = require('firebase-admin/firestore');
const { getStorage: getAdminStorage } = require('firebase-admin/storage');

const config = require('./env');

let firebaseApp;
let cachedServiceAccount;
let firestore;

function hasInlineServiceAccount() {
  return Boolean(
    config.firebase.projectId && config.firebase.clientEmail && config.firebase.privateKey,
  );
}

function resolveServiceAccountPath() {
  if (!config.firebase.serviceAccountPath) {
    return null;
  }

  return path.isAbsolute(config.firebase.serviceAccountPath)
    ? config.firebase.serviceAccountPath
    : path.resolve(process.cwd(), config.firebase.serviceAccountPath);
}

function getServiceAccount() {
  if (cachedServiceAccount) {
    return cachedServiceAccount;
  }

  const serviceAccountPath = resolveServiceAccountPath();

  if (!serviceAccountPath) {
    return null;
  }

  cachedServiceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
  return cachedServiceAccount;
}

function buildCredential() {
  const serviceAccount = getServiceAccount();

  if (serviceAccount) {
    return cert(serviceAccount);
  }

  if (hasInlineServiceAccount()) {
    return cert({
      projectId: config.firebase.projectId,
      clientEmail: config.firebase.clientEmail,
      privateKey: config.firebase.privateKey,
    });
  }

  return applicationDefault();
}

function configureEmulators() {
  if (!config.firebase.useEmulator) {
    return;
  }

  process.env.FIRESTORE_EMULATOR_HOST = config.firebase.firestoreEmulatorHost;
  process.env.FIREBASE_AUTH_EMULATOR_HOST = config.firebase.authEmulatorHost;
}

function getFirebaseProjectId() {
  return config.firebase.projectId || getServiceAccount()?.project_id;
}

function getFirebaseApp() {
  if (firebaseApp) return firebaseApp;

  if (getApps().length) {
    firebaseApp = getApp();
    return firebaseApp;
  }

  configureEmulators();

  firebaseApp = initializeApp({
    credential: buildCredential(),
    projectId: getFirebaseProjectId() || undefined,
    storageBucket: config.firebase.storageBucket || undefined,
  });

  return firebaseApp;
}

function getFirestore() {
  if (!firestore) {
    try {
      firestore = initializeFirestore(getFirebaseApp(), { preferRest: true });
    } catch (_error) {
      firestore = getAdminFirestore(getFirebaseApp());
    }
  }

  return firestore;
}

function getAuth() {
  return getAdminAuth(getFirebaseApp());
}

function getStorage() {
  return getAdminStorage(getFirebaseApp());
}

module.exports = {
  admin,
  getAuth,
  getFirebaseApp,
  getFirebaseProjectId,
  getFirestore,
  getServiceAccount,
  getStorage,
};
