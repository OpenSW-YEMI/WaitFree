import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemi/screen/detail.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> places = [];

  // Firestore에서 shop 데이터를 가져오는 함수
  Future<void> getShops() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('shop').get();

      final List<Map<String, dynamic>> fetchedPlaces = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'address': doc['address'],
          'normal': doc['normal'],
          'crowded': doc['crowded'],
          'lat': doc['lat'],
          'lng': doc['lng'],
        };
      }).toList();

      setState(() {
        places = fetchedPlaces;
      });
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getShops();
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

      // 혼잡도 계산
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

  // 검색어에 따라 장소 필터링
  List<Map<String, dynamic>> getFilteredPlaces() {
    if (_searchQuery.isEmpty) {
      return places;
    } else {
      return places
          .where((place) => place['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
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
            // 검색창
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.teal[200]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // 필터링된 장소 목록 표시
            Expanded(
              child: RefreshIndicator(
                onRefresh: getShops,
                child: ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getShopStatus(
                        place['id'],
                        place['normal'],
                        place['crowded'],
                      ),
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
