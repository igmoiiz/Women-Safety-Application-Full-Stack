import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/repositories/PostRepository/post_repository.dart';
import 'package:women_safety/services/PostService/post_service.dart';
import 'package:women_safety/utils/custom_color.dart';
import 'package:women_safety/utils/custom_toast.dart';
import 'package:women_safety/utils/showSnackbar.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/PostingScreen/widget/post_options_list.dart';

final List<Color> backgroundColors = [
  Colors.white,
  Color(0xFFFF9E9E), // Soft pink
  Color(0xFF98D8D8), // Soft teal
  Color(0xFFA8E6CF), // Soft green
  Color(0xFF90CAF9), // Soft blue
  Color(0xFFE1BEE7), // Soft purple
  Color(0xFF80DEEA), // Soft cyan
  Color(0xFFFFAB91), // Soft deep orange
  Color(0xFF9FA8DA), // Soft indigo
  Color(0xFFB39DDB), // Soft deep purple
  Color(0xFFDCEDC8), // Soft light green
];

final List<TextStyle> textStyles = [
  GoogleFonts.roboto(),
  GoogleFonts.playfairDisplay(),
  GoogleFonts.montserrat(),
  GoogleFonts.poppins(),
  GoogleFonts.merriweather(),
];

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen>
    with TickerProviderStateMixin {
  Color postBackgroundColor = Colors.white;
  Color postTextColor = Colors.black87;
  TextStyle postTextStyle = GoogleFonts.roboto();
  bool isAnonymous = true;
  final _postController = TextEditingController();
  int backgroundColorIndex = 0;
  int textStyleIndex = 0;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  bool _isLoading = false;

  // Media selection variables
  File? _selectedImage;
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();

  String username = '';

  Future<void> _getSPvalue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _getSPvalue();
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: backgroundColors[backgroundColorIndex],
    ).animate(_colorAnimationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _postController.dispose();
    super.dispose();
  }

  // Image picker method
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedVideo = null; // Clear video if image is selected
        });
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error picking image: $e');
    }
  }

  // Camera method
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedVideo = null; // Clear video if image is selected
        });
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error taking photo: $e');
    }
  }

  // Video picker method
  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2), // Limit video length
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVideo = File(pickedFile.path);
          _selectedImage = null; // Clear image if video is selected
        });
      }
    } catch (e) {
      CustomToast.showSnackbar(context, 'Error picking video: $e');
    }
  }

  // Clear selected media
  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
    });
  }

  // void _showBottomSheet() {
  //   showModalBottomSheet(
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) => Container(
  //       height: screenHeight(context) * 0.6,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black12,
  //             blurRadius: 10,
  //             spreadRadius: 2,
  //           ),
  //         ],
  //       ),
  //       child: PostOptionsList(),
  //     ),
  //   );
  // }

  void _toggleBackgroundColor() {
    setState(() {
      backgroundColorIndex =
          (backgroundColorIndex + 1) % backgroundColors.length;
      postBackgroundColor = backgroundColors[backgroundColorIndex];
      postTextColor = (postBackgroundColor == Colors.white)
          ? Colors.black87
          : Colors.black87;

      _colorAnimationController.reset();
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value ?? Colors.white,
        end: postBackgroundColor,
      ).animate(_colorAnimationController);
      _colorAnimationController.forward();
    });
  }

  void _changeFontStyle() {
    setState(() {
      textStyleIndex = (textStyleIndex + 1) % textStyles.length;
      postTextStyle = textStyles[textStyleIndex];
    });
  }

  // Show media picker options
  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          height: 158,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: CustomColor.buttonColor),
                title:
                    Text('Choose from gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: CustomColor.buttonColor),
                title: Text('Take a photo', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createPost() async {
    if (_postController.text.isEmpty &&
        _selectedImage == null &&
        _selectedVideo == null) {
      CustomToast.showSnackbar(context, 'Post cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      final postService = PostService(postRepository: PostRepository());

      await postService.createPost(
        context: context,
        content: _postController.text,
        backgroundColorIndex: backgroundColorIndex,
        textStyleIndex: textStyleIndex,
        isAnonymous: (isAnonymous == true) ? 'true' : username.toString(),
        imageFile: _selectedImage,
        videoFile: _selectedVideo,
      );

      _postController.clear();
      _clearMedia();
    } catch (error) {
      CustomToast.showSnackbar(context, error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Create Post",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: CustomColor.buttonColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Post",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Anonymous switch card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: Text(
                    "Post Anonymously",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Your identity will not be revealed",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  secondary: Icon(
                    isAnonymous ? Icons.visibility_off : Icons.visibility,
                    color: CustomColor.buttonColor,
                  ),
                  activeColor: CustomColor.buttonColor,
                  value: isAnonymous,
                  onChanged: (value) => setState(() => isAnonymous = value),
                ),
              ),
            ),

            // Media preview moved up - display below "Post Anonymously" card
            if (_selectedImage != null || _selectedVideo != null)
              Container(
                margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : _selectedVideo != null
                                ? _buildVideoPreview()
                                : Container(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: _clearMedia,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child:
                              Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content area with text input
            Container(
              height: 450,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Text input area with specific height
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: TextField(
                          controller: _postController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: postTextStyle.copyWith(
                            color: postTextColor,
                            fontSize: 18,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "What's on your mind?",
                            hintStyle: postTextStyle.copyWith(
                              color: const Color.fromARGB(255, 75, 74, 74),
                              fontSize: 18,
                            ),
                            isCollapsed: true, // Important for proper text alignment
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Format buttons section
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFormatButton(
                            icon: Icons.text_fields,
                            label: "Font",
                            onTap: _changeFontStyle,
                          ),
                          SizedBox(width: 8),
                          _buildFormatButton(
                            icon: Icons.palette,
                            label: "Background",
                            onTap: _toggleBackgroundColor,
                          ),
                          SizedBox(width: 8),
                          _buildFormatButton(
                            icon: Icons.photo_camera,
                            label: "Media",
                            onTap: _showMediaPickerOptions,
                          ),
                        ],
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

  // New helper method to build video preview
  Widget _buildVideoPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
        ),
        Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 64,
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Video',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: CustomColor.buttonColor, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CustomColor.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
