import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/utils/size.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/PostingScreen/Posting_screen.dart';
import 'package:women_safety/view/bottomNavigationBar/tabs/ProfileScreen/screen/SavePost/SavePostContainer/save_post_container.dart';

class SavePostScreen extends StatefulWidget {
  const SavePostScreen({super.key});

  @override
  State<SavePostScreen> createState() => _SavePostScreenState();
}

class _SavePostScreenState extends State<SavePostScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Save Post',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 21,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
          ),
          verticalSpace(20),
          SavePostContainer(),
        ],
      ))),
    );
  }
}
