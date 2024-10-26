import 'package:archify/components/my_navbar.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _userProvider = Provider.of<AuthProvider>(context, listen: false);

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
                body: IconButton(
                    onPressed: () async => await _userProvider.logout(),
                    icon: const Icon(Icons.home)),
              );
      },
    );
  }
}
