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

  Future<void> _showRemoveLikeDialog(String likeId) async {
    final confirm = await showCustomDialog(
      context: context,
      title: '찜 해제',
      content: '찜 목록에서 해제하시겠습니까?',
      confirmText: '해제',
      cancelText: '취소',
      onConfirm: () {
        _removeLike(likeId); // 좋아요 해제
      },
    );

    if (confirm) {
      setState(() {}); // 상태 갱신
    }
  }

  Future<bool> showDeleteAllFavoritesDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' 모든 찜 삭제 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '모든 찜 항목을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style:  ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 배경을 흰색으로 설정
                          elevation: 0, // 버튼 그림자 제거
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? false;
  }

  Future<bool> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' $title ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily, // 글로벌 폰트
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 배경을 흰색으로 설정
                          elevation: 0, // 버튼 그림자 제거
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리
                            side: BorderSide(color: Colors.grey, width: 0.5), // 경계선 색상과 두께
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),


                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
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
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 제목과 전체 삭제 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 왼쪽 정렬
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 왼쪽 정렬
                        children: [
                          Text(
                            '찜 목록',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[200],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '내가 좋아요를 누른 매장이에요',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[200],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 35),

                          IconButton(
                            icon: Image.asset(
                              'assets/icon/trash_icon.png', // 이미지 경로
                              width: 24,  // 원하는 크기로 조정
                              height: 24, // 원하는 크기로 조정
                            ),
                            onPressed: () async {
                              final confirm = await showDeleteAllFavoritesDialog(context);

                              if (confirm) {
                                await _removeAllLikes(currentUser.uid);
                                setState(() {}); // 상태 갱신
                              }
                            },
                          ),
                        ],
                      )
                      ,
                    ],
                  )
                ],
              ),
            ),
            Center(
              child: Container(
                width: 330,  // 원하는 길이로 설정
                child: Divider(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 세부 안내 문구 추가

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
                              final confirm = await showCustomDialog(
                                context: context,
                                title: '찜 해제',
                                content: '이 항목을 찜 목록에서 해제하시겠습니까?',
                                confirmText: '해제',
                                cancelText: '취소',
                                onConfirm: () {
                                  _removeLike(likeId); // 좋아요 해제
                                },
                              );

                              if (confirm) {
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
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[200]),
                                ),
                                subtitle: Text(shopData['address'] ?? '주소 없음', style: const TextStyle(color: Colors.grey),),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(left: 0.0), // 우측으로 8px 이동
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.red),
                                    onPressed: () async {
                                      await _showRemoveLikeDialog(likeId);
                                      setState(() {}); // 상태 갱신
                                    },
                                  ),
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
