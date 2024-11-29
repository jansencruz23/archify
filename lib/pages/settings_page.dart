import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/helpers/navigate_pages.dart';

import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late bool _setupNavigationTriggered;

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

  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupNavigationTriggered = false;

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadUserProfile();
      // _checkIfNewUser();
    });

    @override
    void dispose() {

      super.dispose();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _loadUserProfile();
        // _checkIfNewUser();
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
  }

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }




  Future<void> _logout() async {
    await AuthService().logoutInFirebase();
    if (mounted) goRootPage(context);
  }
  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;
    return Consumer<UserProvider>(builder: (context, userProvider, child){
      return _userProvider.isLoading
          ?const Center(child: CircularProgressIndicator())
          : SafeArea(child: Scaffold(
        
        appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: AppBar(
          titleSpacing: 0,
          leadingWidth: 500,


          leading: SizedBox(
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Theme.of(context).colorScheme.inversePrimary), //Add ons --AAlfonso
                  SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.06),
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),


          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 2,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        )
        ),

        //Copy of home page navbar
        bottomNavigationBar: false
            ? null // Hide navbar when keyboard is visible
            : MyNavbar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          showVerticalBar: _showVerticalBar,
          isRotated: _isRotated,
          toggleRotation: _toggleRotation,
          // _isKeyboardVisible: _isKeyboardVisible, //NOTE: Need Key sa navbar para gumana
        ),
      ));
    });
  }
}
