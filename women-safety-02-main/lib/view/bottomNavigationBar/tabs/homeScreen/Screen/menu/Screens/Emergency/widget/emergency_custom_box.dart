import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyCustomBox extends StatefulWidget {
  final String title;
  final String image;
  final String phoneNumber;
  final Color color;
  final void Function()? onTap;
  final bool isHighlighted;

  const EmergencyCustomBox({
    required this.image,
    required this.title,
    required this.phoneNumber,
    this.onTap,
    this.isHighlighted = false,
    this.color = const Color(0xFF6554C0),
    super.key,
  });

  @override
  State<EmergencyCustomBox> createState() => _EmergencyCustomBoxState();
}

class _EmergencyCustomBoxState extends State<EmergencyCustomBox>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EmergencyCustomBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.forward();
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) _controller.reverse();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isPressed ? 0.25 : 0.15),
                  blurRadius: _isPressed ? 12 : 8,
                  offset: Offset(0, _isPressed ? 2 : 4),
                  spreadRadius: _isPressed ? 1 : 0,
                ),
              ],
              border: _isPressed
                  ? Border.all(color: widget.color.withOpacity(0.3))
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) {
                  setState(() {
                    _isPressed = true;
                  });
                  _controller.forward();
                },
                onTapUp: (_) {
                  setState(() {
                    _isPressed = false;
                  });
                  _controller.reverse();
                },
                onTapCancel: () {
                  setState(() {
                    _isPressed = false;
                  });
                  _controller.reverse();
                },
                borderRadius: BorderRadius.circular(16),
                splashColor: widget.color.withOpacity(0.15),
                highlightColor: widget.color.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Left side - Icon and service name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Service icon with colored background
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              widget.image,
                              height: 28,
                              width: 28,
                            ),
                          ),
                          SizedBox(width: 14),
                          // Service name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title.length > 13
                                    ? widget.title.substring(0, 13) + "..."
                                    : widget.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E3E5C),
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.phoneNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Spacer(),

                      // Call button
                      IconButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 229, 245, 255),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 11),
                          elevation: _isPressed ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.phone,
                          size: 20,
                          color: Color.fromARGB(255, 10, 80, 89),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
