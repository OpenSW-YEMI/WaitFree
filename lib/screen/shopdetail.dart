import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopInfo extends StatefulWidget {
  final Map<String, dynamic> shop;
  final String shopId;

  const ShopInfo({Key? key, required this.shop, required this.shopId})
      : super(key: key);

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  bool _isOpen = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Firestore에서 초기 영업 상태를 가져옵니다.
    _isOpen = widget.shop['isOpen'] ?? false;
  }

  // Firestore에서 'shop' 문서의 isOpen 상태를 업데이트하는 함수
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

  // 테이블 행 생성 함수
  TableRow _buildTableRow(String key, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shop['name'],
          style: TextStyle(color: Colors.teal[200], fontSize: 18),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '업체정보',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 테이블 형태로 정보 표시
            Table(
              columnWidths: const {
                0: FixedColumnWidth(100),
                1: FlexColumnWidth(),
              },
              children: [
                _buildTableRow('상호명', widget.shop['name'] ?? '정보 없음'),
                _buildTableRow('매장주소', widget.shop['address'] ?? '정보 없음'),
                _buildTableRow('연락처', widget.shop['contact'] ?? '정보 없음'),
                _buildTableRow('혼잡', '${widget.shop['crowded'] ?? 'N/A'}명부터'),
                _buildTableRow('여유', '${widget.shop['normal'] ?? 'N/A'}명부터'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
