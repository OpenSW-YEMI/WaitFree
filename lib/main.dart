import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemi/screen/detail.dart';
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

  // Firebase Firestore에 deviceToken을 저장하는 함수 호출
  if (token != null) {
    _updateDeviceTokenInFirestore(token);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground Message: ${message.notification?.title}");

    if (message.notification != null) {
      showNotificationDialog(
        context: navigatorKey.currentContext!,
        title: message.notification?.title ?? "No Title",
        body: message.notification?.body ?? "No Body",
      );
    }
  });

}

// Firestore에 사용자의 deviceToken을 업데이트하는 함수
Future<void> _updateDeviceTokenInFirestore(String token) async {
  // 현재 로그인된 사용자
  final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Firestore에서 사용자 문서 가져오기
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'deviceToken': token,  // deviceToken 필드에 토큰 업데이트
      })
          .then((_) {
        print("Device Token updated successfully.");
      });
    } catch (e) {
      print("Error updating device token: $e");
    }
  } else {
    print("No user is logged in.");
  }
}

Future<void> showNotificationDialog({
  required BuildContext context,
  required String title,
  required String body,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // 다이얼로그 외부 클릭으로 닫히지 않음
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' $title ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCAE5E4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
    _handleInitialLink(); // 앱이 백그라운드에서 포그라운드로 돌아왔을 때의 처리
  }

  Future<void> _handleInitialLink() async {
    print("Hello!!!!!");
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      Uri? uri = Uri.tryParse(initialLink);
      if (uri != null) {
        print('Initial link: ${uri.path}');

        // 경로가 '/reserve/{업체 UID}'인 경우
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'reserve' && uri.pathSegments.length == 2) {
          String shopId = uri.pathSegments[1];  // {업체 UID} 값 추출
          print('Navigating to reserve for shop ID: $shopId');

          // Firestore에서 해당 업체 정보 가져오기
          Map<String, dynamic> place = await _getShopDetails(shopId);
          print(place.toString());

          if (place.isNotEmpty) {
            // 업체 정보가 있으면 DetailScreen으로 이동
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DetailScreen(place: place),
              ),
            );
          } else {
            print('Shop with ID $shopId not found.');
          }
        } else {
          print('Unhandled initial link path: ${uri.path}');
        }
      } else {
        print('Invalid URI: $initialLink');
      }
    }
  }

  Future<Map<String, dynamic>> _getShopDetails(String shopId) async {
    // Firestore에서 shop 컬렉션에 있는 업체 정보를 가져옵니다.
    var shopDoc = await FirebaseFirestore.instance.collection('shop').doc(shopId).get();

    if (shopDoc.exists) {
      // Firestore에서 가져온 데이터를 원하는 형식으로 변환
      var data = shopDoc.data()!;
      Map<String, dynamic> place = {
        'id': shopId,
        'name': data['name'] ?? '', // name이 없으면 빈 문자열로 처리
        'address': data['address'] ?? '', // address가 없으면 빈 문자열로 처리
        'normal': data['normal'] ?? 0,  // normal이 없으면 0으로 처리
        'crowded': data['crowded'] ?? 0, // crowded가 없으면 0으로 처리
        'lat': data['lat'] ?? 0.0, // lat가 없으면 0.0으로 처리
        'lng': data['lng'] ?? 0.0, // lng가 없으면 0.0으로 처리
      };

      return place;
    } else {
      print('Shop not found for ID: $shopId');
      return {}; // 업체 정보가 없으면 빈 맵 반환
    }
  }




  void _setupDeepLinkListener() {
    print("Hello!!!!!");
    _linkSub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        // 경로에서 {업체 UID}를 추출
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty && pathSegments[0] == 'reserve' && pathSegments.length == 2) {
          final shopId = pathSegments[1];  // {업체 UID} 값 추출

          print('Received reserve request for shop: $shopId');

          // Firestore에서 해당 업체 정보 가져오기
          Map<String, dynamic> place = await _getShopDetails(shopId);
          print(place.toString());

          // 업체 정보를 전달하여 DetailScreen으로 이동
          if (place.isNotEmpty) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DetailScreen(place: place),
              ),
            );
          } else {
            print('No details found for the shop with ID: $shopId');
          }
        } else {
          print('Invalid deep link path: ${uri.path}');
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
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;

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
