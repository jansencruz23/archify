import 'package:archify/components/my_comment_text_field.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../components/my_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  int _selectedIndex = 0;
  late bool _setupNavigationTriggered;

  bool _isKeyboardVisible = false; //For Keyboard to remove navbar visibility -AAlfonso

  final CarouselController _carouselController = CarouselController();
  int _currentIndex = 0; // Track the current index
  int realIndex = 0; // To store real index

// Sample data for carousel images and dates
  final List<Map<String, String>> carouselData = [
    {
      'image': 'lib/assets/images/Book_img.png',
      'date': '2024-11-17',
      'description': 'let’s read...',
    },
    {
      'image': 'lib/assets/images/sample_Image2.jpg',
      'date': '2024-11-16',
      'description': 'City of stars',
    },
    {
      'image': 'lib/assets/images/sample_Image3.jpg',
      'date': '2024-11-15',
      'description': 'Lagay tayo maximum input text',
    },
  ];
//Sample data sa commentss
  final List<Map<String, dynamic>> _dummyComments = [
    {
      "name": "AAlfonso",
      "comment": "WOWOWOWOW bookworm",
      'avatar': 'lib/assets/images/AAlfonso_img.png',
    },
    {
      "name": "JSalem",
      "comment": "Da best 'to!",
      'avatar': 'lib/assets/images/JSalem_img.png',
    },
    {
      "name": "JCruz",
      "comment": "ganda ng shottt",
      'avatar': 'lib/assets/images/JCruz_img.png',
    },
  ];

  late final TextEditingController _commentController;

  late final FocusNode _fieldComment;




  @override
  void initState() {
    super.initState();
    _setupNavigationTriggered = false;

    _fieldComment = FocusNode();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _checkIfNewUser();
    });

    _commentController = TextEditingController();

    _fieldComment.addListener(() {
      setState(() {
        _isKeyboardVisible = _fieldComment.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _fieldComment.dispose();

    super.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _checkIfNewUser();
    });
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  Future<void> _checkIfNewUser() async {
    if (_setupNavigationTriggered) return;

    final user = await _userProvider.getCurrentUserProfile();

    if (user != null && user.isNew) {
      _setupNavigationTriggered = true;
      if (mounted) {
        goSetup(context);
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logoutInFirebase();
    if (mounted) goRootPage(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  //Add a comment
  // void addComment(String commentText){
  //   FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").add({
  //     "CommentText": commentText,
  //     // "CommentedBy": current.
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Scaffold(
                  // AppBar with custom height
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(70),
                    child: AppBar(
                      // Leading section with profile picture and welcome text
                      titleSpacing: 0,
                      leadingWidth: 100,

                      leading: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Profile picture widget
                            MyProfilePicture(
                              height: 60,
                              width: 60,
                              onProfileTapped: () {},
                            ),
                          ],
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome back text
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontSize: 16),
                            ),
                            // User's name text
                            Text(
                              userProfile == null
                                  ? 'Loading'
                                  : userProfile.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification icon button
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_outlined,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(1),
                        child: Divider(
                          height: 2,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),

                  //AAlfonso notes, updated para invisible navbar when typing
                  bottomNavigationBar: _isKeyboardVisible
                      ? null // Hide navbar when keyboard is visible
                      : MyNavbar(
                          selectedIndex: _selectedIndex,
                          onItemTapped: _onItemTapped,
                          showVerticalBar: true,
                          isRotated: true,
                          toggleRotation: () {},

                          // _isKeyboardVisible: _isKeyboardVisible, //NOTE: Need Key sa navbar para gumana
                        ),

                  //Main Body
                  body: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              GFImageOverlay(
                                image: AssetImage(
                                    'lib/assets/images/Bestday_img.png'),
                                shape: BoxShape.circle,
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Best of the Day',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: _getClampedFontSize(context, 0.05),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Carousel
                        CarouselSlider.builder(

                          itemCount: carouselData.length,
                          itemBuilder: (context, index, realIndex) {

                            // realIndex = index;

                            bool isMainPhoto = this.realIndex == index; //Gamiting Index yung Day

                            print("isMainPhoto: $isMainPhoto"); // Pang debug lang AAlfonso


                            return Stack(
                              children: [
                                // Container Image
                                Container(
                                  width:
                                      MediaQuery.of(context).size.height * 0.4,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        35),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          carouselData[index]['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(
                                              0.5), // Gradient para sa text
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),

                                // Text and date
                                if (isMainPhoto)
                                  Positioned(
                                    bottom: 30,
                                    left: 10,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      child: Text(
                                        carouselData[index]['description'] ??
                                            'No description',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                //date
                                if (isMainPhoto)
                                  Positioned(
                                    bottom: 5,
                                    left: 10,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      child: Text(
                                        carouselData[index]['date']!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                //heart and save button
                                if (isMainPhoto)
                                  Positioned(
                                    bottom: 0,
                                    right: 10,
                                    child: Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // To make buttons not take up full space
                                      mainAxisAlignment: MainAxisAlignment
                                          .start, // Al // To make buttons not take up full space
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.favorite_border,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiaryContainer),
                                          onPressed: () {

                                            // Handle the heart button press
                                          },
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.bookmark_border,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                          ),
                                          onPressed: () {
                                            // Handle the save button press
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                          options: CarouselOptions(
                              enlargeCenterPage: true,
                              height: MediaQuery.of(context).size.height *
                                  0.4, // Set the height for the carousel
                              autoPlay: false,
                              viewportFraction: 0.7),
                        ),

                        //View Comment Icon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // When comment icon is pressed, focus on the comment text field
                                  FocusScope.of(context)
                                      .requestFocus(_fieldComment);
                                },
                                icon: Icon(
                                  Icons.comment_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  size: 24,
                                ),
                              ),
                              Text(
                                'Comments',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontFamily: 'Sora',
                                  fontSize: _getClampedFontSize(context, 0.04),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Comment Section
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: _dummyComments.map((comment) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Avatar
                                    GFImageOverlay(
                                      image: AssetImage(
                                        comment['avatar'] ??
                                            'assets/user_icon.png',
                                      ),
                                      shape: BoxShape.circle,
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    // Comment Text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // If want with name ang comments
                                          // Text(
                                          //   comment['name'] ?? 'Unknown',
                                          //   style: TextStyle(
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 14,
                                          //   ),
                                          // ),
                                          SizedBox(height: 5),
                                          Text(
                                            comment['comment'] ??
                                                'No comment available.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        //Comment Text Field
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              GFImageOverlay(
                                image: AssetImage(
                                    'lib/assets/images/AAlfonso_img.png'),
                                shape: BoxShape.circle,
                                height: 36,
                                width: 36,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: MyCommentTextField(
                                  focusNode: _fieldComment,
                                  controller: _commentController,
                                  hintText: ' Comment...',
                                  obscureText: false,
                                  onSubmitted: (value) {
                                    if (mounted) {
                                      _fieldComment.unfocus();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),

                        //Bottom Padding
                        const SizedBox(height: 30),
                        Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom)),

                        // Test Icons
                        // IconButton(
                        //   onPressed: _logout,
                        //   icon: const Icon(Icons.logout),
                        // ),
                        // IconButton(
                        //   onPressed: () => goSetup(context),
                        //   icon: const Icon(Icons.home),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
