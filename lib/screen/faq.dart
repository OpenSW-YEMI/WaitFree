import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '전체';

  // FAQ 데이터
  final List<Map<String, String>> faqs = [
    {'category': '계정', 'question': '소셜 로그인은 어떤 계정을 지원하나요?'},
    {'category': '계정', 'question': '내 개인정보는 어떻게 변경하나요?'},
    {'category': '계정', 'question': '계정 탈퇴는 어떻게 하나요?'},
    {'category': '계정', 'question': '서비스를 이용할 수 없어요'},
    {'category': '신고', 'question': '비매너 유저를 신고하고 싶어요'},
    {'category': '신고', 'question': '신고를 취소할 수 있나요?'},
    {'category': '건의사항', 'question': '건의하고 싶은 사항이 있어요'},
    {'category': '기타', 'question': '앱 이용 중 오류가 발생했어요'},
  ];

  // 카테고리 목록
  final List<String> categories = ['전체', '계정', '신고', '건의사항', '기타'];

  // 필터링된 FAQ 목록 가져오기
  List<Map<String, String>> getFilteredFAQs() {
    List<Map<String, String>> filteredFAQs = faqs;

    if (_selectedCategory != '전체') {
      filteredFAQs = filteredFAQs
          .where((faq) => faq['category'] == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredFAQs = filteredFAQs
          .where((faq) =>
          faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredFAQs;
  }

  @override
  Widget build(BuildContext context) {
    final filteredFAQs = getFilteredFAQs();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '자주 묻는 질문',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25.0),
        child: Column(
          children: [
            // 검색창
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SizedBox(
                width: 300, // 원하는 너비를 설정
                height: 40, // 원하는 높이를 설정
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13), // hintText 색상과 크기
                    prefixIcon: Icon(Icons.search, color: Colors.teal[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            // 카테고리 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: categories.map((category) {
                  final bool isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.teal[200] : Colors.grey,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              height: 2,
                              width: 30,
                              color: Colors.teal[200],
                            )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 질문 목록
            Expanded(
              child: ListView.builder(
                itemCount: filteredFAQs.length,
                itemBuilder: (context, index) {
                  final faq = filteredFAQs[index];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // 카테고리
                            Expanded(
                              flex: 2,
                              child: Text(
                                faq['category']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            // 질문
                            Expanded(
                              flex: 5,
                              child: Text(
                                faq['question']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
