import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(200), child: AppBar()),
            ));
    });
  }
}
