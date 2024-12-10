import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _key = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();
  final TextEditingController _nicknameController =
      TextEditingController(); // 닉네임 컨트롤러 추가

  String _selectedDomain = '@naver.com'; // 기본 도메인
  final List<String> _domains = [
    '@naver.com',
    '@daum.net',
    '@gmail.com',
    '@kumoh.ac.kr',
    '@hanmail.net',
    '@icloud.com',
    '@outlook.com',
    '@yahoo.com',
    '@nate.com'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입",
            style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: const Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: const Text(
                    '반갑습니다!',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF8BD2CF),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                confirmPasswordInput(),
                const SizedBox(height: 15),
                nicknameInput(),
                const SizedBox(height: 50),
                submitButton(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 닉네임 입력란
  TextFormField nicknameInput() {
    return TextFormField(
      controller: _nicknameController,
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(7), // 7자 이상 입력 불가
      ],
        validator: (val) {
          if (val == null || val.isEmpty) {
            return '닉네임을 입력해주세요.';
          }
          if (val.trim().isEmpty) {
            return '닉네임은 공백만으로 입력할 수 없습니다.'; // 공백만 입력된 경우 에러 메시지
          }
          if (val.length > 7) {
            return '닉네임은 7자 이하로 입력해주세요.';
          }
          if (val.length < 2) {
            return '닉네임은 2자 이상이어야 합니다.';
          }
          return null;
        },
        decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '닉네임',
        hintStyle: const TextStyle(
          color: Color(0xFFC0BFBF),
        ),
          errorStyle: const TextStyle(color: Colors.red),
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  void _showDomainSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정
          // title: const Text('도메인 선택'),
          content: SingleChildScrollView(
            child: Column(
              children: _domains.map((domain) {
                return ListTile(
                  title: Text(domain),
                  onTap: () {
                    setState(() {
                      _selectedDomain = domain; // 선택된 도메인 업데이트
                    });
                    Navigator.pop(context); // 다이얼로그 닫기
                  },
                );
              }).toList(),
            ),
          ),
        );

      },
    );
  }

  Row emailInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _emailController,
            autofocus: true,
            inputFormatters: [
              LengthLimitingTextInputFormatter(320), // 최대 320자 제한
            ],
            validator: (val) {
              if (val == null || val.isEmpty) {
                return '이메일을 입력해주세요.';
              }
              final emailRegExp =
              RegExp(r'^[a-zA-Z0-9._%+-]+$'); // 로컬파트만 유효성 검사
              if (!emailRegExp.hasMatch(val)) {
                return '올바른 이메일 형식이 아니에요.';
              }
              return null;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: '이메일 ID',
              errorStyle: const TextStyle(color: Colors.red),
              hintStyle: const TextStyle(
                color: Color(0xFFC0BFBF),
              ),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        GestureDetector(
          onTap: _showDomainSelectionDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0), // 내부 여백
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5), // 테두리 설정
              borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
              color: Colors.white, // 배경색 설정
            ),
            child: Text(
              '$_selectedDomain 🔻',
              style: const TextStyle(fontSize: 13, color: Colors.black), // 텍스트 스타일
            ),
          ),
        ),
      ],
    );
  }


  // 비밀번호 입력란
  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '비밀번호를 입력해주세요.';
        }
        if (val.length < 8) {
          return '비밀번호는 최소 8자 이상이어야 합니다.';
        }
        if (!RegExp(r'[A-Z]').hasMatch(val)) {
          return '비밀번호에 최소 하나의 대문자가 포함되어야 합니다.';
        }
        if (!RegExp(r'[a-z]').hasMatch(val)) {
          return '비밀번호에 최소 하나의 소문자가 포함되어야 합니다.';
        }
        if (!RegExp(r'[0-9]').hasMatch(val)) {
          return '비밀번호에 최소 하나의 숫자가 포함되어야 합니다.';
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val)) {
          return '비밀번호에 최소 하나의 특수문자가 포함되어야 합니다.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '비밀번호',
        hintStyle: const TextStyle(
          color: Color(0xFFC0BFBF),
        ),
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        errorStyle: const TextStyle(color: Colors.red),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  // 비밀번호 확인 입력란
  TextFormField confirmPasswordInput() {
    return TextFormField(
      controller: _confirmPwdController,
      obscureText: true,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '비밀번호를 다시 입력해주세요.';
        }
        if (val != _pwdController.text) {
          return '비밀번호가 일치하지 않습니다.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '비밀번호 확인',
        hintStyle: const TextStyle(
          color: Color(0xFFC0BFBF),
        ),
        errorStyle: const TextStyle(color: Colors.red),
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  // 회원가입 버튼
  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            // Firebase Authentication 회원가입
            var result =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text.trim() + _selectedDomain,
              password: _pwdController.text.trim(),
            );

            // Firebase Authentication DisplayName 업데이트
            await result.user
                ?.updateDisplayName(_nicknameController.text.trim());

            // FCM에서 디바이스 토큰 가져오기
            String? deviceToken = await FirebaseMessaging.instance.getToken();

            // Firestore에 추가 정보 저장 (디바이스 토큰 포함)
            await FirebaseFirestore.instance
                .collection('users')
                .doc(result.user?.uid)
                .set({
              'nickname': _nicknameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(), // 가입일시
              'reservecount': 0, // 기본 예약 카운트를 0으로 설정
              'deviceToken': deviceToken, // 디바이스 토큰 저장
            });

            // 회원가입 성공 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('회원가입이 완료되었습니다. 새 계정으로 로그인해주세요.')),
            );

            // 로그인 화면으로 이동
            Navigator.pushReplacementNamed(context, "/login");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('비밀번호가 너무 약합니다.')),
              );
            } else if (e.code == 'email-already-in-use') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이미 사용 중인 이메일입니다.')),
              );
            }
          } catch (e) {
            print(e.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('회원가입 중 오류가 발생했습니다.')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCAE5E4),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // 둥근 정도 조절
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          "회원가입",
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }
}
