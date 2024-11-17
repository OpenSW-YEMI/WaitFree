import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RegisterHelpPage extends StatefulWidget {
  const RegisterHelpPage({super.key});

  @override
  State<RegisterHelpPage> createState() => _RegisterHelpPageState();
}

class _RegisterHelpPageState extends State<RegisterHelpPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "업체등록 도움말",
          style: TextStyle(color: Colors.teal[200], fontSize: 20),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  // 첫 번째 페이지
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '업체를 등록하시나요?',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이 기능을 이용할 수 있어요',
                          style: TextStyle(fontSize: 18, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 40),
                        rowWithIcon('지도에 내 업체를 노출시킬 수 있어요', Icons.map_outlined),
                        rowWithIcon('방문 예약자를 받을 수 있어요', Icons.calendar_today_outlined),
                        rowWithIcon('혼잡도 기준 인원 수를 설정할 수 있어요', Icons.people_outline),
                      ],
                    ),
                  ),

                  // 두 번째 페이지
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '몇 가지 정보가 필요해요',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아래는 필수 사항이에요',
                          style: TextStyle(fontSize: 18, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 40),
                        rowWithIcon('대표자 정보(이름, 생년월일, 연락처)', Icons.person_outline),
                        rowWithIcon('상호, 가게 연락처, 개업일자', Icons.business_outlined),
                        rowWithIcon('사업자 등록 번호', Icons.receipt_long_outlined),
                        rowWithIcon('업체 주소 (우편번호, 상세주소)', Icons.location_on_outlined),
                      ],
                    ),
                  ),

                  // 세 번째 페이지
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '몇 가지 안내사항이에요',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '준비가 되셨다면 업체 등록을 진행할게요!',
                          style: TextStyle(fontSize: 18, color: Colors.teal[200]),
                        ),
                        const SizedBox(height: 40),
                        rowWithIcon('운영자가 검토 후 업체 등록 승인을 해드려요', Icons.check_circle_outline),
                        rowWithIcon('승인까지 1~3일 소요될 수 있어요', Icons.access_time_outlined),
                        rowWithIcon('문제가 있다면 고객센터로 문의해주세요', Icons.phone_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 페이지 인디케이터와 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 16,
                      dotColor: Colors.grey,
                      activeDotColor: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 고정된 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: _currentPageIndex == 2
                          ? () {
                        Navigator.pushNamed(context, '/register');
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPageIndex == 2
                            ? const Color(0xFFCAE5E4)
                            : Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "등록하기",
                        style: TextStyle(
                          fontSize: 18,
                          color: _currentPageIndex == 2 ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 아이콘과 텍스트를 나란히 표시하는 위젯
  Widget rowWithIcon(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
