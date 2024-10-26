import 'package:archify/components/my_navbar.dart';
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

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _checkIfNewUser();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return userProvider.isLoading
            // If it is loading display loading circle
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                // Bottom nav bar (replace with custom)
                bottomNavigationBar: const MyNavbar(),
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
