import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/detail.dart';

class Favorite extends StatelessWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          '로그인이 필요합니다.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('likes')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('찜한 항목이 없습니다.'));
          }

          final List<DocumentSnapshot> likedShops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likedShops.length,
            itemBuilder: (context, index) {
              final shopId = likedShops[index]['shopId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('shop')
                    .doc(shopId)
                    .get(),
                builder: (context, shopSnapshot) {
                  if (shopSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (shopSnapshot.hasError || !shopSnapshot.hasData || !shopSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('업체 정보를 가져올 수 없습니다.'),
                    );
                  }

                  final shopData = shopSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        shopData['name'] ?? '이름 없음',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(shopData['address'] ?? '주소 없음'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              place: {
                                'id': shopId,
                                'name': shopData['name'] ?? 'N/A',
                                'address': shopData['address'] ?? 'N/A',
                                'lat': shopData['lat'] ?? 0.0,
                                'lng': shopData['lng'] ?? 0.0,
                              },
                            ),
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
    );
  }
}
