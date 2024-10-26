import 'package:archify/components/my_navbar.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyNavbar(),
      body: IconButton(
          onPressed: () async {
            await Provider.of<AuthProvider>(context, listen: false).logout();
          },
          icon: Icon(Icons.home)),
    );
  }
}
