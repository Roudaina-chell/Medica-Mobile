import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      doctorName: 'Dr.anwar',
      message: 'Create a appointments',
      avatarColor: Colors.brown,
      time: '19:02',
    ),
    NotificationItem(
      doctorName: 'Dr.Rayen',
      message: 'Create a appoiments',
      avatarColor: Colors.brown,
      time: '19:02',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, 
                  color: Colors.black, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 90, 196, 245),
              Color.fromARGB(255, 221, 230, 235),
              Color.fromARGB(255, 214, 225, 230),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Time display in top left
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '19:02',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notifications list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return NotificationCard(notification: notifications[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String doctorName;
  final String message;
  final Color avatarColor;
  final String time;

  NotificationItem({
    required this.doctorName,
    required this.message,
    required this.avatarColor,
    required this.time,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: notification.avatarColor,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.doctorName,
                  style: const TextStyle(
                    color: Color(0xFF42A5F5), // Blue color
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Green dot button
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Light green background
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF66BB6A), // Green dot
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}