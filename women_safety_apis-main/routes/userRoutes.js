const express = require('express');
const router = express.Router();
const User = require('../models/User');

// POST /api/users - Create a new user
router.post('/', async (req, res) => {
  try {
    const { firebaseUid } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ firebaseUid });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this Firebase UID'
      });
    }

    // Create new user
    const newUser = new User(req.body);
    await newUser.save();

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: newUser
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating user',
      error: error.message
    });
  }
});

// GET /api/users/:firebaseUid - Get a user by Firebase UID
router.get('/:firebaseUid', async (req, res) => {
  try {
    const { firebaseUid } = req.params;
    
    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching user',
      error: error.message
    });
  }
});

// PUT /api/users/:firebaseUid - Update user data
router.put('/:firebaseUid', async (req, res) => {
  try {
    const { firebaseUid } = req.params;
    
    const updatedUser = await User.findOneAndUpdate(
      { firebaseUid },
      { ...req.body, updatedAt: Date.now() },
      { new: true, runValidators: true }
    );

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'User updated successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating user',
      error: error.message
    });
  }
});


module.exports = router;
