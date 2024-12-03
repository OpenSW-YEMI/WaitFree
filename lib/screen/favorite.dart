import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemi/screen/detail.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  Future<void> _removeLike(String likeId) async {
    try {
      await FirebaseFirestore.instance.collection('likes').doc(likeId).delete();
    } catch (e) {
      print("좋아요 해제 오류: $e");
    }
  }

  Future<void> _removeAllLikes(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("모든 좋아요 삭제 오류: $e");
    }
  }

  // 찜 항목 해제 확인 다이얼로그
  Future<void> _showRemoveLikeDialog(String likeId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찜 해제'),
        content: const Text('이 항목을 찜 목록에서 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('해제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _removeLike(likeId); // 좋아요 해제
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          '로그인이 필요합니다.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 제목과 전체 삭제 버튼
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '찜 목록',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[200],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.grey),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('모든 찜 삭제'),
                          content: const Text('모든 찜 항목을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _removeAllLikes(currentUser.uid);
                        setState(() {}); // 상태 갱신
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 찜 목록
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('likes')
                    .where('userId', isEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('찜한 항목이 없습니다.'));
                  }

                  final List<DocumentSnapshot> likedShops = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: likedShops.length,
                    itemBuilder: (context, index) {
                      final likeId = likedShops[index].id; // 좋아요 항목 ID
                      final shopId = likedShops[index]['shopId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('shop')
                            .doc(shopId)
                            .get(),
                        builder: (context, shopSnapshot) {
                          if (shopSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (shopSnapshot.hasError ||
                              !shopSnapshot.hasData ||
                              !shopSnapshot.data!.exists) {
                            return const ListTile(
                              title: Text('업체 정보를 가져올 수 없습니다.'),
                            );
                          }

                          final shopData = shopSnapshot.data!.data() as Map<String, dynamic>;

                          return Dismissible(
                            key: ValueKey('$likeId-$index'), // 고유 키 설정
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('찜 해제'),
                                  content: const Text('이 항목을 찜 목록에서 해제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _removeLike(likeId); // 좋아요 해제
                                        Navigator.pop(context, true); // 다이얼로그 닫기
                                      },
                                      child: const Text('해제'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                setState(() {
                                  likedShops.removeAt(index); // 로컬 UI 업데이트
                                });
                              }
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                title: Text(
                                  shopData['name'] ?? '이름 없음',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(shopData['address'] ?? '주소 없음'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () async {
                                    await _showRemoveLikeDialog(likeId);
                                    setState(() {}); // 상태 갱신
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        place: {
                                          'id': shopId,
                                          'name': shopData['name'] ?? 'N/A',
                                          'address': shopData['address'] ?? 'N/A',
                                          'lat': shopData['lat'] ?? 0.0,
                                          'lng': shopData['lng'] ?? 0.0,
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
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
