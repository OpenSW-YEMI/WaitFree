import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? "이메일 없음", // 이메일
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
