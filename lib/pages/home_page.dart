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

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _checkIfNewUser();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.getCurrentUserProfile();
  }

  Future<void> _checkIfNewUser() async {
    final user = await _userProvider.getCurrentUserProfile();
    if (user != null && user.isNew) {
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  leading: Container(
                    child: Row(
                      children: [
                        MyProfilePicture(
                            height: 50, width: 50, onProfileTapped: () {}),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: MyNavbar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
                body: Column(
                  children: [
                    IconButton(
                      onPressed: () async => _logout(),
                      icon: const Icon(Icons.home),
                    ),
                    IconButton(
                      onPressed: () => goSetup(context),
                      icon: const Icon(Icons.home),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
