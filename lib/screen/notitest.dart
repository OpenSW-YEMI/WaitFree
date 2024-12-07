// notification_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  // FCM 초기화
  Future<void> _initializeFCM() async {
    await _getToken(); // FCM 토큰 가져오기
    _listenToForegroundMessages(); // 포그라운드 메시지 리스너 등록
  }

  // FCM 토큰 가져오기
  Future<void> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      setState(() {
        _deviceToken = token;
      });
      print("FCM Token: $_deviceToken");
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  // 포그라운드 상태에서 메시지 처리
  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      if (message.notification != null) {
        // 포그라운드 상태에서 UI에 알림 표시
        _showNotificationDialog(
          title: message.notification?.title ?? "No Title",
          body: message.notification?.body ?? "No Body",
        );
      }
    });
  }

  // 알림 다이얼로그 표시
  void _showNotificationDialog({required String title, required String body}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // 서버로 알림 전송
  Future<void> sendNotification() async {
    if (_deviceToken == null) {
      print("Error: Device token is null");
      return;
    }

    const serverUrl = "http://175.45.193.45:3000/send-notification"; // 서버 IP 변경 필요

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "deviceToken": _deviceToken,
          "title": "Test Notification",
          "body": "This is a test notification",
          "data": {"key": "value"},
        }),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FCM Test"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: sendNotification,
          child: const Text("Send Notification"),
        ),
      ),
    );
  }
}
