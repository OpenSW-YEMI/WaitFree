import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/login.dart';
import 'package:yemi/screen/search.dart';
import 'package:yemi/screen/profile.dart';

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
  int _selectedIndex = 0;
  final auth = FirebaseAuth.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    SearchScreen(), // 변경된 부분
    const CalendarPage(),
    const Favorite(),
    const ChatPage(),
    const ProfilePage(),
  ];

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
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.teal[200],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_search.png'), size: 24),
            label: '둘러보기',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_calendar.png'), size: 24),
            label: '예약정보',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_heart.png'), size: 24),
            label: '찜',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_bell.png'), size: 24),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_person.png'), size: 24),
            label: '정보',
          ),
        ],
      ),
    );
  }
}

// 예약 페이지
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '예약 페이지',
        style: TextStyle(fontSize: 24, color: Colors.teal),
      ),
    );
  }
}

// 홈 페이지
class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '찜 페이지',
        style: TextStyle(fontSize: 24, color: Colors.teal),
      ),
    );
  }
}

// 채팅 페이지
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '알림 페이지',
        style: TextStyle(fontSize: 24, color: Colors.teal),
      ),
    );
  }
}