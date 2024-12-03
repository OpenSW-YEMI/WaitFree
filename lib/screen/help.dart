import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '고객 센터',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '환영한다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '무슨 도움이 필요하니? 아래 버튼 누르렴',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Contact Us Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.teal),
                title: const Text(
                  '문의하기',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text('여기 들어가서 글 적으렴'),
                onTap: () {
                  // Navigate to Contact Form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactFormPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Contact Form Page
class ContactFormPage extends StatelessWidget {
  const ContactFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의하기'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '뭐쓰지',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '문의할 내용을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // 화면 가로 전체를 채우도록 설정
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission (e.g., send message to Firebase)
                    final String message = messageController.text;

                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in the message'),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your message has been sent.'),
                      ),
                    );

                    messageController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCAE5E4),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    '제출',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
