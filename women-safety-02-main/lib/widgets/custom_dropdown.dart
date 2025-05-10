import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class CustomDropdown extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final List<String> items;
  final String? errorText;
  final FocusNode? focusNode;

  const CustomDropdown({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.items,
    this.errorText,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CustomColor.lightSkyblueColor,
            borderRadius: BorderRadius.circular(8),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : Border.all(color: Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              focusNode: focusNode,
              value: controller.text.isEmpty ? null : controller.text,
              hint: Text(
                hintText,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: CustomColor.secondaryDarkColor,
                ),
              ),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: CustomColor.secondaryDarkColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                controller.text = newValue ?? '';
              },
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
