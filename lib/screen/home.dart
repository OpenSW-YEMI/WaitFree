import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yemi/screen/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return const LoginPage();
        } else {
          return const HomeScreen(); // 로그인 성공 시 HomeScreen 반환
        }
      },
    );
  }
}

// 로그인 성공 후 보여줄 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // 초기 선택된 탭 인덱스 (홈 화면)

  // 네비게이션 탭 변경 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '웨잇프리',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icon/icon_menu.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              print("Menu button clicked");
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '홈 화면 내용',
          style: TextStyle(fontSize: 24, color: Colors.teal),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.teal[200],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/icon_search.png',
              width: 24,
              height: 24,
            ),
            label: '돌려보기',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/icon_calendar.png',
              width: 24,
              height: 24,
            ),
            label: '예약',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/icon_home.png',
              width: 24,
              height: 24,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/icon_chat.png',
              width: 24,
              height: 24,
            ),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/icon_person.png',
              width: 24,
              height: 24,
            ),
            label: '정보',
          ),
        ],
      ),
    );
  }
}
