import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yemi/screen/home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    // 불투명도 애니메이션 설정
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // 바운스 애니메이션 설정
    _bounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.2)).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  // 로그인 상태 확인
  void _checkLoginStatus() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 사용자가 이미 로그인된 경우 HomePage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  // 홈 화면으로 이동
  void _navigateToHomeScreen() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _navigateToHomeScreen,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      '환영합니다!',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      '시간 절약의 시작,',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),
                  // const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '웨잇프리',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.teal[200]),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: Lottie.asset(
                      'assets/animation/title.json',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                      repeat: false, // 애니메이션이 한 번만 재생되도록 설정
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _bounceAnimation,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Text(
                    '화면을 터치해 주세요!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
