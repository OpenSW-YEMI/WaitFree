import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';

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
      body: Container(
        padding: const EdgeInsets.all(40),
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
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: const Text(
                    '웨잇프리',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF8BD2CF),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 30),
                loginButton(),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      imageName: "kakaoicon.png",
                      onTap: () => signInWithKakao(context),
                    ),
                    const SizedBox(width: 10),
                    SocialLoginButton(
                      imageName: "googleicon.jpg",
                      onTap: () => signInWithGoogle(context),
                    ),
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
        if (val == null || val.isEmpty) {
          return '이메일을 입력해주세요';
        } else if (!RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(val)) {
          return '이메일 형식으로 입력해주세요';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '이메일',
        hintStyle: const TextStyle(color: Color(0xFFC0BFBF)),
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return '비밀번호를 입력해주세요';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '비밀번호',
        hintStyle: const TextStyle(color: Color(0xFFC0BFBF)),
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  ElevatedButton loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            )
                .then((_) => Navigator.pushReplacementNamed(context, "/home"));
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
        backgroundColor: const Color(0xFFCAE5E4),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "로그인",
        style: TextStyle(fontSize: 15, color: Colors.black),
      ),
    );
  }

  Future<void> signInWithKakao(BuildContext context) async {
    if (await isKakaoTalkInstalled()) {
      try {
        // 카카오톡으로 로그인
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공1');

        // Firebase 인증을 위한 토큰 사용
        await _signInWithKakaoFirebase(context, token);
      } catch (error) {
        print('카카오톡으로 로그인 실패1 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        try {
          // 카카오계정으로 로그인
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공2');

          // Firebase 인증을 위한 토큰 사용
          await _signInWithKakaoFirebase(context, token);
        } catch (error) {
          print('카카오계정으로 로그인 실패2 $error');
        }
      }
    } else {
      try {
        // 카카오계정으로 로그인
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공3');

        // Firebase 인증을 위한 토큰 사용
        await _signInWithKakaoFirebase(context, token);
      } catch (error) {
        print('카카오계정으로 로그인 실패3 $error');
      }
    }
  }

// Firebase 인증 처리 함수
  Future<void> _signInWithKakaoFirebase(BuildContext context, OAuthToken token) async {
    try {
      // Firebase에 인증 정보를 전달
      final OAuthCredential credential = OAuthProvider("oidc.readingbuddy").credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      // Firebase 인증
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('Firebase 로그인 성공');

      // Firebase 인증 후 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      print('Firebase 인증 실패: $e');
    }
  }


  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Google 로그인 성공");
      Navigator.pushReplacementNamed(context, "/home");  // 성공 후 라우팅
    } catch (error) {
      print("Google 로그인 실패 $error");
    }
  }
}

class SocialLoginButton extends StatelessWidget {
  final String imageName;
  final VoidCallback onTap;

  const SocialLoginButton({
    Key? key,
    required this.imageName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(50, 50),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icon/$imageName',
          width: 45,
          height: 45,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
