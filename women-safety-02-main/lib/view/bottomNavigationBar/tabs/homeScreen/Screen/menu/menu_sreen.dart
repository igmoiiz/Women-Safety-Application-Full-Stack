import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/Screen/menu/model/custom_menu_container_model.dart';

class MenuSreen extends StatefulWidget {
  const MenuSreen({super.key});

  @override
  State<MenuSreen> createState() => _MenuSreenState();
}

class _MenuSreenState extends State<MenuSreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // Initialize main fade controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize staggered animation controller for items
    _staggeredController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create intervals for staggered animations
    for (int i = 0; i < customMenuContainerlist.length; i++) {
      final start = i * 0.1;
      _itemSlideIntervals.add(
        Interval(start, start + 0.6, curve: Curves.easeOutQuart),
      );
    }

    _fadeController.forward();
    _staggeredController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  // Get filtered menu items based on search query
  List<CustomMenuContainerModel> get _filteredMenuItems {
    if (_searchQuery.isEmpty) {
      return customMenuContainerlist;
    }
    return customMenuContainerlist.where((item) {
      final title = item.title.toLowerCase();
      return title.startsWith(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF5F7FF),
              Color(0xFFF0F4FF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                _buildHeader(),
                Expanded(
                  child: _buildMenuList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: CustomColor.buttonColor,
                size: 22,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: CustomColor.buttonColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Menu',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3E5C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose your safety features',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF8F9BB3),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _searchController,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Search features',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFFA0A5BD),
                ),
                prefixIcon: Icon(Icons.search, color: CustomColor.buttonColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final menuItems = _filteredMenuItems;

    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: CustomColor.buttonColor.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No features found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF8F9BB3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      physics: BouncingScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final originalIndex = customMenuContainerlist.indexOf(item);

        return AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationValue = _itemSlideIntervals[originalIndex]
                .transform(_staggeredController.value);
            final slideAnimation = Tween<Offset>(
              begin: Offset(0.3, 0),
              end: Offset.zero,
            ).transform(animationValue);

            final opacityAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).transform(animationValue);

            final scaleAnimation = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).transform(animationValue);

            return Opacity(
              opacity: opacityAnimation,
              child: Transform.translate(
                offset: slideAnimation,
                child: Transform.scale(
                  scale: scaleAnimation,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pushNamed(context, item.route),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getColorForIndex(originalIndex)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Image.asset(
                                  item.image,
                                  width: 30,
                                  height: 30,
                                  color: _getColorForIndex(originalIndex),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E3E5C),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _getDescriptionForItem(originalIndex),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Color(0xFF8F9BB3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: CustomColor.buttonColor,
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
          },
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      CustomColor.buttonColor,
      Color(0xFF00B8D9),
      Color(0xFFFF5630),
      Color(0xFF36B37E),
      Color(0xFFFFAB00),
      Color(0xFF6554C0),
    ];
    return colors[index % colors.length];
  }

  String _getDescriptionForItem(int index) {
    List<String> descriptions = [
      'Quickly send alerts to your emergency contacts',
      'Track your journey in real time for safety',
      'Contact emergency services instantly',
      'Access safety training and resources',
      'Share your current location with trusted contacts',
      'Learn self-defense techniques and tips',
    ];
    return descriptions[index % descriptions.length];
  }
}
