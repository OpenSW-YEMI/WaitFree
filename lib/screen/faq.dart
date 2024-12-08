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
    {
      'category': '계정',
      'question': '소셜 로그인은 어떤 계정을 지원하나요?',
      'answer': '현재 웨잇프리 앱에서는 구글과 카카오 로그인을 지원하고 있습니다. 다양한 소셜 계정을 이용해 간편하게 로그인할 수 있습니다.'
    },
    {
      'category': '계정',
      'question': '내 정보는 어떻게 변경하나요?',
      'answer': '현재는 개인정보 변경 기능이 제공되고 있지 않습니다. 더 나은 서비스를 제공할 수 있도록 최선을 다하겠습니다. 감사합니다.'
    },
    {
      'category': '계정',
      'question': '계정 탈퇴는 어떻게 하나요?',
      'answer': '현재는 계정탈퇴 기능이 별도로 제공되고 있지 않습니다. 다만, 고객센터로 회원 탈퇴 신청 문의를 주신다면 빠르게 처리해 드리겠습니다. 탈퇴 시 모든 데이터가 삭제되며 복구가 불가능하니 신중히 선택해 주세요.'
    },
    {
      'category': '계정',
      'question': '서비스를 이용할 수 없어요',
      'answer': '잦은 노쇼, 고의적인 예약 취소, 매크로 사용 등 악의적인 행동이 발견된 경우, 서비스 이용이 일시적으로 제한될 수 있습니다. '
    },
    {
      'category': '신고',
      'question': '비매너 유저를 신고하고 싶어요',
      'answer': '손님의 프로필 화면에서 [신고하기] 버튼을 눌러 비매너 유저를 신고할 수 있습니다. 신고된 이용자는 관리자가 검토 후 적절한 조치를 취합니다.'
    },
    {
      'category': '신고',
      'question': '몇 번의 신고가 누적되어야 이용에 제한이 있나요?',
      'answer': '신고가 3회 이상 누적될 경우 계정이 일시적으로 제한되며, 사안에 따라 영구 정지가 될 수도 있습니다. 악의적인 신고는 반려될 수 있습니다.'
    },
    {
      'category': '건의사항',
      'question': '건의하고 싶은 사항이 있어요',
      'answer': '[정보] - [1:1 문의하기] 메뉴를 통해 건의 사항을 보내주시면 검토 후 반영하도록 노력하겠습니다. 더 나은 서비스를 제공할 수 있도록 최선을 다하겠습니다. 감사합니다.'
    },
    {
      'category': '기타',
      'question': '앱 이용 중 오류가 발생했어요',
      'answer': '오류 발생 시 [정보] - [1:1 문의하기]를 통해 상세 내용을 전달해 주시면 신속히 해결해 드리겠습니다. 앱 재설치나 업데이트를 통해 문제를 해결할 수도 있습니다. 더 나은 서비스를 제공할 수 있도록 최선을 다하겠습니다. 감사합니다.'
    },
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
          .where((faq) => faq['question']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
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
        scrolledUnderElevation: 0,
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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15.0),
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
                    hintStyle: const TextStyle(
                        color: Colors.grey, fontSize: 13), // hintText 색상과 크기
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                              isSelected ? Colors.teal[200] : Colors.grey,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 16.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ExpansionTile(
                        title: Row(
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
                                  fontSize: 13,
                                ),
                                maxLines: 2, // 두 줄 이상 표시
                                overflow: TextOverflow.visible, // 텍스트가 잘리지 않도록 설정
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              faq['answer']!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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
