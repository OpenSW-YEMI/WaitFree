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
            SelectableText(
              place['address'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 지도 섹션
            SizedBox(
              height: 150,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(place['lat'], place['lng']),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(place['name']),
                    position: LatLng(place['lat'], place['lng']),
                    infoWindow: InfoWindow(title: place['name']),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
              ),
            ),

            // 지도와 버튼을 딱 붙게 배치
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
                      Clipboard.setData(ClipboardData(text: place['address']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주소가 복사되었습니다!')),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('주소 복사', style: TextStyle(color: Colors.black, fontSize: 14)),
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
                            lat: place['lat'],
                            lng: place['lng'],
                            name: place['name'],
                          ),
                        ),
                      );
                    },

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text('지도 보기', style: TextStyle(color: Colors.black, fontSize: 14)),
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
  }
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
