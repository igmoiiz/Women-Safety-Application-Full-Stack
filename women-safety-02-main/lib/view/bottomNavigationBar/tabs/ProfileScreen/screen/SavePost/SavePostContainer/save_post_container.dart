import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/PostingScreen/Posting_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/homeScreen/widget/InstagramStylePost/Instagram_style_post.dart';

class SavePostContainer extends StatefulWidget {
  @override
  State<SavePostContainer> createState() => _SavePostContainerState();
}

class _SavePostContainerState extends State<SavePostContainer> {
  List<String> savedPosts = [];

  @override
  void initState() {
    super.initState();
    loadSavedPosts();
  }

  Future<void> loadSavedPosts() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        savedPosts = prefs.getStringList('savedPosts') ?? [];
      });
    });
  }

  final TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AllPosts')
          .where(FieldPath.documentId,
              whereIn: savedPosts.isEmpty ? [''] : savedPosts)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        var posts = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var backgroundColorIndex = post['backgroundColor'];
            var fontStyleIndex = post['fontStyle'];
            var likes = (post['likes'] ?? {}) as Map<String, dynamic>;
            var likeCount = post['likeCount'] ?? 0;
            var isLiked =
                likes[FirebaseAuth.instance.currentUser!.uid] ?? false;
            var timestamp = post['timestamp'] as Timestamp?;
            var timeAgo = timestamp != null
                ? timeago.format(timestamp.toDate())
                : 'Just now';

            // Get media related data
            var mediaUrl = post['mediaUrl'];
            var mediaType = post['mediaType'];
            var isAnonymous = post['isAnonymous'];
            var hasMedia = mediaUrl != null && mediaUrl.toString().isNotEmpty;

            return Container(
              margin: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    /// [ Header]
                    _buildPostHeader(post, timeAgo, isAnonymous),

                    /// [ Media Content ] - Add this new section
                    if (hasMedia) _buildMediaContent(mediaUrl, mediaType),

                    /// [ Content]
                    if (post['content'].toString().isNotEmpty)
                      handleBody(backgroundColorIndex, post, fontStyleIndex),

                    /// [ Footer]
                    handleFooter(isLiked, likeCount, post, context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          verticalSpace(screenHeight(context) * 0.09),
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No saved posts',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Posts you save will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(String mediaUrl, String? mediaType) {
    if (mediaType == 'image') {
      return _buildImageContent(mediaUrl);
    } else if (mediaType == 'video') {
      return _buildVideoContent(mediaUrl);
    }
    return SizedBox();
  }

  Widget _buildImageContent(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenMedia(imageUrl, 'image'),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: 350,
        ),
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(CustomColor.buttonColor),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(String videoUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenMedia(videoUrl, 'video'),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: 350,
        ),
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video thumbnail placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
            // Play button
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: CustomColor.buttonColor,
                size: 40,
              ),
            ),
            // Video indicator text
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenMedia(String url, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaView(
          mediaUrl: url,
          mediaType: type,
        ),
      ),
    );
  }

  Container handleFooter(isLiked, likeCount,
      QueryDocumentSnapshot<Object?> post, BuildContext context) {
    // ...existing code...
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildAnimatedActionButton(
            icon: isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _formatCount(likeCount),
            color: isLiked ? Colors.red : Colors.grey[700]!,
            onTap: () => toggleLike(post.id),
          ),
          SizedBox(width: 24),
          _buildAnimatedActionButton(
            icon: CupertinoIcons.chat_bubble,
            label: "Comment",
            color: Colors.grey[700]!,
            onTap: () {
              handleBottomSheet(context, post);
            },
          ),
          Spacer(),
          _buildAnimatedIconButton(
            icon: Icons.bookmark,
            color: CustomColor.buttonColor,
            onTap: () async {
              handleSavePost(post);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(
      QueryDocumentSnapshot post, String timeAgo, String isAnonymous) {
    // ...existing code...
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${post.id}',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: CustomColor.buttonColor,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAnonymous == 'true' ? 'Anonymous' : isAnonymous,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  timeAgo,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // _buildGradientButton(
          //   "Follow",
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }

  Widget handleBody(backgroundColorIndex, QueryDocumentSnapshot<Object?> post,
      fontStyleIndex) {
    // Adjust post content height based on whether there's media
    final bool hasMedia =
        post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        minHeight: hasMedia ? 100 : 240,
      ),
      decoration: BoxDecoration(
        gradient: backgroundColorIndex == 0
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColors[backgroundColorIndex],
                  backgroundColors[backgroundColorIndex].withOpacity(0.8),
                ],
              ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 25,
            vertical: hasMedia ? 20 : 35,
          ),
          child: Text(
            post['content'],
            style: textStyles[fontStyleIndex].copyWith(
              color: Colors.black87,
              fontSize: hasMedia ? 18 : 24,
              height: 1.5,
              shadows: backgroundColorIndex == 0
                  ? []
                  : [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ...existing code for buttons and other UI elements...

  Widget _buildGradientButton(String text, {required VoidCallback onTap}) {
    // ...existing code...
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomColor.buttonColor,
              CustomColor.buttonColor.withOpacity(0.8)
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CustomColor.buttonColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    // ...existing code...
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 200),
            tween: ColorTween(begin: Colors.grey[700], end: color),
            builder: (context, Color? value, child) {
              return Icon(icon, color: value, size: 24);
            },
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // ...existing code...
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ...existing code for format utilities...

  String _formatCount(int count) {
    // ...existing code...
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  // ...existing utility methods...

  Future<void> toggleLike(String postId) async {
    // ...existing code...
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef =
        FirebaseFirestore.instance.collection('AllPosts').doc(postId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);

      if (!postDoc.exists) {
        throw Exception('Post does not exist!');
      }

      Map<String, dynamic> likes =
          (postDoc.data()?['likes'] ?? {}) as Map<String, dynamic>;
      int likeCount = postDoc.data()?['likeCount'] ?? 0;

      if (likes.containsKey(userId)) {
        likes.remove(userId);
        likeCount--;
      } else {
        likes[userId] = true;
        likeCount++;
      }

      transaction.update(postRef, {
        'likes': likes,
        'likeCount': likeCount,
      });
    });
  }

  // ...existing handleBottomSheet and related methods...

  Future<dynamic> handleBottomSheet(
      BuildContext context, QueryDocumentSnapshot<Object?> post) {
    // ...existing code...
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Comments Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Comments',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('AllPosts')
                    .doc(post.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  // ...existing comment list code...
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: CustomColor.buttonColor,
                      ),
                    );
                  }

                  Map<String, dynamic> comments =
                      (snapshot.data!.get('comments') ?? {})
                          as Map<String, dynamic>;

                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet',
                        style: GoogleFonts.urbanist(
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  List<MapEntry<String, dynamic>> commentsList = comments
                      .entries
                      .toList()
                    ..sort((a, b) => (b.value['timestamp'] ?? Timestamp.now())
                        .compareTo(a.value['timestamp'] ?? Timestamp.now()));

                  return ListView.builder(
                    itemCount: commentsList.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      MapEntry<String, dynamic> commentEntry =
                          commentsList[index];
                      Map<String, dynamic> comment = commentEntry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: CustomColor.buttonColor,
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Anonymous',
                                        style: GoogleFonts.urbanist(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        timeago.format(
                                          (comment['timestamp'] as Timestamp?)
                                                  ?.toDate() ??
                                              DateTime.now(),
                                        ),
                                        style: GoogleFonts.urbanist(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    comment['text'] ?? '',
                                    style: GoogleFonts.urbanist(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Comment Input
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      String commentId =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Map<String, dynamic> newComments =
                          Map.from(post['comments'] ?? {});
                      newComments[commentId] = {
                        'text': commentController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                        'userId': FirebaseAuth.instance.currentUser?.uid,
                      };

                      FirebaseFirestore.instance
                          .collection('AllPosts')
                          .doc(post.id)
                          .update({
                        'comments': newComments,
                      });

                      commentController.clear();
                    },
                    icon: Icon(
                      Icons.send_rounded,
                      color: CustomColor.buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleSavePost(var post) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedPostIds = prefs.getStringList('savedPosts') ?? [];

      if (savedPostIds.contains(post.id)) {
        // Remove post ID from saved posts
        savedPostIds.remove(post.id);
        await prefs.setStringList('savedPosts', savedPostIds);

        setState(() {
          savedPosts.remove(post.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post removed from saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing post'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error handling saved post: $e');
    }
  }
}
