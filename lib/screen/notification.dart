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
    FirebaseFirestore.instance
        .collection('notifications')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc.data());
      }
    });

    print(currentUser.uid == 'iJcYJzaCqffNa0b8fdzd56d9lCl2');

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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final title = notification['title'] ?? '알림 제목 없음';
              final body = notification['body'] ?? '알림 내용 없음';
              final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
              final isRead = notification['read'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2,
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.notifications : Icons.notifications_active,
                    color: isRead ? Colors.grey : Colors.teal,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(body),
                  trailing: timestamp != null
                      ? Text(
                    "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          );
        },
      ),
    );
  }
}
