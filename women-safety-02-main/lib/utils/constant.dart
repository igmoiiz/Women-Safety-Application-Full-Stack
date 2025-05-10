import 'package:flutter/material.dart';
import 'package:women_safety/utils/public_washroom.dart';

final List<PublicWashroom> predefinedWashrooms = [
  PublicWashroom(
    id: '1',
    name: 'Air University Multan Campus – Admin Block Washroom',
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Chak-5 Faiz, Bahawalpur Road',
    city: 'Multan',
    isVerified: true,
    type: 'university',
    rating: 4.0,
  ),

  PublicWashroom(
    id: '2',
    name: 'AUMC Library Washroom',
    latitude: 29.1918,
    longitude: 71.4436,
    address: '3rd–5th Floor, Khan Centre, Abdali Road, Multan Cantt.',
    city: 'Multan',
    isVerified: true,
    type: 'library',
    rating: 4.3,
  ),

  PublicWashroom(
    id: '8',
    name: 'Shell Qasim Pur Service Station – Ladies Washroom',
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Bahawalpur Road, Multan',
    city: 'Multan',
    isVerified: true,
    type: 'service_station',
    rating: 3.6,
  ),

  PublicWashroom(
    id: '3',
    name: 'AUMC Sports Complex Washroom',
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Sports Complex, Bahawalpur Road',
    city: 'Multan',
    isVerified: true,
    type: 'sports',
    rating: 3.9,
  ),

  PublicWashroom(
    id: '4',
    name: 'Academic Block A Washroom',
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Academic Block A, Bahawalpur Road',
    city: 'Multan',
    isVerified: true,
    type: 'academic',
    rating: 4.1,
  ),

  PublicWashroom(
    id: '9',
    name: 'Fortress Stadium',
    latitude: 31.4500,
    longitude: 74.3500,
    address: 'Fortress Stadium',
    city: 'Lahore',
    isVerified: false,
    type: 'public',
    rating: 3.5,
    description: 'Lack of proper lighting and security staff',
  ),

  PublicWashroom(
    id: '5',
    name: 'Student Hostel Block Washroom',
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Hostel Facility, Chak-5 Faiz, Bahawalpur Road',
    city: 'Multan',
    isVerified: true,
    type: 'hostel',
    rating: 3.8,
  ),

  PublicWashroom(
    id: '6',
    name: 'Khan Centre Mall – Ladies Washroom',
    latitude: 30.1918,
    longitude: 71.4436,
    address: 'Abdali Road, Multan Cantt.',
    city: 'Multan',
    isVerified: true,
    type: 'mall',
    rating: 4.2,
  ),

  PublicWashroom(
    id: '10',
    name: 'Jinnah Airport',
    latitude: 24.9060,
    longitude: 67.1608,
    address: 'Karachi Airport',
    city: 'Karachi',
    isVerified: false,
    type: 'public',
    rating: 4.1,
    description: 'Isolated location during late hours',
  ),
  PublicWashroom(
    id: '11',
    name: 'Clifton Beach',
    latitude: 24.8500,
    longitude: 66.9900,
    address: 'Clifton Beach',
    city: 'Karachi',
    isVerified: false,
    type: 'public',
    rating: 3.2,
    description: 'Reports of harassment in evening hours',
  ),

  PublicWashroom(
    id: '7',
    name: "PSO Service Station – Women's Toilet",
    latitude: 29.9687,
    longitude: 71.5060,
    address: 'Main G.T. Road, Multan',
    city: 'Multan',
    isVerified: true,
    type: 'service_station',
    rating: 3.5,
  ),

  PublicWashroom(
    id: '12',
    name: 'Saddar',
    latitude: 33.6005,
    longitude: 73.0680,
    address: 'Saddar, Rawalpindi',
    city: 'Rawalpindi',
    isVerified: false,
    type: 'public',
    rating: 3.6,
    description: 'Inadequate maintenance and poor security',
  ),

  // Peshawar
  PublicWashroom(
    id: '13',
    name: 'Qissa Khwani',
    latitude: 34.0151,
    longitude: 71.5788,
    address: 'Qissa Khwani',
    city: 'Peshawar',
    isVerified: false,
    type: 'public',
    rating: 3.5,
    description: 'Unreliable lock system and poor lighting',
  ),
];

final List<Map<String, dynamic>> options = const [
  {
    "icon": Icons.photo_library_rounded,
    "text": "Photo/video",
    "color": Colors.green,
    "description": "Share photos or videos"
  },
  {
    "icon": Icons.person_add_rounded,
    "text": "Tag people",
    "color": Colors.blue,
    "description": "Tag friends in your post"
  },
  {
    "icon": Icons.emoji_emotions_rounded,
    "text": "Feeling/activity",
    "color": Colors.orange,
    "description": "Share how you're feeling"
  },
  {
    "icon": Icons.location_on_rounded,
    "text": "Check in",
    "color": Colors.red,
    "description": "Add your location"
  },
  {
    "icon": Icons.videocam_rounded,
    "text": "Live video",
    "color": Colors.pink,
    "description": "Share live video"
  },
  {
    "icon": Icons.format_color_fill_rounded,
    "text": "Background colour",
    "color": Colors.teal,
    "description": "Change post background"
  },
  {
    "icon": Icons.camera_rounded,
    "text": "Camera",
    "color": Colors.blueAccent,
    "description": "Take a photo"
  },
];
