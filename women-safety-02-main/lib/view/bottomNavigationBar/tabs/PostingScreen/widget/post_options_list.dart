// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:women_safety/utils/constant.dart';
// import 'package:women_safety/utils/custom_color.dart';
// import 'package:women_safety/utils/size.dart';

// class PostOptionsList extends StatefulWidget {
//   const PostOptionsList({super.key});

//   @override
//   State<PostOptionsList> createState() => _PostOptionsListState();
// }

// class _PostOptionsListState extends State<PostOptionsList>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late List<Animation<double>> _itemAnimations;
//   int? _hoveredIndex;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     // Create staggered animations for each list item
//     _itemAnimations = List.generate(
//       options.length,
//       (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _animationController,
//           curve: Interval(
//             (index * 0.1), // Stagger start times
//             (index * 0.1) + 0.6, // Stagger end times
//             curve: Curves.easeOutCubic,
//           ),
//         ),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Handle for bottom sheet
//         Center(
//           child: Container(
//             margin: const EdgeInsets.only(top: 12, bottom: 8),
//             height: 4,
//             width: 40,
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: CustomColor.buttonColor.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.add_circle_outline,
//                   color: CustomColor.buttonColor,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Text(
//                 "Add to your post",
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         verticalSpace(16),
//         Expanded(
//           child: ListView.builder(
//             physics: const BouncingScrollPhysics(),
//             itemCount: options.length,
//             itemBuilder: (context, index) {
//               final option = options[index];
//               return AnimatedBuilder(
//                 animation: _itemAnimations[index],
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(0, 50 * (1 - _itemAnimations[index].value)),
//                     child: Opacity(
//                       opacity: _itemAnimations[index].value,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: option["color"].withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: ListTile(
//                           onTap: () {
//                             // Add tap animation
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('${option["text"]} coming soon!'),
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                           },
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           leading: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: option["color"].withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               option["icon"],
//                               color: option["color"],
//                               size: 24,
//                             ),
//                           ),
//                           title: Text(
//                             option["text"],
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           subtitle: Text(
//                             option["description"],
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               color: Colors.black54,
//                             ),
//                           ),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             size: 16,
//                             color: option["color"],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOptionCard(Map<String, dynamic> option, int index) {
//     bool isHovered = _hoveredIndex == index;

//     return InkWell(
//       onTap: () {
//         // Add tap animation
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${option["text"]} coming soon!'),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       },
//       onHover: (value) {
//         setState(() {
//           _hoveredIndex = value ? index : null;
//         });
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isHovered
//               ? option["color"].withOpacity(0.2)
//               : option["color"].withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: isHovered
//               ? [
//                   BoxShadow(
//                     color: option["color"].withOpacity(0.3),
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                   )
//                 ]
//               : [],
//           border: Border.all(
//             color: option["color"].withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedContainer(
//               duration: Duration(milliseconds: 200),
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: isHovered
//                     ? option["color"]
//                     : option["color"].withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 option["icon"],
//                 color: isHovered ? Colors.white : option["color"],
//                 size: 24,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               option["text"],
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
