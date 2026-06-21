const UserRoles = Object.freeze({
  CUSTOMER: 'customer',
  STAFF: 'staff',
  ADMIN: 'admin',
});

function buildUserModel({ uid, email, displayName, phoneNumber, photoURL, role = UserRoles.CUSTOMER }) {
  return {
    uid,
    email,
    displayName: displayName || '',
    phoneNumber: phoneNumber || '',
    photoURL: photoURL || '',
    dateOfBirth: null,
    gender: '',
    role,
    isActive: true,
  };
}

module.exports = {
  UserRoles,
  buildUserModel,
};
