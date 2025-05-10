import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety/utils/size.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar completely
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppInfo(),
                    SizedBox(height: 30),
                    _buildFeatureSection(context),
                    SizedBox(height: 30),
                    _buildHowToUseSection(context),
                    SizedBox(height: 30),
                    _buildVersionInfo(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: 280, // Increased height to accommodate status bar
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE49AB0), Color(0xFFD85A5A)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE49AB0).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative elements for visual appeal
              Positioned(
                top: 20,
                left: -15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Add back button in the SafeArea
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'About Us',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Safety First, Always',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 20,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 75,
                  height: 75,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.shield,
                    size: 60,
                    color: Color(0xFFD85A5A),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Container(
      margin: EdgeInsets.only(
          top: 60), // Increase top margin to accommodate the overlapping logo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Our Mission'),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Text(
              'Our mission is to empower women through technology by providing a comprehensive safety application with immediate emergency response, location sharing, and safety resources.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.emergency,
        'title': 'Emergency SOS',
        'desc': 'Send quick alerts to emergency contacts with your location'
      },
      {
        'icon': Icons.location_on,
        'title': 'Location Sharing',
        'desc': 'Share your real-time location with trusted contacts'
      },
      {
        'icon': Icons.library_books,
        'title': 'Safety Resources',
        'desc': 'Access useful safety information and guidelines'
      },
      {
        'icon': Icons.people,
        'title': 'Community Support',
        'desc': 'Connect with a network of supportive individuals'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Key Features'),
        SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['desc'] as String,
            )),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE49AB0).withOpacity(0.2),
                    Color(0xFFD85A5A).withOpacity(0.2)
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color(0xFFD85A5A),
                size: 28,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToUseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('How to Use'),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHowToItem(
                '1',
                'Set up your profile and emergency contacts',
                'Add trusted contacts who will be notified in case of emergency.',
              ),
              Divider(
                  height: 30,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2)),
              _buildHowToItem(
                '2',
                'Configure SOS settings',
                'Customize your SOS trigger and notification preferences.',
              ),
              Divider(
                  height: 30,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2)),
              _buildHowToItem(
                '3',
                'Explore safety resources',
                'Access guides and tips to stay safe in different situations.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowToItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFE49AB0), Color(0xFFD85A5A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE49AB0).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title, String detail) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE49AB0).withOpacity(0.2),
                Color(0xFFD85A5A).withOpacity(0.2)
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFFD85A5A), size: 24),
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              detail,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFFD85A5A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            '© 2023 Women Safety App',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'All rights reserved',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFFD85A5A),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
