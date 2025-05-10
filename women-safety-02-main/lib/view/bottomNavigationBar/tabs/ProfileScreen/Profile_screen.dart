import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/services/firebase_auth/firebase_auth_methods.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/widget/menu_item.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/widget/profile_header.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/AboutScreen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/screen/Settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;
  String username = 'User'; // Initialize with default value

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.person_outline,
      'text': 'Account',
      'routes': '/bottomNavigation/PersonScreen/AccountScreen'
    },
    {
      'icon': Icons.info_outline,
      'text': 'About',
      'routes': '/bottomNavigation/PersonScreen/AboutScreen'
    },
    {'icon': Icons.settings_outlined, 'text': 'Settings', 'routes': ''},
    {
      'icon': Icons.bookmark_border_rounded,
      'text': 'Save Posts',
      'routes': '/bottomNavigation/PersonScreen/SavePostScreen'
    },
  ];

  Future<void> _getSPvalue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  void initState() {
    super.initState();
    _getSPvalue();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _itemAnimations = List.generate(
      _menuItems.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1),
            (index * 0.1) + 0.5,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[50],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              verticalSpace(20),
              ProfileHeader(username: username),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  physics: BouncingScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _itemAnimations[index],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.5, 0),
                          end: Offset.zero,
                        ).animate(_itemAnimations[index]),
                        child: MenuItem(
                          icon: _menuItems[index]['icon'],
                          text: _menuItems[index]['text'],
                          onTap: () {
                            if (_menuItems[index]['text'] == 'Settings') {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SettingsScreen(),
                                ),
                              );
                            } else if (_menuItems[index]['text'] == 'About') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutScreen(),
                                ),
                              );
                            } else {
                              Navigator.pushNamed(
                                      context, _menuItems[index]['routes'])
                                  .then((value) {
                                // Refresh data when returning from any screen
                                _getSPvalue();
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseAuthMethods().signOut(context);
                      },
                      child: Text('Logout'),
                    ),
                  ],
                );
              },
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFD85A5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Color(0xFFD85A5A), width: 0.7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFD85A5A),
              ),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
