import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  // QR 코드에 포함될 URL
  final String qrData = "yemi://profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR 코드 생성")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("업주 QR 코드 생성"),
            SizedBox(height: 20),
            // QR 코드 생성
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text(
              '링크: $qrData',
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/profile');
              },
              child: Text('Go to Profile Page'),
            ),
          ],
        ),
      ),
    );
  }
}
