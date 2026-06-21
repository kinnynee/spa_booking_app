const createError = require('http-errors');
const { getAuth } = require('../config/firebase');
const userRepository = require('../repositories/user.repository');
const { buildUserModel, UserRoles } = require('../models/user.model');
const { toUserDto } = require('../dto/user.dto');

async function register(payload) {
  const existingProfile = await userRepository.findByEmail(payload.email);
  if (existingProfile) throw createError(409, 'Email is already registered');

  const firebaseUser = await getAuth().createUser({
    email: payload.email,
    password: payload.password,
    displayName: payload.displayName,
    phoneNumber: payload.phoneNumber || undefined,
    emailVerified: false,
    disabled: false,
  });

  await getAuth().setCustomUserClaims(firebaseUser.uid, {
    role: UserRoles.CUSTOMER,
  });

  const profile = await userRepository.createProfile(
    buildUserModel({
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      photoURL: firebaseUser.photoURL,
      role: UserRoles.CUSTOMER,
    })
  );

  return toUserDto(profile);
}

module.exports = {
  register,
};
