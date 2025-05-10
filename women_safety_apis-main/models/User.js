const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    required: true,
    unique: true,
  },
  fatherName: {
    type: String,
    required: true,
  },
  cnic: {
    type: String,
    required: true,
  },
  gender: {
    type: String,
    default: "Female",
  },
  bloodGroup: {
    type: String,
    required: true,
  },
  username: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
    // Note: In a production environment, passwords should be hashed
  },
  email: {
    type: String,
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  emergencyPhoneNumber: {
    type: String,
    required: true,
  },
  emergencyEmail: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  }
}, { timestamps: true });

const User = mongoose.model('User', UserSchema);

module.exports = User;
