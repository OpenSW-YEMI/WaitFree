import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    // 메뉴 항목 리스트
    final List<Map<String, dynamic>> menuItems = [
      {'title': '내 업체 등록', 'icon': Icons.app_registration, 'route': '/register'},
      {'title': '로그아웃', 'icon': Icons.logout, 'route': '/logout'},
    ];

    return Scaffold(
      body: ListView.builder(
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
                // 로그아웃 기능 예제 (수정 가능)
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
                          // 로그아웃 로직 추가
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
    );
  }
}