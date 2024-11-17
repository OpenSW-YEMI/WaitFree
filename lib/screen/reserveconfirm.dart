import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String shopName;
  const ConfirmationScreen({Key? key, required this.shopName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '예약 완료',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.check_circle, color: Colors.teal[200], size: 100),
              const SizedBox(height: 20),
              const Text(
                '예약이 확정되었습니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                '도착 시 직원께 문의해주세요',
                style: TextStyle(fontSize: 18, color: Colors.teal[200]),
                textAlign: TextAlign.center,
              ),
              Text(
                '대기 순서는 사정에 따라 변경될 수 있어요',
                style: TextStyle(fontSize: 18, color: Colors.teal[200]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCAE5E4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
