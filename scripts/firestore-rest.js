const { GoogleAuth } = require('google-auth-library');

const config = require('../src/config/env');
const { getFirebaseProjectId } = require('../src/config/firebase');

const DATABASE_ID = encodeURIComponent('(default)');

function getKeyFilename() {
  return config.firebase.serviceAccountPath || undefined;
}

async function getClient() {
  const auth = new GoogleAuth({
    keyFilename: getKeyFilename(),
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });

  return auth.getClient();
}

function getDocumentsBaseUrl(projectId) {
  return `https://firestore.googleapis.com/v1/projects/${projectId}/databases/${DATABASE_ID}/documents`;
}

function encodeValue(value) {
  if (value === null || value === undefined) {
    return { nullValue: null };
  }

  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }

  if (typeof value === 'string') {
    return { stringValue: value };
  }

  if (typeof value === 'boolean') {
    return { booleanValue: value };
  }

  if (typeof value === 'number') {
    if (Number.isInteger(value)) {
      return { integerValue: String(value) };
    }

    return { doubleValue: value };
  }

  if (Array.isArray(value)) {
    return {
      arrayValue: {
        values: value.map(encodeValue),
      },
    };
  }

  return {
    mapValue: {
      fields: encodeFields(value),
    },
  };
}

function encodeFields(record) {
  return Object.fromEntries(
    Object.entries(record)
      .filter(([, value]) => value !== undefined)
      .map(([key, value]) => [key, encodeValue(value)]),
  );
}

function decodeValue(value) {
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return null;
  if ('arrayValue' in value) return (value.arrayValue.values || []).map(decodeValue);
  if ('mapValue' in value) return decodeFields(value.mapValue.fields || {});
  return undefined;
}

function decodeFields(fields) {
  return Object.fromEntries(Object.entries(fields).map(([key, value]) => [key, decodeValue(value)]));
}

async function upsertDocument(collectionName, documentId, data) {
  const projectId = getFirebaseProjectId();
  const client = await getClient();
  const url = `${getDocumentsBaseUrl(projectId)}/${collectionName}/${documentId}`;

  await client.request({
    url,
    method: 'PATCH',
    data: {
      fields: encodeFields(data),
    },
  });
}

async function listDocuments(collectionName, pageSize = 10) {
  const projectId = getFirebaseProjectId();
  const client = await getClient();
  const url = `${getDocumentsBaseUrl(projectId)}/${collectionName}?pageSize=${pageSize}`;
  const response = await client.request({ url });

  return (response.data.documents || []).map((document) => ({
    id: document.name.split('/').at(-1),
    ...decodeFields(document.fields || {}),
  }));
}

module.exports = {
  listDocuments,
  upsertDocument,
};
