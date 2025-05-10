import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:women_safety/repositories/PostRepository/post_repository.dart';
import 'package:women_safety/utils/custom_toast.dart';

class PostService {
  final PostRepository _postRepository;

  // Using official Cloudinary package instead of CloudinaryPublic
  final cloudinary = Cloudinary.unsignedConfig(
    cloudName: 'dfwqg2pnf',
  );

  PostService({required PostRepository postRepository})
      : _postRepository = postRepository;

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      print(
          'Uploading image: ${imageFile.path}, size: ${await imageFile.length()} bytes');

      final response = await cloudinary.unsignedUpload(
        file: imageFile.path,
        resourceType: CloudinaryResourceType.image,
        folder: 'women_safety_posts',
        uploadPreset: 'womensafety',
        progressCallback: (count, total) {
          print('Upload progress: ${count / total * 100}%');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('Cloudinary upload successful: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Cloudinary upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  Future<String?> _uploadVideoToCloudinary(File videoFile) async {
    try {
      print(
          'Uploading video: ${videoFile.path}, size: ${await videoFile.length()} bytes');

      final response = await cloudinary.unsignedUpload(
        file: videoFile.path,
        resourceType: CloudinaryResourceType.video,
        folder: 'women_safety_videos',
        uploadPreset: 'womensafety',
        progressCallback: (count, total) {
          print('Upload progress: ${count / total * 100}%');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('Cloudinary video upload successful: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Cloudinary video upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error uploading video to Cloudinary: $e');
      return null;
    }
  }

  Future<void> createPost({
    required BuildContext context,
    required String content,
    required int backgroundColorIndex,
    required int textStyleIndex,
    required String isAnonymous,
    File? imageFile,
    File? videoFile,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        CustomToast.showSnackbar(context, 'User not found');
        return;
      }

      String? mediaUrl;
      String? mediaType;

      // Show loading indicator
      if (imageFile != null || videoFile != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Uploading media...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This might take a moment',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      // Upload media if present
      try {
        if (imageFile != null) {
          mediaUrl = await _uploadImageToCloudinary(imageFile);
          mediaType = 'image';
        } else if (videoFile != null) {
          mediaUrl = await _uploadVideoToCloudinary(videoFile);
          mediaType = 'video';
        }
      } catch (e) {
        print('Error during media upload: $e');
        // Close loading indicator if it was shown
        if ((imageFile != null || videoFile != null) && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (context.mounted) {
          CustomToast.showSnackbar(context, 'Failed to upload media: $e');
        }
        return;
      }

      // Close loading indicator if it was shown
      if ((imageFile != null || videoFile != null) && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if ((imageFile != null || videoFile != null) &&
          mediaUrl == null &&
          context.mounted) {
        CustomToast.showSnackbar(context, 'Failed to upload media');
        return;
      }

      await _postRepository.createPost(
        content: content,
        backgroundColorIndex: backgroundColorIndex,
        textStyleIndex: textStyleIndex,
        isAnonymous: isAnonymous,
        userId: userId,
        imageUrl: mediaUrl,
        mediaType: mediaType,
      );

      if (context.mounted) {
        CustomToast.showSnackbar(context, 'Post created successfully');
      }
    } catch (e) {
      print('Error creating post: $e');
      if (context.mounted) {
        CustomToast.showSnackbar(context, e.toString());
      }
    }
  }
}
