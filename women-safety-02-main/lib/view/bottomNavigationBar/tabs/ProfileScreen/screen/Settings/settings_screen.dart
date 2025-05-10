import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_settings/app_settings.dart';
import 'package:women_safety/utils/custom_color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: CustomColor.buttonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            'App Permissions',
            [
              _buildSettingTile(
                'Notifications',
                Icons.notifications_none_rounded,
                () => AppSettings.openAppSettings(
                    type: AppSettingsType.notification),
                showArrow: true,
              ),
              _buildSettingTile(
                'Location Services',
                Icons.location_on_outlined,
                () =>
                    AppSettings.openAppSettings(type: AppSettingsType.location),
                showArrow: true,
              ),
              _buildSettingTile(
                'Privacy & Security',
                Icons.security_outlined,
                () =>
                    AppSettings.openAppSettings(type: AppSettingsType.security),
                showArrow: true,
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSettingsSection(
            'App Information',
            [
              _buildSettingTile(
                'Licenses',
                Icons.description_outlined,
                () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Women Safety',
                    applicationVersion: '1.0.0',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/success.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                  );
                },
                showArrow: true,
              ),
              _buildSettingTile(
                'App Version',
                Icons.info_outline,
                () {},
                subtitle: '1.0.0',
                showArrow: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: CustomColor.buttonColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
