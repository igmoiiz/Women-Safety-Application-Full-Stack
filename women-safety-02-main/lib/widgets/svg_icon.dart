import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconWidget extends StatelessWidget {
  final String iconPath;
  final double size;
  final Color color;
  final VoidCallback? onTap; // Make this nullable
  final bool isSelected;

  const SvgIconWidget({
    Key? key,
    required this.iconPath,
    required this.size,
    required this.color,
    required this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If onTap is null, just return the SVG without a GestureDetector
    if (onTap == null) {
      return SvgPicture.asset(
        iconPath,
        height: size,
        width: size,
        color: color,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SvgPicture.asset(
        iconPath,
        height: size,
        width: size,
        color: color,
      ),
    );
  }
}
