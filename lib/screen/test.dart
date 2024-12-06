import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  // QR 코드에 포함될 딥 링크 URL
  final String qrData = "https://dhdheb.github.io";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR 코드 생성")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("업주 QR 코드 생성"),
            const SizedBox(height: 20),
            // QR 코드 생성
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Test(),
  ));
}
