import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoPage extends StatelessWidget {
  final String userId; // 특정 유저의 UID

  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 프로필'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('사용자 정보를 불러오는 중 오류가 발생했습니다.'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('사용자 정보를 찾을 수 없습니다.'),
            );
          }

          // 사용자 데이터
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String displayName = userData['nickname'] ?? '이름 없음';
          final String email = userData['email'] ?? '이메일 없음';
          final String profileImageUrl = userData['profileImage'] ?? '';
          final int reservationCount = userData['reservecount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/icon/icon_person.png') as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 20),

                // 사용자 이름
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // 사용자 이메일
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // 예약 횟수
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event, color: Colors.teal),
                    const SizedBox(width: 10),
                    Text(
                      '예약 횟수: $reservationCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 기타 사용자 정보 (필요 시 추가)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '추가 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'UID: $userId',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '회원 가입일: ${userData['createdAt'] ?? '정보 없음'}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        // 필요한 추가 사용자 정보는 여기에 추가
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
