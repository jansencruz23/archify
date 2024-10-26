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
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPwController;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPwController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

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

  // Register with Google
  Future<void> registerWithGoogle() async {
    try {
      // Get user credentials from Google login
      final userCredential = await _authProvider.loginWithGoogle();

      // Check if the user is new -> save user to database and
      if (userCredential != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        _userProvider.setLoading(true);

        final email = _authProvider.getCurrentUser()!.email;
        await _userProvider.saveUser(email!);
      }
    } catch (ex) {
      // replace with custom show dialog for errors
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
              onTap: () async {
                register();
              },
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

            // Replace with my icon button
            MyButton(
              text: 'Sign up with Google',
              onTap: () async => registerWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}
