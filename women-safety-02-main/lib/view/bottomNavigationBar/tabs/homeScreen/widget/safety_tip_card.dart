import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class SafetyTipCard extends StatelessWidget {
  final String title;
  final String description;
  final int index;
  final String heroTag;

  SafetyTipCard({
    Key? key,
    required this.title,
    required this.description,
    required this.index,
    this.heroTag = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate a different color for each card based on index
    final List<Color> cardColors = [
      CustomColor.buttonColor.withOpacity(0.12),
      Colors.blue.withOpacity(0.12),
      Colors.orange.withOpacity(0.12),
      Colors.green.withOpacity(0.12),
      Colors.purple.withOpacity(0.12),
    ];

    final Color cardColor = cardColors[index % cardColors.length];

    return Hero(
      tag: heroTag.isNotEmpty ? heroTag : 'safety_tip_$index',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFullTipDialog(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 280,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: CustomColor.buttonColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showFullTipDialog(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            'Read More',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: CustomColor.buttonColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullTipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CustomColor.buttonColor,
                            CustomColor.buttonColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: CustomColor.buttonColor,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              alignment: Alignment.centerLeft,
                              height: 55,
                              child: Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Color(0xFF424242),
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: CustomColor.buttonColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Got It',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
