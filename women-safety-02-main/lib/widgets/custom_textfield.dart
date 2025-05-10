import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final int? maxLength;
  final String? errorText; // Added error text parameter

  const CustomTextField({
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.keyboardType,
    this.inputFormatters,
    this.isPassword = false,
    this.maxLength,
    this.errorText, // Added error text parameter
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onEditingComplete: widget.onEditingComplete,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword ? _obscureText : false,
      maxLength: widget.maxLength,
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: CustomColor.secondaryDarkColor,
      ),
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: CustomColor.lightDarkColor,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: CustomColor.lightSkyblueColor,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.roboto(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: CustomColor.secondaryDarkColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        // Add error styling and text
        errorText: widget.errorText,
        errorStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.red,
        ),
        // Add red border when error is present
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: widget.errorText != null
              ? BorderSide(color: Colors.red, width: 1.0)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: widget.errorText != null
              ? BorderSide(color: Colors.red, width: 1.5)
              : BorderSide(color: Colors.transparent, width: 1.5),
        ),
      ),
    );
  }
}
