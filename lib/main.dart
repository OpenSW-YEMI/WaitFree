import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_auth.dart';
import 'package:yemi/firebase_options.dart';
import 'package:yemi/screen/home.dart';
import 'package:yemi/screen/login.dart';
import 'package:yemi/screen/signup.dart';
import 'package:yemi/screen/registerhelp.dart';
import 'package:yemi/screen/register.dart';
import 'package:yemi/screen/welcome_screen.dart';
import 'package:yemi/screen/myshoplist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: 'd1c8b23f18a867d19da528167eea55db',
    javaScriptAppKey: 'faf4dd85b62c94fc7f68abcdf352e465',
  );

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인 상태를 확인
    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'CustomFont',
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
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
      },
    );
  }
}
