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

class InstagramStylePost extends StatefulWidget {
  @override
  State<InstagramStylePost> createState() => _InstagramStylePostState();
}

class _InstagramStylePostState extends State<InstagramStylePost>
    with SingleTickerProviderStateMixin {
  final TextEditingController commentController = TextEditingController();
  late AnimationController _likeController;

  // Add this map to track liked status locally
  final Map<String, bool> _localLikeStatus = {};
  // Add this map to track like counts locally
  final Map<String, int> _localLikeCounts = {};

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AllPosts')
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
            return _buildPostCard(context, posts[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: CustomColor.buttonColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading posts...',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          verticalSpace(screenHeight(context) * 0.09),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.post_add_rounded,
              size: 80,
              color: CustomColor.buttonColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No posts yet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Be the first one to share your thoughts!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/bottomNavigation/addScreen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.buttonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            child: Text(
              'Create Post',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, QueryDocumentSnapshot post) {
    var backgroundColorIndex = post['backgroundColor'];
    var fontStyleIndex = post['fontStyle'];
    var likes = (post['likes'] ?? {}) as Map<String, dynamic>;
    var likeCount = post['likeCount'] ?? 0;
    var isLiked = likes[FirebaseAuth.instance.currentUser!.uid] ?? false;
    var timestamp = post['timestamp'] as Timestamp?;
    var timeAgo =
        timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now';

    // Get media related data
    var mediaUrl = post['mediaUrl'];
    var mediaType = post['mediaType'];
    var isAnonymous = post['isAnonymous'];
    var hasMedia = mediaUrl != null && mediaUrl.toString().isNotEmpty;

    // Initialize local state from Firebase data on first load
    if (!_localLikeStatus.containsKey(post.id)) {
      _localLikeStatus[post.id] = isLiked;
      _localLikeCounts[post.id] = likeCount;
    }

    return Container(
      // margin: EdgeInsets.symmetric(
      //   vertical: 12,
      //   horizontal: 16,
      // ),
      margin: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildPostHeader(post, timeAgo, isAnonymous),

            // Then display content if it's not empty
            if (post['content'].toString().isNotEmpty)
              _buildPostContent(backgroundColorIndex, post, fontStyleIndex),

            // Display media first, if available
            if (hasMedia) _buildMediaContent(mediaUrl, mediaType),

            _buildPostFooter(isLiked, likeCount, post, context),
          ],
        ),
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
        // padding: EdgeInsets.symmetric(horizontal: 6),
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
            // Video thumbnail placeholder (would use VideoThumbnail in a complete implementation)
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
      CupertinoPageRoute(
        builder: (context) => FullScreenMediaView(
          mediaUrl: url,
          mediaType: type,
        ),
      ),
    );
  }

  Widget _buildPostHeader(
      QueryDocumentSnapshot post, String timeAgo, String isAnonymous) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: EdgeInsets.only(left: 8, top: 14, bottom: 4),
      color: Colors.white,
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${post.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CustomColor.buttonColor.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: CustomColor.buttonColor.withOpacity(0.9),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnonymous == 'true' ? 'Anonymous' : isAnonymous,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Icon(Icons.more_vert_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildPostContent(int backgroundColorIndex, QueryDocumentSnapshot post,
      int fontStyleIndex) {
    // Adjust post content height based on whether there's media
    final bool hasMedia =
        post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        minHeight: hasMedia ? 100 : 240,
        minWidth: double.infinity,
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 15,
        ),
        child: Text(
          post['content'],
          style: textStyles[fontStyleIndex].copyWith(
            color: Colors.black87,
            fontSize: 16,
            height: 1.5,
            shadows: backgroundColorIndex == 0
                ? []
                : [
                    Shadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostFooter(bool isLiked, int likeCount,
      QueryDocumentSnapshot post, BuildContext context) {
    // Use local state if available, otherwise use the passed values
    bool localIsLiked = _localLikeStatus.containsKey(post.id)
        ? _localLikeStatus[post.id]!
        : isLiked;

    int localLikeCount = _localLikeCounts.containsKey(post.id)
        ? _localLikeCounts[post.id]!
        : likeCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: localIsLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _formatCount(localLikeCount),
            color: localIsLiked ? Colors.red : Colors.grey[700]!,
            onTap: () => _handleLike(post.id, localIsLiked, localLikeCount),
          ),
          SizedBox(width: 24),
          _buildActionButton(
            icon: CupertinoIcons.chat_bubble,
            label: "Comment",
            color: Colors.grey[700]!,
            onTap: () {
              _showCommentsSheet(context, post);
            },
          ),
          Spacer(),
          _buildBookmarkButton(post),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                icon,
                color: color,
                size: 22,
                key: ValueKey<Color>(color),
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(QueryDocumentSnapshot post) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => handleSavePost(post),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.bookmark_border_rounded,
            color: Colors.grey[700],
            size: 22,
          ),
        ),
      ),
    );
  }

  void _handleLike(String postId, bool currentlyLiked, int currentLikeCount) {
    _likeController.forward(from: 0.0);

    // Update local state immediately for instant UI feedback
    setState(() {
      bool newLikedState = !currentlyLiked;
      _localLikeStatus[postId] = newLikedState;
      _localLikeCounts[postId] =
          newLikedState ? currentLikeCount + 1 : currentLikeCount - 1;
    });

    // Then perform the backend update
    toggleLike(postId);
  }

  void _showCommentsSheet(BuildContext context, QueryDocumentSnapshot post) {
    FocusScope.of(context).unfocus(); // Dismiss any existing keyboard

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important to respond to keyboard
      backgroundColor: Colors.transparent,
      // This ensures the bottom sheet can resize when the keyboard appears
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) => _buildCommentsSheet(context, post),
    );
  }

  Widget _buildCommentsSheet(BuildContext context, QueryDocumentSnapshot post) {
    // Use MediaQuery.of(context).viewInsets.bottom to adjust for keyboard
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(color: Colors.grey[200], height: 1),

            // Comments list
            Expanded(
              child: _buildCommentsList(post),
            ),

            // Comment input - simplify padding here since we're handling it above
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        // Ensure focus works properly by giving it a FocusNode
                        autofocus: false,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  // ...existing code for send button...
                  SizedBox(width: 12),
                  Material(
                    color: CustomColor.buttonColor,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: () => _postComment(post),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
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

  Widget _buildCommentsList(QueryDocumentSnapshot post) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AllPosts')
          .doc(post.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: CustomColor.buttonColor,
            ),
          );
        }

        Map<String, dynamic> comments =
            (snapshot.data!.get('comments') ?? {}) as Map<String, dynamic>;

        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.chat_bubble_text,
                  size: 48,
                  color: Colors.grey[350],
                ),
                SizedBox(height: 16),
                Text(
                  'No comments yet',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Be the first to leave a comment',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        List<MapEntry<String, dynamic>> commentsList = comments.entries.toList()
          ..sort((a, b) => (b.value['timestamp'] ?? Timestamp.now())
              .compareTo(a.value['timestamp'] ?? Timestamp.now()));

        return ListView.separated(
          itemCount: commentsList.length,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey[200],
            height: 24,
          ),
          itemBuilder: (context, index) {
            MapEntry<String, dynamic> commentEntry = commentsList[index];
            Map<String, dynamic> comment = commentEntry.value;

            return _buildCommentItem(comment);
          },
        );
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: CustomColor.buttonColor.withOpacity(0.8),
          child: Icon(
            Icons.person,
            size: 22,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Anonymous',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    timeago.format(
                      (comment['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now(),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                comment['text'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(QueryDocumentSnapshot post) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ),
          SizedBox(width: 12),
          Material(
            color: CustomColor.buttonColor,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              onTap: () => _postComment(post),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _postComment(QueryDocumentSnapshot post) {
    if (commentController.text.trim().isEmpty) return;

    String commentId = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> newComments = Map.from(post['comments'] ?? {});
    newComments[commentId] = {
      'text': commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };

    FirebaseFirestore.instance.collection('AllPosts').doc(post.id).update({
      'comments': newComments,
    });

    commentController.clear();
  }

  // The remaining methods (toggleLike, handleSavePost) remain the same,
  // just format them in a cleaner way

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  Future<void> toggleLike(String postId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef =
        FirebaseFirestore.instance.collection('AllPosts').doc(postId);

    // Don't wait for transaction to complete before continuing UI flow
    FirebaseFirestore.instance.runTransaction((transaction) async {
      try {
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

        return true;
      } catch (e) {
        print('Error in like transaction: $e');
        return false;
      }
    }).catchError((error) {
      // If the transaction fails, revert the local state
      setState(() {
        // Get the current local state
        bool currentLiked = _localLikeStatus[postId] ?? false;
        int currentCount = _localLikeCounts[postId] ?? 0;

        // Revert to opposite
        _localLikeStatus[postId] = !currentLiked;
        _localLikeCounts[postId] =
            currentLiked ? currentCount - 1 : currentCount + 1;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update like. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> handleSavePost(var post) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedPostIds = prefs.getStringList('savedPosts') ?? [];

      if (savedPostIds.contains(post.id)) {
        // Remove post ID from saved posts in SharedPreferences
        savedPostIds.remove(post.id);
        await prefs.setStringList('savedPosts', savedPostIds);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post removed from saved'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Add post ID to saved posts in SharedPreferences
        savedPostIds.add(post.id);
        await prefs.setStringList('savedPosts', savedPostIds);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving post'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error saving post: $e');
    }
  }
}

// Add this class for full-screen media viewing
class FullScreenMediaView extends StatelessWidget {
  final String mediaUrl;
  final String mediaType;

  const FullScreenMediaView({
    required this.mediaUrl,
    required this.mediaType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: mediaType == 'image'
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: mediaUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 72,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Video Player would be implemented here',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // In a real implementation, you would launch a video player or
                        // open the URL in a browser that can play videos
                        // launchUrl(Uri.parse(mediaUrl));
                      },
                      child: Text('Play Video'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
