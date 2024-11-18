import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:yemi/screen/shopdetail.dart';

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
  bool _isPlayingAnimation = false; // 애니메이션 재생 여부

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.shop['isOpen'] ?? false;
  }

  Future<void> _updateShopStatus(bool value) async {
    try {
      await _firestore.collection('shop').doc(widget.shopId).update({
        'isOpen': value,
      });

      setState(() {
        _isOpen = value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '매장이 열렸습니다.' : '매장이 닫혔습니다.'),
        ),
      );
    } catch (e) {
      print('Firestore 업데이트 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _dequeueOldestTeam() async {
    try {
      final querySnapshot = await _firestore
          .collection('queue')
          .where('shopId', isEqualTo: widget.shopId)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가장 오래된 대기 팀이 처리되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대기 중인 팀이 없습니다.')),
        );
      }
    } catch (e) {
      print('대기 팀 삭제 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('업체관리', style: TextStyle(color: Colors.teal[200], fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity, // 가로로 꽉 차게 설정
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
                  color: const Color(0xFFF3F9FB),
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
                            color: Colors.teal,
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

            const SizedBox(height: 60),

            if (_isOpen)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '현재 대기 팀',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('queue')
                        .where('shopId', isEqualTo: widget.shopId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text('대기 인원 수를 가져오는 중 오류가 발생했습니다.');
                      }

                      if (snapshot.hasData) {
                        final int waitingCount = snapshot.data!.docs.length;
                        return Column(
                          children: [
                            Text(
                              '$waitingCount',
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // "처리 완료" 버튼, 대기 인원 수에 따라 비활성화/활성화 설정
                            ElevatedButton(
                              onPressed: waitingCount > 0 ? _dequeueOldestTeam : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: waitingCount > 0
                                    ? Colors.teal[200]
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                waitingCount > 0 ? '다음 팀 들어오세요!' : '대기 중인 손님이 없어요',
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      }

                      return const Text('대기 인원 수를 가져올 수 없습니다.');
                    },
                  ),

                  const SizedBox(height: 30),
                  Divider(color: Colors.teal[200]),
                  const SizedBox(height: 30),
                ],
              ),

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
                        // 애니메이션 완료 후 상태 업데이트
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
                      onChanged: (value) {
                        if (value) {
                          _playOpenAnimation(); // 애니메이션 재생
                        } else {
                          setState(() {
                            _isOpen = false;
                          });
                          _updateShopStatus(false);
                        }
                      },
                      activeColor: Colors.teal,
                    ),

                  const SizedBox(height: 30),

                  Text(
                    _isOpen ? '오늘도 화이팅입니다!' : '매장을 아직 오픈하지 않았어요!',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    _isOpen
                        ? '영업이 종료되었으면 불을 꺼주세요'
                        : '스위치를 눌러 불을 켜주세요',
                    style: TextStyle(fontSize: 15, color: Colors.teal[200]),
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
