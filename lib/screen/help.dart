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
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isNonEmptyValid(String input, {int minLength = 5}) {
    return input.trim().isNotEmpty && input.trim().length >= minLength;
  }

  void _submitReport() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    final replyToEmail = _emailController.text.trim();

    if (!_isNonEmptyValid(subject)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목은 최소 5자 이상이어야 합니다.')),
      );
      return;
    }

    if (!_isNonEmptyValid(message)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내용은 최소 5자 이상이어야 합니다.')),
      );
      return;
    }

    if (!_isValidEmail(replyToEmail)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 이메일 주소를 입력하세요.')),
      );
      return;
    }

    await sendEmail(subject, message, replyToEmail);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('신고가 접수되었습니다.')),
    );

    _subjectController.clear();
    _messageController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              keyboardType: TextInputType.emailAddress,
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