import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_auth.dart';
import 'package:yemi/screen/faq.dart'; // FAQ 페이지 import 추가
import 'package:yemi/screen/home.dart';
import 'package:yemi/screen/login.dart';
import 'package:yemi/screen/signup.dart';
import 'package:yemi/screen/registerhelp.dart';
import 'package:yemi/screen/register.dart';
import 'package:yemi/screen/welcome_screen.dart';
import 'package:yemi/screen/myshoplist.dart';
import 'package:yemi/screen/help.dart';
import 'package:yemi/screen/notitest.dart'; // NotificationPage import 추가
import 'package:yemi/screen/qrtest.dart'; // NotificationPage import 추가
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uni_links2/uni_links.dart';

// 글로벌 NavigatorKey 선언
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'd1c8b23f18a867d19da528167eea55db',
    javaScriptAppKey: 'faf4dd85b62c94fc7f68abcdf352e465',
  );

  await Firebase.initializeApp();

  // Firebase 메시징 설정
  setupFirebaseMessaging();

  runApp(const MyApp());
}

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FCM 토큰 가져오기
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // 포그라운드에서 메시지를 받을 때 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground Message: ${message.notification?.title}");

    if (message.notification != null) {
      // 포그라운드에서 알림을 다이얼로그로 표시
      _showNotificationDialog(
        title: message.notification?.title ?? "No Title",
        body: message.notification?.body ?? "No Body",
      );
    }
  });
}

void _showNotificationDialog({required String title, required String body}) {
  // 다이얼로그를 앱 내에서 표시하기 위해 context 필요
  final context = navigatorKey.currentState?.context;

  if (context != null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _linkSub;

  @override
  void initState() {
    super.initState();
    _setupDeepLinkListener();
  }

  void _setupDeepLinkListener() {
    _linkSub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // 딥 링크를 처리하여 적절한 경로로 이동
        print('Received URI: $uri');
        if (uri.path == '/home') {
          Navigator.pushNamed(context, '/home');
        } else if (uri.path == '/login') {
          Navigator.pushNamed(context, '/login');
        } else if (uri.path == '/signup') {
          Navigator.pushNamed(context, '/signup');
        }
      }
    }, onError: (err) {
      print('Error handling deep link: $err');
    });
  }

  @override
  void dispose() {
    _linkSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인 상태를 확인
    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

    return MaterialApp(
      navigatorKey: navigatorKey, // global navigator key
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'CustomFont',
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      // 로그인된 사용자가 있다면 HomePage로, 그렇지 않으면 WelcomeScreen으로 이동
      home: user != null ? const HomePage() : const WelcomeScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/registerhelp': (context) => const RegisterHelpPage(),
        '/register': (context) => const RegisterPage(),
        '/shopmanage': (context) => const MyShopsPage(),
        '/faq': (context) => FAQPage(),
        '/help': (context) => ReportPage(),
        '/notitest': (context) => NotificationPage(),
        '/qrtest': (context) => Test(), // NotificationPage 라우팅 추가
      },
    );
  }
}
