import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 주소 텍스트
                Expanded(
                  child: SelectableText(
                    place['address'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),

                // 주소 복사 버튼
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.teal),
                  tooltip: '주소 복사',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: place['address']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('주소가 복사되었습니다!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GoogleMap을 Expanded로 감싸서 화면 내에서 공간을 차지하도록 설정
            SizedBox(
              height: 150, // 고정된 높이 설정
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(36.1420, 128.4242),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(place['name']),
                    position: const LatLng(36.1420, 128.4242),
                    infoWindow: InfoWindow(title: place['name']),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
              ),
            )

          ],
        ),
      ),
    );
  }

  // 혼잡도에 따라 색상 변경
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
}
