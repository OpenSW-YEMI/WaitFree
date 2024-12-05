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
    const ReservationPage(),
    const Favorite(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          // 홈 화면이 아닌 다른 화면일 경우 홈 화면으로 돌아가도록 함
          setState(() {
            _selectedIndex = 0; // 홈 화면 인덱스로 설정
          });
          return false; // 기본 뒤로가기 동작을 차단
        }
        // 홈 화면이면 앱 종료
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 배경을 투명하게 설정
          elevation: 0,
          automaticallyImplyLeading: false, // 뒤로가기 버튼 제거 (원하는 경우)
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white, // 스크롤 시에도 흰색 배경
            ),
          ),
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
