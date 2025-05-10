import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/services/api/mongodb_api_service.dart';

String username = '';

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  static Color buttonColor = Color(0xFFE49AB0);
  static Color primaryPinkColor = Color(0xFFBD607C);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String email = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      phoneNumber = prefs.getString('phoneNumber') ?? '';
    });
  }

  Future<void> updateUserData(String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    String tempValue = value;
    if (user != null) {
      try {
        // use temp value

        setState(() {
          if (field == 'username') username = value;
          if (field == 'email') email = value;
          if (field == 'phoneNumber') phoneNumber = value;
        });

        // Update MongoDB
        var (result, val) =
            await MongoDBApiService().updateUserData({field: value}, user.uid);
        if (result) {
          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(field, value);
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            // Update state
            setState(() {
              if (field == 'username') username = tempValue;
              if (field == 'email') email = tempValue;
              if (field == 'phoneNumber') phoneNumber = tempValue;
            });
          }
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            if (field == 'username') username = tempValue;
            if (field == 'email') email = tempValue;
            if (field == 'phoneNumber') phoneNumber = tempValue;
          });
        }
      }
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE49AB0),
                  Color(0xFFD85A5A),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Color(0xFFE49AB0),
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.length > 20
                      ? username.substring(0, 20) + '..'
                      : username,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFFE49AB0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFFE49AB0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      email.length > 12 ? email.substring(0, 12) + '..' : email,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, String field, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE49AB0).withOpacity(0.1),
                  Color(0xFFD85A5A).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AccountScreen.primaryPinkColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.length > 15 ? value.substring(0, 15) + '...' : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: AccountScreen.primaryPinkColor,
              size: 20,
            ),
            onPressed: () async {
              String? newValue = await _showEditDialog(title, value);
              if (newValue != null &&
                  newValue.isNotEmpty &&
                  newValue != value) {
                updateUserData(field, newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _showEditDialog(String title, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    return showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Edit $title'),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Container(
            color: CupertinoColors.white,
            child: CupertinoTextField(
              controller: controller,
              padding: EdgeInsets.all(10),
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 16,
              ),
              maxLength: title == 'Phone Number' ? 11 : null,
              keyboardType:
                  title == 'Phone Number' ? TextInputType.phone : null,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: AccountScreen.primaryPinkColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AccountScreen.primaryPinkColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 55),
              _buildInfoTile('Username', username, 'username', Icons.person),
              _buildInfoTile('Email', email, 'email', Icons.email),
              _buildInfoTile(
                  'Phone Number', phoneNumber, 'phoneNumber', Icons.phone),
              // SizedBox(height: 30),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Add any additional settings or actions
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AccountScreen.buttonColor,
              //       padding: EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: Text(
              //       'Edit Profile',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
