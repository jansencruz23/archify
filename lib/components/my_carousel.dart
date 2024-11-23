//
// import 'package:flutter/material.dart';
//
// import 'package:carousel_slider/carousel_slider.dart';
//
// class MyCarousel extends StatefulWidget {
//
//
//   const MyCarousel({super.key});
//
//   @override
//   State<MyCarousel> createState() => _MyCarouselState();
// }
//
// class _MyCarouselState extends State<MyCarousel> {
//   final CarouselController _carouselController = CarouselController();
//   int _currentIndex = 0; // Store the current carousel index
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CarouselSlider.builder(
//
//           itemCount: carouselData.length,
//           itemBuilder: (context, index, realIndex) {
//
//             // realIndex = index;
//
//             bool isMainPhoto = this.realIndex == index;
//
//             print("isMainPhoto: $isMainPhoto");
//             return Stack(
//               children: [
//                 // Container Image
//                 Container(
//                   width:
//                   MediaQuery.of(context).size.height * 0.4,
//                   height:
//                   MediaQuery.of(context).size.height * 0.5,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(
//                         35), // Curved edges
//                     image: DecorationImage(
//                       image: AssetImage(
//                           carouselData[index]['image']!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(35),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.black.withOpacity(
//                               0.5), // Gradient para sa text
//                           Colors.transparent,
//                         ],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.center,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Text and date
//                 if (isMainPhoto)
//                   Positioned(
//                     bottom: 30,
//                     left: 10,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       child: Text(
//                         carouselData[index]['description'] ??
//                             'No description',
//                         style: TextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 //date
//                 if (isMainPhoto)
//                   Positioned(
//                     bottom: 5,
//                     left: 10,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       child: Text(
//                         carouselData[index]['date']!,
//                         style: TextStyle(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .tertiaryContainer,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 //heart and save button
//                 if (isMainPhoto)
//                   Positioned(
//                     bottom: 0,
//                     right: 10,
//                     child: Row(
//                       mainAxisSize: MainAxisSize
//                           .min, // To make buttons not take up full space
//                       mainAxisAlignment: MainAxisAlignment
//                           .start, // Al // To make buttons not take up full space
//                       children: [
//                         IconButton(
//                           padding: EdgeInsets.zero,
//                           icon: Icon(Icons.favorite_border,
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .tertiaryContainer),
//                           onPressed: () {
//                             // Handle the heart button press
//                           },
//                         ),
//                         IconButton(
//                           padding: EdgeInsets.zero,
//                           icon: Icon(
//                             Icons.bookmark_border,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .tertiaryContainer,
//                           ),
//                           onPressed: () {
//                             // Handle the save button press
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             );
//           },
//           options: CarouselOptions(
//               enlargeCenterPage: true,
//               height: MediaQuery.of(context).size.height *
//                   0.4, // Set the height for the carousel
//               autoPlay: false,
//               viewportFraction: 0.7),
//         ),
//
//       ],
//
//
//     );
//   }
// }
