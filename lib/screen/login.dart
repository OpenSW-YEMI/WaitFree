import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Firebase App")),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/icon_clock.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0), // 바텀 마진 설정
                  child: Text(
                    '웨잇프리',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xFF8BD2CF),
                    ),
                  ),
                ),
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                loginButton(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialloginButton("kakaoicon.png"),
                    SizedBox(width: 10), // 버튼 사이에 10픽셀 간격 추가
                    SocialloginButton("navericon.png"),
                    SizedBox(width: 10), // 버튼 사이에 10픽셀 간격 추가
                    SocialloginButton("googleicon.jpg"),
                  ],
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "계정이 없으신가요?",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
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

        // 포커스된 상태의 테두리
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
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

        // 포커스된 상태의 테두리
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          // 여기에 작성
          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: _emailController.text, password: _pwdController.text)
                .then((_) => Navigator.pushNamed(context, "/"));
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              print('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              print('Wrong password provided for that user.');
            }
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
      child: Container(
        alignment: Alignment.center, // 텍스트를 가운데 정렬
        child: const Text(
          "로그인",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black, // 텍스트 색상 설정
          ),
        ),
      ),
    );
  }
}

Widget SocialloginButton(String imageName) {
  return Padding(
    padding: const EdgeInsets.all(5), // 상하좌우 모두 5픽셀 마진 추가
    child: ElevatedButton(
      onPressed: () {
        print('Elevated Button tapped!');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(50, 50), // 정사각형 크기
        padding: EdgeInsets.zero, // 내용물 패딩 제거
        shape: CircleBorder(), // 버튼을 둥글게 만듦
      ),
      child: ClipOval(
        // 이미지를 둥글게 클립
        child: Image.asset(
          'assets/icon/$imageName', // assets 폴더 안에 있는 이미지 파일
          width: 45, // 이미지 크기 조절
          height: 45,
          fit: BoxFit.cover, // 이미지가 버튼 안에 잘 맞도록 설정
        ),
      ),
    ),
  );
}
