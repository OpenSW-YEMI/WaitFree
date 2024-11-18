import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.shop['isOpen'] ?? false;
  }

  // Firestore에서 'shop' 문서의 isOpen 필드를 업데이트하는 함수
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('업체관리', style: TextStyle(color: Colors.teal[200])),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.shop['name']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text('${widget.shop['address']}'),
            const SizedBox(height: 60),

            // 스위치가 켜져 있을 때만 새로운 위젯 표시
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
                  Divider(color: Colors.teal[200]),
                  const SizedBox(height: 30),

                ],
              ),

            // 매장 열림/닫힘 스위치
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 20),
                  Switch(
                    value: _isOpen,
                    onChanged: (value) {
                      setState(() {
                        _isOpen = value;
                      });
                      _updateShopStatus(value);
                    },
                    activeColor: Colors.teal,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
