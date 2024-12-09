import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:yemi/screen/shopdetail.dart';
import 'package:yemi/screen/userinfo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class ShopDetailPage extends StatefulWidget {
  final Map<String, dynamic> shop;
  final String shopId;

  const ShopDetailPage({Key? key, required this.shop, required this.shopId})
      : super(key: key);

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  bool _isOpen = false;
  bool _isPlayingAnimation = false;
  bool _showQueueList = false;
  bool _showQRCode = false; // QR 코드 표시 여부

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.shop['isOpen'] ?? false;
  }

  String _generateQRCodeLink() {
    final shopId = widget.shopId;
    return 'https://dhdheb.github.io/reserve/$shopId'; // 딥링크 URL
  }

  Future<bool> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
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
                        text: ' $title ',
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
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 배경을 흰색으로 설정
                          elevation: 0, // 버튼 그림자 제거
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
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
    ) ??
        false;
  }

  Future<void> _updateShopStatus(bool value) async {
    try {
      // Firestore의 'shop' 컬렉션에서 매장 상태 업데이트
      await _firestore.collection('shop').doc(widget.shopId).update({
        'isOpen': value,
      });

      setState(() {
        _isOpen = value;
      });

      // 가게를 닫는 경우에만 대기열 삭제
      if (!value) {
        await _clearQueueForShop(widget.shopId);
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '매장이 열렸습니다.' : '매장이 닫혔습니다.'),
        ),
      );
    } catch (e) {
      print('Firestore 업데이트 오류: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

// 특정 매장의 대기열 삭제 함수
  Future<void> _clearQueueForShop(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection('queue')
          .where('shopId', isEqualTo: shopId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('대기열 삭제 완료');
    } catch (e) {
      print('대기열 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대기열 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<String?> _getDeviceToken(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['deviceToken'] as String?;
      } else {
        print('해당 사용자가 존재하지 않습니다.');
        return null;
      }
    } catch (e) {
      print('deviceToken 가져오기 오류: $e');
      return null;
    }
  }

  Future<void> _sendNotificationToUser(
      String deviceToken, String title, String body) async {
    const serverUrl = "http://175.45.193.45:3000/send-notification";

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceToken': deviceToken,
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        print('푸시 알림이 성공적으로 전송되었습니다.');
      } else {
        print('푸시 알림 전송 실패: ${response.body}');
      }
    } catch (e) {
      print('푸시 알림 요청 오류: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchQueueListWithUid() async {
    try {
      final querySnapshot = await _firestore
          .collection('queue')
          .where('shopId', isEqualTo: widget.shopId)
          .orderBy('timestamp') // timestamp 기준으로 정렬
          .get();

      final List<Map<String, dynamic>> queueList = [];

      for (final doc in querySnapshot.docs) {
        final String ownerId = doc['ownerId'] as String;
        final Timestamp timestamp = doc['timestamp'] as Timestamp;

        final userSnapshot =
            await _firestore.collection('users').doc(ownerId).get();

        if (userSnapshot.exists) {
          queueList.add({
            'nickname': userSnapshot['nickname'] as String,
            'userId': ownerId,
            'timestamp': timestamp.toDate(), // DateTime 변환
          });
        }
      }

      print(queueList);

      return queueList;
    } catch (e) {
      print('대기 팀 명단 불러오기 오류: $e');
      return [];
    }
  }

  Future<void> _playOpenAnimation() async {
    setState(() {
      _isPlayingAnimation = true;
    });

    // Lottie 애니메이션 재생 대기
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _isPlayingAnimation = false;
      _isOpen = true;
    });

    _updateShopStatus(true);
  }

  Future<void> _callNextTeam() async {
    try {
      // 가장 오래된 대기 팀 가져오기
      final querySnapshot = await _firestore
          .collection('queue')
          .where('shopId', isEqualTo: widget.shopId)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final oldestTeam = querySnapshot.docs.first;
        final String ownerId = oldestTeam['ownerId'];

        // Firestore에서 해당 사용자의 deviceToken 가져오기
        final String? deviceToken = await _getDeviceToken(ownerId);

        if (deviceToken != null) {
          // 서버에 알림 요청 보내기
          await _sendNotificationToUser(
            deviceToken,
            '대기 순서가 되었습니다!',
            '매장을 방문할 준비를 해주세요!',
          );

          // 알림 정보를 'notifications' 컬렉션에 저장
          await _addNotificationToFirestore(
            ownerId,  // 알림을 받을 사용자 ID
            '대기 순서가 되었습니다!',  // 알림 메시지
            '매장에 방문할 준비를 해주세요!',  // 알림 상세 설명
            widget.shopId,  // 매장 ID
          );

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('다음 팀에게 알림을 보냈습니다.')),
          );
        } else {
          print('deviceToken을 찾을 수 없습니다.');
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대기 중인 팀이 없습니다.')),
        );
      }
    } catch (e) {
      print('대기 팀 호출 오류: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 중 오류가 발생했습니다.')),
      );
    }
  }

// 알림 정보를 'notifications' 컬렉션에 추가하는 함수
  Future<void> _addNotificationToFirestore(
      String userId,
      String title,
      String body,
      String shopId,
      ) async {
    try {
      // 'notifications' 컬렉션에 레코드 추가
      await _firestore.collection('notifications').add({
        'userId': userId,  // 알림을 받을 사용자 ID
        'title': title,  // 알림 제목
        'body': body,  // 알림 내용
        'read': false,  // 알림 읽음 여부 (기본값 false)
        'timestamp': FieldValue.serverTimestamp(),  // 알림 생성 시간
      });

      print('알림이 Firestore에 추가되었습니다.');
    } catch (e) {
      print('알림 추가 오류: $e');
    }
  }


  // '입장 확인' 버튼을 누르면 가장 오래된 대기 팀을 dequeue하고 처리합니다.
  Future<void> _confirmEntry() async {
    try {
      // 가장 오래된 대기 팀 가져오기
      final querySnapshot = await _firestore
          .collection('queue')
          .where('shopId', isEqualTo: widget.shopId)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final oldestTeam = querySnapshot.docs.first;

        // Firestore에서 대기 팀 제거
        await oldestTeam.reference.delete();

        // 새로고침을 위한 setState 호출
        setState(() {});

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대기 팀을 입장 확인하고 제거했습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대기 중인 팀이 없습니다.')),
        );
      }
    } catch (e) {
      print('대기 팀 입장 확인 오류: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(
          '업체관리',
          style: TextStyle(color: Colors.teal[200], fontSize: 20),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopInfo(
                        shop: widget.shop,
                        shopId: widget.shopId,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: const Color(0xFFF5FCFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.shop['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF80CBC4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.shop['address']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_isOpen)
              Center(
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '     현재 대기 팀',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[200],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showQueueList = !_showQueueList;
                            });
                          },
                          icon: Image.asset(
                            _showQueueList
                                ? 'assets/icon/assds.png'  // 대기 팀 명단 보기 이미지 경로
                                : 'assets/icon/assds.png', // 대기 팀 수 보기 이미지 경로
                            width: 25, // 아이콘 크기
                            height: 25, // 아이콘 크기
                          ),
                          padding: EdgeInsets.all(10),  // 아이콘 주변 여백
                          splashRadius: 30,  // 클릭 시 물결 효과 반지름
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 대기 팀 수 또는 명단 표시
                    _showQueueList
                        ? FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchQueueListWithUid(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return const Text(
                                    '대기 팀 명단을 가져오는 중 오류가 발생했습니다.');
                              }

                              if (snapshot.hasData) {
                                final List<Map<String, dynamic>> queueList =
                                    snapshot.data!;
                                return queueList.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: queueList.length,
                                        itemBuilder: (context, index) {
                                          final String nickname =
                                              queueList[index]['nickname']!;
                                          final String userId =
                                              queueList[index]['userId']!;
                                          final DateTime timestamp =
                                              queueList[index]['timestamp']!;

                                          // 날짜 및 시간 포맷
                                          final formattedTime =
                                              "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

                                          return ListTile(
                                            leading: CircleAvatar(
                                              radius: 15, // CircleAvatar의 크기를 줄이기 (기본 값은 20, 여기서 값을 조정)
                                              child: Text(
                                                (index + 1).toString(), // 순번
                                                style: TextStyle(fontSize: 14), // 텍스트 크기 줄이기
                                              ),
                                              backgroundColor: Colors.teal[200],
                                              foregroundColor: Colors.white,
                                            ),

                                              title: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserInfoPage(
                                                            userId: userId),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                nickname,
                                                style: const TextStyle(
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                            subtitle:
                                                Text("$formattedTime"),
                                            trailing: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserInfoPage(
                                                            userId: userId),
                                                  ),
                                                );
                                              },
                                              child: const Icon(
                                                  Icons.chevron_right),
                                            ),
                                            onTap: () {
                                              // ListTile 전체 클릭 시
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserInfoPage(
                                                          userId: userId),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : const Text('현재 대기 중인 팀이 없습니다.');
                              }

                              return const Text('대기 팀 명단을 가져올 수 없습니다.');
                            },
                          )
                        : StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('queue')
                                .where('shopId', isEqualTo: widget.shopId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return const Text(
                                    '대기 인원 수를 가져오는 중 오류가 발생했습니다.');
                              }

                              if (snapshot.hasData) {
                                final int waitingCount =
                                    snapshot.data!.docs.length;
                                return Text(
                                  '$waitingCount',
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              return const Text('대기 인원 수를 가져올 수 없습니다.');
                            },
                          ),

                    const SizedBox(height: 20),

                    // '다음 팀 호출' 버튼과 '입장 확인' 버튼을 가로로 나란히 배치
                    if (_isOpen)
                    const SizedBox(height: 20),
                    Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 가로로 중앙 정렬
                          children: [
                            // '다음 팀 호출' 버튼
                            ElevatedButton(
                              onPressed: _callNextTeam,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFCAE5E4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                minimumSize: const Size(100, 50), // 너비 200, 높이 50으로 고정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                '다음 팀 호출',
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ),

                            const SizedBox(width: 20), // 버튼들 사이에 간격을 줍니다.

                            // '입장 확인' 버튼
                            ElevatedButton(
                              onPressed: _confirmEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFCAE5E4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                minimumSize: const Size(120, 50), // 너비 200, 높이 50으로 고정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                '입장 확인',
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                  ],
                ),
              ),


            const SizedBox(height: 30),
            Divider(color: Colors.grey),
            const SizedBox(height: 30),

            // 스위치와 애니메이션 처리
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isPlayingAnimation)
                    Lottie.asset(
                      'assets/animation/shopopen.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      repeat: false,
                      onLoaded: (composition) {
                        Future.delayed(composition.duration, () {
                          setState(() {
                            _isPlayingAnimation = false;
                            _isOpen = true;
                          });
                          _updateShopStatus(true);
                        });
                      },
                    )
                  else
                    Switch(
                      value: _isOpen,
                      onChanged: (value) async {
                        // 팝업 다이얼로그 띄우기
                        final result = await showCustomDialog(
                          context: context,
                          title: '매장 상태 변경',
                          content: value ? '매장을 열겠습니까?' : '매장을 닫겠습니까?',
                          confirmText: '확인',
                          cancelText: '취소',
                          onConfirm: () {
                            print('확인 버튼 클릭');
                          },
                        );

                        // 확인 버튼을 눌렀을 때만 상태 변경
                        if (result == true) {
                          if (value) {
                            _playOpenAnimation();
                          } else {
                            setState(() {
                              _isOpen = false;
                            });
                            _updateShopStatus(false);
                          }
                        }
                      },
                      activeColor: Colors.teal,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    _isOpen ? '오늘도 화이팅입니다!' : '매장을 아직 오픈하지 않았어요!',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    _isOpen ? '영업이 종료되었으면 불을 꺼주세요' : '스위치를 눌러 불을 켜주세요',
                    style: TextStyle(fontSize: 15, color: Colors.teal[200]),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showQRCode = !_showQRCode; // QR 코드 표시 여부 토글
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCAE5E4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _showQRCode ? 'QR 코드 숨기기' : 'QR 코드 생성',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  if (_showQRCode)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: QrImageView(
                          data: _generateQRCodeLink(), // 딥링크 URL을 QR 코드로 변환
                          version: QrVersions.auto,
                          size: 200.0, // QR 코드 크기
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
