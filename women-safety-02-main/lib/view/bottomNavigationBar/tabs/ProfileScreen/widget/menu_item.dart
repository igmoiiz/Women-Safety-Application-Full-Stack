import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE49AB0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFFE49AB0)),
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
