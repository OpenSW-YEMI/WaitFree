import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoPage extends StatelessWidget {
  final String userId; // 특정 유저의 UID

  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  Future<void> toggleReaction(String targetUserId, String reactionType) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // 사용자가 로그인되지 않았을 경우
      return;
    }

    final currentUserId = currentUser.uid;
    final reactionDoc = FirebaseFirestore.instance.collection('reactions')
        .doc('$currentUserId-$targetUserId'); // 유니크한 document ID (유저 간 반응을 구분)

    final reactionSnapshot = await reactionDoc.get();

    if (reactionSnapshot.exists) {
      // 이미 반응이 존재하는 경우 토글 (반응 삭제)
      final existingReaction = reactionSnapshot.data()?['reactionType'];
      if (existingReaction == reactionType) {
        // 같은 반응이면 삭제
        await reactionDoc.delete();
      } else {
        // 다른 반응이면 업데이트
        await reactionDoc.update({'reactionType': reactionType});
      }
    } else {
      // 반응이 없다면 새로 추가
      await reactionDoc.set({
        'userId': currentUserId,
        'targetUserId': targetUserId,
        'reactionType': reactionType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

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

                // 좋아요 / 싫어요 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up, color: Colors.blue),
                      onPressed: () async {
                        await toggleReaction(userId, 'like');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.thumb_down, color: Colors.red),
                      onPressed: () async {
                        await toggleReaction(userId, 'dislike');
                      },
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
