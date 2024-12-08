import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 패키지 추가

// 이메일 전송 함수
Future<void> sendEmail(String subject, String message, String replyToEmail, String reportedUid, String senderUid) async {
  // 1. SMTP 서버 설정 (예시: Gmail SMTP)
  final smtpServer = gmail('imingyu060@gmail.com', 'mjcr eslw foyd nflh'); // 발신자 이메일과 앱 비밀번호

  // 2. 이메일 메시지 생성
  final emailMessage = Message()
    ..from = Address('imingyu060@gmail.com', 'Flutter 신고 시스템') // 발신자 정보
    ..recipients.add('imingyu060@gmail.com')  // 수신자 이메일
    ..subject = subject                       // 이메일 제목
    ..text = '$message\n\n답변을 받을 이메일 주소: $replyToEmail\n신고된 사용자 UID: $reportedUid\n발신자 UID: $senderUid'; // 발신자 UID 추가

  try {
    // 3. 이메일 전송
    await send(emailMessage, smtpServer);
    print('이메일 전송 성공');
  } catch (e) {
    print('이메일 전송 실패: $e');
  }
}

// 신고 페이지 UI
class ReportPage extends StatefulWidget {
  final String reportedUid; // 신고할 유저의 UID

  const ReportPage({Key? key, required this.reportedUid}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _subjectController = TextEditingController(); // 제목 입력 필드
  final TextEditingController _messageController = TextEditingController(); // 내용 입력 필드
  final TextEditingController _emailController = TextEditingController();   // 이메일 입력 필드
  String? senderUid; // 발신자 UID

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // 초기화 시 로그인된 유저의 UID를 가져옴
  }

  // 현재 로그인된 사용자의 UID를 가져오는 함수
  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        senderUid = currentUser.uid; // 로그인된 사용자의 UID 저장
      });
    }
  }

  // 신고하기 버튼 클릭 시 호출
  void _submitReport() async {
    if (senderUid == null) {
      // 발신자 UID가 없으면 오류 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인되지 않았습니다.')),
      );
      return;
    }

    final subject = _subjectController.text; // 제목 가져오기
    final message = _messageController.text; // 내용 가져오기
    final replyToEmail = _emailController.text; // 답변 받을 이메일 가져오기

    if (subject.isEmpty || message.isEmpty || replyToEmail.isEmpty) {
      // 제목, 내용, 이메일 중 하나라도 비어있으면 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목, 내용, 그리고 이메일을 입력하세요.')),
      );
      return;
    }

    // 이메일 전송 함수 호출
    await sendEmail(subject, message, replyToEmail, widget.reportedUid, senderUid!);

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('신고가 접수되었습니다.')),
    );

    // 입력 필드 초기화
    _subjectController.clear();
    _messageController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 배경을 투명하게 설정
        elevation: 0,
        // automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar의 배경색 설정
          ),
        ),
        centerTitle: true,
        title: Text(
          '유저 신고',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(), // 경계 추가
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2.0), // 포커스 시 경계 색상 변경
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // 기본 경계
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '내용',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(), // 경계 추가
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2.0), // 포커스 시 경계 색상 변경
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // 기본 경계
                ),
              ),
              maxLines: 7,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: '답변 받을 이메일 ',
                    style: TextStyle(
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: '(예: waitfree@naver.com)',
                        style: TextStyle(
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                hintText: '이메일을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12), // 힌트 텍스트 크기 조정
                border: const OutlineInputBorder(), // 경계 추가
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2.0), // 포커스 시 경계 색상 변경
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // 기본 경계
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text('신고하기', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCAE5E4),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "운영자가 신고 내용을 검토한 후 적절한 조치를 취할 예정입니다. "
                    "신고 내용은 구체적으로 작성해주시면 문제 해결에 큰 도움이 됩니다. "
                    "허위 신고는 불이익을 초래할 수 있으니 신중하게 작성 부탁드립니다.",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
