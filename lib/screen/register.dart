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

  // Firestore에 데이터 저장 함수
  // Firestore에 데이터 저장 함수
  Future<void> saveToFirestore() async {
    if (_formKey.currentState!.validate()) {
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
          'crowdedThreshold': int.parse(_crowdedThresholdController.text),
          'relaxedThreshold': int.parse(_relaxedThresholdController.text),
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': user.uid, // 현재 로그인된 사용자의 UID 추가
        });

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업체가 성공적으로 등록되었습니다!')),
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
        title: const Text("업체 등록", style: TextStyle(color: Colors.black, fontSize: 20)),
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
                  style: TextStyle(fontSize: 28, color: Color(0xFF8BD2CF)),
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
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC0BFBF)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    );
  }

  // 각 입력란
  TextFormField businessNameInput() => buildTextField(_businessNameController, '업체명');
  TextFormField ownerNameInput() => buildTextField(_ownerNameController, '대표자 이름');
  TextFormField contactInput() => buildTextField(_contactController, '연락처');
  TextFormField addressInput() => buildTextField(_addressController, '주소');
  TextFormField businessNumberInput() => buildTextField(_businessNumberController, '사업자 등록 번호');
  TextFormField crowdedThresholdInput() => buildTextField(_crowdedThresholdController, '혼잡 기준 인원');
  TextFormField relaxedThresholdInput() => buildTextField(_relaxedThresholdController, '여유 기준 인원');

  TextFormField buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      validator: (val) => val == null || val.isEmpty ? '$label 입력해주세요.' : null,
      decoration: _inputDecoration(label),
    );
  }
}
