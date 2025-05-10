import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createPost({
    required String content,
    required int backgroundColorIndex,
    required int textStyleIndex,
    required String isAnonymous,
    required String userId,
    String? imageUrl,
    String? mediaType,
  }) async {
    final String postId = DateTime.now().millisecondsSinceEpoch.toString();

    await _firestore.collection('AllPosts').doc(postId).set({
      'postId': postId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'backgroundColor': backgroundColorIndex,
      'fontStyle': textStyleIndex,
      'isAnonymous': isAnonymous,
      'likeCount': 0,
      'likes': {},
      'comments': {},
      'mediaUrl': imageUrl,
      'mediaType': mediaType, // 'image' or 'video' or null
    });
  }
}
