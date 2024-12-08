import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// 이메일 전송 함수
Future<void> sendEmail(
    String subject, String message, String replyToEmail) async {
  // 1. SMTP 서버 설정
  final smtpServer =
      gmail('kangcombi@gmail.com', 'phao roed ujzt lvoz'); // 발신자 이메일과 앱 비밀번호

  // 2. 이메일 메시지 생성
  final emailMessage = Message()
    ..from = Address('kangcombi0@gmail.com', 'Flutter 신고 시스템') // 발신자 정보
    ..recipients.add('kangcombi@gmail.com') // 수신자 이메일
    ..subject = subject // 이메일 제목
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
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
        backgroundColor: Colors.white,
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
                hintText: '제목을 입력하세요', // 힌트 텍스트 추가
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12), // 힌트 텍스트 크기 조정
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
                hintText: '문의 내용을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12), // 힌트 텍스트 크기 조정
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
              child: Text('제출', style: TextStyle(color: Colors.black)),
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
                "문의 내용은 운영자가 검토 후 답변해드릴 예정입니다. 자세히 작성해주시면 보다 신속하고 정확한 답변을 드릴 수 있습니다. 감사합니다.",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
