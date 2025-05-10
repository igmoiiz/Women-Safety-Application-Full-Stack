import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  ProfileHeader({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
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
          // Avatar with gradient border
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
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  color: Color(0xFFE49AB0),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE49AB0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.poppins(
                          color: Color(0xFFE49AB0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'User Profile',
                      style: GoogleFonts.poppins(
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
}
