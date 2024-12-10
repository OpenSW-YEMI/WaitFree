import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '로그인이 필요합니다.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    print('현재 로그인된 사용자 UID: ${currentUser.uid}');
    FirebaseFirestore.instance.collection('notifications').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc.data());
      }
    });

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUser.uid) // 현재 사용자 ID에 맞는 알림만 가져옴
            .orderBy('timestamp', descending: true) // 최신 알림 우선
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '받은 알림이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 문구
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 왼쪽 정렬
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 왼쪽 정렬
                            children: [
                              Text(
                                '알림 목록',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[200],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '중요한 소식을 확인하세요!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[200],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 35),

                              IconButton(
                                icon: Image.asset(
                                  'assets/icon/trash_icon.png', // 이미지 경로
                                  width: 24,  // 원하는 크기로 조정
                                  height: 24, // 원하는 크기로 조정
                                ),
                                onPressed: () async {
                                  final currentUser = FirebaseAuth.instance.currentUser;

                                  if (currentUser == null) {
                                    // 로그인되지 않은 경우 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('로그인이 필요합니다.')),
                                    );
                                    return;
                                  }

                                  try {
                                    // Firestore에서 현재 사용자와 관련된 모든 알림 삭제
                                    final notifications = await FirebaseFirestore.instance
                                        .collection('notifications')
                                        .where('userId', isEqualTo: currentUser.uid)
                                        .get();

                                    for (var doc in notifications.docs) {
                                      await FirebaseFirestore.instance
                                          .collection('notifications')
                                          .doc(doc.id)
                                          .delete();
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('모든 알림이 삭제되었습니다.')),
                                    );
                                  } catch (e) {
                                    // 오류 처리
                                    print('알림 삭제 중 오류 발생: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('알림 삭제 중 문제가 발생했습니다.')),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                          ,
                        ],
                      )
                    ],
                  ),
                ),

                Center(
                  child: Container(
                    width: 330,  // 원하는 길이로 설정
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 알림 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final title = notification['title'] ?? '알림 제목 없음';
                      final body = notification['body'] ?? '알림 내용 없음';
                      final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
                      final isRead = notification['read'] ?? false;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        child: ListTile(
                          leading: Image.asset(
                            'assets/icon/notification_icon.png', // 이미지 경로
                            width: 30,  // 원하는 크기로 조정
                            height: 30, // 원하는 크기로 조정
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(body),
                          trailing: timestamp != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center, // Column 내부 요소를 수직으로 중앙 정렬
                            children: [
                              // 날짜 부분
                              Text(
                                "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              // 시간 부분
                              Text(
                                "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          )
                              : null,
                          onTap: () async {
                            // 알림 읽음 처리
                            if (!isRead) {
                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(notification.id)
                                  .update({'read': true});
                            }
                          },
                        ),
                      );
                    },
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
