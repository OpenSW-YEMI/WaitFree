import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report.dart'; // report.dart 페이지 import

class UserInfoPage extends StatefulWidget {
  final String userId; // 특정 유저의 UID

  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String? currentReaction; // 현재 반응 상태 (like / dislike / null)
  int likeCount = 0;
  int dislikeCount = 0;
  String? currentUserId; // 현재 로그인된 유저의 UID

  // 현재 유저의 반응을 가져오는 함수
  Future<void> fetchCurrentReaction() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final reactionDoc = FirebaseFirestore.instance.collection('reactions')
        .doc('$currentUserId-${widget.userId}'); // 유저 간 반응 문서

    final reactionSnapshot = await reactionDoc.get();
    if (reactionSnapshot.exists) {
      setState(() {
        currentReaction = reactionSnapshot.data()?['reactionType'];
      });
    } else {
      setState(() {
        currentReaction = null;
      });
    }
  }

  // 좋아요/싫어요 개수 가져오기
  Future<void> fetchReactionsCount() async {
    final reactionsSnapshot = await FirebaseFirestore.instance
        .collection('reactions')
        .where('targetUserId', isEqualTo: widget.userId)
        .get();

    int likes = 0;
    int dislikes = 0;

    for (var doc in reactionsSnapshot.docs) {
      final reactionType = doc['reactionType'];
      if (reactionType == 'like') {
        likes++;
      } else if (reactionType == 'dislike') {
        dislikes++;
      }
    }

    setState(() {
      likeCount = likes;
      dislikeCount = dislikes;
    });
  }

  Future<void> toggleReaction(String targetUserId, String reactionType) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // 사용자가 로그인되지 않았을 경우
      return;
    }

    final currentUserId = currentUser.uid;
    final reactionDoc = FirebaseFirestore.instance.collection('reactions')
        .doc('$currentUserId-$targetUserId'); // 유니크한 document ID (유저 간 반응을 구분)

    final reactionSnapshot = await reactionDoc.get();

    if (reactionSnapshot.exists) {
      // 이미 반응이 존재하는 경우 토글 (반응 삭제)
      final existingReaction = reactionSnapshot.data()?['reactionType'];
      if (existingReaction == reactionType) {
        // 같은 반응이면 삭제
        await reactionDoc.delete();
        setState(() {
          currentReaction = null;
        });
      } else {
        // 다른 반응이면 업데이트
        await reactionDoc.update({'reactionType': reactionType});
        setState(() {
          currentReaction = reactionType;
        });
      }
    } else {
      // 반응이 없다면 새로 추가
      await reactionDoc.set({
        'userId': currentUserId,
        'targetUserId': targetUserId,
        'reactionType': reactionType,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        currentReaction = reactionType;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.uid; // 현재 로그인된 유저의 UID를 저장
      });
    }
    fetchCurrentReaction(); // 화면 로드 시 현재 반응 상태를 불러옴
    fetchReactionsCount(); // 좋아요/싫어요 개수 가져오기
  }

  @override
  Widget build(BuildContext context) {
    // 좋아요와 싫어요 비율 계산
    final totalReactions = likeCount + dislikeCount;
    final likePercentage = totalReactions > 0 ? likeCount / totalReactions : 0.0;
    final dislikePercentage = totalReactions > 0 ? dislikeCount / totalReactions : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 프로필', style: TextStyle(color: Colors.teal[200], fontSize: 20),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('사용자 정보를 불러오는 중 오류가 발생했습니다.'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('사용자 정보를 찾을 수 없습니다.'),
            );
          }

          // 사용자 데이터
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String displayName = userData['nickname'] ?? '이름 없음';
          final String email = userData['email'] ?? '이메일 없음';
          final String profileImageUrl = userData['profileImage'] ?? '';
          final int reservationCount = userData['reservecount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 이미지
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/icon/icon_person.png') as ImageProvider,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),

                // 사용자 이름
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // 사용자 이메일
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // 예약 횟수
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      '예약 횟수: $reservationCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 좋아요 / 싫어요 비율 막대
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[300],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 250 * likePercentage, // 좋아요 비율
                            height: 10,
                            color: Colors.blue,
                          ),
                          Container(
                            width: 250 * dislikePercentage, // 싫어요 비율
                            height: 10,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 좋아요 / 싫어요 버튼
                // 현재 로그인된 유저가 본인이면 버튼을 숨긴다
                if (currentUserId != widget.userId) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: currentReaction == 'like' ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () async {
                          await toggleReaction(widget.userId, 'like');
                          fetchReactionsCount(); // 반응 상태를 새로 고침
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          color: currentReaction == 'dislike' ? Colors.red : Colors.grey,
                        ),
                        onPressed: () async {
                          await toggleReaction(widget.userId, 'dislike');
                          fetchReactionsCount(); // 반응 상태를 새로 고침
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // 신고 버튼 추가
                if (currentUserId != widget.userId) ...[
                  ElevatedButton(
                    onPressed: () {
                      // 신고 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportPage(reportedUid: widget.userId),
                        ),
                      );
                    },
                    child: Text('신고', style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCAE5E4),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      textStyle: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                // 기타 사용자 정보 (필요 시 추가)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          '회원 가입일: ${userData['createdAt'] ?? '정보 없음'}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
