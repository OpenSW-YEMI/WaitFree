import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemi/screen/membershipinfo.dart';
import 'package:yemi/screen/userinfo.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Function to determine membership level based on reservation count
  String _getMembershipLevel(int reservecount) {
    if (reservecount >= 25 && reservecount <= 35) {
      return "시공간의 지배자";
    } else if (reservecount >= 16 && reservecount <= 24) {
      return "시간 절약의 챔피언";
    } else if (reservecount >= 9 && reservecount <= 15) {
      return "시간의 마법사";
    } else if (reservecount >= 4 && reservecount <= 8) {
      return "분주한 하루의 균형자";
    } else if (reservecount >= 1 && reservecount <= 3) {
      return "시간 절약의 견습생";
    } else {
      return "시간 절약의 첫 걸음"; // 예약이 0회인 경우
    }
  }

  // Function to calculate the number of reservations needed for the next level
  int _getNextLevelThreshold(int reservecount) {
    if (reservecount <= 3) {
      return 4; // 시간 절약의 견습생 -> 분주한 하루의 균형자
    } else if (reservecount <= 8) {
      return 9; // 분주한 하루의 균형자 -> 시간의 마법사
    } else if (reservecount <= 15) {
      return 16; // 시간의 마법사 -> 시간 절약의 챔피언
    } else if (reservecount <= 24) {
      return 25; // 시간 절약의 챔피언 -> 시공간을 다스리는 초월자
    } else if (reservecount <= 35) {
      return 36; // 시공간을 다스리는 초월자 (최고 등급)
    } else {
      return 0; // Already at the highest level
    }
  }

  // Function to calculate how many more reservations are needed to reach the next level
  int _getRemainingForNextLevel(int reservecount) {
    int nextLevelThreshold = _getNextLevelThreshold(reservecount);
    if (nextLevelThreshold == 0) {
      return 0; // No more levels to reach
    } else {
      return nextLevelThreshold - reservecount;
    }
  }

  String _getLevelImage(int reservecount) {
    if (reservecount <= 3) {
      return 'assets/icon/level1.png'; // 시간 절약의 견습생
    } else if (reservecount <= 8) {
      return 'assets/icon/level2.png'; // 분주한 하루의 균형자
    } else if (reservecount <= 15) {
      return 'assets/icon/level3.png'; // 시간의 마법사
    } else if (reservecount <= 24) {
      return 'assets/icon/level4.png'; // 시간 절약의 챔피언
    } else if (reservecount <= 35) {
      return 'assets/icon/level5.png'; // 시공간을 다스리는 초월자
    } else {
      return 'assets/icon/level5.png'; // 최고 등급
    }
  }

  Future<bool> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' $title ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 배경을 흰색으로 설정
                          elevation: 0, // 버튼 그림자 제거
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    // 메뉴 항목 리스트
    final List<Map<String, dynamic>> menuItems = [
      {'title': '내 업체 등록', 'icon': Icons.app_registration, 'route': '/registerhelp'},
      {'title': '내 업체 관리', 'icon': Icons.manage_accounts, 'route': '/shopmanage'},
      {'title': '자주 묻는 질문', 'icon': Icons.question_answer, 'route': '/faq'}, // FAQ 메뉴 추가
      {'title': '고객센터', 'icon': Icons.support_agent, 'route': '/help'},
      // {'title': '알림 기능 테스트', 'icon': Icons.logout, 'route': '/notitest'},
      // {'title': 'QR 기능 테스트', 'icon': Icons.logout, 'route': '/qrtest'},
      {'title': '로그아웃', 'icon': Icons.logout, 'route': '/logout'},
    ];

    return Scaffold(
      body: SingleChildScrollView(  // SingleChildScrollView로 전체 페이지 감싸기
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 사용자 정보 섹션
              Container(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    // 현재 로그인된 사용자의 UID를 UserInfoPage로 전달
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInfoPage(userId: currentUser?.uid ?? ""),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/icon_person.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.displayName ?? "사용자 이름 없음", // DisplayName
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // 예약 횟수 및 회원 등급 섹션
              // 예약 횟수 및 회원 등급 섹션
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.uid)
                    .snapshots(), // 실시간 업데이트 스트림
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "예약 횟수: 로딩 중...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "예약 횟수: 정보 없음",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final int reservecount = data['reservecount'] ?? 0;
                  final String membershipLevel = _getMembershipLevel(reservecount);
                  final int remainingForNextLevel = _getRemainingForNextLevel(reservecount);
                  final int nextLevelThreshold = _getNextLevelThreshold(reservecount);
                  final double progress = nextLevelThreshold > 0
                      ? reservecount / nextLevelThreshold
                      : 1.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembershipInfoPage(
                            membershipLevel: membershipLevel, // 현재 등급 전달
                            reservecount: reservecount,       // 현재 예약 횟수 전달
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 130,
                      child: Card(
                        color: const Color(0xFFF5FCFB),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "$membershipLevel",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.teal[200],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    _getLevelImage(reservecount), // 등급에 맞는 이미지를 반환하는 함수
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                remainingForNextLevel > 0
                                    ? "다음 등급까지 $remainingForNextLevel회!"
                                    : "축하합니다! 최고 등급에 도달하셨습니다!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: remainingForNextLevel > 0 ? Colors.black : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8AD2D0)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$reservecount / $nextLevelThreshold",
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 메뉴 리스트 섹션
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListView.builder(
                  shrinkWrap: true,  // ListView의 크기 제한
                  physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return ListTile(
                      title: item['route'] == '/logout'
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,  // 텍스트와 아이콘을 좌측에 배치
                        children: [
                          const Text(
                            "로그아웃",
                            style: TextStyle(fontSize: 18),
                          ),  // "웃" 글자
                          const SizedBox(width: 8),  // 텍스트와 아이콘 사이 간격
                          Icon(item['icon'], color: Colors.teal, size: 24),  // 아이콘
                        ],
                      )
                          : Text(
                        item['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),  // 오른쪽에 화살표 아이콘
                      onTap: () async {
                        if (item['route'] == '/logout') {
                          final confirm = await showCustomDialog(
                            context: context,
                            title: '로그아웃',
                            content: '정말 로그아웃 하시겠습니까?',
                            confirmText: '확인',
                            cancelText: '취소',
                            onConfirm: () async {
                              await auth.signOut(); // 로그아웃 비동기 처리
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); // 모든 이전 경로를 제거하고 로그인 화면으로 이동
                            },
                          );

                          if (confirm) {
                            // 추가 처리 없음
                          }
                        } else {
                          Navigator.pushNamed(context, item['route']);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
