import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_error_dialog.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final _authProvider = Provider.of<AuthProvider>(context, listen: false);
  late final _userProvider = Provider.of<UserProvider>(context, listen: false);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwController = TextEditingController();

  // Register function calling the user provider
  Future<void> register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPwController.text;

    if (password != confirmPassword) {
      showErrorDialog(context, 'Passwords do not match');
      return;
    }

    _userProvider.setLoading(true);

    try {
      // Register in firebase auth
      await _authProvider.registerEmailPassword(email, password);

      // Save user in firebase database
      await _userProvider.saveUser(email);
    } catch (ex) {
      if (mounted) {
        showErrorDialog(context, ex.toString());
      }
    } finally {
      _userProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // App bar
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Login header text
            const Text('Sign Up'),

            // Space between login and text boxes
            const SizedBox(height: 30),

            // Login text field
            MyTextField(
              controller: _emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            // Space
            const SizedBox(height: 30),

            // Password text field
            MyTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),

            // Space
            const SizedBox(height: 30),

            // Password text field
            MyTextField(
              controller: _confirmPwController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),

            // Space
            const SizedBox(height: 30),

            // Login button
            MyButton(
              text: 'Sign Up',
              onTap: () async => register(),
            ),

            // Space
            const SizedBox(height: 30),

            // already have an acc?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
