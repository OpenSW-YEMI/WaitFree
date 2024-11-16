import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const DetailScreen({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '예약',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 수평으로 가운데 정렬

          children: [
            const SizedBox(height: 10),
            Text(
              place['name'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[200]),
            ),
            const SizedBox(height: 8),
            SelectableText(
              place['address'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            // 대기 인원수 표시
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queue')
                  .where('shopId', isEqualTo: place['id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text('대기 인원수를 가져오는 중 오류가 발생했습니다.');
                }

                if (snapshot.hasData) {
                  // 대기 인원수 계산
                  final int waitingCount = snapshot.data!.docs.length;
                  return Column(
                    children: [
                      const Text(
                        '대기자 수',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$waitingCount',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }

                return const Text('대기 인원수를 가져올 수 없습니다.');
              },
            ),

            const SizedBox(height: 10),

            // 지도 섹션
            SizedBox(
              height: 150,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(place['lat'], place['lng']),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(place['name']),
                    position: LatLng(place['lat'], place['lng']),
                    infoWindow: InfoWindow(title: place['name']),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
              ),
            ),

            // 지도와 버튼을 딱 붙게 배치
            Row(
              children: [
                // 주소 복사 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Color(0xFFD7D7D7)),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: place['address']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주소가 복사되었습니다!')),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('주소 복사', style: TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                // 지도 보기 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Color(0xFFD7D7D7)),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullMapScreen(
                            lat: place['lat'],
                            lng: place['lng'],
                            name: place['name'],
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('지도 보기', style: TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 맨 아래 추가된 예약하기 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCAE5E4),
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // 현재 로그인된 사용자의 UID 가져오기
                final User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                  return;
                }

                final String ownerId = user.uid; // 로그인된 사용자의 UID
                final String shopId = place['id']; // 업체의 ID (place 객체에서 가져옴)

                try {
                  // Firestore의 'queue' 컬렉션에 데이터 추가
                  await FirebaseFirestore.instance.collection('queue').add({
                    'ownerId': ownerId,
                    'shopId': shopId,
                    'timestamp': FieldValue.serverTimestamp(), // 추가: 요청 시간 기록
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('예약이 완료되었습니다!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('예약에 실패했습니다: $e')),
                  );
                }
              },
              child: const Center(
                child: Text(
                  '예약하기',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullMapScreen extends StatelessWidget {
  final double lat;
  final double lng;
  final String name;

  const FullMapScreen({
    Key? key,
    required this.lat,
    required this.lng,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '상세위치',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng),
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
          ),
        },
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
      ),
    );
  }
}
