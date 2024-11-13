import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 장소 목록 (임시 데이터)
  final List<Map<String, dynamic>> places = [
    {
      'name': '세븐치킨',
      'address': '구미 인동 대로41',
      'status': '혼잡',
      'people': 35,
      'image': 'assets/test_image/shop_test.png'
    },
    {
      'name': '참좋은연합의원',
      'address': '구미 양호동 1길 32',
      'status': '여유',
      'people': 3,
      'image': 'assets/test_image/shop_test.png'
    },
    {
      'name': '역전할머니맥주',
      'address': '구미 옥계동 중앙로 2길',
      'status': '보통',
      'people': 12,
      'image': 'assets/test_image/shop_test.png'
    },
    {
      'name': '이철커커헤어',
      'address': '구미 옥계동 강변로86-3',
      'status': '보통',
      'people': 12,
      'image': 'assets/test_image/shop_test.png'
    },
    {
      'name': '뛰뛰빵빵',
      'address': '구미 인동 구남로10',
      'status': '여유',
      'people': 1,
      'image': 'assets/test_image/shop_test.png'
    },
  ];

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
                      leading: Image.asset(
                        place['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
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
