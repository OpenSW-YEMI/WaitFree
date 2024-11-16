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

  // Firestore에서 데이터를 가져오는 함수
  Future<void> getShops() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('shop').get();

      final List<Map<String, dynamic>> fetchedPlaces = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'address': doc['address'],
          'status': '여유',
          'people': 10,
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

  // 검색어에 따라 장소 필터링
  List<Map<String, dynamic>> getFilteredPlaces() {
    if (_searchQuery.isEmpty) {
      return places;
    } else {
      return places
          .where((place) =>
          place['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
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
                  hintStyle: const TextStyle(color: Colors.grey), // hintText 색상을 변경
                  prefixIcon: Icon(Icons.search, color: Colors.teal[200]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // contentPadding을 사용하여 인풋란의 높이 줄이기
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
                onRefresh: getShops, // 위로 당길 때 새로고침
                child: ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                place['status'],
                                style: TextStyle(
                                  color: getStatusColor(place['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${place['people']}명 대기 중',
                                style: TextStyle(color: Colors.grey),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
