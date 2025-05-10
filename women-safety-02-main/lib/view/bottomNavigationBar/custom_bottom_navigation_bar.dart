import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/bloc/bottomNavigation/bloc/bottom_navigation_bloc.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/widgets/svg_icon.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            iconPath: 'assets/icons/home.svg',
            label: 'Home',
            index: 0,
            onTap: () => BlocProvider.of<BottomNavigationBloc>(context)
                .add(HomeIconTapped()),
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/icons/plus.svg',
            label: 'Post',
            index: 1,
            onTap: () => BlocProvider.of<BottomNavigationBloc>(context)
                .add(AddIconTapped()),
          ),
          _buildSosNavItem(
            context,
            index: 2,
            onTap: () => BlocProvider.of<BottomNavigationBloc>(context)
                .add(SOSIconTapped()),
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/icons/chat.svg',
            label: 'Chat',
            index: 3,
            onTap: () => BlocProvider.of<BottomNavigationBloc>(context)
                .add(BubbleIconTapped()),
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/icons/person.svg',
            label: 'Profile',
            index: 4,
            onTap: () => BlocProvider.of<BottomNavigationBloc>(context)
                .add(PersonIconTapped()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconPath,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentIndex == index;
    final Color iconColor =
        isSelected ? CustomColor.buttonColor : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomColor.buttonColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: (label == 'Post')
              ? EdgeInsets.symmetric(horizontal: 5)
              : (label == 'Chat')
                  ? EdgeInsets.symmetric(horizontal: 2.5)
                  : EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgIconWidget(
                iconPath: iconPath,
                size: (label == 'Chat') ? 26.0 : 24.0,
                color: iconColor,
                onTap: onTap, // Pass the same onTap callback
                isSelected: isSelected,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosNavItem(
    BuildContext context, {
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: CustomColor.primaryPinkColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CustomColor.primaryPinkColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIconWidget(
              iconPath: 'assets/icons/sos.svg',
              size: 30.0,
              color: Colors.white,
              onTap: onTap, // Pass the same onTap callback
              isSelected: true,
            ),
            Text(
              "SOS",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
