import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _authProvider = Provider.of<AuthProvider>(context, listen: false);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Login
  Future<void> login() async {
    _authProvider.setLoading(true);

    try {
      await _authProvider.loginEmailPassword(
          emailController.text, passwordController.text);
    } catch (ex) {
      // replace with custom show dialog for errros
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(ex.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Login header text
            const Text('Log In'),

            // Space between login and text boxes
            const SizedBox(height: 30),

            // Login text field
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            // Space
            const SizedBox(height: 30),

            // Password text field
            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),

            // Space
            const SizedBox(height: 30),

            // Login button
            MyButton(
              text: 'Login',
              onTap: () async => login(),
            ),

            // Space
            const SizedBox(height: 30),

            // dont have an acc?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                const SizedBox(width: 5),
                GestureDetector(
                  child: const Text('Sign up'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
