import 'package:flutter/material.dart';

class MembershipInfoPage extends StatelessWidget {
  final String membershipLevel; // 현재 회원의 등급
  final int reservecount; // 현재 예약 횟수

  const MembershipInfoPage({Key? key, required this.membershipLevel, required this.reservecount})
      : super(key: key);

  // Function to calculate the number of reservations needed for the next level
  int _getNextLevelThreshold() {
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
  int _getRemainingForNextLevel() {
    int nextLevelThreshold = _getNextLevelThreshold();
    if (nextLevelThreshold == 0) {
      return 0; // No more levels to reach
    } else {
      return nextLevelThreshold - reservecount;
    }
  }

  // Function to get the appropriate image asset for each level
  String _getLevelImage() {
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

  @override
  Widget build(BuildContext context) {
    int nextLevelThreshold = _getNextLevelThreshold();
    int remainingForNextLevel = _getRemainingForNextLevel();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          "내정보",
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "현재 회원님의 등급이에요",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // 남은 횟수 안내
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: remainingForNextLevel > 0
                          ? "다음 등급까지 "
                          : "축하합니다! ",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    if (remainingForNextLevel > 0)
                      TextSpan(
                        text: "$remainingForNextLevel회",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal[200], // 원하는 색상으로 변경
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    TextSpan(
                      text: remainingForNextLevel > 0
                          ? " 이용횟수 남았어요"
                          : " 최고 등급에 도달하셨습니다!",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              // Highlighted Membership Level Card
              Container(
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.teal, // Border color
                    width: 0.5, // Border width
                  ),
                  borderRadius: BorderRadius.circular(16), // Match with Card's borderRadius
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          _getLevelImage(),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            membershipLevel,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.teal[200],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          remainingForNextLevel > 0
                              ? "$reservecount / $nextLevelThreshold" // Show current and next level thresholds
                              : "$reservecount / 최고", // Show "최고" if at the highest level
                          style: TextStyle(
                            fontSize: 12,
                            color: remainingForNextLevel > 0 ? Colors.grey : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Divider(
                color: Colors.grey[300], // Divider color
                thickness: 1, // Divider thickness
                height: 20, // Space around the divider
              ),

              const SizedBox(height: 30),

              // 이용 횟수별 등급 안내
              const Text(
                "이용 횟수별 등급 안내",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1), // 첫 번째 열 너비 설정
                  1: FlexColumnWidth(2), // 두 번째 열 너비 설정
                },
                children: [
                  _buildTableRow("1~3회", "시간 절약의 견습생"),
                  _buildTableRow("4~8회", "분주한 하루의 균형자"),
                  _buildTableRow("9~15회", "시간의 마법사"),
                  _buildTableRow("16~24회", "시간 절약의 챔피언"),
                  _buildTableRow("25~35회", "시공간의 지배자"),
                  _buildTableRow("36회 이상", "최고 등급 도달"),
                ],
              ),

              const SizedBox(height: 30),

              Divider(
                color: Colors.grey[300], // Divider color
                thickness: 1, // Divider thickness
                height: 20, // Space around the divider
              ),

              const SizedBox(height: 30),

              // 기타 등급 안내
              const Text(
                "기타 등급 안내",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1), // 첫 번째 열 너비 설정
                  1: FlexColumnWidth(2), // 두 번째 열 너비 설정
                },
                children: [
                  _buildTableRow("첫 회원가입", "시간 절약의 첫 걸음"),
                  _buildTableRow("첫 이용정지", "꼭꼭 방문해 주세요"),
                  _buildTableRow("30일간 출석", "꾸준함의 대명사"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 테이블 행 생성 메서드
  TableRow _buildTableRow(String level, String description) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            level,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
