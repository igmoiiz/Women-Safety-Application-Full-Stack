import 'package:flutter/material.dart';

class LoadingOverlay {
  BuildContext _context;

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }

  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  void show() {
    if (_isVisible) return;
    
    _isVisible = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE49AB0)),
          ),
        ),
      ),
    );

    Overlay.of(_context).insert(_overlayEntry!);
  }

  void hide() {
    if (!_isVisible) return;
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }
}
