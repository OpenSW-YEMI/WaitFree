import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: const [
          ListTile(
            title: Text('질문 1'),
            subtitle: Text('이곳은 자주 묻는 질문의 내용입니다.'),
          ),
          Divider(),
          ListTile(
            title: Text('질문 2'),
            subtitle: Text('이곳은 자주 묻는 질문의 내용입니다.'),
          ),
          Divider(),
          ListTile(
            title: Text('질문 3'),
            subtitle: Text('이곳은 자주 묻는 질문의 내용입니다.'),
          ),
        ],
      ),
    );
  }
}
