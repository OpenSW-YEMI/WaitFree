import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/reserveconfirm.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const DetailScreen({Key? key, required this.place}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> reserveShop() async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('queue').add({
        'ownerId': currentUser!.uid,
        'shopId': widget.place['id'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 완료되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약에 실패했습니다: $e')),
      );
    }
  }

  Future<void> cancelReservation(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('queue').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 취소되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 취소에 실패했습니다: $e')),
      );
    }
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('shop')
            .doc(widget.place['id'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('데이터를 가져오는 중 오류가 발생했습니다.'),
            );
          }

          final isOpened = snapshot.data?['isOpen'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  widget.place['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[200],
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  widget.place['address'],
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // 매장이 닫혀 있을 경우 안내 메시지 표시
                if (!isOpened)
                  const Text(
                    '아직 준비중이에요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                // 매장이 열려 있을 경우 대기 인원수와 예약 버튼 표시
                if (isOpened) ...[
                  // 대기 인원수 표시
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('queue')
                        .where('shopId', isEqualTo: widget.place['id'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text('대기 인원수를 가져오는 중 오류가 발생했습니다.');
                      }

                      final int waitingCount = snapshot.data?.docs.length ?? 0;

                      return Column(
                        children: [
                          const Text(
                            '대기자 수',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
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
                    },
                  ),

                  const SizedBox(height: 20),

                  // 예약 버튼
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('queue')
                        .where('shopId', isEqualTo: widget.place['id'])
                        .where('ownerId', isEqualTo: currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final hasReservation = snapshot.data?.docs.isNotEmpty ?? false;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCAE5E4),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: hasReservation
                            ? () =>
                            cancelReservation(snapshot.data!.docs.first.id)
                            : reserveShop,
                        child: Text(
                          hasReservation ? '예약취소' : '예약하기',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),

                // 지도 섹션 (항상 표시)
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.place['lat'], widget.place['lng']),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(widget.place['name']),
                        position: LatLng(widget.place['lat'], widget.place['lng']),
                        infoWindow: InfoWindow(title: widget.place['name']),
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                  ),
                ),

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
                          Clipboard.setData(
                              ClipboardData(text: widget.place['address']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('주소가 복사되었습니다!')),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, color: Colors.grey, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '주소 복사',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
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
                                lat: widget.place['lat'],
                                lng: widget.place['lng'],
                                name: widget.place['name'],
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, color: Colors.grey, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '지도 보기',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

  Future<bool> showConfirmDialog(
    BuildContext context, String shopName, int waitingCount) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' 예약 안내 ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  shopName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${waitingCount + 1}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const TextSpan(
                      text: '번째 순서로 예약하시겠어요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              shopName: shopName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCAE5E4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '예',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '아니요',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ) ?? false;
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