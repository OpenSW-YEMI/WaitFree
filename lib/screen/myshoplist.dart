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

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(  // Center로 감싸서 아이콘과 텍스트가 가운데 정렬되도록 설정
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // 세로로 중앙 정렬
                      crossAxisAlignment: CrossAxisAlignment.center, // 가로로 중앙 정렬
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0), // 원하는 만큼의 패딩 설정
                          child: ImageIcon(
                            const AssetImage('assets/icon/icon_person_filled.png'),
                            size: 80,
                            color: Colors.teal[200],
                          ),
                        ),
                        const Text(
                          '환영해요, 사장님!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '내가 운영중인 업체들이에요',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
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
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index].data() as Map<String, dynamic>;
                      final shopId = shops[index].id;

                      return Card(
                        color: const Color(0xFFF5FCFB),
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                        child: ListTile(
                          title: Text(
                            shop['name'] ?? '이름 없음',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Color(0xFF80CBC4)),
                          ),
                          subtitle: Text(
                            shop['address'] ?? '주소 없음',
                            style: const TextStyle(color: Colors.grey),
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
            ),
          );
        },
      ),
    );
  }
}
