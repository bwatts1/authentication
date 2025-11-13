import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Background message handler
Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quote Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Firebase Quote Notifications'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? fcmToken;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() {
    messaging = FirebaseMessaging.instance;
    
    // Subscribe to topic
    messaging.subscribeToTopic("messaging");
    
    // Get FCM token
    messaging.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
      print('===========================================');
      print('FCM Token: $token');
      print('===========================================');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");
      
      _handleNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      _handleNotification(message);
    });
  }

  void _handleNotification(RemoteMessage message) {
    // Extract notification type from custom data
    String notificationType = message.data['type'] ?? 'regular';
    String category = message.data['category'] ?? 'general';
    
    // Add to notifications list
    setState(() {
      notifications.insert(0, {
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? '',
        'type': notificationType,
        'category': category,
        'timestamp': DateTime.now(),
      });
    });

    // Show custom dialog based on type
    _showCustomDialog(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationType,
      category,
    );
  }

  void _showCustomDialog(String title, String body, String type, String category) {
    // Customize appearance based on type
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    
    switch (type) {
      case 'important':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        iconData = Icons.warning_rounded;
        break;
      case 'wisdom':
        backgroundColor = Colors.purple.shade50;
        textColor = Colors.purple.shade900;
        iconData = Icons.lightbulb_rounded;
        break;
      default: // regular or motivation
        if (category == 'motivation') {
          backgroundColor = Colors.blue.shade50;
          textColor = Colors.blue.shade900;
          iconData = Icons.emoji_events_rounded;
        } else {
          backgroundColor = Colors.grey.shade100;
          textColor = Colors.grey.shade900;
          iconData = Icons.message_rounded;
        }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(iconData, color: textColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                body,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Type: ${type.toUpperCase()} | Category: ${category}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: textColor,
              ),
              child: Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // FCM Token Display
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.token, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Text(
                      'FCM Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SelectableText(
                  fcmToken ?? 'Loading token...',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Copy this token to send test notifications from Firebase Console',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey.shade700),
                SizedBox(width: 8),
                Text(
                  'Received Notifications (${notifications.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Send a test notification from Firebase Console',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    Color cardColor;
    IconData iconData;
    
    switch (notification['type']) {
      case 'important':
        cardColor = Colors.red.shade100;
        iconData = Icons.warning_rounded;
        break;
      case 'wisdom':
        cardColor = Colors.purple.shade100;
        iconData = Icons.lightbulb_rounded;
        break;
      default:
        if (notification['category'] == 'motivation') {
          cardColor = Colors.blue.shade100;
          iconData = Icons.emoji_events_rounded;
        } else {
          cardColor = Colors.grey.shade200;
          iconData = Icons.message_rounded;
        }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(iconData, size: 32),
        title: Text(
          notification['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(notification['body']),
            SizedBox(height: 4),
            Text(
              'Type: ${notification['type']} | ${notification['category']}',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}