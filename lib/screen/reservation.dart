import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/detail.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('로그인이 필요합니다.'),
      );
    }

    Color getStatusColor(String status) {
      switch (status) {
        case '혼잡':
          return Colors.red;
        case '보통':
          return Colors.orange;
        case '여유':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('queue')
              .where('ownerId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('예약된 업체가 없습니다.'));
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String shopId = data['shopId'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('shop')
                      .doc(shopId)
                      .get(),
                  builder: (context, shopSnapshot) {
                    if (shopSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('업체 정보를 불러오는 중...'),
                        leading: CircularProgressIndicator(),
                      );
                    }

                    if (shopSnapshot.hasError || !shopSnapshot.hasData) {
                      return const ListTile(
                        title: Text('업체 정보를 가져올 수 없습니다.'),
                      );
                    }

                    final shopData = shopSnapshot.data!.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          shopData['name'],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[200]),
                        ),
                        subtitle: Text(
                          shopData['address'],
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   shopData['status'],
                            //   style: TextStyle(
                            //     color: getStatusColor(shopData['status']),
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 4),
                            // Text(
                            //   '${shopData['people']}명 대기 중',
                            //   style: TextStyle(color: Colors.grey),
                            // ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(place: shopData),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
