import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart' as geocoding;  // geocoding의 Location을 별칭
import 'package:location/location.dart' as loc;  // location 패키지의 Location을 loc로
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yemi/screen/detail.dart';
import 'dart:math';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> places = [];
  loc.Location location = loc.Location();
  String _sortOption = '자';  // 기본값은 '가' (거리순)

  @override
  void initState() {
    super.initState();
    getShops();
  }

  Future<void> getShops() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('shop').get();

      final List<Map<String, dynamic>> fetchedPlaces = await Future.wait(snapshot.docs.map((doc) async {
        final String address = doc['address'];
        double lat = doc['lat'] ?? 0.0;
        double lng = doc['lng'] ?? 0.0;

        if (lat == 0.0 || lng == 0.0) {
          try {
            List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
            lat = locations.first.latitude;
            lng = locations.first.longitude;

            await FirebaseFirestore.instance.collection('shop').doc(doc.id).update({
              'lat': lat,
              'lng': lng,
            });
          } catch (e) {
            print("Failed to update lat/lng for ${doc.id}: $e");
          }
        }

        return {
          'id': doc.id,
          'name': doc['name'],
          'address': address,
          'normal': doc['normal'],
          'crowded': doc['crowded'],
          'lat': lat,
          'lng': lng,
        };
      }).toList());

      setState(() {
        places = fetchedPlaces;
        if (_sortOption == '가') {
          _sortByDistance();
        } else if (_sortOption == '혼') {
          _sortByCrowd();
        } else if (_sortOption == '자') {
          _sortByName();
        }
      });
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  // 가게 이름을 한글 자모 순으로 정렬 -> 영어는?
  void _sortByName() {
    places.sort((a, b) {
      return a['name'].compareTo(b['name']);
    });

    setState(() {
      places = places;
    });
  }

  // 거리 순으로 정렬
  Future<void> _sortByDistance() async {
    final locData = await location.getLocation();
    if (locData.latitude == null || locData.longitude == null) {
      print("현재 위치를 찾을 수 없습니다.");
      return;
    }
    final double userLat = locData.latitude!;
    final double userLng = locData.longitude!;

    places.sort((a, b) {
      final double distanceA = _calculateDistance(userLat, userLng, a['lat'], a['lng']);
      final double distanceB = _calculateDistance(userLat, userLng, b['lat'], b['lng']);
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      places = places;
    });
  }

  // 두 지점 간의 거리 계산 (단위: km)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLng = (lng2 - lng1) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;  // 거리 계산
  }

  // 혼잡도 순으로 정렬
  void _sortByCrowd() {
    places.sort((a, b) {
      final int waitingCountA = a['normal'];
      final int waitingCountB = b['normal'];

      if (waitingCountA < waitingCountB) return -1;
      if (waitingCountA > waitingCountB) return 1;
      return 0;
    });

    setState(() {
      places = places;  // 상태 갱신
    });
  }

  // 검색어에 따라 장소 필터링
  List<Map<String, dynamic>> getFilteredPlaces() {
    if (_searchQuery.isEmpty) {
      return places;
    } else {
      return places.where((place) {
        return place['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || place['address'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
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

  // 대기 인원 수와 혼잡도 정보 가져오기
  Future<Map<String, dynamic>> getShopStatus(String shopId, int normal, int crowded) async {
    try {
      final QuerySnapshot queueSnapshot = await FirebaseFirestore.instance
          .collection('queue')
          .where('shopId', isEqualTo: shopId)
          .get();

      final int waitingCount = queueSnapshot.docs.length;

      String status;
      if (waitingCount <= normal) {
        status = '여유';
      } else if (waitingCount <= crowded) {
        status = '보통';
      } else {
        status = '혼잡';
      }

      return {
        'status': status,
        'waitingCount': waitingCount,
      };
    } catch (e) {
      print('Error fetching queue data: $e');
      return {
        'status': '정보 없음',
        'waitingCount': 0,
      };
    }
  }

  // 현재 위치 기반으로 지도 화면 띄우기
  Future<void> showMap() async {
    final locData = await location.getLocation();
    if (locData.latitude == null || locData.longitude == null) {
      print("현재 위치를 찾을 수 없습니다.");
      return;
    }
    final double userLat = locData.latitude!;
    final double userLng = locData.longitude!;

    Set<Marker> markers = {};

    // 필터링 범위 설정 (예: 500m)
    const double range = 0.8;  // 500m = 0.5km
    const double earthRadius = 6371; // 지구 반지름 (km)

    for (var place in places) {
      final double shopLat = place['lat'];
      final double shopLng = place['lng'];

      double distance = earthRadius *
          2 *
          asin(sqrt(pow(sin((userLat - shopLat) * pi / 180 / 2), 2) +
              cos(userLat * pi / 180) *
                  cos(shopLat * pi / 180) *
                  pow(sin((userLng - shopLng) * pi / 180 / 2), 2)));

      if (distance <= range) {
        markers.add(Marker(
          markerId: MarkerId(place['id']),
          position: LatLng(shopLat, shopLng),
          infoWindow: InfoWindow(title: place['name']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }
    }

    // 현재 위치 마커 추가
    markers.add(Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(userLat, userLng),
      infoWindow: InfoWindow(title: '현재 위치'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // 지도에 500m 반경 원 추가
    Circle circle = Circle(
      circleId: CircleId('user_location_range'),
      center: LatLng(userLat, userLng),
      radius: range * 1000,  // 범위는 미터로 설정하므로 500m -> 0.5km * 1000
      strokeWidth: 2,
      strokeColor: Colors.blue.withOpacity(0.5),
      fillColor: Colors.blue.withOpacity(0.1),
    );

    // 지도 화면 띄우기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('지도 보기')),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(userLat, userLng),
              zoom: 17,
            ),
            markers: markers,
            circles: {circle},  // Circle 추가
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = getFilteredPlaces();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      prefixIcon: Icon(Icons.search, color: Colors.teal[200]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortOption = value;
                      if (value == '가') {
                        _sortByDistance();
                      } else if (value == '혼') {
                        _sortByCrowd();
                      } else if (value == '자') {
                        _sortByName();
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: '가',
                      child: Text('거리 순'),
                    ),
                    PopupMenuItem<String>(
                      value: '혼',
                      child: Text('혼잡도 순'),
                    ),
                    PopupMenuItem<String>(
                      value: '자',
                      child: Text('이름 순'),
                    ),
                  ],
                  child: Icon(Icons.sort, color: Colors.teal),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: showMap,
                  child: const Text('지도 보기', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: getShops,
                child: ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return FutureBuilder<Map<String, dynamic>>(
                      future: getShopStatus(place['id'], place['normal'], place['crowded']),
                      builder: (context, statusSnapshot) {
                        if (statusSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('정보를 불러오는 중...'),
                            leading: CircularProgressIndicator(),
                          );
                        }

                        if (statusSnapshot.hasError || !statusSnapshot.hasData) {
                          return const ListTile(
                            title: Text('정보를 가져올 수 없습니다.'),
                          );
                        }

                        final statusData = statusSnapshot.data!;
                        final String status = statusData['status'];
                        final int waitingCount = statusData['waitingCount'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                place['name'],
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[200]),
                              ),
                              subtitle: Text(
                                place['address'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$waitingCount명 대기 중',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(place: place),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
