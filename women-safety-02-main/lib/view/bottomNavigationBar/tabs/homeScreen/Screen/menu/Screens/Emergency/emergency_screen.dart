import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/Screens/Emergency/model/custom_emergency_container_model.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/Screens/Emergency/widget/emergency_custom_box.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _itemsAnimationController;
  late Animation<double> _headerScaleAnimation;

  // Track the last tapped emergency service for animation
  String? _lastTappedService;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.easeOutBack),
    );

    _headerAnimationController.forward();
    _itemsAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _itemsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _launchDialer(String number, String title) async {
    setState(() {
      _lastTappedService = title;
    });

    // Format the phone number properly
    String formattedNumber = number.replaceAll('-', '');
    
    // Create the URI with the properly formatted number
    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Try with another approach for some Android devices
        final alternativeUri = Uri.parse('tel:$formattedNumber');
        if (await canLaunchUrl(alternativeUri)) {
          await launchUrl(alternativeUri);
        } else {
          CustomToast.showSnackbar(context, 'Could not launch dialer');
        }
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error launching dialer: ${e.toString()}');
    }

    // Reset the tapped service after a delay
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _lastTappedService = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF9F5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildHeader(),
              _buildEmergencyNote(),
              Expanded(
                child: _buildEmergencyList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: CustomColor.buttonColor,
              ),
            ),
          ),
          Text(
            "Emergency Help",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E5C),
            ),
          ),
          SizedBox(width: 40), // Balance the layout
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _headerScaleAnimation,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomColor.buttonColor,
              CustomColor.buttonColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CustomColor.buttonColor.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/menu_emergency.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Services",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Quick access to help when needed",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildEmergencyNote() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.amber[700],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Tap any service to immediately call for emergency assistance",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.amber[900],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyList() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: customEmergencyContainerModel.length,
      itemBuilder: (context, index) {
        final item = customEmergencyContainerModel[index];

        return AnimatedBuilder(
          animation: _itemsAnimationController,
          builder: (context, child) {
            final delay = index * 0.15;
            final slideAnimation = Tween<Offset>(
              begin: Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _itemsAnimationController,
                curve: Interval(
                  delay.clamp(0.0, 1.0),
                  (delay + 0.5).clamp(0.0, 1.0),
                  curve: Curves.easeOutQuart,
                ),
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _itemsAnimationController,
                curve: Interval(
                  delay.clamp(0.0, 1.0),
                  (delay + 0.5).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
            );

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: EmergencyCustomBox(
                    onTap: () => _launchDialer(item.phoneNumber, item.title),
                    image: item.image,
                    title: item.title,
                    phoneNumber: item.phoneNumber,
                    isHighlighted: _lastTappedService == item.title,
                    color: _getColorForIndex(index),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      Color(0xFFFF5630), // Red for police
      Color(0xFF36B37E), // Green for ambulance
      Color(0xFF0065FF), // Blue for fire brigade
      Color(0xFFFFAB00), // Orange/amber for helpline
      Color(0xFF6554C0), // Purple for virtual police
      Color(0xFF00B8D9), // Cyan for others
    ];
    return colors[index % colors.length];
  }
}
