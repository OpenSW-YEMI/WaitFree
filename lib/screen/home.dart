import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/login.dart';
import 'package:yemi/screen/search.dart'; // 새로 추가된 import

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
  int _selectedIndex = 2;
  final auth = FirebaseAuth.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    SearchScreen(), // 변경된 부분
    const CalendarPage(),
    const HomeContentPage(),
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
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icon/icon_menu.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              auth.signOut();
            },
          ),
        ],
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
            label: '예약',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_home.png'), size: 24),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icon/icon_chat.png'), size: 24),
            label: '채팅',
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
class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/button/btn_register.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10), // 간격 추가
            Image.asset(
              'assets/button/btn_register.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ],
        ),
        const SizedBox(height: 10), // 행 간 간격 추가
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/button/btn_register.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10), // 간격 추가
            Image.asset(
              'assets/button/btn_register.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ],
    );
  }
}

// 채팅 페이지
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '채팅 페이지',
        style: TextStyle(fontSize: 24, color: Colors.teal),
      ),
    );
  }
}

// 정보 페이지
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '정보 페이지',
        style: TextStyle(fontSize: 24, color: Colors.teal),
      ),
    );
  }
}
