import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입", style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: const Color(0xFFFFFFFF),
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
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '닉네임을 입력해주세요.';
        }
        if (val.length < 3) {
          return '닉네임은 3자 이상이어야 합니다.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '닉네임',
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
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  // 이메일 입력란
  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegExp.hasMatch(val)) {
          return '올바른 이메일 형식이 아니에요.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '이메일',
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
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
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
        if (val.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다.';
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
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
            var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _pwdController.text.trim(),
            );

            // Firebase Authentication DisplayName 업데이트
            await result.user?.updateDisplayName(_nicknameController.text.trim());

            // FCM에서 디바이스 토큰 가져오기
            String? deviceToken = await FirebaseMessaging.instance.getToken();

            // Firestore에 추가 정보 저장 (디바이스 토큰 포함)
            await FirebaseFirestore.instance.collection('users').doc(result.user?.uid)
                .set({
              'nickname': _nicknameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(), // 가입일시
              'reservecount': 0, // 기본 예약 카운트를 0으로 설정
              'deviceToken': deviceToken, // 디바이스 토큰 저장
            });

            // 회원가입 완료 후 홈으로 이동
            Navigator.pushNamed(context, "/");
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
