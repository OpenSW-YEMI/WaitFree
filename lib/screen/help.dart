import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// 이메일 전송 함수
Future<void> sendEmail(String subject, String message, String replyToEmail) async {
  // 1. SMTP 서버 설정
  final smtpServer = gmail('kangcombi@gmail.com', 'phao roed ujzt lvoz'); // 발신자 이메일과 앱 비밀번호

  // 2. 이메일 메시지 생성
  final emailMessage = Message()
    ..from = Address('kangcombi0@gmail.com', 'Flutter 신고 시스템') // 발신자 정보
    ..recipients.add('kangcombi@gmail.com')                     // 수신자 이메일
    ..subject = subject                                          // 이메일 제목
    ..text = '$message\n\n답변을 받을 이메일 주소: $replyToEmail'; // 이메일 본문에 이메일 주소 추가

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
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _subjectController = TextEditingController(); // 제목 입력 필드
  final TextEditingController _messageController = TextEditingController(); // 내용 입력 필드
  final TextEditingController _emailController = TextEditingController();   // 이메일 입력 필드

  // 신고하기 버튼 클릭 시 호출
  void _submitReport() async {
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
    await sendEmail(subject, message, replyToEmail);

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
        backgroundColor: Colors.transparent, // 배경을 투명하게 설정
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // AppBar의 배경색 설정
          ),
        ),
        centerTitle: true,
        title: Text(
          '문의하기',
          style: TextStyle(
            color: Colors.teal[200],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '답변 받을 이메일'),
              keyboardType: TextInputType.emailAddress, // 이메일 입력 타입으로 설정
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text('제출', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCAE5E4),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
