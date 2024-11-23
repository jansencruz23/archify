import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _setupNavigationTriggered = false;

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

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
                    preferredSize: Size.fromHeight(90),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: AppBar(
                        // Leading section with profile picture and welcome text
                        titleSpacing: 10,
                        leadingWidth: 80,
                        leading: Row(
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
                        title: Column(
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
                        // Notification icon button
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
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
                  ),
                  bottomNavigationBar: MyNavbar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                    isRotated: false,
                    showVerticalBar: false,
                    toggleRotation: () {},
                  ),
                  body: Column(
                    children: [
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.home),
                      ),
                      IconButton(
                        onPressed: () => goSetup(context),
                        icon: const Icon(Icons.home),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
