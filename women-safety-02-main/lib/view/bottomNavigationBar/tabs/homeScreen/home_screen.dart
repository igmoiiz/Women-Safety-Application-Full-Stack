import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/widget/InstagramStylePost/Instagram_style_post.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/widget/safety_tip_card.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/all_safety_tips_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<Animation<double>> _scaleAnimations = [];
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Create a new list that we'll shuffle
  late List<Map<String, String>> _displayedSafetyTips;

  final List<Map<String, String>> safetyTips = [
    {
      'title': 'Trust Your Instincts',
      'description':
          'If something feels wrong, it probably is. Always trust your gut feeling.',
    },
    {
      'title': 'Stay Connected',
      'description':
          'Share your location with trusted friends when going to new places.',
    },
    {
      'title': 'Be Aware of Surroundings',
      'description':
          'Stay alert and avoid distractions like texting while walking alone.',
    },
    {
      'title': 'Use Emergency SOS',
      'description':
          'Learn how to quickly activate emergency features on your phone.',
    },
    {
      'title': 'Plan Your Route',
      'description':
          "Know where you're going and stick to well-lit, populated areas.",
    },
    {
      'title': 'Self-Defense Basics',
      'description':
          'Learn simple self-defense techniques to protect yourself if needed.',
    },
    {
      'title': 'Public Transport Safety',
      'description':
          'Sit near the driver and avoid empty compartments when traveling alone.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the displayed tips with a shuffled copy
    _displayedSafetyTips = List.from(safetyTips)..shuffle();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Create scale animations for each action button
    for (int i = 0; i < 3; i++) {
      _scaleAnimations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (0.1 * i),
            0.6 + (0.1 * i),
            curve: Curves.easeOutBack,
          ),
        )),
      );
    }

    _animationController.forward();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;

      // Shuffle safety tips on refresh
      _displayedSafetyTips = List.from(safetyTips)..shuffle();
    });

    // Simulate network request
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
    return Future.value();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(7),
                _buildAppBarExtension(),
                verticalSpace(16),
                _buildActionButtons(),
                _buildSafetyTipsSection(),
                verticalSpace(16),
                _buildSectionTitle('Community Stories'),
                verticalSpace(6),
                InstagramStylePost(),
                // Add some bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      titleSpacing: 0,
      title: Hero(
        tag: 'app_title',
        child: Material(
          color: Colors.transparent,
          child: Text(
            "She's Own Safety",
            style: GoogleFonts.playfairDisplay(
              color: CustomColor.buttonColor,
              fontSize: 27,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.only(left: 3, right: 6, top: 3, bottom: 3),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            CupertinoIcons.bars,
            size: 24,
            color: Colors.grey[800],
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/bottomNavigation/home/MenuSreen');
          },
          tooltip: 'Menu',
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 3, left: 6, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.bell,
                  size: 22,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/bottomNavigation/home/NotificationScreen');
                },
                tooltip: 'Notifications',
              ),
              Container(
                margin: EdgeInsets.only(top: 8, right: 10),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CustomColor.buttonColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarExtension() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 21, bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColor.buttonColor.withOpacity(0.1),
            CustomColor.buttonColor.withOpacity(0.2),
            CustomColor.buttonColor.withOpacity(0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CustomColor.buttonColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 28,
                    color: CustomColor.buttonColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: CustomColor.primaryPinkColor,
                      ),
                    ),
                    Text(
                      'Stay safe and connected with your community.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date and weather information row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: CustomColor.buttonColor.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCurrentDate(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(
                  _getWeatherIcon(),
                  size: 18,
                  color: CustomColor.buttonColor.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Stay Safe Today',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    // Could be integrated with a weather API in the future
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 18) {
      return Icons.wb_sunny_rounded; // Daytime
    } else {
      return Icons.nights_stay_rounded; // Nighttime
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Get short day name
    String dayName = weekdays[(now.weekday - 1) % 7].substring(0, 3);

    return '$dayName, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildActionButtons() {
    // Button configurations with icons and colors
    final List<Map<String, dynamic>> buttons = [
      {
        'title': 'Pink Area',
        'subtitle': 'Safe zones',
        'icon': 'assets/images/homeDoor.png',
        'color': CustomColor.buttonColor,
        'route': '/bottomNavigation/home/PinkArea',
      },
      {
        'title': 'Red Area',
        'subtitle': 'Alert zones',
        'icon': Icons.shield_outlined,
        'color': Colors.blue[700]!,
        'route': '/bottomNavigation/home/RedArea',
      },
      {
        'title': 'Locate',
        'subtitle': 'Find help',
        'icon': Icons.location_on_rounded,
        'color': Colors.orange[700]!,
        'route': '/bottomNavigation/home/locateScreen',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      // margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 14, top: 7),
            child: Row(
              children: [
                Container(
                  height: 24,
                  width: 4,
                  decoration: BoxDecoration(
                    color: CustomColor.buttonColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                horizontalSpace(8),
                Text(
                  "Quick Actions",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CustomColor.primaryPinkColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(4),
          SizedBox(
            height: 100, // Decreased height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: buttons.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                return _buildAnimatedQuickAction(
                  index: index,
                  data: buttons[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedQuickAction({
    required int index,
    required Map<String, dynamic> data,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimations[index],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildQuickAction(data),
        ),
      ),
    );
  }

  Widget _buildQuickAction(Map<String, dynamic> data) {
    final Color color = data['color'];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, data['route']);
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: data['icon'] is String
                  ? Image.asset(
                      data['icon'],
                      width: 22,
                      height: 22,
                      color: color,
                    )
                  : Icon(
                      data['icon'],
                      size: 22,
                      color: color,
                    ),
            ),

            const SizedBox(width: 14),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['subtitle'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Safety Tips'),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            key: ValueKey<bool>(_isRefreshing),
            height: 180,
            child: _isRefreshing
                ? Center(
                    child: CircularProgressIndicator(
                      color: CustomColor.buttonColor,
                      strokeWidth: 2,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: _displayedSafetyTips.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: SafetyTipCard(
                          title: _displayedSafetyTips[index]['title'] ?? '',
                          description:
                              _displayedSafetyTips[index]['description'] ?? '',
                          index: index,
                          heroTag: 'safety_tip_card_$index',
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: CustomColor.buttonColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CustomColor.primaryPinkColor,
            ),
          ),
          Spacer(),
          if (title == 'Safety Tips')
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllSafetyTipsScreen(safetyTips: safetyTips),
                  ),
                );
              },
              child: Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CustomColor.buttonColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
