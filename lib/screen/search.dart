import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 장소 목록 (임시 데이터)
  List<Map<String, dynamic>> places = [];

  // Firestore에서 데이터를 가져오는 함수
  Future<void> getShops() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('shop').get();

      // Firestore 문서들을 Map 형태로 변환하여 리스트에 추가
      final List<Map<String, dynamic>> fetchedPlaces = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'address': doc['address'],
          'status': '여유',
          'people': 10,
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
    getShops(); // 초기화 시 Firestore에서 데이터 가져오기
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
          .where((place) => place['name']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = getFilteredPlaces();

    return Scaffold(
      backgroundColor: Colors.white, // 화면 배경을 흰색으로 설정
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            child: ListView.builder(
              itemCount: filteredPlaces.length,
              itemBuilder: (context, index) {
                final place = filteredPlaces[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    color: Colors.white, // 카드 배경을 흰색으로 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        place['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(place['address']),
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
                        print('${place['name']} 선택됨');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
