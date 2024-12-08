import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/detail.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _refreshData() async {
    setState(() {});
  }

  // 혼잡도 색상 변경 함수
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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 부분 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' 예약 현황',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[200],
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // Container(
                    //   width: 200,
                    //   height: 2,
                    //   color: Colors.teal[200], // 밑줄
                    // ),
                    const SizedBox(height: 10),

                    // 오늘의 예약 현황 텍스트
                    Text(
                      '  오늘 방문 예정인 매장들이에요',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.teal[200],
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/icon/icon_clock.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Center(
              child: Container(
                width: 330,  // 원하는 길이로 설정
                child: Divider(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 예약 리스트 부분
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('queue')
                    .where('ownerId', isEqualTo: user!.uid)
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

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final String shopId = data['shopId'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('shop').doc(shopId).get(),
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
                            shopData['id'] = shopSnapshot.data!.id; // 'id' 추가

                            final int normalThreshold = shopData['normal'];
                            final int crowdedThreshold = shopData['crowded'];

                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('queue')
                                  .where('shopId', isEqualTo: shopId)
                                  .get(),
                              builder: (context, queueSnapshot) {
                                if (queueSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (queueSnapshot.hasError) {
                                  return const Text('대기 인원을 가져오는 중 오류가 발생했습니다.');
                                }

                                final int waitingCount = queueSnapshot.data?.docs.length ?? 0;

                                // 혼잡도 계산
                                String status;
                                if (waitingCount <= normalThreshold) {
                                  status = '여유';
                                } else if (waitingCount <= crowdedThreshold) {
                                  status = '보통';
                                } else {
                                  status = '혼잡';
                                }

                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                    title: Text(
                                      shopData['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[200],
                                      ),
                                    ),
                                    subtitle: Text(
                                      shopData['address'],
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$waitingCount명 대기 중',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
