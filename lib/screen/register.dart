import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _businessNumberController = TextEditingController();
  final TextEditingController _crowdedThresholdController = TextEditingController();
  final TextEditingController _relaxedThresholdController = TextEditingController();

  bool _isLoading = false;

  Future<void> saveToFirestore() async {
    if (_formKey.currentState!.validate()) {
      // 혼잡 기준이 여유 기준보다 큰지 확인
      final crowdedThreshold = int.parse(_crowdedThresholdController.text);
      final relaxedThreshold = int.parse(_relaxedThresholdController.text);

      if (crowdedThreshold <= relaxedThreshold) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('혼잡 기준 인원은 여유 기준 인원보다 많아야 합니다.')),
        );
        return;
      }

      // 혼잡과 여유 기준 인원 모두 1 이상이어야 함
      if (crowdedThreshold < 1 || relaxedThreshold < 1) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('혼잡 기준 인원과 여유 기준 인원은 1 이상이어야 합니다.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // 현재 로그인된 사용자의 UID 가져오기
        final User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Firestore에 데이터 추가
        await _firestore.collection('shoprequest').add({
          'businessName': _businessNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'contact': _contactController.text.trim(),
          'address': _addressController.text.trim(),
          'businessNumber': _businessNumberController.text.trim(),
          'crowdedThreshold': crowdedThreshold,
          'relaxedThreshold': relaxedThreshold,
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': user.uid, // 현재 로그인된 사용자의 UID 추가
        });

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업체 등록 신청이 완료되었습니다!')),
        );

        clearForm();
        Navigator.pushNamed(context, "/");

      } catch (e) {
        print('Firestore 저장 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('등록 중 오류가 발생했습니다.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 입력 필드 초기화
  void clearForm() {
    _businessNameController.clear();
    _ownerNameController.clear();
    _contactController.clear();
    _addressController.clear();
    _businessNumberController.clear();
    _crowdedThresholdController.clear();
    _relaxedThresholdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("업체등록", style: TextStyle(color: Colors.teal[200], fontSize: 20)),
        backgroundColor: const Color(0xFFFFFFFF),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Text(
                  '업체 등록을 시작합니다!',
                  style: TextStyle(fontSize: 24, color: Color(0xFF8BD2CF)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                businessNameInput(),
                const SizedBox(height: 15),
                ownerNameInput(),
                const SizedBox(height: 15),
                contactInput(),
                const SizedBox(height: 15),
                addressInput(),
                const SizedBox(height: 15),
                businessNumberInput(),
                const SizedBox(height: 15),
                crowdedThresholdInput(),
                const SizedBox(height: 15),
                relaxedThresholdInput(),
                const SizedBox(height: 50),
                registerButton(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 등록하기 버튼
  ElevatedButton registerButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : saveToFirestore,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLoading ? Colors.grey : const Color(0xFFCAE5E4),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Padding(
        padding: EdgeInsets.all(15),
        child: Text("등록하기", style: TextStyle(fontSize: 18, color: Colors.black)),
      ),
    );
  }

// 공통 입력 필드 스타일
  InputDecoration _inputDecoration(String label) {
    final splitLabel = label.split('('); // 라벨과 예시를 분리
    final mainLabel = splitLabel[0].trim(); // 라벨 부분
    final hint = splitLabel.length > 1 ? '(${splitLabel[1]}' : ''; // 예시 부분

    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: mainLabel,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
          ),
          children: [
            if (hint.isNotEmpty)
              TextSpan(
                text: ' $hint', // 예시 부분 추가
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                ),
              ),
          ],
        ),
      ),
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      errorStyle: const TextStyle(color: Colors.red),
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal, width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    );
  }

  TextFormField buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      validator: (val) => val == null || val.isEmpty ? '정보를 입력해주세요.' : null,
      decoration: _inputDecoration(label), // 수정된 InputDecoration 적용
      keyboardType: keyboardType,
    );
  }

// 각 입력란
  TextFormField businessNameInput() =>
      buildTextField(_businessNameController, '업체명 (예: 웨잇카페)');
  TextFormField ownerNameInput() =>
      buildTextField(_ownerNameController, '대표자 이름 (예: 홍길동)');
  TextFormField contactInput() =>
      buildTextField(_contactController, '연락처 (예: 010-2222-3333)');
  TextFormField addressInput() =>
      buildTextField(_addressController, '주소 (예: 경상북도 구미시 대학로 61)');
  TextFormField businessNumberInput() =>
      buildTextField(_businessNumberController, '사업자 등록 번호 (예: ***-**-*****)');

// 숫자만 입력받아야 하는 필드
  TextFormField crowdedThresholdInput() {
    return buildTextField(
      _crowdedThresholdController,
      '혼잡 기준 인원 (예: 10)',
      keyboardType: TextInputType.number,
    );
  }

  TextFormField relaxedThresholdInput() {
    return buildTextField(
      _relaxedThresholdController,
      '여유 기준 인원 (예: 5)',
      keyboardType: TextInputType.number,
    );
  }


}
