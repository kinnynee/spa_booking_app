const createError = require('http-errors');
const { getAuth } = require('../config/firebase');
const userRepository = require('../repositories/user.repository');
const { buildUserModel } = require('../models/user.model');
const { toUserDto } = require('../dto/user.dto');

async function getOrCreateCurrentUser(authUser) {
  const existingProfile = await userRepository.findById(authUser.uid);
  if (existingProfile) return toUserDto(existingProfile);

  const profile = await userRepository.createProfile(
    buildUserModel({
      uid: authUser.uid,
      email: authUser.email,
      role: authUser.role,
    })
  );

  return toUserDto(profile);
}

async function updateMe(uid, payload) {
  const existingProfile = await userRepository.findById(uid);
  if (!existingProfile) throw createError(404, 'User profile not found');

  const updatedProfile = await userRepository.update(uid, payload);
  return toUserDto(updatedProfile);
}

async function uploadAvatar(uid, file, staticBaseUrl) {
  if (!file) throw createError(400, 'Avatar image is required');

  const photoURL = `${staticBaseUrl}/uploads/${file.filename}`;
  const updatedProfile = await userRepository.update(uid, { photoURL });
  await getAuth().updateUser(uid, { photoURL });

  return toUserDto(updatedProfile);
}

async function listUsers(query) {
  const users = await userRepository.listUsers(query);
  return users.map(toUserDto);
}

async function setUserRole(uid, role) {
  const existingProfile = await userRepository.findById(uid);
  if (!existingProfile) throw createError(404, 'User profile not found');

  await getAuth().setCustomUserClaims(uid, { role });
  const updatedProfile = await userRepository.update(uid, { role });
  return toUserDto(updatedProfile);
}

module.exports = {
  getOrCreateCurrentUser,
  listUsers,
  setUserRole,
  updateMe,
  uploadAvatar,
};
