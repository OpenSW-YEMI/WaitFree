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
            currentTime.difference(lastPressedTime!) > Duration(seconds: 2)) {
          // 뒤로가기 버튼을 처음 눌렀을 때 (또는 2초 이상 차이가 날 때)
          lastPressedTime = currentTime; // 시간을 갱신
          // "한 번 더 누르면 종료됩니다"와 같은 메시지를 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("한 번 더 누르면 종료됩니다."),
              duration: Duration(seconds: 2),
            ),
          );
          return Future.value(false); // 기본 뒤로가기 동작을 차단
        } else {
          // 두 번째 클릭 시 앱 종료
          return Future.value(true); // 앱 종료
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,  // 배경을 하얀색으로 설정
          scrolledUnderElevation: 0,
          elevation: 0,                   // 그림자 제거
          automaticallyImplyLeading: false, // 뒤로가기 버튼을 원하지 않으면 false로 설정
          centerTitle: true,
          title: Text(
            '웨잇프리',
            style: TextStyle(
              color: Colors.teal[200],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.teal[200], // 아이콘 색상 설정 (필요 시)
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
