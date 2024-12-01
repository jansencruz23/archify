import 'package:archify/components/my_comment_text_field.dart';
import 'package:archify/components/my_day.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_provider.dart';
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
  late final DayProvider _dayProvider;
  late final UserProvider _userProvider;
  late bool _setupNavigationTriggered;

  bool _isKeyboardVisible =
      false; //For Keyboard to remove navbar visibility -AAlfonso
  int _selectedIndex = 0;
  bool _showVerticalBar = false;
  bool _isRotated = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _showVerticalBar = !_showVerticalBar;
      }
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  final CarouselController _carouselController = CarouselController();
  String _currentDayId = '';
  int _currentIndex = 0; // Track the current index
  int realIndex = 0; // To store real index
  bool _isInitialLoad = true;

  late final TextEditingController _commentController;
  late final FocusNode _fieldComment;

  @override
  void initState() {
    super.initState();
    _setupNavigationTriggered = false;
    _fieldComment = FocusNode();
    _commentController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _dayProvider = Provider.of<DayProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadUserMoments();
      _checkIfNewUser();
    });

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
      _loadUserMoments();
      _checkIfNewUser();
    });
  }

  Future<void> _loadUserMoments() async {
    await _userProvider.loadUserMoments();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  Future<void> _sendComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    if (_currentDayId.isEmpty) return;

    await _dayProvider.sendComment(comment, _currentDayId);
    _commentController.clear();
  }

  Future<void> _toggleFavorites() async {
    if (_currentDayId.isEmpty) return;

    await _userProvider.toggleFavorites(_currentDayId);
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

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    final userListeningProvider = Provider.of<UserProvider>(context);
    final dayListeningProvider = Provider.of<DayProvider>(context);
    final userProfile = userListeningProvider.userProfile;
    final days = userListeningProvider.moments;
    if (_isInitialLoad && days.isNotEmpty) {
      _currentDayId = days.isEmpty ? '' : days[0].dayId;
    }
    dayListeningProvider.listenToComments(_currentDayId);
    final comments = dayListeningProvider.commentsByDayId;

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
                          showVerticalBar: _showVerticalBar,
                          isRotated: _isRotated,
                          toggleRotation: _toggleRotation,
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
                          itemCount: days.length,
                          itemBuilder: (context, index, realIndex) {
                            if (days.isEmpty) {
                              return const Center(
                                child: Text('No moments available.'),
                              );
                            }
                            final moment = days[index];
                            bool isMainPhoto = this.realIndex == index;

                            return MyDay(
                              moment: moment,
                              isMainPhoto: isMainPhoto,
                              toggleFavorites: _toggleFavorites,
                            );
                          },
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            height: MediaQuery.of(context).size.height * 0.4,
                            autoPlay: false,
                            viewportFraction: 0.7,
                            enableInfiniteScroll: false,
                            reverse: true,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                                _currentDayId = days[index].dayId;
                                _isInitialLoad = false;
                              });
                            },
                          ),
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
                          child: comments[_currentDayId] == null ||
                                  comments[_currentDayId]!.isEmpty
                              ? const Center(
                                  child: Text('No comments available.'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true, // Add this line
                                  itemCount: comments[_currentDayId]!.length,
                                  itemBuilder: (context, index) {
                                    final comment =
                                        comments[_currentDayId]![index];
                                    return ListTile(
                                      leading: GFImageOverlay(
                                        image: Image.network(
                                                comment.profilePictureUrl)
                                            .image,
                                        shape: BoxShape.circle,
                                        height: 36,
                                        width: 36,
                                      ),
                                      title: Text(
                                        comment.content,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          fontFamily: 'Sora',
                                          fontSize: _getClampedFontSize(
                                              context, 0.04),
                                        ),
                                      ),
                                    );
                                  },
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
                              IconButton(
                                onPressed: _sendComment,
                                icon: Icon(Icons.send),
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

                        ElevatedButton(
                          onPressed: () => goProfile(context),
                          child: const Text('Profile'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            goDayGate(context);
                          },
                          child: const Text('Day'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            goJoinOrCreate(context);
                          },
                          child: const Text('Join or Create'),
                        ),

                        // Test Icons
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                        ),
                        IconButton(
                          onPressed: () => goSetup(context),
                          icon: const Icon(Icons.home),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
