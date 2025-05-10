import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/widget/safety_tip_card.dart';

class AllSafetyTipsScreen extends StatefulWidget {
  final List<Map<String, String>> safetyTips;

  const AllSafetyTipsScreen({Key? key, required this.safetyTips})
      : super(key: key);

  @override
  _AllSafetyTipsScreenState createState() => _AllSafetyTipsScreenState();
}

class _AllSafetyTipsScreenState extends State<AllSafetyTipsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;
  late List<Map<String, String>> _displayedTips;

  @override
  void initState() {
    super.initState();
    _displayedTips = List.from(widget.safetyTips);

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _itemAnimations = List.generate(
      _displayedTips.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1 > 0.6 ? 0.6 : index * 0.1,
            min(0.1 + index * 0.1, 1.0),
            curve: Curves.easeOutBack,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CustomColor.buttonColor.withOpacity(0.15),
        leading: Container(
          margin: EdgeInsets.only(left: 8, top: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: CustomColor.primaryPinkColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            'Safety Tips',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CustomColor.primaryPinkColor,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColor.buttonColor.withOpacity(0.15),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _displayedTips.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Fix for opacity value by ensuring it's within valid range
                      final double opacityValue =
                          _itemAnimations[index].value.clamp(0.0, 1.0);

                      return Transform.translate(
                        offset: Offset(
                          0,
                          50 * (1 - _itemAnimations[index].value),
                        ),
                        child: Opacity(
                          opacity: opacityValue,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: (index == 0)
                          ? EdgeInsets.only(bottom: 16, top: 10)
                          : EdgeInsets.only(bottom: 16),
                      child: _buildFullWidthCard(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthCard(int index) {
    // Calculate a different color for each card based on index
    final List<Color> cardColors = [
      CustomColor.buttonColor.withOpacity(0.12),
      Colors.blue.withOpacity(0.12),
      Colors.orange.withOpacity(0.12),
      Colors.green.withOpacity(0.12),
      Colors.purple.withOpacity(0.12),
    ];

    final Color cardColor = cardColors[index % cardColors.length];
    final String title = _displayedTips[index]['title'] ?? '';
    final String description = _displayedTips[index]['description'] ?? '';

    return Hero(
      tag: 'all_safety_tips_$index',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardColor,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFullTipDialog(context, title, description),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForIndex(index),
                            color: _getColorForIndex(index),
                            size: 28,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final List<Color> colors = [
      CustomColor.buttonColor,
      Colors.blue[700]!,
      Colors.orange[700]!,
      Colors.green[700]!,
      Colors.purple[700]!,
    ];

    return colors[index % colors.length];
  }

  IconData _getIconForIndex(int index) {
    final List<IconData> icons = [
      Icons.lightbulb_outline,
      Icons.location_on_outlined,
      Icons.shield_outlined,
      Icons.phone_outlined,
      Icons.notifications_active_outlined,
      Icons.route_outlined,
      Icons.person_outline,
    ];

    return icons[index % icons.length];
  }

  void _showFullTipDialog(
      BuildContext context, String title, String description) {
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
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
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
