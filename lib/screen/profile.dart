import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemi/screen/membershipinfo.dart'; // Favorite 위젯 추가

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  String _getMembershipLevel(int reservecount) {
    if (reservecount >= 25 && reservecount <= 35) {
      return "시공간을 다스리는 초월자";
    } else if (reservecount >= 16 && reservecount <= 24) {
      return "시간 절약의 챔피언";
    } else if (reservecount >= 9 && reservecount <= 15) {
      return "몰루";
    } else if (reservecount >= 4 && reservecount <= 8) {
      return "분주한 하루의 균형자";
    } else if (reservecount >= 1 && reservecount <= 3) {
      return "시간 절약의 견습생";
    } else {
      return "시간 절약의 첫 걸음"; // 예약이 0회인 경우
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    // 메뉴 항목 리스트
    final List<Map<String, dynamic>> menuItems = [
      {'title': '내 업체 등록', 'icon': Icons.app_registration, 'route': '/registerhelp'},
      {'title': '내 업체 관리', 'icon': Icons.manage_accounts, 'route': '/shopmanage'},
      {'title': '로그아웃', 'icon': Icons.logout, 'route': '/logout'},
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 사용자 정보 섹션
          Container(
            color: const Color(0xFFF3F9FB), // 배경색
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.displayName ?? "사용자 이름 없음", // DisplayName
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 예약 횟수 및 회원 등급 섹션
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "예약 횟수: 로딩 중...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "예약 횟수: 정보 없음",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final data = snapshot.data!;
              final int reservecount = data['reservecount'] ?? 0;
              final String membershipLevel = _getMembershipLevel(reservecount);

              return GestureDetector(
                onTap: () {
                  final String membershipLevel = _getMembershipLevel(reservecount); // 등급 계산
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MembershipInfoPage(
                        membershipLevel: membershipLevel, // 현재 등급 전달
                        reservecount: reservecount,       // 현재 예약 횟수 전달
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "예약 횟수: $reservecount",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "회원 등급: $membershipLevel",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 이메일 정보 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "이메일: ${currentUser?.email ?? '이메일 없음'}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 20),

          // 메뉴 리스트 섹션
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item['icon'], color: Colors.teal),
                  title: Text(
                    item['title'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    if (item['route'] == '/logout') {
                      // 로그아웃 기능
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃 하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                auth.signOut();
                                Navigator.of(context).pop();
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, item['route']);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


