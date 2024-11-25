import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            .collection('likes') // likes 컬렉션 참조
            .where('userId', isEqualTo: currentUser.uid) // 현재 사용자 UID와 일치하는 항목 가져오기
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
                    .collection('shop') // shop 컬렉션 참조
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
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        shopData['name'] ?? '이름 없음',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(shopData['address'] ?? '주소 없음'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // 찜 해제 (Firebase에서 해당 레코드 삭제)
                          await FirebaseFirestore.instance
                              .collection('likes')
                              .doc(likedShops[index].id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('찜에서 삭제되었습니다.')),
                          );
                        },
                      ),
                      onTap: () {
                        // 상세 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailPage(
                              shopId: shopId,
                              shopData: shopData,
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

class ShopDetailPage extends StatelessWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const ShopDetailPage({
    Key? key,
    required this.shopId,
    required this.shopData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopData['name']),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('업체명: ${shopData['name'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('주소: ${shopData['address'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('연락처: ${shopData['contact'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
