import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shopmanage.dart'; // 추가된 부분

class MyShopsPage extends StatefulWidget {
  const MyShopsPage({Key? key}) : super(key: key);

  @override
  State<MyShopsPage> createState() => _MyShopsPageState();
}

class _MyShopsPageState extends State<MyShopsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "업체관리",
          style: TextStyle(color: Colors.teal[200], fontSize: 20),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('shop')
            .where('ownerId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 업체가 없습니다.'));
          }

          final List<DocumentSnapshot> shops = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 추가
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0), // 원하는 만큼의 패딩 설정
                      child: ImageIcon(
                        const AssetImage('assets/icon/icon_person_filled.png'),
                        size: 50,
                        color: Colors.teal[200],
                      ),
                    ),
                    const Text(
                      '환영해요, 사장님!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('내가 운영중인 업체들이에요', style: TextStyle(fontSize: 18, color: Colors.teal)),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index].data() as Map<String, dynamic>;
                    final shopId = shops[index].id;

                    return Card(
                      color: const Color(0xFFF3F9FB),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      child: ListTile(
                        title: Text(
                          shop['name'] ?? '이름 없음',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        subtitle: Text(
                          shop['address'] ?? '주소 없음',
                          style: const TextStyle(color: Colors.teal),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopDetailPage(
                                shop: shop,
                                shopId: shopId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
