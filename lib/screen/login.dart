import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  String? _loginError; // 로그인 오류 메시지를 저장할 변수 추가

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
                if (_loginError != null) // 로그인 오류 메시지가 있을 경우 보여주기
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _loginError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
        errorStyle: const TextStyle(color: Colors.red),
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
        setState(() {
          _loginError = null; // 로그인 시 오류 메시지 초기화
        });

        if (_key.currentState!.validate()) {
          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            )
                .then((_) => Navigator.pushReplacementNamed(context, "/home"));
          } on FirebaseAuthException catch (e) {
            // 아이디 또는 비밀번호 오류 처리
            setState(() {
              if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                _loginError = '아이디 또는 비밀번호가 잘못되었습니다.';
              } else {
                _loginError = '아이디 또는 비밀번호가 잘못되었습니다.';
              }
            });
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

  Future<void> _signInWithKakaoFirebase(BuildContext context, OAuthToken token) async {
    try {
      // Firebase에 인증 정보를 전달
      final OAuthCredential credential = OAuthProvider("oidc.readingbuddy").credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      // Firebase 인증
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('Firebase 로그인 성공');

      // Firebase 인증 후, users 컬렉션에 새로운 사용자 추가
      await _addUserToFirestore(userCredential.user);

      // 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      print('Firebase 인증 실패: $e');
    }
  }

  Future<void> _addUserToFirestore(user) async {
    if (user == null) return;

    // FCM에서 디바이스 토큰 가져오기
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    // Firestore에 새 사용자 정보 저장
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'nickname': user.displayName ?? '새 사용자', // 사용자의 displayName을 저장
      'email': user.email ?? '',  // 이메일이 없을 수 있음
      'createdAt': FieldValue.serverTimestamp(), // 가입일시
      'reservecount': 0, // 기본 예약 카운트를 0으로 설정
      'deviceToken': deviceToken, // 디바이스 토큰 저장
    });
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth == null) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 로그인
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print("Google 로그인 성공");

      // Firebase 인증 후, users 컬렉션에 새로운 사용자 추가
      await _addUserToFirestore(userCredential.user);

      // 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, "/home");
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
