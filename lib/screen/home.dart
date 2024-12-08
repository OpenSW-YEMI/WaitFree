import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/login.dart';
import 'package:yemi/screen/notification.dart';
import 'package:yemi/screen/search.dart';
import 'package:yemi/screen/profile.dart';
import 'package:yemi/screen/reservation.dart';
import 'package:yemi/screen/favorite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> user) {
        // 로그인 상태를 명확히 확인
        if (user.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!user.hasData || user.data == null) {
          // 인증 상태가 없으면 로그인 페이지로 이동
          return const LoginPage();
        }
        // 로그인 상태일 경우 홈 화면 반환
        return const HomeScreen();
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final auth = FirebaseAuth.instance;

  // 뒤로가기 버튼 연타를 처리할 변수
  DateTime? lastPressedTime;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    SearchScreen(),
    const ReservationPage(),
    const Favorite(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentTime = DateTime.now();
        if (lastPressedTime == null ||
            currentTime.difference(lastPressedTime!) > const Duration(seconds: 2)) {
          lastPressedTime = currentTime;
          // "한 번 더 누르면 종료됩니다" 메시지 표시
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("한 번 더 누르면 종료됩니다."),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        // 두 번째 클릭 시 앱 종료
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            '웨잇프리',
            style: TextStyle(
              color: Colors.teal[200],
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
      ),
    );
  }
}