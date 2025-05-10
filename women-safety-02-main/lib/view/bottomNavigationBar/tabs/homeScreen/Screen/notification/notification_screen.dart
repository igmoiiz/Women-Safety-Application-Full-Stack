import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/custom_color.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Alert',
      'description': 'You have a new alert in your area.',
      'time': '2 mins ago',
      'type': 'alert',
      'isRead': false
    },
    {
      'title': 'Safety Tip',
      'description': 'Remember to stay in well-lit areas at night.',
      'time': '1 hour ago',
      'type': 'tip',
      'isRead': false
    },
    {
      'title': 'Update',
      'description': 'Your profile has been updated successfully.',
      'time': '3 hours ago',
      'type': 'update',
      'isRead': true
    },
  ];

  void _dismissNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.notification_important_rounded;
      case 'tip':
        return Icons.lightbulb_rounded;
      case 'update':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: CustomColor.primaryPinkColor,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: CustomColor.primaryPinkColor,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Dismissible(
                    key: Key('notification-$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) => _dismissNotification(index),
                    child: _buildNotificationCard(notification, index),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final String type = notification['type'];
    final bool isRead = notification['isRead'];

    // Alternating background colors for a more visually appealing list
    final bool isEven = index % 2 == 0;
    final Color bgColor = isEven
        ? Color(0xFFFFF0F7) // Light pink for even items
        : Colors.white; // White for odd items

    return GestureDetector(
      onTap: () {
        setState(() {
          notification['isRead'] = true;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : CustomColor.primaryPinkColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: CustomColor.primaryPinkColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: CustomColor.primaryPinkColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title']!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryPinkColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      notification['description']!,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTypeTag(type),
                        Text(
                          notification['time']!,
                          style: GoogleFonts.poppins(
                            color: Colors.black45,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(String type) {
    Color bgColor;
    String text;

    switch (type) {
      case 'alert':
        bgColor = Colors.red[50]!;
        text = 'Alert';
        break;
      case 'tip':
        bgColor = Colors.amber[50]!;
        text = 'Tip';
        break;
      case 'update':
        bgColor = Colors.blue[50]!;
        text = 'Update';
        break;
      default:
        bgColor = Colors.grey[50]!;
        text = 'Notification';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: CustomColor.primaryPinkColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 50,
              color: CustomColor.primaryPinkColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
