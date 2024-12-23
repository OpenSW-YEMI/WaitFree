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
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // 초기 찜 상태 확인
  }

  Future<void> _checkIfLiked() async {
    if (currentUser == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('userId', isEqualTo: currentUser!.uid)
        .where('shopId', isEqualTo: widget.place['id'])
        .get();
    setState(() {
      isLiked = snapshot.docs.isNotEmpty;
      print(widget.place.toString());
    });
  }

  Future<bool> showCancelReservationDialog(BuildContext context, String shopName) async {
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
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' 예약 취소 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
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
                const Text(
                  '예약을 취소하시겠습니까?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // '예' 선택
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
                          Navigator.of(context).pop(false); // '아니요' 선택
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 배경을 흰색으로 설정
                          elevation: 0, // 버튼 그림자 제거
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
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

  Future<void> _toggleLike() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final likesCollection = FirebaseFirestore.instance.collection('likes');

    if (isLiked) {
      // 찜 제거
      final snapshot = await likesCollection
          .where('userId', isEqualTo: currentUser!.uid)
          .where('shopId', isEqualTo: widget.place['id'])
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜이 해제되었습니다.')),
      );
    } else {
      // 찜 추가
      await likesCollection.add({
        'userId': currentUser!.uid,
        'shopId': widget.place['id'],
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜 목록에 추가되었습니다.')),
      );
    }

    setState(() {
      isLiked = !isLiked;
    });
  }


  Future<void> reserveShop(int waitingCount) async {
    if (currentUser == null) return;

    // 다이얼로그 띄우기
    final confirmed = await showConfirmDialog(
      context,
      widget.place['name'],
      waitingCount, // 여기에 현재 대기 인원수를 전달 (예: waitingCount)
    );

    if (!confirmed) return;

    try {
      // 예약 정보를 queue 컬렉션에 추가
      await FirebaseFirestore.instance.collection('queue').add({
        'ownerId': currentUser!.uid,
        'shopId': widget.place['id'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // users 컬렉션에서 해당 유저의 reservecount 증가
      final userDocRef =
      FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

      // 트랜잭션을 사용하여 안전하게 업데이트
      FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (snapshot.exists) {
          // 기존 reservecount 값 가져오기
          final currentCount = snapshot['reservecount'] ?? 0;
          final newCount = currentCount + 1; // 새로운 예약 횟수

          // reservecount 업데이트
          transaction.update(userDocRef, {
            'reservecount': newCount,
          });

          // 등급 상승 알림 추가
          if ([4, 9, 16, 25, 36].contains(newCount)) {
            // 등급 상승 알림을 추가하는 함수 호출
            await _addGradeUpNotification(newCount);
          }
        } else {
          // 사용자가 없으면 새로 생성
          transaction.set(userDocRef, {
            'reservecount': 1,
          });
        }
      });

      // 'notifications' 컬렉션에 예약 성공 알림 추가
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': '예약 성공',
        'body': '${widget.place['name']}에 예약이 완료되었어요!',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUser!.uid,
        'read': false, // 기본값은 false
      });

      // ConfirmationScreen으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            shopName: widget.place['name'],
          ),
        ),
      );
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약에 실패했습니다: $e')),
      );
    }
  }

// 등급 상승 알림을 추가하는 함수
  Future<void> _addGradeUpNotification(int newCount) async {
    try {
      // 알림 제목과 내용을 생성
      String title = '등급 상승';
      String body = '축하합니다! 새로운 등급에 도달했습니다. 현재 예약 횟수: $newCount';

      // 'notifications' 컬렉션에 알림 추가
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': currentUser!.uid,  // 알림을 받을 사용자 ID
        'title': title,               // 알림 제목
        'body': body,                 // 알림 내용
        'read': false,                // 알림 읽음 여부 (기본값 false)
        'timestamp': FieldValue.serverTimestamp(),  // 알림 생성 시간
      });

      print('등급 상승 알림이 Firestore에 추가되었습니다.');
    } catch (e) {
      print('알림 추가 오류: $e');
    }
  }


  Future<void> cancelReservation(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('queue').doc(docId).delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 취소되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
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
        scrolledUnderElevation: 0,
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
          int waitingCount = 0;  // 대기 인원 수

          return SingleChildScrollView(
            child: Padding(
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
                          .orderBy('timestamp')  // 대기 순번을 시간 순으로 정렬
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return const Text('대기 인원수를 가져오는 중 오류가 발생했습니다.');
                        }

                        final docs = snapshot.data?.docs ?? [];
                        waitingCount = docs.length;  // 대기 인원 수
                        int? userPosition;

                        // 로그인된 사용자의 순번을 찾음
                        for (int i = 0; i < docs.length; i++) {
                          if (docs[i]['ownerId'] == currentUser?.uid) {
                            userPosition = i + 1;  // 순번은 1부터 시작
                            break;
                          }
                        }

                        return Column(
                          children: [
                            const Text(
                              '대기자 수',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$waitingCount',
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                            ),
                            if (userPosition != null)
                              Text(
                                '내 순번: $userPosition',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          onPressed: () async {
                            if (hasReservation) {
                              // 예약 취소 확인 다이얼로그 띄우기
                              final confirmed = await showCancelReservationDialog(
                                context,
                                widget.place['name'],
                              );

                              if (confirmed) {
                                // 다이얼로그에서 '예'를 선택했을 때만 예약 취소 진행
                                cancelReservation(snapshot.data!.docs.first.id);
                              }
                            } else {
                              // 예약이 없으면 shop 예약
                              reserveShop(waitingCount);
                            }
                          },
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
                      // 찜 버튼
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
                          onPressed: _toggleLike,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '찜',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                            ScaffoldMessenger.of(context).clearSnackBars();
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
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' 예약 안내 ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: '!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
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
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: '번째 순서로 예약하시겠어요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
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
                        backgroundColor: Colors.white, // 배경을 흰색으로 설정
                        elevation: 0, // 버튼 그림자 제거
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 둥근 모서리
                          side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
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
        title: Text(
          '상세위치',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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