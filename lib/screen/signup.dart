import 'package:firebase_auth/firebase_auth.dart';
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
        title: const Text("회원가입", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
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
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                confirmPasswordInput(),
                const SizedBox(height: 15),
                nicknameInput(),
                const SizedBox(height: 15),
                submitButton(),
                const SizedBox(height: 15),
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
      ),
    );
  }

  // 회원가입 버튼
  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );
            Navigator.pushNamed(context, "/");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('비밀번호가 너무 약합니다.');
            } else if (e.code == 'email-already-in-use') {
              print('이미 사용 중인 이메일입니다.');
            }
          } catch (e) {
            print(e.toString());
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFCAE5E4),
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 둥근 정도 조절 (8로 설정)
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          "회원가입",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
